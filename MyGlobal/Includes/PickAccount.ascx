<%@ Control Language="VB" ClassName="PickAccount" %>
<%@ Import Namespace="System.Reflection" %>

<script runat="server">
    Public Sub getData(ByVal Name As String, ByVal RBU As String, ByVal erpid As String, _
                                          ByVal country As String, ByVal location As String, ByVal STATE As String, _
                                          ByVal PROVINCE As String, ByVal status As String, ByVal address1 As String, ByVal Zip As String, ByVal City As String)
        Dim SQLSTR As String = ""
  
        SQLSTR = CreateSAPCustomerDAL.GET_Siebel_Account_List(Name, RBU, erpid, country, location, STATE, PROVINCE, status, address1, Zip, City)

        'TEST.Text = SQLSTR
        'Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "", "ming.zhao@advantech.com.cn", "", "", SQLSTR)
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", SQLSTR)
        GridView2.DataSource = dt
        GridView2.DataBind()
        Me.GridView1.DataSource = dt
    End Sub

    Public Sub ShowData(ByVal Name As String, ByVal RBU As String, ByVal erpid As String, _
                                            ByVal country As String, ByVal location As String, ByVal STATE As String, ByVal PROVINCE As String, _
                                            ByVal status As String, ByVal address1 As String, ByVal Zip As String, ByVal City As String)
        getData(Name, RBU, erpid, country, location, STATE, PROVINCE, status, address1, Zip, City)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        InvokeShowData()
    End Sub
    
    Sub InvokeShowData()
        Dim RBU_Str As String = "AENC"
        RBU_Str=""
        'For i As Integer = 0 To cblRBU.Items.Count - 1
        '    If cblRBU.Items(i).Selected Then RBU_Str += GetSafeStr(cblRBU.Items(i).Value) + ","
        'Next
        ShowData(GetSafeStr(Me.txtName.Text), RBU_Str.Trim(","), _
               GetSafeStr(Me.txtID.Text), GetSafeStr(Me.txtCounrty.Text), _
               GetSafeStr(Me.txtLocation.Text), GetSafeStr(Me.txtState.Text), _
               GetSafeStr(Me.txtProvince.Text), Me.drpStatus.SelectedValue, _
               GetSafeStr(Me.txtAddress1.Text), GetSafeStr(txtZip.Text), _
               GetSafeStr(txtcity.Text))
    End Sub
    Protected Function GetSafeStr(ByVal Str As String) As String
        'If Str.Trim = "'" Then Return ""
        Return Replace(Str.Trim.Replace("'", "''"), "*", "%")
    End Function
    Protected Sub btnSH_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.txtState.Text = Me.txtProvince.Text
        InvokeShowData()
    End Sub
    Public leftSize As String = "-50px"
    Private Function GetleftSize() As String
        If ViewState("leftSize") IsNot Nothing Then
            Return ViewState("leftSize").ToString()
        End If
        Return "-50px"
    End Function
    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim o As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As Object = Me.GridView1.DataKeys(row.RowIndex).Values
        Dim P As Page = Me.Parent.Page
        Dim TP As Type = P.GetType()
        Dim MI As MethodInfo = Nothing
        'If hType.Value = "ALL" Then
        MI = TP.GetMethod("PickAccountEnd")
        'End If
     
            
        Dim para(0) As Object
        para(0) = key
        MI.Invoke(P, para)
    End Sub
