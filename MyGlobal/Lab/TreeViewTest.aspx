<%@ Page Language="VB" %>

<%@ Import Namespace="System.Diagnostics" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim errmsg As String = String.Empty
                
        Dim str As New StringBuilder
        
        Dim xwatch As Stopwatch = New Stopwatch
        xwatch.Start()
        Dim t0 As Long = xwatch.ElapsedMilliseconds
        str.AppendLine(" WITH CATEGORY_CTE([UID],CATEGORY_ID,  CATEGORY_TYPE, PARENT_CATEGORY_ID,ORG , SEQ_NO, LVL, CATEGORY_PATH ) ")
        str.AppendLine(" AS( ")
        str.AppendLine(" SELECT [UID], CATEGORY_ID, CATEGORY_TYPE, PARENT_CATEGORY_ID,ORG, SEQ_NO, 0 AS LVL ")
        'str.AppendLine(" , CAST(isnull(SEQ_NO,'0') AS NVARCHAR(1000)) as CATEGORY_PATH ")
        str.AppendLine(" , CAST([UID] AS NVARCHAR(1000)) as CATEGORY_PATH ")
        str.AppendLine(" FROM CBOM_CATALOG_CATEGORY_YL ")
        str.AppendLine(" WHERE CBOM_CATALOG_CATEGORY_YL.PARENT_CATEGORY_ID = 'Root' ")
        str.AppendLine(" AND CATEGORY_ID ='ACP-1010-BTO' AND ORG='EU' ")
        str.AppendLine(" UNION ALL ")
        str.AppendLine(" SELECT C.[UID], C.CATEGORY_ID, C.CATEGORY_TYPE, C.PARENT_CATEGORY_ID,C.ORG, C.SEQ_NO, CC.LVL + 1 ")
        'str.AppendLine(" , CATEGORY_PATH=cast(CC.CATEGORY_PATH + '\' + cast(isnull(C.SEQ_NO,'0') as nvarchar(1000)) as nvarchar(1000) ) ")
        str.AppendLine(" , CATEGORY_PATH=cast(CC.CATEGORY_PATH + '/' + cast(C.[UID] as nvarchar(1000)) as nvarchar(1000) ) ")
        str.AppendLine(" FROM CBOM_CATALOG_CATEGORY_YL AS C ")
        str.AppendLine(" INNER JOIN CATEGORY_CTE AS CC ON C.PARENT_CATEGORY_ID = CC.CATEGORY_ID ")
        str.AppendLine(" and C.ORG=CC.ORG ")
        str.AppendLine(" ) ")
        str.AppendLine(" SELECT * FROM CATEGORY_CTE ")
        str.AppendLine(" ORDER BY LVL,PARENT_CATEGORY_ID,SEQ_NO ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", str.ToString)
        'Me.GridView1.DataSource = dt
        'Me.GridView1.DataBind()
        xwatch.Stop()
        Dim t1 = xwatch.ElapsedMilliseconds
        xwatch.Reset()
        xwatch.Start()
        
        
        Dim node As TreeNode = Nothing, _ParentPath As String = String.Empty
        Dim _CategoryPath As String = String.Empty
        For Each _row As DataRow In dt.Rows
            'Get parent node path of current node
            _CategoryPath = _row.Item("CATEGORY_PATH").ToString
            If _CategoryPath.LastIndexOf("/") > -1 Then
                _ParentPath = _CategoryPath.Substring(0, _CategoryPath.LastIndexOf("/"))
            Else
                _ParentPath = _CategoryPath
            End If
            
            'Find out parent node
            node = Me.TV1.FindNode(Server.HtmlEncode(_ParentPath))
            
            If node Is Nothing Then
                'Add as root node if the parent node cannot be found
                Me.TV1.Nodes.Add(New TreeNode(_row.Item("CATEGORY_ID"), _row.Item("UID")))
            Else
                'Add as child node if the parent node can be found
                node.ChildNodes.Add(New TreeNode(_row.Item("CATEGORY_ID"), _row.Item("UID")))
            End If
        Next
        Me.TV1.CollapseAll()
        xwatch.Stop()
        Dim t2 As Long = xwatch.ElapsedMilliseconds
        
        
        Me.TextBox1.Text = IIf(t0 > 0, t0 / 1000, t0)
        Me.TextBox2.Text = IIf(t1 > 0, t1 / 1000, t1)
        Me.TextBox3.Text = IIf(t2 > 0, t2 / 1000, t2)
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        t1:<asp:TextBox ID="TextBox1" runat="server" />秒(開始)
        <br />
        t2:<asp:TextBox ID="TextBox2" runat="server" />秒(抓資料)
        <br />
        t3:<asp:TextBox ID="TextBox3" runat="server" />秒(資料轉成Treeview)

        <asp:GridView ID="GridView1" runat="server"></asp:GridView>

        <asp:TreeView ID="TV1" runat="server" co />


    </div>
    </form>
</body>
</html>
