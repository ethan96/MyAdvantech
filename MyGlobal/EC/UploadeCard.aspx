<%@ Page Title="MyAdvantech - Upload eCard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Import Namespace="System.IO" %>

<script runat="server">

    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs) 
        If txtName.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Please input the eCard template name.") : Exit Sub
        If fup1.HasFile AndAlso fup1.FileBytes IsNot Nothing AndAlso fup1.FileBytes.Length > 0 AndAlso _
            (fup1.FileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) Or fup1.FileName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase) _
             Or fup1.FileName.EndsWith(".gif", StringComparison.OrdinalIgnoreCase) Or fup1.FileName.EndsWith(".png", StringComparison.OrdinalIgnoreCase) _
             Or fup1.FileName.EndsWith(".tif", StringComparison.OrdinalIgnoreCase)) Then
            Dim row_id As String = Util.NewRowId("CHRISTMAS_CARD", "MY")
            Dim pImage As New SqlClient.SqlParameter("IMAGE_BYTE", SqlDbType.VarBinary) : pImage.Value = fup1.FileBytes
            Dim m As New MemoryStream(fup1.FileBytes)
            Dim im As System.Drawing.Image = System.Drawing.Image.FromStream(m)
            Dim imgWidth As Integer = im.Width, imgHeight As Integer = im.Height, max As Integer = 0
            If im.Width > im.Height Then max = im.Width Else max = im.Height
            'If max > 1024 Then imgWidth = im.Width * 1024 / max : imgHeight = im.Height * 1024 / max
            hdnImgWidth.Value = imgWidth : hdnImgHeight.Value = imgHeight
            Dim paras() As SqlClient.SqlParameter = {pImage}
            Dim retInt As Integer = dbUtil.dbExecuteNoQuery2("MY", String.Format("insert into christmas_card (ROW_ID,IMAGE_NAME,IMAGE_BYTE,UPLOADED_DATE,UPLOADED_BY,IMAGE_WIDTH,IMAGE_HEIGHT,IS_PUBLIC) values ('{0}',N'{1}',@IMAGE_BYTE,GetDate(),'{2}','{3}','{4}','{5}')", row_id, txtName.Text.Trim.Replace("'", "''"), Session("user_id"), imgWidth, imgHeight, cbPublic.Checked), paras)
            imgCardImage.ImageUrl = "ChristmasImg.ashx?RowId=" + row_id
            ddlName.DataBind()
            ddlName.Items.FindByValue(row_id).Selected = True
            BindImageInfo(imgWidth)
            btnDelete.Visible = True
            tbContent.Visible = True
        End If
    End Sub
    
    Public Sub BindImageInfo(Optional ByVal width As Integer = 0)
        'panelPrevImg.Height = 300
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select isnull(XL,'') as XL,isnull(XR,'') as XR,isnull(YL,'') as YL,isnull(YR,'') as YR,isnull(WIDTH,'') as WIDTH,isnull(HEIGHT,'') as HEIGHT, isnull(IMAGE_WIDTH,'') as IMAGE_WIDTH, isnull(IMAGE_HEIGHT,'') as IMAGE_HEIGHT, IS_PUBLIC from christmas_card where row_id='{0}'", ddlName.SelectedValue))
        If dt.Rows.Count > 0 Then
            With dt.Rows(0)
                txtInsX.Text = .Item("XL").ToString : txtInsX2.Text = .Item("XR").ToString
                txtInsY.Text = .Item("YL").ToString : txtInsY2.Text = .Item("YR").ToString
                txtInsW.Text = .Item("WIDTH").ToString : txtInsH.Text = .Item("HEIGHT").ToString
                hdnImgWidth.Value = .Item("IMAGE_WIDTH").ToString : hdnImgHeight.Value = .Item("IMAGE_HEIGHT").ToString
                If width > 0 And width <= 1024 Then imgCardImage.Width = width Else imgCardImage.Width = 1024
                If width = 0 Then imgCardImage.Width = CInt(.Item("IMAGE_WIDTH"))
                chShowPublic.Checked = CBool(.Item("IS_PUBLIC"))
            End With
        End If
    End Sub

    Protected Sub ddlName_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If ddlName.SelectedValue = "" Then panelPrevImg.Height = 50 : imgCardImage.ImageUrl = "" : tbContent.Visible = False : btnDelete.Visible = False : Exit Sub
        imgCardImage.ImageUrl = "ChristmasImg.ashx?RowId=" + ddlName.SelectedValue
        BindImageInfo()
        btnDelete.Visible = True
        tbContent.Visible = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Request.IsAuthenticated Or Session("user_id") Is Nothing Then Response.Redirect("../home.aspx?ReturnUrl=%2fEC%2fUploadeCard.aspx") : Exit Sub
        If Not Page.IsPostBack Then
            'If MailUtil.IsInRole("AOnline.estore") Or MailUtil.IsInRole("AOnline.Marketing") Or MailUtil.IsInRole("ITD.ACL") Then
            
            'Else
            '    Response.Redirect("eCard.aspx")
            'End If
        End If
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim x1 As String = "", x2 As String = "", y1 As String = "", y2 As String = ""
        If CInt(txtInsX.Text) < CInt(txtInsX2.Text) Then x1 = txtInsX.Text : x2 = txtInsX2.Text Else x1 = txtInsX2.Text : x2 = txtInsX.Text
        If CInt(txtInsY.Text) < CInt(txtInsY2.Text) Then y1 = txtInsY.Text : y2 = txtInsY2.Text Else y1 = txtInsY2.Text : y2 = txtInsY.Text
        dbUtil.dbExecuteNoQuery("MY", String.Format("update christmas_card set XL='{0}',XR='{1}',YL='{2}',YR='{3}',WIDTH='{4}',HEIGHT='{5}',IS_PUBLIC='{6}' where row_id='{7}'", x1, x2, y1, y2, txtInsW.Text.Trim, txtInsH.Text.Trim, chShowPublic.Checked, ddlName.SelectedValue))
        Util.AjaxJSAlert(up1, "Your setting has been saved.")
    End Sub

    Protected Sub btnPreview_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim body As String = "<html xmlns='http://www.w3.org/1999/xhtml'><body>"
        body += "<div style='background-image: url(http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + ddlName.SelectedValue + ");background-repeat: no-repeat;background-size: " + hdnImgWidth.Value + "px " + hdnImgHeight.Value + "px;margin-right: auto;margin-left: auto;font-family: Arial, Helvetica, sans-serif;font-size: 18px;color: #000;'>" + _
                "<table border='0' cellspacing='0' cellpadding='0' width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "'><tr><td width='" + hdnImgWidth.Value + "' height='" + txtInsY.Text + "'>&nbsp;</td></tr>" + _
                "<tr><td valign='top'><table border='0' cellspacing='0' cellpadding='0'><tr><td width='" + txtInsX.Text + "' height='" + txtInsH.Text.Trim + "'>&nbsp;</td><td align='center' width='" + txtInsW.Text.Trim + "' height='" + txtInsH.Text.Trim + "' valign='top' style='font-family: Arial, Helvetica, sans-serif;font-size: 18px;color: #000;'>"
        body += txtGreeting.Text.Replace(ControlChars.Lf, "<br/>")
        body += "</td><td>&nbsp;</td></tr></table></td></tr></table></div>"
        body += "</body></html>"
        'Dim body As String = "<html xmlns='http://www.w3.org/1999/xhtml'>" + _
        '                    "<body><div style='background-image: url(http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + ddlName.SelectedValue + ");background-repeat: no-repeat;height: " + hdnImgHeight.Value + "px;width: " + hdnImgWidth.Value + "px;margin-right: auto;margin-left: auto;font-family: Arial, Helvetica, sans-serif;font-size: 14px;color: #000;'>" + _
        '                    "<table border='0' cellspacing='0' cellpadding='0' width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "'>" + _
        '                    "<tr><td width='" + hdnImgWidth.Value + "' " + _
        '                    "height='" + txtInsY.Text + "'>&nbsp;</td></tr>" + _
        '                    "<tr><td valign='top'><table border='0' cellspacing='0' cellpadding='0'><tr><td width='" + txtInsX.Text + "' height='" + txtInsH.Text + "'>&nbsp;</td><td width='" + txtInsW.Text + "' height='" + txtInsH.Text + "' valign='top' style='font-family: Arial, Helvetica, sans-serif;font-size: 14px;color: #000;'>" + txtGreeting.Text.Replace(ControlChars.Lf, "<br/>") + _
        '                    "</td><td>&nbsp;</td></tr></table></td></tr></table>" + _
        '                    "</div></body></html>"
        If txtInsH.Text = 0 Or txtInsW.Text = 0 Then body = "<html xmlns='http://www.w3.org/1999/xhtml'><table><tr><td><img src='http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + ddlName.SelectedValue + "' width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "' /></td></tr></table></html>"
        lblBody.Text = body
        tb1.Visible = True
        ModalPopupExtender1.Show()
    End Sub
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        tb1.Visible = False
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        dbUtil.dbExecuteNoQuery("MY", String.Format("delete from christmas_card where row_id='{0}'", ddlName.SelectedValue))
        Util.JSAlertRedirect(Me.Page, "This eCard has been deleted.", "UploadeCard.aspx")
    End Sub

    Protected Sub btnDelete_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub btnDelete_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select uploaded_by from christmas_card where row_id='{0}'", ddlName.SelectedValue))
        If obj IsNot Nothing Then
            If obj.ToString = Session("user_id") Then btnDelete.Visible = True Else btnDelete.Visible = False
        Else
            btnDelete.Visible = False
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    .at-maincontainer {
	    background-color:#FFF;
	    line-height: 1.5em;
	    line-height:normal;
	    margin: 0 auto;
	    height:auto;
	    width:890px;
	    color:#666;
    }
</style>
<%--ICC 2015/12/22 Change js sources to relative path.--%>
<script src="../Includes/jquery.min.js" type="text/javascript"></script>
<script src="../Includes/jquery.Jcrop.js" type="text/javascript"></script>
<script type="text/javascript">
    jQuery(function () {
        jQuery('#<%=imgCardImage.ClientID %>').Jcrop({
            onSelect: showCoords,
            onChange: showCoords
        });
    });

    function showCoords(c) {
        document.getElementById('<%=txtInsX.ClientID %>').value = c.x;
        document.getElementById('<%=txtInsY.ClientID %>').value = c.y;
        document.getElementById('<%=txtInsX2.ClientID %>').value = c.x2;
        document.getElementById('<%=txtInsY2.ClientID %>').value = c.y2;
        document.getElementById('<%=txtInsW.ClientID %>').value = c.w;
        document.getElementById('<%=txtInsH.ClientID %>').value = c.h;
    };

</script>

<table class="at-maincontainer">
    <tr>
        <td>
            <table>
                <tr>
                    <td width="600">
                        <div id="navtext"><a style="color:Black" href="../home.aspx">Home</a> > <a style="color:Black" href="../EC/eCard.aspx">Send eCard</a> > Upload eCard</div><br />
                        <div style="font-size: 22px;color: #000;font-weight: bold;font-family: Arial, Helvetica, sans-serif;">Upload Advantech eCard</div>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td height="10"></td></tr>
    <tr>
        <td>
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td valign="top">Select eCard Template</td>
                    <td width="5"></td>
                    <td valign="top">
                         <asp:DropDownList runat="server" ID="ddlName" DataSourceID="sql1" AutoPostBack="true" DataTextField="image_name" DataValueField="row_id" OnSelectedIndexChanged="ddlName_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: MY %>"
                            SelectCommand="select top 100 '' as row_id, '' as image_name union select row_id, image_name from christmas_card order by image_name">
                            <%--<SelectParameters>
                                <asp:SessionParameter Name="UPLOADED_BY" Type="String" SessionField="user_id" />
                            </SelectParameters>--%>
                        </asp:SqlDataSource>
                    </td>
                    <td width="5"></td>
                    <td valign="top"><asp:LinkButton runat="server" ID="btnDelete" Text="Delete this Card" Visible="false" OnClick="btnDelete_Click" OnDataBinding="btnDelete_DataBinding" OnPreRender="btnDelete_PreRender" /></td>
                    <td width="50"></td>
                    <td align="left" valign="top">
                        <table>
                            <tr><th align="left">Add new eCard template</th></tr>
                            <tr>
                                <td>eCard Template Name: <asp:TextBox runat="server" ID="txtName" Width="250px" />&nbsp;</td>
                            </tr>
                            <tr><td><asp:CheckBox runat="server" ID="cbPublic" Text="Is Public?" /></td></tr>
                            <tr><td><asp:FileUpload runat="server" ID="fup1" Width="400px" /></td></tr>
                            <tr><td><asp:Button runat="server" ID="btnUpload" Text="Upload" OnClick="btnUpload_Click" /></td></tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td height="20"></td></tr>
    <tr>
        <td>
            <table runat="server" id="tbContent" visible="false">
                <tr><th align="left">Crop the region you want to input the greeting if needed.</th></tr>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <td style="display:none;">X:<asp:TextBox runat="server" ID="txtInsX" Width="30px" /></td>
                                <td style="display:none;">Y:<asp:TextBox runat="server" ID="txtInsY" Width="30px" /></td>
                                <td style="display:none;">X2:<asp:TextBox runat="server" ID="txtInsX2" Width="30px" /></td>
                                <td style="display:none;">Y2:<asp:TextBox runat="server" ID="txtInsY2" Width="30px" /></td>
                                <td style="display:none;">Width:<asp:TextBox runat="server" ID="txtInsW" Width="30px" /></td>
                                <td style="display:none;">Height:<asp:TextBox runat="server" ID="txtInsH" Width="30px" /></td>
                            </tr>
                        </table>
                        <asp:HiddenField runat="server" ID="hdnImgWidth" /><asp:HiddenField runat="server" ID="hdnImgHeight" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Panel runat="server" ID="panelPrevImg">
                            <asp:Image runat="server" ID="imgCardImage" />
                        </asp:Panel>
                    </td>
                </tr>
                <tr><td height="20"></td></tr>
                <tr><th align="left">Input some words to preview if the layout is well or not.</th></tr>
                <tr>
                    <td>
                        <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                            <ContentTemplate>
                                <table>
                                    <tr><td><asp:TextBox runat="server" ID="txtGreeting" TextMode="MultiLine" Width="300px" Height="100px" /></td></tr>
                                    <tr><td align="center"><asp:Button runat="server" ID="btnPreview" Text="Preview" Width="80px" OnClick="btnPreview_Click" /><asp:Button runat="server" ID="btnSave" Text="Save" Width="80px" OnClick="btnSave_Click" /><font color="gray"> (The testing words will not to be saved in the card.)</font></td></tr>
                                    <tr><td><asp:CheckBox runat="server" ID="chShowPublic" Text="Is Public?" /></td></tr>
                                </table>
                                <asp:LinkButton runat="server" ID="link1" />
                                <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                                    TargetControlID="link1" BackgroundCssClass="modalBackground">
                                </ajaxToolkit:ModalPopupExtender>
                                <asp:Panel runat="server" ID="Panel1" BackColor="White" ScrollBars="Both" Height="600" Width="1024">
                                    <table width="100%" runat="server" id="tb1" visible="false">
                                        <tr><td align="left"><asp:ImageButton runat="server" ID="btnClose" ImageUrl="~/images/close1.jpg" Width="30" OnClick="btnClose_Click" /></td></tr>
                                        <tr><td><asp:Label runat="server" ID="lblBody" /></td></tr>
                                    </table>
                                </asp:Panel>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td height="30"></td></tr>
</table>
</asp:Content>

