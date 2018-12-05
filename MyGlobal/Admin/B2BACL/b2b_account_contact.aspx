<%@ Page Title="MyAdvantech - B2B ACL Contact Administration" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="../../Includes/ChangeCompany.ascx" TagName="ChangeCompany" TagPrefix="uc1" %>
<script runat="server">

    Protected Sub btnAddContact_Click(sender As Object, e As System.EventArgs)
        lbAddMsg.Text = ""
        If String.IsNullOrEmpty(txtAddUserID.Text) Then
            lbAddMsg.Text = "Employee's ID is empty" : Exit Sub
        End If
        If String.IsNullOrEmpty(txtAddFName.Text) Then
            lbAddMsg.Text = "Employee's First Name is empty" : Exit Sub
        End If
        If String.IsNullOrEmpty(txtAddLName.Text) Then
            lbAddMsg.Text = "Employee's Last Name is empty" : Exit Sub
        End If
        If dlJFunc.SelectedIndex = 0 Then
            lbAddMsg.Text = "Please pick a job function" : Exit Sub
        End If
        Dim cmd As New SqlClient.SqlCommand(" insert into company_contact (userid,org_id,company_id,first_name,last_name,job_function,autoupdate) " + _
                                            " values(@UID,@OID,@CID,@FN,@LN,@JFUNC,'No')", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2BACL").ConnectionString))
        With cmd.Parameters
            .AddWithValue("UID", txtAddUserID.Text) : .AddWithValue("OID", "TW01") : .AddWithValue("FN", txtAddFName.Text)
            .AddWithValue("CID", Session("company_id"))
            .AddWithValue("LN", txtAddLName.Text) : .AddWithValue("JFUNC", dlJFunc.SelectedValue)
        End With
        cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
        lbAddMsg.Text = "Added"
        gvB2BContacts.DataBind()
    End Sub
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetEZ(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 10 PrimarySmtpAddress from ADVANTECH_ADDRESSBOOK where PrimarySmtpAddress like '{0}%' order by PrimarySmtpAddress", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = Global_Inc.DeleteZeroOfStr(dt.Rows(i).Item(0))
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            'ICC 2015/8/14 This function is no longer valid. For adding TW01 PI mail list, please use PI Mail Contact Admin(TW01) link.
            Response.Redirect(Request.ApplicationPath)
            'If Util.IsInternalUser2() = False Then Response.Redirect("../../home.aspx")
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <div style="width: 200px">
                    <b>Change Company Id:</b><uc1:ChangeCompany ID="ChangeCompany1" runat="server" />
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <th align="left" colspan="8">
                            Add a New Contact
                        </th>
                    </tr>
                    <tr>
                        <th align="left">
                            User Id:
                        </th>
                        <td>
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" TargetControlID="txtAddUserID"
                                CompletionInterval="100" MinimumPrefixLength="1" ServiceMethod="GetEZ" />
                            <asp:TextBox runat="server" ID="txtAddUserID" Width="210px" />
                        </td>
                        <th align="left">
                            First Name
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtAddFName" Width="50px" />
                        </td>
                        <th align="left">
                            Last Name
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtAddLName" Width="50px" />
                        </td>
                        <th align="left">
                            Job Function:
                        </th>
                        <td>
                            <asp:DropDownList runat="server" ID="dlJFunc" Style="font-family: Arial; font-size: 8pt;
                                color: #3A4A8D; height: 20; width: 150; text-align: left">
                                <asp:ListItem Value="" Text="---- Please Select ----" />
                                <asp:ListItem Value="Sales Assistant" Text="Sales Assistant" />
                                <asp:ListItem Value="Customer Service - BTOS" Text="Customer Service - BTOS" />
                                <asp:ListItem Value="Customer Service - RMA" Text="Customer Service - RMA" />
                                <asp:ListItem Value="Technical Support" Text="Technical Support" />
                                <asp:ListItem Value="Logistics" Text="Logistics" />
                                <asp:ListItem Value="Inside Sales Engineer" Text="Inside Sales Engineer" />
                                <asp:ListItem Value="Account/Channel Manager" Text="Account/Channel Manager" />
                                <asp:ListItem Value="Field Sales Engineer" Text="Field Sales Engineer" />
                                <asp:ListItem Value="Product Manager" Text="Product Manager" />
                                <asp:ListItem Value="Marketing" Text="Marketing" />
                                <asp:ListItem Value="Sales" Text="Sales" />
                                <asp:ListItem Value="OP" Text="OP" />
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="8">
                            <asp:Button runat="server" ID="btnAddContact" Text="Add" OnClick="btnAddContact_Click" />
                        </td>
                    </tr>
                    <tr style="height: 20px">
                        <td colspan="8">
                            <asp:Label runat="server" ID="lbAddMsg" Font-Bold="true" ForeColor="Tomato" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvB2BContacts" Width="100%" AutoGenerateColumns="false"
                    DataKeyNames="USERID" DataSourceID="srcB2BContacts">
                    <Columns>
                        <asp:BoundField HeaderText="Org Id" DataField="ORG_ID" />
                        <asp:BoundField HeaderText="Company Id" DataField="COMPANY_ID" />
                        <asp:BoundField HeaderText="User Id" DataField="USERID" />
                        <asp:BoundField HeaderText="Role" DataField="JOB_FUNCTION" />
                        <asp:BoundField HeaderText="First Name" DataField="FIRST_NAME" />
                        <asp:BoundField HeaderText="Last Name" DataField="LAST_NAME" />
                        <asp:CommandField ShowDeleteButton="true" />
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="srcB2BContacts" ConnectionString="<%$ConnectionStrings:B2BACL %>"
                    SelectCommand="SELECT COMPANY_ID, ORG_ID, FIRST_NAME, LAST_NAME, JOB_FUNCTION, USERID FROM COMPANY_CONTACT WHERE (COMPANY_ID = @CID) AND (ORG_ID = 'TW01') order by userid"
                    DeleteCommand="delete from COMPANY_CONTACT where USERID=@USERID and (COMPANY_ID = @CID) AND (ORG_ID = 'TW01')">
                    <SelectParameters>
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="company_id"
                            Name="CID" />
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="org_id" Name="OID" />
                    </SelectParameters>
                    <DeleteParameters>
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="company_id"
                            Name="CID" />
                        <asp:SessionParameter ConvertEmptyStringToNull="false" SessionField="org_id" Name="OID" />
                    </DeleteParameters>
                </asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Content>
