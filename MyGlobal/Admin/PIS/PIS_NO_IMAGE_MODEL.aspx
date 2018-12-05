<%@ Page Title="MyAdvantech - Without Image Model Report" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestPLine(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        "select distinct top 20 product_line from SAP_PRODUCT where len(product_line)=4 and product_line like '{0}%' order by PRODUCT_LINE ", prefixText.Trim().Replace("'", "").Replace("*", "%")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    
    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 10000 a.part_no, a.model_no, a.status, a.material_group, b.egroup as product_group, "))
            .AppendLine(String.Format(" b.EDIVISION as product_division, b.PRODUCT_LINE, a.tumbnail_image_id, case len(IsNull(a.tumbnail_image_id,'')) when 0 then 'N' else 'Y' end as HasImg  "))
            .AppendLine(String.Format(" from PRODUCT_FULLTEXT_NEW a inner join SAP_PRODUCT b on a.part_no=b.PART_NO  "))
            .AppendLine(String.Format(" where a.material_group in ('PRODUCT') and a.model_no<>'' and a.status in ('A','N','H','S5','M1') "))
            If cbIncImgModel.Checked = False Then
                .AppendLine(String.Format(" and a.tumbnail_image_id is null "))
            End If
            '.AppendLine(String.Format(" and b.PRODUCT_GROUP not in ('OTHR','AGSG') "))
            If txtPN.Text.Trim() <> "" Then
                .AppendFormat(" and a.part_no like '{0}%' ", Replace(Replace(txtPN.Text.Trim(), "'", "''"), "*", "%"))
            End If
            'If txtPL.Text.Trim() <> "" Then
            '    .AppendFormat(" and a.PRODUCT_LINE like '{0}%' ", Replace(Replace(txtPL.Text.Trim(), "'", "''"), "*", "%"))
            'End If
            If gv1 IsNot Nothing AndAlso gv1.HeaderRow IsNot Nothing Then
                Dim pgDlist As DropDownList = gv1.HeaderRow.FindControl("dlHeaderFilterPG")
                If pgDlist IsNot Nothing AndAlso pgDlist.SelectedIndex > 0 Then
                    .AppendLine(String.Format(" and b.egroup='{0}' ", Replace(pgDlist.SelectedValue, "'", "''")))
                End If
                Dim pdDlist As DropDownList = gv1.HeaderRow.FindControl("dlHeaderFilterPD")
                If pdDlist IsNot Nothing AndAlso pdDlist.SelectedIndex > 0 Then
                    .AppendLine(String.Format(" and b.edivision='{0}' ", Replace(pdDlist.SelectedValue, "'", "''")))
                End If
            End If
            .AppendLine(String.Format(" order by a.part_no  "))
        End With
        'Response.Write(sb.ToString())
        Return sb.ToString()
    End Function
    
    Protected Sub gvAccount_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = Nothing
                    For Each c As Control In cell.Controls
                        If TryCast(c, LinkButton) IsNot Nothing Then
                            button = DirectCast(c, LinkButton) : Exit For
                        End If
                    Next
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                    If ViewState("PGIdx") IsNot Nothing AndAlso Integer.TryParse(ViewState("PGIdx"), 0) Then
                        Dim dl As DropDownList = cell.FindControl("dlHeaderFilterPG")
                        Dim dl2 As DropDownList = cell.FindControl("dlHeaderFilterPD")
                        dl.SelectedIndex = CInt(ViewState("PGIdx"))
                        If dl.SelectedIndex = 0 Then
                            For i As Integer = 1 To dl2.Items.Count - 1
                                dl2.Items(i).Enabled = True
                            Next
                        Else
                            For i As Integer = 1 To dl2.Items.Count - 1
                                dl2.Items(i).Enabled = False
                            Next
                            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                                                  " select distinct edivision from SAP_PRODUCT " + _
                                                  " where EDIVISION is not null and egroup='{0}' order by EDIVISION ", Replace(dl.SelectedValue, "'", "''")))
                            For Each r As DataRow In dt.Rows
                                If dl2.Items.FindByValue(r.Item("edivision")) IsNot Nothing Then
                                    dl2.Items.FindByValue(r.Item("edivision")).Enabled = True
                                End If
                            Next
                        End If
                    End If
                    If ViewState("PDIdx") IsNot Nothing AndAlso Integer.TryParse(ViewState("PDIdx"), 0) Then
                        CType(cell.FindControl("dlHeaderFilterPD"), DropDownList).SelectedIndex = CInt(ViewState("PDIdx"))
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            src1.SelectCommand = GetSql()
            txtPN.Attributes("autocomplete") = "off" 'txtPL.Attributes("autocomplete") = "off"
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gv1.PageIndex = 0 : src1.SelectCommand = GetSql()
    End Sub

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("MY", GetSql()), "NoImgModels.xls")
    End Sub

    Protected Sub dlHeaderFilterPG_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        src1.SelectCommand = GetSql()
        Dim dl As DropDownList = sender
        Dim dl2 As DropDownList = dl.NamingContainer.FindControl("dlHeaderFilterPD")
        ViewState("PGIdx") = dl.SelectedIndex
    End Sub

    Protected Sub dlHeaderFilterPD_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        src1.SelectCommand = GetSql()
        Dim dl As DropDownList = sender
        ViewState("PDIdx") = dl.SelectedIndex
    End Sub

    Protected Sub cbIncImgModel_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        src1.SelectCommand = GetSql()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <th align="left" style="color:Navy; height:45px"><h2>No Image Model Report</h2></th>
        </tr>
        <tr>
            <td>
                <table>                   
                    <tr>
                        <th align="left">Part No.</th>
                        <td>
                            <asp:Panel runat="server" ID="panel1" DefaultButton="btnQuery">
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" TargetControlID="txtPN" 
                                    CompletionInterval="100" MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" 
                                    ServiceMethod="GetPartNo" />
                                <asp:TextBox runat="server" ID="txtPN" />
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr align="center">
                        <td colspan="2"><asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <td><asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download" OnClick="imgXls_Click" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:CheckBox runat="server" ID="cbIncImgModel" Text="Include Models with Images" AutoPostBack="true" 
                                        OnCheckedChanged="cbIncImgModel_CheckedChanged" Font-Bold="true" />
                                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="99%" AllowPaging="true" EmptyDataText="No Search Result"
                                        AllowSorting="true" PagerSettings-Position="TopAndBottom" PageSize="100" DataSourceID="src1" ShowHeaderWhenEmpty="true"
                                        EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                                        BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                        PagerStyle-BackColor="#ffffff" OnRowCreated="gvAccount_RowCreated" 
                                        PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Product Group" SortExpression="product_group" ItemStyle-Width="215px">
                                                <HeaderTemplate>
                                                    <asp:DropDownList runat="server" ID="dlHeaderFilterPG" Width="99%" AutoPostBack="true" OnSelectedIndexChanged="dlHeaderFilterPG_SelectedIndexChanged">
                                                        <asp:ListItem Value="Select..." />
                                                        <asp:ListItem Value="AC-DMS" />
                                                        <asp:ListItem Value="Advantech Global Services" />
                                                        <asp:ListItem Value="AiSD" />
                                                        <asp:ListItem Value="AMC-DMS" />
                                                        <asp:ListItem Value="eAutomation" />
                                                        <asp:ListItem Value="EmbCore" />
                                                        <asp:ListItem Value="Embedded Systems" />
                                                        <asp:ListItem Value="ES-DMS" />
                                                        <asp:ListItem Value="eServices & Applied Computing" />
                                                        <asp:ListItem Value="Industrial Communication & Video" />
                                                        <asp:ListItem Value="Industrial HMI & Panel PC" />
                                                        <asp:ListItem Value="MC-DMS" />
                                                        <asp:ListItem Value="Networks and Communication" />
                                                    </asp:DropDownList>&nbsp;
                                                    <asp:LinkButton runat="server" Text="Product Group" Font-Bold="true" ForeColor="Black" ID="lnkSortPG" CommandName="Sort" CommandArgument="product_group" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <%# Eval("product_group")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Product Division" SortExpression="product_division" ItemStyle-Width="205px">
                                                <HeaderTemplate>
                                                    <asp:DropDownList runat="server" ID="dlHeaderFilterPD" Width="99%" AutoPostBack="true" OnSelectedIndexChanged="dlHeaderFilterPD_SelectedIndexChanged">
                                                        <asp:ListItem Value="Select..." />
                                                        <asp:ListItem Value='3.5" Biscuit & EPIC' />
                                                        <asp:ListItem Value='5.25" /EBX/OTHER' />
                                                        <asp:ListItem Value="ADAM" />
                                                        <asp:ListItem Value="AIMB" />
                                                        <asp:ListItem Value="AiSD" />
                                                        <asp:ListItem Value="Applied Infotainment Terminal" />
                                                        <asp:ListItem Value="ATX IMB" />
                                                        <asp:ListItem Value="BCD" />
                                                        <asp:ListItem Value="CFD-AMC1" />
                                                        <asp:ListItem Value="CFD-AMC2" />
                                                        <asp:ListItem Value="CFD-AMC3" />
                                                        <asp:ListItem Value="CFD-AMC4" />
                                                        <asp:ListItem Value="CFD-AMC5" />
                                                        <asp:ListItem Value="CFD-ESI" />
                                                        <asp:ListItem Value="CFD-ESII" />
                                                        <asp:ListItem Value="CFD-MCI" />
                                                        <asp:ListItem Value="CFD-MCII" />
                                                        <asp:ListItem Value="CTOS" />
                                                        <asp:ListItem Value="Design-in Service" />
                                                        <asp:ListItem Value="Digital Signage" />
                                                        <asp:ListItem Value="Display Solution" />
                                                        <asp:ListItem Value="DTOS-Embedded" />
                                                        <asp:ListItem Value="DTOS-System" />
                                                        <asp:ListItem Value="DVS" />
                                                        <asp:ListItem Value="ECG_Others" />
                                                        <asp:ListItem Value="Embedded IPC" />
                                                        <asp:ListItem Value="Factory OEM" />
                                                        <asp:ListItem Value="Green Energy" />
                                                        <asp:ListItem Value="HMI" />
                                                        <asp:ListItem Value="iBuilding" />
                                                        <asp:ListItem Value="Ind. Comm." />
                                                        <asp:ListItem Value="Ind. I/O" />
                                                        <asp:ListItem Value="In-Vehicle Computing" />
                                                        <asp:ListItem Value="IPC & SIS" />
                                                        <asp:ListItem Value="i-Server" />
                                                        <asp:ListItem Value="Medical-Product & Image" />
                                                        <asp:ListItem Value="MEMO(Others)" />
                                                        <asp:ListItem Value="Microsoft & Emb SW Distribution" />
                                                        <asp:ListItem Value="NAPD/DSP/NPU" />
                                                        <asp:ListItem Value="PAC" />
                                                        <asp:ListItem Value="Panel PC" />
                                                        <asp:ListItem Value="PAPS" />
                                                        <asp:ListItem Value="PC/104" />
                                                        <asp:ListItem Value="P-Modules & SoC" />
                                                        <asp:ListItem Value="Portable Computing" />
                                                        <asp:ListItem Value="RISC" />
                                                        <asp:ListItem Value="SIS" />
                                                        <asp:ListItem Value="Slot SBC" />
                                                        <asp:ListItem Value="SOM" />
                                                        <asp:ListItem Value="SVCB" />
                                                        <asp:ListItem Value="UNO" />
                                                        <asp:ListItem Value="UTC" />
                                                        <asp:ListItem Value="WebAccess Solution" />
                                                    </asp:DropDownList>&nbsp;
                                                    <asp:LinkButton runat="server" Text="Product Division" Font-Bold="true" ForeColor="Black" ID="lnkSortPD" CommandName="Sort" CommandArgument="product_division" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <%# Eval("product_division")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" ItemStyle-Width="100px" 
                                                DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" 
                                                DataTextField="part_no" Target="_blank" SortExpression="part_no" />
                                            <asp:HyperLinkField HeaderText="Model No." DataNavigateUrlFields="model_no" 
                                                DataNavigateUrlFormatString="~/Product/model_detail.aspx?model_no={0}" 
                                                DataTextField="model_no" Target="_blank" SortExpression="model_no" />
                                            <asp:BoundField HeaderText="Has Image?" SortExpression="HasImg" DataField="HasImg" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField Visible="false" HeaderText="Thumbnail Image Id" SortExpression="tumbnail_image_id" DataField="tumbnail_image_id" />
                                            <asp:BoundField HeaderText="Status" DataField="status" SortExpression="status" ItemStyle-HorizontalAlign="Center" />   
                                            <asp:BoundField HeaderText="Material Group" DataField="material_group" SortExpression="material_group" ItemStyle-HorizontalAlign="Center" />    
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>    
</asp:Content>