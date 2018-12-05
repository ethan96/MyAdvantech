<%@ Page Title="MyAdvantech - eConfigurator" ValidateRequest="false" EnableEventValidation="false"
    Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim userPassword As String = ""
    Dim userCompany As String = ""


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        If Not Page.IsPostBack Then
            'Session("user_id") = "16130774"
            Me.txtFrom.Text = DateAdd(DateInterval.Month, -3, Now).ToString("yyyy/MM/dd")
            Me.txtTo.Text = Now.AddMonths(3).ToString("yyyy/MM/dd")
            If Session("USER_ID") Is Nothing OrElse Session("Password") Is Nothing Then
                Response.Redirect("~/HOME.aspx?ReturnUrl=~/ORDER/Vendor_AP.aspx")
            Else
                'Dim dt As DataTable = SysUtil.dbGetDataTable("b2bacl", "supplier", "vendor", "b2bvend", "select * from b2bUser where UserID = '" & Session("USER_ID") & "'")
                Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "select * from VENDOR_USER where UserID = '" & Session("USER_ID") & "'")
                If String.Equals(Session("Password").ToString, "apacl", StringComparison.CurrentCultureIgnoreCase) Then
                    If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
                        td1.Visible = False : td2.Visible = True
                    Else
                        td1.Visible = True : td2.Visible = False
                    End If
                Else
                    userCompany = "(" + dt.Rows(0).Item(7).ToString() + ")"
                End If
                Session("company_id") = Session("USER_ID")
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateFrom").DefaultValue = DateAdd(DateInterval.Month, -3, Now).ToString("yyyy/MM/dd")
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateTo").DefaultValue = Now.ToString("yyyy/MM/dd")


            End If
            Me.gvStockInfo.AllowPaging = True
        End If
    End Sub

    Protected Sub gv1_OnRowDataBound(ByVal s As Object, ByVal e As GridViewRowEventArgs) Handles gv1.RowDataBound
        If e.Row.Cells.Count >= 5 Then
            e.Row.Cells(3).Width = New Unit(15, UnitType.Percentage)
        End If
    End Sub

    Protected Sub gv2_OnRowDataBound(ByVal s As Object, ByVal e As GridViewRowEventArgs) Handles gv2.RowDataBound
        If e.Row.Cells.Count >= 5 Then
            e.Row.Cells(3).Width = New Unit(15, UnitType.Percentage)
        End If
    End Sub
    Protected Sub SqlDataSource1_OnInit(ByVal sender As Object, ByVal e As EventArgs) Handles SqlDataSource1.Init
        'Me.SqlDataSource1.SelectParameters.Item("xap_vend").DefaultValue = dl1.SelectedValue

    End Sub

    Protected Sub BtnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Session("company_id") = Session("USER_ID")
        If rb1.SelectedValue = "CLOSE" Then
            TableOpen.Visible = False
            TableClose.Visible = True
            If txtFrom.Text = "" Or IsDate(txtFrom.Text) = False Then
                Me.SqlDataSource2.SelectParameters.Item("xap_effdateFrom").DefaultValue = DateAdd(DateInterval.Month, -3, Now).ToString("yyyy/MM/dd")
            Else
                Me.SqlDataSource2.SelectParameters.Item("xap_effdateFrom").DefaultValue = txtFrom.Text
            End If

            If txtTo.Text = "" Or IsDate(txtTo.Text) = False Then
                Me.SqlDataSource2.SelectParameters.Item("xap_effdateTo").DefaultValue = Now.AddMonths(3).ToString("yyyy/MM/dd")
            Else
                Me.SqlDataSource2.SelectParameters.Item("xap_effdateTo").DefaultValue = txtTo.Text
            End If
        Else
            'Response.Write(DDLorg.SelectedValue)
            TableOpen.Visible = True
            TableClose.Visible = False
            If txtFrom.Text = "" Or IsDate(txtFrom.Text) = False Then
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateFrom").DefaultValue = DateAdd(DateInterval.Month, -3, Now).ToString("yyyy/MM/dd")
            Else
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateFrom").DefaultValue = txtFrom.Text
            End If

            If txtTo.Text = "" Or IsDate(txtTo.Text) = False Then
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateTo").DefaultValue = Now.AddMonths(3).ToString("yyyy/MM/dd")
            Else
                Me.SqlDataSource1.SelectParameters.Item("xap_vo_duedateTo").DefaultValue = txtTo.Text
            End If
        End If
        'Response.Write(SqlDataSource1.SelectCommand)
    End Sub

    Protected Sub LbEffdate_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblEffdate As Label = CType(s, Label)
        lblEffdate.Text = CType(lblEffdate.Text, Date).ToString("yyyy/MM/dd")
    End Sub

    Protected Sub LbDuedate_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblDuedate As Label = CType(s, Label)
        lblDuedate.Text = CType(lblDuedate.Text, Date).ToString("yyyy/MM/dd")
    End Sub

    Protected Sub LbOpenAmt_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblOpenAmt As Label = CType(s, Label)
        lblOpenAmt.Text = CType(lblOpenAmt.Text, Integer).ToString("#,#")
    End Sub

    Protected Sub LbInvAmt_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblInvAmt As Label = CType(s, Label)
        lblInvAmt.Text = CType(lblInvAmt.Text, Integer).ToString("#,#")
    End Sub

    Protected Sub LbApAmt_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblApAmt As Label = CType(s, Label)
        Dim lblApAmtArray() As String = CType(lblApAmt.Text, String).Split(" ")
        If lblApAmtArray(0) <> "TWD" Then
            lblApAmt.Text = lblApAmtArray(0) + " " + FormatNumber(lblApAmtArray(1))
        Else
            lblApAmt.Text = lblApAmtArray(0) + " " + FormatNumber(lblApAmtArray(1)).Replace(".00", "")
        End If
    End Sub

    Protected Sub LbPaidAmt_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblPaidAmt As Label = CType(s, Label)
        lblPaidAmt.Text = FormatNumber(lblPaidAmt.Text)
    End Sub

    Protected Sub LbInvAmt_DataBinding(ByVal s As Object, e As EventArgs)
        Dim lblInvAmt As Label = CType(s, Label)
        lblInvAmt.Text = FormatNumber(lblInvAmt.Text)
    End Sub

    Protected Sub LbOpen_OnDataBinding(ByVal s As Object, ByVal e As EventArgs)
        Dim lblOpen As Label = CType(s, Label)
        Response.Write(lblOpen.Text + "7788")
        If lblOpen.Text.ToUpper.Contains("TRUE") Then
            lblOpen.Text = "OPEN"
        Else
            lblOpen.Text = "CLOSE"
        End If
    End Sub

    Protected Sub BtnExport2Xls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If rb1.SelectedValue = "CLOSE" Then
            gv2.AllowPaging = False
            gv2.AllowSorting = False
            'MyUtil.PrepareGridViewForExport(gv2)
            gv2.DataBind()
            ExportGridView(gv2, "Vendor AP", Response)
        Else
            gv1.AllowPaging = False
            gv1.AllowSorting = False
            'MyUtil.PrepareGridViewForExport(gv1)
            gv1.DataBind()
            ExportGridView(gv1, "Vendor AP", Response)
        End If
    End Sub

    Public Sub ExportGridView(ByVal gv1 As GridView, ByVal FileName As String, ByVal Response As HttpResponse)

        Dim attachment As String = "attachment; filename=" + FileName + ".xls"
        Response.ClearContent()
        Response.AddHeader("content-disposition", attachment)
        Response.ContentType = "application/ms-excel"
        Response.Charset = "utf-8"
        ' Response.ContentEncoding = System.Text.Encoding.UTF8
        Dim sw As New IO.StringWriter
        Dim htw As HtmlTextWriter = New HtmlTextWriter(sw)
        gv1.RenderControl(htw)
        Response.Write(sw.ToString)
        Response.End()

    End Sub
    Public Overrides Sub VerifyRenderingInServerForm(ByVal control As System.Web.UI.Control)
    End Sub

    Protected Sub LinkBtnExport2Xls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        BtnExport2Xls_Click(Me.BtnExport2Xls, Nothing)
    End Sub

    Protected Sub BtnAddPwd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tdAddPwd.Visible = True
        td1.Visible = False
        tbAddCompany.Text = Session("USER_ID")
    End Sub

    Protected Sub BtnChangePwd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tdChangePwd.Visible = True
        td2.Visible = False
        tbChangePwd.Text = ""
        'Dim dt As DataTable = SysUtil.dbGetDataTable("b2bacl", "supplier", "vendor", "b2bvend", "select UserPassword from b2bUser where UserID = '" & Session("USER_ID") & "'")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "select UserPassword from VENDOR_USER where UserID = '" & Session("USER_ID") & "'")
        userPassword = dt.Rows(0).Item(0).ToString()
    End Sub

    Protected Sub BtnChangePwdChanged_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = SysUtil.dbGetDataTable("b2bacl", "supplier", "vendor", "b2bvend", "update b2bUser set UserPassword = '" & Session("USER_ID") + tbChangePwd.Text & "'  where UserID = '" & Session("USER_ID") & "'")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "update VENDOR_USER set UserPassword = '" & Session("USER_ID") + tbChangePwd.Text & "'  where UserID = '" & Session("USER_ID") & "'")
        tdChangePwd.Visible = False
        td2.Visible = True
        Dim info As String = "<center>Update Success!!" + "<br>" + "New Password : " + "<font color='red'>" + Session("USER_ID") + tbChangePwd.Text + "</font>"
        lblInfo.Visible = True
        lblInfo.Text = info
    End Sub

    Protected Sub BtnChangePwdExit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tdChangePwd.Visible = False
        td2.Visible = True
        lblInfo.Text = ""
    End Sub

    Protected Sub BtnAddPwdAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = SysUtil.dbGetDataTable("b2bacl", "supplier", "vendor", "b2bvend", "insert into b2bUser (UserID,UserPassword,UserType,UserCompany,inputdate) values(" & _
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "insert into VENDOR_USER (UserID,UserPassword,UserType,UserCompany,inputdate) values(" &
                                                     "'" & Session("USER_ID") & "','" & Session("USER_ID") + tbAddPwd.Text & "','S','" & tbAddCompany.Text & "','" & Date.Today & "')")
        tdAddPwd.Visible = False
        td1.Visible = False
        td2.Visible = True
        Dim info As String = "<center>Insert Success!!" + "<br>" + "User Password : " + "<font color='red'>" + Session("USER_ID") + tbAddPwd.Text + "</font>" + "<br>" + "User Company : " + "<font color='red'>" + tbAddCompany.Text + "</font>"
        lblInfo.Visible = True
        lblInfo.Text = info
    End Sub

    Protected Sub BtnAddPwdExit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tdAddPwd.Visible = False
        td1.Visible = True
    End Sub

    Protected Sub btnStock_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        Dim strSQL As String = "Select distinct MSSL.WERKS as Plant,MSSL.MATNR as Material,MAKT.MAKTX AS Description, MSSL.SLLAB as Stock, MSSL.ERSDA as DateTime from SAPRDP.MSSL INNER JOIN SAPRDP.MAKT ON MSSL.MATNR = MAKT.MATNR where lifnr = 'T" & Session("USER_ID") & "' and MAKT.SPRAS = 'E' AND MSSL.SLLAB <> '0' order by ERSDA desc"
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSQL)
        'Dim ws As New b2b_ws.B2B_AJP_WS
        'Dim errMessage As String = ""
        'Dim WSDL_URL As String = ""
        'Dim ds As New DataSet()
        'ws.Timeout = 999999
        'Me.GlobalInc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        'ws.Url = WSDL_URL
        'Dim retValue As Integer = ws.GetVendorStock(strSQL, ds, errMessage)
        If dt IsNot Nothing Then
            Me.gvStockInfo.DataSource = dt
            Me.gvStockInfo.DataBind()
        Else
            'Response.Write(retValue & " error :" & errMessage.ToString())
        End If

    End Sub


    Protected Sub gvStockInfo_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Try
            Me.gvInventoryInfo.Visible = True

            Dim i As Integer = Convert.ToInt16(e.CommandArgument)
            Dim selectRow As GridViewRow = Me.gvStockInfo.Rows(i)
            Dim materialCell As TableCell = selectRow.Cells(1)
            Dim plantCell As TableCell = selectRow.Cells(0)

            Select Case plantCell.Text
                Case "AWS"
                    txtPlant.Text = "TWM1"
                Case "IA"
                    txtPlant.Text = "TWM2"
                Case "PPC"
                    txtPlant.Text = "TWM3"
                Case "EPC"
                    txtPlant.Text = "TWM4"
            End Select

            txtMaterial.Text = materialCell.Text
            'txtPlant.Text = plantCell.Text




            'Dim ws As New b2b_ws.B2B_AJP_WS
            Dim errMessage As String = ""
            'Dim WSDL_URL As String = ""
            Dim ds As New DataSet()
            'ws.Timeout = 999999
            'Me.GlobalInc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
            'ws.Url = WSDL_URL
            Dim retValue As Integer = GetVendorInventory("T" & Session("USER_ID"), txtPlant.Text, Me.txtTo.Text, Me.txtFrom.Text, txtMaterial.Text, ds, errMessage)
            If retValue = 1 And ds.Tables.Count > 0 Then
                Me.gvInventoryInfo.DataSource = ds.Tables(0)
                Me.gvInventoryInfo.DataBind()
            Else
                'Response.Write(retValue & " error :" & errMessage.ToString() & ds.Tables.Count)

            End If
        Catch ex As Exception

        End Try



    End Sub

    Public Function GetVendorInventory(ByVal company_id As String, ByVal plant As String, ByVal HDate As String, ByVal LDate As String, ByVal Material As String, ByRef dsResult As DataSet, ByRef errorMessage As String) As Integer

        Dim rtb As New B2B_Vendor_AP.MSEGTable
        Dim proxy As New B2B_Vendor_AP.B2B_Vendor_AP
        proxy.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD").ToString)
        proxy.Connection.Open()
        proxy.Zget_Transdata_For_Subcontract(HDate, LDate, company_id, Material, plant, rtb)
        proxy.Connection.Close()
        dsResult.Tables.Add(rtb.ToADODataTable())

        Return 1

    End Function


    Protected Sub gvStockInfo_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)

        'Try
        '    Me.gvInventoryInfo.Visible = False

        '    Dim strSQL As String = "Select distinct MSSL.WERKS as Plant,MSSL.MATNR as Material,MAKT.MAKTX AS Description, MSSL.SLLAB as Stock, MSSL.ERSDA as DateTime from SAPRDP.MSSL INNER JOIN SAPRDP.MAKT ON MSSL.MATNR = MAKT.MATNR where lifnr = 'T" & Session("USER_ID") & "' and MAKT.SPRAS = 'E' AND MSSL.SLLAB <> '0' order by ERSDA desc"
        '    Dim ws As New b2b_ws.B2B_AJP_WS
        '    Dim errMessage As String = ""
        '    Dim WSDL_URL As String = ""
        '    Dim ds As New DataSet()

        '    ws.Timeout = 999999
        '    Me.GlobalInc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        '    ws.Url = WSDL_URL
        '    Dim retValue As Integer = ws.GetVendorStock(strSQL, ds, errMessage)
        '    If retValue = 1 And ds.Tables.Count > 0 Then
        '        Me.gvStockInfo.DataSource = ds.Tables(0)
        '        Me.gvStockInfo.PageIndex = e.NewPageIndex
        '        Me.gvStockInfo.DataBind()
        '    Else
        '        Response.Write(retValue & " error :" & errMessage.ToString())
        '    End If
        'Catch ex As Exception
        'End Try


    End Sub

    Protected Sub gvInventoryInfo_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        'Try
        '    Me.gvInventoryInfo.Visible = True

        '    Dim ws As New b2b_ws.B2B_AJP_WS
        '    Dim errMessage As String = ""
        '    Dim WSDL_URL As String = ""
        '    Dim ds As New DataSet()
        '    ws.Timeout = 999999
        '    Me.GlobalInc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        '    ws.Url = WSDL_URL
        '    Dim retValue As Integer = ws.GetVendorInventory("T" & Session("USER_ID"), txtPlant.Text, Me.txtTo.Text, Me.txtFrom.Text, txtMaterial.Text, ds, errMessage)
        '    If retValue = 1 And ds.Tables.Count > 0 Then
        '        Me.gvInventoryInfo.DataSource = ds.Tables(0)
        '        Me.gvInventoryInfo.PageIndex = e.NewPageIndex
        '        Me.gvInventoryInfo.DataBind()
        '    Else
        '        Response.Write(retValue & " error :" & errMessage.ToString())
        '    End If
        'Catch ex As Exception
        '    Response.Write(ex.ToString())
        'End Try
    End Sub

    Protected Sub btnExportExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strSQL As String = "Select distinct MSSL.WERKS as Plant,MSSL.MATNR as Material,MAKT.MAKTX AS Description, MSSL.SLLAB as Stock, MSSL.ERSDA as DateTime from SAPRDP.MSSL INNER JOIN SAPRDP.MAKT ON MSSL.MATNR = MAKT.MATNR where lifnr = 'T" & Session("USER_ID") & "' and MAKT.SPRAS = 'E' AND MSSL.SLLAB <> '0' order by ERSDA desc"
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSQL)
        'Dim ws As New b2b_ws.B2B_AJP_WS
        'Dim errMessage As String = ""
        'Dim WSDL_URL As String = ""
        'Dim ds As New DataSet()
        'ws.Timeout = 999999
        'Me.GlobalInc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        'ws.Url = WSDL_URL
        'Dim retValue As Integer = ws.GetVendorStock(strSQL, ds, errMessage)
        If dt IsNot Nothing Then
            Me.gvStockInfo.DataSource = dt
            Me.gvStockInfo.AllowPaging = False
            Me.gvStockInfo.DataBind()
        Else
            'Response.Write(retValue & " error :" & errMessage.ToString())
        End If
        Util.DataTable2ExcelDownload(dt, "VendorStock.xls")
        'MyUtil.ExportGridView(Me.gvStockInfo, "Vendor Stock", Response)
    End Sub

    Protected Sub gvStockInfo_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Select Case e.Row.Cells(0).Text
                    Case "TWM1"
                        e.Row.Cells(0).Text = "AWS"
                    Case "TWM2"
                        e.Row.Cells(0).Text = "IA"
                    Case "TWM3"
                        e.Row.Cells(0).Text = "PPC"
                    Case "TWM4"
                        e.Row.Cells(0).Text = "EPC"
                End Select
                e.Row.Cells(3).Text = String.Format("{0:N1}", e.Row.Cells(3).Text)
            End If
        Catch ex As Exception
            Response.Write(ex.ToString)
        End Try

    End Sub

    Protected Sub gvInventoryInfo_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Select Case e.Row.Cells(1).Text
                    Case "TWM1"
                        e.Row.Cells(1).Text = "AWS"
                    Case "TWM2"
                        e.Row.Cells(1).Text = "IA"
                    Case "TWM3"
                        e.Row.Cells(1).Text = "PPC"
                    Case "TWM4"
                        e.Row.Cells(1).Text = "EPC"
                End Select
            End If
        Catch ex As Exception

        End Try
    End Sub

    Protected Sub gvStockInfo_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Function GetCompany(ByVal s As Object) As String

        If s IsNot Nothing AndAlso Not String.IsNullOrEmpty(s) Then
            If String.Equals(s.ToString.Trim, "TW01", StringComparison.CurrentCultureIgnoreCase) OrElse
                String.Equals(s.ToString.Trim, "ACL", StringComparison.CurrentCultureIgnoreCase) Then
                Return "Advantech"
            ElseIf String.Equals(s.ToString.Trim, "TW04", StringComparison.CurrentCultureIgnoreCase) OrElse
            String.Equals(s.ToString.Trim, "ACA", StringComparison.CurrentCultureIgnoreCase) Then
                Return "ACA"
            Else
                Return "Advanixs"
            End If
        End If
        Return ""
    End Function
    Function GetStatus(ByVal s As Object) As String
        If s IsNot Nothing AndAlso Not String.IsNullOrEmpty(s) Then
            If s.ToUpper.ToString.Trim.Contains("TRUE") Then
                Return "OPEN"
            Else
                Return "CLOSE"
            End If
        End If
        Return ""
    End Function


