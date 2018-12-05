<%@ Page Title="MyAdvantech - Expand & Download CBOM of a material" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Util.IsInternalUser2() Then Response.Redirect("../../home.aspx")
    End Sub
    
    Public Shared Function RemovePrecedingZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        If str.Length > 1 Then
            Return RemovePrecedingZeros(str.Substring(1))
        Else
            Return str
        End If
    End Function
    
    Public Shared Function FormatToSAPPartNo(ByVal str As String) As String
        If String.IsNullOrEmpty(Trim(str)) Then Return ""
        str = RemovePrecedingZeros(str)
        Dim IsNumericPart As Nullable(Of Boolean)
        For i As Integer = 0 To str.Length - 1
            If Not Decimal.TryParse(str.Substring(i, 1), 0) Then
                IsNumericPart = False : Exit For
            Else
                IsNumericPart = True
            End If
        Next
        If IsNumericPart = True Then
            While str.Length < 18
                str = "0" + str
            End While
        End If
        Return str
    End Function
    
    Public Shared Sub ExpandBOM(ParentItem As String, Plant As String, Level As Integer, ByRef RFCProxy As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZPP_BOM_EXPL_MAT_V2_RFC_CKD, ByRef dtBOM As DataTable)
        ParentItem = FormatToSAPPartNo(ParentItem)
        Dim strErr As String = "", BOMTable As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60Table
        RFCProxy.Zpp_Bom_Expl_Mat_V2_Rfc("", "X", ParentItem, Plant, strErr, BOMTable)

        Dim MaxLevel As Integer = 1
        For Each BomRow As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60 In BOMTable
            If BomRow.Stufe > MaxLevel Then MaxLevel = BomRow.Stufe
        Next


        For CurrentProcLevel As Integer = 1 To MaxLevel
            For BomIdx As Integer = 0 To BOMTable.Count - 1
                Dim BomRow As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60 = BOMTable(BomIdx)
                If BomRow.Stufe = CurrentProcLevel + 1 And BomRow.Matnr = ParentItem Then
                    Dim currentFindIdx As Integer = BomIdx
                    While currentFindIdx >= 0
                        currentFindIdx -= 1
                        Dim prevBomRow As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60 = BOMTable(currentFindIdx)
                        If prevBomRow.Stufe = CurrentProcLevel Then
                            BomRow.Matnr = prevBomRow.Idnrk
                            Exit While
                        End If
                    End While
                End If
            Next
        Next

        dtBOM = BOMTable.ToADODataTable()

        Dim BomList As New List(Of ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60)
        For Each BomRow As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60 In BOMTable
            BomList.Add(BomRow)
        Next
        
        For Each BomRow As ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60 In BOMTable
            'If no children then get child bom, otherwise don't get to avoid duplicate
            Dim hasChild = From q In BomList Where q.Matnr = BomRow.Idnrk
            
            If hasChild.Count = 0 Then
                Dim BOMTableChild As New DataTable
                ExpandBOM(BomRow.Idnrk, "", BomRow.Stufe, RFCProxy, BOMTableChild)
                For Each childRow As DataRow In BOMTableChild.Rows
                    childRow.Item("Stufe") = CDbl(childRow.Item("Stufe")) + BomRow.Stufe
                Next
                dtBOM.Merge(BOMTableChild)
            End If
        Next
        
    End Sub
    

    Protected Sub btnDownloadBOM_Click(sender As Object, e As EventArgs)
        lbErrMsg.Text = ""
        If Not String.IsNullOrEmpty(txtParentItem.Text) Then
            Dim dtBOM = MergeGetBOM()
            Util.DataTable2ExcelDownload(dtBOM, Trim(txtParentItem.Text) + "_BOM.xls")
        End If
    End Sub

    Function MergeGetBOM() As DataTable
        Dim MyComBom As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZPP_BOM_EXPL_MAT_V2_RFC_CKD
        Dim BOMTable As New DataTable
        MyComBom.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        MyComBom.Connection.Open()
        ExpandBOM(UCase(Trim(txtParentItem.Text)), dlPlant.SelectedValue, 1, MyComBom, BOMTable)
        MyComBom.Connection.Close()

        With BOMTable.Columns
            .Remove("Mandt")
            '.Remove("Alprf") : .Remove("Alpgr") : .Remove("Ewahr")
            .Item("Alprf").ColumnName = "Alt. Item Rank Order" : .Item("Alpgr").ColumnName = "Alt. Item Grp." : .Item("Ewahr").ColumnName = "Usage Prob (%)"
            .Item("Matnr").ColumnName = "Parent Item" : .Item("Bstmi").ColumnName = "MoQ" : .Item("Ojtxb").ColumnName = "Parent Desc."
            .Item("Idnrk").ColumnName = "Child Item" : .Item("Ojtxp").ColumnName = "Child Desc." : .Item("Stprs").ColumnName = "Cost"
            .Item("Stprs_Usd").ColumnName = "USD Cost" : .Item("Werks").ColumnName = "Plant" : .Item("Waers").ColumnName = "Currency"
            .Item("Stufe").ColumnName = "Level" : .Item("Menge").ColumnName = "Component Qty." : .Item("Peinh").ColumnName = "Price Unit"
            .Item("Peinh_Usd").ColumnName = "USD Price Unit" : .Add("MPN") : .Add("Manufacture Name")
        End With

        Dim MyLocalConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)

        MyLocalConn.Open()
        For Each br As DataRow In BOMTable.Rows
            Dim dtMPN As New DataTable, dtMNAME As New DataTable
            Dim MyLocalApt As New SqlClient.SqlDataAdapter( _
                "select distinct MPN from SAP_PRODUCT_MPN where ADVANTECH_PN=@ADVPN and MPN is not null and LTRIM(RTRIM(MPN))<>'' order by MPN", MyLocalConn)
            MyLocalApt.SelectCommand.Parameters.AddWithValue("ADVPN", br.Item("Child Item"))
            MyLocalApt.Fill(dtMPN)
            If dtMPN.Rows.Count = 1 Then
                br.Item("MPN") = dtMPN.Rows(0).Item("MPN")
                If dtMPN.Rows.Count > 1 Then
                    For Each mpnRow In dtMPN.Rows
                        br.Item("MPN") += "," + mpnRow.Item("MPN")
                    Next
                    'br.Item("MPN") = br.Item("MPN").ToString.Substring(0, br.Item("MPN").ToString.Length - 1)
                End If
            End If
            
            MyLocalApt.SelectCommand.CommandText = _
                " select distinct MNAME from SAP_PRODUCT_MPN where ADVANTECH_PN=@ADVPN and MNAME is not null and LTRIM(RTRIM(MNAME))<>'' order by MNAME"
            MyLocalApt.Fill(dtMNAME)
            
            If dtMNAME.Rows.Count = 1 Then
                br.Item("Manufacture Name") = dtMNAME.Rows(0).Item("MNAME")
                If dtMNAME.Rows.Count > 1 Then
                    For Each mnRow In dtMNAME.Rows
                        br.Item("Manufacture Name") += "," + mnRow.Item("MNAME")
                    Next
                    'br.Item("Manufacture Name") = br.Item("Manufacture Name").ToString.Substring(0, br.Item("Manufacture Name").ToString.Length - 1)
                End If
            End If
            
            
            br.Item("Parent Item") = Global_Inc.RemoveZeroString(br.Item("Parent Item"))
            br.Item("Child Item") = Global_Inc.RemoveZeroString(br.Item("Child Item"))
        Next
        MyLocalConn.Close()
        Return BOMTable
    End Function
    
    Protected Sub btnExpandBOM_Click(sender As Object, e As EventArgs)
        gvBOM.DataSource = Nothing : gvBOM.DataBind()
        If Not String.IsNullOrEmpty(txtParentItem.Text) Then
            gvBOM.DataSource = MergeGetBOM() : gvBOM.DataBind()
        End If
       
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <asp:Panel runat="server" ID="Panel1" DefaultButton="btnDownloadBOM">
                    <table>
                        <tr>
                            <th>Mother Part No.:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtParentItem" Width="150px" />
                            </td>
                            <th>Plant (optional):</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlPlant">
                                    <asp:ListItem Text="Select..." Value="" />
                                    <asp:ListItem Text="TWH1" Value="TWH1" />
                                    <asp:ListItem Text="USH1" Value="USH1" />
                                    <asp:ListItem Text="CKB3" Value="CKB3" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnExpandBOM" Text="Display BOM" OnClick="btnExpandBOM_Click" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnDownloadBOM" Text="Download BOM" OnClick="btnDownloadBOM_Click" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label runat="server" ID="lbErrMsg" ForeColor="Tomato" Font-Bold="true" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvBOM" Width="100%" />
            </td>
        </tr>
    </table>

</asp:Content>
