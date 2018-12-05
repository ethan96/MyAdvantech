<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Product Information" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("Lit_Id") = "y" Then
            Dim model_id As String = Trim(Request("model_id")), model_no As String = Trim(Request("model_no"))
        
            'Dim Model As New ModelUtil(model_id, model_no)
        
            'If IsNothing(Model.model_ID) Then Response.End()
            Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select top 1 isnull(b.Literature_ID,''),FILE_SIZE from SIEBEL_PRODUCT_LITERATURE b, Literature c where b.literature_id=c.literature_id and c.lit_type = 'Product - Datasheet' and c.lit_name like '%DS' and b.Product_id in (select top 1 d.PRODUCT_ID from SIEBEL_PRODUCT d where d.PART_NO = '" + model_no + "')")
            If Not IsNothing(dt) And dt.Rows.Count > 0 Then
                If dt.Rows(0).Item(0) <> "" Then
                    Dim fileUrl As String = UnzipFileUtil.UnzipLit(Server.UrlEncode(dt.Rows(0).Item(0)))
                    lblDatasheet.Text = "<a href='" + fileUrl + "'><img src='/Images/pdf_icon.gif'/> Datasheet(PDF)(" + FormatNumber(CDbl(dt.Rows(0).Item(1)) / 1024, 0, , , -2) + "k" + ")</a>"
                    lblDatasheet.Visible = True
                    Response.Redirect(fileUrl)
                    Response.End()
                End If
            Else
                Response.End()
            End If
            
            'Me.lbModelName.Text = Model.model_No
            'Me.lbModelDesc.Text = Model.Product_Desc
            'Me.litModelIntro.Text = Model.Model_Intro
            'Model.FillModelDetail()
            'Me.gvModelFeatures.DataSource = Model.dtFeature : Me.gvModelFeatures.DataBind()
            'If Model.isRoHSLogo Then imgRoHSPic.Visible = True
            'imgModelPic.ImageUrl = Model.Image_Name
            
        Else
            Response.End()
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="80%">
        <tr>
            <td>
                <asp:Label runat="server" ID="lbModelName" ForeColor="#114B9F" Font-Bold="true" Font-Size="XX-Large" />
                <hr />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <asp:Label runat="server" ID="lbModelDesc" ForeColor="#6F7072" Font-Size="Large" />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:40%">
                            <table width="100%">
                                <tr>
                                    <td align="left">
                                        <asp:Image runat="server" ID="imgModelPic" />
                                    </td>
                                    <td align="left" valign="bottom">
                                        <asp:Image runat="server" ID="imgRoHSPic" ImageUrl="~/Images/rohs.jpg" Visible="false" /><br />
                                        <asp:Label runat="server" ID="lblDatasheet" Visible="false"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width:60%" valign="top">
                            <table width="100%">
                                <tr valign="top">
                                    <th align="left" style="font-size:medium;color:#114B9F">Main Feature</th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gvModelFeatures" ShowHeader="false" ShowFooter="false" BorderWidth="0">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <ItemTemplate>
                                                        <li />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField />
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Panel runat="server" ID="PanelHeaderIntro">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" onmouseover="this.style.cursor='hand'">
                                    <tr>
                                        <td>
                                            <div style="background-color:#D9E3ED; font-size:small;"><b>Introduction</b></div>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                            <asp:Panel runat="server" ID="PanelContentIntro">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td bgcolor="#F0F0F0">
                                            <asp:Literal runat="server" ID="litModelIntro" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>

