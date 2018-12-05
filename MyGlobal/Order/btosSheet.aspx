<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myCompany As New SAP_Company("b2b", "sap_dimcompany")
    Dim myProduct As New SAPProduct("b2b", "sap_product")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Request("NO")) AndAlso Request("NO") <> "" Then
            initInterface()
        End If
    End Sub
    Sub initInterface()
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        If dtMaster.Rows.Count > 0 And dtDetail.Rows.Count > 0 Then
            Dim soldTo As String = dtMaster.Rows(0).Item("SOLDTO_ID")
            Dim shipTo As String = dtMaster.Rows(0).Item("SHIPTO_ID")
            Dim dtSoldTo As DataTable = myCompany.GetDT(String.Format("company_id='{0}'", soldTo), "")
            Dim dtshipTo As DataTable = myCompany.GetDT(String.Format("company_id='{0}'", shipTo), "")
            If dtSoldTo.Rows.Count > 0 And dtshipTo.Rows.Count > 0 Then
                Me.lbSoldTo.Text = dtSoldTo.Rows(0).Item("company_name") & "(" & dtSoldTo.Rows(0).Item("company_id") & ")"
                Me.lbCompanyCode.Text = dtSoldTo.Rows(0).Item("company_id")
            End If
            Dim SONO As String = ""
            If dtMaster.Rows(0).Item("ORDER_STATUS") <> "" Then
                SONO = dtMaster.Rows(0).Item("Order_ID")
            End If
            Me.lbOrderNo.Text = SONO
            Me.lbReqDate.Text = CDate(dtMaster.Rows(0).Item("Required_date")).ToString("yyyy/MM/dd")
            Me.lbShipDate.Text = CDate(dtMaster.Rows(0).Item("due_date")).ToString("yyyy/MM/dd")
            Me.lbPlacedBy.Text = dtMaster.Rows(0).Item("CREATED_BY")
           
        End If
        
        Me.gv1.DataSource = dtDetail
        Me.gv1.DataBind()
    End Sub
    Public Function getDescForPN(ByVal PN As String) As String
        Dim DTSAPPRODUCT As DataTable = myProduct.GetDT(String.Format("part_no='{0}'", PN), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then
            Return DTSAPPRODUCT.Rows(0).Item("Product_desc")
        End If
        Return ""
    End Function
    
    
    
    
    
    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim total As Decimal = myOrderDetail.getTotalAmount(Request("NO"))
        Me.lbTotal.Text = FormatNumber(total, 2)
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .mytable table
        {
            border-collapse: collapse;
            width:100%;
        }
        
        .mytable tr td
        {
            background: #ffffff;
            border: #cccccc 1px solid;
            padding: 2px;
            font-family: Arial;
            font-size:12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div id="divSheet" class="mytable">
    <table><tr><td align="left"><asp:Image runat="server" ID="imgLogo" ImageUrl="~/Images/logo.jpg" /></td>
    <td align="right"><b>CONFIGURATION & QC INSPECTION SHEET</b></td></tr></table>
    <hr />
    <table>
    <tr><td>SOLD TO:</td><td>
    <asp:label runat= "server" ID="lbSoldTo"></asp:label>
    </td><td>ORDER NO:</td><td>
    <asp:label runat= "server" ID="lbOrderNo"></asp:label>
    </td><td>SHIPPING DATE:</td><td>
    <asp:label runat= "server" ID="lbShipDate"></asp:label>
    </td></tr>
    <tr><td>COMPANY CODE:</td><td>
    <asp:label runat= "server" ID="lbCompanyCode"></asp:label>
    </td><td>Placed By:</td><td>
    <asp:label runat= "server" ID="lbPlacedBy"></asp:label>
    </td><td> REQUIRED DATE:</td><td>
    <asp:label runat= "server" ID="lbReqDate"></asp:label>
    </td></tr>
    </table>
    <br />

     <table width="100%">
            <tr>
                <td style="background-color: #ededed; font-weight: bold">
                    Purchased Products
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                        AllowSorting="true" Width="100%" EmptyDataText="No Order Line." DataKeyNames="line_no" OnDataBound="gv1_DataBound">
                        <Columns>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Seq.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Line No.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Line_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Category
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Cate")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Product
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Part_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Description
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# getDescForPN(Eval("PART_NO"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                       
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Qty.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Qty")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                           
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
            <tr><td align="right"> Total：<%= HttpContext.Current.Session("company_currency_sign")%><asp:Label runat="server" ID="lbTotal"></asp:Label></td></tr>
        </table>

    </div>

    </form>
</body>
</html>
