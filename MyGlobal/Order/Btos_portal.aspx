<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech CTOS Order" %>

<script runat="server">
    Dim org As String = "TW"
    Dim CBOMWS As New MyCBOMDAL, _IsAAC As Boolean = False
    Private Function IsAAC() As Boolean
        If Session("account_status") IsNot Nothing AndAlso Session("RBU") IsNot Nothing Then
            If (String.Equals(Session("account_status"), "KA", StringComparison.CurrentCultureIgnoreCase) OrElse _
                String.Equals(Session("account_status"), "CP", StringComparison.CurrentCultureIgnoreCase)) AndAlso _
                 String.Equals(Session("RBU"), "AAC", StringComparison.CurrentCultureIgnoreCase) Then
                Return True
            End If
        End If
        Return False
    End Function
    Protected Sub BuildBtosServiceCenter()
        Dim BtosDT As New DataTable

        'Frank 2012/06/04: Stop using Session("org")
        'If Session("Org") = "US" Then
        If Session("org_id") IsNot Nothing AndAlso Left(Session("org_id"), 2) = "US" Then
            BtosDT.Columns.Add(New DataColumn("Catalog_Type", GetType(String)))
            BtosDT.Columns.Add(New DataColumn("Catalog_Name", GetType(String)))
            Dim dr As DataRow = BtosDT.NewRow()

            'Ryan 20171013 Add for AAC bom logic per Lynette's request, AAC-CP with specified view.
            If HttpContext.Current.Session("SAP Sales Office") IsNot Nothing AndAlso
            HttpContext.Current.Session("SAP Sales Office") = "2100" AndAlso
            HttpContext.Current.Session("account_status") IsNot Nothing AndAlso
            HttpContext.Current.Session("account_status") = "CP" Then
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "DAQ System"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "1U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "2U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "4U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Industrial Tablet PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Panel PC (PPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "MIC-7000 Series"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Touch Panel Computers (TPC and SPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Industrial Panel PC and Workstations (IPPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "eStore BTOS"
                BtosDT.Rows.Add(dr)

            ElseIf Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.ToUpper = "US10" Then
                'Ryan 20180425 For BBUS (US10), only show UNO catalog
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Automation Embedded Controller (UNO and PEC)"
                BtosDT.Rows.Add(dr)

            Else
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "DAQ System"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "1U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "2U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "4U Rackmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Desktop/Wallmount Industrial PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Compact IPC (AIMC, MIC-7500 Series)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Server-grade IPCs"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Machine Vision System (AIIS)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "ITA – Intelligent Transportation Systems"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Advantech GPU Server (AGS)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Advantech Storage Solutions (ASR)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Digital Video Solution"
                BtosDT.Rows.Add(dr)

                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Big Thinking Out of a Slim Box (ARK-1120)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "BOARDS ASSEMBLY (SBC,eSBC,SOM, Motherboards)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "CompactPCI"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "CTOS"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Digital Signage Platforms"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Automation Embedded Controller (UNO and PEC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Embedded Computing"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Embedded IoT Solutions(EIS)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Industrial Tablet PC"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Internet Security Platforms/Nas Platforms-Appliances"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "In-Vehicle Computing System"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Medical Computing"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "MOTION DEVICES"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Panel PC (PPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "MIC-7000 Series"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Pre-Configuration"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Programmable Automation Controllers (PAC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Touch Panel Computers (TPC and SPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Ubiquitous Touch Computer"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "Industrial Panel PC and Workstations (IPPC)"
                BtosDT.Rows.Add(dr)
                dr = BtosDT.NewRow()
                dr.Item("Catalog_Type") = "eStore BTOS"
                BtosDT.Rows.Add(dr)

                'Ryan 20180323 For ADLOG's BTOS project, launched for US01
                If Session("org_id").ToString.ToUpper.Equals("US01") Then
                    dr = BtosDT.NewRow()
                    dr.Item("Catalog_Type") = "In-Vehicle-Mount Terminals (ADLoG)"
                    BtosDT.Rows.Add(dr)
                End If
            End If

            BtosDT.AcceptChanges()
            For Each _row As DataRow In BtosDT.Rows
                _row.Item("Catalog_Name") = CBOMWS.getCatalogLocalName(_row.Item("Catalog_Type"), org)
            Next

        Else
            BtosDT = CBOMWS.getCatalogList(Session("RBU"), org)
        End If
        Dim i As Integer = 0
        Me.p_catalog.Controls.Add(New LiteralControl("<table style=""" &
                                            "color:#000099;font-weight:bold;font-size:90%;""" &
                                            "width=""100%"" border=""0"">"))
        Do While i <= BtosDT.Rows.Count - 1

            Dim HL_CBOM_CTR As New HyperLink
            'HL_CBOM_CTR.Text = CBOMWS.getCatalogLocalName(BtosDT.Rows(i).Item("Catalog_Type"), org)
            HL_CBOM_CTR.Text = BtosDT.Rows(i).Item("Catalog_Name").ToString
            HL_CBOM_CTR.NavigateUrl = "~/order/CBOM_List.aspx?Catalog_Type=" & Server.UrlEncode(BtosDT.Rows(i).Item("Catalog_Type"))
            Select Case BtosDT.Rows(i).Item("Catalog_Type").ToString.ToUpper.Trim()
                Case "eStore BTOS".ToString.ToUpper
                    HL_CBOM_CTR.NavigateUrl = "EstoreCBOMCategory.aspx"
                Case "Touch Panel Computers (TPC and SPC)".ToString.ToUpper
                    If String.Equals(org, "US", StringComparison.CurrentCultureIgnoreCase) Then
                        HL_CBOM_CTR.NavigateUrl = "~/order/CBOM_List.aspx?Catalog_Type=Touch Panel Computers (TPC)"
                    End If
                Case "iservices group".ToString.ToUpper
                    If Not Util.ISIServices_Group_Account() Then
                        i = i + 1
                        Continue Do
                    End If
                    'Case "Automation Embedded Controller (UNO and PEC)".ToString.ToUpper
                    '    i = i + 1
                    '    Continue Do
                Case "In-Vehicle-Mount Terminals (ADLoG)".ToString.ToUpper
                    HL_CBOM_CTR.NavigateUrl = "~/Lab/CBOMV2/CBOM_ListV2.aspx?ID=5e28db9905e0472883f42b6b924d12"
            End Select
            Me.p_catalog.Controls.Add(New LiteralControl("<tr style=""height:15px"">" &
                                                "<td style=""padding-left:10px;width:10px;padding-top:1px;""><img alt="""" src=""../images/point_02.gif"" /></td>" &
                                                "<td>"))
            Me.p_catalog.Controls.Add(HL_CBOM_CTR)
            Me.p_catalog.Controls.Add(New LiteralControl("</td></tr>"))
            If Session("org_id") IsNot Nothing AndAlso Left(Session("org_id"), 2) = "US" Then
                If BtosDT.Rows(i).Item("Catalog_Type").ToString.ToUpper.Trim() = "Touch Panel Computers (TPC and SPC)".ToString.ToUpper Then
                    Dim HL As New HyperLink
                    HL.Text = "Automation Embedded Controller (UNO and PEC)"
                    ' If Session("org_id") IsNot Nothing AndAlso Left(Session("org_id"), 2) = "US" Then
                    HL.Text = "Automation Embedded Controller (UNO)"
                    'End If
                    Me.p_catalog.Controls.Add(New LiteralControl("<tr style=""height:15px"">" &
                                                    "<td style=""padding-left:10px;width:10px;padding-top:1px;""><img alt="""" src=""../images/point_02.gif"" /></td>" &
                                                    "<td>"))
                    HL.NavigateUrl = "~/order/CBOM_List.aspx?Catalog_Type=Automation Embedded Controller (UNO and PEC)"
                    Me.p_catalog.Controls.Add(HL)
                    Me.p_catalog.Controls.Add(New LiteralControl("</td></tr>"))
                End If
            End If
            i = i + 1
        Loop

        Me.p_catalog.Controls.Add(New LiteralControl("</table>"))
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If IsNothing("RBU") Then Response.Redirect("~/home.aspx")


            Dim cbom_org As String = Session("ORG_ID").ToString.ToUpper.Substring(0, 2)
            If Session("org_id_cbom") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom").ToString) Then
                cbom_org = Session("org_id_cbom").ToString.ToUpper.Substring(0, 2)
            End If
            If Session("ORG_ID").ToString.StartsWith("CN") Or cbom_org.StartsWith("DL") Or cbom_org.StartsWith("VN") Then
                Response.Redirect("../Lab/CBOMV2/BTOS_PortalV2.aspx")
            End If

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("Org") IsNot Nothing AndAlso Session("Org").ToString.Trim <> "" Then
            '    org = Session("Org")
            '    ' If Session("org_id").ToString = "US01" Then Response.Redirect("~/Order/btos_Portal_US.aspx")
            'End If
            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Trim <> "" Then
                org = Left(Session("org_id"), 2)
            End If


            _IsAAC = IsAAC() : BuildBtosServiceCenter()

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("Org") <> "EU" Then
            '    Me.divEContact.InnerHtml = ""
            'End If
            If Session("org_id") IsNot Nothing AndAlso Left(Session("org_id"), 2) <> "EU" Then
                Me.divEContact.InnerHtml = ""
            End If

        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" /> >
        <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx" Text="Order Tracking" />  > 
                Place System Orders
        </div>
    <br />
     <div runat="server" id="divEContact" style="text-align:right; color:#336699; font-weight:bold">Email Contact : <a href="mailto:Ebusiness.Aeu@Advantech.eu">Ebusiness.Aeu</a> / <a href="mailto:tam.tran@advantech.nl">Tam.Tran</a></div>
    <div class="menu_title">
            Place System Orders
    </div>
    <br />
    <table style="border-top: solid 1px #556b78; border-bottom: solid 1px #556b78; font-family: Arial;
        font-size: 9pt; background-color: #ebebeb" cellpadding="0" cellspacing="0" width="100%"
        border="0">
        <tr>
            <td>
                <asp:Panel runat="server" ID="p_catalog">
                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Content>
