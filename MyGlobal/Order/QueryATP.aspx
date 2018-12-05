<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Availability Inquiry" EnableEventValidation="false" %>

<%@ Register TagPrefix="uc1" TagName="PickPartNo" Src="~/Includes/PickPartNo.ascx" %>


<script runat="server">
    Dim iRet As Integer = 0
    Dim dt As New DataTable
    Dim plant As String = "EUH1", partNO As String = "", qty As Integer = 0, requiredDate As String = "00000000", unit As String = "PC"
    Dim xmlInput As String = ""
    Dim xmlOut As String = "", xmlLog As String = "", part_no As String = "", STATUS As String = ""
    
    Dim idx As Integer = 0
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Request("Part_no")) AndAlso Request("Part_no").Trim <> "" Then
            Response.Redirect("~/order/PriceAndATP.aspx?PN=" & Request("Part_no").Trim.ToString)
        Else
            Response.Redirect("~/order/PriceAndATP.aspx")
        End If
        
        Response.AppendHeader("Cache-Control", "no-cache; private; no-store; must-revalidate; max-stale=0; post-check=0; pre-check=0; max-age=0")
        'gv1.DataSource = dbUtil.dbGetDataTable("B2B", "select '' as no,'' as date, '' as Qty_Fulfill,'del' as Mandt,'add2cart' as site from user_info where 1<>1 ")
        If Request("Part_No") <> "" And Me.txtPartNo.Text = "" Then
            Me.txtPartNo.Text = Request("Part_no")
        End If
        plant = Left(Session("org_id"), 2) + "H1"        
        If Not IsDBNull(Me.txtPartNo.Text) And Me.txtPartNo.Text.Trim() <> "" And Not Me.Page.IsPostBack Then
            Me.part_no = Trim(Me.txtPartNo.Text.Replace("'", ""))
            'Nada add
            Dim dt As New DataTable
            Me.iRet = initRsATP(dt, Me.plant, Me.part_no, Me.qty.ToString(), Global_Inc.FormatDate(System.DateTime.Now), Me.unit)           
            Me.xmlInput = Global_Inc.DataTableToADOXML(dt)
           
            Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS
            WS.Timeout = -1
            'Dim WSDL_URL As String = ""
            'Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
            'WS.Url = WSDL_URL
            
            Dim soldto_id As String = Session("company_id") '"EFFRFA01"   Jackie changed
            Dim shipto_id As String = soldto_id
            
            '--{2006-08-30}--Daive: add customer "B2BGUEST", get Due Date 
            Dim tempSoldTo As String = ""
            If LCase(Session("COMPANY_ID")) = "b2bguest" Then
                tempSoldTo = soldto_id
                soldto_id = Global_Inc.GetCompanyForB2BGuest()
                shipto_id = soldto_id
            End If
            
            'Me.iRet = WS.GetMultiDueDate(UCase(soldto_id), UCase(shipto_id), "EU10", "10", "00", Me.xmlInput, Me.xmlOut, Me.xmlLog)
            'Me.iRet = WS.GetSingleATP(Me.plant, Me.part_no, Me.qty.ToString(), Global_Inc.FormatDate(System.DateTime.Now), Me.unit, Me.xmlOut, Me.xmlLog)
            Me.iRet = WS.GetMultiATP_New(Me.xmlInput, Me.xmlOut, Me.xmlLog)
            '--{2006-08-30}--Daive: add customer "B2BGUEST", get Due Date. 
            If LCase(Session("COMPANY_ID")) = "b2bguest" Then
                soldto_id = tempSoldTo
                shipto_id = soldto_id
            End If
            Dim rdt As New DataTable
            If Me.iRet = -1 Then
                '---- ERROR HANDEL ----'
                Response.Write("Calling SAP function Error!<br>" & Me.xmlLog & "<br>")
            Else
                Dim sr As System.IO.StringReader = New System.IO.StringReader(Me.xmlOut)
                Dim ds As New DataSet
                ds.ReadXml(sr)
                
                'dt.Merge(ds.Tables("row"))
                If Not IsNothing(ds.Tables("row")) Then
                    rdt.Merge(ds.Tables("row"))
                    '---------------------------
                Else
                    'Nada add 2008215
                    'If Session("user_id") = "nada.liu@advantech.com.cn" Then
                    rdt = dbUtil.dbGetDataTable("B2B", _
                    " select 'EU10' as entity, part_no as part, " & _
                    " DeliveryPlant as site, sum(qty) as qty_req, '" & "2020/10/10" & "' as date, " & _
                    " '' as flag, '' as type, sum(qty) as qty_atb, sum(qty) as qty_atp, " & _
                    " 0 as qty_lack, sum(qty) as qty_fulfill, '0' as flag_scm from logistics_detail where logistics_id='" & _
                    Session("cart_id") & "' and DeliveryPlant like 'TW%' group by part_no,DeliveryPlant ")
                    For i As Integer = 0 To dt.Rows.Count - 1
                        If Left(dt.Rows(i).Item("WERK"), 2) <> "TW" Then
                            Dim drr As DataRow = rdt.NewRow
                            drr.Item("entity") = "EUH1"
                            drr.Item("part") = dt.Rows(i).Item("MATNR")
                            'Response.Write("<b>" & dt.Rows(i).Item("MATNR").ToString() & "</b>")
                            drr.Item("site") = dt.Rows(i).Item("WERK")
                            drr.Item("qty_req") = dt.Rows(i).Item("REQ_QTY")
                            If Not IsNumeric(dt.Rows(i).Item("MATNR")) Then
                                drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), dt.Rows(i).Item("MATNR"), DateTime.Today())
                            Else
                                drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), Mid(dt.Rows(i).Item("MATNR"), 9), DateTime.Today())
                            End If
                            drr.Item("flag") = ""
                            drr.Item("type") = ""
                            drr.Item("qty_atb") = dt.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_atp") = dt.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_lack") = 0
                            drr.Item("qty_fulfill") = dt.Rows(i).Item("REQ_QTY")
                            'drr.Item("flag_scm") = "-1"
                            rdt.Rows.Add(drr)
                            dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set NoATPFlag='Y'" & _
                                " where logistics_id='" & Session("logistics_id") & "' and part_no='" & _
                                dt.Rows(i).Item("MATNR") & "' and DeliveryPlant='" & _
                                dt.Rows(i).Item("WERK") & "'")
                        End If
                    Next
                    'Else
                    'Me.Page.ClientScript.RegisterStartupScript(GetType(String), "alert", "<script>alert('There is no ATP currently for this item.\nFor Further inquiry,Please contact Advantech.')</" & "script>")
                    'Exit Sub
                    'End If
                End If
                
                If rdt.Rows.Count > 1 AndAlso rdt.Rows(rdt.Rows.Count - 1).Item("qty_atp").ToString = "99999" Then
                    rdt.Rows(dt.Rows.Count - 1).Delete()
                    rdt.AcceptChanges()
                End If
                
                If Not IsNothing(rdt) Then
                    gv1.DataSource = rdt
                    gv1.DataBind()
                End If
            
            End If
            
        Else
            'Me.AdxDatagrid1.xSQL = "select '' as no,'' as date, '' as Qty_Fulfill,'del' as Mandt,'add2cart' as site from user_info where 1<>1 "
            'Me.AdxDatagrid1.Visible = False
            
            
        End If
        'If txtPartNo.Text.Trim() <> "" Then
        '    ucCrossSelling1.Visible = True
        '    Dim partNo() As String = {"'" + txtPartNo.Text + "'"}
        '    ucCrossSelling1.CrossSellingPartNo = partNo
        '    ucCrossSelling1._FromPage = "ATP" : ucCrossSelling1._FromModelNo = txtPartNo.Text.Trim.Replace("'", "")
        'Else
        '    ucCrossSelling1.Visible = False
        'End If
    End Sub
    
    Protected Sub btnSubmit_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtPartNo.Text.Trim = "" Then
            lblPartNo.Visible = True : up2.Update() : Exit Sub
        Else
            lblPartNo.Visible = False : up2.Update()
        End If
        '--{2006-04-10}--Daive: Fix Promotion Item to promotion page
        Try
            If Global_Inc.PromotionRelease() = True Then
                If Global_Inc.IsPromotingSMP(Me.txtPartNo.Text, Session("COMPANY_ID")) = True Then
                    Response.Redirect("../Lab/Promotion_Component_List.aspx?part_no=" & Trim(Me.txtPartNo.Text.Replace("'", "")))
                End If
            End If
            If Not OrderUtilities.Add2CartCheck(Me.txtPartNo.Text, "") Then
                Response.Redirect("../order/queryATP.aspx")
            End If
            Dim RDT As New DataTable
            Me.iRet = initRsATP(dt, Me.plant, Me.txtPartNo.Text.Replace("'", "").Trim(), Me.qty.ToString(), Global_Inc.FormatDate(System.DateTime.Now), Me.unit)
            Me.xmlInput = Global_Inc.DataTableToADOXML(dt)
            Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS
            Dim WSDL_URL As String = ""
        
            Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
            WS.Url = WSDL_URL
            Dim company_str As String = UCase(Session("company_id"))
            If UCase(Session("company_id")) = "EHLA002" Then
                company_str = "UUAAESC"
            End If
            Me.iRet = WS.GetMultiATP_New(Me.xmlInput, Me.xmlOut, Me.xmlLog)            
        
            If Me.iRet = -1 Then
                Response.Write("Calling SAP function Error!<br>" & Me.xmlLog & "<br>")
            Else
                Dim sr As System.IO.StringReader = New System.IO.StringReader(Me.xmlOut)
                Dim ds As New DataSet
                ds.ReadXml(sr)
                
                'dt.Merge(ds.Tables("row"))
                If Not IsNothing(ds.Tables("row")) Then
                    RDT.Merge(ds.Tables("row"))
                Else
                    'Nada add 2008215
                    'If Session("user_id") = "nada.liu@advantech.com.cn" Then
                    RDT = dbUtil.dbGetDataTable("B2B", _
                    " select 'EU10' as entity, part_no as part, " & _
                    " DeliveryPlant as site, sum(qty) as qty_req, '" & "2020/10/10" & "' as date, " & _
                    " '' as flag, '' as type, sum(qty) as qty_atb, sum(qty) as qty_atp, " & _
                    " 0 as qty_lack, sum(qty) as qty_fulfill, '0' as flag_scm from logistics_detail where logistics_id='" & _
                    Session("cart_id") & "' and DeliveryPlant like 'TW%' group by part_no,DeliveryPlant ")
                    For i As Integer = 0 To dt.Rows.Count - 1
                        If Left(dt.Rows(i).Item("WERK"), 2) <> "TW" Then
                            Dim drr As DataRow = RDT.NewRow
                            drr.Item("entity") = "EUH1"
                            drr.Item("part") = dt.Rows(i).Item("MATNR")
                            'Response.Write("<b>" & dt.Rows(i).Item("MATNR").ToString() & "</b>")
                            drr.Item("site") = dt.Rows(i).Item("WERK")
                            drr.Item("qty_req") = dt.Rows(i).Item("REQ_QTY")
                            If Not IsNumeric(dt.Rows(i).Item("MATNR")) Then
                                drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), dt.Rows(i).Item("MATNR"), DateTime.Today())
                            Else
                                drr.Item("date") = Global_Inc.GetRPL(Session("company_id"), Mid(dt.Rows(i).Item("MATNR"), 9), DateTime.Today())
                            End If
                            drr.Item("flag") = ""
                            drr.Item("type") = ""
                            drr.Item("qty_atb") = dt.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_atp") = dt.Rows(i).Item("REQ_QTY")
                            drr.Item("qty_lack") = 0
                            drr.Item("qty_fulfill") = dt.Rows(i).Item("REQ_QTY")
                            'drr.Item("flag_scm") = "-1"
                            RDT.Rows.Add(drr)
                            dbUtil.dbExecuteNoQuery("B2B", "update logistics_detail set NoATPFlag='Y'" & _
                                " where logistics_id='" & Session("logistics_id") & "' and part_no='" & _
                                dt.Rows(i).Item("MATNR") & "' and DeliveryPlant='" & _
                                dt.Rows(i).Item("WERK") & "'")
                        End If
                    Next
                    'Else
                    'Me.Page.ClientScript.RegisterStartupScript(GetType(String), "alert", "<script>alert('There is no ATP currently for this item.\nFor Further inquiry,Please contact Advantech.')</" & "script>")
                    'Exit Sub
                    'End If
                End If
                
                If RDT.Rows.Count > 1 AndAlso RDT.Rows(RDT.Rows.Count - 1).Item("qty_atp").ToString = "99999" Then
                    RDT.Rows(dt.Rows.Count - 1).Delete()
                    RDT.AcceptChanges()
                End If
                If RDT.Rows.Count > 0 Then
                    Dim temp As Double = IIf(IsNumeric(RDT.Rows(RDT.Rows.Count - 1).Item("qty_atp")), RDT.Rows(RDT.Rows.Count - 1).Item("qty_atp"), 0.0)
                   
                    Me.tdTotal.InnerText = "Total: " & temp & " PCs"
                End If
                If Not IsNothing(RDT) Then
                    gv1.DataSource = RDT
                    gv1.DataBind()
                End If
                'If txtPartNo.Text.Trim() <> "" Then
                '    ucCrossSelling1.Visible = True
                '    Dim partNo() As String = {"'" + txtPartNo.Text + "'"}
                '    ucCrossSelling1.CrossSellingPartNo = partNo
                '    ucCrossSelling1._FromPage = "ATP" : ucCrossSelling1._FromModelNo = txtPartNo.Text.Trim.Replace("'", "")
                'Else
                '    ucCrossSelling1.Visible = False
                'End If
            End If
        Catch ex As Exception
            Response.Write(ex.ToString)
        End Try
        
        
    End Sub
    
    Function msgbox(ByVal msg As String) As String
        Response.Write("<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>")
        Response.Write("window.alert('" + msg + "')")
        Response.Write("</" & "script>")
        Return 0
    End Function
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If e.Row.RowIndex >= 1 AndAlso Session("RBU") = "AENC" Then
                e.Row.Visible = False : Exit Sub
            End If
            If OrderUtilities.IsGA(Session("company_id")) Then
                e.Row.Cells(1).Text = "To be confirmed within 3 days"
                e.Row.Cells(2).Text = "To be confirmed within 3 days"
            Else
                e.Row.Cells(1).Text = CDate(e.Row.Cells(1).Text).ToString("yyyy/MM/dd")
            
                If Double.TryParse(e.Row.Cells(2).Text, 0) AndAlso Double.Parse(e.Row.Cells(2).Text) = 0 Then
                    e.Row.Cells(1).Text = "N/A"
                    e.Row.Cells(2).Text = "No availability until this date, please contact Advantech for further check."
                    'msgbox("Due date for reference only.  A confirmation with ship dates will follow, normally within 48 hours.")
                End If
                'Response.Write(Me.part_no) : Response.End()
                If OrderUtilities.PhaseOutItemCheck(txtPartNo.Text.Trim) = 0 Then
                    e.Row.Visible = False
                End If
            End If
        End If
    End Sub
    
    Function initRsATP(ByRef dt As DataTable, ByVal plant As String, ByVal partNO As String, ByVal QTY As String, ByVal requiredDate As String, ByVal Unit As String) As Integer
        Me.iRet = Global_Inc.InitRsATPi(dt)
        Dim dr As DataRow = dt.NewRow()
        dr.Item("WERK") = plant.ToUpper()
        If IsNumeric(partNO.Trim().ToUpper()) Then
            dr.Item("MATNR") = "00000000" & partNO.Trim().ToUpper()
        Else
            dr.Item("MATNR") = partNO.Trim().ToUpper()
        End If
        
        dr.Item("REQ_QTY") = QTY.ToString()
        dr.Item("REQ_DATE") = requiredDate.ToString()
        dr.Item("UNI") = Unit.ToString()
        
        dt.Rows.Add(dr)
    End Function
    
    
    Protected Sub ibAdd2Cart_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)

        
        'Me.Global_inc1.ValidationStateCheck()
        
        '--{2006-04-19}--Daive: avoid add component to btos order
        'If Me.Order_Utilities1.BtosOrderCheck() = 1 Then
        '    Response.Redirect("../Order/Cart_List.aspx")
        'End If
        If Global_Inc.PromotionRelease() = True Then
            If Global_Inc.IsPromoting(Me.txtPartNo.Text, Session("COMPANY_ID")) = True Then
                Response.Redirect("../Lab/Promotion_Component_List.aspx?part_no=" & Me.txtPartNo.Text)
            End If
        End If
        
        If Not OrderUtilities.Add2CartCheck(Me.txtPartNo.Text, "") Then
            Response.Redirect("../order/queryATP.aspx")
        End If
        
        Dim part_no As String = ""
        part_no = Trim(Me.txtPartNo.Text.Replace("'", ""))
        If dbUtil.dbGetDataTable("RFM", String.Format("select a.part_no from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.part_no=b.part_no where b.org_id='{0}' and a.part_no='{1}' ", Session("org_id"), part_no)).Rows.Count < 1 Then
            Exit Sub
        End If
        If Not OrderUtilities.Add2CartCheck(part_no, "") Then
            Page.Response.Redirect("../order/cart_list.aspx")
        End If
        
        Dim intCount As Integer = 0, intMaxLineNo As Integer = 0, intQty As Integer = 1, iRet As Integer = 0
        If IsNumeric(Me.txtQTY.Value.Trim()) Then
            intQty = Me.txtQTY.Value.Trim()
        End If
         
        Dim dr1 As DataTable = dbUtil.dbGetDataTable("B2B", "select isnull(max(line_no),0) As line_no from cart_detail where cart_id='" & Session("cart_id") & "' and line_no<100")
        If dr1.Rows.Count > 0 Then
            intMaxLineNo = CInt(dr1.Rows(0).Item("line_no")) + 1
        Else
            intMaxLineNo = 1
        End If
        
        Dim dblListPrice As Decimal = 0
        Dim dblUnitPrice As Decimal = 0
        iRet = OrderUtilities.GetPrice(part_no, Session("company_id"), Session("org_id"), intQty, dblListPrice, dblUnitPrice)
        'Jackie revise 2007/08/23
        iRet = OrderUtilities.CartLine_Add(Session("cart_id"), intMaxLineNo, part_no, intQty, dblListPrice, dblUnitPrice, Me.plant, "0")
	
        Response.Redirect("../order/cart_list.aspx")
        
    End Sub
    
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
        If tabContainer1.ActiveTabIndex = "0" Then
            Dim para As String = ""
            If Trim(txtPartNo.Text.Replace("'", "")) <> "" Then para = "?part_no=" + Trim(txtPartNo.Text.Replace("'", ""))
            Response.Redirect("/Order/QueryPrice.aspx" & para)
        End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
 <style type="text/css">
     .ajax__tab_xp .ajax__tab_tab 
      { height:21px;}
