<%@ Page Title="MyAdvantech - ERPID - Org Id Mapping" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Function Org2Name(ByVal Org As String) As String
        Select Case Org
            Case "TW01"
                Return "Taiwan"
            Case "EU10"
                Return "Europe"
            Case "AU01"
                Return "Taiwan"
            Case "BR01"
                Return "Brazil"
            Case "CN01", "CN10"
                Return "China"
            Case "JP01"
                Return "Japan"
            Case "KR01"
                Return "Korea"
            Case "MY01"
                Return "Malaysia"
            Case "SG01"
                Return "Singapore"
            Case "TL01"
                Return "Thailand"
            Case "US01"
                Return "US"
            Case Else
                Return Left(Org, 2)
        End Select
    End Function
    Protected Sub btnAdd_Click(sender As Object, e As System.EventArgs)
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Try
            Dim cmd As New SqlClient.SqlCommand("select count(*) from sap_dimcompany where company_id=@CID and org_id=@ORGID", conn)
            cmd.Parameters.Add("CID", SqlDbType.NVarChar).Value = Trim(txtERPID.Text).ToUpper()
            cmd.Parameters.Add("ORGID", SqlDbType.NVarChar).Value = Trim(dlOrg.SelectedValue).ToUpper()
            conn.Open()
            Dim r As Integer = cmd.ExecuteScalar()
            If r > 0 Then
                cmd.CommandText = "delete from sap_company_org where company_id=@CID and org_id=@ORGID; " + _
                    " insert into sap_company_org (company_id, org_id, org_name) values (@CID,@ORGID,@ORGNAME)"
                cmd.Parameters.Add("ORGNAME", SqlDbType.NVarChar).Value = Org2Name(Trim(dlOrg.SelectedValue).ToUpper())
                cmd.ExecuteNonQuery()
                lbMsg.Text = Trim(txtERPID.Text).ToUpper() + "/" + Trim(dlOrg.SelectedValue).ToUpper() + " added"
                gv1.DataBind()
            Else
                lbMsg.Text = "company id/org id not found"
            End If
        Catch ex As Exception
            lbMsg.Text = ex.ToString()
        End Try
        conn.Close()
    End Sub
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetERPID(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter( _
            String.Format("select distinct top 10 company_id from MyAdvantechGlobal.dbo.sap_dimcompany where company_id like '{0}%' and COMPANY_TYPE='Z001' order by company_id ", Trim(prefixText).Replace("'", "''")), _
                                                ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.Fill(dt)
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ext1" TargetControlID="txtERPID" MinimumPrefixLength="1" CompletionInterval="300" ServiceMethod="GetERPID" />
    <asp:SqlDataSource runat="server" ID="srcOrg" ConnectionString="<%$ConnectionStrings:MY %>" SelectCommand="select distinct org_id from SAP_DIMCOMPANY order by ORG_ID " />
    <table width="100%">
        <tr>
            <td>
                <table>
                    <tr>
                        <th align="left">Company Id:</th><td><asp:TextBox runat="server" ID="txtERPID" /></td>
                        <th align="left">Org:</th><td><asp:DropDownList runat="server" ID="dlOrg" DataSourceID="srcOrg" DataTextField="org_id" DataValueField="org_id" /></td>
                        <td>
                            <asp:Button runat="server" ID="btnAdd" Text="Add" OnClick="btnAdd_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <asp:UpdatePanel runat="server" ID="up3" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>                            
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" DataSourceID="src1" DataKeyNames="company_id,org_id" Width="500px">
                            <Columns>
                                <asp:CommandField ShowDeleteButton="true" />
                                <asp:BoundField HeaderText="Company Id" DataField="company_id" SortExpression="company_id" />
                                <asp:BoundField HeaderText="Org." DataField="org_id" SortExpression="org_id" />
                                <asp:BoundField HeaderText="Org. Name" DataField="org_name" SortExpression="org_name" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" 
                            SelectCommand="select * from sap_company_org" 
                            DeleteCommand="delete from sap_company_org where company_id=@company_id and org_id=@org_id">                        
                        </asp:SqlDataSource>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>