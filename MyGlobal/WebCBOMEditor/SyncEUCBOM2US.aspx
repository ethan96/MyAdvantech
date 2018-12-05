<%@ Page Title="MyAdvantech - Sync EU CBOM To US" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub btnSync_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim catalogDt As DataTable = dbUtil.dbGetDataTable("MY", _
                              String.Format( _
                                  " select CATALOG_ID,CATALOG_NAME,CATALOG_TYPE,'US' AS CATALOG_ORG,CATALOG_DESC," + _
                                  " CREATED,CREATED_BY,LAST_UPDATED,LAST_UPDATED_BY,IMAGE_ID,convert(varchar(100),NEWID()) AS UID " + _
                                  " from CBOM_CATALOG where CATALOG_ORG='EU' and catalog_id='{0}'", txtBTO.Text.Trim()))
        Dim catSet As New ArrayList, gdt As New DataTable()
        GetCategory(txtBTO.Text.Trim(), gdt, "component", catSet, True)
        If catalogDt.Rows.Count = 1 And gdt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("b2b", "delete from CBOM_CATALOG where CATALOG_ORG='US' and catalog_id='" & txtBTO.Text.Trim() & "'")
        
            Dim bk1 As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            bk1.DestinationTableName = "CBOM_CATALOG"
            bk1.WriteToServer(catalogDt)
            bk1.DestinationTableName = "cbom_catalog_category"
            bk1.WriteToServer(gdt)
            lbMsg.Text = "Sync successfully"
            'gv1.DataSource = gdt : gv1.DataBind()
        Else
            lbMsg.Text = "CBOM not found"
        End If
    End Sub
    
    Sub GetCategory(ByVal catid As String, ByRef GDt As DataTable, ByVal type As String, ByRef CatSet As ArrayList, Optional ByVal Root As Boolean = False)
        If CatSet.Contains(catid) = False Then
            
            CatSet.Add(catid)
            
            Dim col As String = "PARENT_CATEGORY_ID"
            If Root Then col = "CATEGORY_ID"
            Dim categoryDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
          " select CATEGORY_ID,CATEGORY_NAME,CATEGORY_TYPE,PARENT_CATEGORY_ID,CATALOG_ID,CATEGORY_DESC," + _
          " DISPLAY_NAME,IMAGE_ID,EXTENDED_DESC,CREATED,CREATED_BY,LAST_UPDATED,LAST_UPDATED_BY,SEQ_NO, " + _
          " PUBLISH_STATUS,DEFAULT_FLAG,CONFIGURATION_RULE,NOT_EXPAND_CATEGORY,SHOW_HIDE,EZ_FLAG, " + _
          " convert(varchar(100),NEWID()) AS UID,'US' AS ORG from cbom_catalog_category where org='EU' and {0}='{1}'", col, Replace(catid, "'", "''")))
            GDt.Merge(categoryDt)
            For Each r As DataRow In categoryDt.Rows
                GetCategory(r.Item("category_id"), GDt, r.Item("CATEGORY_TYPE"), CatSet)
            Next
        Else
        End If
    End Sub
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim syncitems() As String = {"ACP-4000-BTO", "ACP-4010-BTO", "ACP-4010MB-BTO", "ACP-4320-BTO", "ACP-4360-BTO", _
            "ACP-4360B-BTO", "ACP-4360MBB-BTO", "ACP-5360BP-BTO", "ACP-7360BP-BTO", "IPC-100-BTO", "IPC-3026-BTO", "IPC-510-BTO", _
            "IPC-5120-BTO", "IPC-5122-BTO", "IPC-6006-BTO", "IPC-602-BTO", "IPC-6025-BTO", "IPC-603-BTO", "IPC-610F-BTO", _
            "IPC-610H-BTO", "IPC-610L-BTO", "IPC-611-BTO", "IPC-619-BTO", "IPC-619MB-BTO", "IPC-619S-BTO", "IPC-622-BTO", _
            "IPC-623-BTO", "IPC-630-BTO", "IPC-6606-BTO", "IPC-6608-BTO", "IPC-6806-BTO", "IPC-6806WH-BTO", "IPC-6908-BTO", _
            "IPC-7120-BTO", "IPC-7143-BTO", "IPC-7220-BTO", "MBPC-641-BTO"}
            For Each bto As String In syncitems
                txtBTO.Text = bto
                btnSync_Click(Nothing, Nothing)
            Next
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table width="100%">
                <tr>
                    <td>
                        <asp:TextBox runat="server" ID="txtBTO" Width="300px" />&nbsp;<asp:Button runat="server" ID="btnSync" Text="Sync" OnClick="btnSync_Click" />
                        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:GridView runat="server" ID="gv1" />
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>    
</asp:Content>