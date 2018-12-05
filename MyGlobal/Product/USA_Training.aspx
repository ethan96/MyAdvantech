<%@ Page Title="MyAdvantech - Monthly Channel Partner Training" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
         If Not IsPostBack Then
            gv1.DataSource = getDT()
            gv1.DataBind()
            If Session("user_id").ToString.StartsWith("adam.sturm", StringComparison.OrdinalIgnoreCase) Then
                plUpload.Visible = True
            End If
        End If
    End Sub
    
    Function getDT() As List(Of CHANNEL_TRAINING)
        Dim DC As New CHANNELTRAININGDataContext
        Return DC.CHANNEL_TRAININGs.ToList()
    End Function
    Private Sub btnImport_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnImport.Click
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            If Not IsNothing(MSM) Then
                Dim tempdt As DataTable = UTIL.ExcelFile2DataTable(MSM, 1, 0)
                If Not IsNothing(tempdt) AndAlso tempdt.Rows.Count > 0 Then
                    Dim dc As New CHANNELTRAININGDataContext
                    For Each r As DataRow In tempdt.Rows
                        Dim o As New CHANNEL_TRAINING
                        o.UID = System.Guid.NewGuid.ToString
                        o.NAME = r.Item(0)
                        o.URL = r.Item(1)
                        o.CDATE = Now
                        o.CBY = Session("user_id")
                        dc.CHANNEL_TRAININGs.InsertOnSubmit(o)
                    Next
                    dc.ExecuteCommand("DELETE FROM CHANNEL_TRAINING")
                    dc.SubmitChanges()
                End If
            End If
        End If
        gv1.DataSource = getDT()
        gv1.DataBind()
    End Sub
    Protected Sub btnToXls_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As New DataTable
        dt.Columns.Add("NAME") : dt.Columns.Add("URL")
        Dim D As New CHANNELTRAININGDataContext
        For Each R As CHANNEL_TRAINING In D.CHANNEL_TRAININGs
            Dim tr As DataRow = dt.NewRow
            tr.Item(0) = R.NAME : tr.Item(1) = R.URL
            dt.Rows.Add(tr)
        Next
        dt.AcceptChanges()
        Util.DataTable2ExcelDownload(dt, "Training_Download_Log.xls")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td colspan="3" style="height: 15px">
              <asp:Panel runat="server" ID="plUpload" Visible="false">
                    Upload From Excel:
                    <table>
                        <tr>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" />
                                <asp:Button ID="btnImport" runat="server" Text="Import" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td style="width: 10px">
            </td>
            <td>
                <!--Page Title-->
                <div class="euPageTitle">
                    Advantech iA Channel Training</div>
            </td>
            <td >    <div style="float: right;">
        <asp:ImageButton ID="btnToXls" runat="server" ImageUrl="~/Images/excel.gif" OnClick="btnToXls_Click" /></div>
            </td>
        </tr>
        <tr>
            <td colspan="3" style="height: 15px">
            </td>
        </tr>
        <tr>
            <td colspan="3" width="100%">
            <asp:GridView runat="server" ID="gv1" ShowWhenEmpty="true" AutoGenerateColumns="false"
                    AllowPaging="true" PageSize="50" AllowSorting="true" Width="100%">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" Visible="false">
                            <HeaderTemplate>
                                No.
                            </HeaderTemplate>
                            <ItemTemplate>
                                <%#Container.DataItemIndex + 1%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Description" DataField="NAME" ReadOnly="true" SortExpression="NAME" />
                        <asp:BoundField HeaderText="Last Updated" DataField="CDATE" ReadOnly="true" />
                        <asp:TemplateField HeaderText="Link">
                            <ItemTemplate>
                                <asp:HyperLink runat="server" ID="hyLink" Text="Link" NavigateUrl='<%#Eval("URL") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
    </table>
</asp:Content>