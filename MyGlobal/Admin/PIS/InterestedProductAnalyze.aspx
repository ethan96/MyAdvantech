<%@ Page Title="MyAdvantech - Interested Product Analyzer" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            

            
            Me.gv1.DataSource = CreateMainDatatable()
            Me.GV1.DataBind()
            
        End If
    End Sub
    
    Private Function CreateMainDatatable() As DataTable
        
        
        Dim _sql As New StringBuilder, _FoundRow() As DataRow = Nothing, _NewRow As DataRow = Nothing
        Dim _dt As New DataTable, _Confor As Boolean = False
        _sql.AppendLine(" SELECT a.PARENT_CATEGORY_ID,a.PARENT_CATEGORY_DISPLAY_NAME ")
        _sql.AppendLine(" ,a.CATEGORY_ID,a.CATEGORY_DISPLAY_NAME,a.SEQ_NO,b.LAST_UPDATED,b.LAST_UPDATED_BY ")
        _sql.AppendLine(" FROM V_INTERESTED_PRODUCT a inner join Category b on a.CATEGORY_ID=b.CATEGORY_ID ")
        _sql.AppendLine(" Order by a.PARENT_CATEGORY_DISPLAY_NAME,a.SEQ_NO ")
            
        Dim _PISIPdt As DataTable = dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        _PISIPdt.Columns.Add("CorpSite")
        _PISIPdt.Columns.Add("Siebel")

            
        Dim memws As New MemberShip.MembershipWebservice
        Dim _session As String = "PIS", _iparr() As String = Nothing
        Dim _ComIPdt As DataSet = memws.getProductInterestList(_session)
        Dim _arrlist As New ArrayList
        If _ComIPdt IsNot Nothing AndAlso _ComIPdt.Tables(0) IsNot Nothing Then
            For Each _row As DataRow In _ComIPdt.Tables(0).Rows
                _iparr = _row.Item("IN_PRODUCT").ToString.Split(",")
                For Each _in As String In _iparr
                    If String.IsNullOrEmpty(_in) Then Continue For
                    If String.IsNullOrEmpty(_in.Trim) Then Continue For

                    _in = _in.Trim
                        
                    If _arrlist.IndexOf(_in) > -1 Then Continue For
                        
                    _arrlist.Add(_in)

                    _FoundRow = _PISIPdt.Select("CATEGORY_DISPLAY_NAME='" & _in & "'")

                    If _FoundRow.Length > 0 Then
                        _FoundRow(0).Item("CorpSite") = "OK"
                        Continue For
                    End If
                            
                    _dt = GetCategoryUpdatedNameLog(_in)
                    If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then

                        _FoundRow = _PISIPdt.Select("CATEGORY_ID='" & _dt.Rows(0).Item("Category_ID").ToString & "'")
                        If _FoundRow.Length > 0 AndAlso _dt.Rows(0).Item("functionname").ToString <> "Delete Interested Product" Then
                            _FoundRow(0).Item("CorpSite") = "<strong>[Renamed in PIS]</strong><br>Old Name=" & _in
                            Continue For
                        End If
                               
                    End If
                        

                    _NewRow = _PISIPdt.NewRow()
                    _NewRow.Item("CATEGORY_DISPLAY_NAME") = _in

                    'If PIS category was inactived
                    _dt = GetInactiveCategoryIDFromLog(_in)
                    If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                        _NewRow.Item("CorpSite") = "<strong>[Inactived in PIS]</strong><br> " & _in
                        _PISIPdt.Rows.Add(_NewRow)
                        Continue For
                    End If
                        
                    'If PIS category was deleted
                    _dt = GetCategoryDeleteLog(_in)
                    If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                        _NewRow.Item("CorpSite") = "<strong>[Removed in PIS]</strong><br> " & _dt.Rows(0).Item("NewData").ToString
                        _PISIPdt.Rows.Add(_NewRow)
                        Continue For
                    End If
                        
                    'If log still can not be found
                    _NewRow.Item("CorpSite") = "<strong>[Can not be found in PIS]</strong><br> " & _in
                    _PISIPdt.Rows.Add(_NewRow)
                Next
            Next
        End If
            
        _sql.Clear()
        _sql.AppendLine(" SELECT [VALUE],[TEXT] ")
        _sql.AppendLine(" FROM SIEBEL_CONTACT_InterestedProduct_LOV ")
        _sql.AppendLine(" Order by [TEXT] ")
        Dim _SiebelIPdt As DataTable = dbUtil.dbGetDataTable("MY", _sql.ToString)
            
            
        For Each _row As DataRow In _SiebelIPdt.Rows
            _FoundRow = _PISIPdt.Select("CATEGORY_DISPLAY_NAME='" & _row.Item("TEXT").ToString & "'")
                
            If _FoundRow.Length > 0 AndAlso _FoundRow(0).Item("CATEGORY_ID") IsNot DBNull.Value Then
                _FoundRow(0).Item("Siebel") = "OK"
                Continue For
            End If
                            
            _dt = GetCategoryUpdatedNameLog(_row.Item("TEXT").ToString)
            If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                _FoundRow = _PISIPdt.Select("CATEGORY_ID='" & _dt.Rows(0).Item("Category_ID").ToString & "'")
                If _FoundRow.Length > 0 Then
                    _FoundRow(0).Item("CorpSite") = "<strong>[Renamed in PIS]</strong><br> Old Name=" & _row.Item("TEXT").ToString
                    Continue For
                End If
            End If
            If _Confor Then Continue For


            If _FoundRow.Length > 0 AndAlso _FoundRow(0).Item("CATEGORY_ID") Is DBNull.Value Then
                _FoundRow(0).Item("Siebel") = _FoundRow(0).Item("CorpSite")
                Continue For
            Else

                _NewRow = _PISIPdt.NewRow()
                _NewRow.Item("CATEGORY_DISPLAY_NAME") = _row.Item("TEXT").ToString

                'If PIS category was inactived
                _dt = GetInactiveCategoryIDFromLog(_row.Item("TEXT").ToString)
                If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                    _NewRow.Item("Siebel") = "<strong>[Inactived in PIS]</strong><br> " & _row.Item("TEXT").ToString
                    _PISIPdt.Rows.Add(_NewRow)
                    Continue For
                End If
                        
                'If PIS category was deleted
                _dt = GetCategoryDeleteLog(_row.Item("TEXT").ToString)
                If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                    _NewRow.Item("CorpSite") = "<strong>[Removed in PIS]</strong><br> " & _dt.Rows(0).Item("NewData").ToString
                    _PISIPdt.Rows.Add(_NewRow)
                    Continue For
                End If
                    
            End If

            'If log still can not be found
            _NewRow.Item("Siebel") = "<strong>[Can not be found in PIS]</strong><br> " & _row.Item("TEXT").ToString
            _PISIPdt.Rows.Add(_NewRow)
                
        Next
            
            
            
            
            
            
            
        For i As Integer = _PISIPdt.Rows.Count - 1 To 0 Step -1
            If _PISIPdt.Rows(i).Item("CATEGORY_ID") Is DBNull.Value Then
                _PISIPdt.Rows(i).Item("CATEGORY_DISPLAY_NAME") = DBNull.Value
                Continue For
            End If

            If _PISIPdt.Rows(i).Item("CorpSite") IsNot DBNull.Value AndAlso _PISIPdt.Rows(i).Item("CorpSite") = "OK" Then
                _PISIPdt.Rows(i).Item("CorpSite") = DBNull.Value
            ElseIf _PISIPdt.Rows(i).Item("CorpSite") Is DBNull.Value Then
                _PISIPdt.Rows(i).Item("CorpSite") = "<strong>[Does not exist]</strong>"
                _dt = GetCategoryAddLog(_PISIPdt.Rows(i).Item("CATEGORY_DISPLAY_NAME").ToString)
                If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                    _PISIPdt.Rows(i).Item("CorpSite") &= "<br>" & _dt.Rows(0).Item("NewData").ToString
                End If
            End If
                
            If _PISIPdt.Rows(i).Item("Siebel") IsNot DBNull.Value AndAlso _PISIPdt.Rows(i).Item("Siebel") = "OK" Then
                _PISIPdt.Rows(i).Item("Siebel") = DBNull.Value
            ElseIf _PISIPdt.Rows(i).Item("Siebel") Is DBNull.Value Then
                _PISIPdt.Rows(i).Item("Siebel") = "<strong>[Does not exist]</strong>"
                _dt = GetCategoryAddLog(_PISIPdt.Rows(i).Item("CATEGORY_DISPLAY_NAME").ToString)
                If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                    _PISIPdt.Rows(i).Item("Siebel") &= "<br>" & _dt.Rows(0).Item("NewData").ToString
                End If
            End If

            
            _dt = GetCategoryLastUpdatedLog(_PISIPdt.Rows(i).Item("CATEGORY_ID").ToString)
            If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                _PISIPdt.Rows(i).Item("LAST_UPDATED") = _dt.Rows(0).Item("inserttime").ToString
                _PISIPdt.Rows(i).Item("LAST_UPDATED_BY") = _dt.Rows(0).Item("userid").ToString & "<br>" & _dt.Rows(0).Item("NewData").ToString
            End If
            
        Next
        
        Return _PISIPdt
        
    End Function
    
    
    Private Function GetCategoryUpdatedNameLog(ByVal Category_display_name As String) As DataTable
        
        Dim _sql As New StringBuilder
           
        _sql.AppendLine(" SELECT functionname,model_partno as Category_ID,inserttime,NewData ")
        _sql.AppendLine(" FROM PISlog ")
        _sql.AppendLine(" Where OldData='" & Category_display_name & "' ")
        _sql.AppendLine(" And [action]='(Update)Update Category-Interested Product' ")
        _sql.AppendLine(" And [lang_id]='ENU' ")
        _sql.AppendLine(" And functionname like 'Update Interested Product Display Name%' ")
        _sql.AppendLine(" Order by inserttime desc ")
        
        Return dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        
    End Function

    Private Function GetCategoryDeleteLog(ByVal Category_display_name As String) As DataTable
        
        Dim _sql As New StringBuilder
           
        _sql.AppendLine(" SELECT functionname,model_partno as Category_ID,inserttime,NewData ")
        _sql.AppendLine(" FROM PISlog ")
        _sql.AppendLine(" Where OldData='" & Category_display_name & "' ")
        _sql.AppendLine(" And [action]='(Delete)Delete Category-Interested Product' ")
        _sql.AppendLine(" And [lang_id]='ENU' ")
        _sql.AppendLine(" And functionname like 'Delete Interested Product%' ")
        _sql.AppendLine(" Order by inserttime desc ")
        
        Return dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        
    End Function
    
    Private Function GetCategoryAddLog(ByVal Category_display_name As String) As DataTable
        
        Dim _sql As New StringBuilder
           
        _sql.AppendLine(" SELECT functionname,model_partno as Category_ID,inserttime,NewData ")
        _sql.AppendLine(" FROM PISlog ")
        _sql.AppendLine(" Where OldData='" & Category_display_name & "' ")
        _sql.AppendLine(" And [action]='(Insert)Add Category-Interested Product' ")
        _sql.AppendLine(" And [lang_id]='ENU' ")
        _sql.AppendLine(" And functionname like 'Add New Interested Product%' ")
        _sql.AppendLine(" Order by inserttime desc ")
        
        Return dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        
    End Function


    Private Function GetCategoryLastUpdatedLog(ByVal Category_id As String) As DataTable
        
        Dim _sql As New StringBuilder
           
        _sql.AppendLine(" SELECT top 1 functionname,model_partno as Category_ID,inserttime,NewData,userid ")
        _sql.AppendLine(" FROM PISlog ")
        _sql.AppendLine(" Where model_partno='" & Category_id & "' ")
        _sql.AppendLine(" And [action] like '%Interested Product%' ")
        _sql.AppendLine(" And [lang_id]='ENU' ")
        _sql.AppendLine(" Order by inserttime desc ")
        
        Return dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        
    End Function

    
    Private Function GetInactiveCategoryIDFromLog(ByVal Category_display_name As String) As DataTable
        
        Dim _sql As New StringBuilder
           
        _sql.AppendLine(" SELECT Category_ID,Last_Updated,Last_Updated_by ")
        _sql.AppendLine(" FROM CATEGORY ")
        _sql.AppendLine(" Where display_name='" & Category_display_name & "' ")
        _sql.AppendLine(" And ACTIVE_FLG='N' ")
        
        Return dbUtil.dbGetDataTable("PIS_BackEnd", _sql.ToString)
        
    End Function

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'gv1.AllowPaging = False
        'gv1.DataSource = ViewState("SqlCommand")
        'gv1.DataBind()
        gv1.Export2Excel("InterestedProduct.xls")
        'Util.DataTable2ExcelDownload(CreateMainDatatable, "test.xls")
    End Sub

    

    Protected Sub gv1_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)

    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table>
        <tr>
            <td width="20px">
                <asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" />
            </td>
            <td>
                <asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px"
                    ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" />
            </td>
        </tr>
    </table>
