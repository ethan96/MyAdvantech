
Partial Class Lab_CBOMV2_CBOM_Catalog_Admin
    Inherits System.Web.UI.Page

    Public Shared jsr As New Script.Serialization.JavaScriptSerializer()

    Public Class EasyUITreeNode
        Public Property id As String : Public Property text As String : Private _state As treeStates : Public HieId As String
        Public WriteOnly Property SetState As treeStates
            Set(value As treeStates)
                Me._state = value
            End Set
        End Property

        Public ReadOnly Property state As String
            Get
                Return Me._state.ToString()
            End Get
        End Property

        Public attributes As CustomAttibutes

        Public Property children As List(Of EasyUITreeNode)

        Public Enum treeStates
            open
            closed
        End Enum

        Public Sub New()
            id = "" : text = "" : _state = treeStates.open : Me.children = New List(Of EasyUITreeNode) : Me.attributes = New CustomAttibutes()
        End Sub

        Public Sub New(id As String, text As String)
            Me.id = id : Me.text = text : Me.children = New List(Of EasyUITreeNode) : Me.attributes = New CustomAttibutes()
        End Sub
    End Class
    Public Class CBOM_CATALOG_RECORD
        Public Property ROW_ID As String : Public Property HIE_ID As String : Public Property PAR_HIE_ID As String : Public Property CATALOG_NAME As String
        Public Property CATALOG_TYPE As CatalogTypes : Public Property SEQ_NO As Integer : Public Property EXT_DESC As String
        Public Property SECTOR As String : Public Property LEVEL As Integer
    End Class

    Public Enum CatalogTypes As Integer
        Root = 0
        Catalog = 1
        BTO = 2
    End Enum

    Public Class CustomAttibutes
        Public Property type As String : Public Property seqno As Integer : Public ispromo As Boolean
        Public Sub New()
            type = "" : seqno = -1 : ispromo = False
        End Sub
    End Class


    Public Class DropNodeData
        Public Property id As String : Public Property targetId As String : Public Property point As String
    End Class

    Public Class UpdateTreeException
        Inherits Exception
        Public Sub New(ErrMsg As String)
            MyBase.New(ErrMsg)
        End Sub
    End Class


    Public Class UpdateCatalogDbResult
        Public Property IsUpdated As Boolean : Public Property ServerMessage As String : Public Property NewNodeRowId As String
        Public Sub New()
            IsUpdated = True : ServerMessage = "" : NewNodeRowId = ""
        End Sub
    End Class

    Public Class BTOSPN
        : Public Property id As String : Public Property name As String
    End Class

    Shared Sub Reparent(srcid As String, targetId As String)
        Dim ReparentSql As String = _
        " DECLARE @OldParent hierarchyid, @NewParent hierarchyid, @NodeToBeMoved hierarchyid " + vbCrLf + _
        " SELECT @NewParent = HIE_ID FROM CBOMV2.dbo.CBOM_CATALOG_V2 WHERE ROW_ID = '" + targetId + "' ;  " + vbCrLf + _
        " select @NodeToBeMoved=HIE_ID FROM CBOMV2.dbo.CBOM_CATALOG_V2 WHERE ROW_ID = '" + srcid + "'; " + vbCrLf + _
        " select @OldParent=@NodeToBeMoved.GetAncestor(1); " + vbCrLf + _
        "  " + vbCrLf + _
        " DECLARE children_cursor CURSOR FOR " + vbCrLf + _
        " SELECT HIE_ID FROM CBOMV2.dbo.CBOM_CATALOG_V2 WHERE HIE_ID.IsDescendantOf(@NodeToBeMoved)=1; " + vbCrLf + _
        "  " + vbCrLf + _
        " DECLARE @ChildId hierarchyid; " + vbCrLf + _
        " OPEN children_cursor " + vbCrLf + _
        " FETCH NEXT FROM children_cursor INTO @ChildId; " + vbCrLf + _
        " WHILE @@FETCH_STATUS = 0 " + vbCrLf + _
        " BEGIN " + vbCrLf + _
        " START: " + vbCrLf + _
        "     DECLARE @NewId hierarchyid; " + vbCrLf + _
        "     SELECT @NewId = @NewParent.GetDescendant(MAX(HIE_ID), NULL) " + vbCrLf + _
        "     FROM CBOMV2.dbo.CBOM_CATALOG_V2 WHERE HIE_ID.GetAncestor(1) = @NewParent; " + vbCrLf + _
        "  " + vbCrLf + _
        "     UPDATE CBOMV2.dbo.CBOM_CATALOG_V2 " + vbCrLf + _
        "     SET HIE_ID = HIE_ID.GetReparentedValue(@ChildId, @NewId) " + vbCrLf + _
        "     WHERE HIE_ID.IsDescendantOf(@ChildId) = 1; " + vbCrLf + _
        "     IF @@error <> 0 GOTO START -- On error, retry " + vbCrLf + _
        "         FETCH NEXT FROM children_cursor INTO @ChildId; " + vbCrLf + _
        " END " + vbCrLf + _
        " CLOSE children_cursor; " + vbCrLf + _
        " DEALLOCATE children_cursor; "

        Dim reqCmd As New SqlClient.SqlCommand(ReparentSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString))

        reqCmd.Connection.Open()
        reqCmd.ExecuteNonQuery()
        reqCmd.Connection.Close()
    End Sub

    Enum DropPoints
        top
        bottom
        append
    End Enum
    Shared Sub Reorder(srcid As String, targetId As String, DropPoint As DropPoints, IsSameAncestor As Boolean)
        Dim sql As String = ""

        Select Case DropPoint
            Case DropPoints.top
                If IsSameAncestor Then
                    sql = _
                              " declare @NewSeqNo int; declare @OldSeqNo int;" + vbCrLf + _
                              " select @NewSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@TARGETID; " + vbCrLf + _
                              " select @OldSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID; " + vbCrLf + _
                              " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=@NewSeqNo where ROW_ID=@SRCID; " + vbCrLf + _
                              " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO+1  " + vbCrLf + _
                              " where SEQ_NO>=@NewSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; " +
                              " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO-1 " + vbCrLf + _
                              " where SEQ_NO>@OldSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; "
                Else
                    sql = _
                           " declare @NewSeqNo int; " + vbCrLf + _
                           " select @NewSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@TARGETID; " + vbCrLf + _
                           " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=@NewSeqNo where ROW_ID=@SRCID; " + vbCrLf + _
                           " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO+1  " + vbCrLf + _
                           " where SEQ_NO>=@NewSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; "
                End If
            Case DropPoints.bottom
                If IsSameAncestor Then
                    sql = _
                                " declare @NewSeqNo int; declare @OldSeqNo int;" + vbCrLf + _
                                " select @NewSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@TARGETID; " + vbCrLf + _
                                " select @OldSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID; " + vbCrLf + _
                                " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=@NewSeqNo where ROW_ID=@SRCID; " + vbCrLf + _
                                " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO-1  " + vbCrLf + _
                                " where SEQ_NO<=@NewSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; " +
                                " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO+1 " + vbCrLf + _
                                " where SEQ_NO<@OldSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; "
                Else
                    sql = _
                          " declare @NewSeqNo int; " + vbCrLf + _
                          " select @NewSeqNo=SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@TARGETID; " + vbCrLf + _
                          " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=@NewSeqNo+1 where ROW_ID=@SRCID; " + vbCrLf + _
                          " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO+1  " + vbCrLf + _
                          " where SEQ_NO>=@NewSeqNo and HIE_ID.GetAncestor(1)=(select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@SRCID) and ROW_ID<>@SRCID; "
                End If


            Case DropPoints.append
                sql = _
                    " update CBOMV2.dbo.CBOM_CATALOG_V2 " + _
                    " set SEQ_NO=" + _
                    "   (select isnull(MAX(SEQ_NO),-1)+1 from CBOMV2.dbo.CBOM_CATALOG_V2 where HIE_ID.GetAncestor(1)=" + _
                    "       (select HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@TARGETID) " + _
                    "   and ROW_ID<>@SRCID) where ROW_ID=@SRCID"
        End Select


        Dim cmd As New SqlClient.SqlCommand(sql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString))
        With cmd.Parameters
            .AddWithValue("SRCID", srcid) : .AddWithValue("TARGETID", targetId)
        End With
        cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
    End Sub

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function DropTreeNode(data As DropNodeData) As String
        Dim res As New UpdateCatalogDbResult()

        Dim IsSameAncestor As Integer = dbUtil.dbExecuteScalar("MyLocal", _
            " select case when a.SRCAns=a.TargetAns then 1 else 0 end as IsSameAns " + _
            " from ( " + _
            " 	select  " + _
            " 	isnull((select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID='" + data.id + "'),'/') as SRCAns, " + _
            " 	isnull((select HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID='" + data.targetId + "'),'/') as TargetAns " + _
            " ) a ")

        Select Case IsSameAncestor
            Case 0  'not the same Ancestor
                Select Case data.point
                    Case "append"
                        'reparent
                        Reparent(data.id, data.targetId)
                        'set srcnode's seqno to 0
                        Reorder(data.id, data.targetId, CType([Enum].Parse(GetType(DropPoints), data.point), DropPoints), False)
                    Case "top", "bottom"
                        'reparent, reorder seqno
                        Dim NewParentRowId As String = dbUtil.dbExecuteScalar("MyLocal", _
                                               " select ROW_ID from CBOMV2.dbo.CBOM_CATALOG_V2 " + _
                                               " where HIE_ID=(select HIE_ID.GetAncestor(1) " + _
                                               " from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID='" + data.targetId + "')")
                        Reparent(data.id, NewParentRowId)
                        Reorder(data.id, data.targetId, CType([Enum].Parse(GetType(DropPoints), data.point), DropPoints), False)
                End Select
            Case 1
                Select Case data.point
                    Case "append"
                        'reparent
                        Reparent(data.id, data.targetId)
                        'set srcnode's seqno to 0
                        Reorder(data.id, data.targetId, CType([Enum].Parse(GetType(DropPoints), data.point), DropPoints), True)
                    Case "top", "bottom"
                        'reorder seqno
                        Reorder(data.id, data.targetId, CType([Enum].Parse(GetType(DropPoints), data.point), DropPoints), True)
                End Select
        End Select
        Return jsr.Serialize(res)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function DeleteNode(NodeId As String) As String
        Dim res As New UpdateCatalogDbResult()
        Dim sqlCmd As New SqlClient.SqlCommand( _
            " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=SEQ_NO-1 " + _
            " where HIE_ID.GetAncestor(1)=(select z.HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.ROW_ID=@ROWID) " + _
            " and SEQ_NO>(select z.SEQ_NO from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.ROW_ID=@ROWID); " + _
            " update CBOMV2.dbo.CBOM_CATALOG_V2 set SEQ_NO=0 where SEQ_NO=-1 and HIE_ID.GetAncestor(1)=(select z.HIE_ID.GetAncestor(1) from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.ROW_ID=@ROWID); " + _
            " delete from CBOMV2.dbo.CBOM_CATALOG_V2 where HIE_ID.IsDescendantOf((select z.HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.ROW_ID=@ROWID))=1;", _
            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString))
        sqlCmd.Parameters.AddWithValue("ROWID", NodeId)
        sqlCmd.Connection.Open()
        sqlCmd.ExecuteNonQuery()
        sqlCmd.Connection.Close()
        Return jsr.Serialize(res)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AddSubCatalog(ParRowId As String, CatalogName As String) As String
        Dim res As New UpdateCatalogDbResult()

        If String.IsNullOrEmpty(Trim(CatalogName)) Then
            res.IsUpdated = False : res.ServerMessage = "Catalog Name cannot be empty" : Return jsr.Serialize(res)
        End If

        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        conn.Open()
        Dim cmd As New SqlClient.SqlCommand( _
            " select cast( " + _
            " 	a.HIE_ID.GetDescendant( " + _
            " 		( " + _
            " 			select max(a.HIE_ID)  " + _
            " 			from CBOMV2.dbo.CBOM_CATALOG_V2 a  " + _
            " 			where a.HIE_ID.GetAncestor(1)=(select HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@PARID) " + _
            " 		), NULL) as nvarchar(100)) " + _
            " from CBOMV2.dbo.CBOM_CATALOG_V2 a where a.ROW_ID=@PARID ", conn)
        cmd.Parameters.AddWithValue("PARID", ParRowId)
        Dim NewChildNodeId As String = cmd.ExecuteScalar().ToString()

        Dim InsertSql As String = _
            " insert into CBOMV2.dbo.CBOM_CATALOG_V2  " + _
            " (ROW_ID, HIE_ID, CATALOG_NAME, CATALOG_TYPE, SEQ_NO, EXT_DESC, SECTOR) " + _
            " values(@NEWROWID, @HID,@CNAME, 1, (select isnull(max(z.SEQ_NO),-1)+1 from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.HIE_ID.GetAncestor(1)=(select HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@PARID)), '', '') "

        cmd.CommandText = InsertSql
        Dim NewRowId = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)
        With cmd.Parameters
            .AddWithValue("HID", NewChildNodeId) : .AddWithValue("CNAME", CatalogName) : .AddWithValue("NEWROWID", NewRowId)
        End With

        cmd.ExecuteNonQuery()

        conn.Close()

        res.NewNodeRowId = NewRowId

        Return jsr.Serialize(res)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AddBTOS(ParNodeId As String, BTOS As String) As String
        Dim res As New UpdateCatalogDbResult()
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        Try
            conn.Open()
            Dim chkPnCmd As New SqlClient.SqlCommand(
                "select COUNT(PART_NO) from [ACLSTNR12].MyAdvantechGlobal.dbo.SAP_PRODUCT where PART_NO=@BPN and MATERIAL_GROUP='BTOS'", conn)
            chkPnCmd.Parameters.AddWithValue("BPN", BTOS)
            If CInt(chkPnCmd.ExecuteScalar()) = 0 Then
                Throw New Exception("Invalid BTOS Part Number:" + BTOS)
            End If

            Dim cmd As New SqlClient.SqlCommand( _
                " select cast( " + _
                " 	a.HIE_ID.GetDescendant( " + _
                " 		( " + _
                " 			select max(a.HIE_ID)  " + _
                " 			from CBOMV2.dbo.CBOM_CATALOG_V2 a  " + _
                " 			where a.HIE_ID.GetAncestor(1)=(select HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@PARID) " + _
                " 		), NULL) as nvarchar(100)) " + _
                " from CBOMV2.dbo.CBOM_CATALOG_V2 a where a.ROW_ID=@PARID ", conn)
            cmd.Parameters.AddWithValue("PARID", ParNodeId)
            Dim NewChildNodeId As String = cmd.ExecuteScalar().ToString()

            Dim InsertSql As String = _
                " insert into CBOMV2.dbo.CBOM_CATALOG_V2  " + _
                " (ROW_ID, HIE_ID, CATALOG_NAME, CATALOG_TYPE, SEQ_NO, EXT_DESC, SECTOR) " + _
                " values(@NEWROWID, @HID, @BTOS, " + CInt(CatalogTypes.BTO).ToString() + ", (select isnull(max(z.SEQ_NO),-1)+1 from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.HIE_ID.GetAncestor(1)=(select HIE_ID from CBOMV2.dbo.CBOM_CATALOG_V2 where ROW_ID=@PARID)), '', '') "
            Dim NewRowId = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)
            cmd.CommandText = InsertSql
            cmd.Parameters.AddWithValue("HID", NewChildNodeId) : cmd.Parameters.AddWithValue("BTOS", BTOS) : cmd.Parameters.AddWithValue("NEWROWID", NewRowId)
            cmd.ExecuteNonQuery()
            conn.Close()

            res.NewNodeRowId = NewRowId
        Catch ex As Exception
            conn.Close() : res.IsUpdated = False : res.ServerMessage = ex.Message
        End Try
        Return jsr.Serialize(res)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function UpdateCatalogName(NodeRowId As String, CatalogName As String) As String
        Dim res As New UpdateCatalogDbResult()

        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand("select IsNull(HIE_ID.GetLevel(),0) from CBOMV2.dbo.CBOM_CATALOG_V2 z where ROW_ID=@ROWID", conn)
        cmd.Parameters.AddWithValue("ROWID", NodeRowId)
        conn.Open()
        Try
            If String.IsNullOrEmpty(Trim(CatalogName)) Then
                Throw New UpdateTreeException("Catalog name cannot be empty.")
            End If

            If CInt(cmd.ExecuteScalar()) <= 1 Then
                Throw New UpdateTreeException("Cannot update root catalog's name.")
            End If

            cmd.CommandText = "select catalog_type from CBOMV2.dbo.CBOM_CATALOG_V2 z where z.ROW_ID=@ROWID"
            If CInt(cmd.ExecuteScalar()) = CatalogTypes.BTO Then
                Throw New UpdateTreeException("Cannot rename BTOS PN. Please delete it then add a new one.")
            End If

            cmd.CommandText = "update CBOMV2.dbo.CBOM_CATALOG_V2 set catalog_name=@CNAME where ROW_ID=@ROWID"
            cmd.Parameters.AddWithValue("CNAME", Trim(CatalogName))
            If cmd.ExecuteNonQuery() <> 1 Then
                Throw New UpdateTreeException("The catalog you are updating may no longer exists")
            End If
        Catch ex As UpdateTreeException
            res.IsUpdated = False : res.ServerMessage = ex.Message
        End Try
        conn.Close()
        Return jsr.Serialize(res)
    End Function

    Sub CBOMCatalogRecordsToEasyUITreeNode(ByRef CBOMCatalogRecords As List(Of CBOM_CATALOG_RECORD), ByRef CurrentNode As EasyUITreeNode)
        Dim CurrentNodeHieId = CurrentNode.HieId
        Dim SubRecords = From q In CBOMCatalogRecords Where q.PAR_HIE_ID = CurrentNodeHieId Order By q.SEQ_NO
        For Each SubRecord In SubRecords
            Dim SubTreeNode As New EasyUITreeNode(SubRecord.ROW_ID, SubRecord.CATALOG_NAME)
            SubTreeNode.HieId = SubRecord.HIE_ID
            CurrentNode.children.Add(SubTreeNode)
            CBOMCatalogRecordsToEasyUITreeNode(CBOMCatalogRecords, SubTreeNode)
        Next

    End Sub

    Public Shared Function GetCBOMCatalogTreeByRootId(RootId As String) As List(Of CBOM_CATALOG_RECORD)
        Dim dtCatalogTree As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _
                " select ROW_ID, CAST(a.HIE_ID as nvarchar(100)) as HIE_ID,  " + _
                " IsNull(cast(a.HIE_ID.GetAncestor(1) as nvarchar(100)),'') as PAR_HIE_ID,  " + _
                " a.CATALOG_NAME, a.CATALOG_TYPE, a.SEQ_NO, a.EXT_DESC, a.SECTOR, a.HIE_ID.GetLevel() as LEVEL " + _
                " from CBOMV2.dbo.CBOM_CATALOG_V2 a  " + _
                " where a.HIE_ID.IsDescendantOf( " + _
                " 	( " + _
                " 		select z.HIE_ID  " + _
                " 		from CBOMV2.dbo.CBOM_CATALOG_V2 z  " + _
                " 		where z.ROW_ID='" + Trim(RootId).Replace("'", "''") + "' and cast(z.HIE_ID.GetAncestor(1) as nvarchar(100))='/' " + _
                " 	) " + _
                " )=1 ")

        Dim CBOMCatalogRecords = Util.DataTableToList(Of CBOM_CATALOG_RECORD)(dtCatalogTree)
        Return CBOMCatalogRecords
    End Function
    Public Shared Function AutoSuggestBTOSPN(key As String) As List(Of BTOSPN)
        Dim dt = dbUtil.dbGetDataTable("MY", _
                                       " select top 10 PART_NO as id, PART_NO as name from SAP_PRODUCT a (nolock) " + _
                                       " where a.MATERIAL_GROUP='BTOS' and a.PART_NO like '" + Trim(key).Replace("'", "''") + "%' order by PART_NO")
        Return Util.DataTableToList(Of BTOSPN)(dt)

    End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        If Request("RootId") IsNot Nothing Then
            Dim TreeNodes As New List(Of EasyUITreeNode)
            Dim CBOMCatalogRecords = GetCBOMCatalogTreeByRootId(Request("RootId"))
            Dim RootRecord = From q In CBOMCatalogRecords Where q.LEVEL = 1 Take 1

            If RootRecord.Count = 1 Then
                Dim RootTreeNode As New EasyUITreeNode(RootRecord.First.ROW_ID, RootRecord.First.CATALOG_NAME)
                RootTreeNode.HieId = RootRecord.First.HIE_ID
                CBOMCatalogRecordsToEasyUITreeNode(CBOMCatalogRecords, RootTreeNode)
                TreeNodes.Add(RootTreeNode)

                'For i As Integer = 0 To 29
                '    RootTreeNode.children.Add(New EasyUITreeNode(i.ToString(), i.ToString()))
                'Next

            End If


            Response.Clear()
            Response.Write(jsr.Serialize(TreeNodes))
            Response.End()
        End If

        If Request("q") IsNot Nothing Then
            Dim txtKey As String = Trim(Request("q")), docs = AutoSuggestBTOSPN(txtKey)
            Dim jsr As New Script.Serialization.JavaScriptSerializer, retJson As String = jsr.Serialize(docs)
            If Request("callback") IsNot Nothing Then
                retJson = Request("callback") + "(" + retJson + ")"
            End If
            Response.Clear() : Response.Write(retJson) : Response.End()
        End If

        If Not Page.IsPostBack Then
            If User.Identity.Name.ToLower().EndsWith("@advantech.com.cn") Then
                Me.hdOrgCatalogId.Value = "B1FBCC6845"  'ACN
            Else
                Me.hdOrgCatalogId.Value = "D78A390AD4"  'AEU
            End If

        End If

    End Sub
End Class
