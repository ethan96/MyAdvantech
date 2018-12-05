Imports Microsoft.VisualBasic
Imports Quartz
Imports Quartz.Impl
Imports Sgml
Imports System.IO
Imports System.Xml
Imports System.Net

Public Class ScheduledJob
    Public Sub StartPImailJob()
        Dim scheduleFactory = New Quartz.Impl.StdSchedulerFactory()
        Dim schedular = scheduleFactory.GetScheduler()
        Dim piMail As IJobDetail = JobBuilder.Create(Of SiebelJob)().WithIdentity("PImailJob").Build()
        Dim trigger As ITrigger = TriggerBuilder.Create().WithCronSchedule("0 0/3 * 1/1 * ? *").WithIdentity("PImailJobTrigger").Build() 'Change web job time from per 5m to 3m
        schedular.ScheduleJob(piMail, trigger)
        schedular.Start()
    End Sub

    Public Sub StopPImailJob()
        Dim schedulerFactory = New Quartz.Impl.StdSchedulerFactory().GetScheduler()
        schedulerFactory.UnscheduleJob(New TriggerKey("PImailJobTrigger"))
        schedulerFactory.DeleteJob(New JobKey("PImailJob"))
    End Sub

    Public Sub StartBBCacheJob()
        Dim scheduleFactory = New Quartz.Impl.StdSchedulerFactory()
        Dim schedular = scheduleFactory.GetScheduler()
        Dim BB As IJobDetail = JobBuilder.Create(Of BBJob)().WithIdentity("BBCacheJob").Build()
        Dim trigger As ITrigger = TriggerBuilder.Create().WithCronSchedule("0 0 0/1 * * ?").WithIdentity("BBCacheJobTrigger").Build()
        schedular.ScheduleJob(BB, trigger)
        schedular.Start()
    End Sub

    Public Sub StopBBCacheJob()
        Dim schedulerFactory = New Quartz.Impl.StdSchedulerFactory().GetScheduler()
        schedulerFactory.UnscheduleJob(New TriggerKey("BBCacheJobTrigger"))
        schedulerFactory.DeleteJob(New JobKey("BBCacheJob"))
    End Sub

    Public Sub StartCheckPointJob()
        Dim scheduleFactory = New Quartz.Impl.StdSchedulerFactory()
        Dim schedular = scheduleFactory.GetScheduler()
        Dim CP As IJobDetail = JobBuilder.Create(Of CPJob)().WithIdentity("CheckPointJob").Build()
        Dim trigger As ITrigger = TriggerBuilder.Create().WithCronSchedule("0 0 0/2 * * ?").WithIdentity("CheckPointJobTrigger").Build()
        schedular.ScheduleJob(CP, trigger)
        schedular.Start()
    End Sub

    Public Sub StopCheckPointJob()
        Dim schedulerFactory = New Quartz.Impl.StdSchedulerFactory().GetScheduler()
        schedulerFactory.UnscheduleJob(New TriggerKey("CheckPointJobTrigger"))
        schedulerFactory.DeleteJob(New JobKey("CheckPointJob"))
    End Sub


    Public Sub StartRecreateOptyJob()
        Dim scheduleFactory = New Quartz.Impl.StdSchedulerFactory()
        Dim schedular = scheduleFactory.GetScheduler()
        Dim opty As IJobDetail = JobBuilder.Create(Of ProjectRegistrationJob)().WithIdentity("RecreateOptyJob").Build()
        Dim optytrigger As ITrigger = TriggerBuilder.Create().WithCronSchedule("0 0/6 * 1/1 * ? *").WithIdentity("RecreateOptyJobTrigger").Build()
        schedular.ScheduleJob(opty, optytrigger)
        schedular.Start()
    End Sub

    Public Sub StopRecreateOptyJob()
        Dim schedulerFactory = New Quartz.Impl.StdSchedulerFactory().GetScheduler()
        schedulerFactory.UnscheduleJob(New TriggerKey("RecreateOptyJobTrigger"))
        schedulerFactory.DeleteJob(New JobKey("RecreateOptyJob"))
    End Sub


    Public Sub StartBBeStoreJob()
        Dim scheduleFactory = New Quartz.Impl.StdSchedulerFactory()
        Dim schedular = scheduleFactory.GetScheduler()
        Dim opty As IJobDetail = JobBuilder.Create(Of BBorder2SAP)().WithIdentity("BBorder2SAP").Build()
        Dim optytrigger As ITrigger = TriggerBuilder.Create().WithCronSchedule("0 0/2 * 1/1 * ? *").WithIdentity("BBorder2SAPTrigger").Build()
        schedular.ScheduleJob(opty, optytrigger)
        schedular.Start()
    End Sub

    Public Sub StopBBeStoreJob()
        Dim schedulerFactory = New Quartz.Impl.StdSchedulerFactory().GetScheduler()
        schedulerFactory.UnscheduleJob(New TriggerKey("BBorder2SAPTrigger"))
        schedulerFactory.DeleteJob(New JobKey("BBorder2SAP"))
    End Sub
End Class

