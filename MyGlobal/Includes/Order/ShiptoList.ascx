<%@ Control Language="VB" ClassName="ShiptoList" %>
<script runat="server">
    Dim myCompany As New SAP_Company("b2b", "SAP_dimCompany")
    Sub GetData()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct b.company_id as company_id, b.COMPANY_NAME, b.ADDRESS, " + _
                                      " case a.PARTNER_FUNCTION when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' end as PARTNER_FUNCTION  "))
            .AppendLine(" from SAP_COMPANY_PARTNERS a inner join SAP_DIMCOMPANY b on a.PARENT_COMPANY_ID=b.COMPANY_ID  ")
            .AppendLine(String.Format(" WHERE a.COMPANY_ID='{0}' and b.DELETION_FLAG<>'X' and a.PARTNER_FUNCTION in ('WE','AG') ", Session("Company_id")))
            If Trim(txtShipID.Text) <> String.Empty Then .AppendLine(String.Format(" and b.company_id like N'%{0}%' ", Replace(Replace(Trim(txtShipID.Text), "'", "''"), "*", "%")))
            If Trim(txtShipName.Text) <> String.Empty Then .AppendLine(String.Format(" and b.COMPANY_NAME like N'%{0}%' ", Replace(Replace(Trim(txtShipName.Text), "'", "''"), "*", "%")))
            .AppendLine(String.Format(" order by b.company_id "))
        End With
        Me.SqlDataSource1.SelectCommand = sb.ToString()
        test.Text = sb.ToString()
        'Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        GetData()
    End Sub

    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        Dim p As Control = Me.Parent
        Dim dt As DataTable = myCompany.GetDT(String.Format("company_Id='{0}'", id), "")
        If dt.Rows.Count > 0 Then
            CType(p.FindControl("txtShipTo"), TextBox).Text = id
            CType(p.FindControl("txtShipToAttention"), TextBox).Text = dt.Rows(0).Item("attention")
            '20120730 TC: Marked below line because it caused error, but don't know why
            'CType(p.FindControl("txtShipToAddr"), TextBox).Text = dt.Rows(0).Item("address")
        End If
        CType(p.FindControl("upShipTo"), UpdatePanel).Update()
        CType(p.FindControl("MP_shipto"), AjaxControlToolkit.ModalPopupExtender).Hide()
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        GetData()
    End Sub

    Protected Sub lnkCloseBtn_Click(sender As Object, e As System.EventArgs)
        Dim p As Control = Me.Parent
        CType(p.FindControl("MP_shipto"), AjaxControlToolkit.ModalPopupExtender).Hide()
    End Sub
</script>

<table width="550px">
    <tr>
        <td align="right">
            <asp:LinkButton runat="server" ID="lnkCloseBtn" Text="Close" OnClick="lnkCloseBtn_Click" />
        </td>
    </tr>
    <tr>
        <td>
            <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearch">
                <table>
                    <tr>
                        <th align="left">
                            Ship-To ID:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtShipID" />
                        </td>
                        <th align="left">
                            Ship-To Name:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtShipName" />
                        </td>
                        <td>
                            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>            
        </td>
    </tr>
    <tr>
        <td>
            <asp:GridView runat="server" ID="GridView1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false"
                AllowPaging="true" PageIndex="0" PageSize="12" Width="100%" DataKeyNames="company_id"
                OnPageIndexChanging="GridView1_PageIndexChanging">
                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            ID
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:LinkButton runat="server" ID="lbtnPick" OnClick="lbtnPick_Click" Text='<%# Eval("company_id")%>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Name" DataField="COMPANY_NAME" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Address" DataField="ADDRESS" ItemStyle-HorizontalAlign="Left" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
            </asp:SqlDataSource>
            <asp:Label runat="server" ID="test" Text="Label" Visible="false"></asp:Label>
        </td>
    </tr>
</table>
