Attribute VB_Name = "ModImportarEquipos"
Option Compare Database
Option Explicit

' ============================================================================
'  ModImportarEquipos - Matias, abril de 2008
'
'  Cada cinco minutos (formulario frmReloj, evento Timer) lee los archivos que
'  dejan los equipos en \\SERVIDOR\equipos\entrada y los carga en ResultadoItem.
'  Formato de los equipos: una linea por determinacion,
'      PROTOCOLO;CODIGO;VALOR;UNIDAD
'  El VALOR se guarda TAL CUAL lo manda el equipo: con coma o con punto segun
'  como este configurado, con < o > cuando sale del rango de medicion, o con
'  HEMOLIZADA / REPETIR. No convertir: si se convierte se pierde lo que dijo
'  el equipo, y Norma firma lo que dijo el equipo.
'
'  2011-07  Matias  ahora inserta en el SQL Server (tabla vinculada, dbSeeChanges)
'  2016-03  Matias  el ARCHITECT manda el protocolo con el prefijo de la sede
' ============================================================================

Public Sub ImportarEquipos()
    Dim carpeta As String, archivo As String
    carpeta = Nz(DLookup("Valor", "Configuracion", "Clave = 'RutaEquipos'"), "")
    If carpeta = "" Then Exit Sub
    archivo = Dir(carpeta & "\*.txt")
    Do While archivo <> ""
        ImportarArchivo carpeta & "\" & archivo
        Name carpeta & "\" & archivo As carpeta & "\procesados\" & archivo
        archivo = Dir()
    Loop
End Sub

Private Sub ImportarArchivo(ByVal ruta As String)
    Dim db As DAO.Database, rs As DAO.Recordset, f As Integer, linea As String
    Dim campos() As String, equipo As String, filas As Long

    Set db = CurrentDb
    Set rs = db.OpenRecordset("ResultadoItem", dbOpenDynaset, dbSeeChanges)
    equipo = EquipoDelArchivo(ruta)
    f = FreeFile
    Open ruta For Input As #f
    Do Until EOF(f)
        Line Input #f, linea
        campos = Split(linea, ";")
        If UBound(campos) >= 3 Then
            rs.AddNew
            rs!IdProtocolo = IdDelProtocolo(campos(0))
            rs!CodDeterminacion = Trim$(campos(1))
            rs!Valor = Trim$(campos(2))                 ' tal cual, ver arriba
            rs!Unidad = Trim$(campos(3))
            rs!RangoReferencia = Nz(DLookup("RangoReferencia", "Determinaciones", _
                                     "CodDeterminacion = '" & Trim$(campos(1)) & "'"), "")
            rs!Equipo = equipo
            rs!FechaCarga = Now()
            rs.Update
            filas = filas + 1
        End If
    Loop
    Close #f
    rs.Close
    db.Execute "INSERT INTO ImportEquipos_log (Fecha, Archivo, Filas) VALUES (Now(), '" & _
               ruta & "', " & filas & ")", dbSeeChanges
End Sub

Private Function EquipoDelArchivo(ByVal ruta As String) As String
    ' COBAS_20080412_0930.txt -> COBAS
    Dim nombre As String
    nombre = Mid$(ruta, InStrRev(ruta, "\") + 1)
    EquipoDelArchivo = Left$(nombre, InStr(nombre & "_", "_") - 1)
End Function

Private Function IdDelProtocolo(ByVal nro As String) As Long
    IdDelProtocolo = Nz(DLookup("IdProtocolo", "Protocolos", "NroProtocolo = '" & Trim$(nro) & "'"), 0)
End Function
