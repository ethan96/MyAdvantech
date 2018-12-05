<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            
            lbErrMsg.Text = String.Empty
            InitialDatasheetRepeater()
            
        End If
    End Sub
    
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'ICC 2015/10/26 Hide some server controls from master page. By Peter.Kim's request
        Dim btnSearch As ImageButton = CType(Master.FindControl("btnSearch"), ImageButton)
        If btnSearch IsNot Nothing Then btnSearch.Visible = False
        
        Dim PanelSearch As Panel = CType(Master.FindControl("PanelSearch"), Panel)
        If PanelSearch IsNot Nothing Then PanelSearch.Visible = False
        
        Dim dlSearchOption As DropDownList = CType(Master.FindControl("dlSearchOption"), DropDownList)
        If dlSearchOption IsNot Nothing Then dlSearchOption.Visible = False

        Dim tdSearch As HtmlTableCell = CType(Master.FindControl("tdSearch"), HtmlTableCell)
        If tdSearch IsNot Nothing Then tdSearch.Visible = False
            
        Dim tdAdmin1 As HtmlTableCell = CType(Master.FindControl("ADMIN1_TR"), HtmlTableCell)
        If tdAdmin1 IsNot Nothing Then tdAdmin1.Visible = False
            
        Dim tdAdmin2 As HtmlTableCell = CType(Master.FindControl("ADMIN2_TR"), HtmlTableCell)
        If tdAdmin2 IsNot Nothing Then tdAdmin2.Visible = False
            
        Dim tdAdminBuyer As HtmlTableCell = CType(Master.FindControl("tdAdminBuyer"), HtmlTableCell)
        If tdAdminBuyer IsNot Nothing Then tdAdminBuyer.Visible = False
            
        Dim tdAdminBuyer1 As HtmlTableCell = CType(Master.FindControl("tdAdminBuyer1"), HtmlTableCell)
        If tdAdminBuyer1 IsNot Nothing Then tdAdminBuyer1.Visible = False
            
        Dim tdeQuotation As HtmlTableCell = CType(Master.FindControl("tdeQuotation"), HtmlTableCell)
        If tdeQuotation IsNot Nothing Then tdeQuotation.Visible = False
            
        Dim tdeQuotation1 As HtmlTableCell = CType(Master.FindControl("tdeQuotation1"), HtmlTableCell)
        If tdeQuotation1 IsNot Nothing Then tdeQuotation1.Visible = False
            
        Dim tdHomeProduct As HtmlTableCell = CType(Master.FindControl("tdHomeProduct"), HtmlTableCell)
        If tdHomeProduct IsNot Nothing Then tdHomeProduct.Visible = False
            
        Dim tdHomeProduct1 As HtmlTableCell = CType(Master.FindControl("tdHomeProduct1"), HtmlTableCell)
        If tdHomeProduct1 IsNot Nothing Then tdHomeProduct1.Visible = False
            
        Dim tdHomeResource As HtmlTableCell = CType(Master.FindControl("tdHomeResource"), HtmlTableCell)
        If tdHomeResource IsNot Nothing Then tdHomeResource.Visible = False
            
        Dim tdHomeResource1 As HtmlTableCell = CType(Master.FindControl("tdHomeResource1"), HtmlTableCell)
        If tdHomeResource1 IsNot Nothing Then tdHomeResource1.Visible = False
            
        Dim tdHomeSupport As HtmlTableCell = CType(Master.FindControl("tdHomeSupport"), HtmlTableCell)
        If tdHomeSupport IsNot Nothing Then tdHomeSupport.Visible = False
        
        Dim tdHomeSupport1 As HtmlTableCell = CType(Master.FindControl("tdHomeSupport1"), HtmlTableCell)
        If tdHomeSupport1 IsNot Nothing Then tdHomeSupport1.Visible = False
        
    End Sub
    
    Private Sub InitialDatasheetRepeater()
        rpDatasheet.DataSource = dbUtil.dbGetDataTable("MYLOCAL_NEW", "select * from ADV_ARROW_DATASHEET where IS_ACTIVE = 1 order by LAST_UPD_DATE desc")
        rpDatasheet.DataBind()        
    End Sub

    Protected Sub btnUpload_Click(sender As Object, e As System.EventArgs)
        
        If fuDatasheet.HasFile = False Then
            lbErrMsg.Text = "Please select file."
            Return
        End If
        
        If fuDatasheet.PostedFile.ContentLength > 21000000 Then
            lbErrMsg.Text = "File size must be less than 20 MB."
            Return
        End If
        
        Dim uploadSql As String = _
            " insert into ADV_ARROW_DATASHEET (ROW_ID, FILE_NAME, FILE_DESC, FILE_SOURCE, IS_ACTIVE, CREATED_DATE, CREATED_BY, LAST_UPD_DATE, LAST_UPD_BY, SEQ_NO) " + _
            " values (@ROWID, @FN, @DESC, @FBIN, 1, @CREATED_DATE, @CREATED_BY, @UPD_DATE, @UPD_BY, 1)"
        Dim cmd As New SqlClient.SqlCommand(uploadSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
        With cmd.Parameters
            .AddWithValue("ROWID", Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)) : .AddWithValue("FN", fuDatasheet.FileName.Trim())
            .AddWithValue("DESC", txtDatasheetDesc.Text.Trim()) : .AddWithValue("FBIN", fuDatasheet.FileBytes) : .AddWithValue("CREATED_DATE", DateTime.Now)
            .AddWithValue("CREATED_BY", User.Identity.Name) : .AddWithValue("UPD_DATE", DateTime.Now) : .AddWithValue("UPD_BY", User.Identity.Name)
        End With
        
        Try
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
            cmd.Connection.Close()
            
            lbErrMsg.Text = "Success."
            InitialDatasheetRepeater()
        Catch ex As Exception
            lbErrMsg.Text = "Upload error."
            Util.InsertMyErrLog(ex.ToString())
        End Try
    End Sub
    
    Public Function CssStyle(ByVal row As Integer) As String
        If row Mod 2 = 0 Then
            Return "odd0"
        Else
            Return "odd1"
        End If
    End Function
    
    Public Sub rpDatasheet_OnItemCommand(ByVal sender As Object, ByVal e As RepeaterCommandEventArgs)
        If e.CommandName = "Delete" Then
            Try
                Dim sql As String = String.Format("update ADV_ARROW_DATASHEET set IS_ACTIVE = 0, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{0}' where ROW_ID = '{1}' ", User.Identity.Name, e.CommandArgument.ToString())
                dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", sql)
                InitialDatasheetRepeater()
                lbErrMsg.Text = String.Empty
            Catch ex As Exception
                lbErrMsg.Text = "Delete error."
                Util.InsertMyErrLog(ex.ToString())
            End Try
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <style type="text/css">
        tbody tr.odd0 td
        {
            border-top: #ccc 1px solid;
            text-align: center;
            background: #fff;
            color: #333;
            height: 40px;
            border-right: #ccc 1px solid;
        }
        tbody tr.odd1 td
        {
            text-align: center;
            background: #ebebeb;
            color: #333;
            height: 40px;
            border-top: #ccc 1px solid;
            border-right: #ccc 1px solid;
        }
    </style>
    <div class="root">
        <asp:HyperLink runat="server" ID="hlBack" NavigateUrl="~/home_premier.aspx" Text="Back to home page" />
    </div>
    <table width="100%">
        <tr>
            <td valign="top">
                <table width="50%">
                    <tr>
                        <th align="left" colspan="2">Upload datasheet</th>
                    </tr>
                    <tr>
                        <th align="left">Datasheet description: </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtDatasheetDesc" Width="250px" AutoCompleteType="Disabled" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">Please select file: </th>
                        <td>
                            <asp:FileUpload runat="server" ID="fuDatasheet" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Button runat="server" ID="btnUpload" Text="Upload" OnClick="btnUpload_Click" />
                            <asp:Label runat="server" ID="lbErrMsg" ForeColor="Tomato"></asp:Label>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:Repeater runat="server" ID="rpDatasheet" OnItemCommand="rpDatasheet_OnItemCommand">
                    <HeaderTemplate>
                        <table style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
                            <tr style="color:Black;background-color:Gainsboro;">
                                <th>No.</th>
                                <th style="width: 200px">File name</th>
                                <th style="width: 300px">File description</th>
                                <th>Update time</th>
                                <th>Update by</th>
                                <th style="width: 30px">Delete</th>
                                <th style="width: 35px">Download</th>
                            </tr>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                            <tr class='<%# Me.CssStyle(Container.ItemIndex) %>'>
                                <td><%# Container.ItemIndex + 1 %></td>
                                <td style="text-align:left"><%# Eval("FILE_NAME")%></td>
                                <td style="text-align:left"><%# Eval("FILE_DESC")%></td>
                                <td><%# Eval("LAST_UPD_DATE", "{0:yyyy/MM/dd}")%></td>
                                <td><%# Eval("LAST_UPD_BY")%></td>
                                <td><asp:LinkButton ID="lbDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("ROW_ID") %>' Text="Delete" OnClientClick="return confirm('Do you want to delete this record?')"></asp:LinkButton></td>
                                <td><a href="../../Services/ForPremierDownloadFile.ashx?RowID='<%# Eval("ROW_ID") %>'">Download</a></td>
                            </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