Public Class SiebelJob
    Implements IJob

    Public Sub Execute(context As IJobExecutionContext) Implements IJob.Execute
        Dim sb As New StringBuilder()
        sb.Append(" select distinct om.ORDER_ID,om.PO_NO,om.SOLDTO_ID,om.CURRENCY,om.CREATED_BY,sd.COMPANY_NAME, ")
        sb.Append(" '' AS [Result], '' AS [ErrorMessage]  from ORDER_MASTER om ")
        sb.Append(" INNER JOIN SAP_DIMCOMPANY sd ON om.SOLDTO_ID = sd.COMPANY_ID ")
        sb.Append(" INNER JOIN Cart2OrderMaping map ON om.ORDER_ID = map.OrderNo ")
        sb.Append(" where om.ORDER_STATUS = 'TEMP' AND om.Order_Type in ('ZOR','ZOR2','ZOR6') ")
        sb.Append(" AND sd.ORG_ID = 'EU10' ")
        sb.Append(" AND om.LAST_UPDATED > DATEADD(MINUTE, -10, GETDATE()) ") 'Take orders in 10 minutes.
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)

        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim dtResult As DataTable = dt.Clone()
            For Each dr As DataRow In dt.Rows
                Try
                    sb.Clear()
                    'Check order has been already converted to SAP
                    Dim order_no As String = SAPDAL.SAPDAL.FormatToSAPSODNNo(dr.Item("ORDER_ID").ToString)
                    Dim count As Integer = Convert.ToInt32(OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format(" select count(*) from saprdp.vbak where vbeln = '{0}' ", order_no)))

                    If count > 0 Then
                        Dim result As Boolean = Me.Send_PI_EU(dr, sb)
                        If result = True Then
                            'Update order status
                            dbUtil.dbExecuteNoQuery("MY", String.Format(" update ORDER_MASTER set ORDER_STATUS='FINISH' where order_id = '{0}' ", dr.Item("ORDER_ID").ToString))
                            dr.Item("Result") = "Success"
                        Else
                            dr.Item("Result") = "Fail"
                            dr.Item("ErrorMessage") = sb.ToString
                        End If
                        dtResult.ImportRow(dr)
                    End If
                Catch ex As Exception
                    Me.InsertMyErrLog(ex.ToString)
                End Try
            Next

            If dtResult.Rows.Count > 0 Then Me.SendWebJobResult(dtResult, sb) 'Send result mail to our team members

        End If
    End Sub

    Public Function Send_PI_EU(ByVal om As DataRow, ByRef sb As StringBuilder) As Boolean
        Dim FROM_Email As String = "MyAdvantech@advantech.com"
        Dim TO_Email As String = om.Item("CREATED_BY").ToString
        Dim CC_Email As String = String.Empty
        Dim BCC_Email As String = "MyAdvantech@advantech.com;"
        Dim pono As String = om.Item("po_no").ToString
        Dim compName As String = om.Item("company_name").ToString
        Dim soldtoId As String = om.Item("SOLDTO_ID").ToString
        Dim order_no As String = om.Item("ORDER_ID").ToString
        Dim subject_email As String = String.Format("Advantech Order ({0} / {1}) for {2} ({3})", pono, order_no, compName, soldtoId)
        Dim myDoc As New System.Xml.XmlDocument

        Dim transXML2Html As String = Me.HtmlToXML(order_no, myDoc)
        If Not String.IsNullOrEmpty(transXML2Html) Then
            sb.AppendFormat("Order NO: {0},  Error function: PI_AEU HtmlToXML, Error message: {1}", order_no, transXML2Html)
            Return False
        End If

        Dim mailbody As String = myDoc.OuterXml
        Dim attachfile As String = String.Empty
        Dim strCC As String = String.Empty
        Dim strCC_External As String = String.Empty
        Me.GetPIcc(order_no, soldtoId, strCC, strCC_External)

        If strCC_External.Trim <> "" Then
            TO_Email = TO_Email + ";" + strCC_External
        End If

        '#1
        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)

        TO_Email = strCC
        Dim myOrderDetail As New order_Detail("B2B", "order_Detail")
        Dim ISBTO As Integer = myOrderDetail.isBtoOrder(order_no)
        CC_Email = CC_Email + "order.AEU@advantech.com;"

        If om.Item("CURRENCY") IsNot Nothing AndAlso String.Equals(om.Item("CURRENCY"), "USD", StringComparison.CurrentCultureIgnoreCase) Then
            '#2
            MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "AESC.SCM@advantech.com", "", "myadvantech@advantech.com", subject_email, "", mailbody)
        End If

        If ISBTO = 1 Then
            Dim arr As ArrayList = MyCartOrderBizDAL.GetBTOSOrderNotifyList("EU10")
            TO_Email += String.Join(";", arr.ToArray())
        End If

        '#3
        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)

        Return True
    End Function

    Public Sub GetPIcc(ByVal order_no As String, ByVal company_id As String, ByRef strCC As String, ByRef external As String)
        Dim InvalidOrg As String = ConfigurationManager.AppSettings("InvalidOrg").ToString.Trim()
        Dim OracleSCP As New StringBuilder
        OracleSCP.AppendLine(" select b.kunnr as COMPANY_ID, b.vkorg as ORG_ID, b.vtweg as DIST_CHANN, ")
        OracleSCP.AppendLine(" b.spart as DIVISION, b.parvw as PARTNER_FUNCTION, b.kunn2 as PARENT_COMPANY_ID, ")
        OracleSCP.AppendLine(" b.lifnr as VENDOR_CREDITOR, b.pernr as SALES_CODE, b.parnr as PARTNER_NUMBER, b.KNREF,  ")
        OracleSCP.AppendLine(" b.DEFPA from saprdp.kna1 a inner join saprdp.knvp b on a.kunnr=b.kunnr ")
        OracleSCP.AppendLine(" where a.mandt='168' and b.mandt='168' ")
        OracleSCP.AppendLine(" and b.vkorg in ('EU10') ")
        Dim OracleSEM As New StringBuilder
        OracleSEM.AppendLine(" select a.pernr as sales_code, a.werks as pers_area, a.persg as emp_group, a.persk as sub_emp_group,  ")
        OracleSEM.AppendLine(" (select b.stras from saprdp.pa0006 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as address, ")
        OracleSEM.AppendLine(" (select b.land1 from saprdp.pa0006 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as country,  a.sname, a.ename, ")
        OracleSEM.AppendLine(" (select b.vorna from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as first_name, ")
        OracleSEM.AppendLine(" (select b.nachn from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as last_name, ")
        OracleSEM.AppendLine(" concat(concat((select b.vorna from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and  ")
        OracleSEM.AppendLine(" b.mandt='168'),'.'),(select b.nachn from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168')) as full_name, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='0020' and rownum=1) as tel, ")
        OracleSEM.AppendLine(" decode((select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MAIL'  ")
        OracleSEM.AppendLine(" and rownum=1),null,(select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and  ")
        OracleSEM.AppendLine(" b.subty='0010' and rownum=1),(select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MAIL' and rownum=1)) as email, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='CELL' and rownum=1) as cellphone, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MPHN' and rownum=1) as otherphone, ")
        OracleSEM.AppendLine(" decode((select b.anzkd from saprdp.pa0002 b where b.mandt='168' and rownum=1 and b.pernr=a.pernr),null,0,(select b.anzkd from saprdp.pa0002 b where b.mandt='168' and rownum=1 and b.pernr=a.pernr)) as num_of_child, ")
        OracleSEM.AppendLine(" a.Abkrs as payr_area from saprdp.pa0001 a where a.mandt='168' ")

        Dim sql As String = "select distinct b.EMAIL  from (" + OracleSCP.ToString() + ") a inner join (" + OracleSEM.ToString() + ") b on a.SALES_CODE=b.SALES_CODE " _
                                                             & " and a.ORG_ID not in " + InvalidOrg + "" _
                                                             & " where a.COMPANY_ID='" + company_id + "'  ORDER BY b.EMAIL "
        Dim CDT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
        If CDT.Rows.Count > 0 Then
            For i As Integer = 0 To CDT.Rows.Count - 1
                With CDT.Rows(i)
                    If Not IsDBNull(.Item("EMAIL")) AndAlso Util.IsValidEmailFormat(.Item("EMAIL").ToString) Then
                        strCC = strCC & .Item("EMAIL").ToString & ";"
                    End If
                End With
            Next
        End If
        Dim sql1 As String = "select CONTACT_EMAIL from SAP_COMPANY_CONTACTS where COMPANY_ID='" + company_id + "'"
        Dim sql2 As String = "select a.EMAIL as KEYEmail from sap_employee a inner join order_master b on a.SALES_CODE=b.KEYPERSON WHERE a.PERS_AREA='EU10'  and dbo.IsEmail(a.EMAIL)=1 and b.ORDER_ID='" + order_no + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", sql1 + " UNION " + sql2)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                With dt.Rows(i)
                    If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso .Item("CONTACT_EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                        If Util.IsInternalUser(.Item("CONTACT_EMAIL").ToString) Then
                            strCC = strCC & .Item("CONTACT_EMAIL").ToString & ";"
                        End If
                    End If
                End With
            Next
        End If

        Dim sbCP As New StringBuilder()
        sbCP.AppendFormat(" select ADR6.smtp_addr as CONTACT_EMAIL from  saprdp.ADR6")
        sbCP.AppendFormat(" inner join  saprdp.knvk  on  ADR6.PERSNUMBER=knvk.PRSNR")
        sbCP.AppendFormat(" where knvk.kunnr='{0}'", company_id)
        Dim CPdt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sbCP.ToString())
        If CPdt.Rows.Count > 0 Then
            For i As Integer = 0 To CPdt.Rows.Count - 1
                With CPdt.Rows(i)
                    If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso .Item("CONTACT_EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                        external = external & .Item("CONTACT_EMAIL").ToString & ";"
                    End If
                End With
            Next
        End If
    End Sub

    Public Function HtmlToXML(ByVal order_no As String, ByRef XMLDOC As System.Xml.XmlDocument) As String
        Dim HtmlWriter As New StringWriter()
        Dim HtmlPage As String = String.Empty
        Dim mysgmlReader As New SgmlReader

        Try
            Dim client As New WebClient()
            client.Encoding = Encoding.UTF8
            client.QueryString.Add("NO", order_no)
            HtmlPage = client.DownloadString("http://my.advantech.com:4002/Lab/PI_AEU.aspx") 'Temporary path.

            mysgmlReader.DocType = "HTML"
            mysgmlReader.WhitespaceHandling = WhitespaceHandling.All
            mysgmlReader.CaseFolding = CaseFolding.ToLower
            mysgmlReader.InputStream = New System.IO.StringReader(HtmlPage)

            XMLDOC.PreserveWhitespace = True
            XMLDOC.XmlResolver = Nothing
            XMLDOC.Load(mysgmlReader)

        Catch EX As Exception
            Return EX.ToString
        End Try

        Return String.Empty
    End Function

    Public Sub SendWebJobResult(ByVal dt As DataTable, ByVal sb As StringBuilder)
        Dim gv As New GridView()
        gv.DataSource = dt
        gv.DataBind()
        sb.Clear()
        Dim sw As New System.IO.StringWriter(sb)
        Dim html As New System.Web.UI.HtmlTextWriter(sw)
        gv.RenderControl(html)
        Dim body As String = sb.ToString()
        Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
        Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)

        Dim mail As New System.Net.Mail.MailMessage()
        mail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        mail.To.Add(New System.Net.Mail.MailAddress("Frank.Chung@advantech.com.tw"))
        mail.To.Add(New System.Net.Mail.MailAddress("IC.Chen@advantech.com.tw"))
        mail.To.Add(New System.Net.Mail.MailAddress("YL.Huang@advantech.com.tw"))
        mail.Subject = String.Format("EU PI mail resend at {0}", DateTime.Now.ToShortTimeString())
        mail.Body = body
        mail.IsBodyHtml = True
        Try
            sc.Send(mail)
        Catch ex As Exception

        End Try
    End Sub

    Public Sub InsertMyErrLog(ByVal errMsg As String)
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
            Dim cmd As New SqlClient.SqlCommand("INSERT INTO MY_ERR_LOG (ROW_ID, USERID, URL, QSTRING, EXMSG, APPID, CLIENT_INFO) VALUES (@UNIQID, @UID, @URL, @REQSTR, @ERRMSG, 'MY', @CLIENTINFO)", conn)

            With cmd.Parameters
                .AddWithValue("UNIQID", Left(System.Guid.NewGuid().ToString().Replace("-", ""), 10)) : .AddWithValue("UID", "Web job")
                .AddWithValue("URL", String.Empty) : .AddWithValue("REQSTR", String.Empty) : .AddWithValue("ERRMSG", errMsg) : .AddWithValue("CLIENTINFO", String.Empty)
            End With
            conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
        Catch ex As Exception

        End Try
    End Sub
