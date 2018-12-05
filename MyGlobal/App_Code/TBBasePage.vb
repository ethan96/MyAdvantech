Public Class TBBasePage
    Inherits System.Web.UI.Page
    Private FIsVerifyRender As Boolean = True
    Public Property IsVerifyRender() As Boolean
        Get
            Return FIsVerifyRender
        End Get
        Set(ByVal value As Boolean)
            FIsVerifyRender = value
        End Set
    End Property
    Public Overrides Sub VerifyRenderingInServerForm(ByVal Control As System.Web.UI.Control)
        If Me.IsVerifyRender Then
            MyBase.VerifyRenderingInServerForm(Control)
        End If
    End Sub
    Public Overrides Property EnableEventValidation() As Boolean
        Get
            If Me.IsVerifyRender Then
                Return MyBase.EnableEventValidation
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            MyBase.EnableEventValidation = value
        End Set
    End Property
End Class