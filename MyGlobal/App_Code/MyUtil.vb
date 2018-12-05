Imports Microsoft.VisualBasic

Public Class MyUtil
    Private _context As HttpContext = HttpContext.Current
    Public Sub New()
    End Sub
    Public Shared ReadOnly Property Current() As MyUtil
        Get
            If HttpContext.Current Is Nothing Then
                Return Nothing
            End If
            If HttpContext.Current.Items("MyUtil") Is Nothing Then
                Dim _MyDC As New MyUtil()
                HttpContext.Current.Items.Add("MyUtil", _MyDC)
                Return _MyDC
            End If
            Return DirectCast(HttpContext.Current.Items("MyUtil"), MyUtil)
        End Get
    End Property
    Private _CurrentLing2Sql As MyLing2SqlDataContext
    Public ReadOnly Property MyAContext() As MyLing2SqlDataContext
        Get
            If _CurrentLing2Sql Is Nothing Then
                _CurrentLing2Sql = New MyLing2SqlDataContext()
            End If
            Return _CurrentLing2Sql
        End Get
    End Property
    Private _CurrentQDataContext As eQuotationDBDataContext
    Public ReadOnly Property EQContext() As eQuotationDBDataContext
        Get
            If _CurrentQDataContext Is Nothing Then
                _CurrentQDataContext = New eQuotationDBDataContext()
            End If
            Return _CurrentQDataContext
        End Get
    End Property
    'Private _LocalTime As DateTime
    Public ReadOnly Property CurrentLocalTime() As DateTime
        Get
            '_LocalTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))  'Return _LocalTime
            If HttpContext.Current Is Nothing Then     Return Nothing
            If HttpContext.Current.Items("LocalTime") Is Nothing Then
                Dim _LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
                HttpContext.Current.Items.Add("LocalTime", _LocalTime)
                Return _LocalTime
            End If
            Return CType(HttpContext.Current.Items("LocalTime"), DateTime)
        End Get
    End Property

    Public Property Item(ByVal key As String) As Object
        Get
            If Me._context Is Nothing Then
                Return Nothing
            End If
            If Me._context.Items(key) IsNot Nothing Then
                Return Me._context.Items(key)
            End If
            Return Nothing
        End Get
        Set(ByVal value As Object)
            If Me._context IsNot Nothing Then
                Me._context.Items.Remove(key)

                Me._context.Items.Add(key, value)
            End If
        End Set
    End Property
End Class
