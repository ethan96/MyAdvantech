<%@ Control Language="VB" ClassName="TransactionCriteria" %>
<script runat="server">
    Public Shared MaxPNCount As Integer = 5
    Dim cult As New System.Globalization.CultureInfo("en-US")
    Function IsOrderCriteriaSpecified() As Boolean
        If dlWithOrOut.SelectedIndex <= 0 Then Return False
        If Not String.IsNullOrEmpty(txtOrderFrom.Text) OrElse Not String.IsNullOrEmpty(txtOrderTo.Text) Then Return True
        For i As Integer = 1 To MaxPNCount
            Dim txtPN As TextBox = Me.FindControl("txtOrderPN" + i.ToString())
            If String.IsNullOrEmpty(txtPN.Text) = False Then Return True
        Next
        Return False
    End Function
    Protected Sub btnMoreOrderPN_Click(sender As Object, e As System.EventArgs)
        For i As Integer = 2 To MaxPNCount
            If i = MaxPNCount Then btnMoreOrderPN.Enabled = False
            Dim txtPN As TextBox = Me.FindControl("txtOrderPN" + i.ToString())
            If txtPN Is Nothing Then
                btnMoreOrderPN.Enabled = False
            End If
            If txtPN.Visible = False Then
                txtPN.Visible = True : Exit For
            End If
        Next
    End Sub

    Function GetOrderERPIDSql(ByVal PN As String, ByVal ofrom As Date, ByVal oto As Date) As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct Customer_ID  "))
            .AppendLine(String.Format(" from EAI_ORDER_LOG z where Customer_ID is not null  "))
            .AppendLine(String.Format(" and z.order_date between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
            If Trim(PN) <> String.Empty Then .AppendLine(String.Format(" and z.item_no like '{0}%' ", Replace(Trim(PN), "'", "''").Replace("*", "%")))
        End With
        Return " a.ERP_ID in (" + sb.ToString() + ") "
    End Function

    Function OrderSql(ByRef sb As System.Text.StringBuilder) As Object()
        Dim obj(2) As Object
        With sb
            Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
            If Not String.IsNullOrEmpty(txtOrderFrom.Text) AndAlso Date.TryParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                ofrom = Date.ParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult)
            End If
            If Not String.IsNullOrEmpty(txtOrderTo.Text) AndAlso Date.TryParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                oto = Date.ParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult)
            End If
            obj(0) = ofrom : obj(1) = oto
            Dim strOrderERPIDSql As String = ""
            Dim sqlArr As New ArrayList
            If rblPNAndOr.SelectedValue = "AND" Then
                For i As Integer = 1 To MaxPNCount
                    Dim txtPN As TextBox = Me.FindControl("txtOrderPN" + i.ToString())
                    If i = 1 Or Trim(txtPN.Text) <> String.Empty Then
                        sqlArr.Add(GetOrderERPIDSql(txtPN.Text, ofrom, oto))
                    End If
                Next
                If sqlArr.Count > 0 Then
                    strOrderERPIDSql = String.Join(" and ", sqlArr.ToArray())
                End If
            Else
                For i As Integer = 1 To MaxPNCount
                    Dim txtPN As TextBox = Me.FindControl("txtOrderPN" + i.ToString())
                    If Trim(txtPN.Text) <> String.Empty Then
                        sqlArr.Add(String.Format(" z.{0} like '{1}%' ", GetPtypeColumn(), Replace(Trim(txtPN.Text), "'", "''").Replace("*", "%")))
                    End If
                Next
                Dim subSb As New System.Text.StringBuilder
                subSb.AppendLine(String.Format("  a.ERP_ID {0} in (", IIf(dlWithOrOut.SelectedIndex = 2, "not", "")))
                subSb.AppendLine(String.Format(" select Customer_ID  "))
                subSb.AppendLine(String.Format(" from EAI_ORDER_LOG z where Customer_ID is not null  "))
                subSb.AppendLine(String.Format(" and z.order_date between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
                If sqlArr.Count > 0 Then
                    subSb.AppendLine(String.Format(" and ({0}) ", String.Join(" or ", sqlArr.ToArray())))
                End If
                subSb.AppendLine(" group by Customer_ID ")
                If Integer.TryParse(txtOrderCount.Text, 0) AndAlso CInt(txtOrderCount.Text) >= 0 Then
                    subSb.AppendLine(String.Format(" having COUNT(distinct z.order_no)>{0} ", CInt(txtOrderCount.Text)))
                End If
                subSb.AppendLine(")")
                strOrderERPIDSql = subSb.ToString()
            End If
            obj(2) = IIf(rblPNAndOr.SelectedValue = "AND", True, False)
            If strOrderERPIDSql <> String.Empty Then
                .AppendLine(String.Format(" and a.ERP_ID is not null and a.ERP_ID<>'' and ({0}) ", strOrderERPIDSql))
            End If
            'MailUtil.SendEmail("tc.chen@advantech.com.tw", "myadvantech@advantech.com", "strOrderERPIDSql", strOrderERPIDSql, False, "", "")
        End With
        Return obj
    End Function

    Function GetPtypeColumn() As String
        Select Case dlPType.SelectedIndex
            Case 0
                Return "item_no"
            Case 1
                Return "product_line"
            Case 2
                Return "edivision"
            Case 3
                Return "egroup"
        End Select
        Return "item_no"
    End Function

</script>
<table width="800px">
    <tr align="left">
        <td>
            <table>
                <tr>
                    <td>
                        <asp:DropDownList runat="server" ID="dlWithOrOut">
                            <asp:ListItem Text="Select..." Selected="True" />
                            <asp:ListItem Text="With" />
                            <asp:ListItem Text="Without" />
                        </asp:DropDownList>
                    </td>
                    <th align="left">
                        Order Date:
                    </th>
                    <td align="left">
                        <ajaxToolkit:CalendarExtender runat="server" ID="calext1" TargetControlID="txtOrderFrom"
                            Format="yyyy/MM/dd" />
                        <ajaxToolkit:CalendarExtender runat="server" ID="calext2" TargetControlID="txtOrderTo"
                            Format="yyyy/MM/dd" />
                        <asp:TextBox runat="server" ID="txtOrderFrom" Width="70px" />~<asp:TextBox runat="server"
                            ID="txtOrderTo" Width="70px" />
                    </td>
                    <th align="left">
                        more than
                    </th>
                    <td>
                        <ajaxToolkit:FilteredTextBoxExtender runat="server" FilterType="Numbers" TargetControlID="txtOrderCount"
                            ID="FilteredTextBoxExtender1" />
                        <asp:TextBox runat="server" ID="txtOrderCount" Width="30px" />
                    </td>
                    <th align="left" colspan="3">
                        Order(s)
                    </th>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table>
                <tr>
                    <th align="left">
                        Purchased Items:
                    </th>
                    <td>
                        <table>
                            <tr>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="rblPNAndOr" RepeatColumns="2" RepeatDirection="Horizontal" Visible="false">
                            <asp:ListItem Value="OR" Selected="True" />
                            <asp:ListItem Value="AND" />
                        </asp:RadioButtonList>
                                </td>
                                <th align="left">Type:</th>
                                <td>
                                    <asp:DropDownList runat="server" ID="dlPType">
                                        <asp:ListItem Value="Part Number" Selected="True" />
                                        <asp:ListItem Value="Product Line" />
                                        <asp:ListItem Value="Product Division" />
                                    </asp:DropDownList>
                                </td>
                            </tr>
                        </table>
                        
                    </td>
                    <td align="left">
                        <asp:UpdatePanel runat="server" ID="upOrderPN" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Button runat="server" ID="btnMoreOrderPN" Text="More" OnClick="btnMoreOrderPN_Click" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtOrderPN1"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender2" TargetControlID="txtOrderPN2"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender3" TargetControlID="txtOrderPN3"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender4" TargetControlID="txtOrderPN4"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender5" TargetControlID="txtOrderPN5"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender6" TargetControlID="txtOrderPN6"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender7" TargetControlID="txtOrderPN7"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender8" TargetControlID="txtOrderPN8"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender9" TargetControlID="txtOrderPN9"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender10" TargetControlID="txtOrderPN10"
                                    MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                <asp:TextBox runat="server" ID="txtOrderPN1" Width="80px" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN2" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN3" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN4" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN5" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN6" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN7" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN8" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN9" Width="80px" Visible="false" />&nbsp;
                                <asp:TextBox runat="server" ID="txtOrderPN10" Width="80px" Visible="false" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
