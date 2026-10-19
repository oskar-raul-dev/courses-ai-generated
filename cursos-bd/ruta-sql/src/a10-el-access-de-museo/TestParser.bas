Attribute VB_Name = "TestParser"
Option Explicit

' Characterization tests for ModParser.bas. Expected values come from parse_patients.py,
' which is the behavioural reference. Output goes to the file named by the environment
' variable PARSER_TEST_OUT, because Print opens a dialog in LibreOffice.

Private outFile As Integer
Private passed As Integer
Private failed As Integer

Public Sub Main()
    outFile = FreeFile
    Open Environ("PARSER_TEST_OUT") For Output As #outFile

    CheckParse "clean, all in nombre", "PEREZ PEDRO DNI 23456789 15/03/62 AV COLON 1234", _
        "PEREZ PEDRO", "23456789", "15/03/1962", "AV COLON 1234"
    CheckParse "dotted DNI, no keyword", "LOPEZ JUAN 23.456.789 SAN MARTIN 100", _
        "LOPEZ JUAN", "23456789", "", "SAN MARTIN 100"
    CheckParse "newborn takes mother's DNI", "RN GONZALEZ MARIA DNI 11222333 22/05/01", _
        "RN GONZALEZ MARIA", "11222333", "22/05/2001", ""
    CheckParse "passport taken as DNI", "VARGAS MAMANI JUANA PASAP BOL 4455667 21/12/88 RUTA 20 KM 11", _
        "VARGAS MAMANI JUANA PASAP BOL", "4455667", "21/12/1988", "RUTA 20 KM 11"
    CheckParse "two-digit year 27 -> 2027", "ROMERO NORMA DNI 11154535 12/11/27 OBISPO TREJO 3517", _
        "ROMERO NORMA", "11154535", "12/11/2027", "OBISPO TREJO 3517"
    CheckParse "two-digit year 35 -> 1935", "SOSA RAUL DNI 9337949 23/05/35 DEAN FUNES 3300", _
        "SOSA RAUL", "9337949", "23/05/1935", "DEAN FUNES 3300"
    CheckParse "no DNI, address glued to name", "GONZALEZ MIRTA DEAN FUNES 3427", _
        "GONZALEZ MIRTA DEAN FUNES", "", "", "3427"
    CheckParse "double space", "SOSA  ROSA DNI 30111222", _
        "SOSA ROSA", "30111222", "", ""
    CheckParse "phone ends up in address", "BIANCHI JUAN DNI 35956501 TEL 4262181", _
        "BIANCHI JUAN", "35956501", "", "TEL 4262181"

    CheckEqual "ExtraerDNI with keyword", ExtraerDNI("PEREZ PEDRO DNI 23.456.789"), "23456789"
    CheckEqual "ExtraerDNI without keyword", ExtraerDNI("LOPEZ JUAN 23456789"), "23456789"
    CheckEqual "ExtraerDNI short number is not a DNI", ExtraerDNI("CALLE 25 DE MAYO 1450"), ""
    CheckEqual "ExtraerDNI empty string", ExtraerDNI(""), ""

    Print #outFile, ""
    Print #outFile, passed & " passed, " & failed & " failed"
    Close #outFile
End Sub

Private Sub CheckParse(ByVal label As String, ByVal raw As String, ByVal expName As String, _
                       ByVal expDni As String, ByVal expDate As String, ByVal expAddress As String)
    Dim n As String, d As String, f As String, a As String
    ParsearNombre raw, n, d, f, a
    CheckEqual label & " / nombre", n, expName
    CheckEqual label & " / dni", d, expDni
    CheckEqual label & " / fecha_nac", f, expDate
    CheckEqual label & " / direccion", a, expAddress
End Sub

Private Sub CheckEqual(ByVal label As String, ByVal actual As String, ByVal expected As String)
    If actual = expected Then
        passed = passed + 1
        Print #outFile, "PASS  " & label
    Else
        failed = failed + 1
        Print #outFile, "FAIL  " & label & ": got [" & actual & "] expected [" & expected & "]"
    End If
End Sub
