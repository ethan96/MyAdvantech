<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    'delete from CBOM_CATALOG_CATEGORY where ORG='US'
 
    'INSERT INTO CBOM_CATALOG_CATEGORY 
    'select 
    'CATEGORY_ID,
    'CATEGORY_NAME,
    'CATEGORY_TYPE,
    'PARENT_CATEGORY_ID,
    'CATALOG_ID,
    'CATEGORY_DESC,
    'DISPLAY_NAME,
    'IMAGE_ID,
    'EXTENDED_DESC,
    'CREATED,
    'CREATED_BY,
    'LAST_UPDATED,
    'LAST_UPDATED_BY,
    'SEQ_NO,
    'PUBLISH_STATUS,
    'DEFAULT_FLAG,
    'CONFIGURATION_RULE,
    'NOT_EXPAND_CATEGORY,
    'SHOW_HIDE,
    'EZ_FLAG,
    'convert(varchar(100),NEWID()) AS UID,
    ''US' AS ORG from cbom_catalog_category where org='EU'  
    Public Sub SyncCatalog(ByVal pn As String, ByVal FORG As String, ByVal TORG As String)
        Dim str1 As String = "select " & _
                            "CATALOG_ID," & _
                            "CATALOG_NAME," & _
                            "CATALOG_TYPE," & _
                            "'" & TORG & "' AS CATALOG_ORG," & _
                            "CATALOG_DESC," & _
                            "CREATED," & _
                            "CREATED_BY," & _
                            "LAST_UPDATED," & _
                            "LAST_UPDATED_BY," & _
                            "IMAGE_ID," & _
                            "convert(varchar(100),NEWID()) AS UID" & _
                            " from CBOM_CATALOG where CATALOG_ORG='" & FORG & "' and catalog_id='" & pn & "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str1)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("b2b", "delete from CBOM_CATALOG where CATALOG_ORG='" & TORG & "' and catalog_id='" & pn & "'")
            dbUtil.dbExecuteNoQuery("b2b", "insert into CbomSyncTracking values('" & pn & "','catalog')")
            dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into CBOM_CATALOG values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}')", _
                                                       dt.Rows(0).Item("CATALOG_ID"), dt.Rows(0).Item("CATALOG_NAME"), dt.Rows(0).Item("CATALOG_TYPE"), _
                                                       dt.Rows(0).Item("CATALOG_ORG"), dt.Rows(0).Item("CATALOG_DESC"), dt.Rows(0).Item("CREATED"), _
                                                       dt.Rows(0).Item("CREATED_BY"), dt.Rows(0).Item("LAST_UPDATED"), dt.Rows(0).Item("LAST_UPDATED_BY"), _
                                                       dt.Rows(0).Item("IMAGE_ID"), dt.Rows(0).Item("UID")))
        End If
    End Sub
    Public Sub SyncBTOItem(ByVal pn As String, ByVal FORG As String, ByVal TORG As String)
        Dim str2 As String = "select " & _
                             "CATEGORY_ID," & _
                             "CATEGORY_NAME," & _
                             "CATEGORY_TYPE," & _
                             "PARENT_CATEGORY_ID," & _
                             "CATALOG_ID," & _
                             "CATEGORY_DESC," & _
                             "DISPLAY_NAME," & _
                             "IMAGE_ID," & _
                             "EXTENDED_DESC," & _
                             "CREATED," & _
                             "CREATED_BY," & _
                             "LAST_UPDATED," & _
                             "LAST_UPDATED_BY," & _
                             "SEQ_NO," & _
                             "PUBLISH_STATUS," & _
                             "DEFAULT_FLAG," & _
                             "CONFIGURATION_RULE," & _
                             "NOT_EXPAND_CATEGORY," & _
                             "SHOW_HIDE," & _
                             "EZ_FLAG," & _
                             "convert(varchar(100),NEWID()) AS UID," & _
                             "'" & TORG & "' AS ORG" & _
                             " from cbom_catalog_category where org='" & FORG & "' and category_id='" & pn & "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str2)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("b2b", "delete from cbom_catalog_category where org='" & TORG & "' and category_id='" & pn & "'")
            dbUtil.dbExecuteNoQuery("b2b", "insert into CbomSyncTracking values('" & pn & "','root')")
            dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into cbom_catalog_category values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}')", _
                                                        dt.Rows(0).Item("CATEGORY_ID"), dt.Rows(0).Item("CATEGORY_NAME"), dt.Rows(0).Item("CATEGORY_TYPE"), dt.Rows(0).Item("PARENT_CATEGORY_ID"), _
                                                        dt.Rows(0).Item("CATALOG_ID"), dt.Rows(0).Item("CATEGORY_DESC"), dt.Rows(0).Item("DISPLAY_NAME"), dt.Rows(0).Item("IMAGE_ID"), _
                                                        dt.Rows(0).Item("EXTENDED_DESC"), dt.Rows(0).Item("CREATED"), dt.Rows(0).Item("CREATED_BY"), dt.Rows(0).Item("LAST_UPDATED"), _
                                                        dt.Rows(0).Item("LAST_UPDATED_BY"), dt.Rows(0).Item("SEQ_NO"), dt.Rows(0).Item("PUBLISH_STATUS"), dt.Rows(0).Item("DEFAULT_FLAG"), _
                                                        dt.Rows(0).Item("CONFIGURATION_RULE"), dt.Rows(0).Item("NOT_EXPAND_CATEGORY"), dt.Rows(0).Item("SHOW_HIDE"), dt.Rows(0).Item("EZ_FLAG"), _
                                                        dt.Rows(0).Item("UID"), dt.Rows(0).Item("ORG")))
        End If
    End Sub
  
    
    Public Sub SyncCategory(ByVal PN As String, ByVal FORG As String, ByVal TORG As String)
        Dim str2 As String = "select " & _
                             "CATEGORY_ID," & _
                             "CATEGORY_NAME," & _
                             "CATEGORY_TYPE," & _
                             "PARENT_CATEGORY_ID," & _
                             "CATALOG_ID," & _
                             "CATEGORY_DESC," & _
                             "DISPLAY_NAME," & _
                             "IMAGE_ID," & _
                             "EXTENDED_DESC," & _
                             "CREATED," & _
                             "CREATED_BY," & _
                             "LAST_UPDATED," & _
                             "LAST_UPDATED_BY," & _
                             "SEQ_NO," & _
                             "PUBLISH_STATUS," & _
                             "DEFAULT_FLAG," & _
                             "CONFIGURATION_RULE," & _
                             "NOT_EXPAND_CATEGORY," & _
                             "SHOW_HIDE," & _
                             "EZ_FLAG," & _
                             "convert(varchar(100),NEWID()) AS UID," & _
                             "'" & TORG & "' AS ORG" & _
                             " from cbom_catalog_category where org='" & FORG & "' and PARENT_CATEGORY_ID='" & PN & "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str2)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("b2b", "delete from cbom_catalog_category where org='" & TORG & "' AND PARENT_CATEGORY_ID='" & PN & "'")
            For Each R As DataRow In dt.Rows
                dbUtil.dbExecuteNoQuery("b2b", "insert into CbomSyncTracking values('" & R.Item("CATEGORY_ID") & "','" & PN & "')")
                dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into cbom_catalog_category values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}')", _
                                                        R.Item("CATEGORY_ID"), R.Item("CATEGORY_NAME"), R.Item("CATEGORY_TYPE"), R.Item("PARENT_CATEGORY_ID"), _
                                                        R.Item("CATALOG_ID"), R.Item("CATEGORY_DESC"), R.Item("DISPLAY_NAME"), R.Item("IMAGE_ID"), _
                                                        R.Item("EXTENDED_DESC"), R.Item("CREATED"), R.Item("CREATED_BY"), R.Item("LAST_UPDATED"), _
                                                        R.Item("LAST_UPDATED_BY"), R.Item("SEQ_NO"), R.Item("PUBLISH_STATUS"), R.Item("DEFAULT_FLAG"), _
                                                        R.Item("CONFIGURATION_RULE"), R.Item("NOT_EXPAND_CATEGORY"), R.Item("SHOW_HIDE"), R.Item("EZ_FLAG"), _
                                                        R.Item("UID"), R.Item("ORG")))
                SyncCategory(R.Item("CATEGORY_ID"), FORG, TORG)
            Next
        End If
    End Sub
    Protected Sub btnCopy_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim PN As String = Me.txtPN.Text.Trim
        Dim FORG As String = "EU"
        Dim TORG As String = "US"
        dbUtil.dbExecuteNoQuery("B2B", "DELETE FROM CbomSyncTracking")
        SyncCatalog(PN, FORG, TORG)
        SyncBTOItem(PN, FORG, TORG)
        SyncCategory(PN, FORG, TORG)
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
   BTO NO:<asp:TextBox runat="server" ID="txtPN"></asp:TextBox>
    <asp:Button runat="server" ID= "btnCopy" Text="Button" OnClick="btnCopy_Click" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

