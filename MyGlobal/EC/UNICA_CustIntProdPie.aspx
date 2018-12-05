<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select IsNull((select COUNT(distinct EMAIL_ADDRESS) from SIEBEL_CONTACT where EMAIL_ADDRESS like '%@%.%' and ACTIVE_FLAG='Y'),0),  IsNull((select COUNT(distinct EMAIL_ADDRESS) from SIEBEL_CONTACT a inner join SIEBEL_CONTACT_INTERESTED_PRODUCT b on a.ROW_ID=b.CONTACT_ROW_ID where a.EMAIL_ADDRESS like '%@%.%' and a.EMPLOYEE_FLAG<>'Y' and a.ACTIVE_FLAG='Y'),0)")
            If dt.Rows.Count = 1 AndAlso (dt.Rows(0).Item(0) > 0 Or dt.Rows(0).Item(1) > 0) Then
                Dim data() As Double = {dt.Rows(0).Item(0) - dt.Rows(0).Item(1), dt.Rows(0).Item(1)}
                Dim labels() As String = {"Customer without Segmentation", "Customer with Segmentation"}
                'Dim colors() As Integer = {&H323297, &HB9DEE1}
                Dim colors() As Integer = {&HFF6600, &H323297}
                Dim c As ChartDirector.PieChart = New ChartDirector.PieChart(620, 190)
                With c
                    .setPieSize(310, 100, 70) : .addTitle("") : .set3D() : .setData(data, labels) : .setLabelLayout(ChartDirector.Chart.SideLayout)
                    .setExplode(0) : .setColors2(ChartDirector.Chart.DataColor, colors) : .setColors2(ChartDirector.Chart.TextColor, New Integer() {&HFFFFFF, &H1111111})
                End With
                PieCustIntSeg.Image = c.makeWebImage(ChartDirector.Chart.PNG)
                PieCustIntSeg.ImageMap = c.getHTMLImageMap("", "", "title='{label}: {value}pcs ({percent}%)'")
                lbTotalSiebelContacts.Text = FormatNumber(dt.Rows(0).Item(0), 0)
            Else
                PieCustIntSeg.Visible = False
            End If
        End If
    End Sub

    Protected Sub lnkRowPG_Click(sender As Object, e As System.EventArgs)
        srcIntProdContacts.SelectParameters("PG").DefaultValue = CType(sender, LinkButton).Text
        PanelIntProdContacts.Visible = True
    End Sub

    Protected Sub lnkClose_Click(sender As Object, e As System.EventArgs)
        PanelIntProdContacts.Visible = False
    End Sub
    
    Protected Sub lnkClose1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PanelOrgContacts.Visible = False
    End Sub

    Protected Sub lnkRowOrg_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        srcOrgContacts.SelectParameters("RBU").DefaultValue = CType(sender, LinkButton).Text
        PanelOrgContacts.Visible = True
    End Sub

    Protected Sub gvCustOrgCat_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If CType(e.Row.Cells(0).FindControl("lblRowOrg"), Label).Text = "AEU" OrElse CType(e.Row.Cells(0).FindControl("lblRowOrg"), Label).Text = "SAP" _
                OrElse CType(e.Row.Cells(0).FindControl("lblRowOrg"), Label).Text = "Others" Then
                CType(e.Row.Cells(0).FindControl("lblRowOrg"), Label).Visible = False
            Else
                CType(e.Row.Cells(0).FindControl("lnkRowOrg"), LinkButton).Visible = False
            End If
        End If
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" ID="sm1" />
    <div>
        <table width="100%">
            <tr valign="top">
                <td style="width: 70%">
                    <table width="100%">
                        <tr valign="top">
                            <td>
                                <table width="100%" style="background-color: #E6E6E6">
                                    <tr>
                                        <th align="center">
                                            Siebel
                                        </th>
                                    </tr>
                                    <tr align="center">
                                        <td style="color: Gray">
                                            Total Contact:&nbsp;<asp:Label runat="server" ID="lbTotalSiebelContacts" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr valign="top">
                            <td>
                                <chartdir:WebChartViewer runat="server" ID="PieCustIntSeg" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td width="100%"><hr /></td></tr>
            <tr>
                <td style="width: 100%">
                    <table width="100%">
                        <tr valign="top">
                            <td>
                                <asp:UpdatePanel runat="server" ID="upIntProdContacts">
                                    <ContentTemplate>
                                        <asp:GridView runat="server" ID="gvCustIntProdCat" Width="100%" DataSourceID="srcCustIntProdCat"
                                            AutoGenerateColumns="false">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Product Group" HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center"
                                                    HeaderStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <asp:LinkButton runat="server" ID="lnkRowPG" Text='<%#Eval("Product Group")%>' OnClick="lnkRowPG_Click" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Contacts with Interested Product" HeaderStyle-HorizontalAlign="Center"
                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#FormatNumber(Eval("Contact Number"), 0)%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="srcCustIntProdCat" ConnectionString="<%$ConnectionStrings:MY %>" 
                                        SelectCommand="
                                        select a.PRODUCT_GROUP_DISPLAY_NAME as [Product Group], IsNull(COUNT(distinct c.EMAIL_ADDRESS),0) as [Contact Number]
                                        from (select a.INTERESTED_PRODUCT_DISPLAY_NAME, case when a.INTERESTED_PRODUCT_DISPLAY_NAME='Applied Computing Platforms' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Blade Computing Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='DSP Processing Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Network Application Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Self-service Solution' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='UbiQ Scenario Control' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Self-Service Touch Computer' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Industrial Mobile Computers' then 'Digital Logistics' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Industrial Portable Computers' then 'Digital Logistics' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Portable Computing Platforms' then 'Digital Logistics' when a.PRODUCT_GROUP_DISPLAY_NAME='Digital Logistics, Digital Retail & Hospitality' then 'Digital Retail & Hospitality' else a.PRODUCT_GROUP_DISPLAY_NAME end as PRODUCT_GROUP_DISPLAY_NAME from PIS_InterestedProduct_ProductGroup a) a inner join SIEBEL_CONTACT_INTERESTED_PRODUCT b 
                                        on a.INTERESTED_PRODUCT_DISPLAY_NAME=b.NAME inner join SIEBEL_CONTACT c on b.CONTACT_ROW_ID=c.ROW_ID 
                                        where c.EMAIL_ADDRESS like '%@%.%' and c.EMPLOYEE_FLAG<>'Y'  and c.ACTIVE_FLAG='Y' 
                                        group by a.PRODUCT_GROUP_DISPLAY_NAME
                                        order by a.PRODUCT_GROUP_DISPLAY_NAME" />

            <%--                            <asp:SqlDataSource runat="server" ID="srcCustIntProdCat" ConnectionString="<%$ConnectionStrings:MY %>" 
                                        SelectCommand="
                                        select a.Product_Group as [Product Group], COUNT(distinct c.EMAIL_ADDRESS) as [Contact Number]
                                        from CurationPool.dbo.LEADSFLASH_PRODUCTCATEGORY_INTERESTEDPRODUCT a inner join SIEBEL_CONTACT_INTERESTED_PRODUCT b 
                                        on a.Interested_Product=b.NAME inner join SIEBEL_CONTACT c on b.CONTACT_ROW_ID=c.ROW_ID 
                                        where c.EMAIL_ADDRESS like '%@%.%' and c.EMPLOYEE_FLAG<>'Y'  and c.ACTIVE_FLAG='Y' 
                                        group by a.Product_Group
                                        order by a.Product_Group" />
            --%>                            <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
                                            TargetControlID="PanelIntProdContacts" HorizontalSide="Center" VerticalSide="Middle" />
                                        <asp:Panel runat="server" ID="PanelIntProdContacts" Visible="false" Width="90%" Height="80%" ScrollBars="Auto"
                                            BackColor="#E6E6E6">
                                            <table width="100%">
                                                <tr>
                                                    <td align="right">
                                                        <asp:LinkButton runat="server" ID="lnkClose" Text="Close" OnClick="lnkClose_Click" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:GridView runat="server" ID="gvIntProdContacts" Width="90%" AutoGenerateColumns="false"
                                                            DataSourceID="srcIntProdContacts">
                                                            <Columns>
                                                                <asp:TemplateField HeaderText="Product Category" HeaderStyle-BackColor="#BBE0E3"
                                                                    ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <a>
                                                                            <%#Eval("Int Product")%></a>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="Contacts with Interested Product" HeaderStyle-HorizontalAlign="Center"
                                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <%#FormatNumber(Eval("Contact Number"), 0)%>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        <asp:SqlDataSource runat="server" ID="srcIntProdContacts" ConnectionString="<%$ConnectionStrings:MY %>" 
                                                            SelectCommand="
                                                            select a.INTERESTED_PRODUCT_DISPLAY_NAME as [Int Product], COUNT(distinct c.EMAIL_ADDRESS) as [Contact Number]
                                                            from (select a.INTERESTED_PRODUCT_DISPLAY_NAME, case when a.INTERESTED_PRODUCT_DISPLAY_NAME='Applied Computing Platforms' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Blade Computing Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='DSP Processing Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Network Application Platforms' then 'NCG' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Self-service Solution' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='UbiQ Scenario Control' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Self-Service Touch Computer' then 'Digital Retail & Hospitality' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Industrial Mobile Computers' then 'Digital Logistics' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Industrial Portable Computers' then 'Digital Logistics' when a.INTERESTED_PRODUCT_DISPLAY_NAME='Portable Computing Platforms' then 'Digital Logistics' when a.PRODUCT_GROUP_DISPLAY_NAME='Digital Logistics, Digital Retail & Hospitality' then 'Digital Retail & Hospitality' else a.PRODUCT_GROUP_DISPLAY_NAME end as PRODUCT_GROUP_DISPLAY_NAME from PIS_InterestedProduct_ProductGroup a) a inner join SIEBEL_CONTACT_INTERESTED_PRODUCT b 
                                                            on a.INTERESTED_PRODUCT_DISPLAY_NAME=b.NAME inner join SIEBEL_CONTACT c on b.CONTACT_ROW_ID=c.ROW_ID 
                                                            where c.EMAIL_ADDRESS like '%@%.%' and c.EMPLOYEE_FLAG<>'Y' and c.ACTIVE_FLAG='Y' and a.PRODUCT_GROUP_DISPLAY_NAME=@PG
                                                            group by a.INTERESTED_PRODUCT_DISPLAY_NAME
                                                            order by a.INTERESTED_PRODUCT_DISPLAY_NAME">
                                                            <SelectParameters>
                                                                <asp:Parameter ConvertEmptyStringToNull="false" Name="PG" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>

            <%--                                            <asp:SqlDataSource runat="server" ID="srcIntProdContacts" ConnectionString="<%$ConnectionStrings:MY %>" 
                                                            SelectCommand="
                                                            select a.Interested_Product as [Int Product], COUNT(distinct c.EMAIL_ADDRESS) as [Contact Number]
                                                            from CurationPool.dbo.LEADSFLASH_PRODUCTCATEGORY_INTERESTEDPRODUCT a inner join SIEBEL_CONTACT_INTERESTED_PRODUCT b 
                                                            on a.Interested_Product=b.NAME inner join SIEBEL_CONTACT c on b.CONTACT_ROW_ID=c.ROW_ID 
                                                            where c.EMAIL_ADDRESS like '%@%.%' and c.EMPLOYEE_FLAG<>'Y' and c.ACTIVE_FLAG='Y' and a.Product_Group=@PG
                                                            group by a.Interested_Product
                                                            order by a.Interested_Product">
                                                            <SelectParameters>
                                                                <asp:Parameter ConvertEmptyStringToNull="false" Name="PG" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
            --%>                                        </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                            <td valign="top">
                                <asp:UpdatePanel runat="server" ID="upOrgContacts">
                                    <ContentTemplate>
                                        <asp:GridView runat="server" ID="gvCustOrgCat" Width="100%" DataSourceID="srcCustOrgCat"
                                            AutoGenerateColumns="false" OnRowDataBound="gvCustOrgCat_RowDataBound">
                                            <Columns>
                                                <asp:TemplateField HeaderText="RBU" HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center"
                                                    HeaderStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <asp:LinkButton runat="server" ID="lnkRowOrg" Text='<%#Eval("RBU")%>' OnClick="lnkRowOrg_Click" />
                                                        <asp:Label runat="server" ID="lblRowOrg" Text='<%#Eval("RBU") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Total Contacts" HeaderStyle-HorizontalAlign="Center"
                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# FormatNumber(Eval("Total Number"), 0)%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Contacts with Interested Product" HeaderStyle-HorizontalAlign="Center"
                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#FormatNumber(Eval("Contact Number"), 0)%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Segmented %" HeaderStyle-HorizontalAlign="Center"
                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# Eval("SegmentedRate")%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="srcCustOrgCat" ConnectionString="<%$ConnectionStrings:MY %>" 
                                        SelectCommand="
                                        select a.RBU, a.[Total Number], b.[Contact Number], case when a.[Total Number]=0 or a.[Total Number] is null or b.[Contact Number] is null then '0%' else CAST(CAST(CAST(b.[Contact Number] as decimal(10,2))/CAST(a.[Total Number] as decimal(10,2))*100 as decimal(10,2)) as varchar)+'%' end as SegmentedRate from ( 
                                        select case when a.FLASHLEADS_RBU is null then 'Others' else a.FLASHLEADS_RBU end as [RBU], COUNT(distinct b.EMAIL_ADDRESS) as [Total Number] 
                                        from SIEBEL_CONTACT b left join CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU a on a.SIEBEL_RBU=b.OrgID
                                        where b.EMAIL_ADDRESS like '%@%.%' and b.EMPLOYEE_FLAG<>'Y'  and b.ACTIVE_FLAG='Y'
                                        group by a.FLASHLEADS_RBU) as a LEFT join 
                                        ( 
                                        select case when a.FLASHLEADS_RBU is null then 'Others' else a.FLASHLEADS_RBU end as [RBU], COUNT(distinct b.EMAIL_ADDRESS) as [Contact Number] 
                                        from SIEBEL_CONTACT b left join CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU a on a.SIEBEL_RBU=b.OrgID
                                        inner join SIEBEL_CONTACT_INTERESTED_PRODUCT c on b.ROW_ID=c.CONTACT_ROW_ID inner join PIS_InterestedProduct_ProductGroup d on c.NAME=d.INTERESTED_PRODUCT_DISPLAY_NAME
                                        where b.EMAIL_ADDRESS like '%@%.%' and b.EMPLOYEE_FLAG<>'Y'  and b.ACTIVE_FLAG='Y'
                                        group by a.FLASHLEADS_RBU) as b on a.RBU=b.RBU
                                        order by a.RBU" />

                                        <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender2" runat="server"
                                            TargetControlID="PanelOrgContacts" HorizontalSide="Center" VerticalSide="Middle" />
                                        <asp:Panel runat="server" ID="PanelOrgContacts" Visible="false" Width="90%" Height="80%" ScrollBars="Auto"
                                            BackColor="#E6E6E6">
                                            <table width="100%">
                                                <tr>
                                                    <td align="right">
                                                        <asp:LinkButton runat="server" ID="lnkClose1" Text="Close" OnClick="lnkClose1_Click" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:GridView runat="server" ID="gvOrgContacts" Width="90%" AutoGenerateColumns="false"
                                                            DataSourceID="srcOrgContacts">
                                                            <Columns>
                                                                <asp:TemplateField HeaderText="RBU" HeaderStyle-BackColor="#BBE0E3"
                                                                    ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <a>
                                                                            <%# Eval("RBU")%></a>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="Total Contacts" HeaderStyle-HorizontalAlign="Center"
                                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <%# FormatNumber(Eval("Total Number"), 0)%>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="Contacts with Interested Product" HeaderStyle-HorizontalAlign="Center"
                                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <%#FormatNumber(Eval("Contact Number"), 0)%>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="Segmented %" HeaderStyle-HorizontalAlign="Center"
                                                                    HeaderStyle-BackColor="#BBE0E3" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <%# Eval("SegmentedRate")%>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        <asp:SqlDataSource runat="server" ID="srcOrgContacts" ConnectionString="<%$ConnectionStrings:MY %>" 
                                                            SelectCommand="
                                                            select isnull(a.RBU,'NULL') as RBU, isnull(a.[Total Number],0) as [Total Number], isnull(b.[Contact Number],0) as [Contact Number], case when a.[Total Number]=0 or a.[Total Number] is null or b.[Contact Number] is null then '0%' else CAST(CAST(CAST(b.[Contact Number] as decimal(10,2))/CAST(a.[Total Number] as decimal(10,2))*100 as decimal(10,2)) as varchar)+'%' end as SegmentedRate from ( 
                                                            select a.SIEBEL_RBU as [RBU], COUNT(distinct a.EMAIL_ADDRESS) as [Total Number] from (
                                                            select a.SIEBEL_RBU, case when a.FLASHLEADS_RBU is null then 'Others' else a.FLASHLEADS_RBU end as FLASHLEADS_RBU, b.EMAIL_ADDRESS, b.EMPLOYEE_FLAG, b.ACTIVE_FLAG 
                                                            from SIEBEL_CONTACT b left join CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU a on a.SIEBEL_RBU=b.OrgID
                                                            where b.EMAIL_ADDRESS like '%@%.%' and b.EMPLOYEE_FLAG<>'Y' and b.ACTIVE_FLAG='Y') as a where a.FLASHLEADS_RBU =@RBU
                                                            group by a.SIEBEL_RBU) as a Left join
                                                            (
                                                            select a.SIEBEL_RBU as [RBU], COUNT(distinct a.EMAIL_ADDRESS) as [Contact Number] from (
                                                            select a.SIEBEL_RBU, case when a.FLASHLEADS_RBU is null then 'Others' else a.FLASHLEADS_RBU end as FLASHLEADS_RBU, b.EMAIL_ADDRESS, b.EMPLOYEE_FLAG, b.ACTIVE_FLAG 
                                                            from SIEBEL_CONTACT b left join CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU a on a.SIEBEL_RBU=b.OrgID
                                                            inner join SIEBEL_CONTACT_INTERESTED_PRODUCT c on b.ROW_ID=c.CONTACT_ROW_ID inner join PIS_InterestedProduct_ProductGroup d on c.NAME=d.INTERESTED_PRODUCT_DISPLAY_NAME
                                                            where b.EMAIL_ADDRESS like '%@%.%' and b.EMPLOYEE_FLAG<>'Y' and b.ACTIVE_FLAG='Y') as a where a.FLASHLEADS_RBU =@RBU
                                                            group by a.SIEBEL_RBU) as b on a.RBU=b.RBU
                                                            order by a.RBU">
                                                            <SelectParameters>
                                                                <asp:Parameter ConvertEmptyStringToNull="false" Name="RBU" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
