<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech – Sync Single Item From SAP" %>

<script runat="server">
    
    Function syncTbSAPProduct(ByVal pn As String) As Integer
        'Frank 2011/12/21:欄位順序必需跟目標資料表的欄位順序一樣，因為是用SqlBulk Insert
        Dim str As String = String.Format("select distinct a.matnr as part_no, " & _
                                            "a.bismt as model_no, " & _
                                            "a.MATKL as material_group, " & _
                                            "a.SPART as division, " & _
                                            "a.PRDHA as product_hierarchy, " & _
                                            "a.PRDHA as product_group, " & _
                                            "a.PRDHA as product_division, " &
                                            "a.PRDHA as product_line, " & _
                                            "a.MTPOS_MARA as GenItemCatGrp, " & _
                                            "(select MAKTX from saprdp.makt b where b.matnr=a.matnr and rownum=1 and b.spras='E') as product_desc," & _
                                            "a.ZEIFO as rohs_flag, " & _
                                            "(select vmsta from saprdp.mvke where mvke.matnr=a.matnr and mvke.vkorg='TW01' and rownum=1) as status," & _
                                            "'' as EGROUP, " & _
                                            "'' as EDIVISION, " & _
                                            "a.NTGEW as NET_WEIGHT, " & _
                                            "a.BRGEW as GROSS_WEIGHT, " & _
                                            "a.GEWEI as WEIGHT_UNIT, " & _
                                            "a.VOLUM as VOLUME, " & _
                                            "a.VOLEH as VOLUME_UNIT, " & _
                                            "a.ERSDA as CREATE_DATE, " & _
                                            "a.LAEDA as LAST_UPD_DATE, " & _
                                            "to_char(a.mtart) as product_type, " & _
                                            "a.blatt as GIP_CODE," & _
                                            "a.GROES as SIZE_DIMENSIONS " & _
                                            "from saprdp.mara a where mandt='168' and matnr='{0}'", pn)
        
        Try
            Dim DT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", str)
            If DT.Rows.Count <= 0 Then
                Return 2
            End If
            For i As Integer = 0 To DT.Rows.Count - 1
                If DT.Rows(i).Item("Part_no").ToString.StartsWith("0") Then
                    For n As Integer = 1 To DT.Rows(i).Item("Part_no").ToString.Length - 1
                        If DT.Rows(i).Item("Part_no").ToString.Substring(n, 1) <> "0" Then
                            DT.Rows(i).Item("Part_no") = DT.Rows(i).Item("Part_no").ToString.Substring(n) : Exit For
                        End If
                    Next
                End If
                
                If Not IsDBNull(DT.Rows(i).Item("product_hierarchy")) Then
                    Dim ps() As String = Split(DT.Rows(i).Item("product_hierarchy"), "-")
                    If ps.Length >= 3 Then
                        DT.Rows(i).Item("PRODUCT_GROUP") = ps(0) : DT.Rows(i).Item("PRODUCT_DIVISION") = ps(1)
                        If ps.Length = 3 Then
                            DT.Rows(i).Item("PRODUCT_LINE") = ps(2)
                        Else
                            DT.Rows(i).Item("PRODUCT_LINE") = ps(2) + ps(3)
                        End If
                    End If
                End If
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
            bk.DestinationTableName = "SAP_PRODUCT"
            bk.WriteToServer(DT)
        Catch ex As Exception
            Return 2
        End Try
        Return 0
    End Function
    
    Function syncTbSAPProductStatus(ByVal pn As String, ByVal ORG As String) As Integer
        Dim ORGCondition As String = ""
        If ORG.ToUpper <> "ALL" Then
            ORGCondition = "and mvke.vkorg like '" & ORG & "%'"
        End If
        Dim str As String = String.Format("select matnr as part_no, vkorg as sales_org, vtweg as dist_channel, vmsta as product_status, " & _
                                           " AUMNG as min_order_qty, LFMNG as min_dlv_qty, EFMNG as min_bto_qty, DWERK as dlv_plant, " & _
                                           " KONDM as material_pricing_grp, vmstd as valid_date, to_char(mvke.mtpos) as item_category_group " & _
                                           " from saprdp.MVKE " & _
                                           " where mandt='168' and matnr='{0}' {1}", pn, ORGCondition)
        
        Try
            Dim DT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", str)
            For i As Integer = 0 To DT.Rows.Count - 1
                If DT.Rows(i).Item("Part_no").ToString.StartsWith("0") Then
                    For n As Integer = 1 To DT.Rows(i).Item("Part_no").ToString.Length - 1
                        If DT.Rows(i).Item("Part_no").ToString.Substring(n, 1) <> "0" Then
                            DT.Rows(i).Item("Part_no") = DT.Rows(i).Item("Part_no").ToString.Substring(n) : Exit For
                        End If
                    Next
                End If
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
            bk.DestinationTableName = "SAP_PRODUCT_STATUS"
            bk.WriteToServer(DT)

            If ORG.StartsWith("EU", StringComparison.InvariantCultureIgnoreCase) AndAlso DT.Rows(0).Item("product_status").ToString.ToUpper = "O" Then
                'Frank 2012/10/17: If part status is O and sales org is EU, then do not write this part into SAP_PRODUCT_STATUS_ORDERABLE
            Else
                bk.DestinationTableName = "SAP_PRODUCT_STATUS_ORDERABLE"
                bk.WriteToServer(DT)
            End If
        Catch ex As Exception
            Return 3
        End Try
        Return 0
    End Function
    
    Function syncTbSAPProductOrg(ByVal pn As String, ByVal ORG As String) As Integer
        Dim ORGCondition As String = ""
        If ORG.ToUpper <> "ALL" Then
            ORGCondition = "and mvke.vkorg like '" & ORG & "%'"
        End If
        Dim str As String = String.Format("SELECT DISTINCT " & _
                                            " to_char(mara.matnr) as part_no, " & _
                                            " mvke.vkorg as org_id, " & _
                                            " mvke.VTWEG as dist_channel, " & _
                                            " to_char(mvke.vmsta) as status, " & _
                                            " to_char(mvke.PRAT5) as B2BOnline, " & _
                                            " mvke.DWERK as DeliveryPlant, " & _
                                            " mvke.kondm as PricingGroup, mara.laeda as LAST_UPD_DATE " & _
                                            " FROM saprdp.mara INNER JOIN saprdp.mvke ON mara.matnr = mvke.matnr " & _
                                            " WHERE mara.mandt='168' and mvke.mandt='168' and mara.mtart LIKE 'Z%' and mara.matnr='{0}' {1}", pn, ORGCondition)
        Try
            Dim DT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", str)
            For i As Integer = 0 To DT.Rows.Count - 1
                If DT.Rows(i).Item("Part_no").ToString.StartsWith("0") Then
                    For n As Integer = 1 To DT.Rows(i).Item("Part_no").ToString.Length - 1
                        If DT.Rows(i).Item("Part_no").ToString.Substring(n, 1) <> "0" Then
                            DT.Rows(i).Item("Part_no") = DT.Rows(i).Item("Part_no").ToString.Substring(n) : Exit For
                        End If
                    Next
                End If
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
            bk.DestinationTableName = "SAP_PRODUCT_ORG"
            bk.WriteToServer(DT)
        Catch ex As Exception
            Return 4
        End Try
        Return 0
    End Function
    
    Function syncTbSAPProductABC(ByVal pn As String, ByVal ORG As String) As Integer
        Dim ORGCondition As String = ""
        If ORG.ToUpper <> "ALL" Then
            ORGCondition = "and marc.werks like '" & ORG & "%'"
        End If
        Dim STR As String = String.Format("select matnr as PART_NO, werks as PLANT, maabc as ABC_INDICATOR,marc.PLIFZ as PlannedDelTime, " & _
                                            "marc.WEBAZ as GrProcessingTime " & _
                                            "from saprdp.marc where mandt='168' and matnr='{0}' {1}", pn, ORGCondition)
        Try
            Dim DT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", STR)
            For i As Integer = 0 To DT.Rows.Count - 1
                If DT.Rows(i).Item("Part_no").ToString.StartsWith("0") Then
                    For n As Integer = 1 To DT.Rows(i).Item("Part_no").ToString.Length - 1
                        If DT.Rows(i).Item("Part_no").ToString.Substring(n, 1) <> "0" Then
                            DT.Rows(i).Item("Part_no") = DT.Rows(i).Item("Part_no").ToString.Substring(n) : Exit For
                        End If
                    Next
                End If
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
            bk.DestinationTableName = "SAP_PRODUCT_ABC"
            bk.WriteToServer(DT)
        Catch ex As Exception
            Return 5
        End Try
        Return 0
    End Function
    
    Function Clear(ByVal pn As String, ByVal ORG As String) As Integer
        Try
            Dim str As String = ""
            If ORG.ToUpper = "ALL" Then
                str = String.Format("delete from SAP_PRODUCT WHERE PART_NO='{0}';DELETE FROM SAP_PRODUCT_ORG WHERE PART_NO='{0}';DELETE FROM SAP_PRODUCT_ABC WHERE PART_NO='{0}';DELETE FROM SAP_PRODUCT_STATUS WHERE PART_NO='{0}';DELETE FROM SAP_PRODUCT_STATUS_ORDERABLE WHERE PART_NO='{0}'", pn)
            Else
                str = String.Format("delete from SAP_PRODUCT WHERE PART_NO='{0}';DELETE FROM SAP_PRODUCT_ORG WHERE PART_NO='{0}' AND ORG_ID LIKE '{1}%';DELETE FROM SAP_PRODUCT_ABC WHERE PART_NO='{0}' AND PLANT LIKE '{1}%';DELETE FROM SAP_PRODUCT_STATUS WHERE PART_NO='{0}' AND sales_org LIKE '{1}%';DELETE FROM SAP_PRODUCT_STATUS_ORDERABLE WHERE PART_NO='{0}' AND sales_org LIKE '{1}%'", pn, ORG)
            End If
            dbUtil.dbExecuteNoQuery("MY", str)
        Catch ex As Exception
            Return 1
        End Try
        Return 0
    End Function
    
    Function ErrorMessage(ByVal eCode As Integer, ByVal pn As String, ByVal ORG As String) As String
        If eCode = 0 Then
            Return "Synchronized successfully. Product Status is """ & getStatus(pn, ORG) & """!"
        ElseIf eCode = 1 Then
            Return "Error Number 1"
        ElseIf eCode = 2 Then
            Return "specified part number cannot be found in SAP!"
        ElseIf eCode = 3 Then
            Return "Error Number 3"
        ElseIf eCode = 4 Then
            Return "Error Number 4"
        ElseIf eCode = 5 Then
            Return "Error Number 5"
        Else
            Return "Unexcepted Error!"
        End If
    End Function
    
    Protected Function getStatus(ByVal part_no As String, ByVal org As String) As String
        Dim str As String = ""
        If org.ToUpper = "ALL" Then
            str = String.Format("select top 1 status from SAP_PRODUCT where part_no='{0}'", part_no.TrimStart("0"))
        Else
            str = String.Format("select top 1 product_status from SAP_PRODUCT_STATUS where part_no='{0}' and sales_org like '{1}%'", part_no.TrimStart("0"), org)
        End If
        Dim status As Object = dbUtil.dbExecuteScalar("b2b", str)
        If Not IsNothing(status) AndAlso status.ToString <> "" Then
            Return status.ToString
        End If
        Return ""
    End Function

    Protected Sub btnSync_Click(ByVal sender As Object, ByVal e As System.EventArgs)
       
        Dim ORG As String = Me.drpOrg.SelectedValue
        'Dim REC As Integer = 0
        Dim PN As String = Me.txtPN.Text.Trim.ToUpper.Replace("'", "''")
        'If REC = 0 Then
        '    'REC = Clear(PN, ORG)
        'End If
        
        'If IsNumeric(PN) Then
        '    PN = CDbl(PN).ToString("000000000000000000")
        'End If
        
        'If REC = 0 Then
        '    REC = Me.syncTbSAPProduct(PN)
        'End If
        'If REC = 0 Then
        '    REC = Me.syncTbSAPProductABC(PN, ORG)
        'End If
        'If REC = 0 Then
        '    REC = Me.syncTbSAPProductOrg(PN, ORG)
        'End If
        'If REC = 0 Then
        '    Me.syncTbSAPProductStatus(PN, ORG)
        'End If
        Dim EM As String = ""
        'Dim PNS As New SAPDAL.syncSingleProduct
        Dim PNA As New ArrayList
        PNA.Add(PN)
        SAPDAL.syncSingleProduct.syncSAPProduct(PNA, ORG, False, EM, True)
        'dbUtil.dbExecuteNoQuery("MY", "insert into SAP_PRODUCT_STATUS_ORDERABLE select distinct PART_NO,SALES_ORG,DIST_CHANNEL,PRODUCT_STATUS,MIN_ORDER_QTY,MIN_DLV_QTY,MIN_BTO_QTY,DLV_PLANT,MATERIAL_PRICING_GRP,VALID_DATE,ITEM_CATEGORY_GROUP from SAP_PRODUCT_STATUS where PART_NO='" + Replace(Trim(PN), "'", "") + "'")
        If EM = "" Then
            Me.lbRec.Text = ErrorMessage(0, PN, ORG)
        Else
            Me.lbRec.Text = EM
        End If
       
    End Sub
    
    
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Util.IsANAPowerUser() Then
        '    Me.drpOrg.SelectedValue = "US"
        '    Me.drpOrg.Enabled = False
        'End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsInternalUser(Session("user_id")) = False Then
                Response.Redirect("../home.aspx")
            End If
            Me.txtPN.Attributes("autocomplete") = "off"
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <br />
    <div class="euPageTitle">Sync Single Item From SAP</div>
    <br />
    <ajaxToolkit:AutoCompleteExtender ID="ajacAce" runat="server" TargetControlID="txtPN"
        ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetSAPPN" MinimumPrefixLength="1">
    </ajaxToolkit:AutoCompleteExtender>

    <table style=" margin:10px">
        <tr>
            <td><B>Part No:</B> </td><td><asp:TextBox runat="server" ID="txtPN"></asp:TextBox></td>
        </tr>
        <tr>
            <td>
                <B>Org:</B>
            </td>
            <td> 
                <asp:DropDownList runat="server" ID="drpOrg">
                    <asp:ListItem Value="ALL">ALL</asp:ListItem>
                    <asp:ListItem Value="US">US</asp:ListItem>
                    <asp:ListItem Value="TW">TW</asp:ListItem>
                    <asp:ListItem Value="EU">EU</asp:ListItem>
                    <asp:ListItem Value="CN">CN</asp:ListItem>
                    <asp:ListItem Value="KR">KR</asp:ListItem>
                    <asp:ListItem Value="JP">JP</asp:ListItem>
                    <asp:ListItem Value="MY">MY</asp:ListItem>
                    <asp:ListItem Value="SG">SG</asp:ListItem>
                    <asp:ListItem Value="AU">AU</asp:ListItem>
                </asp:DropDownList> 
            </td>
        </tr>
    </table> 
    <table style=" margin:10px">
        <tr>
            <td>
                <asp:Button runat="server" Text=" Synchronize Part Number from SAP to MyAdvantech " id="btnSync" OnClick="btnSync_Click" />
            </td>
            <td>
                <asp:Label runat="server" ID="lbRec"></asp:Label>
            </td>
        </tr>
    </table>
</asp:Content>