Attribute VB_Name = "ModParser"
Option Compare Database
Option Explicit

' ============================================================================
'  ModParser - "el parser"
'
'  Ruben, marzo de 1998. La recepcion carga todo junto en el campo nombre:
'      APELLIDO NOMBRE espacio DNI espacio NUMERO espacio FECHA espacio DIRECCION
'  Esto lo separa. Solo toca los pacientes que no tienen DNI cargado,
'  y no pisa la fecha ni la direccion si ya estaban.
'
'  HISTORIA (no borrar)
'  1998-03  Ruben   version original: DNI y el numero, o el primer numero
'                   de siete u ocho cifras
'  2000-01  Ruben   CorregirAnio: los que nacieron "en el futuro" (ver abajo)
'  2003-05  Ruben   pasaporte: P o PASAP, el pais en tres letras y el numero
'                   (la senora de Bolivia de la sede nueva)
'  2005-08  Ruben   LE y LC son como el DNI (los jubilados con libreta)
'  2006-04  Ruben   ExtraerOS: la obra social escrita en el nombre
'  2008-06  Matias  RN al principio: recien nacido, el DNI es el de la madre
'  2011-07  Matias  LimpiarNombre para lo que viene del SQL Server con
'                   espacios de mas
'  2014-02  Matias  ExtraerTelefono, para la tabla ParaLlamar
'  2016-10  Matias  OJO: hay una copia en el SQL Server, dbo.fn_ExtraerDNI,
'                   para los reportes. Si se cambia esto hay que cambiar
'                   aquella tambien
'  2019-11  Matias  OTRO: la paciente con el certificado de residencia
'                   precaria. OTRO y lo que venga, tal cual
'  2020-05  Matias  ParsearPacientesDesde: correr solo sobre lo nuevo,
'                   que con el COVID el parser completo tarda una hora
'
'  Para correrlo: abrir el modulo, poner el cursor en ParsearPacientes y F5.
'  Hacer una copia de la base ANTES.
' ============================================================================

Private Const LARGO_MINIMO_DNI As Integer = 7

' ----------------------------------------------------------------------------
'  Ayudantes
' ----------------------------------------------------------------------------

Private Function EsNumero(ByVal t As String) As Boolean
    Dim i As Integer, c As String
    If Len(t) = 0 Then Exit Function
    For i = 1 To Len(t)
        c = Mid$(t, i, 1)
        If Not (c Like "#" Or c = ".") Then Exit Function
    Next i
    EsNumero = True
End Function

Private Function EsFecha(ByVal t As String) As Boolean
    EsFecha = (InStr(t, "/") > 0) And IsDate(t)
End Function

Private Function SinPuntos(ByVal t As String) As String
    SinPuntos = Replace(t, ".", "")
End Function

' 2011: lo que viene del SQL Server trae espacios de mas y a veces tabs
Public Function LimpiarNombre(ByVal crudo As String) As String
    Dim t As String
    t = Replace(crudo, vbTab, " ")
    t = Replace(t, Chr(160), " ")
    Do While InStr(t, "  ") > 0
        t = Replace(t, "  ", " ")
    Loop
    LimpiarNombre = Trim$(t)
End Function

' ----------------------------------------------------------------------------
'  El parser
' ----------------------------------------------------------------------------

