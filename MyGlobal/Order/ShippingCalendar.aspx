<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Shipping Calendar" Culture="en-US"   %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">
    Dim tYear As String = "Year", tMonth As String = "Month"
    
    Dim tbotitle1 As String = "My B2B Order"
    Dim tBOTitle2 As String = "Backorder"
    Dim tBOTitle As String = "Shipping Calender"
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim SelDate As Date
        If Not Page.IsPostBack Then
            Dim intToYear As Integer = Now.Year + 10
            For i As Integer = 1990 To intToYear
                Me.DlYear.Items.Add(New ListItem(i.ToString(), i.ToString()))
            Next
            Me.DlYear.SelectedValue = Now.Year.ToString()
            Me.DlMonth.SelectedValue = Now.Month.ToString()
            DataBind()
        End If
        SelDate = Me.DlYear.Text.ToString & "-" & Me.DlMonth.SelectedValue.ToString & "-" & "01"
        cal1.VisibleDate = SelDate
        If Session("org_id") Is Nothing OrElse Session("org_id") = "" Then Session("org_id") = "EU10"
        
    End Sub
    Protected Sub cal1_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
       
    End Sub

    Protected Sub cal1_DayRender(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DayRenderEventArgs)
      
        Dim d As CalendarDay = e.Day, c As TableCell = e.Cell, p1 As New Panel, gv1 As New GridView, dt As New DataTable
        'ming add 
    
        ' end
        c.Controls.Clear() : dt.Columns.Add("part_no") : dt.Columns.Add("dd")      
        With p1
            .ScrollBars = ScrollBars.Auto : .Width = New Unit(110, UnitType.Pixel) : p1.Height = New Unit(100, UnitType.Pixel)
        End With     
        gv1.ShowHeader = False        
        c.Controls.Add(p1)
        Dim rs() As DataRow = CType(ViewState("DDTable"), DataTable).Select(String.Format("duedate='{0}'", d.Date.ToString("yyyyMMdd")))     
      '  Dim dayRow As DataRow = dt.NewRow() : dayRow.Item(0) = d.Date.Day.ToString() : dt.Rows.Add(dayRow)
        If rs IsNot Nothing AndAlso rs.Length > 0 Then
            For Each r As DataRow In rs
                Dim r2 As DataRow = dt.NewRow
                r2.Item("part_no") = r.Item("ProductId") : r2.Item("dd") = d.Date.ToString("yyyy-MM-dd") : dt.Rows.Add(r2)
            Next
        End If
      '  AddHandler gv1.RowDataBound, AddressOf gv1_rowDataBind
        '  gv1.DataSource = dt : gv1.DataBind() : p1.Controls.Add(gv1)
        ' ming add
        c.Text = "<div class=""text_mini"">"
        If d.IsWeekend Then
          
            c.Text = c.Text + "<span class=""span1"">  <font color=""Silver"">" + d.Date.Day.ToString + "</font></span><br>"
        Else
            c.Text = c.Text + "<span class=""span1"">" + d.Date.Day.ToString + "</span><br>"
        End If
     
        Dim sb As New StringBuilder
        If dt.Rows.Count > 0 Then
            c.Text = c.Text + "<span class=""span2"">" + dt.Rows.Count.ToString + " items</span><br>"
            With sb
                sb.AppendFormat("<div class=""hid""><ul>")
                For i As Integer = 0 To dt.Rows.Count - 1
                    sb.AppendFormat("<li><a target=""_blank"" href='BO_BackorderInquiry.aspx?txtPN={0}&txtOrderDateFrom={1}' >{0}</a></li>", dt.Rows(i).Item("part_no").ToString, dt.Rows(i).Item("dd").ToString)
                Next
                sb.AppendFormat("</ul></div>")
            End With
        Else
            c.Text = c.Text + "<span class=""span2""></span><br>"
        End If
        c.Text = c.Text + sb.ToString + "</div>"
        ' ming end
        With gv1
            .Width = New Unit(110, UnitType.Pixel) : .BorderWidth = New Unit(0, UnitType.Pixel)
            .HorizontalAlign = HorizontalAlign.Center
            If Not d.IsOtherMonth Then
                .CssClass = "text_mini"
            End If
        End With
    End Sub

    Protected Sub cal1_VisibleMonthChanged(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MonthChangedEventArgs)
        SetBackOrderOfVisibleMonth()
    End Sub

    Private Sub SetBackOrderOfVisibleMonth()
        If ViewState("DDTable") Is Nothing Then
            ViewState("DDTable") = New DataTable
        Else
            CType(ViewState("DDTable"), DataTable).Clear()
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select * from SAP_BACKORDER_AB where BILLTOID='" + Session("company_id") + "' and DUEDATE between '{0}' and '{1}'", cal1.VisibleDate.ToString("yyyy-MM-01"), Util.GetLastDateOfMonth(cal1.VisibleDate).ToString("yyyy-MM-dd")))
        ViewState("DDTable") = dt
    End Sub
        
    Protected Sub cal1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            cal1.VisibleDate = Now : SetBackOrderOfVisibleMonth()
        End If
        cal1.VisibleDate = Me.DlYear.Text.ToString & "-" & Me.DlMonth.SelectedValue.ToString & "-" & "01" : SetBackOrderOfVisibleMonth()
    End Sub
    
    Protected Sub gv1_rowDataBind(ByVal sender As Object, ByVal e As GridViewRowEventArgs)
        If e.Row.RowIndex <> 0 Then
            e.Row.HorizontalAlign = HorizontalAlign.Left
        End If
        e.Row.Cells(1).Visible = False
        If e.Row.RowType <> DataControlRowType.Header And e.Row.RowType <> DataControlRowType.Footer And e.Row.RowIndex <> 0 Then
            e.Row.Cells(0).Text = "<a href='BO_BackorderInquiry.aspx?txtPN=" & e.Row.Cells(0).Text & "&txtOrderDateFrom=" & e.Row.Cells(1).Text & "' >" & e.Row.Cells(0).Text & "</a>"
        End If
    End Sub

   
    Protected Sub btimg_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)

    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="btimg">

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script> 
<div class="root">
    <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
    >
    <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx" Text="Order Tracking" />
    > A/P Inquiry
