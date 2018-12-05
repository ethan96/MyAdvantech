Imports Microsoft.VisualBasic
Imports InterConPrjReg

Public Class InterConPrjRegUtil
    Public Enum Prj_Status
        Request = 0
        Approve = 1
        Reject = 2
        Approve2 = 3
        Reject2 = 4
        WON = 5
        LOST = 6
        Delete = 7
    End Enum
    Public Shared Function IsEquals(ByVal str1 As String, ByVal str2 As String) As Boolean
        str1 = str1.Trim : str2 = str2.Trim
        If str1.Equals(str2, StringComparison.OrdinalIgnoreCase) Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetProductsHtml(ByVal prjid As String) As String
        Dim pageHolder As New TBBasePage() : pageHolder.IsVerifyRender = False : Dim ProductGv As New GridView
        Dim ProdGv As New GridView
        With pageHolder.Controls
            .Add(New LiteralControl("Product(s) Information :"))
            .Add(ProductGv)
        End With
        ProductGv.DataSource = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select PART_NO,QTY,remark,SELLINGPRICE,STANDARDPRICE,REQUESTPRICE,LAST_UPD_BY,LAST_UPD_DATE from  MY_PRJ_REG_PRODUCTS where PRJ_ROW_ID ='{0}' order by LINE_NO ", prjid))
        ProductGv.DataBind()
        Dim output As New IO.StringWriter()
        HttpContext.Current.Server.Execute(pageHolder, output, False)
        Return output.ToString.Trim
    End Function
    Public Shared Function GetCurrencySign(Optional ByVal Curr As String = "") As String
        If Not String.IsNullOrEmpty(Curr) Then
            Return Util.GET_CurrSign_By_Curr(Curr)
        End If
        If HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") IsNot Nothing AndAlso HttpContext.Current.Session("COMPANY_CURRENCY_SIGN").ToString.Trim <> "" Then
            Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN").ToString.Trim + " "
        End If
        Return ""
    End Function

    Public Shared Function AddProject(ByRef PrjMaster As MY_PRJ_REG_MASTERDataTable, _
                                      ByRef PrjContact As MY_PRJ_REG_CONTACTSDataTable, _
                                      ByRef PrjProd As MY_PRJ_REG_PRODUCTSDataTable, _
                                      ByRef PrjCompetitor As MY_PRJ_REG_COMPETITORSDataTable, _
                                      ByRef PrjSchedule As MY_PRJ_REG_PRODUCT_SCHEDULESDataTable, ByVal PrimarySalesEmail As String, _
                                      ByVal Status As Integer) As String
        If PrjMaster.Rows.Count <> 1 Then Return ""
        Dim rid As String = NewRowId("MY_PRJ_REG_MASTER", "MyLocal")
        CType(PrjMaster.Rows(0), MY_PRJ_REG_MASTERRow).ROW_ID = rid
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        conn.Open()
        Dim bk As New SqlClient.SqlBulkCopy(conn)
        bk.DestinationTableName = "MY_PRJ_REG_MASTER" : bk.WriteToServer(PrjMaster)
        For Each r As MY_PRJ_REG_CONTACTSRow In PrjContact.Rows
            r.ROW_ID = NewRowId("MY_PRJ_REG_CONTACTS", "MyLocal") : r.PRJ_ROW_ID = rid
        Next
        For Each r As MY_PRJ_REG_PRODUCTSRow In PrjProd.Rows
            ' r.ROW_ID = NewRowId("MY_PRJ_REG_PRODUCTS", "MyLocal")
            r.PRJ_ROW_ID = rid
        Next
        For Each r As MY_PRJ_REG_COMPETITORSRow In PrjCompetitor.Rows
            r.ROW_ID = NewRowId("MY_PRJ_REG_COMPETITORS", "MyLocal") : r.PRJ_ROW_ID = rid
        Next
        For Each r As MY_PRJ_REG_PRODUCT_SCHEDULESRow In PrjSchedule.Rows
            r.ROW_ID = NewRowId("MY_PRJ_REG_PRODUCT_SCHEDULES", "MyLocal") ': r.PRJ_PROD_ROW_ID = rid
        Next
        Try
            bk.DestinationTableName = "MY_PRJ_REG_CONTACTS" : bk.WriteToServer(PrjContact)

            bk.DestinationTableName = "MY_PRJ_REG_COMPETITORS" : bk.WriteToServer(PrjCompetitor)
            bk.DestinationTableName = "MY_PRJ_REG_PRODUCT_SCHEDULES" : bk.WriteToServer(PrjSchedule)

            'ICC Add column mapping for dbo.MY_PRJ_REG_PRODUCTS
            bk.DestinationTableName = "MY_PRJ_REG_PRODUCTS"
            bk.ColumnMappings.Add("ROW_ID", "ROW_ID")
            bk.ColumnMappings.Add("PRJ_ROW_ID", "PRJ_ROW_ID")
            bk.ColumnMappings.Add("LINE_NO", "LINE_NO")
            bk.ColumnMappings.Add("PART_NO", "PART_NO")
            bk.ColumnMappings.Add("PRODUCT_NAME", "PRODUCT_NAME")
            bk.ColumnMappings.Add("QTY", "QTY")
            bk.ColumnMappings.Add("AMOUNT", "AMOUNT")
            bk.ColumnMappings.Add("REMARK", "REMARK")
            bk.ColumnMappings.Add("SELLINGPRICE", "SELLINGPRICE")
            bk.ColumnMappings.Add("REQUESTPRICE", "REQUESTPRICE")
            bk.ColumnMappings.Add("STANDARDPRICE", "STANDARDPRICE")
            bk.ColumnMappings.Add("CREATED_BY", "CREATED_BY")
            bk.ColumnMappings.Add("CREATED_DATE", "CREATED_DATE")
            bk.ColumnMappings.Add("LAST_UPD_BY", "LAST_UPD_BY")
            bk.ColumnMappings.Add("LAST_UPD_DATE", "LAST_UPD_DATE")
            bk.WriteToServer(PrjProd)

            'ICC 2016/5/19 Insert primary sales email to new table. This sales email is selected by CP sales
            dbUtil.dbExecuteNoQuery("MyLocal", String.Format(" Delete from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}'; Insert into MY_PRJ_REG_PRIMARY_SALES_EMAIL values ('{0}', '{1}', '{2}', GETDATE())", rid, PrimarySalesEmail, CType(PrjMaster.Rows(0), MY_PRJ_REG_MASTERRow).CREATED_BY))

        Catch ex As Exception
            rid = ""
        End Try
        If conn.State <> ConnectionState.Closed Then conn.Close()
        If rid <> "" Then
            If Status = 1 Then '1 means send to approve
                If Prj2Siebel(rid, PrimarySalesEmail).Trim() <> "" Then
                    CreateStatus(rid)
                    Sendmail(rid, "", 0, "", PrjProd)
                Else
                    'ICC 2016/5/23 If create Siebel opportunity failed return empty.
                    Return String.Empty
                    'ICC 2016/3/8 Do not sent duplicate email
                    'Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Create Opty Failed in US Prj RegId:" + rid, "Prj2Siebel2", True, "", "")
                End If
            ElseIf Status = 2 Then '2 means save for further edit
                CreateStatus(rid, -1) '-1 means save for further edit
            End If
        End If
        Return rid
    End Function
    Public Shared Function Prj2Siebel(ByVal rid As String, ByVal primarySalesEmail As String) As String
        'Dim msg As String = ""
        Dim AccountRowID As String = ""
        Dim ContactRowId As String = ""
        Dim strPosId As String = "", strOwner As String = ""
        Dim PrimaryUserid As String = ""
        Dim TOTALrevenue As String = "", org As String = HttpContext.Current.Session("RBU")
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim prjMasterRow As MY_PRJ_REG_MASTERRow = Prj_M_A.GetDataByRowID(rid).Rows(0)
        With prjMasterRow
            AccountRowID = .CP_ACCOUNT_ROW_ID
            ContactRowId = USPrjRegUtil.GetContactRowId(HttpContext.Current.User.Identity.Name)
            TOTALrevenue = .PRJ_TOTAL_AMT.ToString()
            Dim Returnint As Integer = USPrjRegUtil.Get_Owner_PosId(AccountRowID, strOwner, strPosId)
            PrimaryUserid = USPrjRegUtil.GetPrimaryUseridByEmal(HttpContext.Current.User.Identity.Name)
            Dim Curr As String = USPrjRegUtil.GetCurr(AccountRowID)
        End With

        'ICC 2016/4/11 Competitor text can also be updated by Siebel web service
        Dim Prj_R_Competitor As New InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter
        Dim prjCompetitorTable As MY_PRJ_REG_COMPETITORSDataTable = Prj_R_Competitor.GetListByPrjRowID(rid)
        Dim prjCompetitorRow As MY_PRJ_REG_COMPETITORSRow = Nothing
        If Not prjCompetitorTable Is Nothing AndAlso prjCompetitorTable.Rows.Count > 0 Then
            prjCompetitorRow = prjCompetitorTable.Rows(0)
        End If
        'ICC 2016/4/11 Products can also be updated by Siebel web service
        Dim Prj_R_Product As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
        Dim prjProductRow As MY_PRJ_REG_PRODUCTSRow = Prj_R_Product.GetDataByPRJ_ROW_ID(rid).Rows(0)

        'Dim ws As New aeu_eai2000.Siebel_WS
        'ws.Timeout = -1 : ws.UseDefaultCredentials = True
        Dim Account_ROW_ID As String = AccountRowID
        'Dim eCoveWs As New eCoverageWS.WSSiebel, res As eCoverageWS.RESULT = Nothing
        Try
            Dim prjname As String = prjMasterRow.PRJ_NAME, prjdesc As String = prjMasterRow.PRJ_DESC
            If prjMasterRow.PRJ_NAME.Length > 100 Then
                prjname = prjMasterRow.PRJ_NAME.Substring(0, 100)
            End If
            If prjMasterRow.PRJ_DESC.Length > 255 Then
                prjdesc = prjMasterRow.PRJ_DESC.Substring(0, 255)
            End If
            If Util.IsTesting() Then
                prjname = "TEST BY IT,Please ignore it" + Now.ToString("yyyymmddhhmmss")
                prjdesc = "TEST BY IT,Please ignore it"
            End If
            Dim retbool As Boolean = False, OptyId As String = String.Empty, ErrorStr As String = String.Empty
            'retbool = ws.ImportOpportunityV2(prjname, prjdesc, "", "", False, prjMasterRow.PRJ_EST_CLOSE_DATE, org, "", "", "", _
            '              InterConPrjRegUtil.GetTotalAmountByID(rid), "", "", prjMasterRow.PRJ_AMT_CURR, "Funnel Sales Methodology", "10% Validating", _
            '               prjMasterRow.CP_ACCOUNT_ROW_ID, "", "", strOwner, "", OptyId, ErrorStr)
            'HttpContext.Current.Response.Write(OptyId)
            'Exit Function

            'ICC 2016/3/8 Use new Siebel web service to create opportunity
            'Dim result As Tuple(Of Boolean, String) = _
            '    Advantech.Myadvantech.DataAccess.SiebelDAL.CreateSiebelOpty4PrjReg(AccountRowID, prjMasterRow.PRJ_EST_CLOSE_DATE.ToString("MM/dd/yyyy"), prjMasterRow.PRJ_AMT_CURR, prjname, InterConPrjRegUtil.GetTotalAmountByID(rid), ContactRowId, org, strOwner)

            'ICC 2016/4/11 Use new class to create opportunity for Siebel web service
            Dim pr As New Advantech.Myadvantech.DataAccess.ProjectRegistration()
            pr.Account_Row_ID = Account_ROW_ID
            pr.Project_Name = prjname
            pr.Close_Date = prjMasterRow.PRJ_EST_CLOSE_DATE.ToString("MM/dd/yyyy")
            pr.Currency = prjMasterRow.PRJ_AMT_CURR
            pr.Revenue = InterConPrjRegUtil.GetTotalAmountByID(rid)
            pr.Contact_Row_ID = ContactRowId
            pr.RBU = org
            pr.Owner_Email = primarySalesEmail 'ICC 2016/5/19 Change to Primary sales email
            pr.Description = prjMasterRow.PRJ_DESC

            If Not prjCompetitorRow Is Nothing Then
                pr.Competition = prjCompetitorRow.COMPETITOR_NAME
            End If

            If Not prjProductRow Is Nothing Then
                Dim ps As New List(Of Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct)
                Dim p As New Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct()
                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select count(a.PART_NO) "))
                    .AppendLine(String.Format(" from sap_product a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO  "))
                    .AppendLine(String.Format(" where a.PART_NO = '{0}' and b.ORG_ID='{1}' and c.PRODUCT_STATUS in ('A','N','H','O','M1') and c.DLV_PLANT='{2}H1' ", _
                                              prjProductRow.PART_NO, HttpContext.Current.Session("org_id").ToString(), Left(HttpContext.Current.Session("org_id"), 2)))
                End With
                Dim count As Integer = CType(dbUtil.dbExecuteScalar("MY", sb.ToString), Integer)
                If count > 0 Then
                    p.Main_Product = prjProductRow.PART_NO
                    p.Main_Product_Qty = prjProductRow.QTY
                    ps.Add(p)
                End If
                pr.Products = ps
            End If

            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.SiebelDAL.CreateSiebelOpty4PrjReg(pr)

            If result.Item1 = False Then
                Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", _
                               "Create Opty Failed in US Prj RegId:" + prjMasterRow.ROW_ID, "Siebel web service returned error message: " + result.Item2, True, "", "")
                Return String.Empty
            Else
                OptyId = result.Item2
            End If

            'ICC 2016/3/8 Create product forecast web service is not ready!
            'If retbool = False Then
            '    Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", _
            '                   "Create Opty Failed in US Prj RegId:" + prjMasterRow.ROW_ID, "eCoverage WS returned error message:" + ErrorStr, True, "", "")
            '    msg = " Sieble Create Opty Failed." : Return ""
            'Else
            '    '20111130 TC: Create product forecast after opty created successfully
            '    Dim Prj_Prod As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
            '    Dim prjProdDt As MY_PRJ_REG_PRODUCTSDataTable = Prj_Prod.GetDataByPRJ_ROW_ID(rid)
            '    If prjProdDt.Count > 0 Then
            '        Dim FcstProdDt As New DataTable("ProdForecast")
            '        FcstProdDt.Columns.Add("part_no") : FcstProdDt.Columns.Add("QTY", GetType(Double))
            '        For Each pr As MY_PRJ_REG_PRODUCTSRow In prjProdDt.Rows
            '            Dim fpr As DataRow = FcstProdDt.NewRow()
            '            fpr.Item("part_no") = pr.PART_NO : fpr.Item("QTY") = pr.QTY : FcstProdDt.Rows.Add(fpr)
            '        Next
            '        '20120807 Rudy: Pending 10 seconds to create product forecast
            '        Threading.Thread.Sleep(10000)
            '        ws.ImportOptyForecast(OptyId, FcstProdDt)
            '    End If

            'End If
            Prj_M_A.UpdateOptyID(OptyId, rid)
            Threading.Thread.Sleep(2000) : MYSIEBELDAL.SyncSiebelOpty(OptyId)
            Return OptyId
        Catch ex As Exception
            'If res IsNot Nothing Then ex.Data("eCoverageWSErr") = res.ERR_MSG
            'Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Create Opty Failed in US Prj RegId:" + rid, ex.ToString(), True, "", "")
            'msg = " Sieble Create Opty Failed."
            'Return ""
            Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", _
                               "Create Opty Failed in US Prj RegId:" + prjMasterRow.ROW_ID, "Error message: " + ex.ToString, True, "", "")
            Return String.Empty
        End Try
        Return String.Empty
    End Function
    Public Shared Function Sendmail(ByVal rid As String, Optional ByVal strSubject As String = "", Optional ByVal StatusNum As Integer = 0, Optional ByVal mailString As String = "", Optional ByVal products As MY_PRJ_REG_PRODUCTSDataTable = Nothing) As Integer
        Dim CPName As String = HttpContext.Current.Session("company_id")
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim R As MY_PRJ_REG_MASTERRow = Prj_M_A.GetDataByRowID(rid).Rows(0)
        'ICC 2016/5/19 Change to primarySalesEmail. GetPriSalesOwnerOfAccount(R.CP_ACCOUNT_ROW_ID)
        Dim obj As Object = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select top 1 ISNULL(PRIMARY_SALES_EMAIL,'') from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}' ", rid))
        Dim salesEmail As String = String.Empty

        If String.IsNullOrEmpty(obj) Then
            salesEmail = "MyAdvantech@advantech.com"
        Else
            salesEmail = obj.ToString
        End If
        Dim TOstr As String = "", CCstr As String = "", Receiver As String = ""
        Dim mailTitle As String = "A Project registration is applied by channel partner " + HttpContext.Current.User.Identity.Name + " (" + CPName + ")"
        If strSubject <> "" Then
            mailTitle = strSubject
        End If
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Dim Srow As MY_PRJ_REG_AUDITRow = Prj_S_A.GetByPRJ_ROW_ID(rid).Rows(0)
        Receiver = Util.GetNameVonEmail(salesEmail)
        If StatusNum = 0 OrElse StatusNum = -1 Then
            TOstr = salesEmail
            'ICC 2018/3/26 Remove CM team from CC list
            'CCstr = "ChannelManagement.ACL@advantech.com" 'ICC 2016/3/4 Add ChannelManagement.ACL group in CC list
            'Receiver = Util.GetNameVonEmail(salesEmail)
        ElseIf StatusNum = -2 Then
            TOstr = HttpContext.Current.User.Identity.Name
            Receiver = Util.GetNameVonEmail(HttpContext.Current.User.Identity.Name)
            Dim psales As String = GetPriSalesOwnerOfAccount(rid)
            'ICC 2018/3/26 Remove CM team from CC list
            'CCstr = "ChannelManagement.ACL@advantech.com"
            If Not String.IsNullOrEmpty(psales) Then CCstr += ("," + psales)
            If Not String.IsNullOrEmpty(R.CREATED_BY) Then CCstr += ("," + R.CREATED_BY)
        Else
            'TOstr = R.CREATED_BY
            'TOstr = salesEmail
            'ICC 2016/4/14 For approve and reject situation, will send mail to created
            If Not String.IsNullOrEmpty(R.CREATED_BY) AndAlso Util.IsValidEmailFormat(R.CREATED_BY) Then
                TOstr = R.CREATED_BY
                Receiver = Util.GetNameVonEmail(R.CREATED_BY)
            ElseIf Not String.IsNullOrEmpty(R.LAST_UPD_BY) AndAlso Util.IsValidEmailFormat(R.LAST_UPD_BY) Then
                TOstr = R.LAST_UPD_BY
                Receiver = Util.GetNameVonEmail(R.LAST_UPD_BY)
            Else
                TOstr = "MyAdvantech@advantech.com"
                Receiver = Util.GetNameVonEmail("MyAdvantech@advantech.com")
            End If
            'ICC 2018/3/26 Remove CM team from CC list
            CCstr = Srow.SALES_BY + "," + salesEmail 'ICC 2016/3/4 Add ChannelManagement.ACL group in CC list , ICC 2016/7/6 Add primary sales in CC list
            'Receiver = Util.GetNameVonEmail(R.CREATED_BY)
        End If
        Dim emailApprove As String = String.Empty
        Dim mailBody As New System.Text.StringBuilder
        With mailBody
            .AppendLine(String.Format("Dear {0},<br />", Receiver))
            .AppendLine(String.Format("  <br />"))
            If StatusNum = 2 Then
                .AppendLine(String.Format("""{2}"" is rejected by {0}, <br/>Reject comment: {1}  <br />", Srow.SALES_BY, Srow.REASONWONLOST, R.PRJ_NAME))
            ElseIf StatusNum = 1 Then
                .AppendLine(String.Format("""{2}"" is approved by {0} on {1}  <br /> comment: {3}  <br />", Srow.SALES_BY, Srow.SALES_APP_DATE, R.PRJ_NAME, Srow.REASONWONLOST))
            ElseIf StatusNum = -1 OrElse StatusNum = -2 Then
                .AppendLine(mailString + "<br />")
            ElseIf StatusNum = 7 Then
                .AppendLine(String.Format("""{2}"" is deleted by {0} on {1}  <br /> comment: {3}  <br />", Srow.SALES_BY, Srow.SALES_APP_DATE, R.PRJ_NAME, Srow.REASONWONLOST))
            Else
                .AppendLine(String.Format("""{2}"" is applied by {1}. <br />Customer ID: {0}  <br />", CPName, HttpContext.Current.User.Identity.Name, R.PRJ_NAME))
                emailApprove = "<h3>You can click here to approve or reject this project.</h3><p><a href='" + Util.GetRuntimeSiteUrl() + "/Lab/PrjDoApprove.aspx?UID=" + rid + "&Status=1'>Approve</a> | <a href='" + Util.GetRuntimeSiteUrl() + "/Lab/PrjDoApprove.aspx?UID=" + rid + "&Status=2'>Reject</a></p><br />"
            End If
            .AppendFormat("<h2>Customer Information</h2>Company name: {0}<br />Postal code: {1}<br />State: {2}<br />Country: {3}<br />Address: {4}<br />", R.ENDCUST_NAME, R.ENDCUST_POST_CODE, R.ENDCUST_STATE, R.ENDCUST_COUNTRY, R.ENDCUST_ADDR)
            .AppendFormat("<h2>Project Information</h2>Project name: {0}<br />Project description: {1}<br />Potential risk: {2}<br />Needed Advantech support: {3}<br /> Close date: {4}<br />", R.PRJ_NAME, R.PRJ_DESC, R.POTENTIAL_RISK, R.NEEDED_ADV_SUPPORT, R.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd"))
            If products IsNot Nothing AndAlso products.Rows.Count > 0 Then
                .AppendFormat("<h2>Product(s) Information</h2>")
                For Each pd As MY_PRJ_REG_PRODUCTSRow In products.Rows
                    .AppendFormat("Model No.: {0}. Qty: {1}. Remark: {2}. Selling price: {3} Request price: {4} Standard price: {5}<br />", pd.PART_NO, pd.QTY, pd.REMARK, pd.SELLINGPRICE, pd.REQUESTPRICE, pd.STANDARDPRICE)
                Next
                .Append("<br /><br />")
            End If
            .AppendLine(String.Format("{0}Please check the detail below:  <br />", emailApprove))
            .AppendLine(String.Format("<a href='" + Util.GetRuntimeSiteUrl() + "/My/InterCon/PrjDetail.aspx?ROW_ID={0}'>MyAdvantech Project Registration detail page</a><br />", rid))
            .AppendLine(String.Format("Thank you.  <br />"))
            .AppendLine(String.Format("Best Regards,  <br />"))
            .AppendLine(String.Format("<a href='mailto:MyAdvantech@advantech.com'>MyAdvantech IT Team</a>  <br />"))
        End With
        If Util.IsTesting() Then
            'ICC 2016/3/4 Change testing mail receivers and content
            'Util.SendEmail("ming.zhao@advantech.com.cn", "myadvantech@advantech.com", mailTitle, mailBody.ToString(), True, CCstr, "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn")
            mailTitle = mailTitle.Insert(0, "Testing mail - ")
            'ICC 2016/3/21 Cancel test email
            'mailBody.Insert(0, String.Format("To: {0} <br /> CC: {1} <br />", TOstr, CCstr))
            'Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", mailTitle, mailBody.ToString, True, String.Empty, String.Empty)
            'Return 1
        End If
        Util.SendEmail(TOstr, "myadvantech@advantech.com", mailTitle, mailBody.ToString(), True, CCstr, "MyAdvantech@advantech.com,ChannelManagement.ACL@advantech.com")
        Return 1
    End Function
    Public Shared Function SendUpdateMail(ByVal rid As String, ByVal strSubject As String, ByVal mailBody As String) As Integer
        Dim CPName As String = HttpContext.Current.Session("company_id")
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim R As MY_PRJ_REG_MASTERRow = Prj_M_A.GetDataByRowID(rid).Rows(0)
        Dim salesEmail As String = GetPriSalesOwnerOfAccount(R.ROW_ID) 'ICC 2016/5/19
        If salesEmail = String.Empty Then
            salesEmail = "MyAdvantech@advantech.com"
        End If
        Dim TOstr As String = "", CCstr As String = "", Receiver As String = ""
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Dim Srow As MY_PRJ_REG_AUDITRow = Prj_S_A.GetByPRJ_ROW_ID(rid).Rows(0)
        TOstr = salesEmail
        Receiver = Util.GetNameVonEmail(salesEmail)
        Dim name As String = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 ISNULL(ACCOUNT_NAME,'') from SIEBEL_ACCOUNT where ERP_ID = '{0}' order by account_Status ", R.CP_COMPANY_ID)).ToString
        Dim strMailBody As New System.Text.StringBuilder
        With strMailBody
            .AppendLine(String.Format("Dear {0},<br />", Receiver))
            .AppendLine(String.Format("  <br />"))
            .AppendFormat("CP name: {0} <br />ERP ID: {1} <br />Project Name: {2} <br />", name, R.CP_COMPANY_ID, R.PRJ_NAME)
            .AppendLine(mailBody)
            .AppendLine(String.Format("<br/>Please check the detail below:  <br />"))
            .AppendLine(String.Format("<a href='" + Util.GetRuntimeSiteUrl() + "/My/InterCon/PrjDetail.aspx?ROW_ID={0}'>MyAdvantech Project Registration detail page</a><br />", rid))
            .AppendLine(String.Format("Thank you.  <br />"))
            .AppendLine(String.Format("Best Regards,  <br />"))
            .AppendLine(String.Format("<a href='mailto:MyAdvantech@advantech.com'>MyAdvantech IT Team</a>  <br />"))
        End With
        If Util.IsTesting() Then
            strSubject = strSubject.Insert(0, "Testing mail - ")
            'ICC 2016/3/21 Cancel test email
            'Util.SendEmail("ming.zhao@advantech.com.cn", "myadvantech@advantech.com", strSubject, "TO:" + TOstr + "<hr/>" + strMailBody.ToString(), True, "", "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn")
            'Return 1
        End If
        Util.SendEmail(TOstr, "myadvantech@advantech.com", strSubject, strMailBody.ToString(), True, CCstr, "MyAdvantech@advantech.com,ChannelManagement.ACL@advantech.com")
        Return 1
    End Function

    Public Shared Function GetPriSalesOwnerOfAccount(ByVal rid As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select top 1 ISNULL(PRIMARY_SALES_EMAIL,'') from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}'", rid))
        If Not obj Is Nothing Then Return obj.ToString()

        'If account_row_id = "1-2TAAS7" Then Return "tc.chen@advantech.com.tw"
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        '    "select top 1 PRIMARY_SALES_EMAIL from SIEBEL_ACCOUNT where ROW_ID='{0}' and dbo.IsEmail(PRIMARY_SALES_EMAIL)=1 ", account_row_id))
        'If dt.Rows.Count = 1 Then
        '    Return dt.Rows(0).Item("PRIMARY_SALES_EMAIL")
        'End If
        Return String.Empty
    End Function

    Public Shared Function GetSalesOwnerDirectBoss(ByVal SalesEmail As String) As String
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
            "select top 1 PAR_EMAIL from SIEBEL_SALES_HIERARCHY where EMAIL ='{0}' and dbo.IsEmail(PAR_EMAIL)=1  and POSITION_TYPE='Channel Sales Rep' ", SalesEmail))
        If dt.Rows.Count = 1 Then
            Return dt.Rows(0).Item("PAR_EMAIL")
        Else
            dt = dbUtil.dbGetDataTable("MY", String.Format( _
            "select top 1 PAR_EMAIL from SIEBEL_SALES_HIERARCHY where EMAIL ='{0}' and dbo.IsEmail(PAR_EMAIL)=1 ", SalesEmail))
            If dt.Rows.Count = 1 Then
                Return dt.Rows(0).Item("PAR_EMAIL")
            End If
        End If
        Return String.Empty
    End Function

    Public Shared Function CreateStatus(ByVal rid As String, Optional status As Integer = 0) As Boolean
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Prj_S_A.DeleteQuery(rid)
        Prj_S_A.InsertQuery(NewRowId("MY_PRJ_REG_AUDIT", "MyLocal"), rid, status, "")
        Return True
    End Function
    Public Shared Function UpdateStatusForSale(ByVal rid As String, ByVal StatusNum As Integer) As Boolean
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        'Prj_S_A.UpdateForSales(StatusNum, HttpContext.Current.User.Identity.Name, Now(), rid)
        Return True
    End Function
    Public Shared Function UpdateStatusForManagement(ByVal rid As String, ByVal StatusNum As Integer) As Boolean
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Prj_S_A.UpdateForManagement(StatusNum, HttpContext.Current.User.Identity.Name, Now(), rid)
        Return True
    End Function

    Public Shared Function CreatePrjRegCourse(ByVal rid As String, ByVal stage As String, ByVal user As String) As Boolean
        Try
            Dim ID As String = NewRowId("MY_PRJ_REG_OPTY_COURSE", "MyLocal")
            dbUtil.dbExecuteNoQuery("MyLocal", String.Format(" INSERT INTO [MY_PRJ_REG_OPTY_COURSE] VALUES (N'{0}', N'{1}', N'{2}', N'{3}', N'{3}', GETDATE(), N'{3}', GETDATE()) ", ID, rid, stage, user))
        Catch ex As Exception
            Util.InsertMyErrLogV2(ex.ToString)
            Return False
        End Try
        Return True
    End Function

    Public Shared Function UpdatePrj(ByVal rid As String, ByVal closedate As DateTime, ByVal LAST_UPD_BY As String, ByVal LAST_UPD_DATE As DateTime) As Boolean
        Dim returnInt As Integer = dbUtil.dbExecuteNoQuery("MYLOCAL", "update MY_PRJ_REG_MASTER  set  PRJ_EST_CLOSE_DATE='" + closedate.ToString + "',LAST_UPD_BY='" + LAST_UPD_BY + "',LAST_UPD_DATE='" + LAST_UPD_DATE.ToString + "' where row_id ='" + rid + "'")
        If returnInt > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetTotalAmountByID(ByVal rid As String) As Decimal
        Return Decimal.Parse(dbUtil.dbExecuteScalar("MYLOCAL", "select  isnull(sum(STANDARDPRICE*qty),0)  as TotalAmount from  MY_PRJ_REG_PRODUCTS where prj_row_id ='" + rid + "'"))
    End Function
    Public Shared Function update_Siebel(ByVal rid As String, ByVal Stage As String, ByVal TotalAmount As Decimal, ByVal Primary_Position_ID As String, Optional ByVal Reject_Reason As String = "", Optional ByVal Close_Date As String = "", Optional ByVal competitor As String = "", Optional ByVal products As List(Of Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct) = Nothing) As Boolean
        Reject_Reason = ""
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim R As MY_PRJ_REG_MASTERRow = Prj_M_A.GetDataByRowID(rid).Rows(0)
        If R.PRJ_OPTY_ID = "" Then
            Return False
            Exit Function
        End If
        'Dim DESC_TEXT As String = ""
        'obj = dbUtil.dbExecuteScalar("CRMDB75", " select DESC_TEXT  from  S_OPTY WHERE ROW_ID = '" + M.Opty_Id + "' ")
        'If obj IsNot Nothing Then DESC_TEXT = obj.ToString()
        Try
            'Dim ws As New aeu_eai2000.Siebel_WS
            'ws.Timeout = -1 : ws.UseDefaultCredentials = True
            'ws.UpdateOpportunityStage_Proj(R.PRJ_OPTY_ID, R.CP_ACCOUNT_ROW_ID, Stage, R.PRJ_DESC, TotalAmount.ToString(), R.PRJ_EST_CLOSE_DATE, Reject_Reason)
            'ICC 2015/3/4 Use new Siebel web service to update opty
            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateSiebelOpty4PrjReg(R.PRJ_OPTY_ID, TotalAmount.ToString, Stage, String.Empty, Close_Date, "", "", "", competitor, products)
            If result.Item1 = False Then
                Dim para As New StringBuilder()
                para.AppendFormat("Row ID: {0} <br /> Opty ID: {1} <br /> Sales stage: {2} <br /> Revenue: {3} <br />", rid, R.PRJ_OPTY_ID, Stage, TotalAmount.ToString)
                para.AppendFormat("Error message: {0}", result.Item2)
                Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", "Update Siebel Opty for project registration failed", para.ToString, True, String.Empty, String.Empty)
            End If
            Return True
        Catch ex As Exception
            Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", _
                           String.Format("Update Opty to Siebel for OptyID:{0} by {1}", R.PRJ_OPTY_ID, HttpContext.Current.Session("user_id").ToString), ex.ToString(), True, "", "")
        End Try
        Return False
    End Function
    Public Shared Function NewRowId(ByVal table_name As String, ByVal connName As String) As String
        Dim tmpRowId As String = "", conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings(connName).ConnectionString)
        Dim cmd As New SqlClient.SqlCommand("", conn)
        conn.Open()
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            cmd.CommandText = "select count(*) as counts from " + table_name + " where ROW_ID='" + tmpRowId + "'"
            Dim retObj As Object = cmd.ExecuteScalar()
            If CInt(retObj) = 0 Then
                Exit Do
            End If
        Loop
        conn.Close()
        Return tmpRowId
    End Function
    Public Shared Function GetAccountRowIDbyName(ByVal companyname As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("CRMDB75", "select top 1  ROW_ID  from S_ORG_EXT  where Upper(NAME)= N'" + companyname.ToUpper().Replace("'", "''") + "'")
        If obj IsNot Nothing Then
            Return obj.ToString.Trim()
        End If
        Return ""
    End Function

    Public Shared Function AutoSuggestCustName(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 20 a.NAME, a.ROW_ID "))
            .AppendLine(String.Format(" from S_ORG_EXT a left join S_ADDR_ORG d on a.PR_ADDR_ID=d.ROW_ID "))
            .AppendLine(String.Format(" where a.PAR_OU_ID is not null "))  'and a.PAR_OU_ID in 
            '.AppendLine(String.Format(" ( "))
            '.AppendLine(String.Format(" 	select z.ROW_ID from S_ORG_EXT_X z where Upper(z.ATTRIB_05)=Upper('{0}') ", _
            '                          HttpContext.Current.Session("company_id").ToString.Replace("'", "").Trim().ToUpper()))
            '.AppendLine(String.Format(" ) "))
            If prefixText.Trim <> "" Then
                .AppendLine(String.Format(" and Upper(a.NAME) like N'%{0}%' ", prefixText.Trim.Replace("'", "''").ToUpper()))
            End If
            .AppendLine(String.Format(" order by a.NAME "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        Dim items As New List(Of String)
        If dt.Rows.Count > 0 Then
            'Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                'str(i) = dt.Rows(i).Item(0)
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dt.Rows(i).Item("NAME"), dt.Rows(i).Item("ROW_ID")))
            Next
            Return items.ToArray()
        End If
        Return Nothing
    End Function
    Public Shared Function AutoSuggestPN(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 20 a.PART_NO  "))
            .AppendLine(String.Format(" from sap_product a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO  "))
            .AppendLine(String.Format(" where a.PART_NO like '{0}%' and b.ORG_ID='{1}' and c.PRODUCT_STATUS in ('A','N','H','O','M1') and c.DLV_PLANT='{2}H1' ", _
                                      prefixText.Trim().Replace("'", "").Replace("*", "%"), HttpContext.Current.Session("org_id").ToString(), Left(HttpContext.Current.Session("org_id"), 2)))
            .AppendLine(String.Format(" order by a.PART_NO  "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    Public Shared Function GetPrice(ByVal pn As String) As Double
        Dim ws As New MYSAPDAL, strCompanyId As String = HttpContext.Current.Session("company_id"), strOrg As String = HttpContext.Current.Session("org_id")
        Dim pinTable As New SAPDALDS.ProductInDataTable, pOutTable As New SAPDALDS.ProductOutDataTable
        pinTable.AddProductInRow(pn, 1)
        If ws.GetPriceV2(strCompanyId, strCompanyId, strOrg, MYSAPDAL.SAPOrderType.ZOR, pinTable, pOutTable, "") AndAlso pOutTable.Count > 0 Then
            Return CDbl(pOutTable(0).UNIT_PRICE)
        Else
            Return -1
        End If
        'If pn.Trim() = "" OrElse HttpContext.Current.Session Is Nothing _
        '    OrElse HttpContext.Current.Session("company_id") Is Nothing _
        '    OrElse HttpContext.Current.Session("company_id").ToString() = "" Then Return 999999
        'pn = pn.Trim().Replace("'", "''").ToUpper()
        'Dim rp As Double = Util.GetSAPPrice(pn, HttpContext.Current.Session("company_id"))
        'Return rp
    End Function
    Public Shared Function GetAddrByCustRowId(ByVal rowid As String) As DataTable
        If rowid.Trim() = "" Then Return New DataTable("ACCOUNTADDR")
        rowid = rowid.Trim().Replace("'", "").ToUpper()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1 IsNull(d.ADDR,'') as ADDRESS,IsNull(d.ZIPCODE,'') as ZIPCODE,  "))
            .AppendLine(String.Format(" IsNull(d.STATE,'') as STATE,IsNull(d.COUNTRY,'') as COUNTRY "))
            .AppendLine(String.Format(" from S_ORG_EXT a left join S_ADDR_ORG d on a.PR_ADDR_ID=d.ROW_ID "))
            .AppendLine(String.Format(" where a.ROW_ID='{0}' ", rowid))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        dt.TableName = "ACCOUNTADDR"
        Return dt
    End Function

    Public Shared Function GetSimilarAccount(ByVal ENDCUST_NAME As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
            String.Format(" select top 20 ROW_ID, ACCOUNT_NAME, RBU, PRIMARY_SALES_EMAIL, ACCOUNT_STATUS, ADDRESS, COUNTRY " + _
                          " from SIEBEL_ACCOUNT " + _
                          " where dbo.CalcEditDistance(account_name,N'{0}')<=6 " + _
                          " order by dbo.CalcEditDistance(account_name,N'{0}')", Replace(ENDCUST_NAME, "'", "''")))
        Return dt
    End Function

    Public Shared Function GetSimilarOpty(ByVal PRJ_NAME As String, ByVal PrjOptyRowId As String, ByVal PrjRowId As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
        String.Format(" select top 10 a.ROW_ID as OPTY_ID, a.NAME, a.CREATED, a.CREATED_BY, a.SALES_TEAM_NAME, a.STAGE_NAME, a.SUM_WIN_PROB,  " + _
        " a.SUM_REVN_AMT, a.CURCY_CD, a.BU_NAME, b.ACCOUNT_NAME, a.ACCOUNT_ROW_ID, 0 as DIST " + _
        " from SIEBEL_OPPORTUNITY a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID  " + _
        " where a.ROW_ID<>'" + PrjOptyRowId + "' and dbo.CalcEditDistance(a.NAME,N'{0}')<=15 " + _
        " order by dbo.CalcEditDistance(a.NAME,N'{0}'), a.CREATED desc ", Replace(PRJ_NAME, "'", "''")))
        Dim Prj_Prod As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
        Dim prjProdDt As MY_PRJ_REG_PRODUCTSDataTable = Prj_Prod.GetDataByPRJ_ROW_ID(PrjRowId)
        If prjProdDt.Count > 0 Then
            For Each pr As MY_PRJ_REG_PRODUCTSRow In prjProdDt.Rows
                If pr.PART_NO IsNot Nothing AndAlso pr.PART_NO <> String.Empty Then
                    Dim pdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                     " select distinct top 5 a.ROW_ID as OPTY_ID, a.NAME, a.CREATED, a.CREATED_BY, a.SALES_TEAM_NAME, a.STAGE_NAME, a.SUM_WIN_PROB,   " + _
                     " a.SUM_REVN_AMT, a.CURCY_CD, a.BU_NAME, b.ACCOUNT_NAME, a.ACCOUNT_ROW_ID,  " + _
                     " dbo.CalcEditDistance(a.NAME,'{0}')+dbo.CalcEditDistance(c.PART_NO,'{0}') as DIST " + _
                     " from SIEBEL_OPPORTUNITY a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID inner join SIEBEL_PRODUCT_FORECAST c on a.ROW_ID=c.OPTY_ID   " + _
                     " where dbo.CalcEditDistance(a.NAME,'{0}')<=5 or dbo.CalcEditDistance(c.PART_NO,'{0}')<=5  " + _
                     " order by dbo.CalcEditDistance(a.NAME,'{0}')+dbo.CalcEditDistance(c.PART_NO,'{0}') ", Replace(pr.PART_NO, "'", "''")))
                    For Each pdtr As DataRow In pdt.Rows
                        If dt.Select("OPTY_ID='" + pdtr.Item("OPTY_ID") + "'").Length = 0 Then
                            dt.Rows.Add(pdtr.ItemArray) : dt.AcceptChanges()
                        End If
                    Next
                End If
            Next
        End If
        Return dt
    End Function

    Public Shared Function GetPrimarySalesEmail(ByVal ERP_ID As String) As DataTable
        Dim sb As New StringBuilder()
        sb.Append(" select distinct a.PRIMARY_FLAG, ISNULL(c.EMAIL_ADDR, '') as [EMAIL_ADDR], c.FIRST_NAME, c.LAST_NAME from SIEBEL_ACCOUNT_OWNER a (nolock) inner join SIEBEL_ACCOUNT b (nolock) ")
        sb.AppendFormat(" on a.ACCOUNT_ROW_ID=b.ROW_ID inner join SIEBEL_POSITION c on a.POSITION_ID=c.ROW_ID where b.ERP_ID = '{0}' ", ERP_ID)
        sb.Append(" and c.EMAIL_ADDR not in ('sieowner@advantech.com.tw') and dbo.IsEmail(c.EMAIL_ADDR)=1 and c.EMAIL_ADDR like '%@advantech%' ")
        sb.Append(" order by a.PRIMARY_FLAG desc, EMAIL_ADDR ")
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    'ICC 2016/5/30 By Candy's request. Scenario 1 is to check one user contact exists in two different accounts.
    Public Shared Function GetPrimarySalesEmailScenario1(ByVal email As String) As DataTable
        Dim sb As New StringBuilder()
        sb.Append(" select distinct sp.EMAIL_ADDR, sao.PRIMARY_FLAG from SIEBEL_CONTACT sc (nolock)  inner join SIEBEL_CONTACT_ACCOUNT sca (nolock) on sc.ROW_ID = sca.CONTACT_ROW_ID ")
        sb.Append(" inner join SIEBEL_ACCOUNT sa (nolock) on sca.ACCOUNT_ROW_ID = sa.ROW_ID inner join SIEBEL_ACCOUNT_OWNER sao (nolock) on sao.ACCOUNT_ROW_ID = sa.ROW_ID ")
        sb.AppendFormat(" inner join SIEBEL_POSITION sp (nolock) on sp.ROW_ID = sao.POSITION_ID where sc.EMAIL_ADDRESS = '{0}' ", email)
        sb.Append(" and sp.EMAIL_ADDR not in ('sieowner@advantech.com.tw') and dbo.IsEmail(sp.EMAIL_ADDR) = 1 and sp.EMAIL_ADDR like '%@advantech%' ")
        sb.Append(" and sp.EMAIL_ADDR is not null order by sao.PRIMARY_FLAG desc, sp.EMAIL_ADDR ")
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    'ICC 2016/5/30 By Candy's request. Scenario 2 is to check one user email exists in two different contacts.
    Public Shared Function GetPrimarySalesEmailScenario2(ByVal email As String) As DataTable
        Dim sb As New StringBuilder()
        sb.Append(" select distinct sp.EMAIL_ADDR, sao.PRIMARY_FLAG from SIEBEL_CONTACT sc (nolock) inner join SIEBEL_ACCOUNT sa (nolock) on sc.ACCOUNT_ROW_ID = sa.ROW_ID ")
        sb.Append(" inner join SIEBEL_ACCOUNT_OWNER sao (nolock) on sao.ACCOUNT_ROW_ID = sa.ROW_ID inner join SIEBEL_POSITION sp (nolock) on sao.POSITION_ID = sp.ROW_ID ")
        sb.AppendFormat(" where sc.EMAIL_ADDRESS = '{0}' and sp.EMAIL_ADDR not in ('sieowner@advantech.com.tw') and dbo.IsEmail(sp.EMAIL_ADDR) = 1 ", email)
        sb.Append(" and sp.EMAIL_ADDR like '%@advantech%' and sp.EMAIL_ADDR is not null order by sao.PRIMARY_FLAG desc ")
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function
End Class
