Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services
Imports Advantech.Myadvantech.Business

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")>
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)>
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Public Class BBorderAPI
    Inherits System.Web.Services.WebService

    <WebMethod(EnableSession:=True)>
    <System.Web.Script.Services.ScriptMethod(UseHttpGet:=True, ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Sub GetBBorder(ByVal Email As String, ByVal OrderNo As String, ByVal OrderStatus As String)
        Dim _val As String = Newtonsoft.Json.JsonConvert.SerializeObject(String.Empty)
        Dim orders As List(Of Advantech.Myadvantech.DataAccess.Entities.Order) = OrderBusinessLogic.GetBBordersList(Email, OrderNo, OrderStatus)
        If orders IsNot Nothing AndAlso orders.Count > 0 Then
            'ICC Set emergency shipping methods
            Dim emergencyshipment = New List(Of String)()
            emergencyshipment.Add("FedEx 2 Day®")
            emergencyshipment.Add("FedEx Standard Overnight®")
            emergencyshipment.Add("FedEx Priority Overnight®")
            emergencyshipment.Add("FedEx First Overnight®")
            emergencyshipment.Add("UPS Next Day Air®")
            emergencyshipment.Add("UPS Second Day Air®")
            emergencyshipment.Add("USPS Priority Mail®")

            Dim emergencyorders = New List(Of Advantech.Myadvantech.DataAccess.Entities.Order)()
            Dim normalorders = New List(Of Advantech.Myadvantech.DataAccess.Entities.Order)()
            For Each o In orders
                If Not String.IsNullOrEmpty(o.ShippingMethod) AndAlso emergencyshipment.Contains(o.ShippingMethod) Then
                    o.Emergency = True
                    emergencyorders.Add(o)
                Else
                    o.Emergency = False
                    normalorders.Add(o)
                End If
            Next
            emergencyorders.AddRange(normalorders.ToArray)

            Dim _order1 = emergencyorders.Select(Function(p) New With
                                                    {.OrderDate = p.OrderDate.Value.ToString("yyyy-MM-dd tt hh:mm:ss", System.Globalization.CultureInfo.InvariantCulture),
                                                     .OrderNo = p.OrderNo,
                                                     .UserID = p.UserID,
                                                     .SAPSyncStatus = IIf(String.IsNullOrEmpty(p.SAPSyncStatus), Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.NeedERPID.ToString(), p.SAPSyncStatus),
                                                     .ERPID = IIf(String.IsNullOrEmpty(p.SAPSyncBy), String.Empty, p.SAPSyncBy),
                                                     .Emergency = p.Emergency
                                                    })
            _val = Newtonsoft.Json.JsonConvert.SerializeObject(_order1)
        End If

        Context.Response.Clear()
        Context.Response.Write(_val)
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub CreateSAPOrderFromBBeStore(ByVal OrderNo As String)
        If Not String.IsNullOrEmpty(OrderNo) AndAlso Util.IsTesting() = False Then
            Dim order = OrderBusinessLogic.GetBBeStoreOrderByOrderNo(OrderNo)
            Dim record = OrderBusinessLogic.GetBBorderRecord(OrderNo)
            If order IsNot Nothing AndAlso record Is Nothing Then
                Dim status As Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus = Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.ReadyToSAP 'ICC 2018/8/13 Only use ReadyToSap status for BB order
                Dim customerID As String = String.Empty

                Dim shipto = order.Cart.ShipToContact
                If shipto IsNot Nothing AndAlso shipto.ToBeVerifiedShipToAddress = True Then status = Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.ToBeVerifiedShipToAddr

                Dim customer = Me.GetERPIDbyEmail(order.UserID)
                If customer IsNot Nothing AndAlso Not String.IsNullOrEmpty(customer.CustomerID) Then
                    customerID = customer.CustomerID
                Else
                    status = Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.NeedERPID
                End If

                Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBorderRecord(OrderNo, customerID, status)
                'If customer IsNot Nothing AndAlso Not String.IsNullOrEmpty(customer.CustomerID) Then
                '    Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBorderRecord(OrderNo, customer.CustomerID, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess)
                'Else
                '    Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBorderRecord(OrderNo, String.Empty, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.NeedERPID)
                'End If
            End If
        End If
        dbUtil.dbExecuteNoQuery("MY", String.Format("INSERT INTO BB_ESTORE_LOG VALUES ('CreateSAPOrderFromBBeStore', 'OrderNo: {0}', '{1}', '', GETDATE()) ", OrderNo, Util.IsTesting().ToString))
    End Sub

    <WebMethod(EnableSession:=True)>
    Function Process(ByVal OrderNo As String) As WebServiceResult
        Dim ret As WebServiceResult = New WebServiceResult()
        ret.OrderNo = OrderNo
        Dim eStoreOrder As Advantech.Myadvantech.DataAccess.Entities.Order = OrderBusinessLogic.GetBBeStoreOrderByOrderNo(OrderNo)

        If eStoreOrder Is Nothing Then
            ret.Result = False
            ret.Message = "eStore order not found."
        Else
            Dim customer = Me.GetERPIDbyEmail(eStoreOrder.UserID)
            If customer IsNot Nothing AndAlso Not String.IsNullOrEmpty(customer.CustomerID) Then
                Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.Business.OrderBusinessLogic.BBeStoreData2MyAdvantechTable(OrderNo, customer.CustomerID, Util.IsTesting)
                If result.Item1 = True Then
                    Dim au As AuthUtil = New AuthUtil()
                    au.ChangeCompanyId(customer.CustomerID)

                    ret.Result = SAPDOC.SOCreateV6(OrderNo, ret.Message, Util.IsTesting(), "")

                    If ret.Result = False Then
                        SAPDOC.SendFailedOrderMailForBBUS(OrderNo)
                        'ret.Message = "Sync order to SAP failed. Please refer to failed order mail."
                        Dim sb As StringBuilder = New StringBuilder("Sync order to SAP failed. Please refer to failed order mail and the following message.")
                        Dim msg As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select ISNULL([MESSAGE],'') AS MSG from ORDER_PROC_STATUS2 where ORDER_NO = '{0}' order by LINE_SEQ", OrderNo))
                        If msg IsNot Nothing AndAlso msg.Rows.Count > 0 Then
                            For Each dr As DataRow In msg.Rows
                                sb.Append(dr(0).ToString)
                            Next
                        End If
                        ret.Message = sb.ToString
                    Else
                        If AuthUtil.IsBBUS AndAlso Advantech.Myadvantech.Business.OrderBusinessLogic.IsCreditCardPayment(OrderNo) Then
                            Dim sno As String = Global_Inc.SONoBuildSAPFormat(OrderNo.Trim.ToUpper).ToString
                            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from BB_CREDITCARD_ORDER where ORDER_NO='{0}'", OrderNo))
                            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                                Dim cardNo As String = dt.Rows(0).Item("CARD_NO").ToString
                                Dim cardType As String = dt.Rows(0).Item("CARD_TYPE").ToString
                                Dim authCode As String = dt.Rows(0).Item("AUTH_CODE").ToString
                                Dim transID As String = dt.Rows(0).Item("TRANSACTION_ID").ToString
                                Dim amount As Decimal = 0
                                If Not IsDBNull(dt.Rows(0).Item("TOTAL_AUTH_AMOUNT")) Then
                                    Decimal.TryParse(dt.Rows(0).Item("TOTAL_AUTH_AMOUNT").ToString, amount)
                                End If
                                If Not String.IsNullOrEmpty(cardNo) AndAlso Not String.IsNullOrEmpty(cardType) AndAlso Not String.IsNullOrEmpty(authCode) _
                                    AndAlso Not String.IsNullOrEmpty(transID) AndAlso amount > 0 Then
                                    Advantech.Myadvantech.Business.OrderBusinessLogic.AddCreditCardInfo2SAPSO(sno, authCode, transID, cardType, cardNo, amount, Util.IsTesting())
                                End If
                            End If
                            Advantech.Myadvantech.Business.OrderBusinessLogic.UnblockSOCreditCard(OrderNo, Util.IsTesting())
                        End If
                        SAPDOC.SendPI(OrderNo, False)
                    End If

                Else
                    ret.Result = False
                    ret.Message = "Convert data from eStore to MyAdvantech failed. Message: " + result.Item2
                End If
            Else
                ret.Result = False
                ret.Message = "Need ERP ID"
            End If

        End If
        Return ret
    End Function

    <WebMethod(EnableSession:=True)>
    Public Function GetERPIDbyEmail(ByVal userID As String) As Advantech.Myadvantech.DataAccess.BBCustomer
        'Dim cs As String = "SAP_PRD"
        'If Util.IsTesting() = True Then cs = "SAP_Test"
        'Dim dt As DataTable = OraDbUtil.dbGetDataTable(cs, String.Format("select a.kunnr from saprdp.kna1 a inner join saprdp.knvk b on a.kunnr = b.kunnr inner join saprdp.adr6 c on b.prsnr = c.persnumber where a.mandt = '168' and b.mandt='168' and (UPPER(c.smtp_addr) = '{0}' or LOWER(c.smtp_addr) = '{1}') order by a.kunnr", userID.ToUpper(), userID.ToLower()))
        'If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
        '    Dim list As New List(Of Customer)()
        '    For Each dr As DataRow In dt.Rows
        '        list.Add(New Customer(dr.Item(0).ToString().Trim().ToUpper()))
        '    Next
        '    Return list
        'End If
        If Not String.IsNullOrEmpty(userID) Then
            Dim cust = GetBBcustomerByUserID(userID)
            If cust IsNot Nothing AndAlso Not String.IsNullOrEmpty(cust.CustomerID) Then cust.IncotermText = Me.GetIncotermTextByERPID(cust.CustomerID, cust.OrgID)
            Return cust
        Else
            Return Nothing
        End If

    End Function

    <WebMethod(EnableSession:=True)>
    Public Function GetBBcustomerByUserID(ByVal userID As String) As Advantech.Myadvantech.DataAccess.BBCustomer
        If Not String.IsNullOrEmpty(userID) Then
            Dim cust = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getBBcustomerByUserID(userID)
            If cust IsNot Nothing Then
                Return cust
            End If
        End If
        Return Nothing

    End Function

    <WebMethod(EnableSession:=True)>
    Public Function GetIncotermTextByERPID(ByVal ERPID As String, ByVal ORGID As String) As String

        If Not String.IsNullOrEmpty(ERPID) AndAlso Not String.IsNullOrEmpty(ORGID) Then
            Dim objIncoText As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 INCO2 from SAP_DIMCOMPANY where COMPANY_ID = '{0}' and ORG_ID = '{1}'", ERPID, ORGID))
            If objIncoText IsNot Nothing AndAlso Not String.IsNullOrEmpty(objIncoText.ToString) AndAlso Not objIncoText.ToString.Equals("Ottawa IL", StringComparison.OrdinalIgnoreCase) AndAlso objIncoText.ToString.Length >= 6 Then
                Return objIncoText.ToString
            End If
        End If

        Return String.Empty

    End Function

    <WebMethod(EnableSession:=True)>
    Public Sub AutoMaticallyTransfereStoreOrderToSAP()

        Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
        Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)
        Dim mail As New System.Net.Mail.MailMessage()
        mail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        mail.To.Add(New System.Net.Mail.MailAddress("myadvantech@advantech.com"))
        mail.To.Add(New System.Net.Mail.MailAddress("sarah.lee@advantech.com.tw"))
        mail.Subject = String.Format("Sync eStore order to SAP automatically in {0}", DateTime.Now.ToShortTimeString())
        mail.IsBodyHtml = True

        'Try
        '    Dim no = Advantech.Myadvantech.Business.OrderBusinessLogic.GetBBordersByStatus(Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.NeedERPID)
        '    If no IsNot Nothing AndAlso no.Count > 0 Then
        '        For Each n In no
        '            Dim eStoreOrder = Advantech.Myadvantech.DataAccess.BBeStoreDAL.GetBBeStoreOrderByOrderNo(n.ORDER_NO)
        '            If eStoreOrder IsNot Nothing Then
        '                Dim row_ID As Object = dbUtil.dbExecuteScalar("CRMDB75", String.Format("select top 1 ROW_ID from S_CONTACT where UPPER(EMAIL_ADDR) ='{0}'", eStoreOrder.UserID.ToUpper))
        '                If row_ID IsNot Nothing AndAlso Not String.IsNullOrEmpty(row_ID.ToString) Then
        '                    Dim count = dbUtil.dbExecuteScalar("MY", String.Format("select count(*) from SIEBEL_CONTACT where ROW_ID='{0}'", row_ID.ToString))
        '                    Dim dc As Integer = -1
        '                    If Integer.TryParse(count.ToString, dc) = True AndAlso dc = 0 Then
        '                        Dim contactID As List(Of String) = New List(Of String)()
        '                        contactID.Add(row_ID.ToString)
        '                        If Advantech.Myadvantech.DataAccess.SiebelDAL.SyncSiebelContact(contactID) = True Then
        '                            Dim cust = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getBBcustomerIDByUserID(eStoreOrder.UserID)
        '                            If cust IsNot Nothing AndAlso Not String.IsNullOrEmpty(cust.CustomerID) Then
        '                                dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='UnProcess', ERPID = '{1}' where ID={0}", n.ID, cust.CustomerID))
        '                            End If
        '                        End If
        '                    Else
        '                        Dim cust = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getBBcustomerIDByUserID(eStoreOrder.UserID)
        '                        If cust IsNot Nothing AndAlso Not String.IsNullOrEmpty(cust.CustomerID) Then
        '                            dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='UnProcess', ERPID = '{1}' where ID={0}", n.ID, cust.CustomerID))
        '                        End If
        '                    End If
        '                End If
        '            End If
        '        Next
        '    End If
        'Catch ex As Exception
        '    mail.Body = "Update Siebel contact failed. Exception: " + ex.ToString + "<br /><br />"
        'End Try

        Dim orders = Advantech.Myadvantech.Business.OrderBusinessLogic.GetBBordersByStatus(Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess)
        If orders IsNot Nothing AndAlso orders.Count > 0 Then
            Dim results As List(Of WebServiceResult) = New List(Of WebServiceResult)()
            For Each o In orders
                Try
                    Dim result As WebServiceResult = Me.Process(o.ORDER_NO)
                    If result.Result = True Then
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='SuccessToSAP', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.SuccessToSAP, String.Empty)
                    ElseIf result.Message = "eStore order not found." Then
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='UnProcess', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess, String.Empty)
                    Else
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='FailedToSAP', PROCESS_LOG = '{1}', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO, result.Message))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.FailedToSAP, result.Message)
                    End If
                    results.Add(result)
                Catch ex As Exception
                    Dim result As WebServiceResult = New WebServiceResult()
                    result.OrderNo = o.ORDER_NO
                    result.Result = False
                    result.Message = ex.ToString
                    results.Add(result)
                End Try
            Next

            Dim gv As New GridView()
            gv.DataSource = results.Select(Function(p) New With {.OrderNo = p.OrderNo, .Status = IIf(p.Result, "Success to SAP", "Failed to SAP").ToString, .Message = p.Message}).ToList()
            gv.DataBind()
            Dim sb As New StringBuilder()
            Dim sw As New System.IO.StringWriter(sb)
            Dim html As New System.Web.UI.HtmlTextWriter(sw)
            gv.RenderControl(html)
            mail.Body += sb.ToString()

            Try
                sc.Send(mail)
            Catch ex As Exception
                Try
                    sc.Send(mail)
                Catch exx As Exception

                End Try
            End Try
        Else
            'mail.Subject = "No BB eStore order in these few minutes"
            'mail.Body += "No BB eStore order in these few minutes..."
        End If

        'Try
        '    sc.Send(mail)
        'Catch ex As Exception

        'End Try
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub SynceStoreOrderToSAP(ByVal OrderNo As String)
        Dim results As List(Of WebServiceResult) = New List(Of WebServiceResult)()
        If Not String.IsNullOrEmpty(OrderNo) Then
            Try
                Dim result = Me.Process(OrderNo)
                results.Add(result)

                If result.Result = True Then
                    dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='SuccessToSAP', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", OrderNo))
                    'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(OrderNo, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.SuccessToSAP, String.Empty)
                ElseIf result.Message = "eStore order not found." Then
                    dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='ReadyToSAP', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", OrderNo))
                    'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(OrderNo, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess, String.Empty)
                Else
                    dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='FailedToSAP', PROCESS_LOG = '{1}', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", OrderNo, result.Message))
                    'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(OrderNo, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.FailedToSAP, result.Message)
                End If

                If HttpContext.Current.Request.IsAuthenticated = True Then
                    dbUtil.dbExecuteNoQuery("MY", String.Format("INSERT INTO BB_ESTORE_LOG VALUES ('SynceStoreOrderToSAP', 'OrderNo: {0}, Result: {1}, Message: {2}', '{3}', '{4}', GETDATE()) ", OrderNo, result.Result.ToString, result.Message, Util.IsTesting().ToString, HttpContext.Current.User.Identity.Name))
                End If

            Catch ex As Exception
                Dim result = New WebServiceResult()
                result.Result = False
                result.Message = ex.StackTrace
                results.Add(result)
            End Try
        End If

        Context.Response.Clear()
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(results))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub GetContactPerson(ByVal Email As String, ByVal ERPID As String, ByVal Name As String)
        Dim list As New List(Of Customer)()

        If String.IsNullOrEmpty(Email) AndAlso String.IsNullOrEmpty(ERPID) AndAlso String.IsNullOrEmpty(Name) Then

        Else
            Dim cs As String = "SAP_PRD"
            If Util.IsTesting() = True Then cs = "SAP_Test"
            'Dim sql As StringBuilder = New StringBuilder("select distinct a.kunnr, a.NAME1 from saprdp.kna1 a inner join saprdp.knvk b on a.kunnr = b.kunnr inner join saprdp.adr6 c on b.prsnr = c.persnumber where a.mandt = '168' and b.mandt='168' and a.KTOKD='Z001' ")
            'If Not String.IsNullOrEmpty(Email) Then
            '    sql.AppendFormat(" and b.mandt='168' and (UPPER(c.smtp_addr) like '%{0}%' or LOWER(c.smtp_addr) like '%{1}%') ", Email.ToUpper, Email.ToLower)
            'End If
            'If Not String.IsNullOrEmpty(ERPID) Then
            '    sql.AppendFormat(" and (UPPER(a.kunnr) like '%{0}%' or LOWER(a.kunnr) like '%{1}%') ", ERPID.ToUpper, ERPID.ToLower)
            'End If
            'If Not String.IsNullOrEmpty(Name) Then
            '    sql.AppendFormat(" and a.NAME1 like '%{0}%' ", Name.Trim)
            'End If
            'sql.Append(" order by a.kunnr")

            '2018/1/2 ICC Change to new SQL
            Dim sql As StringBuilder = New StringBuilder("select distinct a.kunnr, a.NAME1, a.REGIO, b.city1, b.post_code1, b.country from saprdp.knvv b ")
            sql.Append(" inner join saprdp.kna1 a on a.kunnr = b.kunnr inner join saprdp.adrc b on a.adrnr = b.addrnumber and a.land1 = b.country and b.NATION=' ' and b.client='168' ")
            sql.Append(" where a.mandt = '168' and a.KTOKD='Z001' and b.vkorg='US10' ")

            If Not String.IsNullOrEmpty(ERPID) Then
                sql.AppendFormat(" and (UPPER(a.kunnr) like '%{0}%' or LOWER(a.kunnr) like '%{1}%') ", ERPID.Trim.ToUpper, ERPID.Trim.ToLower)
            End If

            If Not String.IsNullOrEmpty(Name) Then
                sql.AppendFormat(" and (UPPER(a.NAME1) like '%{0}%' or LOWER(a.NAME1) like '%{1}%') ", Name.Trim.ToUpper, Name.Trim.ToLower)
            End If

            If Not String.IsNullOrEmpty(Email) Then
                sql.Append(" and a.kunnr in (select distinct b.kunnr from saprdp.knvk b inner join saprdp.adr6 c on b.prsnr = c.persnumber where b.mandt='168' ")
                sql.AppendFormat(" and (UPPER(c.smtp_addr) like '%{0}%' or LOWER(c.smtp_addr) like '%{1}%')) ", Email.Trim.ToUpper, Email.Trim.ToLower)
            End If

            sql.Append(" order by a.kunnr ")

            Dim dt As DataTable = OraDbUtil.dbGetDataTable(cs, sql.ToString)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                For Each dr As DataRow In dt.Rows
                    list.Add(New Customer(dr.Item(0).ToString().Trim().ToUpper(), dr.Item(1).ToString().Trim().ToUpper(),
                                          dr.Item(2).ToString.Trim.ToUpper, dr.Item(3).ToString.Trim, dr.Item(4).ToString.Trim.ToUpper,
                                          dr.Item(5).ToString.Trim.ToUpper))
                Next
            End If
        End If
        Context.Response.Clear()
        Context.Response.ContentType = "application/json"
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <System.Web.Script.Services.ScriptMethod(UseHttpGet:=True, ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Sub GetBBCreditCardOrder(ByVal invNo As String, ByVal soNo As String, ByVal dnNo As String, ByVal poNo As String, ByVal org As String, ByVal dateFrom As String, ByVal dateTo As String, ByVal onlyInvoicedOrders As Boolean, ByVal isCaptured As Boolean, ByVal rowCount As Integer)
        Dim result As String = String.Empty
        Dim sb As New System.Text.StringBuilder
        dateFrom = Convert.ToDateTime(dateFrom).AddDays(-1).ToString("yyyy/MM/dd")
        Dim InvoiceInClauseTuple As List(Of Tuple(Of String, String)) = New List(Of Tuple(Of String, String))
        If onlyInvoicedOrders Then

            'select all US10 invoiced orders with credit card information which is in invoice Clause(which G/L account not clear)
            With sb
                .AppendFormat(" Select b.vbeln As INVOICE_NO, a.kunag As ERP_ID, ")
                .AppendFormat("(SELECT VBAK.BSTNK FROM saprdp.vbak WHERE VBAK.VBELN=b.AUBEL And ROWNUM=1 And VBAK.MANDT='168') as PO_NO, ")
                .AppendFormat(" b.aubel AS SO_NO, b.vgbel As DN_NO, a.WAERK As CURRENCY, ")
                .AppendFormat(" b.posnr AS LINE_NO, b.matnr As PART_NO, b.fkimg As INVOICE_QTY, a.erdat As INVOICE_DATE, b.kzwi2 As SUB_TOTAL, b.NETWR As SubTotalWithFreight, b.MWSBP As Tax, b.kzwi4 As Freight, a.ZTERM, e.ccnum As CARD_NUMBER, e.ccins As CARD_TYPE, e.autwr as AUTH_AMOUNT, e.autra As TRANSACTION_ID, e.aunum As AUTH_CODE, e.audat as AUTH_DATE")

                .AppendFormat(" From saprdp.vbrk a inner Join saprdp.vbrp b on a.vbeln=b.vbeln inner Join saprdp.vbak c on b.aubel=c.vbeln ")

                .AppendFormat(" inner Join( SELECT inn.* ")
                .AppendFormat(" FROM(SELECT d.*, (ROW_NUMBER() OVER(PARTITION BY fplnr ORDER BY fpltr DESC)) As Rank ")
                .AppendFormat(" From saprdp.FPLTC d Where Trim(autra) Is Not null And autra <> '1111111111'  ) inn ")
                .AppendFormat(" WHERE inn.Rank= 1) e On b.RPLNR = e.fplnr ")

                .AppendFormat(" Where a.mandt ='168' and b.mandt='168'  and c.mandt='168' ")

                InvoiceInClauseTuple = OrderBusinessLogic.getSAPTempGL(org)

                If InvoiceInClauseTuple.Count > 0 Then
                    Dim InvoiceInClauseString As List(Of String) = New List(Of String)()
                    For Each invoice In InvoiceInClauseTuple
                        InvoiceInClauseString.Add("'" + invoice.Item1 + "'")
                    Next
                    .AppendFormat(" and b.vbeln in ({0})", String.Join(",", InvoiceInClauseString.ToArray()))
                End If

                .AppendFormat(" and a.ZTERM = 'CODC' ")

                Dim inv_no As String = "00" & invNo
                If invNo.Trim <> "" Then .AppendFormat(" and  a.vbeln ='{0}'", inv_no)
                If soNo.Trim <> "" Then .AppendFormat(" and b.aubel ='{0}'", Global_Inc.Format2SAPItem2(soNo.Trim.Replace("'", "''")))
                If dnNo.Trim <> "" Then .AppendFormat(" and b.vgbel like '%{0}%'", dnNo.Trim)

                If org.Trim <> "" Then .AppendFormat(" and a.vkorg = '{0}' ", org)
                .AppendFormat(" and a.erdat BETWEEN '{0}' AND '{1}'", Replace(dateFrom.Trim, "/", ""), Replace(dateTo.Trim, "/", ""))
                .AppendFormat(" and (ROWNUM < {0}) order by a.VBELN desc, b.posnr asc", rowCount.ToString)


                'If Me.txtpart_no.Text.Trim <> "" Then .AppendFormat(" and b.matnr like '%{0}%'", Me.txtpart_no.Text.Trim)
            End With
        Else
            'select all US10 orders
            With sb
                .AppendFormat(" Select a.vbeln As SO_NO, b.ZTERM As PAYMENT_TERM, c.ccnum As CARD_NUMBER,  c.autwr As AUTH_AMOUNT, c.autra As TRANSACTION_ID, c.aunum As AUTH_CODE, c.audat as AUTH_DATE ")
                .AppendFormat(" From saprdp.vbak  a inner Join saprdp.vbkd b on a.vbeln = b.vbeln inner Join saprdp.FPLTC c on a.rplnr = c.fplnr ")
                .AppendFormat(" Where a.mandt='168' and a.auart like 'ZOR%' and b.ZTERM = 'CODC' and trim(c.autra) is not null ")

                If soNo.Trim <> "" Then .AppendFormat(" and a.vbeln ='{0}'", Global_Inc.Format2SAPItem2(soNo.Trim.Replace("'", "''")))
                If org.Trim <> "" Then .AppendFormat(" and a.VKORG ='{0}' ", org)
                .AppendFormat(" and a.ERDAT BETWEEN '{0}' AND '{1}'", Replace(dateFrom.Trim, "/", ""), Replace(dateTo.Trim, "/", ""))
                .AppendFormat(" and (ROWNUM < {0}) order by a.VBELN desc ", rowCount.ToString)
            End With

        End If



        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        If poNo <> "" Then
            For Each r As DataRow In dt.Rows
                If r.Item("PO_NO") <> poNo Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
        End If


        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim orders As List(Of CreditCardOrder) = New List(Of CreditCardOrder)
            Dim order As CreditCardOrder = New CreditCardOrder
            Dim orderDetails As List(Of CreditCardOrderDetail) = New List(Of CreditCardOrderDetail)
            'Dim authAmount As Decimal = 0
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim r As DataRow = dt.Rows(i)
                If r.Item("INVOICE_NO").ToString.Trim <> "" And r.Item("TRANSACTION_ID").ToString.Trim <> "" Then
                    Dim orderDetail As CreditCardOrderDetail = New CreditCardOrderDetail
                    If onlyInvoicedOrders Then
                        orderDetail.OrderNo = r.Item("SO_NO")
                        orderDetail.InvoiceNo = r.Item("INVOICE_NO")
                        orderDetail.PoNo = r.Item("PO_NO")
                        orderDetail.DnNo = r.Item("DN_NO")
                        orderDetail.Currency = r.Item("CURRENCY")
                        orderDetail.LineNo = r.Item("LINE_NO")
                        orderDetail.PartNo = r.Item("PART_NO")
                        orderDetail.InvoiceQty = r.Item("INVOICE_QTY")
                        orderDetail.Tax = r.Item("TAX")
                        orderDetail.SubTotal = r.Item("SUB_TOTAL")
                        orderDetail.SubTotalWithFreight = r.Item("SubTotalWithFreight")
                        orderDetail.InvoiceDate = r.Item("INVOICE_DATE")
                        orderDetails.Add(orderDetail)
                    End If
                    '' 第一條line的SubTotalWithFreight已含運費，所以不用另外加運費到authamount,只需加總每條line的未稅價(SubTotalWithFreight) and tax
                    'authAmount += orderDetail.SubTotalWithFreight + orderDetail.Tax



                    Dim nextRow As DataRow = dt(i + 1)
                    Dim isNewInvoice As Boolean = False
                    If nextRow Is Nothing Then
                        isNewInvoice = True
                    Else
                        If r.Item("INVOICE_NO") <> nextRow.Item("INVOICE_NO") Then
                            isNewInvoice = True
                        End If
                    End If

                    If isNewInvoice Then
                        order = New CreditCardOrder
                        order.InvoiceNo = r.Item("INVOICE_NO")
                        order.OrderNo = r.Item("SO_NO")
                        order.PoNo = r.Item("PO_NO")
                        order.Customer = r.Item("ERP_ID")
                        order.InvoicedDate = DateTime.ParseExact(r.Item("INVOICE_DATE"), "yyyyMMdd", Nothing).ToString("MM\/dd\/yyyy")
                        order.TransactionId = r.Item("TRANSACTION_ID")
                        order.AuthCode = r.Item("AUTH_CODE")
                        order.AuthorizedAmount = r.Item("AUTH_AMOUNT")

                        Dim item = InvoiceInClauseTuple.Where(Function(s) s.Item1 = order.InvoiceNo).FirstOrDefault()
                        If item IsNot Nothing Then
                            order.InvoicedAmount = Convert.ToDecimal(item.Item2)
                        End If

                        'order.AuthorizedAmount = authAmount
                        order.AuthorizedDate = r.Item("AUTH_DATE")
                        If r.Item("CARD_NUMBER") IsNot Nothing Then
                            order.CreditCardNumber = "XXXX" + r.Item("CARD_NUMBER").Substring(r.Item("CARD_NUMBER").Length - 4, 4)
                        End If
                        order.CardType = r.Item("CARD_TYPE")


                        '利用BBCredtCard table來檢查Order 的transaction status(authorization/captured/void)
                        Dim bbcreditCardOrders = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetAllBBCreditCardOrder()
                        Dim bbCreditCardOrder = bbcreditCardOrders.Where(Function(o) o.ORDER_NO = r.Item("SO_NO") And o.STATUS = "Success").OrderByDescending(Function(o) o.CREATED_DATE).FirstOrDefault
                        If bbCreditCardOrder IsNot Nothing Then
                            If bbCreditCardOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Capture.ToString Then
                                order.TransactionStatus = "Already Captured"
                            Else
                                order.TransactionStatus = "Not Captured"
                            End If

                        End If

                        order.InvoiceOrderDetail = orderDetails
                        orders.Add(order)
                        orderDetails = New List(Of CreditCardOrderDetail)
                        'authAmount = 0
                    End If

                End If

            Next


            result = Newtonsoft.Json.JsonConvert.SerializeObject(orders)
        End If


        Context.Response.Clear()
        Context.Response.Write(result)
        Context.Response.End()
    End Sub


    <WebMethod(EnableSession:=True)>
    <System.Web.Script.Services.ScriptMethod(UseHttpGet:=True, ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Sub CaptureBBCreditCardAuthorizedOrder(ByVal selectedCapturedItems As String)
        Dim results As List(Of CCTransactionResult) = New List(Of CCTransactionResult)
        Dim capturedItems As List(Of CreditCardOrder) = New List(Of CreditCardOrder)
        Dim apiLoginId As String
        Dim apiTransactionKey As String
        'Dim simulation As Boolean
        'If Util.IsTesting() Then

        '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.Login.US")
        '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.TransactionKey.US")
        '    simulation = True

        'Else

        '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Login.US")
        '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.TransactionKey.US")
        '    simulation = False
        'End If

        capturedItems = Newtonsoft.Json.JsonConvert.DeserializeObject(Of List(Of CreditCardOrder))(selectedCapturedItems)



        For Each item In capturedItems.GroupBy(Function(x) x.OrderNo)
            Dim order = item.FirstOrDefault
            'Dim response = AuthorizeNetSolution.CapturePreviouslyAuthorizeAmount(order.CaptureAmount, order.TransactionId, apiLoginId, apiTransactionKey, simulation)
            Dim response = AuthorizeNetSolution.CapturePreviouslyAuthorizeAmount(order.CaptureAmount, order.TransactionId, Util.IsTesting())

            Dim result As CCTransactionResult = New CCTransactionResult()

            'Add captured result to bb_credtiCard_order table
            Try
                Dim ccOrder = New Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER
                ccOrder.ORDER_NO = order.OrderNo
                ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Capture.ToString
                ccOrder.TRANSACTION_ID = response.TransactionID
                ccOrder.TOTAL_AUTH_AMOUNT = order.CaptureAmount
                ccOrder.STATUS = response.Result
                ccOrder.AUTH_CODE = response.AuthCode
                ccOrder.CREATED_DATE = DateTime.Now
                ccOrder.CREATED_By = Session("user_id")
                ccOrder.MESSAGE = response.Message
                Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder)
            Catch ex As Exception
                Dim message = ex.Message
            End Try

            result.OrderNo = order.OrderNo
            result.Result = response.Result
            result.Message = response.Message
            results.Add(result)
        Next


        Context.Response.Clear()
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(results))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    Public Sub GetCaptureAndUpdateCreditCardTranStatusForBBOrder()

        Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
        Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)
        Dim mail As New System.Net.Mail.MailMessage()
        mail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        mail.To.Add(New System.Net.Mail.MailAddress("myadvantech@advantech.com"))
        mail.To.Add(New System.Net.Mail.MailAddress("sarah.lee@advantech.com.tw"))
        mail.Subject = String.Format("Sync eStore order to SAP automatically in {0}", DateTime.Now.ToShortTimeString())
        mail.IsBodyHtml = True
        Dim apiLoginId As String
        Dim apiTransactionKey As String
        'Dim simulation As Boolean
        'If Util.IsTesting() Then

        '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.Login.US")
        '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.TransactionKey.US")
        '    simulation = True

        'Else

        '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Login.US")
        '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.TransactionKey.US")
        '    simulation = False
        'End If
        Try

            Dim settleResult = Advantech.Myadvantech.Business.AuthorizeNetSolution.GetSettledList(Util.IsTesting())
        Catch ex As Exception
            mail.Body = "Get Authorize.net Unsettled Transaction List failed. Exception: " + ex.ToString + "<br /><br />"
        End Try

        Dim orders = Advantech.Myadvantech.Business.OrderBusinessLogic.GetBBordersByStatus(Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess)
        If orders IsNot Nothing AndAlso orders.Count > 0 Then
            Dim results As List(Of WebServiceResult) = New List(Of WebServiceResult)()
            For Each o In orders
                Try
                    Dim result As WebServiceResult = Me.Process(o.ORDER_NO)
                    If result.Result = True Then
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='SuccessToSAP', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.SuccessToSAP, String.Empty)
                    ElseIf result.Message = "eStore order not found." Then
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='UnProcess', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.UnProcess, String.Empty)
                    Else
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='FailedToSAP', PROCESS_LOG = '{1}', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", o.ORDER_NO, result.Message))
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UpdateBBorderRecord(o.ORDER_NO, Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.FailedToSAP, result.Message)
                    End If
                    results.Add(result)
                Catch ex As Exception
                    Dim result As WebServiceResult = New WebServiceResult()
                    result.OrderNo = o.ORDER_NO
                    result.Result = False
                    result.Message = ex.ToString
                    results.Add(result)
                End Try
            Next

            Dim gv As New GridView()
            gv.DataSource = results.Select(Function(p) New With {.OrderNo = p.OrderNo, .Status = IIf(p.Result, "Success to SAP", "Failed to SAP").ToString, .Message = p.Message}).ToList()
            gv.DataBind()
            Dim sb As New StringBuilder()
            Dim sw As New System.IO.StringWriter(sb)
            Dim html As New System.Web.UI.HtmlTextWriter(sw)
            gv.RenderControl(html)
            mail.Body += sb.ToString()
        Else
            mail.Subject = "No BB eStore order in these few minutes"
            'mail.Body += "No BB eStore order in these few minutes..."
        End If

        Try
            sc.Send(mail)
        Catch ex As Exception

        End Try
    End Sub
    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub AssociateSiebelSAPAccountContact(ByVal OrderNo As String, ByVal ERPID As String)
        Dim results As List(Of WebServiceResult) = New List(Of WebServiceResult)()
        If Not String.IsNullOrEmpty(OrderNo) AndAlso Not String.IsNullOrEmpty(ERPID) Then
            Dim result As WebServiceResult = New WebServiceResult()
            result.Result = Advantech.Myadvantech.Business.UserRoleBusinessLogic.AssociateSiebelSAPAccountContact(Util.IsTesting(), OrderNo, ERPID)
            If result.Result = True Then
                dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_ESTORE_ORDER set ORDER_STATUS='ReadyToSAP', PROCESS_LOG = '', UPDATED_DATE=GETDATE() where ORDER_NO='{0}'", OrderNo))
            End If
            results.Add(result)

            Try
                If HttpContext.Current.Request.IsAuthenticated = True Then
                    dbUtil.dbExecuteNoQuery("MY", String.Format("INSERT INTO BB_ESTORE_LOG VALUES ('AssociateSiebelSAPAccountContact', 'OrderNo: {0}, ERP ID: {1}, Result: {2}, Message: {3}', '{4}', '{5}', GETDATE()) ", OrderNo, ERPID, result.Result.ToString, result.Message, Util.IsTesting().ToString, HttpContext.Current.User.Identity.Name))
                End If
            Catch ex As Exception

            End Try
        End If
        Context.Response.Clear()
        Context.Response.ContentType = "application/json"
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(results))
        Context.Response.End()
    End Sub


    <WebMethod(EnableSession:=True)>
    <System.Web.Script.Services.ScriptMethod(UseHttpGet:=True, ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Sub AuthorizeBBCreditCardOrder(ByVal orderNo As String, ByVal cardType As String, ByVal cardNumber As String, ByVal expDate As String, ByVal cvv As String, ByVal cardHolder As String, ByVal authAmount As Decimal, ByVal billToStreet As String, ByVal billToCity As String, ByVal billToState As String, ByVal billToZipCode As String, ByVal billToCountry As String)


        Dim results As List(Of CCTransactionResult) = New List(Of CCTransactionResult)
        Dim result As CCTransactionResult = New CCTransactionResult()
        If Not String.IsNullOrEmpty(cardNumber) AndAlso Not String.IsNullOrEmpty(cardType) AndAlso Not String.IsNullOrEmpty(cardNumber) AndAlso Not String.IsNullOrEmpty(cardNumber) And authAmount > 0 Then
            Dim apiLoginId As String
            Dim apiTransactionKey As String
            'Dim simulation As Boolean
            'If Util.IsTesting() Then

            '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.Login.US")
            '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.Sanbox.TransactionKey.US")
            '    simulation = True

            'Else

            '    apiLoginId = ConfigurationManager.AppSettings("AuthorizeNet.BB.Login.US")
            '    apiTransactionKey = ConfigurationManager.AppSettings("AuthorizeNet.BB.TransactionKey.US")
            '    simulation = False
            'End If

            Dim firstName As String = ""
            Dim lastName As String = ""
            If Not String.IsNullOrEmpty(cardHolder) Then
                If cardHolder.Contains(" ") Then
                    firstName = cardHolder.Substring(0, cardHolder.LastIndexOf(" "))
                    lastName = cardHolder.Substring(cardHolder.LastIndexOf(" ") + 1)
                Else
                    firstName = cardHolder
                End If
            End If

            Dim response = AuthorizeNetSolution.AuthorizePaymentAmount(orderNo, authAmount, firstName, lastName, billToStreet, billToCity, billToState, billToZipCode, "", cardNumber, Convert.ToDateTime(expDate).ToString("yyyy-MM"), cvv, Util.IsTesting())


            'Add authorization result to bb_credtiCard_order table
            Try
                Dim ccOrder = New Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER
                ccOrder.ORDER_NO = orderNo
                ccOrder.CARD_TYPE = cardType
                ccOrder.CARD_NO = cardNumber
                ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Authorization.ToString
                ccOrder.TRANSACTION_ID = response.TransactionID
                ccOrder.STATUS = response.Result
                ccOrder.TOTAL_AUTH_AMOUNT = authAmount
                ccOrder.AUTH_CODE = response.AuthCode
                ccOrder.CREATED_DATE = DateTime.Now
                ccOrder.CREATED_By = Session("user_id")
                ccOrder.MESSAGE = response.Message
                Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder)
            Catch ex As Exception
                Dim message = ex.Message
            End Try

            If (response.Result = "Success") Then
                If Not String.IsNullOrEmpty(cardNumber) AndAlso Not String.IsNullOrEmpty(cardType) AndAlso Not String.IsNullOrEmpty(response.AuthCode) _
                        AndAlso Not String.IsNullOrEmpty(response.TransactionID) AndAlso authAmount > 0 Then
                    Try
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.AddCreditCardInfo2SAPSO(orderNo, response.AuthCode, response.TransactionID, cardType, cardNumber, authAmount, simulation)
                        'Advantech.Myadvantech.Business.OrderBusinessLogic.UnblockSOCreditCard(orderNo, simulation)

                    Catch ex As Exception

                    End Try

                End If
            End If
            result.OrderNo = orderNo
            result.Result = response.Result
            result.Message = response.Message
            result.TransactionId = response.TransactionID
            result.AuthCode = response.AuthCode

        Else
            result.OrderNo = orderNo
            result.Result = "Fail"
            result.Message = "Credit card information is not complete"
            result.TransactionId = "NA"
            result.AuthCode = "NA"
        End If


        results.Add(result)

        Context.Response.Clear()
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(results))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <System.Web.Script.Services.ScriptMethod(UseHttpGet:=True, ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Sub GetFreight(ByVal shipToCountry As String, ByVal shipToZipCode As String, ByVal shipToState As String, ByVal cartId As String)
        'Dim shippingmethods As List(Of ShippingMethod) = New List(Of ShippingMethod)
        Dim shippingResult As ShippingResult = New ShippingResult

        shippingResult = Advantech.Myadvantech.Business.FreightCalculateBusinessLogic.CalculateBBFreight(shipToCountry, shipToZipCode, shipToState, cartId)
        'Dim freightOptions As List(Of Advantech.Myadvantech.DataAccess.FreightOption) = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetAllFreightOptions()


        'For Each o In freightOptions
        '    Dim method As ShippingMethod = New ShippingMethod
        '    method.MethodName = o.SAPCode + ": " + o.Description
        '    method.MethodValue = o.CarrierCode + ": " + o.Description
        '    method.DisplayShippingCost = "N/A"
        '    If o.EStoreServiceName IsNot Nothing Then
        '        method.EstoreServiceName = o.EStoreServiceName
        '        shippingmethods.Add(method)
        '    End If

        'Next


        'Dim result As Advantech.Myadvantech.DataAccess.com.advantech.bbdev.Response = New Advantech.Myadvantech.DataAccess.com.advantech.bbdev.Response
        'result = Advantech.Myadvantech.Business.FreightCalculateBusinessLogic.CalculateBBFreight(shipToCountry, shipToZipCode, shipToState, cartId)

        'If result IsNot Nothing Then
        '    'If result.ShippingRates IsNot Nothing Then
        '    '    'shippingResult.Status = result.Status
        '    '    'For Each item In result.ShippingRates


        '    '    '    'For Each method In shippingmethods

        '    '    '    '    If method.EstoreServiceName = item.Nmae Then

        '    '    '    '        If String.IsNullOrEmpty(item.ErrorMessage) Then
        '    '    '    '            method.ShippingCost = item.Rate
        '    '    '    '            method.DisplayShippingCost = item.Rate.ToString()
        '    '    '    '        Else
        '    '    '    '            method.ErrorMessage = item.ErrorMessage
        '    '    '    '        End If

        '    '    '    '    End If

        '    '    '    'Next
        '    '    'Next

        '    '    'shippingResult.ShippingMethods = shippingmethods
        '    'End If
        '    'If result.Boxex(0) IsNot Nothing Then

        '    '    shippingResult.Weight = Decimal.Round(result.Boxex(0).Weight, 2)

        '    'End If
        '    'shippingResult.Message = result.message
        '    'If result.DetailMessages IsNot Nothing Then
        '    '    shippingResult.DetailMessage = result.DetailMessages.ToList
        '    'End If

        'End If
        Context.Response.Clear()
            Context.Response.ContentType = "application/json"
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(shippingResult))
            Context.Response.End()

    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub UpdateShipToAddress(ByVal ContactID As String, ByVal Address As String)
        Dim result As WebServiceResult = New WebServiceResult()
        If Context.Request.IsAuthenticated = False Then
            result.Result = False
            result.Message = "Wrong request"
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
            Context.Response.End()
        End If

        If String.IsNullOrWhiteSpace(ContactID) Or String.IsNullOrWhiteSpace(Address) Then
            result.Result = False
            result.Message = "Data cannot be empty"
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
            Context.Response.End()
        End If

        Dim ID As Integer = 0
        If Integer.TryParse(ContactID, ID) = False Or ID = 0 Then
            result.Result = False
            result.Message = "Contact ID is wrong"
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
            Context.Response.End()
        End If

        Try
            dbUtil.dbExecuteNoQuery("BBeStore", String.Format("UPDATE CartContact SET Address1 = N'{0}', ValidationStatus = N'CCRConfirmed' WHERE ContactID = {1}", Address.Trim(), ID))
            result.Result = True
            result.Message = String.Empty
        Catch ex As Exception
            result.Result = False
            result.Message = ex.Message
        End Try
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
        Context.Response.End()
    End Sub
