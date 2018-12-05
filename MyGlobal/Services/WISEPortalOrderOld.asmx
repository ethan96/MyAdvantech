<%@ WebService Language="VB" Class="WISEPortalOrder" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "MyAdvantech")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class WISEPortalOrder
    Inherits System.Web.Services.WebService 
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty! Shit!!"
    End Function
    
    
    Class ReturnResult
        Public Property IsSuccess As Boolean : Public Property ErrorMessage As String
        Public ERPID As String : Public OrgId As String : Public SONO As String : Public InventoryMatDoc As String
        Public Sub New()
            Me.IsSuccess = False : Me.ErrorMessage = ""
        End Sub
    End Class
    
    <WebMethod()> _
    Public Function WISEPoint2Order(MembershipEmail As String, WISE_PartNo As String, Qty As Integer, Amount As Decimal, AssetId As String) As String
        Amount = Math.Abs(Amount) : WISE_PartNo = Trim(WISE_PartNo)
        Dim ReturnResult1 As New ReturnResult(), jsr As New Script.Serialization.JavaScriptSerializer()
        Dim ERPId As String = String.Empty, OrgId As String = String.Empty ', SAPPartNo As String = String.Empty
        Dim sqlGetERPId As String = _
            " select distinct top 1 b.COMPANY_ID, b.ORG_ID, b.salesoffice, b.CURRENCY " + _
            " from SIEBEL_CONTACT a (nolock) inner join SAP_DIMCOMPANY b (nolock) on a.ERPID=b.COMPANY_ID  " + _
            " where a.EMAIL_ADDRESS not like '%@advantech%.%' and a.EMPLOYEE_FLAG='N' and a.ACTIVE_FLAG='Y' and b.COMPANY_TYPE='Z001' " + _
            " and b.ORG_ID not in ('CN02','CN11','CN12','CN13','CN20','CN30','CN40','EU20','EU30','EU31','EU32','EU33','EU34','EU50','TW02','TW03','TW04','TWCP','TW07') " + _
            " and dbo.IsEmail(a.EMAIL_ADDRESS)=1 " + _
            " and a.EMAIL_ADDRESS=@EMAIL " + _
            " order by b.ORG_ID  "
        Dim AptSiebel As New SqlClient.SqlDataAdapter(sqlGetERPId, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim dtERPId As New DataTable
        AptSiebel.SelectCommand.Parameters.AddWithValue("EMAIL", MembershipEmail)
        AptSiebel.Fill(dtERPId)
        AptSiebel.SelectCommand.Connection.Close()
        If dtERPId.Rows.Count = 0 Then
            ReturnResult1.ErrorMessage = "Cannot find a valid ERPID for this customer from Siebel"
            Return jsr.Serialize(ReturnResult1)
        Else
            ERPId = dtERPId.Rows(0).Item("COMPANY_ID") : OrgId = dtERPId.Rows(0).Item("ORG_ID")
        End If
        
        Dim sqlCheckWisePN As String = "select count(*) from WISE_PORTAL_PRODUCT where PART_NO=@PN"
        Dim cmdMyLocal As New SqlClient.SqlCommand(sqlCheckWisePN, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString))
        cmdMyLocal.Parameters.AddWithValue("PN", WISE_PartNo)
        cmdMyLocal.Connection.Open()
        Dim chkCount As Integer = CInt(cmdMyLocal.ExecuteScalar())
        cmdMyLocal.Connection.Close()
        If chkCount = 0 Then
            ReturnResult1.ErrorMessage = String.Format("{0} is not a WISE Portal Part Number", WISE_PartNo)
            Return jsr.Serialize(ReturnResult1)
        End If
        
        ReturnResult1.ERPID = ERPId : ReturnResult1.OrgId = OrgId
        'ERPId = "ASPA001" : OrgId = "TW01"
        
        'SAPPartNo = "WA-P81-U075E"
        
        Dim proxy1 As New SO_CREATE_COMMIT.SO_CREATE_COMMIT, OrderHeader As New SO_CREATE_COMMIT.BAPISDHD1, ItemIn As New SO_CREATE_COMMIT.BAPISDITMTable
        Dim PartNr As New SO_CREATE_COMMIT.BAPIPARNRTable, ScheLine As New SO_CREATE_COMMIT.BAPISCHDLTable, Conditions As New SO_CREATE_COMMIT.BAPICONDTable
       
        Dim distr_chan As String = "10", division As String = "00"
        
        If Trim(OrgId).ToUpper() = "US01" Then
            If dtERPId.Rows(0).Item("salesoffice") = "2300" Then
                distr_chan = "10" : division = "20"
            Else
                distr_chan = "30" : division = "10"
            End If
        End If
        
        Dim Currency As String = dtERPId.Rows(0).Item("CURRENCY")
      
        With OrderHeader
            .Doc_Type = "ZOR2" : .Sales_Org = OrgId : .Distr_Chan = distr_chan : .Division = division : .Currency = Currency
        End With
     
        'ERPId = "T00694868"
        Dim PartNr_Ship_Record As New SO_CREATE_COMMIT.BAPIPARNR
        PartNr_Ship_Record.Partn_Role = "WE" : PartNr_Ship_Record.Partn_Numb = ERPId
        PartNr.Add(PartNr_Ship_Record)
        Dim PartNr_Sold_Record As New SO_CREATE_COMMIT.BAPIPARNR
        PartNr_Sold_Record.Partn_Role = "AG" : PartNr_Sold_Record.Partn_Numb = ERPId
        PartNr.Add(PartNr_Sold_Record)
        
     
        Dim Item_Record_DownPay As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_DownPay As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_DownPay As New SO_CREATE_COMMIT.BAPICOND
            
        Item_Record_DownPay.Material = "DOWN-PAYMENT"
        Item_Record_DownPay.Itm_Number = 1 : Item_Record_DownPay.Ref_1 = "MyAdvantech"
        Item_Record_DownPay.Purch_No_C = AssetId
        ItemIn.Add(Item_Record_DownPay)
            
        ScheLine_Record_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number
        ScheLine_Record_DownPay.Req_Qty = Qty : ScheLine_Record_DownPay.Req_Date = Now.ToString("yyyyMMdd")
       
        ScheLine.Add(ScheLine_Record_DownPay)
        
        S_ConditionRow_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number : S_ConditionRow_DownPay.Cond_Type = "ZPN0" : S_ConditionRow_DownPay.Currency = Currency
        S_ConditionRow_DownPay.Cond_Value = Amount * -1 : Conditions.Add(S_ConditionRow_DownPay)
        
        
      
        Dim Item_Record_WISE As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_WISE As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_WISE As New SO_CREATE_COMMIT.BAPICOND
            
        Item_Record_WISE.Material = Global_Inc.Format2SAPItem(WISE_PartNo)
        Item_Record_WISE.Itm_Number = 2 : Item_Record_WISE.Ref_1 = "MyAdvantech"
        Item_Record_WISE.Purch_No_C = AssetId
        ItemIn.Add(Item_Record_WISE)
            
        ScheLine_Record_WISE.Itm_Number = Item_Record_WISE.Itm_Number
        ScheLine_Record_WISE.Req_Qty = Qty : ScheLine_Record_WISE.Req_Date = Now.ToString("yyyyMMdd")
       
        ScheLine.Add(ScheLine_Record_WISE)
        
        S_ConditionRow_WISE.Itm_Number = Item_Record_WISE.Itm_Number : S_ConditionRow_WISE.Cond_Type = "ZPN0" : S_ConditionRow_WISE.Currency = Currency
        S_ConditionRow_WISE.Cond_Value = Amount : Conditions.Add(S_ConditionRow_WISE)
        
        proxy1.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings("SAPConnTest"))
        'proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        proxy1.Connection.Open()
        Dim strError As String = "", strRelationType As String = "", strPConvert As String = "", strpintnumassign As String = ""
        Dim strPTestRun As String = "", Doc_Number As String = ""
        Dim retTable As New SO_CREATE_COMMIT.BAPIRET2Table
        Dim refDoc_Number As String = SAPDAL.SAPDAL.SO_GetNumber("WISE")
        Doc_Number = refDoc_Number
        
        ReturnResult1.SONO = refDoc_Number
        
        proxy1.Bapi_Salesorder_Createfromdat2( _
            strError, strRelationType, strPConvert, strpintnumassign, New SO_CREATE_COMMIT.BAPISDLS, _
            OrderHeader, New SO_CREATE_COMMIT.BAPISDHD1X, Doc_Number, New SO_CREATE_COMMIT.BAPI_SENDER, _
            strPTestRun, refDoc_Number, New SO_CREATE_COMMIT.BAPIPAREXTable, New SO_CREATE_COMMIT.BAPICCARDTable, _
            New SO_CREATE_COMMIT.BAPICUBLBTable, New SO_CREATE_COMMIT.BAPICUINSTable, New SO_CREATE_COMMIT.BAPICUPRTTable, _
            New SO_CREATE_COMMIT.BAPICUCFGTable, New SO_CREATE_COMMIT.BAPICUREFTable, New SO_CREATE_COMMIT.BAPICUVALTable, _
            New SO_CREATE_COMMIT.BAPICUVKTable, Conditions, New SO_CREATE_COMMIT.BAPICONDXTable, ItemIn, _
            New SO_CREATE_COMMIT.BAPISDITMXTable, New SO_CREATE_COMMIT.BAPISDKEYTable, PartNr, ScheLine, _
            New SO_CREATE_COMMIT.BAPISCHDLXTable, New SO_CREATE_COMMIT.BAPISDTEXTTable, New SO_CREATE_COMMIT.BAPIADDR1Table, retTable)
        
        proxy1.CommitWork() : proxy1.Connection.Close()
        
        Dim SOReturnList As New List(Of SO_CREATE_COMMIT.BAPIRET2)
        SOReturnList.AddRange(Util.DataTableToList(Of SO_CREATE_COMMIT.BAPIRET2)(retTable.ToADODataTable()))
        
        Dim SOErrors = From q In SOReturnList Where q.Type = "E"
                       
        If SOErrors.Count > 0 Then
            ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when creating SO:"
            For Each er In SOErrors
                ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
            Next
            ReturnResult1.IsSuccess = False
            Return jsr.Serialize(ReturnResult1)
        End If
        'gv1.DataSource = SOReturnList : gv1.DataBind()
        
        Dim proxy2 As New ZBAPI_GOODSMVT_CREATE.ZBAPI_GOODSMVT_CREATE(ConfigurationManager.AppSettings("SAPConnTest"))
        Dim GOODSMVT_HEADER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_01()
        Dim GOODSMVT_CODE As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_CODE()
        Dim GOODSMVT_ITEM As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATETable()
        Dim GOODSMVT_SERIALNUMBER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_SERIALNUMBERTable()
        Dim GOODSMVT_Return As New ZBAPI_GOODSMVT_CREATE.BAPIRET2Table()
        Dim GOODSMVT_HEADRET As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_RET()
        Dim MATERIALDOCUMENT As String = "", MATDOCUMENTYEAR As String = ""
        
        With GOODSMVT_HEADER
            .Pstng_Date = Now.ToString("yyyyMMdd")  '實際過帳日期
            .Doc_Date = Now.ToString("yyyyMMdd")    '單據日期
            .Pr_Uname = "b2baeu"
        End With
        GOODSMVT_CODE.Gm_Code = "05"    'fix "05" 
        
        Dim GOODSMVTItem1 As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATE()
        With GOODSMVTItem1
            .Material = Item_Record_WISE.Material : .Plant = Left(OrgId, 2) + "H1" : .Stge_Loc = "0000" : .Move_Type = "913" : .Entry_Qnt = Qty
        End With
        GOODSMVT_ITEM.Add(GOODSMVTItem1)
        
        
        proxy2.Connection.Open()
        proxy2.Zbapi_Goodsmvt_Create(GOODSMVT_CODE, GOODSMVT_HEADER, "", GOODSMVT_HEADRET, MATDOCUMENTYEAR, MATERIALDOCUMENT, GOODSMVT_ITEM, GOODSMVT_SERIALNUMBER, GOODSMVT_Return)
        proxy2.Connection.Close()
        
        Dim GoodMVTReturn As New List(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)
        GoodMVTReturn.AddRange(Util.DataTableToList(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)(GOODSMVT_Return.ToADODataTable()))
        
        Dim GoodMVTErrors = From q In GoodMVTReturn Where q.Type = "E"
        
        If GoodMVTErrors.Count > 0 Then
            ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when adding inventory:"
            For Each er In GoodMVTErrors
                ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
            Next
            ReturnResult1.IsSuccess = False
            Return jsr.Serialize(ReturnResult1)
        End If
        
        ReturnResult1.InventoryMatDoc = GOODSMVT_HEADRET.Mat_Doc
        ReturnResult1.IsSuccess = True
        Return jsr.Serialize(ReturnResult1)
    End Function

End Class
