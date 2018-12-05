Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class CBOMV2_Editor
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloKittyClock() As String
        Return "Hello Kitty! It is now " + Now.ToLongTimeString()
    End Function

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True)> _
    Public Sub InitializeTree()
        HttpContext.Current.Response.Clear()
        HttpContext.Current.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.InitializeTree(HttpContext.Current.Request("RootID").ToString, HttpContext.Current.Request("ORG_ID").ToString))
        HttpContext.Current.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddComponent(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, IsExpand As String, IsDefault As String, OrgID As String, ConfigurationRule As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddComponent(ParentGUID, CategoryID, CategoryNote, CategoryType, IsExpand, IsDefault, OrgID, ConfigurationRule))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddSharedComponent(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, IsExpand As String, IsDefault As String, OrgID As String, ConfigurationRule As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddSharedComponent(ParentGUID, CategoryID, CategoryNote, CategoryType, IsExpand, IsDefault, OrgID, ConfigurationRule))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CopySharedComponent(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, IsExpand As String, IsDefault As String, SharedGUID As String, OrgID As String, ConfigurationRule As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CopySharedComponent(ParentGUID, CategoryID, CategoryNote, CategoryType, IsExpand, IsDefault, SharedGUID, OrgID, ConfigurationRule))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddCategory(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, CategoryQty As String, IsExpand As String, IsRequired As String, OrgID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddCategory(ParentGUID, CategoryID, CategoryNote, CategoryType, CategoryQty, IsExpand, IsRequired, OrgID))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddSharedCategory(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, CategoryQty As String, IsExpand As String, IsRequired As String, OrgID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddSharedCategory(ParentGUID, CategoryID, CategoryNote, CategoryType, CategoryQty, IsExpand, IsRequired, OrgID))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CopySharedCategory(ParentGUID As String, CategoryID As String, CategoryNote As String, CategoryType As String, CategoryQty As String, IsExpand As String, IsRequired As String, SharedGUID As String, OrgID As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CopySharedCategory(ParentGUID, CategoryID, CategoryNote, CategoryType, CategoryQty, IsExpand, IsRequired, SharedGUID, OrgID))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub UpdateSelectedNode(GUID As String, CategoryID As String, Desc As String, Type As String, Qty As String, isExpand As String, isRequired As String, isDefault As String, ConfigurationRule As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.UpdateSelectedNode(GUID, CategoryID, Desc, Type, Qty, isExpand, isRequired, isDefault, ConfigurationRule))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DeleteNode(GUID As String, NodeType As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DeleteNode(GUID, NodeType))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DropTreeNode(parentid As String, parenttype As String, currentid As String, currentseq As String, targetid As String, targetseq As String, point As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DropTreeNode(parentid, parenttype, currentid, currentseq, targetid, targetseq, point))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub ReOrderByAlphabetical(GUID As String, NodeType As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.ReOrderByAlphabetical(GUID, NodeType))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub ReOrderBySeq(ParentGUID As String, ParentNodeType As String)
        Context.Response.Clear()
        Context.Response.Write(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.ReOrderBySeq(ParentGUID, ParentNodeType))
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub InitialProductCompatibility()
        Dim dt As DataTable = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibility()
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(IIf(dt.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(dt), Nothing)))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CreateProductCompatibility(ByVal PartNo1 As String, ByVal PartNo2 As String, ByVal Relation As String, ByVal Reason As String)
        If String.IsNullOrWhiteSpace(PartNo1) Or String.IsNullOrWhiteSpace(PartNo2) Then
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "Please input data.", Key .NewData = Nothing}))
        Else
            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateProductCompatibility(PartNo1, PartNo2, Relation, Reason, Context.User.Identity.Name)
            Dim newData As New DataTable()
            If result.Item1 = True Then newData = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibility()
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = IIf(newData.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(newData), Nothing)}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DeleteProductCompatibility(ByVal ID As Integer)
        Dim sid As Integer = 0
        Integer.TryParse(ID.ToString(), sid)
        Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DeleteProductCompatibility(sid)
        If result.Item1 = True Then
            Dim dt As DataTable = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibility()
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = IIf(dt.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(dt), Nothing)}))
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddProjectCatelogCategory(ByVal companyID As String, ByVal partNo As String, ByVal memo As String)
        If Not String.IsNullOrWhiteSpace(companyID) AndAlso Not String.IsNullOrWhiteSpace(partNo) Then
            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddProjectCatelogCategory(companyID.Trim(), partNo.Trim(), memo.Trim(), Context.User.Identity.Name.ToString())
            If result.Item1 = True Then
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.InitialProjectCatalogCategory(companyID.Trim())}))
            Else
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Nothing}))
            End If
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "Empty data", Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub InitialProjectCatalogCategory(ByVal companyID As String)
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.InitialProjectCatalogCategory(companyID.Trim())))
        Context.Response.End()
    End Sub
    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub DeleterProjectCatalogCategory(ByVal ID As String, ByVal companyID As String)
        If Not String.IsNullOrWhiteSpace(ID) Then
            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DeleterProjectCatalogCategory(ID)
            If result.Item1 = True Then
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.InitialProjectCatalogCategory(companyID.Trim())}))
            Else
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Nothing}))
            End If
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "ID is wrong", Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub

    'This region is just for TW temporarily use
    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub InitialProductCompatibilityTW()
        Dim dt As DataTable = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibilityTW()
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(IIf(dt.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(dt), Nothing)))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CreateProductCompatibilityTW(ByVal PartNo1 As String, ByVal PartNo2 As String, ByVal Relation As String, ByVal Reason As String)
        If String.IsNullOrWhiteSpace(PartNo1) Or String.IsNullOrWhiteSpace(PartNo2) Then
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "Please input data.", Key .NewData = Nothing}))
        Else
            Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateProductCompatibilityTW(PartNo1, PartNo2, Relation, Reason, Context.User.Identity.Name)
            Dim newData As New DataTable()
            If result.Item1 = True Then newData = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibilityTW()
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = IIf(newData.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(newData), Nothing)}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub DeleteProductCompatibilityTW(ByVal ID As Integer)
        Dim sid As Integer = 0
        Integer.TryParse(ID.ToString(), sid)
        Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DeleteProductCompatibilityTW(sid, Context.User.Identity.Name)
        If result.Item1 = True Then
            Dim dt As DataTable = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetProductCompatibilityTW()
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = IIf(dt.Rows.Count > 0, Util.DataTableToList(Of Advantech.Myadvantech.DataAccess.ProductCompatibility)(dt), Nothing)}))
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub GetAssignedCTOS(ByVal ERPID As String)
        Dim masters As List(Of Advantech.Myadvantech.DataAccess.AssignedCTOS_Master)
        If Context.Request.IsAuthenticated = True AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom")) Then
            masters = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetAssignedCTOSfromCompanyID(Session("org_id_cbom").ToString, ERPID.ToUpper)
        Else
            masters = New List(Of Advantech.Myadvantech.DataAccess.AssignedCTOS_Master)()
        End If
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(masters))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub DeleteAssignedCTOS(ByVal ROW_IDs As String)

        Dim _ROW_IDs As String() = Newtonsoft.Json.JsonConvert.DeserializeObject(Of String())(ROW_IDs)

        If _ROW_IDs IsNot Nothing AndAlso _ROW_IDs.Count > 0 Then
            For Each _id As String In _ROW_IDs
                Dim rowID As Integer = 0
                If Integer.TryParse(_id, rowID) = True AndAlso rowID > 0 Then
                    Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.DeleteAssignedCTOS(rowID)
                End If
            Next
        End If

        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = True, Key .Message = "Delete CTOS Visibility setting successfully", Key .NewData = Nothing}))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub AddCBOMVisibilityCompanyID(ByVal companyID As String, ByVal categoryid As String)

        If Not String.IsNullOrWhiteSpace(companyID) AndAlso Not String.IsNullOrWhiteSpace(categoryid) Then
            Dim _erpidlist As New List(Of String)
            _erpidlist.Add(companyID)
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddAssignedCTOS(_erpidlist, categoryid, Context.User.Identity.Name.ToString())
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = True, Key .Message = companyID, Key .NewData = Nothing}))

            'If result.Item1 = True Then
            '    Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.InitialProjectCatalogCategory(companyID.Trim())}))
            'Else
            '    Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = result.Item2, Key .NewData = Nothing}))
            'End If
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "Empty data", Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)>
    Public Sub UploadCBOMVisibilityByExcel()

        Dim UserID As String = Context.User.Identity.Name.ToString()
        Dim CategoryID As String = Context.Request.Form("CategoryID").ToString

        If Not String.IsNullOrEmpty(UserID) AndAlso Not String.IsNullOrEmpty(CategoryID) AndAlso Context.Request.Files IsNot Nothing AndAlso Context.Request.Files.Count > 0 Then
            Dim file As System.IO.Stream = Context.Request.Files(0).InputStream
            Dim dtUpload As DataTable = Util.ExcelFile2DataTable(file, 0, 0)

            Dim CompanyIDs As New List(Of String)
            If dtUpload IsNot Nothing AndAlso dtUpload.Rows.Count > 0 Then
                For Each d As DataRow In dtUpload.Rows
                    If d(0) IsNot Nothing AndAlso Not String.IsNullOrEmpty(d(0).ToString) Then
                        CompanyIDs.Add("'" + d(0).ToString + "'")
                    End If
                Next
            Else
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "No records to be uploaded in file.", Key .NewData = Nothing}))
                Context.Response.End()
                Return
            End If

            Dim dtSAP As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select COMPANY_ID from SAP_DIMCOMPANY WHERE COMPANY_ID IN ({0})", String.Join(", ", CompanyIDs.ToArray)))
            If dtSAP IsNot Nothing AndAlso dtSAP.Rows.Count > 0 Then
                CompanyIDs = New List(Of String)
                For Each d As DataRow In dtSAP.Rows
                    If d("COMPANY_ID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(d("COMPANY_ID").ToString) Then
                        CompanyIDs.Add(d("COMPANY_ID").ToString)
                    End If
                Next
                Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.AddAssignedCTOS(CompanyIDs, CategoryID, UserID)
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = True, Key .Message = "Successfully uploaded.", Key .NewData = Nothing}))
            Else
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "No valid IDs to be uploaded in file.", Key .NewData = Nothing}))
                Context.Response.End()
                Return
            End If
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = "No file to be uploaded.", Key .NewData = Nothing}))
        End If
        Context.Response.End()
    End Sub


End Class