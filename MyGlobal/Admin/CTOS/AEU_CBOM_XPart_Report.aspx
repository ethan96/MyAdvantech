<%@ Page Language="VB" %>

<!DOCTYPE html>

<script runat="server">

    Public Class XPartStatus
        Public Property PART_NO As String : Public Property STATUS As String
        Public Sub New(PN As String)
            PART_NO = Trim(PN).ToUpper() : STATUS = ""
        End Sub
        Public Sub New()
            PART_NO = "" : STATUS = ""
        End Sub
    End Class
    
    Protected Sub Page_Load(sender As Object, e As EventArgs)
        
        Dim ObsoleteXPartList = Util.DataTableToList(Of XPartStatus)( _
            dbUtil.dbGetDataTable("MY", "select PART_NO, STATUS from SAP_PRODUCT_ORG where ORG_ID='EU10' and PART_NO like 'X%' and STATUS in ('O','I')"))
        
        Dim XCBOMDt As New DataTable, sqlBOM = _
        " with cteCBOM (CATEGORY_ID, PARENT_CATEGORY_ID, CATEGORY_TYPE, SEQ_NO, CONFIGURATION_RULE, DEFAULT_FLAG, DEPTH, HIERARCHY, BTO)  " + _
        " as " + _
        " ( " + _
        "     select CATEGORY_ID, PARENT_CATEGORY_ID, CATEGORY_TYPE, SEQ_NO,CONFIGURATION_RULE, isnull(DEFAULT_FLAG,0) as DEFAULT_FLAG, 0 as DEPTH, cast(CATEGORY_ID as nvarchar(max)) as HIERARCHY, CATEGORY_ID as BTO " + _
        "     from MyAdvantechGlobal.dbo.CBOM_CATALOG_CATEGORY  " + _
        "     where PARENT_CATEGORY_ID='Root' and ORG='EU' and CATEGORY_ID like '%-BTO' " + _
        "     union all " + _
        "     select a.CATEGORY_ID, a.PARENT_CATEGORY_ID, a.CATEGORY_TYPE, a.SEQ_NO, a.CONFIGURATION_RULE, a.DEFAULT_FLAG, b.DEPTH+1 as DEPTH, cast(b.HIERARCHY+'->'+a.CATEGORY_ID as nvarchar(max)) as HIERARCHY, b.BTO " + _
        "     from MyAdvantechGlobal.dbo.CBOM_CATALOG_CATEGORY a inner join cteCBOM b on a.PARENT_CATEGORY_ID=b.CATEGORY_ID " + _
        "     where a.PARENT_CATEGORY_ID=b.CATEGORY_ID and a.ORG='EU' and a.CATEGORY_ID<>a.PARENT_CATEGORY_ID " + _
        " ) " + _
        " select distinct CATEGORY_ID, BTO " + _
        " from cteCBOM  " + _
        " where CATEGORY_TYPE='Component' and (CATEGORY_ID like 'X%' or CATEGORY_ID like '%|X%') " + _
        " order by CATEGORY_ID, BTO "
        Dim apt As New SqlClient.SqlDataAdapter(sqlBOM, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.CommandTimeout = 99999
        apt.Fill(XCBOMDt)
        apt.SelectCommand.Connection.Close()
        
        For Each XBOMRow As DataRow In XCBOMDt.Rows
            Dim FoundXPNs As New List(Of XPartStatus)
            Dim parts = Split(XBOMRow.Item("CATEGORY_ID"), "|")
            For Each Part In parts
                If Part.StartsWith("X", StringComparison.CurrentCultureIgnoreCase) Then
                    Part = Trim(Part).ToUpper()
                    Dim isExist = From q In FoundXPNs Where String.Equals(Part, q.PART_NO, StringComparison.CurrentCultureIgnoreCase)
                                  
                    If isExist.Count = 0 Then
                        Dim IsObsolete = From q In ObsoleteXPartList Where String.Equals(q.PART_NO, Part, StringComparison.CurrentCultureIgnoreCase)
                        If IsObsolete.Count = 0 Then
                            FoundXPNs.Add(New XPartStatus(Part))
                            Dim XPNCol = "XPN" + FoundXPNs.Count.ToString()
                            If Not XCBOMDt.Columns.Contains(XPNCol) Then XCBOMDt.Columns.Add(XPNCol)
                            XBOMRow.Item(XPNCol) = Part
                        End If
                    End If
                End If
            Next
        Next
        
        Util.DataTable2ExcelDownload(XCBOMDt, "AEU_CBOM_XPart.xls")
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
