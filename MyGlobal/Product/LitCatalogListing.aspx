<%@ Page Title="MyAdvantech - Literature listing" EnableEventValidation="false" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    Public StrCatalog_name, StrCatalog_Group, StrCatalog_ID, StrCatalog_Image, StrCatalog_Status, StrCatalog_PerCase As String
    Public StrCatalog_PDF, StrCatalog_PAGES, StrCatalog_SEQ, StrCatalog_Desc, StrSingle_Request, StrBulk_Request As String
    Public strCataID As String
    Public flag As String
    Dim savePath As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If IsPostBack Then
            If Request("Send") = "YES" Then
                StrCatalog_ID = TxtCatalogID.Text
                CatalogIDlist(StrCatalog_ID)
                If flag = "NoExist" Then
                    'If (UploadPDF.HasFile) AndAlso (UploadPDF.PostedFile.ContentLength / 1048576) > 50 Then
                    '    Me.ClientScript.RegisterStartupScript(Me.GetType(), "alert", "alert('PDF size exceeds 50MB. Please reduce PDF size.')", True)
                    '    Exit Sub
                    'Else
                    EditDT("Add", "")
                    Response.Redirect("LitCataloglisting.aspx")
                    'End If
                Else
                    labCheckCataID.Text = "The CatalogID has Exist"
                    labCheckResult.Text = "The CatalogID has ExistD"
                End If



            ElseIf Request("Send") = "Check" Then
                StrCatalog_ID = TxtCatalogID.Text
                CatalogIDlist(StrCatalog_ID)
                If flag = "NoExist" Then
                    labCheckResult.Text = "Can use"
                Else
                    labCheckResult.Text = "The CatalogID has ExistD"
                End If

            End If

        End If
        ' Session("RBU") = "AAC"
        If Session("RBU") IsNot Nothing AndAlso Session("RBU") <> "" Then
            HF_User_View.Value = Session("RBU").ToString().ToUpper().Replace("'", "''")
        End If
        getList()
    End Sub
    Public Function EditDT(ByVal strAdmin As String, ByVal strCataID As String)
        StrCatalog_name = txtCatalogName.Text.Replace("'", "''")
        StrCatalog_Group = DDrCatalogGrop.SelectedValue
        StrCatalog_ID = TxtCatalogID.Text.Replace("'", "''")
        StrCatalog_Image = UploadImageToServer(StrCatalog_ID, "image") 'UploadImage.FileName
        StrCatalog_Status = DDRCataStatus.SelectedValue
        StrCatalog_PerCase = txtCatalogPerCase.Text.Replace("'", "''")
        StrCatalog_PDF = UploadImageToServer(StrCatalog_ID, "pdf") 'UploadPDF.FileName
        StrCatalog_PAGES = txtCatalogPAGES.Text.Replace("'", "''")
        StrCatalog_SEQ = txtCatalogSEQ.Text.Replace("'", "''")
        StrCatalog_Desc = txtCatalogDesc.Text.Replace("'", "''")
        StrSingle_Request = RadioBtnListSingleRequest.SelectedValue
        StrBulk_Request = RadioBtnListBulkRequest.SelectedValue
        Dim strSQL As String
        strSQL = "insert into Misc_Catalog_Listing " & _
                   "(Catalog_name,Catalog_Group,Catalog_ID,Catalog_Image," & _
                   "Catalog_Status, Catalog_PerCase,Catalog_PDF,Catalog_PAGES,Catalog_SEQ,Catalog_Desc," & _
                   "Single_Request,Bulk_Request,RBU_ID )" & _
                   "values(N'" & StrCatalog_name & "',N'" & StrCatalog_Group & "',N'" & StrCatalog_ID & "',N'" & StrCatalog_Image & "',N'" & StrCatalog_Status & "'" & _
                   ",N'" & StrCatalog_PerCase & "',N'" & StrCatalog_PDF & "',N'" & StrCatalog_PAGES & "',N'" & StrCatalog_SEQ & "',N'" & StrCatalog_Desc & "',N'" & StrSingle_Request & "',N'" & StrBulk_Request & "',N'" & HF_User_View.Value & "')"

        dbUtil.dbExecuteNoQuery("MY", strSQL)
    End Function

    Public Function getList()
        Dim l_strSQLCmd As String
        l_strSQLCmd = "select 'Edit' as Edit , Catalog_name,Catalog_Group,Catalog_ID,Catalog_Image,Catalog_Status, Catalog_PerCase,Catalog_PDF,Catalog_PAGES,Catalog_SEQ," & _
            "case when len(Catalog_Desc)>50 then substring(Catalog_Desc,0,45)+'....' else Catalog_Desc end as Catalog_Desc,Single_Request,Bulk_Request from Misc_Catalog_Listing where  (IsDEL <> 1 OR ISDEL IS NULL) "

        If TBName.Text <> "" Then
            l_strSQLCmd += String.Format(" AND  ( Catalog_Name LIKE '%{0}%'  or Catalog_Desc LIKE '%{0}%' )", TBName.Text.Trim.Replace("'", "''"))
        End If
        l_strSQLCmd += " order by Catalog_SEQ "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", l_strSQLCmd)
        gv1.DataSource = dt
        gv1.DataBind()
    End Function
    Public Function CatalogIDlist(ByVal CatalogID As String) As String
        Dim strSelectSQL As String
        Dim xDT As DataTable
        strSelectSQL = String.Format("select  IsDel,Catalog_ID from Misc_Catalog_Listing where Catalog_ID='{0}'", CatalogID.Replace("'", "''"))
        xDT = dbUtil.dbGetDataTable("MY", strSelectSQL)
        If xDT.Rows.Count >= 1 Then
            If xDT.Rows(0).Item("IsDel").ToString = "1" Then
                dbUtil.dbExecuteNoQuery("MY", String.Format("update Misc_Catalog_Listing set Catalog_ID= Catalog_ID + '-DEL' where Catalog_ID ='{0}' and IsDel =1", CatalogID.Replace("'", "''")))
                flag = "NoExist"
            Else
                flag = "Exist"
            End If
        Else
            flag = "NoExist"
        End If
    End Function
    Public Enum AGSFileStatus
        FileDisable
        FileEnable
    End Enum
    Function UploadImageToServer(ByVal StrSource_ID As String, ByVal type As String) As String
        Dim strFileName, strFileExt, strFile_Size As String : Dim filelength As Integer : Dim filedatastream As Stream
        If type.ToLower = "image" Then
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
            If Not UploadImage.HasFile Then
                Return ""
            End If
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
            If Not UploadPDF.HasFile Then
                Return ""
            End If
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
        Dim File_ID As String = Me.getRandomID()
        Dim userid As String = Session("user_id").ToString.Trim
        Dim Add_query As New StringBuilder
        Add_query.AppendFormat(" Insert into AGS_Upload_Files(Source_ID,Source,File_Category,File_ID,File_Name,File_Desc,File_Ext,File_Size,File_Status,Last_Updated,Last_Updated_By,File_Data,File_Answer) ")
        Add_query.AppendFormat(" Values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}',@img,'{11}')", StrSource_ID.Replace("'", "''"), "Literature", type.ToUpper.Replace("'", "''"), File_ID.Replace("'", "''"), strFileName.Replace("'", "''"), strFileName.Replace("'", "''"), strFileExt.Replace("'", "''"), strFile_Size, "1", Now(), userid.Replace("'", "''"), "")
        Dim sqlConn As New SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim sqlComm As New SqlCommand(Add_query.ToString, sqlConn)
        sqlComm.Parameters.Add("@img", SqlDbType.Image) '添加参数
        sqlComm.Parameters("@img").Value = fileData '为参数赋值
        sqlConn.Open()
        sqlComm.ExecuteNonQuery()
        sqlConn.Close()
        Return File_ID
    End Function
    Public Function getRandomID() As String

        Dim tmpDate As DateTime = Now()

        Dim tmpID As String

        '--------------
        'Process Year Mont Day
        '-----------------
        'Dim tmpStr As String = get02ZString(tmpDate.Year Mod 36, 1)
        tmpID = get02ZString(tmpDate.Year Mod 36, 1) & _
                get02ZString(tmpDate.Month, 1) & _
                get02ZString(tmpDate.Day, 1)
        '-------------------
        'Process Hour Min Sec Hour one digit and Min + Sec 3 digit
        '-------------------
        tmpID = tmpID & get02ZString(tmpDate.Hour, 1) & _
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
    Function UploadPDFToServer(ByVal StrCatalog_ID As String) As String
        'Dim oAGSFile As New AGSUploadFiles
        'Dim strFileName, strFileExt As String
        'strFileName = UploadPDF.FileName
        'strFileExt = ""
        'If UploadPDF.FileName.LastIndexOf(".") > 0 Then
        '    strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
        '    strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))
        'End If
        'Dim filedatastream As Stream = UploadPDF.PostedFile.InputStream
        'Dim filelength As Integer = UploadPDF.PostedFile.ContentLength
        'Dim fileData(filelength) As Byte
        'filedatastream.Read(fileData, 0, filelength)
        'With oAGSFile

        '    .File_ID = Util.getRandomID()
        '    .File_Category = "PDF" 'xType
        '    .Source = "Literature" '"DistInfo"
        '    .Source_ID = StrCatalog_ID 'ID
        '    .File_Name = strFileName
        '    .File_Desc = strFileName 'xDesc
        '    .File_Ext = strFileExt
        '    .File_Status = AGSFileStatus.FileEnable
        '    .File_Size = UploadImage.FileBytes.Length()
        '    .Last_Updated = Now()
        '    .Last_Updated_By = Session("user_id") 'xAut
        '    .File_Data = fileData
        '    .File_Answer = "" 'xAns
        '    '.AddByRandomID()
        '    Dim err As String = ""
        '    If .IsExist() Then
        '       
        '    Else
        '        .Add(err)
        '      
        '    End If
        'End With
        'Return oAGSFile.File_ID
        Return ""
    End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gv1.RowDataBound
        Dim oType As ListItemType = e.Row.RowType
        If (oType <> ListItemType.Header And oType <> ListItemType.Footer) Then
            Dim catalogID As String = e.Row.Cells(3).Text
            e.Row.Cells(13).Text = "<img src='../Images/pencil.gif' style='cursor:pointer;' onclick='javascript:EditAdmin(""" & catalogID & """)'/>"
            e.Row.Cells(4).Text = "<a target='_blank' href='../includes/showfile.aspx?File_ID=" & e.Row.Cells(4).Text & "'>" & e.Row.Cells(4).Text & "</a>"
            e.Row.Cells(7).Text = "<a target='_blank' href='../includes/showfile.aspx?File_ID=" & e.Row.Cells(7).Text & "'>" & e.Row.Cells(7).Text & "</a>"
        End If

    End Sub

    Protected Sub ImgDel_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim Catalog_ID As String = gv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values(0).ToString
        Dim strSQL As String = "update Misc_Catalog_listing set IsDEL = 1 WHERE Catalog_ID ='" + Catalog_ID + "'"
        dbUtil.dbExecuteNoQuery("my", strSQL)
        getList()
    End Sub
    Protected Sub BTSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        getList()
    End Sub

    Protected Sub ibtnSeqUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim CID As String = obj.CommandName
        Dim oseq As Integer = Integer.Parse(obj.CommandArgument)
        Dim nextIDSeq As DataTable
        nextIDSeq = dbUtil.dbGetDataTable("my", String.Format("select top 1 catalog_id,catalog_seq from misc_catalog_listing where catalog_seq < {0} and (IsDEL <> 1 OR ISDEL IS NULL) order by catalog_seq desc", oseq))
        If Not IsNothing(nextIDSeq) AndAlso nextIDSeq.Rows.Count > 0 Then
            Dim nextId As String = nextIDSeq.Rows(0).Item("catalog_id")
            Dim nextSeq As Integer = nextIDSeq.Rows(0).Item("catalog_seq")
            Dim strSQL As String = String.Format("update misc_catalog_listing set Catalog_SEQ = {0} where Catalog_ID='{1}' and (IsDEL <> 1 OR ISDEL IS NULL);update misc_catalog_listing set Catalog_SEQ = {2} where Catalog_ID='{3}' and (IsDEL <> 1 OR ISDEL IS NULL)", nextSeq, CID, oseq, nextId)
            dbUtil.dbExecuteNoQuery("my", strSQL)
        End If
        getList()
    End Sub

    Protected Sub ibtnSeqDown_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim CID As String = obj.CommandName
        Dim oseq As Integer = Integer.Parse(obj.CommandArgument)
        Dim nextIDSeq As DataTable
        nextIDSeq = dbUtil.dbGetDataTable("my", String.Format("select top 1 catalog_id,catalog_seq from misc_catalog_listing where catalog_seq > {0} and (IsDEL <> 1 OR ISDEL IS NULL) order by catalog_seq", oseq))
        If Not IsNothing(nextIDSeq) AndAlso nextIDSeq.Rows.Count > 0 Then
            Dim nextId As String = nextIDSeq.Rows(0).Item("catalog_id")
            Dim nextSeq As Integer = nextIDSeq.Rows(0).Item("catalog_seq")
            Dim strSQL As String = String.Format("update misc_catalog_listing set Catalog_SEQ = {0} where Catalog_ID='{1}' and (IsDEL <> 1 OR ISDEL IS NULL);update misc_catalog_listing set Catalog_SEQ = {2} where Catalog_ID='{3}' and (IsDEL <> 1 OR ISDEL IS NULL)", nextSeq, CID, oseq, nextId)
            dbUtil.dbExecuteNoQuery("my", strSQL)
        End If
        getList()
    End Sub

    Protected Sub btnUpdateSeq_Click(sender As Object, e As EventArgs)
        Dim locationIds As String() = (From p In Request.Form("LocationId").Split(",")
                                       Select p).ToArray()
        Dim preference As Integer = 1
        For Each locationId As String In locationIds
            Me.UpdateSeq(locationId, preference)
            preference += 1
        Next
        Response.Redirect(Request.Url.AbsoluteUri)
    End Sub

    Private Sub UpdateSeq(locationId As String, preference As Integer)
        'Response.Write(String.Format("update set catalog_seq={0} where catlaog_id='{1}'<br/>", preference, locationId.Replace("'", "''")))
        dbUtil.dbExecuteNoQuery("MY", String.Format("update Misc_Catalog_Listing set catalog_seq={0} where catalog_id='{1}'", preference, locationId.Replace("'", "''")))
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="/EC/Includes/jquery-latest.min.js"></script>    
    <script src="../Includes/js/jquery-ui.js"></script>
    <link href="../Includes/js/jquery-ui.css" rel="stylesheet" />
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

             $("[id*=<%=gv1.ClientID%>]").sortable({
                 items: 'tr:not(tr:first-child)',
                 cursor: 'pointer',
                 axis: 'y',
                 dropOnEmpty: false,
                 start: function (e, ui) {
                     ui.item.addClass("selected");
                 },
                 stop: function (e, ui) {
                     ui.item.removeClass("selected");
                 },
                 receive: function (e, ui) {
                     $(this).find("tbody").append(ui.item);
                 }
             });

        });
        function EditAdmin(StrCatalog) {
            //alert(StrCatalog);
            window.location = "LitCatalogListEdit.aspx?CatalogID=" + StrCatalog;
            //document.form1.submit();  

        }
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

        function validateCatID() {
            Obj = document.getElementById('<%=TxtCatalogID.ClientID %>');
            if (Trim(Obj.value) == "") {
                alert("CatalogID is required.");
            }
            else {
                document.aspnetForm.action = "Litcataloglisting.aspx?Send=Check";
                document.aspnetForm.submit();
            }

        }


        function validate() {
            //Obj = document.MyForm1.continue1
            //if (Obj.value == "No")
            //   return true

            var strFlag = "TRUE";



            //    Obj = document.RegisterForm.strCompany
            var Obj = document.getElementById('<%=txtCatalogName.ClientID %>');

            if (Trim(Obj.value) == "") {
                alert("Catalog name is required.");
                Obj.focus();
                Obj.select();
                strFlag = "FALSE";
                return false;
            }



            // Obj = document.RegisterForm.strAddress
            Obj = document.getElementById('<%=TxtCatalogID.ClientID %>');
            if (Trim(Obj.value) == "") {
                alert("CatalogID is required.");
                Obj.focus();
                Obj.select();
                strFlag = "FALSE";
                return false;
            }


            Obj = document.getElementById("ctl00__main_DDRCataStatus")
            if (Trim(Obj.value) == "") {
                alert("Catalog Status is required.");
                Obj.focus();
                strFlag = "FALSE";
                return false;
            }

            // Obj = document.RegisterForm.strState
            Obj = document.getElementById("ctl00__main_DDrCatalogGrop")
            if (Trim(Obj.value) == "") {
                alert("Catalog Group is required.");
                Obj.focus();
                strFlag = "FALSE";
                return false;
            }

            //Obj = document.RegisterForm.strZip
            Obj = document.getElementById("ctl00__main_txtCatalogPerCase")
            if (Trim(Obj.value) == "") {
                alert("CatalogPerCase is required.");
                Obj.focus();
                Obj.select();
                strFlag = "FALSE";
                return false;
            }


            //Obj = document.RegisterForm.strPhone
            Obj = document.getElementById("ctl00__main_txtCatalogPAGES")
            if (Trim(Obj.value) == "") {
                alert("CatalogPAGES is required.");
                Obj.focus();
                Obj.select();
                strFlag = "FALSE";
                return false;
            }
            // Obj = document.RegisterForm.strEmail
            Obj = document.getElementById("ctl00__main_txtCatalogSEQ")
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


            Obj = document.getElementById("ctl00__main_txtCatalogDesc")
            if (Trim(Obj.value) == "") {
                alert("CatalogDesc is required.");
                Obj.focus();
                Obj.select();
                strFlag = "FALSE";
                return false;
            }


            if (strFlag != "FALSE") {
                document.aspnetForm.action = "Litcataloglisting.aspx?Send=YES";
                document.aspnetForm.submit();
            }

        }
        function btnSubmit_onclick() {

        }

    </script>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top">
                &nbsp;
            </td>
        </tr>
        <tr>
            <td height="6">
                Keywords:
                <asp:TextBox ID="TBName" runat="server"></asp:TextBox>
                <asp:Button ID="BTSearch" runat="server" Text="Search" OnClick="BTSearch_Click" />
            </td>
        </tr>
        <tr>
            <td valign="top" width="98%" align="left">
                <table>
                    <tr>
                        <td width="100%">
                            <asp:Button runat="server" ID="btnUpdateSeq" Text="Update Sequence" OnClick="btnUpdateSeq_Click" />
                            <sgv:SmartGridView runat="server" ID="gv1" ShowWhenEmpty="true" DataKeyNames="Catalog_ID"
                                AutoGenerateColumns="false" AllowSorting="true" Width="100%">
                                <Columns>
                                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                        <HeaderTemplate>
                                            No.
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                            <input type="hidden" name="LocationId" value='<%# Eval("Catalog_ID") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Name" DataField="Catalog_Name" ReadOnly="true" ItemStyle-HorizontalAlign="Right" />
                                    <asp:BoundField HeaderText="Group" DataField="Catalog_Group" ReadOnly="true" />
                                    <asp:BoundField HeaderText="ID" DataField="Catalog_ID" ReadOnly="true" />
                                    <asp:BoundField HeaderText="Image" DataField="Catalog_Image" ReadOnly="true" />
                                    <asp:BoundField HeaderText="Status" DataField="Catalog_Status" ReadOnly="true" />
                                    <asp:BoundField HeaderText="PerCase" DataField="Catalog_PerCase" ReadOnly="true" />
                                    <asp:BoundField HeaderText=" PDF " DataField="Catalog_PDF" ReadOnly="true" />
                                    <asp:BoundField HeaderText="Pages" DataField="Catalog_PAGES" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="SEQ" DataField="Catalog_SEQ" ReadOnly="true" />
                                    <asp:BoundField HeaderText="Description" DataField="Catalog_DESC" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Left" />
                                    <asp:BoundField HeaderText="SingleRequest" DataField="Single_Request" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="BulkRequest" DataField="Bulk_Request" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Edit" DataField="Edit" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Delete">
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ImgDel" ImageUrl="~/images/btn_del.gif" runat="server" OnClick="ImgDel_Click" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <HeaderTemplate>
                                            Move
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:LinkButton runat="server" ForeColor="#000000" Font-Size="Large" CommandName='<%#Bind("Catalog_ID")%>' ID="ibtnSeqUp" CommandArgument='<%#Bind("Catalog_seq")%>'
                                                        Font-Bold="true" Text="↑" OnClick="ibtnSeqUp_Click" />
                                                    </td>
                                                    <td>
                                                        <asp:LinkButton runat="server" ForeColor="#000000" Font-Size="Large" CommandName='<%#Bind("Catalog_ID")%>' ID="ibtnSeqDown" CommandArgument='<%#Bind("Catalog_seq")%>'
                                                        Font-Bold="true" Text="↓" OnClick="ibtnSeqDown_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="#FFFFCC" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                            </sgv:SmartGridView>
                        </td>
                    </tr>
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
                                        <div class="mceLabel">
                                            <font color="red">*</font>&nbsp;Catalog Name:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogName" size="40"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">* </font>Catalog&nbsp;Group:&nbsp;</div>
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
                                    <td bgcolor="#dcdcdc" align="right" width="120" style="height: 26px">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Catalog ID&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" style="height: 26px" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="TxtCatalogID" size="40"></asp:TextBox>
                                        <%--<asp:Button  runat="server" ID="btnCheckCataID" Text="Check CatalogID"/>--%>
                                        <input id="btnCheckCataID" name="CheckCatID" type="button" value="Check" onclick="validateCatID();" />
                                        <asp:Label ID="labCheckResult" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Catalog Status:&nbsp;</div>
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
                                        <div class="mceLabel">
                                            <font color="red">*</font>&nbsp;Catalog PerCase:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogPerCase" size="40"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Catalog PAGES:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogPAGES" size="40"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120" style="height: 26px">
                                        <div class="mceLabel">
                                            <font color="red">*</font>&nbsp;Catalog SEQ:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" style="height: 26px" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogSEQ" size="40"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Single_Request&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:RadioButtonList ID="RadioBtnListSingleRequest" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="No" Value="No"></asp:ListItem>
                                            <asp:ListItem Text="Yes" Value="Yes" Selected="True"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Bulk_Request&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:RadioButtonList ID="RadioBtnListBulkRequest" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="No" Value="No"></asp:ListItem>
                                            <asp:ListItem Text="Yes" Value="Yes" Selected="True"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Catalog Description&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogDesc" TextMode="multiLine" Rows="6"
                                            Columns="57" MaxLength="180"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red"></font>Catalog Image&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" align="left">
                                        &nbsp;<asp:FileUpload runat="server" ID="UploadImage" size="30" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120" style="height: 26px">
                                        <div class="mceLabel">
                                            <font color="red"></font>Catalog PDF&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel" style="height: 26px" align="left">
                                        &nbsp;<asp:FileUpload runat="server" ID="UploadPDF" size="30" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#e6e6fa" valign="middle" height="35">
                                        <%-- <asp:Button runat="server" ID="BtnADD" Text="ADD"  />--%><asp:HiddenField ID="HF_User_View"
                                            runat="server" />
                                        &nbsp;<input id="btnSubmit" name="mySubmit" type="button" value="ADD" onclick="validate();"
                                            onclick="return btnSubmit_onclick()" />
                                        <asp:Label ID="labCheckCataID" runat="server"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td valign="bottom">
                &nbsp;
            </td>
        </tr>
    </table>
</asp:Content>
