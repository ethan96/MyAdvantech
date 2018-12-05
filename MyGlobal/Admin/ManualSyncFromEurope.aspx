<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public Function getList(ByVal FORG As String, ByVal CATALOG_ID As String) As DataTable
        Dim str1 As String = "select " & _
                          "CATALOG_ID" & _
                          " from CBOM_CATALOG where CATALOG_ORG='" & FORG & "' and catalog_TYPE  IN " & _
                          "('CompactPCI'," & _
                          "'Digital Signage Platforms'," & _
                          "'Digital Video Solution'," & _
                          "'Embedded Computing'," & _
                          "'Industrial Tablet PC'," & _
                          "'iServices Group'," & _
                          "'Medical Computing'," & _
                          "'Panel PC (PPC)'," & _
                          "'Pre-Configuration'," & _
                          "'Ubiquitous Touch Computer'," & _
                          "'Internet Security Platforms/Nas Platforms-Appliances','In-Vehicle Computing System')"

        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str1)
        Return dt
    End Function
    Public Function getListCheck(ByVal FORG As String, ByVal CATALOG_ID As String) As DataTable
        Dim str1 As String = "select " & _
                         " top 1 CATALOG_ID" & _
                         " from CBOM_CATALOG where CATALOG_ORG='" & FORG & "' and CATALOG_ID ='" + CATALOG_ID + "' "

        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str1)
        'Response.Write(str1)
        'Response.End()
        Return dt
    End Function
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
            dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into CBOM_CATALOG values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}')", _
                                                       dt.Rows(0).Item("CATALOG_ID"), dt.Rows(0).Item("CATALOG_NAME"), dt.Rows(0).Item("CATALOG_TYPE"), _
                                                       dt.Rows(0).Item("CATALOG_ORG"), dt.Rows(0).Item("CATALOG_DESC"), Now.ToShortDateString, _
                                                       dt.Rows(0).Item("CREATED_BY"), Now.ToShortDateString, dt.Rows(0).Item("LAST_UPDATED_BY"), _
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
                                                        dt.Rows(0).Item("EXTENDED_DESC"), Now.ToShortDateString, dt.Rows(0).Item("CREATED_BY"), Now.ToShortDateString, _
                                                        dt.Rows(0).Item("LAST_UPDATED_BY"), dt.Rows(0).Item("SEQ_NO"), dt.Rows(0).Item("PUBLISH_STATUS"), dt.Rows(0).Item("DEFAULT_FLAG"), _
                                                        dt.Rows(0).Item("CONFIGURATION_RULE"), dt.Rows(0).Item("NOT_EXPAND_CATEGORY"), dt.Rows(0).Item("SHOW_HIDE"), dt.Rows(0).Item("EZ_FLAG"), _
                                                        dt.Rows(0).Item("UID"), dt.Rows(0).Item("ORG")))
        End If
    End Sub

    Public Sub SyncCategory(ByVal PN As String, ByVal FORG As String, ByVal TORG As String, ByRef CatSet As ArrayList)
        If CatSet.Contains(PN) Then
            Exit Sub
        End If
        Dim str2 As String = "select " & _
                             "CATEGORY_ID," & _
                             "CATEGORY_NAME," & _
                             "CATEGORY_TYPE," & _
                             "PARENT_CATEGORY_ID," & _
                             "CATALOG_ID," & _
                             "ISNULL(CATEGORY_DESC, '') AS CATEGORY_DESC," & _
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
                             " from cbom_catalog_category where org='" & FORG & "' and PARENT_CATEGORY_ID='" & PN & "' and category_id <> PARENT_CATEGORY_ID"
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str2)
        If dt.Rows.Count > 0 Then
            CatSet.Add(PN)
            Dim temp As New ArrayList
            temp = CatSet
            Dim SQL As String = "delete from cbom_catalog_category where org='" & TORG & "' AND PARENT_CATEGORY_ID='" & PN & "'"
            Try
                dbUtil.dbExecuteNoQuery("b2b", SQL)
            Catch ex As Exception
                Util.SendEmail("ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Manual Sync From Europe Error", ex.Message, True, "tc.chen.advantech.com.tw", "")
            End Try
            For Each R As DataRow In dt.Rows
                ' dbUtil.dbExecuteNoQuery("b2b", "insert into CbomSyncTracking values('" & R.Item("CATEGORY_ID") & "','" & PN & "')")
                'Ryan Huang 2015/11/30: R.Item("CATEGORY_DESC")修正單引號判斷錯誤,使用replace將"'"取代為"''"
                dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into cbom_catalog_category values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}')", _
                                                        R.Item("CATEGORY_ID"), R.Item("CATEGORY_NAME"), R.Item("CATEGORY_TYPE"), R.Item("PARENT_CATEGORY_ID"), _
                                                        R.Item("CATALOG_ID"), R.Item("CATEGORY_DESC").ToString().Replace("'", "''"), R.Item("DISPLAY_NAME"), R.Item("IMAGE_ID"), _
                                                        R.Item("EXTENDED_DESC"), Now.ToShortDateString, R.Item("CREATED_BY"), Now.ToShortDateString, _
                                                        R.Item("LAST_UPDATED_BY"), R.Item("SEQ_NO"), R.Item("PUBLISH_STATUS"), R.Item("DEFAULT_FLAG"), _
                                                        R.Item("CONFIGURATION_RULE"), R.Item("NOT_EXPAND_CATEGORY"), R.Item("SHOW_HIDE"), R.Item("EZ_FLAG"), _
                                                        R.Item("UID"), R.Item("ORG")))
                SyncCategory(R.Item("CATEGORY_ID"), FORG, TORG, CatSet)
                CatSet = temp
            Next
        End If
    End Sub
    Protected Sub BTsync_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim CATALOG_ID As String = ""
        lbMsg.Text = ""
        If TBctos.Text.Trim = "" Then
            lbMsg.Text = "Please enter BTOS name." : Exit Sub
        End If
        CATALOG_ID = TBctos.Text.Trim.Replace("'", "''")
        Dim FORG As String = "EU"
        Dim TORG As String = DDL_ORG.SelectedValue ' "US"
        dbUtil.dbExecuteNoQuery("b2b", "DELETE FROM CbomSyncTracking")
        'Dim DT As DataTable = getList(FORG, CATALOG_ID)
        'If DT.Rows.Count > 0 Then
        '    lbMsg.Text = TBctos.Text.Trim + "  is automatically synced from EU to US every day." : Exit Sub
        'End If
        Dim DT As DataTable = getListCheck(FORG, CATALOG_ID)
        If DT.Rows.Count = 0 Then
            lbMsg.Text = TBctos.Text.Trim + "  is not in AEU’s database." : Exit Sub
        End If
        'OrderUtilities.showDT(DT)
        'Exit Sub
        For Each r As DataRow In DT.Rows
            SyncCatalog(r.Item("CATALOG_ID"), FORG, TORG)
            SyncBTOItem(r.Item("CATALOG_ID"), FORG, TORG)
            Dim catset As New ArrayList
            SyncCategory(r.Item("CATALOG_ID"), FORG, TORG, catset)
            ' Console.Write(r.Item("CATALOG_ID"))
        Next
        lbMsg.Text = TBctos.Text.Trim + " synchronized successfully"
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Session("org_id") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id")) Then
                Dim TOORG As String = Session("org_id").ToString.Substring(0, 2)
                DDL_ORG.Items.Add(New ListItem(TOORG, TOORG))
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr valign="top">
            <td width="220">
                <asp:TextBox runat="server" ID="TBctos" Width="200"></asp:TextBox>
            </td>
            <td width="20" valign="middle">
                <strong>To: </strong>
            </td>
            <td width="55">
                <asp:DropDownList ID="DDL_ORG" runat="server">
                </asp:DropDownList>
            </td>
            <td width="110">
                <asp:Button runat="server" Text="Synchronize" ID="BTsync" OnClick="BTsync_Click" />
            </td>
            <td>
                <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Red" />
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
