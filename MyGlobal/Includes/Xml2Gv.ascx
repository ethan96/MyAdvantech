<%@ Control Language="VB" ClassName="Xml2Gv" %>

<script runat="server">
    Public Property ShowHeader() As Boolean
        Get
            Return gv1.ShowHeader
        End Get
        Set(ByVal value As Boolean)
            gv1.ShowHeader = value
        End Set
    End Property
    Public Property InputXml() As String
        Get
            If ViewState("src") IsNot Nothing Then Return Util.DataTableToXml(ViewState("src"))
            Return ""
        End Get
        Set(ByVal value As String)
            Try
                Dim dt As DataTable = Util.XmlToDataTable("<xml>" + value + "</xml>")
                If dt IsNot Nothing Then
                    ViewState("src") = dt
                    gv1.DataSource = dt : gv1.DataBind()
                End If
            Catch ex As Exception
            End Try
        End Set
    End Property
    Public ReadOnly Property srcdb() As DataTable
        Get
            If ViewState("src") IsNot Nothing Then Return ViewState("src")
            Return New DataTable()
        End Get
    End Property
</script>
<asp:GridView runat="server" ID="gv1" Width="100%" />