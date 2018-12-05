<%@ Page Title="MyAdvantech - Process フジツウ" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="Aspose.Cells" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
       
    End Sub

    Protected Sub btnUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If afup1.HasFile = False OrElse afup1.FileName.EndsWith(".xls") = False Then Exit Sub
        Util.SetASPOSELicense()
        Dim wb As New Workbook, ExUSD2EMB As Double = CDbl(txtExr.Text)
        wb.Open(afup1.FileContent)
        For Each s As Worksheet In wb.Worksheets
            For i As Integer = 0 To s.Cells.MaxDataRow - 1
                If s.Cells(i, 0).Value IsNot Nothing AndAlso s.Cells(i, 0).Value.ToString().Contains("Item Number") Then
                    For j As Integer = 0 To s.Cells.MaxColumn - 1
                        'If s.Cells(i, j).Value IsNot Nothing Then Console.WriteLine(s.Cells(i, j).Value.ToString())
                        If s.Cells(i, j).Value IsNot Nothing AndAlso s.Cells(i, j).Value.ToString().Contains("EX-Works(USD)") Then
                            If rblType.SelectedIndex = 0 Then
                                s.Cells(i, j).PutValue("客户价格")
                            Else
                                s.Cells(i, j).PutValue("子商采购价格")
                            End If
                            For k As Integer = i + 1 To s.Cells.MaxDataRow
                                If s.Cells(k, j).Value IsNot Nothing Then
                                    Dim p As Double = -100
                                    If rblType.SelectedIndex = 0 Then
                                        p = ExPriceToMarkupPrice(s.Cells(k, j).Value, ExUSD2EMB)
                                    Else
                                        p = ExPriceToPtnrPrice(s.Cells(k, j).Value, ExUSD2EMB)
                                    End If
                                    If p > -1 Then
                                        s.Cells(k, j).PutValue(Math.Round(p))
                                    End If
                                End If
                            Next
                            Exit For
                        End If
                    Next
                    Exit For
                End If
            Next
        Next
        Response.Clear()
        Response.ContentType = "application/vnd.ms-excel"
        Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0};", "price.xls"))
        Response.BinaryWrite(wb.SaveToStream().ToArray())
    End Sub
    
    Public Function ExPriceToPtnrPrice(ByVal exp As Object, ByVal ExUSD2EMB As Double) As Double
        If Double.TryParse(exp, 0) = False Then Return -1
        Dim p As Double = CDbl(exp)
        Return p * 1.2 * ExUSD2EMB
    End Function
    
    Public Function ExPriceToMarkupPrice(ByVal exp As Object, ByVal ExUSD2EMB As Double) As Double
        If Double.TryParse(exp, 0) = False Then Return -1
        Dim p As Double = CDbl(exp)
        'Dim revRate As Double = 0
        If p > 500 Then
            p = p * ExUSD2EMB / 0.7
        Else
            If p <= 50 Then
                p = p * ExUSD2EMB / 0.6
            Else
                If p <= 500 And p > 50 Then
                    p = p * ExUSD2EMB / 0.65
                End If
            End If
        End If
        'p = p * ExUSD2EMB / (1.0 - revRate)
        Return p
        'If p <= 50 Then
        '    p = p * ExUSD2EMB * 1.4
        'Else
        '    If p > 50 And p <= 500 Then
        '        p = p * ExUSD2EMB * 1.35
        '    Else
        '        If p > 500 Then
        '            p = p * ExUSD2EMB * 1.3
        '        End If
        '    End If
        'End If
        'Return p
    End Function
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="800px">
        <tr>
            <th colspan="2" style="font-size:large; color:Navy;">Process フジツウ Price</th>
        </tr>
        <tr>
            <th align="left">
                File Path:
            </th>
            <td>
                <asp:FileUpload runat="server" ID="afup1" Width="95%" />
            </td>
        </tr>
        <tr>
            <th align="left">USD to RMB Exchange Rate:</th>
            <td>
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="txtExr" FilterType="Numbers, Custom" ValidChars="." />
                <asp:TextBox runat="server" ID="txtExr" Width="80px" Text="6.782" />
            </td>
        </tr>
        <tr>
            <th align="left">Type:</th>
            <td>
                <asp:RadioButtonList runat="server" ID="rblType" RepeatColumns="2" RepeatDirection="Horizontal">
                    <asp:ListItem Value="For Customer" Selected="True" />
                    <asp:ListItem Value="For Partner" />
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="center"><asp:Button runat="server" ID="btnUp" Text="Upload" OnClick="btnUp_Click" /></td>
        </tr>
    </table>
</asp:Content>