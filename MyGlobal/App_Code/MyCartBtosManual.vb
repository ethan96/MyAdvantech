Imports Microsoft.VisualBasic

Public Class MyCartBtosManual
    Public Shared Function InsertCartBtosManual(ByVal _CartBtosPartManual As Cart_BtosPart_Manual) As Boolean
        Try
            MyUtil.Current.MyAContext.Cart_BtosPart_Manuals.InsertOnSubmit(_CartBtosPartManual)
            MyUtil.Current.MyAContext.SubmitChanges()
        Catch ex As Exception
            Return False
        End Try
        Return False
    End Function

    Public Shared Function InCartBtosManual(ByVal caitid As String, ByVal partid As String) As Boolean
        If Not (String.IsNullOrEmpty(caitid) And String.IsNullOrEmpty(partid)) Then
            Dim _btospart As Cart_BtosPart_Manual = MyUtil.Current.MyAContext.Cart_BtosPart_Manuals.Where(Function(p) p.Cart_Id = caitid AndAlso p.Part_No = partid).FirstOrDefault()
            If _btospart IsNot Nothing Then Return True
        End If
        Return False
    End Function

End Class
