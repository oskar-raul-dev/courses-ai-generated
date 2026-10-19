Attribute VB_Name = "ModParser"
Option Compare Database
Option Explicit

' ============================================================================
'  ModParser - "el parser"
'  Ruben, marzo de 1998. Version original: todavia no conoce pasaportes
'  (ver la genealogia del parser en historia-de-alameda.md, seccion 3.2).
'
'  La recepcion carga todo junto en el campo nombre, asi:
'      APELLIDO NOMBRE espacio DNI espacio NUMERO espacio FECHA espacio DIRECCION
'  Esto lo separa. Solo toca los pacientes que no tienen DNI cargado,
'  y no pisa la fecha ni la direccion si ya estaban.
'
'  Para correrlo: abrir el modulo, poner el cursor en ParsearPacientes y F5.
'  Hacer una copia de la base ANTES.
' ============================================================================

Private Function EsNumero(ByVal t As String) As Boolean
    Dim i As Integer, c As String
    If Len(t) = 0 Then Exit Function
    For i = 1 To Len(t)
        c = Mid$(t, i, 1)
        If Not (c Like "#" Or c = ".") Then Exit Function
    Next i
    EsNumero = True
End Function

' d/m/aa o d/m/aaaa, siempre dia/mes, sin mirar la configuracion regional.
' Anio de dos cifras: del 00 al 29 es 20xx, como la PC de la recepcion en 1998.
Private Function FechaDMA(ByVal t As String, ByRef f As Date) As Boolean
    Dim p() As String, d As Integer, m As Integer, a As Integer
    p = Split(t, "/")
    If UBound(p) <> 2 Then Exit Function
    If Not (EsNumero(p(0)) And EsNumero(p(1)) And EsNumero(p(2))) Then Exit Function
    If InStr(t, ".") > 0 Then Exit Function
    If Len(p(2)) <> 2 And Len(p(2)) <> 4 Then Exit Function
    d = CInt(p(0)): m = CInt(p(1)): a = CInt(p(2))
    If Len(p(2)) = 2 Then a = IIf(a < 30, 2000 + a, 1900 + a)
    If m < 1 Or m > 12 Or d < 1 Then Exit Function
    f = DateSerial(a, m, d)
    If Day(f) <> d Then Exit Function
    FechaDMA = True
End Function

Private Function EsFecha(ByVal t As String) As Boolean
    Dim f As Date
    EsFecha = FechaDMA(t, f)
End Function

' Separa un nombre "crudo" en sus partes. Devuelve todo por referencia.
Public Sub ParsearNombre(ByVal crudo As String, ByRef nombre As String, ByRef dni As String, _
                         ByRef fecha As String, ByRef direccion As String)
    Dim partes() As String, i As Integer, t As String
    Dim enNombre As Boolean

    nombre = "": dni = "": fecha = "": direccion = ""
    enNombre = True
    partes = Split(Trim$(crudo), " ")

    i = LBound(partes)
    Do While i <= UBound(partes)
        t = partes(i)
        If t = "" Then
            ' doble espacio: se ignora
        ElseIf t = "DNI" And dni = "" And i < UBound(partes) Then
            i = i + 1
            dni = Replace(partes(i), ".", "")
            enNombre = False
        ElseIf EsFecha(t) And fecha = "" Then
            Dim f As Date
            FechaDMA t, f
            fecha = Format$(Day(f), "00") & "/" & Format$(Month(f), "00") & "/" & Year(f)
            enNombre = False
        ElseIf EsNumero(t) And dni = "" And Len(Replace(t, ".", "")) >= 7 Then
            dni = Replace(t, ".", "")
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

Public Sub ParsearPacientes()
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim n As String, d As String, f As String, dirc As String
    Dim cuenta As Long

    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM pacientes WHERE dni Is Null OR dni = ''", dbOpenDynaset)

    Do Until rs.EOF
        ParsearNombre Nz(rs!nombre, ""), n, d, f, dirc
        If d <> "" Then
            rs.Edit
            rs!nombre = n
            rs!dni = d
            If Nz(rs!fecha_nac, "") = "" And f <> "" Then rs!fecha_nac = f
            If Nz(rs!direccion, "") = "" And dirc <> "" Then rs!direccion = dirc
            rs.Update
            cuenta = cuenta + 1
        End If
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing
    MsgBox "Listo. Se separaron " & cuenta & " pacientes.", vbInformation, "Parser"
End Sub
