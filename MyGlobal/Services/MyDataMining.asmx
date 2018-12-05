<%@ WebService Language="VB" Class="MyDataMining" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantechWS")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class MyDataMining
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty GGYY! " + Now.ToString("yyyyMMddHHmmss")
    End Function
    
    <WebMethod()> _
    Public Function GetBasketAnalysis(ByVal PartNo As String) As DataTable
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _
         "select top 30 REF_PART_NO, ORDERS from DM_BASKET_ANALYSIS where PART_NO='" + Trim(Replace(PartNo, "'", "''")) + "' order by ORDERS desc")
            dt.TableName = "Basket"
            Return dt
        Catch ex As Exception
            Dim fdt As New DataTable("Basket")
            With fdt.Columns
                .Add("REF_PART_NO") : .Add("ORDERS", GetType(Integer))
            End With
            Return fdt
        End Try
    End Function
    
    <WebMethod()> _
    Public Function GetMultiBasketAnalysis(ByVal PartNos As String(), ByVal TopCount As Integer) As DataTable
        If PartNos.Length = 0 Then Return Nothing
        If TopCount <= 0 Then Return Nothing
        Dim gdt As New DataTable
        Dim tg(PartNos.Length - 1) As Threading.Thread, objs(PartNos.Length - 1) As BasketClass
        For i As Integer = 0 To PartNos.Length - 1
            Dim pn As String = PartNos(i)
            Dim o As New BasketClass(pn)
            Dim t As New Threading.Thread(AddressOf o.GetAnalysis)
            tg(i) = t : objs(i) = o
            tg(i).Start()
        Next
        For i As Integer = 0 To PartNos.Length - 1
            tg(i).Join()
            gdt.Merge(objs(i).dt)
        Next
        If gdt.Rows.Count >= 2 Then
            For i As Integer = 0 To gdt.Rows.Count - 2
                For J As Integer = i + 1 To gdt.Rows.Count - 1
                    If CInt(gdt.Rows(i).Item("orders")) > 0 AndAlso _
                        gdt.Rows(i).Item("ref_part_no") = gdt.Rows(J).Item("ref_part_no") Then
                        gdt.Rows(i).Item("orders") = CInt(gdt.Rows(i).Item("orders")) + CInt(gdt.Rows(J).Item("orders"))
                        gdt.Rows(J).Item("orders") = 0
                    End If
                Next
            Next
            Dim ndt As DataTable = gdt.Clone()
            For i As Integer = 0 To gdt.Rows.Count - 1
                If CInt(gdt.Rows(i).Item("orders")) > 0 Then
                    ndt.ImportRow(gdt.Rows(i))
                End If
            Next
            gdt = ndt
        End If
        gdt.DefaultView.Sort = "ORDERS desc"
        gdt = gdt.DefaultView.ToTable()
        If gdt.Rows.Count > TopCount Then
            Dim ndt As DataTable = gdt.Clone()
            For i As Integer = 0 To TopCount - 1
                ndt.ImportRow(gdt.Rows(i))
            Next
            gdt = ndt
        End If
        gdt.TableName = "Basket"
        Return gdt
    End Function
    
    Private Class BasketClass
        Public dt As DataTable, pn As String
        Public Sub New(ByVal partno As String)
            pn = partno
        End Sub
        Public Sub GetAnalysis()
            Dim ws As New MyDataMining
            dt = ws.GetBasketAnalysis(pn)
        End Sub
    End Class

End Class
