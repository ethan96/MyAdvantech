<%@ Control Language="VB" ClassName="MyEDM" %>

<script runat="server">
    Public Shared Function GetMyEDM() As String
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Return ""
        Try
            Dim ws As New eCampaign_New.EC
            ws.UseDefaultCredentials = True
            Dim dt As DataTable = ws.GetMyEDM(HttpContext.Current.Session("user_id"))
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine("<table width='100%'>")
                For i As Integer = 0 To dt.Rows.Count - 1
                    Dim r As DataRow = dt.Rows(i)
                    Dim bcolor As String = "FEFEFE"
                    If i Mod 2 = 1 Then bcolor = "DCDBDB"
                    .AppendLine(String.Format("<tr style='background-color:#" + bcolor + ";'><td><a target='_blank' href='/Includes/GetTemplate.ashx?RowId={2}&Email={3}' title='{1}'>{0}</a></td></tr>", _
                                              r.Item("email_subject"), CDate(r.Item("email_send_time")).ToString("yyyy/MM/dd"), _
                                              r.Item("row_id"), r.Item("contact_email")))
                Next
                .AppendLine("</table>")
                Return sb.ToString()
            End With
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Error GetMyEDM by " + HttpContext.Current.Session("user_id"), ex.ToString, False, "", "")
        End Try
        Return ""
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            
        End If
       
    End Sub

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999
        div1.InnerHtml = GetMyEDM()
        Timer1.Enabled = False
    End Sub
</script>
<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Timer runat="Server" ID="Timer1" Interval="10" OnTick="Timer1_Tick" />
        <table width="100%">
            <tr>
                <th align="left"><h3 style="color:Navy">My eNewsletter</h3></th>
            </tr>
            <tr valign="top">
                <td><div runat="Server" id="div1" style="overflow:scroll; height:150px" /></td>
            </tr>
        </table>        
    </ContentTemplate>
</asp:UpdatePanel>