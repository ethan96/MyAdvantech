<%@ Control Language="VB" ClassName="MyPriceList" %>

<script runat="server">
    Protected Sub PriceListSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        PriceListSrc.SelectParameters("PriceGrade").DefaultValue = dbUtil.dbExecuteScalar("B2B", "select top 1 price_class from company where company_id='" + Session("company_id") + "'")
        PriceListSrc.SelectParameters("currency").DefaultValue = dbUtil.dbExecuteScalar("B2B", "select top 1 CURRENCY  from company where company_id = '" & Session("company_id") & "' and company_type ='Partner'")
        e.Command.CommandTimeout = 300000
    End Sub

    Protected Sub PriceListGv_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim model_no As String = e.Row.Cells(0).Text.Replace("&nbsp;", "")
            If Not IsNothing(model_no) And model_no <> "" Then
                e.Row.Cells(12).Text = "<a target='_blank' href='http://my.advantech.eu/Product/ProductInfo.aspx?model_no=" + model_no + "&Lit_Id=y'>Datasheet(PDF)</a>"
            Else
                e.Row.Cells(12).Text = ""
            End If
            e.Row.Cells(6).Text = CInt(e.Row.Cells(6).Text).ToString + "%"
        End If
    End Sub

    Protected Sub btnPriceListExcel_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        PriceListGv.DataBind()
        PriceListGv.Export2Excel("Price List.xls")
    End Sub

    Protected Sub btnPriceListExcel2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PriceListGv.DataBind()
        PriceListGv.Export2Excel("Price List.xls")
    End Sub
</script>
<asp:UpdatePanel runat="server" ID="PriceListUp">
    <ContentTemplate>
        <asp:ImageButton runat="server" ID="btnPriceListExcel" ImageUrl="/Images/excel.gif" AlternateText="Export to Excel" OnClick="btnPriceListExcel_Click" />
        <asp:LinkButton runat="server" ID="btnPriceListExcel2" Text="Export to Excel" OnClick="btnPriceListExcel2_Click" />
        <sgv:SmartGridView runat="server" ID="PriceListGv" AllowSorting="true" AutoGenerateColumns="false"
             DataSourceID="PriceListSrc" ShowWhenEmpty="true" OnRowDataBoundDataRow="PriceListGv_RowDataBoundDataRow">
             <CaptionTemplate></CaptionTemplate>
             <Columns>
                <asp:BoundField HeaderText="Model No" DataField="Model No" SortExpression="Model No" />
                <asp:HyperLinkField HeaderText="Part No" DataNavigateUrlFields="Part No" DataNavigateUrlFormatString="http://aeu-ebus-dev:7000/Datamining/ProductProfile.aspx?PN={0}" DataTextField="Part No" Target="_blank" SortExpression="Part No" />
                <asp:BoundField HeaderText="Product Line" DataField="Product Line" SortExpression="Product Line" />
                <asp:BoundField HeaderText="Product Desc" DataField="Product Desc" SortExpression="Product Desc" />
                <asp:BoundField HeaderText="Currency" DataField="Currency" SortExpression="Currency" />
                <asp:BoundField HeaderText="List Price" DataField="List Price" SortExpression="List Price" ItemStyle-HorizontalAlign="Right" />
                <asp:BoundField HeaderText="Discount" DataField="Discount" SortExpression="Discount" ItemStyle-HorizontalAlign="Right" />
                <asp:BoundField HeaderText="Unit Price" DataField="Unit Price" SortExpression="Unit Price" ItemStyle-HorizontalAlign="Right" />
                <asp:BoundField HeaderText="Remark" DataField="Remark" SortExpression="Remark" />
                <asp:BoundField HeaderText="Rohs" DataField="Rohs" SortExpression="Rohs" />
                <asp:BoundField HeaderText="Class" DataField="Class" SortExpression="Class" />
                <asp:BoundField HeaderText="Product Group" DataField="Product Group" SortExpression="Product Group" />
                <asp:BoundField HeaderText="Datasheet" DataField="Model No" />
             </Columns>
             <FixRowColumn FixRowType="Header" TableWidth="95%" TableHeight="400px" FixRows="-1" FixColumns="-1" />
        </sgv:SmartGridView>
        <asp:SqlDataSource runat="server" ID="PriceListSrc" ConnectionString="<%$ connectionStrings:B2B %>" 
             SelectCommand="select [Model No], [Part No], [Product Line], [Product Desc], Currency,
                            convert(decimal(18,2),[List Price]) as [List Price], 
                            convert(decimal(18,2),Discount) as Discount, convert(decimal(18,2),[Unit Price]) as [Unit Price], 
                            Remark,  isnull(a.Rohs,'') as Rohs,isnull(a.Class,'') 
                            as Class,a.PRODUCT_GROUP as [Product Group]
                             from PRICING_TABLEV2 as P 
                            left join product as a on P.[Part No]=a.part_no  where 
                            P.CURCY_CD = @currency and P.GRADE_NAME = @PriceGrade and P.ORG = 'AESC'" OnSelecting="PriceListSrc_Selecting">
            <SelectParameters>
                <asp:Parameter Name="currency" Type="String" />
                <asp:Parameter Name="PriceGrade" Type="String" />
            </SelectParameters> 
        </asp:SqlDataSource>
    </ContentTemplate>
    <Triggers>
        <asp:PostBackTrigger ControlID="btnPriceListExcel" />
        <asp:PostBackTrigger ControlID="btnPriceListExcel2" />
    </Triggers>
</asp:UpdatePanel>
