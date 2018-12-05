<%@ Page Title="Channel Partner Leads Manager Administration" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false"%>
<%@ Import Namespace="SiebelBusObjectInterfaces" %>
<%@ Register Src="~/Includes/OptyPtnrContact.ascx" TagName="OptyPtnrContact" TagPrefix="uc1" %>
<%@ Register src="../Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>
<script runat="server">    
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            OptySrc.SelectCommand = GetMyLeads()
            Try
                If HttpContext.Current.User.Identity.Name = "gary.chen@advantech.com.tw" _
                OrElse HttpContext.Current.User.Identity.Name = "kander.kan@advantech.com.tw" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "172.16.7.48" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "172.16.2.208" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "59.115.129.139" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "59.124.232.162" Then
                    Response.End()
                End If
            Catch ex As Exception
                Response.End()
            End Try      
            If Util.IsInternalUser(Session("user_id")) OrElse Util.IsAEUIT() Then
                chgcompanypanel1.Visible = True
            End If
        End If
        If LCase(Session("user_id")) Like "*@*advantech*" Then
            OptyGv.Visible = True
        Else
            OptyGv.Visible = False : chgcompanypanel1.Width = Unit.Pixel(0)
        End If
      
    End Sub
 
    Private Function GetMyLeads() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            '.AppendLine("select '' as row_id, '' as contact_email, '' as first_name,'' as work_phone union select row_id, email_address as contact_email, firstname+' '+middlename+' '+lastname as first_name,workphone as work_phone ")
            .AppendLine("select row_id, email_address as contact_email, firstname+' '+middlename+' '+lastname as first_name,workphone as work_phone,JOB_FUNCTION as job")
            .AppendLine("from siebel_contact where account_row_id in (select row_id from siebel_account where erp_id<>'' ")
            .AppendLine("and erp_id in (select erp_id from siebel_account where erp_id<>'' and erp_id is not null and  ")
            .AppendLine("row_id in ")
            .AppendLine(String.Format("( select distinct row_id from siebel_account where erp_id='{0}' and row_id is not null) ", Session("company_id")))
            .AppendLine(")) and email_address like '%@%.%' order by row_id ")
        End With
        Return sb.ToString()
    End Function
    Protected Sub OptyGv_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
       
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            Dim cb As CheckBox = CType(e.Row.FindControl("item"), CheckBox)
            Dim contact_email As String = System.Text.RegularExpressions.Regex.Replace(e.Row.Cells(5).Text, "<[^>]*>", String.Empty)
            If isexist(contact_email) Then
                cb.Checked = True
                e.Row.Attributes.Add("style", "background-color:#9999FF")

            End If
            
        End If
        
    End Sub
    
 
    Protected Sub btnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim row_id As String, contact_email As String
        Dim arr As New ArrayList, SendEmailarr As New ArrayList, SendCancelEmailarr As New ArrayList
        For Each r As GridViewRow In OptyGv.Rows
            If r.RowType = DataControlRowType.DataRow Then
                row_id = System.Text.RegularExpressions.Regex.Replace(r.Cells(2).Text, "<[^>]*>", String.Empty)
                contact_email = System.Text.RegularExpressions.Regex.Replace(r.Cells(5).Text, "<[^>]*>", String.Empty)
                Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
                If cb IsNot Nothing And cb.Checked Then
                    If isexist(contact_email) Then
                    Else
                        arr.Add(String.Format("insert siebel_MyLeads values('{0}','{1}','{2}')", row_id, contact_email, Session("company_id")))
                        SendEmailarr.Add(contact_email)
                    End If
                Else
                    If isexist(contact_email) Then
                        arr.Add(String.Format("delete siebel_MyLeads where row_id = '{0}'", row_id))
                        SendCancelEmailarr.Add(contact_email)
                    End If
                End If         
            End If
        Next
       
        For Each aa As String In arr
            dbUtil.dbExecuteNoQuery("RFM", aa.ToString)
        Next
        OptySrc.SelectCommand = GetMyLeads()
        OptySrc.DataBind()
        OptyGv.DataBind()
        Label1.Text = "Channel Partner Leads Managers have been assigned."
        up1.Update()
        For Each bb As String In SendEmailarr
            Call SendEmail(bb)
        Next
        For Each cc As String In SendCancelEmailarr
            Call Send_Cancel_Email(cc)
        Next
        
    End Sub
    
    Public Function isexist(ByVal contact_email As String) As Boolean
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select * from siebel_MyLeads where contact_email = '{0}' and company_id = '{1}'", contact_email, Session("company_id")))
        If dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function SendEmail(ByVal Contact_Email As String) As Integer
        Dim FROM_Email As String = "",TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        '
        Dim strStyle As String = ""
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 10pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        
        FROM_Email = HttpContext.Current.Session("USER_ID")
        TO_Email = Contact_Email
        'TO_Email = "Tc.Chen@advantech.eu"
        CC_Email = ""
        BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "You have been assigned the permission to view all the sales leads."
        '
        MailBody = MailBody & "<html><body><center>"
        MailBody = MailBody & strStyle
        MailBody = MailBody & "<table width='95%' border='0' align='center'><tr><td>Dear Customer</td></tr>"
        MailBody = MailBody & "<tr><td><br />You have been assigned the permission to view all the sales leads assigned from Advantech to your company."
        MailBody = MailBody & "<br />Please go to MyAdvantech <a href='http://my.advantech.eu/my/MyLeads.aspx'>My Sales Leads</a> to have a look."
        MailBody = MailBody & "<br />Thank you.</td></tr>"
        MailBody = MailBody & String.Format("<tr><td><BR>Best Regards,<br />{0}</td></tr></table>", HttpContext.Current.Session("USER_ID"))
        MailBody = MailBody & "</center></body></html>"
        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Return 1
    End Function
    Public Shared Function Send_Cancel_Email(ByVal Contact_Email As String) As Integer
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        '
        Dim strStyle As String = ""
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 10pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        
        FROM_Email = HttpContext.Current.Session("USER_ID")
        TO_Email = Contact_Email
        'TO_Email = "Tc.Chen@advantech.eu"
        CC_Email = ""
        BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "You have been cancelled the permission to view all the sales leads"
        '
        MailBody = MailBody & "<html><body><center>"
        MailBody = MailBody & strStyle
        MailBody = MailBody & "<table width='95%' border='0' align='center'><tr><td>Dear Customer</td></tr>"
        MailBody = MailBody & "<tr><td><br />You have been cancelled the permission to view all the sales leads assigned from Advantech to your company."
        'MailBody = MailBody & "<br />Please go to MyAdvantech <a href='http://my.advantech.eu/my/MyLeads.aspx'>My Sales Leads</a> to have a look."
        MailBody = MailBody & "<br />Thank you.</td></tr>"
        MailBody = MailBody & String.Format("<tr><td><BR>Best Regards,<br />{0}</td></tr></table>", HttpContext.Current.Session("USER_ID"))
        MailBody = MailBody & "</center></body></html>"
        Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Return 1
    End Function

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
.hidden { display:none;}
</style>
    <table width="100%">
        <tr>            
            <th align="left" style="font-size:large; color:Navy; width:600px">Grant Leads Management Permission to Channel Partner</th>
            <td align="right">
                <table>
                    <tr>
                        <td colspan="2">
                            <asp:Panel runat="server" ID="chgcompanypanel1" Visible="false" Width="250px" ScrollBars="Auto" BorderWidth="1px" HorizontalAlign="Left">
                              <%--  <asp:LoginView runat="server" ID="ChangeCompanyView">
                                    <RoleGroups>
                                        <asp:RoleGroup Roles="Logistics,Administrator">
                                            <ContentTemplate>--%>
                                                <b>Change Company:</b><uc1:ChangeCompany ID="ChangeCompany1" runat="server"/><br />
                                                <asp:UpdatePanel runat="server" ID="upAddMeOptyTeam" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        &nbsp;<%--<asp:LinkButton runat="server" ID="lnkAddMe2OptyTeam" Text="Inform me when customer update leads" OnClick="lnkAddMe2OptyTeam_Click" OnInit="lnkAddMe2OptyTeam_Init" />                   --%>                                     
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>                                                
                                          <%--  </ContentTemplate>
                                        </asp:RoleGroup>
                                    </RoleGroups>
                                </asp:LoginView>--%>
                            </asp:Panel>  
                        </td>
                    </tr>
                </table>                              
            </td>
        </tr>
        <tr>            
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Button ID="Button1" runat="server" Text="assign"  OnClick="btnPick_Click"/>
                        <asp:Label ID="Label1" runat="server" Text="" Font-Size="X-Small" ForeColor="Red"></asp:Label>
                        <sgv:SmartGridView runat="server" ID="OptyGv" Width="98%"   
                            OnRowDataBoundDataRow="OptyGv_RowDataBoundDataRow"   DataKeyNames="ROW_ID" DataSourceID="OptySrc" AutoGenerateColumns="false" >
                            <Columns>
                               <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                                    <headertemplate>
                                        No.
                                    </headertemplate>
                                    <itemtemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </itemtemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                    <headertemplate>
                                        <asp:CheckBox ID="all" runat="server" />
                                    </headertemplate>
                                    <itemtemplate>
                                        <asp:CheckBox ID="item" runat="server" />
                                    </itemtemplate>
                                </asp:TemplateField> 
                                <asp:BoundField DataField="row_id" ItemStyle-CssClass="hidden" FooterStyle-CssClass="hidden"  HeaderStyle-CssClass="hidden" HeaderText="Row_ID" SortExpression="row_id" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />                                    
                                <asp:BoundField DataField="first_name" HeaderText="Full Name" SortExpression="first_name" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />                               
                                <asp:BoundField DataField="work_phone" Visible="false" HeaderText="WorkPhone" SortExpression="work_phone" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />                               
                                <asp:BoundField DataField="contact_email" HeaderText="Email" SortExpression="contact_email" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />   
                                <asp:BoundField DataField="job" HeaderText="Job Function" SortExpression="job" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />                               
                            </Columns>
                            <FixRowColumn FixColumns="-1" FixRows="-1" FixRowType="Header" TableHeight="520px" TableWidth="99%" />
                        </sgv:SmartGridView>
                        <asp:SqlDataSource runat="server" ID="OptySrc" ConnectionString="<%$ ConnectionStrings:RFM %>"/>
                    </ContentTemplate>                 
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>

