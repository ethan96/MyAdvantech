<%@ Page Title="MyAdvantech - Forward CMS eDM Content" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If User.Identity.IsAuthenticated = False Then Response.Redirect("../home.aspx")
            'HtmlEditorExtender1.AjaxFileUpload.AllowedFileTypes = "jpg,jpeg,gif,png,bmp"
           
            If Request("CMSID") IsNot Nothing Then
                hdCMSID.Value = Trim(Request("CMSID"))
                
                Dim dtCMS As New DataTable
                Dim sqlAptMy As New SqlClient.SqlDataAdapter( _
                    " select top 1 HYPER_LINK, IsNull(TITLE,'') as TITLE from WWW_RESOURCES where RECORD_ID=@CMSID and HYPER_LINK like 'http%://%' order by RELEASE_DATE desc", _
                    ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                sqlAptMy.SelectCommand.Parameters.AddWithValue("CMSID", hdCMSID.Value)
                sqlAptMy.Fill(dtCMS)
                sqlAptMy.SelectCommand.Connection.Close()
                If dtCMS.Rows.Count = 1 Then
                    Dim strCMSUrl As String = dtCMS.Rows(0).Item("HYPER_LINK")
                    Dim strTitle As String = dtCMS.Rows(0).Item("TITLE")
                    txtSendTo.Text = User.Identity.Name : txtSubject.Text = strTitle
                    Dim strEDMID As String = Left(Guid.NewGuid().ToString().Replace("-", ""), 10)
                    hdEDMID.Value = strEDMID
                    Dim cmd As New SqlClient.SqlCommand( _
                        "insert into CurationPool.dbo.FWD_EDM_MASTER (ROW_ID,SENT_BY, CMS_ID) values(@ROWID,@UID,@CMSID)", _
                        New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
                    cmd.Parameters.AddWithValue("ROWID", strEDMID) : cmd.Parameters.AddWithValue("UID", User.Identity.Name) : cmd.Parameters.AddWithValue("CMSID", hdCMSID.Value)
                    cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
                End If
                
                
                'Timer1.Enabled = True
            Else
                'Response.Redirect("AlleDMNewsLetter2.aspx")
            End If
        End If
    End Sub
    
    Public Shared Function FormatCMSContent(ByVal strCMSURL As String, ByRef ms As IO.MemoryStream, ByRef client As Net.WebClient, ByRef strHtmlContent As String) As Boolean
        Dim doc As New HtmlAgilityPack.HtmlDocument
        If ms IsNot Nothing Then
            doc.Load(ms, True)
            Dim ccn As HtmlAgilityPack.HtmlNodeCollection = doc.DocumentNode.SelectNodes("//img")
            If Not IsNothing(ccn) AndAlso ccn.Count > 0 Then
                For Each n As HtmlAgilityPack.HtmlNode In ccn
                    If n.HasAttributes AndAlso (n.Attributes("src") IsNot Nothing OrElse n.Attributes("background") IsNot Nothing) Then
                        Dim srcAttribute As String = IIf(n.Attributes("src") IsNot Nothing, "src", "background")
                        Dim curi As New Uri(n.Attributes(srcAttribute).Value, UriKind.RelativeOrAbsolute)
                        If Not curi.IsAbsoluteUri Then
                            curi = New Uri(New Uri(strCMSURL), n.Attributes(srcAttribute).Value)
                        End If
                        n.Attributes(srcAttribute).Value = curi.AbsoluteUri
                    End If
                Next
            End If

            ccn = doc.DocumentNode.SelectNodes("//link")
            Dim docR As New HtmlAgilityPack.HtmlDocument
            If Not IsNothing(ccn) AndAlso ccn.Count > 0 Then
                For Each n As HtmlAgilityPack.HtmlNode In ccn
                    If n.HasAttributes AndAlso n.Attributes("type") IsNot Nothing AndAlso n.Attributes("type").Value Like "*css" AndAlso _
                        n.Attributes("href") IsNot Nothing Then
                        Try
                            Dim headNode As HtmlAgilityPack.HtmlNode = doc.DocumentNode.SelectSingleNode("//head")
                            If headNode IsNot Nothing Then
                                Dim curi As New Uri(n.Attributes("href").Value, UriKind.RelativeOrAbsolute)
                                If Not curi.IsAbsoluteUri Then
                                    curi = New Uri(New Uri(strCMSURL), n.Attributes("href").Value)
                                End If
                                Dim httpReq As Net.HttpWebRequest = Net.WebRequest.Create(curi.AbsoluteUri)
                                httpReq.AllowAutoRedirect = False
                                Dim httpRes As Net.HttpWebResponse = httpReq.GetResponse()
                                If httpRes.StatusCode <> Net.HttpStatusCode.NotFound Then
                                    Dim msCss As New IO.MemoryStream(client.DownloadData(curi.AbsoluteUri))
                                    docR.Load(msCss, Encoding.UTF8)
                                    Dim strCss As String = docR.DocumentNode.OuterHtml
                                    If Not strCss.Contains("Advantech - Page Not Found") Then
                                        Dim NewCssNode As HtmlAgilityPack.HtmlNode = _
                                            HtmlAgilityPack.HtmlNode.CreateNode("<style type='text/css'>" + vbCrLf + Replace(strCss, vbCr, vbCrLf) + vbCrLf + "</style>")
                                        headNode.AppendChild(NewCssNode)
                                    End If
                                End If
                                httpRes.Close()
                            End If
                        Catch ex As Exception
                        End Try
                    End If
                Next
            End If
            strHtmlContent = doc.DocumentNode.OuterHtml
        End If
        Return True
    End Function
    
    'Protected Sub HtmlEditorExtender1_ImageUploadComplete(sender As Object, e As AjaxControlToolkit.AjaxFileUploadEventArgs)
    '    If e.FileSize < 5000000 Then
    '        Dim cmd As New SqlClient.SqlCommand("insert into CurationPool.dbo.FWD_EDM_IMG (ROW_ID, UPLOADED_BY, FILE_NAME, FILE_BIN, EDM_ID) values(@ROWID,@UID,@FNAME,@FBIN,@EDMID)", _
    '                                       New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
    '        Dim strImgId As String = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)
    '        With cmd.Parameters
    '            .AddWithValue("ROWID", strImgId) : .AddWithValue("UID", User.Identity.Name) : .AddWithValue("FNAME", e.FileName)
    '            .AddWithValue("FBIN", e.GetContents()) : .AddWithValue("EDMID", hdEDMID.Value)
    '        End With
    '        cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
    '        e.PostedUrl = Util.GetRuntimeSiteUrl + "/EC/FwdEDMImg.ashx?ID=" + strImgId
    '    End If
       
    'End Sub
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetCMSContent(ByVal CMSID As String) As String
        Dim dtCMS As New DataTable
        Dim sqlAptMy As New SqlClient.SqlDataAdapter( _
            " select top 1 HYPER_LINK, IsNull(TITLE,'') as TITLE from WWW_RESOURCES where RECORD_ID=@CMSID and HYPER_LINK like 'http%://%' order by RELEASE_DATE desc", _
            ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlAptMy.SelectCommand.Parameters.AddWithValue("CMSID", CMSID)
        sqlAptMy.Fill(dtCMS)
        sqlAptMy.SelectCommand.Connection.Close()
        If dtCMS.Rows.Count = 1 Then
            Dim strCMSUrl As String = dtCMS.Rows(0).Item("HYPER_LINK").ToString()
            Dim strContent As String = ""
            Dim client As New Net.WebClient, doc As New HtmlAgilityPack.HtmlDocument
            Dim ms As IO.MemoryStream = Nothing
            Try
                ms = New IO.MemoryStream(client.DownloadData(strCMSUrl))
                FormatCMSContent(strCMSUrl, ms, client, strContent)
                Dim serializer = New Script.Serialization.JavaScriptSerializer()
                Return serializer.Serialize(strContent)
            Catch ex As Exception
                Return ex.ToString()
                'lbSendWarningMsg.Text = "failed to get content from CMS due to error: " + ex.Message
            End Try
        End If
        Return "error"
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function SendEDM(ByVal strBody As String, ByVal strSubject As String, ByVal strSendToList As String, ByVal strEDMId As String) As String
        Threading.Thread.Sleep(1000)
        Dim serializer = New Script.Serialization.JavaScriptSerializer()
        Try
            If String.IsNullOrEmpty(Trim(strSendToList)) Then
                Return serializer.Serialize("Send-To is empty")
            End If
            strSendToList = Replace(strSendToList, ";", ",")
            Dim strSendTos() As String = Split(strSendToList, ",")
            For Each strSendTo As String In strSendTos
                If Not Util.IsValidEmailFormat(Trim(strSendTo)) Then
                    Return serializer.Serialize(strSendTo + " is in invalid email format")
                End If
            Next
            If strSendTos.Length > 5 Then
                Return serializer.Serialize("you cannot send to more than 5 recipients")
            End If
            Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
            Dim msg As New Net.Mail.MailMessage("myadvantech@advantech.com", strSendToList)
            msg.ReplyToList.Add(HttpContext.Current.User.Identity.Name)
            With msg
                '.Bcc.Add("myadvantech@advantech.com")
                .BodyEncoding = Text.Encoding.UTF8 : .IsBodyHtml = True : .Subject = strSubject : .Body = strBody : .SubjectEncoding = Text.Encoding.UTF8
                .Bcc.Add("stefanie.chang@advantech.com.tw") : .Bcc.Add("phoebe.chang@advantech.com.tw") : .Bcc.Add("myadvantech@advantech.com")
            End With
            Try
                sm.Send(msg)
                Dim cmd As New SqlClient.SqlCommand( _
                    "update CurationPool.dbo.FWD_EDM_MASTER set SEND_TO=@STO, SUBJECT=@SUBJECT, BODY=@BODY, SENT_DATE=GETDATE(),IS_SENT=1 where ROW_ID=@RID", _
                    New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
                With cmd.Parameters
                    .AddWithValue("STO", strSendToList) : .AddWithValue("SUBJECT", strSubject) : .AddWithValue("BODY", strBody) : .AddWithValue("RID", strEDMId)
                End With
                cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Catch ex As Exception
                Return serializer.Serialize("failed to send due to error:" + ex.Message)
            End Try
      
            sm.Dispose()
        Catch ex2 As Exception
            Return serializer.Serialize("failed to send due to error:" + ex2.Message)
        End Try
        Return serializer.Serialize("Your mail has been sent")
    End Function
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        html, body
        {
            margin: 0;
            padding: 0;
        }
        
        
        /* =Typography
-----------------------------------------------------------------------------*/
        body
        {
            font-family: Helvetica, Arial, sans-serif;
            font-size: 14px;
        }
        
        
        /* =Layout
-----------------------------------------------------------------------------*/
        #page
        {
            width: 940px;
            margin: 50px auto;
        }
        
        /* =Misc
-----------------------------------------------------------------------------*/
        .list li
        {
            margin: 10px 0;
        }
    </style>
    <link rel="stylesheet" href="./redactor/redactor.css" />
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript" src="./redactor/redactor.min.js"></script>
    <script type="text/javascript" src="json2.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {           
            $('#editor1').redactor({
                imageUpload: './redactor/img_upload.aspx'
            });
            getCMSContent();
        });

        function getCMSContent() {
            var cmsid = $("#<%=hdCMSID.ClientID %>").val();
            //console.log(cmsid);
            if (cmsid != '') {
                var postData = JSON.stringify({ CMSID: cmsid });
                $.ajax(
                {
                    type: "POST",
                    url: "FwdEDM.aspx/GetCMSContent",
                    data: postData,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (retData) {
                        //console.log("call GetCMSContent ok");
                        var cmsContent = $.parseJSON(retData.d);
                        $("#editor1").html(cmsContent);
                    },
                    error: function (msg) {
                        //console.log("call GetCMSContent err:" + msg.d);
                    }
                }
            );
            }
        };

        function Send(btnSend) {
            $(btnSend).prop('disabled', true);
            $("#<%=lbSendWarningMsg.ClientID %>").empty();
            $("#imgLoadSend").css("display", "block");
            var postData = JSON.stringify({ strBody: $("#editor1").html(), strSubject: $("#<%=txtSubject.ClientID %>").val(), 
            strSendToList: $("#<%=txtSendTo.ClientID %>").val(), strEDMId: $("#<%=hdEDMID.ClientID %>").val() });
            $.ajax(
                {
                    type: "POST",
                    url: "FwdEDM.aspx/SendEDM",
                    data: postData,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (retData) {
                        //console.log("call SendEDM ok");
                        var retMsg = $.parseJSON(retData.d);
                        $("#<%=lbSendWarningMsg.ClientID %>").html(retMsg);
                        $("#imgLoadSend").css("display", "none");
                        $(btnSend).prop('disabled', false);
                    },
                    error: function (msg) {
                        //console.log("call SendEDM err:" + msg.d);
                        $("#imgLoadSend").css("display", "none");
                        $(btnSend).prop('disabled', false);
                    }
                }
            );
        }
//            document.getElementById('<%=lbSendWarningMsg.ClientID %>').innerHTML = "";
//            document.getElementById('imgLoadSend').style.display = "block";
//            PageMethods.SendEDM(
//                document.getElementById('editor1').innerHTML,
//                document.getElementById('<%=txtSubject.ClientID %>').value,
//                document.getElementById('<%=txtSendTo.ClientID %>').value,
//                document.getElementById('<%=hdEDMID.ClientID %>').value,
//                function (pagedResult, eleid, methodName) {
//                    //console.log('send ok ' + pagedResult);
//                    if (pagedResult != '') {
//                        document.getElementById('<%=lbSendWarningMsg.ClientID %>').innerHTML = pagedResult;
//                        document.getElementById('imgLoadSend').style.display = "none";
//                    }
//                },
//                function (error, userContext, methodName) {
//                    //console.log('err');
//                    document.getElementById('imgLoadSend').style.display = "none";
//                });       

    </script>
    <asp:HiddenField runat="server" ID="hdCMSID" />
    <asp:HiddenField runat="server" ID="hdEDMID" />
    <table width="100%">
        <tr style="height: 30px">
            <td valign="top">
                <table>
                    <tr valign="top">
                        <td align="left">
                            <img style='border: 0px; height: 15px; display: none;' alt='loading' src='../images/loading2.gif'
                                id="imgLoadSend" />
                        </td>
                        <td align="center">
                            <asp:Label runat="server" ID="lbSendWarningMsg" Font-Bold="true" ForeColor="Tomato" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr valign="top">
            <td valign="top">
                <table width="100%">
                    <tr align="left" valign="top">
                        <td align="left">
                            <input type="button" value="Send" id="btnSend2" onclick="Send(this);" style="width: 70px;
                                height: 40px; font-size: large; font-weight: bold;" />
                        </td>
                        <td align="left">
                            <table width="100%">
                                <tr align="left">
                                    <th align="left" style="width: 10%">
                                        Send To:
                                    </th>
                                    <td align="left" style="width: 90%">
                                        <asp:TextBox runat="server" ID="txtSendTo" Width="95%" />
                                    </td>
                                </tr>
                                <tr align="left">
                                    <th align="left" style="width: 10%">
                                        Subject:
                                    </th>
                                    <td align="left" style="width: 90%">
                                        <asp:TextBox runat="server" ID="txtSubject" Width="95%" />
                                    </td>
                                </tr>                                
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr valign="top">
            <td valign="top">
                <div id="page">
                    <div id="editor1" style="height:400px">
                    
                    </div>
                </div>
            </td>
        </tr>
    </table>
</asp:Content>
