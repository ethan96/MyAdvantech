<%@ Page Title="MyAdvantech - Literature edit" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    Public StrCatalog_name, StrCatalog_Group, StrCatalog_ID, StrCatalog_Image, StrCatalog_Status, StrCatalog_PerCase As String
    Public StrCatalog_PDF, StrCatalog_PAGES, StrCatalog_SEQ, StrCatalog_Desc, StrSingle_Request, StrBulk_Request As String
    Public strCataID As String
    Public strImage, strPDF As String
    Dim savePath As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            strCataID = Request("CatalogID")
            If strCataID <> "" Then
                If Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    Response.Write(strCataID)
                End If
                GetUpdateInfor(strCataID)
            End If
        End If
        If IsPostBack Then
            If Request("Send") = "YES" Then
                'If (UploadPDF.HasFile) AndAlso (UploadPDF.PostedFile.ContentLength / 1048576) > 50 Then
                '    Me.ClientScript.RegisterStartupScript(Me.GetType(), "alert", "alert('PDF size exceeds 50MB. Please reduce PDF size.')", True)
                '    Exit Sub
                'Else
                EditDT()
                Response.Redirect("LitCataloglisting.aspx")
                'End If
            End If
        End If
        ' Session("user_view") = "AAC"
        If Session("RBU") <> "" Then
            HF_User_View.Value = Session("RBU").ToString().ToUpper()
        End If
    End Sub
    Function GetUpdateInfor(ByVal strCataID As String)
        Dim xDT As DataTable
        Dim strSelectSQL As String
        strSelectSQL = "select isnull(Catalog_name,'') as Catalog_name ,isnull(Catalog_Group,'') as Catalog_Group " & _
                       ",isnull(Catalog_ID,'')as Catalog_ID,isnull(Catalog_Image,'')as Catalog_Image,  " & _
                         "isnull(Catalog_Status,'') as Catalog_Status, isnull(Catalog_PerCase,'')as Catalog_PerCase " & _
                           ",isnull(Catalog_PDF,'')as Catalog_PDF,isnull(Catalog_PAGES,'')as Catalog_PAGES " & _
                          ",isnull(Catalog_SEQ,'')as Catalog_SEQ,isnull(Catalog_Desc,'')as Catalog_Desc, " & _
                         "isnull(Single_Request,'')as Single_Request,isnull(Bulk_Request,'')as Bulk_Request from Misc_Catalog_Listing  " & _
                        "where catalog_id=N'" & strCataID.Replace("'", "''") & "' "

        xDT = dbUtil.dbGetDataTable("MY", strSelectSQL)
        If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            Response.Write(strSelectSQL)
            ' Response.End()
        End If
        If xDT.Rows.Count >= 1 Then
            txtCatalogName.Text = xDT.Rows(0).Item("Catalog_Name")
            DDrCatalogGrop.SelectedValue = xDT.Rows(0).Item("Catalog_Group")
            TxtCatalogID.Text = xDT.Rows(0).Item("Catalog_ID")

            strImage = "<a target='_blank' href='../includes/showfile.aspx?File_ID=" & xDT.Rows(0).Item("Catalog_Image") & "'>" & xDT.Rows(0).Item("Catalog_Image") & "</a>"
            Session("Catalog_Image") = xDT.Rows(0).Item("Catalog_Image")
            DDRCataStatus.SelectedValue = xDT.Rows(0).Item("Catalog_Status")
            txtCatalogPerCase.Text = xDT.Rows(0).Item("Catalog_PerCase")
            strPDF = "<a target='_blank' href='../includes/showfile.aspx?File_ID=" & xDT.Rows(0).Item("Catalog_PDF") & "'>" & xDT.Rows(0).Item("Catalog_PDF") & "</a>"
            Session("Catalog_PDF") = xDT.Rows(0).Item("Catalog_PDF")
            txtCatalogPAGES.Text = xDT.Rows(0).Item("Catalog_PAGES")
            txtCatalogSEQ.Text = xDT.Rows(0).Item("Catalog_SEQ")
            txtCatalogDesc.Text = xDT.Rows(0).Item("Catalog_Desc")
            RadioBtnListSingleRequest.SelectedValue = xDT.Rows(0).Item("Single_Request")
            RadioBtnListBulkRequest.SelectedValue = xDT.Rows(0).Item("Bulk_Request")
        End If
    End Function

    Function EditDT()
        StrCatalog_name = txtCatalogName.Text.Replace("'", "''")
        StrCatalog_Group = DDrCatalogGrop.SelectedValue
        StrCatalog_ID = TxtCatalogID.Text.Replace("'", "''")
        StrCatalog_Status = DDRCataStatus.SelectedValue
        StrCatalog_PerCase = txtCatalogPerCase.Text.Replace("'", "''")
        StrCatalog_PAGES = txtCatalogPAGES.Text.Replace("'", "''")
        StrCatalog_SEQ = txtCatalogSEQ.Text.Replace("'", "''")
        StrCatalog_Desc = txtCatalogDesc.Text.Replace("'", "''")
        StrSingle_Request = RadioBtnListSingleRequest.SelectedValue
        StrBulk_Request = RadioBtnListBulkRequest.SelectedValue
        Dim strSQL As String
        strSQL = "update   Misc_Catalog_Listing " &
                        "set Catalog_name=N' " & StrCatalog_name & "' " &
                         ",Catalog_Group=N'" & StrCatalog_Group & "'" &
                        ",Catalog_ID=N'" & StrCatalog_ID & "'" &
                         ",Catalog_Status=N'" & StrCatalog_Status & "'" &
                        ", Catalog_PerCase=N'" & StrCatalog_PerCase & "'" &
                        ",Catalog_PAGES=N'" & StrCatalog_PAGES & "'" &
                        ",Catalog_SEQ=N'" & StrCatalog_SEQ & "'" &
                        ",Catalog_Desc= N'" & StrCatalog_Desc & "'" &
                        ",Single_Request=N'" & StrSingle_Request & "'" &
                       ",Bulk_Request=N'" & StrBulk_Request & "' "


        If (UploadImage.HasFile) Then UploadFileToServer(Session("Catalog_Image"), "Image", StrCatalog_ID)

        If (UploadPDF.HasFile) Then
            UploadFileToServer(Session("Catalog_PDF"), "PDF", StrCatalog_ID)
        End If

        strSQL = strSQL + " where Catalog_ID=N'" & StrCatalog_ID & "'"
        dbUtil.dbExecuteNoQuery("MY", strSQL)
        If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            Response.Write(strSQL)
            ' Response.End()
        End If
    End Function
    Function UploadFileToServer2(ByVal StrFile_ID As String, ByVal type As String)
        'Dim oAGSFile As New AGSUploadFiles
        'Dim strFileName, strFileExt As String
        'Dim filedatastream As Stream
        'Dim filelength As Integer
        'If type.ToLower = "pdf" Then
        '    strFileName = UploadPDF.FileName
        '    strFileExt = ""

        '    If UploadPDF.FileName.LastIndexOf(".") > 0 Then

        '        strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
        '        strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))

        '    End If

        '    filedatastream = UploadPDF.PostedFile.InputStream
        '    filelength = UploadPDF.PostedFile.ContentLength
        'Else
        '    strFileName = UploadImage.FileName
        '    strFileExt = ""

        '    If UploadImage.FileName.LastIndexOf(".") > 0 Then

        '        strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
        '        strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))

        '    End If

        '    filedatastream = UploadImage.PostedFile.InputStream
        '    filelength = UploadImage.PostedFile.ContentLength
        'End If

        'Dim fileData(filelength) As Byte
        'filedatastream.Read(fileData, 0, filelength)
        'With oAGSFile
        '    .File_ID = StrFile_ID
        '    Dim err As String = ""
        '    If .Refresh(err) > 0 Then

        '        .File_Name = strFileName
        '        .File_Desc = strFileName 'xDesc
        '        .File_Ext = strFileExt
        '        .File_Size = UploadImage.FileBytes.Length()
        '        .Last_Updated = Now()
        '        .Last_Updated_By = Session("user_id") 'xAut
        '        .File_Data = fileData


        '        If .Update(err) > 0 Then
        '           
        '        Else

        '         
        '        End If
        '    Else

        '    End If

        'End With
    End Function
    Function UploadFileToServer(ByVal StrSource_ID As String, ByVal type As String, ByVal Catalog_ID As String) As String
        Dim strFileName, strFileExt, strFile_Size As String : Dim filelength As Integer : Dim filedatastream As Stream
        If type.ToLower = "image" Then
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
            strFileName = UploadImage.FileName
            If UploadImage.FileName.LastIndexOf(".") > 0 Then
                strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
                strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))
            End If
            filedatastream = UploadImage.PostedFile.InputStream
            filelength = UploadImage.PostedFile.ContentLength
            strFile_Size = UploadImage.FileBytes.Length()
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
        End If
        If type.ToLower = "pdf" Then
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
            strFileName = UploadPDF.FileName
            If UploadPDF.FileName.LastIndexOf(".") > 0 Then
                strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
                strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))
            End If
            filedatastream = UploadPDF.PostedFile.InputStream
            filelength = UploadPDF.PostedFile.ContentLength
            strFile_Size = UploadPDF.FileBytes.Length()
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
        End If
        Dim fileData(filelength) As Byte
        filedatastream.Read(fileData, 0, filelength)
        ' Dim File_ID As String = Me.getRandomID()
        Dim userid As String = Session("user_id").ToString.Trim
        Dim Add_query As New StringBuilder
        ' Add_query.AppendFormat(" Insert into AGS_Upload_Files(Source_ID,Source,File_Category,File_ID,File_Name,File_Desc,File_Ext,File_Size,File_Status,Last_Updated,Last_Updated_By,File_Data,File_Answer) ")
        ' Add_query.AppendFormat(" Values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}',@img,'{11}')", StrSource_ID, "Literature", type.ToUpper, File_ID, strFileName, strFileName, strFileExt, strFile_Size, "1", Now(), userid, "")
        '2017/01/10 ICC Check ID is null or empy. If null means this literature didn't upload any files before.
        If String.IsNullOrEmpty(StrSource_ID) AndAlso Not String.IsNullOrEmpty(Catalog_ID) Then
            StrSource_ID = Me.getRandomID()
            Add_query.Append(" Insert into AGS_Upload_Files (Source_ID,Source,File_Category,File_ID,File_Name,File_Desc,File_Ext,File_Size,File_Status,Last_Updated,Last_Updated_By,File_Data,File_Answer) ")
            Add_query.AppendFormat(" Values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}',@img,'{11}'); ", Catalog_ID.Replace("'", "''"), "Literature", type.ToUpper().Replace("'", "''"), StrSource_ID.Replace("'", "''"), strFileName, strFileName.Replace("'", "''"), strFileExt.Replace("'", "''"), strFile_Size, "1", Now(), userid.Replace("'", "''"), "")

            'Also have to update listing table's column
            If type.ToLower = "image" Then
                Add_query.AppendFormat(" update Misc_Catalog_Listing set  Catalog_Image = N'{0}' where catalog_id = N'{1}' ", StrSource_ID.Replace("'", "''"), Catalog_ID.Replace("'", "''"))
            ElseIf type.ToLower = "pdf" Then
                Add_query.AppendFormat(" update Misc_Catalog_Listing set  Catalog_PDF = N'{0}' where catalog_id = N'{1}' ", StrSource_ID.Replace("'", "''"), Catalog_ID.Replace("'", "''"))
            End If
        Else
            Add_query.AppendFormat(" update AGS_Upload_Files set File_Name='{1}',File_Desc='{1}',File_Ext='{2}', File_Size='{3}',Last_Updated='{4}',Last_Updated_By ='{5}',File_Data =@img where File_ID ='{0}'", StrSource_ID, strFileName, strFileExt, strFile_Size, Now(), userid)
        End If

        Dim sqlConn As New SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim sqlComm As New SqlCommand(Add_query.ToString, sqlConn)
        sqlComm.Parameters.Add("@img", SqlDbType.Image) '添加参数
        sqlComm.Parameters("@img").Value = fileData '为参数赋值
        sqlConn.Open()
        sqlComm.ExecuteNonQuery()
        sqlConn.Close()
        ' Response.Write(Add_query)
        ' Response.End()
        Return ""
    End Function

    Public Function getRandomID() As String

        Dim tmpDate As DateTime = Now()

        Dim tmpID As String

        '--------------
        'Process Year Mont Day
        '-----------------
        'Dim tmpStr As String = get02ZString(tmpDate.Year Mod 36, 1)
        tmpID = get02ZString(tmpDate.Year Mod 36, 1) &
                get02ZString(tmpDate.Month, 1) &
                get02ZString(tmpDate.Day, 1)
        '-------------------
        'Process Hour Min Sec Hour one digit and Min + Sec 3 digit
        '-------------------
        tmpID = tmpID & get02ZString(tmpDate.Hour, 1) &
                get02ZString(tmpDate.Minute * 60 + tmpDate.Second, 3)

        'Dim obj As New Random(CType(System.DateTime.Now.Ticks Mod System.Int32.MaxValue, Integer))

        tmpID = tmpID & get02ZString(CType(ObjRan.Next(46655), Integer), 3)

        Return tmpID


    End Function

    Private Shared Function get02ZString(ByVal pIntNbr As Int64, ByVal pIntDigits As Integer) As String

        Dim tmpStrReturn As String = ""

        Dim tmpInt As Int64

        If pIntNbr < 0 Then
            tmpInt = -pIntNbr
        Else
            tmpInt = pIntNbr
        End If

        Do

            Dim tmpInt2 As Integer = tmpInt Mod 36

            If tmpInt2 < 10 Then
                tmpStrReturn = tmpInt2 & tmpStrReturn
            Else
                'Chr 65 is A
                tmpStrReturn = Chr(65 + tmpInt2 - 10) & tmpStrReturn
            End If

            tmpInt = (tmpInt - tmpInt2) / 36

        Loop While tmpInt > 0

        Do While tmpStrReturn.Length < pIntDigits
            tmpStrReturn = "0" & tmpStrReturn
        Loop

        If pIntNbr < 0 Then
            tmpStrReturn = "-" & tmpStrReturn
        End If

        Return tmpStrReturn

    End Function

    Private Shared _ObjRan As Random
    Public Shared Property ObjRan() As Random
        Get
            If _ObjRan Is Nothing Then
                _ObjRan = New Random(CType(System.DateTime.Now.Ticks Mod System.Int32.MaxValue, Integer))
            End If
            Return _ObjRan
        End Get
        Set(ByVal value As Random)
            _ObjRan = value
        End Set
    End Property
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript" src="/EC/Includes/jquery-latest.min.js"></script>
<script type="text/javascript">
  
    $(function () {
        $('#<%=UploadPDF.ClientID %>').change(function () {  //選取類型為file且值發生改變的
            var file = this.files[0]; //定義file=發生改的file
            size = file.size; //size=檔案大小
            if (file.size > 52428800) {
                alert('PDF size exceeds 50MB. Please reduce PDF size.'); //顯示警告!!
                $(this).val('');  //將檔案欄設為空白
            }
        });
    });

    function isChar(passedVal) {
        if (((passedVal >= "A") && (passedVal <= "Z")) || ((passedVal >= "a") && (passedVal <= "z")))
            return true;
        else
            return false;
    }


    function isDigit(PassedValue) {
        if ((PassedValue >= "0") && (PassedValue <= "9"))
            return true;
        return false;
    }

    function Trim(PassedValue) {
        for (i = 0; i < PassedValue.length; i++) {
            if (PassedValue.charAt(i) != " ") {
                x = i;
                break;
            }
        }
        z = PassedValue.length - 1;
        y = -1;
        while (z >= 0) {
            if (PassedValue.charAt(z) != " ") {
                y = z;
                break;
            }
            z = z - 1
        }
        ans = ""
        if (y >= 0) {
            for (i = x; i <= y; i++) {
                ans = ans + PassedValue.charAt(i);
            }
        }
        return ans
    }



    function validate() {
    

        var strFlag = "TRUE";

        //    Obj = document.RegisterForm.strCompany
        var Obj = document.getElementById("<%=txtCatalogName.ClientID %>")

        if (Trim(Obj.value) == "") {
            alert("Catalog name is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }



        // Obj = document.RegisterForm.strAddress
        Obj = document.getElementById("<%=TxtCatalogID.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("CatalogID is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }


        Obj = document.getElementById("<%=DDRCataStatus.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("Catalog Status is required.");
            Obj.focus();
            strFlag = "FALSE";
            return false;
        }

        // Obj = document.RegisterForm.strState
        Obj = document.getElementById("<%=DDrCatalogGrop.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("Catalog Group is required.");
            Obj.focus();
            strFlag = "FALSE";
            return false;
        }

        //Obj = document.RegisterForm.strZip
        Obj = document.getElementById("<%=txtCatalogPerCase.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("CatalogPerCase is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }


        //Obj = document.RegisterForm.strPhone
        Obj = document.getElementById("<%=txtCatalogPAGES.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("CatalogPAGES is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }


        Obj = document.getElementById("<%=txtCatalogSEQ.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("CatalogSEQ is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }




        if (isDigit(Trim(Obj.value)) == false) {
            alert("Invalid CatalogSEQ.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }


        Obj = document.getElementById("<%=txtCatalogDesc.ClientID %>")
        if (Trim(Obj.value) == "") {
            alert("CatalogDesc is required.");
            Obj.focus();
            Obj.select();
            strFlag = "FALSE";
            return false;
        }

    
        if (strFlag != "FALSE") {
            document.aspnetForm.action = "LitCatalogListEdit.aspx?Send=YES";
           
            document.aspnetForm.submit();

        }





    }
</script>

 
 
   <table  width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top">&nbsp;</td>
        </tr>
         <tr>
                        <td height="6">&nbsp;
                        </td>
                    </tr>
        <tr>
            <td valign="top" width="98%" align="left">
                
 
 
 
 
 <table width="100%" >
   <tr>
     <td align="center">
         <table width="50%" border="0" cellspacing="1" cellpadding="1">
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#b0c4de" height="30">
                                        <b>Catalog&nbsp;Information</b>
                                    </td>
                                </tr>
                             
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>&nbsp;Catalog Name:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:TextBox runat="server" ID="txtCatalogName" size="40"></asp:TextBox>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">* </font>Catalog&nbsp;Group:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;
                                        <asp:DropDownList ID="DDrCatalogGrop" runat="server">
                                         <asp:ListItem Text="-- Select Below --" Value=""></asp:ListItem>
                                        <asp:ListItem Text="CD-ROM" Value="CD-ROM"></asp:ListItem>
                                         <asp:ListItem Text="Print" Value="Print"></asp:ListItem>
                                        
                                        </asp:DropDownList>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Catalog ID&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:TextBox runat="server" ID="TxtCatalogID" size="40" ReadOnly="true"></asp:TextBox>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Catalog Status:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<%--<asp:TextBox runat="server" ID="txtCatalogStatus" size="40"></asp:TextBox>--%>
											
											 <asp:DropDownList ID="DDRCataStatus" runat="server">
                                         <asp:ListItem Text="-- Select Below --" Value=""></asp:ListItem>
                                        <asp:ListItem Text="Available" Value="Available"></asp:ListItem>
                                         <asp:ListItem Text="Not Available" Value="Not Available"></asp:ListItem>
                                         <asp:ListItem Text="In Transfer" Value="In Transfer"></asp:ListItem>
                                        
                                        </asp:DropDownList>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>&nbsp;Catalog PerCase:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:TextBox runat="server" ID="txtCatalogPerCase" size="40"></asp:TextBox>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Catalog PAGES:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:TextBox runat="server" ID="txtCatalogPAGES" size="40"></asp:TextBox>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>&nbsp;Catalog SEQ:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:TextBox runat="server" ID="txtCatalogSEQ" size="40"></asp:TextBox>
									</td>
                                </tr>
                                 <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Single_Request&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:RadioButtonList ID="RadioBtnListSingleRequest" runat="server" RepeatDirection="Horizontal">
											<asp:ListItem Text="No" Value="No"></asp:ListItem>
											<asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                        </asp:RadioButtonList>
									</td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Bulk_Request&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
											&nbsp;<asp:RadioButtonList ID="RadioBtnListBulkRequest" runat="server" RepeatDirection="Horizontal">
											<asp:ListItem Text="No" Value="No"></asp:ListItem>
											<asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                        </asp:RadioButtonList>
									</td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Catalog Description&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
										        &nbsp;<asp:TextBox runat="server" ID="txtCatalogDesc" TextMode="multiLine" Rows="6" Columns="57" MaxLength="180"></asp:TextBox>
									</td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red"></font>Catalog Image&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
										   &nbsp;<asp:FileUpload runat="server" ID="UploadImage"  size="30"/>
										   <%=strImage %>
										   
										   <%--<asp:Label runat="server" ID="labUploadImage"></asp:Label>--%>
									</td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red"></font>Catalog PDF&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel" align="left">
										   &nbsp;<asp:FileUpload runat="server" ID="UploadPDF"  size="30"/>
										   
										   <%=strPDF %>
										  <%--<a href=""> <asp:Label runat="server" ID="labUploadPDF"></asp:Label></a>--%>
									</td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#e6e6fa" valign="middle" height="35">
                                                                          
                                        <asp:HiddenField   ID="HF_User_View" runat="server" />
                                        <input id="btnSubmit" name="mySubmit" type="button" value="Update" onclick="validate();"/>
                                      
                                    </td>
                                </tr>
                            </table>
     </td>
   </tr>
   
   <tr>
     <td width="100%">
      
       
                 
                                  
     </td>
   </tr>
 </table>
 
 </td>
 
 </tr>
  <tr>
            <td valign="bottom">
            </td>
        </tr>
 </table>
 

</asp:Content>

