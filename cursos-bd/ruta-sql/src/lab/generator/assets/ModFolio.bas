Attribute VB_Name = "ModFolio"
Option Compare Database
Option Explicit

' ============================================================================
'  ModFolio - numeracion de protocolos y de comprobantes
'
'  2004-03  Ruben   NroProtocolo = prefijo de la sede + DMax + 1
'  2015-07  Matias  factura electronica: el web service rechaza si el numero
'                   no es el ultimo autorizado + 1 (error 10016). Antes se
'                   usaba DMax sobre Comprobantes; ahora la tabla UltimoNumero
' ============================================================================

' 2004: el numero visible del protocolo. Con una PC por sede anda perfecto.
Public Function ProximoProtocolo(ByVal sede As String) As String
    Dim ultimo As Variant
    ultimo = DMax("Val(Mid(NroProtocolo, 3))", "Protocolos", "Left(NroProtocolo, 1) = '" & sede & "'")
    ProximoProtocolo = sede & "-" & Format$(Nz(ultimo, 0) + 1, "0000000")
End Function

' 2015-07 (la primera semana, hasta que salio el error 10016):
'Public Function ProximoComprobante(ByVal pv As Integer, ByVal tipo As String) As Long
'    ProximoComprobante = Nz(DMax("Numero", "Comprobantes", _
'                         "PuntoVenta = " & pv & " AND TipoComprobante = '" & tipo & "'"), 0) + 1
'End Function

' 2015-07: el numero sale de UltimoNumero. Primero se suma, despues se lee.
Public Function ProximoComprobante(ByVal pv As Integer, ByVal tipo As String) As Long
    Dim db As DAO.Database
    Set db = CurrentDb
    db.Execute "UPDATE UltimoNumero SET Ultimo = Ultimo + 1 " & _
               "WHERE PuntoVenta = " & pv & " AND TipoComprobante = '" & tipo & "'", dbFailOnError + dbSeeChanges
    ProximoComprobante = DLookup("Ultimo", "UltimoNumero", _
                         "PuntoVenta = " & pv & " AND TipoComprobante = '" & tipo & "'")
End Function

' Si el web service rechaza con 10016, se guarda el rechazo y se pide el que corresponde
' con FECompUltimoAutorizado (lo hace el formulario de caja).
Public Sub RegistrarRechazo(ByVal pv As Integer, ByVal tipo As String, ByVal numero As Long, _
                            ByVal codigo As String, ByVal mensaje As String)
    CurrentDb.Execute "INSERT INTO ComprobantesRechazados (Fecha, PuntoVenta, TipoComprobante, Numero, Codigo, Mensaje) " & _
                      "VALUES (Now(), " & pv & ", '" & tipo & "', " & numero & ", '" & codigo & "', '" & _
                      Replace(mensaje, "'", "''") & "')", dbFailOnError + dbSeeChanges
End Sub
