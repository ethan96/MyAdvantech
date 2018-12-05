<%@ Control Language="VB" ClassName="CustWarrantyItem" %>
<%@ Register Src="~/Includes/Xml2Gv.ascx" TagName="Xml2Gv" TagPrefix="uc1" %>
<script runat="server">
    Public ReadOnly Property AllSN() As ArrayList
        Get
            If ViewState("asn") IsNot Nothing Then
                Return ViewState("asn")
            Else
                ViewState("asn") = New ArrayList
                Return ViewState("asn")
            End If
        End Get
    End Property
    Public Property CustId() As String
        Get
            Return src1.SelectParameters("CN").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("CN").DefaultValue = value
            src1.SelectCommand = src1.SelectCommand + " and a.customer_no in (" + value + ") order by a.warranty_end_date "
        End Set
    End Property
    Public Property WFrom() As Date
        Get
            Return CDate(src1.SelectParameters("FROM").DefaultValue)
        End Get
        Set(ByVal value As Date)
            src1.SelectParameters("FROM").DefaultValue = CDate(value).ToString("yyyy-MM-dd")
        End Set
    End Property
    Public Property WTo() As Date
        Get
            Return CDate(src1.SelectParameters("TO").DefaultValue)
        End Get
        Set(ByVal value As Date)
            src1.SelectParameters("TO").DefaultValue = CDate(value).ToString("yyyy-MM-dd")
        End Set
    End Property
    Public Property CustEMail() As String
        Get
            Return ViewState("cemail")
        End Get
        Set(ByVal value As String)
            ViewState("cemail") = value
        End Set
    End Property
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim rsn As Xml2Gv = e.Row.FindControl("sn1")
            If rsn IsNot Nothing AndAlso rsn.srcdb.Rows.Count > 0 Then
                Dim rsnlist As New ArrayList
                For Each r As DataRow In rsn.srcdb.Rows
                    AllSN.Add(r.Item(0).ToString()) : rsnlist.Add(r.Item(0).ToString())
                Next
                e.Row.Cells(e.Row.Cells.Count - 1).Text = String.Format( _
               "http://support.advantech.com.tw/extendedwarranty/ewproductlist.aspx?" + _
               "Uid={0}&txtPartNo={1}&utm_source=advcust&utm_medium=email&" + _
               "utm_campaign=edm12112008&PromotionCode=EW-200812&Snlist={2}", _
               CustEMail, DataBinder.Eval(e.Row.DataItem, "part_no").ToString(), String.Join(",", rsnlist.ToArray(GetType(String))))
            Else
                'e.Row.Visible = False
            End If
           
        End If
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 350
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        'lbMsg.Text = String.Join(",", AllSN.ToArray(GetType(String)))
        For Each gr As GridViewRow In gv1.Rows
            If gr.RowType = DataControlRowType.DataRow Then
                gr.Cells(gr.Cells.Count - 1).Text = String.Format("<a href='{0}&Ssnlist={1}'>Go</a>", gr.Cells(gr.Cells.Count - 1).Text, String.Join(",", AllSN.ToArray(GetType(String))))
            End If
        Next
    End Sub
</script>
<table width="100%">
    <tr>
        <td>           
            <asp:GridView Width="97%" runat="server" ID="gv1" DataSourceID="src1" AutoGenerateColumns="false" OnRowDataBound="gv1_RowDataBound" OnDataBound="gv1_DataBound">
                <Columns>                    
                    <asp:BoundField HeaderText="PO No." DataField="po_no" SortExpression="" />
                    <asp:HyperLinkField HeaderText="Part No." DataTextField="part_no" 
                        DataNavigateUrlFields="model_no" DataNavigateUrlFormatString="http://my.advantech.eu/Product/Model_Detail.aspx?model_no={0}" Target="_blank" />                   
                    <asp:BoundField HeaderText="Qty." DataField="qty" SortExpression="" ItemStyle-HorizontalAlign="Center"/>
                    <asp:TemplateField HeaderText="Warranty Expire Date" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%#CDate(Eval("warranty_end_date")).ToString("yyyy-MM-dd")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="S/N">
                        <ItemTemplate>
                            <uc1:Xml2Gv runat="server" ID="sn1" InputXml='<%#Eval("SN") %>' ShowHeader="false" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Buy On Line" ItemStyle-HorizontalAlign="Center" />
                </Columns>
            </asp:GridView> 
            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:RFM %>" 
                SelectCommand="
                select top 100 
                (select top 1 po_no from sap_order_log b where b.order_no=a.so_no) as po_no, 
                case a.IsCTOS when 0 then a.part_no when 1 then IsNull((select top 1 b.part_no from ctos_order_log b where b.order_no=a.so_no),'') end as part_no,
                IsNull((select top 1 b.model_no from sap_product b where b.part_no=a.part_no),'') as model_no,
                a.qty, a.warranty_end_date,
                (select serial_number as [s/n] from sfis where warranty_year between year(@FROM) and year(@TO) and container_no=a.so_no and key_part_no=a.part_no for xml path('')) as SN
                from rma_customer_warranty a where a.warranty_end_date between @FROM and @TO " OnSelecting="src1_Selecting">
                <SelectParameters>
                    <asp:Parameter ConvertEmptyStringToNull="false" Name="CN" Type="String" />
                    <asp:Parameter ConvertEmptyStringToNull="false" Name="FROM" Type="String" />
                    <asp:Parameter ConvertEmptyStringToNull="false" Name="TO" Type="String" />
                </SelectParameters>
            </asp:SqlDataSource>
        </td>
    </tr>
</table>

                    