<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Button1_Click(sender As Object, e As EventArgs)
        Dim _sql As New StringBuilder
        _sql.AppendLine(" DECLARE @ID  hierarchyid ")
        _sql.AppendLine(" SELECT @ID  = HIE_ID ")
        _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = 'CN_BTOS'  ")
        _sql.AppendLine(" SELECT ID, CATEGORY_ID as BTOParentItem, CATEGORY_TYPE, SEQ_NO,ORG ")
        _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
        _sql.AppendLine(" AND HIE_ID.GetLevel()= 2  ")
        _sql.AppendLine(" ORDER BY SEQ_NO ")
        
        
        '_sql.Clear()
        '_sql.AppendLine("select * from CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
        
        Me.gv1.DataSource = dt
        Me.gv1.DataBind()
        
    End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs)

    End Sub
    
    Class CBomObj
        Public ID As String = String.Empty
        Public Category_ID As String = String.Empty
        Public Sub New(ByVal _id As String, ByVal _Category_id As String)
            Me.ID = _id
            Me.Category_ID = _Category_id
        End Sub
        
        
            
    End Class
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            
            Dim _ID As String = DBITEM.Item("ID").ToString
            Dim _partno As String = DBITEM.Item("BTOParentItem").ToString
            'Dim _BTOParentPrefix As String = _partno.Replace("-BTO", "")
            Dim _BTOParentPrefix As String = _partno.Substring(0, 6)
            Dim _CBOMobjlist As New List(Of CBomObj)
            
            Dim _sql As New StringBuilder
            
            '主料號，機箱
            _sql.Clear()
            _sql.AppendLine(" DECLARE @ID hierarchyid ")
            _sql.AppendLine(" SELECT @ID = HIE_ID ")
            _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & _ID & "'  ")
            _sql.AppendLine(" SELECT CBOM2.*  ")
            _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 CBOM2 ")
            _sql.AppendLine(" WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
            _sql.AppendLine(" and (CATEGORY_ID like '" & _BTOParentPrefix & "%' ")
            _sql.AppendLine(" ) ")
            _sql.AppendLine(" and HIE_ID.GetLevel()  > 2 ")
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
            Dim _chassisarr() As String = Nothing
            Dim _chassispref As String = String.Empty
            Dim _CBOMMainPart As New List(Of String)
            For Each _row As DataRow In dt.Rows
                _chassisarr = _row.Item("Category_ID").ToString.Trim.Split("-")
                _chassispref = _chassisarr(0) & "-" & _chassisarr(1)
                If Not _CBOMMainPart.Contains(_chassispref) Then
                    If _CBOMMainPart.Count > 0 Then
                        e.Row.Cells(2).Text &= ", "
                    End If
                    e.Row.Cells(2).Text &= _chassispref
                    _CBOMMainPart.Add(_chassispref)
                End If
                'e.Row.Cells(2).Text &= _row.Item("Category_ID").ToString.Trim & ","
                '_CBOMobjlist.Add(New CBomObj(_row.Item("ID"), _row.Item("Category_ID")))
            Next

            
            '版卡
            _sql.Clear()
            _sql.AppendLine(" DECLARE @ID hierarchyid ")
            _sql.AppendLine(" SELECT @ID = HIE_ID ")
            _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & _ID & "'  ")
            _sql.AppendLine(" SELECT CBOM2.*  ")
            _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 CBOM2 ")
            _sql.AppendLine(" WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
            _sql.AppendLine(" and (CATEGORY_ID like 'PCA-%' ")
            _sql.AppendLine(" or CATEGORY_ID like 'PCE-%' ")
            _sql.AppendLine(" or CATEGORY_ID like 'AIMB-%' ")
            _sql.AppendLine(" or CATEGORY_ID like 'ASMB-%' ")
            _sql.AppendLine(" or CATEGORY_ID like 'MIC-%' ")
            _sql.AppendLine(" or CATEGORY_ID like 'PCI-%' ")
            _sql.AppendLine(" ) ")
            _sql.AppendLine(" and HIE_ID.GetLevel()  > 2 ")
            dt = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
            _chassisarr = Nothing
            _chassispref = String.Empty
            _CBOMMainPart = New List(Of String)
            e.Row.Cells(2).Text &= "<br/><br/>"
            For Each _row As DataRow In dt.Rows
                _chassisarr = _row.Item("Category_ID").ToString.Trim.Split("-")
                _chassispref = _chassisarr(0) & "-" & _chassisarr(1)
                If Not _CBOMMainPart.Contains(_chassispref) Then
                    If _CBOMMainPart.Count > 0 Then
                        e.Row.Cells(2).Text &= ", "
                    End If
                    e.Row.Cells(2).Text &= _chassispref
                    _CBOMMainPart.Add(_chassispref)
                End If
                'e.Row.Cells(2).Text &= _row.Item("Category_ID").ToString.Trim & ","
                '_CBOMobjlist.Add(New CBomObj(_row.Item("ID"), _row.Item("Category_ID")))
            Next
            
            e.Row.Cells(4).Text = "<img src=""../../images/ebiz.aeu.face/btn_config.gif"" style=""cursor:pointer"" onclick=""Call_Configurator('" & DBITEM.Item("ID") & "')""/>"
            
            ' _sql.Clear()
            '_sql.AppendLine(" DECLARE @ID hierarchyid ")
            '_sql.AppendLine(" SELECT @ID = HIE_ID ")
            '_sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & _ID & "'  ")
            '_sql.AppendLine(" SELECT CBOM2.SHARED_CATEGORY_ID  ")
            '_sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 CBOM2 ")
            '_sql.AppendLine(" WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
            '_sql.AppendLine(" and SHARED_CATEGORY_ID<>'' ")

            'dt = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
            
            'For Each _row As DataRow In dt.Rows
            '    _sql.Clear()
            '    _sql.AppendLine(" DECLARE @ID hierarchyid ")
            '    _sql.AppendLine(" SELECT @ID = HIE_ID ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID ='" & _row.Item("SHARED_CATEGORY_ID").ToString & "'")
            '    _sql.AppendLine(" SELECT HIE_ID.GetLevel() as level,* ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 ")
            '    _sql.AppendLine(" WHERE (CATEGORY_ID like '" & _BTOParentPrefix & "%' ")
            '    _sql.AppendLine(" ) ")
            '    _sql.AppendLine(" and HIE_ID.IsDescendantOf(@ID) = 1 ")
                
            '    Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
                
            '    If dt2 IsNot Nothing AndAlso dt2.Rows.Count > 0 Then
                    
            '        For Each _row2 As DataRow In dt2.Rows
            '            e.Row.Cells(2).Text &= "<a href='' >" & _row2.Item("Category_ID").ToString & "</a><br/>"
            '            _CBOMobjlist.Add(New CBomObj(_row2.Item("ID"), _row2.Item("Category_ID")))
            '        Next
            '    End If
                
            'Next
            
            
            
            
            'For Each _obj As CBomObj In _CBOMobjlist
                
                
            '    _sql.Clear()
            '    _sql.AppendLine(" DECLARE @ID hierarchyid ")
            '    _sql.AppendLine(" SELECT @ID = HIE_ID ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & _obj.ID & "'  ")
            '    _sql.AppendLine(" SELECT CBOM2.*  ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 CBOM2 ")
            '    _sql.AppendLine(" WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
            '    _sql.AppendLine(" and ( ")
            '    _sql.AppendLine(" CATEGORY_ID like 'PCA-%' ")
            '    _sql.AppendLine(" or CATEGORY_ID like 'PCE-%' ")
            '    _sql.AppendLine(" or CATEGORY_ID like 'AIMB-%' ")
            '    _sql.AppendLine(" or CATEGORY_ID like 'ASMB-%' ")
            '    _sql.AppendLine(" or CATEGORY_ID like 'MIC-%' ")
            '    _sql.AppendLine(" or CATEGORY_ID like 'PCI-%' ")
            '    _sql.AppendLine(" ) ")
            '    '_sql.AppendLine(" and HIE_ID.GetLevel()  > 2 ")
            '    dt = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
            '    For Each _row As DataRow In dt.Rows
            '        e.Row.Cells(2).Text &= "長板" & _row.Item("Category_ID").ToString & "<br/>"
            '        '_CBOMobjlist.Add(New CBomObj(_row.Item("ID"), _row.Item("Category_ID")))
            '    Next
            
            
            '    _sql.Clear()
            '    _sql.AppendLine(" DECLARE @ID hierarchyid ")
            '    _sql.AppendLine(" SELECT @ID = HIE_ID ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & _obj.ID & "'  ")
            '    _sql.AppendLine(" SELECT CBOM2.SHARED_CATEGORY_ID  ")
            '    _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 CBOM2 ")
            '    _sql.AppendLine(" WHERE HIE_ID.IsDescendantOf(@ID) = 1 ")
            '    _sql.AppendLine(" and SHARED_CATEGORY_ID<>'' ")

            '    dt = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
            
            '    For Each _row As DataRow In dt.Rows
            '        _sql.Clear()
            '        _sql.AppendLine(" DECLARE @ID hierarchyid ")
            '        _sql.AppendLine(" SELECT @ID = HIE_ID ")
            '        _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 WHERE ID ='" & _row.Item("SHARED_CATEGORY_ID").ToString & "'")
            '        _sql.AppendLine(" SELECT HIE_ID.GetLevel() as level,* ")
            '        _sql.AppendLine(" FROM CBOMV2.dbo.CBOM_CATALOG_CATEGORY_V2 ")
            '        _sql.AppendLine(" WHERE ( ")
            '        _sql.AppendLine(" CATEGORY_ID like 'PCA-%' ")
            '        _sql.AppendLine(" or CATEGORY_ID like 'PCE-%' ")
            '        _sql.AppendLine(" or CATEGORY_ID like 'AIMB-%' ")
            '        _sql.AppendLine(" or CATEGORY_ID like 'ASMB-%' ")
            '        _sql.AppendLine(" or CATEGORY_ID like 'MIC-%' ")
            '        _sql.AppendLine(" or CATEGORY_ID like 'PCI-%' ")
            '        _sql.AppendLine(" ) ")
            '        _sql.AppendLine(" and HIE_ID.IsDescendantOf(@ID) = 1 ")
                
            '        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _sql.ToString)
                
            '        If dt2 IsNot Nothing AndAlso dt2.Rows.Count > 0 Then
                    
            '            For Each _row2 As DataRow In dt2.Rows
            '                e.Row.Cells(2).Text &= "長板" & _row2.Item("Category_ID").ToString & "<br/>"
            '                '_CBOMobjlist.Add(New CBomObj(_row2.Item("ID"), _row2.Item("Category_ID")))
            '            Next
            '        End If
                
            '    Next
                
                
            'Next
            
            Dim a = 1 + 1
            
            'Dim _partno As String = CType(e.Row.Cells(0).Controls(0), HyperLink).Text
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">

機箱型號：<asp:TextBox ID="TextBox1" runat="server"></asp:TextBox><br/>
版卡型號：<asp:TextBox ID="TextBox2" runat="server"></asp:TextBox>
    <asp:Button ID="Button1" runat="server" Text="查詢" OnClick="Button1_Click" />

    <asp:GridView ID="gv1" runat="server" AutoGenerateColumns="false" Width="100%"
        EmptyDataText="No search results were found." EmptyDataRowStyle-Font-Size="Larger"
        EmptyDataRowStyle-Font-Bold="true" AllowPaging="false" OnRowDataBound="gv1_RowDataBound">

        <Columns>
            <asp:BoundField HeaderText="ID" DataField="ID" ItemStyle-Width="200px" Visible="false" />
            <asp:BoundField HeaderText="BTO" DataField="BTOParentItem" ItemStyle-Width="100px" />
<%--                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                    </asp:TemplateField>
                    <asp:HyperLinkField HeaderText="BTO" Target="_blank" DataNavigateUrlFields="model_no"
                        DataNavigateUrlFormatString="~/product/model_detail.aspx?model_no={0}" DataTextField="part_no"
                        SortExpression="part_no" />
                    <asp:HyperLinkField HeaderText="Model No." Target="_blank" DataTextField="model_no"
                        DataNavigateUrlFields="model_no" DataNavigateUrlFormatString="~/product/model_detail.aspx?model_no={0}" />
                    <asp:BoundField HeaderText="Product Description" DataField="product_desc" ItemStyle-Width="200px" />
--%>
            <asp:TemplateField ItemStyle-HorizontalAlign="left" HeaderStyle-Width="500px">
                <HeaderTemplate>
                    Key Features
                </HeaderTemplate>
                <ItemTemplate>
                    
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="5px">
                <HeaderTemplate>
                    Qty
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="TxtQTY" runat="server" Text="1" Font-Size="" Width="40" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px">
                <HeaderTemplate>
                    Configure
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:Button ID="BTConfig" runat="server" Text="Configure"  />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>

    </asp:GridView>

 <script type="text/javascript">
    

     function setQty(obj) {
         // alert (obj.value)
         //Session("QTY") = obj.value
         obj.previousSibling.value = obj.value
     }	
	
     function Call_Configurator(CATALOG_NAME) {
         //var intQty = document.getElementById('qty-' + CATALOG_NAME ).value ; 
         var intQty = 1;
         var quote=0
         if ('<%=Request("UID") %>'!='') {quote=1;}
        document.location.href = 'Configurator.aspx?BTOITEM=' + CATALOG_NAME + '&QTY=' + intQty;
     }
     </script>

</asp:Content>