</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td style="height: 51px; width: 1004px;">
                &nbsp;
                <div class="euPageTitle">
                    &nbsp; Vendor AP</div>
            </td>
        </tr>
        <tr>
            <td style="height: 28px; font: caption; color: red; width: 100%;">
                &nbsp; &nbsp;&nbsp;Account :
                <%=Session("USER_ID")+userCompany%>
            </td>
        </tr>
        <tr>
            <td style="left: 10px; position: relative; height: 50px; width: 100%;">
                <table>
                    <tr>
                        <td style="height: 25px">
                            Company
                        </td>
                        <td style="height: 25px">
                            <asp:DropDownList ID="DDLorg" runat="server">
                                <asp:ListItem Value="ACL" Selected="True">Advantech </asp:ListItem>
                                <asp:ListItem Value="ADS">Advanixs </asp:ListItem>
                                <asp:ListItem Value="ACA">ACA</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                </table>
                <table border="1">
                    <tr>
                        <td>
                            Query Date
                        </td>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upDate">
                                <ContentTemplate>
                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalFrom" TargetControlID="txtFrom"
                                        Format="yyyy/MM/dd" CssClass="MyCalendar" />
                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalTo" TargetControlID="txtTo" Format="yyyy/MM/dd"
                                        CssClass="MyCalendar" />
                                    <asp:TextBox runat="server" ID="txtFrom" />~<asp:TextBox runat="server" ID="txtTo" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                        <td rowspan='2'>
                            <asp:Button runat="server" ID="BtnQuery" Text="Search" OnClick="BtnQuery_Click" />
                        </td>
                        <td rowspan='2'>
                            <asp:ImageButton runat="server" ID="BtnExport2Xls" ImageUrl="/Images/excel.gif" AlternateText="Export to Excel"
                                OnClick="BtnExport2Xls_Click" />
                            <asp:LinkButton runat="server" ID="LinkBtnExport2Xls" Text="Export to Excel" OnClick="LinkBtnExport2Xls_Click" />
                        </td>
                        <td runat="server" id="td1" rowspan='2' visible="false">
                            <asp:Button runat="server" ID="BtnAddPwd" Text="Add New Password" OnClick="BtnAddPwd_Click" />
                        </td>
                        <td runat="server" id="tdAddPwd" rowspan='2' visible="false" style="width: 155px">
                            Password :
                            <%=Session("USER_ID")%><asp:TextBox runat="server" ID="tbAddPwd" Width="40px" MaxLength="6" /><br />
                            Company :
                            <asp:TextBox runat="server" ID="tbAddCompany" /><br />
                            <center>
                                <asp:Button runat="server" ID="BtnAddPwdAdd" Text="Add" OnClick="BtnAddPwdAdd_Click" />&nbsp;
                                &nbsp;
                                <asp:Button runat="server" ID="BtnAddPwdExit" Text="Exit" OnClick="BtnAddPwdExit_Click" /></center>
                        </td>
                        <td runat="server" id="td2" rowspan='2' visible="false">
                            <asp:Button runat="server" ID="BtnChangePwd" Text="Change Password" OnClick="BtnChangePwd_Click" /><br />
                            <asp:Label runat="server" ID="lblInfo" Visible="false" />
                        </td>
                        <td runat="server" id="tdChangePwd" rowspan='2' visible="false">
                            Old Password :
                            <%=userPassword%><br />
                            New Password :
                            <%=Session("USER_ID")%><asp:TextBox runat="server" ID="tbChangePwd" Width="40px"
                                MaxLength="6" /><br />
                            <center>
                                <asp:Button runat="server" ID="BtnChangePwdChanged" Text="Change" OnClick="BtnChangePwdChanged_Click" />&nbsp;
                                &nbsp;
                                <asp:Button runat="server" ID="BtnChangePwdExit" Text="Exit" OnClick="BtnChangePwdExit_Click" /></center>
                        </td>
                        <td rowspan='2'>
                            <asp:Label ID="lblStock" runat="server" Text="Check Stock" Width="64px"></asp:Label>
                            <br />
                            <asp:Button ID="btnStock" runat="server" OnClick="btnStock_Click" Text="Check" /><br />
                            <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" OnClick="btnExportExcel_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 50px">
                            Status
                        </td>
                        <td style="height: 50px">
                            <asp:RadioButtonList runat="server" ID="rb1" RepeatDirection="Horizontal">
                                <asp:ListItem Text="OPEN" Value="OPEN" Selected="True" />
                                <asp:ListItem Text="CLOSE" Value="CLOSE" />
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="left: 10px; position: static; width: 100%;">
                <table runat="server" id="TableOpen" style="width: 100%;">
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                        <td>
                            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="False" CssClass="text"
                                DataSourceID="SqlDataSource1" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None"
                                BorderWidth="1px" CellPadding="3" GridLines="Horizontal" AllowPaging="True" OnRowDataBound="gv1_OnRowDataBound"
                                PageSize="30" Width="100%">
                                <Columns>
                                    <asp:TemplateField HeaderText="Company" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <%# GetCompany(Eval("xap_org_id"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Effective Date">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbEffdate" Text='<%# Bind("xap_effdate") %>' OnDataBinding="LbEffdate_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="xap_ref" HeaderText="Adavntech's Voucher No." SortExpression="xap_ref">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                         <asp:BoundField DataField="bktxt" HeaderText="Remark" SortExpression="bktxt">
                                        <ItemStyle HorizontalAlign="left" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="xap_inv_nbr" HeaderText="Invoice No." SortExpression="xap_inv_nbr">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Open Amount">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbOpenAmt" Text='<%# Bind("xap_open_amt") %>' OnDataBinding="LbOpenAmt_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Right" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Invoice Amount">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbInvAmt" Text='<%# Bind("xap_inv_amt") %>' OnDataBinding="LbInvAmt_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Right" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <%# GetStatus(Eval("xap_open"))%>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="AP Amount">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbApAmt" Text='<%# Bind("AP_Amount") %>' OnDataBinding="LbApAmt_OnDataBinding" />
                                        </ItemTemplate>
                                        <HeaderStyle Width="80px" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Due Date">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbDuedate" Text='<%# Bind("xap_vo_duedate") %>' OnDataBinding="LbDuedate_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="xap_seq" HeaderText="xap_seq" SortExpression="xap_seq"
                                        Visible="False" />
                                </Columns>
                                <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                                <RowStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <PagerStyle CssClass="text" BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
                                <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <AlternatingRowStyle BackColor="#F7F7F7" />
                                <PagerSettings PageButtonCount="30" Position="TopAndBottom" />
                            </asp:GridView>
                            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"
                                SelectCommand="SELECT [xap_effdate],xap_org_id, [xap_ref], [xap_open_amt], [xap_seq], [xap_inv_amt], [xap_inv_nbr], [xap_open], [xap_ap_curr] + ' ' + cast([xap_amt] as nvarchar) as [AP_Amount], [xap_vo_duedate],[xap__qad01] as bktxt FROM B2BSupplier.dbo.[Mis_xapinq] WHERE (([xap_vend] = @xap_vend) AND ([xap_open] = @xap_open) AND (xap_org_id=@xap_org_id) and ([xap_type] = @xap_type) AND ([xap_vo_duedate] >= @xap_vo_duedateFrom) AND ([xap_vo_duedate] <= @xap_vo_duedateTo)) order by [xap_vo_duedate] desc">
                                <SelectParameters>
                                    <asp:SessionParameter DefaultValue="" Name="xap_vend" SessionField="company_id" Type="String" />
                                    <asp:Parameter DefaultValue="true" Name="xap_open" Type="String" />
                                    <asp:Parameter DefaultValue="vo" Name="xap_type" Type="String" />
                                    <asp:Parameter Name="xap_vo_duedateFrom" DefaultValue="" Type="String" />
                                    <asp:Parameter Name="xap_vo_duedateTo" DefaultValue="" Type="String" />
                                    <asp:ControlParameter Name="xap_org_id" ControlID="ddlORG" DefaultValue="ACL" PropertyName="SelectedValue" />
                                </SelectParameters>
                            </asp:SqlDataSource>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="left: 10px; position: static; width: 100%;">
                <table runat="server" id="TableClose" style="width: 100%">
                    <tr>
                        <td>
                        </td>
                        <td>
                            <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="False" CssClass="text"
                                DataSourceID="SqlDataSource2" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None"
                                BorderWidth="1px" CellPadding="3" GridLines="Horizontal" AllowPaging="True" OnRowDataBound="gv2_OnRowDataBound"
                                PageSize="30" Width="100%">
                                <Columns>
                                    <asp:BoundField DataField="xap_ref" HeaderText="Adavntech's Check" SortExpression="xap_ref"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField DataField="xap_ck_voucher" HeaderText="Adavntech's Voucher No." SortExpression="xap_ck_voucher"
                                        ItemStyle-HorizontalAlign="Center" />
                                     <asp:BoundField DataField="bktxt" HeaderText="Remark" SortExpression="bktxt">
                                        <ItemStyle HorizontalAlign="left" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="xap_inv_nbr" HeaderText="Invoice No." SortExpression="xap_inv_nbr"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <%# GetStatus(Eval("xap_open"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="xap_ck_curr" HeaderText="Paid Currency" SortExpression="xap_ck_curr"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Paid Amount">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbPaidAmt" Text='<%# Bind("xap_amt")%>' OnDataBinding="LbPaidAmt_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Right" />
                                        <HeaderStyle Width="70px" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Invoice Amount">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbInvAmt" Text='<%# Bind("xap_inv_amt")%>' OnDataBinding="LbInvAmt_DataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Right" />
                                        <HeaderStyle Width="70px" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Paid Date">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="LbEffdate" Text='<%# Bind("xap_effdate") %>' OnDataBinding="LbEffdate_OnDataBinding" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="xap_seq" HeaderText="xap_seq" SortExpression="xap_seq"
                                        Visible="False" />
                                </Columns>
                                <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                                <RowStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <PagerStyle CssClass="text" BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
                                <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <AlternatingRowStyle BackColor="#F7F7F7" />
                                <PagerSettings PageButtonCount="30" Position="TopAndBottom" />
                            </asp:GridView>
                            <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"
                                SelectCommand="SELECT [xap_effdate], xap_org_id,[xap_ref], [xap_ck_voucher], [xap_seq], [xap_inv_nbr], [xap_open], [xap_ck_curr], [xap_amt], [xap_inv_amt] ,[xap__qad01] as bktxt FROM B2BSupplier.dbo.[Mis_xapinq] WHERE (([xap_vend] = @xap_vend) AND ([xap_open] = @xap_open) AND ([xap_type] = @xap_type) AND (xap_org_id=@xap_org_id) and ([xap_effdate] >= @xap_effdateFrom) AND ([xap_effdate] <= @xap_effdateTo)) order by [xap_effdate] desc">
                                <SelectParameters>
                                    <asp:SessionParameter DefaultValue="" Name="xap_vend" SessionField="company_id" Type="String" />
                                    <asp:Parameter DefaultValue="fals" Name="xap_open" Type="String" />
                                    <asp:Parameter DefaultValue="ck" Name="xap_type" Type="String" />
                                    <asp:Parameter Name="xap_effdateFrom" DefaultValue="" Type="String" />
                                    <asp:Parameter Name="xap_effdateTo" DefaultValue="" Type="String" />
                                    <asp:ControlParameter Name="xap_org_id" ControlID="ddlORG" DefaultValue="ACL" PropertyName="SelectedValue" />
                                </SelectParameters>
                            </asp:SqlDataSource>
                        </td>
                    </tr>
                </table>
                <table runat="server" id="Table2" style="width: 100%">
                    <tr>
                        <td style="width: 100%">
                            <asp:GridView runat="server" ID="gvStockInfo" CssClass="text" BackColor="White" BorderColor="#E7E7FF"
                                BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal" AllowPaging="True"
                                OnRowCommand="gvStockInfo_RowCommand" OnPageIndexChanging="gvStockInfo_PageIndexChanging"
                                AutoGenerateColumns="False" PageSize="20" OnRowDataBound="gvStockInfo_RowDataBound"
                                OnDataBound="gvStockInfo_DataBound" Width="100%">
                                <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                                <RowStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <PagerStyle CssClass="text" BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
                                <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <AlternatingRowStyle BackColor="#F7F7F7" />
                                <PagerSettings PageButtonCount="30" Position="TopAndBottom" />
                                <Columns>
                                    <asp:BoundField DataField="PLANT" HeaderText="PLANT" />
                                    <asp:BoundField DataField="MATERIAL" HeaderText="MATERIAL" />
                                    <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" />
                                    <asp:BoundField DataField="STOCK" HeaderText="STOCK" DataFormatString="{0:N1}" />
                                    <asp:BoundField DataField="DATETIME" HeaderText="DATETIME" />
                                    <asp:ButtonField ButtonType="Button" CommandName="Check" Text="Check" />
                                </Columns>
                            </asp:GridView>
                        </td>
                        <td>
                        </td>
                        <td>
                            <asp:GridView runat="server" ID="gvInventoryInfo" CssClass="text" BackColor="White"
                                BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal"
                                AutoGenerateColumns="False" PageSize="20" AllowPaging="True" OnPageIndexChanging="gvInventoryInfo_PageIndexChanging"
                                OnRowDataBound="gvInventoryInfo_RowDataBound" Width="100%">
                                <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                                <RowStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <PagerStyle CssClass="text" BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
                                <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                <AlternatingRowStyle BackColor="#F7F7F7" />
                                <PagerSettings PageButtonCount="30" Position="TopAndBottom" />
                                <Columns>
                                    <asp:BoundField DataField="MATNR" HeaderText="Material" />
                                    <asp:BoundField DataField="WERKS" HeaderText="Plant" />
                                    <asp:BoundField DataField="VFDAT" HeaderText="Date " />
                                    <asp:BoundField DataField="MENGE" HeaderText="Qty" />
                                    <asp:BoundField DataField="SGTXT" HeaderText="Category" />
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <!--Buffer-->
            </td>
        </tr>
    </table>
    <asp:TextBox ID="txtMaterial" runat="server" Visible="False"></asp:TextBox>
    <asp:TextBox ID="txtPlant" runat="server" Visible="False"></asp:TextBox>
</asp:Content>
