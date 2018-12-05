<%@ Page Title="MyAdvantech - Company Profile & Corporate Video" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public Class WebsiteThumbnail
        Protected _url As String
        Protected _width As Integer, _height As Integer
        Protected _thumbWidth As Integer, _thumbHeight As Integer
        Protected _bmp As System.Drawing.Bitmap

        Public Shared Function GetThumbnail(url As String, width As Integer, height As Integer, thumbWidth As Integer, thumbHeight As Integer) As System.Drawing.Bitmap
            Dim thumbnail As New WebsiteThumbnail(url, width, height, thumbWidth, thumbHeight)
            Return thumbnail.GetThumbnail()
        End Function

        Protected Sub New(url As String, width As Integer, height As Integer, thumbWidth As Integer, thumbHeight As Integer)
            _url = url
            _width = width
            _height = height
            _thumbWidth = thumbWidth
            _thumbHeight = thumbHeight
        End Sub

        Protected Function GetThumbnail() As System.Drawing.Bitmap
            Dim thread As New Threading.Thread(New System.Threading.ThreadStart(AddressOf GetThumbnailWorker))
            thread.SetApartmentState(System.Threading.ApartmentState.STA)
            thread.Start()
            thread.Join()
            Return TryCast(_bmp.GetThumbnailImage(_thumbWidth, _thumbHeight, Nothing, IntPtr.Zero), System.Drawing.Bitmap)
        End Function

        Protected Sub GetThumbnailWorker()
            Using browser As New System.Windows.Forms.WebBrowser()
                browser.ClientSize = New System.Drawing.Size(_width, _height)
                browser.ScrollBarsEnabled = False
                browser.ScriptErrorsSuppressed = True
                browser.Navigate(_url)

                While browser.ReadyState <> System.Windows.Forms.WebBrowserReadyState.Complete
                    System.Windows.Forms.Application.DoEvents()
                End While

                _bmp = New System.Drawing.Bitmap(_width, _height)
                browser.DrawToBitmap(_bmp, New System.Drawing.Rectangle(0, 0, _width, _height))
                browser.Dispose()
            End Using
        End Sub
    End Class

    Public Function GetData() as DataTable
        Dim mainSQL as string = " From Master AS M (nolock) " + _
                                " LEFT OUTER JOIN Dictionary AS D (nolock) ON M.Type = D.Did " + _
                                " LEFT OUTER JOIN ExtensionEvents AS EE (nolock) ON M.CmsID = EE.CmsID " + _
                                " LEFT OUTER JOIN (select z.CmsID, cast(z.RelationKey as varchar(36)) as RelationKey, z.RelationType from Relation z (nolock)) R ON M.CmsID=R.CmsID and LEN (R.RelationKey) = 36 " + _
                                " LEFT OUTER JOIN (select CAST(z.Did as varchar(36)) as Did, z.DataType, z.Description, z.DisplayName from Dictionary z (nolock)) DR on R.RelationKey=DR.Did " + _
                                " WHERE (M.Status = 1) AND (GETDATE() BETWEEN M.ReleaseDate AND M.EndDate) AND M.CmsID in (SELECT CmsID FROM Relation) " + _
                                " AND DR.DisplayName ='Corp News' "

        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select {0} *,ISNULL(a.row,999) as row1,ISNULL(b.row,999) as row2 from ( ", IIf(Request("Thumbnail") = "y", "top 4", ""))
            .AppendFormat(" SELECT DISTINCT top 100 M.Title as p_Title, M.ModifyDate as p_ModifyDate, isnull(M.Abstract,'') AS p_Abstract, D.DisplayName as p_DisplayName,  ")
            .AppendFormat(" M.URL as p_URL, isnull((SELECT top 1 FilePath FROM ExtensionFile WHERE (CmsID = M.CmsID) AND (Did IN (SELECT Did FROM Dictionary WHERE (DisplayName = 'Featured Image')))),'') AS p_RECORD_IMG,  ")
            .AppendFormat(" M.CmsID as p_CmsID, ROW_NUMBER() over (ORDER BY M.ReleaseDate desc) as row ")
            .AppendFormat(mainSQL)
            .AppendFormat(" AND D.DisplayName='presentation slide' ")
            .AppendFormat(" ) as a full outer join  ")
            .AppendFormat(" ( ")
            .AppendFormat(" SELECT DISTINCT top 100 M.Title as v_Title, M.ModifyDate as v_ModifyDate, isnull(M.Abstract,'') AS v_Abstract, D.DisplayName as v_DisplayName,  ")
            .AppendFormat(" M.URL as v_URL, isnull((SELECT top 1 FilePath FROM ExtensionFile WHERE (CmsID = M.CmsID) AND (Did IN (SELECT Did FROM Dictionary WHERE (DisplayName = 'Featured Image')))),'') AS v_RECORD_IMG,  ")
            .AppendFormat(" M.CmsID as v_CmsID, ROW_NUMBER() over (ORDER BY M.ReleaseDate desc) as row ")
            .AppendFormat(mainSQL)
            .AppendFormat(" AND D.DisplayName='video' ")
            .AppendFormat(" AND M.CreatedEmail in ('Nicole.Lee@advantech.com.tw','Jennifer.Huang@advantech.com.tw') ") 'Rudy 2018.06.06 : Video只抓Nicole和Jennifer上傳的
            .AppendFormat(" ) as b on a.row=b.row ")
            .AppendFormat(" order by row1,row2 ")
        End With

        Dim dt as DataTable = dbUtil.dbGetDataTable("CMS", sb.ToString)
        Return dt
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("Thumbnail") = "y" Then
            div_root.Visible = False
        End If

        gv1.DataSource = GetData()
        gv1.DataBind()
    End Sub

    Protected Sub Page_PreRender(sender As Object, e As EventArgs)
        If Request("Thumbnail") = "y" AndAlso Request("W") = "y" Then
            Dim dt as new DataTable
            Try
                dt = GetData()
            Catch ex as Exception

            End Try
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim bmp As System.Drawing.Bitmap = WebsiteThumbnail.GetThumbnail("http://my.advantech.com/Product/CorporateMaterial.aspx?thumbnail=y", 850, 500, 850, 500)
                Dim ms As New System.IO.MemoryStream()
                bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg)
                Dim pThumbnail As New SqlClient.SqlParameter("THUMBNAIL", SqlDbType.VarBinary) : pThumbnail.Value = ms.ToArray()
                Dim paras() As SqlClient.SqlParameter = {pThumbnail}
                dbUtil.dbExecuteNoQuery2("MY", String.Format("delete from campaign_thumbnail where campaign_row_id='{0}'; insert into campaign_thumbnail (campaign_row_id,thumbnail) values ('{0}',@THUMBNAIL)", "CorporateMaterial"), paras)
            End If

        End If
    End Sub

    Protected Sub gv1_PreRender(sender As Object, e As EventArgs)
        Dim gv As GridView = CType(sender, GridView)
        Dim header As GridViewRow = gv.Controls(0).Controls(0)
        header.Cells(0).Visible = False
        header.Cells(1).ColumnSpan = 2
        header.Cells(1).Text = "Presentation Deck"
        header.Cells(2).Visible = False
        header.Cells(3).ColumnSpan = 2
        header.Cells(3).Text = "Video"
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If CType(e.Row.Cells(0).FindControl("imgpPic"), Image).ImageUrl = "" AndAlso CType(e.Row.Cells(0).FindControl("lblpSubject"), Label).Text <> "" Then
                CType(e.Row.Cells(0).FindControl("imgpPic"), Image).ImageUrl = "~/Images/logo1.jpg"
            End If
            If CType(e.Row.Cells(0).FindControl("lblpSubject"), Label).Text = "" Then
                CType(e.Row.Cells(0).FindControl("imgpPic"), Image).Height = Unit.Pixel(1)
            End If
            If CType(e.Row.Cells(0).FindControl("imgvPic"), Image).ImageUrl = "" AndAlso CType(e.Row.Cells(0).FindControl("lblvSubject"), Label).Text <> "" Then
                CType(e.Row.Cells(0).FindControl("imgvPic"), Image).ImageUrl = "~/Images/logo1.jpg" '"http://downloadt.advantech.com/ProductFile/PIS/white.gif"
            End If
            If CType(e.Row.Cells(0).FindControl("lblvSubject"), Label).Text = "" Then
                CType(e.Row.Cells(0).FindControl("imgvPic"), Image).Height = Unit.Pixel(1)
            End If
            If Request("Thumbnail") = "y" Then
                e.Row.Cells(1).Width = Unit.Pixel(200) : e.Row.Cells(3).Width = Unit.Pixel(200)
            End If
        End If
    End Sub

    Protected Sub Page_PreInit(sender As Object, e As EventArgs)
        If Request("Thumbnail") = "y" Then
            MasterPageFile = "~/Includes/MySubMaster.master"
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    .cm_title th {
        border: 0px;
    }
    .cm_title {
        color: #3190bb;
        font-size: 19px;
        font-weight: normal;
        height: 32px;
    }
    .border td {
        border: 0px;
    }
