<%@ Page Language="VB" %>

<%@ Import Namespace="System.Diagnostics" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim errmsg As String = String.Empty
        'Dim aaa As Boolean = Advantech.Myadvantech.Business.OrderBusinessLogic.IsAEUOrderItemBelowMOQ("FU751661", errmsg, "EU10")
        'Dim ccc = 1
        
        'Dim Collapse As Integer = 1 '0向上 1向下
        'Dim CategoryID As String = "1-2MLJWW"
        'Dim lang As String = "ENU"
        'Dim layer As Integer = 10
        
        Dim str As New StringBuilder
        
        'str.AppendLine(" WITH CATEGORY_CTE ")
        'str.AppendLine(" AS ")
        'str.AppendLine(" ( ")
        'str.AppendLine(" SELECT CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID, CATALOG_ID, CATEGORY_DESC ")
        'str.AppendLine(" ,DISPLAY_NAME, EXTENDED_DESC, SEQ_NO, ACTIVE_FLG, LAST_UPDATED, 1 AS LAYER ")
        'str.AppendLine(" FROM CATEGORY ")
        
        'If Collapse = 0 Then
        '    str.AppendLine(" WHERE CATEGORY.CATEGORY_ID = '" & CategoryID & "' ")
        'Else
        '    str.AppendLine(" WHERE CATEGORY.PARENT_CATEGORY_ID = '" & CategoryID & "' ")
        'End If
        
        'str.AppendLine(" AND ACTIVE_FLG = 'Y' ")
        'str.AppendLine(" UNION ALL ")
        'str.AppendLine(" SELECT C.CATEGORY_ID, C.CATEGORY_NAME, C.CATEGORY_TYPE, C.PARENT_CATEGORY_ID, C.CATALOG_ID, C.CATEGORY_DESC ")
        'str.AppendLine(" ,C.DISPLAY_NAME, C.EXTENDED_DESC, C.SEQ_NO, C.ACTIVE_FLG, C.LAST_UPDATED, CC.LAYER + 1 ")
        'str.AppendLine(" FROM CATEGORY AS C ")

        'If Collapse = 0 Then
        '    str.AppendLine(" INNER JOIN CATEGORY_CTE AS CC ON C.CATEGORY_ID = CC.PARENT_CATEGORY_ID ")
        '    str.AppendLine(" AND C.CATEGORY_ID <> C.PARENT_CATEGORY_ID ")
        'Else
        '    str.AppendLine(" INNER JOIN CATEGORY_CTE AS CC ON C.PARENT_CATEGORY_ID = CC.CATEGORY_ID ")
        'End If
        'str.AppendLine(" ) ")

        'str.AppendLine(" SELECT CCTE.CATEGORY_ID, CCTE.CATEGORY_NAME, CCTE.CATEGORY_TYPE, CCTE.PARENT_CATEGORY_ID, CCTE.CATALOG_ID ")
        'str.AppendLine(" , CCTE.CATEGORY_DESC, CCTE.SEQ_NO, CCTE.ACTIVE_FLG, CCTE.LAST_UPDATED, CCTE.LAYER, L.LITERATURE_ID ")

        'If lang = "ENU" Then
        '    str.AppendLine(" , CCTE.DISPLAY_NAME, CCTE.EXTENDED_DESC ")
        '    str.AppendLine(" FROM CATEGORY_CTE AS CCTE LEFT JOIN CATEGORY_LIT AS CL ON CCTE.CATEGORY_ID = CL.CATEGORY_ID ")
        '    str.AppendLine(" LEFT JOIN LITERATURE AS L ON CL.LITERATURE_ID = L.LITERATURE_ID ")
        'Else
        '    str.AppendLine(" , isnull(CLG.DISPLAY_NAME,CCTE.DISPLAY_NAME) as DISPLAY_NAME ")
        '    str.AppendLine(" , isnull(CLG.EXTENDED_DESC,CCTE.EXTENDED_DESC) as EXTENDED_DESC ")
            
        '    str.AppendLine(" FROM CATEGORY_CTE AS CCTE ")
        '    str.AppendLine(" LEFT JOIN CATEGORY_LIT AS CL ON CCTE.CATEGORY_ID = CL.CATEGORY_ID ")
        '    str.AppendLine(" LEFT JOIN LITERATURE AS L ON CL.LITERATURE_ID = L.LITERATURE_ID ")
        '    str.AppendLine(" LEFT JOIN CATEGORY_LANG AS CLG ON CCTE.CATEGORY_ID = CLG.CATEGORY_ID AND CLG.LANG_ID = '" + lang + "' ")
            
        'End If
        
        'str.AppendLine(" WHERE ")

        'If Collapse = 0 Then
        '    str.AppendLine(" CCTE.CATEGORY_ID <> 'root' ")
        '    str.AppendLine(" ORDER BY LAYER DESC ")
        'Else
        '    str.AppendLine(" ACTIVE_FLG = 'Y' ")
        '    If layer <> 0 Then
        '        str.AppendLine(" AND LAYER <= '" & layer & "' ")
        '    End If
        '    str.AppendLine(" ORDER BY LAYER, SEQ_NO ")
        'End If
        
       
        
        'Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", str.ToString)
        'Me.GridView1.DataSource = dt
        'Me.GridView1.DataBind()
        
        Dim xwatch As Stopwatch = New Stopwatch
        xwatch.Start()
        Dim t0 As Long = xwatch.ElapsedMilliseconds
        str.AppendLine(" WITH CATEGORY_CTE([UID],CATEGORY_ID,  CATEGORY_TYPE, PARENT_CATEGORY_ID,ORG , SEQ_NO, LVL, CATEGORY_PATH ) ")
        str.AppendLine(" AS( ")
        str.AppendLine(" SELECT [UID], CATEGORY_ID, CATEGORY_TYPE, PARENT_CATEGORY_ID,ORG, SEQ_NO, 0 AS LVL ")
        'str.AppendLine(" , CAST(isnull(SEQ_NO,'0') AS NVARCHAR(1000)) as CATEGORY_PATH ")
        str.AppendLine(" , CAST([UID] AS NVARCHAR(1000)) as CATEGORY_PATH ")
        str.AppendLine(" FROM CBOM_CATALOG_CATEGORY ")
        str.AppendLine(" WHERE CBOM_CATALOG_CATEGORY.PARENT_CATEGORY_ID = 'Root' ")
        str.AppendLine(" AND CATEGORY_ID ='ACP-1010-BTO' AND ORG='EU' ")
        str.AppendLine(" UNION ALL ")
        str.AppendLine(" SELECT C.[UID], C.CATEGORY_ID, C.CATEGORY_TYPE, C.PARENT_CATEGORY_ID,C.ORG, C.SEQ_NO, CC.LVL + 1 ")
        'str.AppendLine(" , CATEGORY_PATH=cast(CC.CATEGORY_PATH + '\' + cast(isnull(C.SEQ_NO,'0') as nvarchar(1000)) as nvarchar(1000) ) ")
        str.AppendLine(" , CATEGORY_PATH=cast(CC.CATEGORY_PATH + '/' + cast(C.[UID] as nvarchar(1000)) as nvarchar(1000) ) ")
        str.AppendLine(" FROM CBOM_CATALOG_CATEGORY AS C ")
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
        
        'Me.TV1.Nodes.Add(New TreeNode(dt.Rows(0).Item("CATEGORY_ID"), dt.Rows(0).Item("UID")))
        
        'Dim part_no As String = "SOM-6894C7-S7A1E"
        'Dim ORG_ID As String = "US01"
        'Dim COMPANY_ID As String = "UTXMOU001"
        'Dim currency As String = "USD"
        'Dim unitprice As Decimal, listprice As Decimal
        'Dim dtPriceRec As New DataTable
        'SAPtools.getSAPPriceByTable(part_no, ORG_ID, COMPANY_ID, currency, dtPriceRec)
        'If dtPriceRec.Rows.Count > 0 Then
        '    unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
        '    listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
        'End If
        'Me.TextBox1.Text = listprice
        'Me.TextBox2.Text = unitprice
        'Me.TextBox3.Text = Util.IsTesting
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