</div>
<style type="text/css">
    .shiipping_tab { clear: left; }
     ul, li { margin: 0; padding: 0; list-style:  none; font-family:Arial, Helvetica, sans-serif; font-size:12px; font-weight:bold;} 
     ul.tabs { width: 100%; height: 35px; border-bottom: 3px solid #d3d3d3;
    border-left: 1px solid #d3d3d3; } ul.tabs li { text-align:center; padding-top:4px;
    width:70px; float: left; height: 30px; line-height: 12px; overflow: hidden;
    position: relative; margin-bottom: -1px; /* 讓 li 往下移來遮住 ul 的部份 border-bottom
    */ border: 1px solid #d3d3d3; border-left: none; background-color: #ebebeb;
    } 
    ul.tabs li.active { color:#000; border-bottom: 5px solid #fff; background-color:#FFFFFF;} 
    div.tab_container { width: 100%; border: 1px solid #d3d3d3; /*border-top:none;  background: #fff;*/ } 
    div.tab_container .tab_content { font-size:12px; color:#5b5b5c; font-family:Arial, Helvetica, sans-serif; clear: left; }
    div.tab_container .tab_content h2 { font-size:16px; color:#000; font-family:Arial,Helvetica, sans-serif; margin: 0 0 5px; }
     .text_mini{ cursor: pointer; } 
    .text_mini .span1 { font-size: 20px; font-weight: bold; color: #000000; } 
    .text_mini .span2 { font-size: 13px; color: #FF0000; margin-top:10px;} 
    .text_mini .hid{ z-index:10; position:absolute; display:none;} .text_mini
    .hid ul {border: 1px solid #CCCCCC; background-color: #FFFFCC; float: left;
    width:160px; margin:0; padding:0; padding-top:10px; padding-bottom:10px; } 
    .text_mini .hid li { line-height:24px; margin-right: 5px; margin-left: 8px; float: left; }
    #tablediv
    {
        float: right;
	    margin-right: 15px;
	    height: 25px;
	    vertical-align: middle;
	    position: relative;
	    width: 100%;
	   
	    text-align: right;
	    margin-top:6px;
	  
	 }
</style>
<script type="text/javascript">
    $(function () {
        $(".text_mini").hover(
    function () {

        $(this).parent().css("backgroundColor", "#FFFFCC");
        $(this).children(".hid").css("left", jQuery(this).parent().offset().left + jQuery(this).outerWidth());
        $(this).children(".hid").css("top", jQuery(this).parent().offset().top); //+ jQuery(this).outerHeight() #333399
        $(this).children(".hid").show();
    },
  function () {
      $(this).children(".hid").hide();
      $(this).parent().css("backgroundColor", "");
  }
);
    });
</script> 
<div class="left" style="width:170px;">
    <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="ShippingCalendar" />
</div>
<div class="right" style="width:707px;">
    <table border="0" cellpadding="0" cellspacing="0" width="99%">
        <tr>
            <td colspan="2" class="h2">
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="12" valign="top">
                            <img src="../images/point.gif" width="7" height="14" />
                        </td>
                        <td>
                            Shipping Calendar
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
            </td>
            <td align="left">
               <%-- <div class="shiipping_tab" >
                    <ul class="tabs">
                        <li>
                            <a href="BO_BackOrderInquiry.aspx?company_id=<%=session(" company_id") %>">
                                Backorder
                            </a>
                        </li>
                        <li>
                            <a href="BO_B2BOrderInquiry.aspx?company_id=<%=session(" company_id") %>">
                                My B2B Order
                            </a>
                        </li>
                        <li class="active">
                            <a href="#">
                                Shipping Calendar
                            </a>
                        </li>
                        <li>
                            <a href="/Order/BO_OrderTracking.aspx?company_id=<%=session(" company_id ") %>">
                                Order Tracking
                            </a>
                        </li>
                        <li>
                            <a href="/Order/BO_InvoiceInquiry.aspx?company_id=<%=session(" company_id") %>">
                                Invoice Inquiry
                            </a>
                        </li>
                        <li>
                            <a href="/Order/ARInquiry_WS.aspx?company_id=<%=session(" company_id ") %>">
                                A/P Inquiry
                            </a>
                        </li>
                        <li>
                            <a href="/Order/MyRMA.aspx?company_id=<%=session(" company_id ") %>">
                                My RMA Order
                            </a>
                        </li>
                        <li>
                            <a href="/order/BO_SerialInquiry.aspx?company_id=<%=session(" company_id ") %>">
                                S/N Inquiry
                            </a>
                        </li>
                        <li>
                            <a href="/order/BO_forwardertracking.aspx?company_id=<%=session(" company_id ") %>">
                                Forwarder Tracking
                            </a>
                        </li>
                    </ul>
                </div>--%>
                <div class="tab_container"  >
                    <div class="tab_content">
                       
                        <div id="tablediv" class="text" >
                            <%=tYear%>  :  <asp:DropDownList runat="server" ID="DlYear" AutoPostBack="false" />                       
                            <%=tMonth%>  :
                                            <asp:DropDownList runat="server" ID="DlMonth" AutoPostBack="false">
                                            <asp:ListItem Text="January" Value="1" />
                                            <asp:ListItem Text="February" Value="2" />
                                            <asp:ListItem Text="March" Value="3" />
                                            <asp:ListItem Text="April" Value="4" />
                                            <asp:ListItem Text="May" Value="5" />
                                            <asp:ListItem Text="June" Value="6" />
                                            <asp:ListItem Text="July" Value="7" />
                                            <asp:ListItem Text="August" Value="8" />
                                            <asp:ListItem Text="Spetember" Value="9" />
                                            <asp:ListItem Text="October" Value="10" />
                                            <asp:ListItem Text="November" Value="11" />
                                            <asp:ListItem Text="December" Value="12" />
                                           </asp:DropDownList>
                       <span style="vertical-align: bottom;"><asp:ImageButton runat="server" ID="btimg" ImageUrl="../images/searchnew01.gif" OnClick="btimg_Click" /> </span>                        
                        </div><br /><br />
                        <asp:Panel runat="server" ID="Panel1">
                            <!--Start-->
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <asp:Calendar runat="server" ID="cal1" Width="100%" Height="550px" OnDataBinding="cal1_DataBinding"
                                        OnDayRender="cal1_DayRender" OnVisibleMonthChanged="cal1_VisibleMonthChanged"
                                        OnLoad="cal1_Load" BackColor="White" BorderColor="White" BorderWidth="1px"
                                        Font-Names="Verdana" Font-Size="9pt" ForeColor="Black" NextPrevFormat="CustomText"
                                        PrevMonthText="<<" NextMonthText=">>">
                                            <SelectedDayStyle BackColor="#333399" ForeColor="White" />
                                            <TodayDayStyle BackColor="#E5ECF9" />
                                            <OtherMonthDayStyle ForeColor="#999999" />
                                            <NextPrevStyle Font-Bold="True" Font-Size="8pt" ForeColor="#333333" VerticalAlign="Bottom"
                                            />
                                            <DayHeaderStyle Font-Bold="True" Font-Size="8pt" />
                                            <TitleStyle BackColor="#ebebeb" BorderColor="#ebebeb" BorderWidth="1px"
                                            Font-Bold="True" Font-Size="12pt" ForeColor="Black" />
                                        </asp:Calendar>
                                    </td>
                                </tr>
                            </table>
                            <!--end-->
                        </asp:Panel>
                    </div>
                </div>
            </td>
        </tr>
    
</div>       
</asp:Panel>
</asp:Content>