</style>
    <div class="root" runat="server" ID="div_root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > Corporate Presentation Material</div>
    <br />
    <asp:GridView runat="server" ID="gv1" EnableTheming="false" AutoGenerateColumns="False" HeaderStyle-HorizontalAlign="Center" 
        BorderColor="White" RowStyle-CssClass="border" BorderWidth="0" HeaderStyle-CssClass="cm_title" OnPreRender="gv1_PreRender" OnRowDataBound="gv1_RowDataBound" >
        <HeaderStyle HorizontalAlign="Left" Font-Size="Large" BorderWidth="0px" />
        <RowStyle BorderWidth="0px" VerticalAlign="Top" BorderColor="White" />
        <Columns>
            <asp:TemplateField HeaderText="Presentation Deck" HeaderStyle-Width="200px">
                <ItemTemplate>
                    <table>
                        <%--<tr><td height="20"></td></tr>--%>
                        <tr>
                            <td>
                                <a href='<%#Eval("p_URL") %>' target="_blank">
                                    <asp:Image runat="server" ID="imgpPic" Width="180px" ImageUrl='<%#Eval("p_RECORD_IMG") %>' />
                                </a>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Description" ItemStyle-Width="300px">
                <ItemTemplate>
                    <table style="table-layout:fixed; ">
                        <tr><td height="3"></td></tr>
                        <tr>
                            <td valign="top">
                                <a href='<%#Eval("p_URL") %>' target="_blank"><asp:Label runat="server" ID="lblpSubject" Text='<%#Eval("p_Title") %>' Font-Bold="true" /></a>
                            </td>
                        </tr>
                        <%--<tr>
                            <td valign="top" style="width: 250; word-wrap: break-word"><asp:Label runat="server" ID="lblpDesc" Text='<%#Eval("p_Abstract") %>' Width="250px" /></td>
                        </tr>--%>
                    </table>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Video" HeaderStyle-Width="200px">
                <ItemTemplate>
                    <table>
                        <%--<tr><td height="20"></td></tr>--%>
                        <tr>
                            <td>
                                <a href='<%#Eval("v_URL") %>' target="_blank">
                                    <asp:Image runat="server" ID="imgvPic" Width="180px" ImageUrl='<%#Eval("v_RECORD_IMG") %>' />
                                </a>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Description">
                <ItemTemplate>
                    <table style="table-layout:fixed">
                        <%--<tr><td height="20"></td></tr>--%>
                        <tr>
                            <td valign="top" width="300px">
                                <a href='<%#Eval("v_URL") %>' target="_blank"><asp:Label runat="server" ID="lblvSubject" Text='<%#Eval("v_Title") %>' Font-Bold="true" /></a>
                            </td>
                        </tr>
                        <%--<tr>
                            <td valign="top" style="width: 260; word-wrap: break-word"><asp:Label runat="server" ID="lblvDesc" Text='<%#Eval("v_Abstract") %>' Width="260px" /></td>
                        </tr>--%>
                    </table>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>

