<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="RMA Order Status Tracking"%>

<script runat="server">
    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            Dim tmpPN As String = Replace(Trim(Me.txtPartNo.Text), "'", "''")
            Dim tmpOrderNo As String = Replace(Trim(Me.txtOrderNo.Text), "'", "''")
            Dim tmpSN As String = Replace(Trim(Me.txtSN.Text), "'", "''")
            Dim tmpFrom As Date = Date.MinValue, tmpTo As Date = Date.MaxValue
            .AppendLine(" select top 1000 RMA_NO=a.Order_NO+'-'+Cast(a.Item_No as varchar(4)), ")
            .AppendLine(" dbo.DateOnly(a.Order_Dt) as Order_Date, a.Product_Name, a.Barcode, a.Now_Stage ")
            .AppendLine(" from RMA_My_Request_OrderList a ")
            
            'ICC 2015/8/5 Arrow's company should use in for sql parameter
            If Me.Arrows.Contains(Session("company_id")) Then
                .AppendLine(String.Format(" where a.Bill_ID in ('{0}') ", String.Join("','", Me.Arrows)))
            Else
                .AppendLine(String.Format(" where a.Bill_ID='{0}' ", Session("company_id")))
            End If

            If tmpOrderNo <> "" Then
                .AppendLine(String.Format(" and a.Order_NO+'-'+Cast(a.Item_No as varchar(4)) like '%{0}%' ", tmpOrderNo))
            End If
            If tmpPN <> "" Then
                .AppendLine(String.Format(" and a.Product_Name like '%{0}%' ", tmpPN))
            End If
            If tmpSN <> "" Then
                .AppendLine(String.Format(" and a.Barcode like '%{0}%' ", tmpSN))
            End If
            If Date.TryParseExact(Trim(Me.txtOrderFrom.Text), "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpFrom) Then
                .AppendLine(String.Format(" and a.Order_Dt>='{0}' ", tmpFrom.ToString("yyyy-MM-dd")))
            End If
            If Date.TryParseExact(Trim(Me.txtOrderTo.Text), "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpTo) Then
                .AppendLine(String.Format(" and a.Order_Dt<='{0}' ", tmpTo.ToString("yyyy-MM-dd")))
            End If
            If dlStatus.SelectedValue <> "" Then
                .AppendLine(String.Format(" and a.Now_Stage='{0}' ", dlStatus.SelectedValue))
            End If
            .AppendFormat(" order by a.order_dt desc ")
        End With
        Return sb.ToString()
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Trim(Request("order_no")) <> "" Then
                txtOrderNo.Text = Trim(Request("order_no"))               
            End If
            SqlDataSource1.SelectCommand = GetSql()
        End If
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim part_no As String = e.Row.Cells(2).Text
            If Util.IsAEUIT() Or Util.IsInternalUser2() Then
                e.Row.Cells(2).Text = "<a href='http://datamining.advantech.eu/Datamining/ProductProfile.aspx?PN=" + part_no + "' target='_blank'>" + part_no + "</a>"
            End If
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SqlDataSource1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SqlDataSource1.SelectCommand = GetSql()
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        SqlDataSource1.SelectCommand = GetSql()
    End Sub
    
    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("My", GetSql()), "RMA.xls")
    End Sub

    Protected Sub SqlDataSource1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
    
    Public ReadOnly Property Arrows As List(Of String)
        Get
            Dim arrow As List(Of String) = Cache("ArrowCustomers")
            If arrow Is Nothing Then
                arrow = New List(Of String)
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", " select distinct COMPANY_ID from US_COMPANY_GROUP where GROUP_ID = 1 ")
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    For Each row In dt.Rows
                        arrow.Add(row(0).ToString)
                    Next
                    Cache.Add("ArrowCustomers", arrow, Nothing, Now.AddHours(3), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
                End If
            End If
            Return arrow
        End Get
    End Property

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <div class="root"><asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" /> > <a href="#">Support & Download</a> > Return & Repair</div>
    <table width="100%">
        <tr>
            <td>
                <div class="right" style="width:600px; float:left;"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>    
                      <td height="24" class="h2">
                      <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                          <td class="menu_title">RMA Record</td>
                        </tr>
                      </table>
                      </td>
                    </tr>
                  <tr>
                    <td>
                      <table width="100%" border="0" cellspacing="0" cellpadding="0" class="rightcontant3">
                        <tr>
                          <td colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">

                          </table></td>
                        </tr>
                        <tr><td height="20" colspan="3"></td></tr>        
        
                        <tr>
                          <td colspan="3"></td>
                        </tr>
        
                         <tr>
                           <td width="3%"></td>
                           <td >
           
                           <table width="100%" border="0" cellpadding="0" cellspacing="0">
                              <form id="form3" name="form3" method="post" action="">
                                    <tr>
                                      <td width="25%" height="30" class="h5">Order No.:</td>
                                      <td>
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ext1" TargetControlID="txtOrderNo" 
                                            CompletionInterval="1000" MinimumPrefixLength="3" ServicePath="~/Services/AutoComplete.asmx" 
                                            ServiceMethod="GetRMAOrderNo" />
                                        <asp:TextBox runat="server" ID="txtOrderNo" Width="200px"/>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td class="h5" height="30">Serial No.:</td>
                                      <td><asp:TextBox runat="server" ID="txtSN" Width="200px" />                                            </td>
                                    </tr>
                                    <tr>
                                      <td class="h5" height="30">Part No.:</td>
                                      <td>
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ext2" TargetControlID="txtPartNo" 
                                            CompletionInterval="1000" MinimumPrefixLength="2" ServicePath="~/Services/AutoComplete.asmx" 
                                            ServiceMethod="GetPartNo" />
                                        <asp:TextBox runat="server" ID="txtPartNo" Width="200px" />
                                      </td>
                                    </tr>                    
                                    <tr>
                                      <td class="h5" height="30">Status:</td>
                                      <td>
                                        <asp:DropDownList runat="server" ID="dlStatus" Width="200px">
                                            <asp:ListItem Text="All" Value=""/>                                
                                            <asp:ListItem Text="Receive" Value="Receive"/>
                                            <asp:ListItem Text="Back Receive" Value="Back Receive" />
                                            <asp:ListItem Text="Ship" Value="Ship"/>
                                            <asp:ListItem Text="Back Ship" Value="Back Ship"/>
                                            <asp:ListItem Text="Repair" Value="Repair"/>
                                            <asp:ListItem Text="Back Repair" Value="Back Repair"/>
                                            <asp:ListItem Text="Accounting" Value="Accounting"/>                                
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td class="h5" height="30">Order Date:</td>
                                      <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="cal1" TargetControlID="txtOrderFrom" Format="dd/MM/yyyy" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="cal2" TargetControlID="txtOrderTo" Format="dd/MM/yyyy" />
                                        <asp:TextBox runat="server" ID="txtOrderFrom" Width="100px" />~
                                        <asp:TextBox runat="server" ID="txtOrderTo" Width="100px" />
                                        <span class="date_word">yyyy/mm/dd</span></td>
                                    </tr>                    
                                    <tr>
                                      <td height="30" colspan="2" align="right"><asp:ImageButton runat="server" ID="btnQuery" ImageUrl="~/Images/search1.gif" AlternateText="Search" OnClick="btnQuery_Click" /></td>
                                    </tr>
                                  </form>
                           </table>
                            
                           </td>
                           <td width="3%"></td>
                         </tr>
                         <tr>
                          <td height="10" colspan="3"></td>
                        </tr>
                          </table> 
                </td>
                  </tr>
  

                  <tr><td>
         
                  </td></tr>
                </table>
                </div>
            </td>
        </tr>
    </table>
    
    <table>
        <tr>
            <td>
                <div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                          <td height="10" colspan="2"><img src="../images/line3.gif" width="889" height="1" /></td>
                      </tr>
                      <tr height="30">
                          <td>
                            <table>  
                                <tr>
                                    <td width="20px"><asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" /></td>    
                                    <td><asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px" ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" /></td>
                                </tr>
                            </table>
                          </td>
                      </tr>
                      <tr>
                            <td>
                                 <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="False" Width="100%" AllowPaging="true" PageSize="50"
                                    DataSourceID="SqlDataSource1" OnRowDataBound="gv1_RowDataBound" OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting"
                                    EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                                    BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="#311e90" HeaderStyle-Font-Size="10px" RowStyle-Font-Size="10px" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                    PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                    <Columns>
                                        <asp:HyperLinkField HeaderText="RMA No." Target="_blank" DataNavigateUrlFields="RMA_NO" 
                                            DataNavigateUrlFormatString="http://erma.advantech.com.tw/WorkSpace/rma_display_summary.asp?rmano={0}" 
                                            DataTextField="RMA_NO" SortExpression="RMA_NO" />
                                        <asp:BoundField DataField="Order_Date" HeaderText="Order Date" 
                                            SortExpression="Order_Date" />
                                        <asp:BoundField DataField="Product_Name" HeaderText="Product Name" 
                                            SortExpression="Product_Name" />
                                        <asp:BoundField DataField="Now_Stage" HeaderText="Status" 
                                            SortExpression="Now_Stage" />  
                                        <asp:BoundField DataField="Barcode" HeaderText="Barcode" 
                                            SortExpression="Barcode" />                       
                                    </Columns>
                                </asp:GridView>
                                <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                                    ConnectionString="<%$ ConnectionStrings:RFM %>" SelectCommand="" OnSelecting="SqlDataSource1_Selecting" />
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
    
</asp:Content>