<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- Price Inquiry" EnableEventValidation="false" %>
<%@ Register TagPrefix="uc1" TagName="PickPartNo" Src="~/Includes/PickPartNo.ascx" %>

<script runat="server">
    Dim l_strSQLCmd As String = "", strCategory As String = "", strPriceGrade As String = "", strCurrency As String = ""
    Dim strCompanyId As String = ""
    Dim strProductLine As String = "", strCompanyType As String = "", strGradeSpr As String = "", strGradeStd As String = ""
    Dim strStatus As String = "", strProductGrp As String = "", strPartCode As String = "", strGradePtd As String = ""
    Dim strPartNo As String = "", iRet As Integer = 0
    'dim flg_excel As Boolean = False ' this flag is for the export the excel
    
    Protected Sub ibsearch_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        '--{2006-04-10}--Daive: Fix Promotion Item to promotion page
        If Global_Inc.PromotionRelease() = True Then
            If Global_Inc.IsPromoting(strPartNo, Session("COMPANY_ID")) Then
                Response.Redirect("../Lab/Promotion_Component_List.aspx?part_no=" & strPartNo)
            End If
        End If
        If Not OrderUtilities.Add2CartCheck(Me.txtPartNo.Text, "") Then
            Response.Redirect("../order/queryPrice.aspx")
        End If
        
        InitialVar()
        l_strSQLCmd = "select so_bank='', " & _
         "a.PART_NO, " & _
         "a.PRODUCT_DESC, " & _
         "a.STATUS, " & _
         "a.PRODUCT_LINE, " & _
         "a.PRODUCT_GROUP, " & _
         "PRODUCT_TYPE='" & strCategory & "', " & _
         "GRADE='" & strPriceGrade & "', " & _
         "CURRENCY='" & strCurrency & "', " & _
         "'' as LIST_PRICE, " & _
         "UNIT_PRICE='', " & _
         "START_DATE ='', " & _
         "END_DATE='', " & _
         "'' as ADD2CART, " & _
         "IsNull((select top 1 c.abc_indicator from sap_product_abc c where c.part_no=a.part_no and c.plant=b.deliveryplant),'') as class " & _
         "from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.part_no=b.part_no where b.org_id='" + Session("org_id") + "' "
        Dim l_strWhere As String = " and " & _
        "a.PART_NO = '" & strPartNo & "' "
        
        ViewState("SqlCommand") = ""
        Me.SqlDataSource1.SelectCommand = l_strSQLCmd & l_strWhere
        ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
        ' Response.Write(l_strSQLCmd & l_strWhere)
        'If Not Page.IsPostBack  then 'Or Me.excel_flg.Text = "true" Then
        gv1.DataBind()
        'End If
        'If txtPartNo.Text.Trim() <> "" Then
        '    ucCrossSelling1.Visible = True
        '    Dim partNo() As String = {"'" + txtPartNo.Text + "'"}
        '    ucCrossSelling1.CrossSellingPartNo = partNo
        '    ucCrossSelling1._FromPage = "Price" : ucCrossSelling1._FromModelNo = txtPartNo.Text.Trim.Replace("'", "")
        'Else
        '    ucCrossSelling1.Visible = False
        'End If
    End Sub
    
    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") = "" Then
            gv1.EmptyDataText = ""
        Else
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        End If
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Dim list_price As Decimal = 0, unit_price As Decimal = 0
        Dim cuu As String = ""
        If e.Row.RowType = DataControlRowType.DataRow Then
            Me.iRet = OrderUtilities.GetPrice(e.Row.Cells(1).Text, Session("company_id"), Session("org_id"), 1, list_price, unit_price)
            Select Case e.Row.Cells(4).Text.Trim()
                Case "US", "USD"
                    cuu = cuu & "$"
                Case "EUR"
                    cuu = cuu & "&euro;"
                Case "GBP"
                    cuu = cuu & "&pound;"
                Case "NT", "NTD", "TWD"
                    cuu = cuu & "NT"
                Case Else
                    cuu = cuu & "$"
            End Select
            
            'AdxDatagrid1.VxUserFormat(oDataGridItem, 7, "<img alt='' scr='../images/ebiz.aeu.face/btn_Call.GIF' onclick=Add2Cart('" & retVal(1) & "')  />")
            e.Row.Cells(7).Text = "<IMG alt="""" src=""../Images/ebiz.aeu.face/btn_add2cart1.gif""  align=""absmiddle"" style=""cursor:hand;"" onclick=""Add2Cart('" & Server.UrlEncode(e.Row.Cells(1).Text) & "')""/>"
            
            If list_price >= 0 Then
                e.Row.Cells(5).Text = cuu & list_price.ToString("#,##0.00")
            Else
                If IsPtrade(e.Row.Cells(1).Text) Then
                    e.Row.Cells(5).Text = "N/A"
                Else
                    e.Row.Cells(5).Text = "TBD"
                End If
            End If
            If unit_price >= 0 Then
                e.Row.Cells(6).Text = cuu & unit_price.ToString("#,##0.00")
            Else
                e.Row.Cells(6).Text = "TBD"
            End If
            If Util.IsInternalUser2() Or Util.IsInternalUser(Session("user_id")) Then
                e.Row.Cells(1).Text = "<a target='_blank' href='../DM/ProductDashboard.aspx?PN=" + e.Row.Cells(1).Text + "'>" + e.Row.Cells(1).Text + "</a>"
            End If
            If e.Row.Cells(8).Text.Trim().ToUpper = "A" Or e.Row.Cells(8).Text.Trim().ToUpper = "B" Then
                e.Row.Cells(1).Text = e.Row.Cells(1).Text & "&nbsp;<IMG alt=""class"" src=""../Images/hot-orange.gif""  align=""absmiddle""/>"
            End If
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(8).Visible = False
        End If
      
    End Sub
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        If Not IsNothing(Request("part_no")) AndAlso Request("part_no").Trim <> "" Then
            Response.Redirect("~/order/PriceAndATP.aspx?PN=" & Request("part_no").Trim.ToString)
        Else
            Response.Redirect("~/order/PriceAndATP.aspx")
        End If
        
        Response.AppendHeader("Cache-Control", "no-cache; private; no-store; must-revalidate; max-stale=0; post-check=0; pre-check=0; max-age=0")
        If Request("part_no") IsNot Nothing AndAlso Request("part_no") <> "" AndAlso Me.txtPartNo.Text = "" Then
            Me.txtPartNo.Text = Server.UrlEncode(Request("part_no"))
        End If
        
        'If Not OrderUtilities.Add2CartCheck(Trim(Me.txtPartNo.Text.Replace("'", "")), Session("user_role")) Then
        '    Response.Redirect("../order/queryPrice.aspx")
        'End If
        
        InitialVar()
        l_strSQLCmd = "select so_bank='', " & _
         "PART_NO, " & _
         "PRODUCT_DESC, " & _
         "STATUS, " & _
         "PRODUCT_LINE, " & _
         "PRODUCT_GROUP, " & _
         "PRODUCT_TYPE='" & strCategory & "', " & _
         "GRADE='" & strPriceGrade & "', " & _
         "CURRENCY='" & strCurrency & "', " & _
         "'' as LIST_PRICE, " & _
         "UNIT_PRICE='', " & _
         "START_DATE ='', " & _
         "END_DATE='', " & _
         "'' as ADD2CART, " & _
         String.Format("IsNull((select top 1 z.abc_indicator from sap_product_abc z where z.part_no=a.part_no and left(z.plant,2)='{0}' order by z.plant),'') as Class ", Left(Session("org_id").ToString(), 2)) & _
         "from SAP_PRODUCT a where 1=1 "
        Dim l_strWhere As String = " and " & _
        "PART_NO = '" & strPartNo & "' and isnull(material_group,'0') not like '%CTOS%' "
        
        Me.SqlDataSource1.SelectCommand = l_strSQLCmd & l_strWhere
        
        ' Response.Write(l_strSQLCmd & l_strWhere)
        If Not Page.IsPostBack Then 'Or Me.excel_flg.Text = "true" Then
            gv1.DataBind()
        End If
        
        If Me.ucPickPartNo.Visible Then
            'AddHandler CType(ucPickPartNo.Controls("gv1"), GridView).SelectedIndexChanged, AddressOf gv_SelectedIndexChanged
        End If
        If LCase(Session("user_id")) = "r.deraad@go4mobility.nl" Or LCase(Session("user_id")) = "j.sep@go4mobility.nl" Then
            Response.Redirect("/Home.aspx")
        End If
        
        'If txtPartNo.Text.Trim() <> "" Then
        '    ucCrossSelling1.Visible = True
        '    Dim partNo() As String = {"'" + txtPartNo.Text + "'"}
        '    ucCrossSelling1.CrossSellingPartNo = partNo
        '    ucCrossSelling1._FromPage = "Price" : ucCrossSelling1._FromModelNo = txtPartNo.Text.Trim.Replace("'", "")
        'Else
        '    ucCrossSelling1.Visible = False
        'End If
    End Sub
    
    Sub InitialVar()
        If Request("company_id") = "" Then
            strCompanyId = Session("COMPANY_ID")
            'strCompanyId = "EURP001"
        Else
            strCompanyId = Request("company_id")
        End If
        
        'strCompanyId = "EFFRFA01"
        '    'strCompanyId = "D6MO02"

        '    iTemp = DBConn_Get("B2BAESC", "B2B", l_adoConn)
        '    '---- prepare company info
        l_strSQLCmd = String.Format("select company_price_type, currency, company_name, price_class, '' as ptrade_price_class from SAP_DIMCOMPANY where company_id = '{0}' and company_type ='Z001'", strCompanyId)
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If dt.Rows.Count > 0 Then
            strCurrency = dt.Rows(0).Item("currency").ToString()
            strGradeStd = dt.Rows(0).Item("price_class").ToString()
            strGradePtd = dt.Rows(0).Item("ptrade_price_class").ToString()
            ' strCompanyName = Me.Global_inc1.dbGetDataTable("", "", l_strSQLCmd).Rows(0).Item("company_name").ToString()
            ' strCompanyPriceType = Me.Global_inc1.dbGetDataTable("", "", l_strSQLCmd).Rows(0).Item("company_price_type").ToString()
        End If
        'l_adoRs = l_adoConn.Execute(l_strSQLCmd)
        '    If Not l_adoRs.EOF Then
        '        strCurrency = l_adoRs("currency")
        '        strGradeStd = l_adoRs("price_class")
        '        strGradePtd = l_adoRs("ptrade_price_class")
        '        strCompanyName = l_adoRs("company_name")
        '        strCompanyPriceType = l_adoRs("company_price_type")
        '    End If
        '    'strGradeStd = "RLPE2L0A1E2"
        Select Case strCompanyId
            Case "EFRA008", "EITW004", "EUKADV", "EHLC001", "UUAAESC"
                strCompanyType = "RBU"
                strGradeSpr = strGradeStd
            Case Else
                strCompanyType = "CUSTOMER"
                strGradeSpr = strGradeStd
        End Select

        'If Not Page.IsPostBack Then
        '    If Request("txtPartNo") = "" Then
        '        strPartNo = Me.txtPartNo.Text
        '    Else
        '        strPartNo = Request("txtPartNo")
        '        Me.txtPartNo.Text = Request("txtPartNo")
        '    End If
        'Else
        strPartNo = Trim(Me.txtPartNo.Text.Replace("'", ""))
        'End If
        
        Dim dt1 As New DataTable
        Me.l_strSQLCmd = String.Format("select a.status, a.product_line, a.product_group from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.part_no=b.part_no where b.org_id='{1}' and a.part_no='{0}' ", strPartNo, Session("org_id"))
        dt1 = dbUtil.dbGetDataTable("B2B", Me.l_strSQLCmd)
        If dt1.Rows.Count > 0 Then
            strProductLine = dt1.Rows(0).Item("product_line").ToString()
            strStatus = dt1.Rows(0).Item("status").ToString()
            strProductGrp = dt1.Rows(0).Item("product_group").ToString()
            strPartCode = dt1.Rows(0).Item("product_line").ToString() & dt1.Rows(0).Item("product_group").ToString()
        End If
        '    l_adoRs = l_adoConn.Execute(l_strSQLCmd)
        '    If Not l_adoRs.EOF Then
        '        strProductLine = l_adoRs("product_line")
        '        strStatus = l_adoRs("status")
        '        strProductGrp = l_adoRs("product_group")
        '        strPartCode = l_adoRs("product_line") & l_adoRs("product_group")
        '    End If

        If IsNumeric(Left(strPartNo, 1)) And Left(strPartNo, 4) <> "2011" Then
            strCategory = "SPARE"
            strPriceGrade = strGradeSpr
        ElseIf Left(strPartNo, 4) = "2011" Then
            strCategory = "CATALOG"
            strPriceGrade = "AESC"
            '20050325 TC
            'ElseIf (UCase(strProductLine) = "TRAD" or UCase(left(strPartNo,2))="P-") Then
        ElseIf (UCase(strProductLine) = "TRAD" Or Me.IsPtrade(strPartNo)) Then
            strCategory = "PTRADE"
            strPriceGrade = strGradePtd
        ElseIf UCase(Left(strPartNo, 6)) = "OPTION" Then
            strCategory = "OPTION"
            strPriceGrade = "AESC"
        ElseIf UCase(Left(strPartNo, 4)) = "CTOS" Then
            strCategory = "CTOS"
            strPriceGrade = "AESC"
        Else
            strCategory = "STANDARD"
            strPriceGrade = strGradeStd
        End If
    End Sub

    Function IsPtrade(ByVal part_no As String) As Boolean
        'Dim ptrade As String = ""
        'ptrade = dbUtil.dbExecuteScalar("B2B", "select isnull(product_type,'') as product_type from product where part_no='" & part_no & "'")
        'If ptrade = "ZPER" Then
        '    IsPtrade = True
        'Else
        '    IsPtrade = False
        'End If  
    End Function
    
    Protected Sub btnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CType(ucPickPartNo.FindControl("txtModelNo"), TextBox).Text = ""
        CType(ucPickPartNo.FindControl("txtDesc"), TextBox).Text = ""
        CType(ucPickPartNo.FindControl("txtPartNo"), TextBox).Text = Trim(txtPartNo.Text.Replace("'", ""))
        'ucPickPartNo._strPartNO = txtPartNo.Text
        ucPickPartNo.initialSearch()
        ucPickPartNo.Visible = True
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub ucPickPartNo_pick(ByVal part_no As String)
        txtPartNo.Text = part_no
        ModalPopupExtender1.Hide()
        ucPickPartNo.Visible = False
        up1.Update() : up2.Update()
    End Sub

    Protected Sub ucPickPartNo_close()
        ucPickPartNo.Visible = False
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub ucPickPartNo_update()
        up2.Update()
    End Sub

    Protected Sub tabContainer1_ActiveTabChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If tabContainer1.ActiveTabIndex = "1" Then
            Dim para As String = ""
            If Trim(txtPartNo.Text.Replace("'", "")) <> "" Then para = "?part_no=" + Trim(txtPartNo.Text.Replace("'", ""))
            Response.Redirect("/Order/QueryATP.aspx" & para)
        End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script language="javascript" type="text/javascript">
    function Add2Cart(val)	
    {
        //alert (val)
        document.location.href = '../order/cart_add2cartline.aspx?part_no=' + val + '&qty=1';
    }
	    //-->
    </script>
     <style type="text/css">
     .ajax__tab_xp .ajax__tab_tab 
      { height:21px;}
</style>
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" ID="Table2">
		<tr>
			<td height="3">
				<!--Buffer--> &nbsp;
			</td>
		</tr>
	    <tr>
			<td width="15px"></td>
			<td>
				<table cellpadding=0 cellspacing=0 width="100%">
					<tr>
						<td>
							<!--Page Navi Bar-->
							<table border="0" cellspacing="0" cellpadding="0" ID="Table4">
								<tr>
									<td><asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/Home.aspx" Text="Home" /></td>
									<td width="15" align="center">></td>
									<td><asp:HyperLink runat="server" ID="hlSearchCenter" NavigateUrl="/Product/search.aspx" Text="Basic Product Search" /></td>
									<td width="15" align="center">></td>
									<td><div class="euPageNaviBar">Price Inquiry</div></td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="3" height="15"></td>
					</tr>
					<tr>
						<td>
							<!--Page Title-->
							<div class="euPageTitle">Price Inquiry</div>
						</td>
					</tr>
					<tr>
						<td colspan="3" height="15"></td>
					</tr>
					<tr>
						<td>
						    <!--input type="hidden" name="company_id" value="" ID="Hidden1"-->		
						    <ajaxToolkit:TabContainer runat="server" ID="tabContainer1" AutoPostBack="true" Width="457" OnActiveTabChanged="tabContainer1_ActiveTabChanged">
						        <ajaxToolkit:TabPanel HeaderText="Inquire Price" TabIndex="0" runat="server" ID="tabQueryPrice">
						            <ContentTemplate>
						                <table width="439" cellpadding="0" cellspacing="0" border="0" ID="Table6">
					                        <tr><td height="8px"></td></tr>
					                        <tr>
						                        <td width="40px" height="30px" align="right" valign="middle">
							                        <img src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7">&nbsp;
						                        </td>
						                        <td width="70" valign="middle">
							                        <div class="euFormFieldCaption">Part No</div>
						                        </td>
						                        <td align="left">
						                            <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
				                                        <ContentTemplate>
				                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                                                ServiceMethod="GetPartNo" TargetControlID="txtPartNo" ServicePath="~/Services/AutoComplete.asmx" 
                                                                MinimumPrefixLength="2" FirstRowSelected="true" />
				                                            <asp:TextBox ID="txtPartNo" runat="server" ></asp:TextBox>&nbsp;
                                                            &nbsp;<asp:Button runat="server" ID="btnPick" Text="Pick" OnClick="btnPick_Click" />
                                                            <asp:LinkButton runat="server" ID="link1" />
                                                            <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
				                                                PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
				                                            <asp:Panel runat="server" ID="Panel1">
                                                                <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                                    <ContentTemplate>
				                                                        <uc1:PickPartNo runat="server" ID="ucPickPartNo" Type="queryPrice" Visible="false" Onpick="ucPickPartNo_pick" Onclose="ucPickPartNo_close" Onupdate="ucPickPartNo_update" />
				                                                    </ContentTemplate>
                                                                </asp:UpdatePanel>
				                                            </asp:Panel>
				                                        </ContentTemplate>
				                                    </asp:UpdatePanel>
                                                </td>
						                        <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;
                                                    <asp:ImageButton ID="ibsearch" runat="server" ImageUrl="../images/query_new.GIF"
                                                        OnClick="ibsearch_Click" />
                                                </td>
					                        </tr>
					                        <tr><td height="8px"></td></tr>
				                        </table>   
						            </ContentTemplate>
						        </ajaxToolkit:TabPanel>
						        <ajaxToolkit:TabPanel runat="server" ID="tabQueryATP" HeaderText="Check Availability" TabIndex="1">
						            <ContentTemplate>
						                <table width="439">
                                            <tr>
                                                <td valign="middle" style="font-size:large; color:Gray;" align="center">
                                                    <div class="text"
                                                        style="color:Gray; font-size:larger; width:100px">
                                                        <img src="/Images/loading.gif" alt="Loading" width="16" height="16" />Loading...                
                                                    </div>   
                                                </td>
                                            </tr>
                                        </table>
						            </ContentTemplate>
						        </ajaxToolkit:TabPanel>
						    </ajaxToolkit:TabContainer>			
						</td>                            
                    </tr>				
                    <tr>
						<td colspan="3" height="15"></td>
					</tr>
                    		
					<tr valign="top">
						<td align="center">
                            <table border="0" width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="20" Width="100%"
							                 EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true" OnRowDataBound="gv1_RowDataBound">
							                <Columns>
							                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                    <headertemplate>
                                                        No.
                                                    </headertemplate>
                                                    <itemtemplate>
                                                        <%# Container.DataItemIndex + 1 %>
                                                    </itemtemplate>
                                                </asp:TemplateField>
							                    <asp:BoundField HeaderText="Part No" DataField="PART_NO" SortExpression="PART_NO" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Product Line" DataField="PRODUCT_LINE" SortExpression="PRODUCT_LINE" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Product Group" DataField="PRODUCT_GROUP" SortExpression="PRODUCT_GROUP" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Currency" DataField="Currency" SortExpression="Currency" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="List Price" DataField="LIST_PRICE" SortExpression="LIST_PRICE" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Unit Price" DataField="UNIT_PRICE" SortExpression="UNIT_PRICE" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Add To Cart" DataField="ADD2CART" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Hot" DataField="Class" ItemStyle-HorizontalAlign="Center" />
							                </Columns>
							                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                            <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                            <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
							            </asp:GridView>
							            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:B2B %>" SelectCommand="" OnLoad="SqlDataSource1_Load">
							            </asp:SqlDataSource>
                                    </td>
                                </tr>
                            </table>
                        </td>
					</tr>
					<tr><td height="10"></td></tr>
					<tr><td><hr /></td></tr>
		            <tr><td height="5"></td></tr>
		            <tr>
		                <td align="center">
		                    <table width="850px">
		                        <tr>
		                            <td>
		                                <%--<uc2:ucCrossSelling runat="server" ID="ucCrossSelling1" />--%>
		                            </td>
		                        </tr>
		                    </table>
		                </td>
		            </tr>
				</table>
			</td>
			<td width="15px"></td>
		</tr>
		
		<tr>
			<td height="70"></td>
		</tr>
	</table>
	
</asp:Content>
