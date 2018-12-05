<%@ Page Title="ATW Common BTOS" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            Dim plines As New ArrayList
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                                    " select a.PART_NO, SUBSTRING( a.PART_NO,0,CHARINDEX('-',a.PART_NO)) as ProductLine, sum(a.ORDER_QTY) as Qty, count(distinct a.COMPANY_ID) as Customers " + _
                                    " from SAP_ORDER_HISTORY a with (nolock) inner join SAP_PRODUCT b with (nolock) on a.PART_NO=b.PART_NO  " + _
                                    " where a.PART_NO like '%-BTO' and a.PART_NO<>'PTRADE-BTO' and b.MATERIAL_GROUP in ('BTOS')  " + _
                                    " and a.SALES_ORG='TW01' and a.ORDER_DATE>=getdate()-1000 and b.STATUS='A' " + _
                                    " and SUBSTRING( a.PART_NO,0,CHARINDEX('-',a.PART_NO)) not in ('LCDP','LEDP','CAMPAIGN07') " + _
                                    " and a.PART_NO in (select distinct z.CATEGORY_ID from CBOM_CATALOG_CATEGORY z with (nolock) where z.ORG='TW' and z.PARENT_CATEGORY_ID='Root') " + _
                                    " group by a.PART_NO having sum(a.ORDER_QTY)>10 and count(distinct a.COMPANY_ID)>3 " + _
                                    " order by SUBSTRING( a.PART_NO,0,CHARINDEX('-',a.PART_NO)), sum(a.ORDER_QTY) desc, count(distinct a.COMPANY_ID) desc, a.PART_NO ")
            For Each r As DataRow In dt.Rows
                If Not plines.Contains(r.Item("ProductLine").ToString()) Then
                    Tree1.Nodes.Add(New TreeNode(r.Item("ProductLine").ToString(), r.Item("ProductLine").ToString()))
                    plines.Add(r.Item("ProductLine").ToString())
                Else
                    plines.Add(r.Item("ProductLine").ToString())
                End If
            Next
            
            For Each n As TreeNode In Tree1.Nodes
                Dim rs() As DataRow = dt.Select("ProductLine='" + Replace(n.Value, "'", "''") + "'")
                For Each r As DataRow In rs
                    Dim btoNode As New TreeNode(r.Item("PART_NO"), r.Item("PART_NO"))
                    btoNode.Target = "_blank" : btoNode.NavigateUrl = "../Order/Configurator.aspx?BTOITEM=" + btoNode.Value
                    n.ChildNodes.Add(btoNode)
                Next
            Next
            'Tree1.CollapseAll()
        End If
    End Sub

    Protected Sub Tree1_SelectedNodeChanged(sender As Object, e As EventArgs)
        If Tree1.SelectedNode.Depth = 1 Then
            Response.Redirect("../Order/Configurator.aspx?BTOITEM=" + Tree1.SelectedNode.Value)
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:TreeView runat="server" ID="Tree1" OnSelectedNodeChanged="Tree1_SelectedNodeChanged" />
</asp:Content>