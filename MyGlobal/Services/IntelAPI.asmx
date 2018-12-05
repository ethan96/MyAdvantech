<%@ WebService Language="VB" Class="IntelAPI" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="my.advantech.com")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class IntelAPI
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function GetIntelProducts() As String
        Dim dtUsBuyProd As DataTable = dbUtil.dbGetDataTable("AdvStore", _
       "SELECT a.DisplayPartno FROM [eStoreProduction].[dbo].[Product] a where StoreID='AUS' and a.PublishStatus=1")
        
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select a.PART_NO, a.MODEL_NO, cast(a.[Launch Date] as date) as [Launch Date], a.[eStore URL],  ")
            .AppendLine(" ( ")
            .AppendLine(" 	select top 1 z1.INTERESTED_PRODUCT_DISPLAY_NAME  ")
            .AppendLine(" 	from PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING z1  ")
            .AppendLine(" 	where z1.ITEM_TYPE='model' and z1.ITEM_ID=a.MODEL_NO ")
            .AppendLine(" 	order by z1.INTERESTED_PRODUCT_DISPLAY_NAME ")
            .AppendLine(" ) as [Product Category], ")
            .AppendLine(" ( ")
            .AppendLine(" 	select top 1 z1.PRODUCT_GROUP_DISPLAY_NAME  ")
            .AppendLine(" 	from PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING z1 ")
            .AppendLine(" 	where z1.ITEM_TYPE='model' and z1.ITEM_ID=a.MODEL_NO ")
            .AppendLine(" 	order by z1.PRODUCT_GROUP_DISPLAY_NAME ")
            .AppendLine(" ) as [Product Group], ")
            .AppendLine(" IsNull( ")
            .AppendLine(" 	( ")
            .AppendLine(" 		select z.AttrCatName+':'+z.AttrValueName +';' ")
            .AppendLine(" 		from PIS.dbo.[V_Spec_V2] z  ")
            .AppendLine(" 		where z.ProductNo=a.PART_NO and ")
            .AppendLine(" 		( ")
            .AppendLine(" 			z.AttrValueName like '%intel%' or ")
            .AppendLine(" 			z.AttrValueName like '%atom%' or ")
            .AppendLine(" 			z.AttrValueName like '%Celeron%' or ")
            .AppendLine(" 			z.AttrValueName like '%Pentium%' or ")
            .AppendLine(" 			z.AttrValueName like '%Xeon%' or ")
            .AppendLine(" 			z.AttrValueName like '%Core i%'  ")
            .AppendLine(" 		) 	 ")
            .AppendLine(" 		order by z.AttrCatName, z.AttrValueName  ")
            .AppendLine(" 		for xml path('') ")
            .AppendLine(" 	), ")
            .AppendLine(" 	( ")
            .AppendLine(" 		select z.AttrCatName+':'+z.AttrValueName +';' ")
            .AppendLine(" 		from PIS.dbo.[V_Spec_V2] z  ")
            .AppendLine(" 		where z.ProductNo=a.MODEL_NO and ")
            .AppendLine(" 		( ")
            .AppendLine(" 			z.AttrValueName like '%intel%' or ")
            .AppendLine(" 			z.AttrValueName like '%atom%' or ")
            .AppendLine(" 			z.AttrValueName like '%Celeron%' or ")
            .AppendLine(" 			z.AttrValueName like '%Pentium%' or ")
            .AppendLine(" 			z.AttrValueName like '%Xeon%' or ")
            .AppendLine(" 			z.AttrValueName like '%Core i%'  ")
            .AppendLine(" 		) 	 ")
            .AppendLine(" 		order by z.AttrCatName, z.AttrValueName  ")
            .AppendLine(" 		for xml path('') ")
            .AppendLine(" 	) ")
            .AppendLine(" ) as [Processor],  ")
            .AppendLine(" 'http://www.advantech.com/products/' + a.MODEL_NO + '/mod_' + a.MODEL_ID + '.aspx' as [Model URL],  ")
            .AppendLine("  (select top 1 z.Active_FLG from PISBackend.dbo.Model_Publish z where z.Model_name=a.MODEL_NO and Site_ID='ACL') as [Model Active Flag], ")
            .AppendLine(" ( ")
            .AppendLine(" 	select top 1 'http://support.advantech.com/support/downloadDatasheet.aspx?Literature_ID=' + z1.literature_id ")
            .AppendLine(" 	from PIS.dbo.Model_lit z1 inner join PIS.dbo.LITERATURE z2 on z1.literature_id=z2.LITERATURE_ID  ")
            .AppendLine(" 	where z2.LIT_TYPE='Product - Datasheet' and z2.LANG='ENU' and z1.model_name=a.MODEL_NO ")
            .AppendLine(" 	order by z2.LAST_UPDATED desc, z2.CREATED desc ")
            .AppendLine("  ")
            .AppendLine(" ) as [Datasheet URL], a.LIST_PRICE, ")
            .AppendLine(" (select top 1 z.CREATED_BY from PIS.dbo.model z where z.MODEL_ID=a.MODEL_ID) as [Created By],  ")
            .AppendLine(" (select top 1 z.LAST_UPDATED_BY  from PIS.dbo.model z where z.MODEL_ID=a.MODEL_ID order by z.LAST_UPDATED desc) as [Last Updated By] ")
            .AppendLine(" from ")
            .AppendLine(" ( ")
            .AppendLine(" 	select a.PART_NO, a.[Launch Date], a.[eStore URL], IsNull(a.PIS_MODEL_ID, a.PLM_MODEL_ID) as MODEL_ID, IsNull(a.PIS_MODEL_NO,a.PLM_MODEL_NO) as MODEL_NO, a.LIST_PRICE  ")
            .AppendLine(" 	from ")
            .AppendLine(" 	( ")
            .AppendLine(" 		select a.PART_NO, c.LIST_PRICE, ")
            .AppendLine(" 		IsNull(b.RELEASE_DATE,cast(a.CREATE_DATE as datetime)) as [Launch Date],   ")
            .AppendLine(" 		'http://buy.advantech.com/Product/Product.aspx?ProductID='+a.PART_NO as [eStore URL],  ")
            .AppendLine(" 		(select top 1 z2.MODEL_ID from PIS.dbo.model_product z1 inner join PIS.dbo.model z2 on z1.model_name=z2.MODEL_NAME where z1.part_no=a.PART_NO and z1.relation='product' order by z1.Last_update_date desc, z1.created_date desc) as PIS_MODEL_ID, ")
            .AppendLine(" 		(select top 1 z.model_name from PIS.dbo.model_product z where z.part_no=a.PART_NO and z.relation='product' order by z.Last_update_date desc, z.created_date desc) as PIS_MODEL_NO, ")
            .AppendLine(" 		a.MODEL_NO as PLM_MODEL_NO, (select top 1 z.MODEL_ID from PIS.dbo.model z where z.MODEL_NAME=a.MODEL_NO order by z.LAST_UPDATED_BY desc, a.CREATE_DATE desc) as PLM_MODEL_ID ")
            .AppendLine(" 		from SAP_PRODUCT a left join PLM_PHASEIN b on a.PART_NO=b.ITEM_NUMBER left join eQuotation.dbo.PRODUCT_LIST_PRICE c on a.PART_NO=c.PART_NO  ")
            .AppendLine(" 		where c.ORG='US01' and c.CURRENCY='USD' ")
            .AppendLine(" 		and a.PART_NO in  ")
            .AppendLine(" 		( ")
            .AppendLine(" 			select a.ProductNo ")
            .AppendLine(" 			from [PIS].[dbo].[V_Spec_V2] a  ")
            .AppendLine(" 			where a.ItemType='Part' and a.ProductNo is not null and ")
            .AppendLine(" 			( ")
            .AppendLine(" 				a.AttrValueName like '%intel%' or ")
            .AppendLine(" 				a.AttrValueName like '%atom%' or ")
            .AppendLine(" 				a.AttrValueName like '%Celeron%' or ")
            .AppendLine(" 				a.AttrValueName like '%Pentium%' or ")
            .AppendLine(" 				a.AttrValueName like '%Xeon%' or ")
            .AppendLine(" 				a.AttrValueName like '%Core i%'  ")
            .AppendLine(" 			) ")
            .AppendLine(" 			union ")
            .AppendLine(" 			select distinct b.part_no ")
            .AppendLine(" 			from [PIS].[dbo].[V_Spec_V2] a inner join PIS.dbo.model_product b on a.ProductNo=b.model_name  ")
            .AppendLine(" 			where a.ItemType='Model' and  ")
            .AppendLine(" 			( ")
            .AppendLine(" 				a.AttrValueName like '%intel%' or ")
            .AppendLine(" 				a.AttrValueName like '%atom%' or ")
            .AppendLine(" 				a.AttrValueName like '%Celeron%' or ")
            .AppendLine(" 				a.AttrValueName like '%Pentium%' or ")
            .AppendLine(" 				a.AttrValueName like '%Xeon%' or ")
            .AppendLine(" 				a.AttrValueName like '%Core i%'  ")
            .AppendLine(" 			) and b.relation='product' and b.part_no is not null ")
            .AppendLine(" 		) and a.STATUS in ('S5','A') and a.MATERIAL_GROUP in ('PRODUCT') and a.MODEL_NO<>'' ")
            .AppendLine(" 	) a ")
            .AppendLine(" 	where a.PIS_MODEL_ID is not null or a.PLM_MODEL_ID is not null ")
            .AppendLine(" ) a ")
            .AppendLine("   order by a.model_no, a.part_no ")
        End With
        Dim dtInteProd As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        For Each intelProd As DataRow In dtInteProd.Rows
            If dtUsBuyProd.Select("DisplayPartno='" + intelProd.Item("PART_NO").ToString().Replace("'", "''") + "'").Length = 0 Then
                intelProd.Item("eStore URL") = "" : intelProd.Item("LIST_PRICE") = DBNull.Value
            End If
            If Not intelProd.Item("Model Active Flag").ToString.Equals("Y") Then
                intelProd.Item("Model URL") = "" : intelProd.Item("Datasheet URL") = ""
            End If
        Next
        With dtInteProd.Columns
            .Remove("Model Active Flag") : .Remove("LIST_PRICE") : .Remove("Created By") : .Remove("Last Updated By")
        End With
       
        Return DataTableToJSON(dtInteProd)
    End Function
    
    Public Shared Function DataTableToJSON(table As DataTable) As String
        Dim list As New List(Of Dictionary(Of String, Object))()

        For Each row As DataRow In table.Rows
            Dim dict As New Dictionary(Of String, Object)()

            For Each col As DataColumn In table.Columns
                dict(col.ColumnName) = row(col)
            Next
            list.Add(dict)
        Next
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(list)
    End Function
    
End Class
