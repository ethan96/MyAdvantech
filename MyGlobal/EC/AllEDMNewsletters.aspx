<%@ Page Title="MyAdvantech - All eDM/Newsletters" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Net" %>

<script runat="server">

    Public Function GetSearchCMS_Sql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 1000 RECORD_ID, TITLE, RELEASE_DATE, HYPER_LINK, CATEGORY_NAME, RBU "))
            .AppendLine(String.Format(" from WWW_RESOURCES "))
            .AppendLine(String.Format(" where CATEGORY_NAME in ('eDM / eNewsletter') and IS_INTERNAL_ONLY=0 "))
            If String.IsNullOrEmpty(Me.txtSearchKey.Text) = False Then .AppendLine(String.Format(" and (TITLE like N'%{0}%')  ", Trim(Me.txtSearchKey.Text).Replace("'", "''").Replace("*", "%")))
            If rblLanguage.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and RBU in ({0}) ", GetRBUByLang()))
            End If
            .AppendLine(String.Format(" order by RELEASE_DATE desc, RECORD_ID "))
        End With
        'txtSql.Text = sb.ToString()
        'Exit Function
        Return sb.ToString()
    End Function
    
    Public Function GetRBUByLang() As String
        Select Case rblLanguage.SelectedValue
            Case "ENU"
                Return "'AESC','ACL','AAU','AUK','ABN','AIT','ANADMF','ADL','AENC','AAC'"
            Case "CHS"
                Return "'ASH','ABJ','ACN'"
            Case "CHT"
                Return "'ATW'"
            Case "RUS"
                Return "'ARU'"
            Case "JP"
                Return "'AJP'"
            Case "KR"
                Return "'AKR'"
            Case "TH"
                Return "'ATH'"
        End Select
    End Function
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If User.Identity.IsAuthenticated = False Then
                Response.Redirect("../home.aspx?ReturnUrl=" + Request.RawUrl)
            End If
            src1.SelectCommand = GetSearchCMS_Sql()
        End If
    End Sub
    
    Protected Sub lnkDownload_Click(sender As Object, e As System.EventArgs)
        Dim strCMSId As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hdRowCMSID"), HiddenField).Value
        Try
            Dim CWS As New CorpAdminWS.AdminWebService
            'Dim ws As New WWWLocal.AdvantechWebServiceLocal
            Dim strUrl As String = CWS.Get_EDM_Source_File_By_CMD_ID(strCMSId)
            If String.IsNullOrEmpty(strUrl) Then
               
            Else
               
                Util.AjaxRedirect(up1, strUrl)
            End If
        Catch ex As Exception
            Util.AjaxJSAlert(up1, ex.Message)
        End Try
    End Sub
   
    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        src1.SelectCommand = GetSearchCMS_Sql()
    End Sub

    Protected Sub gv1_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gv1.PageIndex = e.NewPageIndex
        src1.SelectCommand = GetSearchCMS_Sql()
    End Sub

    Protected Sub gv1_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSearchCMS_Sql()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <br />
            <h2 style="color:Navy">Advantech eDM/Newsletter List</h2><br />
            <asp:Panel runat="server" ID="panelSearch" DefaultButton="btnSearch">
                <table>
                    <tr>
                        <th align="left">Keyword:</th>
                        <td>
                            <asp:TextBox runat="server" ID="txtSearchKey" Width="200px" />
                        </td>
                        <td>
                            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                           <%-- <asp:TextBox runat="server" ID="txtSql" TextMode="MultiLine" Width="800px" Height="200px" />--%>
                        </td>
                    </tr>
                    <tr>
                        <th align="left">
                            Language:
                        </th>
                        <td>
                            <asp:RadioButtonList runat="server" ID="rblLanguage" RepeatColumns="9" RepeatDirection="Horizontal">
                                <asp:ListItem Text="All" Value="All" Selected="True" />
                                <asp:ListItem Text="English" Value="ENU" />
                                <asp:ListItem Text="Traditional Chinese" Value="CHT" />
                                <asp:ListItem Text="Simplified Chinese" Value="CHS" />
                                <asp:ListItem Text="Russian" Value="RUS" />
                                <asp:ListItem Text="Japanese" Value="JP" />
                                <asp:ListItem Text="Korean" Value="KR" />
                                <asp:ListItem Text="Thai" Value="TH" /> 
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <asp:GridView runat="server" ID="gv1" Width="98%" DataSourceID="src1" AutoGenerateColumns="false" 
                AllowSorting="true" AllowPaging="true" PageSize="50" PagerSettings-Position="TopAndBottom" OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting">
                <Columns>
                    <asp:TemplateField HeaderText="Release Date" HeaderStyle-Width="10%" ItemStyle-HorizontalAlign="Center" SortExpression="RELEASE_DATE">
                        <ItemTemplate>
                            <%#CDate(Eval("RELEASE_DATE")).ToString("yyyy/MM/dd")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Type" DataField="CATEGORY_NAME" SortExpression="CATEGORY_NAME" HeaderStyle-Width="20%" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField HeaderText="Subject" DataField="TITLE" SortExpression="TITLE" HeaderStyle-Width="45%" />
                    <asp:BoundField HeaderText="Region" DataField="RBU" SortExpression="RBU" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Center" />
                    <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="20%" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:HiddenField runat="server" ID="hdRowCMSID" Value='<%#Eval("RECORD_ID") %>' />
                            <asp:HiddenField runat="server" ID="hdRowCMSURL" Value='<%#Eval("HYPER_LINK") %>' />
                            <asp:HiddenField runat="server" ID="hdRowSubject" Value='<%#Eval("TITLE") %>' />
                            <a href='<%#Eval("HYPER_LINK") %>' target="_blank">View</a>&nbsp;&nbsp;
                            <asp:LinkButton runat="server" ID="lnkDownload" Text="Download" OnClick="lnkDownload_Click" />&nbsp;&nbsp;
                            <a href='FwdEDM.aspx?CMSID=<%#Eval("RECORD_ID") %>' target="_blank">Forward</a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" />            
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
