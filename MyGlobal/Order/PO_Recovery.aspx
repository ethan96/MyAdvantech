<%@ Page Title="MyAdvantech - PO Recovery" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If request("order_no") <> "" Then
                Me.Order_No.Text = request("order_no")
                DisplayOrderInfo()
            End If
        End If
    End Sub
    
    Protected Sub Query_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        DisplayOrderInfo()
    End Sub
    
    Protected Sub Recovery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strSoldtoID As String = ""
        Dim strOrderID As String = ""
        Dim strOrderNo As String = Trim(Me.Order_No.Text)
        
        Dim dtOrder As DataTable = dbUtil.dbGetDataTable("MY", "select ORDER_ID, SOLDTO_ID from ORDER_MASTER where ORDER_NO='" & strOrderNo & "'")
        
        If dtOrder.Rows.Count > 0 Then
            strOrderID = dtOrder.Rows(0).Item("ORDER_ID").ToString
            strSoldtoID = dtOrder.Rows(0).Item("SOLDTO_ID").ToString
        End If
        
        '==========    For PO    Added By Siaowei.Jhai    2006/12/20    ==========
        ' If strSoldtoID.Trim().ToUpper() = "AJPADV" Or strSoldtoID.Trim().ToUpper() = "AALP003" Or strSoldtoID.Trim().ToUpper() = "ASPA001" Then
        If MYSAPDAL.IsCreatePO(UCase(strSoldtoID.Trim)) Then
            Dim tempdt As DataTable = dbUtil.dbGetDataTable("MY", "select line_no from order_detail where order_id = '" & strOrderID & "' order by line_no desc")
            If tempdt.Rows.Count > 0 AndAlso tempdt.Rows(0).Item("line_no") >= 100 Then
                Dim retMsg As String = ""
                Dim result As Boolean
                'Me.Order_Utilities1.CreatePo(strOrderNo, retMsg, result)
                ' Dim objPO As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 PO_NO from ORDER_PO where ORDER_NO='{0}'", strOrderNo))
                'If objPO IsNot Nothing andalso objPO.ToString <> "" Then
                ' MYSAPDAL.CreatePo_Sap(strOrderNo, objPO.ToString, retMsg, result)
                MYSAPDAL.CreatePo(strOrderNo, strOrderNo, retMsg, result, True)
                '   End If
                
                DisplayErrMsg(retMsg, result)
            End If
        End If
        '==========    For PO    Added By Siaowei.Jhai    2006/12/20    ==========
        
        DisplayOrderInfo()
        'Response.Redirect("../order/PO_Recovery.aspx?Order_No=" & Trim(Me.Order_No.Text) & "")
    End Sub

    Protected Sub UpdateTop_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        '--Update the item in XML file (START)
        Dim xmlDoc As New System.Xml.XmlDocument
        Dim xmlNode As System.Xml.XmlNodeList = Nothing
        Dim subxmlNode As System.Xml.XmlNodeList = Nothing
        Dim tempXMLNode As System.Xml.XmlNode = Nothing
        
        Dim ordno As String = Me.Order_No.Text.Trim().ToUpper()
        Dim po_no As String = ""
        Dim dtPO As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 PO_NO, PO_XML from ORDER_PO where ORDER_NO='{0}'", ordno))
        If dtPO.Rows.Count > 0 Then
            po_no = dtPO.Rows(0).Item("PO_NO").ToString
            If po_no.Trim() = "" Then
                po_no = ordno
            End If
        
            xmlDoc.LoadXml(dtPO.Rows(0).Item("PO_XML").ToString)
            '//--Order Header

            '//--Order Detail
            xmlNode = xmlDoc.GetElementsByTagName("Order_Line")
            Dim j As Integer = 0
            While j <= xmlNode.Count - 1
                subxmlNode = xmlNode.Item(j).ChildNodes
                If Request("chkDelete$$$" & subxmlNode.Item(0).InnerText) = "Yes" Then
                    tempXMLNode = xmlNode.Item(j)
                    xmlNode.Item(j).ParentNode.RemoveChild(tempXMLNode)
                Else
                    j = j + 1
                End If
            End While
            
            dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PO set PO_XML=N'{0}'", ordno, po_no, xmlDoc.OuterXml.Replace("'", "''")))
            xmlDoc = Nothing
        End If
        
        '--Update the item in XML file (END)
        DisplayOrderInfo()
    End Sub
    
    
    Protected Sub UpdateBottom_Click(ByVal sender As Object, ByVal e As System.EventArgs)
  
        DisplayOrderInfo()
    End Sub
    

    
    Private Sub DisplayOrderInfo()
        Dim orderno As String = Me.Order_No.Text
        gvMaster.DataSource = dbUtil.dbGetDataTable("MY", String.Format("SELECT top  1 *  from  order_master where order_id ='{0}' ", orderno))
        gvMaster.DataBind()
        gvDetail.DataSource = MyOrderX.GetOrderListV2(orderno)
        gvDetail.DataBind()
    End Sub
        
    
    Protected Sub DisplayErrMsg(ByVal retXml As String, ByVal result As Boolean)
        
        If result = False Then
            If retXml <> "" Then
                Dim xRow As New TableRow
                Dim xCell As New TableCell
                xRow = New TableRow
                xCell = New TableCell
                xCell.Style.Value = "width:100%"
                xCell.Text = "&nbsp;+&nbsp;<font color=""red"" size=""3"">" & retXml & "</font>"
                xRow.Cells.Add(xCell)
                Me.ErrMsg.Rows.Add(xRow)
            Else
                Dim xRow As New TableRow
                Dim xCell As New TableCell
                xRow = New TableRow
                xCell = New TableCell
                xCell.Style.Value = "width:100%"
                xCell.Text = "&nbsp;+&nbsp;<font color=""red"" size=""3"">" & "Call SAP Function Error" & "</font>"
                xRow.Cells.Add(xCell)
                Me.ErrMsg.Rows.Add(xRow)
            End If
        Else
            
            Dim sr As New System.IO.StringReader(retXml)
            Dim ds As New DataSet
            ds.ReadXml(sr)
            Dim DT As New DataTable
            DT = ds.Tables("BAPIRET2Table")
 
        
            Dim xRow As New TableRow
            Dim xCell As New TableCell
        
            Dim i As Integer = 0
            While i <= DT.Rows.Count - 1
                If DT.Rows(i).Item("Type") <> "W" Then
                
                    xRow = New TableRow
                    xCell = New TableCell
                    xCell.Style.Value = "width:100%"
                    xCell.Text = "&nbsp;+&nbsp;<font color=""black"" size=""3"">" & DT.Rows(i).Item("NUMBER") & "&nbsp;>>>>>&nbsp;</font><font color=""red"" size=""3"">" & DT.Rows(i).Item("Message") & "</font>"
                    xRow.Cells.Add(xCell)
                    Me.ErrMsg.Rows.Add(xRow)
                
                End If
                i = i + 1
            End While
            
        End If

    End Sub
  
    Protected Sub ShowFailedOrderList_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("PO_Recovery.aspx")
    End Sub
    Dim myOrderMaster As New order_Master("b2b", "ORDER_MASTER")
    Dim myOrderDetail As New order_Detail("b2b", "ORDER_DETAIL")
    Protected Sub txtPartNo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim CustPN As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' AND LINE_NO='{1}'", Trim(Me.Order_No.Text), id), String.Format("PART_NO='{0}'", CustPN))
    End Sub

    Protected Sub chxDel_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As CheckBox = CType(sender, CheckBox)
        If obj.Checked Then
            Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
            Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
            myOrderDetail.Delete(String.Format("order_id='{0}' and line_no={1}", Trim(Me.Order_No.Text), id))
            myOrderDetail.reSetLineNoAfterDel(Trim(Me.Order_No.Text), id)
        End If
    End Sub

    Protected Sub txtPO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim PONO As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("PO_NO='{0}'", PONO))
    End Sub
    Protected Sub txtMSReqDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim ReqDate As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("REQUIRED_DATE='{0}'", ReqDate))
    End Sub
    Protected Sub txtPrice_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim price As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Trim(Me.Order_No.Text), id), String.Format("UNIT_PRICE='{0}'", price))
    End Sub

    Protected Sub txtQty_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim Qty As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Trim(Me.Order_No.Text), id), String.Format("qty='{0}'", Qty))
    End Sub

   
    Protected Sub txtDueDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim DueDate As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Trim(Me.Order_No.Text), id), String.Format("due_Date='{0}'", DueDate))
    End Sub

    Protected Sub txtReqDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim ReqDate As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Trim(Me.Order_No.Text), id), String.Format("required_Date='{0}'", ReqDate))
    End Sub

    Protected Sub txtShipTo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim shipto As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("shipto_id='{0}'", shipto))
    End Sub
    Protected Sub txtSoldTo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim shipto As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("soldto_id='{0}'", shipto))
    End Sub
    
    
    Sub Update() Handles btnUpdateUp.Click, btnUpdateDown.Click
        DisplayOrderInfo()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<table cellpadding="0" cellspacing="0" width="100%" id="Table2">
    
    <tr>
    <td class="euPageTitle" align="left">
        PO Recovery&nbsp;&nbsp;&nbsp;
    </td>
    </tr>
    <tr>
    <td height="2">
            &nbsp;
    </td>
    </tr>
    <tr>
    <td align="left">
        <!--form name="FormQuery" method="POST" action="Order_Recovery_sap.asp"-->
            &nbsp;&nbsp;&nbsp;<font color="#00008B" size="3"><b>Order&nbsp;NO:</b></font>&nbsp;<asp:TextBox runat="server" ID="Order_No" Width="100px"></asp:TextBox>
