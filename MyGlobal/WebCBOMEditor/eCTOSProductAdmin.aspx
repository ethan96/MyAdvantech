<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="eCTOS Produt Customer Mapping" %>

<script runat="server">
    Dim dv As New DataView
    Dim dt As New DataTable
    Protected Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        ' Me.Global_inc1.ValidationStateCheck()
        ' Response.Write("on Developing...") : Response.End()
        SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        Dim T_strselect As String = ""
        If Session("eCTOS_Temp") Is Nothing Then
            T_strselect = "Select distinct PART_NO as PART_NO, " & _
                              " COMPANY_ID, " & _
                              " SHIPTO_ID, " & _
                              " PRODUCT_TYPE " & _
                              " from PRODUCT_CUSTOMER_DICT " & _
                              " where 1<>1"
            dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, T_strselect)
            Session("eCTOS_Temp") = dt
        Else
            dt = Session("eCTOS_Temp")
        End If
        Call InitDgeCTOS_Temp()
        Call InitAdgeCTOS()
    End Sub
    Protected Sub InitDgeCTOS_Temp()
        dv = New DataView(dt)
        Me.DgeCTOS_Temp.DataSource = dv
        If Not Page.IsPostBack Then
            Me.DgeCTOS_Temp.DataBind()
        End If
    End Sub
    Protected Sub InitAdgeCTOS()
        Dim T_strselect As String = ""
        T_strselect = "Select distinct '' as SO_BANK, " & _
                      " PART_NO as PART_NO, " & _
                      " COMPANY_ID, " & _
                      " SHIPTO_ID, " & _
                      " PRODUCT_TYPE, " & _
                      " UNIT_PRICE, " & _
                      " MAXQTY, " & _
                      " '' AS BTN_DELETE " & _
                      " from PRODUCT_CUSTOMER_DICT " & _
                      " where PART_NO like '%-CTOS%' and COMPANY_ID<>'' and PRODUCT_TYPE in ('CTOS','ECTOS') order by PART_NO"
        Me.SqlDataSource1.SelectCommand = T_strselect
        If Not Page.IsPostBack Then
            Me.GridView1.DataBind()
        End If
    End Sub
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType <> DataControlRowType.Pager Then
            e.Row.Cells(1).Visible = False
            e.Row.Cells(6).Visible = False
            e.Row.Cells(7).Visible = False
            e.Row.Cells(8).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.Header AndAlso Not Page.IsPostBack Then
            Me.drpFields.Items.Clear()
            e.Row.Cells(0).Text = "Del."
            Me.drpFields.Items.Add(New ListItem("Part No", e.Row.Cells(2).Text))
            
            e.Row.Cells(2).Text = "Part No"
            Me.drpFields.Items.Add(New ListItem("Company Id", e.Row.Cells(3).Text))
            
            e.Row.Cells(3).Text = "Company Id"
            Me.drpFields.Items.Add(New ListItem("Ship To", e.Row.Cells(4).Text))
            
            e.Row.Cells(4).Text = "Ship To"
            Me.drpFields.Items.Add(New ListItem("Product Type", e.Row.Cells(5).Text))
            
            e.Row.Cells(5).Text = "Product Type"
            
        End If
    
    End Sub

    
    Protected Sub Delete_TempItem(ByVal sender As Object, ByVal e As DataGridCommandEventArgs)
        Dim xDataGridItem As DataGridItem = e.Item
        Dim PartNO_Cell As String = xDataGridItem.Cells(0).Text
        Dim CompanyID_Cell As String = xDataGridItem.Cells(1).Text
        Dim ProductType_Cell As String = xDataGridItem.Cells(3).Text
        If e.CommandName = "DeleteTempItem" Then
            dv.RowFilter = "PART_NO = '" & CStr(PartNO_Cell) & "' and COMPANY_ID='" & CStr(CompanyID_Cell) & "' and PRODUCT_TYPE='" & CStr(ProductType_Cell) & "'"
            'dv.RowFilter = "PART_NO = '" & CStr(PartNO_Cell) & "'"
            If dv.Count > 0 Then
                dv.Delete(0)
                dv.Table.AcceptChanges()
                dv.RowFilter = ""
                dt = dv.Table
                Session("eCTOS_Temp") = dt
                Me.DgeCTOS_Temp.DataBind()
            End If
        End If
    End Sub
    
    'Protected Sub AdgeCTOS_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs)
    '    Dim xDataGridItem As DataGridItem = e.Item
    '    Dim xItemType As ListItemType = e.Item.ItemType
    '    Dim retValue() As String
    '    If xItemType <> ListItemType.Header And xItemType <> ListItemType.Footer Then
    '        retValue = Me.AdgeCTOS.VxGetGridItemValue(xDataGridItem)
    '        Me.AdgeCTOS.VxUserFormat(xDataGridItem, 5, )
    '    End If
    'End Sub

    Protected Sub Submit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If String.IsNullOrEmpty(Me.txtpartno.Text.Trim) Then Exit Sub
        If String.IsNullOrEmpty(Me.txtcompid.Text.Trim) Then Exit Sub
        If String.IsNullOrEmpty(Me.txtshiptoid.Text.Trim) Then Exit Sub
        dv.RowFilter = "PART_NO = '" & CStr(Trim(Me.txtpartno.Text)) & "' and COMPANY_ID='" & CStr(Trim(Me.txtcompid.Text)) & "' and PRODUCT_TYPE='" & CStr(Trim(Me.txtproducttype.SelectedValue)) & "'"
        Dim xDataTable As DataTable
        xDataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select * from PRODUCT_CUSTOMER_DICT where PART_NO = '" & CStr(Trim(Me.txtpartno.Text)) & "' and COMPANY_ID='" & CStr(Trim(Me.txtcompid.Text)) & "' and PRODUCT_TYPE='" & CStr(Trim(Me.txtproducttype.SelectedValue)) & "'")
        If dv.Count > 0 Or xDataTable.Rows.Count > 0 Then
        Else
            Dim dr As DataRow
            dr = dt.NewRow
            dr.Item("PART_NO") = Trim(Me.txtpartno.Text)
            dr.Item("COMPANY_ID") = Trim(Me.txtcompid.Text)
            dr.Item("SHIPTO_ID") = Trim(Me.txtshiptoid.Text)
            dr.Item("PRODUCT_TYPE") = Trim(Me.txtproducttype.SelectedValue)
            dt.Rows.Add(dr)
            Session("eCTOS_Temp") = dt
            dv = New DataView(dt)
            Me.DgeCTOS_Temp.DataSource = dv
            Me.DgeCTOS_Temp.DataBind()
        End If
        
    End Sub

    Protected Sub SubmitAll_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strInsert As String
        If dt.Rows.Count > 0 Then
            Dim i As Integer = 0
            While i <= dt.Rows.Count - 1
                Try
                    strInsert = "insert into PRODUCT_CUSTOMER_DICT(" & _
                                " PART_NO, " & _
                                " ORG_ID," & _
                                " COMPANY_ID, " & _
                                " SHIPTO_ID, " & _
                                " PRODUCT_TYPE, " & _
                                " UNIT_PRICE, " & _
                                " MAXQTY, " & _
                                " OPTION_CODE) " & _
                                " Values(" & _
                                " '" & CStr(dt.Rows(i).Item("PART_NO")) & "'," & _
                                " 'BTOSDATA'," & _
                                " '" & CStr(dt.Rows(i).Item("COMPANY_ID")) & "'," & _
                                " '" & CStr(dt.Rows(i).Item("SHIPTO_ID")) & "'," & _
                                " '" & CStr(dt.Rows(i).Item("PRODUCT_TYPE")) & "'," & _
                                " 0," & _
                                " 0," & _
                                " ''" & _
                                " )"
                    dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, strInsert)
                Catch ex As Exception
                    Exit Sub
                End Try
                i = i + 1
            End While
            dv.RowFilter = "1<>1"
            dt = dv.Table
            Session("eCTOS_Temp") = dt
            Me.DgeCTOS_Temp.DataSource = dv
            Me.DgeCTOS_Temp.DataBind()
            Me.GridView1.DataBind()
        End If
        
    End Sub
    Protected Sub sh(ByVal sender As Object, ByVal e As EventArgs)
        Dim sql As String = " select distinct '' as SO_BANK, " & _
                      " PART_NO as PART_NO, " & _
                      " COMPANY_ID, " & _
                      " SHIPTO_ID, " & _
                      " PRODUCT_TYPE, " & _
                      " UNIT_PRICE, " & _
                      " MAXQTY, " & _
                      " '' AS BTN_DELETE "
        SqlDataSource1.SelectCommand = String.Format(sql + " FROM [PRODUCT_CUSTOMER_DICT] where {0}", Me.drpFields.SelectedValue & " like '%" & Me.txtStr.Text.Trim & "%'")
        'Response.Write(SqlDataSource1.SelectCommand)
        GridView1.DataBind()
    End Sub

    Protected Sub SqlDataSource1_Deleted(sender As Object, e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
        sh(sender, e)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" language="javascript">

        function PickPartNO(xElement, xPartNO) {
            var Url;
            Url = "../Order/PickPartNo.aspx?Element=" + "ctl00__main_" + xElement + "&Type=CTOSCUSTOMER&PartNO=" + xPartNO + "";
            window.open(Url, "pop", "height=570,width=480,scrollbars=yes");
        }
        function PickCompanyID(xElement, xType, xCompanyID) {
            var Url;
            Url = "../Order/PickCompanyID.aspx?Element=" + "ctl00__main_" + xElement + "&Type=" + xType + "&CompanyID=" + xCompanyID + "";
            window.open(Url, "pop", "height=570,width=480,scrollbars=yes");
        }
    </script>
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;
            </td>
        </tr>
        <tr>
            <td align="center">
                <table id="Table2" width="60%">
                    <tr>
                        <td valign="middle" width="100%" align="left">
                            <div class="euPageTitle">
                                <b>eCTOS Product-Customer Mapping</b></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;
            </td>
        </tr>
        <tr>
            <td align="center">
                <table width="60%" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td style="border: #4f60b2 2px solid">
                            <table width="100%" height="100%" cellspacing="1" cellpadding="2" id="Table1" border="0"
                                bordercolor="#cfcfcf">
                                <tr bgcolor="#bec4e3">
                                    <td colspan="2" height="20" class="text">
                                        <font color="#303d83"><b>Please fill in the information below to add products</b></font>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="160px" align="right" bgcolor="#f0f0f0" class="text">
                                        Part No &nbsp;&nbsp;
                                    </td>
                                    <td bgcolor="#f0f0f0" class="text" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtpartno"></asp:TextBox>
                                        &nbsp;&nbsp;
                                        <input type="button" onclick="PickPartNO('txtpartno','-CTOS');" value='Pick' style="cursor: hand"
                                            id="Button1" name="Button1"></input>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" bgcolor="#f0f0f0" class="text">
                                        Company Id &nbsp;&nbsp;
                                    </td>
                                    <td bgcolor="#f0f0f0" class="text" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtcompid"></asp:TextBox>&nbsp;&nbsp;&nbsp;
                                        <input type="button" onclick="PickCompanyID('txtcompid','','');" value='Pick' style="cursor: hand"
                                            id="Button2" name="Button1"></input>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" bgcolor="#f0f0f0" class="text">
                                        ShipTo Id &nbsp;&nbsp;
                                    </td>
                                    <td bgcolor="#f0f0f0" class="text" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtshiptoid"></asp:TextBox>&nbsp;&nbsp;&nbsp;
                                        <input type="button" onclick="PickCompanyID('txtshiptoid','ShipTo','');" value='Pick'
                                            style="cursor: hand" id="Button3" name="Button1"></input>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" bgcolor="#f0f0f0" class="text">
                                        Product Type &nbsp;&nbsp;
                                    </td>
                                    <td bgcolor="#f0f0f0" class="text" align="left">
                                        &nbsp;
                                        <asp:DropDownList runat="server" ID="txtproducttype">
                                            <asp:ListItem Value="ECTOS" Text="ECTOS"></asp:ListItem>
                                            <asp:ListItem Value="CTOS" Text="CTOS"></asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#ffffff" colspan="2" valign="middle" align="center" height="30px">
                                        <asp:Button runat="server" ID="Submit" Text="Submit" OnClick="Submit_Click" />
                                    </td>
                                </tr>
                                <%--<input type="hidden" name="txtunitprice" value="0" ID="Text4" onBlur='fn_check_num(this)'></input>
								<input type="hidden" value=9999 name="txtMaxQty" ID="Hidden1" onBlur='fn_check_num(this)'></input>--%>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:DataGrid runat="server" ID="DgeCTOS_Temp" ShowHeader="true" ShowFooter="false"
                                OnItemCommand="Delete_TempItem" AutoGenerateColumns="false" Width="100%" Style="border: #CFCFCF 1px solid;"
                                AllowPaging="true" PagerStyle-Position="Top" PagerStyle-HorizontalAlign="right"
                                PagerStyle-BackColor="#6495ED" PagerStyle-Font-Bold="true" PagerStyle-NextPageText="&nbsp;&nbsp;Next >>>"
                                PagerStyle-PrevPageText="<<< Pre&nbsp;&nbsp;" PagerStyle-Mode="NextPrev" PageSize="10">
                                <HeaderStyle BackColor="#bec4e3" />
                                <Columns>
                                    <asp:BoundColumn DataField="part_no" HeaderText="Part No" ItemStyle-Width="20%" ItemStyle-BackColor="#FFFAFA">
                                    </asp:BoundColumn>
                                    <asp:BoundColumn DataField="company_id" HeaderText="Company Id" ItemStyle-Width="20%"
                                        ItemStyle-BackColor="#FFFAFA"></asp:BoundColumn>
                                    <asp:BoundColumn DataField="SHIPTO_ID" HeaderText="Ship To" ItemStyle-Width="20%"
                                        ItemStyle-BackColor="#FFFAFA"></asp:BoundColumn>
                                    <asp:BoundColumn DataField="product_type" HeaderText="Product Type" ItemStyle-Width="20%"
                                        ItemStyle-BackColor="#FFFAFA"></asp:BoundColumn>
                                    <asp:ButtonColumn CommandName="DeleteTempItem" Text="Delete" HeaderText="Del" ItemStyle-Width="20%"
                                        ButtonType="PushButton" ItemStyle-BackColor="#FFFAFA"></asp:ButtonColumn>
                                </Columns>
                            </asp:DataGrid>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button runat="Server" ID="SubmitAll" Text="Submit All" OnClick="SubmitAll_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" width="100%">
                            <!---->
                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle"
                                id="Table3">
                                <tr>
                                    <td>
                                        <!--SH-->
                                        <table>
                                            <tr>
                                                <td>
                                                    Search By:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="drpFields" runat="server">
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtStr" runat="server"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:Button ID="btnSH" runat="server" Text="Search" OnClick="sh" />
                                                </td>
                                            </tr>
                                        </table>
                                        <!--SH-->
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-left: 10px; border-bottom: #ffffff 1px solid; height: 20px; background-color: #6699CC"
                                        align="left" valign="middle" class="text">
                                        <font color="#ffffff"><b>Product Customer Dictionary</b></font>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="GridView1" DataSourceID="SqlDataSource1" OnRowDataBound="GridView1_RowDataBound"
                                            DataKeyNames="PART_NO" AllowPaging="True" PageIndex="0" PageSize="30" Width="100%">
                                            <Columns>
                                                <asp:CommandField ShowDeleteButton="true" HeaderText="Del" />
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"
                                            DeleteCommand="delete from PRODUCT_CUSTOMER_DICT where PART_NO=@PART_NO" OnDeleted="SqlDataSource1_Deleted">
                                            <DeleteParameters>
                                                <asp:Parameter Type="String" Name="PART_NO" />
                                            </DeleteParameters>
                                        </asp:SqlDataSource>
                                    </td>
                                </tr>
                                <tr>
                                    <td id="tdTotal" align="right" style="background-color: #ffffff" runat="server">
                                    </td>
                                </tr>
                            </table>
                            <!---->
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
