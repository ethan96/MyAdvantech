<%@ WebHandler Language="VB" Class="ModelLit" %>

Imports System
Imports System.Web
Imports System.Data.SqlClient

Public Class ModelLit : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        'context.Response.ContentType = "text/plain"
        'context.Response.Write("Hello World")
        
        Dim _ModelID As String = context.Request("ModelID"), _LitType As String = context.Request("LitType"), _LangId As String = context.Request("LangId")
        
        'url 1
        Dim _GlobalDownLoadturl = "http://downloadt.advantech.com/download/downloadlit.aspx?LIT_ID="
        
        If String.IsNullOrEmpty(_ModelID) OrElse String.IsNullOrEmpty(_LitType) Then
            context.Response.Redirect(_GlobalDownLoadturl)
        End If
        
        If String.IsNullOrEmpty(_LangId) Then _LangId = "ENU"
        
        Dim _SQL As New StringBuilder
        With _SQL
            .Append(" Select Top 1 a.Model_Name, c.Siebel_FileName, c.Literature_ID, c.LIT_TYPE, c.FILE_NAME, c.FILE_EXT ")
            .Append(" From Model a left join Model_lit b on a.Model_Name=b.model_name ")
            .Append(" left join Literature c on b.literature_id=c.literature_id ")
            .Append(" Where a.MODEL_ID=@MODEL_ID ")
            .Append(" And c.LIT_TYPE=@LIT_TYPE ")
            .Append(" And c.LANG=@LANG ")
            .Append(" Order by c.LAST_UPDATED Desc ")
        End With
        
        Dim apt As New SqlDataAdapter(_SQL.ToString, _
        New SqlConnection(ConfigurationManager.ConnectionStrings("PIS").ConnectionString))
        apt.SelectCommand.Parameters.AddWithValue("MODEL_ID", _ModelID)
        apt.SelectCommand.Parameters.AddWithValue("LIT_TYPE", _LitType)
        apt.SelectCommand.Parameters.AddWithValue("LANG", _LangId)
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        _SQL = Nothing
        
        Dim _Model_Name As String = String.Empty, _Siebel_FileName As String = String.Empty, _LitID As String = String.Empty
        Dim _File_Name As String = String.Empty, _File_EXT As String = String.Empty
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            _Model_Name = dt.Rows(0).Item("Model_Name") : _Siebel_FileName = dt.Rows(0).Item("Siebel_FileName")
            _LitID = dt.Rows(0).Item("Literature_ID") : _File_Name = dt.Rows(0).Item("FILE_NAME")
            _File_EXT = dt.Rows(0).Item("FILE_EXT")
        Else
            context.Response.Redirect(_GlobalDownLoadturl)
        End If
        
        'Frank: Linking literature url
        'Sample : http://downloadt.advantech.com/ProductFile/PIS/DPX-E105/Product%20-%20Datasheet/DPX-E105_DS20110916181903.pdf
        Dim _url As New StringBuilder
        If String.IsNullOrEmpty(_Siebel_FileName) Then
            _url.Append("http://downloadt.advantech.com/ProductFile/PIS/")
            _url.Append(HttpUtility.HtmlEncode(_Model_Name) & "/")
            _url.Append(_LitType & "/")
            _url.Append(_File_Name & "." & _File_EXT)
        Else
            _url.Append(_GlobalDownLoadturl)
            _url.Append(_LitID)
        End If
        If _File_EXT.Equals("pdf", StringComparison.InvariantCultureIgnoreCase) Then
            context.Response.ContentType = "application/pdf"
        Else
            context.Response.ContentType = "application/jpeg"
        End If
        context.Response.Redirect(_url.ToString)
        
        
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class