<%--                            &nbsp;&nbsp;<asp:Button runat="server" ID="ShowFailedOrderList" Text="ShowFailedOrderList" OnClick="ShowFailedOrderList_Click" />--%>
            &nbsp;&nbsp;<asp:Button runat="server" ID="Query" Text="Query" OnClick="Query_Click" />
            &nbsp;&nbsp;<asp:Button runat="server" ID="Recovery" Text="Recovery" OnClick="Recovery_Click" />
        <!--/form-->
        </td>
    </tr>
    <tr>
        <td height="2">
            <hr/>
        </td>
    </tr>

   
    <tr runat="server" id="trErrMsg">
        <td height="2" align="left">
            <table width="100%" border="0" cellspacing="0" cellspadding="0">
                <tr>
                <td style="padding-left:10px;border-bottom:#ffffff 1px solid" valign="middle" height="20" bgcolor="#6699CC">
  	                &nbsp;<font size=3 color="#ffffff"><b>Message</b></font>
                </td>
                </tr> 
  	            <tr>
  		        <td width="100%" valign="top" cellspacing="1" cellspadding="1" style="background-color:#bec4e3"> 
                    <asp:Table runat="server" ID="ErrMsg" Width="100%" CellPadding="1" CellSpacing="1" BackColor="#ffffff"></asp:Table>
                </td>
                </tr>  	                           
  	            <tr>
  	            <td height="5" bgcolor="#ffffff">
  	                &nbsp;
  	            </td>
  	            </tr>
  	        </table>
        </td>
    </tr>


     <tr><td colspan="2">

   <asp:GridView runat="server" ID="gvMaster" AutoGenerateColumns="false" AllowPaging="false"
        AllowSorting="true" Width="100%" EmptyDataText="No Order" DataKeyNames="Order_id">
        <Columns>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Order NO
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("order_no")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    PO NO
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPO" runat="server" Text='<%# IIf(String.IsNullOrEmpty(Eval("PO_no")), Eval("order_no"), Eval("PO_no"))%>' OnTextChanged="txtPO_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
               <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Sold To
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtSoldTo" runat="server" Text='<%# Eval("SoldTo_id")%>' OnTextChanged="txtSoldTo_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Ship To
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtShipTo" runat="server" Text='<%# Eval("shipto_id")%>' OnTextChanged="txtShipTo_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Order Date
                </HeaderTemplate>
                <ItemTemplate>
                    <%# CDate(Eval("Order_Date")).ToString("yyyy/MM/dd")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Required Date
                </HeaderTemplate>
                <ItemTemplate>
                <%--<%# CDate(Eval("Required_date")).ToString("yyyy/MM/dd")%>--%>
                         <asp:TextBox ID="txtMSReqDate" Width="80px" runat="server" Text='<%# cdate(Eval("Required_date")).tostring("yyyy/MM/dd")%>'
                        OnTextChanged="txtMSReqDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
  <div style="height:6px;"></div>
     <asp:Button runat="server" ID="btnUpdateUp" Text=" >> Update Header << " />    
