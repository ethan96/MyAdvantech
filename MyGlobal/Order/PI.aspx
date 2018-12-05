<%@ Page Title="MyAdvantech–Proforma Invoice Preview" EnableEventValidation="false" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myFailedOrder As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS2")
  
    Public Function getMassage() As String
        Dim isSimulate As Boolean = False
        If Request("NO").ToString.Length > 15 Then
            isSimulate = True
        End If
        If Util.IsInternalUser2() Then
            Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
            Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(Request("NO"))
            If ordermasterDT.Rows.Count > 0 Then
                Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
                If Not IsDBNull(ordermasterDR.ORDER_STATUS) AndAlso ordermasterDR.ORDER_STATUS.ToString.Equals("FINISH", StringComparison.OrdinalIgnoreCase) Then
                    Return ""
                End If
            End If
            Dim mm As String = ""
            Dim Message_DT As DataTable = myFailedOrder.GetDT(String.Format("order_no='{0}'", Request("NO")), "LINE_SEQ")
            If Message_DT.Rows.Count > 0 Then
                Dim j As Integer = 0
                While j <= Message_DT.Rows.Count - 1
                    If Message_DT.Rows(j).Item("NUMBER") <> "311" And Message_DT.Rows(j).Item("NUMBER") <> "233" Then
                        mm &= "<font color=""red"">&nbsp;&nbsp;+&nbsp;" & Message_DT.Rows(j).Item("MESSAGE") & "</font>"
                        mm &= "<br/>"
                    End If
                    j = j + 1
                End While
                If isSimulate Then
                    myFailedOrder.Delete(String.Format("order_no='{0}'", Request("NO")))
                End If
            End If
            Return mm.Replace(Request("NO"), "SO")
        End If
        Return ""
    End Function
    Public Function SetOrder_Master_Extension(ByVal OrderNo As String) As Integer
        Dim PI2CUSTOMER_FLAG As Integer = 1
        If CBPI2Customer.Checked = True Then
            PI2CUSTOMER_FLAG = 0
        End If
        Dim myorder_Master_Extension As New order_Master_Extension("b2b", "order_Master_Extension")
        myorder_Master_Extension.Add(OrderNo, PI2CUSTOMER_FLAG)
        Return 1
    End Function
    '<System.Web.Services.WebMethod()> _
    Public Function PlaceOrder(ByVal OrderNo As String) As String
        Dim myOrderMaster As New order_Master("b2b", "order_master"), myOrderDetail As New order_Detail("b2b", "order_detail")
        Dim myFt As New Freight("b2b", "Freight"), ret As Boolean = False, ErrMsg As String = "", old_id As String = OrderNo, order_no As String = old_id
        Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", OrderNo), "")
        If DT.Rows.Count > 0 AndAlso DT.Rows(0).Item("ORDER_STATUS") = "" Then
            order_no = SAPDOC.getOrderNumberOracle(old_id)
            If order_no <> "" And order_no <> old_id Then
                myOrderMaster.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}',ORDER_STATUS='TEMP',order_No='{0}'", order_no))
                myOrderDetail.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}'", order_no))
                myFt.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}'", order_no))
                Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
                A.UpdateOrderID(order_no, old_id)
                SetOrder_Master_Extension(order_no)
                '20121012 Ming CreateSAPQuote
                Dim Quote_Id As String = "" 
                Dim CQuoteret As Boolean = False
                Try
                    If AuthUtil.IsUSAonlineSales(Session("user_id")) AndAlso myOrderDetail.isQuoteOrder(order_no, Quote_Id) Then
                        If Not String.IsNullOrEmpty(Quote_Id) Then
                            Dim SAPQlogA As New MyOrderDSTableAdapters.CreateSAPQuoteLogTableAdapter
                            SAPQlogA.Insert(order_no, Quote_Id, Now)
                            If Quote_Id.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) OrElse Quote_Id.StartsWith("AMXQ", StringComparison.CurrentCultureIgnoreCase) Then
                                If MYSAPDAL.checkSAPQuote(Quote_Id) = False Then
                                    CQuoteret = SAPDOC.SOCreateV5(order_no, ErrMsg, False, Quote_Id, True)
                                End If
                            End If
                        End If
                    End If
                Catch ex As Exception
                    Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Create SAP Quote Failed.", ex.ToString, True, "", "")
                End Try
                Dim dtMsg As New DataTable
                If CQuoteret Then
                    For i As Integer = 0 To 3
                        If MYSAPDAL.checkSAPQuote(Quote_Id) Then
                            Exit For
                        End If
                        If i = 3 Then
                            Quote_Id = ""
                            Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Find SAP Quote Failed.", "", True, "", "")
                            Exit For
                        End If
                        Threading.Thread.Sleep(1000)
                    Next
                Else
                    If MYSAPDAL.checkSAPQuote(Quote_Id) = False Then
                        Quote_Id = ""
                    End If
                End If
                ret = SAPDOC.SOCreateV5(order_no, ErrMsg, False, Quote_Id)
                If ret Then
                    SAPDOC.ProcessAfterOrderSuccess(order_no, ErrMsg)
                    ' 201208022 Ming: delete old data for cart and create new cartid and orderid
                    AuthUtil.SetOrderid(old_id)
                    
                    '20130729 Rudy: Create PO when company id is AJPADV, or AALP003, or ASPA001
                    If UCase(Session("COMPANY_ID")) = "AJPADV" Or UCase(Session("COMPANY_ID")) = "AALP003" Or UCase(Session("COMPANY_ID")) = "ASPA001" Then
                        If BtosOrderCheck(order_no) = 1 Then
                            Dim retMsg As String = "", pono As String = ""
                            Dim result As Boolean
                            'Create PO XML
                            'MYSAPDAL.CreatePo(order_no, pono, retMsg, result)
                            ''PO XML to SAP
                            'MYSAPDAL.CreatePo_Sap(order_no, pono, retMsg, result)
                            ''Send Mail 
                            'MYSAPDAL.PO_SendMail(order_no, pono, retMsg, result)
                        End If
                    End If
                    
                    ' 20120801 Ming: Update SO ShipTo Attention
                    Dim retTable As New DataTable : Dim IsSAPProductionServer As Boolean = True
                    If Util.IsTesting() Then
                        IsSAPProductionServer = False
                    End If
                    If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                        Dim OrderPartnerdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(order_no)
                        Dim FirstRow As MyOrderDS.ORDER_PARTNERSRow = OrderPartnerdt.Select("TYPE='S'").FirstOrDefault()
                        If FirstRow IsNot Nothing AndAlso Not String.IsNullOrEmpty(FirstRow.ERPID) AndAlso Not String.IsNullOrEmpty(order_no) Then
                            With FirstRow
                                MYSAPBIZ.UpdateSAPSOShipToAttentionAddress(order_no, .ERPID, .NAME, .ATTENTION, .STREET, _
                                                                           .STREET2, .CITY, .STATE, .ZIPCODE, .COUNTRY, .TAXJURI, retTable, IsSAPProductionServer)
                            End With
                        End If
                        '20120816 Ming: Update SO Zero Price Items
                        Threading.Thread.Sleep(1000)
                        MYSAPBIZ.UpdateSOZeroPriceItems(order_no, retTable)
                        '20120816 TC: If Early ship is not allowed, update it on SAP SO
                        Dim aptOrderMaster As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
                        If aptOrderMaster.GetEarlyShipOption(order_no) = 0 Then
                            Dim dtReturn As DataTable = Nothing
                            Threading.Thread.Sleep(2000)
                            If Not MYSAPBIZ.UpdateSOSpecId(order_no, EnumSetting.EarlyShipmentSetting.Early_Shipment_Not_Allowed, dtReturn) Then
                                '20120816 TC: should log this failure and inform IT
                            End If
                        End If
                    End If
                    'end
                    Dim quoteId As String = ""
                    If myOrderDetail.isQuoteOrder(order_no, quoteId) Then
                        Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
                        Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(order_no)
                        If ordermasterDT.Rows.Count > 0 Then
                            Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
                            With ordermasterDR
                                Dim quote_to_order_logDT As New quote.EQDS.QUOTE_TO_ORDER_LOGDataTable
                                Dim quote_to_order_logDR As quote.EQDS.QUOTE_TO_ORDER_LOGRow = quote_to_order_logDT.NewQUOTE_TO_ORDER_LOGRow()
                                quote_to_order_logDR.PO_NO = .PO_NO
                                quote_to_order_logDR.SO_NO = .ORDER_NO
                                quote_to_order_logDR.QUOTEID = quoteId
                                quote_to_order_logDR.ORDER_DATE = .CREATED_DATE
                                quote_to_order_logDR.ORDER_BY = .CREATED_BY
                                quote_to_order_logDT.Rows.Add(quote_to_order_logDR)
                                quote_to_order_logDT.AcceptChanges()
                                Dim WS As New quote.quoteExit : WS.Timeout = -1
                                If Util.IsTesting() Then
                                    WS.Url = "http://eq.advantech.com:8100/Services/QuoteExit.asmx"
                                End If
                                WS.WriteQuoteToOrderLog(quote_to_order_logDT)
                            End With
                        End If
                    End If
                Else
                    If Not Util.IsTesting() Then
                        SAPDOC.ProcessAfterOrderFailed(order_no, ErrMsg)
                    End If
                    Glob.ShowInfo(ErrMsg)
                    'OrderUtilities.showDT(dtMsg)
                End If
              
            End If
        End If
        Return order_no
    End Function
    
    Function BtosOrderCheck(ByVal Order_No As String) As Integer
        Dim myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no >= 100", Order_No), "line_No")
        If dtDetail.Rows.Count > 0 Then
            BtosOrderCheck = 1
        Else
            BtosOrderCheck = 0
        End If
    End Function
    
    Function SiteDefinition_Get(ByVal szSite_Parameter, ByRef szPara_Value) As String
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
        "select Site_Parameter,Para_Value from SITE_DEFINITION where Site_Parameter=" & "'" & szSite_Parameter & "'")
        If dt Is Nothing Then
            Return ""
            Exit Function
        End If
        If dt.Rows.Count = 0 Then
            Return ""
            Exit Function
        End If
        szPara_Value = dt.Rows(0).Item("Para_Value").ToString()
        Return 1
        
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Util.IsTestingQuote2Order() Then
                Response.Redirect(String.Format("PIV2.aspx{0}", Request.Url.Query))
            End If
            If MailUtil.IsInRole("Aonline.USA") Then
                CBPI2Customer.Checked = True : trTermConditionContent.Visible = False
            Else
                CBPI2Customer.Checked = False
            End If
            If Util.IsInternalUser2() Then
                Me.trPI2In.Visible = True : TandC_Button.SelectedIndex = 0
            End If
            btnOrder.Enabled = IIf(SAPDOC.ISRBU(Session("company_id")) = True, False, True)
            Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
            If DT.Rows.Count > 0 Then
                If DT.Rows(0).Item("ORDER_STATUS") = "" Or myOrderDetail.IsExists(String.Format("order_id='{0}'", Request("NO"))) = 1 Then
                    Me.btnOrder.Visible = True : Me.TCtb.Visible = True
                End If
                If MailUtil.IsInRole("Aonline.USA") Then
                    SAPDOC.SOCreateV5(Request("NO"), "", True)
                End If
                If DT.Rows(0).Item("ORDER_STATUS") = "TEMP" Then
                    If Not Util.IsInternalUser2() Then
                        Me.lbThanks.Text = "Thanks for Order: " & Request("NO") & "."
                        Me.lbThanks.ForeColor = Drawing.Color.Green
                        Me.lbThanks.Font.Bold = True
                    Else
                        ' Me.lbThanks.Text = "Order: " & Request("NO") & " NOT SUCCESS"
                        Me.lbThanks.Text = "MyAdvantech failed to sync this order to SAP due to following reason:"
                        Me.lbThanks.ForeColor = Drawing.Color.Red
                        Me.lbThanks.Font.Bold = True
                    End If
                ElseIf DT.Rows(0).Item("ORDER_STATUS") = "FINISH" Then
                    Me.lbThanks.Text = "Thanks for Order: " & Request("NO") & "."
                    Me.lbThanks.ForeColor = Drawing.Color.Green
                    Me.lbThanks.Font.Bold = True
                    Me.btnOrder.Visible = False
                    Me.TCtb.Visible = False
                End If
                
                'GETORDERINFO(Request("NO"))
            End If
                
            GETORDERINFO(Request("NO"))
            If OrderUtilities.IsDirect2SAP() Then
                If Not Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    Me.btnOrder_Click(Me.btnOrder, Nothing)
                End If
            End If
        End If
    End Sub
    
    Protected Sub GETORDERINFO(ByVal ORDERNO As String)
        Dim customerBlock As String = "", orderBlock As String = "", detailBlock As String = ""
        Dim url As String = ""
        url = "PI_AEU.aspx?NO=" & ORDERNO
        Dim MyDOC As New System.Xml.XmlDocument
        Global_Inc.HtmlToXML(url, MyDOC)
        'Global_Inc.getXmlBlockByID("div", "divCustInfo", MyDOC, customerBlock)
        'Global_Inc.getXmlBlockByID("div", "divOrderInfo", MyDOC, orderBlock)
        Global_Inc.getXmlBlockByID("div", "divDetailInfo", MyDOC, detailBlock)
        Me.lb_Cust.Text = Util.GetAscxStr(ORDERNO, 0)
        Me.lb_Order.Text = Util.GetAscxStr(ORDERNO, 1)
        Me.lb_Detail.Text = detailBlock
    End Sub

   
    
    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If SAPDOC.ISRBU(Session("company_id")) Then
            Glob.ShowInfo("Order cannot be placed via Sales Offices.") : Exit Sub
        End If
        Dim ORDERNO As String = PlaceOrder(Request("NO"))
        If OrderUtilities.IsDirect2SAP() Then
            Session.Contents.Remove("Direct2SAP")
        End If
        Response.Redirect("~/order/pi.aspx?NO=" + ORDERNO)
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css" id="Sty" runat="server">
        .mytable table
        {
            width: 100%;
            border-collapse: collapse;
        }
        
        .mytable tr td
        {
            background: #ffffff;
            border: #cccccc 1px solid;
            padding: 2px;
            font-family: Arial;
            font-size: 12px;
        }
    </style>
    <table width="100%">
        <tr>
            <td align="left">
                <asp:Label runat="server" ID="lbThanks"></asp:Label>
                <br />
                <%= getMassage()%>
            </td>
            <td align="right">
                <table>
                    <tr>
                        <td>
                            <a href="#" onclick="DoPrint()">Print</a>
                        </td>
                        <td>
                            |
                        </td>
                        <td>
                            <asp:HyperLink runat="server" ID="hlHome" Text="Home" NavigateUrl="~/home.aspx"></asp:HyperLink>
                        </td>
                        <td>
                            |
                        </td>
                        <td>
                            <asp:HyperLink runat="server" ID="hlNew" Text="New Order" NavigateUrl="~/order/Cart_list.aspx"></asp:HyperLink>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <asp:Label runat="server" ID="lb_Cust" CssClass="mytable"></asp:Label>
    <asp:Label runat="server" ID="lb_Order" CssClass="mytable"></asp:Label>
    <asp:Label runat="server" ID="lb_Detail" CssClass="mytable"></asp:Label>
    <table valign="top" align="center" id="TCtb" runat="server" visible="false" width="100%">
        <tr>
            <td height="25px" id="trPI2In" align="center" runat="server" visible="false">
                <asp:CheckBox ID="CBPI2Customer" runat="server" Checked="true" />
                <strong style="color: Red;">PI to internal only</strong>
            </td>
        </tr>
        <tr runat="server" id="trTermConditionContent">
            <td height="233px" valign="top" align="center">
                <iframe style="border: 0; border-color: #D4D0C8" frameborder="0" scrolling="no" id="my_Iframe"
                    runat="server" name="Terms_Condition" width="898" height="335px" src="./Terms_Conditions.aspx">
                </iframe>
            </td>
        </tr>
        <tr>
            <td align="center" height="15px">
                <asp:RadioButtonList ID="TandC_Button" runat="server" RepeatDirection="Horizontal" Font-Bold="true">
                    <asp:ListItem Value="Y" Text="I Accept" />
                    <asp:ListItem Value="N" Selected="true" Text="I DO NOT Accept" />
                </asp:RadioButtonList>
            </td>
        </tr>
    </table>
    <div id="warndiv" style="font-size: 12px; color: #FF0000">
    </div>
    <table width="100%">
        <tr>
            <td align="center">
                <asp:Button runat="server" ID="btnOrder" Text=" >> Confirm Order << " Visible="false"
                    OnClientClick="return getOpty(this)" OnClick="btnOrder_Click" />
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function getOpty(O) {
            //ming add
            document.getElementById('warndiv').innerHTML = "";
            var SPAN_RB = document.getElementById('<%=Me.TandC_Button.ClientID%>');
            if (SPAN_RB) {
                var radioButtonList = SPAN_RB.getElementsByTagName('input');
                for (var i = 0; i < radioButtonList.length; i++) {
                    if (radioButtonList.item(i).checked && radioButtonList.item(i).value == 'N') {
                        document.getElementById('warndiv').innerHTML = "Please accept Terms and Conditions, or contact Advantech for further request.";
                        return false;
                    }
                }
            }
            ShowDIV('DialogDiv');
            return true;
            //end
            //            O.value = " >> Waiting... << "
            //            O.disabled = true;
            //            var t = '<%=Request("NO") %>'
            //            PageMethods.PlaceOrder(t, onS, onF, O);
        }
        //        function onS(result, O) {
        //            location.href = "/order/pi.aspx?NO=" + result
        //        }
        //        function onF(result, O) {
        //            location.href = "/order/pi.aspx?NO=" + result
        //        }


        function DoPrint() {
            var obj0 = document.getElementById('<%=Me.Sty.ClientID%>');
            var obj1 = document.getElementById('<%=Me.lb_Cust.ClientID%>');
            var obj2 = document.getElementById('<%=Me.lb_Order.ClientID%>');
            var obj3 = document.getElementById('<%=Me.lb_Detail.ClientID%>');

            var text0 = obj0.outerHTML;
            var text1 = obj1.innerHTML;
            var text2 = obj2.innerHTML;
            var text3 = obj3.innerHTML;
            document.open();
            document.write("");
            document.write(text0 + text1 + text2 + text3);
            document.close();
            print();
            window.location.href = window.location.href;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <script src="../Includes/jquery.min.js" type="text/javascript"></script>    <style type="text/css"  >      
      #BgDiv{background-color:#000; position:absolute; z-index:99; left:0; top:0; display:none; width:100%; height:1000px;opacity:0.5;filter: alpha(opacity=50);-moz-opacity: 0.5;}
      #DialogDiv{position:absolute;width:600px; left:50%; top:50%;  margin-left:-300px;margin-top:-63px;height:125px; z-index:100;background-color:#fff; border:4px #BF7A06 solid; padding:1px;}
      #DialogDiv .form{padding:10px; line-height:20px; font-weight:bold; color:Black;}
  </style>
  <script language="javascript" type="text/javascript">
      function ShowDIV(thisObjID) {
          $("#BgDiv").css({ display: "block", height: $(document).height() });
          var divId = document.getElementById(thisObjID);
          divId.style.top = ((document.body.clientHeight - divId.clientHeight) / 2 + document.body.scrollTop / 2) + "px";
          $("#" + thisObjID).css("display", "block");
      }
 </script>
  <div id="BgDiv"></div>
  <div id="DialogDiv" style="display:none">
   <div class="form">Your order is being processed and may take several seconds. Please do not close or refresh this page, or your order may not be processed successfully, thank you.
    <br />
    <asp:Image runat="server" ID="imgMasterLoad" ImageUrl="~/Images/LoadingRed.gif" />
    <b>Loading ...</b>
   </div>
  </div>
</asp:Content>
