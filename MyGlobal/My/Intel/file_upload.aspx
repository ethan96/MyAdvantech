<%@ Page Title="MyAdvantech Intel Portal - File Upload Administration" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>
<%@ Register TagPrefix="fup" Namespace="OboutInc.FileUpload" Assembly="obout_FileUpload" %>
<script runat="server">
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim authFlg As Boolean = False, cu As String = User.Identity.Name.ToLower()
            authFlg = IntelPortal.Allowed2UploadFileUsers.Contains(cu)
            If Not authFlg Then
                Response.Redirect("../../home.aspx")
            End If
        End If
    End Sub

    Protected Sub btnUpload_Click(sender As Object, e As System.EventArgs)
        If Page.IsPostBack Then
            Dim rid As String = Util.NewRowId("INTEL_PORTAL_FILES", "MyLocal")
            Dim fext As String = IO.Path.GetExtension(fup1.FileName)
            If fext.StartsWith(".") AndAlso fext.Length > 1 Then fext = fext.Substring(1)
            Dim fDesc As String = HttpUtility.HtmlEncode(txtFDesc.Text)
            If fDesc.Length > 1000 Then fDesc = fDesc.Substring(0, 1000)
            Dim fname As String = fup1.FileName
            Try
                If fup1.FileBytes.Length <= 50 * 1000000 AndAlso fup1.HasFile AndAlso fup1.FileBytes.Length > 0 Then
              
                    Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
                    Dim cmd As New SqlClient.SqlCommand( _
                        " INSERT INTO INTEL_PORTAL_FILES (ROW_ID, FILE_NAME, FILE_EXT, FILE_BIN, FILE_DESC, UPLOADED_BY, IS_VISIBLE, DOWNLOAD_TYPE) " + _
                        " VALUES (@RID, @FNAME, @FEXT, @FBIN, @FDESC, @CBY, 1, @DLTYPE)", conn)
                    With cmd.Parameters
                        .AddWithValue("RID", rid) : .AddWithValue("FNAME", fname) : .AddWithValue("FEXT", fext)
                        .AddWithValue("FBIN", fup1.FileBytes)
                        .AddWithValue("FDESC", fDesc) : .AddWithValue("CBY", User.Identity.Name)
                        .AddWithValue("DLTYPE", rblFType.SelectedValue)
                    End With
                    conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
                    gvFiles.DataBind()
                    txtFDesc.Text = ""
                End If
            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw", "myadvantech@advantech.com", "Upload intel file error by " + User.Identity.Name, fname + " " + fup1.FileBytes.Length.ToString() + " bytes", False, "", "")
            End Try
        End If
    End Sub

    Protected Sub lnkRowDeleteBtn_Click(sender As Object, e As System.EventArgs)
        Dim cRow As GridViewRow = CType(CType(sender, LinkButton).NamingContainer, GridViewRow)
        Dim lnkDel As LinkButton = CType(sender, LinkButton)
        Dim IsVisisble As String = CType(cRow.FindControl("hd_SHOWHIDE"), HiddenField).Value
        Dim rid As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hd_RowID"), HiddenField).Value
        Dim ShowHideValue As String = IIf(IsVisisble = "True", "0", "1")
        dbUtil.dbExecuteNoQuery("MyLocal", "update INTEL_PORTAL_FILES set IS_VISIBLE=" + ShowHideValue + " where ROW_ID='" + rid + "'")
        gvFiles.DataBind()
    End Sub

    Protected Sub gvFiles_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
       
    End Sub

    Protected Sub gvFiles_DataBound(sender As Object, e As System.EventArgs)
        For Each Row As GridViewRow In gvFiles.Rows
            If Row.RowType = DataControlRowType.DataRow Then
                ' Dim cRow As GridViewRow = e.Row
                Dim lnkDel As LinkButton = Row.FindControl("lnkRowDeleteBtn")
                Dim IsVisisble As String = CType(Row.FindControl("hd_SHOWHIDE"), HiddenField).Value
                If IsVisisble = "True" Then
                    lnkDel.Text = "Hide"
                Else
                    lnkDel.Text = "Show"
                End If
            End If
        Next
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">   
    <table width="100%">
        <tr>
            <th align="left"><h2>Intel Portal Content Admin</h2></th>
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <th align="left">File Path</th><td><asp:FileUpload runat="server" ID="fup1" Width="600px" /></td>
                    </tr>
                    <tr>
                        <th align="left">File Description:</th>
                        <td>
                            <asp:TextBox runat="server" ID="txtFDesc" Width="600px" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">File Type:</th>
                        <td>
                            <asp:RadioButtonList runat="server" ID="rblFType" RepeatColumns="2" RepeatDirection="Horizontal">
                                <asp:ListItem Text="Download Area" Value="DL" Selected="True" />
                                <asp:ListItem Text="eNewsletter" Value="EDM" />
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2"><asp:Button runat="server" ID="btnUpload" Text="Upload" OnClick="btnUpload_Click" /> </td>
                    </tr>
                </table>        
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upFiles" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gvFiles" AutoGenerateColumns="false" DataSourceID="srcFiles" EnableTheming="false"
                            Width="100%" DataKeyNames="ROW_ID" OnRowDataBound="gvFiles_RowDataBound" OnDataBound="gvFiles_DataBound">
                            <Columns>
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:HiddenField runat="server" ID="hd_SHOWHIDE" Value='<%#Eval("IS_VISIBLE") %>' />
                                        <asp:LinkButton runat="server" ID="lnkRowDeleteBtn" Text="Hide" OnClick="lnkRowDeleteBtn_Click" />
                                        <asp:HiddenField runat="server" ID="hd_RowID" Value='<%#Eval("ROW_ID") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="File Name" SortExpression="FILE_NAME">
                                    <ItemTemplate>
                                        <a href='dl_intel_file.ashx?FID=<%#Eval("ROW_ID") %>'>
                                            <%#Eval("FILE_NAME")%></a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="File Extenstion" DataField="FILE_EXT" SortExpression="FILE_EXT" />
                                <asp:BoundField HeaderText="Uploaded Date" DataField="UPLOAD_DATE" SortExpression="UPLOAD_DATE" />
                                <asp:BoundField HeaderText="Uploaded By" DataField="UPLOADED_BY" SortExpression="UPLOADED_BY" />
                                <asp:BoundField HeaderText="Content Type" DataField="DOWNLOAD_TYPE" SortExpression="DOWNLOAD_TYPE" /> 
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="srcFiles" ConnectionString="<%$ConnectionStrings:MyLocal %>"
                            SelectCommand="SELECT ROW_ID, FILE_NAME, FILE_EXT, FILE_DESC, ACTIVE_FLAG, UPLOAD_DATE, UPLOADED_BY, 
                            LAST_UPD_DATE, LAST_UPD_BY, RELEASE_DATE, IS_VISIBLE, 
                            case DOWNLOAD_TYPE when 'DL' then 'Download Area' when 'EDM' then 'eNewsletter' end as DOWNLOAD_TYPE
                            FROM INTEL_PORTAL_FILES 
                            order by UPLOAD_DATE desc" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>