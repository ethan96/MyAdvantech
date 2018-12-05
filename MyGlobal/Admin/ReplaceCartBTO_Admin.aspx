<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If String.IsNullOrEmpty(TextBox1.Text) Then
            Util.AjaxJSAlert(up1, "NUMBER cannot be empty")
            Exit Sub
        End If
        If String.IsNullOrEmpty(TextBox2.Text) Then
            Util.AjaxJSAlert(up1, "VNUMBER cannot be empty")
            Exit Sub
        End If
        Dim p() As String = Split(TextBox1.Text.Trim, ",")
        For i As Integer = 0 To p.Length - 1
            If IsExist(p(i)) Then
                Util.AjaxJSAlert(up1, p(i) + " : already exists")
            Else
                dbUtil.dbExecuteNoQuery("my", String.Format("INSERT INTO EZ_CBOM_MAPPING ([ROW_ID] ,[NUMBER] ,[VNUMBER],[ORG],[LAST_UPD_DATE] ,[LAST_UPD_BY],ISMANUAL) VALUES('{0}','{1}','{2}','{3}','{4}','{5}',1)", _
                                 Util.NewRowId("EZ_CBOM_MAPPING", "my"), p(i), TextBox2.Text.Trim.Replace("'", "''"), Left(Session("org_id").ToString.ToUpper, 2), Now(), Session("user_id")))

            End If
        Next
        Util.AjaxJSAlert(up1, "Add successful")
        Bind()
        TextBox1.Text = ""
        TextBox2.Text = ""
    End Sub
    Public Function IsExist(ByVal partno As String) As Boolean
        If dbUtil.dbGetDataTable("my", String.Format("  select number from  EZ_CBOM_MAPPING where number='{0}' and ORG ='{1}'", partno, Left(Session("org_id"), 2))).Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Protected Sub Button2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Bind()
    End Sub
    Public Sub Bind()
        gv1.DataSource = dbUtil.dbGetDataTable("MY", GetSQL())
        gv1.DataBind()
    End Sub
    Public Function GetSQL() As String
        Dim sqlwhere As String = ""
        If Not Util.IsAEUIT() Then
            sqlwhere = String.Format("and org ='{0}' and ismanual =1 ", Left(Session("org_id"), 2))
        End If
        Dim sql As String = "select [ROW_ID],[NUMBER],[VNUMBER],ISMANUAL,[ORG],[LAST_UPD_DATE],[LAST_UPD_BY] from EZ_CBOM_MAPPING where  NUMBER like '%" + TextBox3.Text.Trim.Replace("'", "''") + "%' and VNUMBER like '%" + TextBox4.Text.Trim.Replace("'", "''") + "%'  "
        Return sql + sqlwhere + " ORDER BY org,ismanual  desc"
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Util.IsAEUIT() OrElse User.Identity.Name.Equals("james.hill@advantech.com", StringComparison.OrdinalIgnoreCase) Then '2015/3/2 Add James Hill to access ReplaceCartBTO_Admin. By ICC 
        Else
            Response.End()
        End If
        If Not IsPostBack Then
         Bind()
        End If
    End Sub
    Protected Sub gv1_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
    End Sub
    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not Util.IsAEUIT() Then
            e.Row.Cells(3).Visible = False
            e.Row.Cells(4).Visible = False
        End If
        'If e.Row.RowType = DataControlRowType.DataRow Then
        '    Dim dt As System.Data.DataRowView = CType(e.Row.DataItem, System.Data.DataRowView)
        '    Dim ISMANUAL As Boolean = Boolean.Parse(dt.DataView(e.Row.RowIndex)("ISMANUAL"))
        '    If ISMANUAL Then
        '        e.Row.BackColor = Drawing.Color.Tomato
        '    End If
        'End If
    End Sub

    Protected Sub gv1_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim strsql As String = "delete from EZ_CBOM_MAPPING where ROW_ID='" + gv1.DataKeys(e.RowIndex).Value.ToString() + "'"
        dbUtil.dbExecuteNoQuery("MY", strsql)
        Util.AjaxJSAlert(up1, "Delete successful")
        Bind()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:UpdatePanel runat="server" ID="up1" >
        <ContentTemplate>
            <center>
                <table width="100%" border="0" align="center" style="border-style: groove;  padding-top:7px; padding-bottom:7px;">
                    <tr>
                        <td align="right">
                            BTOS Display Name:
                        </td>
                        <td>
                            <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                        </td>
                        <td align="right">
                            Actual BTOS Part Number:
                        </td>
                        <td>
                            <asp:TextBox ID="TextBox2" runat="server"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                        <td align="left">
                            <asp:Button ID="Button1" runat="server" Text="Add" OnClick="Button1_Click" />
                        </td>
                    </tr>
                </table>
                <br />
                <table width="100%" border="0" align="center" style="border-style: groove;">
                    <tr>
                        <td align="center" style="padding-top:10px; padding-bottom:10px;"">
                            BTOS Display Name:
                            <asp:TextBox ID="TextBox3" runat="server"></asp:TextBox>
                            Actual BTOS Part Number:
                            <asp:TextBox ID="TextBox4" runat="server"></asp:TextBox>
                            <asp:Button ID="Button2" runat="server" Text="Serach" OnClick="Button2_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td align="center">
                            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                                AllowSorting="false"  DataKeyNames="ROW_ID" Width="98%"
                                OnRowUpdating="gv1_RowUpdating" OnRowDataBound="gv1_RowDataBound" OnRowDeleting="gv1_RowDeleting">
                                <Columns>
                                    <asp:CommandField ShowEditButton="false" DeleteText=" Delete " ShowDeleteButton="true" />
                                    <asp:BoundField HeaderText="BTOS Display Name" DataField="NUMBER" SortExpression="NUMBER" />
                                    <asp:BoundField HeaderText="Actual BTOS Part Number" DataField="VNUMBER" SortExpression="VNUMBER" />
                                    <asp:TemplateField HeaderText="Manual" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:CheckBox runat="server" ID="tj" Checked='<%#Eval("ISMANUAL")%> ' Enabled="false" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="ORG" DataField="ORG" SortExpression="ORG" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="LAST_UPD_DATE" DataField="LAST_UPD_DATE" DataFormatString="{0:MM/dd/yyy}"
                                        ReadOnly="true" ItemStyle-HorizontalAlign="Center" SortExpression="LAST_UPD_DATE" />
                                    <asp:BoundField HeaderText="LAST_UPD_BY" DataField="LAST_UPD_BY" ReadOnly="true"
                                        SortExpression="LAST_UPD_BY" />
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
    <%--            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>"
                    SelectCommand="select [ROW_ID],[NUMBER],[VNUMBER],ISMANUAL,[ORG],[LAST_UPD_DATE],[LAST_UPD_BY] from EZ_CBOM_MAPPING where org =@org ORDER BY org"
                    UpdateCommand="UPDATE EZ_CBOM_MAPPING SET NUMBER = @NUMBER, VNUMBER = @VNUMBER,
                 LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = @UID,ISMANUAL=1 where row_id=@ROW_ID" DeleteCommand="delete from EZ_CBOM_MAPPING where row_id=@ROW_ID">
                    <UpdateParameters>
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="user_id" Name="UID" />
                    </UpdateParameters>
                    <SelectParameters>
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="org" Name="org" />
                    </SelectParameters>
                </asp:SqlDataSource>--%>
            </center>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
