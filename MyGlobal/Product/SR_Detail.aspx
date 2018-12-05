<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Model Detail"%>

<%@ Import Namespace="System.Drawing" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sr_Detail As New SRUtil()
        sr_Detail.SR_Detail(Trim(HttpUtility.UrlEncode(Request("SR_ID"))))
        lblSR_Number.Text = "<h2>Download " + sr_Detail.strSRNum + "</h2>"
        lblProdModel.Text = sr_Detail.strProdModel.ToString
        lblType.Text = sr_Detail.strSRType
        lblAbstract.Text = sr_Detail.strSRAbstract
        lblDesc.Text = sr_Detail.strSRDesc
        lblCategory.Text = sr_Detail.strSRCategory
        lblOS.Text = sr_Detail.strOS.ToString
        Dim SolDt As DataTable = sr_Detail.SolutionDt
        Dim SolutionFileHt As Hashtable = sr_Detail.DownloadFileHt
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

                        c1.Text = "<a target='_blank' href='/Product/Unzip_File.aspx?File_Id=" + fr.Item("FILE_ID").ToString() + "&Part_NO=" + Trim(Request("Part_NO")) + "&Type=FAQ&C=" + Request("C") + "'>" + _
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
                                    <td style="background-color:#ccccff; height:20;" align="right"><b>Type : </b></td>
                                    <td><asp:Label runat="server" ID="lblType" /></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#ccccff; height:20;" align="right"><b>Abstract : </b></td>
                                    <td><asp:Label runat="server" ID="lblAbstract" /></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#ccccff; height:20;" align="right"><b>Description : </b></td>
                                    <td><asp:Label runat="server" ID="lblDesc" /></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#ccccff; height:20;" align="right"><b>Category : </b></td>
                                    <td><asp:Label runat="server" ID="lblCategory" /></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#ccccff; height:20;" align="right"><b>Operating System : </b></td>
                                    <td><asp:Label runat="server" ID="lblOS" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td valign="top">
                            <h3>Solution</h3>
                            <asp:Panel runat="server" ID="SolPanel" />
                        </td>
                    </tr>
                </table>                            
            </td>
        </tr>
    </table>                   
</asp:Content>