<%@ Page Title="View SIEBEL Quotation" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Import Namespace="Oracle.DataAccess.Client" %>
<%@ Register src="../Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>
<%@ Register Src="~/Includes/Order/PickERE.ascx" TagName="ERE" TagPrefix="uc2" %>

<script runat="server">
    Public listR As Integer = 0
    Public chkR As Integer = 0
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetSIEBELQuotes(ByVal QuoteName As String, ByVal AccountName As String) As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 100 a.ROW_ID, a.QUOTE_NUM, a.TARGET_OU_ID as ACCOUNT_ROW_ID, b.NAME as ACCOUNT_NAME, IsNull(c.ATTRIB_05,'') as ERPID, "))
            .AppendLine(String.Format(" IsNull((select cast(sum(z.QTY_REQ*z.UNIT_PRI) as numeric(18,2)) from S_QUOTE_ITEM z where z.SD_ID=a.ROW_ID),0) as QUOTE_SUM, "))
            .AppendLine(String.Format(" a.NAME, IsNull(a.STATUS_DT,'') as QUOTE_STATUS,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.FST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as First_Name,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.LAST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Last_Name,   "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Contact_Email,  "))
            .AppendLine(String.Format(" a.CURCY_CD as Currency,  "))
            .AppendLine(String.Format(" a.EFF_START_DT as Effective_Date,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.NAME from S_OPTY z where z.ROW_ID=a.OPTY_ID),'') as OPTY_NAME, a.OPTY_ID,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID in (select z2.PR_EMP_ID from S_POSTN z2 where z2.ROW_ID=a.SALES_REP_POSTN_ID)),'') as Sales_Rep,  "))
            .AppendLine(String.Format(" a.CREATED, a.DESC_TEXT as QUOTE_DESC, a.DUE_DT, a.EFF_END_DT, a.ACTIVE_FLG, "))
            .AppendLine(String.Format(" a.CREATED_BY, a.SALES_REP_POSTN_ID as OWNER_ID "))
            .AppendLine(String.Format(" from S_DOC_QUOTE a inner join S_ORG_EXT b on a.TARGET_OU_ID=b.ROW_ID  inner join S_ORG_EXT_X c on b.ROW_ID=c.ROW_ID	"))
            .AppendLine(" where 1=1 ")
            If QuoteName.Trim <> "" Then
                .AppendLine(String.Format(" and Upper(a.NAME) like N'%{0}%' ", QuoteName.ToUpper.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If AccountName.Trim <> "" Then
                .AppendLine(String.Format(" and Upper(b.NAME) like N'%{0}%' ", AccountName.ToUpper.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(" order by a.CREATED desc")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMAPPDB", sb.ToString())
        If dt.Rows.Count = 0 Then
            Return "No matched Quotation"
        End If
        sb = New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format("<table width='100%'>"))
            .AppendLine(String.Format("<tr><th>Quotation Name</th><th>Account Name</th></tr>"))
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim r As DataRow = dt.Rows(i)
                Dim bcolor As String = "FEFEFE"
                If i Mod 2 = 1 Then bcolor = "DCDBDB"
                .AppendLine(String.Format("<tr style='background-color:#" + bcolor + ";'>" + _
                                          " <td>" + _
                                          "     <a href='ViewSIEBELQuote.aspx?QUOTEID={0}'>{1}</a>" + _
                                          " </td>" + _
                                          " <td>{2}</td>" + _
                                          "</tr>", r.Item("ROW_ID"), r.Item("NAME"), r.Item("ACCOUNT_NAME")))
            Next
            .AppendLine(String.Format("</table>"))
        End With
        Return sb.ToString()
    End Function
    Function GetQuoteLinesSql(ByVal QuoteId As String) As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT a.LN_NUM, b.NAME AS PART_NO, b.DESC_TEXT, IsNull(cast(IsNull(a.BASE_UNIT_PRI,a.UNIT_PRI) as numeric(18,2)),0) as START_PRICE,  "))
            'Nada20140102 for Show's request changed Qty to Req Qty ,Price to Net Price
            '.AppendLine(String.Format(" IsNull(cast(IsNull(a.NET_PRI,a.BASE_UNIT_PRI) as numeric(18,2)),0) as DISCOUNT_PRICE, "))
            .AppendLine(String.Format(" (case when ISNUMERIC(c.ATTRIB_15) = 1 then CAST(c.ATTRIB_15 as numeric(18,2)) else 0 end) as DISCOUNT_PRICE, "))
            '/Nada20140102
            .AppendLine(String.Format(" case  CONVERT(int, IsNull(a.BASE_UNIT_PRI ,0)) when 0 then CONVERT(varchar(10),0.0)+'%' else "))
            .AppendLine(String.Format(" cast(IsNull(cast((a.BASE_UNIT_PRI-IsNull(a.UNIT_PRI,a.BASE_UNIT_PRI))/a.BASE_UNIT_PRI*100 as numeric(18,2)),0.0) as varchar(10))+'%' end as DISC, "))
            'Nada20140102 for Show's request changed Qty to Req Qty ,Price to Net Price
            '.AppendLine(String.Format(" cast(a.QTY_REQ as int) as QTY_REQ, cast(a.EXTD_QTY as int) as EXTD_QTY, "))
            .AppendLine(String.Format(" (case when ISNUMERIC(c.ATTRIB_04)=1 THEN CAST(c.ATTRIB_04 as int) ELSE 1 END) as QTY_REQ, cast(a.EXTD_QTY as int) as EXTD_QTY, "))
            '/Nada20140102
            .AppendLine(String.Format(" IsNull(c.ATTRIB_03,'') as Product_Rpt, IsNull(c.ATTRIB_47,'') as Description_Rpt,convert(varchar(14),a.QUOTE_ITM_EXCH_DT,111) as duedate "))
            .AppendLine(String.Format(" FROM S_QUOTE_ITEM AS a INNER JOIN S_PROD_INT AS b ON a.PROD_ID = b.ROW_ID inner join S_QUOTE_ITEM_X c on a.ROW_ID=c.ROW_ID "))
            .AppendLine(String.Format(" WHERE a.SD_ID = '{0}' ORDER BY a.LN_NUM", QuoteId))
        End With
        Return sb.ToString()
    End Function
    Function GetQuoteLines(ByVal QuoteId As String) As DataTable
        Dim qiDt As DataTable = Nothing
        For i As Integer = 1 To 3
            Try
                qiDt = dbUtil.dbGetDataTable("CRMAPPDB", GetQuoteLinesSql(QuoteId))
                Exit For
            Catch ex As System.Data.SqlClient.SqlException
                Threading.Thread.Sleep(500)
            End Try
        Next
        Return qiDt
    End Function

    Function GetQuoteHeader(ByVal QuoteId As String) As System.Data.DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select a.QUOTE_NUM, a.TARGET_OU_ID as ACCOUNT_ROW_ID, b.NAME as ACCOUNT_NAME, IsNull(c.ATTRIB_05,'') as ERPID, "))
            .AppendLine(String.Format(" IsNull((select cast(sum(z.QTY_REQ*z.UNIT_PRI) as numeric(18,2)) from S_QUOTE_ITEM z where z.SD_ID=a.ROW_ID),0) as QUOTE_SUM, "))
            .AppendLine(String.Format(" a.NAME, IsNull(a.STATUS_DT,'') as QUOTE_STATUS,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.FST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as First_Name,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.LAST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Last_Name,   "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Contact_Email,  "))
            .AppendLine(String.Format(" a.CURCY_CD as Currency,  "))
            .AppendLine(String.Format(" IsNull(a.EFF_START_DT,GetDate()) as Effective_Date,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.NAME from S_OPTY z where z.ROW_ID=a.OPTY_ID),'') as OPTY_NAME, a.OPTY_ID,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID in (select z2.PR_EMP_ID from S_POSTN z2 where z2.ROW_ID=a.SALES_REP_POSTN_ID)),'') as Sales_Rep,  "))
            .AppendLine(String.Format(" a.CREATED, a.DESC_TEXT as QUOTE_DESC,IsNull(a.DUE_DT,GetDate()) as DUE_DT,a.EFF_END_DT, a.ACTIVE_FLG, "))
            .AppendLine(String.Format(" a.CREATED_BY, a.SALES_REP_POSTN_ID as OWNER_ID "))
            .AppendLine(String.Format(" from S_DOC_QUOTE a inner join S_ORG_EXT b on a.TARGET_OU_ID=b.ROW_ID  inner join S_ORG_EXT_X c on b.ROW_ID=c.ROW_ID	"))
            .AppendLine(String.Format(" where a.ROW_ID='{0}' ", QuoteId))
        End With
        Dim qmDt As DataTable = Nothing
        For i As Integer = 1 To 3
            Try
                qmDt = dbUtil.dbGetDataTable("CRMAPPDB", sb.ToString())
                Exit For
            Catch ex As System.Data.SqlClient.SqlException
                Threading.Thread.Sleep(500)
            End Try
        Next
        Return qmDt
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/ATW/SiebelQuote.aspx?QUOTEID=" & Request("QUOTEID")))
        'If Util.IsTesting Then
        '    Response.Redirect(String.Format("http://eq.advantech.com:8300/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
        'Else
        '    Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
        'End If
        Dim url As String = ""
        If Util.IsTesting Then
            url = "http://172.20.1.30:8300"
        Else
            url = "http://eq.advantech.com"
        End If
        url &= "/ATW/SiebelQuote.aspx?QUOTEID=" & Request("QUOTEID")
        Response.Redirect(url)

        
        If Util.IsAEUIT() Then
            btnQuote2Order.Visible = True
        End If
        If Session("user_id").ToString.ToUpper = "MING.ZHAO@ADVANTECH.COM.CN" Then
            btnConfirmOrder.Enabled = False
        End If
        If Not Util.IsInternalUser(Session("user_id")) Then Response.Redirect("/Home.aspx")
        If Not Page.IsPostBack AndAlso Request("QUOTEID") IsNot Nothing Then
            gvItems.EmptyDataText = "No line items"
            Dim qid As String = Trim(Request("QUOTEID")).Replace("'", "")
            hd_Qid.Value = qid
            Session.Contents.Remove("Product_Err")
            Session.Contents.Remove("GV_checkbox")
            listR = 0
            chkR = 0
            Dim sb As New System.Text.StringBuilder
            Dim qmDt As DataTable = GetQuoteHeader(qid)
            If qmDt IsNot Nothing AndAlso qmDt.Rows.Count = 1 Then
                With qmDt.Rows(0)
                    lbAccount.Text = .Item("ACCOUNT_NAME") : lbCurr.Text = .Item("Currency")
                    'If IsDBNull(.Item("DUE_DT")) OrElse IsDBNull(.Item("Effective_Date")) Then                      
                    'Else
                    lbDue.Text = CDate(.Item("DUE_DT")).ToString("yyyy/MM/dd") : lbEffDate.Text = CDate(.Item("Effective_Date")).ToString("yyyy/MM/dd")
                    'End If
                    lbFstName.Text = .Item("First_Name") : lbLstName.Text = .Item("Last_Name")
                    lbOptyName.Text = .Item("OPTY_NAME") : lbQuoteName.Text = .Item("NAME")
                    lbPickedQuoteName.Text = .Item("NAME")
                    lbQuoteNum.Text = .Item("QUOTE_NUM") : lbQuoteStatus.Text = .Item("QUOTE_STATUS")
                    lbSalesRep.Text = .Item("Sales_Rep")
                    lbTotal.Text = .Item("QUOTE_SUM")
                    lbERPID.Text = .Item("ERPID")
                    Me.txtReqDate.Text = CDate(.Item("DUE_DT")).ToString("yyyy/MM/dd")
                End With
                'Dim qiDt As DataTable = GetQuoteLines(qid)
                'gvItems.DataSource = qiDt : gvItems.DataBind()
                src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
                'OrderUtilities.showDT(qmDt)
                'OrderUtilities.showDT(dbUtil.dbGetDataTable("CRMAPPDB", GetQuoteLinesSql(hd_Qid.Value)))
            Else
                lbMsg.Text = "Requested quotation does not exist in SIEBEL"
            End If
        End If
    End Sub
    Function ShowProdStatus(ByVal pn As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 status from sap_product_org where org_id='TW01' and part_no='{0}'", pn.Replace("'", "")))
        If obj IsNot Nothing Then
            Return obj.ToString()
        Else
            Return "N/A"
        End If
    End Function
    Protected Sub btnQuote2Order_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnQuote2Ordernew_Click(Nothing, Nothing)
    End Sub
    Public Function IsBtoOrder(ByVal partno As String) As Boolean
        'For Each r As GridViewRow In gvItems.Rows
        '    If r.RowType = Web.UI.WebControls.DataControlRowType.DataRow Then
        '        Dim chk As CheckBox = r.FindControl("item")
        '        If chk.Checked Then
        '            Dim rPn As String = CType(r.FindControl("txtRowPN"), TextBox).Text.Trim()                   
        '            If rPn.Trim.ToUpper.EndsWith("BTO") AndAlso r.RowIndex = 0 Then
        '                Return True
        '            Else
        '                Return False
        '            End If 
        '        End If
        '    End If
        'Next
        If partno.Trim.EndsWith("BTO", StringComparison.CurrentCultureIgnoreCase) OrElse partno.Trim.EndsWith("CTOS", StringComparison.CurrentCultureIgnoreCase) Then
                Return True 
        End If
        Return False
    End Function
    Protected Sub gvItems_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
    End Sub

    Protected Sub gvItems_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
    End Sub

    Protected Sub gvItems_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
    End Sub

    Protected Sub gvItems_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(11).Text = FormatNumber(CDbl(CType(e.Row.Cells(8).FindControl("txtPrice"), TextBox).Text) * CDbl(CType(e.Row.Cells(10).FindControl("txtQty"), TextBox).Text), 2)
            '為了防止perant item有修改過，重新整理後qty數量會復原
            If hf_qty.Value <> "" Then
                Dim pQty As Integer = CInt(hf_qty.Value)
                CType(e.Row.Cells(7).FindControl("txtQty"), TextBox).Text = CStr(CType(CType(e.Row.Cells(7).FindControl("txtQty"), TextBox).Text, Integer) * pQty)
            End If
            
            Dim rPn As String = CType(e.Row.Cells(2).FindControl("txtRowPN"), TextBox).Text.Trim()
            If rPn.EndsWith("BTO") Then
                Dim chk As CheckBox = e.Row.Cells(1).FindControl("item")
                chk.Checked = True
                chk.Enabled = False
            End If
            
            'JJ 2014/3/18：Session("Product_Err") Not Is Nothing表示,ProductList內的料號其中有一個有問題
            If Not Session("Product_Err") Is Nothing Then
                
                Dim Literal_Err As Literal = e.Row.Cells(2).FindControl("Literal_err")
                Dim _ProductList As New List(Of SAPDAL.ProductX)
                Dim _GVcheckbox As New List(Of Boolean)
                Dim chk As CheckBox = e.Row.Cells(1).FindControl("item")
                _ProductList = Session("Product_Err")
                
                '因為檢查後如果有問題，重跑RowDataBound後CheckBox會被還原了，所以必須記下來重新載入
                _GVcheckbox = Session("GV_checkbox")
                chk.Checked = _GVcheckbox(chkR)
                
                If chk.Checked Then
                    CType(e.Row.Cells(2).FindControl("txtRowPN"), TextBox).Text = _ProductList(listR).PartNo
                    
                    'StatusCode=""表示查無此料號
                    If _ProductList(listR).StatusCode = "" Then
                        Literal_Err.Text += "<p style='color: #CC0000'>Invalid part number<p>"
                    Else
                        'Is Phase Out就顯示料號的狀態
                        If _ProductList(listR).IsPhaseOut Then
                            Literal_Err.Text += "<p style='color: #CC0000'>Invalid part number<p>"
                            Literal_Err.Text += "<p style='color: #CC0000'>Status:(" + _ProductList(listR).StatusCode + ")" + _ProductList(listR).StatusDesc + "<p>"
                        Else
                            Literal_Err.Text = ""
                        End If
                    End If
                    listR += 1 'Product List用來記順序的
                   
                Else
                    Literal_Err.Text = ""
                End If
                chkR += 1 '用來記錄GridView內checkbox的順序的
            End If
        End If
    End Sub

    Protected Sub gvItems_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)

    End Sub

    
    Protected Sub btnConfirmOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.End()
        'For k As Integer = 0 To gvItems.Rows.Count - 1
        '    Response.Write(k & "|")
        '    For m As Integer = 0 To gvItems.Columns.Count - 1
        '        Response.Write("<font color=""#ff0000"">" & m & ":</font>") : Response.Write(gvItems.Rows(k).Cells(m).Text)
        '    Next
        '    Response.Write("<br>")
        'Next
        'Response.End()
        lbMsg.Text = "" : lbOrderMsg.Text = ""
        src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
        If Request("QUOTEID") IsNot Nothing Then
            Dim qid As String = Trim(Request("QUOTEID")).Replace("'", "")
            Dim sb As New System.Text.StringBuilder
            Dim qmDt As DataTable = GetQuoteHeader(qid)
            If qmDt IsNot Nothing AndAlso qmDt.Rows.Count = 1 Then
                Dim QuoteToERPId As String = qmDt.Rows(0).Item("ERPID").ToString().ToUpper().Trim().Replace("'", "")
                Dim OptyId As String = qmDt.Rows(0).Item("OPTY_ID").ToString()
                Dim ReqDate As String = qmDt.Rows(0).Item("DUE_DT").ToString()
                If QuoteToERPId <> "" Then
                    Dim ERPIDInfDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
                    String.Format("select kunnr, name1 from saprdp.kna1 where mandt='168' and kunnr='{0}'", QuoteToERPId))
                    'Dim qiDt As DataTable = GetQuoteLines(qid)
                    If ERPIDInfDt.Rows.Count = 1 Then
                        Me.chgCompany.TargetCompanyId = QuoteToERPId
                        Me.chgCompany.ChangeToCompanyId()
                        
                        'master
                        Dim UID As String = ""
                        Global_Inc.UniqueID_Get("EU", "L", 12, UID)
                        Dim OrderNo As String = ""
                        OrderNo = OrderUtilities.getOrderNumberOracle(UID)
                        Dim PoNo As String = OrderNo
                        Dim PartialFlag As String = "Y"
                        Dim RequiredDate As String = Me.txtReqDate.Text
                        Dim Currency As String = Session("Company_Currency")
                        Dim Incoterm As String = ""
                        Dim IncotermText As String = ""
                        Dim ShipCondition As String = OrderUtilities.getShipConditionByERPID(QuoteToERPId)
                        Dim SalesNote As String = Util.ReplaceSQLStringFunc(Me.txtSalesNote.Text)
                        Dim OrderNote As String = Util.ReplaceSQLStringFunc(Me.txtOrderNote.Text)
                        
                        OrderUtilities.clearOrder(OrderNo)
                        
                        OrderUtilities.OrderMaster_Insert(UID, OrderNo, "SO", PoNo, Now(), QuoteToERPId, QuoteToERPId, QuoteToERPId, "", Now(), "", "", PartialFlag, "", "", 0, 0, "", "", "", "", Now(), RequiredDate, "", Currency, OrderNote, "", 0, 0, Session("User_id"), "Z", Incoterm, IncotermText, SalesNote, "", ShipCondition)
                        
                        'Dim str As String = "select IsNull(attention,'') as attention, IsNull(ship_via,'') as ship_via from sap_dimcompany where company_id = '" & Session("COMPANY_ID") & "' and org_id = '" & Session("COMPANY_ORG_ID") & "' and company_type='Partner'"
                        
                        'detail
                        Dim i As Integer = 0
                        Dim count As Integer = 0
                        Dim g_adoConn As New OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
                        g_adoConn.Open()
                        Dim dbCmd As OracleCommand = g_adoConn.CreateCommand()
                        dbCmd.CommandType = CommandType.Text
                        
                        For Each r As GridViewRow In gvItems.Rows
                            If count + 1 = 100 Or i > 200 Then
                                lbMsg.Text = "too much items."
                                Exit Sub
                            End If
                           
                            
                            If r.RowType = Web.UI.WebControls.DataControlRowType.DataRow Then
                                Dim chk As CheckBox = r.FindControl("item")
                                If chk.Checked Then
                                    Dim rPn As String = CType(r.FindControl("txtRowPN"), TextBox).Text.Trim()
                                    Dim rLp As Decimal = CDbl(r.Cells(7).Text)
                                    Dim rUp As Decimal = CType(r.FindControl("txtPrice"), TextBox).Text.Trim()
                                    Dim rQty As Integer = CType(r.FindControl("txtQty"), TextBox).Text.Trim()
                                    Dim rReqDate As String = CType(r.FindControl("txtDueDate"), TextBox).Text.Trim()
                                    Dim strSqlCmd As String = String.Format( _
                                    "select COUNT(A.MATNR) from saprdp.mara a left join saprdp.mvke b on a.matnr=b.matnr where a.matnr='{1}'" & _
                                    " and (a.MATKL IN ('BTOS','CTOS','ZSRV') or (b.VMSTA IN ('A','N','H','S5','M1') and b.VKORG='{0}')) " & _
                                    " and a.mandt='168' AND B.MANDT='168'", Session("org_id").ToString.ToUpper, Global_Inc.Format2SAPItem(rPn.Replace("'", "''").ToUpper))
                                    dbCmd.CommandText = strSqlCmd
                                    Dim retObj As Object = Nothing
                                    Try
                                        retObj = dbCmd.ExecuteScalar()
                                    Catch ex As Exception
                                        
                                    End Try
                                    
                                    If Not IsNothing(retObj) AndAlso CInt(retObj) > 0 Then
                                        If rPn.ToString.ToUpper Like "*-BTO" Then
                                            Dim SBUPDATELINENO As String = String.Format("update MyAdvantechGlobal.dbo.order_detail set order_detail.LINE_NO=order_detail.LINE_NO+100 where order_detail.order_id='{0}'", UID)
                                            dbUtil.dbExecuteNoQuery("B2B", SBUPDATELINENO.ToString())
                                            OrderUtilities.OrderDetail_Insert(UID, 100, "", rPn, "", rQty, rLp, rUp, Now(), "", "", rReqDate, "Z", 0, Now(), 0)
                                            i += 100
                                        Else
                                            OrderUtilities.OrderDetail_Insert(UID, i + 1, "", rPn, "", rQty, rLp, rUp, Now(), "", "", rReqDate, "Z", 0, Now(), 0)
                                            i += 1
                                        End If
                                        Dim sb1 As New System.Text.StringBuilder
                                        With sb1
                                            .AppendLine(String.Format(" update MyAdvantechGlobal.dbo.order_detail set order_detail.DeliveryPlant=p.DeliveryPlant "))
                                            .AppendLine(String.Format(" from sap_product_org p  "))
                                            .AppendLine(String.Format(" where order_detail.part_no=p.part_no " + _
                                                                      " and order_id='{0}' and p.org_id='{1}' ", UID, Session("org_id")))
                                        End With
                                        dbUtil.dbExecuteNoQuery("B2B", sb1.ToString())
                                        count += 1
                                    Else
                                        Dim sql As String = String.Format("delete from  MyAdvantechGlobal.dbo.order_master where order_id='{0}'", UID)
                                        dbUtil.dbExecuteNoQuery("B2B", sql.ToString())
                                        sql = String.Format("delete from  MyAdvantechGlobal.dbo.order_detail where order_id='{0}'", UID)
                                        dbUtil.dbExecuteNoQuery("B2B", sql.ToString())
                                        lbMsg.Text = rPn & " is an invalid part no."
                                        lbOrderMsg.Text = "Part Number:" + rPn + " is an invalid part no."
                                        Exit Sub
                                    End If
                                End If
                            End If
                        Next
                        g_adoConn.Close() : g_adoConn = Nothing
                        'Response.End()
                        If OptyId <> "" Then
                            Dim sb2 As New System.Text.StringBuilder
                            With sb2
                                .AppendLine(String.Format(" update MyAdvantechGlobal.dbo.order_detail set order_detail.optyid='{0}' where order_id='{1}'", OptyId, UID))
                            End With
                            dbUtil.dbExecuteNoQuery("B2B", sb2.ToString())
                            Session("Optyid") = OptyId
                        End If
                        Dim exeFunc As Integer = 0
                        exeFunc = OrderUtilities.OrderXML_Create("SO", UID, Session("ORG_ID"))
                        exeFunc = OrderUtilities.ERPOrder_Integrate("SO", OrderNo)
                        exeFunc = OrderUtilities.SendPI(OrderNo, "PI", "")
                        If exeFunc = 1 Then
                            dbUtil.dbExecuteNoQuery("b2b", String.Format("update oracleOrderNum set isSuccess=1 where order_id='{0}'", UID))
                        End If
                        If OptyId <> "" And exeFunc = 1 Then
                            Dim OPTYrevenue As Decimal = 0.0
                            OPTYrevenue = dbUtil.dbExecuteScalar("B2B", "select SUM(QTY * UNIT_PRICE) from order_DETAIL where order_id = '" & Trim(UID) & "'")
                            OptyId = dbUtil.dbExecuteScalar("B2B", "select TOP 1 OPTYID from order_DETAIL where order_id = '" & Trim(UID) & "'")
                            Dim ws As New aeu_eai2000.Siebel_WS
                            ws.Timeout = -1
                            ws.UseDefaultCredentials = True
                            Dim b As Boolean = False
                            Try
                                b = ws.UpdateOpportunityStatusRevenue(OptyId, "Won", OPTYrevenue, False)
                            Catch ex As Exception
                                Util.SendEmail("ebusiness.aeu@advantech.eu", "ebiz.aeu@advantech.eu", _
                                               String.Format("Update Opty to Won for SO:{0} OptyID:{1}", OrderNo, OptyId), ex.ToString(), True, "", "")
                            End Try
                            Session("Optyid") = ""
                            Session("Optyid") = Nothing
                            'If Session("user_id").ToString.ToLower.Contains("nada.liu") Then
                            '    Response.Write(OPTYrevenue & OPTYID) : Response.End()
                            'End If
                        End If
                        Dim flgOrderExist As String = "No"
                        'Response.Redirect("~/order/Order_Confirm_V6.aspx?flag=" & flgOrderExist & "&order_no=" & OrderNo & "&order_id=" & UID)
                        Util.AjaxRedirect(upOrderMsg, "../order/Order_Confirm_V6.aspx?flag=" & flgOrderExist & "&order_no=" & OrderNo & "&order_id=" & UID)

                    Else
                        lbMsg.Text = "ERPID is not correctly maintained for this quote-to account in SIEBEL"
                    End If
                Else
                    lbMsg.Text = "ERPID is not maintained for this quote-to account in SIEBEL"
                End If
            End If
        End If
    End Sub

    Protected Sub btnQuote2Ordernew_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbPOPMsg.Text = ""
        src1.SelectCommand = GetQuoteLinesSql(hd_Qid.Value)
        If Request("QUOTEID") IsNot Nothing Then
            Dim qid As String = Trim(Request("QUOTEID")).Replace("'", "")
            Dim sb As New System.Text.StringBuilder
            Dim qmDt As DataTable = GetQuoteHeader(qid)
            If qmDt IsNot Nothing AndAlso qmDt.Rows.Count = 1 Then
                Dim QuoteToERPId As String = qmDt.Rows(0).Item("ERPID").ToString().ToUpper().Trim().Replace("'", "")
                If QuoteToERPId <> "" Then
                    If MYSAPBIZ.is_Valid_Company_Id(QuoteToERPId) = False Then
                        'lbPOPMsg.Text = String.Format("Please click <a href=""../Admin/SyncCustomer.aspx?companyid={0}"" target=""_blank"" style=""text-decoration: underline;""><strong style=""color:#FF0000"">here</strong></a> to synchronize company id({0}) From SAP to MyAdvantech", QuoteToERPId.ToString.Trim)
                        lbPOPMsg.Text = String.Format("ErpId " + QuoteToERPId + " is invalid, Please click <a href=""../Admin/SyncCustomer.aspx?companyid={0}"" target=""_blank"" style=""text-decoration: underline;""><strong style=""color:#FF0000"">here</strong></a> to synchronize company id({0}) From SAP to MyAdvantech", QuoteToERPId.ToString.Trim)
                        Exit Sub
                    End If
                    Dim ERPIDInfDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
                    String.Format("select kunnr, name1 from saprdp.kna1 where mandt='168' and kunnr='{0}'", QuoteToERPId))
                    'Dim qiDt As DataTable = GetQuoteLines(qid)                                     
                    If ERPIDInfDt.Rows.Count = 1 Then
                        Me.chgCompany.TargetCompanyId = QuoteToERPId
                        Me.chgCompany.ChangeToCompanyId()
                        'Dim Istrue As Boolean = Me.chgCompany.ChangeToCompanyId()
                        'If Istrue = False Then
                        '    lbMsg.Text = ""
                        '    Exit Sub
                        'End If
                        
                        'JJ 2014/3/18：檢查Product是否存在及不為Phase Out
                        Dim IsHavePhaseout As Boolean = False
                        Dim _ProductList As New List(Of SAPDAL.ProductX)
                        Dim _GVcheckbox As New List(Of Boolean)
                        Dim _ProductX As New SAPDAL.ProductX()
                        For Each r As GridViewRow In gvItems.Rows
                            If r.RowType = Web.UI.WebControls.DataControlRowType.DataRow Then
                                Dim chk As CheckBox = r.FindControl("item")
                                _GVcheckbox.Add(chk.Checked)
                                If chk.Checked Then
                                    Dim rPn As String = CType(r.FindControl("txtRowPN"), TextBox).Text.Trim()
                                    _ProductList.Add(New SAPDAL.ProductX(rPn, Session("ORG_ID"), ""))
                                End If
                            End If
                        Next
                        _ProductList = _ProductX.GetProductInfo(_ProductList, Session("ORG_ID"), IsHavePhaseout)
                       
                        'JJ 2014/3/18：IsHavePhaseout=true表示Product List中有料號有問題
                        '必須存在Session中是因為顯示Error是在GridView中的Row中，所以是要在RowDataBound中做
                        '所以用Session帶過去，如果沒問題就清空Session 
                        If IsHavePhaseout Then
                            Session("Product_Err") = _ProductList
                            Session("GV_checkbox") = _GVcheckbox
                            listR = 0
                            chkR = 0
                            Exit Sub
                        Else
                            Session.Contents.Remove("Product_Err")
                            Session.Contents.Remove("GV_checkbox")
                            listR = 0
                            chkR = 0
                        End If
                                                                       
                        Dim strcartId As String = Session("CART_ID"), i As Integer = 0
                        Dim mycart As New CartList("b2b", "cart_detail_V2")
                        'mycart.Delete(String.Format("cart_id='{0}'", strcartId))
                        MyCartX.DeleteCartAllItem(strcartId)
                        Dim Type_int As Integer = CartItemType.Part
                        Dim _higherLevel As Integer = 0, _isUpdatePrice As Integer = 1, _ParentItemQty As Integer = 1
                        For Each r As GridViewRow In gvItems.Rows
                            If r.RowType = Web.UI.WebControls.DataControlRowType.DataRow Then
                                Dim chk As CheckBox = r.FindControl("item")
                                If chk.Checked Then
                                    Dim rPn As String = CType(r.FindControl("txtRowPN"), TextBox).Text.Trim()
                                    Dim rLp As Decimal = CDbl(r.Cells(7).Text)
                                    Dim rUp As Decimal = 0
                                    If CType(r.FindControl("txtPrice"), TextBox).Text.Trim() = "" Then
                                        rUp = 0
                                    Else
                                        rUp = CDec(CType(r.FindControl("txtPrice"), TextBox).Text.Trim())
                                    End If
                                       
                                    Dim rQty As Integer = 1
                                    Dim tbQty As String = CType(r.FindControl("txtQty"), TextBox).Text.Trim()
                                    If Integer.TryParse(tbQty, 0) AndAlso Integer.Parse(tbQty) > 0 Then
                                        rQty = Integer.Parse(tbQty)
                                    End If
                                    Dim rDueDate As DateTime = CDate(CType(r.FindControl("txtDueDate"), TextBox).Text.Trim())
                                    Dim _Description As String = r.Cells(4).Text.Trim
                                    'lbMsg.Text = r.Cells(13).Text.Trim.ToString
                                    'Exit Sub
                                    Dim rDataKey As Integer = CInt(r.Cells(13).Text.Trim.ToString) 'gvItems.DataKeys(r.RowIndex).Values(0).ToString                                 
                                    '    If i + 1 = 100 Then Exit For
                                    '    If CInt(dbUtil.dbExecuteScalar("MY", String.Format( _
                                    '    " select count(distinct a.part_no) from sap_product a inner join sap_product_org b  " + _
                                    '    " on a.part_no=b.part_no and b.org_id='{0}'  " + _
                                    '    " where a.part_no='{1}' and a.status in ('A','N','H','S5') ", _
                                    '    Session("org_id"), rPn.Replace("'", "''")))) = 1 Then
                                    '        OrderUtilities.CartLine_Add(strcartId, i + 1, rPn, rQty, rLp, rUp, 0)
                                    '        i += 1
                                    '    End If
                             
                                    If IsBtoOrder(rPn) Then
                                        Type_int = CartItemType.BtosParent
                                        '_higherLevel = MyCartX.getBtosParentLineNo(strcartId)
                                    End If
                                    If Type_int = CartItemType.BtosParent AndAlso Not IsBtoOrder(rPn) Then
                                        Type_int = CartItemType.BtosPart
                                    End If
                                    If Type_int = CartItemType.BtosParent Then
                                        _higherLevel = 0 : _ParentItemQty = rQty
                                    End If
                                    If Type_int = CartItemType.BtosPart Then
                                        _higherLevel = 100 : rQty = rQty * _ParentItemQty
                                    End If
                                    'If Type_int = CartItemType.BtosPart Then
                                    '    _isUpdatePrice = 0
                                    'End If
                                    If rPn.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) OrElse String.Equals(rPn.Trim, "T", StringComparison.CurrentCultureIgnoreCase) Then
                                        Continue For
                                    End If
                                    
                                    'Dim line_no As Integer = mycart.ADD2CART_V2(strcartId, rPn, rQty, 0, Type_int, "", _isUpdatePrice, 0, rDueDate, _Description, "", _higherLevel, False)
                                    Dim line_no As Integer = MyCartOrderBizDAL.Add2Cart_BIZ(strcartId, rPn, rQty, 0, Type_int, "", _isUpdatePrice, 0, rDueDate, _Description, "", _higherLevel, False)
                                    
                                    ' mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", strcartId, line_no), String.Format("list_price='{0}',unit_price='{1}'", rLp, rUp))
                                    If Decimal.TryParse(rUp, 0) AndAlso Decimal.Parse(rUp) > 0 AndAlso Type_int = CartItemType.Part Then
                                        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", strcartId, line_no), String.Format("unit_price='{0}'", rUp))
                                    End If
                                    'If Not Type_int = CartItemType.Part Then
                                    '    'If InStr(rPn, "AGS-EW") > 0 Then
                                    '    '    mycart.Update(String.Format("cart_id='{0}'", strcartId), String.Format("ew_flag='{0}'", Glob.getMonthByEWItem(rPn)))
                                    '    'Else

                                    '    'End If
                                    'Else
                                    '    If OrderUtilities.Add2CartCheck(rPn, QuoteToERPId) Or InStr(rPn, "AGS-EW") > 0 Then
                                    '        If InStr(rPn, "AGS-EW") > 0 Then
                                    '            mycart.Update(String.Format("cart_id='{0}' and line_no ={1}-1", strcartId, Integer.Parse(rDataKey)), String.Format("ew_flag='{0}'", Glob.getMonthByEWItem(rPn)))
                                    '        Else
                                    '            Dim line_no As Integer = mycart.ADD2CART_V2(strcartId, rPn, rQty, 0, 0, "", 0, 1, rDueDate, "", "", 0, False)
                                    '            mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", strcartId, line_no), String.Format("list_price='{0}',unit_price='{1}'", rLp, rUp))
                                    '        End If
                                    '    End If
                                    'End If
                                    
                                    
                                    '''''''end  
                                End If
                            End If
                        Next
                        Dim _CartMaster As New CartMaster
                        _CartMaster.CartID = strcartId
                        _CartMaster.ErpID = QuoteToERPId
                        _CartMaster.CreatedDate = Now
                        _CartMaster.QuoteID = qid
                        _CartMaster.Currency = Session("COMPANY_CURRENCY")
                        _CartMaster.CreatedBy = Session("user_id")
                        _CartMaster.LastUpdatedDate = Now
                        _CartMaster.LastUpdatedBy = Session("user_id")
                        If qmDt.Rows(0).Item("OPTY_ID").ToString <> "" Then
                            Session("OptyId") = qmDt.Rows(0).Item("OPTY_ID").ToString
                            _CartMaster.OpportunityID = qmDt.Rows(0).Item("OPTY_ID").ToString
                        End If
                        MyCartX.LogCartMaster(_CartMaster)
                        'Response.Redirect("/Order/Cart_List.aspx")
                        Dim dtsalecode As DataTable = SAPDOC.GetKeyInPersonV2(Session("user_id").ToString.Trim)
                        If dtsalecode.Rows.Count > 0 Then
                            For Each r As DataRow In dtsalecode.Rows
                                If r.Item("SALES_CODE") IsNot Nothing AndAlso Not String.IsNullOrEmpty(r.Item("SALES_CODE")) Then
                                    txtERE.Text = r.Item("SALES_CODE").ToString.Trim
                                    Exit For
                                End If
                            Next
                        End If
                        'Response.Redirect(String.Format("~/Order/OrderInfoV2.aspx?PAR1={0}", txtERE.Text.Trim))
                        Response.Redirect("~/Order/Cart_ListV2.aspx")
                    Else
                        lbPOPMsg.Text = "ERPID is not correctly maintained for this quote-to account in SIEBEL"
                    End If
                Else
                    lbPOPMsg.Text = "ERPID is not maintained for this quote-to account in SIEBEL"
                End If
            End If
        End If
    End Sub
    Public Function Add2CartCheck(ByVal part_no As String, ByVal QuoteToERPId As String) As Boolean
        Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select a.PART_NO, a.PRODUCT_STATUS  from SAP_PRODUCT_STATUS a inner join SAP_DIMCOMPANY b on a.SALES_ORG=b.ORG_ID  where a.PART_NO='{1}' and b.COMPANY_ID='{0}' and a.PRODUCT_STATUS in ('A','N','H','M1')", QuoteToERPId, part_no))
        If fdt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Protected Sub pickERE_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Me.ascxPickERE.ShowData("")
        Me.UPPickERE.Update()
        Me.MPPickERE.Show()
    End Sub
    
    Public Sub PickEREEnd(ByVal str As Object)
        Dim KEY As String = str.ToString
        Me.txtERE.Text = KEY
        Me.UPPickFm.Update()
        Me.MPPickERE.Hide()
    End Sub

    Protected Sub txtQty_TextChanged(sender As Object, e As System.EventArgs)
        Dim t As TextBox = CType(sender, TextBox)
        
        Dim drv As GridViewRow = CType(t.NamingContainer, GridViewRow)
        Dim rowIndex As Integer = drv.RowIndex
        
        Dim partNo As String = CType(gvItems.Rows(rowIndex).FindControl("txtRowPN"), TextBox).Text

        'JJ 2014/3/19：判斷是不是parent part no
        Dim checkPN As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select count(material_group) from sap_product where part_no='{0}' and material_group in ('BTOS','CTOS')", partNo))
        
        'JJ 2014/3/19：大於0就是parent part no，但數量必須不為空白
        If checkPN.Rows(0)(0) > 0 AndAlso t.Text <> "" Then
            If t.Text <> "" Then
                hf_qty.Value = t.Text
            End If
            
            Dim dt As DataTable = GetQuoteLines(hd_Qid.Value)
            
            Dim rint As Integer = 0
            For Each r As GridViewRow In gvItems.Rows
                
                If r.RowType = Web.UI.WebControls.DataControlRowType.DataRow Then
                    If Not CType(r.Cells(2).FindControl("txtRowPN"), TextBox).Text = CType(drv.Cells(2).FindControl("txtRowPN"), TextBox).Text Then
                        'CType(r.Cells(7).FindControl("txtQty"), TextBox).Text = CStr(CType(CType(r.Cells(7).FindControl("txtQty"), TextBox).Text, Integer) * t1)
                        CType(r.Cells(7).FindControl("txtQty"), TextBox).Text = CStr(CType(dt.Rows(rint)(7), Integer) * CInt(hf_qty.Value))
                    End If
                    rint += 1
                End If
            Next
            
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server"> 
    <script type="text/javascript">
        function ShowQuoteDiv() {
            var divEC = document.getElementById('div_AllQuote');
            var divECData = document.getElementById('div_AllQuoteData');
            var qQName = document.getElementById('txtQName').value;
            var qAccName = document.getElementById('txtQAcc').value;
            divEC.style.display = 'block';
            divECData.innerHTML = "<center><img src='/Images/loading2.gif' alt='Loading...' width='35' height='35' />Loading SIEBEL Quotation...</center> ";
            PageMethods.GetSIEBELQuotes(qQName, qAccName,
                function (pagedResult, eleid, methodName) {
                    divECData.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    divECData.innerHTML = "";
                });
        }
        function DivOffOrOn(id) {
            var div = document.getElementById(id);
            if (div.style.display == 'block') { div.style.display = 'none'; } else { div.style.display = 'block'; }
        }
        function checkdate(id, Maximum) {
            var id = document.getElementById("ctl00__main_" + id);
            if (id.value.length > Maximum) {
                alert('More than ' + Maximum + ' characters')
                id.focus()
                return false
            }
            else {
                return true
            }
        }
        function setDueDate() {
            var ii = "00";
            var obj1 = document.getElementById('<%=Me.txtDueDate1.ClientID%>')
            if (obj1.value == '') { return; }
            for (i = 2; i <= 99; i++) {
                if (i < 10) { ii = "0" + i; }
                else { ii = i; }
                var obj = document.getElementById("ctl00__main_gvItems_ctl" + ii + "_txtDueDate");
                if (obj == null) { return; }
                obj.value = obj1.value;
            }
        }
        function setQty() {
            var ii = "00";
            var obj1 = document.getElementById('<%=Me.txtQty1.ClientID%>')
            if (obj1.value == '') { return; }
            for (i = 2; i <= 99; i++) {
                if (i < 10) { ii = "0" + i; }
                else { ii = i; }
                var obj = document.getElementById("ctl00__main_gvItems_ctl" + ii + "_txtQty");
                if (obj == null) { return; }
                obj.value = obj1.value;
            }
        }
        function calendarShown(sender, args) {
            sender._popupBehavior._element.style.zIndex = 1100000;
        } 
    </script>   
    <asp:HiddenField runat="server" ID="hd_Qid" />
    <table width="100%">
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td><asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" /></td>
                    </tr>
                    <tr>
                        <th align='left' style="color:#658AC3">
                            Quotation <asp:Label runat="server" ID="lbPickedQuoteName" Font-Bold="true" ForeColor="Navy" />&nbsp;
                            <input type="image" src="../images/pickPick.gif" 
                                style="border-width:0px;" onclick="ShowQuoteDiv(); return false;" width="18" height="18" />
                            <div id="div_AllQuote" style="display:none; position:absolute; 
                                background-color:white;border: solid 1px silver;padding:10px; 
                                width:650px; height:200px;overflow:auto;">
                                <table width="100%">
                                    <tr valign="top">
                                        <td>Quotation Name:</td>
                                        <td><input type="text" id="txtQName" /></td>
                                        <td>Account Name:</td>
                                        <td><input type="text" id="txtQAcc" /></td>
                                        <td>
                                            <input type="button" id="btnQueryQuote" value="Query" 
                                                onclick='ShowQuoteDiv(); return false;'/>
                                        </td>
                                        <td align="right">
                                            <a href="javascript:void(0)" onclick="javascript:document.getElementById('div_AllQuote').style.display='none';">Close</a>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td colspan="4" id='div_AllQuoteData'></td>
                                    </tr>
                                </table>
                            </div> 
                        </th>
                    </tr>
                    <tr><td><hr /></td></tr>
                    <tr>
                        <td>
                            <table width="100%" style="border-color:Gray">
                                <tr>
                                    <th align="left">Quote #:</th>
                                    <td><asp:Label runat="server" ID="lbQuoteNum" /></td>
                                    <th align="left">Account:</th>
                                    <td><asp:Label runat="server" ID="lbAccount" /></td>
                                    <th align="left">Account's ERPID:</th>
                                    <td><asp:Label runat="server" ID="lbERPID" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Name:</th>
                                    <td><asp:Label runat="server" ID="lbQuoteName" /></td>
                                    <th align="left">Status:</th>
                                    <td><asp:Label runat="server" ID="lbQuoteStatus" /></td>
                                    <th align="left">Currency:</th>
                                    <td><asp:Label runat="server" ID="lbCurr" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Last Name:</th>
                                    <td><asp:Label runat="server" ID="lbLstName" /></td>
                                    <th align="left">First Name:</th>
                                    <td><asp:Label runat="server" ID="lbFstName" /></td>
                                    <th align="left">Effective:</th>
                                    <td><asp:Label runat="server" ID="lbEffDate" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Opportunity:</th>
                                    <td><asp:Label runat="server" ID="lbOptyName" /></td>
                                    <th align="left">Sales Rep:</th>
                                    <td><asp:Label runat="server" ID="lbSalesRep" /></td>
                                    <th align="left">Due:</th>
                                    <td><asp:Label runat="server" ID="lbDue" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Total:</th>
                                    <td><asp:Label runat="server" ID="lbTotal" /></td>
                                    <th align="left"></th>
                                    <td></td>
                                    <th align="left"></th>
                                    <td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr><td style="height:10px">&nbsp;</td></tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <th align='left' style="color:#658AC3">Line Items</th>
                    </tr>
                    <tr><td><hr /></td></tr>
                    <tr style="display:none;"><td align="right">
                    <ajaxToolkit:CalendarExtender TargetControlID="txtDueDate1"  CssClass="MyCalendar" runat="server" Format="yyyy/MM/dd" ID="gcalDate1" />
                    <asp:TextBox runat="server" ID="txtQty1"></asp:TextBox> <input id="btnQty" type="button" onclick="setQty()" value="set Qty"/>
                    <asp:TextBox runat="server" ID="txtDueDate1"></asp:TextBox> <input id="btnDueDate" type="button" onclick="setDueDate()" value="set DueDate"/>
                    </td></tr>
                    <tr>
                        <td>
                            <table style="width:100%">                                                            
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gvItems" Width="100%" 
                                            AutoGenerateColumns="false" OnPageIndexChanging="gvItems_PageIndexChanging" 
                                            OnRowUpdating="gvItems_RowUpdating" OnSorting="gvItems_Sorting" 
                                            OnRowDataBound="gvItems_RowDataBound" OnRowEditing="gvItems_RowEditing"  DataKeyNames="LN_NUM"
                                            DataSourceID="src1">
                                            <Columns>
                                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                    <headertemplate>
                                                        No.
                                                    </headertemplate>
                                                    <itemtemplate>
                                                        <%# Container.DataItemIndex + 1 %>
                                                    </itemtemplate>

<ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                    <headertemplate>
                                                        <asp:CheckBox ID="all" runat="server" Checked="true" />
                                                    </headertemplate>
                                                    <itemtemplate>                                                                
                                                        <asp:CheckBox ID="item" runat="server" Checked="true" />                                                              
                                                    </itemtemplate>

<ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Product">
                                                    <ItemTemplate>
                                                        <asp:TextBox runat="server" ID="txtRowPN" Text='<%#Eval("PART_NO") %>' />
                                                        <asp:Literal ID="Literal_err" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateField> 
                                                <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# ShowProdStatus(Eval("PART_NO"))%>
                                                    </ItemTemplate>

<ItemStyle HorizontalAlign="Center"></ItemStyle>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Description" DataField="DESC_TEXT" />
                                                <asp:BoundField HeaderText="Product(Rpt)" DataField="Product_Rpt" Visible="false"/>
                                                <asp:BoundField HeaderText="Description(Rpt)" DataField="Description_Rpt" Visible="false"/>
                                                <asp:BoundField HeaderText="Start Price" DataField="START_PRICE" 
                                                    ItemStyle-HorizontalAlign="Right" >
<ItemStyle HorizontalAlign="Right"></ItemStyle>
                                                </asp:BoundField>
                                                <asp:TemplateField HeaderText="Item Net Price" >
                                                <ItemTemplate>
                                                <ajaxToolkit:FilteredTextBoxExtender ID="FilteredTextBoxExtender1" TargetControlID="txtPrice" runat="server" FilterType="Numbers,Custom" ValidChars="."></ajaxToolkit:FilteredTextBoxExtender>
                                                <asp:TextBox runat="server" ID="txtPrice" Text='<%#Eval("DISCOUNT_PRICE") %>' Width="80" style="text-align :right"/>
                                                </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Discount" DataField="DISC" 
                                                    ItemStyle-HorizontalAlign="Center" Visible="false">

<ItemStyle HorizontalAlign="Center"></ItemStyle>
                                                </asp:BoundField>

                                                <asp:TemplateField HeaderText="Qty.">
                                                <ItemTemplate>
                                                <ajaxToolkit:FilteredTextBoxExtender ID="FilteredTextBoxExtender2" TargetControlID="txtQty" runat="server" FilterType="Numbers"></ajaxToolkit:FilteredTextBoxExtender>

                                                <asp:TextBox runat="server" ID="txtQty" Text='<%#Eval("QTY_REQ") %>' Width="50" 
                                                        style="text-align :right" />
                                                </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:BoundField HeaderText="Sub Total" DataField="" 
                                                    ItemStyle-HorizontalAlign="right">
                                               
<ItemStyle HorizontalAlign="Right"></ItemStyle>
                                                </asp:BoundField>
                                               
                                                <asp:TemplateField HeaderText="Due Date">
                                                <ItemTemplate>
                                                <asp:TextBox runat="server" ID="txtDueDate" OnClientShown="calendarShown" Text='<%#Eval("duedate") %>' Width="80" style="text-align :right"/>
                                                <ajaxToolkit:CalendarExtender TargetControlID="txtDueDate" runat="server" OnClientShown="calendarShown" Format="yyyy/MM/dd" ID="gcalDate" />
                                                </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="LN_NUM" DataField="LN_NUM" 
                                                    HeaderStyle-CssClass="displaynone"  ItemStyle-CssClass="displaynone"  >
<HeaderStyle CssClass="displaynone"></HeaderStyle>

<ItemStyle CssClass="displaynone"></ItemStyle>
                                                </asp:BoundField>
                                            </Columns>
                                     <%--       <CascadeCheckboxes>
                                                <sgv:CascadeCheckbox ChildCheckboxID="item" ParentCheckboxID="all" />
                                            </CascadeCheckboxes>
                                            <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="100%" TableWidth="100%" />--%>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:CRMAPPDB %>" />
                                    </td>
                                </tr>
                            </table>                             
                        </td>
                    </tr>
                    <tr>
                        <td><%# ShowProdStatus(Eval("PART_NO"))%><%--       <CascadeCheckboxes>
                                                <sgv:CascadeCheckbox ChildCheckboxID="item" ParentCheckboxID="all" />
                                            </CascadeCheckboxes>
                                            <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="100%" TableWidth="100%" />--%>
                                    <asp:Label runat="server" ID="lbPOPMsg" Font-Bold="true" ForeColor="Tomato" />
                            <%# ShowProdStatus(Eval("PART_NO"))%>
                        <br/>
                            <asp:Button runat="server" ID="btnQuote2Order" Text="Add to Cart" OnClick="btnQuote2Order_Click" />
                            <input type="button" id="cbtnDirect2SAP" value="Direct2SAP" onclick="DivOffOrOn('div_OrderInfo')" style="display:none;" />                                        
                            <uc1:ChangeCompany runat="server" ID="chgCompany" Visible="false" />
                            <div id="div_OrderInfo" style="display:none;">
                                <table>
                                    <tr align="left" valign="top">
                                        <td style="background-color:#FFFFFF">
                                           <div align="right"> Required Date:</div>
                                        </td>
                                        <td style="width:100px;height:10px;background-color:#FFFFFF" align="left">
                                            <ajaxToolkit:CalendarExtender TargetControlID="txtReqDate" runat="server" Format="yyyy/MM/dd" ID="calDate" />
                                            <asp:TextBox ID="txtReqDate" runat="server" MaxLength="20" Width="95px" />
                                           ( YYYY/ MM / DD )
                                        </td>
                                        <td style="background-color:#FFFFFF;height:66px">
                                            <div align="right"> External Notes:<br/>(Maximum 1000 Characters)</div>
                                        </td>
                                        <td style="background-color:#FFFFFF;height:66px" align="left">                                            
                                            <asp:TextBox ID="txtOrderNote" runat="server" TextMode="MultiLine" 
                                                onblur="return checkdate( 'txtOrderNote','1000')" Columns="50" 
                                                Rows="5" MaxLength="28" />
                                        </td>
                                        <td style="background-color:#FFFFFF;height:66px">
                                            <div align="right"> Sales Notes:<br>(Maximum 300 Characters)</div>
                                        </td>
                                        <td style="background-color:#FFFFFF;height:66px" align="left">                                       
                                            <asp:TextBox ID="txtSalesNote" runat="server" TextMode="MultiLine" 
                                                onblur="return checkdate( 'txtSalesNote','300')" Columns="50" 
                                                Rows="5" MaxLength="28" />
                                        </td>
                                    </tr>
                                </table>
                                <asp:Button runat="server" ID="btnConfirmOrder" text="Convert to Order in SAP" Enabled="true" OnClick="btnConfirmOrder_Click" />&nbsp;
                                <asp:UpdatePanel runat="server" ID="upOrderMsg" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Label runat="server" ID="lbOrderMsg" ForeColor="Tomato" Font-Bold="true" Font-Size="Larger" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnConfirmOrder" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>                                
                                <input type="button" id="cbtnClose" value="Close" onclick="DivOffOrOn('div_OrderInfo')" style="display:none;"/>
                            </div>
                        </td>
                    </tr>    
                </table>
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="HiddenField1" runat="server" />   
    <asp:HiddenField ID="hf_qty" runat="server" />
    <ajaxToolkit:ModalPopupExtender ID="ModalPopupExtender1" runat="server" PopupControlID="Panel1" 
    TargetControlID="HiddenField1" BackgroundCssClass="modalBackground" CancelControlID="HiddenField1" BehaviorID="Panel1">   
    </ajaxToolkit:ModalPopupExtender>
    <asp:Panel ID="Panel1" runat="server" CssClass="modalPopup" style="display:none;width:400px;">  
        <asp:UpdatePanel ID="UPPickFm" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <table width="100%" border="0" align="center" cellspacing="2" cellpadding="2">
                              <tr>
                                <td></td>
                                <td align="right">【<a href="#" onclick="return closepanel('Panel1');">Close</a>】</td>
                              </tr>
                              <tr>
                                <td align="right" width="40%"><strong>ER Employee :</strong></td>
                                <td align="left">
                                    <asp:TextBox ID="txtERE" runat="server"></asp:TextBox>
                                    <asp:ImageButton ID="pickERE" runat="server" ImageUrl="~/images/pickPick.gif" OnClick="pickERE_Click" />
                                    <ajaxtoolkit:filteredtextboxextender runat="server" id="ft1" targetcontrolid="txtERE" filtertype="Numbers, Custom" />
                                </td>
                              </tr>
                              <tr>
                                <td height="30"></td>
                                <td align="left">
                                    <asp:Button ID="btnQuote2Ordernew" runat="server" Text="Confirm" OnClientClick="return checkPar();" OnClick="btnQuote2Ordernew_Click" />
                                </td>                 
                              </tr>
                              <tr>
                                <td height="30" colspan="2"></td>
                              </tr>
                            </table>    
            </ContentTemplate>
        </asp:UpdatePanel>       
                      
    </asp:Panel>
    <asp:LinkButton ID="lbDummyERE" runat="server"></asp:LinkButton>
    <ajaxtoolkit:modalpopupextender id="MPPickERE" runat="server" targetcontrolid="lbDummyERE"
        popupcontrolid="PLPickERE" backgroundcssclass="modalBackground" cancelcontrolid="CancelButtonERE"
        dropshadow="true" />
        <asp:Panel ID="PLPickERE" runat="server" Style="display: none" CssClass="modalPopup">
        <div style="text-align: right;">
            <asp:LinkButton ID="CancelButtonERE" runat="server" Text="Close" />
        </div>
        <div>
            <asp:UpdatePanel ID="UPPickERE" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <uc2:ERE ID="ascxPickERE" runat="server" />
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </asp:Panel>
      <script language="javascript" type="text/javascript">
          function openpanel(panel_id) {
              $find(panel_id).show();
              return false;
          }
          function closepanel(panel_id) {
              $find(panel_id).hide();
              return false;
          }
          function checkPar() {
              var par1 = document.getElementById("<%=txtERE.ClientID %>");
              if (par1.value == '') {
                  par1.style.backgroundColor = "#ff0000";
                  return false;
              }
          }
    </script>


</asp:Content>