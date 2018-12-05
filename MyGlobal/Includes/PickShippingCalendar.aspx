<%@ Page Language="VB" %>

<%@ Import Namespace="System.Globalization" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Dim xDT As New System.Data.DataTable, Dt_sap_company_calendar As System.Data.DataTable
    Dim xDTcust As New System.Data.DataTable
    Dim Arr01 As New ArrayList
    Public Orgbysession As String = ""
    Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs)

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'If Session("Org") Is Nothing OrElse Session("Org").ToString() = "" Then
        If Session("Org_id") Is Nothing OrElse Session("Org_id").ToString() = "" Then
            Util.JSAlertRedirect(Me.Page, "Please log in first.", Util.GetRuntimeSiteUrl() + "/home.aspx")
            Response.End()
            Exit Sub
        Else

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'Orgbysession = OrderUtilities.getCalendarbyOrg(Session("Org").ToString())
            'Orgbysession = OrderUtilities.getCalendarbyOrg(Left(Session("Org_id").ToString().ToUpper, 2))
            Orgbysession = SAPDAL.SAPDAL.GetCalendarIDbyOrg(Left(Session("Org_id").ToString().ToUpper, 2))

            'Ryan 20180104 BBUS should use ORG = ZD instead of US, US is for ANA not BBUS.
            If AuthUtil.IsBBUS Then
                Orgbysession = "ZD"
            End If

        End If

    End Sub
    ' ming get local time
    Sub initDDYear()
        Me.ddYear.Items.Clear()
        Me.ddYear.Items.Add(New ListItem(Now.Year.ToString, Now.Year.ToString))
        Me.ddYear.Items.Add(New ListItem(DateAdd(DateInterval.Year, 1, Now).Year.ToString, DateAdd(DateInterval.Year, 1, Now).Year.ToString))
        Me.ddYear.Items.Add(New ListItem(DateAdd(DateInterval.Year, 2, Now).Year.ToString, DateAdd(DateInterval.Year, 2, Now).Year.ToString))
    End Sub
    Dim Today_Date As Date = Today.Date
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        'Ryan 20180103 ORG setting for local time 
        Dim OrgForLocalTime As String = Session("org_id").ToString.Substring(0, 2)
        If Session("org_id").ToString.ToUpper.Equals("US10") Then
            OrgForLocalTime = "BB"
        End If

        Dim localtime As DateTime = SAPDOC.GetLocalTime(OrgForLocalTime)
        Today_Date = localtime.Date

        Me.Calendar1.Caption = "<font size='3pt'><b>" & "Calendar" & "</b></font>"
        If Not Page.IsPostBack Then

            initDDYear()

            Try
                Me.txtType.Text = Request("Type").ToString.ToLower
            Catch ex As Exception
                Me.txtType.Text = ""
            End Try
            Try
                Me.txtElement.Text = Request("Element").ToString.ToLower
            Catch ex As Exception
                Me.txtElement.Text = ""
            End Try
            Try
                Me.txtFormat.Text = Request("Format").ToString.ToLower
                If Me.txtFormat.Text = "" Then
                    Me.txtFormat.Text = "dd/MM/yyyy"
                End If
            Catch ex As Exception
                Me.txtFormat.Text = "dd/MM/yyyy"
            End Try
            Try
                Me.HF_IsBTOS.Value = Request("IsBTOS").ToString
            Catch ex As Exception
                Me.HF_IsBTOS.Value = 0
            End Try
            Try
                Me.HF_SelectedDate.Value = Request("SelectedDate").ToString
            Catch ex As Exception
                Me.HF_SelectedDate.Value = ""
            End Try
            Try
                Me.txtSalesOrg.Text = Request("SalesOrg").ToString.ToLower
                If Me.txtSalesOrg.Text = "" Then
                    Me.txtSalesOrg.Text = "EU10"
                End If
            Catch ex As Exception
                Me.txtSalesOrg.Text = "EU10"
            End Try
            Try
                Me.txtCustomerId.Text = Request("CustomerId").ToString.ToLower
                If Me.txtCustomerId.Text = "" Then
                    Me.txtCustomerId.Text = Session("COMPANY_ID")
                End If
                'If Me.txtCustomerId.Text = "" Then
                '    Me.txtCustomerId.Text = "Default"
                'End If
            Catch ex As Exception
                Me.txtCustomerId.Text = "Default"
            End Try
            Try
                Me.txtPlant.Text = Request("Plant").ToString.ToLower
                If Me.txtPlant.Text = "" Then
                    Me.txtPlant.Text = "Default"
                End If
            Catch ex As Exception
                Me.txtPlant.Text = "Default"
            End Try

            Dim _org As String = Left(Session("org_id").ToString.ToUpper, 2)
            Dim _selectdate As Date = Today_Date

            If Date.TryParseExact(Me.HF_SelectedDate.Value, "yyyy/MM/dd", CultureInfo.CurrentCulture, DateTimeStyles.None, _selectdate) Then

            Else
                _selectdate = Today_Date
                If _org.Equals("EU", StringComparison.InvariantCultureIgnoreCase) Then
                    _selectdate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, _selectdate), Session("org_id"), 7)
                End If
            End If


            'Me.Calendar1.SelectedDate = Today_Date
            Me.Calendar1.SelectedDate = _selectdate
            '--
            'Response.Write(Me.Calendar1.VisibleDate.Month.ToString + "<hr>")
            'Me.Calendar1.VisibleDate = Today_Date
            Me.Calendar1.VisibleDate = _selectdate
            Me.Calendar1.TodaysDate = Today_Date

            If _selectdate.ToString = Today_Date.ToString Then
                Me.Calendar1.SelectedDayStyle.ForeColor = Drawing.Color.Red
            End If

            If Session("org_id").ToString.ToUpper.StartsWith("CN") Then
                Me.hfFirstAvailablyDate.Value = MyCartOrderBizDAL.getCompNextWorkDateV2(SAPDOC.GetLocalTime(Session("org_id")), Session("org_id"), 5).ToString
            ElseIf MyCartX.IsEUBtosCart(Session("cart_id")) Then
                Me.hfFirstAvailablyDate.Value = MyCartOrderBizDAL.getCompNextWorkDateV2(SAPDOC.GetLocalTime(Session("org_id")), Session("org_id"), 5).ToString
            End If

        End If
        '--
        If Page.IsPostBack Then
            If Request("Flag") = "YES" Then
                Dim FromDate As Date = CDate(Me.ddYear.SelectedValue & "/" & Me.ddMonth.SelectedValue & "/1")
                Me.Calendar1.VisibleDate = FromDate
            End If
        End If
        If Page.IsPostBack Then
            ' Response.Write(Me.Calendar1.VisibleDate.Year.ToString() + "<hr/>")
            ' xDT = dbUtil.dbGetDataTable("B2B", "Select * from ShippingCalendar_new WHERE JAHR = '" + ddYear.SelectedValue + "' and IDENT ='" + Orgbysession.ToString.Trim.ToUpper() + "'")
        Else
            xDT = dbUtil.dbGetDataTable("B2B", "Select JAHR,MON01,MON02,MON03,MON04,MON05,MON06,MON07,MON08,MON09,MON10,MON11,MON12,IDENT,ORG from ShippingCalendar_new WHERE JAHR = '" + Date.Now.Year.ToString + "'  and IDENT ='" + Orgbysession.ToString.Trim.ToUpper() + "'")

            For i As Integer = 0 To Me.ddMonth.Items.Count - 1
                If Me.ddMonth.Items(i).Value = Date.Now.Month.ToString Then
                    Me.ddMonth.SelectedIndex = i
                    Exit For
                End If
            Next
        End If


    End Sub

    Protected Sub Calendar1_VisibleMonthChanged(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MonthChangedEventArgs)
        Me.Calendar1.VisibleDate = e.NewDate
        For i As Integer = 0 To Me.ddYear.Items.Count - 1
            If Me.ddYear.Items(i).Value = Me.Calendar1.VisibleDate.Year Then
                Me.ddYear.SelectedIndex = i
                Exit For
            End If
        Next
        For i As Integer = 0 To Me.ddMonth.Items.Count - 1
            If Me.ddMonth.Items(i).Value = Me.Calendar1.VisibleDate.Month Then
                Me.ddMonth.SelectedIndex = i
                Exit For
            End If
        Next
        ' Response.Write("<hr>" + e.NewDate.ToLongDateString)
    End Sub
    Protected Sub Calendar1_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(Me.Calendar1.VisibleDate.Year.ToString() + "<hr/>")
        xDT = dbUtil.dbGetDataTable("B2B", "Select JAHR,MON01,MON02,MON03,MON04,MON05,MON06,MON07,MON08,MON09,MON10,MON11,MON12,IDENT,ORG from ShippingCalendar_new WHERE JAHR = '" + Me.Calendar1.VisibleDate.Year.ToString() + "' and IDENT ='" + Orgbysession.ToString.Trim.ToUpper() + "'")
        Dim monthstr As String = ""
        If Me.Calendar1.VisibleDate.Month.ToString.Trim.Length = 1 Then
            monthstr = "0" + Me.Calendar1.VisibleDate.Month.ToString.Trim
        Else
            monthstr = Me.Calendar1.VisibleDate.Month.ToString.Trim
        End If
        ' Response.Write("<hr>" + monthstr + "<hr>")
        If xDT.Rows.Count > 0 Then
            ' OrderUtilities.showDT(xDT)
            If Not IsDBNull(xDT.Rows(0).Item("MON" + monthstr)) AndAlso xDT.Rows(0).Item("MON" + monthstr).ToString <> "" Then
                Dim thiscolumn As String = xDT.Rows(0).Item("MON" + monthstr).ToString
                For i As Integer = 0 To thiscolumn.Length - 1
                    Arr01.Add(Mid(thiscolumn, i + 1, 1))
                Next
            End If

        End If


        If Left(Session("org_id").ToString.ToUpper, 2) = "EU" Then
            Dim sql As New StringBuilder
            sql.AppendLine("select rtrim(MOAB1)+rtrim(MOBI1)+rtrim(MOAB2)+rtrim(MOBI2)  as Monday,")
            sql.AppendLine("rtrim(DIAB1)+rtrim(DIBI1)+rtrim(DIAB2)+rtrim(DIBI2)  as Tuesday,")
            sql.AppendLine("rtrim(MIAB1)+rtrim(MIBI1)+rtrim(MIAB2)+rtrim(MIBI2)  as Wednesday,")
            sql.AppendLine("rtrim(DOAB1)+rtrim(DOBI1)+rtrim(DOAB2)+rtrim(DOBI2)  as Thursday,")
            sql.AppendLine("rtrim(FRAB1)+rtrim(FRBI1)+rtrim(FRAB2)+rtrim(FRBI2)  as Friday,")
            sql.AppendLine("rtrim(SAAB1)+rtrim(SABI1)+rtrim(SAAB2)+rtrim(SABI2)  as Saturday,")
            sql.AppendLine("rtrim(SOAB1)+rtrim(SOBI1)+rtrim(SOAB2)+rtrim(SOBI2)  as Sunday")
            sql.AppendLine("from SAP_COMPANY_CALENDAR")
            sql.AppendLine(String.Format("where KUNNR='{0}'", Session("COMPANY_ID")))
            Dt_sap_company_calendar = dbUtil.dbGetDataTable("B2B", sql.ToString)
        End If

        'For i As Integer = 0 To Arr01.Count - 1
        '    Response.Write("<br>" + Arr01(i))
        'Next
    End Sub

    Protected Sub Calendar1_DayRender(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DayRenderEventArgs)
        Dim _org As String = Left(Session("org_id").ToString.ToUpper, 2)

        'Ryan 20180103 Allow BBUS to pick today
        Dim _allowToday As Boolean = False
        If Session("org_id").ToString.ToUpper.Equals("US10") Then
            _allowToday = True
        End If

        If e.Day.IsOtherMonth = True Then
            e.Cell.Text = ""
        Else
            If Arr01.Count > 0 Then
                If e.Day.Date < Today_Date Then
                    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                ElseIf e.Day.Date = Today_Date AndAlso Not _allowToday Then
                    e.Cell.Text = e.Day.Date.Day
                Else
                    ' Dim dateit As New DateTime(Me.Calendar1.VisibleDate.Year, Me.Calendar1.VisibleDate.Month, i)
                    'Response.Write("<br>" + Arr01.Count.ToString() + ":" + (e.Day.Date.Day - 1).ToString)
                    Try
                        If Arr01.Count >= Integer.Parse(e.Day.Date.Day - 1) AndAlso Arr01(e.Day.Date.Day - 1).ToString = "1" Then
                            e.Cell.Attributes.Add("onclick", "PickDate('" & Me.txtElement.Text & "','" & FormatDate(Me.txtFormat.Text, e.Day.Date) & "')")
                        Else
                            e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                        End If
                    Catch ex As Exception
                        e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                        Util.SendEmail("ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "Pick Shipping Calendar error: " + HttpContext.Current.User.Identity.Name, Me.Calendar1.VisibleDate.ToString() + ":" + e.Day.Date.ToString() + "|" + ex.ToString(), False, "tc.chen@advantech.com.tw", "")
                    End Try
                End If

            Else
                e.Cell.Attributes.Add("onclick", "PickDate('" & Me.txtElement.Text & "','" & FormatDate(Me.txtFormat.Text, e.Day.Date) & "')")
            End If

            ' MING ADD  FOR SAP_COMPANY_Clendar
            If Dt_sap_company_calendar IsNot Nothing AndAlso Dt_sap_company_calendar.Rows.Count > 0 Then
                Dim checknum As Int64 = 0
                With Dt_sap_company_calendar.Rows(0)
                    Select Case e.Day.Date.DayOfWeek
                        Case DayOfWeek.Monday
                            If Isabilityday(.Item("Monday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Tuesday
                            If Isabilityday(.Item("Tuesday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Wednesday
                            If Isabilityday(.Item("Wednesday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Thursday
                            If Isabilityday(.Item("Thursday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Friday
                            If Isabilityday(.Item("Friday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Saturday
                            If Isabilityday(.Item("Saturday").ToString.Trim) Then
                                checknum = 1
                            End If
                        Case DayOfWeek.Sunday
                            If Isabilityday(.Item("Sunday").ToString.Trim) Then
                                checknum = 1
                            End If
                    End Select
                End With
                If checknum = 1 Then

                    'e.Cell.Attributes.Add("onclick", "PickDate('" & Me.txtElement.Text & "','" & FormatDate(Me.txtFormat.Text, e.Day.Date) & "')")
                    'Frank 2013/06/03
                    '- If it is not a btos order
                    '==> then today can not be picked
                    If Me.HF_IsBTOS.Value = "0" AndAlso e.Day.Date = Today_Date Then
                    Else
                        'Ming add 20140408 the shipment date can be picked after today
                        If e.Day.Date > Today_Date Then
                            e.Cell.Attributes.Add("onclick", "PickDate('" & Me.txtElement.Text & "','" & FormatDate(Me.txtFormat.Text, e.Day.Date) & "')")
                        End If
                    End If
                ElseIf e.Day.Date = Today_Date Then
                    e.Cell.Text = e.Day.Date.Day
                Else
                    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                    'Frank:2013/06/13 If the date cannot be picked, then remove the onclick event handler
                    e.Cell.Attributes.Remove("onclick")
                End If
            End If
            'end
            'If CDate("12/27/2010") <= e.Day.Date AndAlso e.Day.Date <= CDate("12/31/2010") Then
            '    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
            'End If
            'If CDate("12/2/2010") <= e.Day.Date AndAlso e.Day.Date <= CDate("12/3/2010") Then
            '    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
            'End If
            'If CDate("11/17/2011") <= e.Day.Date AndAlso e.Day.Date <= CDate("11/18/2011") Then
            '    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
            'End If
            If Request("IsBTOS") IsNot Nothing AndAlso Request("IsBTOS").ToString.Trim = "1" Then
                Dim AfterAssemblyDate As String = MyCartOrderBizDAL.getBTOParentDueDate(MyUtil.Current.CurrentLocalTime.ToString("yyyy/MM/dd"))
                If e.Day.Date < CDate(AfterAssemblyDate) Then
                    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                    e.Cell.Attributes.Remove("onclick")
                End If
            End If

            If Session("org_id").ToString.ToUpper.StartsWith("CN") OrElse MyCartX.IsEUBtosCart(Session("cart_id")) Then
                If e.Day.Date < Me.hfFirstAvailablyDate.Value Then
                    e.Cell.Text = "<font color=""Silver"">" & e.Day.Date.Day & "</font>"
                    e.Cell.Attributes.Remove("onclick")
                End If
            End If

        End If
    End Sub
    Public Function Isabilityday(ByVal str As String) As Boolean
        Static Num() As String = New String() {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
        For Each numb As String In Num
            If str.Contains(numb) Then
                Return True
                Exit Function
            End If
        Next
        Return False
    End Function
    Protected Function FormatDate(ByVal xFormat As String, ByVal xDate As String)
        Dim RetDate As String = ""

        RetDate = CDate(xDate).Date.ToString("yyyy/MM/dd")

        Return RetDate
    End Function


</script>

<script type="text/javascript" language="javascript">
    function PickDate(xElement, xValue) {

        var obj = eval("window.opener.document.aspnetForm." + xElement);
        obj.value = xValue;
        self.close();

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Calendar - Advantech Online</title>
    <meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE" />
    <meta content="JavaScript" name="vs_defaultClientScript" />
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
    <link href="./ebiz.aeu.style2.css" rel="stylesheet" />

</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" valign="top" colspan="4">
                        <asp:TextBox runat="server" ID="txtType" Text="" Visible="false"></asp:TextBox>
                        <asp:TextBox runat="server" ID="txtElement" Text="" Visible="false"></asp:TextBox>
                        <asp:TextBox runat="server" ID="txtFormat" Text="dd/MM/yyyy" Visible="false"></asp:TextBox>
                        <asp:TextBox runat="server" ID="txtSalesOrg" Text="EU10" Visible="false"></asp:TextBox>
                        <asp:TextBox runat="server" ID="txtCustomerId" Text="Default" Visible="false"></asp:TextBox>
                        <asp:TextBox runat="server" ID="txtPlant" Text="Default" Visible="false"></asp:TextBox>
                        <asp:HiddenField ID="HF_SelectedDate" runat="server" />
                        <asp:HiddenField ID="HF_IsBTOS" Value="0" runat="server" />
                        <asp:Calendar ID="Calendar1" runat="server" BackColor="#ffffff" ForeColor="#000000"
                            Font-Names="Arial" Font-Size="10pt" CellPadding="6" CellSpacing="0" TitleStyle-BackColor="#0000cc"
                            TitleStyle-Font-Bold="true" TitleStyle-ForeColor="#ffffff" TitleStyle-Font-Size="8pt"
                            PrevMonthText="<font color='#ffffff'><b><&nbsp;Prev</b></font>" NextMonthText="<font color='#ffffff'><b>Next&nbsp;></b></font>"
                            SelectedDayStyle-BorderStyle="Solid" SelectedDayStyle-BorderColor="#999999" SelectedDayStyle-BorderWidth="1px"
                            SelectedDayStyle-BackColor="#ffffff" TodayDayStyle-ForeColor="red" SelectedDayStyle-ForeColor="Black" SelectedDayStyle-Font-Bold="true"
                            OnDayRender="Calendar1_DayRender" OnVisibleMonthChanged="Calendar1_VisibleMonthChanged" OnPreRender="Calendar1_PreRender">
                            <WeekendDayStyle ForeColor="Silver" />
                        </asp:Calendar>
                    </td>
                </tr>
                <tr>
                    <td>
                        <b>&nbsp;Month:</b><input type="hidden" name="Flag" id="Flag" value="NO" />
                    </td>
                    <td>
                        <asp:DropDownList runat="server" ID="ddMonth" onchange="Javascript: document.form1.Flag.value = 'YES';"
                            AutoPostBack="true">
                            <asp:ListItem Value="1" Text="January"></asp:ListItem>
                            <asp:ListItem Value="2" Text="February"></asp:ListItem>
                            <asp:ListItem Value="3" Text="March"></asp:ListItem>
                            <asp:ListItem Value="4" Text="April"></asp:ListItem>
                            <asp:ListItem Value="5" Text="May"></asp:ListItem>
                            <asp:ListItem Value="6" Text="June"></asp:ListItem>
                            <asp:ListItem Value="7" Text="July"></asp:ListItem>
                            <asp:ListItem Value="8" Text="August"></asp:ListItem>
                            <asp:ListItem Value="9" Text="September"></asp:ListItem>
                            <asp:ListItem Value="10" Text="October"></asp:ListItem>
                            <asp:ListItem Value="11" Text="November"></asp:ListItem>
                            <asp:ListItem Value="12" Text="December"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td>
                        <b>Year</b>
                    </td>
                    <td>
                        <asp:DropDownList runat="server" ID="ddYear" onchange="Javascript: document.form1.Flag.value = 'YES';"
                            AutoPostBack="true">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <font color="red"><b>Tip: Day in red is today.</b></font>
                    </td>
                </tr>
            </table>
            <asp:HiddenField ID="hfFirstAvailablyDate" Value='<%DateTime.Now %>' runat="server" />
        </div>
    </form>
</body>
</html>
