<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Cart History Detail" %>

<%@ Import Namespace="SAPDAL" %>

<script runat="server">
    Dim CartId As String = String.Empty, currSin As String = String.Empty
    Dim _EWlist As List(Of EWPartNo) = Nothing, _IsAnyPhaseOutProd As Boolean = False
    Dim _ProductList As New List(Of ProductX)
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        currSin = Session("company_currency_sign")
        If Not IsPostBack Then
            Dim org As String = Session("org_id")
            _EWlist = MyCartX.GetExtendedWarranty()
            If Not IsNothing(Request("UID")) AndAlso Request("UID") <> "" Then
                CartId = Request("UID")
                Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)
                Dim _ProductX As New ProductX()
                For Each i As CartItem In _cartlist
                    _ProductList.Add(New ProductX(i.Part_No, org, i.Delivery_Plant))
                Next
                _ProductList = _ProductX.GetProductInfo(_ProductList, org, _IsAnyPhaseOutProd)
                GridView1.DataSource = _cartlist
                GridView1.DataBind()
            End If
        End If
    End Sub

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim str As String = String.Format("select line_no,category,part_no,Description,qty,list_price,unit_price,ew_flag,req_date,due_date from cart_DETAIL_V2 where cart_id='{0}' order by line_no", Request("UID"))
        Dim TB As DataTable = dbUtil.dbGetDataTable("B2B", str)
        Util.DataTable2ExcelDownload(TB, "MyCartHistory.xls")
    End Sub
    Dim strStatusCode As String = "", strStatusDesc As String = ""
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim _CartItem As CartItem = CType(e.Row.DataItem, CartItem)
            If _IsAnyPhaseOutProd Then
                Dim _currproductX = _ProductList.Where(Function(p) p.PartNo = _CartItem.Part_No).FirstOrDefault
                If _currproductX IsNot Nothing AndAlso _currproductX.IsPhaseOut Then
                        e.Row.Cells(2).Text = e.Row.Cells(2).Text + vbTab + "<span>Status [ " + _currproductX.StatusCode + " ]: " + _currproductX.StatusDesc+"</span>"
                    'e.Row.Cells(2).ForeColor = Drawing.Color.Red
                    End If
                'If _currproductX IsNot Nothing Then
                '    e.Row.Cells(2).Text = e.Row.Cells(2).Text + vbTab + "Status [ " + _currproductX.StatusCode + " ]: " + _currproductX.StatusDesc
                'End If
                End If
                If _CartItem.ItemTypeX = CartItemType.BtosParent Then
                    e.Row.BackColor = Drawing.Color.LightYellow
                    e.Row.Cells(4).Text = currSin + _CartItem.ChildSubListPriceX.ToString
                    e.Row.Cells(5).Text = currSin + _CartItem.ChildSubUnitPriceX.ToString
                Else
                    e.Row.Cells(4).Text = currSin + e.Row.Cells(4).Text
                    e.Row.Cells(5).Text = currSin + e.Row.Cells(5).Text
                End If
                Dim EWflag As Integer = 0
                If Integer.TryParse(e.Row.Cells(6).Text.Trim, 0) Then
                    EWflag = Integer.Parse(e.Row.Cells(6).Text.Trim)
                    Dim EXpartNo As EWPartNo = _EWlist.Where(Function(p) p.ID = EWflag).FirstOrDefault()
                    If EXpartNo IsNot Nothing Then
                        e.Row.Cells(6).Text = EXpartNo.EW_Month
                    Else
                        e.Row.Cells(6).Text = ""
                    End If
                End If
            End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <style>
        .Tnowrap {
            white-space: nowrap;
        }

            .Tnowrap span {
                color: tomato;
            }
    </style>
  <div>
        <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
            <tr valign="top">
                <td valign="top">
                    <table cellpadding="0" cellspacing="0" width="100%">
                        <tr valign="top">
                            <td>
                                <table width="100%" id="Table2">
                                    <tr valign="top">
                                        <td height="2">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td align="left">
                                            <div class="euPageTitle">
                                                Cart Detail</div>
                                            &nbsp;&nbsp;&nbsp;<span class="PageMessageBar"></span>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td height="2">
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle"
                                                id="Table1">
                                                <tr>
                                                    <td class="menu_title">
                                                        Shopping Cart History Detail<br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                <td>
                                                 <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download" OnClick="imgXls_Click" />
                                                </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:GridView DataKeyNames="line_no" runat="server" Width="100%" ID="GridView1" AutoGenerateColumns="false"
                                                     AllowPaging="false" OnRowDataBound="GridView1_RowDataBound">
                                                           <Columns>
                                                           <asp:BoundField DataField="line_no" HeaderText="Line No" />
                                                           <asp:BoundField DataField="Category" HeaderText="Category" />
                                                           <asp:BoundField DataField="part_no" HeaderText="Part No" ItemStyle-CssClass="Tnowrap" />
                                                           <asp:BoundField DataField="Qty" HeaderText="Qty"  ItemStyle-HorizontalAlign="Center"/>
                                                           <asp:BoundField DataField="List_Price" HeaderText="List Price" />
                                                           <asp:BoundField DataField="Unit_Price" HeaderText="Unit Price" />
                                                           <asp:BoundField DataField="Ew_flag" HeaderText="Extended Warranty Year"  ItemStyle-HorizontalAlign="Center"/>
                                                           <asp:BoundField DataField="req_date" HeaderText="Req. Date" DataFormatString="{0:yyyy/MM/dd}"/>
                                                           <asp:BoundField DataField="due_date" HeaderText="Due. Date" DataFormatString="{0:yyyy/MM/dd}"/>
                                                           </Columns>
                                                        </asp:GridView>
                                             <%--           <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
                                                        </asp:SqlDataSource>--%>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    
</asp:Content>