</script>


 
            <asp:GridView ID="GridView2" runat="server" Visible="false">
            </asp:GridView>
            <asp:Panel DefaultButton="btnSH" runat="server" ID="pldd">
                <table>
                    <tr>
                        <th align="left" style="color: #333333">
                            Name:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtName" Width="80" />
                        </td>
                        <th align="left" style="color: #333333;display:none;">
                            ERP ID:
                        </th>
                        <td  style="display:none;">
                            <asp:TextBox runat="server" ID="txtID" Width="80" />
                        </td>
                        <th align="left" style="color: #333333;display:none;">
                            ORG(RBU):
                        </th>
                        <td style="display:none;">
                            <asp:TextBox runat="server" ID="txtRBUodl" Width="60" Visible="false" />
                            <div id="test" style="position: relative;" onmouseover="document.getElementById('cbllist').style.display=''"
                                onmouseout="document.getElementById('cbllist').style.display='none'">
                                <a href="javascript:void(0);" style="background-color: #004576; color: White;">Choose</a>
                                <div id="cbllist" style="display: none; position: absolute; left: <%= GetleftSize() %>;
                                    top: 15px;">
                                    <asp:CheckBoxList runat="server" ID="cblRBU" RepeatDirection="Horizontal" RepeatColumns="3"
                                        BackColor="Silver" with="500px">
                                    </asp:CheckBoxList>
                                </div>
                            </div>
                        </td>
                        <th align="left" style="color: #333333">
                            Status:
                        </th>
                        <td>
                            <asp:DropDownList runat="server" ID="drpStatus" Width="80">
                                <asp:ListItem Value="">Select...</asp:ListItem>
                                <asp:ListItem Value="01-Premier Channel Partner">01-Premier Channel Partner</asp:ListItem>
                                <asp:ListItem Value="02-Gold Channel Partner">02-Gold Channel Partner</asp:ListItem>
                                <asp:ListItem Value="03-Certified Channel Partner">03-Certified Channel Partner</asp:ListItem>
                                <asp:ListItem Value="04-DMS Premier Key">04-DMS Premier Key</asp:ListItem>
                                <asp:ListItem Value="Account">Account</asp:ListItem>
                                <asp:ListItem Value="06-Key Account">06-Key Account</asp:ListItem>
                                <asp:ListItem Value="06P-Potential Key Account">06P-Potential Key Account</asp:ListItem>
                                <asp:ListItem Value="07-General Account">07-General Account</asp:ListItem>
                                <asp:ListItem Value="08-Partner's Existing ">08-Partner's Existing </asp:ListItem>
                                <asp:ListItem Value="Customer">Customer</asp:ListItem>
                                <asp:ListItem Value="09-Assigned to Partner">09-Assigned to Partner</asp:ListItem>
                                <asp:ListItem Value="10-Sales Contact">10-Sales Contact</asp:ListItem>
                                <asp:ListItem Value="11-Prospect">11-Prospect</asp:ListItem>
                                <asp:ListItem Value="12-Leads">12-Leads</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="color: #333333">
                            Address1:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtAddress1" Width="170px" />
                        </td>
                        <th align="left" style="color: #333333">
                            City:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtcity" Width="60" />
                        </td>
                        <th align="left" style="color: #333333">
                            State/Province:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtProvince" Width="60" />
                            <asp:TextBox runat="server" ID="txtState" Width="30" Visible="false" />
                        </td>
                        <th align="left" style="color: #333333">
                          
                        </th>
                        <td>
                          
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="color: #333333">
                            Site:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtLocation" Width="60" />
                        </td>
                        <th align="left" style="color: #333333">
                            Country:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtCounrty" Width="60" />
                        </td>
                            <th align="left" style="color: #333333">
                            Zip:
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtZip" Width="60px" />
                        </td>
                        <td colspan="1">
                            <asp:Button runat="server" ID="btnSH" OnClick="btnSH_Click" Text="Search" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <asp:Panel runat="server" ID="PanelSearchResult" Width="700" Height="300px" ScrollBars="Auto"
                HorizontalAlign="Center">
                <asp:GridView DataKeyNames="ROW_ID,erpid,companyname" ID="GridView1" AllowPaging="true"
                    PageIndex="0" PageSize="10" runat="server" AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging"
                    Width="670">
                    <Columns>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Label runat="server" ID="lbPick" Text="Pick"></asp:Label>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:LinkButton runat="server" ID="lbtnPick" Text="Pick" OnClick="lbtnPick_Click"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Name" DataField="companyname" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="ROW_ID" DataField="ROW_ID"  ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="ORG(RBU)" DataField="RBU" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Account Status" DataField="Status" ItemStyle-HorizontalAlign="Left" />
                        <asp:TemplateField HeaderText="Address Information" ItemStyle-HorizontalAlign="Left"
                            ItemStyle-Width="350px">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr align="left">
                                        <th align="left" style="color: #333333; width: 34%; background-color: #EEEEEE">
                                            Country
                                        </th>
                                        <th align="left" style="color: #333333; width: 33%; background-color: #EEEEEE">
                                            city
                                        </th>
                                        <th align="left" style="color: #333333; width: 33%; background-color: #EEEEEE">
                                            Site
                                        </th>
                                    </tr>
                                    <tr>
                                        <td align="left">
                                            <%#Eval("COUNTRY")%>
                                        </td>
                                        <td align="left">
                                            <%#Eval("city")%>
                                        </td>
                                        <td align="left">
                                            <%#Eval("location")%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                            State
                                        </th>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                            Province
                                        </th>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                            Zip
                                        </th>
                                    </tr>
                                    <tr>
                                        <td align="left">
                                            <%#Eval("State")%>
                                        </td>
                                        <td align="left">
                                            <%#Eval("province")%>
                                        </td>
                                        <td align="left">
                                            <%#Eval("ZIPCODE")%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                            Address1
                                        </th>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                            Address2
                                        </th>
                                        <th align="left" style="color: #333333; background-color: #EEEEEE">
                                        </th>
                                    </tr>
                                    <tr>
                                        <td align="left">
                                            <%#Eval("Address")%>
                                        </td>
                                        <td align="left">
                                            <%#Eval("Address2")%>
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
