<%@ Page Title="MyAdvantech - AOnline Contact List Generate Function" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Register Src="AOnlineFunctionLinks.ascx" TagName="AOnlineFunctionLinks" TagPrefix="uc1" %>
<script runat="server">

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        GetContactList()
    End Sub
    
    Sub GetContactList()
        gvContacts.Visible = True
        Dim arRBU As ArrayList = DataMiningUtil.GetRBU()
        If arRBU.Count = 0 Then
            gvContacts.Visible = False : PanelSiebelContacts.Height = Unit.Pixel(50) : Exit Sub
        End If
       
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 100 a.ROW_ID, a.ACCOUNT, a.ERPID, a.FirstName, a.LastName, a.EMAIL_ADDRESS, a.ACCOUNT_STATUS, a.ACCOUNT_ROW_ID, b.RBU  "))
            .AppendLine(String.Format(" from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID  "))
            .AppendLine(String.Format(" where dbo.IsEmail(a.email_address)=1 and a.EMAIL_ADDRESS not like '%@advantech%.%' " + _
                                      " and a.ACTIVE_FLAG='Y' and a.NeverMail<>'Y' and b.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
            If String.IsNullOrEmpty(txtActName.Text) = False Then .AppendLine(String.Format(" and a.ACCOUNT like N'%" + Replace(Replace(Trim(txtActName.Text), "'", "''"), "*", "%") + "%' "))
            If String.IsNullOrEmpty(txtOptyName.Text) = False Then
                .AppendLine(String.Format(" and a.ACCOUNT_ROW_ID in (select distinct z.ACCOUNT_ROW_ID from SIEBEL_OPPORTUNITY z " + _
                                          " where z.NAME like N'%{0}%' or z.DESC_TEXT like N'%{0}%' and z.ACCOUNT_ROW_ID is not null) ", Replace(Replace(Trim(txtOptyName.Text), "'", "''"), "*", "%")))
            End If
            If String.IsNullOrEmpty(txtSAPOrderPN.Text) = False Then
                .AppendLine(String.Format(" and a.ERPID<>'' and a.ERPID in (select distinct top 100 z.Customer_ID from eai_order_log z where z.item_no like N'%" + Replace(Replace(Trim(txtSAPOrderPN.Text), "'", "''"), "*", "%") + "%') "))
            End If
            .AppendLine(String.Format(" order by a.ACCOUNT_ROW_ID, a.ROW_ID  "))
        End With
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        Dim dt As New DataTable
        apt.Fill(dt)
        gvContacts.DataSource = dt : gvContacts.DataBind()
        If gvContacts.Rows.Count >= 50 Then
            PanelSiebelContacts.Height = Unit.Pixel(200)
        ElseIf gvContacts.Rows.Count > 0 Then
            PanelSiebelContacts.Height = Unit.Pixel(50)
        Else
            PanelSiebelContacts.Height = Unit.Pixel(50) : gvContacts.Visible = False
        End If
    End Sub
    
    Protected Sub cbHeaderRowAll_CheckedChanged(sender As Object, e As System.EventArgs)
        Dim ck As Boolean = CType(sender, CheckBox).Checked
        For Each r As GridViewRow In gvContacts.Rows
            If r.RowType = DataControlRowType.DataRow Then
                CType(r.FindControl("cbRowCheckContact"), CheckBox).Checked = ck
            End If
        Next
    End Sub

    Protected Sub btnAdd2List_Click(sender As Object, e As System.EventArgs)
        Try
            lbAddContactMsg.Text = ""
            If dlMyList.SelectedIndex >= 0 Then
                Dim mArry As New ArrayList
                Select Case rblAddOption.SelectedIndex
                    Case 0
                        For Each r As GridViewRow In gvContacts.Rows
                            If r.RowType = DataControlRowType.DataRow Then
                                Dim mv As String = CType(r.FindControl("hdRowEmail"), HiddenField).Value
                                If Not mArry.Contains(mv) Then mArry.Add(CType(r.FindControl("hdRowEmail"), HiddenField).Value)
                            End If
                        Next
                    Case 1
                        txtAddMails.Text = Replace(txtAddMails.Text, ",", ";")
                        Dim ms() As String = Split(txtAddMails.Text, ";")
                        For Each m As String In ms
                            If Util.IsValidEmailFormat(m) AndAlso Not mArry.Contains(m) Then mArry.Add(m)
                        Next
                    Case 2
                       
                End Select
                If mArry.Count = 0 Then
                    lbAddContactMsg.Text = "No contact to be added"
                Else
                    If AOnlineUtil.AOnlineSalesCampaign.AddContactEmails2ContactList(dlMyList.SelectedValue, mArry) Then
                        lbAddContactMsg.Text = "Contacts have been added to selected contact list" : gvMyList.DataBind()
                    Else
                        lbAddContactMsg.Text = "No contact has been added"
                    End If
                End If
            Else
                lbAddContactMsg.Text = "Please select or create a contact list first"
            End If
        Catch ex As Exception
            lbAddContactMsg.Text = ex.ToString()
        End Try
       
    End Sub

    Protected Sub btnNewList_Click(sender As Object, e As System.EventArgs)
        lbAddListMsg.Text = ""
        If String.IsNullOrEmpty(txtNewListName.Text) = False Then
            AOnlineUtil.AOnlineSalesCampaign.CreateMyContactList(txtNewListName.Text)
            lbAddListMsg.Text = "Contact list " + txtNewListName.Text + " has been created"
            gvMyList.DataBind() : dlMyList.DataBind() : dlMyList.SelectedIndex = 0
            dlMyList_SelectedIndexChanged(Nothing, Nothing)
        Else
            lbAddListMsg.Text = "Contact list name is empty"
        End If
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            srcMyList.SelectParameters("CBY").DefaultValue = User.Identity.Name
        End If
    End Sub

    Protected Sub lnkRowDelMyList_Click(sender As Object, e As System.EventArgs)
        Dim lnk As LinkButton = sender
        Dim hdLid As String = CType(lnk.NamingContainer.FindControl("hdRowListID"), HiddenField).Value
        AOnlineUtil.AOnlineSalesCampaign.DeleteMyContactList(hdLid)
        gvMyList.DataBind() : dlMyList.DataBind()
    End Sub

    Protected Sub fup1_UploadedComplete(sender As Object, e As AjaxControlToolkit.AsyncFileUploadEventArgs)
        lbFupMsg.Text = ""
        ScriptManager.RegisterClientScriptBlock(Me, Me.GetType(), "reply", "document.getElementById('" & lbFupMsg.ClientID & "').innerHTML= 'Done!';", True)
        If dlMyList.SelectedIndex >= 0 Then
            Dim mArry As New ArrayList
            If fup1.HasFile AndAlso _
                                   (fup1.FileName.EndsWith(".xls", StringComparison.OrdinalIgnoreCase) Or fup1.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase)) Then
                Dim dt As DataTable = Util.ExcelFile2DataTable(fup1.FileContent)
                For Each r As DataRow In dt.Rows
                    Dim mv As String = r.Item(0)
                    If Util.IsValidEmailFormat(mv) AndAlso Not mArry.Contains(mv) Then mArry.Add(mv)
                Next
                If mArry.Count = 0 Then
                    lbFupMsg.Text = "No contact to be added"
                Else
                    If AOnlineUtil.AOnlineSalesCampaign.AddContactEmails2ContactList(dlMyList.SelectedValue, mArry) Then
                        lbFupMsg.Text = "Contacts have been added to selected contact list" : gvMyList.DataBind()
                    Else
                        lbFupMsg.Text = "No contact has been added"
                    End If
                End If
            End If
        Else
            lbFupMsg.Text = "Please select or create a contact list first"
        End If
    End Sub

    Protected Sub dlMyList_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        hySeeContactList.NavigateUrl = "~/My/AOnline/MyContactList.aspx?ListID=" + dlMyList.SelectedValue
    End Sub

    Protected Sub Page_PreRender(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            
        End If
    End Sub

    Protected Sub TimerSeeList_Tick(sender As Object, e As System.EventArgs)
        Try
            TimerSeeList.Interval = 99999
            dlMyList_SelectedIndexChanged(Nothing, Nothing)
        Catch ex As Exception

        End Try
        TimerSeeList.Enabled = False
    End Sub

    Protected Sub rblAddOption_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        Select Case rblAddOption.SelectedIndex
            Case 0
                trSearchSiebel.Visible = True : trAddEmail.Visible = False : trUploadXls.Visible = False
            Case 1
                trSearchSiebel.Visible = False : trAddEmail.Visible = True : trUploadXls.Visible = False
            Case 2
                trSearchSiebel.Visible = False : trAddEmail.Visible = False : trUploadXls.Visible = True
        End Select
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <h2>
                    List Generation</h2>
            </td>
            <td align="right">
                <uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:RadioButtonList runat="server" ID="rblAddOption" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblAddOption_SelectedIndexChanged">
                    <asp:ListItem Text="Search Siebel" Selected="True" />
                    <asp:ListItem Text="Add Email manually" />
                    <asp:ListItem Text="Upload by Excel" />
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr runat="server" id="trSearchSiebel" visible="true">
            <td>
                <table width="100%">
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="PanelSearchContact" DefaultButton="btnSearch">
                                <table>
                                    <tr>
                                        <th align="left">
                                            Siebel Account Name
                                        </th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtActName" Width="250px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">
                                            Siebel Opportunity Name
                                        </th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtOptyName" Width="250px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">
                                            SAP Ordered P/N
                                        </th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSAPOrderPN" Width="250px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upSearchContact" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Panel runat="server" ID="PanelSiebelContacts" Width="100%" Height="50px" ScrollBars="Auto">
                                        <asp:GridView runat="server" ID="gvContacts" Width="100%" AutoGenerateColumns="false">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox runat="server" ID="cbHeaderRowAll" AutoPostBack="true" Checked="true"
                                                            OnCheckedChanged="cbHeaderRowAll_CheckedChanged" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox runat="server" ID="cbRowCheckContact" Checked="true" />
                                                        <asp:HiddenField runat="server" ID="hdRowEmail" Value='<%#Eval("EMAIL_ADDRESS") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Account">
                                                    <ItemTemplate>
                                                        <a target="_blank" href='../../DM/CustomerDashboard.aspx?ROWID=<%#Eval("ACCOUNT_ROW_ID") %>&ERPID=<%#Eval("ERPID") %>'>
                                                            <%#Eval("ACCOUNT")%></a>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="First Name" DataField="FirstName" SortExpression="FirstName" />
                                                <asp:BoundField HeaderText="Last Name" DataField="LastName" SortExpression="LastName" />
                                                <asp:TemplateField HeaderText="Email">
                                                    <ItemTemplate>
                                                        <a target="_blank" href='../../DM/ContactDashboard.aspx?ROWID=<%#Eval("ROW_ID") %>'>
                                                            <%#Eval("EMAIL_ADDRESS")%></a>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" SortExpression="ACCOUNT_STATUS" />
                                                <asp:BoundField HeaderText="Org." DataField="RBU" SortExpression="RBU" />
                                            </Columns>
                                        </asp:GridView>
                                    </asp:Panel>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>        
        <tr runat="server" id="trAddEmail" visible="false">
            <td>
                <table width="100%">
                                <tr>
                                    <th align="left">
                                        Add Email
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtAddMails" Width="500px" />
                                    </td>
                                    <td>
                                        (Split by ; for multiple emails)
                                    </td>
                                </tr>
                            </table>
            </td>
        </tr>
        <tr runat="server" id="trUploadXls" visible="false">
            <td>
                <table width="100%">
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td>
                                        Upload My Excel List:
                                    </td>
                                    <td>
                                        <a href="http://ec.advantech.eu/Files/ContactList.xls">Sample Excel</a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="1">
                            <ajaxToolkit:AsyncFileUpload runat="server" ID="fup1" Width="800px" ThrobberID="imgUploadingProdPhoto"
                                OnClientUploadError="uploadError" OnClientUploadStarted="StartUpload" OnClientUploadComplete="UploadComplete"
                                CompleteBackColor="Lime" UploaderStyle="Modern" ErrorBackColor="Red" UploadingBackColor="#66CCFF"
                                OnUploadedComplete="fup1_UploadedComplete" />
                            &nbsp;<asp:Image runat="server" ID="imgUploadingProdPhoto" ImageUrl="~/Images/loading2.gif"
                                AlternateText="Loading..." />
                            <asp:Label runat="server" ID="lbFupMsg" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table>
                    <tr>
                        <td colspan="3">
                            <a href="javascript:void(0);" onclick='ShowListPanel();'>Create a New List</a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button runat="server" ID="btnAdd2List" Text="Add To My Mailist List" OnClick="btnAdd2List_Click" />
                        </td>
                        <th align="left">
                            List Name:
                        </th>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upMyDlList" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:DropDownList runat="server" ID="dlMyList" DataTextField="LIST_NAME" DataSourceID="srcMyList"
                                        DataValueField="ROW_ID" AutoPostBack="true" OnSelectedIndexChanged="dlMyList_SelectedIndexChanged" />
                                    <asp:SqlDataSource runat="server" ID="srcMyList" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                                        SelectCommand="select top 10 ROW_ID, LIST_NAME, CREATED_DATE, (select count(z.row_id) from AONLINE_SALES_CONTACTLIST_DETAIL z where z.LIST_ID=a.ROW_ID) as contacts 
                                        from AONLINE_SALES_CONTACTLIST_MASTER a where a.USERID=@CBY order by CREATED_DATE desc">
                                        <SelectParameters>
                                            <asp:Parameter ConvertEmptyStringToNull="false" Name="CBY" />
                                        </SelectParameters>
                                    </asp:SqlDataSource>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnNewList" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upSeeContactList" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="TimerSeeList" Interval="100" OnTick="TimerSeeList_Tick" />
                                    <asp:HyperLink runat="server" ID="hySeeContactList" Text="See Contact List" NavigateUrl="~/My/AOnline/MyContactList.aspx"
                                        Target="_blank" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="dlMyList" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="btnNewList" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr style="height: 15px">
                        <td colspan="4">
                            <asp:UpdatePanel runat="server" ID="upAddContact" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbAddContactMsg" Font-Bold="true" ForeColor="Tomato" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnAdd2List" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <script type="text/javascript">

        function uploadError(sender, args) {
            alert('Error during upload');
        }

        function StartUpload(sender, args) {

        }

        function UploadComplete(sender, args) {
            alert('Contacts in excel have been imported to selected contact list');
        }

        function ShowListPanel() {
            var divMoz = document.getElementById('divList');
            divMoz.style.display = 'block';
        }
        function CloseDivList() {
            var divMoz = document.getElementById('divList');
            divMoz.style.display = 'none';
        }
    </script>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="ListDetail" HorizontalSide="Center" VerticalSide="Middle" HorizontalOffset="350"
        VerticalOffset="300" />
    <asp:Panel runat="server" ID="ListDetail" DefaultButton="btnNewList">
        <div id="divList" style="display: none; background-color: white; border: solid 1px silver;
            padding: 10px; width: 750px; height: 450px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td>
                        <a href="javascript:void(0);" onclick="CloseDivList();">Close</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="divListDetail">
                            <table width="100%">
                                <tr>
                                    <td>
                                        Name:
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtNewListName" Width="200px" />
                                    </td>
                                    <td>
                                        <asp:Button runat="server" ID="btnNewList" Text="Create" OnClick="btnNewList_Click" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:UpdatePanel runat="server" ID="upNewList" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Label runat="server" ID="lbAddListMsg" Font-Bold="true" ForeColor="Tomato" />
                                                <asp:GridView runat="server" ID="gvMyList" Width="100%" AutoGenerateColumns="false"
                                                    DataSourceID="srcMyList">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:UpdatePanel runat="server" ID="upRowDelList" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <asp:HiddenField runat="server" ID="hdRowListID" Value='<%#Eval("ROW_ID") %>' />
                                                                        <asp:LinkButton runat="server" ID="lnkRowDelMyList" Text="Delete" OnClientClick="return confirm('Are you sure to delete this list?');"
                                                                            OnClick="lnkRowDelMyList_Click" />
                                                                    </ContentTemplate>
                                                                    <Triggers>
                                                                        <asp:PostBackTrigger ControlID="lnkRowDelMyList" />
                                                                    </Triggers>
                                                                </asp:UpdatePanel>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="Name" DataField="LIST_NAME" SortExpression="LIST_NAME" />
                                                        <asp:BoundField HeaderText="Created Date" DataField="CREATED_DATE" SortExpression="CREATED_DATE" />
                                                        <asp:TemplateField HeaderText="Contacts" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='MyContactList.aspx?ListID=<%#Eval("ROW_ID") %>'>
                                                                    <%#Eval("Contacts")%></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnNewList" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>
</asp:Content>
