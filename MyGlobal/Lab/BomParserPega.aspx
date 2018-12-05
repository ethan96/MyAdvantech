<%@ Page Title="Suck Parse BOM" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<script runat="server">
    Class ResultRow
        Public Property V1 As String : Public Property V2 As String : Public Property V3 As String
    End Class
    
    Protected Sub btnParse_Click(sender As Object, e As System.EventArgs)
        Dim ResultRows As New List(Of ResultRow)
        Dim lines() As String = Split(txt1.Text, vbCrLf)
        For i As Integer = 0 To lines.Length - 1
            Dim line As String = Trim(lines(i))
            If line.IndexOf(" ") >= 0 AndAlso Integer.TryParse(line.Substring(0, line.IndexOf(" ")), 0) Then
                Dim ResultRow1 As New ResultRow
                Dim Line1Values() As String = Split(line, " ")
                ResultRow1.V1 = Line1Values(1)
                ResultRow1.V2 = Line1Values(Line1Values.Length - 2)
                ResultRows.Add(ResultRow1)
                i = i + 2
                If i > lines.Length - 1 Then Exit For
                Dim V3Values As New System.Text.StringBuilder
                While True
                    If lines(i).EndsWith(",") Then
                        Dim Line3Values() As String = Split(lines(i), " ")
                        V3Values.Append(Line3Values(Line3Values.Length - 1))
                        'ResultRow1.V3 = Line3Values(Line3Values.Length - 1)
                        If i + 1 <= lines.Length - 1 AndAlso lines(i + 1).EndsWith(",") Then
                            i += 1
                        Else
                            Exit While
                        End If
                    Else
                        Exit While
                    End If
                End While
                ResultRow1.V3 = V3Values.ToString()
                While True
                    i += 1
                    If i > lines.Length - 1 Then Exit For
                    lines(i) = Trim(lines(i))
                    If lines(i).IndexOf(" ") >= 0 AndAlso Integer.TryParse(lines(i).Substring(0, lines(i).IndexOf(" ")), 0) Then
                        i -= 1
                        Exit While
                    End If
                End While
                'Response.Write(line.Substring(0, line.IndexOf(" ")) + "<br/>")
            End If
        Next
        gv1.DataSource = ResultRows
        gv1.DataBind()
        tabcon1.ActiveTabIndex = 1
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<ajaxToolkit:TabContainer runat="server" ID="tabcon1">
        <ajaxToolkit:TabPanel runat="server" ID="tab1" HeaderText="Input">
            <ContentTemplate>
                <asp:Button runat="server" ID="btnParse" Text="Parse" OnClick="btnParse_Click" />
                <asp:TextBox runat="server" ID="txt1" TextMode="MultiLine" Width="800px" Height="200px" />
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tab2" HeaderText="Result">
            <ContentTemplate>
                <asp:GridView runat="server" ID="gv1" />
                <asp:TextBox runat="server" ID="txt2" TextMode="MultiLine" Width="800px" Height="200px" />
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>  
</asp:Content>