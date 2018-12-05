<%@ Page Title="MyAdvantech - Intel Portal" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not IntelPortal.IsIntelUser() Then
                Response.Redirect("login_check.aspx")
            End If
            hyUploadIntelFiles.Visible = IntelPortal.Allowed2UploadFileUsers.Contains(User.Identity.Name.ToLower())
            Dim dt As DataTable = dbUtil.dbGetDataTable("My", " select distinct TITLE, RECORD_IMG, RELEASE_DATE from MyAdvantechGlobal.dbo.WWW_RESOURCES where TITLE like '%mom%' order by RELEASE_DATE desc ")
            gvres.DataSource = dt
            gvres.DataBind()
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <h1>
                    Intel Portal</h1>
            </td>
        </tr>
        <tr>
            <td style="height: 5px">
                &nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <h3>
                    Download Area</h3>
            </td>
        </tr>
        <tr>
            <td align="right">
                <asp:HyperLink runat="server" ID="hyUploadIntelFiles" Visible="false" NavigateUrl="~/My/Intel/file_upload.aspx"
                    Text="Upload File (Internal Only)" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvres" AutoGenerateColumns="false" Width="100%"
                    DataKeyNames="TITLE" ShowHeader="false" EnableTheming="false">
                    <Columns>
                        <asp:TemplateField HeaderText="File Name" SortExpression="FILE_NAME">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>
                                        <td align="left" style="font-size: larger">
                                            <a href='<%#Eval("RECORD_IMG") %>' target="_blank">
                                                <%#Eval("TITLE")%></a>
                                        </td>
                                        <td align="right">
                                            <%#Util.FormatDate(Eval("RELEASE_DATE"))%>
                                        </td>
                                    </tr>
                                    <%--  <tr>
                                        <td colspan="2">
                                            &nbsp;&nbsp;<%#Eval("ABSTRACT")%>
                                        </td>
                                    </tr>--%>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:GridView runat="server" ID="gvFiles" AutoGenerateColumns="false" DataSourceID="srcFiles"
                    Width="100%" DataKeyNames="ROW_ID" ShowHeader="false" EnableTheming="false">
                    <Columns>
                        <asp:TemplateField HeaderText="File Name" SortExpression="FILE_NAME">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>
                                        <td align="left" style="font-size: larger">
                                            <a href='dl_intel_file.ashx?FID=<%#Eval("ROW_ID") %>' target="_blank">
                                                <%#Eval("FILE_NAME")%></a>
                                        </td>
                                        <td align="right">
                                            <%#Util.FormatDate(Eval("UPLOAD_DATE"))%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            &nbsp;&nbsp;<%#Eval("FILE_DESC")%>
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="srcFiles" ConnectionString="<%$ConnectionStrings:MyLocal %>"
                    SelectCommand="SELECT ROW_ID, FILE_NAME, FILE_EXT, FILE_DESC, ACTIVE_FLAG, UPLOAD_DATE, UPLOADED_BY, LAST_UPD_DATE, LAST_UPD_BY, RELEASE_DATE
                        FROM INTEL_PORTAL_FILES where IS_VISIBLE=1 and DOWNLOAD_TYPE='DL'
                        order by UPLOAD_DATE desc" />
            </td>
        </tr>
        <tr style="display: none">
            <td>
                &nbsp;&nbsp;&nbsp;&nbsp;<h3>
                    Newsletters</h3>
            </td>
        </tr>
        <tr style="display: none">
            <td>
                <asp:GridView runat="server" ID="gvEDM" AutoGenerateColumns="false" DataSourceID="srcFiles2"
                    Width="100%" DataKeyNames="ROW_ID" ShowHeader="false" EnableTheming="false">
                    <Columns>
                        <asp:TemplateField HeaderText="File Name" SortExpression="FILE_NAME">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>
                                        <td align="left" style="font-size: larger">
                                            <a href='dl_intel_file.ashx?FID=<%#Eval("ROW_ID") %>'>
                                                <%#Eval("FILE_NAME")%></a>
                                        </td>
                                        <td align="right">
                                            <%#Util.FormatDate(Eval("UPLOAD_DATE"))%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            &nbsp;&nbsp;<%#Eval("FILE_DESC")%>
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="srcFiles2" ConnectionString="<%$ConnectionStrings:MyLocal %>"
                    SelectCommand="SELECT ROW_ID, FILE_NAME, FILE_EXT, FILE_DESC, ACTIVE_FLAG, UPLOAD_DATE, UPLOADED_BY, LAST_UPD_DATE, LAST_UPD_BY, RELEASE_DATE
                        FROM INTEL_PORTAL_FILES where IS_VISIBLE=1 and DOWNLOAD_TYPE='EDM'
                        order by UPLOAD_DATE desc" />
            </td>
        </tr>
    </table>
</asp:Content>
