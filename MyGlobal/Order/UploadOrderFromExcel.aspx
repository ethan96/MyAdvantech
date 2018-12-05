<%@ Page Title="Upload Order Data From Excel" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim mycart As New CartList("b2b", "cart_detail_v2")
    Sub initDT(ByRef DT As DataTable)
        DT.Columns.Add("Part No")
        DT.Columns.Add("Qty")
        DT.Columns.Add("SAP Product Status")
        DT.Columns.Add("MOQ")
        DT.Columns.Add("Blocked Reason")
        'DT.Columns.Add("Extended Warranty")
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Response.Write("A:" + AuthUtil.IsCanPlaceOrder(Session("user_id")).ToString)
            If Util.IsInternalUser(Session("user_id")) = False Then
                'If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
                If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then Response.Redirect("~/home.aspx")
            End If
            Dim dt As New DataTable
            initDT(dt)
            Me.gv1.DataSource = dt
            Me.gv1.DataBind()
        End If

    End Sub

    Protected Sub btnImPort_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            import()
        Catch ex As Exception
            If Me.FileUpload1.PostedFile.ContentLength > 0 Then
                Util.SendEmailWithAttachment("eBusiness.AEU@advantech.eu", "eBusiness.AEU@advantech.eu", "UploadOrderFromExcel.aspx : Error reading excel to dt", _
                              ex.ToString(), True, "", "ming.zhao@advantech.com.cn", New System.IO.MemoryStream(Me.FileUpload1.FileBytes), FileUpload1.PostedFile.FileName)
            End If
        End Try
    End Sub

    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim filename As System.IO.Stream = upload()
        If Not IsNothing(filename) Then
            preview(filename)
        End If
    End Sub
    Function upload() As System.IO.Stream
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            'Me.FileUpload1.SaveAs(fileName)
            Return MSM
        End If
        Return Nothing
    End Function
    Sub import()
        Dim CartId As String = Session("cart_id").ToString.Trim
        If Not IsNothing(ViewState("Cart")) Then
            Dim dttemp As DataTable = CType(ViewState("Cart"), DataTable)
            If dttemp.Rows.Count <= 0 Then
                Glob.ShowInfo("No data be uploaded.")
                Exit Sub
            End If

            Dim dt As New DataTable
            initDT(dt)

            For Each r As DataRow In dttemp.Rows
                Dim rr As DataRow = dt.NewRow
                rr.Item("Part No") = r.Item(0)
                rr.Item("Qty") = r.Item(1)

                'Only add items to cart if it's not blocked
                If String.IsNullOrEmpty(r.Item(4)) Then
                    dt.Rows.Add(rr)
                End If
            Next

            If dt.Rows.Count > 0 Then
                MyCartX.DeleteCartAllItem(CartId)
                Dim ReqDate As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
                ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), Session("org_id"))
                Dim msg As String = String.Empty
                For Each r As DataRow In dt.Rows
                    Dim partNo As String = r.Item("Part No")
                    Dim qty As Integer = r.Item("Qty")
                    Dim EWFLAG As Integer = 0
                    msg = ""
                    'mycart.ADD2CART_V2(CartId, partNo, qty, EWFLAG, 0, "", 1, 1, ReqDate, "", "", 0, False)
                    MyCartOrderBizDAL.Add2Cart_BIZ(CartId, partNo, qty, EWFLAG, 0, "", 1, 1, ReqDate, "", "", 0, False, msg)
                Next
            End If
            Response.Redirect("~/Order/Cart_listV2.aspx")
        End If
    End Sub

    Sub preview(ByVal fileName As System.IO.Stream)
        Dim CartId As String = Session("cart_id").ToString.Trim
        Dim tempdt As DataTable = Util.ExcelFile2DataTable(fileName, 1, 0)
        If tempdt.Rows.Count <= 0 Then
            Glob.ShowInfo("No data be uploaded.")
            Exit Sub
        End If
        If tempdt.Columns.Count < 2 Then
            Glob.ShowInfo("The uploaded excel file is in invalid format. Please download and use sample excel file.")
            Exit Sub
        End If

        Dim dt As New DataTable
        initDT(dt)
        Dim ReqDate As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), Session("org_id"))

        Dim DefaultShipto As String = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), CartId)
        Dim CountryCode As String = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)

        For Each r As DataRow In tempdt.Rows
            Dim rr As DataRow = dt.NewRow
            rr.Item("Part No") = r.Item(0)
            rr.Item("Qty") = r.Item(1)
            If Convert.ToString(rr.Item("Part No")).Trim <> "" And Convert.ToString(rr.Item("Qty")).Trim <> "" Then
                Dim EWFLAG As Integer = 0, msg As String = String.Empty, line_no As Integer = 0
                line_no = MyCartOrderBizDAL.Add2Cart_BIZ(CartId, rr.Item("Part No"), rr.Item("Qty"), EWFLAG, 0, "", 1, 1, ReqDate, "", "", 0, False, msg)
                Dim productdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select TOP 1 PRODUCT_STATUS, MIN_ORDER_QTY from SAP_PRODUCT_STATUS where PART_NO = '{0}' and SALES_ORG='{1}' ", rr.Item("Part No"), Session("org_id")))
                If productdt.Rows.Count > 0 Then
                    rr.Item("SAP Product Status") = Convert.ToString(productdt.Rows(0).Item("PRODUCT_STATUS"))
                    rr.Item("MOQ") = Convert.ToInt32(productdt.Rows(0).Item("MIN_ORDER_QTY"))
                End If
                MyCartX.DeleteCartItem(CartId, line_no)
                rr.Item("Blocked Reason") = msg

                'Ryan 20171027 Put Invalid parts validation here
                Dim refmsg As String = String.Empty
                If Advantech.Myadvantech.Business.PartBusinessLogic.IsInvalidParts(Session("company_id").ToString(), Session("org_id").ToString, rr.Item("Part No"),
                     Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), CountryCode, Util.IsInternalUser(Session("user_id")), refmsg) Then
                    rr.Item("Blocked Reason") = refmsg
                End If

                dt.Rows.Add(rr)
            Else
                Glob.ShowInfo("Part No or Qty data should not be empty.")
                Exit Sub
            End If
        Next
        Me.gv1.DataSource = dt
        ViewState("Cart") = dt
        Me.gv1.DataBind()
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(ViewState("Cart")) Then
            Try
                Dim dt As DataTable = CType(ViewState("Cart"), DataTable)
                If dt.Rows.Count > 0 Then
                    Me.btnImPort.Visible = True
                End If
            Catch ex As Exception

            End Try
        End If
    End Sub

    Protected Sub gv1_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If (e.Row.RowType = DataControlRowType.DataRow) Then
            If (Convert.ToString(e.Row.Cells(4).Text) <> "") Then
                e.Row.Cells(4).ForeColor = System.Drawing.Color.Red
                e.Row.Cells(4).Font.Bold = True
            End If
        End If


    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td class="menu_title">
                Upload Order File to Cart
            </td>
            <td width="200" height="25" valign="middle">
                <asp:HyperLink runat="server" ID="HL1" NavigateUrl="~/order/UploadOrderFromExcel_Adv.aspx" Font-Bold="True" Font-Underline="True">Advanced Upload Function</asp:HyperLink>
            </td>
        </tr>
        <tr>
            <td colspan="2" >
                <table>
                    <tr>
                        <td style="border: 1px solid #d7d0d0; padding: 10px">
                            <asp:FileUpload ID="FileUpload1" runat="server" />
                            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <p style="margin-left: 10px">
        <b>Use this interface to upload your order via a MS Excel spreadsheet, listing product
            numbers and quantities. </b>
        <br />
        <br />
        1. Fill out the spreadsheet with the columns as shown below. (Note: It is necessary
        to use the full Advantech product numbers. Ex.: AIMB-554G2-00A1E)
        <br />
        2. Choose the File Format of your upload
        <br />
        3. Click "Browse" to choose the file on your system
        <br />
        4. Once selected, click "Upload"
    </p>
    <asp:GridView runat="server" ID="gv1" Width="100%" AllowPaging="false" AutoGenerateColumns="true"
        ShowHeaderWhenEmpty="true" OnRowDataBound="gv1_RowDataBound">
    </asp:GridView>
    <table width="100%">
        <tr>
            <td align="center">
                <asp:Button ID="btnImPort" runat="server" Text="Import2Cart" OnClick="btnImPort_Click" Visible="false"/>
            </td>
        </tr>
    </table>
    <hr />
    <table>
      <tr>
    <td>
   <asp:HyperLink NavigateUrl="~/files/CartSample.xls" runat="server" ID="HLKExcelSample" Text="Click Here for Downloadable Sample (MS Excel)"></asp:HyperLink>
    </td>
    </tr>
    <tr>
    <td>
   <asp:Image ImageUrl="~/files/excelSample.png" runat="server" ID="imgExcelSample" />
    </td>
    </tr>
    </table>

    <div class="loading" align="center">
        Loading. Please wait.<br />
        <br />
        <img src="../Images/loading.gif" alt="" />
    </div>

    <style type="text/css">
        .modal
        {
            position: fixed;
            top: 0;
            left: 0;
            background-color: black;
            z-index: 99;
            opacity: 0.8;
            filter: alpha(opacity=80);
            -moz-opacity: 0.8;
            min-height: 100%;
            width: 100%;
        }
        .loading
        {
            font-family: Arial;
            font-size: 10pt;
            border: 5px solid #F49600;
            width: 200px;
            height: 100px;
            display: none;
            position: fixed;
            background-color: White;
            z-index: 999;
        }
    </style>

    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript">
        function ShowProgress() {
            setTimeout(function () {
                var modal = $('<div />');
                modal.addClass("modal");
                $('body').append(modal);
                var loading = $(".loading");
                loading.show();
                var top = Math.max($(window).height() / 2 - loading[0].offsetHeight / 2, 0);
                var left = Math.max($(window).width() / 2 - loading[0].offsetWidth / 2, 0);
                loading.css({ top: top, left: left });
            }, 200);
        }
        $('#<%=btnUpload.ClientID %> , #<%=btnImPort.ClientID %>').click(function () {
            ShowProgress();
        });
    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