<div style="height:10px;"></div>
    <asp:GridView runat="server" ID="gvDetail" AutoGenerateColumns="false" AllowPaging="false"
        AllowSorting="true" Width="100%" EmptyDataText="No Order" DataKeyNames="line_no">
        <Columns>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Index
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Container.DataItemIndex + 1%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Line No
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("Line_no")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Order No
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("Order_ID")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Item No
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPartNo" runat="server" Text='<%# Eval("part_no")%>' OnTextChanged="txtPartNo_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    QTY
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtQty" Width="30px" runat="server" Text='<%# Eval("Qty")%>' OnTextChanged="txtQty_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Price
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPrice" Width="80px" runat="server" Text='<%# Eval("unit_Price")%>'
                        OnTextChanged="txtPrice_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Req Date
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtReqDate" Width="80px" runat="server" Text='<%# cdate(Eval("required_date")).tostring("yyyy/MM/dd")%>'
                        OnTextChanged="txtReqDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Due Date
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtDueDate" Width="80px" runat="server" Text='<%# cdate(Eval("due_date")).tostring("yyyy/MM/dd")%>'
                        OnTextChanged="txtDueDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    Del
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:CheckBox runat="server" ID="chxDel" OnCheckedChanged="chxDel_CheckedChanged" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
      <div style="height:6px;"></div>
    <asp:Button runat="server" ID="btnUpdateDown" Text=" >> Update Detail<< " />

         </td></tr>

 

    
</table>
</asp:Content>

