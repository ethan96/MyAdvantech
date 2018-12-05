<%@ Page Title="MyAdvantech - BTOS Order History Inquiry Function" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub btnQuery_Click(sender As Object, e As EventArgs)
        gvBTO_Orders.DataSource = Nothing : gvBTO_Orders.DataBind()
        Dim dt As DataTable = SearchBTOOrder()
        gvBTO_Orders.DataSource = dt : gvBTO_Orders.DataBind()
    End Sub
    
    
    
    Function SearchBTOOrder() As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select top 100 a.SO_NO, a.PART_NO, IsNull(b.STATUS,'N/A') as BTO_STATUS, a.ORDER_DATE, a.COMPANY_ID,  ")
            .AppendLine(" replace(replace(( ")
            .AppendLine(" 	select z.PART_NO +' ('+IsNull(z2.STATUS,'N/A')+')' as PART_NO  ")
            .AppendLine(" 	from SAP_ORDER_HISTORY z with (nolock) left join SAP_PRODUCT_ORG z2 with (nolock) on z.part_no=z2.part_no  ")
            .AppendLine(" 	where z.SO_NO=a.SO_NO and z.HIGHER_LEVEL>0 and z2.org_id='" + Session("org_id") + "' ")
            .AppendLine(" 	group by z.PART_NO, z2.STATUS order by z.PART_NO desc for xml path('') ")
            .AppendLine(" ),'<PART_NO>',''),'</PART_NO>',';') as Components ")
            .AppendLine(" from SAP_ORDER_HISTORY a with (nolock) left join SAP_PRODUCT_ORG b with (nolock) on a.PART_NO=b.PART_NO ")
            .AppendLine(" where a.PART_NO like '%-BTO' and a.ORDER_DATE>=DATEADD(YEAR, -3, getdate()) and b.ORG_ID='" + Session("org_id") + "' ")
            If Not String.IsNullOrEmpty(txtBTOPN.Text) Then .AppendLine(" and a.PART_NO like '%" + Trim(txtBTOPN.Text).Replace("*", "%").Replace("'", "''") + "%' ")
            .AppendLine(" and a.SALES_ORG='" + dlRegion.SelectedValue + "' ")
            .AppendLine(" and a.SO_NO in ")
            .AppendLine(" ( ")
            .AppendLine(" 	select a.SO_NO ")
            .AppendLine(" 	from SAP_ORDER_HISTORY a with (nolock) ")
            .AppendLine(" 	where a.HIGHER_LEVEL>0  ")
            If Not String.IsNullOrEmpty(txtCompPN.Text) Then .AppendLine(" and a.PART_NO like '%" + Trim(txtCompPN.Text).Replace("*", "%").Replace("'", "''") + "%' ")
            If Not String.IsNullOrEmpty(txtSONO.Text) Then .AppendLine(" and a.SO_NO like '%" + Trim(txtSONO.Text).Replace("*", "%").Replace("'", "''") + "%' ")
            .AppendLine(" 	group by a.SO_NO  ")
            .AppendLine(" ) ")
            .AppendLine(" group by a.SO_NO, a.PART_NO, a.ORDER_DATE, a.COMPANY_ID, b.STATUS ")
            .AppendLine(" order by a.ORDER_DATE desc, a.PART_NO, a.SO_NO  ")
        End With
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function
    
    Public Shared Function HighlightKeyWords(text As String, keywords As String, fullMatch As Boolean) As String
        If text = [String].Empty OrElse keywords = [String].Empty Then
            Return text
        End If
        Dim cssClass As String = "red"
        'keywords = Replace(keywords, " ", ",")
        Dim wds = keywords.Split(New String() {",", " "}, StringSplitOptions.RemoveEmptyEntries)
       
        If Not fullMatch Then
            Return wds.Select(Function(word) word.Trim()).Aggregate(text, Function(current, pattern) Regex.Replace(current, pattern, String.Format("<span style=""color:{0}"">{1}</span>", cssClass, "$0"), RegexOptions.IgnoreCase))
        End If
        Return wds.Select(Function(word) "\b" & word.Trim() & "\b").Aggregate(text, Function(current, pattern) Regex.Replace(current, pattern, String.Format("<span style=""color:{0}"">{1}</span>", cssClass, "$0"), RegexOptions.IgnoreCase))

    End Function
    
    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            If dlRegion.Items.FindByValue(Session("org_id")) IsNot Nothing Then dlRegion.Items.FindByValue(Session("org_id")).Selected = True
        End If
    End Sub
    
    <Serializable()> _
    Class Add2CartReturnObject
        Public Property HasError As Boolean : Public Property ErrMsg As String
        Public Sub New()
            HasError = False : ErrMsg = ""
        End Sub
    End Class
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AddBTO2Cart(SoNo As String) As String
        Dim Add2CartReturnObj As New Add2CartReturnObject, js As New Script.Serialization.JavaScriptSerializer()
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                                                  " select a.PART_NO, a.LINE_NO, a.ORDER_QTY, a.HIGHER_LEVEL    " + _
                                                  " from SAP_ORDER_HISTORY a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO  " + _
                                                  " where a.SO_NO='" + Replace(SoNo, "'", "''") + "' and b.STATUS in ('A','N','H') and a.PART_NO not like 'AGS-EW%' " + _
                                                  " and a.LINE_NO>=100 and b.ORG_ID='" + HttpContext.Current.Session("org_id") + "' " + _
                                                  " order by a.LINE_NO  ")
            Dim CartId As String = HttpContext.Current.Session("CART_ID")
            dbUtil.dbExecuteNoQuery("MY", "delete from order_detail where order_id='" + CartId + "'")
            'Dim HasError As Boolean = False, sbErrMsg As New System.Text.StringBuilder
            For Each r As DataRow In dt.Rows
                Dim PartNo As String = r.Item("PART_NO"), errMsg As String = ""
                Dim itemType As CartItemType = IIf(PartNo.EndsWith("-BTO", StringComparison.CurrentCultureIgnoreCase), CartItemType.BtosParent, CartItemType.BtosPart)
                If MyCartOrderBizDAL.Add2Cart_BIZ(CartId, r.Item("PART_NO"), r.Item("ORDER_QTY"), 0, itemType, r.Item("PART_NO"), 1, 0, Now, "", "", r.Item("HIGHER_LEVEL"), True, errMsg) = 0 Then
                    Add2CartReturnObj.HasError = True : Add2CartReturnObj.ErrMsg += errMsg + ";"
                End If
            Next
        Catch ex As Exception
            Add2CartReturnObj.HasError = True : Add2CartReturnObj.ErrMsg += ex.ToString() + ";"
        End Try
      
        Return js.Serialize(Add2CartReturnObj)
    End Function
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">   
    <link rel="stylesheet" href="../Includes/js/jquery-ui.css" />
    <script type="text/javascript" src="../EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/json2.js"></script>
    <link rel="stylesheet" href="../Includes/js/token-input-facebook.css" type="text/css" />
    <script type="text/javascript" src="../Includes/js/jquery.tokeninput.js"></script>
    <style type="text/css">
        ul.token-input-list-facebook {
            overflow: hidden;
            height: auto !important;
            height: 1%;
            border: 1px solid #8496ba;
            cursor: text;
            font-size: 12px;
            font-family: Verdana;
            min-height: 1px;
            z-index: 999;
            margin: 0;
            padding: 0;
            background-color: #fff;
            list-style-type: none;
            clear: left;
            width: 500px;
        }

            ul.token-input-list-facebook li input {
                border: 0;
                padding: 3px 8px;
                background-color: white;
                margin: 2px 0;
                -webkit-appearance: caret;
                width: 240px;
            }
    </style>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm != null) {
            prm.add_endRequest(enableQueryButton);
        }

        function enableQueryButton() {
            document.getElementById('<%=btnQuery.ClientID%>').disabled = false;
        }

        function add2cart(addBtn) {
            busyMode(true);
            var sono = $(addBtn).parent().find("#divSONO").text();
            //console.log("sono:" + sono);
            var postData = JSON.stringify({ SoNo: sono });
            $.ajax(
                    {
                        type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/AddBTO2Cart", data: postData, contentType:"application/json; charset=utf-8", dataType: "json",
                        success: function (retData) {
                            var Add2CartReturnObj = $.parseJSON(retData.d);
                            //console.log(Add2CartReturnObj.HasError + " " + Add2CartReturnObj.ErrMsg);
                            if (Add2CartReturnObj.HasError) {
                                $("#tdErrMsg").empty(); $("#tdErrMsg").text(Add2CartReturnObj.ErrMsg);
                                $("#divAdd2cartError").dialog(
                                    {
                                        modal: true,
                                        width: $(window).width() - 100,
                                        height: $(window).height() - 100,
                                        open: function (event, ui) { },
                                        title: "Error Message"
                                    }
                                );
                            }
                            else {
                                window.location = "../Order/Cart_ListV2.aspx";
                            }
                            busyMode(false);
                        },
                        error: function (msg) {
                            console.log("call AddBTO2Cart err:" + msg.d); busyMode(false);
                        }
                    }
                );
        }

        function busyMode(mode) {
            (mode == true) ? $("#ctl00_UpdateProgress2").css("visibility", "visible") : $("#ctl00_UpdateProgress2").css("visibility", "hidden");
            (mode == true) ? $("#imgLoading").css("style", "block") : $("#imgLoading").css("style", "none");
        }

    </script>
    <table width="100%">
        <tr>
            <td align="center">
                <asp:Panel runat="server" ID="Panel1" DefaultButton="btnQuery">
                    <table id="tableQuerySO" width="400px">
                        <tr>
                            <th align="left">Component (ex: AIMB-2*)
                            </th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtCompPN" ServicePath="~/Services/AutoComplete.asmx"
                                    ServiceMethod="GetSAPPN" MinimumPrefixLength="2" />
                                <asp:TextBox runat="server" ID="txtCompPN" Width="150px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">BTO (ex: IPC-610-BTO)
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBTOPN" Width="150px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">SO No.
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtSONO" Width="150px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Region</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlRegion">
                                    <asp:ListItem Text="AJP" Value="JP01" />
                                    <asp:ListItem Text="ANA" Value="US01" />
                                    <asp:ListItem Text="AEU" Value="EU10" />
                                    <asp:ListItem Text="ATW" Value="TW01" />
                                    <asp:ListItem Text="ACN" Value="CN10" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr style="display:none">
                            <th align="left">Order Date:
                            </th>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalExt1" TargetControlID="txtSO_OrderDateFrom" Format="yyyy/MM/dd" />
                                            <asp:TextBox runat="server" ID="txtSO_OrderDateFrom" Width="80px" />
                                        </td>
                                        <td>~
                                        </td>
                                        <td>
                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalExt2" TargetControlID="txtSO_OrderDateTo" Format="yyyy/MM/dd" />
                                            <asp:TextBox runat="server" ID="txtSO_OrderDateTo" Width="80px" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td align="center" colspan="2">
                                <asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" UseSubmitBehavior="false" OnClientClick="this.disabled=true;" />
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
                        <asp:GridView runat="server" ID="gvBTO_Orders" Width="100%" AutoGenerateColumns="false" EmptyDataText="No matched data">
                            <Columns>
                                <asp:TemplateField HeaderText="SO No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="15%">
                                    <ItemTemplate>
                                        <span id="divSONO" style="display:inline"><%#Eval("SO_NO")%></span>&nbsp;
                                        <a href="javascript:void(0);" onclick="add2cart(this)"><img src="../Images/ImgCart.gif" alt="Add to Cart" /></a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="BTO Part No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="20%">
                                    <ItemTemplate>                                        
                                        <%#HighlightKeyWords(Eval("PART_NO"), Me.txtBTOPN.Text, False)%>&nbsp;(<%#Eval("BTO_STATUS")%>)
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Order Date" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                    <ItemTemplate>
                                        <%#CDate(Eval("ORDER_DATE")).ToString("yyyy/MM/dd")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Components" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>                                        
                                        <%#HighlightKeyWords(HighlightKeyWords(HighlightKeyWords(Replace(Eval("Components"), ";", "<br/>"), Me.txtCompPN.Text, False), "\(O\)", False), "\(I\)", False)%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <div id="divAdd2cartError" style="display:none; overflow:auto">
        <table width="100%">
            <tr>
                <td align="center" id="tdErrMsg" style="color:tomato"></td>
            </tr>
        </table>
    </div> 
</asp:Content>
