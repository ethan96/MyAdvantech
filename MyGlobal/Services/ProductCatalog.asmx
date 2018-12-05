<%@ WebService Language="VB" Class="ProductCatalog" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
imports AjaxControlToolkit
Imports System.Collections.Generic
Imports System.Data
Imports System.Data.SqlClient
Imports System.Web.Configuration

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
<System.Web.Script.Services.ScriptService()> _
Public Class ProductCatalog
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function getCatalog_Obsolate(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
        Return Nothing
        Dim kv As StringDictionary = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues)
        Dim sql As String = "'"
        Try
            Select Case category
                Case "Catalog"
                    sql = "SELECT DISTINCT [EGROUP] as display_name FROM [SAP_PRODUCT] WHERE [EGROUP] IS NOT NULL ORDER BY [EGROUP]"
                Case "Category"
                    sql = "SELECT DISTINCT [EDIVISION] as display_name FROM [SAP_PRODUCT] WHERE [EGROUP] = '" & kv("Catalog") & "' AND [EDIVISION] is not null order by [EDIVISION]"
            End Select
            Dim _city As List(Of CascadingDropDownNameValue) = New List(Of CascadingDropDownNameValue)()
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
            For Each row As DataRow In dt.Rows
                _city.Add(New CascadingDropDownNameValue(row("DISPLAY_NAME").ToString(), row("DISPLAY_NAME").ToString()))
            Next
            Return _city.ToArray()
            
            'Select Case category
            '    Case "Catalog"
            '        sql = "SELECT [CATEGORY_ID], DISPLAY_NAME from v_SIEBEL_CATALOG_CATEGORY where PARENT_CATEGORY_ID='root' and CATALOGID in ('1-2JKBQD','1-2MLAX2')"
            '    Case "Category"
            '        sql = "SELECT [CATEGORY_ID], [DISPLAY_NAME] FROM [v_SIEBEL_CATALOG_CATEGORY] WHERE [PARENT_CATEGORY_ID] = '" & kv("Catalog") & "' AND [ACTIVE_FLG] = 'Y' AND [CATEGORY_TYPE] = '" & category & "' ORDER BY SEQ_NO"
            '    Case "SubCategory"
            '        sql = "SELECT [CATEGORY_ID], [DISPLAY_NAME] FROM [v_SIEBEL_CATALOG_CATEGORY] WHERE [PARENT_CATEGORY_ID] = '" & kv("Category") & "' AND [ACTIVE_FLG] = 'Y' AND [CATEGORY_TYPE] is not null ORDER BY SEQ_NO"
            '    Case "SubCategory2"
            '        sql = "SELECT [CATEGORY_ID], [DISPLAY_NAME] FROM [v_SIEBEL_CATALOG_CATEGORY] WHERE [PARENT_CATEGORY_ID] = '" & kv("SubCategory") & "' AND [ACTIVE_FLG] = 'Y' AND [CATEGORY_TYPE] is not null ORDER BY SEQ_NO"
            '    Case "SubCategory3"
            '        sql = "SELECT [CATEGORY_ID], [DISPLAY_NAME] FROM [v_SIEBEL_CATALOG_CATEGORY] WHERE [PARENT_CATEGORY_ID] = '" & kv("SubCategory2") & "' AND [ACTIVE_FLG] = 'Y' AND [CATEGORY_TYPE] is not null ORDER BY SEQ_NO"
            '    Case "Model"
            '        sql = "SELECT [CATEGORY_ID], [DISPLAY_NAME] FROM [v_SIEBEL_CATALOG_CATEGORY] WHERE [PARENT_CATEGORY_ID] = '" & kv("SubCategory3") & "' AND [ACTIVE_FLG] = 'Y' AND [CATEGORY_TYPE] = 'Model' ORDER BY SEQ_NO"
            '    Case Else
            '        sql = "SELECT [CATEGORY_ID], DISPLAY_NAME from v_SIEBEL_CATALOG_CATEGORY where PARENT_CATEGORY_ID='root' and CATALOGID in ('1-2JKBQD','1-2MLAX2')"
            'End Select
            
            'Dim _city As List(Of CascadingDropDownNameValue) = New List(Of CascadingDropDownNameValue)()
            'Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", sql)
            'For Each row As DataRow In dt.Rows
            '    _city.Add(New CascadingDropDownNameValue(row("DISPLAY_NAME").ToString(), row("CATEGORY_ID").ToString()))
            'Next
            'Return _city.ToArray()

        Catch ex As Exception
            Throw New Exception
        End Try

    End Function
	

End Class
