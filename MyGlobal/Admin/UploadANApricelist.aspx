<%@ Page Title="Upload excel file of Pricelist" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<%@ Import Namespace="System.IO" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'ICC 2015/10/30 Add Page_Load event to set permission for users.
        'For Adam, he can upload AAC & AENC, and for Andy.Chiu, he can upload Arrow price list.
        If Not Page.IsPostBack Then
            If Util.IsAEUIT() = True Then
                'MyAdvantech team can see all radio list
            ElseIf Util.IsANAPowerUser() = True Then
                RadioButtonList1.Items.Remove(New ListItem("Arrow", "Arrow"))
            ElseIf User.Identity.Name.ToLower() = "andy.chiu@advantech.com.tw" Then
                RadioButtonList1.Items.Remove(New ListItem("AAC", "AAC"))
                RadioButtonList1.Items.Remove(New ListItem("AENC", "AENC"))
            Else
                Response.Redirect(Request.ApplicationPath)
            End If
        End If
    End Sub
    
    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Label1.Text = ""
        If RadioButtonList1.SelectedIndex < 0 Then
            Label1.Text = "Please select the type."
            Exit Sub
        End If
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim strFileName, strFileExt, strFile_Size As String : Dim filelength As Integer : Dim filedatastream As Stream
            strFileName = FileUpload1.FileName
            If FileUpload1.FileName.LastIndexOf(".") > 0 Then
                strFileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
                strFileName = strFileName.Substring(0, strFileName.LastIndexOf("."))
            End If
            If strFileExt.ToUpper = "XLS" OrElse strFileExt.ToUpper = "XLSX" Then 'ICC 2015/10/1 Add xlsx extension.
                filedatastream = FileUpload1.PostedFile.InputStream
                filelength = FileUpload1.PostedFile.ContentLength
                strFile_Size = FileUpload1.FileBytes.Length()
                Dim fileData(filelength) As Byte
                filedatastream.Read(fileData, 0, filelength)
                dbUtil.dbExecuteNoQuery("MyLocal", "delete from PRICE_FILES where FILE_NAME='" + RadioButtonList1.SelectedValue.ToString.Trim.ToUpper + "_PriceList" + "'")
                Dim Add_query As New StringBuilder
                Add_query.AppendFormat(" INSERT INTO [PRICE_FILES]([ROW_ID],[File_Name],[File_Ext],[File_Size],[File_Data] ,[Last_Updated] ,[Last_Updated_By]) ")
                Add_query.AppendFormat(" Values('{0}','{1}','{2}','{3}',@img,'{4}','{5}')", _
                                       Util.NewRowId("PRICE_FILES", "MyLocal"), RadioButtonList1.SelectedValue.ToString.Trim.ToUpper + "_PriceList", strFileExt.ToUpper.Replace("'", "''"), _
                                       strFile_Size, Now(), Session("user_id"))
                Dim sqlConn As New SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
                Dim sqlComm As New SqlCommand(Add_query.ToString, sqlConn)
                sqlComm.Parameters.Add("@img", SqlDbType.Image) '添加参数
                sqlComm.Parameters("@img").Value = fileData '为参数赋值
                sqlConn.Open()
                sqlComm.ExecuteNonQuery()
                sqlConn.Close()
                ''''''''''''''''              
                'Me.FileUpload1.SaveAs(Server.MapPath("/") & "\Files\" + RadioButtonList1.SelectedValue.ToString.Trim.ToUpper + "_PriceList.xls")
                Label1.Text = "The file is uploaded successfully."
            Else
                Label1.Text = "The file is not correct format."
            End If
        Else
            Label1.Text = "Please select a file."
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

  <h2>Upload excel file of Pricelist</h2>
    <table width="40%" border="0" align="center">
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td  align="left">
        <asp:FileUpload ID="FileUpload1" runat="server" />
    </td>
    <td>
        <asp:RadioButtonList ID="RadioButtonList1" runat="server" RepeatDirection="Horizontal">
            <asp:ListItem Value="AAC">AAC</asp:ListItem>
            <asp:ListItem Value="AENC">AENC</asp:ListItem>
            <asp:ListItem Value="Arrow">Arrow</asp:ListItem><%--ICC 2015/10/30 Add Arrow listitem--%>
        </asp:RadioButtonList>
    </td>
    <td>
        <asp:Button ID="Button1" runat="server" Text="Upload" OnClick="Button1_Click" />
    </td>
  </tr>
  <tr>
    <td align="left" colspan="3">
        <asp:Label ID="Label1" runat="server" Text="" Font-Size="12PX" ForeColor="Red"></asp:Label>
    </td>
  </tr>
</table>
       

   
</asp:Content>

