<%@ Page Title="MyAdvantech - AOnline Sales Portal" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim Months() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    Public Shared Function GetSalesID(ByVal userid As String, ByRef SalesId As String, ByRef PositionId As String) As Boolean
        If userid Is Nothing OrElse userid.Contains("@") = False Then Return Nothing
        Dim namepart As String = Util.GetNameVonEmail(userid)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
           "select top 1 SALES_CODE, POSTN_ID from SIEBEL_SAP_SALESCODE where SALES_EMAIL='{0}' and SALES_CODE<>'' and POSTN_ID is not null", userid))
        If dt.Rows.Count = 1 Then
            Dim retcode As String = ""
            If dt.Rows(0).Item("SALES_CODE").ToString().Contains("-") Then
                Dim pp() As String = Split(dt.Rows(0).Item("SALES_CODE").ToString(), "-")
                retcode = pp(0)
            Else
                retcode = dt.Rows(0).Item("SALES_CODE").ToString()
            End If
            If retcode.Trim() <> "" Then
                SalesId = retcode : PositionId = dt.Rows(0).Item("POSTN_ID")
                Return True
            End If
        End If
        Return False
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            hdEmail.Value = User.Identity.Name
            If Not GetSalesID(User.Identity.Name, hdSalesID.Value, hdPosID.Value) Then
                If (MailUtil.IsInRole("AOnline.Marketing") Or MailUtil.IsInRole("DIRECTOR.ACL") Or MailUtil.IsInRole("ITD.ACL")) Then
                    hdSalesID.Value = "11136003" 'Winnie Tsai's sales id
                    hdPosID.Value = "1-HXERP"
                    hdEmail.Value = "winnie.tsai@advantech.com.tw"
                Else
                    Util.JSAlertRedirect(Me.Page, "Sorry, you are not authorized to visit this page", "../../home.aspx")
                End If
            End If
        End If
    End Sub

    Protected Sub TimerGlobSales_Tick(sender As Object, e As System.EventArgs)
        TimerGlobSales.Interval = 9999
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 3 b.FULL_NAME, left(b.PERS_AREA,2) as ORG, SUM(a.Us_amt) as AMT   "))
                .AppendLine(String.Format(" from EAI_SALE_FACT_THISYEAR a inner join SAP_EMPLOYEE b on a.Sales_ID=b.SALES_CODE  "))
                .AppendLine(String.Format(" where FACTYEAR={0} and sector like '%aonline%' and month(efftive_date)={1} and a.Qty<>0 and Tran_Type='Shipment' ", _
                                          Now.Year.ToString(), (Now.Month-1).ToString()))
                .AppendLine(String.Format(" group by b.FULL_NAME, left(b.PERS_AREA,2)  "))
                .AppendLine(String.Format(" order by SUM(a.Us_amt) desc "))
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            gvGlobalSalesList.DataSource = dt : gvGlobalSalesList.DataBind() : tbGlobSales.Visible = True
            lbGlobalSalesYM.Text = "Global Top Sales -" + Months(Now.Month - 2) + "."
        Catch ex As Exception
            'lbGlobalSalesYM.Text = ex.ToString()
        End Try
        TimerGlobSales.Enabled = False
    End Sub
    
    Protected Sub TimerSalesSiebel_Tick(sender As Object, e As System.EventArgs)
        TimerSalesSiebel.Interval = 9999
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString), cmd As New SqlClient.SqlCommand()
            conn.Open() : cmd.Connection = conn
            cmd.CommandText = _
              "select COUNT(a.ROW_ID) from SIEBEL_ACCOUNT a inner join SIEBEL_ACCOUNT_STAT b on a.ROW_ID=b.ROW_ID " + _
              " where a.PRIMARY_SALES_EMAIL=@EM and b.YearOpty=0"
            cmd.Parameters.AddWithValue("EM", hdEmail.Value)
            Dim obj As Object = cmd.ExecuteScalar()
            If obj IsNot Nothing Then
                hy1YearNoOpty.Text = "(" + obj.ToString() + ")"
            End If
            obj = Nothing
            cmd.CommandText = _
                " select COUNT(distinct b.COMPANY_ID) from SIEBEL_ACCOUNT a inner join SAP_COMPANY_STAT b on a.ERP_ID=b.COMPANY_ID " + _
                " where a.PRIMARY_SALES_EMAIL=@EM "
            obj = cmd.ExecuteScalar()
            If obj IsNot Nothing Then
                hyMyPriAccount.Text = "(" + obj.ToString() + ")"
            End If
            obj = Nothing
            If conn.State <> ConnectionState.Closed Then conn.Close()
        Catch ex As Exception
            hy1YearNoOpty.Text = ex.ToString()
        End Try
        TimerSalesSiebel.Enabled = False
        TimerSalesPerf.Enabled = True : TimerSalesPerf.Interval = 100
    End Sub

    Protected Sub TimerSalesPerf_Tick(sender As Object, e As System.EventArgs)
        TimerSalesPerf.Interval = 9999
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString), cmd As New SqlClient.SqlCommand()
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter( _
                " select count(distinct a.order_no) as orders, SUM(a.Us_amt) as amt from EAI_SALE_FACT_THISYEAR a " + _
                " where a.factyear>=2012 and a.Sales_ID=@SID and a.Qty>0 and Tran_Type='Backlog'", conn)
            apt.SelectCommand.Parameters.AddWithValue("SID", hdSalesID.Value)
            apt.Fill(dt)
            If dt.Rows.Count = 1 Then
                hyBlog.Text = String.Format("{0}, USD {1}", dt.Rows(0).Item("orders"), dt.Rows(0).Item("amt"))
            End If
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter( _
                "select count(distinct a.order_no) as orders, SUM(a.Us_amt) as amt from EAI_SALE_FACT_THISYEAR a " + _
                " where a.factyear>=2012 and a.Sales_ID=@SID and a.Qty>0 and Tran_Type='Shipment' and efftive_date>=GETDATE()-7", conn)
            apt.SelectCommand.Parameters.AddWithValue("SID", hdSalesID.Value)
            apt.Fill(dt)
            If dt.Rows.Count = 1 Then
                hyShipWeek.Text = String.Format("{0}, USD {1}", dt.Rows(0).Item("orders"), dt.Rows(0).Item("amt"))
            End If
        Catch ex As Exception
            hy1YearNoOpty.Text += ex.ToString()
        End Try
        TimerSalesPerf.Enabled = False : TimerSalesAR.Enabled = True : TimerSalesAR.Interval = 100
    End Sub

    Protected Sub TimerSalesAR_Tick(sender As Object, e As System.EventArgs)
        TimerSalesAR.Interval = 9999
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString), cmd As New SqlClient.SqlCommand()
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter( _
                " select distinct b.AMOUNT, b.CURRENCY " + _
                " from EAI_SALE_FACT a inner join SAP_CUSTOMER_AR b on a.Customer_ID=b.COMPANY_ID and a.org=b.ORG and a.BillingDoc=b.INVOICE_NO " + _
                " where a.Sales_ID=@SID and b.DUE_DATE<GETDATE() ", conn)
            apt.SelectCommand.Parameters.AddWithValue("SID", hdSalesID.Value)
            apt.Fill(dt)
            If dt.Rows.Count > 0 Then
                Dim tmpAmt As Decimal = 0
                For Each r As DataRow In dt.Rows
                    tmpAmt += r.Item("AMOUNT")
                Next
                hyOverdueAR.Text = String.Format("{0}, USD {1}", dt.Rows.Count.ToString(), tmpAmt.ToString())
            End If
        Catch ex As Exception
            hy1YearNoOpty.Text += ex.ToString()
        End Try
        TimerSalesAR.Enabled = False
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="hdSalesID" />
    <asp:HiddenField runat="server" ID="hdPosID" />
    <asp:HiddenField runat="server" ID="hdEmail" />
    <table width="100%">
        <tr valign="top">
            <td style="width: 20%">
                <table width="100%">
                    <tr>
                        <td align="center">
                            <img src="http://employeezone.advantech.com.tw/people_finder/images/p-1.jpg" width="150px"
                                height="180px" alt="" />
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <h3>
                                <%=Util.GetNameVonEmail(User.Identity.Name)%></h3>
                        </th>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <li />
                                    </td>
                                    <td>
                                        <asp:HyperLink runat="server" ID="HyperLink1" Text="Sales Achievement" NavigateUrl="" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                    </td>
                                    <td>
                                        <asp:HyperLink runat="server" ID="HyperLink2" Text="Achievement Rate %" NavigateUrl="" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                    </td>
                                    <td>
                                        <asp:HyperLink runat="server" ID="HyperLink3" Text="My Commission" NavigateUrl="" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upGlobSales" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="TimerGlobSales" Interval="500" OnTick="TimerGlobSales_Tick" />
                                    <table runat="server" id="tbGlobSales" visible="false" width="100%" style="background-color: #E4E4E4;">
                                        <tr>
                                            <th>
                                               <asp:Label runat="server" ID="lbGlobalSalesYM" /> 
                                            </th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:GridView runat="server" ID="gvGlobalSalesList" Width="100%" AutoGenerateColumns="false"
                                                    ShowHeader="false">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <img src="http://employeezone.advantech.com.tw/people_finder/images/p-1.jpg" width="30px"
                                                                    height="40px" alt="" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="100%">
                                                            <ItemTemplate>
                                                                <table width="100%">
                                                                    <tr>
                                                                        <th align="left" style="width: 10px">
                                                                            <%# Container.DataItemIndex + 1 %>.
                                                                        </th>
                                                                        <th align="left">
                                                                            <%#Eval("ORG")%>
                                                                        </th>
                                                                    </tr>
                                                                    <tr>
                                                                        <td />
                                                                        <th align="left">
                                                                            <%#Eval("FULL_NAME")%>
                                                                        </th>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 40%">
                <table width="100%">
                    <tr>
                        <td valign="top">
                            <table width="100%">
                                <tr valign="top">
                                    <td>
                                        <table width="100%" style="background-color: #FFDCC0; border-style: groove">
                                            <tr>
                                                <th align="left" style="font-size: larger; color: #FF6600">
                                                    Resource Center
                                                </th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="hyMaterialPromotion" Text="My Material Promotion"
                                                        NavigateUrl="ContentSearch.aspx" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink4" Text="Latest HQ eCampaign" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink5" Text="Dashboard" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="font-size: larger; color: #FF6600">
                                                    Good Sales Sharing
                                                </th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink6" Text="Project Win" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink7" Text="Good Tools Sharing" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink8" Text="Complaint Handling" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="font-size: larger; color: #FF6600">
                                                    Sales Training & Certification
                                                </th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink9" Text="Training Course" NavigateUrl="" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <li />
                                                    <asp:HyperLink runat="server" ID="HyperLink10" Text="My Certification Record" NavigateUrl="" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" style="background-color: #CADCFF; border-style: groove">
                                <tr>
                                    <th align="left" style="font-size: larger; color: #4F81BD">
                                        Product Information
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                        <asp:HyperLink runat="server" ID="hyPhaseInOut" Text="New Product Phase-in" Target="_blank"
                                            NavigateUrl="~/Product/Product_PhaseInOut.aspx" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                        <asp:HyperLink runat="server" ID="hySalesKitRoadmap" Text="Sales Kit & Roadmap" Target="_blank"
                                            NavigateUrl="" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                        <asp:HyperLink runat="server" ID="HyperLink11" Text="Comparison Table" Target="_blank"
                                            NavigateUrl="#" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <li />
                                        <asp:HyperLink runat="server" ID="HyperLink12" Text="Phase-out Notice" Target="_blank"
                                            NavigateUrl="#" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 40%">
                <asp:UpdatePanel runat="server" ID="upSalesPerf" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Timer runat="server" ID="TimerSalesSiebel" Interval="50" OnTick="TimerSalesSiebel_Tick" />
                        <asp:Timer runat="server" ID="TimerSalesPerf" Enabled="false" OnTick="TimerSalesPerf_Tick" />
                        <asp:Timer runat="server" ID="TimerSalesAR" Enabled="false" OnTick="TimerSalesAR_Tick" />
                        <table width="100%" style="background-color: #EAE2F6; border-style: groove">
                            <tr>
                                <th colspan="2" align="left" style="font-size: larger">
                                    Sales Intelligence
                                </th>
                            </tr>
                            <tr valign="top">
                                <td>
                                    1.
                                </td>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <b>Business Converage Density</b>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Over 1-year without Opportunity
                                                <asp:HyperLink runat="Server" ID="hy1YearNoOpty" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Purchasing History
                                                <asp:HyperLink runat="Server" ID="hyPurchaseHistory" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                My Primary Account List
                                                <asp:HyperLink runat="Server" ID="hyMyPriAccount" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td>
                                    2.
                                </td>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <b>My To-do List</b>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Scheduled Activity
                                                <asp:HyperLink runat="Server" ID="hySchAct" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Due by Week/ Monthly Opportunity
                                                <asp:HyperLink runat="Server" ID="hyDueOpty" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Overdue Opportunity
                                                <asp:HyperLink runat="Server" ID="hyOverdueOpty" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Overdue Activity
                                                <asp:HyperLink runat="Server" ID="hyOverdueAct" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td>
                                    3.
                                </td>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <b>My Backlog</b>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Backlog List
                                                <asp:HyperLink runat="Server" ID="hyBlog" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Ship by this Week
                                                <asp:HyperLink runat="Server" ID="hyShipWeek" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td>
                                    4.
                                </td>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <b>My A/R</b>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Overdue List
                                                <asp:HyperLink runat="Server" ID="hyOverdueAR" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <li />
                                                Due by this Month
                                                <asp:HyperLink runat="Server" ID="hyDueMonthAR" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function ShowDivMain() {
            var divCat = document.getElementById('divMain');
            divCat.style.display = 'block';
        }
        function CloseDivMain() {
            var divCat = document.getElementById('divMain');
            divCat.style.display = 'none';
        }
    </script>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="PanelData" HorizontalSide="Center" VerticalSide="Middle"
        HorizontalOffset="400" VerticalOffset="200" />
    <asp:Panel runat="server" ID="PanelData">
        <div id="divMain" style="display: none; background-color: white; border: solid 1px silver;
            padding: 10px; width: 650px; height: 350px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td align="right">
                        <a href="javascript:void(0);" onclick="CloseDivMain();">Close</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <ajaxToolkit:TabContainer runat="server" ID="tabcon1">
                            <ajaxToolkit:TabPanel runat="server" ID="TabPanel1" HeaderText="tab1">
                                
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="TabPanel2" HeaderText="tab2">
                                
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="TabPanel3" HeaderText="tab3">
                                
                            </ajaxToolkit:TabPanel>
                        </ajaxToolkit:TabContainer>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>
</asp:Content>