<%--    <asp:GridView ID="GV1" runat="server" AutoGenerateColumns="False" AllowSorting="True">
--%>       
 <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="100%"  OnSorting="gv1_Sorting">
        <Columns>
            <%--            <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Check
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:CheckBox ID="CheckBox_SelecedPart" runat="server" />
                </ItemTemplate>
            </asp:TemplateField>
            --%>
            <asp:BoundField ItemStyle-Width="200px" HeaderText="SBU" DataField="PARENT_CATEGORY_DISPLAY_NAME"
                ItemStyle-HorizontalAlign="left" SortExpression="PARENT_CATEGORY_DISPLAY_NAME" />
            <asp:BoundField ItemStyle-Width="200px" HeaderText="Interested Product" DataField="CATEGORY_DISPLAY_NAME"
                ItemStyle-HorizontalAlign="left" SortExpression="CATEGORY_DISPLAY_NAME" />
            <asp:BoundField ItemStyle-Width="200px" HeaderText="Corp. Site" DataField="CorpSite"
                ItemStyle-HorizontalAlign="left" SortExpression="CorpSite" HtmlEncode="False" />
            <asp:BoundField ItemStyle-Width="200px" HeaderText="Siebel" DataField="Siebel" ItemStyle-HorizontalAlign="left"
                SortExpression="Siebel" HtmlEncode="False" />
            <asp:BoundField ItemStyle-Width="200px" HeaderText="PIS Last Updated Time" DataField="LAST_UPDATED" ItemStyle-HorizontalAlign="left"
                SortExpression="LAST_UPDATED" HtmlEncode="False" />
            <asp:BoundField ItemStyle-Width="200px" HeaderText="PIS Last Updated By" DataField="LAST_UPDATED_BY" ItemStyle-HorizontalAlign="left"
                SortExpression="LAST_UPDATED_BY" HtmlEncode="False" />
        </Columns>
</sgv:SmartGridView>
    <%--</asp:GridView>--%>
</asp:Content>
