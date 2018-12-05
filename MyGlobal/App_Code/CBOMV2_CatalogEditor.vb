Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class CBOMV2_CatalogEditor
     Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloWorld() As String
        Return "Hello World"
    End Function

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True)> _
    Public Sub InitializeTree()
        HttpContext.Current.Response.Clear()
        HttpContext.Current.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.InitializeTree(HttpContext.Current.Request("ORG_ID").ToString))
        HttpContext.Current.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub AddComponent(ParentGUID As String, CategoryID As String, CategoryNote As String, OrgID As String, UserID As String, CategoryGUID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.AddNew(ParentGUID, CategoryID, CategoryNote, OrgID, Advantech.Myadvantech.DataAccess.CategoryTypes.Component, UserID, CategoryGUID))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddCategory(ParentGUID As String, CategoryID As String, CategoryNote As String, OrgID As String, UserID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.AddNew(ParentGUID, CategoryID, CategoryNote, OrgID, Advantech.Myadvantech.DataAccess.CategoryTypes.Category, UserID, ""))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub UpdateSelectedNode(GUID As String, CategoryID As String, Desc As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.UpdateSelectedNode(GUID, CategoryID, Desc))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DeleteNode(GUID As String, NodeType As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.DeleteNode(GUID, NodeType))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DropTreeNode(parentid As String, currentid As String, currentseq As String, targetid As String, targetseq As String, point As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.DropTreeNode(parentid, currentid, currentseq, targetid, targetseq, point))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub ReOrderByAlphabetical(GUID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.ReOrderByAlphabetical(GUID))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub ReOrderBySeq(GUID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_CatalogEditorDAL.ReOrderBySeq(GUID))
    End Sub

End Class