<%@ WebHandler Language="VB" Class="SyncCatalogPriceATP" %>

Imports System
Imports System.Web

Public Class SyncCatalogPriceATP : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest 
        Dim _ip As String = Util.GetClientIP()
        If _ip.StartsWith("172.20.1.*") OrElse _ip.StartsWith("127.*") Or True Then
            Try
                Dim sb As New StringBuilder
                With sb
                    .AppendLine(String.Format(" select top 999 a.PART_NO  "))
                    .AppendLine(String.Format(" from SAP_PRODUCT a "))
                    .AppendLine(String.Format(" where a.PART_NO like '20000%' and a.PRODUCT_HIERARCHY in ('AGSG-CTOS-0000','OTHR-MEMO-0000')  "))
                    .AppendLine(String.Format(" order by a.PART_NO  "))
                End With
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                dt.Columns.Add("Price", GetType(Double)) : dt.Columns.Add("ATP", GetType(Integer))
                Dim pdt As DataTable = PricingUtil.GetProductsTableDef(), err As String = ""
                For Each r As DataRow In dt.Rows
                    Dim pr As DataRow = pdt.NewRow()
                    pr.Item("PartNo") = r.Item("PART_NO") : pr.Item("Qty") = 1 : pdt.Rows.Add(pr)
                Next
                Dim rdt As DataTable = PricingUtil.GetMultiPrice("TW01", "UUAASC", pdt, err)
                For Each r As DataRow In dt.Rows
                    Dim rs() As DataRow = rdt.Select("Matnr='" + r.Item("PART_NO") + "'")
                    If rs.Length > 0 Then
                        r.Item("Price") = rs(0).Item("Netwr")
                    Else
                        r.Item("Price") = -1
                    End If
                
                    If Trim(r.Item("PART_NO")) <> "" Then
                        Dim dttemp As New DataTable
                        SAPtools.getInventoryAndATPTable(r.Item("PART_NO"), "TWH1", 0, "", 0, dttemp)
                        If dttemp Is Nothing OrElse dttemp.Rows.Count = 0 Then
                        Else
                            Dim intATP As Integer = 0
                            For Each atpr As DataRow In dttemp.Rows
                                If Double.TryParse(atpr.Item("com_qty"), 0) Then intATP += atpr.Item("com_qty")
                            Next
                            r.Item("ATP") = intATP
                        End If
                    End If
                Next
                dbUtil.dbExecuteNoQuery("MyDM", "truncate table CATALOG_PRICE_ATP")
                Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MyDM").ConnectionString)
                bk.DestinationTableName = "CATALOG_PRICE_ATP"
                bk.WriteToServer(dt)
                MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "OK sync catalog price & ATP", "wrote " + dt.Rows.Count.ToString(), False, "", "")
            Catch ex As Exception
                MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Error sync catalog price & ATP", ex.ToString(), False, "", "")
            End Try
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class