End Class


<Serializable()>
Public Class WebServiceResult
    Public OrderNo As String
    Public Result As Boolean
    Public Message As String

    Public Sub New()
        Result = False
        Message = String.Empty
        OrderNo = String.Empty
    End Sub
End Class

<Serializable()>
Public Class Customer
    Public CompanyID As String
    Public Email As String
    Public State As String
    Public City As String
    Public Zipcode As String
    Public Country As String
    Public Sub New()

    End Sub
    Public Sub New(ByVal c As String)
        Me.CompanyID = c
    End Sub

    Public Sub New(ByVal c As String, ByVal e As String)
        Me.CompanyID = c
        Me.Email = e
    End Sub

    Public Sub New(ByVal cid As String, ByVal e As String, ByVal st As String, ByVal ct As String, ByVal zc As String, ByVal cy As String)
        Me.CompanyID = cid
        Me.Email = e
        Me.State = st
        Me.City = ct
        Me.Zipcode = zc
        Me.Country = cy
    End Sub

    Public Enum BBorderStatus
        UnProcess
        Failed
        Success
        NeedERPID
    End Enum
End Class

<Serializable()>
Public Class CreditCardOrderDetail
    Public InvoiceNo As String
    Public PoNo As String
    Public OrderNo As String
    Public DnNo As String
    Public Currency As String
    Public LineNo As Integer
    Public PartNo As String
    Public ProductGroup As String
    Public InvoiceQty As Integer
    Public UnitPrice As Decimal
    Public Tax As Decimal
    Public SubTotal As Decimal
    Public SubTotalWithFreight As Decimal
    Public InvoiceDate As String



    Public Sub New()
        InvoiceNo = String.Empty
        PoNo = String.Empty
        OrderNo = String.Empty
        DnNo = String.Empty
        Currency = String.Empty
        LineNo = 0
        PartNo = String.Empty
        ProductGroup = String.Empty
        InvoiceQty = 0
        UnitPrice = 0
        Tax = 0
        SubTotal = 0
        SubTotalWithFreight = 0
        InvoiceDate = String.Empty
    End Sub
