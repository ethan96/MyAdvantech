<%@ Page Title="MyAdvantech - AJP BTOS Orders" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("q") IsNot Nothing Then
            Dim txtKey = Trim(Context.Request("q"))
            Dim SOList As New List(Of PairObject)
            Dim MatchedSOs = GetSONo(txtKey, 1)
            For Each MatchedSO In MatchedSOs
                SOList.Add(New PairObject(MatchedSO, MatchedSO))
            Next
            Dim jsr As New Script.Serialization.JavaScriptSerializer, retJson As String = jsr.Serialize(SOList)
            If Request("callback") IsNot Nothing Then
                retJson = Context.Request("callback") + "(" + retJson + ")"
            End If
            Response.Clear() : Response.Write(retJson) : Response.End()
        End If

        If Not Page.IsPostBack Then
            txtFromDate.Text = Now.ToString("yyyy/MM/dd")
            txtToDate.Text = Now.AddDays(7).ToString("yyyy/MM/dd")
            'GetBTOSList()
        End If
    End Sub

    Public Class PairObject
        Public Property id As String : Public Property name As String
        Public Sub New(ByVal k As String, ByVal v As String)
            Me.id = k : Me.name = v
        End Sub
    End Class

    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function GetSONo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Replace(RemovePrecedingZeros(Trim(prefixText)), "'", "''"), "*", "%").ToUpper()
        If IsNumeric(prefixText.Substring(0, 1)) Then prefixText = "000" + prefixText
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format(
          " select distinct a.vbeln from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln where a.vbeln like '{0}%' and a.vkorg='JP01' and b.matnr like '%-BTO' and rownum<=10 order by a.vbeln desc ", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = RemovePrecedingZeros(dt.Rows(i).Item(0))
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub btnDLPDF_Click(ByVal sender As Object, e As EventArgs)
        Dim sono = CType(CType(sender, LinkButton).NamingContainer.FindControl("hdRowSONO"), HiddenField).Value
        Dim lineno = CType(CType(sender, LinkButton).NamingContainer.FindControl("hdRowLineNo"), HiddenField).Value
        GetQuotePDF(sono + "," + lineno)
    End Sub

    Public Shared Function GetQuotePDF(ByVal SOLINENO As String) As String
        Dim pageHolder As New TBBasePage()
        pageHolder.IsVerifyRender = False

        Dim ControlURL As String = "~/Order/AJPBTOSTemplate.ascx"

        Dim cw1 As UserControl = DirectCast(pageHolder.LoadControl(ControlURL), UserControl)
        Dim viewControlType As Type = cw1.GetType

        'Get control property as a object and set its value
        Dim p_QuoteId As Reflection.PropertyInfo = viewControlType.GetProperty("SO_LINE_NO")
        p_QuoteId.SetValue(cw1, SOLINENO, Nothing)

        'Dim _meth As Reflection.MethodInfo = viewControlType.GetMethod("LoadData")
        '_meth.Invoke(cw1, Nothing)
        pageHolder.Controls.Add(cw1)
        Dim output As New IO.StringWriter()
        HttpContext.Current.Server.Execute(pageHolder, output, False)
        'Return output.ToString()

        Dim bt As Byte() = Util.GetPdfBytesFromHtmlString(output.ToString())
        HttpContext.Current.Response.Clear()
        HttpContext.Current.Response.AddHeader("Content-Type", "binary/octet-stream")
        HttpContext.Current.Response.AddHeader("Content-Disposition", "attachment; filename=" + Split(SOLINENO, ",")(0) + ".pdf;size = " + bt.Length.ToString())
        HttpContext.Current.Response.Flush()
        HttpContext.Current.Response.BinaryWrite(bt)
        HttpContext.Current.Response.Flush()
        HttpContext.Current.Response.End()

    End Function


    Protected Sub btnSearchSO_Click(sender As Object, e As System.EventArgs)
        GetBTOSList()
    End Sub

    Sub GetBTOSList()
        Dim p As New SAP_SFIS_RFC.SAP_SFIS_RFC
        Dim soItemTable As New SAP_SFIS_RFC.ZSOITEMTable, soHeaderTable As New SAP_SFIS_RFC.ZWOHEADERTable
        Dim custIdTable As New SAP_SFIS_RFC.ZCUSTIDTable
        p.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        Dim dt As DataTable = Nothing, dtHeader As DataTable = Nothing
        Dim isCTOSOrderOnly As String = "X"
        Dim querySONoTo As String = String.Empty
        Dim querySONoFrom As String = "" : If Trim(txtSearchSONOFrom.Text).Length >= 7 Then querySONoFrom = Trim(txtSearchSONOFrom.Text.ToUpper())
        If Trim(txtSearchSONOTo.Text).Length >= 7 Then
            querySONoTo = Trim(txtSearchSONOTo.Text.ToUpper())
        End If
        Dim qWorkCenter = ""
        Dim DlvPlant = "JPH1"

        Dim PrefDateFormat As String = "yyyy/MM/dd", cult As New System.Globalization.CultureInfo("en-US")
        Dim FromDate As Date = Date.MinValue, ToDate As Date = Date.MaxValue

        If Date.TryParseExact(txtFromDate.Text, PrefDateFormat, cult, System.Globalization.DateTimeStyles.None, Now) Then
            FromDate = Date.ParseExact(txtFromDate.Text, PrefDateFormat, cult)
        Else
            FromDate = Now
        End If

        If Date.TryParseExact(txtToDate.Text, PrefDateFormat, cult, System.Globalization.DateTimeStyles.None, Now) Then
            ToDate = Date.ParseExact(txtToDate.Text, PrefDateFormat, cult)
        Else
            ToDate = Now.AddDays(7)
        End If
        txtFromDate.Text = FromDate.ToString(PrefDateFormat) : txtToDate.Text = ToDate.ToString(PrefDateFormat)
        Dim dtSOList As DataTable = Nothing
        p.Connection.Open()
        If (querySONoFrom = String.Empty Or querySONoTo = String.Empty) And txtSONumbers.Text = String.Empty Then
            p.Zget_Dashboard_For_Sfis(isCTOSOrderOnly, "", "", "", querySONoFrom, "", "", DlvPlant, "", qWorkCenter, "1", "", ToDate.ToString("yyyy/MM/dd"), FromDate.ToString("yyyy/MM/dd"), "", custIdTable, soItemTable, soHeaderTable)
            Dim ListSOItems As New List(Of SAP_SFIS_RFC.ZSOITEM)
            For Each soItem As SAP_SFIS_RFC.ZSOITEM In soItemTable
                If soItem.Matnr.EndsWith("BTO") Then
                    ListSOItems.Add(soItem)
                End If
            Next
            dtSOList = Util.ListToDataTable(Of SAP_SFIS_RFC.ZSOITEM)(ListSOItems)
        Else
            dtSOList = New DataTable
            Dim dtSORange As New DataTable
            If querySONoFrom <> String.Empty Or querySONoTo <> String.Empty Then
                Dim SOSql =
                " select a.vbeln  " +
                " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln  " +
                " where a.vkorg='JP01' and b.matkl='BTOS' "
                If querySONoFrom <> String.Empty Then
                    SOSql += " and a.vbeln>='" + FormatToSAPSODNNo(querySONoFrom) + "' "
                End If

                If querySONoTo <> String.Empty Then
                    SOSql += " and a.vbeln<='" + FormatToSAPSODNNo(querySONoTo) + "' "
                End If

                SOSql += " and rownum<=30 group by a.vbeln order by a.vbeln "
                dtSORange = OraDbUtil.dbGetDataTable("SAP_PRD", SOSql)
            End If

            If txtSONumbers.Text <> String.Empty Then
                If dtSORange.Rows.Count = 0 Then dtSORange.Columns.Add("vbeln")
                Dim SONumbers = Split(txtSONumbers.Text, ";") ', SOAry As New ArrayList
                For Each SO In SONumbers
                    Dim nr = dtSORange.NewRow()
                    nr.Item("vbeln") = SO
                    dtSORange.Rows.Add(nr)
                Next

            End If

            Dim ListSOItems As New List(Of SAP_SFIS_RFC.ZSOITEM)
            For Each SONoRow As DataRow In dtSORange.Rows
                p.Zget_Dashboard_For_Sfis("X", "", "", "", SONoRow.Item("vbeln"), "", "", DlvPlant, "", qWorkCenter, "1", "", ToDate.ToString("yyyy/MM/dd"), FromDate.ToString("yyyy/MM/dd"), "", custIdTable, soItemTable, soHeaderTable)
                'dtSOList.Merge(soItemTable.ToADODataTable())
                For Each soItem As SAP_SFIS_RFC.ZSOITEM In soItemTable
                    Dim IsSOExist = From q In ListSOItems Where q.Vbeln = soItem.Vbeln And q.Posnr = soItem.Posnr
                    If IsSOExist.Count = 0 AndAlso soItem.Matnr.EndsWith("-BTO") Then
                        ListSOItems.Add(soItem)
                    End If
                Next
            Next
            dtSOList = Util.ListToDataTable(Of SAP_SFIS_RFC.ZSOITEM)(ListSOItems)

        End If

        p.Connection.Close()
        dtSOList.Columns.Add("ShipToAddr") : dtSOList.Columns.Add("SalesNote")

        For Each SORow As DataRow In dtSOList.Rows
            Dim Sql =
            " select b.title, b.name1, b.name_co, b.post_code1 , b.street, b.tel_number " +
            " from saprdp.vbpa a " +
            " inner join saprdp.adrc b on a.land1=b.country and a.adrnr=b.addrnumber " +
            " where a.vbeln='" + FormatToSAPSODNNo(SORow.Item("vbeln")) + "' and a.parvw='WE'  "
            Dim dtShipTo = OraDbUtil.dbGetDataTable("SAP_PRD", Sql), sbShipToAddr As String = ""
            If dtShipTo.Rows.Count > 0 Then
                sbShipToAddr =
                    dtShipTo.Rows(0).Item("name1") + "<br/>" + dtShipTo.Rows(0).Item("post_code1") +
                    "<br/>" + dtShipTo.Rows(0).Item("street") + "<br/>" + dtShipTo.Rows(0).Item("name_co") + "<br/>TEL:" + dtShipTo.Rows(0).Item("tel_number")
            End If
            SORow.Item("ShipToAddr") = sbShipToAddr
            SORow.Item("SalesNote") = GetSOSalesNote(SORow.Item("vbeln"))
        Next

        gvSO.DataSource = dtSOList : gvSO.DataBind()

        If ViewState("SOList") Is Nothing Then
            ViewState("SOList") = New DataTable
        Else
            CType(ViewState("SOList"), DataTable).Clear()
        End If
        ViewState("SOList") = dtSOList

    End Sub

    Public Shared Function FormatToSAPSODNNo(ByVal str As String) As String
        If String.IsNullOrEmpty(str) Then Return ""
        str = UCase(str)
        If Not Decimal.TryParse(str.Substring(0, 1), 0) Then Return str
        While str.Length < 10
            str = "0" + str
        End While
        Return str
    End Function

    Public Shared Function RemovePrecedingZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        If str.Length > 1 Then
            Return RemovePrecedingZeros(str.Substring(1))
        Else
            Return str
        End If
    End Function

    Public Shared Function GetSOSalesNote(SoNo As String) As String
        '20140512 Change to ZEOP (EU OP Note), or remain 0001 (Saels Note from customer)
        Dim tdid As String = "0001"
        Dim apt As New Oracle.DataAccess.Client.OracleDataAdapter(
  " select tdid, tdname, tdspras from saprdp.stxl where mandt='168' and relid='TX' and tdobject='VBBK' " +
  " and tdname='" + FormatToSAPSODNNo(RemovePrecedingZeros(Replace(Trim(SoNo), "'", "''"))) + "' and tdid='" + tdid + "' and srtf2>=0",
  New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString))
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()

        If dt.Rows.Count > 0 Then
            Dim eup As New Z_READ_TEXT.Z_READ_TEXT, header As New Z_READ_TEXT.THEAD, lines As New Z_READ_TEXT.TLINETable
            eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            eup.Connection.Open()
            eup.Zread_Text(0, "168", dt.Rows(0).Item("TDID"), dt.Rows(0).Item("tdspras"), "", dt.Rows(0).Item("TDNAME"), "VBBK", header, lines)
            eup.Connection.Close()
            Dim sb As New System.Text.StringBuilder
            For Each line As Z_READ_TEXT.TLINE In lines
                sb.Append(line.Tdline + vbCrLf)
            Next
            Return sb.ToString()
        Else
            Return ""
        End If
    End Function

    Protected Sub gvSO_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gvSO.PageIndex
        gvSO.DataSource = SortDataTable(ViewState("SOList"), False) : gvSO.DataBind() : gvSO.PageIndex = pageIndex
        ScriptManager.RegisterStartupScript(upSO, upSO.GetType(), "calcTotalGRQty", "calcTotalGRQty();", True)
    End Sub

    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    If String.Equals(GridViewSortExpression, "Vbeln", StringComparison.CurrentCultureIgnoreCase) Or
                        String.Equals(GridViewSortExpression, "Name1", StringComparison.CurrentCultureIgnoreCase) Then
                        If String.Equals(GridViewSortExpression, "Vbeln", StringComparison.CurrentCultureIgnoreCase) Then
                            dataView.Sort = "Vbeln " + GetSortDirection() + ", Posnr asc"
                        ElseIf String.Equals(GridViewSortExpression, "Name1", StringComparison.CurrentCultureIgnoreCase) Then
                            dataView.Sort = "Name1 " + GetSortDirection() + ", Vbeln asc, Posnr asc"
                        End If
                    Else
                        dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                    End If

                End If
            End If
            Return dataView
        Else
            Return New DataView()
        End If
    End Function

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") Is Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") Is Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property

    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function

    Sub GridView_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim gvBTOSComp = CType(e.Row.FindControl("gvBTOSComp"), GridView)
            If e.Row.DataItemIndex = 0 Then gvBTOSComp.ShowHeader = True
            Dim SONO = FormatToSAPSODNNo(CType(e.Row.FindControl("hdRowSONO"), HiddenField).Value)
            Dim LineNo = "000" + CType(e.Row.FindControl("hdRowLineNo"), HiddenField).Value
            Dim Sql As String =
       " select b.posnr, b.matnr, b.kwmeng " +
       " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln " +
       " where a.mandt='168' and b.mandt='168' " +
       " and a.vkorg='JP01' and a.vbeln='" + SONO + "' and uepos='" + LineNo + "' " +
       " order by b.posnr "
            Dim dtBTOSItems = OraDbUtil.dbGetDataTable("SAP_PRD", Sql)
            gvBTOSComp.DataSource = dtBTOSItems : gvBTOSComp.DataBind()
        End If
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" href="/Includes/js/token-input-facebook.css" type="text/css" />
    <script type="text/javascript" src="/Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="/Includes/js/jquery.tokeninput.js"></script>
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
            width: 800px;
            display: inline-flex;
        }

        ul.token-input-list-facebook li input {
            border: 0;
            padding: 3px 8px;
            background-color: white;
            margin: 2px 0;
            -webkit-appearance: caret;
            width: 800px;
        }
    </style>
    <script type="text/javascript">

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm != null) {
            prm.add_endRequest(enableQueryButton);
        }

        function enableQueryButton() {
            document.getElementById('<%=btnSearchSO.ClientID%>').disabled = false;
        }

        $(document).ready(
            function () {                
                $("#<%=txtSONumbers.ClientID%>").tokenInput("<%=System.IO.Path.GetFileName(Request.PhysicalPath) %>",
                    {
                        theme: "facebook", searchDelay: 200, minChars: 4, tokenDelimiter: ";", hintText: "Type SO No.", tokenLimit: 10, preventDuplicates: true, resizeInput: false
                    }
                );                
            }
        );

        
    </script>
    <table width="100%">
        <tr style="height:30px">
            <td><h2>AJP BTOS Order List</h2></td>
        </tr>
        <tr>
            <td>
                <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearchSO">
                    <table width="100%">
                        <tr>
                            <th align="left">From Date </th>
                            <td>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" Enabled="True" Format="yyyy/MM/dd" TargetControlID="txtFromDate">
                                </ajaxToolkit:CalendarExtender>
                                <asp:TextBox ID="txtFromDate" runat="server" Width="80px"></asp:TextBox>
                            </td>
                            <th align="left">&nbsp;To Date </th>
                            <td>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" Enabled="True" Format="yyyy/MM/dd" TargetControlID="txtToDate">
                                </ajaxToolkit:CalendarExtender>
                                <asp:TextBox ID="txtToDate" runat="server" Width="80px"></asp:TextBox>
                            </td>
                            <th>SO No. (From)</th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtSearchSONOFrom"
                                    MinimumPrefixLength="4" CompletionInterval="100" ServiceMethod="GetSONo" />
                                <asp:TextBox runat="server" ID="txtSearchSONOFrom" Width="100px" /></td>
                            <th>SO No. (To)</th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext2" TargetControlID="txtSearchSONOTo"
                                    MinimumPrefixLength="3" CompletionInterval="100" ServiceMethod="GetSONo" />
                                <asp:TextBox runat="server" ID="txtSearchSONOTo" Width="100px" /></td>                            
                            <td>
                                <asp:Button ID="btnSearchSO" runat="server" OnClick="btnSearchSO_Click" OnClientClick="this.disabled=true;" Text="Search" UseSubmitBehavior="False" />
                            </td>
                        </tr>
                        <tr>  
                            <th align="left">SO Numbers:</th>                        
                            <td colspan="7">
                                <asp:TextBox runat="server" ID="txtSONumbers" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upSO" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gvSO" Width="1200px" AutoGenerateColumns="false"
                            AllowSorting="True" OnSorting="gvSO_Sorting" OnRowCreated="gvRowCreated" OnRowDataBound="GridView_RowDataBound">
                            <Columns>
                                <asp:BoundField HeaderText="SO No." DataField="Vbeln" ItemStyle-HorizontalAlign="Center"
                                    SortExpression="Vbeln">
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:BoundField>
                                <asp:BoundField HeaderText="Sold-To Name" DataField="Name1" SortExpression="Name1" />                                
                                <asp:TemplateField HeaderText="Line No." ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="line_no" SortExpression="Posnr">
                                    <ItemTemplate>
                                        <%#RemovePrecedingZeros(Eval("Posnr"))%>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Part No." ItemStyle-Width="130px" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="line_no" SortExpression="Posnr">
                                    <ItemTemplate>
                                        <%#RemovePrecedingZeros(Eval("Matnr"))%>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Components" HeaderStyle-Width="250px">
                                    <ItemTemplate>
                                        <asp:GridView runat="server" ID="gvBTOSComp" AutoGenerateColumns="false" ShowHeader="false" Width="100%">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Line No." ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#RemovePrecedingZeros(Eval("posnr")) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Component" ItemStyle-Width="150px">
                                                    <ItemTemplate>
                                                        <%#RemovePrecedingZeros(Eval("matnr")) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Qty." ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Eval("kwmeng") %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Ship-To Addr." HeaderStyle-Width="200px">
                                    <ItemTemplate>
                                        <%#Eval("ShipToAddr") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sales Note">
                                    <ItemTemplate>
                                        <%#Eval("SalesNote") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="Cust. Req. Date" DataField="Edatu" ItemStyle-HorizontalAlign="Center"
                                    SortExpression="Edatu">
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:BoundField>
                                <asp:TemplateField HeaderText="ATP Date" ItemStyle-HorizontalAlign="Center" SortExpression="MBDAT">
                                    <ItemTemplate>
                                        <%#Eval("MBDAT")%>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WO No." SortExpression="Aufnr">
                                    <ItemTemplate>
                                        <%#Eval("Aufnr")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="DN No." SortExpression="Zokprod" ItemStyle-HorizontalAlign="Center" Visible="false">
                                    <ItemTemplate>
                                        <div>
                                            <%#Eval("Zokprod")%>
                                        </div>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Required Qty." SortExpression="KWMENG" ItemStyle-HorizontalAlign="Center" Visible="False">
                                    <ItemTemplate>
                                        <%#FormatNumber(Eval("KWMENG"), 0)%>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="OP Name" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="Opname" Visible="false"
                                    SortExpression="Opname">
                                    <ItemTemplate>
                                        <%#Eval("Opname")%>
                                    </ItemTemplate>
                                    <ItemStyle CssClass="Opname" HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sales Name" ItemStyle-HorizontalAlign="Center" SortExpression="SALESNM">
                                    <ItemTemplate>
                                        <%#Eval("SALESNM")%>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:UpdatePanel runat="server" ID="upGvRow" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:HiddenField runat="server" ID="hdRowSONO" Value='<%#Eval("Vbeln") %>' />
                                                <asp:HiddenField runat="server" ID="hdRowLineNo" Value='<%#RemovePrecedingZeros(Eval("Posnr")) %>' />
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:LinkButton runat="server" ID="btnDLPDF" Text="PDF" OnClick="btnDLPDF_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:PostBackTrigger ControlID="btnDLPDF" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearchSO" EventName="Click" />                        
                    </Triggers>
                </asp:UpdatePanel>

            </td>
        </tr>
    </table>
</asp:Content>
