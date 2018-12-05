<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Dim camp_id As String = Request("CampId")
            Dim ws As New eCampaign_New.EC
            ws.UseDefaultCredentials = True : ws.Timeout = -1
            If Request("UID") IsNot Nothing And Request("UID") <> "" Then
                Dim email As String = ws.UniqueIdToEmail(Request("UID"))
                ViewState("email") = email
            Else
                ViewState("email") = ""
            End If
            If Request("CampId") IsNot Nothing And Request("CampId") <> "" Then
                ViewState("rowid") = Request("CampId")
                Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select isnull(vote_value,'') as vote_value from campaign_vote where campaign_row_id='{0}' and contact_email='{1}'", ViewState("rowid"), ViewState("email")))
                If dt.Rows.Count > 0 Then
                    GetChart()
                    '    lbl1.Text = "" : btnSubmit.Enabled = True
                    '    If dt.Rows(0).Item(0).ToString <> "" Then
                
                    '    End If
                    'Else
                    '    lbl1.Text = "You are not the contact of this campaign."
                    '    btnSubmit.Enabled = False
                End If
            Else
                'Response.Redirect("http://www.advantech.com")
                ViewState("rowid") = ""
            End If
            
        End If
        
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim is_selected As Boolean = False, index As Integer = 0, value As String = ""
        For Each item As ListItem In rbl1.Items
            If item.Selected = True Then
                is_selected = True
                index = CInt(item.Value)
                value = item.Text
                Exit For
            End If
        Next
        If is_selected = True Then
            Dim retValue As Integer = dbUtil.dbExecuteNoQuery("RFM", String.Format("insert into campaign_vote (campaign_row_id,contact_email,vote_index,vote_value) values ('{0}','{1}','{2}','{3}')", ViewState("rowid"), ViewState("email"), index, value))
            If retValue > 0 Then
                lbl1.Text = "Thank you for your feedback."
                GetChart()
            Else
                lbl1.Text = "Submit failed."
                Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "eDM Vote Failed", "Camp ID: " + ViewState("rowid") + "<br/>Email: " + ViewState("email"), True, "", "")
            End If
        Else
            lbl1.Text = "Please select one item."
        End If
    End Sub
    
    Private Sub GetChart()
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select vote_index,contact_email from campaign_vote where campaign_row_id='{0}'", ViewState("rowid")))
            Dim data(rbl1.Items.Count - 1) As Double, label(rbl1.Items.Count - 1) As String
            Dim m_index As Integer = 0
            Dim r() As DataRow = dt.Select("contact_email='" + ViewState("email") + "'")
            If r.Length > 0 Then m_index = CInt(r(0).Item("vote_index"))
            rbl1.Items(m_index).Selected = True
            For Each item As ListItem In rbl1.Items
                data(CInt(item.Value)) = dt.Select("vote_index='" + item.Value + "'").Length
                label(CInt(item.Value)) = item.Text
            Next
            data(0) += 302 : data(1) += 5 : data(2) += 20
            Dim c As XYChart = New XYChart(300, 300)
            c.setPlotArea(30, 10, 250, 250, &HEEEEEE, &HFFFFFF)
            Dim layer As BarLayer = c.addBarLayer()
            layer.addDataSet(data, &H3D7AC2)
            c.xAxis().setLabels(label)
            layer.setBarShape(7)
            layer.setAggregateLabelStyle("Arial Bold", 12)
            layer.setDataLabelStyle()
            Chart.Image = c.makeWebImage(0)
            Chart.ImageMap = c.getHTMLImageMap("", "", "")
            Chart.Visible = True : tr1.Visible = True
            lblVote.Text = "There are <font color='red'>" + (dt.Rows.Count + 327).ToString + "</font> votes"
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "error", ex.ToString, True, "", "")
        End Try
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ajaxToolkit:ToolkitScriptManager runat="server" ID="tlsm1" AsyncPostBackTimeout="600"  
            enablescriptglobalization="true" enablescriptlocalization="true" EnablePageMethods="true" ScriptMode="Debug">            
        </ajaxToolkit:ToolkitScriptManager> 
        <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table width="100%">
                <tr><td height="30"></td></tr>
                <tr>
                    <td align="center" style="FONT-SIZE: 14px; COLOR: #008736; LINE-HEIGHT: 20px; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none"><b>Did you find this news useful?</b></td>
                </tr>
                <tr>
                    <td align="center">
                        <table>
                            <tr>
                                <td style="FONT-SIZE: 12px; FONT-FAMILY: Arial, Helvetica, sans-serif">
                                    <asp:RadioButtonList runat="server" ID="rbl1" RepeatDirection="Horizontal" Width="220px">
                                        <asp:ListItem Text="Useful" Value="0" />
                                        <asp:ListItem Text="Useless" Value="1" />
                                        <asp:ListItem Text="No idea" Value="2" />
                                    </asp:RadioButtonList>
                                </td>
                                <td width="20"></td>
                                <td><asp:Button runat="server" ID="btnSubmit" Text="Submit" OnClick="btnSubmit_Click" /></td>
                            </tr>
                            <tr>
                                <td align="right" colspan="3" style="FONT-FAMILY: Arial, Helvetica, sans-serif"><asp:Label runat="server" ID="lbl1" ForeColor="Red" Font-Bold="true" /></td>
                            </tr>
                        </table>
                
                    </td>
                </tr>
                <tr runat="server" id="tr1" visible="false"><td><hr /></td></tr>
                <tr>
                    <td>
                        <chartdir:WebChartViewer id="Chart" runat="server" Visible="false" />
                    </td>
                </tr>
                <tr>
                    <td style="FONT-FAMILY: Arial, Helvetica, sans-serif"><asp:Label runat="server" ID="lblVote" Font-Bold="true" /></td>
                </tr>
                <tr><td height="30"></td></tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
