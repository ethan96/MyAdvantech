<%@ WebService Language="VB" Class="AutoJob" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantechWS")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class AutoJob
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKittyClock() As String
        Return "Hello Kitty! It is now " + Now.ToLongTimeString()
    End Function
    
    <WebMethod()> _
    Public Function SyncSAP_TCURX() As Boolean
        Dim p1 As New Read_Sap_Table.Read_Sap_Table(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim readData As New Read_Sap_Table.TAB512Table
        p1.Rfc_Read_Table("|", "", "TCURX", 0, 0, readData, New Read_Sap_Table.RFC_DB_FLDTable, New Read_Sap_Table.RFC_DB_OPTTable)
        p1.Connection.Close()
        
        Dim dtTCURX As New DataTable : dtTCURX.Columns.Add("CURRENCY") : dtTCURX.Columns.Add("FACTOR")
        
        For Each DataRow As Read_Sap_Table.TAB512 In readData
            Dim columns() As String = Split(DataRow.Wa, "|")
            For Each col As String In columns
                col = Trim(col)
            Next
            Dim recTCURX As DataRow = dtTCURX.NewRow()
            recTCURX.Item("CURRENCY") = columns(0) : recTCURX.Item("FACTOR") = columns(1)
            dtTCURX.Rows.Add(recTCURX)
        Next
        Dim myConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim bk As New SqlClient.SqlBulkCopy(myConn)
        Dim cmd As New SqlClient.SqlCommand("truncate table SAP_TCURX", myConn)
        myConn.Open()
        cmd.ExecuteNonQuery()
        bk.DestinationTableName = "SAP_TCURX"
        bk.WriteToServer(dtTCURX)
        myConn.Close()
        Return True
    End Function
    
    <WebMethod()> _
    Public Function SyncCatalogPriceATP() As Boolean
        Dim _ip As String = Util.GetClientIP()
        If _ip.StartsWith("172.20.1.") OrElse _ip.StartsWith("127.") OrElse _ip.Contains("10.0.0.234") Then
                Try
                    Dim sb As New StringBuilder
                    With sb
                        .AppendLine(String.Format(" select top 999 a.PART_NO  "))
                        .AppendLine(String.Format(" from SAP_PRODUCT a "))
                        .AppendLine(String.Format("where  (a.PART_NO like '20000%' or a.PART_NO like '86%') and a.PRODUCT_HIERARCHY in ('AGSG-CTOS-0000','OTHR-MEMO-0000')  "))
                        .AppendLine(String.Format(" order by a.PART_NO  "))
                    End With
                    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                    dt.Columns.Add("Price", GetType(Double)) : dt.Columns.Add("ATP", GetType(Integer))
                    Dim pdt As DataTable = PricingUtil.GetProductsTableDef(), err As String = ""
                    For Each r As DataRow In dt.Rows
                        Dim pr As DataRow = pdt.NewRow()
                        pr.Item("PartNo") = r.Item("PART_NO") : pr.Item("Qty") = 1 : pdt.Rows.Add(pr)
                    Next
                Dim rdt As DataTable = PricingUtil.GetMultiPrice("TW01", "ADVANA", pdt, err)
                    Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
                    p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                    p1.Connection.Open()
                    For Each r As DataRow In dt.Rows
                        Dim rs() As DataRow = rdt.Select("Matnr='" + r.Item("PART_NO") + "'")
                        If rs.Length > 0 Then
                            r.Item("Price") = rs(0).Item("Netwr")
                        Else
                            r.Item("Price") = -1
                        End If
                
                        If Trim(r.Item("PART_NO")) <> "" Then
                            Dim dttemp As New DataTable
                            'Ming  add 2013-11-29  抽离getInventoryAndATPTable的调用,自己本身调用Bapi
                            'SAPtools.getInventoryAndATPTable(r.Item("PART_NO"), "TWH1", 0, "", 0, dttemp)
                            Dim PartNo = Global_Inc.Format2SAPItem(Trim(UCase(r.Item("PART_NO"))))
                            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                            Dim rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
                            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, UCase("TWH1"), "", "", "", "", "PC", "", 0, "", "", _
                                       New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                  
                            dttemp = atpTb.ToADODataTable()
                            'end
                            Dim MRPATP As Double = GetMRPATP(r.Item("PART_NO"), "TWH1", "SubcSt")
                        If dttemp Is Nothing OrElse dttemp.Rows.Count = 0 Then
                            r.Item("ATP") = 0
                        Else
                            Dim intATP As Integer = 0
                            For Each atpr As DataRow In dttemp.Rows
                                If Double.TryParse(atpr.Item("com_qty"), 0) Then intATP += atpr.Item("com_qty")
                            Next
                            If MRPATP > 0 Then intATP += MRPATP
                            r.Item("ATP") = intATP
                        End If
                        End If
                    Next
                    p1.Connection.Close()
                    dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", "truncate table CATALOG_PRICE_ATP")
                    Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
                    bk.DestinationTableName = "CATALOG_PRICE_ATP"
                    bk.WriteToServer(dt)
                    MailUtil.SendEmail("myadvantech@advantech.com", "ebusiness.aeu@advantech.eu", "OK sync catalog price & ATP", "wrote " + dt.Rows.Count.ToString(), False, "", "")
                    Return True
                Catch ex As Exception
                    MailUtil.SendEmail("myadvantech@advantech.com", "ebusiness.aeu@advantech.eu", "Error sync catalog price & ATP", ex.ToString(), False, "", "")
                    Return False
                End Try
            End If
            Return False
    End Function
    
    Function GetMRPATP(ByVal partno As String, ByVal plant As String, ByVal Delb0 As String) As Double
        Dim p As New Z_MD_MRP_LIST_API.Z_MD_MRP_LIST_API
        Dim mdkpDt As New Z_MD_MRP_LIST_API.MDKP, mt61dDt As New Z_MD_MRP_LIST_API.MT61D
        Dim mdezDt As New Z_MD_MRP_LIST_API.MDEZTable, mdpsDt As New Z_MD_MRP_LIST_API.MDPSTable
        Dim mdsuDt As New Z_MD_MRP_LIST_API.MDSUTable
        Dim retATP As Double = -1
        p.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Try
            p.Connection.Open()
            p.Z_Md_Mrp_List_Api(0, "", "", "", "", "", "0000000000", "", "", Global_Inc.Format2SAPItem(partno), "000", "X", plant, mdkpDt, mt61dDt, mdezDt, mdpsDt, mdsuDt)
            Dim dt As DataTable = mdezDt.ToADODataTable()
            Dim rs() As DataRow = dt.Select("Delb0='" + Delb0 + "'")
            If rs.Length > 0 Then
                retATP = rs(0).Item("Mng01")
            End If
        Catch ex As Exception

        End Try
        p.Connection.Close()
        Return retATP
    End Function

End Class