End Class

<Serializable()>
Public Class CreditCardOrder
    Public InvoiceNo As String
    Public OrderNo As String
    Public PoNo As String
    Public Customer As String
    Public CreditCardNumber As String
    Public CardType As String
    Public Freight As Decimal
    Public InvoicedDate As String
    Public TransactionId As String
    Public AuthCode As String
    Public InvoicedAmount As Decimal
    Public CaptureAmount As Decimal
    Public AuthorizedAmount As Decimal
    Public AuthorizedDate As String
    Public TransactionStatus As String
    Public InvoiceOrderDetail As List(Of CreditCardOrderDetail)



    Public Sub New()
        InvoiceNo = String.Empty
        OrderNo = String.Empty
        PoNo = String.Empty
        Customer = String.Empty
        CreditCardNumber = String.Empty
        CardType = String.Empty
        Freight = 0
        TransactionId = String.Empty
        AuthCode = String.Empty
        AuthorizedAmount = 0
        InvoicedAmount = 0
        CaptureAmount = 0
        AuthorizedDate = String.Empty
        TransactionStatus = "Not Captured"
        InvoiceOrderDetail = New List(Of CreditCardOrderDetail)
    End Sub
End Class


<Serializable()>
Public Class CCTransactionResult
    Public OrderNo As String
    Public Result As String
    Public Message As String
    Public TransactionId As String
    Public AuthCode As String

    Public Sub New()
        Result = String.Empty
        Message = String.Empty
        OrderNo = String.Empty
        TransactionId = String.Empty
        AuthCode = String.Empty
    End Sub
End Class

'<Serializable()>
'Public Class ShippingMethod

'    Public MethodName As String
'    Public MethodValue As String
'    Public ShippingCost As Double
'    Public DisplayShippingCost As String
'    Public EstoreServiceName As String
'    Public ErrorMessage As String


'End Class

'Public Class ShippingResult
'    Public Status As String
'    Public Weight As Double
'    Public ShippingMethods As List(Of ShippingMethod)
'    Public Message As String
'    Public DetailMessage As List(Of String)
'End Class