Imports Microsoft.VisualBasic

Public Class InterConUtil
    Public Shared Function AutoSuggestCustName(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 30 a.ACCOUNT_NAME as NAME, a.ROW_ID   "))
            .AppendLine(String.Format(" from SIEBEL_ACCOUNT a  "))
            '.AppendLine(String.Format(" where a.PARENT_ROW_ID<>a.ROW_ID and a.PARENT_ROW_ID<>''  "))
            '.AppendLine(String.Format(" and a.PARENT_ROW_ID in (select z.ROW_ID from SIEBEL_ACCOUNT z where z.ERP_ID='{0}' and z.ERP_ID<>'') ", HttpContext.Current.Session("company_id").ToString.Replace("'", "").Trim().ToUpper()))
            '.AppendLine(String.Format(" order by a.ACCOUNT_NAME "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        Dim items As New List(Of String)
        If dt.Rows.Count > 0 Then
            'Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                'str(i) = dt.Rows(i).Item(0)
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dt.Rows(i).Item("NAME"), dt.Rows(i).Item("ROW_ID")))
            Next
            Return items.ToArray()
        End If
        Return Nothing
    End Function
End Class