</style>
    <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0"> 
	    <tr> 
	        <td> <!--Header--> 
	            <!--include virtual='/utility/header_inc.asp' --> 
	        </td> 
	    </tr> 
	    <tr> 
	        <td height="3"> <!--Buffer--> &nbsp; </td> 
	    </tr> 
	    <tr> 
	        <td> 
	            <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0"> 
	                <tr> 
	                    <td width="10px"> </td> 
	                    <td> 
                            <!--Page Navi Bar--> 
                            <table border="0" cellspacing="0" cellpadding="0" ID="Table4">
								<tr>
									<td><asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/Home.aspx" Text="Home" /></td>
									<td width="15" align="center">></td>
									<td><asp:HyperLink runat="server" ID="hlSearchCenter" NavigateUrl="/Product/search.aspx" Text="Basic Product Search" /></td>
									<td width="15" align="center">></td>
									<td><div class="euPageNaviBar">Check Availability</div></td>
								</tr>
							</table>
                        </td> 
                        <td width="20px"> </td> 
                    </tr> 
                    <tr> <td colspan="3" height="15"> </td> </tr> 
                    <tr> 
                        <td width="10px"> </td> 
                        <td> <!--Page Title--> <div class="euPageTitle">Availability Inquiry</div> </td> 
                        <td width="20px"> </td> 
                    </tr> 
                    <tr> <td colspan="3" height="15"> </td> </tr> 
                    <tr> 
                        <td width="10px"> </td> 
                        <td valign="top"> 
                            <ajaxToolkit:TabContainer runat="server" ID="tabContainer1" AutoPostBack="true" Width="457" ActiveTabIndex="1" OnActiveTabChanged="tabContainer1_ActiveTabChanged">
                                <ajaxToolkit:TabPanel runat="server" ID="tabQueryPrice" HeaderText="Inquire Price" TabIndex="0">
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
                                <ajaxToolkit:TabPanel runat="server" ID="tabQueryATP" HeaderText="Check Availability" TabIndex="1">
                                    <ContentTemplate>
                                        <table width="439" border="0" cellpadding="0" cellspacing="0">
										    <tr>
												<td colspan="4" height="4px">
												</td>
											</tr>
											<tr valign="middle">
												<td width="5%" height="30px" align="right">
													<img src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7">&nbsp;&nbsp;
												</td>
												<td width="20%">
													<div class="euFormFieldCaption">Material&nbsp;:</div>
												</td>
												<td width="75%">
													<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                                        <ContentTemplate>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                                                ServiceMethod="GetPartNo" TargetControlID="txtPartNo" ServicePath="~/Services/AutoComplete.asmx" 
                                                                MinimumPrefixLength="2" FirstRowSelected="true" />
                                                            <asp:TextBox ID="txtPartNo" runat="server" ></asp:TextBox>&nbsp;&nbsp;
                                                            <asp:Button runat="server" ID="btnPick" Text="Pick" OnClick="btnPick_Click" />
                                                            <asp:Label runat="server" ID="lblPartNo" Text=" * Please input Meterial" ForeColor="Red" Visible="false" />
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
											</tr>
											<tr>
												<td colspan="4" height="3px">
												</td>
											</tr>
											<tr valign="middle">
												<td width="5%" height="30px" align="right">
												</td>
												<td width="20%">
												</td>
												<td width="45%">
                                                    <table border="0" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td><input type="submit" name="submit" class="euFormSubmit" value="Submit" id="btnSubmit" onserverclick="btnSubmit_ServerClick" runat="server">
                                                                &nbsp; &nbsp;</td>
                                                            <td>QTY:<input type="text" class="euFormFieldValue" name="Part_No" value="" size="5" id="txtQTY" runat="server">&nbsp; &nbsp;</td>
                                                            <td><asp:ImageButton ID="ibAdd2Cart" runat="server" ImageUrl="../Images/ebiz.aeu.face/btn_add2cart1.gif" OnClick="ibAdd2Cart_Click" /></td>
                                                        </tr>
                                                    </table>
                                                </td>
												<td width="*" align="left">
												</td>
											</tr>
											<tr>
												<td colspan="4" height="4px">
												</td>
											</tr>
									    </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                            </ajaxToolkit:TabContainer>
						</td>
						<td width="20px">
						</td>
					</tr>
					<tr>
						<td colspan="3" height="15">
						</td>
					</tr>
					<tr>
						<td width="10px">
						</td>
						<td valign="top">
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
						        <tr>
						            <td>
						                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="20" Width="100%"
							                 EmptyDataText="No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . " EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true" OnRowDataBound="gv1_RowDataBound">
							                <Columns>
							                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                    <headertemplate>
                                                        No.
                                                    </headertemplate>
                                                    <itemtemplate>
                                                        <%# Container.DataItemIndex + 1 %>
                                                    </itemtemplate>
                                                </asp:TemplateField>
							                    <asp:BoundField HeaderText="Available Date" DataField="date" ItemStyle-HorizontalAlign="Center" />
							                    <asp:BoundField HeaderText="Availability" DataField="Qty_Fulfill" ItemStyle-HorizontalAlign="Center" />
							                </Columns>
							                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                            <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                            <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
							            </asp:GridView>
						            </td>
						        </tr>
						        <tr><td align="right" style="font-weight:bold;" runat="server" id="tdTotal"></td></tr>
						    </table>
						</td>
						<td width="20px">
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
		<tr>
			<td height="70">
				<!--Buffer--> &nbsp;
			</td>
		</tr>
	</table>

    <script language="javascript" type="text/javascript">
	
        function Add2Cart(val)	
        {

            var aa=document.getElementById("Add2CartQty")
            var qty = aa.value    
            //alert ('../order/cart_add2cartline.aspx?part_no=' + val + '&qty=' + qty)
            document.location.href = '../order/cart_add2cartline.aspx?part_no=' + val + '&qty=' + qty;
            
        }
	        //-->
     </script>
</asp:Content>


