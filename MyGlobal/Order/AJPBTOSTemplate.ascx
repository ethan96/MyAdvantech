<%@ Control Language="VB" ClassName="AJPBTOSTemplate" %>

<script runat="server">

    Public WriteOnly Property SO_LINE_NO
        Set(value)
            Dim solineno = Split(value, ",")
            SetBTOSDetail(solineno(0), solineno(1))
        End Set
    End Property

    Sub SetBTOSDetail(SONO As String, LINENO As String)
        SONO = FormatToSAPSODNNo(SONO)
        LINENO = "000" + LINENO
        Dim Sql As String =
        " select b.posnr, b.matnr, b.uepos, b.arktx, b.kwmeng, b.matkl " +
        " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln " +
        " where a.mandt='168' and b.mandt='168' " +
        " and a.vkorg='JP01' and a.vbeln='" + SONO + "' and (b.uepos='" + LINENO + "' or b.posnr='" + LINENO + "') " +
        " and b.matnr not like 'AGS-%' and b.matnr not like 'OPTION%' " +
        " order by b.posnr "
        Dim dtBTOSItems = OraDbUtil.dbGetDataTable("SAP_PRD", Sql)
        gvBTOSItems.DataSource = dtBTOSItems : gvBTOSItems.DataBind()
        txtSONO.Text = RemovePrecedingZeros(SONO)

        If dtBTOSItems.Rows.Count > 0 AndAlso dtBTOSItems.Rows(0).Item("matkl").Equals("BTOS") Then
            txtBTOPN.Text = dtBTOSItems.Rows(0).Item("matnr")
            txtQty.Text = dtBTOSItems.Rows(0).Item("kwmeng")
        End If

        Sql =
        " select b.title, b.name1, b.name_co, b.post_code1 , b.street, b.tel_number " +
        " from saprdp.vbpa a " +
        " inner join saprdp.adrc b on a.land1=b.country and a.adrnr=b.addrnumber " +
        " where a.vbeln='" + SONO + "' and a.parvw='WE'  "
        Dim dtShipTo = OraDbUtil.dbGetDataTable("SAP_PRD", Sql)
        If dtShipTo.Rows.Count > 0 Then
            lbShipToAccountName.Text = dtShipTo.Rows(0).Item("name1")
            lbShipToContactName.Text = dtShipTo.Rows(0).Item("name_co")
            lbShipToPostCode.Text = dtShipTo.Rows(0).Item("post_code1")
            lbShipToStreet.Text = dtShipTo.Rows(0).Item("street")
            lbShipToTel.Text = dtShipTo.Rows(0).Item("tel_number")
        End If
        Dim Lines = 0
        txtSalesNote.Text = GetSOSalesNote(SONO, Lines)
        txtSalesNote.Height = Unit.Point(Lines * 15 + 30)
    End Sub

    Public Shared Function FormatToSAPSODNNo(ByVal str As String) As String
        If String.IsNullOrEmpty(str) Then Return ""
        str = UCase(str)
        If Not Decimal.TryParse(str.Substring(0, 1), 0) Then Return str
        While str.Length < 10
            str = "0" + str
        End While
        Return str
    End Function

    Public Shared Function RemovePrecedingZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        If str.Length > 1 Then
            Return RemovePrecedingZeros(str.Substring(1))
        Else
            Return str
        End If
    End Function

    Public Shared Function GetSOSalesNote(SoNo As String, ByRef TextLines As Integer) As String
        TextLines = 1
        '20140512 Change to ZEOP (EU OP Note), or remain 0001 (Saels Note from customer)
        Dim tdid As String = "0001"
        Dim apt As New Oracle.DataAccess.Client.OracleDataAdapter(
  " select tdid, tdname, tdspras from saprdp.stxl where mandt='168' and relid='TX' and tdobject='VBBK' " +
  " and tdname='" + FormatToSAPSODNNo(RemovePrecedingZeros(Replace(Trim(SoNo), "'", "''"))) + "' and tdid='" + tdid + "' and srtf2>=0",
  New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString))
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()

        If dt.Rows.Count > 0 Then
            Dim eup As New Z_READ_TEXT.Z_READ_TEXT, header As New Z_READ_TEXT.THEAD, lines As New Z_READ_TEXT.TLINETable
            eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            eup.Connection.Open()
            eup.Zread_Text(0, "168", dt.Rows(0).Item("TDID"), dt.Rows(0).Item("tdspras"), "", dt.Rows(0).Item("TDNAME"), "VBBK", header, lines)
            eup.Connection.Close()
            TextLines = lines.Count
            Dim sb As New System.Text.StringBuilder
            For Each line As Z_READ_TEXT.TLINE In lines
                sb.Append(line.Tdline + vbCrLf)
            Next
            Return sb.ToString()
        Else
            Return ""
        End If
    End Function

</script>
<table width="100%">
    <tr>
        <td>
            <table>
                <tr>
                    <td>作業Date</td><td></td><td><h1 style="color:navy">CTOS作業内容</h1></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table>
                <tr>
                    <th>CTOS受付番号</th>
                    <td>
                        <asp:TextBox runat="server" ID="txtSONO" />
                    </td>
                    <td>
                        <asp:TextBox runat="server" ID="txtBTOPN" />
                    </td>
                    <td align="right">
                        <asp:TextBox runat="server" ID="txtQty" Width="30px" />&nbsp;set
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <asp:GridView runat="server" ID="gvBTOSItems" Width="50%" AutoGenerateColumns="false">
                <Columns>
                    <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%#Container.DataItemIndex + 1%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="品名" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="line_no">
                        <ItemTemplate>
                            <%#RemovePrecedingZeros(Eval("matnr"))%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="数量" ItemStyle-HorizontalAlign="Right" ItemStyle-CssClass="line_no">
                        <ItemTemplate>
                            <%#Eval("kwmeng")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="備考" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="line_no">
                        <ItemTemplate>
                            
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </td>
    </tr>
    <tr>
        <td>
            <table width="300px">
                <tr>
                    <td>部材納品日</td>
                    <td>
                        <input type="text" /></td>
                </tr>
                <tr>
                    <td>出荷日</td>
                    <td>
                        <input type="text" /></td>
                </tr>
                <tr>
                    <td>到着日</td>
                    <td>
                        <input type="text" /></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>納品先</td>
    </tr>
    <tr>
        <td>
            <table border="1" style="border-style:solid; border-collapse:collapse; width:80%">
                <tr>
                    <td><asp:Label runat="server" ID="lbShipToAccountName" /></td>
                </tr>
                <tr>
                    <td><asp:Label runat="server" ID="lbShipToPostCode" /></td>
                </tr>
                <tr>
                    <td><asp:Label runat="server" ID="lbShipToStreet" /></td>
                </tr>
                <tr>
                    <td><asp:Label runat="server" ID="lbShipToContactName" /></td>
                </tr>
                <tr>
                    <td>TEL:<asp:Label runat="server" ID="lbShipToTel" /></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr style="height:15px"><td>&nbsp;</td></tr>
    <tr>
        <td>作業指示</td>
    </tr>    
    <tr>
        <td>
            <asp:TextBox runat="server" ID="txtSalesNote" TextMode="MultiLine" Width="100%" /></td>
    </tr>
</table>
