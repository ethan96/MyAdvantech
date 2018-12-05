<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Create Siebel Account" %>

<script runat="server">

    Private Function CheckAccount(ByVal AccountName As String) As Boolean
        Try
            If CInt(dbUtil.dbExecuteScalar("CRMDB75", String.Format("select count(*) from S_ORG_EXT where upper(NAME) = upper('{0}')", AccountName))) = 0 Then
                Return False
            End If
            Return True
        Catch ex As Exception
            Util.AjaxJSAlert(up1, "Siebel system is busy. Please try it again.")
        End Try
    End Function
    
    Protected Sub btnCreate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not PreValidateData(HttpUtility.HtmlEncode(txtName.Text.Trim()), txtTeam.Text, HttpUtility.HtmlEncode(txtPhone.Text.Trim()), HttpUtility.HtmlEncode(txtCity.Text.Trim()), HttpUtility.HtmlEncode(txtAddr.Text.Trim())) Then
            Util.AjaxJSAlert(up1, "Account Name, Account Team, Phone Number, City, Address are required.")
            Exit Sub
        End If
        
        If CheckAccount(HttpUtility.HtmlEncode(txtName.Text.Trim())) Then
            Util.AjaxJSAlert(up1, "This account name has been existed.")
            Exit Sub
        End If
        
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" INSERT INTO ACCOUNT_DRAFT ")
            .AppendLine(" (TEMP_ID, ACCOUNT_NAME, REGION, SITE, PHONE, FAX, ACCOUNT_TYPE, ACCOUNT_STATUS, ACCOUNT_TEAM, URL, CURRENCY, ")
            .AppendLine(" CITY, COUNTRY, ZIP_CODE, ADDRESS, CREATED_BY, CREATED_DATE, CONTACT_ROW_ID, BAA, ORGANIZATION, PARENT_ACCOUNT_ERPID) ")
            .AppendLine(" VALUES (@TEMPID, @NAME, @REGION, @SITE, @PHONE, @FAX, @TYPE, @STATUS, @TEAM, @URL, @CURR, @CITY, @COUNTRY, @ZIPCODE, @ADDRESS, @CREATEBY, GETDATE(), @CONTACTROWID, @BAA, @BU, @ERP)")
        End With
        Dim pTempId As New System.Data.SqlClient.SqlParameter("TEMPID", SqlDbType.VarChar) : pTempId.Value = NewId()
        Dim pName As New System.Data.SqlClient.SqlParameter("NAME", SqlDbType.NVarChar) : pName.Value = HttpUtility.HtmlEncode(txtName.Text.Trim())
        Dim pRegion As New System.Data.SqlClient.SqlParameter("REGION", SqlDbType.NVarChar) : pRegion.Value = HttpUtility.HtmlEncode(txtRegion.Text.Trim())
        Dim pSite As New System.Data.SqlClient.SqlParameter("SITE", SqlDbType.NVarChar) : pSite.Value = HttpUtility.HtmlEncode(txtSite.Text.Trim())
        Dim pPhone As New System.Data.SqlClient.SqlParameter("PHONE", SqlDbType.VarChar) : pPhone.Value = HttpUtility.HtmlEncode(txtPhone.Text.Trim())
        Dim pFax As New System.Data.SqlClient.SqlParameter("FAX", SqlDbType.VarChar) : pFax.Value = HttpUtility.HtmlEncode(txtFax.Text.Trim())
        Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.VarChar) : pType.Value = ""
        Dim pStatus As New System.Data.SqlClient.SqlParameter("STATUS", SqlDbType.VarChar) : pStatus.Value = ""
        Dim pTeam As New System.Data.SqlClient.SqlParameter("TEAM", SqlDbType.VarChar) : pTeam.Value = txtTeam.Text
        Dim pUrl As New System.Data.SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = HttpUtility.HtmlEncode(txtUrl.Text.Trim())
        Dim pCurr As New System.Data.SqlClient.SqlParameter("CURR", SqlDbType.VarChar) : pCurr.Value = dlCurrency.SelectedValue
        Dim pCity As New System.Data.SqlClient.SqlParameter("CITY", SqlDbType.NVarChar) : pCity.Value = HttpUtility.HtmlEncode(txtCity.Text.Trim())
        Dim pCountry As New System.Data.SqlClient.SqlParameter("COUNTRY", SqlDbType.VarChar) : pCountry.Value = dlCountry.SelectedValue
        Dim pZipCode As New System.Data.SqlClient.SqlParameter("ZIPCODE", SqlDbType.VarChar) : pZipCode.Value = HttpUtility.HtmlEncode(txtZip.Text.Trim())
        Dim pAddress As New System.Data.SqlClient.SqlParameter("ADDRESS", SqlDbType.NVarChar) : pAddress.Value = HttpUtility.HtmlEncode(txtAddr.Text.Trim())
        Dim pCBy As New System.Data.SqlClient.SqlParameter("CREATEBY", SqlDbType.VarChar) : pCBy.Value = Session("user_id")
        Dim pCId As New System.Data.SqlClient.SqlParameter("CONTACTROWID", SqlDbType.VarChar) : pCId.Value = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(row_id,'') from siebel_contact where email_address ='{0}'", txtTeam.Text.Split("(")(0).Trim())).ToString
        Dim pBAA As New System.Data.SqlClient.SqlParameter("BAA", SqlDbType.VarChar) : pBAA.Value = ""
        Dim pBU As New System.Data.SqlClient.SqlParameter("BU", SqlDbType.VarChar) : pBU.Value = ""
        Dim pERP As New System.Data.SqlClient.SqlParameter("ERP", SqlDbType.VarChar) : pERP.Value = Session("company_id")
        Dim para() As System.Data.SqlClient.SqlParameter = {pTempId, pName, pRegion, pSite, pPhone, pFax, pType, pStatus, pTeam, pUrl, pCurr, pCity, pCountry, pZipCode, pAddress, pCBy, pCId, pBAA, pBU, pERP}
        Dim retInt As Integer = dbUtil.dbExecuteNoQuery2("MY", sb.ToString(), para)
        gvAccount.DataBind()
        SendMail()
        'Dim ws As New Siebel_WS, err As String = ""
        'Dim rid As String = ws.CreateAccount(txtRegion.Text, txtName.Text, txtSite.Text, txtPhone.Text, txtFax.Text, _
        '                 dlType.SelectedValue, txtUrl.Text, dlStatus.SelectedValue, txtTeam.Text, txtCity.Text, _
        '                 dlCountry.SelectedValue, txtZip.Text, txtAddr.Text, dlBAA.SelectedValue, _
        '                 dlCurrency.SelectedValue, rbIsPartner.SelectedValue, dlBU.SelectedValue, err)
        'Response.Write(String.Format("rid:{0}<br/>err:{1}<br/>", rid, err))
        If retInt > 0 Then
            Session("NewCreatedAccount") = HttpUtility.HtmlEncode(txtName.Text.Trim())
            Session("Owner") = HttpUtility.HtmlEncode(txtTeam.Text)
            Response.Redirect("/My/CreateLead.aspx")
        End If
    End Sub
    
    Private Sub SendMail()
        Dim body As String
        body = "Dears,<br/><br/>" + _
               "A new account has been created.<br/>" + _
               "You can process it through this link <a href='http://my.advantech.eu/My/CreateAccount.aspx'>New Account Request</a><br/><br/>" + _
               "<table><tr>" + _
               "<td><b>Account Name : </b></td><td>" + HttpUtility.HtmlEncode(txtName.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Parent Account : </b></td><td>" + Session("company_name") + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Region : </b></td><td>" + HttpUtility.HtmlEncode(txtRegion.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Main Site : </b></td><td>" + HttpUtility.HtmlEncode(txtSite.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Phone Number : </b></td><td>" + HttpUtility.HtmlEncode(txtPhone.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Fax Number : </b></td><td>" + HttpUtility.HtmlEncode(txtFax.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Currency : </b></td><td>" + dlCurrency.SelectedValue + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Url : </b></td><td>" + HttpUtility.HtmlEncode(txtUrl.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Account Team : </b></td><td>" + HttpUtility.HtmlEncode(txtTeam.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Country : </b></td><td>" + dlCountry.SelectedValue + "</td>" + _
               "</tr><tr>" + _
               "<td><b>City : </b></td><td>" + HttpUtility.HtmlEncode(txtCity.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>ZIP Code : </b></td><td>" + HttpUtility.HtmlEncode(txtZip.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Address : </b></td><td>" + HttpUtility.HtmlEncode(txtAddr.Text.Trim()) + "</td>" + _
               "</tr><tr>" + _
               "<td><b>Created By : </b></td><td>" + Session("user_id") + " (" + Session("company_name") + ")</td></tr></table><br/><br/>" + _
               "Best Regards,<br/><a href='http://my.advantech.eu'>MyAdvantech</a>"
        Util.SendEmail(HttpUtility.HtmlEncode(txtTeam.Text.Split("(")(0).Trim()), "eBusiness.AEU@advantech.eu", "New Account Request", body, True, "", "tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw")
        'HttpUtility.HtmlEncode(txtTeam.Text.Split("(")(0).Trim())
    End Sub
    
    Private Function PreValidateData(ByVal name As String, ByVal team As String, ByVal phone As String, ByVal city As String, ByVal addr As String) As Boolean
        If name = "" OrElse team = "" OrElse phone = "" OrElse city = "" OrElse addr = "" Then
            Return False
        End If
        Return True
    End Function
    
    Private Shared Function NewId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(*) as counts from ACCOUNT_DRAFT where TEMP_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.End()
        If Not Page.IsPostBack Then
            'Session("company_id") = "T16270654" : Session("company_name") = "駿緯國際股份有限公司"
            If User.IsInRole("Administrator") Or User.IsInRole("Logistics") Then AdminRow.Visible = True
            If Session("NewCreatedAccount") <> "" Then btnCreate.Enabled = False
        End If
    End Sub

    Protected Sub gvAccount_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If DataBinder.Eval(e.Row.DataItem, "STATUS_CODE") = 2 Then
                CType(e.Row.Cells(0).Controls(0), LinkButton).Enabled = False
                CType(e.Row.Cells(0).Controls(0), LinkButton).ToolTip = "Cannot update account once it is approved"
                Exit Sub
            End If
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim tmpdlCurr As DropDownList = e.Row.FindControl("dlRowCurrency"), tmpCurr As String = DataBinder.Eval(e.Row.DataItem, "CURRENCY")
            Dim tmpdlCountry As DropDownList = e.Row.FindControl("dlRowCountry"), tmpCountry As String = DataBinder.Eval(e.Row.DataItem, "COUNTRY")
            Dim tmpdltype As DropDownList = e.Row.FindControl("dlRowType"), tmpType As String = DataBinder.Eval(e.Row.DataItem, "ACCOUNT_TYPE")
            Dim tmpdlstatus As DropDownList = e.Row.FindControl("dlRowStatus"), tmpStatus As String = DataBinder.Eval(e.Row.DataItem, "ACCOUNT_STATUS")
            Dim tmpdlbaa As DropDownList = e.Row.FindControl("dlRowBAA"), tmpBAA As String = DataBinder.Eval(e.Row.DataItem, "BAA")
            Dim tmpdlbu As DropDownList = e.Row.FindControl("dlRowBU"), tmpBU As String = DataBinder.Eval(e.Row.DataItem, "ORGANIZATION")
            Dim tmpdlAppstatus As DropDownList = e.Row.FindControl("dlRowApprovalStatus"), tmpcode As Integer = DataBinder.Eval(e.Row.DataItem, "STATUS_CODE")
            If tmpdlCurr IsNot Nothing Then SelectDropdownlist(tmpdlCurr, tmpCurr)
            If tmpdlCountry IsNot Nothing Then SelectDropdownlist(tmpdlCountry, tmpCountry)
            If tmpdltype IsNot Nothing Then SelectDropdownlist(tmpdltype, tmpType)
            If tmpdlstatus IsNot Nothing Then SelectDropdownlist(tmpdlstatus, tmpStatus)
            If tmpdlbaa IsNot Nothing Then SelectDropdownlist(tmpdlbaa, tmpBAA)
            If tmpdlbu IsNot Nothing Then SelectDropdownlist(tmpdlbu, tmpBU)
            If tmpdlAppstatus IsNot Nothing Then SelectDropdownlist(tmpdlAppstatus, tmpcode.ToString())
            Dim tmplbispartner As Label = e.Row.FindControl("lblRowIsPartner")
            Dim tmprbispartner As RadioButtonList = e.Row.FindControl("rbRowIsPartner")
            If DataBinder.Eval(e.Row.DataItem, "IS_PARTNER") = "N" Then
                If tmplbispartner IsNot Nothing Then tmplbispartner.Text = "No"
                If tmprbispartner IsNot Nothing Then tmprbispartner.Items(1).Selected = True : tmprbispartner.Items(0).Selected = False
            Else
                If tmplbispartner IsNot Nothing Then tmplbispartner.Text = "Yes"
                If tmprbispartner IsNot Nothing Then tmprbispartner.Items(0).Selected = True : tmprbispartner.Items(1).Selected = False
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
    
    Protected Sub accSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 90 * 1000
    End Sub

    Protected Sub accSrc_Updated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
        If accSrc.UpdateParameters.Item("SCODE").DefaultValue = 2 Then
            dbUtil.dbExecuteNoQuery("MY", String.Format("UPDATE ACCOUNT_DRAFT set approved_by='{0}', approved_date=GetDate() where row_id='{1}'", Session("user_id"), accSrc.UpdateParameters("ROWID").DefaultValue))
        End If
    End Sub
    
    Protected Sub Updating(ByVal s As Object, ByVal e As GridViewUpdateEventArgs) Handles gvAccount.RowUpdating
        Dim oriAccName As String = dbUtil.dbExecuteScalar("My", String.Format("select account_name from account_draft where temp_id='{0}'", e.Keys(0).ToString))
        Dim tmprow As GridViewRow = gvAccount.Rows(e.RowIndex)
        Dim tmpcode As Integer = CType(tmprow.FindControl("dlRowApprovalStatus"), DropDownList).SelectedValue
        Dim tmpname As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowName"), TextBox).Text.Trim())
        Dim tmpregion As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowRegion"), TextBox).Text.Trim())
        Dim tmpsite As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowSite"), TextBox).Text.Trim())
        Dim tmpphone As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowPhone"), TextBox).Text.Trim())
        Dim tmpfax As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowFax"), TextBox).Text.Trim())
        Dim tmptype As String = CType(tmprow.FindControl("dlRowType"), DropDownList).SelectedValue
        Dim tmpstatus As String = CType(tmprow.FindControl("dlRowStatus"), DropDownList).SelectedValue
        Dim tmpteam As String = CType(tmprow.FindControl("txtRowTeam"), TextBox).Text
        Dim tmpteamlogin As String = dbUtil.dbExecuteScalar("CRMDB75", _
              String.Format("select top 1 a.LOGIN from S_USER a where a.ROW_ID = '{0}'", CType(tmprow.FindControl("txtRowTeam"), TextBox).Text.Split("(")(1).Replace(")", "").Trim())).ToString
        Dim tmpurl As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowUrl"), TextBox).Text.Trim())
        Dim tmpcurr As String = CType(tmprow.FindControl("dlRowCurrency"), DropDownList).SelectedValue
        Dim tmpcity As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowCity"), TextBox).Text.Trim())
        Dim tmpcountry As String = CType(tmprow.FindControl("dlRowCountry"), DropDownList).SelectedValue
        Dim tmpzcode As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowZip"), TextBox).Text.Trim())
        Dim tmpaddr As String = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowAddr"), TextBox).Text.Trim())
        Dim tmpbaa As String = CType(tmprow.FindControl("dlRowBAA"), DropDownList).SelectedValue
        Dim tmpbu As String = CType(tmprow.FindControl("dlRowBU"), DropDownList).SelectedValue
        Dim tmpispartner As String = CType(tmprow.FindControl("rbRowIsPartner"), RadioButtonList).SelectedValue
        Dim tmperp As String = CType(tmprow.FindControl("txtRowERP"), TextBox).Text
        Dim tmpcid As String
        If tmpteam = "" Then
            tmpcid = ""
        Else
            tmpcid = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(row_id,'') from siebel_contact where email_address ='{0}'", tmpteam.Split("(")(0).Trim())).ToString()
        End If
        
        With accSrc.UpdateParameters
            .Item("NAME").DefaultValue = tmpname : .Item("REGION").DefaultValue = tmpregion
            .Item("SITE").DefaultValue = tmpsite : .Item("PHONE").DefaultValue = tmpphone
            .Item("FAX").DefaultValue = tmpfax : .Item("TYPE").DefaultValue = tmptype
            .Item("STATUS").DefaultValue = tmpstatus : .Item("TEAM").DefaultValue = tmpteam
            .Item("URL").DefaultValue = tmpurl : .Item("CURRENCY").DefaultValue = tmpcurr
            .Item("CITY").DefaultValue = tmpcity : .Item("COUNTRY").DefaultValue = tmpcountry
            .Item("ZIP_CODE").DefaultValue = tmpzcode : .Item("ADDR").DefaultValue = tmpaddr
            .Item("BAA").DefaultValue = tmpbaa : .Item("BU").DefaultValue = tmpbu
            .Item("IS_PARTNER").DefaultValue = tmpispartner : .Item("CROWID").DefaultValue = tmpcid
            .Item("SCODE").DefaultValue = tmpcode : .Item("ROWID").DefaultValue = ""
        End With
        dbUtil.dbExecuteNoQuery("My", String.Format("update opportunity_draft set account_name='{0}' where account_name='{1}'", tmpname, oriAccName))
        If CheckAccount(tmpname) Then
            accSrc.UpdateParameters.Item("SCODE").DefaultValue = 0
            Util.AjaxJSAlert(up1, "This account has been existed.")
            Exit Sub
        End If
        If Not PreValidateData(tmpname, tmpteam, tmpphone, tmpcity, tmpaddr) Then
            accSrc.UpdateParameters.Item("SCODE").DefaultValue = 0
            Util.AjaxJSAlert(up1, "Account Name, Account Team, Phone Number, City, Address are required.")
            Exit Sub
        End If
        If tmpcode = 2 Then
            Dim ws As New MYSIEBELDAL, err As String = ""
            Dim tmpsfax As String = ""
            If tmpfax <> "" Then tmpsfax = "+886" + tmpfax
            Dim paccrowid As String = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(row_id,'') from siebel_account where erp_id='{0}'", tmperp)).ToString
            Dim tmprowid As String = ws.CreateAccount(tmpregion, tmpname, tmpsite, "+886" + tmpphone, tmpsfax, tmptype, tmpurl, tmpstatus, tmpteamlogin, tmpcity, tmpcountry, tmpzcode, tmpaddr, tmpbaa, tmpcurr, tmpispartner, tmpbu, paccrowid, err)
            If tmprowid = "" And err <> "" Then
                Util.AjaxJSAlert(up1, "Error creating account to Siebel")
                e.Cancel = True : Exit Sub
            End If
            accSrc.UpdateParameters.Item("ROWID").DefaultValue = tmprowid
            dbUtil.dbExecuteNoQuery("My", String.Format("update opportunity_draft set account_row_id='{0}' where account_name=N'{1}'", tmprowid, tmpname))
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(" INSERT INTO SIEBEL_ACCOUNT ")
                .AppendLine(" (ROW_ID, ACCOUNT_NAME, ACCOUNT_STATUS, FAX_NUM, PHONE_NUM, OU_TYPE_CD, URL, ACCOUNT_TYPE, RBU, ")
                .AppendLine(" MAJORACCOUNT_FLAG, COMPETITOR_FLAG, PARTNER_FLAG, COUNTRY, CITY, ADDRESS, BAA, CREATED, LAST_UPDATED, PARENT_ROW_ID) ")
                .AppendLine(" VALUES (@ROWID, @NAME, @STATUS, @FAX, @PHONE, @TYPE, @URL, @TYPE, @BU, @ISMAJORACCOUNT, @ISCOMPETITOR, @ISPARTNER, @COUNTRY, @CITY, @ADDRESS, @BAA, @CREATED, GETDATE(), @PROWID)")
            End With
            Dim pRowId As New System.Data.SqlClient.SqlParameter("ROWID", SqlDbType.NVarChar) : pRowId.Value = tmprowid
            Dim pName As New System.Data.SqlClient.SqlParameter("NAME", SqlDbType.NVarChar) : pName.Value = tmpname
            Dim pStatus As New System.Data.SqlClient.SqlParameter("STATUS", SqlDbType.NVarChar) : pStatus.Value = tmpstatus
            Dim pFax As New System.Data.SqlClient.SqlParameter("FAX", SqlDbType.NVarChar) : pFax.Value = tmpfax
            Dim pPhone As New System.Data.SqlClient.SqlParameter("PHONE", SqlDbType.NVarChar) : pPhone.Value = tmpphone
            Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.NVarChar) : pType.Value = tmptype
            Dim pUrl As New System.Data.SqlClient.SqlParameter("URL", SqlDbType.NVarChar) : pUrl.Value = tmpurl
            Dim pBU As New System.Data.SqlClient.SqlParameter("BU", SqlDbType.NVarChar) : pBU.Value = tmpbu
            Dim pMj As New System.Data.SqlClient.SqlParameter("ISMAJORACCOUNT", SqlDbType.NVarChar) : pMj.Value = "N"
            Dim pCP As New System.Data.SqlClient.SqlParameter("ISCOMPETITOR", SqlDbType.NVarChar) : pCP.Value = "N"
            Dim pPartner As New System.Data.SqlClient.SqlParameter("ISPARTNER", SqlDbType.NVarChar) : pPartner.Value = tmpispartner
            Dim pCountry As New System.Data.SqlClient.SqlParameter("COUNTRY", SqlDbType.NVarChar) : pCountry.Value = tmpcountry
            Dim pCity As New System.Data.SqlClient.SqlParameter("CITY", SqlDbType.NVarChar) : pCity.Value = tmpcity
            Dim pAddress As New System.Data.SqlClient.SqlParameter("ADDRESS", SqlDbType.NVarChar) : pAddress.Value = tmpaddr
            Dim pBAA As New System.Data.SqlClient.SqlParameter("BAA", SqlDbType.NVarChar) : pBAA.Value = tmpbaa
            Dim pCBy As New System.Data.SqlClient.SqlParameter("CREATED", SqlDbType.DateTime) : pCBy.Value = CDate(tmprow.Cells(2).Text)
            Dim pPID As New System.Data.SqlClient.SqlParameter("PROWID", SqlDbType.NVarChar) : pPID.Value = paccrowid
            Dim para() As System.Data.SqlClient.SqlParameter = {pRowId, pName, pStatus, pFax, pPhone, pType, pUrl, pBU, pMj, pCP, pPartner, pCountry, pCity, pAddress, pCBy, pBAA, pPID}
            dbUtil.dbExecuteNoQuery2("RFM", sb.ToString(), para)
        End If
    End Sub

    Protected Sub dlCountry_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub dlCountry_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        For i As Integer = 0 To dlCountry.Items.Count - 1
            If dlCountry.Items(i).Value = "Taiwan" Then dlCountry.Items(i).Selected = True
        Next
    End Sub

    Protected Sub lblRowTeam_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lb As Label = CType(sender, Label)
        lb.Text = lb.Text.Split("(")(0).Trim()
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
<script type="text/javascript">
var txtid;
function PickOwner(flag,id){
   window.open("/Includes/PickSiebelContact.aspx?Flag=AccountTeam&Flag1="+flag, "pop","height=470,width=680,scrollbars=yes");
   txtid=id.substring(0,id.lastIndexOf("_")+1);
}
function updateFromChildWindow(updateValue,flag)
{
    if (flag=="gv")
    {
        document.getElementById(txtid+'txtRowTeam').value=updateValue;
    }
    else
    {
        document.getElementById('<%= Me.txtTeam.ClientID %>').value = updateValue;
    }
}
</script>
    <h3>Create Siebel Account</h3>
    <table width="100%" border="0">
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Account Name</th>
            <td>
                <asp:TextBox runat="server" ID="txtName" Width="200px" />
                <asp:RequiredFieldValidator runat="server" ID="rfvName" ErrorMessage=" *" ForeColor="Red" ControlToValidate="txtName" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Region</th>
            <td>
                <asp:TextBox runat="server" ID="txtRegion" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Main Site</th>
            <td>
                <asp:TextBox runat="server" ID="txtSite" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Phone Number</th>
            <td>
                <asp:TextBox runat="server" ID="txtPhone" Width="200px" />
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbePhone" FilterType="Numbers,Custom" ValidChars="-, ,(,)" TargetControlID="txtPhone" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Fax Number</th>
            <td>
                <asp:TextBox runat="server" ID="txtFax" Width="200px" />
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeFax" FilterType="Numbers,Custom" ValidChars="-, ,(,)" TargetControlID="txtFax" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Currency</th> 
            <td>
                <asp:DropDownList runat="server" ID="dlCurrency"> 
                    <asp:ListItem Text="NTD" Value="NTD" />
                    <asp:ListItem Text="USD" Value="USD" /> 
                </asp:DropDownList> 
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Url</th>
            <td>
                <asp:TextBox runat="server" ID="txtUrl" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Account Team</th>
            <td>
                <asp:TextBox runat="server" ID="txtTeam" Width="200px" Enabled="false" Text="" />
                <input name="Pick" style="cursor:hand" value="Pick" type="button" onclick="PickOwner('','');" id="Button11"/>
                <asp:RequiredFieldValidator runat="server" ID="rfvTeam" ErrorMessage=" *" ForeColor="Red" ControlToValidate="txtTeam" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>City</th>
            <td>
                <asp:TextBox runat="server" ID="txtCity" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%">Country</th>
            <td>
                <asp:DropDownList runat="server" ID="dlCountry" DataTextField="text" DataValueField="value" DataSourceID="countrysrc" OnDataBinding="dlCountry_DataBinding" OnPreRender="dlCountry_PreRender" />
                <asp:SqlDataSource runat="server" ID="countrysrc" ConnectionString="<%$ConnectionStrings:RFM %>" 
                    SelectCommand="select TEXT, VALUE from SIEBEL_ACCOUNT_COUNTRY_LOV where VALUE<>'' and TEXT<>'' order by TEXT" />
            </td>
        </tr>        
        <tr>
            <th align="left" width="10%">ZIP Code</th>
            <td>
                <asp:TextBox runat="server" ID="txtZip" Width="200px" />
            </td>
        </tr>
        <tr>
            <th align="left" width="10%"><font color="red">*</font>Address</th>
            <td>
                <asp:TextBox runat="server" ID="txtAddr" Width="200px" />
            </td>
        </tr>
        <tr>
            <td colspan="2" align="left">
                <asp:Button runat="server" ID="btnCreate" Text="Submit" OnClick="btnCreate_Click" />
                <ajaxToolkit:ConfirmButtonExtender runat="server" ID="cbeCreate" TargetControlID="btnCreate" ConfirmText="This request will send to the Account Team." ConfirmOnFormSubmit="true" />
            </td>
        </tr>
        <tr><td colspan="2">&nbsp;</td></tr>
        <tr runat="server" id="AdminRow" visible="false">
            <td colspan="2" align="left">
                <asp:UpdatePanel runat="server" ID="up1">
                    <ContentTemplate>
                        <h4>Create Account Draft (Visible to Internal User Only)</h4>
                        <sgv:SmartGridView runat="server" ID="gvAccount" AutoGenerateColumns="false" Width="95%" DataKeyNames="TEMP_ID"
                             AllowPaging="true" AllowSorting="true" DataSourceID="accSrc" OnRowDataBoundDataRow="gvAccount_RowDataBoundDataRow">
                            <Columns>
                                <asp:CommandField ShowEditButton="true" EditText="Update" CausesValidation="false"/>    
                                <asp:TemplateField HeaderText="Approval Status" SortExpression="APPROVAL_STATUS" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowApproveStatus" Text='<%#Eval("APPROVAL_STATUS") %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:DropDownList runat="server" ID="dlRowApprovalStatus">
                                            <asp:ListItem Text="Waiting" Value="0" />
                                            <asp:ListItem Text="Rejected" Value="1" />
                                            <asp:ListItem Text="Approved" Value="2" />
                                        </asp:DropDownList>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="Created Date" SortExpression="CREATED_DATE" DataField="CREATED_DATE" ReadOnly="true" />
                                <asp:BoundField HeaderText="Created By" SortExpression="CREATED_BY" DataField="CREATED_BY" ReadOnly="true"/>
                                <asp:TemplateField HeaderText="Account Detail" SortExpression="ACCOUNT_NAME">
                                    <ItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <th colspan="4"><font color="red">Parent Account</font></th>
                                            </tr>
                                            <tr>
                                                <td colspan="4"><asp:Label runat="server" ID="lblRowERP" Text='<%#Eval("PARENT_ACCOUNT_ERPID") %>' ForeColor="Blue" Font-Bold="true" /></td>
                                            </tr>
                                            <tr>
                                                <th>Account Name</th><th>Account Type</th><th>Account Status</th><th>Account Team</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowName" Text='<%#Eval("ACCOUNT_NAME") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowType" Text='<%#Eval("ACCOUNT_TYPE") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowStatus" Text='<%#Eval("ACCOUNT_STATUS") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowTeam" Text='<%#Eval("ACCOUNT_TEAM") %>' OnDataBinding="lblRowTeam_DataBinding" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Region</th><th>Main Site</th><th>Phone</th><th>Fax</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowRegion" Text='<%#Eval("REGION") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowSite" Text='<%#Eval("SITE") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowPhone" Text='<%#Eval("PHONE") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowFax" Text='<%#Eval("FAX") %>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Currency</th><th>Country</th><th>City</th><th>ZIP Code</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowCurr" Text='<%#Eval("CURRENCY") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowCountry" Text='<%#Eval("COUNTRY") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowCity" Text='<%#Eval("CITY") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowZipCode" Text='<%#Eval("ZIP_CODE") %>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Address</th><th></th><th>Url</th><th></th>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:Label runat="server" ID="lblAddress" Text='<%#Eval("ADDRESS") %>' />
                                                </td>
                                                <td colspan="2" align="left">
                                                    <asp:Label runat="server" ID="lblUrl" Text='<%#Eval("URL") %>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Primary BAA</th><th>Is Partner?</th><th>Organization</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowBAA" Text='<%#Eval("BAA") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRowIsPartner" Text='<%#Eval("IS_PARTNER") %>' />
                                                </td>
                                                <td colspan="2">
                                                    <asp:Label runat="server" ID="lblOrganization" Text='<%#Eval("ORGANIZATION") %>' />
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <th colspan="4"><font color="red">Parent Account</font></th>
                                            </tr>
                                            <tr>
                                                <td colspan="4"><asp:TextBox runat="server" ID="txtRowERP" Text='<%#Eval("PARENT_ACCOUNT_ERPID") %>' Enabled="false" /></td>
                                            </tr>
                                            <tr>
                                                <th>Account Name</th><th>Account Type</th><th>Account Status</th><th>Account Team</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowName" Text='<%#Eval("ACCOUNT_NAME") %>' Width="200px" />
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowType">
                                                        <asp:ListItem Text="Alliance Partner" Value="Alliance Partner" />
                                                        <asp:ListItem Text="Catalog House" Value="Catalog House" />
                                                        <asp:ListItem Text="Construction Engineering" Value="Construction Engineering" />
                                                        <asp:ListItem Text="Consultant" Value="Consultant" />
                                                        <asp:ListItem Text="Distributor" Value="Distributor" />
                                                        <asp:ListItem Text="End user - Building Automation" Value="End user - Building Automation" />
                                                        <asp:ListItem Text="End user - Education" Value="End user - Education" />
                                                        <asp:ListItem Text="End user - eStore" Value="End user - eStore" />
                                                        <asp:ListItem Text="End user - General" value="End user - General" />
                                                        <asp:ListItem Text="End user - Government" Value="End user - Government" />
                                                        <asp:ListItem Text="End user - Military" Value="End user - Military" />
                                                        <asp:ListItem Text="End User - Medical" Value="End User - Medical" />
                                                        <asp:ListItem Text="Machine Manufactor" Value="Machine Manufactor" />
                                                        <asp:ListItem Text="ODM" Value="ODM" />
                                                        <asp:ListItem Text="OEM" Value="OEM" />
                                                        <asp:ListItem Text="Others" Value="Others" />
                                                        <asp:ListItem Text="Press-Design Agency" Value="Press-Design Agency" />
                                                        <asp:ListItem Text="Press-Online Media" Value="Press-Online Media" />
                                                        <asp:ListItem Text="Press-Others" Value="Press-Others" />
                                                        <asp:ListItem Text="Press-Printed Media" Value="Press-Printed Media" />
                                                        <asp:ListItem Text="Press-Research Agency" Value="Press-Research Agency" />
                                                        <asp:ListItem Text="Representative" Value="Representative" />
                                                        <asp:ListItem Text="SI / VAR" Value="SI / VAR" />
                                                        <asp:ListItem Text="Solution Partner" Value="Solution Partner" />
                                                        <asp:ListItem Text="Trader Import/Export" Value="Trader Import/Export" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowStatus">
                                                        <asp:ListItem Text="01-Premier Channel Partner" Value="01-Premier Channel Partner"></asp:ListItem>
                                                        <asp:ListItem Text="02-D&Ms PKA" Value="02-D&Ms PKA"></asp:ListItem>
                                                        <asp:ListItem Text="03-Premier Key Account" Value="03-Premier Key Account"></asp:ListItem>
                                                        <asp:ListItem Text="04-Channel Partner" Value="04-Channel Partner"></asp:ListItem>
                                                        <asp:ListItem Text="05-Golden Key Account(ACN)" Value="05-Golden Key Account(ACN)"></asp:ListItem>
                                                        <asp:ListItem Text="06-Key Account" Value="06-Key Account"></asp:ListItem>
                                                        <asp:ListItem Text="06P-Potential Key Account" Value="06P-Potential Key Account"></asp:ListItem>
                                                        <asp:ListItem Text="07-General Account" Value="07-General Account"></asp:ListItem>
                                                        <asp:ListItem Text="08-Partner's Existing Customer" Value="08-Partner's Existing Customer"></asp:ListItem>
                                                        <asp:ListItem Text="09-Assigned to Partner" Value="09-Assigned to Partner"></asp:ListItem>
                                                        <asp:ListItem Text="10-Sales Contact" Value="10-Sales Contact"></asp:ListItem>
                                                        <asp:ListItem Text="11-Prospect" Value="11-Prospect"></asp:ListItem>
                                                        <asp:ListItem Text="12-Leads" Value="12-Leads"></asp:ListItem>
                                                        <asp:ListItem Text="13-Press/Media" Value="13-Press/Media"></asp:ListItem>
                                                        <asp:ListItem Text="14-Inactive" Value="14-Inactive"></asp:ListItem>
                                                        <asp:ListItem Text="15-Unverified" Value="15-Unverified"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowTeam" Text='<%#Eval("ACCOUNT_TEAM") %>' Width="200px" Enabled="false" />
                                                    <asp:Button runat="server" ID="Button2" Text="Pick" OnClientClick="PickOwner('gv',this.id);return false;" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Region</th><th>Main Site</th><th>Phone</th><th>Fax</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowRegion" Text='<%#Eval("REGION") %>' Width="200px" />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowSite" Text='<%#Eval("SITE") %>' Width="200px" />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowPhone" Text='<%#Eval("PHONE") %>' Width="200px" />
                                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRowPhone" FilterType="Numbers,Custom" ValidChars="-, ,(,)" TargetControlID="txtRowPhone" />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowFax" Text='<%#Eval("FAX") %>' Width="200px" />
                                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRowFax" FilterType="Numbers,Custom" ValidChars="-, ,(,)" TargetControlID="txtRowFax" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Currency</th><th>Country</th><th>City</th><th>ZIP Code</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowCurrency">
                                                        <asp:ListItem Text="NTD" Value="NTD" />
                                                        <asp:ListItem Text="USD" Value="USD" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowCountry" DataTextField="text" DataValueField="value" DataSourceID="countrysrc" />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowCity" Text='<%#Eval("CITY") %>' Width="200px" />
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRowZip" Text='<%#Eval("ZIP_CODE") %>' Width="200px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Address</th><th></th><th>Url</th><th></th>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:TextBox runat="server" ID="txtRowAddr" Text='<%#Eval("ADDRESS") %>' Width="450px" />
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox runat="server" ID="txtRowUrl" Text='<%#Eval("URL") %>' Width="450px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Primary BAA</th><th>Is Partner?</th><th>Organization</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRowBAA">
                                                        <asp:ListItem Text="Aircraft/aerospace" Value="Aircraft/aerospace" />
                                                        <asp:ListItem Text="Automated Optical Inspection(AOI)" Value="Automated Optical Inspection(AOI)" />
                                                        <asp:ListItem Text="Automotive" Value="Automotive" />
                                                        <asp:ListItem Text="Building Automation" Value="Building Automation" />
                                                        <asp:ListItem Text="Chemical" Value="Chemical" />
                                                        <asp:ListItem Text="Consulting/Engineering/System Integrator" Value="Consulting/Engineering/System Integrator" />
                                                        <asp:ListItem Text="Data Processing/Ent eBusiness/ERP Integration" Value="Data Processing/Ent eBusiness/ERP Integration" />
                                                        <asp:ListItem Text="Digi Signage/Info Display/Narrow Casting/Streaming" Value="Digi Signage/Info Display/Narrow Casting/Streaming" />
                                                        <asp:ListItem Text="Education/eLearning" Value="Education/eLearning" />
                                                        <asp:ListItem Text="Entertainment/Gaming" Value="Entertainment/Gaming" />
                                                        <asp:ListItem Text="Factory Automation" Value="Factory Automation" />
                                                        <asp:ListItem Text="Food/Beverage" Value="Food/Beverage" />
                                                        <asp:ListItem Text="Government/Military" Value="Government/Military" />
                                                        <asp:ListItem Text="Home Automation" Value="Home Automation" />
                                                        <asp:ListItem Text="Industrial Equipment Manufacturing" Value="Industrial Equipment Manufacturing" />
                                                        <asp:ListItem Text="Internet Security" Value="Internet Security" />
                                                        <asp:ListItem Text="Internet Service Provider" Value="Internet Service Provider" />
                                                        <asp:ListItem Text="In-vehicle Computing" Value="In-vehicle Computing" />
                                                        <asp:ListItem Text="KIOSK/Point of Sale Terminals" Value="KIOSK/Point of Sale Terminals" />
                                                        <asp:ListItem Text="Logistics/Warehouse Management" Value="Logistics/Warehouse Management" />
                                                        <asp:ListItem Text="M2M" Value="M2M" />
                                                        <asp:ListItem Text="Machine Automation" Value="Machine Automation" />
                                                        <asp:ListItem Text="Metals/Mining" Value="Metals/Mining" />
                                                        <asp:ListItem Text="Packaging" Value="Packaging" />
                                                        <asp:ListItem Text="Petroleum" Value="Petroleum" />
                                                        <asp:ListItem Text="Pharmaceutical/Medical/Healthcare" Value="Pharmaceutical/Medical/Healthcare" />
                                                        <asp:ListItem Text="Plastics/Textiles/Fibers" Value="Plastics/Textiles/Fibers" />
                                                        <asp:ListItem Text="Power & Energy" Value="Power & Energy" />
                                                        <asp:ListItem Text="Process Automation & Control" Value="Process Automation & Control" />
                                                        <asp:ListItem Text="Pulp/Paper" Value="Pulp/Paper" />
                                                        <asp:ListItem Text="Remote Monitoring & Control" Value="Remote Monitoring & Control" />
                                                        <asp:ListItem Text="Research" Value="Research" />
                                                        <asp:ListItem Text="Security & Video Surveillance" Value="Security & Video Surveillance" />
                                                        <asp:ListItem Text="Semiconductor" Value="Semiconductor" />
                                                        <asp:ListItem Text="Telecommunications" Value="Telecommunications" />
                                                        <asp:ListItem Text="Test/Measurement/Instrumentation" Value="Test/Measurement/Instrumentation" />
                                                        <asp:ListItem Text="Transportation" Value="Transportation" />
                                                        <asp:ListItem Text="Utilities" Value="Utilities" />
                                                        <asp:ListItem Text="Water/Emission/Air Quality Monitoring" Value="Water/Emission/Air Quality Monitoring" />
                                                        <asp:ListItem Text="Water/Wastewater" Value="Water/Wastewater" />
                                                        <asp:ListItem Text="Others" Value="Others" />
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:RadioButtonList runat="server" ID="rbRowIsPartner" RepeatDirection="Horizontal">
                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                        <asp:ListItem Text="No" Value="N" Selected="True" />
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td colspan="2">
                                                    <asp:DropDownList runat="server" ID="dlRowBU" DataTextField="text" DataValueField="value" DataSourceID="burowsrc" />
                                                    <asp:SqlDataSource runat="server" ID="burowsrc" ConnectionString="<%$ConnectionStrings:RFM %>" 
                                                        SelectCommand="select TEXT, VALUE from SIEBEL_ACCOUNT_RBU_LOV where VALUE<>'' and TEXT<>'' order by TEXT" />
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
                        <asp:SqlDataSource runat="server" ID="accSrc" ConnectionString="<%$ connectionStrings:My %>"
                             SelectCommand="select *,case STATUS_CODE when 0 then 'Waiting' when 1 then 'Rejected' when 2 then 'Accepted' end as 'APPROVAL_STATUS' from account_draft order by created_date desc"
                             UpdateCommand="
                             update account_draft 
                             set account_name=@NAME, region=@REGION, SITE=@SITE, PHONE=@PHONE, FAX=@FAX, ACCOUNT_TYPE=@TYPE, ADDRESS=@ADDR, 
                             ACCOUNT_STATUS=@STATUS, ACCOUNT_TEAM=@TEAM, URL=@URL, CURRENCY=@CURRENCY, CITY=@CITY, COUNTRY=@COUNTRY,
                             ZIP_CODE=@ZIP_CODE,BAA=@BAA, ORGANIZATION=@BU, IS_PARTNER=@IS_PARTNER, STATUS_CODE=@SCODE, CONTACT_ROW_ID=@CROWID,
                             LAST_UPDATED_BY=@LUBY, LAST_UPDATED_DATE=GetDate(), ROW_ID=@ROWID 
                             where (TEMP_ID = @TEMP_ID)" OnSelecting="accSrc_Selecting" OnUpdated="accSrc_Updated">
                             <UpdateParameters>
                                <asp:Parameter Name="NAME" Type="String" DefaultValue="" />
                                <asp:Parameter Name="REGION" Type="String" DefaultValue="" />
                                <asp:Parameter Name="SITE" Type="String" DefaultValue="" />
                                <asp:Parameter Name="PHONE" Type="String" DefaultValue="" />
                                <asp:Parameter Name="FAX" Type="String" DefaultValue="" />
                                <asp:Parameter Name="TYPE" Type="String" DefaultValue="" />
                                <asp:Parameter Name="STATUS" Type="String" DefaultValue="" />
                                <asp:Parameter Name="TEAM" Type="String" DefaultValue="" />
                                <asp:Parameter Name="URL" Type="String" DefaultValue="" />
                                <asp:Parameter Name="CURRENCY" Type="String" DefaultValue="" />
                                <asp:Parameter Name="CITY" Type="String" DefaultValue="" />
                                <asp:Parameter Name="COUNTRY" Type="String" DefaultValue="" />
                                <asp:Parameter Name="ZIP_CODE" Type="String" DefaultValue="" />
                                <asp:Parameter Name="ADDR" Type="String" DefaultValue="" />
                                <asp:Parameter Name="BAA" Type="String" DefaultValue="" />
                                <asp:Parameter Name="BU" Type="String" DefaultValue="" />
                                <asp:Parameter Name="IS_PARTNER" Type="String" DefaultValue="" />
                                <asp:Parameter Name="SCODE" Type="Int16" DefaultValue="0" />
                                <asp:Parameter Name="CROWID"  Type="String" DefaultValue="" />
                                <asp:SessionParameter Name="LUBY" SessionField="user_id" Type="String" />
                                <asp:Parameter DefaultValue="" Name="ROWID" Type="String" />
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