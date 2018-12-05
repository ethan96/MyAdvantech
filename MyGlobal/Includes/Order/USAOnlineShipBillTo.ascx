<%@ Control Language="VB" ClassName="USAOnlineShipBillTo" %>
<script runat="server">    

    Private Function SearchAllSAPCompanySoldBillShipTo_MyAdvLocal(ByVal ERPID As String, ByVal Org_id As String, ByVal CompanyName As String, ByVal Address As String, ByVal State As String,
ByVal Division As String, ByVal SalesGroup As String, ByVal SalesOffice As String, Optional ByVal WhereStr As String = "", Optional Type As String = "") As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top 500 a.COMPANY_ID, a.KUNNR, a.ORG_ID, a.COMPANY_NAME, a.ADDRESS, a.COUNTRY, a.CITY,  "))
            .AppendLine(String.Format(" a.STREET, a.ZIP_CODE, a.STATE, a.CONTACT_EMAIL, a.TEL_NO, a.FAX_NO, a.ATTENTION,  "))
            .AppendLine(String.Format(" a.PARTNER_FUNCTION, a.SALESOFFICE, a.SALESGROUP, a.DIVISION, a.STR_SUPPL3 "))
            .AppendLine(String.Format(" FROM SAP_COMPANY_SHIPBILL_TO a "))
            .AppendLine(String.Format(" where 1=1 "))
            .AppendLine(String.Format(" and (a.COMPANY_ID like '%{0}%' or a.KUNNR like '%{0}%') ", Replace(Trim(ERPID), "'", "''")))
            .AppendLine(String.Format(" and a.ORG_ID='US01' "))
            If Not String.IsNullOrEmpty(State) Then .AppendLine(String.Format(" and a.STATE like N'%{0}%' ", Replace(Trim(State), "'", "''")))
            If Not String.IsNullOrEmpty(Address) Then .AppendLine(String.Format(" and a.ADDRESS like N'%{0}%' ", Replace(Trim(Address), "'", "''")))
            If Not String.IsNullOrEmpty(CompanyName) Then .AppendLine(String.Format(" and a.COMPANY_NAME like N'%{0}%' ", Replace(Trim(CompanyName), "'", "''")))
            If Not String.IsNullOrEmpty(Division) Then .AppendLine(String.Format(" and a.DIVISION='{0}' ", Replace(Trim(Division), "'", "''")))
            If Not String.IsNullOrEmpty(SalesOffice) Then .AppendLine(String.Format(" and a.SALESOFFICE='{0}' ", Replace(Trim(SalesOffice), "'", "''")))

            If Not String.IsNullOrEmpty(Type) Then
                Select Case Type
                    Case "S"
                        .Append(" AND a.PARTNER_FUNCTION = 'Ship-To' ")
                    Case "B"
                        .Append(" AND a.PARTNER_FUNCTION = 'Bill-To' ")
                    Case "EM"
                        .Append(" AND a.PARTNER_FUNCTION = 'End Customer' ")
                End Select
            Else
                '.Append(" AND A.PARVW in ('WE','AG','RE','EM') ")
            End If

            If Not String.IsNullOrEmpty(WhereStr) Then
                .AppendFormat(" AND a.company_type in ({0})", WhereStr)
            End If

            .AppendLine(String.Format(" order by a.COMPANY_ID  "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        dt.TableName = "SAPPF"
        Return dt
    End Function


    Public Function SearchAllSAPCompanySoldBillShipTo(
   ByVal ERPID As String, ByVal Org_id As String, ByVal CompanyName As String, ByVal Address As String, ByVal State As String,
   ByVal Division As String, ByVal SalesGroup As String, ByVal SalesOffice As String, ByVal SearchTerm As String, Optional ByVal WhereStr As String = "", Optional Type As String = "") As DataTable

        Dim dt As DataTable
        'Ryan 20170724 Only apply SearchAllSAPCompanySoldBillShipTo_MyAdvLocal for US01
        If Org_id.ToUpper.Equals("US01") Then
            dt = SearchAllSAPCompanySoldBillShipTo_MyAdvLocal(ERPID, Org_id, CompanyName, Address, State, Division, SalesGroup, SalesOffice, WhereStr, Type)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then Return dt
        End If

        'ICC For EU users, we don't have to join saprdp.knvv necessary, and also SalesOffice, SalesGroup, division - these three column should be empty.
        Dim isEu As Boolean = False
        If Org_id.StartsWith("EU") Then isEu = True

        'dt = New DataTable
        Dim sb As New System.Text.StringBuilder

        With sb
            If Type.Equals("EM", StringComparison.OrdinalIgnoreCase) Then
                'For AJP end customer searching, needs to select all JP01 customer ID
                If Org_id.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                    sb.Append(Advantech.Myadvantech.Business.OrderBusinessLogic.GetAJPAddressString(ERPID, CompanyName))
                Else
                    'If is not JP01, only allow to select the EM ID under ERPID.
                    sb.Append(Advantech.Myadvantech.Business.OrderBusinessLogic.GetSAPPartnerAddressString(Org_id, Session("company_id"), ERPID, CompanyName, "EM"))
                End If
            Else
                ' .AppendLine(" SELECT A.KUNN2 AS company_id, A.VKORG as ORG_ID, B.NAME1 AS COMPANY_NAME,  D.street  ||' '|| D.city1 ||' '|| D.region ||' '|| D.post_code1 ||' '|| D.country AS Address, ") 'B.STRAS AS ADDRESS,
                .AppendLine(" SELECT distinct A.KUNN2 AS company_id, A.VKORG as ORG_ID, B.NAME1 AS COMPANY_NAME, " +
                " D.street  ||' '|| D.city1 ||' '|| D.region ||' '|| D.post_code1 ||' '|| (select e.landx from saprdp.t005t e where e.land1=B.land1 and e.spras='E' and rownum=1) AS Address, ") 'B.STRAS AS ADDRESS,
                .AppendLine(" B.Land1 AS  COUNTRY,B.Ort01 AS CITY,B.STRAS as STREET,")
                .AppendLine(" B.PSTLZ AS ZIP_CODE, D.region AS STATE,  C.smtp_addr AS CONTACT_EMAIL,B.TELF1 AS TEL_NO,B.TELFX AS FAX_NO, D.NAME_CO as Attention, ")
                .AppendLine(" case A.PARVW when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' when 'RE' then 'Bill-To' end as PARTNER_FUNCTION, ")
                .AppendFormat(" {0} as SalesOffice, {1} as SalesGroup, {2} as division,D.STR_SUPPL3  ", IIf(isEu, "' '", "E.VKBUR"), IIf(isEu, "' '", "E.VKGRP"), IIf(isEu, "' '", "E.SPART"))
                .AppendLine(" FROM saprdp.kna1 B  ")
                .AppendLine(" left join saprdp.adr6 C on B.adrnr=C.addrnumber ")
                .AppendLine(" INNER JOIN  saprdp.knvp A on A.KUNN2 = B.KUNNR  ")
                .AppendFormat(" inner join saprdp.adrc D on  D.country=B.land1 and D.addrnumber=B.adrnr {0} ", IIf(isEu, "", " inner join saprdp.knvv E on B.KUNNR=E.KUNNR "))
                .AppendLine(" where  B.loevm<>'X' ")
                'ICC 2015/11/23 State, Address these two variables is always empty.
                'If Not String.IsNullOrEmpty(State) Then .AppendFormat(" and Upper(D.region) LIKE '%{0}%' ", UCase(State.Replace("'", "''").Trim))
                'If Not String.IsNullOrEmpty(Address) Then .AppendFormat(" and Upper(B.STRAS) LIKE '%{0}%' ", UCase(Address.Replace("'", "''").Trim))

                If Not String.IsNullOrEmpty(CompanyName) Then .AppendFormat(" and (Upper(B.NAME1) LIKE '%{0}%' or B.NAME2 like '%{0}%') ", UCase(CompanyName.Replace("'", "''").Trim))
                If HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("TW") Then
                    If Not String.IsNullOrEmpty(ERPID) Then .AppendFormat(" and (A.Kunnr = '{0}') ", UCase(ERPID.Replace("'", "''").Trim))
                Else
                    If Not String.IsNullOrEmpty(ERPID) Then .AppendFormat(" and (A.Kunnr LIKE '%{0}%' or A.KUNN2 like '%{0}%') ", UCase(ERPID.Replace("'", "''").Trim))
                End If
                If Not String.IsNullOrEmpty(Org_id) Then .AppendFormat(" and A.VKORG = '{0}' ", UCase(Org_id.Replace("'", "''").Trim))

                'Ryan 20180813 Add for search term (SAP customer master data field search term 1&2 )
                If Not String.IsNullOrEmpty(SearchTerm) Then .AppendFormat("  and (D.SORT1 like N'%{0}%' OR D.SORT2 LIKE N'%{0}%') ", UCase(SearchTerm.Replace("'", "''").Trim))

                'ICC 2015/11/23 Division, SalesGroup and SalesOffice these three variables is always empty.
                'If Not String.IsNullOrEmpty(Division) Then
                '    .AppendFormat(" and E.SPART = '{0}' ", UCase(Division.Replace("'", "''").Trim))
                'End If
                'If Not String.IsNullOrEmpty(SalesGroup) Then
                '    .AppendFormat(" and E.VKGRP = '{0}' ", UCase(SalesGroup.Replace("'", "''").Trim))
                'End If
                'If Not String.IsNullOrEmpty(SalesOffice) Then
                '    .AppendFormat(" and E.VKBUR = '{0}' ", UCase(SalesOffice.Replace("'", "''").Trim))
                'End If
                'If Not String.IsNullOrEmpty(Type) OrElse Type = "" Then
                If Not String.IsNullOrEmpty(Type) Then
                    Select Case Type
                        Case "S"
                            .Append(" AND A.PARVW = 'WE' ")
                        Case "B"
                            .Append(" AND A.PARVW ='RE' ")
                        Case "EM"
                            .Append(" AND A.PARVW ='EM' ")
                    End Select
                Else
                    .Append(" AND A.PARVW in ('WE','AG','RE','EM') ")
                End If
                If Not String.IsNullOrEmpty(WhereStr) Then
                    .AppendFormat(" AND B.ktokd in ({0})", WhereStr)
                End If
                .Append(" ORDER BY A.Kunn2 ")

            End If
        End With

        Try
            dt = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString(), 30)

            'Ryan 20180716 Processing for external users to remove un-relevant records due to SAP sql has performance issue.
            If Not Util.IsInternalUser2 Then
                Dim dtPartners As DataTable = dbUtil.dbGetDataTable("MY", String.Format("SELECT distinct PARENT_COMPANY_ID FROM SAP_COMPANY_PARTNERS WHERE COMPANY_ID = '{0}'", Session("company_id").ToString.Replace("'", "''").Trim))
                Dim listPartners As List(Of String) = New List(Of String)

                If dtPartners IsNot Nothing AndAlso dtPartners.Rows.Count > 0 Then
                    For Each drPartner As DataRow In dtPartners.Rows
                        If Not String.IsNullOrEmpty(drPartner("PARENT_COMPANY_ID").ToString) Then
                            listPartners.Add(drPartner("PARENT_COMPANY_ID").ToString.ToUpper)
                        End If
                    Next

                    For index As Integer = 0 To dt.Rows.Count - 1
                        Dim dr As DataRow = dt.Rows(index)
                        If Not listPartners.Contains(dr("company_id").ToString.ToUpper) Then
                            dr.Delete()
                        End If
                    Next
                    dt.AcceptChanges()
                Else
                    dt = New DataTable()
                End If
            End If
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString)
            gvBillShipTo.EmptyDataText = "System is currently busy, please wait or try again later."
        End Try

        dt.TableName = "SAPPF"
        Return dt

    End Function

    Sub GetData(Optional ByVal WhereStr As String = "", Optional Type As String = "")

        'Ryan 20170214 If type = EM and is not JP01 users, only allow to select Sold-to's EM, so disable textbox.
        If Type.Equals("EM") Then
            thERPID.Text = "End Customer ID: "
            thCompanyName.Text = "End Customer Name: "

            If Not Session("ORG_ID").ToString.Equals("JP01") Then
                'txtShipID.ReadOnly = True
                'txtShipID.BackColor = Drawing.ColorTranslator.FromHtml("#ebebe4")
                'txtShipName.ReadOnly = True
                'txtShipName.BackColor = Drawing.ColorTranslator.FromHtml("#ebebe4")
            End If
        End If

        Dim retDt As DataTable = SearchAllSAPCompanySoldBillShipTo(txtShipID.Text, Session("org_id"), txtShipName.Text, "", "", "", "", "", txtSearchTerm.Text, WhereStr, Type)

        'Ryan 20180102 Also needs to filter for BBUS
        'ICC 2015/11/23 For EU10, filter duplicate company ID and hide division, sales group, sales office three columns. This request is by Maria.Rot.
        If Not String.IsNullOrEmpty(Session("Org_ID")) AndAlso Session("Org_ID").ToString().StartsWith("EU") AndAlso retDt.Rows.Count > 0 Then
            retDt = retDt.DefaultView.ToTable(True, "company_id", "COMPANY_NAME", "ADDRESS", "PARTNER_FUNCTION", "STREET", "CITY", "STATE", "ZIP_CODE", "COUNTRY", "Attention", "TEL_NO", "STR_SUPPL3", "division", "SalesGroup", "SalesOffice")
        ElseIf Not String.IsNullOrEmpty(Session("Org_ID")) AndAlso Session("Org_ID").ToString().Equals("US10") AndAlso retDt.Rows.Count > 0 Then
            retDt = retDt.DefaultView.ToTable(True, "company_id", "COMPANY_NAME", "ADDRESS", "PARTNER_FUNCTION", "STREET", "CITY", "STATE", "ZIP_CODE", "COUNTRY", "Attention", "TEL_NO", "STR_SUPPL3", "division", "SalesGroup", "SalesOffice")
        End If
        gvBillShipTo.DataSource = retDt : gvBillShipTo.DataBind()
        Me.HiddenWhere.Value = WhereStr : Me.HiddenType.Value = Type
    End Sub

    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvBillShipTo.PageIndex = e.NewPageIndex
        GetData(Me.HiddenWhere.Value, Me.HiddenType.Value)
    End Sub

    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(0)
        Dim p As Control = Me.Parent

        'Ryan 20180511 Comment below out, align with OrderAddress.ascx logic to get address data from SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr
        'CType(p.FindControl("txtShipTo"), TextBox).Text = id
        'CType(p.FindControl("txtShipToName"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(9)
        'CType(p.FindControl("txtShipToStreet"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(1)
        'CType(p.FindControl("txtShipToStreet2"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(8)
        'CType(p.FindControl("txtShipToCity"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(2)
        'CType(p.FindControl("txtShipToState"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(3)
        'CType(p.FindControl("txtShipToZipcode"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(4)
        'CType(p.FindControl("txtShipToCountry"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(5)
        'CType(p.FindControl("txtShipToAttention"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(6)
        'CType(p.FindControl("txtShipToTel"), TextBox).Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(7)
        'Dim txtTaxJuri As TextBox = CType(p.FindControl("txtTaxJuri"), TextBox)
        'If txtTaxJuri IsNot Nothing Then
        '    'txtTaxJuri.Text = Me.gvBillShipTo.DataKeys(row.RowIndex).Values(3) + Me.gvBillShipTo.DataKeys(row.RowIndex).Values(4)
        '    'ICC 2015/9/21 Get tax juri data from SAP, not from State + Zip Code
        '    Dim Ptnrdt As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(id)
        '    If Ptnrdt.Rows.Count > 0 Then
        '        Dim PtnrRow As SAPDAL.SalesOrder.PartnerAddressesRow = Ptnrdt.Rows(0)
        '        With PtnrRow
        '            txtTaxJuri.Text = .Taxjurcode
        '        End With
        '    Else
        '        txtTaxJuri.Text = String.Empty 'ICC 2015/9/22 No tax juri data in SAP
        '    End If
        'End If
        'End Ryan 20180511 Comment out

        'Ryan 20180511 New logic applied here
        Dim Ptnrdt As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(id)
        If Ptnrdt.Rows.Count > 0 Then
            Dim PtnrRow As SAPDAL.SalesOrder.PartnerAddressesRow = Ptnrdt.Rows(0)
            With PtnrRow
                CType(p.FindControl("txtShipTo"), TextBox).Text = id
                CType(p.FindControl("txtShipToName"), TextBox).Text = .Name.ToUpper().Trim
                CType(p.FindControl("txtShipToStreet"), TextBox).Text = .Street
                CType(p.FindControl("txtShipToStreet2"), TextBox).Text = .Str_Suppl3
                CType(p.FindControl("txtShipToCity"), TextBox).Text = .City
                CType(p.FindControl("txtShipToState"), TextBox).Text = .Region_str
                CType(p.FindControl("txtShipToZipcode"), TextBox).Text = .Postl_Cod1
                CType(p.FindControl("txtShipToCountry"), TextBox).Text = .Country
                CType(p.FindControl("txtShipToAttention"), TextBox).Text = .C_O_Name
                CType(p.FindControl("txtShipToTel"), TextBox).Text = .Tel1_Numbr
                CType(p.FindControl("txtShiptoEmail"), TextBox).Text = .E_Mail
                CType(p.FindControl("txtTaxJuri"), TextBox).Text = .Taxjurcode

                If AuthUtil.IsBBUS Then
                    Dim rootParent = Me.Parent.Parent.Parent.Parent.Parent
                    Dim rootParentRBLDropShipment = CType(rootParent.FindControl("rblDropShipment"), RadioButtonList)
                    '20180725 Alex: a. soldToName <> ShiptoName b.totalamount <5000 c.is bbdropshipment user
                    Dim ordertotalamount1 As Decimal = MyCartX.GetTotalAmount(Session("cart_id"))
                    If .Name.ToUpper().Trim <> Session("company_name").ToUpper().Trim And ordertotalamount1 < 5000 And AuthUtil.IsBBDropShipmentCustomer Then
                        rootParentRBLDropShipment.Items.FindByValue("true").Selected = True
                        rootParentRBLDropShipment.Items.FindByValue("false").Selected = False
                    Else
                        rootParentRBLDropShipment.Items.FindByValue("true").Selected = False
                        rootParentRBLDropShipment.Items.FindByValue("false").Selected = True
                    End If

                    Dim taxc As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select TAXKD from saprdp.knvi where mandt='168' and kunnr='{0}' AND TATYP = 'UTXJ' and rownum = 1", id))
                    If Not taxc Is Nothing AndAlso Not String.IsNullOrEmpty(taxc.ToString) AndAlso Not CType(p.FindControl("dlTaxClassification"), DropDownList).Items.FindByValue(taxc.ToString) Is Nothing Then
                        CType(p.FindControl("dlTaxClassification"), DropDownList).ClearSelection()
                        CType(p.FindControl("dlTaxClassification"), DropDownList).Items.FindByValue(taxc.ToString).Selected = True
                    End If
                    CType(p.FindControl("drpCountry"), DropDownList).SelectedValue = .Country
                    Dim WS As New USTaxService
                    ' Get tax if country is US and taxble
                    If CType(p.FindControl("txtShipToCountry"), TextBox).Text.Equals("US") AndAlso CType(p.FindControl("dlTaxClassification"), DropDownList).SelectedValue.Equals("1") AndAlso WS.getZIPInfo(CType(p.FindControl("txtShipToZipcode"), TextBox).Text, "", "", "", True, True) Then

                        Dim taxrate As Decimal = 0
                        WS.getSalesTaxByZIP(CType(p.FindControl("txtShipToZipcode"), TextBox).Text, taxrate)

                        Dim ordertotalamount As Decimal = MyCartX.GetTotalAmount(Session("cart_id"))
                        Dim taxamount = Decimal.Round(ordertotalamount * taxrate, 2)

                        CType(rootParent.FindControl("txtBBTaxAmount"), TextBox).Text = taxamount
                        CType(rootParent.FindControl("lbBBTaxRate"), Label).Text = taxrate
                        CType(rootParent.FindControl("upBBUS"), UpdatePanel).Update()
                    Else
                        CType(rootParent.FindControl("txtBBTaxAmount"), TextBox).Text = "0"
                        CType(rootParent.FindControl("lbBBTaxRate"), Label).Text = 0
                        CType(rootParent.FindControl("upBBUS"), UpdatePanel).Update()
                    End If


                    CType(rootParent.FindControl("upBBUSDropShipment"), UpdatePanel).Update()
                End If
            End With
        End If


        CType(p.FindControl("upShipTo"), UpdatePanel).Update()
        CType(p.FindControl("MP_shipto"), AjaxControlToolkit.ModalPopupExtender).Hide()
    End Sub


    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        GetData(Me.HiddenWhere.Value, Me.HiddenType.Value)
    End Sub

    Protected Sub lnkCloseBtn_Click(sender As Object, e As System.EventArgs)
        Dim p As Control = Me.Parent
        CType(p.FindControl("MP_shipto"), AjaxControlToolkit.ModalPopupExtender).Hide()
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtShipID.Text = Session("company_id")
            'ICC 2015/11/23 For EU10, hide division, sales group, sales office three columns. This request is by Maria.Rot.
            If Not String.IsNullOrEmpty(Session("Org_ID")) AndAlso Session("Org_ID").ToString().StartsWith("EU") Then
                gvBillShipTo.Columns(5).Visible = False
                gvBillShipTo.Columns(6).Visible = False
                gvBillShipTo.Columns(7).Visible = False
            End If

            'Ryan 20180813 Search term only visible for ACN
            If AuthUtil.IsACN Then
                Me.trSearchTerm.Visible = True
            End If
        End If
    End Sub
