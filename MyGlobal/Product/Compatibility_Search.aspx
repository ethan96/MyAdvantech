<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Compatibility Search" %>
<%--<%@ Register TagPrefix="adl" Namespace="clsAdxInheritsTreeView.nms3view" Assembly="clsAdxInheritsTreeView"%>--%>

<script runat="server">

    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack And Request("key") <> "" Then
            txtSearch.Text = Request("key")
        End If
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetCbomPartNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "")
        Dim topCount As Integer = 20
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct top " + topCount.ToString() + " category_id FROM cbom_catalog_category where category_id like '{0}%' order by category_id ", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String, alist As New ArrayList
            For Each r As DataRow In dt.Rows
                If Not alist.Contains(r.Item(0)) Then
                    str(alist.Count) = r.Item(0)
                    alist.Add(r.Item(0))
                End If
            Next
            ReDim Preserve str(alist.Count - 1)
            Return str
        End If
        Return Nothing
    End Function
    
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tvChild.Nodes.Clear() : tvParent.Nodes.Clear()
        If ViewState("Dt") Is Nothing Then
            ViewState("Dt") = New DataTable
        Else
            CType(ViewState("Dt"), DataTable).Clear()
        End If
        
        Dim part_no As String = Trim(txtSearch.Text.Replace("'", ""))
        Dim p_node_c As New TreeNode
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select a.category_id, a.category_type, a.category_desc, b.rohs_status, '' as class, isnull((select top 1 c.category_id from siebel_catalog_category c where c.display_name=b.model_no),'') as model_id from cbom_catalog_category a left join siebel_product b on a.category_id = b.part_no where a.category_id='{0}'", part_no))
        
        If dt.Rows.Count > 0 Then
            lblChild.Visible = False : lblParent.Visible = False
            p_node_c.Text = part_no
            If dt.Rows(0).Item(1).ToString.ToLower() = "component" Then
                p_node_c.Text = "<a href='javascript:CheckPriceDue(""" & dt.Rows(0).Item(0).ToString & """,""1"")' title='Check Price'>" + dt.Rows(0).Item(0).ToString + IIf(dt.Rows(0).Item(2).ToString <> "", "【" + dt.Rows(0).Item(2).ToString + "】", "【】") + "</a>"
                If dt.Rows(0).Item(3).ToString.ToLower() = "y" Then p_node_c.Text += "&nbsp;&nbsp;<img alt='RoHs' src='../Images/rohs.jpg'  />"
                'If dt.Rows(0).Item(4).ToString.ToLower() = "a" Or dt.Rows(0).Item(4).ToString.ToLower() = "b" Then p_node_c.Text += "&nbsp;&nbsp;<img alt='class' src='../Images/Hot-Orange.gif'  />"
                If dt.Rows(0).Item(5).ToString <> "" Then p_node_c.Text += "&nbsp;&nbsp;<a href='http://my.advantech.com/Product/Model_Detail.aspx?model_id=" + dt.Rows(0).Item(5).ToString + "' target='_blank'>Detail</a>"
            End If
            AppendChildTree(part_no, dt.Rows(0).Item(1).ToString.ToLower(), p_node_c)
            tvChild.Nodes.Add(p_node_c)
            
            Dim dtParent As DataTable = GetParentItem(part_no)
            If dtParent.Rows.Count > 0 Then
                If dtParent.Rows.Count = 1 And dtParent.Rows(0).Item(0).ToString.ToLower = "root" Then
                    lblParent.Visible = True
                Else
                    lblParent.Visible = False
                    For Each row As DataRow In dtParent.Rows
                        If row.Item(0).ToString.ToLower <> "root" Then
                            Dim p_node As New TreeNode
                            Dim dt1 As New DataTable
                            If row.Item(1).ToString.ToLower() = "component" Then
                                dt1 = dbUtil.dbGetDataTable("B2B", String.Format("select category_id, category_type from cbom_catalog_category where category_id='{0}'", row.Item(0).ToString))
                                If dt1.Rows.Count > 0 Then
                                    p_node.Text = "<a href='javascript:CheckPriceDueCategory(""" & dt1.Rows(0).Item(0).ToString & """,""1"")'>" + dt1.Rows(0).Item(0).ToString + "</a>"
                                Else
                                    p_node.Text = "<a href='javascript:CheckPriceDueCategory(""" & row.Item(0).ToString & """,""1"")'>" + row.Item(0).ToString + "</a>"
                                End If
                            End If
                            If row.Item(1).ToString.ToLower() = "category" Then
                                dt1 = dbUtil.dbGetDataTable("my", String.Format("select a.category_id, a.category_type, a.category_desc, b.rohs_status, '' as class, isnull((select top 1 c.category_id from siebel_catalog_category c where c.display_name=b.model_no),'') as model_id from cbom_catalog_category a left join siebel_product b on a.category_id = b.part_no where a.category_id='{0}'", row.Item(0).ToString))
                                If dt1.Rows.Count > 0 Then
                                    p_node.Text = "<a href='javascript:CheckPriceDue(""" & dt1.Rows(0).Item(0).ToString & """,""1"")' title='Check Price'>" + dt1.Rows(0).Item(0).ToString + IIf(dt1.Rows(0).Item(2).ToString <> "", "【" + dt1.Rows(0).Item(2).ToString + "】", "【】") + "</a>"
                                    If dt1.Rows(0).Item(3).ToString.ToLower() = "y" Then p_node.Text += "&nbsp;&nbsp;<img alt='RoHs' src='../Images/rohs.jpg'  />"
                                    'If dt1.Rows(0).Item(4).ToString.ToLower() = "a" Or dt1.Rows(0).Item(4).ToString.ToLower() = "b" Then p_node.Text += "&nbsp;&nbsp;<img alt='class' src='../Images/Hot-Orange.gif'  />"
                                    If dt1.Rows(0).Item(5).ToString <> "" Then p_node.Text += "&nbsp;&nbsp;<a href='http://my.advantech.com/Product/Model_Detail.aspx?model_id=" + dt1.Rows(0).Item(5).ToString + "' target='_blank'>Detail</a>"
                                Else
                                    p_node.Text = "<a href='javascript:CheckPriceDue(""" & row.Item(0).ToString & """,""1"")' title='Check Price'>" + row.Item(0).ToString + "</a>"
                                End If
                            End If
                            If dt1.Rows.Count > 0 Then
                                AppendChildTree(dt1.Rows(0).Item(0).ToString, dt1.Rows(0).Item(1).ToString.ToLower(), p_node)
                            End If
                            tvParent.Nodes.Add(p_node)
                        End If
                    Next
                End If
            Else
                lblParent.Visible = True
            End If
        Else
            lblChild.Visible = True : lblParent.Visible = True
        End If
        
    End Sub

    Private Sub AppendChildTree(ByVal category_id As String, ByVal type As String, ByRef p_node As TreeNode, Optional ByVal check As Boolean = False)
        Dim temp_node As TreeNode = p_node
        Dim node_array As New ArrayList
        If check = True Then
            node_array.Add(temp_node.Text.Split("【")(0).Split(">")(1))
            While Not IsNothing(temp_node.Parent)
                temp_node = temp_node.Parent
                node_array.Add(temp_node.Text.Split("【")(0).Split(">")(1))
            End While
        End If
        
        Select Case type
            Case "category"
                Dim dtChild As DataTable = GetChildItem(category_id, type)
                If dtChild.Rows.Count > 0 Then
                    For Each row As DataRow In dtChild.Rows
                        Dim c_node As New TreeNode
                        c_node.Text = "<a href='javascript:CheckPriceDue(""" & row.Item(0).ToString & """,""1"")' title='Check Price'>" + row.Item(0).ToString + IIf(row.Item(2).ToString <> "", "【" + row.Item(2).ToString + "】", "【】") + "</a>"
                        If row.Item(3).ToString.ToLower() = "y" Then c_node.Text += "&nbsp;&nbsp;<img alt='RoHs' src='../Images/rohs.jpg'  />"
                        'If row.Item(4).ToString.ToLower() = "a" Or row.Item(4).ToString.ToLower() = "b" Then c_node.Text += "&nbsp;&nbsp;<img alt='class' src='../Images/Hot-Orange.gif'  />"
                        If row.Item(5).ToString <> "" Then c_node.Text += "&nbsp;&nbsp;<a href='http://my.advantech.com/Product/Model_Detail.aspx?model_id=" + row.Item(5).ToString + "' target='_blank'>Detail</a>"
                        If CInt(row.Item(6).ToString) > 0 And Not node_array.Contains(row.Item(0).ToString) Then c_node.ShowCheckBox = True
                        p_node.ChildNodes.Add(c_node)
                    Next
                End If
                    
            Case "component"
                Dim dtChild As DataTable = GetChildItem(category_id, type)
                If dtChild.Rows.Count > 0 Then
                    For Each row As DataRow In dtChild.Rows
                        If row.Item(1).ToString.ToLower = "category" Then
                            Dim c_node As New TreeNode
                            c_node.Text = "<a href='javascript:CheckPriceDueCategory(""" & Server.HtmlEncode(row.Item(0).ToString.Replace("&", "$$$")) & """,""1"")'>" + row.Item(0).ToString + "</a>"
                            Dim dtCC As DataTable = GetChildItem(row.Item(0).ToString, row.Item(1).ToString.ToLower())
                            For Each r As DataRow In dtCC.Rows
                                Dim c_node_c As New TreeNode
                                c_node_c.Text = "<a href='javascript:CheckPriceDue(""" & r.Item(0).ToString & """,""1"")' title='Check Price'>" + r.Item(0).ToString + IIf(r.Item(2).ToString <> "", "【" + r.Item(2).ToString + "】", "【】") + "</a>"
                                If r.Item(3).ToString.ToLower() = "y" Then c_node_c.Text += "&nbsp;&nbsp;<img alt='RoHs' src='../Images/rohs.jpg'  />"
                                'If r.Item(4).ToString.ToLower() = "a" Or r.Item(4).ToString.ToLower() = "b" Then c_node_c.Text += "&nbsp;&nbsp;<img alt='class' src='../Images/Hot-Orange.gif' />"
                                If r.Item(5).ToString <> "" Then c_node_c.Text += "&nbsp;&nbsp;<a href='http://my.advantech.com/Product/Model_Detail.aspx?model_id=" + r.Item(5).ToString + "' target='_blank'>Detail</a>"
                                If CInt(r.Item(6).ToString) > 0 And Not node_array.Contains(r.Item(0).ToString) Then c_node_c.ShowCheckBox = True
                                c_node.ChildNodes.Add(c_node_c)
                            Next
                            p_node.ChildNodes.Add(c_node)
                        Else
                            Dim dtCC As DataTable = dbUtil.dbGetDataTable("my", String.Format("select a.category_id, a.category_type, a.category_desc, b.rohs_status, '' as class, isnull((select top 1 c.category_id from siebel_catalog_category c where c.display_name=b.model_no),'') as model_id, (select count(d.category_id) from cbom_catalog_category d where d.parent_category_id=a.category_id) from cbom_catalog_category a left join siebel_product b on a.category_id = b.part_no where a.category_id='{0}' and (b.status='A' or b.status='H' or b.status='N' or b.status='S5') order by a.seq_no,a.category_id", row.Item(0).ToString))
                            Dim c_node As New TreeNode
                            c_node.Text = "<a href='javascript:CheckPriceDue(""" & dtCC.Rows(0).Item(0).ToString & """,""1"")' title='Check Price'>" + dtCC.Rows(0).Item(0).ToString + IIf(dtCC.Rows(0).Item(2).ToString <> "", "【" + dtCC.Rows(0).Item(2).ToString + "】", "【】") + "</a>"
                            If dtCC.Rows(0).Item(3).ToString.ToLower() = "y" Then c_node.Text += "&nbsp;&nbsp;<img alt='RoHs' src='../Images/rohs.jpg'  />"
                            'If dtCC.Rows(0).Item(4).ToString.ToLower() = "a" Or dtCC.Rows(0).Item(4).ToString.ToLower() = "b" Then c_node.Text += "&nbsp;&nbsp;<img alt='class' src='../Images/Hot-Orange.gif' />"
                            If dtCC.Rows(0).Item(5).ToString <> "" Then c_node.Text += "&nbsp;&nbsp;<a href='http://my.advantech.com/Product/Model_Detail.aspx?model_id=" + dtCC.Rows(0).Item(5).ToString + "' target='_blank'>Detail</a>"
                            If CInt(dtCC.Rows(0).Item(6).ToString) > 0 And Not node_array.Contains(dtCC.Rows(0).Item(0).ToString) Then
                                c_node.ShowCheckBox = True
                            Else
                                c_node.Text = "&nbsp;&nbsp;&nbsp;&nbsp;" + c_node.Text
                            End If
                            p_node.ChildNodes.Add(c_node)
                        End If
                    Next
                End If
        End Select
    End Sub
    
    Private Function GetParentItem(ByVal part_no As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct isnull(parent_category_id,'') as parent_category_id, category_type from cbom_catalog_category where category_id='{0}' order by parent_category_id", part_no))
        Return dt
    End Function
    
    Private Function GetChildItem(ByVal part_no As String, ByVal type As String) As DataTable
        Dim dt As New DataTable
        Select Case type
            Case "component"
                dt = dbUtil.dbGetDataTable("my", String.Format("select a.category_id, a.category_type, a.category_desc from cbom_catalog_category a where a.parent_category_id='{0}' order by a.seq_no,a.category_id", part_no))
            Case "category"
                dt = dbUtil.dbGetDataTable("my", String.Format("select a.category_id, a.category_type, a.category_desc, b.rohs_status, '' as class, isnull((select top 1 c.category_id from siebel_catalog_category c where c.display_name=b.model_no),'') as model_id, (select count(d.category_id) from cbom_catalog_category d where d.parent_category_id=a.category_id) from cbom_catalog_category a left join siebel_product b on a.category_id = b.part_no where a.parent_category_id='{0}' and (b.status='A' or b.status='H' or b.status='N' or b.status='S5') order by a.seq_no,a.category_id", part_no))
        End Select
        Return dt
    End Function
    
    Protected Sub CheckNode(ByVal sender As Object, ByVal e As TreeNodeEventArgs)
        If e.Node.Checked = True Then
            Dim nc As Integer = e.Node.ChildNodes.Count
            For i As Integer = 1 To nc
                e.Node.ChildNodes.RemoveAt(0)
            Next
            Dim category_id As String = e.Node.Text.Split("【")(0).Split(">")(1)
            Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select category_id, category_type from cbom_catalog_category where category_id='{0}'", category_id))
            AppendChildTree(dt.Rows(0).Item(0).ToString, dt.Rows(0).Item(1).ToString.ToLower(), e.Node, True)
            e.Node.ExpandAll()
        Else
            e.Node.CollapseAll()
        End If
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript">
    function PostBackOnChecked(){
        
        var o = window.event.srcElement;
        if (o.tagName == "INPUT" && o.type == "checkbox"){
            //Hide mouse if possible
            document.body.style.cursor ="wait";     
            __doPostBack("","");    
        } 
    }
    function checkBox_Click(eventElement)
    {
        var c = eventElement.target;
        var cid = c.id;
        var treeviewID;
        if (cid.substring(0,15) == "ctl00__main_tvP")
        {
            treeviewID="ct100__main_tvParent";
        }
        if (cid.substring(0,15) == "ctl00__main_tvC")
        {
            treeviewID="ct100__main_tvChild";
        }
        document.getElementById('<%=hdn1.clientID %>').value=cid.substring((treeviewID + "n").length, cid.indexOf("CheckBox"))*20;
    }
    
    function document.body.onload()
    {
        window.scroll(0,document.getElementById('<%=hdn1.clientID %>').value);
        var width1 = screen.width;
        document.getElementById('<%=PanelParent.clientID %>').style.width=width1 / 2 - 30;
        document.getElementById('<%=PanelChild.clientID %>').style.width=width1 / 2 - 30;
        document.getElementById('<%=tvParent.clientID %>').style.width=width1 / 2 - 30;
        document.getElementById('<%=tvChild.clientID %>').style.width=width1 / 2 - 30;
    }
    
    
</script>
    <%--<asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>--%>
        <asp:HiddenField runat="server" ID="hdn1" />
        <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearch">
            <table width="100%">
                <tr>
                    <td width="100%">
                        <table>
                            <tr>
                                <td><b>Part No. : </b></td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtSearch" />
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acePartNo" TargetControlID="txtSearch" MinimumPrefixLength="2" ServiceMethod="GetCbomPartNo" CompletionInterval="1000" />
                                </td>
                                <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr><td height="10"></td></tr>
                <tr>
                    <td width="100%">
                        <table width="100%">
                            <tr>
                                <td valign="top" width="50%">
                                    <asp:Panel runat="server" ID="PanelParent" ScrollBars="Horizontal" Height="350">
                                        <b>Parent : </b>
                                        <asp:Label runat="server" ID="lblParent" Text="Not Found" ForeColor="Red" Visible="false" />
                                        <asp:TreeView runat="server" ID="tvParent" OnTreeNodeCheckChanged="CheckNode" />
                                    </asp:Panel>
                                </td>
                                <td valign="top" width="50%">
                                    <asp:Panel runat="server" ID="PanelChild" ScrollBars="Horizontal" Height="350">
                                        <b>Child : </b>
                                        <asp:Label runat="server" ID="lblChild" Text="Not Found" ForeColor="Red" Visible="false" />
                                        <asp:TreeView runat="server" ID="tvChild" OnTreeNodeCheckChanged="CheckNode" />
                                    </asp:Panel>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </asp:Panel>
            
        <%--</ContentTemplate>
    </asp:UpdatePanel>--%>
    
    <script type="text/javascript">
        var checkBoxes = document.getElementsByTagName("input");

        if (document.all) {    
            document.getElementById('ctl00__main_tvChild').onclick = PostBackOnChecked;  
            document.getElementById('ctl00__main_tvParent').onclick = PostBackOnChecked;    
        }
        for (var i = 0; i < checkBoxes.length; i++)
        {
            if (checkBoxes[i].type == "checkbox")
            {
                $addHandler(checkBoxes[i], "click", checkBox_Click);
            }
        }
        
        function ShowWaitCursor()
        {
             document.body.style.cursor ="wait";     
        }
        
        function CheckPriceDue(part_no,qty)
        {
            var Url="../order/PriceDue.aspx?part_no=" + part_no + "&qty=" + qty
            window.open(Url, "pop","height=300,width=520,scrollbars=yes");
        }
        
        function CheckPriceDueCategory(part_no,qty)
        {
            var Url="../order/PriceDueCategory.aspx?part_no=" + part_no + "&qty=" + qty
            window.open(Url, "pop","height=300,width=520,scrollbars=yes");
        }
    </script>
</asp:Content>

