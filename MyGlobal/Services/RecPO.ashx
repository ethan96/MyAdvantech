<%@ WebHandler Language="VB" Class="RecPO" %>

Imports System
Imports System.Web

Public Class RecPO : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("POData") IsNot Nothing Then
            Dim strInput = context.Request("POData")
            Dim jsr As New Script.Serialization.JavaScriptSerializer()
            Dim Input = jsr.Deserialize(Of InputParameters)(strInput)
            context.Response.Write("PO data received successfully.")
        End If
    End Sub

    Public Class InputParameters
        Public Property Vendor_SONO As String : Public Property Advantech_PONO As String
        Public Property OrderDate As Date : Public Property VendorPN As String
        Public Property SerialNumbers As List(Of SNRecord)
        Public Sub New()
            SerialNumbers = New List(Of SNRecord)
        End Sub
    End Class

    Public Class SNRecord
        Public Property SN As String
        Public Sub New(SN As String)
            Me.SN = SN
        End Sub
        Public Sub New()

        End Sub
    End Class

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class