' Separa un nombre "crudo" en sus partes. Devuelve todo por referencia.
Public Sub ParsearNombre(ByVal crudo As String, ByRef nombre As String, ByRef dni As String, _
                         ByRef fecha As String, ByRef direccion As String)
    Dim partes() As String, i As Integer, t As String, u As String
    Dim enNombre As Boolean

    nombre = "": dni = "": fecha = "": direccion = ""
    enNombre = True
    partes = Split(Trim$(crudo), " ")

    i = LBound(partes)
    Do While i <= UBound(partes)
        t = partes(i)
        u = UCase$(t)
        If t = "" Then
            ' doble espacio: se ignora
        ElseIf (u = "DNI" Or u = "LE" Or u = "LC") And dni = "" And i < UBound(partes) Then
            ' 2005: la libreta es como el DNI, el numero es el mismo
            i = i + 1
            dni = SinPuntos(partes(i))
            enNombre = False
        ElseIf (u = "P" Or u = "PASAP") And dni = "" And i + 1 < UBound(partes) Then
            ' 2003: pasaporte. El pais va al nombre entre parentesis, el numero al dni
            nombre = nombre & " (" & partes(i + 1) & ")"
            dni = partes(i + 2)
            i = i + 2
            enNombre = False
        ElseIf u = "OTRO" And dni = "" And i < UBound(partes) Then
            ' 2019: no es DNI ni pasaporte. Se guarda tal cual, con OTRO adelante
            i = i + 1
            dni = "OTRO " & partes(i)
            enNombre = False
        ElseIf u = "RN" And i = LBound(partes) Then
            ' 2008: recien nacido. El DNI que venga es el de la madre y se guarda igual
            nombre = "RN"
        ElseIf EsFecha(t) And fecha = "" Then
            ' CDate con anio de dos digitos: del 00 al 29 lo toma como 20xx
            fecha = Format$(CDate(t), "dd/mm/yyyy")
            enNombre = False
        ElseIf EsNumero(t) And dni = "" And Len(SinPuntos(t)) >= LARGO_MINIMO_DNI Then
            dni = SinPuntos(t)
            enNombre = False
        ElseIf enNombre And Not (Left$(t, 1) Like "#") Then
            nombre = nombre & " " & t
        Else
            enNombre = False
            direccion = direccion & " " & t
        End If
        i = i + 1
    Loop

    nombre = Trim$(nombre)
    direccion = Trim$(direccion)
End Sub

Public Function ExtraerDNI(ByVal crudo As String) As String
    Dim n As String, d As String, f As String, dirc As String
    ParsearNombre crudo, n, d, f, dirc
    ExtraerDNI = d
End Function

Public Function ExtraerNombre(ByVal crudo As String) As String
    Dim n As String, d As String, f As String, dirc As String
    ParsearNombre crudo, n, d, f, dirc
    ExtraerNombre = n
End Function

' 2006: la obra social escrita en el nombre. Devuelve la sigla o vacio.
' Las que no estan en la lista no las encuentra; agregarlas aca.
Public Function ExtraerOS(ByVal crudo As String) As String
    Dim conocidas As Variant, k As Integer, u As String
    conocidas = Array("OSDE", "PAMI", "APROSS", "IPAM", "SANCOR", "SWISS", "GALENO", _
                      "OSECAC", "UOM", "OSPRERA", "DASPU", "PARTICULAR")
    u = " " & UCase$(SinPuntos(crudo)) & " "
    For k = LBound(conocidas) To UBound(conocidas)
        If InStr(u, " " & conocidas(k) & " ") > 0 Then
            ExtraerOS = conocidas(k)
            Exit Function
        End If
    Next k
    ExtraerOS = ""
End Function

' 2014: el telefono con sus notas, "4251234 (VECINA)". Devuelve solo los numeros.
Public Function ExtraerTelefono(ByVal crudo As String) As String
    Dim i As Integer, c As String, salida As String
    For i = 1 To Len(crudo)
        c = Mid$(crudo, i, 1)
        If c Like "#" Then
            salida = salida & c
        ElseIf c = "(" Or c = "/" Then
            Exit For
        End If
    Next i
    ExtraerTelefono = salida
End Function

' ----------------------------------------------------------------------------
'  2000: los que nacieron en el futuro
' ----------------------------------------------------------------------------

' Si la fecha de nacimiento quedo despues de hoy, le resta cien anios.
' Solo para mostrar en el informe: NO se graba (Norma no quiere que se toque).
Public Function CorregirAnio(ByVal fechaNac As Variant) As Variant
    If IsNull(fechaNac) Then
        CorregirAnio = Null
    ElseIf fechaNac > Date Then
        CorregirAnio = DateAdd("yyyy", -100, fechaNac)
    Else
        CorregirAnio = fechaNac
    End If
End Function

Public Function EdadEnAnios(ByVal fechaNac As Variant) As Variant
    Dim f As Variant
    f = CorregirAnio(fechaNac)
    If IsNull(f) Then
        EdadEnAnios = Null
    Else
        EdadEnAnios = DateDiff("yyyy", f, Date) + (Format$(Date, "mmdd") < Format$(f, "mmdd"))
    End If
