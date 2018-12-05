<%@ Page Title="MyAdvantech - Check Where an Item is Used in CTOS" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)

    End Sub
    
    Function getRootBTOByCategoryId(ByRef CatId As String, ByRef MyConn As SqlClient.SqlConnection) As List(Of CatIdRootBTOPair)
        Dim tmpFoundList As New List(Of CatIdRootBTOPair), tmpCatId As String = CatId, loopTimes As Integer = 0
        While True
            If loopTimes >= 10 Then Exit While
            Dim sql As String = _
            " select distinct top 1 a.PARENT_CATEGORY_ID, a.CATEGORY_TYPE   " + _
            " from CBOM_CATALOG_CATEGORY a (nolock) " + _
            " where a.CATEGORY_ID=@CATID and a.ORG='EU' " + _
            " order by a.PARENT_CATEGORY_ID  "
            Dim apt As New SqlClient.SqlDataAdapter(sql, MyConn)
            Dim dt As New DataTable
            apt.SelectCommand.Parameters.AddWithValue("CATID", tmpCatId)
            apt.Fill(dt)
            If dt.Rows.Count = 0 Then Exit While
            
            If String.Equals(dt.Rows(0).Item("PARENT_CATEGORY_ID").ToString, "Root", StringComparison.CurrentCultureIgnoreCase) Then
                tmpFoundList.Add(New CatIdRootBTOPair(CatId, tmpCatId))
                Exit While
            Else
                tmpCatId = dt.Rows(0).Item("PARENT_CATEGORY_ID")
                loopTimes += 1
            End If
        End While
        
        Return tmpFoundList
        
    End Function
    
    Class CatIdRootBTOPair
        Public Property CatId As String : Public Property RootBTO As String
        Public Sub New(catid As String, rootBto As String)
            Me.CatId = catid : Me.RootBTO = rootBto
        End Sub
    End Class
    
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        lbErrMsg.Text = "" : gvCompBTO.DataSource = Nothing : gvCompBTO.DataBind()
        Dim strComp As String = Trim(txtComp.Text)
        If strComp.Length <= 4 Then
            lbErrMsg.Text = "Length of component keyword is too short" : Exit Sub
        End If
        Dim sql As String = _
            " select distinct top 100 a.CATEGORY_ID as Component, a.PARENT_CATEGORY_ID as Category, a.ORG  " + _
            " from CBOM_CATALOG_CATEGORY a (nolock) " + _
            " where a.CATEGORY_ID like '%" + Replace(strComp, "'", "''").Replace("*", "%") + "%' and a.CATEGORY_TYPE='Component' " + _
            " and a.ORG='EU' " + _
            " order by a.CATEGORY_ID, a.PARENT_CATEGORY_ID, a.ORG  "
        Dim dtBTO As DataTable = dbUtil.dbGetDataTable("MY", sql)
        dtBTO.Columns.Add("Root_BTOS")
        
        Dim FoundSet As New List(Of CatIdRootBTOPair), MyConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        MyConn.Open()
        For Each btoRow As DataRow In dtBTO.Rows
            
            Dim catId As String = btoRow.Item("Category").ToString().ToLower()
            Dim isfound = From q In FoundSet Where q.CatId = catId
                          
            If isfound.Count = 0 Then
                Dim tmpList As List(Of CatIdRootBTOPair) = getRootBTOByCategoryId(catId, MyConn)
                If tmpList.Count > 0 Then
                    FoundSet.AddRange(tmpList)
                    btoRow.Item("Root_BTOS") = tmpList(0).RootBTO
                End If
            Else
                btoRow.Item("Root_BTOS") = isfound.First.RootBTO
            End If
            
        Next
        MyConn.Close()
        
        gvCompBTO.DataSource = dtBTO : gvCompBTO.DataBind()
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearch">
                    <table>
                        <tr>
                            <th>Component:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtComp" Width="150px" /></td>
                            <td>
                                <asp:Button runat="server" ID="btnSearch" Text="Search Where-Used" OnClick="btnSearch_Click" /></td>
                        </tr>
                        <tr style="height:25px">
                            <td colspan="3">
                                <asp:Label runat="server" ID="lbErrMsg" ForeColor="Tomato" Font-Bold="true" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvCompBTO" AutoGenerateColumns="false">
                    <Columns>
                        <asp:TemplateField HeaderText="Component">
                            <ItemTemplate>
                                <%#Eval("Component")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Parent Category">
                            <ItemTemplate>
                                <%#Eval("Category")%>
                            </ItemTemplate>
                        </asp:TemplateField> 
                        <asp:TemplateField HeaderText="Root BTOS">
                            <ItemTemplate>
                                <%#Eval("Root_BTOS")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
    </table>
</asp:Content>