<%@ Page Title="MyAdvantech - Survey Reports" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("MYLOCAL", src1.SelectCommand), "AEUIT_Survey.xls")
    End Sub
    
    Function SplitCourses(ByVal cs As String) As String
        If cs.Contains("|") Then
            Dim css() As String = Split(cs, "|")
            Dim sb As New System.Text.StringBuilder
            For Each c As String In css
                sb.Append("&nbsp;&nbsp;<Li/>" + c + "<br />")
            Next
            Return sb.ToString()
        Else
            Return cs
        End If
    End Function

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <th align="left" style="color:Navy; font-size:large">eCampaign Survey Result</th>
        </tr>
        <tr>
            <td>
            
            </td>
        </tr>
        <tr>
            <td>
                <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download" OnClick="imgXls_Click" />
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" AllowPaging="true" 
                            AllowSorting="true" PagerSettings-Position="TopAndBottom" DataSourceID="src1" PageSize="100" OnRowCreated="gvRowCreated">
                            <Columns>
                                <asp:BoundField HeaderText="Campaign ID" DataField="CAMP_ID" SortExpression="CAMP_ID" />
                                <asp:BoundField HeaderText="Submit Time" DataField="SUBMIT_TIME" SortExpression="SUBMIT_TIME" />
                                <asp:BoundField HeaderText="Company Name" DataField="CONTACT_COMPANY" SortExpression="CONTACT_COMPANY" />
                                <asp:BoundField HeaderText="Contact Tel." DataField="CONTACT_TEL" SortExpression="CONTACT_TEL" />
                                <asp:HyperLinkField HeaderText="Contact Email" DataNavigateUrlFields="CONTACT_EMAIL" 
                                    DataNavigateUrlFormatString="~/DM/ContactDashboard.aspx?EMAIL={0}" DataTextField="CONTACT_EMAIL" 
                                    SortExpression="CONTACT_EMAIL" Target="_blank" />
                                <asp:TemplateField HeaderText="Request Brochure?" SortExpression="REQ_BROCHURE" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%# IIf(Eval("REQ_BROCHURE"), "Y", "N")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Interested Courses" SortExpression="INTERESTED_COURSES">
                                    <ItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <td>&nbsp;&nbsp;</td>
                                                <td><%# SplitCourses(Eval("INTERESTED_COURSES"))%></td>
                                            </tr>
                                        </table>
                                        
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MYLOCAL %>" 
                            SelectCommand="SELECT TOP (10000) CAMP_ID, CONTACT_NAME, CONTACT_COMPANY, CONTACT_TEL, CONTACT_EMAIL, INTERESTED_COURSES, REQ_BROCHURE, SUBMIT_TIME FROM  CAMPAIGN_SURVEYS ORDER BY SUBMIT_TIME DESC" />
                    </ContentTemplate>
                </asp:UpdatePanel>                
            </td>
        </tr>
    </table>
</asp:Content>

