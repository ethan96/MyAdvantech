<%@ WebService Language="VB" Class="ProductSearch" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class ProductSearch
    Inherits System.Web.Services.WebService 
    
	<WebMethod()> _
	Public Function HelloWorld() As String
		Return "Hello World"
	End Function

    <WebMethod()> _
    Public Function GetProduct(ByVal key As String) As DataSet
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(key))
        Dim strKey As String = fts.NormalForm.Replace("'", "''")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select * from ( "))
            .AppendLine(String.Format(" SELECT distinct top 500 a.Part_NO, IsNull(a.TUMBNAIL_IMAGE_ID,'') as TUMBNAIL_IMAGE_ID,  "))
            .AppendLine(String.Format(" a.ROHS_STATUS, a.PRODUCT_DESC, a.FEATURES, IsNull(a.EXTENTED_DESC,'') as EXTENTED_DESC, c.STATUS, "))
            .AppendLine(String.Format(" a.Model_No, a.product_group, "))
            .AppendLine(String.Format(" a.product_division, a.product_line "))
            .AppendLine(String.Format(" FROM PRODUCT_FULLTEXT_NEW AS a left join "))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	SELECT [key], [rank]  "))
            .AppendLine(String.Format(" 	FROM CONTAINSTABLE( "))
            .AppendLine(String.Format(" 			PRODUCT_FULLTEXT_NEW,  "))
            .AppendLine(String.Format(" 			(part_no, Model_no, PRODUCT_DESC,FEATURES,EXTENTED_DESC),  "))
            .AppendLine(String.Format(" 			N'{0}') ", strKey))
            .AppendLine(String.Format(" ) b on a.U_ID=b.[key] "))
            .AppendLine(String.Format(" inner join SAP_PRODUCT_ORG c on a.part_no=c.PART_NO and c.ORG_ID='US01'  "))
            .AppendLine(String.Format(" inner join SAP_PRODUCT d on a.part_no=d.PART_NO "))
            .AppendLine(String.Format(" where a.part_no not like 'C-CTOS%' and c.STATUS not in ('I','O','S1','L','V')  "))
            .AppendLine(String.Format(" and a.STATUS is not null and a.material_group not in ('ODM','T','ES','ZSRV','968MS')  "))
            .AppendLine(String.Format(" order by a.Part_NO "))
            .AppendLine(String.Format(" ) as tmp "))
        End With
        Dim dt As New DataTable("Product")
        dt = dbUtil.dbGetDataTable("MY", sb.ToString)
        Dim ds As New DataSet
        ds.Tables.Add(dt)
        Return ds
    End Function
End Class
