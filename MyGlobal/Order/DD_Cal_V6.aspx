<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" Title="MyAdvantech - Due Date Calculation" %>

<%@ Import Namespace="System.Drawing" %>
<%@ Register TagPrefix="uc3" TagName="OrderFlowState" Src="~/Includes/OrderFlowState.ascx" %>
<script runat="server">
    
    Dim StrLogistics_Id As String = ""
    Dim judgedate As String = ""
    ' Peter add 2008/04/30
    Dim dtOne, dtTwo As DataTable
    
    Shared Function getCustomerNo(ByVal CompanyID As String, ByVal MaterialNo As String) As String
        'Dim CustomerNo As Object = dbUtil.dbExecuteScalar("B2B", "select top 1 isnull(CustMaterialNo,'') from CustMaterialMapping where Org='EU10' AND DistrChannel='00' AND customerid='" & CompanyID & "' AND MaterialNo='" & MaterialNo & "'")
        'If Not IsNothing(CustomerNo) AndAlso CustomerNo.ToString <> "" Then
        '    Return CustomerNo
        'End If
        Return ""
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim DMF_Flag As Integer = 99
        Dim OptyID As String = ""
        If Request("DMF") <> "" Then
            DMF_Flag = Request("DMF")
        End If
        
        If Not Session("OptyID") Is Nothing Then
            OptyID = Session("OptyID")
        End If
        
        StrLogistics_Id = Session("cart_id")
        If Trim(StrLogistics_Id) = "" Then Exit Sub
        If Not Page.IsPostBack Then
            'Jackie add 20071009 for customer's sales note issue
            'Dim dt_salesnote As DataTable = dbUtil.dbGetDataTable("B2B", "select SalesNote from CustomerSalesNote where CustomerId='" & Session("company_id") & "'")
            'If dt_salesnote.Rows.Count > 0 Then
            '    dbUtil.dbExecuteNoQuery("B2B", "update logistics_master set sales_note='" & _
            '        dt_salesnote.Rows(0).Item("SalesNote").ToString.Replace("'", "''") & _
            '        "',DefaultSalesNote='Y' where logistics_id='" & Session("logistics_id") & "'")
            'End If
            If Util.IsAEUIT() Or _
               Util.IsInternalUser2() Then
                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" update MyAdvantechGlobal.dbo.logistics_detail set logistics_detail.DeliveryPlant=p.DeliveryPlant "))
                    .AppendLine(String.Format(" from sap_product_org p  "))
                    .AppendLine(String.Format(" where logistics_detail.part_no=p.part_no " + _
                                              " and logistics_id='{0}' and p.org_id='{1}' ", Session("logistics_id"), Session("org_id")))
                End With
                dbUtil.dbExecuteNoQuery("B2B", sb.ToString())
                'dbUtil.dbExecuteNoQuery("B2B", _
                '    "update logistics_detail set logistics_detail.DeliveryPlant=p.DeliveryPlant" & _
                '    " from Product p where logistics_detail.part_no=p.part_no and logistics_id='" & Session("logistics_id") & "' and line_no<100")
            End If
            
            'Nada add for DMF_Flag
            If DMF_Flag = 1 Then
                dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set DMF_Flag='E1'" & _
                    " WHERE logistics_id='" & Session("logistics_id") & "'")
            ElseIf DMF_Flag = 0 Then
                'Response.Write(DMF_Flag)
                dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set DMF_Flag=''" & _
                    " WHERE logistics_id='" & Session("logistics_id") & "'")
            End If
            
            If OptyID <> "" Then
                dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set Optyid='" & OptyID & "'" & _
                    " WHERE logistics_id='" & Session("logistics_id") & "'")
            Else
                dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set Optyid=''" & _
                    " WHERE logistics_id='" & Session("logistics_id") & "'")
            End If
            
            'Dim g_adoConn As New SqlClient.SqlConnection
            Dim flgReqChange As String = "No", strSQL As String = "", xadoDR As DataTable
            strSQL = "select required_date from logistics_master where logistics_id = '" & _
            Session("LOGISTICS_ID") & "'"
            xadoDR = dbUtil.dbGetDataTable("B2B", strSQL)
            Dim exeFunc As Integer = 0
            Dim dtDefaultReqDate As String = "", dtReqDate As String = "", CustomerInputReqDate As String = ""
            If xadoDR.Rows.Count > 0 Then
                dtDefaultReqDate = Global_Inc.FormatDate(Date.Now.Date)
                If CDate(dtDefaultReqDate) <= CDate(xadoDR.Rows(0).Item("required_date")) Then
                    dtReqDate = Global_Inc.FormatDate(xadoDR.Rows(0).Item("required_date"))
                    flgReqChange = "Yes"
                Else
                    dtReqDate = Global_Inc.FormatDate(dtDefaultReqDate)
                End If
                'If user's req_date is later than default, use user's.
                strSQL = "update logistics_detail set required_date = '" & _
                CDate(dtReqDate) & "' where logistics_id = '" & Session("LOGISTICS_ID") & "'"
                
                dbUtil.dbExecuteNoQuery("B2B", strSQL)
                CustomerInputReqDate = dtReqDate
               
            End If
                     
            Dim sdr As DataTable
            Dim soldto_id, shipto_id As String
            soldto_id = Session("company_id")
            shipto_id = soldto_id
            sdr = dbUtil.dbGetDataTable("B2B", _
            "select isnull(shipto_id,'') as shipto_id from logistics_master where logistics_id='" & StrLogistics_Id & "'")
            If sdr.Rows.Count > 0 Then
                shipto_id = sdr.Rows(0).Item("shipto_id")
            Else
                shipto_id = Session("company_id")
            End If
            
            Dim dr As DataTable, oRsATPi As New DataTable : Global_Inc.InitRsATPi(oRsATPi)
            Dim oRsATP As New DataTable : Global_Inc.InitATPRs(oRsATP)
            dr = dbUtil.dbGetDataTable("B2B", _
            "select part_no,DeliveryPlant, sum(qty) as qty_sub from logistics_detail where logistics_id='" & _
            StrLogistics_Id & "' group by part_no,DeliveryPlant ")
            Dim dt1 As DataTable = dbUtil.dbGetDataTable("B2B", "select required_date from logistics_master where logistics_id='" & Session("logistics_id") & "'")
            Dim ACL_Required_Date As String = ""
            If dt1.Rows.Count > 0 Then
                ACL_Required_Date = Global_Inc.FormatDate(dt1.Rows(0).Item("Required_date"))
            End If
            
            For Each r As DataRow In dr.Rows
                Dim row1 As DataRow = oRsATPi.NewRow()
                Dim xDP As String = r.Item("DeliveryPlant").Trim().ToUpper()
                If xDP = "" Then xDP = "EUH1"
                row1.Item("WERK") = xDP
                row1.Item("MATNR") = r.Item("part_no").Trim().ToUpper()
                row1.Item("REQ_QTY") = r.Item("qty_sub")
                If row1.Item("WERK") = "EUH1" Then
                    row1.Item("REQ_DATE") = System.DateTime.Today()
                Else
                    row1.Item("REQ_DATE") = CDate(ACL_Required_Date)
                End If
                row1.Item("UNI") = "PC" : oRsATPi.Rows.Add(row1)
            Next
            Dim strSendXml As String = Global_Inc.DataTableToADOXML(oRsATPi)
            Dim strRecXml As String = "", strRemark As String = ""
            Dim sc3 As New B2BAEU_SAP_WS.B2B_AEU_WS
            Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc3.Url)
            Dim sales_org As String = Session("org_id")
            Dim distr_chan As String = "10", division As String = "00"
            If Trim(sales_org).ToUpper() = "US01" Then
                distr_chan = "30" : division = "10"
            End If
            Try
                sc3.Timeout = 99999999
                Dim iRtn As Integer = sc3.GetMultiDueDate(soldto_id.ToUpper.Trim, shipto_id.ToUpper.Trim, _
            sales_org, distr_chan, division, strSendXml, strRecXml, strRemark)
            Catch ex As Exception
                Response.Write(ex.ToString() & "Error") : Response.End()
            End Try
            
            'Response.Write(strSendXml & "" & strRecXml & "" & strRemark)
            Dim ATPResultTable As DataTable = Nothing
            Dim ResultDs As DataSet
            Dim sr As IO.StringReader
            
            If Not strRemark.Trim().Equals("") Then
                If Util.IsAEUIT() Or Util.IsInternalUser2() Then
                    Dim AlertScript As String = _
                    "<Script language='javascript'>" & vbCrLf & _
                    "alert('SAP error: " & strRemark & "." & " " & _
                    "due date may be incorrect, please contact eBusiness.AEU, thank you.');" & vbCrLf & _
                    "</" & "Script>"
                    ClientScript.RegisterStartupScript(Me.GetType(), "Alert", AlertScript)
                End If
                
                ATPResultTable = New DataTable("row")
                
                Dim FakeDueDate As String = _
                Global_Inc.stdDate2SAPDate(DateAdd(DateInterval.Day, 30, Today()))
                
                ATPResultTable = dbUtil.dbGetDataTable("B2B", _
                    " select 'EU10' as entity, part_no as part, " & _
                    " DeliveryPlant as site, sum(qty) as qty_req, '" & FakeDueDate & "' as date, " & _
                    " '' as flag, '' as type, sum(qty) as qty_atb, sum(qty) as qty_atp, " & _
                    " 0 as qty_lack, sum(qty) as qty_fulfill, '0' as flag_scm from logistics_detail where logistics_id='" & _
                    StrLogistics_Id & "' group by part_no,DeliveryPlant")
            Else
                sr = New System.IO.StringReader(strRecXml)
                ResultDs = New DataSet
                Try
                    ResultDs.ReadXml(sr)
                Catch ex As Exception
                    Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "error reading due date xml in dd cal v6", ex.ToString() + "<br/>" + strRecXml + "<br/>" + strRemark, True, "", "")
                    'Exit Sub
                End Try
               
                ResultDs.Tables(ResultDs.Tables.Count - 1).AcceptChanges()
                ResultDs.Relations.Clear()
                ATPResultTable = ResultDs.Tables("row")
                If Not ATPResultTable Is Nothing Then
               
                    'response.Write(strRecXml) 
                    'Response.End()
                    ATPResultTable.Constraints.Clear()
                    ATPResultTable.Columns.Remove("mandt")
                    ATPResultTable.Columns.Remove("due_date")
                    ATPResultTable.Columns.Remove("due_date_scm")
                    ATPResultTable.Columns.Remove("atp_date_scm")
                    ATPResultTable.Columns.Remove("insert_Id")
                    ATPResultTable.DefaultView.Sort = "site,part,date"
                    ATPResultTable.AcceptChanges()
                    
                    'dg2.DataSource = ATPResultTable : dg2.DataBind()
                Else
                    'jackie add 2007/08/29 for only acl and atp=0 case
                    ATPResultTable = dbUtil.dbGetDataTable("B2B", _
                    " select 'EU10' as entity, part_no as part, " & _
                    " DeliveryPlant as site, sum(qty) as qty_req, '" & "2020/10/10" & "' as date, " & _
                    " '' as flag, '' as type, sum(qty) as qty_atb, sum(qty) as qty_atp, " & _
                    " 0 as qty_lack, sum(qty) as qty_fulfill, '0' as flag_scm from logistics_detail where logistics_id='" & _
                    StrLogistics_Id & "' and DeliveryPlant like 'TW%' group by part_no,DeliveryPlant ")
                    'jackie add 2007/12/04 for the Z1 atp new rule
                    
                    For i As Integer = 0 To oRsATPi.Rows.Count - 1
                        If Left(oRsATPi.Rows(i).Item("WERK"), 2) <> "TW" Then
                            Dim drr As DataRow = ATPResultTable.NewRow
                            drr.Item("entity") = "EUH1"
                            drr.Item("part") = oRsATPi.Rows(i).Item("MATNR")
                            drr.Item("site") = oRsATPi.Rows(i).Item("WERK")
                            drr.Item("qty_req") = oRsATPi.Rows(i).Item("REQ_QTY")
                            drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), oRsATPi.Rows(i).Item("MATNR"), Today)
                            drr.Item("flag") = ""
                            drr.Item("type") = ""
                            drr.Item("qty_atb") = oRsATPi.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_atp") = oRsATPi.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_lack") = 0
                            drr.Item("qty_fulfill") = oRsATPi.Rows(i).Item("REQ_QTY")
                            drr.Item("flag_scm") = "-1"
                            ATPResultTable.Rows.Add(drr)
                           
                            dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set NoATPFlag='Y'" & _
                                " where logistics_id='" & Session("logistics_id") & "' and part_no='" & _
                                oRsATPi.Rows(i).Item("MATNR") & "' and DeliveryPlant='" & _
                                oRsATPi.Rows(i).Item("WERK") & "'")
                                 
                        End If
                    Next
                End If
                'add the TBD due date
                Dim OriginalCount As Integer = ATPResultTable.Rows.Count
                
                Dim strsql1 As String = ""
                
                For Each drSend As DataRow In oRsATPi.Rows
                    Dim flg As Boolean = False
                    For i As Integer = 0 To OriginalCount - 1
                        If ATPResultTable.Rows(i).Item("part") = drSend.Item("MATNR") And _
                            ATPResultTable.Rows(i).Item("site") = drSend.Item("WERK") Then
                            flg = True
                            Exit For
                        End If
                    Next
                    If Not flg Then
                        If Left(drSend.Item("WERK").ToString.ToUpper, 2) = "TW" Then
                            Dim aa As DataRow = ATPResultTable.NewRow
                            aa.Item("part") = drSend.Item("MATNR")
                            aa.Item("site") = drSend.Item("WERK")
                            aa.Item("qty_atp") = 0
                            aa.Item("qty_atb") = 0
                            aa.Item("qty_req") = drSend.Item("REQ_QTY")
                            aa.Item("entity") = "EU10"
                            aa.Item("flag_scm") = "0"
                            aa.Item("date") = "2020/10/10" 'TBD
                            strsql1 &= "update logistics_detail set DUE_DATE='2020/10/10' where logistics_id='" & _
                                Session("logistics_id") & "' and Part_No='" & drSend.Item("MATNR") & "' and DeliveryPlant='" & drSend.Item("WERK") & "' and DeliveryPlant like 'TW%';"
                            ATPResultTable.Rows.Add(aa)
                        Else
                            Dim drr As DataRow = ATPResultTable.NewRow
                            drr.Item("entity") = "EUH1"
                            drr.Item("part") = drSend.Item("MATNR")
                            drr.Item("site") = drSend.Item("WERK")
                            drr.Item("qty_req") = drSend.Item("REQ_QTY")
                            drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), drSend.Item("MATNR"), Today)
                            drr.Item("flag") = ""
                            drr.Item("type") = ""
                            drr.Item("qty_atb") = drSend.Item("REQ_QTY")
                            drr.Item("qty_atp") = drSend.Item("REQ_QTY")
                            drr.Item("qty_lack") = 0
                            drr.Item("qty_fulfill") = drSend.Item("REQ_QTY")
                            drr.Item("flag_scm") = "-1"
                            ATPResultTable.Rows.Add(drr)
                            
                            dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set NoATPFlag='Y'" & _
                                " where logistics_id='" & Session("logistics_id") & "' and part_no='" & _
                                drSend.Item("MATNR") & "' and DeliveryPlant='" & _
                                drSend.Item("WERK") & "'")
                                
                        End If
                    End If
                Next
                
                If strsql1 <> "" Then
                
                    dbUtil.dbExecuteNoQuery("B2B", strsql1)
                    
                End If
                
            End If
            Dim currPartNo As String = ""
            Dim cumATP As Integer = 0
            Dim SUPPLY_LT_Flag As Boolean = False
            Dim dr1 As DataTable = dbUtil.dbGetDataTable("B2B", _
            "select distinct part_no,DeliveryPlant from logistics_detail where logistics_id='" & _
            StrLogistics_Id & "'")
            Dim ATPResultTb As New DataTable()
            For i As Integer = 0 To ATPResultTable.Columns.Count - 1
                Dim col1 As New DataColumn(ATPResultTable.Columns.Item(i).ColumnName, _
                ATPResultTable.Columns.Item(i).DataType)
                ATPResultTb.Columns.Add(col1)
            Next
        
            'jackie add 200712/03 for Z1 atp rule
            Dim ATPResultDummy As New DataTable
            ATPResultDummy = ATPResultTable
            For i As Integer = 0 To ATPResultTable.Rows.Count - 1
                If UCase(ATPResultTable.Rows(i).Item("part")) Like "OPTION*" Or _
                UCase(ATPResultTable.Rows(i).Item("part")) Like "S-WARRANTY*" Or _
                UCase(ATPResultTable.Rows(i).Item("part")) Like "AGS-EW-*" Then
                    ATPResultTable.Rows(i).Item("date") = DateAdd(DateInterval.Day, 1, Today())
                Else
                    '--{2005-8-22}--Daive: Create a Promotion Flag in description
                    '---------------------------------------------------------------------------------------------------------
                    'If LCase(Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                    If Global_Inc.PromotionRelease() = True Then
                        Dim PromotionFlagSQL As String = ""
                        Dim PromotionFlagDatareader As DataTable
                        PromotionFlagSQL = "select PART_NO,ONHAND_QTY,PromotionType from PROMOTION_PRODUCT_INFO where START_DATE < '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and PART_NO='" & UCase(ATPResultTable.Rows(i).Item("part")) & "' and Status='Yes'"
                        PromotionFlagDatareader = dbUtil.dbGetDataTable("B2B", PromotionFlagSQL)
                        If PromotionFlagDatareader.Rows.Count > 0 AndAlso PromotionFlagDatareader.Rows(0).Item("PromotionType") = "smp" Then
                            ATPResultTable.Rows(i).Item("date") = DateAdd(DateInterval.Day, 1, Today())
                        End If
                        'g_adoConn.Close()
                    End If
                    '---------------------------------------------------------------------------------------------------------
                End If
            Next
            
            'jackie add 2007/12/03 for Z1 ATP new rule START
            'insert the dummy record
            For Each r As DataRow In dr1.Rows
                Dim dtRow As DataRow()
                'dtRow = ATPResultTable.Select("part='" & r.Item("part_no") & "' and site='" & _
                '            "EUH1" & "'", "part asc,date asc")
                dtRow = ATPResultTable.Select("part='" & r.Item("part_no") & "'", "part asc,date asc")
                cumATP = 0 : Dim qtyTotal As Integer = 0 : Dim qtyRequired As Integer = 0
                SUPPLY_LT_Flag = False
                Dim rowCount As Integer = dtRow.GetUpperBound(0)
                For i As Integer = 0 To rowCount
                    dtRow(i).Item("qty_atp") = dtRow(i).Item("qty_atb") + cumATP
                    dtRow(i).Item("type") = "5"
                    cumATP = dtRow(i).Item("qty_atp")
                    dtRow(i).Item("qty_lack") = dtRow(i).Item("qty_req") - dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") < 0 Then dtRow(i).Item("qty_lack") = 0
                    dtRow(i).Item("qty_fulfill") = dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") = 0 And SUPPLY_LT_Flag.Equals(False) Then
                        dtRow(i).Item("type") = "6"
                        SUPPLY_LT_Flag = True
                    End If
                    qtyTotal = dtRow(i).Item("qty_atp")
                    qtyRequired = dtRow(i).Item("qty_req")
                Next
                
                If Not SUPPLY_LT_Flag Then
                    Dim row1 As DataRow = ATPResultDummy.NewRow()
                    row1.Item("entity") = dtRow(rowCount).Item("entity")
                    row1.Item("part") = dtRow(rowCount).Item("part")
                    row1.Item("site") = dtRow(rowCount).Item("site")
                    row1.Item("qty_req") = qtyRequired
                   
                    Dim xDate As String = Global_Inc.GetRPL(Session("company_id"), dtRow(rowCount).Item("part"), System.DateTime.Today)
                    row1.Item("date") = xDate.Replace("/", "-")
                    row1.Item("type") = "6" 'dtRow(rowCount).Item("type")
                    row1.Item("qty_atp") = qtyRequired
                    row1.Item("qty_atb") = qtyRequired - qtyTotal
                    row1.Item("qty_fulfill") = qtyRequired
                    row1.Item("qty_lack") = "0"
                    row1.Item("flag_scm") = "-1"
                    ATPResultDummy.Rows.Add(row1)
                    
                    dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set NoATPFlag='Y'" & _
                               " where logistics_id='" & Session("logistics_id") & "' and part_no='" & _
                               r.Item("part_no") & "' and DeliveryPlant='" & _
                               r.Item("DeliveryPlant") & "'")
                    'row1.Item("flag_scm") = dtRow(i).Item("flag_scm")
                End If
            Next
            
            ATPResultDummy.DefaultView.Sort = "part asc, date asc"
            ATPResultDummy = ATPResultDummy.DefaultView.ToTable
            'dg2.DataSource = ATPResultDummy : dg2.DataBind()
            
            ATPResultTable.Rows.Clear()
            ATPResultTable.Merge(ATPResultDummy)
            ATPResultTable.DefaultView.Sort = "part asc, date asc"
            ATPResultTable = ATPResultTable.DefaultView.ToTable
            'jackie add 2007/12/03 END
            
            'Dim dr_tbd() As DataRow
            'jackie 20071203 survey how to make datareader go to the first row?
            dr1 = dbUtil.dbGetDataTable("B2B", _
            "select distinct part_no,DeliveryPlant from logistics_detail where logistics_id='" & _
            StrLogistics_Id & "'")
            For Each r As DataRow In dr1.Rows
                Dim dtRow As DataRow()
                dtRow = ATPResultTable.Select("part='" & r.Item("part_no") & "' and site='" & _
                            r.Item("DeliveryPlant") & "'", "part asc,date asc")
                cumATP = 0
                SUPPLY_LT_Flag = False
                For i As Integer = 0 To dtRow.GetUpperBound(0)
                    dtRow(i).Item("qty_atp") = dtRow(i).Item("qty_atb") + cumATP
                    dtRow(i).Item("type") = "5"
                    cumATP = dtRow(i).Item("qty_atp")
                    dtRow(i).Item("qty_lack") = dtRow(i).Item("qty_req") - dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") < 0 Then dtRow(i).Item("qty_lack") = 0
                    dtRow(i).Item("qty_fulfill") = dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") = 0 And SUPPLY_LT_Flag.Equals(False) Then
                        dtRow(i).Item("type") = "6"
                        SUPPLY_LT_Flag = True
                    End If
                Next
                'if not satisfy all then insert TBD
                If Not SUPPLY_LT_Flag Then
                    dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set DUE_DATE='2020/10/10' where logistics_id='" & _
                            Session("logistics_id") & "' and Part_No='" & r.Item("part_no") & "' and DeliveryPlant='" & r.Item("DeliveryPlant") & "' and DeliveryPlant<>'EUH1'")
                End If
                
                For i As Integer = 0 To dtRow.GetUpperBound(0)
                    Dim row1 As DataRow = ATPResultTb.NewRow()
                    row1.Item("entity") = dtRow(i).Item("entity")
                    row1.Item("part") = dtRow(i).Item("part")
                    row1.Item("site") = dtRow(i).Item("site")
                    row1.Item("qty_req") = dtRow(i).Item("qty_req")
                    row1.Item("date") = Global_Inc.FormatDate(dtRow(i).Item("date"))
                    row1.Item("type") = dtRow(i).Item("type")
                    row1.Item("qty_atp") = dtRow(i).Item("qty_atp")
                    row1.Item("qty_atb") = dtRow(i).Item("qty_atb")
                    row1.Item("qty_fulfill") = dtRow(i).Item("qty_fulfill")
                    row1.Item("qty_lack") = dtRow(i).Item("qty_lack")
                    If dtRow(i).Item("flag_scm") = -1 Then
                        'msgbox("Due date for reference only.  A confirmation with ship dates will follow, normally within 48 hours.")
                        judgedate = "aaa"
                    End If
                    row1.Item("flag_scm") = dtRow(i).Item("flag_scm")
                    ATPResultTb.Rows.Add(row1)
                Next
            Next
            With ATPResultTb.Columns
                .Item("entity").ColumnName = "Entity" : .Item("part").ColumnName = "Part No" : .Item("site").ColumnName = "Site"
                .Item("date").ColumnName = "Delivery On" : .Item("qty_atb").ColumnName = "ATB Qty" : .Item("qty_atp").ColumnName = "ATP Qty"
                .Item("qty_lack").ColumnName = "Qty Lack" : .Item("qty_fulfill").ColumnName = "Qty Fulfill" : .Item("type").ColumnName = "Due=6"
                .Item("flag_scm").ColumnName = "SCM Flag" : .Remove("qty_req") : .Remove("flag")
            End With
            ' peter add 2008/04/30
            dtOne = ATPResultTb
            dg1.DataSource = ATPResultTb : dg1.DataBind() : dg1.Visible = True : ddTrace1.Visible = True
            If Util.IsAEUIT() Or Util.IsInternalUser2() Then
                dg1.Visible = True : ddTrace1.Visible = True
            Else
                dg1.Visible = False : ddTrace1.Visible = False
            End If
            If OrderUtilities.IsGA(Session("Company_id")) Then
                ddTrace1.Visible = False
            End If
            dr1 = dbUtil.dbGetDataTable("B2B", _
            "select distinct part_no,DeliveryPlant from logistics_detail where logistics_id='" & _
            StrLogistics_Id & "'")
            
            For Each r As DataRow In dr1.Rows
                Dim dtRow As DataRow() = ATPResultTable.Select("part='" & _
               r.Item("part_no") & "' and site='" & r.Item("DeliveryPlant") & "'", "part asc,entity asc, date asc")
                cumATP = 0
                SUPPLY_LT_Flag = False
                
                For i As Integer = 0 To dtRow.GetUpperBound(0)
                    dtRow(i).Item("qty_atp") = dtRow(i).Item("qty_atb") + cumATP
                    dtRow(i).Item("type") = "5"
                    cumATP = dtRow(i).Item("qty_atp")
                    dtRow(i).Item("qty_lack") = dtRow(i).Item("qty_req") - dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") < 0 Then dtRow(i).Item("qty_lack") = 0
                    dtRow(i).Item("qty_fulfill") = dtRow(i).Item("qty_atp")
                    If dtRow(i).Item("qty_lack") = 0 And SUPPLY_LT_Flag.Equals(False) Then
                        dtRow(i).Item("type") = "6"
                        SUPPLY_LT_Flag = True
                        
                        dbUtil.dbExecuteNoQuery("B2B", _
                        "update logistics_detail set due_date='" & _
                        CDate(dtRow(i).Item("date")) & "' where logistics_id='" & _
                        StrLogistics_Id & "' and part_no='" & dtRow(i).Item("part") & "' and DeliveryPlant='" & dtRow(i).Item("site") & "'")
                   
                    End If
                Next
                 
            Next
            'Response.Write("a")
            'Response.End()
            Dim WithoutBTOSTb As New DataTable
            WithoutBTOSTb.Columns.Add("Line", Type.GetType("System.Int32"))
            WithoutBTOSTb.Columns.Add("Part No", Type.GetType("System.String"))
            WithoutBTOSTb.Columns.Add("Qty", Type.GetType("System.Int32"))
            WithoutBTOSTb.Columns.Add("Due Date", Type.GetType("System.String"))
            WithoutBTOSTb.Columns.Add("Delivery Plant", Type.GetType("System.String"))
            AdjustDD4ItemInMultipleLine(Me.StrLogistics_Id)
            'Jackie add 2007/08/26 for PT project. Handle the ship from ACL : LatestATP
            Dim strsql_acl As String = "select part_no,line_no,convert(varchar(10),due_date,111) as due_date,DeliveryPlant from logistics_detail where logistics_id='" & _
                Session("logistics_id") & "' and DeliveryPlant<>'EUH1' and DeliveryPlant like 'TW%'" & _
                " and Part_no<>'AGS-EW-%' and convert(varchar(10),due_date,111)<>'2020/10/10' order by line_no"
            Dim dt_acl As DataTable = dbUtil.dbGetDataTable("B2B", strsql_acl)
            If dt_acl.Rows.Count > 0 Then
                Dim str_acl As String = ""
                For i As Integer = 0 To dt_acl.Rows.Count - 1
                    Dim line_no As String = dt_acl.Rows(i).Item("line_no")
                    Dim due_date_acl As String = ""
                    due_date_acl = Global_Inc.FormatDate_New(dt_acl.Rows(i).Item("due_date"))
                    Dim plant_acl As String = dt_acl.Rows(i).Item("DeliveryPlant")
                    Dim ws As New B2BAEU_SAP_WS.B2B_AEU_WS
                    ws.Url = "http://172.21.34.44:9000/B2B_SAP_WS.asmx"
                    ws.Timeout = 999999
                    'Response.Write(due_date_acl) : Response.End()
                    ws.Get_Next_WorkingDate_ByCode(due_date_acl, "3", "TW")
                    'ws.Get_Next_WrokingDate(due_date_acl, "3")
                    Dim dt_calendar As DataTable = dbUtil.dbGetDataTable("B2B", "select top 2 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
                        " plant='EUH1' and SalesOrg='EU10' and CustomerId='Default' and Holiday='N' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                        due_date_acl & "') order by PKYear")
                    If dt_calendar.Rows.Count > 0 Then
                        If Global_Inc.FormatDate_New(dt_calendar.Rows(0).Item("PKYear").ToString) <> due_date_acl Then
                            due_date_acl = dt_calendar.Rows(0).Item("PKYear").ToString
                        End If
                        str_acl &= "update logistics_detail set due_date='" & CDate(due_date_acl) & "' where logistics_id='" & _
                               Session("logistics_id") & "' and line_no=" & line_no & ";"
                    End If
                Next
                
                If str_acl <> "" Then
                
                    dbUtil.dbExecuteNoQuery("B2B", str_acl)
                    
                End If
                
            End If
            
            'Jackie add 2007/03/23
            Dim DtJackie As New DataTable, UpdateEwSql As String = ""
            DtJackie = dbUtil.dbGetDataTable("B2B", "select line_no,part_no,due_date from logistics_detail where logistics_id='" & Session("logistics_id") & "' order by line_no")
            For i As Integer = 0 To DtJackie.Rows.Count - 1
                If DtJackie.Rows(i).Item("part_no").ToString.ToLower.Trim.IndexOf("ags-ew-") = 0 Then
                    UpdateEwSql &= "update logistics_detail set due_date='" & CDate(DtJackie.Rows(i - 1).Item("due_date").ToString.Trim) & _
                    "' where line_no=" & DtJackie.Rows(i).Item("line_no").ToString.Trim & " and line_no<100 and part_no='" & DtJackie.Rows(i).Item("part_no").ToString.Trim & "';"
                End If
            Next
            If UpdateEwSql <> "" Then
                dbUtil.dbExecuteNoQuery("B2B", UpdateEwSql)
            End If
            
            Dim sqlConn3 As System.Data.SqlClient.SqlConnection = Nothing
           
            Dim dr2 As DataTable = dbUtil.dbGetDataTable("B2B", _
           "select line_no as Line, part_no as 'Part No', Qty, due_date As 'Due Date', " & _
           " DeliveryPlant  from logistics_detail " & _
           " where logistics_id='" & StrLogistics_Id & "' order by line_no")
            For Each r2 As DataRow In dr2.Rows
                Dim r As DataRow = WithoutBTOSTb.NewRow
                r.Item("Line") = r2.Item("Line")
                r.Item("Part No") = r2.Item("Part No")
                r.Item("Qty") = r2.Item("Qty")
                r.Item("Delivery Plant") = r2.Item("DeliveryPlant")
                If Trim(r2.Item("Due Date")) = "" Or CStr(r2.Item("Due Date")) Like "*1900*" Then
                    r.Item("Due Date") = Global_Inc.FormatDate(System.DateTime.Today) 'Today.Year & "/" & Today.Month & "/" & Today.Day
                Else
                    r.Item("Due Date") = Global_Inc.FormatDate(r2.Item("Due Date")) 'DatePart(DateInterval.Year, dr2.Item("Due Date")) & "/" & DatePart(DateInterval.Month, dr2.Item("Due Date")) & "/" & DatePart(DateInterval.Day, dr2.Item("Due Date"))
                End If
                If OrderUtilities.IsGA(Session("Company_id")) Then
                    r.Item("Due Date") = "To be confirmed within 3 days"
                End If
                WithoutBTOSTb.Rows.Add(r)
            Next
            Me.BeforeBTOSDg.DataSource = WithoutBTOSTb
            Me.BeforeBTOSDg.DataBind()
            Dim OrderPartialFlag As Object = dbUtil.dbExecuteScalar("B2B", _
            "select partial_flag from logistics_master where logistics_id='" & Me.StrLogistics_Id & "'")
            Dim strUpdateNonPartialSql As String = ""
            If OrderUtilities.BtosOrderCheck() = 1 Or (OrderPartialFlag IsNot Nothing AndAlso OrderPartialFlag.ToString() = "N") Then
                '<Nada Modified for Btos first date>
                Dim TempDt As DataTable = dbUtil.dbGetDataTable("B2B", _
                "select max(due_date) as due_date from logistics_detail where logistics_id='" & _
                Me.StrLogistics_Id & "'")
                
                'Dim TempDt As DataTable = dbUtil.dbGetDataTable("B2B", _
                '"select max(required_date) as due_date from logistics_detail where logistics_id='" & _
                'Me.StrLogistics_Id & "'")
                '</Nada Modified for Btos first date>
                Dim MaxDue As System.DateTime = System.DateTime.Today()
                Dim sqlCn As System.Data.SqlClient.SqlConnection = Nothing
                If TempDt.Rows.Count > 0 Then
                    MaxDue = CDate(TempDt.Rows(0).Item("due_date"))
                    '<Nada added for Btos first date>
                    'Dim WorkDays As String = "5"
                    'Global_Inc.SiteDefinition_Get("BTOSWorkingDays", WorkDays)
                    'Dim sc4 As New B2BAEU_SAP_WS.B2B_AEU_WS
                    'Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc4.Url)
                    'Dim strMaxDD As String = CDate(MaxDue).ToString("yyyy-MM-dd")
                    'WorkDays = "-" & WorkDays
                    'sc4.Get_Next_WrokingDate(strMaxDD, WorkDays)
                    'MaxDue = CDate(strMaxDD)
                    '</Nada added for Btos first date>
                    dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set due_date='" & _
                    MaxDue & "' where logistics_id='" & Me.StrLogistics_Id & _
                    "' and line_no > 100 and line_no % 100 <> 0")
                End If
                'sqlCn.Close()
                If OrderUtilities.BtosOrderCheck() = 1 Then
                    Dim WorkDays As String = "5"
                    Global_Inc.SiteDefinition_Get("BTOSWorkingDays", WorkDays)
                    Dim sc4 As New B2BAEU_SAP_WS.B2B_AEU_WS
                    Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc4.Url)
                    Dim strMaxDD As String = CDate(MaxDue).ToString("yyyy-MM-dd")
                    sc4.Get_Next_WrokingDate(strMaxDD, WorkDays)
                    If Date.TryParse(strMaxDD, Now) Then
                        MaxDue = CDate(strMaxDD)
                    Else
                        MaxDue = DateAdd(DateInterval.Month, 3, Now)
                    End If
                    Response.Write(MaxDue & "||" & Session("cart_id"))
                    strUpdateNonPartialSql = "update logistics_detail set due_date='" & _
                    MaxDue & "' where logistics_id='" & Me.StrLogistics_Id & "' and line_no = 100"
                    
                Else
                    If OrderPartialFlag = "N" Then
                        strUpdateNonPartialSql = "update logistics_detail set due_date='" & _
                        CDate(MaxDue) & "' where logistics_id='" & Me.StrLogistics_Id & "'"
                    End If
                End If
                Dim sqlCn2 As System.Data.SqlClient.SqlConnection = Nothing
                dbUtil.dbExecuteNoQuery("B2B", strUpdateNonPartialSql)
            End If
            
            Dim stockDT As New DataTable
            stockDT = dbutil.dbGetDataTable("b2b", "SELECT LINE_NO , DUE_DATE FROM logistics_detail " & _
            " where logistics_id='" & StrLogistics_Id & "' order by line_no")
            For I As Integer = 0 To stockDT.Rows.Count - 1
                If DateDiff(DateInterval.Day, CDate("2008-7-10"), CDate(stockDT.Rows(I).Item("DUE_DATE").ToString)) = 0 Or _
                DateDiff(DateInterval.Day, CDate("2008-7-11"), CDate(stockDT.Rows(I).Item("DUE_DATE").ToString)) = 0 Then
                    dbutil.dbExecuteNoQuery("B2B", "UPDATE logistics_detail SET DUE_DATE='2007-7-14' where logistics_id='" & StrLogistics_Id & "' AND LINE_NO='" & stockDT.Rows(I).Item("LINE_NO") & "'")
                End If
            Next
            
            Dim AfterBTOSTb As New DataTable
            With AfterBTOSTb.Columns
                .Add("Line", Type.GetType("System.Int32")) : .Add("Part No", Type.GetType("System.String"))
                .Add("Qty", Type.GetType("System.Int32")) : .Add("Due Date", Type.GetType("System.String")) : .Add("Delivery Plant", Type.GetType("System.String"))
            End With
            Dim dr4 As DataTable = dbUtil.dbGetDataTable("B2B", _
            "select line_no as Line, part_no as 'Part No', Qty, due_date As 'Due Date', " & _
            "DeliveryPlant from logistics_detail " & _
            " where logistics_id='" & StrLogistics_Id & "' order by line_no")
            
            For Each r2 As DataRow In dr4.Rows
                Dim r As DataRow = AfterBTOSTb.NewRow
                r.Item("Line") = r2.Item("Line") : r.Item("Part No") = r2.Item("Part No") : r.Item("Qty") = r2.Item("Qty")
                r.Item("Due Date") = Global_Inc.FormatDate(r2.Item("Due Date"))
                If OrderUtilities.IsGA(Session("Company_id")) Then
                    r.Item("Due Date") = "To be confirmed within 3 days"
                End If
                r.Item("Delivery Plant") = r2.Item("DeliveryPlant") : AfterBTOSTb.Rows.Add(r)
            Next
            Me.AfterBTOSDg.DataSource = AfterBTOSTb : Me.AfterBTOSDg.DataBind()
        End If
        DisplayOrderInfo(StrLogistics_Id)
    End Sub
    
    Sub updateDueDate()
        
    End Sub
    
    Function GetRPL(ByVal CustomerId As String, ByVal xDate As Date) As String
        Dim dtRPL As DataTable = dbUtil.dbGetDataTable("B2B", "select top 30 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
        " plant='EUH1' and SalesOrg='EU10' and CustomerId='Default' and Holiday='N' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                       xDate & "') order by PKYear asc")
        Dim RPL As String = Global_Inc.FormatDate(DateAdd(DateInterval.Day, 30, DateTime.Today))
        If dtRPL.Rows.Count = 30 Then
            RPL = dtRPL.Rows(29).Item("PKYear")
        End If
        Dim dtSC As DataTable = dbUtil.dbGetDataTable("B2B", "select top 2 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
         " plant='EUH1' and SalesOrg='EU10' and CustomerId='" & CustomerId & "' and Holiday='N' and ShippingCalendarDay='Y' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                        RPL & "') order by PKYear asc")
        If dtSC.Rows.Count > 0 Then
            RPL = dtSC.Rows(0).Item("PKYear")
        End If
        Return RPL
    End Function
    
    Function msgbox(ByVal msg As String) As String
        Response.Write("<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>")
        Response.Write("window.alert('" + msg + "')")
        Response.Write("</" & "script>")
        Return 0
    End Function
    
    Shared Sub insertCustomerNo(ByVal CompanyID As String, ByVal MaterialNo As String, ByVal CustMaterialNo As String)
        'Dim SqlStr As String = "insert into CustMaterialMapping (Org,DistrChannel,customerid,MaterialNo,CreatedBy,CreatedOn,CustMaterialNo)" & _
        '                       " values ('EU10','00','" & CompanyID & "','" & MaterialNo & "','Nada',getdate(),'" & CustMaterialNo & "')"
        'dbUtil.dbExecuteNoQuery("B2B", SqlStr)
    End Sub
    Shared Sub updateCustomerNo(ByVal CompanyID As String, ByVal MaterialNo As String, ByVal CustMaterialNo As String)
        'Dim SqlStr As String = "update CustMaterialMapping set CreatedOn=getdate(),CustMaterialNo='" & CustMaterialNo & "'" & _
        '                       " where Org='EU10' AND DistrChannel='00' AND customerid='" & CompanyID & "' AND MaterialNo='" & MaterialNo & "'"
        'dbUtil.dbExecuteNoQuery("B2B", SqlStr)
    End Sub
    Shared Function isCustomerNoExists(ByVal CompanyID As String, ByVal MaterialNo As String) As Boolean
        'Dim isCustomerNoExist As Object = dbUtil.dbExecuteScalar("B2B", "select isnull(count(MaterialNo),0) from CustMaterialMapping where Org='EU10' AND DistrChannel='00' AND customerid='" & CompanyID & "' AND MaterialNo='" & MaterialNo & "'")
        'If IsNumeric(isCustomerNoExist) Then
        '    If isCustomerNoExist > 0 Then
        '        Return True
        '    End If
        'End If
        Return False
    End Function
    
    Protected Sub GoPiPreviewBtn_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection
        Dim xSQL As String = ""
        Dim strSQLCmd As String = ""
        Dim LogisticsDetailDT As New DataTable
        strSQLCmd = "select distinct * from logistics_detail where logistics_id='" & StrLogistics_Id & "' order by line_no desc"
        LogisticsDetailDT = dbUtil.dbGetDataTable("B2B", strSQLCmd)
        Dim i As Integer = 0
        Dim RequestName As String = ""
        Dim max_required_date As String = Global_Inc.FormatDate(Date.Today.Date)
        While i <= LogisticsDetailDT.Rows.Count - 1
            Dim CustomerPNname As String = "CustomerPN" & LogisticsDetailDT.Rows(i).Item("Line_NO")
            RequestName = "required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO")
            If Not IsNothing(Request(CustomerPNname)) Then
                If isCustomerNoExists(Session("Company_id"), LogisticsDetailDT.Rows(i).Item("part_NO")) Then
                    updateCustomerNo(Session("Company_id"), LogisticsDetailDT.Rows(i).Item("part_NO"), Replace(Request(CustomerPNname), "'", "''"))
                Else
                    insertCustomerNo(Session("Company_id"), LogisticsDetailDT.Rows(i).Item("part_NO"), Replace(Request(CustomerPNname), "'", "''"))
                End If
            End If
            If Request("required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO")) <> "" Then
                If max_required_date < CDate(Request("required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO"))) Then
                    max_required_date = CDate(Request("required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO")))
                End If
                
                strSQLCmd = "update logistics_detail set " & _
                            "required_date ='" & CDate(Request("required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO"))) & "' " & _
                            " where " & _
                            "logistics_id = '" & StrLogistics_Id & "' and " & _
                            "line_no = " & CInt(LogisticsDetailDT.Rows(i).Item("Line_NO"))
               
                If LogisticsDetailDT.Rows(i).Item("Line_NO") >= 100 And LogisticsDetailDT.Rows(i).Item("Line_NO") Mod 100 = 0 Then
                    strSQLCmd = "update logistics_detail set " & _
                                "required_date ='" & CDate(Request("required_date$$$" & LogisticsDetailDT.Rows(i).Item("Line_NO"))) & "' " & _
                                " where " & _
                                "logistics_id = '" & StrLogistics_Id & "' and " & _
                                "line_no/100 = " & CInt(LogisticsDetailDT.Rows(i).Item("Line_NO") / 100)
                End If
                
                dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
                
            End If
            i = i + 1
        End While
        Dim strAuto_Order_Flag_Master As String = "N"
        strSQLCmd = "select due_date from  logistics_detail  " & _
                    " where auto_order_flag = 'Y'" & _
                    " and logistics_id = '" & StrLogistics_Id & "'"
        Dim tmpDR As DataTable
        tmpDR = dbUtil.dbGetDataTable("B2B", strSQLCmd)
        If tmpDR.Rows.Count > 0 Then
            strAuto_Order_Flag_Master = "Y"
        End If
        
        strSQLCmd = "update logistics_master set " & _
                    "auto_order_flag ='" & strAuto_Order_Flag_Master & "',required_date='" & CDate(max_required_date) & "'" & _
                    "where " & _
                    "logistics_id = '" & StrLogistics_Id & "' "
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        '<Nada Modified for Btos First date>
        'Dim Comp_DueDataDT As DataTable
        'Comp_DueDataDT = dbUtil.dbGetDataTable("B2B", "select * from logistics_detail where logistics_id = '" & StrLogistics_Id & "' and due_date < cast(required_date as datetime) and line_no >= 100 and line_no%100=0 ")
        'If Comp_DueDataDT.Rows.Count > 0 Then
        '    Dim tmpRequireDate As String = CDate(Comp_DueDataDT.Rows(0).Item("REQUIRED_DATE"))
        '    Dim FwdDays As Integer
        '    FwdDays = -CInt(Global_Inc.SiteDefinition_Get("BTOSWorkingDays"))
        '    Dim compBTOSDD As String = tmpRequireDate
        '    Global_Inc.WeekDayFwd(compBTOSDD, FwdDays)
        '    strSQLCmd = "update logistics_detail set " & _
        '                "due_date = '" & cdate(compBTOSDD) & "' " & _
        '                "where " & _
        '                "logistics_id = '" & StrLogistics_Id & "' and due_date < cast(required_date as datetime) and line_no > 100 and line_no%100<>0 "

        '    dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)

        'End If
        Dim tmpRequireDate As String
        If OrderUtilities.BtosOrderCheck = 1 Then
            Dim firstDT As String = ""
            firstDT = dbUtil.dbExecuteScalar("B2B", "SELECT REQUIRED_DATE FROM logistics_detail where logistics_id = '" & StrLogistics_Id & "' and LINE_NO=100").ToString
            
            tmpRequireDate = CDate(firstDT)
        Else
            tmpRequireDate = CDate(max_required_date)
        End If
        Dim FwdDays As Integer
        FwdDays = -CInt(Global_Inc.SiteDefinition_Get("BTOSWorkingDays"))
        Dim compBTOSDD As String = tmpRequireDate
        Global_Inc.WeekDayFwd(compBTOSDD, FwdDays)
        strSQLCmd = "update logistics_detail set " & _
        "due_date = '" & CDate(compBTOSDD) & "' " & _
        "where " & _
        "logistics_id = '" & StrLogistics_Id & "' and line_no > 100 and line_no%100<>0 "
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        '</Nada Modified for Btos First date>
        Dim RequiredDateNoteDT As DataTable
        RequiredDateNoteDT = dbUtil.dbGetDataTable("B2B", "select * from logistics_detail where logistics_id = '" & StrLogistics_Id & "' and required_date > getdate() and line_no >= 100 and line_no%100=0 ")
        If RequiredDateNoteDT.Rows.Count > 0 Then
        
            Dim tmpSalesNoteRS As DataTable
            tmpSalesNoteRS = dbUtil.dbGetDataTable("B2B", "select SALES_NOTE from logistics_master where logistics_id = '" & StrLogistics_Id & "'")
            Dim tmpSalesNote As String = tmpSalesNoteRS.Rows(0).Item("SALES_NOTE")
	     
            Dim xMonth As String = Month(CDate(RequiredDateNoteDT.Rows(0).Item("REQUIRED_DATE")))
            Dim xDay As String = Day(CDate(RequiredDateNoteDT.Rows(0).Item("REQUIRED_DATE")))
            Dim xYear As String = Right(CStr(Year(CDate(RequiredDateNoteDT.Rows(0).Item("REQUIRED_DATE")))), 2)
            If Len(xMonth) < 2 Then
                xMonth = "0" & xMonth
            End If
            If Len(xDay) < 2 Then
                xDay = "0" & xDay
            End If
            Dim strRequiredDateNote As String = "Customer requested date: " & xMonth & "/" & xDay & "/" & Right(CStr(xYear), 2) & Chr(13) & Chr(10)
            If tmpSalesNote.Length >= 35 Then
                If LCase(Left(tmpSalesNote, 24)) = "customer requested date:" Then
                    tmpSalesNote = strRequiredDateNote & Mid(tmpSalesNote, 36)
                Else
                    tmpSalesNote = strRequiredDateNote & tmpSalesNote
                End If
            Else
                tmpSalesNote = strRequiredDateNote & tmpSalesNote
            End If
            
            strSQLCmd = "update logistics_master set " & _
                       "SALES_NOTE = '" & tmpSalesNote & "' " & _
                       "where " & _
                       "logistics_id = '" & StrLogistics_Id & "'"
            dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
            
        End If
         
        '**** If Required Date > Due Date, Set Due Date = Required Date ****'
        '<Nada Modified for Btos First date>
        strSQLCmd = "update logistics_detail set " & _
                    "due_date = cast(required_date as datetime) " & _
                    "where " & _
                    "logistics_id = '" & StrLogistics_Id & "' and due_date < cast(required_date as datetime) and (line_no < 100 or line_no%100=0) "
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        'If OrderUtilities.BtosOrderCheck() = 1 Then
        '    strSQLCmd = "update logistics_detail set " & _
        '           "due_date = cast(required_date as datetime) " & _
        '           "where " & _
        '           "logistics_id = '" & StrLogistics_Id & "' and line_no = 100"
        'Else
        '    strSQLCmd = "update logistics_detail set " & _
        '            "due_date = cast(required_date as datetime) " & _
        '            "where " & _
        '            "logistics_id = '" & StrLogistics_Id & "' and due_date < cast(required_date as datetime) and line_no < 100"
        'End If
        
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        
        '</Nada Modified for Btos First date>
        Dim BTOSRequiredDate As String = ""
        Dim BTOSRequiredDateDT As DataTable
        BTOSRequiredDateDT = dbUtil.dbGetDataTable("B2B", "select required_date as MaxRequireDate from logistics_detail where logistics_id = '" & StrLogistics_Id & "' and line_no>=100 and line_no%100=0")
        If BTOSRequiredDateDT.Rows.Count > 0 Then
            BTOSRequiredDate = CDate(BTOSRequiredDateDT.Rows(0).Item("MaxRequireDate"))
            Global_Inc.WeekDayFwd(BTOSRequiredDate, -12)
            strSQLCmd = "update logistics_detail set " & _
                        "required_date = '" & CDate(BTOSRequiredDate) & "'" & _
                        "where " & _
                        "logistics_id = '" & StrLogistics_Id & "' and line_no>100 and line_no%100<>0 "
             
            dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
           
        End If
        strSQLCmd = "update logistics_detail set " & _
                    "required_date = getdate() " & _
                    "where " & _
                    "logistics_id = '" & StrLogistics_Id & "' and cast(required_date as datetime)< cast(getdate() as datetime) "
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        
        
        Dim MaxRequireDateDT As DataTable
        MaxRequireDateDT = dbUtil.dbGetDataTable("B2B", "select max(required_date) as MaxRequireDate from logistics_detail where logistics_id = '" & StrLogistics_Id & "'")
        If Global_Inc.FormatDate(MaxRequireDateDT.Rows(0).Item(0)) <> "" Then
            strSQLCmd = "update logistics_master set " & _
                      "required_date = '" & CDate(MaxRequireDateDT.Rows(0).Item(0)).ToString("MM/dd/yyyy") & "' " & _
                      "where " & _
                       "logistics_id = '" & StrLogistics_Id & "'"
            
            dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
           
        End If
        
        'Jackie add 2007/03/23
        Dim DtJackie As New DataTable, UpdateEwSql As String = ""
        DtJackie = dbUtil.dbGetDataTable("B2B", "select line_no,part_no,due_date,required_date from logistics_detail where logistics_id='" & Session("logistics_id") & "' order by line_no")
        For ii As Integer = 0 To DtJackie.Rows.Count - 1
            If DtJackie.Rows(ii).Item("part_no").ToString.ToLower.Trim.IndexOf("ags-ew-") = 0 Then
                UpdateEwSql &= "update logistics_detail set due_date='" & CDate(DtJackie.Rows(ii - 1).Item("due_date").ToString.Trim) & _
                                "',required_date='" & CDate(CDate(DtJackie.Rows(ii - 1).Item("required_date").ToString.Trim).ToString("MM/dd/yyyy")) & _
                "' where line_no=" & DtJackie.Rows(ii).Item("line_no").ToString.Trim & " and line_no<100 and part_no='" & DtJackie.Rows(ii).Item("part_no").ToString.Trim & "';"
            End If
        Next
        If UpdateEwSql <> "" Then
        
            dbUtil.dbExecuteNoQuery("B2B", UpdateEwSql)
            'response.write(CDATE(CDATE(MaxRequireDateDT.Rows(0).Item(0)).ToString("MM/dd/yyyy")))
            '    Response.End()
        End If
         
        If Global_Inc.C_ShowRoHS = True Then
            Response.Redirect("PI_Preview_RoHS.aspx")
            Exit Sub
        End If
        Response.Redirect("PI_Preview_V6.aspx")
    End Sub
    'Customer Material No
    
    
    Public Shared Function GetAsmblyComp(ByVal strFunc_Id As Integer, ByVal strTran_Id As String, ByRef p_strAsmblyComp As String) As Integer
        Dim strAsmblyComp As String = ""
        Dim IsAsmblyOutsrc As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim adoDR As DataTable
        Dim strSQLCmd As String = ""

        Select Case strFunc_Id
            Case 1 'Logistics
                strSQLCmd = "select part_no from logistics_detail where logistics_id = '" & strTran_Id & "' and (part_no like '%OPTION%' or part_no ='Assembly Fee Visam')"
            Case 2 'Order
                strSQLCmd = "select part_no from order_detail where order_id = '" & strTran_Id & "' and (part_no like '%OPTION%' or part_no ='Assembly Fee Visam')"
            Case Else
                strSQLCmd = "select part_no from order_detail where order_id = '" & strTran_Id & "' and (part_no like '%OPTION%' or part_no ='Assembly Fee Visam')"
        End Select
        'HttpContext.Current.Response.Write("<BR>strSQLCmd:" & strSQLCmd)
        adoDR = dbUtil.dbGetDataTable("B2B", strSQLCmd)
        If adoDR.Rows.Count > 0 Then
            If HttpContext.Current.Session("USER_ID") = "gary.chen@advantech.com.tw" Then
                'HttpContext.Current.Response.Write("<BR>UCase(adoRs(part_no)):" & UCase(adoRs("part_no")))

                'HttpContext.Current.Response.Write("<BR>trim_part:" & trim(UCase(adoRs("part_no"))))
            End If

            If InStr(UCase(adoDR.Rows(0).Item("part_no")), "VISAM") > 0 Or InStr(UCase(adoDR.Rows(0).Item("part_no")), "GBM") > 0 Or InStr(UCase(adoDR.Rows(0).Item("part_no")), "RAINB") > 0 Or InStr(UCase(adoDR.Rows(0).Item("part_no")), "DHS") > 0 Or InStr(UCase(adoDR.Rows(0).Item("part_no")), "REIJSEN") > 0 Then
                If InStr(UCase(adoDR.Rows(0).Item("part_no")), "VISAM") > 0 Then
                    strAsmblyComp = "ADLVISAM"
                End If
                If InStr(UCase(adoDR.Rows(0).Item("part_no")), "GBM") > 0 Then
                    strAsmblyComp = "ADLGBM"
                End If
                If InStr(UCase(adoDR.Rows(0).Item("part_no")), "RAINB") > 0 Then
                    strAsmblyComp = "ADLRAINB"
                End If
                If InStr(UCase(adoDR.Rows(0).Item("part_no")), "DHS") > 0 Then
                    strAsmblyComp = "AITDHS"
                End If
                If InStr(UCase(adoDR.Rows(0).Item("part_no")), "REIJSEN") > 0 Then
                    strAsmblyComp = "ABNREIJS"
                End If

                IsAsmblyOutsrc = "Yes"
            Else
                '----HttpContext.Current.Response.Write("<BR>No 3rd")
                strAsmblyComp = "AESCBTOS"
                IsAsmblyOutsrc = "No"
            End If
        Else
            strAsmblyComp = "NORMAL"
            IsAsmblyOutsrc = "No"
        End If
        p_strAsmblyComp = strAsmblyComp
        'g_adoConn.Close()
        'HttpContext.Current.Response.Write strAsmblyComp
        'HttpContext.Current.Response.Write p_strAsmblyComp

    End Function
    
    Private Sub DisplayOrderInfo(ByVal strPIId As String)
        Dim xRow As New TableRow
        Dim xCell As New TableCell
               
        Dim l_strSQLCmd As String = ""
        Const strSlowMoving As String = ""
        
        Dim OrderInfoDR As DataTable
        l_strSQLCmd = "select " & _
                      "a.po_no," & _
                      "a.po_date," & _
                      "a.due_date," & _
                      "a.required_date," & _
                      "a.ship_condition," & _
                      "a.order_note," & _
                      "a.partial_flag," & _
                      "a.remark, " & _
                      "a.INCOTERM, " & _
                      "a.INCOTERM_TEXT, " & _
                      "a.SALES_NOTE, " & _
                      "IsNull(a.FREIGHT,-1) as freight, " & _
                      "a.OP_NOTE,a.prj_note,isnull(a.DefaultSalesNote,'N') as DefaultSalesNote " & _
                      "from logistics_master a " & _
                      "left join sap_dimcompany b " & _
                      "on a.soldto_id = b.company_id and b.company_type in ('Partner','Z001') " & _
                      "where a.logistics_id = '" & strPIId & "'"
        OrderInfoDR = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If OrderInfoDR.Rows.Count > 0 Then
            '11
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>PO No.&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '12
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & OrderInfoDR.Rows(0).Item("po_no") & "</font>"
            xRow.Cells.Add(xCell)
            '13
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Advantech SO&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '14
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = ""
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '21
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Order Date&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '22
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Date.Now) & "</font>"
            xRow.Cells.Add(xCell)
            '23
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Payment Term&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '24
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = ""
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '31
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Required Date&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '32
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(OrderInfoDR.Rows(0).Item("required_date")) & "</font>"
            xRow.Cells.Add(xCell)
            '33
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Incoterm&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '34
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & OrderInfoDR.Rows(0).Item("INCOTERM") & "</font>"
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '41
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Placed By&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '42
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & Session("USER_ID") & "</font>"
            xRow.Cells.Add(xCell)
            '43
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Incoterm Text&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '44
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            If LCase(OrderInfoDR.Rows(0).Item("INCOTERM_TEXT").ToString) = "blank" Then
                xCell.Text = "<font color=""#333333"">&nbsp;</font>"
            Else
                xCell.Text = "<font color=""#333333"">&nbsp;" & OrderInfoDR.Rows(0).Item("INCOTERM_TEXT").ToString & "</font>"
            End If
            
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '51
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Freight&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '52
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & OrderInfoDR.Rows(0).Item("remark") & "</font>"
            If CDbl(OrderInfoDR.Rows(0).Item("freight")) > 0 Then
                xCell.Text += CDbl(OrderInfoDR.Rows(0).Item("freight")).ToString()
            End If
            xRow.Cells.Add(xCell)
            '53
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Channel&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '54
            Dim exeFunc As Integer = 0
            Dim strAsmblyComp As String = ""
            Dim strOrderType As String = ""
            exeFunc = GetAsmblyComp(1, strPIId, strAsmblyComp)
            If UCase(strAsmblyComp) = "ADLVISAM" Then
                strOrderType = "VISAM"
            ElseIf UCase(strAsmblyComp) = "ADLGBM" Then
                strOrderType = "GBM"
            ElseIf UCase(strAsmblyComp) = "ADLRAINB" Then
                strOrderType = "RAINB"
            Else
                strOrderType = "SO"
            End If
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & strOrderType & "</font>"
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '61
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Partial OK&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '62
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & OrderInfoDR.Rows(0).Item("partial_flag") & "</font>"
            xRow.Cells.Add(xCell)
            '63
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Ship Condition&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '64
            xCell = New TableCell
            xCell.BackColor = Color.White
            xCell.Style.Value = "width:35%"
            xCell.Text = "<font color=""#333333"">&nbsp;" & Mid(OrderInfoDR.Rows(0).Item("ship_condition"), 3) & "</font>"
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            '71
            '----------------------------------
            Dim strPoDate As String = ""
            strPoDate = Global_Inc.FormatDate(OrderInfoDR.Rows(0).Item("po_date"))
            If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                If Not (CStr(strPoDate) Like "*9999*") Then
                    xRow = New TableRow
                    xCell = New TableCell
                    xCell.Style.Value = "background-color:#f0f0f0;width:15%"
                    xCell.VerticalAlign = VerticalAlign.Middle
                    xCell.HorizontalAlign = HorizontalAlign.Right
                    xCell.Text = "<font color=""#333333""><b>PO Date&nbsp;&nbsp;</b></font>"
                    xRow.Cells.Add(xCell)
                    '62
                    xCell = New TableCell
                    xCell.BackColor = Color.White
                    xCell.Style.Value = "width:35%"
                    xCell.Text = "<font color=""#333333"">&nbsp;" & strPoDate & "</font>"
                    xRow.Cells.Add(xCell)
                    '63
                    xCell = New TableCell
                    xCell.Style.Value = "background-color:#f0f0f0;width:15%"
                    xCell.VerticalAlign = VerticalAlign.Middle
                    xCell.HorizontalAlign = HorizontalAlign.Right
                    xCell.Text = ""
                    xRow.Cells.Add(xCell)
                    '64
                    xCell = New TableCell
                    xCell.BackColor = Color.White
                    xCell.Style.Value = "width:35%"
                    xCell.Text = ""
                    xRow.Cells.Add(xCell)
                    Me.OrderInfo.Rows.Add(xRow)
                End If
            End If
            '81
            '----------------------------------
            xRow = New TableRow
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0;height:50px;width:15%"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Right
            xCell.Text = "<font color=""#333333""><b>Order Note&nbsp;&nbsp;</b></font>"
            xRow.Cells.Add(xCell)
            '82
            xCell = New TableCell
            xCell.ColumnSpan = 3
            xCell.BackColor = Color.White
            xCell.VerticalAlign = VerticalAlign.Top
            xCell.Height = "50"
            xCell.Text = "<font color=""red""><b>&nbsp;" & Replace(Global_Inc.HTMLEncode(OrderInfoDR.Rows(0).Item("order_note")), "$$$$", "<br/>") & "</b></font>"
            xRow.Cells.Add(xCell)
            Me.OrderInfo.Rows.Add(xRow)
            If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                '91
                '----------------------------------
                xRow = New TableRow
                xCell = New TableCell
                xCell.Style.Value = "background-color:#f0f0f0;height:50px;width:15%"
                xCell.VerticalAlign = VerticalAlign.Middle
                xCell.HorizontalAlign = HorizontalAlign.Right
                xCell.Text = "<font color=""#333333""><b>Sales Note&nbsp;&nbsp;</b></font>"
                xRow.Cells.Add(xCell)
                '92
                xCell = New TableCell
                xCell.ColumnSpan = 3
                xCell.BackColor = Color.White
                xCell.VerticalAlign = VerticalAlign.Top
                xCell.Height = "50"
                If OrderInfoDR.Rows(0).Item("DefaultSalesNote").ToString.ToUpper = "Y" Then
                    xCell.Text = "<font color=""red""><b>&nbsp;" & OrderInfoDR.Rows(0).Item("SALES_NOTE") & "</b></font>"
                Else
                    xCell.Text = "<font color=""red""><b>&nbsp;" & Server.HtmlEncode(OrderInfoDR.Rows(0).Item("SALES_NOTE")) & "</b></font>"
                End If
                xRow.Cells.Add(xCell)
                Me.OrderInfo.Rows.Add(xRow)
                '10
                '----------------------------------
                xRow = New TableRow
                xCell = New TableCell
                xCell.Style.Value = "background-color:#f0f0f0;height:50px;width:15%"
                xCell.VerticalAlign = VerticalAlign.Middle
                xCell.HorizontalAlign = HorizontalAlign.Right
                xCell.Text = "<font color=""#333333""><b>OP Note&nbsp;&nbsp;</b></font>"
                xRow.Cells.Add(xCell)
                '10
                xCell = New TableCell
                xCell.ColumnSpan = 3
                xCell.BackColor = Color.White
                xCell.VerticalAlign = VerticalAlign.Top
                xCell.Height = "50"
                xCell.Text = "<font color=""red""><b>&nbsp;" & Server.HtmlEncode(OrderInfoDR.Rows(0).Item("OP_NOTE")) & "</b></font>"
                xRow.Cells.Add(xCell)
                Me.OrderInfo.Rows.Add(xRow)
                
                xRow = New TableRow
                xCell = New TableCell
                xCell.Style.Value = "background-color:#f0f0f0;height:50px;width:15%"
                xCell.VerticalAlign = VerticalAlign.Middle
                xCell.HorizontalAlign = HorizontalAlign.Right
                xCell.Text = "<font color=""#333333""><b>Projet Note&nbsp;&nbsp;</b></font>"
                xRow.Cells.Add(xCell)
                '10
                xCell = New TableCell
                xCell.ColumnSpan = 3
                xCell.BackColor = Color.White
                xCell.VerticalAlign = VerticalAlign.Top
                xCell.Height = "50"
                xCell.Text = "<font color=""red""><b>&nbsp;" & Server.HtmlEncode(OrderInfoDR.Rows(0).Item("prj_NOTE")) & "</b></font>"
                xRow.Cells.Add(xCell)
                Me.OrderInfo.Rows.Add(xRow)
            End If
        End If
        'g_adoConn.Close()
        
        '====Display Purchased Products
        '--Table Header
        '11
        '----------------------------------
        xRow = New TableRow
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Seq</b>"
        xRow.Cells.Add(xCell)
        '12
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Ln</b>"
        xRow.Cells.Add(xCell)
        
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Sales Leads from Advantech (DMF)</b>"
        xRow.Cells.Add(xCell)
        
       
        '13
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Product</b>"
        xRow.Cells.Add(xCell)
        
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Customer P\N</b>"
        xRow.Cells.Add(xCell)
        '14
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Description</b>"
        xRow.Cells.Add(xCell)
        '15
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Due Date</b>"
        xRow.Cells.Add(xCell)
        '16
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Req Date"
        xRow.Cells.Add(xCell)
        '17
        If Global_Inc.C_ShowRoHS = True Then
            xCell = New TableCell
            xCell.Style.Value = "background-color:#f0f0f0"
            xCell.VerticalAlign = VerticalAlign.Middle
            xCell.HorizontalAlign = HorizontalAlign.Center
            xCell.Text = "<b>RoHS</b>"
            xRow.Cells.Add(xCell)
        End If
        '17
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Class</b>"
        xRow.Cells.Add(xCell)
        '17
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Qty</b>"
        xRow.Cells.Add(xCell)
        '18
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Price</b>"
        xRow.Cells.Add(xCell)
        '19
        xCell = New TableCell
        xCell.Style.Value = "background-color:#f0f0f0"
        xCell.VerticalAlign = VerticalAlign.Middle
        xCell.HorizontalAlign = HorizontalAlign.Center
        xCell.Text = "<b>Subtotal</b>"
        xRow.Cells.Add(xCell)
        Me.PurchProd.Rows.Add(xRow)
        '-----Show Order Detail
        l_strSQLCmd = "select " & _
                      "b.part_no, a.currency, " & _
                      "b.line_no, " & _
                      "IsNull(b.DMF_Flag,'') as DMF_Flag, " & _
                      "b.part_no, " & _
                      "max(c.product_desc)" & strSlowMoving & " as product_desc," & _
                      "IsNull(case c.RoHS_Flag when 1 then 'Y' else 'N' end,'') as RoHS, " & _
                      "IsNull((select top 1 z.abc_indicator from sap_product_abc z where z.part_no=b.part_no),'') as Class, " & _
                      "b.due_date, " & _
                      "b.required_date, " & _
                      "b.qty, " & _
                      "b.auto_order_flag, " & _
                      "b.auto_order_qty, " & _
                      "b.supplier_due_date, " & _
                      "b.unit_price " & _
                      "from logistics_master a " & _
                      "inner join logistics_detail b " & _
                      "on a.logistics_id = b.logistics_id " & _
                      "left join sap_product c " & _
                      " on b.part_no = c.part_no " + _
                      " inner join sap_product_org d on c.part_no=d.part_no and d.org_id='" + Session("org_id") + "' " & _
                      "where a.logistics_id = '" & strPIId & "' " & _
                      "group by a.currency,b.line_no,b.DMF_Flag, b.part_no,c.RoHS_Flag,b.due_date,b.required_date,b.qty,b.auto_order_flag,b.auto_order_qty,b.supplier_due_date,b.unit_price " & _
                      "order by b.line_no "
        Dim PurchProdDT As New DataTable
        PurchProdDT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        
        ' --------------------------Peter add 2008/04/30 -----------------------------
        PurchProdDT.Columns.Add("judge_date")
        Dim drTwo() As System.Data.DataRow
        'IdTEst.DataSource = dtOne
        'IdTEst.DataBind()
        'Response.Write(dtOne.Rows.Count.ToString() & "<br />")
        'Response.Write(dtOne.Rows(0).Item("Part No").ToString())
        For Each dr As DataRow In PurchProdDT.Rows

            Dim strQuery As String = "[Part No]=" & "'" & dr.Item("part_no").ToString() & "' and [SCM Flag]='-1'"
            'Response.Write(strQuery)
            
            If dtOne IsNot Nothing AndAlso dtOne.Rows.Count > 0 Then
                drTwo = dtOne.Select(strQuery) 'dtOne.Select(strQuery)

                If drTwo.Length > 0 Then
                    dr.Item("judge_date") = "True"
                    'Response.Write(dr.Item("judge_date") & "four-ture <br />")
                    'Response.Write(dr.Item("judge_date"))
                Else
                    dr.Item("judge_date") = "False"
                    'Response.Write(dr.Item("judge_date") & "four-false <br />")
                    'Response.Write(dr.Item("judge_date"))
                End If
            End If

        Next
        '------------------------------------------------------------------------------
        
        Dim flgStdExist As String = "No"
        Dim flgBTOSExist As String = "No"
        Dim strCurrency As String = ""
        Dim strCurrSign As String = ""
        Dim flgBtosTBD As String = "No"
        Dim flgStdTBD As String = "No"
        Dim fltSubTotal As String = 0
        Dim fltBTOSTotal As String = 0
        
        Dim dtBTOItemDueDate As String = ""
        Dim fltBTOItemSum As Decimal = 0
        Dim fltBTOItemTotalSum As Decimal = 0
        If PurchProdDT.Rows.Count > 0 Then
            strCurrency = PurchProdDT.Rows(0).Item("currency")
            Select Case UCase(PurchProdDT.Rows(0).Item("currency"))
                Case "US", "USD"
                    strCurrSign = "$"
                Case "NT"
                    strCurrSign = "NT"
                Case "EUR"
                    strCurrSign = "&euro;"
                Case "GBP"
                    strCurrSign = "&pound;"
                Case Else
                    strCurrSign = "$"
            End Select
            
            flgBtosTBD = "No"
            flgStdTBD = "No"
            fltSubTotal = 0
            fltBTOSTotal = 0
            
            Dim l_strSQLCmdSum As String = ""
            Dim intX As Integer = 1
            While intX <= PurchProdDT.Rows.Count
                xRow = New TableRow
                If PurchProdDT.Rows(intX - 1).Item("line_no") < 100 Then
                    flgStdExist = "Yes"
                    If PurchProdDT.Rows(intX - 1).Item("unit_price") <= 0 Then
                        xRow.Style.Value = "BACKGROUND-COLOR: #ccffff;WIDTH=100%"
                    Else
                        xRow.Style.Value = ""
                    End If
                    '--NP
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:5%;"
                    xCell.HorizontalAlign = HorizontalAlign.Right
                    xCell.Text = "<font color=""#333333"">" & intX & "&nbsp;</font>"
                    xRow.Cells.Add(xCell)
                    '--Ln
                    xCell = New TableCell
                    Try
                        If PurchProdDT.Rows(intX - 1).Item("auto_order_flag") = "T" Then
                            xCell.Style.Value = "BACKGROUND-COLOR:#ccffff;width:3%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                        Else
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                        End If
                    Catch ex As Exception
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                    End Try
                    
                    xCell.Text = "<font color=""#333333"">" & PurchProdDT.Rows(intX - 1).Item("line_no") & "</font>"
                    xRow.Cells.Add(xCell)
                    
                    '--DMF_Flag
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                    If UCase(PurchProdDT.Rows(intX - 1).Item("DMF_Flag")) <> "" Then
                        xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" Checked=""Checked"" value=" & PurchProdDT.Rows(intX - 1).Item("line_no") & " ONCLICK=""DMFcheck(this,this.value)"" /></font>"
                    Else
                        xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" value=" & PurchProdDT.Rows(intX - 1).Item("line_no") & " ONCLICK=""DMFcheck(this,this.value)""""/></font>"
                    End If
                    xRow.Cells.Add(xCell)
                    '--Product
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:17%;"
                    If Util.IsAEUIT() Or _
                    Util.IsInternalUser2() Then
                        xCell.Text = "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "' >" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</a></font>"
                    Else
                        xCell.Text = "<font color=""#333333"">&nbsp;" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</font>"
                        
                    End If
                    xRow.Cells.Add(xCell)
                    
                    '--CustomerPN
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;"
                    xCell.Text = "<input type=""text"" id=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ name=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ value=""" & UCase(getCustomerNo(Session("Company_id"), PurchProdDT.Rows(intX - 1).Item("part_no"))) & """/>"
                    xRow.Cells.Add(xCell)
                    
                    '--Product Description
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:40%;"
                    xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("product_desc") & "</font>"
                    '--{2005-8-22}--Daive: Create a Promotion Flag in description
                    '---------------------------------------------------------------------------------------------------------
                    'If LCase(Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                    If Global_Inc.PromotionRelease() = True Then
                        Dim PromotionFlagSQL As String = ""
                        Dim PromotionFlagDatareader As DataTable
                        PromotionFlagSQL = "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and PART_NO='" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "' and Status='Yes'"
                        PromotionFlagDatareader = dbUtil.dbGetDataTable("B2B", PromotionFlagSQL)
                        If PromotionFlagDatareader.Rows.Count > 0 Then
                            xCell.Text = xCell.Text & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                        End If
                        'g_adoConn.Close()
                    End If
                    If UCase(PurchProdDT.Rows(intX - 1).Item("part_no")).ToString.Trim.IndexOf("AGS-EW-") = 0 And intX < 100 Then
                        xCell.Text = xCell.Text & "<br><b> For Line" & PurchProdDT.Rows(intX - 2).Item("line_no").ToString.Trim & ", P/N=" & PurchProdDT.Rows(intX - 2).Item("part_no").ToString.Trim & "</b>"
                    End If
                    '---------------------------------------------------------------------------------------------------------                    
                    xRow.Cells.Add(xCell)
                    '--Due Date
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                    xCell.HorizontalAlign = HorizontalAlign.Center
                    
                    If PurchProdDT.Rows(intX - 1).Item("part_no").ToString.ToUpper.IndexOf("AGS-EW-") = -1 Then
                        If Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) = "2020/10/10" Then
                            xCell.Text = "<font color=""#333333"">&nbsp;TBD</font>"
                        Else
                            If PurchProdDT.Rows(intX - 1).Item("judge_date").ToString() = "True" Then
                                xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font>"
                            Else
                                xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "</font>"
                            End If
                        End If
                    Else
                        If Global_Inc.FormatDate(PurchProdDT.Rows(intX - 2).Item("due_date")) = "2020/10/10" Then
                            xCell.Text = "<font color=""#333333"">&nbsp;TBD</font>"
                        Else
                            If PurchProdDT.Rows(intX - 2).Item("judge_date").ToString() = "True" Then
                                xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font>"
                            Else
                                xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "</font>"
                            End If
                        End If
                        'Jackie add 2007/03/23
                    End If
                    If OrderUtilities.IsGA(Session("Company_id")) Then
                        xCell.Text = "To be confirmed within 3 days"
                    End If
                    xRow.Cells.Add(xCell)
                    '--Require Date
                    xCell = New TableCell
                    If PurchProdDT.Rows(intX - 1).Item("required_date") = PurchProdDT.Rows(intX - 1).Item("due_date") Then
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                    Else
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffcccc;width:10%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                    End If
                    'Jackie 20070117
                    If PurchProdDT.Rows(intX - 1).Item("part_no").ToString.ToUpper.IndexOf("AGS-EW-") = -1 Then
                        xCell.Text = "<input type=""text"" runat=""server"" name=""required_date$$$" & PurchProdDT.Rows(intX - 1).Item("line_no") & """ size=""10"" readonly=""true""  value=""" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("required_date")) & """ Onclick=""PickDate('../INCLUDES/PickShippingCalendar.aspx','required_date$$$" & PurchProdDT.Rows(intX - 1).Item("line_no") & "','yyyy/MM/dd','EU10','EUH1')""  style=""font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; width: 60;text-align: left"">"
                    Else
                        xCell.Text = ""
                    End If
                    xRow.Cells.Add(xCell)
                    If Global_Inc.C_ShowRoHS = True Then
                        '--RoHS
                        xCell = New TableCell
                        xCell.Style.Value = "width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                        xCell.BackColor = Color.White
                        If PurchProdDT.Rows(intX - 1).Item("RoHS").ToString.ToLower = "y" Then
                            xCell.Text = "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/>"
                        Else
                            xCell.Text = "&nbsp;"
                        End If
                            
                        xRow.Cells.Add(xCell)
                    End If
                    '--Class
                    xCell = New TableCell
                    xCell.Style.Value = "width:5%;"
                    xCell.HorizontalAlign = HorizontalAlign.Center
                    xCell.BackColor = Color.White
                    If PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "A" Or PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "B" Then
                        xCell.Text = "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/>"
                    Else
                        xCell.Text = "&nbsp;"
                    End If
                    xRow.Cells.Add(xCell)
                    '--QTY
                    xCell = New TableCell
                    xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:5%;"
                    xCell.HorizontalAlign = HorizontalAlign.Right
                    xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("qty") & "</font>"
                    xRow.Cells.Add(xCell)
                    '--Unit Price and SubTotal
                    If PurchProdDT.Rows(intX - 1).Item("unit_price") <= 0 Then
                        fltSubTotal = fltSubTotal + 0
                        flgStdTBD = "Yes"
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;a"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;TBD</font>"
                        xRow.Cells.Add(xCell)
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:15%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">&nbsp;TBD</font>"
                        xRow.Cells.Add(xCell)
                        fltBTOSTotal = fltBTOSTotal + 0
                    Else
                        fltSubTotal = CDec(fltSubTotal) + CInt(PurchProdDT.Rows(intX - 1).Item("qty")) * CDec(PurchProdDT.Rows(intX - 1).Item("unit_price"))
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(PurchProdDT.Rows(intX - 1).Item("unit_price"), 2) & "</font>"
                        xRow.Cells.Add(xCell)
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:15%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(PurchProdDT.Rows(intX - 1).Item("unit_price") * PurchProdDT.Rows(intX - 1).Item("qty"), 2) & "</font>"
                        xRow.Cells.Add(xCell)
                    End If
                    Me.PurchProd.Rows.Add(xRow)
                Else
                    flgBTOSExist = "Yes"
                    If PurchProdDT.Rows(intX - 1).Item("line_no") Mod 100 = 0 Then
                        l_strSQLCmdSum = "select " & _
                                         "max(b.due_date) as BTOItemDueDate, " & _
                                         "sum(b.unit_price) as BTOItemSum, " & _
                                         "sum(b.unit_price * b.qty) as BTOItemTotalSum " & _
                                         "from logistics_master a " & _
                                         "inner join logistics_detail b " & _
                                         "on a.logistics_id = b.logistics_id " & _
                                         "where " & _
                                         "a.logistics_id = '" & strPIId & "' and " & _
                                         "len(b.line_no) >=3 and " & _
                                         "left(b.line_no,1) = left(" & PurchProdDT.Rows(intX - 1).Item("line_no") & ",1) and " & _
                                         "b.unit_price >= 0"
                        Dim l_SQLSumDR As DataTable
                        l_SQLSumDR = dbUtil.dbGetDataTable("B2B", l_strSQLCmdSum)
                        If l_SQLSumDR.Rows.Count > 0 Then
                            dtBTOItemDueDate = Global_Inc.FormatDate(l_SQLSumDR.Rows(0).Item("BTOItemDueDate"))
                            fltBTOItemSum = CDec(l_SQLSumDR.Rows(0).Item("BTOItemSum"))
                            fltBTOItemTotalSum = CDec(l_SQLSumDR.Rows(0).Item("BTOItemTotalSum"))
                        Else
                            fltBTOItemSum = 0
                            fltBTOItemTotalSum = 0
                        End If
                        
                        xRow.Style.Value = "font-weight: bold;BACKGROUND-COLOR: #ffcccc;WIDTH:100%;"
                        '--NP
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                        If PurchProdDT.Rows(intX - 1).Item("part_no") Like "*C-CTOS*" Then
                            xCell.Text = "<font color=""BLUE"">BTOS<br>(CTOS)</font>"
                        Else
                            xCell.Text = "<font color=""BLUE"">BTOS</font>"
                        End If
                        xRow.Cells.Add(xCell)
                        '--Ln
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">" & PurchProdDT.Rows(intX - 1).Item("line_no") & "</font>"
                        xRow.Cells.Add(xCell)
                        
                        '--DMF_Flag
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                        If UCase(PurchProdDT.Rows(intX - 1).Item("DMF_Flag")) <> "" Then
                            xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" Checked=""Checked"" value=" & PurchProdDT.Rows(intX - 1).Item("line_no") & " ONCLICK=""DMFcheck(this,this.value)"" /></font>"
                        Else
                            xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" value=" & PurchProdDT.Rows(intX - 1).Item("line_no") & " ONCLICK=""DMFcheck(this,this.value)""""/></font>"
                        End If
                        xRow.Cells.Add(xCell)
                        '--Product
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:17%;"
                        xCell.HorizontalAlign = HorizontalAlign.Left
                        If Util.IsAEUIT() Or _
                         Util.IsInternalUser2() Then
                            xCell.Text = "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "' >" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</a></font>"
                        Else
                            xCell.Text = "<font color=""#333333"">&nbsp;" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</font>"
                            
                        End If
                           
                        
                        'xCell.Text = "<font color=""#333333"">&nbsp;" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</font>"
                        xRow.Cells.Add(xCell)
                        '--CustomerPN
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;"
                        xCell.Text = "<input type=""text"" id=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ name=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ value=""" & UCase(getCustomerNo(Session("Company_id"), PurchProdDT.Rows(intX - 1).Item("part_no"))) & """/>"
                        xRow.Cells.Add(xCell)
                        '--Product Description
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:40%;"
                        xCell.HorizontalAlign = HorizontalAlign.Left
                        xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("product_desc") & "</font>"
                        '--{2005-8-22}--Daive: Create a Promotion Flag in description
                        '---------------------------------------------------------------------------------------------------------
                        'If LCase(Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                        If Global_Inc.PromotionRelease() = True Then
                            Dim PromotionFlagSQL As String = ""
                            Dim PromotionFlagDatareader As DataTable
                            PromotionFlagSQL = "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and PART_NO='" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "' and Status='Yes'"
                            PromotionFlagDatareader = dbUtil.dbGetDataTable("B2B", PromotionFlagSQL)
                            If PromotionFlagDatareader.Rows.Count > 0 Then
                                xCell.Text = xCell.Text & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                            End If
                            'g_adoConn.Close()
                        End If
                        '---------------------------------------------------------------------------------------------------------
                        xRow.Cells.Add(xCell)
                        '--Due Date
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                        'peter add 2008/04/30
                        If judgedate = "aaa" Then
                            xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font>"
                        Else
                            xCell.Text = "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("due_date")) & "</font>"
                        End If
                        If OrderUtilities.IsGA(Session("company_id")) Then
                            xCell.Text = "To be confirmed within 3 days"
                        End If
                        xRow.Cells.Add(xCell)
                        '--Require Date
                        xCell = New TableCell
                        If PurchProdDT.Rows(intX - 1).Item("required_date") = PurchProdDT.Rows(intX - 1).Item("due_date") Then
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Center
                        Else
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffcccc;width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Center
                        End If
                        xCell.Text = "<input type=""text"" readonly=""true"" runat=""server"" name=""required_date$$$" & PurchProdDT.Rows(intX - 1).Item("line_no") & """ size=""10""  value=""" & Global_Inc.FormatDate(PurchProdDT.Rows(intX - 1).Item("required_date")) & """ Onclick=""PickDate('../INCLUDES/PickShippingCalendar.aspx','required_date$$$" & PurchProdDT.Rows(intX - 1).Item("line_no") & "','yyyy/MM/dd','EU10','EUH1')""  style=""font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; width: 60;text-align: left"">"
                        xRow.Cells.Add(xCell)
                        If Global_Inc.C_ShowRoHS = True Then
                            '--RoHS
                            xCell = New TableCell
                            xCell.Style.Value = "width:5%;"
                            xCell.HorizontalAlign = HorizontalAlign.Center
                            xCell.BackColor = Color.White
                            If PurchProdDT.Rows(intX - 1).Item("RoHS").ToString.ToLower = "y" Then
                                xCell.Text = "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/>"
                            Else
                                xCell.Text = "&nbsp;"
                            End If
                            
                            xRow.Cells.Add(xCell)
                        End If
                        '--Class
                        xCell = New TableCell
                        xCell.Style.Value = "width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                        xCell.BackColor = Color.White
                        If PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "A" Or PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "B" Then
                            xCell.Text = "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/>"
                        Else
                            xCell.Text = "&nbsp;"
                        End If
                        xRow.Cells.Add(xCell)
                        '--QTY
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("qty") & "</font>"
                        xRow.Cells.Add(xCell)
                        '--Unit Price and SubTotal
                        If fltBTOItemSum <= 0 Then
                            fltBTOSTotal = CDec(fltBTOSTotal) + 0
                            flgBtosTBD = "Yes"
                            xCell = New TableCell
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;TBD</font>"
                            xRow.Cells.Add(xCell)
                            xCell = New TableCell
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:15%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"">&nbsp;TBD</font>"
                            xRow.Cells.Add(xCell)
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + CInt(PurchProdDT.Rows(intX - 1).Item("qty")) * CDec(PurchProdDT.Rows(intX - 1).Item("unit_price"))
                            xCell = New TableCell
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            If IsNumeric(fltBTOItemSum) Then
                                xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(fltBTOItemSum, 2) & "</font>"
                            Else
                                xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & "-1" & "</font>"
                            End If
                            xRow.Cells.Add(xCell)
                            xCell = New TableCell
                            xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:15%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            If IsNumeric(fltBTOItemTotalSum) Then
                                xCell.Text = "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(fltBTOItemTotalSum, 2) & "</font>"
                            Else
                                xCell.Text = "<font color=""#333333"">&nbsp;" & strCurrSign & "-1" & "</font>"
                            End If
                            xRow.Cells.Add(xCell)
                        End If
                        Me.PurchProd.Rows.Add(xRow)
                    Else
                        If PurchProdDT.Rows(intX - 1).Item("unit_price") <= 0 Then
                            xRow.Style.Value = "BACKGROUND-COLOR: #ccffff;WIDTH=100%"
                        Else
                            xRow.Style.Value = ""
                        End If
                        '--NP
                        xCell = New TableCell
                        xCell.Style.Value = "width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">&nbsp;</font>"
                        xRow.Cells.Add(xCell)
                        '--Ln
                        xCell = New TableCell
                        xCell.Style.Value = "width:3%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">" & PurchProdDT.Rows(intX - 1).Item("line_no") & "</font>"
                        xRow.Cells.Add(xCell)
                        '--DMF_Flag
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;width:3%;"
                        If UCase(PurchProdDT.Rows(intX - 1).Item("DMF_Flag")) <> "" Then
                            xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" Checked=""Checked"" disabled=""disabled"" /></font>"
                        Else
                            xCell.Text = "<font color=""#333333""><input id=""DMF_Flag"" type=""checkbox"" disabled=""disabled""/></font>"
                        End If
                        xRow.Cells.Add(xCell)
                        '--Product
                        xCell = New TableCell
                        xCell.Style.Value = "width:17%;"
                        xCell.HorizontalAlign = HorizontalAlign.Left
                        If Util.IsAEUIT() Or _
                        Util.IsInternalUser2() Then
                            xCell.Text = "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "' >" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</a></font>"
                        Else
                            xCell.Text = "<font color=""#333333"">&nbsp;" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</font>"
                            
                        End If
                        'xCell.Text = "<font color=""#333333"">&nbsp;" & UCase(PurchProdDT.Rows(intX - 1).Item("part_no")) & "</font>"
                        xRow.Cells.Add(xCell)
                       
                        '--CustomerPN
                        xCell = New TableCell
                        xCell.Style.Value = "BACKGROUND-COLOR:#ffffff;"
                        xCell.Text = "<input type=""text"" id=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ name=""CustomerPN" & UCase(PurchProdDT.Rows(intX - 1).Item("line_no")) & """ value=""" & UCase(getCustomerNo(Session("Company_id"), PurchProdDT.Rows(intX - 1).Item("part_no"))) & """/>"
                        xRow.Cells.Add(xCell)
                        '--Product Description --> combined by Product Desc, Due Date and Required Date
                        xCell = New TableCell
                        xCell.Style.Value = "width:40%;"
                        xCell.ColumnSpan = 3
                        xCell.HorizontalAlign = HorizontalAlign.Left
                        If InStr(UCase(PurchProdDT.Rows(intX - 1).Item("part_no")), "S-WARRANTY") <> 0 And OrderUtilities.BtosOrderCheck() = 1 Then
                            Dim EW_DescDR As DataTable
                            Dim strEWSQL As String = ""
                            strEWSQL = "Select CATEGORY_DESC from CONFIGURATION_CATALOG_CATEGORY where CATALOG_ID = '" & Session("G_CATALOG_ID") & "' and CATEGORY_ID = '" & PurchProdDT.Rows(intX - 1).Item("part_no") & "' and CATEGORY_TYPE = 'Component'"
                            EW_DescDR = dbUtil.dbGetDataTable("B2B", strEWSQL)
                            '---------{2005-10-24}--Jackie: get quotation ew_description
                            If EW_DescDR.Rows.Count > 0 Then
                                '-----------------------------------------------------
                                xCell.Text = "<font color=""#333333"">&nbsp;" & EW_DescDR.Rows(0).Item("CATEGORY_DESC") & "</font>"
                                '-----------------------------------------------------
                            Else
                                
                                'Dim g_adoConn1 As New SqlClient.SqlConnection
                                Dim EW_DescDR_Quote As DataTable
                                strEWSQL = "Select CATEGORY_DESC from QUOTATION_CATALOG_CATEGORY where CATALOG_ID = '" & Session("G_CATALOG_ID") & "' and CATEGORY_ID = '" & PurchProdDT.Rows(intX - 1).Item("part_no") & "' and CATEGORY_TYPE = 'Component'"
                                EW_DescDR_Quote = dbUtil.dbGetDataTable("B2B", strEWSQL)
                                If EW_DescDR_Quote.Rows.Count > 0 Then
                                    
                                Else
                                    xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("product_desc") & "</font>"
                                End If
                                xCell.Text = "<font color=""#333333"">&nbsp;" & EW_DescDR_Quote.Rows(0).Item("CATEGORY_DESC") & "</font>"
                                
                            End If
                            'g_adoConn.Close()
                            '-----------------------------------------------------					
                        Else
                            xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("product_desc") & "</font>"
                        End If
                        xRow.Cells.Add(xCell)
                        If Global_Inc.C_ShowRoHS = True Then
                            '--RoHS
                            xCell = New TableCell
                            xCell.Style.Value = "width:5%;"
                            xCell.HorizontalAlign = HorizontalAlign.Center
                            If PurchProdDT.Rows(intX - 1).Item("RoHS").ToString.ToLower = "y" Then
                                xCell.Text = "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/>"
                            Else
                                xCell.Text = "&nbsp;"
                            End If
                            
                            xRow.Cells.Add(xCell)
                        End If
                        '--Class
                        xCell = New TableCell
                        xCell.Style.Value = "width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Center
                        If PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "A" Or PurchProdDT.Rows(intX - 1).Item("Class").ToString.ToUpper = "B" Then
                            xCell.Text = "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/>"
                        Else
                            xCell.Text = "&nbsp;"
                        End If
                        xRow.Cells.Add(xCell)
                        '--QTY
                        xCell = New TableCell
                        xCell.Style.Value = "width:5%;"
                        xCell.HorizontalAlign = HorizontalAlign.Right
                        xCell.Text = "<font color=""#333333"">&nbsp;" & PurchProdDT.Rows(intX - 1).Item("qty") & "</font>"
                        xRow.Cells.Add(xCell)
                        '--Unit Price and SubTotal
                        If PurchProdDT.Rows(intX - 1).Item("unit_price") <= 0 Then
                            fltBTOSTotal = CDec(fltBTOSTotal) + 0
                            flgBtosTBD = "Yes"
                            xCell = New TableCell
                            xCell.Style.Value = "width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;TBD</font>"
                            xRow.Cells.Add(xCell)
                            xCell = New TableCell
                            xCell.Style.Value = "width:15%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"">&nbsp;TBD</font>"
                            xRow.Cells.Add(xCell)
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + CInt(PurchProdDT.Rows(intX - 1).Item("qty")) * CDec(PurchProdDT.Rows(intX - 1).Item("unit_price"))
                            xCell = New TableCell
                            xCell.Style.Value = "width:10%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(PurchProdDT.Rows(intX - 1).Item("unit_price"), 2) & "</font>"
                            xRow.Cells.Add(xCell)
                            xCell = New TableCell
                            xCell.Style.Value = "width:15%;"
                            xCell.HorizontalAlign = HorizontalAlign.Right
                            xCell.Text = "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(PurchProdDT.Rows(intX - 1).Item("unit_price") * PurchProdDT.Rows(intX - 1).Item("qty"), 2) & "</font>"
                            xRow.Cells.Add(xCell)
                        End If
                        Me.PurchProd.Rows.Add(xRow)
                    End If
                End If
                intX = intX + 1
            End While
        End If
        '-- Table Footer
        xRow = New TableRow
        If flgBTOSExist = "Yes" Then
            xCell = New TableCell
            xCell.Style.Value = "BACKGROUND-COLOR:#f0f0f0;width:100%;"
            If Global_Inc.C_ShowRoHS = True Then
                xCell.ColumnSpan = 13
            Else
                xCell.ColumnSpan = 12
            End If
            
            xCell.HorizontalAlign = HorizontalAlign.Right
            If fltBTOSTotal <= 0 Then
                xCell.Text = "<font colspan=""12"" color=""#333333""><b>BTOS(CTOS) Total:&nbsp;TBD</b></font>"
            Else
                If flgBtosTBD = "Yes" Then
                    xCell.Text = "<font colspan=""12"" color=""#333333""><b>BTOS(CTOS) Total:&nbsp;" & strCurrSign & FormatNumber(fltBTOSTotal, 2) & " + TBD</b></font>"
                Else
                    xCell.Text = "<font colspan=""12"" color=""#333333""><b>BTOS(CTOS) Total:&nbsp;" & strCurrSign & FormatNumber(fltBTOSTotal, 2) & "</b></font>"
                End If
            End If
            xRow.Cells.Add(xCell)
            Me.PurchProd.Rows.Add(xRow)
        End If
        
        Dim fltTotal As Decimal = 0
        fltTotal = CDec(fltSubTotal) + CDec(fltBTOSTotal)
        xRow = New TableRow
        xCell = New TableCell
        xCell.Style.Value = "BACKGROUND-COLOR:#f0f0f0;width:100%;"
        If Global_Inc.C_ShowRoHS = True Then
            xCell.ColumnSpan = 13
        Else
            xCell.ColumnSpan = 12
        End If
        xCell.HorizontalAlign = HorizontalAlign.Right
        If fltTotal <= 0 Then
            xCell.Text = "<font colspan=""11"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;TBD</b></font>"
        Else
            If flgStdTBD = "Yes" Or flgBtosTBD = "Yes" Then
                xCell.Text = "<font colspan=""11"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & " + TBD</b></font>"
            Else
                xCell.Text = "<font colspan=""11"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & "</b></font>"
            End If
        End If
        
        xRow.Cells.Add(xCell)
        Me.PurchProd.Rows.Add(xRow)
    End Sub

    Protected Sub dg1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs)
        If e.Item.ItemType <> ListItemType.Header And e.Item.ItemType <> ListItemType.Footer Then
            If Util.IsAEUIT() Or _
                    Util.IsInternalUser2() Then
                e.Item.Cells(1).Text = "<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & e.Item.Cells(1).Text & "' >" & e.Item.Cells(1).Text & "</A>"
            End If
            If (e.Item.Cells(3).Text.Trim.ToLower.IndexOf("2020/10/10") = 0) Then
                e.Item.Cells(3).Text = "TBD"
            End If
        End If

    End Sub
    
    Protected Sub BeforeBTOSDg_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs)
        If e.Item.ItemType <> ListItemType.Header And e.Item.ItemType <> ListItemType.Footer Then
            If Util.IsAEUIT() Or _
                  Util.IsInternalUser2() Then
                e.Item.Cells(1).Text = "<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & e.Item.Cells(1).Text & "' >" & e.Item.Cells(1).Text & "</A>"
            End If
            If (e.Item.Cells(3).Text.Trim.ToLower.IndexOf("2020/10/10") = 0) Then
                e.Item.Cells(3).Text = "TBD"
            End If
        End If

    End Sub
    
    Protected Sub AfterBTOSDg_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs)
        If e.Item.ItemType <> ListItemType.Header And e.Item.ItemType <> ListItemType.Footer Then
            If Util.IsAEUIT() Or _
                  Util.IsInternalUser2() Then
                e.Item.Cells(1).Text = "<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & e.Item.Cells(1).Text & "' >" & e.Item.Cells(1).Text & "</A>"
            End If
            If (e.Item.Cells(3).Text.Trim.ToLower.IndexOf("2020/10/10") = 0) Then
                e.Item.Cells(3).Text = "TBD"
            End If
        End If

    End Sub
    
    
    Function AdjustDD4ItemInMultipleLine(ByVal lid As String) As Boolean

        Dim pRs As DataTable = dbUtil.dbGetDataTable("B2B", _
                " select part_no,DeliveryPlant,line_no,qty " & _
                " from logistics_detail where logistics_id='" & lid & "' " & _
                " and part_no in " & _
                " (select part_no from logistics_detail where logistics_id='" & lid & "' " & _
                " and part_no not like 'AGS-EW-%' group by part_no,DeliveryPlant having count(line_no) > 1)" & _
                "  order by line_no ")
        
        For i As Integer = 0 To pRs.Rows.Count - 1
            
            Dim cqtyRs As DataTable = dbUtil.dbGetDataTable("B2B", _
                    " select sum(qty) as qty from logistics_detail where logistics_id='" & lid & "' " & _
                    " and part_no='" & pRs.Rows(i).Item("part_no") & "' " & _
                    " and DeliveryPlant='" & pRs.Rows(i).Item("DeliveryPlant") & "' " & _
                    " and line_no < " & CInt(pRs.Rows(i).Item("line_no")) & " having sum(qty) > 0 ")
            Dim CumQty As Integer = 0
            If cqtyRs.Rows.Count > 0 Then
                CumQty = CDbl(pRs.Rows(i).Item("qty")) + CDbl(cqtyRs.Rows(0).Item("qty"))
            Else
                CumQty = CDbl(pRs.Rows(i).Item("qty"))
            End If
            Dim LatestATP As DateTime = DateTime.Today()
            Dim DeliveryPlant As String = pRs.Rows(i).Item("DeliveryPlant")
            Dim NoATPFlag As String = "N" : Dim getATPFlag As Boolean = True
            getATPFlag = getLatestATP(UCase(pRs.Rows(i).Item("part_no")), CumQty, LatestATP, DeliveryPlant)
            If getATPFlag = False Then
                NoATPFlag = "Y"
            End If
            'Response.Write("<br>" & LatestATP)
            dbUtil.dbExecuteNoQuery("B2B", _
            "update logistics_detail set due_date='" & _
            cdate(LatestATP) & "',NoATPFlag='" & NoATPFlag & "' where logistics_id='" & _
            lid & "' and part_no='" & pRs.Rows(i).Item("part_no") & "' and line_no=" & pRs.Rows(i).Item("line_no"))
            'sqlConn.Close()
            'Jackie add 2007/03/23 to adjust the ew due date
            If dbUtil.dbGetDataTable("B2B", "select part_no from logistics_detail where logistics_id='" & _
                            lid & "' and line_no=" & (CInt(pRs.Rows(i).Item("line_no")) + 1).ToString & _
                            " and line_no<100 and part_no like 'ags-ew-%'").Rows.Count > 0 Then
                Dim EwSql As String = "update logistics_detail set due_date='" & _
                 cdate(LatestATP) & "' where logistics_id='" & _
        lid & "' and part_no like 'ags-ew-%' and line_no<100 and line_no=" & (CInt(pRs.Rows(i).Item("line_no")) + 1).ToString
                dbUtil.dbExecuteNoQuery("B2B", EwSql)
            End If
        Next
        

    End Function
    
    
    
    Function getLatestATP(ByVal part_no As String, ByVal Qty As Decimal, ByRef LatestATP As DateTime, ByVal DeliveryPlant As String) As Boolean
        Dim dt As New DataTable
        dt.Columns.Add("part_no", Type.GetType("System.String"))
        dt.Columns.Add("qty", Type.GetType("System.Decimal"))
        dt.Columns.Add("req_date", Type.GetType("System.DateTime"))
        dt.Columns.Add("due_date", Type.GetType("System.DateTime"))
        Dim r As DataRow = dt.NewRow()
        r.Item("part_no") = part_no
        r.Item("qty") = Qty
        r.Item("req_date") = Today()
        r.Item("due_date") = Today()
        dt.Rows.Add(r)
        Me.GetMultiATP(dt, DeliveryPlant)
        If dt.Rows.Count > 0 Then
            LatestATP = dt.Rows(0).Item("due_date")
            Return True
        Else
            If Left(DeliveryPlant.ToUpper, 2) = "TW" Then
                LatestATP = "2020/10/10"
                Return True
            Else
                LatestATP = Global_Inc.GetRPL(Session("company_id"), part_no, Today)
                Return False
            End If
        End If
    End Function
    
    Function GetMultiATP(ByRef dt As DataTable, ByVal DeliveryPlant As String) As Boolean
        
        Dim soldto_id As String = Session("company_id") '"EFFRFA01"   Jackie changed
        Dim shipto_id As String = soldto_id
        Dim dr As System.Data.SqlClient.SqlDataReader
        Dim oRsATPi As New DataTable
        Global_Inc.InitRsATPi(oRsATPi)
        Dim oRsATP As New DataTable
        Global_Inc.InitATPRs(oRsATP)
        
        For i As Integer = 0 To dt.Rows.Count - 1
            
            Dim row1 As DataRow = oRsATPi.NewRow()
            row1.Item("WERK") = DeliveryPlant
            row1.Item("MATNR") = UCase(dt.Rows(i).Item("part_no"))
            row1.Item("REQ_QTY") = dt.Rows(i).Item("qty")
            row1.Item("REQ_DATE") = dt.Rows(i).Item("req_date")
            row1.Item("REQ_DATE") = System.DateTime.Today()
            row1.Item("UNI") = "PC"
            If LCase(Session("user_id")) = "daive.wang@advantech.com.cn" Then
                Try
                    oRsATPi.Rows.Add(row1)
                Catch ex As Exception
                    Response.End()
                End Try
            Else
                oRsATPi.Rows.Add(row1)
            End If
        Next
        
        '--{2006-08-30}--Daive: add customer "B2BGUEST", get Due Date 
        Dim tempSoldTo As String = ""
        If LCase(Session("COMPANY_ID")) = "b2bguest" Then
            tempSoldTo = soldto_id
            soldto_id = Global_Inc.GetCompanyForB2BGuest() : shipto_id = soldto_id
        End If
        
        Dim strSendXml As String = Global_Inc.DataTableToADOXML(oRsATPi)
        Dim strRecXml As String = ""
        Dim strRemark As String = ""
        Dim sc3 As New B2BAEU_SAP_WS.B2B_AEU_WS
        Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc3.Url)
        sc3.Timeout = 999999
        Dim iRtn As Integer
        If Session("user_id").ToString.ToLower = "jackie.wu@advantech.com.cn" Then
            iRtn = sc3.GetMultiDueDate(soldto_id, shipto_id, "EU10", "10", "00", strSendXml, strRecXml, strRemark)
        Else
            iRtn = sc3.GetMultiDueDate(soldto_id, shipto_id, "EU10", "10", "00", strSendXml, strRecXml, strRemark)
        End If
        Dim ResultDs As New System.Data.DataSet
        Dim sr As New System.IO.StringReader(strRecXml)
        ResultDs.ReadXml(sr)
        '--{2006-08-30}--Daive: add customer "B2BGUEST", get Due Date. 
        If LCase(Session("COMPANY_ID")) = "b2bguest" Then
            soldto_id = tempSoldTo
            shipto_id = soldto_id
        End If
        
        Dim ATPResultTable As DataTable = ResultDs.Tables("row")
        If ATPResultTable Is Nothing Then
            dt = New DataTable
            Return False
        End If
        
        ResultDs.Tables(ResultDs.Tables.Count - 1).AcceptChanges()
        Try
            ResultDs.Relations.Remove("insert_row")
        Catch ex As Exception
            'SyncLock GetType(Order_Utilities)
            For i As Integer = 0 To dt.Rows.Count - 1
                dt.Rows(i).Item("due_date") = DateAdd(DateInterval.Day, 35, System.DateTime.Today())
            Next
            Exit Function
            'End SyncLock
        End Try
        ATPResultTable.Constraints.Remove("insert_row")
        ATPResultTable.Columns.Remove("mandt")
        ATPResultTable.Columns.Remove("due_date")
        ATPResultTable.Columns.Remove("due_date_scm")
        ATPResultTable.Columns.Remove("atp_date_scm")
        ATPResultTable.Columns.Remove("insert_Id")
        ATPResultTable.DefaultView.Sort = "part,date"
        ATPResultTable.AcceptChanges()
        
        Dim currPartNo As String = ""
        Dim cumATP As Integer = 0
        Dim SUPPLY_LT_Flag As Boolean = False
        'Dim dr1 As SqlClient.SqlDataReader = Me.dbDataReader("", "", "select distinct part_no from logistics_detail where logistics_id='" & StrLogistics_Id & "'")
        Dim ATPResultTb As New DataTable()
        For i As Integer = 0 To ATPResultTable.Columns.Count - 1
            Dim col1 As New DataColumn(ATPResultTable.Columns.Item(i).ColumnName, ATPResultTable.Columns.Item(i).DataType)
            ATPResultTb.Columns.Add(col1)
        Next
        
        'SyncLock (GetType(Order_Utilities))
        For j As Integer = 0 To dt.Rows.Count - 1
            Dim dtRow As DataRow()
            'If Global_Inc.IsNumericItem(dt.Rows(j).Item("part_no")) Then
            '    dtRow = ATPResultTable.Select("part='00000000" & dt.Rows(j).Item("part_no") & "'", "part asc,date asc")
            'Else
            dtRow = ATPResultTable.Select("part='" & dt.Rows(j).Item("part_no") & "' and site='" & DeliveryPlant & "'", "part asc,date asc")
            'End If
            
            cumATP = 0
            SUPPLY_LT_Flag = False
            
            For i As Integer = 0 To dtRow.GetUpperBound(0)
                dtRow(i).Item("qty_atp") = dtRow(i).Item("qty_atb") + cumATP
                dtRow(i).Item("type") = "5"
                cumATP = dtRow(i).Item("qty_atp")
                dtRow(i).Item("qty_lack") = dtRow(i).Item("qty_req") - dtRow(i).Item("qty_atp")
                If dtRow(i).Item("qty_lack") < 0 Then dtRow(i).Item("qty_lack") = 0
                dtRow(i).Item("qty_fulfill") = dtRow(i).Item("qty_atp")
                If dtRow(i).Item("qty_lack") = 0 And SUPPLY_LT_Flag.Equals(False) Then
                    dtRow(i).Item("type") = "6"
                    SUPPLY_LT_Flag = True
                    dt.Rows(j).Item("due_date") = Global_Inc.FormatDate(dtRow(i).Item("date"))
                    Return True
                End If
            Next
            
            'jackie addd 2007/08/24
            If SUPPLY_LT_Flag = False Then
                dt = New DataTable
                Return False
            End If
            
        Next
                
    End Function
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">

   <%-- <script type="text/jscript">--%>
      <script type="text/javascript" language="javascript">
    
    function PostBackOnChecked(){
        
        var o = window.event.srcElement;
        if (o.tagName == "INPUT"){
            //Hide mouse if possible
            document.body.style.cursor ="wait";     
            //__doPostBack("","");        
        } 
        
    }  
         
function PickDate(Url,Element,Format,SalesOrg,Plant){
  Url = Url + "?Type=shippingcalendar&Element=" + Element + "&Format=" + Format + "&SalesOrg=" + SalesOrg + "&CustomerId=&Plant=" + Plant
  //alert(Url);
  //alert(document.all.txtDate.value);
  window.open(Url,"pop","height=265,width=263,top=300,left=400,scrollbars=no")
} 
</script>
    <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td><uc3:OrderFlowState runat="server" id="OrderFlowState1" /></td>
        </tr>
        <tr>
            <td>
                <table id="Table2" width="100%">
                    <tr>
                        <td>
                            <div class="euPageTitle">
                                Due Date Calculation</div>
                        </td>
                    </tr>
                    <tr>
                        <td style="height:5px">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            NOTE: Due date will be identical with required date if the input required date is
                            later than system promised due date.<br />
                            NOTE: Required date will be updated on the next page.<br />
                        </td>
                    </tr>
                    <tr>
                        <td style="height:5px">&nbsp;</td>
                    </tr>                    
                    <tr>
                        <td valign="bottom">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="background-color:#6699cc;height:20px;padding-left: 10px; border-bottom: #ffffff 1px solid">
                                        <font color="#ffffff"><b>Order Information</b></font></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#bec4e3;height:17px;border-right: #cfcfcf 1px solid; border-top: #cfcfcf 1px solid;
                                        border-left: #cfcfcf 1px solid; border-bottom: #cfcfcf 1px solid">
                                        <asp:Table ID="OrderInfo" runat="server" CellPadding="2" CellSpacing="1" Height="17px" Width="100%">
                                        </asp:Table>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="background-color:#6699cc;height:20px;padding-left: 10px; border-bottom: #ffffff 1px solid">
                                        <font color="#ffffff"><b>Purchased Products</b></font></td>
                                </tr>
                                <tr>
                                    <td style="background-color:#bec4e3;height:17px;border-right: #cfcfcf 1px solid; border-top: #cfcfcf 1px solid;
                                        border-left: #cfcfcf 1px solid; border-bottom: #cfcfcf 1px solid">
                                        <asp:Table ID="PurchProd" runat="server" cellpadding="2" cellspacing="1" height="17" width="100%">
                                        </asp:Table>
                                    </td>
                                </tr>
                            </table>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="bottom">
                            <asp:ImageButton ID="GoPartialBtn" ImageUrl="../images/ebiz.aeu.face/btn_partial.gif" runat="server" Visible="false"
                                style="cursor: hand" />                                
                            <asp:ImageButton ID="GoPiPreviewBtn" ImageUrl="../images/ebiz.aeu.face/btn_next_step2.gif" runat="server"
                                style="cursor: hand" OnClick="GoPiPreviewBtn_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table id="Table3" width="100%">
                    <tr>
                        <td align="center" style="height:13px" valign="bottom">
                            <br />
                            <hr />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table> 
    <table width="100%" id="DDTraceTable">
        <tr>
		    <td valign="bottom"><div class="euPageTitle">Due Date Monitor</div></td>
        </tr>
        <tr><td rowspan="1"></td></tr>
        <tr>
            <td style="background-color:#6699CC;width:100%;"><font color="#ffffff"><b> After BTOS Process</b></font>
            &nbsp;<asp:DataGrid ID="AfterBTOSDg" runat="server" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal" Height="65px" width="100%" Visible="True" OnItemDataBound="AfterBTOSDg_ItemDataBound">
                        <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                        <SelectedItemStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                        <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" Mode="NumericPages" />
                        <AlternatingItemStyle BackColor="#F7F7F7" />
                        <ItemStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                        <HeaderStyle BackColor="#BEC4E3" Font-Bold="True" ForeColor="#F7F7F7" />
                    </asp:DataGrid>
            </td>
        </tr>
        <tr><td rowspan="1"></td></tr>
        <tr>
            <td style="background-color:#6699CC;width:100%;"><font color="#ffffff"><b> Without BTOS Process</b></font>
            &nbsp;<asp:DataGrid ID="BeforeBTOSDg" runat="server" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal" Height="65px" width="100%" Visible="True" OnItemDataBound="BeforeBTOSDg_ItemDataBound">
                        <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                        <SelectedItemStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                        <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" Mode="NumericPages" />
                        <AlternatingItemStyle BackColor="#F7F7F7" />
                        <ItemStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                        <HeaderStyle BackColor="#BEC4E3" Font-Bold="True" ForeColor="#F7F7F7" />
                    </asp:DataGrid>
            </td>
        </tr>
        <tr><td rowspan="1"></td></tr>
        <tr>
            <td id="ddTrace1" runat="server" visible="false" style="background-color:#6699CC;width:100%;"><font color="#ffffff"><b> Due Date Trace</b></font>
            &nbsp;<asp:DataGrid ID="dg1" runat="server" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal" Height="65px" width="100%" Visible="False" OnItemDataBound="dg1_ItemDataBound">
                        <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                        <SelectedItemStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                        <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" Mode="NumericPages" />
                        <AlternatingItemStyle BackColor="#F7F7F7" />
                        <ItemStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                        <HeaderStyle BackColor="#BEC4E3" Font-Bold="True" ForeColor="#F7F7F7" />
                    </asp:DataGrid>
            </td>        
        </tr>            
    </table> 
<script type="text/javascript">
        if (document.all) {    
            document.getElementById('<%=GoPiPreviewBtn.ClientID %>').onclick = PostBackOnChecked; }   
            //document.getElementById('GoPartialBtn').onclick = PostBackOnChecked; 
        function DMFcheck(obj,val)
        {
        if (obj.checked)
        {
        location.href("alterDMF.Aspx?DMF=1&LINE=" + val)
        }
        else
        {
        location.href("alterDMF.Aspx?DMF=0&LINE=" + val)
        }}
</script>
</asp:Content>