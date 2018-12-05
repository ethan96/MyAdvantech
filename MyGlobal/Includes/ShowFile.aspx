<%@ Page Title="MyAdvantech - Download File" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
 Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("File_ID") IsNot Nothing AndAlso Request("File_ID").ToString() <> "" Then
            Dim strFID As String = Request("File_ID").ToString().Trim()
            Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
            " SELECT top 1 Source_ID, Source, File_Category, File_ID, File_Name, File_Desc, " + _
            " File_Ext, File_Size, File_Status, Last_Updated, Last_Updated_By, File_Data, File_Answer " + _
            " FROM AGS_Upload_Files where File_ID='{0}' and File_Data is not null and File_Name<>'' and File_Ext<>'' ", _
            Replace(strFID, "'", "''")))
            If fdt.Rows.Count = 1 Then
                Dim r As DataRow = fdt.Rows(0)
                Dim FileNameFull As String = ""
                Dim FileContainName As String = ""
                FileNameFull = r.Item("File_Name") + "." + r.Item("File_Ext")
                FileContainName = strFID + "." + r.Item("File_Ext")
                If r.Item("File_Ext").ToString.ToLower = "pdf" Then
                    Response.AddHeader("content-type", "application/pdf;")
                Else
                    Response.AddHeader("content-type", "image/jpg;")
                End If
               
                Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(FileNameFull)))
                Response.AddHeader("content-length", r.Item("File_Size"))
                Response.BinaryWrite(r.Item("File_Data"))
                Response.End()
            Else
                Util.JSAlert(Me.Page, "Cannot find this document on server")
            End If
        End If
        If Request("ROW_ID") IsNot Nothing AndAlso Request("ROW_ID").ToString() <> "" Then
            Dim strFID As String = Request("ROW_ID").ToString().Trim()
            Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
            " SELECT top 1 IMG_DATA AS File_Data " + _
            " FROM CBOM_CATALOG_IMAGES where ROW_ID='{0}' and IMG_DATA is not null  ", _
            Replace(strFID, "'", "''")))
            If fdt.Rows.Count = 1 Then
                Dim r As DataRow = fdt.Rows(0)
                Dim FileNameFull As String = ""
                FileNameFull = "showimage" + "." + "jpg"
                Response.AddHeader("content-type", "image/jpg;")
                Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(FileNameFull)))
                'Response.AddHeader("content-length", r.Item("File_Size"))
                Response.BinaryWrite(r.Item("File_Data"))
                Response.End()

            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
</asp:Content>