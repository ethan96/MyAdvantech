<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Model Detail"%>

<%@ Import Namespace="System.Drawing" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sr_id As String = ""
        If Request("SR_ID") IsNot Nothing Then sr_id = Trim(HttpUtility.UrlEncode(Request("SR_ID").ToString).Replace("|", "+"))
        Dim sr_Download As New SRUtil()
        If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(SR_ID) from SIEBEL_SR_DOWNLOAD where SR_ID='{0}'", sr_id))) > 0 Then
            sr_Download.SR_Download(sr_id)
        Else
            Dim objLit As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(DESCRIPTION,'') from SUPPORT_DOWNLOAD where DOC_ID='1-H1VQ1'"))
            If objLit IsNot Nothing Then sr_Download.strSRAbstract = objLit.ToString
            Dim pmDt As DataTable = dbUtil.dbGetDataTable("My", "SELECT * FROM SIEBEL_SR_PRODUCT WHERE SR_ID='" + sr_id + "'")
            If Not IsNothing(pmDt) AndAlso pmDt.Rows.Count > 0 Then
                For i As Integer = 0 To pmDt.Rows.Count - 1
                    If i > 0 Then
                        sr_Download.strProdModel.Append(", " + pmDt.Rows(i).Item("PART_NO").ToString())
                    Else
                        sr_Download.strProdModel.Append(pmDt.Rows(i).Item("PART_NO").ToString())
                    End If
                Next
            End If
            sr_Download.SolutionDt = dbUtil.dbGetDataTable("My", _
            " SELECT C.SR_ID as SOLUTION_ID, C.NAME as SOLUTION_NAME, IsNull(C.FAQ_QUES_TEXT, '') as FAQ, " + _
            " IsNull(C.RESOLUTION_TEXT, '') as SOLUTION_DESC, C.CREATED as CREATED_DATE, C.PUBLISH_FLG as PUBLISH_FLAG " + _
            " FROM SIEBEL_SR_SOLUTION_RELATION B, SIEBEL_SR_SOLUTION C " + _
            " WHERE B.SOLUTION_ID = C.SR_ID AND C.PUBLISH_FLG = 'Y' AND B.SR_ID = '" + sr_id + "' ")

            If Not IsNothing(sr_Download.SolutionDt) AndAlso sr_Download.SolutionDt.Rows.Count > 0 Then
                For Each r As DataRow In sr_Download.SolutionDt.Rows
                    Dim SolutionFileDt As DataTable = dbUtil.dbGetDataTable("My", _
                    " SELECT A.FILE_ID, IsNull(A.FILE_NAME, '') as FILE_NAME, IsNull(A.FILE_EXT, '') as FILE_EXT, " + _
                    " IsNull(A.FILE_SIZE, 0) as FILE_SIZE, IsNull(A.FILE_DESC, '') as FILE_DESC, A.CREATED_DATE " + _
                    " FROM SIEBEL_SR_SOLUTION_FILE AS A CROSS JOIN SIEBEL_SR_SOLUTION_FILE_RELATION AS B " + _
                    " WHERE (A.FILE_ID = B.FILE_ID) AND (A.PUBLISH_FLAG = 'Y') AND " + _
                    " (B.SOLUTION_ID = '" + r.Item("SOLUTION_ID").ToString() + "') ")

                    sr_Download.DownloadFileHt.Add(r.Item("SOLUTION_ID").ToString(), SolutionFileDt)
                Next
            End If
        End If
        
        lblSR_Number.Text = "<h2>Download " + sr_Download.strSRNum + "</h2>"
        lblProdModel.Text = sr_Download.strProdModel.ToString()
        lblAbstract.Text = sr_Download.strSRAbstract
        lblDesc.Text = sr_Download.strSRDesc
        Dim SolDt As DataTable = sr_Download.SolutionDt
        Dim SolutionFileHt As Hashtable = sr_Download.DownloadFileHt
        If Not IsNothing(SolDt) AndAlso SolDt.Rows.Count > 0 Then
            For Each r As DataRow In SolDt.Rows
                Dim tmpTb As New Table
                Dim tmpR1 As New TableRow, tmpR2 As New TableRow, tmpR3 As New TableRow

                tmpTb.BackColor = Color.FromArgb(CLng("&Hff"), CLng("&Hff"), CLng("&H9c"))
                tmpTb.Width = New Unit(900, UnitType.Pixel)
                tmpTb.BorderWidth = New Unit(1, UnitType.Pixel)

                Dim solNameDateCell As New TableCell, solDescCell As New TableCell, solDLCell As New TableCell
                tmpR1.Cells.Add(solNameDateCell) : tmpR2.Cells.Add(solDescCell) : tmpR3.Cells.Add(solDLCell)
                solNameDateCell.Text = _
                "<li><b>" + _
                SolDt.Rows(0).Item("SOLUTION_NAME").ToString() + "</b></li> Date:<a>" + _
                CDate(SolDt.Rows(0).Item("CREATED_DATE").ToString()).ToString("MM/dd/yyyy") + "</a>"
                solDescCell.Text = Replace(r.Item("SOLUTION_DESC").ToString(), vbCrLf, "<br/>")
                
                Dim SolutionFileDt As DataTable = CType(SolutionFileHt.Item(r.Item("SOLUTION_ID").ToString()), DataTable)
                If Not IsNothing(SolutionFileDt) AndAlso SolutionFileDt.Rows.Count > 0 Then
                    For Each fr As DataRow In SolutionFileDt.Rows
                        Dim tmpFTb As New Table, tmpFRow As New TableRow
                        Dim c1 As New TableCell, c2 As New TableCell, c3 As New TableCell

                        tmpFTb.BackColor = Color.FromArgb(CLng("&Hcc"), CLng("&Hcc"), CLng("&Hcc"))
                        tmpFTb.Width = New Unit(900, UnitType.Pixel)

                        'c1.Text = "<a target='_blank' href='/Product/Unzip_File.aspx?File_Id=" + fr.Item("FILE_ID").ToString() + "&Type=Download'>" + _
                        'fr.Item("FILE_NAME").ToString() + "." + fr.Item("FILE_EXT").ToString() + _
                        '" (" + FormatNumber(CDbl(fr.Item("FILE_SIZE")) / 1024, 0, , , -2) + "k)" + "</a>"
                        Dim url As String = "http://downloadt.advantech.com/download/downloadsr.aspx?File_Id=" + fr.Item("FILE_ID").ToString()
                        c1.Text = "<a target='_blank' href='' id='c1' onmouseover='javascript:GetUrl(""c1"",""" + url + """)' onmousedown='javascript:TracePage(""lit"",""" + Request("C") + """,""" + fr.Item("FILE_ID").ToString() + """,""c1"",""" + url + """)'>" + _
                        fr.Item("FILE_NAME").ToString() + "." + fr.Item("FILE_EXT").ToString() + _
                        " (" + FormatNumber(CDbl(fr.Item("FILE_SIZE")) / 1024, 0, , , -2) + "k)" + "</a>"
                        
                        c3.Text = fr.Item("FILE_DESC").ToString() + " (" + _
                        IIf( _
                        IsDate(fr.Item("CREATED_DATE").ToString()), _
                        CDate(fr.Item("CREATED_DATE").ToString()).ToString("MM/dd/yyyy"), _
                        "") + _
                        ")"
                        c3.Width = New Unit(75, UnitType.Percentage)
                        With tmpFRow.Cells
                            .Add(c1) : .Add(c2) : .Add(c3)
                        End With
                        tmpFTb.Rows.Add(tmpFRow)
                        solDLCell.Controls.Add(tmpFTb)
                    Next

                End If

                With tmpTb.Rows
                    .Add(tmpR1) : .Add(tmpR2) : .Add(tmpR3)
                End With
                SolPanel.Controls.Add(tmpTb)
            Next
        End If
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
<script type="text/javascript">
    function TracePage(type, lit_type, rid, ID, url) {
        document.getElementById(ID).href = "javascript:void(0)";
        window.open("MaterialRedirectPage.aspx?Type=" + type + "&C=" + lit_type + "&rid=" + rid + "&url=" + url);
    }
    function GetUrl(ID, url) {
        document.getElementById(ID).href = url;
    }
</script>
    <table class="text" style="height:100%" cellpadding="0" cellspacing="0" width="100%" border="0">
        <tr>
            <td valign="top">
            <table>
                <tr>
                    <td>
                        <table width="100%">                               
                            <tr>
                                <td valign="top">
                                    <table>
                                        <tr>
                                            <td valign="top"><asp:Label runat="server" ID="lblSR_Number" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td style="background-color:#ccccff; height:20;" align="right"><b>Product Model : </b></td>
                                            <td><asp:Label runat="server" ID="lblProdModel" /></td>
                                        </tr>
                                        <tr>
                                            <td style="background-color:#ccccff; height:20;" align="right"><b>Abstract : </b></td>
                                            <td><asp:Label runat="server" ID="lblAbstract" /></td>
                                        </tr>
                                        <tr>
                                            <td style="background-color:#ccccff; height:20;" align="right"><b>Description : </b></td>
                                            <td><asp:Label runat="server" ID="lblDesc" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Panel runat="server" ID="SolPanel" />
                                </td>
                            </tr>
                        </table>                            
                    </td>
                </tr>
            </table>                   
            </td>
        </tr>
    </table> 
</asp:Content>