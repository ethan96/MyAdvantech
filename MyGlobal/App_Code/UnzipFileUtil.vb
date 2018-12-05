Imports Microsoft.VisualBasic
Imports System.IO

Public Class UnzipFileUtil
    Public Shared Function UnzipImage(ByVal Literature_Id As String) As String
        Dim imageID As String = ""
        Dim LitDt As DataTable = dbUtil.dbGetDataTable("My", _
        " Select IsNull(SIEBEL_FILENAME, '') as SIEBEL_FILENAME, IsNull(LIT_NAME, '') as LIT_NAME, " + _
        " IsNull(FILE_NAME, '') as FILE_NAME, IsNull(FILE_EXT, '') as FILE_EXT, LIT_TYPE " + _
        " From LITERATURE " & _
        " Where LITERATURE_ID = '" & Replace(Literature_Id, "'", "''") & "'")

        If Not IsNothing(LitDt) AndAlso LitDt.Rows.Count > 0 Then
            Dim LitName As String = ""
            Dim FileName As String = LitDt.Rows(0).Item("SIEBEL_FILENAME").ToString()

            If LitDt.Rows(0).Item("FILE_EXT").ToString() = "" Then
                LitName = Literature_Id
            Else
                LitName = Literature_Id + "." + LitDt.Rows(0).Item("FILE_EXT").ToString()
            End If
            'Response.Write("\\Crmdb75\siebfile\att\" + FileName)

            imageID = LitName + ":" + FileName
        End If
        Return imageID
    End Function

    Public Shared Function UnzipLit(ByVal Literature_Id As String) As String
        'UnzipSiebelFile("", "")
        'Response.Write("Under Construction")
        Dim unzipFilePath As String = ""
        Dim LitDt As DataTable = dbUtil.dbGetDataTable("My", _
        " Select IsNull(SIEBEL_FILENAME, '') as SIEBEL_FILENAME, IsNull(LIT_NAME, '') as LIT_NAME, " + _
        " IsNull(FILE_NAME, '') as FILE_NAME, IsNull(FILE_EXT, '') as FILE_EXT, LIT_TYPE " + _
        " From LITERATURE " & _
        " Where LITERATURE_ID = '" & Replace(Literature_Id, "'", "''") & "'")

        If Not IsNothing(LitDt) AndAlso LitDt.Rows.Count > 0 Then
            Dim LitName As String = ""
            Dim FileName As String = LitDt.Rows(0).Item("SIEBEL_FILENAME").ToString()

            If LitDt.Rows(0).Item("FILE_EXT").ToString() = "" Then
                LitName = Literature_Id
            Else
                LitName = Literature_Id + "." + LitDt.Rows(0).Item("FILE_EXT").ToString()
            End If
            'Response.Write("\\Crmdb75\siebfile\att\" + FileName)

            unzipFilePath = UnzipFile(LitName, FileName)
        End If
        Return unzipFilePath
    End Function

    Public Shared Function UnzipDownload(ByVal File_Id As String) As String
        Dim unzipFilePath As String = ""
        Dim sr_dt As DataTable = dbUtil.dbGetDataTable("My", _
        " Select IsNull(FILE_ID, '') as FILE_ID, IsNull(FILE_REV_NUM, '') as FILE_REV_NUM, " + _
        " IsNull(FILE_EXT, '') as FILE_EXT, IsNull(FILE_NAME, '') as FILE_NAME " + _
        " From SIEBEL_SR_SOLUTION_FILE Where FILE_ID = '" + Replace(File_Id, "'", "''") + "'")
        Dim local_filename As String = "", local_ext As String = ""
        'Throw New Exception(sr_dt.Rows(0).Item(1))
        If Not IsNothing(sr_dt) AndAlso sr_dt.Rows.Count > 0 Then
            local_filename = sr_dt.Rows(0).Item("FILE_NAME").ToString
            Dim Filename As String = _
                "S_RESITEM_" & _
                sr_dt.Rows(0).Item("FILE_ID").ToString() & _
                "_" & _
                sr_dt.Rows(0).Item("FILE_REV_NUM").ToString() & _
                ".SAF"
            Dim LitName As String = ""

            If sr_dt.Rows(0).Item("FILE_EXT").ToString() = "" Then
                LitName = sr_dt.Rows(0).Item("FILE_ID").ToString() & _
                          "_" & _
                          sr_dt.Rows(0).Item("FILE_REV_NUM").ToString()
            Else
                LitName = sr_dt.Rows(0).Item("FILE_ID").ToString() & _
                          "_" & _
                          sr_dt.Rows(0).Item("FILE_REV_NUM").ToString()
                LitName = LitName & "." & sr_dt.Rows(0).Item("FILE_EXT").ToString()
                local_ext = "." + sr_dt.Rows(0).Item("FILE_EXT").ToString()
            End If

            unzipFilePath = UnzipFile(LitName, Filename)

        End If
        Return unzipFilePath
    End Function

    Private Shared Function UnzipFile(ByVal LitName As String, ByVal FileName As String) As String
        If LitName.Contains(".") Then
            Return "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" & Left(LitName, LitName.IndexOf("."))
        Else
            Return ""
        End If

        'Dim MyUnzip As New MyUnzip.Unzip
        'MyUnzip.UseDefaultCredentials = True
        'MyUnzip.Timeout = 300 * 1000
        'Return MyUnzip.UnzipFile(LitName, FileName)
        'If Not IO.File.Exists("C:\MyAdvantech\Files\UnzippedFiles\" + LitName) Then
        '    If Not MapSiebFileDrive("S") Then
        '        Throw New Exception("Can't map to CRMDB75\SiebFile\")
        '        Exit Function
        '    End If

        '    Dim SiebelFilePath As String = "S:\att\" + FileName
        '    If IO.File.Exists(SiebelFilePath) Then
        '        If Not IO.File.Exists("C:\SiebelLit\" + FileName) Then
        '            IO.File.Copy(SiebelFilePath, "C:\SiebelLit\" + FileName)
        '        End If
        '        UnMapSiebFileDrive("S")

        '        If (UnzipSiebelFile("C:\SiebelLit\" + FileName, "C:\SiebelLit\" + LitName)) Then

        '            If File.Exists("C:\MyAdvantech\Files\UnzippedFiles\" + LitName) Then
        '                File.Delete("C:\MyAdvantech\Files\UnzippedFiles\" + LitName)
        '            End If
        '            Dim intC As Integer = 0
        '            Do While Not File.Exists("C:\SiebelLit\" + LitName)
        '                Threading.Thread.Sleep(300)
        '                intC += 1
        '                If intC >= 10 Then Exit Do
        '            Loop
        '            File.Copy("C:\SiebelLit\" + LitName, "C:\MyAdvantech\Files\UnzippedFiles\" + LitName)
        '            intC = 0
        '            Do While Not File.Exists("C:\MyAdvantech\Files\UnzippedFiles\" + LitName)
        '                Threading.Thread.Sleep(300)
        '                intC += 1
        '                If intC >= 10 Then Exit Do
        '            Loop
        '        Else
        '            Return ""
        '        End If

        '    Else
        '        Return ""
        '        'Throw New Exception("File " + SiebelFilePath + " not found in Siebel.")
        '    End If
        'End If
        'Return "/Files/UnzippedFiles/" + LitName
    End Function

    Public Shared Function MapSiebFileDrive(ByVal drive_letter As String) As Boolean

        Try
            Dim nd As New NetworkDrive
            nd.LocalDrive = drive_letter + ":"
            nd.ShareName = "\\crmdb75\SiebFile"
            nd.MapDrive("ADVANTECH\sieowner", "advan")
        Catch ex As Exception
            Return False
        End Try
        Return True

    End Function

    'Public Shared Function UnMapSiebFileDrive(ByVal drive_letter As String) As Boolean

    '    Try
    '        Dim nd As New NetworkDrive
    '        nd.LocalDrive = drive_letter + ":"
    '        nd.ShareName = "\\crmdb75\SiebFile"
    '        nd.Force = True
    '        nd.UnMapDrive()
    '    Catch ex As Exception
    '        Return False
    '    End Try
    '    Return True

    'End Function

    'Public Shared Function UnzipSiebelFile(ByVal FromPath As String, ByVal ToPath As String) As Boolean

    '    Dim filepath As String = "C:\MyAdvantech\Files\Unzip\UnzipSiebelFile.bat"
    '    Dim psi As Diagnostics.ProcessStartInfo = New Diagnostics.ProcessStartInfo("cmd.exe")
    '    psi.UseShellExecute = False
    '    psi.RedirectStandardOutput = True
    '    psi.RedirectStandardInput = True
    '    psi.RedirectStandardError = True
    '    Dim proc As Diagnostics.Process = Diagnostics.Process.Start(psi)
    '    Dim sr As StreamReader = File.OpenText(filepath)
    '    Dim sw As StreamWriter = proc.StandardInput
    '    Dim er As StreamReader = proc.StandardError

    '    If sr.Peek <> -1 Then
    '        Dim strInput As String = _
    '        sr.ReadLine + _
    '        " " + FromPath + " " + ToPath + _
    '        Environment.NewLine
    '        sw.WriteLine(strInput)
    '        'Response.Write(strInput + "<br/>")
    '    End If
    '    'Do While er.Peek <> -1
    '    '    Response.Write(er.ReadLine() + "<br/>")
    '    'Loop
    '    sr.Close()
    '    proc.Close()
    '    sw.Close()
    '    Return True

    'End Function
End Class
