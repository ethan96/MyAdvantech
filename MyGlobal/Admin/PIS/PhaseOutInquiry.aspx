<%@ Page Title="MyAdvantech - Product Phase Out and Replaced By Inquiry" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<script runat="server">

    Protected Sub btn1_Click(sender As Object, e As System.EventArgs)
        gv1.DataSource = Nothing : gv1.DataBind()
        If Not String.IsNullOrEmpty(Trim(txtPN.Text)) Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                " select distinct top 100 a.PART_NO as PhasedOutPN, a.REPLACED_BY, case a.REPLACED_BY_TYPE when 'M' then 'Model' else 'Part Number' end as REPLACED_BY_TYPE, IsNull(a.PM_NOTE,'') as PM_NOTE " + _
                " from MY_PRODUCT_REPLACED_BY a " + _
                " where a.PART_NO like '%" + Replace(Trim(txtPN.Text), "'", "''") + "%' " + _
                " order by a.PART_NO, a.REPLACED_BY  ")
            gv1.DataSource = dt : gv1.DataBind()
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <asp:Panel runat="server" ID="panel1" DefaultButton="btn1">
                    <table>
                        <tr>
                            <th align="left">
                                Model or Part Number:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtPN" Width="100px" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btn1" Text="Query" OnClick="btn1_Click" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false">
                            <Columns>
                                <asp:BoundField HeaderText="Phased Out Part Number" DataField="PhasedOutPN" />
                                <asp:BoundField HeaderText="Replaced By" DataField="REPLACED_BY" />
                                <asp:BoundField HeaderText="Replaced By Type" DataField="REPLACED_BY_TYPE" />
                                <asp:BoundField HeaderText="PLM's PM Note" DataField="PM_NOTE" />
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btn1" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
