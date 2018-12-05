<%@ WebHandler Language="VB" Class="CPLogo" %>

Imports System
Imports System.Web

Public Class CPLogo : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("ERPID") IsNot Nothing AndAlso .Request("ERPID") <> "" Then
                Dim bs() As Byte = dbUtil.dbExecuteScalar("RFM", _
                String.Format("select top 1 logo_img from sap_company_logo where company_id='{0}' and logo_img is not null", Replace(Trim(.Request("ERPID")), "'", "''")))
                If bs IsNot Nothing AndAlso bs.Length > 0 Then
                    .Response.ContentType = "image/" + .Request("ERPID") + ".GIF"
                    .Response.BinaryWrite(bs)
                    .Response.End()
                Else
                    .Response.Redirect("http://www.advantech.eu/images/logo_advantech.gif")
                End If
            End If
        End With
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class