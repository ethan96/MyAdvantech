<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Cart History" %>

<%@ Import Namespace="SAPDAL" %>

<script runat="server">
    Dim mycart As New CartList("b2b", "cart_detail")
    Dim myCartHistory As New cart_history("b2b", "cart_history")
    Dim org As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        org = Session("org_id")
        Dim str As String = String.Format("select * from {0} where company_id='{1}' and description<>'Auto Approved' and Cart_Status = '1' order by CREATED_ON DESC", myCartHistory.tb, Session("company_id"))
        Me.SqlDataSource1.SelectCommand = str
    End Sub

   
    Protected Sub GVbtnDetail_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        Response.Redirect("~/Order/cartHistory_detail.aspx?UID=" & id)
    End Sub
    Protected Sub cartHistory2Quotation(ByVal ID As String)
        'Dim isRptOrder As Integer = 0
        'isRptOrder = dtCH.Rows(0).Item("oStatus")
        'Dim ws As New quote.quoteExit
        'ws.Timeout = -1
        'Dim quoteId As String = ws.toQuotation(Session("company_id"), Session("user_id"), Util.ReplaceSQLStringFunc(dtCH.Rows(0).Item("description")), "", isRptOrder, Session("org_Id"), detail.ToArray)
        'ws.Dispose()
        'If quoteId <> "" Then
        '    Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/QuotationMaster.aspx?UID={0}", quoteId))
        '    Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
        'End If
        Dim _currErpid As String = Session("company_id"), _orgid As String = Session("org_Id")
        Dim SAPcompanyDT As DataTable = SAPDAL.SAPDAL.GetCompanyDataFromLocal(_currErpid, _orgid)
        If SAPcompanyDT.Rows.Count <= 0 Then Glob.ShowInfo("Invalid Erpid.") : Exit Sub
        Dim myCH As New cart_history("B2B", "cart_history")
        Dim dtCH As DataTable = myCH.GetDT(String.Format("cart_id='{0}'", ID), "")
        If dtCH.Rows.Count = 0 Then Glob.ShowInfo("Invalid History Record.") : Exit Sub
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(ID)
        If _cartlist.Count = 0 Then Glob.ShowInfo("No Item Be Added.") : Exit Sub
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", MYSIEBELDAL.GET_Account_info_By_ERPID(_currErpid))
        If dt.Rows.Count <= 0 Then Glob.ShowInfo("Invalid Erpid.") : Exit Sub
        Dim _AccountRowid As String = dt.Rows(0).Item("Row_ID")
        Dim strGETRBU As String = MYSIEBELDAL.GetRBUFromAccountID(_AccountRowid)
        Dim isRptOrder As Integer = 0 : isRptOrder = dtCH.Rows(0).Item("oStatus")
        Dim _QuoteMaster As New QuotationMaster
        Dim _Quotelist As New List(Of QuotationDetail)
        _QuoteMaster.quoteId = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 15)
        _QuoteMaster.quoteNo = ""
        _QuoteMaster.quoteToRowId = _AccountRowid
        _QuoteMaster.customId = Util.ReplaceSQLStringFunc(dtCH.Rows(0).Item("description"))
        _QuoteMaster.quoteToErpId = _currErpid
        _QuoteMaster.quoteToName = dt.Rows(0).Item("COMPANYNAME")
        _QuoteMaster.org = _orgid
        _QuoteMaster.siebelRBU = strGETRBU
        _QuoteMaster.currency = SAPcompanyDT.Rows(0).Item("CURRENCY")
        _QuoteMaster.salesEmail = getPriSalesEmailByAccountROWID(_AccountRowid)
        _QuoteMaster.salesRowId = GET_ContactRowID_by_Email(_AccountRowid)
        _QuoteMaster.DocType = 0
        _QuoteMaster.DOCSTATUS = 0
        _QuoteMaster.qstatus = "DRAFT"
        _QuoteMaster.createdDate = Now
        _QuoteMaster.reqDate = Now
        _QuoteMaster.expiredDate = Now.AddMonths(1)
        _QuoteMaster.createdBy = Session("user_id")
        _QuoteMaster.isRepeatedOrder = isRptOrder
        _QuoteMaster.Revision_Number = 1
        _QuoteMaster.Active = 1
        _QuoteMaster.quoteDate = Now
        For Each x As CartItem In _cartlist
            Dim Quoteitem As New QuotationDetail
            Quoteitem.quoteId = _QuoteMaster.quoteId : Quoteitem.line_No = x.Line_No : Quoteitem.partNo = x.Part_No
            Quoteitem.description = x.Description : Quoteitem.qty = x.Qty
            Quoteitem.listPrice = x.List_Price : Quoteitem.unitPrice = x.oUnit_Price
            Quoteitem.newUnitPrice = x.Unit_Price : Quoteitem.itp = x.Itp
            If Quoteitem.unitPrice Is Nothing Then Quoteitem.unitPrice = Quoteitem.newUnitPrice
            Quoteitem.newItp = x.Itp : Quoteitem.deliveryPlant = x.Delivery_Plant
            Quoteitem.category = x.Category : Quoteitem.classABC = x.class
            Quoteitem.rohs = x.rohs : Quoteitem.ewFlag = x.Ew_Flag
            Quoteitem.reqDate = x.req_date : Quoteitem.dueDate = x.due_date
            Quoteitem.satisfyFlag = x.SatisfyFlag : Quoteitem.canBeConfirmed = x.CanbeConfirmed
            Quoteitem.custMaterial = x.CustMaterial : Quoteitem.inventory = x.inventory
            Quoteitem.oType = x.otype : Quoteitem.modelNo = x.Model_No
            Quoteitem.ItemType = 0
            If x.ItemTypeX = CartItemType.BtosParent Then
                Quoteitem.ItemType = 1
            End If
            Quoteitem.HigherLevel = 0
            Quoteitem.HigherLevel = x.higherLevel
            Quoteitem.sprNo = ""
            _Quotelist.Add(Quoteitem)
        Next
        Try
            MyUtil.Current.EQContext.QuotationMasters.InsertOnSubmit(_QuoteMaster)
            MyUtil.Current.EQContext.QuotationDetails.InsertAllOnSubmit(_Quotelist)
            MyUtil.Current.EQContext.SubmitChanges()
            Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/QuotationMaster.aspx?UID={0}", _QuoteMaster.quoteId))
            Dim url As String = "http://eq.advantech.com"
            If Util.IsTesting() Then
                url = "http://eq.advantech.com:8300"
            End If
            Response.Redirect(String.Format("{3}/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL, url))
        Catch ex As Exception
            Glob.ShowInfo(ex.Message.ToString())
            Exit Sub
        End Try
    End Sub
    Function getPriSalesEmailByAccountROWID(ByVal ROWID As String) As String
        Dim Str As Object = String.Format("SELECT TOP 1 isnull(EMAIL_ADDR,'') FROM S_CONTACT WHERE ROW_ID=(SELECT TOP 1 PR_EMP_ID from S_POSTN where ROW_ID = (SELECT TOP 1 PR_POSTN_ID FROM S_ORG_EXT WHERE ROW_ID='{0}')) and EMAIL_ADDR is not null", ROWID)
        Dim EMAIL = dbUtil.dbExecuteScalar("CRMDB75", Str)
        If EMAIL Is Nothing Then Return ""
        Return EMAIL.ToString
    End Function
    Function GET_ContactRowID_by_Email(ByVal email As String) As String
        Dim str As String = String.Format("SELECT TOP 1 ROW_ID FROM S_CONTACT WHERE UPPER(EMAIL_ADDR)='{0}' and ROW_ID IN (select ROW_ID from S_USER WHERE UPPER(LOGIN) not like 'DELETE%')", email.ToUpper)
        Dim ROWID As Object = dbUtil.dbExecuteScalar("CRMDB75", str)
        If Not IsNothing(ROWID) AndAlso ROWID.ToString <> "" Then
            Return ROWID.ToString
        End If
        Return "1-2SUYGX"
    End Function
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim STATUS As Integer = CType(e.Row.FindControl("hstatus"), HiddenField).Value
            Dim o As Button = CType(e.Row.FindControl("GVbtnAdd2Cart"), Button)
            'If STATUS = 1 Or STATUS = 3 Then
            'o.Text = "Order"
            'End If
            'If STATUS = 2 Or STATUS = 4 Then
            '    o.Text = "Pending"
            '    o.Enabled = False
            'End If
            'Dim lbStatus As Label = CType(e.Row.FindControl("lbStatus"), Label)
            'If STATUS = -1 Then
            '    lbStatus.Text = "GP Rejected"
            'End If
            'If STATUS = 0 Then
            '    lbStatus.Text = "Cart History"
            'End If
            'If STATUS = 1 Then
            '    lbStatus.Text = "GP Approved"
            'End If
            'If STATUS = 2 Then
            '    lbStatus.Text = "GP Approving"
            'End If
            'If STATUS = 3 Then
            '    lbStatus.Text = "Repeated Order Approved"
            'End If
            'If STATUS = 4 Then
            '    lbStatus.Text = "Repeated Order Approving"
            'End If
            Dim lbType As Label = CType(e.Row.FindControl("lbType"), Label)
            If MyCartX.IsHaveBtos(Me.GridView1.DataKeys(e.Row.RowIndex).Value) Then
                lbType.Text = "System"
            End If
            
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            If Util.IsInternalUser2() Then
                e.Row.Cells(9).Visible = True
            Else
                e.Row.Cells(9).Visible = True : e.Row.Cells(10).Visible = False
            End If
        End If
    End Sub

    Protected Sub GVbtnAdd2Cart_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        Dim _IsAnyPhaseOutProd As Boolean = False
        Dim _ProductList As New List(Of ProductX)
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(id)
        
        'Frank 20160302 EU's customer is not allowed to place combo order
        If Not String.IsNullOrEmpty(org) _
           AndAlso org.StartsWith("EU", StringComparison.InvariantCultureIgnoreCase) _
           AndAlso MyCartX.IsComboCart(id) Then
            Dim titlestr As String = "Warning"
            Dim str As String = id + " cannot be added to cart because the combo order(loose items & configuration systems) is not allowed to be placed."
            str += " <br/> You can """
            str += String.Format("<a href=""cartHistory_detail.aspx?UID={0}"" target=""_blank"">click here</a>""", id)
            str += "  to check the detail."
            Dim Num As String = "20"
            ScriptManager.RegisterStartupScript(UP1, HttpContext.Current.GetType(), "show", "ShowMasterErr('" & titlestr & "','" & str & "', " & Num.ToString() & ");", True)
            Exit Sub
        End If
        
        
        Dim _ProductX As New ProductX()
        For Each i As CartItem In _cartlist
            _ProductList.Add(New ProductX(i.Part_No, org, i.Delivery_Plant))
        Next
        _ProductList = _ProductX.GetProductInfo(_ProductList, org, _IsAnyPhaseOutProd)
        If _IsAnyPhaseOutProd Then
            Dim titlestr As String = "Warning"
            Dim str As String = "The status of below Item(s) "
            str += " is(are) phase out or invalid .<br/> You can """
            str += String.Format("<a href=""cartHistory_detail.aspx?UID={0}"" target=""_blank"">click here</a>""", id)
            str += "  to check the detail."
            str += " <ul> "
            For Each item As CartItem In _cartlist
                Dim _currproductX = _ProductList.Where(Function(p) p.PartNo = item.Part_No).FirstOrDefault
                If _currproductX IsNot Nothing AndAlso _currproductX.IsPhaseOut Then
                    str += String.Format("<li>LineNo:{1} {2} <font color=""red"">{0}</font></li>", _currproductX.PartNo, item.Line_No, vbTab)
                End If
            Next
            str += " </ul> "
            Dim Num As String = "20"
            ScriptManager.RegisterStartupScript(UP1, HttpContext.Current.GetType(), "show", "ShowMasterErr('" & titlestr & "','" & str & "', " & Num.ToString() & ");", True)
            Exit Sub
        End If
        
        'Ryan 20160308 If cart contains loose item + configuration system then block it and not allowed to transfer.
        If org.StartsWith("EU") Then
            If _cartlist.Where(Function(p) p.ItemTypeX = CartItemType.Part).Count() > 0 AndAlso _cartlist.Where(Function(p) p.ItemTypeX = CartItemType.BtosParent).Count() > 0 Then
                Dim titlestr As String = "Warning"
                Dim str As String = id + " cannot be added to cart because combo order(loose items & configuration systems ) is not allowed to be placed."
                Dim Num As String = "20"
                ScriptManager.RegisterStartupScript(UP1, HttpContext.Current.GetType(), "show", "ShowMasterErr('" & titlestr & "','" & str & "', " & Num.ToString() & ");", True)
                Exit Sub
            End If
        End If
            
        MyCartX.Copy2Cart(id, Session("cart_Id").ToString())
        Response.Redirect("~/order/cart_list.aspx")
        'End If
    End Sub

    Protected Sub lbtnCart_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/Order/Cart_list.aspx")
    End Sub

    Protected Sub GVbtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        'myCartHistory.Delete(String.Format("cart_id='{0}'", id))
        'mycart.Delete(String.Format("cart_id='{0}'", id))
        
        'Ryan 20160219 Fake Delete
        Dim update_str As String = String.Format("update cart_history set Cart_Status = '0' where Cart_id = '{0}'", id)
        dbUtil.dbExecuteNoQuery("MY", update_str)
        
        Me.GridView1.DataBind()
    End Sub

    Protected Sub GVbtnAdd2Quote_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        cartHistory2Quotation(id)
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <link href="../Includes/js/jquery-ui.css" rel="stylesheet" />
    <script src="../Includes/js/jquery-latest.min.js"></script>
    <script src="../Includes/js/jquery-ui.js"></script>
    <style>
        #divMasterAlertWindow b a {
            color: #E35838;
        }

        #divMasterAlertWindow b ul {
            padding-top: 5px;
        }
    </style>
    <div id="divMasterAlertWindow" style="display: none;">
        <center>
            <b style="text-align: left; float: left; padding-left: 10px;" class="errMsg"></b>
        </center>
    </div>
    <script>
        function ShowMasterErr(title, errStr, loadingSeconds) {
            var _title = "Alert Messages";
            if ($.trim(title) != "") { _title = title; }

            $("#divMasterAlertWindow").dialog(
                {
                    title: _title,
                    modal: true, width: '50%',
                    open: function (type, data) {
                        $("#divMasterAlertWindow").find(".errMsg").html(errStr);
                        ////扩展自动关闭功能
                        if ($.isNumeric(loadingSeconds) && loadingSeconds > 0) {
                            setTimeout(function () { $("#divMasterAlertWindow").dialog("close") }, loadingSeconds * 1000);
                        }
                        ///扩展结束
                    },
                    close: function (type, data) { $("#divMasterAlertWindow").find(".errMsg").empty(); }
                }
               );
        }
    </script>
    <div>
        <table width="100%">
            <tr>
                <td align="right">
                    <table>
                        <tr>
                            <td>
                                <asp:Image ID="imgLK" runat="server" ImageUrl="~/Images/arrow2007_small-BU3.gif" />
                            </td>
                            <td>
                                <asp:LinkButton runat="server" ID="lbtnCart" OnClick="lbtnCart_Click">My Cart</asp:LinkButton>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <hr />
        <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
            <tr valign="top">
                <td valign="top">
                    <table cellpadding="0" cellspacing="0" width="100%">
                        <tr valign="top">
                            <td>
                                <table width="100%" id="Table2">
                                    <tr valign="top">
                                        <td height="2">&nbsp;
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td align="left">
                                            <div class="euPageTitle">
                                                Cart History
                                            </div>
                                            &nbsp;&nbsp;&nbsp;<span class="PageMessageBar"></span>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td height="2"></td>
                                    </tr>
                                    <tr valign="top">
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle"
                                                id="Table1">
                                                <tr>
                                                    <td class="menu_title">Shopping Cart History<br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:UpdatePanel runat="server" ID="UP1" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:GridView DataKeyNames="cart_id" runat="server" Width="100%" ID="GridView1" AutoGenerateColumns="false"
                                                                    DataSourceID="SqlDataSource1" AllowPaging="True" PageIndex="0" PageSize="20"
                                                                    OnRowDataBound="GridView1_RowDataBound">
                                                                    <Columns>
                                                                        <asp:BoundField DataField="Cart_id" HeaderText="No." />
                                                                        <asp:BoundField DataField="description" HeaderText="Description" />
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Type
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <asp:Label ID="lbType" runat="server" Text="Component"></asp:Label>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:BoundField DataField="Company_id" HeaderText="Company" />
                                                                        <asp:BoundField DataField="Created_by" HeaderText="Created By" />
                                                                        <asp:BoundField DataField="Created_On" HeaderText="Created On" />
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Status
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <asp:Label ID="lbStatus" runat="server" Text=""></asp:Label>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Add2Cart
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <asp:HiddenField runat="server" ID="HSTATUS" Value='<%#Bind("ostatus") %>' />
                                                                                <asp:Button Text="Add2Cart" ID="GVbtnAdd2Cart" runat="server" OnClick="GVbtnAdd2Cart_Click" />
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Detail
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <%--      <asp:Button Text="Detail" ID="GVbtnDetail" runat="server" OnClick="GVbtnDetail_Click" />--%>
                                                                                <a href="cartHistory_detail.aspx?UID=<%#Eval("cart_id") %>" target="_blank">Detail</a>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Delete
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <asp:Button Text="Delete" ID="GVbtnDelete" runat="server" OnClick="GVbtnDelete_Click" />
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField>
                                                                            <HeaderTemplate>
                                                                                Add2Quote
                                                                            </HeaderTemplate>
                                                                            <ItemTemplate>
                                                                                <asp:Button Text="Add2Quote" ID="GVbtnAdd2Quote" runat="server"
                                                                                    OnClick="GVbtnAdd2Quote_Click" />
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"></asp:SqlDataSource>
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
