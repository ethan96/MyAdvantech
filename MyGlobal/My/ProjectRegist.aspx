<%@ Page Title="MyAdvantech - Project Registration" ValidateRequest="false"  Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public tid As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("company_id") Is Nothing OrElse Session("Org_id") Is Nothing OrElse Session("user_id") Is Nothing OrElse Session("RBU") Is Nothing Then
            Session.Abandon() : FormsAuthentication.SignOut() : Response.Redirect("~/home.aspx")
        End If
                
        If Not IsPostBack Then
            If MailUtil.IsInRole("ITD.ACL") OrElse MailUtil.IsInRole("EMPLOYEES.AAC.USA") _
                OrElse MailUtil.IsInRole("Employee.AASC") OrElse MailUtil.IsInRole("EMPLOYEES.Irvine") Then
                hyUSPrjRegList.Visible = True
            Else
                hyUSPrjRegList.Visible = False
            End If
            If USPrjRegUtil.IsSalesContactAdmin() Then hyEditSC.Visible = True
            tbapp.Text = Session("user_id") : tbapp.Enabled = False : tbemal.Text = Session("user_id")
            Dim qstr As String = "select top 1 isnull(CITY,'') as  city , isnull(state,'') as COUNTRY_NAME,isnull(PHONE_NUM,'') as TEL_NO,isnull(ACCOUNT_NAME,'') as COMPANY_NAME from siebel_account where erp_id='" + Session("company_id").ToString() + "' "
            Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", qstr)
            If dt.Rows.Count > 0 Then
                tbpn.Text = dt.Rows(0)("TEL_NO").ToString.Trim() : tbc1.Text = dt.Rows(0)("CITY").ToString : tbs1.Text = dt.Rows(0)("COUNTRY_NAME").ToString
            End If
            Dim obj As Object = dbUtil.dbExecuteScalar("b2b", " select  IsNull(FirstName,'') +' '+IsNull(LastName,'') as NAME from SIEBEL_CONTACT where EMAIL_ADDRESS='" + Session("user_id").ToString + "'")
            If obj IsNot Nothing Then
                tbcperson.Text = obj.ToString()
            End If
            tbcpartner.Text = Session("company_id").ToString.Trim : tbcpartner.Enabled = False
            tbcomp.Attributes("autocomplete") = "off"
            If Session("RBU") = "AENC" Then
                DDLOrgID.SelectedValue = "AENC"
            Else
                DDLOrgID.SelectedValue = "AAC"
            End If
            If Util.IsAdmin() Then Me.tdOrg.Visible = True
            tid = Request("req")
            If tid <> "" Then
                Dim M As New Us_Prjreg_M(tid)
                tbapp.Text = M.Appliciant : tbcpartner.Text = M.CPartner : tbcperson.Text = M.Contact : tbpn.Text = M.Phone
                tbemal.Text = M.Email : tbc1.Text = M.City1 : tbs1.Text = M.State1 : DDLASC.SelectedValue = M.AdvSalesContact
                DDLOrgID.SelectedValue = M.Org_ID : tbcomp.Text = M.Company : tbadd.Text = M.Address : tbc2.Text = M.City2
                tbs2.Text = M.State2 : tbZIP.Text = M.Zip : tbProName.Text = M.Project_Name : tbPC.Text = M.Contact1
                tbPhone1.Text = M.ContactPhone1 : tbeMail1.Text = M.ContactEMail1 : tbEC.Text = M.Contact2
                tbPhone2.Text = M.ContactPhone2 : tbeMail2.Text = M.ContactEMail2 : tbprotodate.Text = USPrjRegUtil.checkdatemin(M.Prototype_Date)
                tbproductiondate.Text = USPrjRegUtil.checkdatemin(M.Production_Date)
            End If
            changeAdvSalesContact(DDLOrgID.SelectedValue)
        End If
            
    End Sub
    Private Sub changeAdvSalesContact(ByVal strView As String)
        Dim dt As DataTable = USPrjRegUtil.GetSalesContact(strView)
        DDLASC.Items.Clear()
        For Each r As DataRow In dt.Rows
            DDLASC.Items.Add(New ListItem(r.Item("SALES_NAME"), r.Item("SALES_EMAIL")))
        Next       
        If Me.DDLOrgID.Text = "AENC" Then
            For i As Integer = 0 To DDLASC.Items.Count - 1
                If Me.DDLASC.Items(i).Text = "Cliff Chen" Then
                    Me.DDLASC.SelectedIndex = i
                End If
            Next
        End If
    End Sub
    Protected Sub DDLOrgID_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles DDLOrgID.SelectedIndexChanged
        changeAdvSalesContact(DDLOrgID.SelectedValue)
    End Sub
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestCustName(ByVal prefixText As String, ByVal count As Integer) As String()
        Return USPrjRegUtil.AutoSuggestCustName(prefixText, count)
    End Function
    <Services.WebMethod()> _
  <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetAddrByCustRowId(ByVal rowid As String) As DataTable
        Return USPrjRegUtil.GetAddrByCustRowId(rowid)
    End Function
    Protected Sub NextBT_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim req_id As String = ""
        If tbpn.Text.Trim = "" Then Warn.Text = "* Phone Number is required." : Exit Sub
        If tbemal.Text.Trim = "" Then Warn.Text = "* Email Address is required." : Exit Sub
        If tbc1.Text.Trim = "" Then Warn.Text = "* City is required." : Exit Sub
        If tbs1.Text.Trim = "" Then Warn.Text = "* State is required." : Exit Sub
        If tbcomp.Text.Trim = "" Then Warn.Text = "* Company is required." : Exit Sub
        If tbadd.Text.Trim = "" Then Warn.Text = "* Address is required." : Exit Sub
        If tbc2.Text.Trim = "" Then Warn.Text = "* City is required." : Exit Sub
        If tbs2.Text.Trim = "" Then Warn.Text = "* State is required." : Exit Sub
        If tbZIP.Text.Trim = "" Then Warn.Text = "* Zip is required." : Exit Sub          
        If tbProName.Text.Trim = "" Then Warn.Text = "* Project Name is required." : Exit Sub
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select  ROW_ID from  S_OPTY where RTRIM(LTRIM(Lower(NAME)))  =N'{0}' ", tbProName.Text.Trim.Replace("'", "''").ToLower))
        If dt.Rows.Count > 0 Then Warn.Text = "* Project Name already exists." : Exit Sub
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Dim M As New Us_Prjreg_M()
        M.Appliciant = tbapp.Text.Replace("'", "''") : M.CPartner = tbcpartner.Text.Replace("'", "''") : M.Contact = tbcperson.Text.Replace("'", "''")
        M.Phone = tbpn.Text.Replace("'", "''") : M.Email = tbemal.Text.Replace("'", "''") : M.City1 = tbc1.Text.Replace("'", "''")
        M.State1 = tbs1.Text.Replace("'", "''") : M.AdvSalesContact = DDLASC.SelectedValue : M.Company = HttpUtility.HtmlEncode(tbcomp.Text).Replace("'", "''")
        M.Address = HttpUtility.HtmlEncode(tbadd.Text).Replace("'", "''") : M.City2 = tbc2.Text.Replace("'", "''")
        M.State2 = tbs2.Text.Replace("'", "''") : M.Zip = tbZIP.Text.Replace("'", "''") : M.Project_Name = HttpUtility.HtmlEncode(tbProName.Text).Replace("'", "''")
        M.Contact1 = tbPC.Text.Replace("'", "''") : M.ContactPhone1 = tbPhone1.Text.Replace("'", "''") : M.ContactEMail1 = tbeMail1.Text.Replace("'", "''")
        M.Contact2 = tbEC.Text.Replace("'", "''") : M.ContactPhone2 = tbPhone2.Text.Replace("'", "''") : M.ContactEMail2 = tbeMail2.Text.Replace("'", "''")
        M.Org_ID = DDLOrgID.SelectedValue : M.Expire_Date = DateAdd(Microsoft.VisualBasic.DateInterval.Month, 6, Now).ToString("MM/dd/yyyy")
        M.Prototype_Date = DateTime.MinValue : M.Production_Date = DateTime.MinValue:
        If IsDate(tbprotodate.Text) Then M.Prototype_Date = CDate(tbprotodate.Text)
        If IsDate(tbproductiondate.Text) Then M.Production_Date = CDate(tbproductiondate.Text)
        M.Reg_date = Date.Now : M.Status = "Request"
        If Request("req") <> "" Then
            M.Request_id = Request("req") : M.UPDAYE_M()
        Else
            M.Request_id = USPrjRegUtil.NewRowId("US_PrjReg_Mstr", "B2B")
            M.Insert_M()
        End If
        Util.AjaxRedirect(Me.up1, "ProjectRegDetail.aspx?req=" & M.Request_id)
    End Sub
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
                Response.Redirect("../home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
                Response.End()
            End If
            
            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員在home_ez上是隱藏的，所以如果直接用URL連結就導回首頁
            If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) Then
                Response.Redirect("~/home.aspx")
                Response.End()
            End If
            
            If Session("org_id") <> "US01" Then
                Response.Redirect("InterCon/PrjReg.aspx")
            End If
            If Util.IsInternalUser(Session("user_id")) = False Then
                If Session("account_status") <> "CP" Then
                    Response.Redirect("../home.aspx")
                Else
                    If Session("RBU") <> "AENC" And Session("RBU") <> "AAC" Then
                        Response.Redirect("../home.aspx")
                    End If
                End If
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