End Function

' ----------------------------------------------------------------------------
'  Las corridas sobre la tabla
' ----------------------------------------------------------------------------

Public Sub ParsearPacientes()
    ParsearPacientesDesde 0
End Sub

' 2020: con el COVID el parser completo tarda una hora. Esto corre solo
' sobre los pacientes con IdPaciente mayor que el que se le pasa.
Public Sub ParsearPacientesDesde(ByVal desdeId As Long)
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim n As String, d As String, f As String, dirc As String
    Dim cuenta As Long, sql As String

    Set db = CurrentDb
    sql = "SELECT * FROM Pacientes WHERE (DNI Is Null OR DNI = '') AND IdPaciente > " & desdeId
    Set rs = db.OpenRecordset(sql, dbOpenDynaset, dbSeeChanges)

    Do Until rs.EOF
        ParsearNombre LimpiarNombre(Nz(rs!Nombre, "")), n, d, f, dirc
        If d <> "" Then
            rs.Edit
            rs!Nombre = n
            rs!DNI = d
            If Nz(rs!FechaNac, "") = "" And f <> "" Then rs!FechaNac = f
            If Nz(rs!Direccion, "") = "" And dirc <> "" Then rs!Direccion = dirc
            If Nz(rs!ObraSocial, "") = "" Then rs!ObraSocial = ExtraerOS(rs!Nombre)
            rs.Update
            cuenta = cuenta + 1
        End If
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing
    MsgBox "Listo. Se separaron " & cuenta & " pacientes.", vbInformation, "Parser"
End Sub

' Para revisar a mano lo que el parser no entiende. Llena la tabla
' Pacientes_Duplicados_Revisar con los que tienen el mismo DNI.
Public Sub MarcarDuplicados()
    Dim db As DAO.Database, rs As DAO.Recordset, anterior As String, idAnterior As Long
    Set db = CurrentDb
    db.Execute "DELETE FROM Pacientes_Duplicados_Revisar", dbFailOnError + dbSeeChanges
    Set rs = db.OpenRecordset("SELECT IdPaciente, DNI FROM Pacientes WHERE DNI <> '' ORDER BY DNI", _
                              dbOpenSnapshot, dbSeeChanges)
    Do Until rs.EOF
        If rs!DNI = anterior Then
            db.Execute "INSERT INTO Pacientes_Duplicados_Revisar (IdPaciente, IdPacienteDuplicado, Revisado) " & _
                       "VALUES (" & idAnterior & ", " & rs!IdPaciente & ", False)", dbFailOnError + dbSeeChanges
        End If
        anterior = rs!DNI
        idAnterior = rs!IdPaciente
        rs.MoveNext
    Loop
    rs.Close
End Sub

' ----------------------------------------------------------------------------
'  Pruebas rapidas (Ctrl+G y escribir ProbarParser)
' ----------------------------------------------------------------------------

Public Sub ProbarParser()
    Debug.Print ExtraerDNI("PEREZ PEDRO DNI 23456789")              ' 23456789
    Debug.Print ExtraerDNI("PEREZ PEDRO DNI 23.456.789")            ' 23456789
    Debug.Print ExtraerDNI("GONZALEZ MARIA 11222333 OSDE 210")      ' 11222333
    Debug.Print ExtraerDNI("RN GONZALEZ MARIA DNI 11222333")        ' 11222333 (la madre)
    Debug.Print ExtraerDNI("VARGAS MAMANI JUANA PASAP BOL 4455667") ' 4455667
    Debug.Print ExtraerDNI("AGUERO ELVIRA LC 4563218")              ' 4563218
    Debug.Print ExtraerDNI("ZAPATA ANA OTRO 1234/19")               ' OTRO 1234/19
    Debug.Print ExtraerOS("GONZALEZ MARIA 11222333 O.S.D.E 210")    ' OSDE
    Debug.Print ExtraerTelefono("4251234 (VECINA DE ENFRENTE)")     ' 4251234
End Sub