End Class

Public Class BBJob
    Implements IJob

    Public Sub Execute(context As IJobExecutionContext) Implements IJob.Execute
        Try
            BB_GetDT()
            BBT_GetDT()
        Catch ex As Exception
            Call MailUtil.Utility_EMailPage("YL.Huang@advantech.com.tw", "YL.Huang@advantech.com.tw", "", "", "WebJob-BB Cache exception", "", "In ScheduledJob.vb,   Msg: " + ex.ToString + ",  Time: " + Date.Now.ToString)
        End Try
    End Sub

    Protected Sub BB_GetDT()
        'use cache mechanism
        Dim BBDT As New DataTable
        Dim epricer_str As String = "SELECT Item_No FROM Item_TPart_ITP_Master where Customer_ID = 'ADVBBUS' and Approval_No <> 'T0007548'"
        Dim epricer_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("ACLSQL7", epricer_str)
        Dim str_partno As String = String.Empty

        '先從SQL7 epricer 取得所有符合之料號，並做成一個字串待後續select條件使用
        If epricer_dt.Rows.Count > 0 Then
            Dim a As New ArrayList
            For Each r As DataRow In epricer_dt.Rows
                a.Add("'" + r.Item("Item_No") + "'")
            Next
            str_partno = "(" + String.Join(",", a.ToArray()) + ")"
        End If

        '用剛剛組合好的料號集合在SQL6的SAP_Product撈PRODUCT_DESC
        Dim sapproduct_str As String = "SELECT a.PART_NO, a.PRODUCT_DESC from SAP_PRODUCT a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
            " on a.PART_NO = b.PART_NO WHERE a.PART_NO IN " & str_partno & " and b.SALES_ORG = 'TW01' "
        Dim sapproduct_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("MY", sapproduct_str)

        '組合一個string去SAP內撈內部料號，因Oracle DB限定in至多一千個，處理較繁瑣
        Dim ls As List(Of String) = New List(Of String)
        For Each r As DataRow In sapproduct_dt.Rows
            ls.Add("'" + r.Item("PART_NO") + "'")
        Next
        Dim bbinternal_dt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr = ''")

        For i As Integer = 0 To Math.Floor(ls.Count / 1000) Step 1
            If ls.Count - i * 1000 = 0 Then
                Continue For
            ElseIf ls.Count - i * 1000 < 1000 Then
                str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, ls.Count - i * 1000).ToArray()) + ")"
            Else
                str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, 1000).ToArray()) + ")"
            End If

            Dim bbinternal_str As String = "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr in " + str_partno
            Dim bbinternal_tempdt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", bbinternal_str)
            bbinternal_dt.Merge(bbinternal_tempdt)
        Next

        ' 將sapproduct_dt 與 bbinternal_dt 兩張 dt 用 partno left join起來
        Dim temp = From x In sapproduct_dt.AsEnumerable
                   Group Join y In bbinternal_dt.AsEnumerable
                   On x.Field(Of String)("PART_NO") Equals y.Field(Of String)("matnr")
                   Into Group
                   Let y = Group.FirstOrDefault
                   Select PART_NO = x.Field(Of String)("PART_NO"),
                   PRODUCT_DESC = x.Field(Of String)("PRODUCT_DESC"),
                   KDMAT = If(y Is Nothing, Nothing, y.Field(Of String)("kdmat"))

        BBDT.Columns.Add("PART_NO", Type.GetType("System.String"))
        BBDT.Columns.Add("PRODUCT_DESC", Type.GetType("System.String"))
        BBDT.Columns.Add("kdmat", Type.GetType("System.String"))

        For Each item In temp
            Dim dr As DataRow = BBDT.NewRow
            dr.Item("PART_NO") = item.PART_NO
            dr.Item("PRODUCT_DESC") = item.PRODUCT_DESC
            dr.Item("kdmat") = item.KDMAT
            BBDT.Rows.Add(dr)
        Next

        'PartNO 與 desc.準備好後，去SAP撈unit_price
        BBDT.Columns.Add("unit_price", Type.GetType("System.String"))
        Dim ws As New MYSAPDAL
        Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
        For Each r As DataRow In BBDT.Rows
            pin.AddProductInRow(r.Item("part_no"), 1)
        Next
        If ws.GetPrice("ADVBBUS", "ADVBBUS", "TW01", pin, pout, errMsg) Then
            For Each r As DataRow In BBDT.Rows
                Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                    r.Item("unit_price") = "$" + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                End If
            Next
        End If

        'Remove parts which unit_price is 0
        Dim BBDT_Copy As DataTable = BBDT.Copy
        BBDT.Clear()
        For Each d As DataRow In BBDT_Copy.Rows
            If Decimal.Parse(Replace(d.Item("unit_price").ToString, "$", "")) > 0 Then
                BBDT.ImportRow(d)
            End If
        Next

        System.Web.HttpRuntime.Cache.Remove("BBDT")
        System.Web.HttpRuntime.Cache.Insert("BBDT", BBDT, Nothing, Now.AddHours(3), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        'Call MailUtil.Utility_EMailPage("YL.Huang@advantech.com.tw", "YL.Huang@advantech.com.tw", "", "", "WebJob-BB Cache Start 1", "", "Time: " + Date.Now.ToString + "<br/>BBDT Rows: " + BBDT.Rows.Count.ToString)
    End Sub

    Protected Sub BBT_GetDT()
        'use cache mechanism
        Dim BBTDT As New DataTable
        Dim epricer_str As String = "SELECT Item_No FROM Item_TPart_ITP_Master where Customer_ID = 'ADVBBUS' and Approval_No <> 'T0007548'"
        Dim epricer_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("ACLSQL7", epricer_str)
        Dim str_partno As String = String.Empty

        '先從SQL7 epricer 取得所有符合之料號，並做成一個字串待後續select條件使用
        If epricer_dt.Rows.Count > 0 Then
            Dim a As New ArrayList
            For Each r As DataRow In epricer_dt.Rows
                a.Add("'" + r.Item("Item_No") + "'")
            Next
            str_partno = "(" + String.Join(",", a.ToArray()) + ")"
        End If

        '用剛剛組合好的料號集合在SQL6的SAP_Product撈PRODUCT_DESC
        Dim sapproduct_str As String = "SELECT a.PART_NO, a.PRODUCT_DESC from SAP_PRODUCT a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
            "on a.PART_NO = b.PART_NO WHERE a.PART_NO IN " & str_partno &
            " and a.MATERIAL_GROUP in ('ODM','T') and b.SALES_ORG = 'TW01'"
        Dim sapproduct_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("MY", sapproduct_str)

        '組合一個string去SAP內撈內部料號，因Oracle DB限定in至多一千個，處理較繁瑣
        Dim ls As List(Of String) = New List(Of String)
        For Each r As DataRow In sapproduct_dt.Rows
            ls.Add("'" + r.Item("PART_NO") + "'")
        Next
        Dim bbinternal_dt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr = ''")

        For i As Integer = 0 To Math.Floor(ls.Count / 1000) Step 1
            If ls.Count - i * 1000 = 0 Then
                Continue For
            ElseIf ls.Count - i * 1000 < 1000 Then
                str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, ls.Count - i * 1000).ToArray()) + ")"
            Else
                str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, 1000).ToArray()) + ")"
            End If

            Dim bbinternal_str As String = "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr in " + str_partno
            Dim bbinternal_tempdt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", bbinternal_str)
            bbinternal_dt.Merge(bbinternal_tempdt)
        Next

        ' 將sapproduct_dt 與 bbinternal_dt 兩張 dt 用 partno left join起來
        Dim temp = From x In sapproduct_dt.AsEnumerable
                   Group Join y In bbinternal_dt.AsEnumerable
                   On x.Field(Of String)("PART_NO") Equals y.Field(Of String)("matnr")
                   Into Group
                   Let y = Group.FirstOrDefault
                   Select PART_NO = x.Field(Of String)("PART_NO"),
                   PRODUCT_DESC = x.Field(Of String)("PRODUCT_DESC"),
                   KDMAT = If(y Is Nothing, Nothing, y.Field(Of String)("kdmat"))

        BBTDT.Columns.Add("PART_NO", Type.GetType("System.String"))
        BBTDT.Columns.Add("PRODUCT_DESC", Type.GetType("System.String"))
        BBTDT.Columns.Add("kdmat", Type.GetType("System.String"))

        For Each item In temp
            Dim dr As DataRow = BBTDT.NewRow
            dr.Item("PART_NO") = item.PART_NO
            dr.Item("PRODUCT_DESC") = item.PRODUCT_DESC
            dr.Item("kdmat") = item.KDMAT
            BBTDT.Rows.Add(dr)
        Next

        'PartNO 與 desc.準備好後，去SAP撈unit_price
        BBTDT.Columns.Add("unit_price", Type.GetType("System.String"))
        Dim ws As New MYSAPDAL
        Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
        For Each r As DataRow In BBTDT.Rows
            pin.AddProductInRow(r.Item("part_no"), 1)
        Next

        If ws.GetPrice("ADVBBUS", "ADVBBUS", "TW01", pin, pout, errMsg) Then
            For Each r As DataRow In BBTDT.Rows
                Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                    r.Item("unit_price") = "$" + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                End If
            Next
        End If

        'Remove parts which unit_price is 0
        Dim BBTDT_Copy As DataTable = BBTDT.Copy
        BBTDT.Clear()
        For Each d As DataRow In BBTDT_Copy.Rows
            If Decimal.Parse(Replace(d.Item("unit_price").ToString, "$", "")) > 0 Then
                BBTDT.ImportRow(d)
            End If
        Next

        System.Web.HttpRuntime.Cache.Remove("BBTDT")
        System.Web.HttpRuntime.Cache.Insert("BBTDT", BBTDT, Nothing, Now.AddHours(3), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        'Call MailUtil.Utility_EMailPage("YL.Huang@advantech.com.tw", "YL.Huang@advantech.com.tw", "", "", "WebJob-BB Cache Start 2", "", "Time: " + Date.Now.ToString + "<br/>BBTDT Rows: " + BBTDT.Rows.Count.ToString)
    End Sub

End Class

Public Class CPJob
    Implements IJob

    Public Sub Execute(context As IJobExecutionContext) Implements IJob.Execute
        Try
            Dim J As Advantech.Myadvantech.DataAccess.CheckPointWS.Job = New Advantech.Myadvantech.DataAccess.CheckPointWS.Job()
            J.job()
        Catch ex As Exception
            Call MailUtil.Utility_EMailPage("YL.Huang@advantech.com.tw", "YL.Huang@advantech.com.tw", "", "", "WebJob-Check Point exception", "", "In ScheduledJob.vb, Msg: " + ex.ToString + ", Time: " + Date.Now.ToString)
        End Try
    End Sub
End Class

Public Class ProjectRegistrationJob
    Implements IJob
    Public Sub Execute(context As IJobExecutionContext) Implements IJob.Execute
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("MyLocal", " select distinct ma.ROW_ID from MY_PRJ_REG_MASTER ma left join MY_PRJ_REG_AUDIT au on ma.ROW_ID = au.PRJ_ROW_ID inner join MY_PRJ_REG_PRIMARY_SALES_EMAIL se on ma.ROW_ID= se.PRJ_ROW_ID where au.STATUS is null ")
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                For Each dr As DataRow In dt.Rows
                    Dim count As Object = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select COUNT(*) from MY_PRJ_REG_OPTY_AUTO_CREATED_TIMES where PRJ_ROW_ID = '{0}' ", dr.Item("ROW_ID").ToString))
                    If Not count Is Nothing AndAlso Integer.Parse(count) = 0 Then
                        dbUtil.dbExecuteNoQuery("MyLocal", String.Format(" insert into MY_PRJ_REG_OPTY_AUTO_CREATED_TIMES values('{0}', 'FAILED', 0, GETDATE(), '') ", dr.Item("ROW_ID").ToString))
                    End If
                Next
            End If

            dt = dbUtil.dbGetDataTable("MyLocal", " select top 3 * from MY_PRJ_REG_OPTY_AUTO_CREATED_TIMES where PRJ_STATUS = 'FAILED' and RE_CREATED_TIMES < 3 order by CREATED_DATE desc ")
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                Dim list As New List(Of ProjectRegistrationJob)
                For Each dr As DataRow In dt.Rows
                    Dim result As Tuple(Of Boolean, String) = RecreateOpty(dr.Item("PRJ_ROW_ID").ToString)
                    If Not result Is Nothing AndAlso result.Item1 = False Then
                        Dim times As Integer = 0
                        If Integer.TryParse(dr.Item("RE_CREATED_TIMES").ToString, times) = True Then
                            times += 1
                        Else
                            times = 3
                        End If
                        dbUtil.dbExecuteNoQuery("MyLocal", String.Format(" update MY_PRJ_REG_OPTY_AUTO_CREATED_TIMES set RE_CREATED_TIMES ={0} where PRJ_ROW_ID = '{1}' ", times, dr("PRJ_ROW_ID").ToString))
                        list.Add(New ProjectRegistrationJob(dr.Item("PRJ_ROW_ID").ToString, "Failed", result.Item2))
                    ElseIf Not result Is Nothing AndAlso result.Item1 = True Then
                        list.Add(New ProjectRegistrationJob(dr.Item("PRJ_ROW_ID").ToString, "Success", String.Empty))
                    End If
                Next

                If list.Count > 0 Then
                    Dim gv As New GridView()
                    gv.DataSource = list
                    gv.DataBind()
                    Dim sb As New StringBuilder()
                    Dim sw As New System.IO.StringWriter(sb)
                    Dim html As New System.Web.UI.HtmlTextWriter(sw)
                    gv.RenderControl(html)
                    Dim body As String = sb.ToString()
                    Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
                    Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)

                    Dim mail As New System.Net.Mail.MailMessage()
                    mail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
                    'mail.To.Add(New System.Net.Mail.MailAddress("Frank.Chung@advantech.com.tw"))
                    mail.To.Add(New System.Net.Mail.MailAddress("IC.Chen@advantech.com.tw"))
                    'mail.To.Add(New System.Net.Mail.MailAddress("YL.Huang@advantech.com.tw"))
                    mail.Subject = String.Format("Project registration re-create opportunity mail sent at {0}", DateTime.Now.ToShortTimeString())
                    mail.Body = body
                    mail.IsBodyHtml = True
                    sc.Send(mail)
                End If
            End If
        Catch ex As Exception
            Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
            Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)

            Dim mail As New System.Net.Mail.MailMessage()
            mail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
            mail.To.Add(New System.Net.Mail.MailAddress("IC.Chen@advantech.com.tw"))
            mail.Subject = "Opty re-create failed"
            mail.Body = ex.ToString
            Try
                sc.Send(mail)
            Catch exx As Exception

            End Try
        End Try
        
    End Sub

    Public Shared Function RecreateOpty(ByVal rid As String) As Tuple(Of Boolean, String)
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim Prj_M_DataTable As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = Prj_M_A.GetDataByRowID(rid)
        If Not Prj_M_DataTable Is Nothing AndAlso Prj_M_DataTable.Rows.Count > 0 Then
            Dim prjMasterRow As InterConPrjReg.MY_PRJ_REG_MASTERRow = Prj_M_DataTable.Rows(0)

            Dim Prj_R_Competitor As New InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter
            Dim prjCompetitorTable As InterConPrjReg.MY_PRJ_REG_COMPETITORSDataTable = Prj_R_Competitor.GetListByPrjRowID(rid)
            Dim prjCompetitorRow As InterConPrjReg.MY_PRJ_REG_COMPETITORSRow = Nothing
            If Not prjCompetitorTable Is Nothing AndAlso prjCompetitorTable.Rows.Count > 0 Then
                prjCompetitorRow = prjCompetitorTable.Rows(0)
            End If

            Dim Prj_R_Product As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
            Dim prjProductTable As InterConPrjReg.MY_PRJ_REG_PRODUCTSDataTable = Prj_R_Product.GetDataByPRJ_ROW_ID(rid)
            Dim prjProductRow As InterConPrjReg.MY_PRJ_REG_PRODUCTSRow = Nothing
            If Not prjProductTable Is Nothing AndAlso prjProductTable.Rows.Count > 0 Then
                prjProductRow = prjProductTable.Rows(0)
            End If

            Dim prjname As String = prjMasterRow.PRJ_NAME, prjdesc As String = prjMasterRow.PRJ_DESC
            If prjMasterRow.PRJ_NAME.Length > 100 Then
                prjname = prjMasterRow.PRJ_NAME.Substring(0, 100)
            End If
            If prjMasterRow.PRJ_DESC.Length > 255 Then
                prjdesc = prjMasterRow.PRJ_DESC.Substring(0, 255)
            End If

            Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 RBU from siebel_account where RBU is not null and RBU<>'' and ERP_ID = '{0}' order by account_status", prjMasterRow.CP_COMPANY_ID))
            Dim org As String = "ACL"
            If Not obj Is Nothing AndAlso Not String.IsNullOrEmpty(obj) Then org = obj.ToString

            Dim primarySalesEmail As String = String.Empty
            obj = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select top 1 ISNULL(PRIMARY_SALES_EMAIL,'') from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}' ", rid))
            If Not obj Is Nothing AndAlso Not String.IsNullOrEmpty(obj) Then primarySalesEmail = obj.ToString

            Dim pr As New Advantech.Myadvantech.DataAccess.ProjectRegistration()
            pr.Account_Row_ID = prjMasterRow.CP_ACCOUNT_ROW_ID
            pr.Project_Name = prjname
            pr.Close_Date = prjMasterRow.PRJ_EST_CLOSE_DATE.ToString("MM/dd/yyyy")
            pr.Currency = prjMasterRow.PRJ_AMT_CURR
            pr.Revenue = InterConPrjRegUtil.GetTotalAmountByID(rid)
            pr.Contact_Row_ID = USPrjRegUtil.GetContactRowId(prjMasterRow.CREATED_BY)
            pr.RBU = org
            pr.Owner_Email = primarySalesEmail
            pr.Description = prjdesc

            If Not prjCompetitorRow Is Nothing Then
                pr.Competition = prjCompetitorRow.COMPETITOR_NAME
            End If

            If Not prjProductRow Is Nothing Then
                Dim ps As New List(Of Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct)
                Dim p As New Advantech.Myadvantech.DataAccess.ProjectRegistrationProduct()
                p.Main_Product = prjProductRow.PART_NO
                p.Main_Product_Qty = prjProductRow.QTY
                ps.Add(p)
                pr.Products = ps
            End If

            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.SiebelDAL.CreateSiebelOpty4PrjReg(pr)
            If result.Item1 = True Then
                Prj_M_A.UpdateOptyID(result.Item2, rid)
                Threading.Thread.Sleep(2000) : MYSIEBELDAL.SyncSiebelOpty(result.Item2)
                InterConPrjRegUtil.CreateStatus(rid)
                Sendmail(rid, prjMasterRow.CP_COMPANY_ID, prjMasterRow.PRJ_NAME, prjMasterRow.CREATED_BY)
                dbUtil.dbExecuteNoQuery("MyLocal", String.Format(" update MY_PRJ_REG_OPTY_AUTO_CREATED_TIMES set PRJ_STATUS = 'SUCCESS' where PRJ_ROW_ID = '{0}' ", rid))
            End If
            Return result
        End If
        Return Nothing
    End Function

    Public Shared Function Sendmail(ByVal rid As String, ByVal company As String, ByVal prjName As String, ByVal user As String) As Integer
        Dim CPName As String = company
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim obj As Object = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select top 1 ISNULL(PRIMARY_SALES_EMAIL,'') from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}' ", rid))
        Dim salesEmail As String = "MyAdvantech@advantech.com"
        If Not obj Is Nothing AndAlso Not String.IsNullOrEmpty(obj) Then salesEmail = obj.ToString

        Dim TOstr As String = salesEmail, CCstr As String = "ChannelManagement.ACL@advantech.com", Receiver As String = ""
        Dim mailTitle As String = "A Project registration is applied by channel partner " + user + " (" + CPName + ")"
        Receiver = Util.GetNameVonEmail(salesEmail)

        Dim mailBody As New System.Text.StringBuilder
        With mailBody
            .AppendLine(String.Format("Dear {0},<br />", Receiver))
            .AppendLine(String.Format("  <br />"))
            .AppendLine(String.Format("""{2}"" is applied by {1}, customer id: {0}  <br />", CPName, user, prjName))
            .AppendLine(String.Format("Please check the detail below:  <br />"))
            .AppendLine(String.Format("<a href='http://my.advantech.com//My/InterCon/PrjDetail.aspx?ROW_ID={0}'>MyAdvantech Project Registration detail page</a><br />", rid))
            .AppendLine(String.Format("Thank you.  <br />"))
            .AppendLine(String.Format("Best Regards,  <br />"))
            .AppendLine(String.Format("<a href='mailto:MyAdvantech@advantech.com'>MyAdvantech IT Team</a>  <br />"))
        End With
        Util.SendEmail(TOstr, "myadvantech@advantech.com", mailTitle, mailBody.ToString(), True, CCstr, "MyAdvantech@advantech.com")
        Return 1
    End Function

    Private rid As String
    Public Property RowID As String
        Get
            Return rid
        End Get
        Set(ByVal value As String)
            rid = value
        End Set
    End Property

    Private status As String
    Public Property OptyStatus As String
        Get
            Return status
        End Get
        Set(ByVal value As String)
            status = value
        End Set
    End Property

    Private reason As String
    Public Property Message As String
        Get
            Return reason
        End Get
        Set(ByVal value As String)
            reason = value
        End Set
    End Property

    Sub New()

    End Sub

    Sub New(ByVal rid As String, ByVal status As String, ByVal reason As String)
        Me.RowID = rid
        Me.OptyStatus = status
        Me.Message = reason
    End Sub
End Class

Public Class BBorder2SAP
    Implements IJob

    Public Sub Execute(context As IJobExecutionContext) Implements IJob.Execute

        'Dim _SMTPServer As String = ConfigurationManager.AppSettings("SMTPServer")
        'Dim sc As New System.Net.Mail.SmtpClient(_SMTPServer)
        'Dim mail As New System.Net.Mail.MailMessage()
        'mail.From = New Net.Mail.MailAddress("IC.Chen@advantech.com.tw")
        'mail.To.Add(New System.Net.Mail.MailAddress("IC.Chen@advantech.com.tw,Tc.Chen@advantech.com.tw,YL.Huang@advantech.com.tw"))
        'mail.Subject = String.Format("BB eStore order to SAP at {0}", DateTime.Now.ToShortTimeString())
        'mail.IsBodyHtml = True

        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "SELECT ORDER_NO FROM BB_ESTORE_ORDER WHERE ORDER_STATUS = 'UnProcess' ORDER BY CREATED_DATE")
        'If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
        '    Dim results As List(Of BBorderSync.WebServiceResult) = New List(Of BBorderSync.WebServiceResult)
        '    For Each dr As DataRow In dt.Rows
        '        Dim api As BBorderSync.BBorderAPI = New BBorderSync.BBorderAPI()
        '        api.Timeout = 60000
        '        Try
        '            Dim result = api.Process(dr.Item("ORDER_NO").ToString)
        '            If result.Result = False Then
        '                dbUtil.dbExecuteNoQuery("MY", String.Format("UPDATE BB_ESTORE_ORDER SET ORDER_STATUS = N'Failed', PROCESS_LOG = N'{0}', UPDATED_DATE = GETDATE() WHERE ORDER_NO = N'{1}'", result.Message, dr.Item("ORDER_NO").ToString))
        '            Else
        '                dbUtil.dbExecuteNoQuery("MY", String.Format("UPDATE BB_ESTORE_ORDER SET ORDER_STATUS = N'Success', UPDATED_DATE = GETDATE() WHERE ORDER_NO = N'{0}'", dr.Item("ORDER_NO").ToString))
        '            End If
        '            results.Add(result)
        '        Catch ex As Exception
        '            mail.Body = ex.ToString
        '            'sc.Send(mail)
        '        End Try

        '    Next
        '    If results.Count > 0 Then
        '        Dim gv As New GridView()
        '        gv.DataSource = results.Select(Function(p) New With _
        '                                              {.OrderNo = p.OrderNo, .Result = p.Result.ToString, .Message = p.Message}).ToList()
        '        gv.DataBind()
        '        Dim sb As New StringBuilder()
        '        Dim sw As New System.IO.StringWriter(sb)
        '        Dim html As New System.Web.UI.HtmlTextWriter(sw)
        '        gv.RenderControl(html)
        '        mail.Body = sb.ToString()
        '    End If
        '    sc.Send(mail)
        'Else
        '    'No dato
        'End If
    End Sub

End Class