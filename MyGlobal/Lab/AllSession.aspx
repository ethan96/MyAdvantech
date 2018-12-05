<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
<%--        Session("CART_ID") = "2DB00CE185F94FB9ABB39CEFB40F0662"
        Session("ORDER_ID") = "2DB00CE185F94FB9ABB39CEFB40F0662"--%>
        'Response.Write("<br>Session的所有值:<br>") 
        If Not Util.IsAEUIT() Then
         'Response.End()   
        End If
        Dim dt As New DataTable()
        dt.Columns.Add("name", GetType(String))
        dt.Columns.Add("value", GetType(String))
        For Each item As String In Session.Contents          
            Dim dr As DataRow = dt.NewRow()
            dr("name") = item.ToString
            dr("value") = Session(item).ToString
            dt.Rows.Add(dr)
        Next
        dt.AcceptChanges()
        GridView1.DataSource = dt
        GridView1.DataBind()
        dt.Clear()
        For i As Integer = 0 To HttpContext.Current.Request.Cookies.Count - 1
            Dim dr As DataRow = dt.NewRow()
            dr("name") = HttpContext.Current.Request.Cookies.Keys(i).ToString
            dr("value") = HttpContext.Current.Request.Cookies(i).Value.ToString
            dt.Rows.Add(dr)
        Next
        dt.AcceptChanges()
        GridView2.DataSource = dt
        GridView2.DataBind()
        dt.Clear()
        For i As Integer = 0 To HttpContext.Current.Application.Count - 1
            Dim dr As DataRow = dt.NewRow()
            dr("name") = HttpContext.Current.Application.Keys(i).ToString
            dr("value") = HttpContext.Current.Application(i).ToString()
            dt.Rows.Add(dr)
        Next
        dt.AcceptChanges()
        GridView3.DataSource = dt
        GridView3.DataBind()
    End Sub

    Protected Sub Button1_Click(sender As Object, e As System.EventArgs)
        Dim mailbody As String = SAPDOC.GetPI("FU661906", 0)
        'Response.Write(str)
        Dim subject_email As String = "test by ming"
        Dim FROM_Email As String = "eBusiness.AEU@advantech.eu", TEST_TO_Email As String = "ming.zhao@advantech.com.cn;nada.liu@advantech.com.cn;tc.chen@advantech.com.tw"
        Dim CC_Email As String = "", BCC_Email As String = ""
        Dim strCC As String = "", strCC_External As String = ""
        Dim j As Integer = SAPDOC.GetPIcc("FU661906", strCC, strCC_External)
        Dim TO_Email = HttpContext.Current.Session("USER_ID")
        If strCC_External.Trim <> "" Then
            TO_Email = TO_Email + ";" + strCC_External
        End If
        CC_Email = ""
        MailUtil.Utility_EMailPage(FROM_Email, TEST_TO_Email, "", "", subject_email, "", "TO:" + TO_Email + "<BR/>" + "CC:" + CC_Email + "<br/>" + "BCC:" + BCC_Email + "<BR/>" + mailbody)
        TO_Email = strCC
        CC_Email = "eBusiness.AEU@advantech.eu;"
        'If HttpContext.Current.Session("org_id").ToString.Trim.ToUpper = "EU10" Then
        '    CC_Email = CC_Email + "claudio.cerqueti@advantech.nl;"
        'End If
        MailUtil.Utility_EMailPage(FROM_Email, TEST_TO_Email, "", "", subject_email, "", "TO:" + TO_Email + "<BR/>" + "CC:" + CC_Email + "<br/>" + "BCC:" + BCC_Email + "<BR/>" + mailbody)
        'Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn;nada.liu@advantech.com.cn;tc.chen@advantech.com.tw",
                                       '   "", "", "test by ming", "", str, "")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<center>
    <asp:Button ID="Button1" runat="server" Text="Button" OnClick="Button1_Click" />
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right" valign="top">
      <asp:HyperLink ID="HyperLink1" NavigateUrl="~/admin/GetSSOProfile.aspx" Target="_blank" runat="server">
        SSO User Profile Inquiry
      </asp:HyperLink><br />
       <asp:HyperLink ID="HyperLink2" NavigateUrl="~/admin/RegSSOUser.aspx" Target="_blank" runat="server">
        SSO User Register
      </asp:HyperLink><br />
      <asp:HyperLink ID="HyperLink3" NavigateUrl="~/admin/userlog.aspx" Target="_blank" runat="server">
        userlog
      </asp:HyperLink><br />
      <asp:HyperLink ID="HyperLink4" NavigateUrl="~/admin/MultiLangAdmin.aspx" Target="_blank" runat="server">
        Multilanguage Administration
      </asp:HyperLink><br />
      <asp:HyperLink ID="HyperLink5" NavigateUrl="~/admin/QuerySAP.aspx" Target="_blank" runat="server">
        Query SAP DB
      </asp:HyperLink><br />
    </td>
     <td align="center" valign="top">
        <b>Session的所有值:</b>
        <asp:GridView ID="GridView1" runat="server">
        </asp:GridView>
            <b>CookiEs的所有值:</b>
        <sgv:SmartGridView ID="GridView2"  runat="server">
            <FixRowColumn FixColumns="-1" FixRows="-1" TableWidth="600px" TableHeight="185px"  FixRowType="Header" />    
        </sgv:SmartGridView>

        <b>Application的所有值:</b>
        <sgv:SmartGridView ID="GridView3"  runat="server">
   
        </sgv:SmartGridView>
     </td>
  </tr>
</table>   
</center>
    
</asp:Content>

