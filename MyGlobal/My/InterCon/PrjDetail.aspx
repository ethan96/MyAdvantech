<%@ Page Title="MyAdvantech - Project Registration Detail" EnableEventValidation="false"
    Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="InterConPrjRegTableAdapters" %>
<%@ Import Namespace="InterConPrjReg" %>
<%@ Register Src="PrjApprove.ascx" TagName="PrjApprove" TagPrefix="uc1" %>
<%@ Register Src="PrjUpdate2Siebel.ascx" TagName="PrjUpdate2Siebel" TagPrefix="uc2" %>
<script runat="server">
    Dim R As MY_PRJ_REG_MASTERRow = Nothing
    Dim IsCanUpdate As Boolean = False, IsCanUpdateQty As Boolean = False, IsCanUpdateCountry As Boolean = False
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("ROW_ID") IsNot Nothing AndAlso Trim(Request("ROW_ID")) <> String.Empty Then
            Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
            Dim dt As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = Prj_M_A.GetDataByRowID(Request("ROW_ID"))
            If dt Is Nothing OrElse dt.Rows.Count = 0 Then Response.Redirect(Request.ApplicationPath)
            R = dt.Rows(0)
            'Dim Prj_C_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_CONTACTSTableAdapter
            'gvContact.DataSource = Prj_C_A.GetListByPrjRowID(Request("ROW_ID")) : gvContact.DataBind()
            'Dim Prj_Com_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter
            'gvCompetitor.DataSource = Prj_Com_A.GetListByPrjRowID(Request("ROW_ID")) : gvCompetitor.DataBind()
            ''
            Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
            Dim Sdt As InterConPrjReg.MY_PRJ_REG_AUDITDataTable = Prj_S_A.GetByPRJ_ROW_ID(Request("ROW_ID"))
            If Sdt.Rows.Count > 0 Then
                Dim Srow As MY_PRJ_REG_AUDITRow = Sdt.Rows(0)
                'ICC 2016/5/19 Change this function parameter
                Dim strCPOwner As String = InterConPrjRegUtil.GetPriSalesOwnerOfAccount(R.ROW_ID)
                Select Case Srow.STATUS
                    Case 0
                        If strCPOwner <> String.Empty Then
                            Dim strCPOwnerBoss As String = InterConPrjRegUtil.GetSalesOwnerDirectBoss(strCPOwner)
                            If strCPOwnerBoss = String.Empty Then strCPOwnerBoss = "sieowner@advantech.com.tw"
                            If Not InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwner) And _
                                Not InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwnerBoss) Then
                            Else
                                IsCanUpdate = True : IsCanUpdateCountry = True
                            End If
                        End If
                        If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("ChannelManagement.ACL") OrElse MailUtil.IsInRole("DMKT.ACL") Then IsCanUpdateCountry = True
                    Case 1
                        If strCPOwner <> String.Empty Then
                            Dim strCPOwnerBoss As String = InterConPrjRegUtil.GetSalesOwnerDirectBoss(strCPOwner)
                            If strCPOwnerBoss = String.Empty Then strCPOwnerBoss = "sieowner@advantech.com.tw"
                            If Not InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwner) And _
                                Not InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwnerBoss) Then
                            Else
                                IsCanUpdateQty = True : IsCanUpdateCountry = True
                            End If
                        End If
                        If InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, R.CREATED_BY) Then
                            IsCanUpdateQty = True
                        End If
                        If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("ChannelManagement.ACL") Then IsCanUpdateCountry = True
                    Case 2
                    Case 7
                        IsCanUpdateCountry = False
                    Case Else
                End Select
                If InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, R.CREATED_BY) OrElse InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwner) Then
                    IsCanUpdateCountry = True
                Else
                    Dim strCPOwnerBoss As String = InterConPrjRegUtil.GetSalesOwnerDirectBoss(strCPOwner)
                    If strCPOwnerBoss = String.Empty Then strCPOwnerBoss = "sieowner@advantech.com.tw"
                    If InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwnerBoss) Then IsCanUpdateCountry = True
                End If
            End If
        End If
        'If IsCanUpdateCountry Then mvCountry.ActiveViewIndex = 1 Else mvCountry.ActiveViewIndex = 0
        If Not IsPostBack Then
            If Request("ROW_ID") IsNot Nothing AndAlso Trim(Request("ROW_ID")) <> String.Empty Then
                Dim Prj_P_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
                gvProduct.DataSource = Prj_P_A.GetDataByPRJ_ROW_ID(Request("ROW_ID")) : gvProduct.DataBind()
                hfRowID.Value = Request("ROW_ID")
                txtPrjCloseDate.Text = R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd")
            End If
            LitPossibleOpportunity.Visible = False : LitPossibleCustomer.Visible = False
            If Util.IsInternalUser2() Then
                LitPossibleOpportunity.Visible = True : LitPossibleCustomer.Visible = True
            End If
        End If
    End Sub

    Protected Function GetData(ByVal obj As Object) As DataTable
        Dim sql As String = String.Format("SELECT [ROW_ID] ,[PRJ_PROD_ROW_ID] ,[SCHEDULE_LINE_NO] ,[SHIP_DATE] ,[QTY],[CREATED_BY],[CREATED_DATE] ,[LAST_UPD_BY] ,[LAST_UPD_DATE] FROM [MY_PRJ_REG_PRODUCT_SCHEDULES] where prj_prod_row_id='{0}'", obj.ToString.Trim)
        Dim dt As DataTable = dbUtil.dbGetDataTable("mylocal", sql)
        If dt.Rows.Count > 0 Then
            Return dt
        End If
        Return Nothing
    End Function

    Protected Sub TimerAccount_Tick(sender As Object, e As System.EventArgs)
        TimerAccount.Interval = 9999
        Try
            Dim possEndCustDt As DataTable = InterConPrjRegUtil.GetSimilarAccount(R.ENDCUST_NAME)
            gvSimilarEndCust.DataSource = possEndCustDt : gvSimilarEndCust.DataBind()
        Catch ex As Exception

        End Try
        TimerAccount.Enabled = False
    End Sub

    Protected Sub TimerSimOpty_Tick(sender As Object, e As System.EventArgs)
        TimerSimOpty.Interval = 9999
        Try
            Dim possOptyDt As DataTable = InterConPrjRegUtil.GetSimilarOpty(R.PRJ_NAME, R.PRJ_OPTY_ID, R.ROW_ID)
            gvSimilarOpty.DataSource = possOptyDt : gvSimilarOpty.DataBind()
        Catch ex As Exception

        End Try
        TimerSimOpty.Enabled = False
    End Sub

    Protected Sub gvSimilarOpty_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim tmpOptyId As String = CType(e.Row.FindControl("hd_RowOptyId"), HiddenField).Value
            Dim fcstDt As DataTable = dbUtil.dbGetDataTable("MY", _
            " select top 20 PART_NO, TOTAL_QTY from SIEBEL_PRODUCT_FORECAST z " + _
            " where z.OPTY_ID='" + tmpOptyId + "' order by z.PART_NO, z.TOTAL_QTY ")
            Dim fcstGv As GridView = e.Row.FindControl("gvRowFcst")
            fcstGv.DataSource = fcstDt : fcstGv.DataBind()
            If fcstDt.Rows.Count = 0 Then fcstGv.Visible = False
        End If
    End Sub
    Dim Prj_PS_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTS_APPROVE_PRICETableAdapter
    Protected Sub gvProduct_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim TBAprice As TextBox = CType(e.Row.Cells(7).FindControl("TBAprice"), TextBox)
            Dim BTAprice As Button = CType(e.Row.Cells(7).FindControl("BTAprice"), Button)
            BTAprice.Enabled = IsCanUpdate
            Dim BTQty As Button = CType(e.Row.Cells(7).FindControl("BTQty"), Button)
            BTQty.Enabled = IsCanUpdateQty
            Dim BTSprice As Button = CType(e.Row.Cells(4).FindControl("BTSprice"), Button)
            BTSprice.Enabled = IsCanUpdateQty
            If Decimal.TryParse(e.Row.Cells(6).Text.Trim(), 0) Then
                Dim RequestPrice As Decimal = CType(e.Row.Cells(6).Text.Trim(), Decimal)
                If RequestPrice < 0 Then
                    e.Row.Cells(6).HorizontalAlign = HorizontalAlign.Center
                    e.Row.Cells(6).Text = "N/A"
                    TBAprice.Text = 0
                Else
                    e.Row.Cells(6).Text = InterConPrjRegUtil.GetCurrencySign() + String.Format("{0:0.00}", RequestPrice)
                    TBAprice.Text = RequestPrice.ToString()
                End If
            End If
            Dim prorowid As String = gvProduct.DataKeys(e.Row.RowIndex).Values(0)
            Dim line_no As String = gvProduct.DataKeys(e.Row.RowIndex).Values(1)
            'ICC 2016/3/8 Table - MY_PRJ_REG_PRODUCTS_APPROVE_PRICE is gone
            'Dim Aprice As Object = Prj_PS_A.ScalarQuery(prorowid, line_no)
            'If Aprice IsNot Nothing AndAlso Decimal.TryParse(Aprice, 0) = True Then
            '    TBAprice.Text = Aprice.ToString()
            'End If
        End If
    End Sub

    Protected Sub BTAprice_Click(sender As Object, e As System.EventArgs)
        Dim gvr As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        Dim TBAprice As TextBox = CType(gvr.Cells(7).FindControl("TBAprice"), TextBox)
        If Decimal.TryParse(TBAprice.Text.Trim, 0) = False Then
            Util.AjaxJSAlert(Me.upProduct, "Approve Price is empty or not a numeric number")
            Exit Sub
        End If
        Dim prorowid As String = gvProduct.DataKeys(gvr.RowIndex).Values(0)
        Dim line_no As String = gvProduct.DataKeys(gvr.RowIndex).Values(1)
        'ICC 2016/3/8 Table - MY_PRJ_REG_PRODUCTS_APPROVE_PRICE is gone
        'Prj_PS_A.DeleteQuery(prorowid)
        'Prj_PS_A.InsertQuery(prorowid, Integer.Parse(line_no), Decimal.Parse(TBAprice.Text.Trim), Session("user_id"), System.DateTime.Now())
        Util.AjaxJSAlert(Me.upProduct, "Update successful")
    End Sub

    Protected Sub BTSprice_Click(sender As Object, e As System.EventArgs)
        Dim gvr As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        Dim TBSprice As TextBox = CType(gvr.Cells(4).FindControl("TBSprice"), TextBox)
        If Decimal.TryParse(TBSprice.Text.Trim, 0) = False Then
            Util.AjaxJSAlert(Me.upProduct, "Selling Price is empty or not a numeric number")
            Exit Sub
        End If
        Dim prorowid As String = gvProduct.DataKeys(gvr.RowIndex).Values(0)
        'dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("UPDATE MY_PRJ_REG_PRODUCTS SET SELLINGPRICE ={0} WHERE ROW_ID ='{1}'", CDec(TBSprice.Text), prorowid))
        'Util.AjaxJSAlert(Me.upProduct, "Update successful")
        'Dim Currency As String = InterConPrjRegUtil.GetCurrencySign(dbUtil.dbExecuteScalar("MYLOCAL", "SELECT top 1 isnull(PRJ_AMT_CURR,'') as curr from MY_PRJ_REG_MASTER where ROW_ID ='" + Request("ROW_ID") + "'"))
        LabWarn.Text = "Update successful"
        Timer2.Enabled = True
        Dim MailSubject As String = String.Format("PartNO({0}) 's Selling Price is changed to {1} by {2}", gvr.Cells(0).Text.Trim, String.Format("{0:0.00}", TBSprice.Text), Session("user_id"))
        InterConPrjRegUtil.SendUpdateMail(Request("ROW_ID"), MailSubject, InterConPrjRegUtil.GetProductsHtml(Request("ROW_ID")))
    End Sub
    Protected Sub BTQty_Click(sender As Object, e As System.EventArgs)
        LabWarn.Text = ""
        Dim gvr As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        Dim TBQty As TextBox = CType(gvr.Cells(1).FindControl("TBQTY"), TextBox)
        If Decimal.TryParse(TBQty.Text.Trim, 0) = False Then
            LabWarn.Text = "Qty is empty or not a numeric number"
            Exit Sub
        End If
        Dim prorowid As String = gvProduct.DataKeys(gvr.RowIndex).Values(0)
        Dim line_no As String = gvProduct.DataKeys(gvr.RowIndex).Values(1)
        dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE MY_PRJ_REG_PRODUCTS SET QTY =" + TBQty.Text + "  WHERE ROW_ID ='" + prorowid + "' AND LINE_NO =" + line_no + "")
        LabWarn.Text = "Update successful"
        Timer2.Enabled = True
        Dim MailSubject As String = String.Format("PartNO({0}) 's Qty is changed to {1} by {2}", gvr.Cells(0).Text.Trim, TBQty.Text, Session("user_id"))
        InterConPrjRegUtil.SendUpdateMail(Request("ROW_ID"), MailSubject, InterConPrjRegUtil.GetProductsHtml(Request("ROW_ID")))
    End Sub
    Protected Sub Timer2_Tick(sender As Object, e As System.EventArgs)
        LabWarn.Text = ""
        Timer2.Enabled = False
    End Sub

    Protected Sub ddlCountry_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        'If ddlCountry.Items.FindByValue(R.ENDCUST_COUNTRY) IsNot Nothing Then
        '    ddlCountry.Items.FindByValue(R.ENDCUST_COUNTRY).Selected = True
        'End If
        ddlCountry.ClearSelection()
        For Each i As ListItem In ddlCountry.Items
            If String.Equals(i.Value, R.ENDCUST_COUNTRY, StringComparison.CurrentCultureIgnoreCase) Then
                i.Selected = True
            End If
        Next
    End Sub

    Protected Sub btnUpdCountry_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim pMasterDAL As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        'Dim dtMaster As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = pMasterDAL.GetDataByRowID(Request("ROW_ID"))
        'Dim row As InterConPrjReg.MY_PRJ_REG_MASTERRow = dtMaster.Rows(0)
        'row.ENDCUST_COUNTRY = ddlCountry.SelectedValue
        pMasterDAL.UpdateCountry(ddlCountry.SelectedValue, Request("ROW_ID"))
    End Sub

    'Protected Sub gvContact_RowDataBound(sender As Object, e As GridViewRowEventArgs)
    '    If e.Row.RowType = DataControlRowType.DataRow Then
    '        Dim drv As DataRowView = CType(e.Row.DataItem, DataRowView)
    '        If Not drv Is Nothing Then
    '            If Not IsDBNull(drv.DataView(e.Row.RowIndex)("ROW_ID")) Then e.Row.Attributes.Add("data-key", drv.DataView(e.Row.RowIndex)("ROW_ID").ToString)
    '            e.Row.Attributes.Add("class", "MyRow")
    '        End If
    '    End If
    'End Sub

    'Protected Sub gvCompetitor_RowDataBound(sender As Object, e As GridViewRowEventArgs)
    '    If e.Row.RowType = DataControlRowType.DataRow Then
    '        Dim drv As DataRowView = CType(e.Row.DataItem, DataRowView)
    '        If Not drv Is Nothing Then
    '            If Not IsDBNull(drv.DataView(e.Row.RowIndex)("ROW_ID")) Then e.Row.Attributes.Add("data-key", drv.DataView(e.Row.RowIndex)("ROW_ID").ToString)
    '            e.Row.Attributes.Add("class", "MyComp")
    '        End If
    '    End If
    'End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function UpdateCustomerInformation(ByVal RowID As String, ByVal CustomerName As String, ByVal PostCode As String, ByVal State As String, ByVal Country As String, ByVal Address As String) As String
        If String.IsNullOrEmpty(RowID) OrElse String.IsNullOrEmpty(CustomerName) Then Return "ERROR"
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim dt As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = Prj_M_A.GetDataByRowID(RowID)
        If dt Is Nothing OrElse dt.Rows.Count = 0 Then Return "ERROR"
        Dim R As MY_PRJ_REG_MASTERRow = dt.Rows(0)
        Dim sbMaster As New StringBuilder()
        Dim listData As New List(Of CompareClass)
        sbMaster.AppendFormat(" Update MY_PRJ_REG_MASTER set ENDCUST_NAME = N'{0}'  ", CustomerName)
        If String.Equals(R.ENDCUST_NAME, CustomerName, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Company Name", R.ENDCUST_NAME, CustomerName))
        If Not String.IsNullOrEmpty(PostCode) Then
            sbMaster.AppendFormat(" , ENDCUST_POST_CODE = N'{0}' ", PostCode)
            If String.Equals(R.ENDCUST_POST_CODE, PostCode, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Post Code", R.ENDCUST_POST_CODE, PostCode))
        End If

        If Not String.IsNullOrEmpty(State) Then
            sbMaster.AppendFormat(" , ENDCUST_STATE = N'{0}' ", State)
            If String.Equals(R.ENDCUST_STATE, State, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("State", R.ENDCUST_STATE, State))
        End If

        If Not String.IsNullOrEmpty(Country) Then
            sbMaster.AppendFormat(" , ENDCUST_COUNTRY = N'{0}' ", Country)
            If String.Equals(R.ENDCUST_STATE, Country, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Country", R.ENDCUST_COUNTRY, Country))
        End If

        If Not String.IsNullOrEmpty(Address) Then
            sbMaster.AppendFormat(" , ENDCUST_ADDR = N'{0}' ", Address)
            If String.Equals(R.ENDCUST_ADDR, Address, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Address", R.ENDCUST_ADDR, Address))
        End If

        sbMaster.AppendFormat(" where ROW_ID = '{0}'; ", RowID)
        'Dim listData2 As New List(Of CompareClass)
        'If Not Projects Is Nothing AndAlso Projects.Count > 0 Then
        '    Dim dtaContact As New InterConPrjRegTableAdapters.MY_PRJ_REG_CONTACTSTableAdapter
        '    Dim dtContact As InterConPrjReg.MY_PRJ_REG_CONTACTSDataTable = dtaContact.GetListByPrjRowID(RowID)
        '    If Not dtContact Is Nothing AndAlso dtContact.Rows.Count > 0 Then
        '        Dim contacts As InterConPrjReg.MY_PRJ_REG_CONTACTSRow = dtContact.Rows(0)
        '        For Each project As Advantech.Myadvantech.DataAccess.ProjectRegistration In Projects
        '            If String.IsNullOrEmpty(project.RowID) Then Continue For
        '            For Each c As InterConPrjReg.MY_PRJ_REG_CONTACTSRow In dtContact
        '                If c.ROW_ID = project.RowID Then contacts = c
        '            Next
        '            Dim data As New CompareClass()
        '            data.ColumnName = R.PRJ_NAME
        '            sbMaster.AppendFormat(" Update MY_PRJ_REG_CONTACTS set LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = N'{0}' ", HttpContext.Current.User.Identity.Name)

        '            If Not String.IsNullOrEmpty(project.LastName) Then
        '                sbMaster.AppendFormat(" , LAST_NAME = N'{0}' ", project.LastName)
        '                If String.Equals(contacts.LAST_NAME, project.LastName, StringComparison.OrdinalIgnoreCase) = False Then
        '                    data.Old_Value += String.Format("LAST NAME: {0} ", contacts.LAST_NAME)
        '                    data.New_Value += String.Format("LAST NAME: {0} ", project.LastName)
        '                End If
        '            End If

        '            If Not String.IsNullOrEmpty(project.FirstName) Then
        '                sbMaster.AppendFormat(" , FIRST_NAME = N'{0}' ", project.FirstName)
        '                If String.Equals(contacts.FIRST_NAME, project.FirstName, StringComparison.OrdinalIgnoreCase) = False Then
        '                    data.Old_Value += String.Format("FIRST NAME: {0} ", contacts.FIRST_NAME)
        '                    data.New_Value += String.Format("FIRST NAME: {0} ", project.FirstName)
        '                End If
        '            End If

        '            If Not String.IsNullOrEmpty(project.Email) Then
        '                sbMaster.AppendFormat(" , EMAIL = N'{0}' ", project.Email)
        '                If String.Equals(contacts.EMAIL, project.Email, StringComparison.OrdinalIgnoreCase) = False Then
        '                    data.Old_Value += String.Format("EMAIL: {0} ", contacts.EMAIL)
        '                    data.New_Value += String.Format("EMAIL: {0} ", project.Email)
        '                End If
        '            End If

        '            If Not String.IsNullOrEmpty(project.Telephone) Then
        '                sbMaster.AppendFormat(" , TEL = N'{0}' ", project.Telephone)
        '                If String.Equals(contacts.TEL, project.Telephone, StringComparison.OrdinalIgnoreCase) = False Then
        '                    data.Old_Value += String.Format("TEL: {0} ", contacts.TEL)
        '                    data.New_Value += String.Format("TEL: {0} ", project.Telephone)
        '                End If
        '            End If
        '            If Not String.IsNullOrEmpty(data.New_Value) AndAlso Not String.IsNullOrEmpty(data.Old_Value) Then listData2.Add(data)
        '            sbMaster.AppendFormat(" Where ROW_ID = N'{0}'; ", project.RowID)
        '        Next
        '    End If

        'End If

        Try
            dbUtil.dbExecuteNoQuery("MyLocal", sbMaster.ToString)
            Dim mailbody As String = String.Empty
            If listData.Count > 0 Then
                Dim sb As New StringBuilder()
                Dim cpName As String = String.Empty
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", R.CP_ACCOUNT_ROW_ID))
                If Not obj Is Nothing Then cpName = obj.ToString()
                Dim stage As String = String.Empty
                obj = dbUtil.dbExecuteScalar("CRMAPPDB", String.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", R.PRJ_OPTY_ID))
                If Not obj Is Nothing Then stage = obj.ToString()
                sb.AppendFormat("Project Information has been updated by {0} on {1}. <br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4} <br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, Date.Now.ToString("yyyy/MM/dd"), cpName, R.CP_COMPANY_ID, R.PRJ_NAME, stage, InterConPrjRegUtil.GetTotalAmountByID(RowID), R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"))
                sb.Append("<br /><span style='color: blue;'>[Before Change]</span><br />")
                For Each cc As CompareClass In listData
                    sb.AppendFormat("{0}: {1} <br />", cc.ColumnName, cc.Old_Value)
                Next
                sb.Append("<br /><span style='color: blue;'>[After Change]</span><br />")
                For Each cc As CompareClass In listData
                    sb.AppendFormat("{0}: {1} <br />", cc.ColumnName, cc.New_Value)
                Next
                InterConPrjRegUtil.Sendmail(RowID, "A Project registration information data has been updated by " + HttpContext.Current.User.Identity.Name, -2, sb.ToString())

                'Dim gv As New GridView()
                'gv.DataSource = listData
                'gv.DataBind()
                'For i = 0 To gv.Rows.Count - 1
                '    If i Mod 2 > 0 Then gv.Rows(i).BackColor = System.Drawing.ColorTranslator.FromHtml("#E6E6E6")
                'Next
                'Dim sb As New StringBuilder()
                'Dim sw As New System.IO.StringWriter(sb)
                'Dim html As New System.Web.UI.HtmlTextWriter(sw)
                'gv.RenderControl(html)
                'sb.Insert(0, String.Format("Customer Information has been updated by {0} on {1}. <br /> Project Name: {2} <br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), R.PRJ_NAME))
                'mailbody = sb.ToString + "<br />"
            End If
            'If listData2.Count > 0 Then
            '    Dim gv As New GridView()
            '    gv.DataSource = listData2
            '    gv.DataBind()
            '    For i = 0 To gv.Rows.Count - 1
            '        If i Mod 2 > 0 Then gv.Rows(i).BackColor = System.Drawing.ColorTranslator.FromHtml("#E6E6E6")
            '    Next
            '    Dim sb As New StringBuilder()
            '    Dim sw As New System.IO.StringWriter(sb)
            '    Dim html As New System.Web.UI.HtmlTextWriter(sw)
            '    gv.RenderControl(html)
            '    sb.Insert(0, String.Format("Contact Information has been updated by {0} on {1}. <br /> Project Name: {2} <br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), R.PRJ_NAME))
            '    mailbody += sb.ToString
            'End If
            'InterConPrjRegUtil.Sendmail(RowID, "A Project registration data has been updated by " + HttpContext.Current.User.Identity.Name, -1, mailbody)
        Catch ex As Exception
            Return "ERROR"
        End Try

        Return "OK"
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function UpdateProjectInfo(ByVal RowID As String, ByVal ProjectName As String, ByVal ProjectDesc As String, ByVal PoRisk As String, ByVal AdvSupport As String, ByVal CloseDate As String) As String
        If String.IsNullOrEmpty(RowID) OrElse String.IsNullOrEmpty(ProjectName) Then Return "ERROR"
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim dt As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = Prj_M_A.GetDataByRowID(RowID)
        If dt Is Nothing OrElse dt.Rows.Count = 0 Then Return "ERROR"
        Dim R As MY_PRJ_REG_MASTERRow = dt.Rows(0)
        Dim sbMaster As New StringBuilder()
        Dim listData As New List(Of CompareClass)
        sbMaster.AppendFormat(" Update MY_PRJ_REG_MASTER set LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = N'{0}'  ", HttpContext.Current.User.Identity.Name)

        If String.Equals(R.PRJ_NAME, ProjectName, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Project Name", R.PRJ_NAME, ProjectName))
        If Not String.IsNullOrEmpty(ProjectDesc) Then
            sbMaster.AppendFormat(" , PRJ_DESC = N'{0}' ", ProjectDesc)
            If String.Equals(R.PRJ_DESC, ProjectDesc, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Project Description", R.PRJ_DESC, ProjectDesc))
        End If
        If Not String.IsNullOrEmpty(PoRisk) Then
            sbMaster.AppendFormat(" , POTENTIAL_RISK = N'{0}' ", PoRisk)
            If String.Equals(R.POTENTIAL_RISK, PoRisk, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Potential risk", R.POTENTIAL_RISK, PoRisk))
        End If
        If Not String.IsNullOrEmpty(AdvSupport) Then
            sbMaster.AppendFormat(" , NEEDED_ADV_SUPPORT = N'{0}' ", AdvSupport)
            If String.Equals(R.NEEDED_ADV_SUPPORT, AdvSupport, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Needed Advantech Support", R.NEEDED_ADV_SUPPORT, AdvSupport))
        End If

        If Not String.IsNullOrEmpty(CloseDate) Then sbMaster.AppendFormat(" , PRJ_EST_CLOSE_DATE = N'{0}' ", CloseDate)
        If String.Equals(R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"), CloseDate, StringComparison.OrdinalIgnoreCase) = False Then listData.Add(New CompareClass("Close Date", R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"), CloseDate))
        sbMaster.AppendFormat(" where ROW_ID = '{0}'; ", RowID)

        Try
            dbUtil.dbExecuteNoQuery("MyLocal", sbMaster.ToString)

            If listData.Count > 0 Then
                Dim cpName As String = String.Empty
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", R.CP_ACCOUNT_ROW_ID))
                If Not obj Is Nothing Then cpName = obj.ToString()
                Dim stage As String = String.Empty
                obj = dbUtil.dbExecuteScalar("CRMAPPDB", String.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", R.PRJ_OPTY_ID))
                If Not obj Is Nothing Then stage = obj.ToString()
                Dim sb As New StringBuilder()
                sb.AppendFormat("Project Information has been updated by {0} on {1}. <br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4} <br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, Date.Now.ToString("yyyy/MM/dd"), cpName, R.CP_COMPANY_ID, R.PRJ_NAME, stage, InterConPrjRegUtil.GetTotalAmountByID(RowID), R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"))
                sb.Append("<br /><span style='color: blue;'>[Before Change]</span><br />")
                For Each cc As CompareClass In listData
                    sb.AppendFormat("{0}: {1} <br />", cc.ColumnName, cc.Old_Value)
                Next
                sb.Append("<br /><span style='color: blue;'>[After Change]</span><br />")
                For Each cc As CompareClass In listData
                    sb.AppendFormat("{0}: {1} <br />", cc.ColumnName, cc.New_Value)
                Next
                InterConPrjRegUtil.Sendmail(RowID, "A Project registration information data has been updated by " + HttpContext.Current.User.Identity.Name, -2, sb.ToString())
                'Dim gv As New GridView()
                'gv.DataSource = listData
                'gv.DataBind()
                'For i = 0 To gv.Rows.Count - 1
                '    If i Mod 2 > 0 Then gv.Rows(i).BackColor = System.Drawing.ColorTranslator.FromHtml("#E6E6E6")
                'Next
                'Dim sb As New StringBuilder()
                'Dim sw As New System.IO.StringWriter(sb)
                'Dim html As New System.Web.UI.HtmlTextWriter(sw)
                'gv.RenderControl(html)
                'sb.Insert(0, String.Format("Project Information has been updated by {0} on {1}. <br /> Project Name: {2} <br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), ProjectName))
                'InterConPrjRegUtil.Sendmail(RowID, "A Project registration data has been updated by " + HttpContext.Current.User.Identity.Name, -1, sb.ToString)
            End If
        Catch ex As Exception
            Return "ERROR"
        End Try

        Return "OK"
    End Function

    '<Services.WebMethod()> _
    '<Web.Script.Services.ScriptMethod()> _
    'Public Shared Function UpdateCompetitor(ByVal Projects As List(Of Advantech.Myadvantech.DataAccess.ProjectRegistration)) As String
    '    If Not Projects Is Nothing AndAlso Projects.Count > 0 Then
    '        Dim sbCompetitor As New StringBuilder()
    '        Dim listData As New List(Of CompareClass)
    '        Dim dtaCompetitor As New InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter
    '        Dim dtCompetitor As InterConPrjReg.MY_PRJ_REG_COMPETITORSDataTable = dtaCompetitor.GetListByPrjRowID(Projects.FirstOrDefault().Contact_Row_ID)
    '        If Not dtCompetitor Is Nothing AndAlso dtCompetitor.Rows.Count > 0 Then
    '            Dim competitor As InterConPrjReg.MY_PRJ_REG_COMPETITORSRow = dtCompetitor.Rows(0)
    '            For Each prj As Advantech.Myadvantech.DataAccess.ProjectRegistration In Projects
    '                If String.IsNullOrEmpty(prj.RowID) Then Continue For
    '                For Each c As InterConPrjReg.MY_PRJ_REG_COMPETITORSRow In dtCompetitor
    '                    If c.ROW_ID = prj.RowID Then competitor = c
    '                Next
    '                Dim data As New CompareClass()

    '                sbCompetitor.AppendFormat(" Update MY_PRJ_REG_COMPETITORS set LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = N'{0}' ", HttpContext.Current.User.Identity.Name)
    '                data.ColumnName = prj.Project_Name

    '                If Not String.IsNullOrEmpty(prj.CompetitorName) Then
    '                    sbCompetitor.AppendFormat(" , COMPETITOR_NAME = N'{0}' ", prj.CompetitorName.Trim())
    '                    If String.Equals(competitor.COMPETITOR_NAME, prj.CompetitorName.Trim(), StringComparison.OrdinalIgnoreCase) = False Then
    '                        data.Old_Value += String.Format("Last Name: {0} ", competitor.COMPETITOR_NAME)
    '                        data.New_Value += String.Format("Last Name: {0} ", prj.CompetitorName)
    '                    End If
    '                End If

    '                If Not String.IsNullOrEmpty(prj.ModelNo) Then
    '                    sbCompetitor.AppendFormat(" , MODEL_NO = N'{0}' ", prj.ModelNo.Trim())
    '                    If String.Equals(competitor.MODEL_NO, prj.ModelNo.Trim(), StringComparison.OrdinalIgnoreCase) = False Then
    '                        data.Old_Value += String.Format("MODEL NO: {0} ", competitor.MODEL_NO)
    '                        data.New_Value += String.Format("MODEL NO: {0} ", prj.ModelNo)
    '                    End If
    '                End If

    '                If Not String.IsNullOrEmpty(prj.Remark) Then
    '                    sbCompetitor.AppendFormat(" , REMARK = N'{0}' ", prj.Remark.Trim())
    '                    If String.Equals(competitor.REMARK, prj.Remark.Trim(), StringComparison.OrdinalIgnoreCase) = False Then
    '                        data.Old_Value += String.Format("Remark: {0} ", competitor.REMARK)
    '                        data.New_Value += String.Format("Remark: {0} ", prj.Remark)
    '                    End If
    '                End If

    '                Dim price As Decimal = 0
    '                If Not String.IsNullOrEmpty(prj.SellingPrice) AndAlso Decimal.TryParse(prj.SellingPrice, price) = True Then
    '                    If price > 0 Then
    '                        sbCompetitor.AppendFormat(" , SELLING_PRICE = {0} ", price)
    '                        If String.Equals(competitor.SELLING_PRICE.ToString, prj.SellingPrice.Trim(), StringComparison.OrdinalIgnoreCase) = False Then
    '                            data.Old_Value += String.Format("Selling Price: {0} ", competitor.SELLING_PRICE.ToString)
    '                            data.New_Value += String.Format("Selling Price: {0} ", prj.SellingPrice)
    '                        End If
    '                    End If

    '                End If
    '                listData.Add(data)
    '                sbCompetitor.AppendFormat(" where ROW_ID = '{0}'; ", prj.RowID)
    '            Next
    '        End If

    '        If sbCompetitor.Length > 0 Then
    '            Try
    '                dbUtil.dbExecuteNoQuery("MyLocal", sbCompetitor.ToString)
    '                If listData.Count > 0 Then
    '                    Dim gv As New GridView()
    '                    gv.DataSource = listData
    '                    gv.DataBind()
    '                    For i = 0 To gv.Rows.Count - 1
    '                        If i Mod 2 > 0 Then gv.Rows(i).BackColor = System.Drawing.ColorTranslator.FromHtml("#E6E6E6")
    '                    Next
    '                    Dim sb As New StringBuilder()
    '                    Dim sw As New System.IO.StringWriter(sb)
    '                    Dim html As New System.Web.UI.HtmlTextWriter(sw)
    '                    gv.RenderControl(html)
    '                    sb.Insert(0, String.Format("Competitor Information has been updated by {0} on {1}. <br /> Project Name: {2} <br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), Projects.FirstOrDefault().Project_Name))
    '                    InterConPrjRegUtil.Sendmail(Projects.FirstOrDefault().Contact_Row_ID, "A Project registration data has been updated by " + HttpContext.Current.User.Identity.Name, -1, sb.ToString)
    '                End If
    '            Catch ex As Exception
    '                Return "ERROR"
    '            End Try
    '        End If

    '    End If
    '    Return "OK"
    'End Function

    Public Class CompareClass
        Private cname As String
        Public Property ColumnName As String
            Get
                Return cname
            End Get
            Set(ByVal value As String)
                cname = value
            End Set
        End Property

        Private older As String
        Public Property Old_Value As String
            Get
                Return older
            End Get
            Set(ByVal value As String)
                older = value
            End Set
        End Property
        Private newer As String
        Public Property New_Value As String
            Get
                Return newer
            End Get
            Set(ByVal value As String)
                newer = value
            End Set
        End Property
        Sub New()

        End Sub
        Sub New(ByVal _columnname As String, ByVal _before As String, ByVal _after As String)
            Me.ColumnName = _columnname
            Me.Old_Value = _before
            Me.New_Value = _after
        End Sub
    End Class

    Protected Sub btnUpdateRemark_Click(sender As Object, e As EventArgs)
        LabWarn.Text = ""
        Dim gvr As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        Dim txtRemark As TextBox = CType(gvr.Cells(3).FindControl("txtRemark"), TextBox)
        Dim prorowid As String = gvProduct.DataKeys(gvr.RowIndex).Values(0)
        Dim line_no As String = gvProduct.DataKeys(gvr.RowIndex).Values(1)
        Dim gv As New GridView()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("SELECT TOP 1 PART_NO, QTY, REMARK, SELLINGPRICE, STANDARDPRICE, REQUESTPRICE, LAST_UPD_BY, LAST_UPD_DATE FROM MY_PRJ_REG_PRODUCTS WHERE ROW_ID ='{0}' AND LINE_NO = {1}", prorowid, line_no))
        gv.DataSource = dt
        gv.DataBind()
        Dim gvsb As New StringBuilder()
        Dim sw As New System.IO.StringWriter(gvsb)
        Dim html As New System.Web.UI.HtmlTextWriter(sw)
        gv.RenderControl(html)
        dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE MY_PRJ_REG_PRODUCTS SET REMARK ='" + txtRemark.Text.Trim() + "', LAST_UPD_BY = '" + Context.User.Identity.Name + "', LAST_UPD_DATE = GETDATE() WHERE ROW_ID ='" + prorowid + "' AND LINE_NO =" + line_no + "")
        LabWarn.Text = "Update successful"
        Timer2.Enabled = True
        Dim cpName As String = String.Empty
        Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", R.CP_ACCOUNT_ROW_ID))
        If Not obj Is Nothing Then cpName = obj.ToString()
        Dim stage As String = String.Empty
        obj = dbUtil.dbExecuteScalar("CRMAPPDB", String.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", R.PRJ_OPTY_ID))
        If Not obj Is Nothing Then stage = obj.ToString()
        Dim sb As New StringBuilder()
        sb.AppendFormat("Project Information has been updated by {0} on {1}. <br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4} <br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, Date.Now.ToString("yyyy/MM/dd"), cpName, R.CP_COMPANY_ID, R.PRJ_NAME, stage, InterConPrjRegUtil.GetTotalAmountByID(R.ROW_ID), R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"))
        sb.Append("<br /><span style='color: blue;'>[Before Change]</span><br />")
        sb.Append(gvsb.ToString() + "<br />")
        sb.Append("<br /><span style='color: blue;'>[After Change]</span><br />")
        gvsb.Clear()
        dt.Rows(0).Item("REMARK") = txtRemark.Text.Trim()
        gv.DataSource = dt
        gv.DataBind()
        gv.RenderControl(html)
        sb.Append(gvsb.ToString())
        InterConPrjRegUtil.Sendmail(Request("ROW_ID"), "A Project registration part NO.'s remark has been changed by " + Session("user_id").ToString + "", -2, sb.ToString())
    End Sub

    Protected Sub btnUpdatePartNo_Click(sender As Object, e As EventArgs)
        LabWarn.Text = ""
        Dim gvr As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        Dim txtPartNo As TextBox = CType(gvr.Cells(0).FindControl("txtPartNo"), TextBox)
        Dim TBQty As TextBox = CType(gvr.Cells(1).FindControl("TBQTY"), TextBox)
        Dim txtRemark As TextBox = CType(gvr.Cells(3).FindControl("txtRemark"), TextBox)
        Dim TBSprice As TextBox = CType(gvr.Cells(4).FindControl("TBSprice"), TextBox)

        If String.IsNullOrEmpty(txtPartNo.Text) Then
            Util.AjaxJSAlert(Me.upProduct, "Part No error")
            Exit Sub
        Else
            Dim sp() As String = AutoSuggestPN(txtPartNo.Text.Trim(), 10)
            If sp Is Nothing OrElse sp.Length = 0 Then
                Util.AjaxJSAlert(Me.upProduct, "Part No error")
                Exit Sub
            End If
        End If

        If Decimal.TryParse(TBQty.Text.Trim, 0) = False Then
            LabWarn.Text = "Qty is empty or not a numeric number"
            Exit Sub
        End If

        If Decimal.TryParse(TBSprice.Text.Trim, 0) = False Then
            Util.AjaxJSAlert(Me.upProduct, "Selling Price is empty or not a numeric number")
            Exit Sub
        End If

        Dim price As Double = GetPrice(txtPartNo.Text)
        Dim prorowid As String = gvProduct.DataKeys(gvr.RowIndex).Values(0)
        Dim line_no As String = gvProduct.DataKeys(gvr.RowIndex).Values(1)
        Dim pdList As New List(Of Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct)
        Dim prp As New Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct()
        Dim q As Decimal = 1
        Decimal.TryParse(TBQty.Text, q)
        Dim sprice As Decimal = 1
        Decimal.TryParse(TBSprice.Text, sprice)
        Dim pdsb As New System.Text.StringBuilder
        With pdsb
            .AppendLine(String.Format(" select count(a.PART_NO) "))
            .AppendLine(String.Format(" from sap_product a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO  "))
            .AppendLine(String.Format(" where a.PART_NO = '{0}' and b.ORG_ID='{1}' and c.PRODUCT_STATUS in ('A','N','H','O','M1') and c.DLV_PLANT='{2}H1' ", _
                                      txtPartNo.Text.Trim(), HttpContext.Current.Session("org_id").ToString(), Left(HttpContext.Current.Session("org_id"), 2)))
        End With
        Dim count As Integer = CType(dbUtil.dbExecuteScalar("MY", pdsb.ToString), Integer)
        If count > 0 Then
            prp.Main_Product = txtPartNo.Text.Trim()
            prp.Main_Product_Qty = q.ToString
            pdList.Add(prp)
        End If
        Dim gv As New GridView()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("SELECT TOP 1 PART_NO, QTY, REMARK, SELLINGPRICE, STANDARDPRICE, REQUESTPRICE, LAST_UPD_BY, LAST_UPD_DATE FROM MY_PRJ_REG_PRODUCTS WHERE ROW_ID ='{0}' AND LINE_NO = {1}", prorowid, line_no))
        gv.DataSource = dt
        gv.DataBind()
        Dim gvsb As New StringBuilder()
        Dim sw As New System.IO.StringWriter(gvsb)
        Dim html As New System.Web.UI.HtmlTextWriter(sw)
        gv.RenderControl(html)
        dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("UPDATE MY_PRJ_REG_PRODUCTS SET PART_NO ='{0}', STANDARDPRICE = {1}, LAST_UPD_BY = '{2}', LAST_UPD_DATE = GETDATE(), QTY = {5}, SELLINGPRICE = {6}, REMARK = '{7}' where ROW_ID = '{3}' and LINE_NO = {4}", txtPartNo.Text.Trim(), price, Context.User.Identity.Name, prorowid, line_no, q, sprice, txtRemark.Text.Trim()))
        LabWarn.Text = "Update successful"
        Dim cpName As String = String.Empty
        Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", R.CP_ACCOUNT_ROW_ID))
        If Not obj Is Nothing Then cpName = obj.ToString()
        Dim stage As String = String.Empty
        obj = dbUtil.dbExecuteScalar("CRMAPPDB", String.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", R.PRJ_OPTY_ID))
        If Not obj Is Nothing Then stage = obj.ToString()
        Dim sb As New StringBuilder()
        sb.AppendFormat("Project Information has been updated by {0} on {1}. <br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4} <br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, Date.Now.ToString("yyyy/MM/dd"), cpName, R.CP_COMPANY_ID, R.PRJ_NAME, stage, InterConPrjRegUtil.GetTotalAmountByID(R.ROW_ID), R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"))
        sb.Append("<br /><span style='color: blue;'>[Before Change]</span><br />")
        sb.Append(gvsb.ToString() + "<br />")
        sb.Append("<br /><span style='color: blue;'>[After Change]</span><br />")
        gvsb.Clear()
        dt.Rows(0).Item("PART_NO") = txtPartNo.Text.Trim()
        dt.Rows(0).Item("STANDARDPRICE") = price
        dt.Rows(0).Item("QTY") = q
        dt.Rows(0).Item("REMARK") = txtRemark.Text.Trim()
        dt.Rows(0).Item("SELLINGPRICE") = sprice
        gv.DataSource = dt
        gv.DataBind()
        gv.RenderControl(html)
        sb.Append(gvsb.ToString())
        InterConPrjRegUtil.Sendmail(Request("ROW_ID"), "A Project registration part NO. has been changed by " + Session("user_id").ToString + "", -2, sb.ToString())
        InterConPrjRegUtil.update_Siebel(Request("ROW_ID"), "", 0, "", "", "", "", pdList)
    End Sub

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestPN(ByVal prefixText As String, ByVal count As Integer) As String()
        Return InterConPrjRegUtil.AutoSuggestPN(prefixText, count)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPrice(ByVal pn As String) As Double
        Dim ws As New MYSAPDAL, strCompanyId As String = HttpContext.Current.Session("company_id"), strOrg As String = HttpContext.Current.Session("org_id")
        Dim pinTable As New SAPDALDS.ProductInDataTable, pOutTable As New SAPDALDS.ProductOutDataTable
        pinTable.AddProductInRow(pn, 1)
        If ws.GetPriceV2(strCompanyId, strCompanyId, strOrg, MYSAPDAL.SAPOrderType.ZOR, pinTable, pOutTable, "") AndAlso pOutTable.Count > 0 Then
            Return CDbl(pOutTable(0).UNIT_PRICE)
        Else
            'Return -1
            '2016/3/21 Change price to 0 to prevent Siebel web service is not allow -1.
            Return 0
        End If
        'Return InterConPrjRegUtil.GetPrice(pn)
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../Includes/jquery-latest.min.js"></script>
    <link href="Image/PJcss.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function UpdateCustomerData() {
            var custname = $("#custname").val().trim();
            if (custname == undefined || custname == "") {
                alert("Company Name cannot be empty!");
                return false;
            }
            //var projects = [];
            //$(".MyRow").each(function () {
            //    var dom = $(this);
            //    var project = {};
            //    project.RowID = dom.attr("data-key");
            //    project.LastName = dom.find(".lastname").val();
            //    project.FirstName = dom.find(".firstname").val();
            //    project.Email = dom.find(".email").val();
            //    project.Telephone = dom.find(".tel").val();
            //    projects.push(project);
            //});
            var country = $('#<%=ddlCountry.ClientID%> option:selected').text();
            var postData = JSON.stringify({ RowID: '<%= hfRowID.Value%>', CustomerName: custname, PostCode: $("#postcode").val().trim(), State: $("#state").val().trim(), Country: country.trim(), Address: $("#addr").val().trim() });
            $.ajax({
                type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/My/InterCon/PrjDetail.aspx/UpdateCustomerInformation", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    if ($.trim(data.d) != "") {
                        if (data.d == "OK") {
                            alert("Update success!");
                        }
                        else
                            alert("Update failed! Please contact MyAdvantech@advantech.com.");
                    }
                },
                error: function () {
                    alert("Update failed! Please contact MyAdvantech@advantech.com.");
                }
            });
        }

        function UpdateProjectInfo() {
            var prjname = $("#prjname").val().trim();
            if (prjname == undefined || prjname == "") {
                alert("Project Name cannot be empty!");
                return false;
            }
            var closedate = $('#<%=txtPrjCloseDate.ClientID%>').val().trim();
            if (closedate == undefined || closedate == "") {
                alert("Close date cannot be empty!");
                return false;
            }
            var postData = JSON.stringify({ RowID: '<%= hfRowID.Value%>', ProjectName: prjname, ProjectDesc: $("#prjdesc").val().trim(), PoRisk: $("#prjrisk").val().trim(), AdvSupport: $("#prjsupp").val().trim(), CloseDate: closedate });
            $.ajax({
                type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/My/InterCon/PrjDetail.aspx/UpdateProjectInfo", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    if ($.trim(data.d) != "") {
                        if (data.d == "OK")
                            alert("Update success!");
                        else
                            alert("Update failed! Please contact MyAdvantech@advantech.com.");
                    }
                },
                error: function () {
                    alert("Update failed! Please contact MyAdvantech@advantech.com.");
                }
            });
        }

        <%--function UpdateCompetitor() {
            var projects = [];
            var prjName = $("#prjname").val().trim();
            $(".MyComp").each(function () {
                var dom = $(this);
                var project = {};
                project.RowID = dom.attr("data-key");
                project.Project_Name = prjName;
                project.Contact_Row_ID = '<%= hfRowID.Value%>';
                project.CompetitorName = dom.find(".comname").val();
                project.ModelNo = dom.find(".modname").val();
                project.SellingPrice = dom.find(".sellprice").val();
                project.Remark = dom.find(".remark").val();
                projects.push(project);
            });
            var postData = JSON.stringify({ Projects: projects });
            $.ajax({
                type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/My/InterCon/PrjDetail.aspx/UpdateCompetitor", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    if ($.trim(data.d) != "") {
                        if (data.d == "OK")
                            alert("Update success!");
                        else
                            alert("Update failed! Please contact MyAdvantech@advantech.com.");
                    }
                },
                error: function () {
                    alert("Update failed! Please contact MyAdvantech@advantech.com.");
                }
            });
        }--%>

        function LoadContact() {
            $.ajax({
                type: "GET", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/GetContactsByPrjRowID", data: { RowID: '<%= hfRowID.Value%>' }, dataType: "json",
                success: function (retData) {
                    if (!!retData && retData.length > 0) {
                        var html = "";
                        for (var i = 0; i < retData.length; i++) {
                            html += ("<tr id='" + retData[i].rowID + "' class=\"ContactRow\" style=\"background-color: white; text-align: center;\">");
                            html += ("<td><input type=\"text\" data-value='lastname' value='" + retData[i].lastname + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='firstname' value='" + retData[i].firstname + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='email' value='" + retData[i].email + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='tel' value='" + retData[i].tel + "' /></td>");
                            html += ("<td><input type=\"button\" data-key='" + retData[i].rowID + "' onclick='DeleteContact(this);' value='Delete' /></td></tr>");
                        }
                        $("#tbContact").html(html);
                    }
                },
                error: function () {
                    alert("Load contact failed!");
                }
            });
        }

        function DeleteContact(rowid) {
            if (!!rowid && confirm("Do you want to delete this contact?") == true) {
                var id = $(rowid).attr("data-key");
                $.ajax({
                    type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/DeleteContact", data: { RowID: id }, dataType: "json",
                    success: function () {
                        alert("Success");
                    }
                });
                $("#" + id).remove();
                $("#btnAddContact").prop("disabled", false);
            }
        }

        function LoadCompetitor() {
            $.ajax({
                type: "GET", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/GetCompetitorsByPrjRowID", data: { RowID: '<%= hfRowID.Value%>' }, dataType: "json",
                success: function (retData) {
                    if (!!retData && retData.length > 0) {
                        var html = "";
                        for (var i = 0; i < retData.length; i++) {
                            html += ("<tr id='" + retData[i].rowID + "' class=\"CompetitorRow\" style=\"background-color: white; text-align: center;\">");
                            html += ("<td><input type=\"text\" data-value='competitorname' value='" + retData[i].competitorname + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='modelno' value='" + retData[i].modelno + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='sellingprice' value='" + retData[i].sellingprice + "' /></td>");
                            html += ("<td><input type=\"text\" data-value='remark' value='" + retData[i].remark + "' /></td>");
                            html += ("<td><input type=\"button\" data-key='" + retData[i].rowID + "' onclick='DeleteCompetitor(this);' value='Delete' /></td></tr>");
                        }
                        $("#tbCompetitor").html(html);
                    }
                },
                error: function () {
                    alert("Load competitor failed!");
                }
            });
        }

        function DeleteCompetitor(rowid) {
            if (!!rowid && confirm("Do you want to delete this competitor?") == true) {
                var id = $(rowid).attr("data-key");
                $.ajax({
                    type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/DeleteCompetitor", data: { RowID: id }, dataType: "json",
                    success: function () {
                        alert("Success");
                    }
                });
                $("#" + id).remove();
                $("#btnAddCompetitor").prop("disabled", false);
            }
        }

        function PNSelected(source, eventArgs) {
            if (!!source && !!eventArgs) {
                var txtID = source.get_id().replace("ace1", "txtPartNo");
                if (!!txtID) {
                    FillModelCPPrice(eventArgs.get_value(), txtID);
                }
            }
        }
        function FillModelCPPrice(modelno, sourceid) {
            PageMethods.GetPrice(modelno,
                function (pagedResult, eleid, methodName) {
                    //alert(pagedResult);
                    var p = pagedResult;
                    if (p) {
                        if (p > 0) {
                            var pid = sourceid.replace('txtPartNo', 'lbStdPrice');
                            //alert(pid);
                            document.getElementById(pid).innerHTML = p;
                        }
                    }
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                }
            );
        }

        $(function () {

            //Contacts
            LoadContact();

            LoadCompetitor();

            $("#btnAddContact").click(function () {
                var count = $(".ContactRow").length;
                if (count <= 4) {
                    var html = "<tr class=\"ContactRow\" style=\"background-color: white; text-align: center;\">";
                    html += "<td><input data-value='lastname' type=\"text\" /></td>";
                    html += "<td><input data-value='firstname' type=\"text\" /></td>";
                    html += "<td><input data-value='email' type=\"text\" /></td>";
                    html += "<td><input data-value='tel' type=\"text\" /></td>";
                    html += "<td></td></tr>";
                    $("#tbContact").append(html);

                    if(count == 4)
                        $(this).prop("disabled", true);
                }
                else
                    return false;
            });

            $("#btnUpdateContact").click(function () {
                var contacts = [];
                $(".ContactRow").each(function (i, n) {
                    var lastname = "";
                    var firstname = "";
                    var email = "";
                    var tel = "";
                    $(n).children().each(function (j, m) {
                        var dv = $(m).children().attr("data-value");
                        switch (dv) {
                            case "lastname":
                                lastname = $(m).children().val();
                                break;
                            case "firstname":
                                firstname = $(m).children().val();
                                break;
                            case "email":
                                email = $(m).children().val();
                                break;
                            case "tel":
                                tel = $(m).children().val();
                                break;
                        }
                    });
                    if (lastname != "" && firstname != "" && email != "") {
                        contacts.push({
                            lastname: lastname,
                            firstname: firstname,
                            email: email,
                            tel: tel
                        });
                    }
                });
                if (contacts.length > 0) {
                    $.ajax({
                        type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/UpdateContacts", data: { PrjRowID: '<%= hfRowID.Value%>', JsonData: JSON.stringify(contacts) }, dataType: "json",
                        success: function (retData) {
                            if (!!retData && retData.length > 0) {
                                var html = "";
                                for (var i = 0; i < retData.length; i++) {
                                    html += ("<tr id='" + retData[i].rowID + "' class=\"ContactRow\" style=\"background-color: white; text-align: center;\">");
                                    html += ("<td><input type=\"text\" data-value='lastname' value='" + retData[i].lastname + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='firstname' value='" + retData[i].firstname + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='email' value='" + retData[i].email + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='tel' value='" + retData[i].tel + "' /></td>");
                                    html += ("<td><input type=\"button\" data-key='" + retData[i].rowID + "' onclick='DeleteContact(this);' value='Delete' /></td></tr>");
                                }
                                $("#tbContact").html(html);
                                if (retData.length == 5)
                                    $("#btnAddContact").prop("disabled", true);
                                else
                                    $("#btnAddContact").prop("disabled", false);
                            }
                            alert("Update success!");
                        },
                        error: function () {
                            alert("Update contact failed!");
                        }
                    });
                }
            });

            $("#btnAddCompetitor").click(function () {
                var count = $(".CompetitorRow").length;
                if (count <= 4) {
                    var html = "<tr class=\"CompetitorRow\" style=\"background-color: white; text-align: center;\">";
                    html += "<td><input data-value='competitorname' type=\"text\" /></td>";
                    html += "<td><input data-value='modelno' type=\"text\" /></td>";
                    html += "<td><input data-value='sellingprice' type=\"text\" /></td>";
                    html += "<td><input data-value='remark' type=\"text\" /></td>";
                    html += "<td></td></tr>";
                    $("#tbCompetitor").append(html);

                    if (count == 4)
                        $(this).prop("disabled", true);
                }
                else
                    return false;
            });

            $("#btnUpdateCompetitor").click(function (e) {
                var competitors = [];
                var flag = true;
                $(".CompetitorRow").each(function (i, n) {
                    var competitorname = "";
                    var modelno = "";
                    var sellingprice = "";
                    var remark = "";
                    $(n).children().each(function (j, m) {
                        var dv = $(m).children().attr("data-value");
                        switch (dv) {
                            case "competitorname":
                                competitorname = $(m).children().val();
                                break;
                            case "modelno":
                                modelno = $(m).children().val();
                                break;
                            case "sellingprice":
                                sellingprice = $(m).children().val();
                                break;
                            case "remark":
                                remark = $(m).children().val();
                                break;
                        }
                    });

                    if (sellingprice != "" && isNaN(sellingprice) == true) {
                        alert("Selling price is error");
                        flag = false;
                    }

                    if (competitorname != "" && modelno != "" && sellingprice != "") {
                        competitors.push({
                            competitorname: competitorname,
                            modelno: modelno,
                            sellingprice: sellingprice,
                            remark: remark
                        });
                    }
                });
                if (competitors.length > 0 && flag == true) {
                    $.ajax({
                        type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/Services/ProjectRegistration.asmx/UpdateCompetitor", data: { PrjRowID: '<%= hfRowID.Value%>', JsonData: JSON.stringify(competitors) }, dataType: "json",
                        success: function (retData) {
                            if (!!retData && retData.length > 0) {
                                var html = "";
                                for (var i = 0; i < retData.length; i++) {
                                    html += ("<tr id='" + retData[i].rowID + "' class=\"CompetitorRow\" style=\"background-color: white; text-align: center;\">");
                                    html += ("<td><input type=\"text\" data-value='competitorname' value='" + retData[i].competitorname + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='modelno' value='" + retData[i].modelno + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='sellingprice' value='" + retData[i].sellingprice + "' /></td>");
                                    html += ("<td><input type=\"text\" data-value='remark' value='" + retData[i].remark + "' /></td>");
                                    html += ("<td><input type=\"button\" data-key='" + retData[i].rowID + "' onclick='DeleteCompetitor(this);' value='Delete' /></td></tr>");
                                }
                                $("#tbCompetitor").html(html);
                                if (retData.length == 5)
                                    $("#btnAddCompetitor").prop("disabled", true);
                                else
                                    $("#btnAddCompetitor").prop("disabled", false);
                            }
                            alert("Update success!");
                        },
                        error: function () {
                            alert("Update competitor failed!");
                        }
                    });
                }
                e.preventDefault();
            });

            var editFlag = '<%= IsCanUpdateCountry%>';
            if (editFlag == undefined || editFlag != "True") {
                $(".updatedata").hide();
                $('#<%=ddlCountry.ClientID%>').attr("disabled", true);
            }
            <%--if ('<%=gvCompetitor.Rows.Count%>' < 1) {
                $("#btnProjectCompe").hide();
            }--%>
            //$(".MyRow").each(function () {
            //    $(this).css({ "text-align": "center" });
            //});
            //$(".MyComp").each(function () {
            //    $(this).css({ "text-align": "center" });
            //});
            $(".updatedata").on("click", function (e) {
                var dom = $(this);
                switch (dom.attr("id")) {
                    case "btnCustomerData":
                        return UpdateCustomerData();
                        break;
                    case "btnProjectInfo":
                        return UpdateProjectInfo();
                        break;
                    //case "btnProjectCompe":
                    //    return UpdateCompetitor();
                    //    break;
                }
                e.preventDefault();
            });

            //$("input[type='text']").attr("autocomplete", false);
            $('#<%=txtPrjCloseDate.ClientID%>').bind("keypress", false);
            $(".sellprice").on("blur", function () {
                var dom = $(this);
                if (dom.val() == "")
                    return false;
                if (isNaN(dom.val()) == true)
                    dom.focus();
            });
            $(".email").on("blur", function () {
                var dom = $(this);
                if (dom.val() == "")
                    return false;
                var reg = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (reg.test(dom.val()) == false)
                    dom.focus();
            });
        });
    </script>
    <div class="detail">
        <h2>
            Customer Information&nbsp;<button id="btnCustomerData" class="updatedata">Update</button></h2>
        <table width="100%" border="1" cellpadding="0" cellspacing="2" style="border-style: groove;">
            <tr>
                <td width="20%">
                    Company Name:
                </td>
                <td>
                    <input type="text" id="custname" value='<%= R.ENDCUST_NAME%>' />
                </td>
            </tr>
            <tr>
                <td>
                    Postal Code:
                </td>
                <td>
                    <input type="text" id="postcode" value='<%= R.ENDCUST_POST_CODE%>' />
                </td>
            </tr>
            <tr>
                <td>
                    State:
                </td>
                <td>
                    <input type="text" id="state" value='<%= R.ENDCUST_STATE%>' />
                </td>
            </tr>
            <tr>
                <td>
                    Country:
                </td>
                <td>
                    <asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="sqlCountry" DataTextField="text" DataValueField="value" OnDataBound="ddlCountry_DataBound"></asp:DropDownList>
                    <asp:SqlDataSource runat="server" ID="sqlCountry" ConnectionString="<%$ connectionStrings: MY %>"
                                SelectCommand="select * from SIEBEL_ACCOUNT_COUNTRY_LOV order by text"></asp:SqlDataSource>
                   <%-- <asp:MultiView runat="server" ID="mvCountry" ActiveViewIndex="0">
                        <asp:View runat="server" ID="v1">
                            <input type="text" id="country" value='<%= R.ENDCUST_COUNTRY%>' />
                        </asp:View>
                        <asp:View runat="server" ID="v2">
                            <table>
                                <tr>
                                    <td><asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="sqlCountry" DataTextField="text" DataValueField="value" OnDataBound="ddlCountry_DataBound"></asp:DropDownList></td>
                                    <td><asp:Button runat="server" ID="btnUpdCountry" Text="Update" OnClick="btnUpdCountry_Click" /></td>
                                </tr>
                            </table>
                            <asp:SqlDataSource runat="server" ID="sqlCountry" ConnectionString="<%$ connectionStrings: MY %>"
                                SelectCommand="select * from SIEBEL_ACCOUNT_COUNTRY_LOV order by text"></asp:SqlDataSource>
                        </asp:View>
                    </asp:MultiView>--%>
                </td>
            </tr>
            <tr>
                <td>
                    Address:
                </td>
                <td>
                    <input type="text" id="addr" value='<%= R.ENDCUST_ADDR%>' />
                </td>
            </tr>
        </table>
        <b>Contact(s):<input type="button" id="btnUpdateContact" value="Update" /></b>
        <div>
            <table cellspacing="0" rules="all" border="1" style="border-color: #D7D0D0; border-width: 1px; width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="color: black; background-color: gainsboro;">
                        <th scope="col">Last Name</th>
                        <th scope="col">First Name</th>
                        <th scope="col">Email</th>
                        <th scope="col">Tel.</th>
                        <th scope="col">Delete</th>
                    </tr>
                </thead>
                <tbody id="tbContact">
                </tbody>
            </table>
            <table>
                <tbody>
                    <tr>
                        <td style="text-align: right;">
                            <input type="button" id="btnAddContact" value="Add" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <%--<asp:GridView runat="server" ID="gvContact" Width="100%" AutoGenerateColumns="false" OnRowDataBound="gvContact_RowDataBound"
            EmptyDataText="No Data." ShowHeaderWhenEmpty="false">
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>
                        Last Name
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="lastname" Text='<%#Bind("LAST_NAME")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        First Name
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="firstname" Text='<%#Bind("FIRST_NAME")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        Email
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="email" Text='<%#Bind("Email")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        Tel.
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtTEL" runat="server" CssClass="tel" Text='<%#Bind("TEL")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>--%>
        <hr />
        <span runat="server" id="LitPossibleCustomer"><b>Possible duplicate end customer list:</b>
            <asp:UpdatePanel runat="server" ID="upSimilarAccounts" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Timer runat="server" ID="TimerAccount" Interval="100" OnTick="TimerAccount_Tick" />
                    <asp:GridView runat="server" ID="gvSimilarEndCust" AutoGenerateColumns="false" Width="100%"
                        EmptyDataText="No Data." ShowHeaderWhenEmpty="false">
                        <Columns>
                            <asp:HyperLinkField HeaderText="Account Name" SortExpression="account_name" DataNavigateUrlFields="ROW_ID"
                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name"
                                Target="_blank" />
                            <asp:BoundField HeaderText="Org." DataField="RBU" />
                            <asp:BoundField HeaderText="Primary Account Owner" DataField="PRIMARY_SALES_EMAIL" />
                            <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" />
                            <asp:BoundField HeaderText="Address" DataField="ADDRESS" />
                            <asp:BoundField HeaderText="Country" DataField="COUNTRY" />
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>
        </span>
        <h2>
            Project Information&nbsp;<button class="updatedata" id="btnProjectInfo">Update</button></h2>
        <table width="100%" border="1" cellpadding="0" cellspacing="2" style="border-style: groove;">
            <tr>
                <td width="20%">
                    Project Name:
                </td>
                <td>
                    <input type="text" id="prjname" value='<%= R.PRJ_NAME%>' size="80" maxlength="100" disabled="disabled" />
                </td>
            </tr>
            <tr>
                <td>
                    Project Description:
                </td>
                <td>
                    <input type="text" id="prjdesc" value='<%= R.PRJ_DESC%>' size="115" maxlength="200" />
                </td>
            </tr>
            <tr>
                <td>
                    Potential risk:
                </td>
                <td>
                    <input type="text" id="prjrisk" value='<%= R.POTENTIAL_RISK%>' size="115" maxlength="200" />
                </td>
            </tr>
            <tr>
                <td>
                    Needed Advantech Support:
                </td>
                <td>
                    <input type="text" id="prjsupp" value='<%= R.NEEDED_ADV_SUPPORT%>' size="115" maxlength="200" />
                </td>
            </tr>
            <tr>
                <td>
                    Close Date:
                </td>
                <td>
                    <ajaxToolkit:CalendarExtender runat="server" ID="cext1" TargetControlID="txtPrjCloseDate" Format="yyyy/MM/dd" />
                    <asp:TextBox ID="txtPrjCloseDate" runat="server"></asp:TextBox>
                </td>
            </tr>
            <%--            <tr>
                <td>
                    Total Amount:
                </td>
                <td>
                    <%= R.PRJ_TOTAL_AMT.ToString()%>
                </td>
            </tr>--%>
        </table>
        <h2>
            Competitor Information:&nbsp;<button id="btnUpdateCompetitor">Update</button></h2>
        <div>
            <table cellspacing="0" rules="all" border="1" style="border-color: #D7D0D0; border-width: 1px; width: 100%; border-collapse: collapse;">
                <thead>
                    <tr>
                        <th>Competitor Name</th>
                        <th>Model Name</th>
                        <th>Selling Price</th>
                        <th>Remark</th>
                        <th>Delete</th>
                    </tr>
                </thead>
                <tbody id="tbCompetitor">
                </tbody>
            </table>
            <table>
                <tbody>
                    <tr>
                        <td style="text-align: right;">
                            <input type="button" id="btnAddCompetitor" value="Add" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <%--<asp:GridView runat="server" ID="gvCompetitor" Width="100%" AutoGenerateColumns="false"
            EmptyDataText="No Data." ShowHeaderWhenEmpty="false" OnRowDataBound="gvCompetitor_RowDataBound">
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>Competitor Name</HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtComName" runat="server" CssClass="comname" Text='<%#Bind("COMPETITOR_NAME")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>Model Name</HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtModelName" runat="server" CssClass="modname" Text='<%#Bind("MODEL_NO")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>Selling Price</HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtSellPrice" runat="server" CssClass="sellprice" Text='<%#Bind("SELLING_PRICE")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>Remark</HeaderTemplate>
                    <ItemTemplate>
                        <asp:TextBox ID="txtRemark" runat="server" CssClass="remark" Text='<%#Bind("REMARK")%>' ></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>--%>
        <hr />
        <span runat="server" id="LitPossibleOpportunity"><b>Possible duplicate opportunity list:</b>
            <asp:UpdatePanel runat="server" ID="upSimilarOpty" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Timer runat="server" ID="TimerSimOpty" Interval="200" OnTick="TimerSimOpty_Tick" />
                    <asp:GridView runat="server" ID="gvSimilarOpty" AutoGenerateColumns="false" Width="100%"
                        EmptyDataText="No Data." ShowHeaderWhenEmpty="false" OnRowDataBound="gvSimilarOpty_RowDataBound">
                        <Columns>
                            <asp:BoundField HeaderText="Opty. Name" DataField="NAME" />
                            <asp:HyperLinkField HeaderText="Account Name" SortExpression="account_name" DataNavigateUrlFields="ACCOUNT_ROW_ID"
                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name"
                                Target="_blank" />
                            <asp:TemplateField HeaderText="Product Forecast" HeaderStyle-Width="160px">
                                <ItemTemplate>
                                    <asp:HiddenField runat="server" ID="hd_RowOptyId" Value='<%#Eval("OPTY_ID") %>' />
                                    <asp:GridView runat="server" ID="gvRowFcst" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:BoundField HeaderText="Part No." DataField="PART_NO" />
                                            <asp:BoundField HeaderText="Total Qty." DataField="TOTAL_QTY" ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </asp:GridView>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Created Date" DataField="CREATED" />
                            <asp:BoundField HeaderText="Sales Owner" DataField="SALES_TEAM_NAME" />
                            <asp:BoundField HeaderText="Stage" DataField="STAGE_NAME" />
                            <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="Amount" ItemStyle-CssClass="Tnowrap">
                                <ItemTemplate>
                                    <%= InterConPrjRegUtil.GetCurrencySign()%><%#DataBinder.Eval(Container.DataItem, "SUM_REVN_AMT ", "{0:N2} ")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Currency" DataField="CURCY_CD" />
                            <asp:BoundField HeaderText="Org." DataField="BU_NAME" />
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>
        </span>
        <asp:UpdatePanel runat="server" ID="upProduct">
            <ContentTemplate>
                <h2>
                    Product(s) Information &nbsp;&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="LabWarn"
                        ForeColor="Tomato" Font-Size="11px"></asp:Label></h2>
                <asp:Timer runat="server" ID="Timer2" Interval="300" OnTick="Timer2_Tick" Enabled="false" />
                <asp:GridView runat="server" ID="gvProduct" DataKeyNames="row_id,line_no" Width="100%"
                    AutoGenerateColumns="false" OnRowDataBound="gvProduct_RowDataBound">
                    <Columns>
                        <%--<asp:BoundField HeaderText="Part Number" DataField="PART_NO" />--%>
                        <asp:TemplateField HeaderText="Part Number" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" TargetControlID="txtPartNo"
                                    ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                    OnClientItemSelected="PNSelected"></ajaxToolkit:AutoCompleteExtender>
                                <asp:TextBox runat="server" ID="txtPartNo" Text='<%# Eval("PART_NO") %>'></asp:TextBox>
                                <asp:Button runat="server" ID="btnUpdatePartNo" Text="Update" OnClick="btnUpdatePartNo_Click" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- <asp:BoundField HeaderText="Qty." DataField="QTY" ItemStyle-HorizontalAlign="Center" />--%>
                        <asp:TemplateField HeaderText="Qty." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150">
                            <ItemTemplate>
                                <asp:TextBox runat="server" ID="TBQTY" Width="50" Text='<%# Eval("qty") %>'></asp:TextBox>
                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="Filtered2TB" TargetControlID="TBQTY"
                                    ValidChars="1234567890" />
                                <asp:Button runat="server" Text="Update" ID="BTQty" OnClick="BTQty_Click" Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Schedules" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:GridView runat="server" ID="gv2" DataSource='<%# GetData(Eval("ROW_ID")) %>'
                                    AutoGenerateColumns="false" EmptyDataText="No" ShowHeaderWhenEmpty="false" Width="92px">
                                    <Columns>
                                        <asp:BoundField HeaderText="Ship Date" DataField="SHIP_DATE" ItemStyle-HorizontalAlign="Center" DataFormatString="{0: yyyy-MM-dd}" />
                                        <asp:BoundField HeaderText="Qty." DataField="QTY" ItemStyle-HorizontalAlign="Center" />
                                    </Columns>
                                </asp:GridView>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--<asp:BoundField HeaderText="Remark" DataField="REMARK" />--%>
                        <asp:TemplateField HeaderText="Remark" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:TextBox runat="server" ID="txtRemark" Width="50" Text='<%# Eval("REMARK") %>'></asp:TextBox>
                                <asp:Button runat="server" ID="btnUpdateRemark" Text="Update" OnClick="btnUpdateRemark_Click" Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- <asp:BoundField  DataField="SELLINGPRICE" DataFormatString="{0:N2}"  />--%>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="Selling Price" ItemStyle-CssClass="Tnowrap">
                            <ItemTemplate>
                                <%= InterConPrjRegUtil.GetCurrencySign()%>
                                   <asp:TextBox runat="server" ID="TBSprice" Width="70" Text='<%#DataBinder.Eval(Container.DataItem, "SELLINGPRICE ", "{0:N2} ")%>'></asp:TextBox>
                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="Filtered3TB" TargetControlID="TBSprice"
                                    ValidChars="1234567890." />
                                <asp:Button runat="server" Text="Update" ID="BTSprice" OnClick="BTSprice_Click" Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="Standard Price" ItemStyle-CssClass="Tnowrap">
                            <ItemTemplate>
                                <%= InterConPrjRegUtil.GetCurrencySign()%><asp:Label ID="lbStdPrice" runat="server" Text='<%#DataBinder.Eval(Container.DataItem, "STANDARDPRICE ", "{0:N2} ")%>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField  DataField="REQUESTPRICE" DataFormatString="{0:N2}" ItemStyle-CssClass="Tnowrap"  ItemStyle-HorizontalAlign="Right" HeaderText="Request Price"/>
                        <asp:TemplateField HeaderText="Approve Price" ItemStyle-HorizontalAlign="Right"     ItemStyle-Width="200" Visible="false">
                            <ItemTemplate>
                                <%= InterConPrjRegUtil.GetCurrencySign()%>
                                <asp:TextBox runat="server" ID="TBAprice" Width="100"></asp:TextBox>
                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTB" TargetControlID="TBAprice"
                                    ValidChars="1234567890." />
                                <asp:Button runat="server" Text="Update" ID="BTAprice" OnClick="BTAprice_Click" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
        <uc2:PrjUpdate2Siebel ID="PrjUpdate2Siebel1" runat="server" />
        <uc1:PrjApprove ID="PrjApprove1" runat="server" />
        <asp:HiddenField ClientIDMode="Static" ID="hfRowID" runat="server" />
    </div>
</asp:Content>