<table style="height:100%" cellpadding="0" cellspacing="0" width="100%" border="0">
    <tr>
        <td valign="top">
		    <table width="100%">
                <tr>
                    <td style="height: 10px" colspan="2">
                        <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyUSPrjRegList" NavigateUrl="~/My/ProjectRegList.aspx" Text="All Registered Projects (Internal Only)" />
                    </td>
                </tr>
		        <tr>
			    <td valign="top" colspan="2" style="width: 82%"><h2>
			        Channel Partner Project Registration Application</h2><br />
			        This project registration is subject to Advantech review.Upon approval you will received an email notification
			        </td>
			    </tr>
			    <tr><td height="20"></td></tr>
			</table>
			<table border=0 cellpadding=2 cellspacing=0 width="100%">
			    <tr>
                    <td width="20%" style="font-weight:bolder; font-size:medium " align="left" colspan="2">Applicant Info:</td>
                    <td align="left"></td>
                </tr>
			    <tr runat="server" visible="false">
                   <td width="20%" style="font-weight:bolder" align="right">Applicant:</td>
                   <td align="left"><asp:TextBox ID="tbapp" runat="server"></asp:TextBox></td>
                </tr>
                <tr runat="server" >
                    <td width="20%" style="font-weight:bolder" align="right">Channel Partner:</td>
                    <td align="left"><asp:TextBox ID="tbcpartner" runat="server"></asp:TextBox></td>
                </tr>
                <tr runat="server" >
                    <td width="20%" style="font-weight:bolder" align="right">Contact Person:</td>
                    <td align="left"><asp:TextBox ID="tbcperson" runat="server"></asp:TextBox></td>
                </tr>
                <tr runat="server" >
                    <td width="20%" style="font-weight:bolder" align="right">Phone Number:<span style="color:Red">*</span></td>
                    <td align="left"><asp:TextBox ID="tbpn" runat="server"></asp:TextBox></td>
                </tr>
                <tr runat="server" >
                    <td width="20%" style="font-weight:bolder" align="right">Email Address:<span style="color:Red">*</span></td>
                    <td align="left"><asp:TextBox ID="tbemal" runat="server" Width="200px" /></td>
                </tr>
                <tr runat="server" >
                    <td width="20%" style="font-weight:bolder" align="right">City and State:<span style="color:Red">*</span></td>
                    <td align="left">City&nbsp;<asp:TextBox ID="tbc1" runat="server"></asp:TextBox>&nbsp;State&nbsp;<asp:TextBox ID="tbs1" runat="server"></asp:TextBox></td>
                </tr>
                <tr>
                    <td width="20%" style="font-weight:bolder" align="right">Advantech Sales Contact:<span style="color:Red">*</span></td>
                    <td align="left">
                        <asp:DropDownList ID="DDLASC" runat="server" />&nbsp;&nbsp;
                        <asp:HyperLink runat="server" ID="hyEditSC" Text="Edit this list (Internal Only)" Visible="false" NavigateUrl="~/Admin/ANA/SalesContactList.aspx" Target="_blank" />
                    </td>
                </tr>
                <tr id="tdOrg" runat="server"  visible="false">
                    <td width="20%" style="font-weight:bolder" align="right">Org:<span style="color:Red">(Internal Only)</span></td>
                    <td align="left">
                        <asp:DropDownList ID="DDLOrgID" runat="server" AutoPostBack="true" >
                            <asp:ListItem Selected="True">AAC</asp:ListItem>
                            <asp:ListItem>AENC</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                   <td width="20%" style="font-weight:bolder" align="right" height="15"></td>
                   <td align="left"></td>
                </tr>
                <tr>
                   <td width="20%" style="font-weight:bolder; font-size:medium " align="left" colspan="2">Project Registration Info:</td>
                   <td align=left></td>
                </tr>
                <tr>
                   <td width="20%" style="font-weight:bolder" align="right">Company:<span style="color:Red">*</span></td>
                   <td align="left"><asp:TextBox ID="tbcomp" runat="server" Width="315px"></asp:TextBox>
                    
                      <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" OnClientItemSelected="EndCustSelected" 
                                        TargetControlID="tbcomp" MinimumPrefixLength="0" 
                                        CompletionInterval="500" ServiceMethod="AutoSuggestCustName" />
         
                    </td>
                </tr>
                <tr>
                    <td width="20%" style="font-weight:bolder" align="right">Address:<span style="color:Red">*</span></td>
                    <td align="left"><asp:TextBox ID="tbadd" runat="server" Width="315px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td width="20%" style="font-weight:bolder" align="right">City and State:<span style="color:Red">*</span></td>
                    <td align="left">
                            City&nbsp
                            <asp:TextBox ID="tbc2" runat="server"></asp:TextBox>&nbsp;
                            <span style="color:Red">*</span>State&nbsp;
                            <asp:TextBox ID="tbs2" runat="server"></asp:TextBox>
                            <span style="color:Red">*</span>Zip&nbsp;
                            <asp:TextBox ID="tbZIP" runat="server"></asp:TextBox>
                   </td>
                </tr>
                <tr>
                    <td width="20%" style="font-weight:bolder" align="right">Project Name:<span style="color:Red">*</span></td>
                    <td align="left"><asp:TextBox ID="tbProName" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
			    <tr>
                    <td width="20%"></td>
                    <td align="left"><span style="color:Red">* Unique project name required. Ex. Rue ACP-2320 Server.</span></td>
                </tr>
			    <tr>
                    <td width="20%" style="font-weight:bolder" align="right">Procurement Contact:</td>
                    <td valign=middle align=left style="font-weight:bolder"><asp:TextBox ID="tbPC" runat="server"></asp:TextBox>
			        &nbsp;&nbsp;Phone:&nbsp;<asp:TextBox ID="tbPhone1" runat="server"></asp:TextBox>&nbsp;&nbsp;eMail:&nbsp;<asp:TextBox ID="tbeMail1" runat="server"></asp:TextBox>
			        </td>
                </tr>
			   <tr>
                   <td width="20%" style="font-weight:bolder" align="right">Engineering Contact:</td>
                   <td valign=middle align=left style="font-weight:bolder"><asp:TextBox ID="tbEC" runat="server"></asp:TextBox>
			        &nbsp;&nbsp;Phone:&nbsp;<asp:TextBox ID="tbPhone2" runat="server"></asp:TextBox>&nbsp;&nbsp;eMail:&nbsp;<asp:TextBox ID="tbeMail2" runat="server"></asp:TextBox>
			        </td>
               </tr>
			   <tr>
                  <td width="20%" style="font-weight:bolder" align="right">Prototype Date:</td>
                  <td align="left"><asp:TextBox ID="tbprotodate" runat="server"></asp:TextBox></td>
              </tr>
			  <tr>
                  <td width="20%" style="font-weight:bolder" align="right">Production Date:</td>
                  <td align=left><asp:TextBox ID="tbproductiondate" runat="server"></asp:TextBox></td>
                    <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="tbprotodate" Format="yyyy/MM/dd" />
				    <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="tbproductiondate" Format="yyyy/MM/dd"/>
               </tr>
               <tr>
                <td width="20%"></td>
                <td height="20" align="left" valign="middle" >
                    <asp:UpdatePanel runat="server" ID="up1">
                        <ContentTemplate>
                            <asp:Label runat="server" ID="Warn" ForeColor="Red">&nbsp;</asp:Label> 
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="NextBT" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel> 
                </td>
               </tr>			       
			   <tr>
                  <td width="20%" valign="top"></td>
                  <td align="left" valign="top"  height="20">                                             
                       <asp:Button ID="NextBT" runat="server" Text="Next Step"  OnClick="NextBT_Click" />
             <%--          OnClientClick="return Validate();"--%>
                  </td>
               </tr>
			</table>
	     </td>
	  </tr>
      <tr style="height:120px">
                        <td>&nbsp;</td>
      </tr>
	 </table>
                <script type="text/javascript">
        function EndCustSelected(source, eventArgs) {
            //alert(" Key : " + eventArgs.get_text() + " Value : " + eventArgs.get_value());
            var rid = eventArgs.get_value();
            //alert(rid);
            FillEndCustAdd(rid);
        }
        function FillEndCustAdd(rid) {
      
            var custAddr = document.getElementById('<%=tbadd.ClientID %>');
            var custState = document.getElementById('<%=tbs2.ClientID %>');
            var clist = document.getElementById('<%=tbc2.ClientID %>');
            PageMethods.GetAddrByCustRowId(rid,
                function (pagedResult, eleid, methodName) {
                    var dt = pagedResult;
                    if (dt != null && typeof (dt) == "object") {
                        if (dt.rows.length = 1) {                        
                            custAddr.value = dt.rows[0].ADDRESS;
                            custState.value = dt.rows[0].STATE;
                          //  var ctry = dt.rows[0].COUNTRY;
//                            for (i = 0; i < clist.length; i++) {
//                                if (clist.options[i].value == ctry) {
//                                    clist.selectedIndex = i;
//                                    break;
//                                }
                            clist.value = dt.rows[0].CITY;

                            }
                          //  document.getElementById('=hd_EndCustRowId.ClientID %>').value = rid;
                            //alert(document.getElementById('=hd_EndCustRowId.ClientID %>').value);
                        }
                    
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                }
            );
        }
         </script>
         <script language=javascript>
             function $(o) { return document.getElementById(o); }
             function Validate() {
                 return true;
                 var obj;
                 obj = $('<%=tbpn.ClientID %>');

                 if (obj.value == "") {
                     alert("the Phone Number is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbemal.ClientID %>');

                 if (obj.value == "") {
                     alert("the Email Address is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbc1.ClientID %>');

                 if (obj.value == "") {
                     alert("the city is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbs1.ClientID %>');

                 if (obj.value == "") {
                     alert("the state is required")
                     obj.focus();
                     return false;
                 }
               //  obj = $('<%=DDLASC.ClientID %>');

//                 if (obj.value == "") {
//                     alert("the ASC is required")
//                     obj.focus();
//                     return false;
//                 }
                 obj = $('<%=tbcomp.ClientID %>');

                 if (obj.value == "") {
                     alert("the Company is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbadd.ClientID %>');

                 if (obj.value == "") {
                     alert("the Address is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbc2.ClientID %>');

                 if (obj.value == "") {
                     alert("the city is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbs2.ClientID %>');

                 if (obj.value == "") {
                     alert("the state is required")
                     obj.focus();
                     return false;
                 }
                 obj = $('<%=tbProName.ClientID %>');

                 if (obj.value == "") {
                     alert("the Project Name is required")
                     obj.focus();
                     return false;
                 }
             }
</script>
</asp:Content>

