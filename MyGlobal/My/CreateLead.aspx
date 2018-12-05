<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Upload Leads" %>

<script runat="server">

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Session("company_id") = "T16270654" : Session("company_name") = "駿緯國際股份有限公司"
            If Util.IsAEUIT() Or Util.IsInternalUser2() Then AdminRow.Visible = True
        End If
    End Sub

    Protected Sub btnCreate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not PreValidateData() Then
            Util.AjaxJSAlert(Up3, "Account, Project Name, Owner are required. Amount must be greater than 0.")
            Exit Sub
        End If
        If IsProjExist(HttpUtility.HtmlEncode(txtPrjName.Text.Trim())) Then
            Util.AjaxJSAlert(Up3, "This project name has been existed in Siebel.")
            Exit Sub
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" INSERT INTO OPPORTUNITY_DRAFT ")
            .AppendLine(" (TEMP_ID, PROJECT_NAME, SALES_STAGE, PROBABILITY, ACCOUNT_ROW_ID, LEAD_PARTNER, REVENUE, CURRENCY, DESCRIPTION, CREATED_BY, ")
            .AppendLine(" CONTACT_ROW_ID, CREATED_DATE, STATUS_CODE, OWNER_ID, ACCOUNT_NAME, PARENT_ACCOUNT_ERPID) ")
            .AppendLine(" VALUES (@TEMPID, @PROJNAME, @STAGE, @PROB, @ACCOUNTROWID, @LEADPARTNER, @REVENUE, @CURR, @DESC, @CREATEBY, @CONTACTROWID, GETDATE(), 0, @OWNERID, @ACCOUNTNAME, @ERP)")
        End With
        Dim pTempId As New System.Data.SqlClient.SqlParameter("TEMPID", SqlDbType.VarChar) : pTempId.Value = NewId()
        Dim pPrjName As New System.Data.SqlClient.SqlParameter("PROJNAME", SqlDbType.NVarChar) : pPrjName.Value = HttpUtility.HtmlEncode(txtPrjName.Text.Trim())
        Dim pStage As New System.Data.SqlClient.SqlParameter("STAGE", SqlDbType.VarChar) : pStage.Value = "5% New Lead"
        Dim pProb As New System.Data.SqlClient.SqlParameter("PROB", SqlDbType.Float) : pProb.Value = 5.0
        Dim pARowId As New System.Data.SqlClient.SqlParameter("ACCOUNTROWID", SqlDbType.VarChar)
        Dim pAName As New System.Data.SqlClient.SqlParameter("ACCOUNTNAME", SqlDbType.NVarChar)
        If Session("NewCreatedAccount") <> "" Then
            pAName.Value = txtAccount.Text
            pARowId.Value = ""
        Else
            pAName.Value = txtAccount.Text.Split("(")(0)
            pARowId.Value = txtAccount.Text.Split("(")(1).Replace(")", "")
        End If
        Dim pLeadPartner As New System.Data.SqlClient.SqlParameter("LEADPARTNER", SqlDbType.Char) : pLeadPartner.Value = "Y"
        Dim pRev As New System.Data.SqlClient.SqlParameter("REVENUE", SqlDbType.Float) : pRev.Value = Double.Parse(txtRevenue.Text)
        Dim pCur As New System.Data.SqlClient.SqlParameter("CURR", SqlDbType.VarChar) : pCur.Value = dlCurrency.SelectedValue
        Dim pDesc As New System.Data.SqlClient.SqlParameter("DESC", SqlDbType.NVarChar) : pDesc.Value = HttpUtility.HtmlEncode(txtDesc.Text).Replace(vbCrLf, "<br/>")
        Dim pCBy As New System.Data.SqlClient.SqlParameter("CREATEBY", SqlDbType.NVarChar) : pCBy.Value = Session("user_id")
        Dim pCRowId As New System.Data.SqlClient.SqlParameter("CONTACTROWID", SqlDbType.VarChar)
        If txtContact.Text <> "" Then
            pCRowId.Value = txtContact.Text.Split("(")(2).Replace(")", "")
        Else
            pCRowId.Value = ""
        End If
        Dim pOwnerId As New System.Data.SqlClient.SqlParameter("OWNERID", SqlDbType.VarChar) : pOwnerId.Value = HttpUtility.HtmlEncode(txtOwner.Text.Trim())
        Dim pERP As New System.Data.SqlClient.SqlParameter("ERP", SqlDbType.NVarChar) : pERP.Value = Session("company_id")
        Dim para() As System.Data.SqlClient.SqlParameter = {pTempId, pPrjName, pStage, pProb, pARowId, pLeadPartner, pRev, pCur, pDesc, pCBy, pCRowId, pOwnerId, pAName, pERP}
        Dim retInt As Integer = dbUtil.dbExecuteNoQuery2("MY", sb.ToString(), para)
        OptyAdminGv.DataBind()
        If retInt = 1 Then
            SendMail()
            Util.AjaxJSAlert(Up3, "This lead has been created. We will process it ASAP. Thank you!!")
        End If
        
        'txtPrjName.Text = "" : txtRevenue.Text = "" : txtDesc.Text = "" : txtOwner.Text = ""
    End Sub
    
    Private Function IsProjExist(ByVal ProjName As String) As Boolean
        Try
            If CInt(dbUtil.dbExecuteScalar("CRMDB75", String.Format("select count(*) from S_OPTY where upper(NAME) = upper('{0}')", ProjName))) = 0 Then Return False
            Return True
        Catch ex As Exception
            Util.AjaxJSAlert(Up3, "Siebel system is busy. Please try it again.")
        End Try
    End Function
    
    Private Sub SendMail()
        Dim body As String
        Dim account As String = "", contact As String = ""
        If Session("NewCreatedAccount") <> "" Then
            account = txtAccount.Text
        Else
            account = txtAccount.Text.Split("(")(0)
        End If
        If txtContact.Text <> "" Then
            contact = txtContact.Text.Split("(")(1).Replace(")", "")
        End If
        body = "Dears,<br/><br/>" + _
               "A new lead has been created.<br/>" + _
               "You can process it through this link <a href='http://my.advantech.eu/My/CreateLead.aspx'>New Lead Request</a><br/><br/>" + _
               "<table><tr>" + _
               "<td><b>Project Name : </b></td><td>" + HttpUtility.HtmlEncode(txtPrjName.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Parent Account : </b></td><td>" + Session("company_name") + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Account : </b></td><td>" + account + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Contact : </b></td><td>" + contact + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Owner : </b></td><td>" + txtOwner.Text.Trim() + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Amount : </b></td><td>" + txtRevenue.Text + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Currency : </b></td><td>" + dlCurrency.SelectedValue + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Description : </b></td><td>" + HttpUtility.HtmlEncode(txtDesc.Text.Replace(vbCrLf, "<br/>")) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Created By : </b></td><td>" + Session("user_id") + " (" + Session("company_name") + ")</td></tr></table><br/><br/>" + _
               "Best Regards,<br/><a href='http://my.advantech.eu'>MyAdvantech</a>"
        Util.SendEmail(txtOwner.Text.Split("(")(0).Trim(), "eBusiness.AEU@advantech.eu", "New Lead Request", body, True, "", "tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw")
        'txtOwner.Text.Split("(")(0).Trim()
    End Sub
    Private Function PreValidateData() As Boolean
        If HttpUtility.HtmlEncode(txtAccount.Text.Trim()) = "" OrElse dlCurrency.SelectedValue = "" Then
            Return False
        End If
        If txtPrjName.Text.Trim = "" Then Return False
        If Double.TryParse(txtRevenue.Text, 0) = False Then Return False
        If txtOwner.Text = "" Then Return False
        Return True
    End Function
    
    Private Shared Function NewId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(*) as counts from OPPORTUNITY_DRAFT where TEMP_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function

    Protected Sub OptyAdminGv_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If DataBinder.Eval(e.Row.DataItem, "STATUS_CODE") = 2 Then
                CType(e.Row.Cells(0).Controls(0), LinkButton).Enabled = False
                CType(e.Row.Cells(0).Controls(0), LinkButton).ToolTip = "Cannot update lead once it is approved"
            End If
            
            Dim tmpdlCurr As DropDownList = e.Row.FindControl("dlRowCurrency"), tmpCurr As String = DataBinder.Eval(e.Row.DataItem, "CURRENCY")
            Dim tmpdlStage As DropDownList = e.Row.FindControl("dlRowStage"), tmpStg As String = DataBinder.Eval(e.Row.DataItem, "SALES_STAGE")
            Dim tmpdlProb As DropDownList = e.Row.FindControl("dlRowProb"), tmpProb As Double = DataBinder.Eval(e.Row.DataItem, "PROBABILITY")
            Dim tmpdlStatus As DropDownList = e.Row.FindControl("dlRowApprovalStatus"), tmpcode As Integer = DataBinder.Eval(e.Row.DataItem, "STATUS_CODE")
            If tmpdlCurr IsNot Nothing Then SelectDropdownlist(tmpdlCurr, tmpCurr)
            If tmpdlStage IsNot Nothing Then SelectDropdownlist(tmpdlStage, tmpStg.ToString())
            If tmpdlProb IsNot Nothing Then SelectDropdownlist(tmpdlProb, tmpProb.ToString())
            If tmpdlStatus IsNot Nothing Then SelectDropdownlist(tmpdlStatus, tmpcode.ToString())
            If e.Row.FindControl("dlRowAccount") IsNot Nothing Then CType(e.Row.FindControl("dlRowAccount"), TextBox).Attributes.Add("DISABLED", "DISABLED")
            If e.Row.FindControl("dlRowContact") IsNot Nothing Then CType(e.Row.FindControl("dlRowContact"), TextBox).Attributes.Add("DISABLED", "DISABLED")
            Dim cid As String = "", cmail As String = ""
            If e.Row.FindControl("lbRowContact") IsNot Nothing Then
                cid = CType(e.Row.FindControl("lbRowContact"), Label).Text
                If cid <> "" Then cmail = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(email_address + ' (' + FirstName+' '+LastName+')','') from SIEBEL_CONTACT where row_id='{0}'", cid)).ToString()
                CType(e.Row.FindControl("lbRowContact"), Label).Text = cmail
            End If
            If e.Row.FindControl("dlRowContact") IsNot Nothing Then
                cid = CType(e.Row.FindControl("dlRowContact"), TextBox).Text
                If cid <> "" Then cmail = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(email_address + ' (' + FirstName+' '+LastName+')'+' ('+row_id+')','') from SIEBEL_CONTACT where row_id='{0}'", cid)).ToString()
                CType(e.Row.FindControl("dlRowContact"), TextBox).Text = cmail
            End If
            If e.Row.FindControl("lbRowAccount") IsNot Nothing Then
                Dim accname As String = ""
                If CType(e.Row.FindControl("lbRowAccount"), Label).Text <> "" Then accname = CType(e.Row.FindControl("lbRowAccount"), Label).Text
                If dbUtil.dbExecuteScalar("My", String.Format("select top 1 isnull(account_row_id,'') from opportunity_draft where account_name = N'{0}'", accname)).ToString = "" Then
                    e.Row.FindControl("hlRowAccount").Visible = True
                Else
                    e.Row.FindControl("hlRowAccount").Visible = False
                End If
            End If
            If e.Row.FindControl("dlRowAccount") IsNot Nothing Then
                If CType(e.Row.FindControl("dlRowAccount"), TextBox).Text = "" Then
                    e.Row.FindControl("hlRowEditAccount").Visible = True
                    CType(e.Row.FindControl("dlRowApprovalStatus"), DropDownList).Items(2).Enabled = False
                    CType(e.Row.FindControl("btnRowPickContact"), Button).Enabled = False
                Else
                    e.Row.FindControl("hlRowEditAccount").Visible = False
                End If
            End If
            If e.Row.FindControl("lbRowRevenue") IsNot Nothing Then
                If e.Row.FindControl("lbRowCurrency") IsNot Nothing Then
                    If CType(e.Row.FindControl("lbRowCurrency"), Label).Text = "USD" Then
                        CType(e.Row.FindControl("lbRowRevenue"), Label).Text = CDbl(CType(e.Row.FindControl("lbRowRevenue"), Label).Text).ToString("#,##0.00")
                    Else
                        CType(e.Row.FindControl("lbRowRevenue"), Label).Text = CInt(CType(e.Row.FindControl("lbRowRevenue"), Label).Text).ToString("#,##")
                    End If
                End If
            End If
            If e.Row.FindControl("txtRowRevenue") IsNot Nothing Then
                If tmpdlCurr IsNot Nothing Then
                    If tmpdlCurr.SelectedValue = "USD" Then
                        CType(e.Row.FindControl("txtRowRevenue"), TextBox).Text = CDbl(CType(e.Row.FindControl("txtRowRevenue"), TextBox).Text).ToString("#,##0.00")
                    Else
                        CType(e.Row.FindControl("txtRowRevenue"), TextBox).Text = CInt(CType(e.Row.FindControl("txtRowRevenue"), TextBox).Text).ToString("#,##")
                    End If
                End If
            End If
        End If
        
    End Sub
    
    Private Function SelectDropdownlist(ByRef dl As DropDownList, ByVal chkvalue As String) As Integer
        For i As Integer = 0 To dl.Items.Count - 1
            If dl.Items(i).Value = chkvalue Then
                dl.Items(i).Selected = True
                dl.SelectedIndex = i
                Return i
            End If
        Next
        Return -1
    End Function
    
    Protected Sub Updating(ByVal s As Object, ByVal e As GridViewUpdateEventArgs) Handles OptyAdminGv.RowUpdating
        
        Dim tmprow As GridViewRow = OptyAdminGv.Rows(e.RowIndex)
        Dim tmprev As String = CType(tmprow.FindControl("txtRowRevenue"), TextBox).Text
        If Double.TryParse(tmprev, 0) = False Then
            'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "no!!", "", False, "", "")
            e.Cancel = True : Exit Sub
        End If
        Dim tmpcode As Integer = CType(tmprow.FindControl("dlRowApprovalStatus"), DropDownList).SelectedValue
        Dim tmpcurr As String = CType(tmprow.FindControl("dlRowCurrency"), DropDownList).SelectedValue
        Dim tmpprjname As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowProjectName"), TextBox).Text)
        Dim tmpdesc As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowDesc"), TextBox).Text.Replace(vbCrLf, "<br/>")) + " "
        Dim tmpstage As String = CType(tmprow.FindControl("dlRowStage"), DropDownList).SelectedValue
        Dim tmpprob As Double = Double.Parse(CType(tmprow.FindControl("dlRowStage"), DropDownList).SelectedValue.Split("%")(0))
        Dim tmparowid As String = CType(tmprow.FindControl("dlRowAccount"), TextBox).Text
        Dim tmpcrowid As String = ""
        If CType(tmprow.FindControl("dlRowContact"), TextBox).Text <> "" Then tmpcrowid = CType(tmprow.FindControl("dlRowContact"), TextBox).Text.Split("(")(2).Replace(")", "")
        Dim tmpownerid As String = dbUtil.dbExecuteScalar("CRMDB75", _
              String.Format("select top 1 a.LOGIN from S_USER a where a.ROW_ID = '{0}'", CType(tmprow.FindControl("txtRowOwner"), TextBox).Text.Split("(")(1).Replace(")", "").Trim())).ToString
        With optySrc.UpdateParameters
            .Item("PRJNAME").DefaultValue = tmpprjname : .Item("STAGE").DefaultValue = tmpstage
            .Item("PROB").DefaultValue = tmpprob : .Item("ACCOUNTID").DefaultValue = tmparowid
            .Item("REVENUE").DefaultValue = CDbl(tmprev) : .Item("CURR").DefaultValue = tmpcurr
            .Item("DESC").DefaultValue = tmpdesc : .Item("CONTACTID").DefaultValue = tmpcrowid
            .Item("SCODE").DefaultValue = tmpcode : .Item("ROWID").DefaultValue = ""
            .Item("OWNERID").DefaultValue = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowOwner"), TextBox).Text.Trim()) : .Item("ACTROWID").DefaultValue = ""
        End With
        If IsProjExist(tmpprjname) Then
            optySrc.UpdateParameters.Item("SCODE").DefaultValue = 0
            Util.AjaxJSAlert(Up3, "This project name has been existed in Siebel.")
            Exit Sub
        End If
        If tmpcode = 2 Then
            If tmparowid = "" Then
                optySrc.UpdateParameters.Item("SCODE").DefaultValue = 0
                Util.AjaxJSAlert(Up3, "This account has not been approved. Please approve it first.")
                Exit Sub
            End If
            Dim ws As New MYSIEBELDAL, err As String = ""
            Dim tmpcontact As String = ""
            If tmpcrowid <> "" Then tmpcontact = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(EMAIL_ADDRESS,'') from SIEBEL_CONTACT where row_id='{0}'", tmpcrowid)).ToString()
            Dim tmprowid As String = ws.CreateSiebelOpportunity(tmparowid, tmpprjname, tmpdesc, tmpstage, tmprev, "Y", tmpownerid, tmpcurr, "", tmpcontact, True, err)
            If tmprowid = "" And err <> "" Then
                Util.AjaxJSAlert(Up3, "Error creating lead to Siebel(opty)")
                e.Cancel = True : Exit Sub
            End If
            optySrc.UpdateParameters.Item("ROWID").DefaultValue = tmprowid
            
            Dim err1 As String = ""
            Dim tmpactdesc As String = "Upload Lead -- " + tmpprjname
            'Dim tmpaccountrowid As String = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(row_id,'') from siebel_account where erp_id='{0}'", CType(tmprow.FindControl("txtRowERP"), TextBox).Text)).ToString
            Dim tmpactid As String = ws.CreateSiebelActivity("Email - Inbound", tmprowid, tmpownerid, tmparowid, tmpactdesc, tmpdesc, err1)
            If tmpactid = "" And err1 <> "" Then
                Util.AjaxJSAlert(Up3, "Error creating lead to Siebel(action)")
                e.Cancel = True : Exit Sub
            End If
            optySrc.UpdateParameters.Item("ACTROWID").DefaultValue = tmpactid
        End If
    End Sub
    
    Protected Sub Updated(ByVal s As Object, ByVal e As GridViewUpdatedEventArgs) Handles OptyAdminGv.RowUpdated
    End Sub

    Protected Sub optySrc_Updated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
        'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", optySrc.UpdateParameters.Item("SCODE").DefaultValue.ToString, "", False, "", "")
        If optySrc.UpdateParameters.Item("SCODE").DefaultValue = 2 Then
            If optySrc.UpdateParameters("ROWID").DefaultValue <> "" Then dbUtil.dbExecuteNoQuery("MY", String.Format("UPDATE OPPORTUNITY_DRAFT set approved_by='{0}', approved_date=GetDate() where row_id='{1}'", Session("user_id"), optySrc.UpdateParameters("ROWID").DefaultValue))
        End If
    End Sub

    Protected Sub optySrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 90 * 1000
    End Sub

    Protected Sub lbRowOwner_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lb As Label = CType(sender, Label)
        lb.Text = lb.Text.Split("(")(0).Trim()
    End Sub

    Protected Sub btnCreateAccount_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("/My/CreateAccount.aspx")
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Session("NewCreatedAccount") <> "" Then
                btnPickAccount.Enabled = False : btnCreateAccount.Enabled = False : btnPickContact.Enabled = False : txtAccount.Text = Session("NewCreatedAccount") : btnClear.Visible = True
            Else
                btnPickAccount.Enabled = True : btnCreateAccount.Enabled = True : btnPickContact.Enabled = True : btnClear.Visible = False
            End If
            If Session("Owner") <> "" Then
                txtOwner.Text = Session("Owner")
            End If
        End If
    End Sub
        
    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Session("NewCreatedAccount") = "" : btnPickAccount.Enabled = True : btnCreateAccount.Enabled = True : btnPickContact.Enabled = True : btnClear.Visible = False : txtAccount.Text = "" : Session("Owner") = ""
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript">
var txtid;
function PickOwner(flag,id){
   window.open("/Includes/PickSiebelContact.aspx?Flag=Owner&Flag1="+flag, "pop","height=470,width=680,scrollbars=yes");
   txtid=id.substring(0,id.lastIndexOf("_")+1);
}
function updateFromChildWindow(updateValue,flag)
{
    if (flag=="gv")
    {
        document.getElementById(txtid+'txtRowOwner').value = updateValue;
    }
    else
    {
        document.getElementById('<%= Me.txtOwner.ClientID %>').value = updateValue;
    }
}
function PickAccount(){
    window.open("/Includes/PickSiebelAccount.aspx", "pop","height=470,width=680,scrollbars=yes");
}
function updateFromChildWindowAcc(updateValue)
{
    document.getElementById('<%= Me.txtAccount.ClientID %>').value = updateValue;
    document.getElementById('<%= Me.txtContact.ClientID %>').value = "";
}
function PickContact(flag,flag1,id){
    if(flag1!="gv"){
//        if (document.getElementById('<%= Me.txtAccount.ClientID %>').value=="") {
//            alert("Please pick an account first.");
//            return;
//        }
    }
    var txtaccount;
    if(flag1=="gv") {
        txtid=id.substring(0,id.lastIndexOf("_")+1);
        txtaccount=document.getElementById(txtid+'dlRowAccount').value;
    }
    else{
        txtaccount=document.getElementById('<%= Me.txtAccount.ClientID %>').value;
    }
    window.open("/Includes/PickSiebelContact.aspx?Flag="+flag+"&Flag1="+flag1+"&accid="+txtaccount, "pop","height=470,width=680,scrollbars=yes");
}
function updateFromChildWindowContact(updateValue1,updateValue2,flag)
{
    if(flag=="gv") {
        document.getElementById(txtid+'dlRowContact').value=updateValue1;
    }
    else{
        document.getElementById('<%= Me.txtAccount.ClientID %>').value = updateValue2;
        document.getElementById('<%= Me.txtContact.ClientID %>').value = updateValue1;
    }
}
</script>

    <table width="100%" border="0" cellpadding="0" cellspacing="2">
        <tr>
            <td colspan="2">
                <h3>Upload Leads</h3>
            </td>
        </tr>
        <tr align="left">
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="Up1" UpdateMode="Conditional">
                    <ContentTemplate>
                         <table width="100%" border="0" cellpadding="0" cellspacing="1">
                            <tr>
                                <th align="left" width="10%"><font color="red">*</font>Account</th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtAccount" Width="250px" Enabled="false" />
                                    <asp:Button runat="server" ID="btnPickAccount" Text="Pick" OnClientClick="PickAccount();return false;" />
                                    <asp:Button runat="server" ID="btnCreateAccount" Text="Create New Account" OnClick="btnCreateAccount_Click" />
                                </td>
                            </tr>
                            <tr>
                                <th align="left" width="10%">Contact</th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtContact" Width="250px" Enabled="false" />
                                    <asp:Button runat="server" ID="btnPickContact" Text="Pick" OnClientClick="PickContact('PickContact','','');return false;" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>            
            </td>            
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Project Name</th>
            <td>
                <asp:TextBox runat="server" ID="txtPrjName" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Amount</th>
            <td>
                <asp:TextBox runat="server" ID="txtRevenue" Width="200px" />
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRevenue" FilterMode="ValidChars" FilterType="Numbers,Custom" ValidChars="." TargetControlID="txtRevenue" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Currency</th>
            <td>
               <asp:UpdatePanel runat="server" ID="Up2">
                    <ContentTemplate>
                        <asp:DropDownList runat="server" ID="dlCurrency">
                            <asp:ListItem Text="NTD" Value="NTD" />
                            <asp:ListItem Text="USD" Value="USD" />
                        </asp:DropDownList> 
                    </ContentTemplate>
                </asp:UpdatePanel>           
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Owner</th>
            <td>
                <asp:TextBox runat="server" ID="txtOwner" Enabled="false" Width="250" />
                <input name="Pick" style="cursor:hand" value="Pick" type="button" onclick="PickOwner('','');" id="Button11" runat="server" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Description</th>
            <td>
                <asp:TextBox runat="server" ID="txtDesc" Width="450px" TextMode="MultiLine" MaxLength="1000"  Rows="6"/>
            </td>
        </tr>        
        <tr>
            <td colspan="2" align="left">
                <asp:Button runat="server" ID="btnCreate" Text="Submit" OnClick="btnCreate_Click" />
                <ajaxToolkit:ConfirmButtonExtender runat="server" ID="cbeCreate" TargetControlID="btnCreate" ConfirmText="This request will send to the owner." ConfirmOnFormSubmit="true" />
                <asp:Button runat="server" ID="btnClear" Text="Clear this New Account" Visible="false" OnClick="btnClear_Click" />
                <ajaxToolkit:ConfirmButtonExtender runat="server" ID="cbeClear" TargetControlID="btnClear" ConfirmText="Do you want to clear this account created before?" ConfirmOnFormSubmit="true"></ajaxToolkit:ConfirmButtonExtender>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="left">&nbsp;</td>
        </tr>
        <tr runat="server" id="AdminRow" visible="false">
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="Up3">
                    <ContentTemplate>
                        <h4>Uploaded Leads (Visible to Internal User Only)</h4>
                        <sgv:SmartGridView Width="95%" runat="server" ID="OptyAdminGv" DataKeyNames="TEMP_ID"
                            AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" DataSourceID="optySrc" OnRowDataBoundDataRow="OptyAdminGv_RowDataBoundDataRow">
                            <Columns>
                                <asp:CommandField ShowEditButton="true" EditText="Update"/>                                                        
                                <asp:TemplateField HeaderText="Approval Status" SortExpression="APPROVAL_STATUS">
                                    <ItemTemplate>
                                        <table>
                                            <tr>
                                                <td><asp:Label runat="server" ID="lbRowApproveStatus" Text='<%#Eval("APPROVAL_STATUS") %>' /></td>
                                                <td><asp:HyperLink runat="server" ID="hlRowAccount" Text="Approve Account" NavigateUrl="/My/CreateAccount.aspx" Visible="false" /></td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowApprovalStatus">
                                                        <asp:ListItem Text="Waiting" Value="0" />
                                                        <asp:ListItem Text="Rejected" Value="1" />
                                                        <asp:ListItem Text="Approved" Value="2" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td><asp:HyperLink runat="server" ID="hlRowEditAccount" Text="Approve Account" NavigateUrl="/My/CreateAccount.aspx" Visible="false" /></td>
                                            </tr>
                                        </table>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="Created Date" SortExpression="CREATED_DATE" DataField="CREATED_DATE" ReadOnly="true" />
                                <asp:BoundField HeaderText="Created By" SortExpression="CREATED_BY" DataField="CREATED_BY" ReadOnly="true"/>
                                <asp:TemplateField HeaderText="Lead Detail" SortExpression="PROJECT_NAME">
                                    <ItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <th colspan="2"><font color="red">Owner</font></th><th colspan="2"><font color="red">Parent Account</font></th>
                                            </tr>
                                            <tr>
                                                <td colspan="2"><asp:Label runat="server" ID="lbRowOwner" Text='<%#Eval("OWNER_ID") %>' ForeColor="Blue" Font-Bold="true" OnDataBinding="lbRowOwner_DataBinding" /></td>
                                                <td colspan="2"><asp:Label runat="server" ID="lblRowERP" Text='<%#Eval("PARENT_ACCOUNT_ERPID") %>' ForeColor="Blue" Font-Bold="true" /></td>
                                            </tr>
                                            <tr>
                                                <th>Project Name</th><th>Amount</th><th>Currency</th><th>Description</th>                                                                        
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowProjectName" Text='<%#Eval("PROJECT_NAME") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowRevenue" Text='<%#Eval("REVENUE") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowCurrency" Text='<%#Eval("CURRENCY") %>' />
                                                </td>
                                                <td>
                                                    <asp:Textbox ReadOnly="true" Width="200px" TextMode="MultiLine" runat="server" ID="lbRowDesc" Text='<%#Replace(HttpUtility.HtmlDecode(Eval("DESCRIPTION")),"<br/>",VbCrLf) %>' />
                                                </td>                                                                        
                                            </tr>
                                            <tr>
                                                <th>Sales Stage</th><th>Probability</th><th>Account</th><th>Contact</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowStage" Width="150px" Text='<%#Eval("SALES_STAGE") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowProb" Text='<%#Eval("PROBABILITY") %>' />%
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowAccount" Text='<%#Eval("ACCOUNT_NAME") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lbRowContact" Text='<%#Eval("CONTACT_EMAIL") %>' />  
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <th><font color="red">Owner</font></th>
                                            </tr>
                                            <tr>
                                                <td colspan="8">
                                                    <asp:TextBox runat="server" ID="txtRowOwner" Text='<%#Eval("OWNER_ID") %>' Width="250" Enabled="false" />
                                                    <asp:Button runat="server" ID="Button2" Text="Pick" OnClientClick="PickOwner('gv',this.id);return false;" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th><font color="red">Parent Account</font></th>
                                            </tr>
                                            <tr>
                                                <td colspan="8">
                                                    <asp:TextBox runat="server" ID="txtRowERP" Text='<%#Eval("PARENT_ACCOUNT_ERPID") %>' Enabled="false" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Project Name</th><th>Amount</th><th>Currency</th><th>Description</th><th>Sales Stage</th>
                                                <th>Probability</th><th>Account</th><th>Contact</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowProjectName" Text='<%#Eval("PROJECT_NAME") %>' />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowRevenue" Text='<%#Eval("REVENUE") %>' Width="40px" />
                                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRowRevenue" FilterMode="ValidChars" FilterType="Numbers,Custom" ValidChars="." TargetControlID="txtRowRevenue" />
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowCurrency">
                                                        <asp:ListItem Text="NTD" Value="NTD" />
                                                        <asp:ListItem Text="USD" Value="USD" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowDesc" Text='<%#replace(HttpUtility.HtmlDecode(Eval("DESCRIPTION")),"<br/>",vbcrlf) %>' TextMode="MultiLine" Rows="5" Width="150px" />
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowStage">
                                                        <asp:ListItem Text="5% New Lead" Value="5% New Lead" />
                                                        <asp:ListItem Text="10% Validating" Value="10% Validating" />
                                                        <asp:ListItem Text="25% Proposing/Quoting" Value="25% Proposing/Quoting" />
                                                        <asp:ListItem Text="40% Testing" Value="40% Testing" />
                                                        <asp:ListItem Text="50% Negotiating" Value="50% Negotiating" />
                                                        <asp:ListItem Text="75% Waiting for PO/Approval" Value="75% Waiting for PO/Approval" />
                                                        <asp:ListItem Text="90% Expected Flow Business" Value="90% Expected Flow Business" />
                                                        <asp:ListItem Text="100% Won-PO Input in SAP" Value="100% Won-PO Input in SAP" />
                                                        <asp:ListItem Text="0% Lost" Value="0% Lost" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowProb" Text='<%#Eval("PROBABILITY") %>' Enabled="false" />
                                                </td>
                                                <td colspan="2">                                                   
                                                    <table width="100%">
                                                        <tr>
                                                            <td>
                                                                <asp:TextBox runat="server" ID="dlRowAccount" Text='<%#Eval("account_row_id") %>'/>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox runat="server" ID="dlRowContact" Text='<%#Eval("contact_email") %>' Width="250px" />
                                                                <asp:button runat="server" ID="btnRowPickContact" Text="Pick" OnClientClick="PickContact('PickContact','gv',this.id);return false;" />
                                                                <%--<asp:DropDownList Width="260px" runat="server" ID="dlRowContact" DataTextField="text" DataValueField="value"/>--%>
                                                            </td>
                                                        </tr>                                                                                        
                                                    </table>                                                                           
                                                </td>                                                                       
                                            </tr>                                                                    
                                        </table>
                                    </EditItemTemplate>
                                </asp:TemplateField>   
                                <asp:BoundField HeaderText="Approved By" SortExpression="APPROVED_BY" DataField="APPROVED_BY" ReadOnly="true" />
                                <asp:BoundField HeaderText="Approved Date" SortExpression="APPROVED_DATE" DataField="APPROVED_DATE" ReadOnly="true" />
                                <asp:BoundField HeaderText="Last Updated By" SortExpression="LAST_UPDATED_BY" DataField="LAST_UPDATED_BY" ReadOnly="true" />
                                <asp:BoundField HeaderText="Last Updated Date" SortExpression="LAST_UPDATED_DATE" DataField="LAST_UPDATED_DATE" ReadOnly="true" />
                            </Columns>
                            <PagerSettings Position="TopAndBottom" />
                        </sgv:SmartGridView>
                        <asp:SqlDataSource runat="server" ID="optySrc" ConnectionString="<%$ConnectionStrings:MY %>" 
                            SelectCommand="
                            SELECT TEMP_ID, PROJECT_NAME, SALES_STAGE, PROBABILITY, ACCOUNT_ROW_ID, LEAD_PARTNER, 
                            REVENUE, CURRENCY, DESCRIPTION, CREATED_BY, CONTACT_ROW_ID, CREATED_DATE, STATUS_CODE, 
                            case STATUS_CODE when 0 then 'Waiting' when 1 then 'Rejected' when 2 then 'Accepted' end as 'APPROVAL_STATUS',
                            APPROVED_BY, APPROVED_DATE, ROW_ID, LAST_UPDATED_BY, LAST_UPDATED_DATE,
                            ACCOUNT_NAME,
                            isnull(CONTACT_ROW_ID,'') as CONTACT_EMAIL,
                            OWNER_ID, ACT_ROW_ID, PARENT_ACCOUNT_ERPID  
                            FROM OPPORTUNITY_DRAFT order by CREATED_DATE desc" 
                            UpdateCommand="
                            UPDATE OPPORTUNITY_DRAFT
                            SET PROJECT_NAME = @PRJNAME, SALES_STAGE = @STAGE, PROBABILITY = @PROB, STATUS_CODE=@SCODE, 
                            ACCOUNT_ROW_ID = @ACCOUNTID, REVENUE = @REVENUE, ROW_ID=@ROWID,
                            CURRENCY = @CURR, DESCRIPTION = @DESC, CONTACT_ROW_ID = @CONTACTID, LAST_UPDATED_BY=@LUBY, 
                            LAST_UPDATED_DATE=GetDate(), OWNER_ID = @OWNERID, ACT_ROW_ID = @ACTROWID 
                            WHERE (TEMP_ID = @TEMP_ID)" OnUpdated="optySrc_Updated" OnSelecting="optySrc_Selecting">
                            <UpdateParameters>
                                <asp:Parameter DefaultValue="0" Name="SCODE" Type="Int16" />
                                <asp:Parameter DefaultValue="" Name="PRJNAME" Type="String" />
                                <asp:Parameter DefaultValue="" Name="STAGE" Type="String" />
                                <asp:Parameter DefaultValue="25.0" Name="PROB" Type="Double" />
                                <asp:Parameter DefaultValue="" Name="ACCOUNTID" Type="String" />
                                <asp:Parameter DefaultValue="0.0" Name="REVENUE" Type="Double" />
                                <asp:Parameter DefaultValue="" Name="CURR" Type="String" />
                                <asp:Parameter DefaultValue="" Name="DESC" Type="String" />
                                <asp:Parameter DefaultValue="" Name="CONTACTID" Type="String" />
                                <asp:SessionParameter DefaultValue="" Name="LUBY" SessionField="user_id" Type="String" />
                                <asp:Parameter DefaultValue="" Name="ROWID" Type="String" />
                                <asp:Parameter DefaultValue="" Name="OWNERID" Type="String" />
                                <asp:Parameter DefaultValue="" Name="ACTROWID" Type="String" />
                            </UpdateParameters>
                        </asp:SqlDataSource>                                                                          
                    </ContentTemplate> 
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnCreate" EventName="Click" />
                    </Triggers>                    
                </asp:UpdatePanel>                
            </td>
        </tr>
    </table>
</asp:Content>

