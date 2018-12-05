<%@ Page Title="PIS - Huge File Upload" Language="VB" MasterPageFile="~/Includes/MyMaster.master" EnableEventValidation="false" %>
<%@ Register TagPrefix="fup" Namespace="OboutInc.FileUpload" Assembly="obout_FileUpload" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsInternalUser2() = False Then Response.Redirect("../../home.aspx")
        End If

        If Page.IsPostBack Then

            If mv1.ActiveViewIndex = 0 Then
                Dim files As HttpFileCollection = Page.Request.Files, total As Integer = 0, i As Integer
                For i = 0 To files.Count - 1
                    Dim file As HttpPostedFile = files(i)
                    If file.FileName.Length > 0 Then
                        total = total + 1
                    End If
                Next
                If total > 0 Then
                    'ServerResponse.Text = "Uploading Files to Limelight..."
                    Dim longDate As String = String.Format("{0:yyyyMMddHHmmss}", DateTime.Now)
                    Dim FileName As String = files(0).FileName, FileExt As String = System.IO.Path.GetExtension(FileName)
                    If FileName.Length > 80 Then FileName = FileName.Substring(0, 80)
                    If FileExt.StartsWith(".") AndAlso FileExt.Length > 1 Then FileExt = FileExt.Substring(1)
                    Dim FileSize As Integer = files(0).ContentLength, LitId As String = ""
                    FileName = longDate + FileName
                    Dim l As New Aspose.Network.License()
                    l.SetLicense(HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic"))
                    Dim client As New Aspose.Network.Ftp.FtpClient("advantech.upload.llnw.net", 21, "advantech-ht", "dcy54p")
                    Try
                        'set data send time out to be 20 seconds
                        client.DataSendTimeout = 20000
                        'set data receive time out to be 20 seconds
                        client.DataReceiveTimeout = 20000
                        client.Connect(True)
                        If client.Exists("/PIS/" + FileName) Then client.Delete("/PIS/" + FileName)
                        client.Upload(files(0).InputStream, "/PIS/" + FileName)
                        client.Disconnect()
                    Catch fe As Aspose.Network.Ftp.FtpException
                        Response.Write("Upload to Limelight FTP Error:" + fe.ToString())
                        Response.End()
                    End Try
                    Dim strFTPUrl As String = "http://advantech.vo.llnwd.net/o35/PIS/" + HttpUtility.UrlEncode(FileName)
                    SaveMarketImageInfo(FileName, FileExt, dlFType.SelectedValue, FileSize, "PISMaterials", Session("user_id"), LitId, strFTPUrl)
                    If LitId <> String.Empty Then
                        lbLitId.Text = LitId
                        hyFNameLink.Text = FileName : hyFNameLink.NavigateUrl = strFTPUrl
                        txtDisplayName.Text = FileName
                        lbFileExt.Text = FileExt
                        lbFileSize.Text = FileSize.ToString()
                        lbCDate.Text = Now.ToString("yyyy-MM-dd")
                        txtSDate.Text = lbCDate.Text
                        txtEDate.Text = DateAdd(DateInterval.Day, 7, Now).ToString("yyyy-MM-dd")
                        lbCBy.Text = Session("user_id")
                        For Each li As ListItem In dlFileTypeStep2.Items
                            li.Selected = False
                            If li.Value = dlFType.SelectedValue Then li.Selected = True
                        Next
                        mv1.ActiveViewIndex = 1
                    End If
                Else

                End If
            End If
        End If
    End Sub

    Sub FillLOV()

    End Sub

    Protected Sub btnNext_Click(sender As Object, e As System.EventArgs)
        Dim tmpSDate As Date = Date.MinValue, tmpEDate As Date = Date.MaxValue
        If Not Date.TryParseExact(txtSDate.Text, "yyyy-MM-dd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, tmpSDate) Then
            tmpSDate = Now
        End If
        If Not Date.TryParseExact(txtEDate.Text, "yyyy-MM-dd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, tmpEDate) Then
            tmpEDate = Date.MaxValue
        End If
        UpdateMarketEdititerature(lbLitId.Text, txtDisplayName.Text, lbFileExt.Text, txtFDesc.Text, dlPriId.SelectedValue, dlPLevel.SelectedValue, tmpSDate, tmpEDate, rblActivestatus.SelectedValue, dlLang.SelectedValue)
        mv1.ActiveViewIndex = 2
        timerRefresh.Enabled = True
    End Sub

    Public Function SaveMarketImageInfo(ByVal fileName As String, ByVal fileExt As String, ByVal fileType As String, _
                                        ByVal fileSize As Integer, ByVal Primary_Sdu As String, ByVal admin As String, _
                                        ByRef literId As String, Optional ByVal ftpurl As String = "") As Boolean
        If fileName.Length > 100 Then fileName = Left(fileName, 100)
        Using con As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("PIS_BackEnd").ConnectionString)
            Dim insertSql As String = "INSERT INTO LITERATURE VALUES (@litID,'',@litName,'',@litType,@fileName,@fileExt,@fileSize,'','ACL','','General',@Primary_Sdu,GETDATE(),@createBy,GETDATE(),@LAST_UPDATED_BY,'','','Y','ENU');"
            Dim litID As String = Guid.NewGuid.ToString
            Using cmd As New SqlClient.SqlCommand(insertSql, con)
                With cmd.Parameters
                    .AddWithValue("@litID", litID) : .AddWithValue("@litName", fileName) : .AddWithValue("@litType", fileType)
                    .AddWithValue("@fileName", fileName) : .AddWithValue("@fileExt", fileExt) : .AddWithValue("@fileSize", fileSize)
                    .AddWithValue("@Primary_Sdu", Primary_Sdu) : .AddWithValue("@createBy", admin) : .AddWithValue("@LAST_UPDATED_BY", admin)
                End With
                Try
                    con.Open()
                    If cmd.ExecuteNonQuery() > 0 Then
                        Dim query As String = "INSERT INTO LITERATURE_EXTEND(LIT_ID,FTP_URL) Values(@litId,@FTPURL)"
                        Using updateCmd As New SqlClient.SqlCommand(query, con)
                            updateCmd.Parameters.AddWithValue("@litId", litID) : updateCmd.Parameters.AddWithValue("@FTPURL", ftpurl)
                            updateCmd.ExecuteNonQuery() : literId = litID
                        End Using
                        con.Dispose() : Return True
                    End If
                    Return False
                Catch ex As Exception
                    ex.Data("ExtraInfo") = ex.Message
                    Throw ex
                End Try
                Return False
            End Using
        End Using
    End Function

    Public Function UpdateMarketEdititerature(ByVal litId As String, ByVal displayName As String, ByVal fileType As String, ByVal desc As String, ByVal primaryOrgId As String, ByVal primaryLevel As String, _
                                              ByVal startDate As Date, ByVal endDate As Date, ByVal intFlg As String, ByVal lang As String) As Boolean
        If displayName.Length >= 100 Then displayName = Left(displayName, 99)
        If desc.Length >= 255 Then desc = Left(desc, 254)
        Using con As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("PIS_BackEnd").ConnectionString)
            Dim queryStr As String = "Update LITERATURE set  lit_Name=@litName,LIT_DESC=@litDesc,LIT_TYPE=@litType,PRIMARY_ORG_ID=@primaryId,PRIMARY_LEVEL=@primaryLevel,LAST_UPDATED=getDate(), " & _
                                        "START_DATE=@startDate,END_DATE=@endDate,INT_FLG=@intFlg,LANG=@lang where LITERATURE_ID=@litId "
            Using cmd As New SqlClient.SqlCommand(queryStr, con)
                Try
                    con.Open()
                    With cmd.Parameters
                        .AddWithValue("@litName", displayName) : .AddWithValue("@litDesc", desc) : .AddWithValue("@litType", dlFileTypeStep2.SelectedValue)
                        .AddWithValue("@primaryId", primaryOrgId) : .AddWithValue("@primaryLevel", primaryLevel)
                        .AddWithValue("@startDate", startDate) : .AddWithValue("@endDate", endDate) : .AddWithValue("@intFlg", intFlg)
                        .AddWithValue("@lang", lang) : .AddWithValue("@litId", litId)
                    End With
                    Return cmd.ExecuteNonQuery() > 0
                Catch ex As Exception
                    con.Close()
                    Response.Write(cmd.CommandText + "<br/>")
                    For Each p As SqlClient.SqlParameter In cmd.Parameters
                        Response.Write(p.ParameterName + ":" + p.Value.ToString() + "<br/>")
                    Next
                    Response.End()
                    Throw ex
                End Try
            End Using
        End Using
        Return False
    End Function

    Protected Sub timerRefresh_Tick(sender As Object, e As System.EventArgs)
        timerRefresh.Enabled = False
        Response.Redirect("HugeFileUpload.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/JavaScript">
        function Clear() {
            document.getElementById("<%= uploadedFilesNumber.ClientID %>").innerHTML = "Uploading files to Limelight...";
            ShowHideCancelUploadBtn();
            clearFileInputs();
        }
        function ShowHideCancelUploadBtn(){
            if(document.getElementById('lnkCancelUpload').style.display=='block'){
                document.getElementById('lnkCancelUpload').style.display='none';
            }
            else{
                document.getElementById('lnkCancelUpload').style.display='block';
            }
        }
        function Refresh(info) {
            document.getElementById("<%= uploadedFilesNumber.ClientID %>").innerHTML =
                 'uploaded ' + info.Bytes + ' bytes from ' + info.RequestSize + ' ...';
        }
        function Cancel(){
            <%= FileUploadProgress1.ClientID %>_obj.CancelRequest();
            document.getElementById('lnkCancelUpload').style.display='none';
            ShowHideCancelUploadBtn();
        }
        function Rejected(fileName, size, maxSize)
        {
            alert("File "+fileName+" is rejected \nIts size ("+size+" bytes) exceeds "+maxSize+" bytes");
        }     
        function clearFileInputs() {
            var inp = document.getElementsByTagName("input");
            for (var i = 0; i < inp.length; i++) {
                var el = inp[i];
                // input with type 'file' only and not empty
                if (el.type == "file" && el.value != "") {
                // clear it
                    if (document.all && !window.opera) {
                        el.parentNode.insertBefore(el.cloneNode(false), el);
                        el.parentNode.removeChild(el);
                    }
                    else {
                        var new_span = document.createElement("SPAN");
                        el.parentNode.insertBefore(new_span, el);
                        new_span.appendChild(el);
                        new_span.innerHTML = new_span.innerHTML;
                        new_span.parentNode.insertBefore(new_span.firstChild, new_span);
                        new_span.parentNode.removeChild(new_span);                        
                    }
                }
            }
            return true;
        }  
    </script>
    <h2>PIS Huge File Upload</h2>
    <asp:MultiView runat="server" ID="mv1" ActiveViewIndex="0">
        <asp:View runat="server" ID="v1">
            <table width="100%">
                <tr>
                    <th align="left">
                        File Type:
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlFType">
                            <asp:ListItem Value="Advertisement" />
                            <asp:ListItem Value="Banner" />
                            <asp:ListItem Value="Brochure" />
                            <asp:ListItem Value="Catalogue" />
                            <asp:ListItem Value="Category_Photo" />
                            <asp:ListItem Value="Certificate" />
                            <asp:ListItem Value="Certificate-BSMI" />
                            <asp:ListItem Value="Certificate-CB" />
                            <asp:ListItem Value="Certificate-CB/60601" />
                            <asp:ListItem Value="Certificate-CCC" />
                            <asp:ListItem Value="Certificate-CCEE" />
                            <asp:ListItem Value="Certificate-CCIB" />
                            <asp:ListItem Value="Certificate-CE/60601/EMC" />
                            <asp:ListItem Value="Certificate-CE/60601/LVD" />
                            <asp:ListItem Value="Certificate-CE/EMC" />
                            <asp:ListItem Value="Certificate-CE/LVD" />
                            <asp:ListItem Value="Certificate-CSA" />
                            <asp:ListItem Value="Certificate-C-Tick" />
                            <asp:ListItem Value="Certificate-FCC" />
                            <asp:ListItem Value="Certificate-ISO" />
                            <asp:ListItem Value="Certificate-Others" />
                            <asp:ListItem Value="Certificate-TUV/60601" />
                            <asp:ListItem Value="Certificate-UL" />
                            <asp:ListItem Value="Certificate-UL/2601" />
                            <asp:ListItem Value="Certificate-UL/60601-1" />
                            <asp:ListItem Value="Certificate-VCCI" />
                            <asp:ListItem Value="Corporate - Award" />
                            <asp:ListItem Value="Corporate - Company Profile" />
                            <asp:ListItem Value="Corporate - Guide" />
                            <asp:ListItem Value="Corporate - Logo" />
                            <asp:ListItem Value="Corporate - Template" />
                            <asp:ListItem Value="Data Sheet" />
                            <asp:ListItem Value="DM" />
                            <asp:ListItem Value="eDM" />
                            <asp:ListItem Value="Event Poster" />
                            <asp:ListItem Value="Event Presentation" />
                            <asp:ListItem Value="Manual" />
                            <asp:ListItem Value="Market Intelligence" />
                            <asp:ListItem Value="Photo" />
                            <asp:ListItem Value="Podcast" />
                            <asp:ListItem Value="Poster" />
                            <asp:ListItem Value="Press Release" />
                            <asp:ListItem Value="Product - Award" />
                            <asp:ListItem Value="Product - Datasheet" />
                            <asp:ListItem Value="Product - Documentation" />
                            <asp:ListItem Value="Product - Photo(3D)" />
                            <asp:ListItem Value="Product - Photo(B)" />
                            <asp:ListItem Value="Product - Photo(board)" />
                            <asp:ListItem Value="Product - Photo(DS)" />
                            <asp:ListItem Value="Product - Photo(Main)" />
                            <asp:ListItem Value="Product - Photo(Ori)" />
                            <asp:ListItem Value="Product - Photo(S)" />
                            <asp:ListItem Value="Product - Roadmap" />
                            <asp:ListItem Value="Product - Sales Kit" />
                            <asp:ListItem Value="White Paper" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Select File:
                    </th>
                    <td>
                        <input type="file" name="myFile1" style="margin-left: 20px;" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <input type="submit" value="Upload" name="mySubmit" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">                        
                    </td>
                </tr>
            </table>
        </asp:View>
        <asp:View runat="server" ID="v2">
            <table width="100%">
                <tr>
                    <td colspan="2">
                        File Content Maintenance
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Lit Id
                    </th>
                    <td>
                        <asp:Label runat="server" ID="lbLitId" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        File Name
                    </th>
                    <td>
                        <asp:HyperLink runat="server" ID="hyFNameLink" Target="_blank" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Display Name
                    </th>
                    <td>
                        <asp:TextBox runat="server" ID="txtDisplayName" Width="300px" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        File Type
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlFileTypeStep2">
                            <asp:ListItem Value="Advertisement" />
                            <asp:ListItem Value="Banner" />
                            <asp:ListItem Value="Brochure" />
                            <asp:ListItem Value="Catalogue" />
                            <asp:ListItem Value="Category_Photo" />
                            <asp:ListItem Value="Certificate" />
                            <asp:ListItem Value="Certificate-BSMI" />
                            <asp:ListItem Value="Certificate-CB" />
                            <asp:ListItem Value="Certificate-CB/60601" />
                            <asp:ListItem Value="Certificate-CCC" />
                            <asp:ListItem Value="Certificate-CCEE" />
                            <asp:ListItem Value="Certificate-CCIB" />
                            <asp:ListItem Value="Certificate-CE/60601/EMC" />
                            <asp:ListItem Value="Certificate-CE/60601/LVD" />
                            <asp:ListItem Value="Certificate-CE/EMC" />
                            <asp:ListItem Value="Certificate-CE/LVD" />
                            <asp:ListItem Value="Certificate-CSA" />
                            <asp:ListItem Value="Certificate-C-Tick" />
                            <asp:ListItem Value="Certificate-FCC" />
                            <asp:ListItem Value="Certificate-ISO" />
                            <asp:ListItem Value="Certificate-Others" />
                            <asp:ListItem Value="Certificate-TUV/60601" />
                            <asp:ListItem Value="Certificate-UL" />
                            <asp:ListItem Value="Certificate-UL/2601" />
                            <asp:ListItem Value="Certificate-UL/60601-1" />
                            <asp:ListItem Value="Certificate-VCCI" />
                            <asp:ListItem Value="Corporate - Award" />
                            <asp:ListItem Value="Corporate - Company Profile" />
                            <asp:ListItem Value="Corporate - Guide" />
                            <asp:ListItem Value="Corporate - Logo" />
                            <asp:ListItem Value="Corporate - Template" />
                            <asp:ListItem Value="Data Sheet" />
                            <asp:ListItem Value="DM" />
                            <asp:ListItem Value="eDM" />
                            <asp:ListItem Value="Event Poster" />
                            <asp:ListItem Value="Event Presentation" />
                            <asp:ListItem Value="Manual" />
                            <asp:ListItem Value="Market Intelligence" />
                            <asp:ListItem Value="Photo" />
                            <asp:ListItem Value="Podcast" />
                            <asp:ListItem Value="Poster" />
                            <asp:ListItem Value="Press Release" />
                            <asp:ListItem Value="Product - Award" />
                            <asp:ListItem Value="Product - Datasheet" />
                            <asp:ListItem Value="Product - Documentation" />
                            <asp:ListItem Value="Product - Photo(3D)" />
                            <asp:ListItem Value="Product - Photo(B)" />
                            <asp:ListItem Value="Product - Photo(board)" />
                            <asp:ListItem Value="Product - Photo(DS)" />
                            <asp:ListItem Value="Product - Photo(Main)" />
                            <asp:ListItem Value="Product - Photo(Ori)" />
                            <asp:ListItem Value="Product - Photo(S)" />
                            <asp:ListItem Value="Product - Roadmap" />
                            <asp:ListItem Value="Product - Sales Kit" />
                            <asp:ListItem Value="White Paper" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        File Extension
                    </th>
                    <td>
                        <asp:Label runat="server" ID="lbFileExt" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        File Size
                    </th>
                    <td>
                        <asp:Label runat="server" ID="lbFileSize" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        created Date
                    </th>
                    <td>
                        <asp:Label runat="server" ID="lbCDate" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Created By
                    </th>
                    <td>
                        <asp:Label runat="server" ID="lbCBy" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Description or Banner Link
                    </th>
                    <td>
                        <asp:TextBox runat="server" ID="txtFDesc" Width="300px" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Primary ID
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlPriId">
                            <asp:ListItem Value="AAC" />
                            <asp:ListItem Value="AAI" />
                            <asp:ListItem Value="AASC" />
                            <asp:ListItem Value="AAU" />
                            <asp:ListItem Value="ABE" />
                            <asp:ListItem Value="ABJ" />
                            <asp:ListItem Value="ABN" />
                            <asp:ListItem Value="ABR" />
                            <asp:ListItem Value="ACL" Selected="True" />
                            <asp:ListItem Value="ACN" />
                            <asp:ListItem Value="ACSC" />
                            <asp:ListItem Value="ADL" />
                            <asp:ListItem Value="AEE" />
                            <asp:ListItem Value="AENC" />
                            <asp:ListItem Value="AESC" />
                            <asp:ListItem Value="AFR" />
                            <asp:ListItem Value="AIC" />
                            <asp:ListItem Value="AID" />
                            <asp:ListItem Value="AIN" />
                            <asp:ListItem Value="AIT" />
                            <asp:ListItem Value="AJP" />
                            <asp:ListItem Value="AKR" />
                            <asp:ListItem Value="AMY" />
                            <asp:ListItem Value="APL" />
                            <asp:ListItem Value="ARU" />
                            <asp:ListItem Value="ASG" />
                            <asp:ListItem Value="ATH" />
                            <asp:ListItem Value="ATW" />
                            <asp:ListItem Value="AUK" />
                            <asp:ListItem Value="corp" />
                            <asp:ListItem Value="Israel" />
                            <asp:ListItem Value="Turkey" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Primary Level
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlPLevel">
                            <asp:ListItem Value="Channel" />
                            <asp:ListItem Value="General" />
                            <asp:ListItem Value="RBU" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Primary SDU
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlPriSDU" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Start Date
                    </th>
                    <td>
                        <ajaxToolkit:CalendarExtender runat="server" ID="cext1" TargetControlID="txtSDate"
                            Format="yyyy-MM-dd" />
                        <asp:TextBox runat="server" ID="txtSDate" Width="80px" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        End Date
                    </th>
                    <td>
                        <ajaxToolkit:CalendarExtender runat="server" ID="cext2" TargetControlID="txtEDate"
                            Format="yyyy-MM-dd" />
                        <asp:TextBox runat="server" ID="txtEDate" Width="80px" />&nbsp;<asp:CheckBox runat="server"
                            ID="cbNeverExpire" AutoPostBack="true" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Active Status
                    </th>
                    <td>
                        <asp:RadioButtonList runat="server" ID="rblActivestatus" RepeatColumns="2" RepeatDirection="Horizontal">
                            <asp:ListItem Text="Y" Selected="True" />
                            <asp:ListItem Text="N" />
                        </asp:RadioButtonList>
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Language
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlLang">
                            <asp:ListItem Value="ARA" />
                            <asp:ListItem Value="CHS" />
                            <asp:ListItem Value="CHT" />
                            <asp:ListItem Value="ENG" />
                            <asp:ListItem Value="ENU" Selected="True" />
                            <asp:ListItem Value="ESP" />
                            <asp:ListItem Value="JP" />
                            <asp:ListItem Value="KOR" />
                            <asp:ListItem Value="RUS" />
                            <asp:ListItem Value="SVE" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr style="display:none">
                    <th align="left">
                        Thumbnail
                    </th>
                    <td>
                        <asp:FileUpload runat="server" ID="fupTnail" Width="500px" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        FTP Url
                    </th>
                    <td>
                        <asp:HyperLink runat="server" ID="hyFTPUrl" />
                    </td>
                </tr>
                <tr>
                    <th align="left">
                        Product Line Selection
                    </th>
                    <td>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" align="right"><asp:Button runat="server" ID="btnNext" Text="Save and Next" OnClick="btnNext_Click" /></td>
                </tr>
            </table>
        </asp:View>
        <asp:View runat="server" ID="v3">
            Saved                        
        </asp:View>
    </asp:MultiView>
    <asp:Timer runat="server" ID="timerRefresh" Enabled="false" Interval="2000" OnTick="timerRefresh_Tick" />
    <fup:FileUploadProgress ID="FileUploadProgress1" OnClientProgressStopped="function(){}"
        OnClientProgressStarted="Clear" OnClientProgressRefreshed="Refresh" OnClientSubmitting="function(){}"
        OnClientFileRejected="Rejected" ShowUploadedFiles="true" runat="server">
    </fup:FileUploadProgress>
    <a href="javascript:void(0);" onclick="Cancel(); return false;" id="lnkCancelUpload"
        style="display: none;">Cancel Upload</a>
    <asp:Label runat="server" ID="uploadedFilesNumber" Text="" />
</asp:Content>