</script>
<asp:Panel runat="server" ID="panelUSshipbillto" DefaultButton="btnSearch">
    <table width="650px">
        <tr>
            <td align="right">
                <asp:LinkButton runat="server" ID="lnkCloseBtn" Text="Close" OnClick="lnkCloseBtn_Click" />
            </td>
        </tr>
        <tr id="trSearch" runat="server">
            <td>
                <table>
                    <tr>
                        <th align="left">
                            <asp:Label runat="server" ID="thERPID" Text="Ship-to ID:"></asp:Label>
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtShipID" />
                        </td>
                        <th align="left">
                            <asp:Label runat="server" ID="thCompanyName" Text="Ship-to Name:"></asp:Label>
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtShipName" />
                        </td>
                        <td>
                            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                            <asp:HiddenField ID="HiddenWhere" runat="server" Value="" />
                            <asp:HiddenField ID="HiddenType" runat="server" Value="" />
                        </td>
                    </tr>
                    <tr id="trSearchTerm" runat="server" visible="false">
                        <th align="left">
                            <asp:Label runat="server" ID="Label1" Text="Search Term:"></asp:Label>
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtSearchTerm" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvBillShipTo" AutoGenerateColumns="false" AllowPaging="true"
                    PageIndex="0" PageSize="8" Width="100%" DataKeyNames="company_id,STREET,CITY,STATE,ZIP_CODE,COUNTRY,Attention,TEL_NO,STR_SUPPL3,COMPANY_NAME"
                    OnPageIndexChanging="GridView1_PageIndexChanging" EmptyDataText="No search results were found">
                    <Columns>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                ID
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:LinkButton runat="server" ID="lbtnPick" OnClick="lbtnPick_Click" Text='<%# Eval("company_id")%>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Name" DataField="COMPANY_NAME" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Address" DataField="ADDRESS" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Attention" DataField="Attention" />
                        <asp:BoundField HeaderText="Type" DataField="PARTNER_FUNCTION" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="Division" DataField="division" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="Sales Group" DataField="SalesGroup" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="Sales Office" DataField="SalesOffice" ItemStyle-HorizontalAlign="Center" />
                    </Columns>
                </asp:GridView>
                <asp:Label runat="server" ID="test" Text="Label" Visible="false" />
            </td>
        </tr>
    </table>
</asp:Panel>
