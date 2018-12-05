<%@ Control Language="VB" ClassName="AMDbanner" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        If Not Page.IsPostBack Then
            If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(email) from amd_sales_list where email='{0}'", Session("user_id")))) > 0 Then
                'Panel1.Visible = True
                hyAMD.NavigateUrl = ConfigurationManager.AppSettings("SSOPath") + String.Format("?tempid={0}&pass=my&id={1}&callbackurl={2}", Session("TempId"), Session("user_id"), "http://www.advantech.com/embeddedcomputing/AMD/Default.aspx")
                hyAMD.Visible = True : imgAMD.Visible = False
            Else
                hyAMD.Enabled = False : imgAMD.Visible = True
            End If
        End If
    End Sub
</script>
<asp:Panel runat="server" ID="Panel1" Visible="true">
    <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td height="139">
                <asp:Image runat="server" ID="imgAMD" ImageUrl="~/images/banner_w246h138.gif" width="246" height="138" />
                <asp:HyperLink runat="server" ID="hyAMD" Target="_blank" ImageUrl="~/images/banner_w246h138.gif" Width="246" Height="138" Visible="false">
                    
                </asp:HyperLink>
            </td>
        </tr>
        <tr>
            <td height="10">
            </td>
        </tr>
    </table>
</asp:Panel>
