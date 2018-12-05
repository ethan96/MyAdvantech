<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

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

    Public Shared Function GetCBOMCatalogTreeByRootId(RootId As String) As List(Of CBOM_CATALOG_RECORD)
        Dim dtCatalogTree As DataTable = dbUtil.dbGetDataTable("MYLOCAL",
                " select ROW_ID, CAST(a.HIE_ID as nvarchar(100)) as HIE_ID,  " +
                " IsNull(cast(a.HIE_ID.GetAncestor(1) as nvarchar(100)),'') as PAR_HIE_ID,  " +
                " a.CATALOG_NAME, a.CATALOG_TYPE, a.SEQ_NO, a.EXT_DESC, a.SECTOR, a.HIE_ID.GetLevel() as LEVEL " +
                " from CBOM_CATALOG_V2 a  " +
                " where a.HIE_ID.IsDescendantOf( " +
                " 	( " +
                " 		select z.HIE_ID  " +
                " 		from CBOM_CATALOG_V2 z  " +
                " 		where z.ROW_ID='" + Trim(RootId).Replace("'", "''") + "' and cast(z.HIE_ID.GetAncestor(1) as nvarchar(100))='/' " +
                " 	) " +
                " )=1 ")

        Dim CBOMCatalogRecords = Util.DataTableToList(Of CBOM_CATALOG_RECORD)(dtCatalogTree)
        Return CBOMCatalogRecords
    End Function

    Sub CBOMCatalogRecordsToEasyUITreeNode(ByRef CBOMCatalogRecords As List(Of CBOM_CATALOG_RECORD), ByRef CurrentNode As EasyUITreeNode)
        Dim CurrentNodeHieId = CurrentNode.HieId
        Dim SubRecords = From q In CBOMCatalogRecords Where q.PAR_HIE_ID = CurrentNodeHieId Order By q.SEQ_NO
        For Each SubRecord In SubRecords
            Dim SubTreeNode As New EasyUITreeNode(SubRecord.ROW_ID, SubRecord.CATALOG_NAME)
            SubTreeNode.HieId = SubRecord.HIE_ID
            SubTreeNode.attributes.type = SubRecord.CATALOG_TYPE
            CurrentNode.children.Add(SubTreeNode)
            CBOMCatalogRecordsToEasyUITreeNode(CBOMCatalogRecords, SubTreeNode)
        Next

    End Sub


    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Request("RootId") IsNot Nothing Then
            Dim TreeNodes As New List(Of EasyUITreeNode)
            Dim CBOMCatalogRecords = GetCBOMCatalogTreeByRootId(Request("RootId"))
            Dim RootRecord = From q In CBOMCatalogRecords Where q.LEVEL = 1 Take 1

            If RootRecord.Count = 1 Then
                Dim RootTreeNode As New EasyUITreeNode(RootRecord.First.ROW_ID, RootRecord.First.CATALOG_NAME)
                RootTreeNode.HieId = RootRecord.First.HIE_ID
                CBOMCatalogRecordsToEasyUITreeNode(CBOMCatalogRecords, RootTreeNode)
                For Each child In RootTreeNode.children
                    TreeNodes.Add(child)
                Next
            End If


            Response.Clear()
            Response.Write(jsr.Serialize(TreeNodes))
            Response.End()
        End If

        If Not Page.IsPostBack Then
            If User.Identity.Name.ToLower().EndsWith("@advantech.com.cn") Then
                Me.hdOrgCatalogId.Value = "B1FBCC6845"  'ACN
            Else
                Me.hdOrgCatalogId.Value = "D78A390AD4"  'AEU
            End If

        End If

    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/icon.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/demo.css">
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <asp:HiddenField runat="server" ID="hdOrgCatalogId" Value="" />
    <table width="100%">
        <tr>
            <td></td>
        </tr>
        <tr>
            <td>
                <ul id="CatalogTree" style="width:80%">
                </ul>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        $(document).ready(
            function () {
                $('#CatalogTree').tree(
                {
                    dnd: false,
                    onClick: function (node) {
                        //selectedNode = node; $('#txtSelectedCatalogName').val(node.text);
                        //console.log("type is:"+node.attributes.type);
                        if (node.attributes.type == 2) {
                            //window.location.href = '<%=Util.GetRuntimeSiteUrl()%>/Order/Configurator.aspx?BTOItem=' + node.text;
                            window.open('<%=Util.GetRuntimeSiteUrl()%>/Order/Configurator.aspx?BTOItem=' + node.text, '_blank');
                        }
                    },
                    url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>?RootId=' + $("#<%=hdOrgCatalogId.ClientID%>").val()
                }
                );
            }
        );
    </script>
</asp:Content>
