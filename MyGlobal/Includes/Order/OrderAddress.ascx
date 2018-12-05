<%@ Control Language="VB" ClassName="OrderAddress" %>

<%--<%@ Register Src="~/Includes/Order/ShiptoList.ascx" TagName="ShipTo" TagPrefix="uc1" %>--%>
<%@ Register Src="~/Includes/Order/USAOnlineShipBillTo.ascx" TagName="ShipToUS" TagPrefix="uc1" %>

<script runat="server">
    Private _IsCanPick As Boolean = True
    Public Property IsCanPick As Boolean
        Get
            Return _IsCanPick
        End Get
        Set(value As Boolean)
            Me._IsCanPick = value
        End Set
    End Property

    Private _editable As Boolean
    ''' <summary>
    ''' this property is only used for new bill addresss setting, set to true
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property Editable As Boolean
        Get
            Return _editable
        End Get
        Set(value As Boolean)
            Me._editable = value
            txtShipToTel.Enabled = value
            txtShipToStreet.Enabled = value
            txtShipToStreet2.Enabled = value
            txtShipToCountry.Enabled = value
            txtShipToZipcode.Enabled = value
            txtShipToState.Enabled = value
            txtShipToCity.Enabled = value
            txtShipToAttention.Enabled = value
            txtTaxJuri.Enabled = value
            txtShiptoEmail.Enabled = value
            trerpid.Visible = Not value
            If Session("company_id").ToString.Equals("ULTR00001", StringComparison.OrdinalIgnoreCase) OrElse
                MailUtil.IsInRole("Aonline.USA") Then
                'trErpName.Visible = True
                trerpid.Visible = True
                If Me.Type = "S" Then
                    txtShipToName.Enabled = True
                End If
                'Else
                'trErpName.Visible = False
            End If
        End Set
    End Property

    Private _type As String
    Public Property Type As String
        Get
            Return _type
        End Get
        Set(value As String)
            Me._type = value
        End Set
    End Property
    Protected Sub btnShipPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'If ucShipTo.Visible Then
        '    Me.ucShipTo.GetData()
        'Else
        Dim WhereStr As String = ""
        If Me.Type = "B" Then
            WhereStr = "'Z001','Z003'"
        ElseIf Me.Type = "S" Then
            WhereStr = "'Z001','Z002'"
        End If
        Me.ucShipToUS.GetData(WhereStr, Me.Type)
        'End If
        Me.up_shipto_c.Update() : Me.MP_shipto.Show()
    End Sub

    Public Property ERPID As String
        Get
            Return txtShipTo.Text
        End Get
        Set(value As String)
            txtShipTo.Text = value
        End Set
    End Property
    Public Property Name As String
        Get
            Return txtShipToName.Text
        End Get
        Set(value As String)
            txtShipToName.Text = value
        End Set
    End Property

    Public Property Attention As String
        Get
            Return txtShipToAttention.Text
        End Get
        Set(value As String)
            txtShipToAttention.Text = value
        End Set
    End Property

    Public Property Tel As String
        Get
            Return txtShipToTel.Text
        End Get
        Set(value As String)
            txtShipToTel.Text = value
        End Set
    End Property
    Public Property Street As String
        Get
            Return txtShipToStreet.Text
        End Get
        Set(value As String)
            txtShipToStreet.Text = value
        End Set
    End Property
    Public Property Street2 As String
        Get
            Return txtShipToStreet2.Text
        End Get
        Set(value As String)
            txtShipToStreet2.Text = value
        End Set
    End Property
    Public Property City As String
        Get
            Return txtShipToCity.Text
        End Get
        Set(value As String)
            txtShipToCity.Text = value
        End Set
    End Property
    Public Property State As String
        Get
            Return txtShipToState.Text.Trim.ToUpper
        End Get
        Set(value As String)
            txtShipToState.Text = value
        End Set
    End Property
    Public Property Zipcode As String
        Get
            Return txtShipToZipcode.Text
        End Get
        Set(value As String)
            txtShipToZipcode.Text = value
        End Set
    End Property
    Public Property Country As String
        Get
            Return txtShipToCountry.Text
        End Get
        Set(value As String)
            txtShipToCountry.Text = value
        End Set
    End Property
    Public Property taxJuri As String
        Get
            Return txtTaxJuri.Text.Trim.ToUpper
        End Get
        Set(ByVal value As String)
            txtTaxJuri.Text = value
        End Set
    End Property
    Public Property EMAIL As String
        Get
            Return IIf(String.IsNullOrEmpty(txtShiptoEmail.Text), String.Empty, txtShiptoEmail.Text)
        End Get
        Set(value As String)
            txtShiptoEmail.Text = value
        End Set
    End Property
    Public ReadOnly Property TaxClassification As String
        Get
            If tdTaxClassification.Visible = False AndAlso Not AuthUtil.IsBBUS Then
                Return String.Empty
            Else
                Return IIf(String.IsNullOrEmpty(dlTaxClassification.SelectedValue), String.Empty, dlTaxClassification.SelectedValue)
            End If
        End Get
    End Property

    Public ReadOnly Property IsTaxJuriValid As Boolean
        Get
            If hfIsTaxJuriValid.Value.Equals("False") Then
                Return False
            Else
                Return True
            End If
        End Get
    End Property

    Public ReadOnly Property ShipToZipCode() As TextBox
        Get
            Return Me.txtShipToZipcode
        End Get

    End Property

    Public ReadOnly Property ShipToState() As TextBox
        Get
            Return Me.txtShipToState
        End Get

    End Property

    Public ReadOnly Property ShipToCountry() As DropDownList
        Get
            Return Me.drpCountry
        End Get

    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            '20120716 TC: Show ucShipToUS for US Employees
            'If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            '    Me.ucShipToUS.Visible = True : Me.ucShipTo.Visible = False
            'Else
            '    Me.ucShipToUS.Visible = False : Me.ucShipTo.Visible = True
            'End If           

            If Not IsCanPick Then
                btnShipPick.Visible = False
            End If

            If Me.Type = "SOLDTO" OrElse Me.Type = "S" Then
                If String.IsNullOrEmpty(txtShipTo.Text.Trim) Then
                    txtShipTo.Text = Session("company_id")
                    If Me.Type = "S" Then
                        GetShiptoID()
                    End If
                End If
            End If

            ''ICC 2015/7/20 Check sold to ERP ID first, if it is in US_COMPANY_GROUP.
            'If Me.Type = "SOLDTO" Then
            '    Dim sid As Object = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 isnull(SOLD_TO_COMPANY_ID,'') as SoldToFlag from US_COMPANY_GROUP where COMPANY_ID = '{0}' ", txtShipTo.Text))
            '    If Not sid Is Nothing AndAlso Not String.IsNullOrEmpty(sid.ToString) Then
            '        If String.Equals(sid, "OriginalSoldTo", StringComparison.InvariantCultureIgnoreCase) Then
            '            Dim sql As String = String.Format(" select top 1 isnull( A.ERP_ID,'') as  ERPID  from SIEBEL_CONTACT C INNER JOIN  SIEBEL_ACCOUNT A ON A.ROW_ID=C.ACCOUNT_ROW_ID  INNER JOIN SAP_DIMCOMPANY  E ON A.ERP_ID = E.COMPANY_ID WHERE C.EMAIL_ADDRESS='{0}'", HttpContext.Current.User.Identity.Name)
            '            Dim DefaultErpID As Object = dbUtil.dbExecuteScalar("MY", sql)
            '            If DefaultErpID IsNot Nothing AndAlso Not String.IsNullOrEmpty(DefaultErpID) Then
            '                txtShipTo.Text = DefaultErpID.ToString
            '            End If
            '        Else
            '            txtShipTo.Text = sid.ToString
            '        End If
            '    End If
            'End If

            '\2013-8-26,MXT2****下單時，傳進SAP SO的sold to要替換成UUMM001，EM 要传自己的companyid
            If Util.IsMexicoT2Customer(Session("company_id").ToString, "") AndAlso Me.Type = "EM" Then
                txtShipTo.Text = Session("company_id")
            End If
            '/end

            'Ryan 20170214 Bring out the default End Customer(EM)'s information and set it to page.
            If Me.Type = "EM" Then
                btnClear.Visible = True

                'Get from eQuotation first, else get SAP default end customer ID
                Dim _Quoteid As String = String.Empty
                Dim isQuote2Cart As Boolean = MyCartX.IsQuote2Cart(Session("cart_id"), _Quoteid)
                Dim QuoteEndCustomer As String = Advantech.Myadvantech.Business.QuoteBusinessLogic.GetQuotationEndCustomer(_Quoteid)

                If isQuote2Cart AndAlso Not String.IsNullOrEmpty(QuoteEndCustomer) Then
                    txtShipTo.Text = QuoteEndCustomer
                Else
                    Dim DefaultEMID As String = String.Empty
                    Dim HasSAPEM As Boolean = Advantech.Myadvantech.Business.OrderBusinessLogic.HasSAPEndCustomer(Session("company_id").ToString, DefaultEMID)
                    If HasSAPEM AndAlso Not String.IsNullOrEmpty(DefaultEMID) Then
                        txtShipTo.Text = DefaultEMID
                    End If
                End If
            End If

            If Me.Type = "S" Then
                ' Get po number and ShipCondition for upload order
                Dim ShiptoID As String = String.Empty
                Dim retint As Integer = OrderUtilities.GetParsForUploadOrder(Session("cart_id"), ShiptoID, "", "")
                If retint = 1 Then
                    If Not String.Equals(txtShipTo.Text.Trim, ShiptoID) Then
                        If SAPDAL.SAPDAL.IsInShiptoList(ShiptoID, txtShipTo.Text.Trim) Then
                            txtShipTo.Text = ShiptoID
                        End If
                    End If
                End If

                If Util.IsInternalUser2 Then
                    'Ryan 20180410 Also enable for ADLoG users
                    'Ryan 20171024 Only enable ship-to for AJP and BBUS
                    If Session("org_id").ToString.StartsWith("JP") OrElse AuthUtil.IsBBUS OrElse AuthUtil.IsADloG Then
                        EnableAllforShipto(True)
                    End If
                Else
                    If AuthUtil.IsBBUS Then
                        EnableAllforShipto(True)
                    End If
                End If

                'Ryan 20170929 Add for BBUS tax classification settings.
                If AuthUtil.IsBBUS Then
                    If Util.IsBBCustomerCare Then
                        tdTaxClassification.Visible = True
                    End If
                    Dim taxc As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select TAXKD from saprdp.knvi where mandt='168' and kunnr='{0}' AND TATYP = 'UTXJ' and rownum = 1", txtShipTo.Text))
                    If Not taxc Is Nothing AndAlso Not String.IsNullOrEmpty(taxc.ToString) AndAlso Not Me.dlTaxClassification.Items.FindByValue(taxc.ToString) Is Nothing Then
                        Me.dlTaxClassification.ClearSelection()
                        Me.dlTaxClassification.Items.FindByValue(taxc.ToString).Selected = True
                    End If

                    'Ryan 20171129 Show country drop down
                    Me.tdCountry.Visible = False
                    Me.trDrpCountry.Visible = True

                    Dim dtCountries As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select land1, landx from saprdp.t005t where mandt='168' and spras='E' order by landx")
                    For Each d As DataRow In dtCountries.Rows
                        Me.drpCountry.Items.Add(New ListItem(String.Format("{0} ({1})", d("landx").ToString(), d("land1").ToString()), d("land1").ToString()))
                    Next
                    Me.drpCountry.Items.Insert(0, New ListItem("Select...", ""))

                    If Util.IsInternalUser2 Then
                        hlNewCustomer.Visible = True
                    End If
                End If

                Me.tdTaxJuri.Visible = True
                Me.tdEmail.Visible = True
            End If
            If Me.Type = "B" Then
                If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                    Dim billto As String = SAPDAL.SAPDAL.GetBillToNotSoldTo(Session("company_id"), Session("org_id").ToString)
                    If String.IsNullOrEmpty(txtShipTo.Text) AndAlso Not String.IsNullOrEmpty(billto) Then
                        txtShipTo.Text = billto
                    End If
                End If
            End If

            'Ryan 20171018 Type ZP & ZQ logic, currently only used by BBUS.
            If Me.Type = "ZP" OrElse Me.Type = "ZQ" Then
                tdEmail.Visible = True
                EnableAllforShipto(True)
                Me.txtShipTo.Text = Session("company_id")
            End If

            '------------------------------------------------------------------------
            'ICC 2015/7/20 Check sold to ERP ID first, if it is in US_COMPANY_GROUP.
            If Not Util.IsInternalUser2() AndAlso Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                Dim sid As Object = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 isnull(SOLD_TO_COMPANY_ID,'') as SoldToFlag from US_COMPANY_GROUP where COMPANY_ID = '{0}' ", txtShipTo.Text))
                If Not sid Is Nothing AndAlso Not String.IsNullOrEmpty(sid.ToString) Then
                    If String.Equals(sid, "OriginalSoldTo", StringComparison.InvariantCultureIgnoreCase) Then
                        Dim sql As String = String.Format(" select top 1 isnull( A.ERP_ID,'') as  ERPID  from SIEBEL_CONTACT C INNER JOIN  SIEBEL_ACCOUNT A ON A.ROW_ID=C.ACCOUNT_ROW_ID  INNER JOIN SAP_DIMCOMPANY  E ON A.ERP_ID = E.COMPANY_ID WHERE C.EMAIL_ADDRESS='{0}'", HttpContext.Current.User.Identity.Name)
                        Dim DefaultErpID As Object = dbUtil.dbExecuteScalar("MY", sql)
                        If DefaultErpID IsNot Nothing AndAlso Not String.IsNullOrEmpty(DefaultErpID) Then
                            txtShipTo.Text = DefaultErpID.ToString
                        End If
                    Else
                        txtShipTo.Text = sid.ToString
                    End If
                End If
            End If
            '-------------------------------------------------------------------------


            If Not String.IsNullOrEmpty(txtShipTo.Text.Trim) Then
                If String.IsNullOrEmpty(txtShipToName.Text.Trim) Then
                    txtShipToName.Text = getCompanyName(txtShipTo.Text.Trim)
                End If
                Dim Ptnrdt As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(txtShipTo.Text.Trim)

                If Ptnrdt.Rows.Count > 0 Then
                    Dim PtnrRow As SAPDAL.SalesOrder.PartnerAddressesRow = Ptnrdt.Rows(0)
                    With PtnrRow

                        If Not IsDBNull(.Name) AndAlso String.IsNullOrEmpty(txtShipToName.Text.Trim) Then
                            txtShipToName.Text = .Name.ToUpper().Trim
                        End If
                        If String.IsNullOrEmpty(txtShipToAttention.Text.Trim) Then
                            txtShipToAttention.Text = .C_O_Name
                        End If
                        If String.IsNullOrEmpty(txtShipToTel.Text.Trim) Then
                            txtShipToTel.Text = .Tel1_Numbr
                        End If
                        If String.IsNullOrEmpty(txtShipToStreet.Text.Trim) Then
                            txtShipToStreet.Text = .Street
                        End If
                        If String.IsNullOrEmpty(txtShipToStreet2.Text.Trim) Then
                            txtShipToStreet2.Text = .Str_Suppl3
                        End If
                        If String.IsNullOrEmpty(txtShipToCity.Text.Trim) Then
                            txtShipToCity.Text = .City
                        End If
                        If String.IsNullOrEmpty(txtShipToState.Text.Trim) Then
                            txtShipToState.Text = .Region_str
                        End If
                        If String.IsNullOrEmpty(txtShipToZipcode.Text.Trim) Then
                            txtShipToZipcode.Text = .Postl_Cod1
                        End If
                        If String.IsNullOrEmpty(txtShipToCountry.Text.Trim) Then
                            txtShipToCountry.Text = .Country
                        End If
                        If String.IsNullOrEmpty(txtTaxJuri.Text.Trim) Then
                            txtTaxJuri.Text = .Taxjurcode
                        End If
                        If String.IsNullOrEmpty(txtShiptoEmail.Text.Trim) Then
                            txtShiptoEmail.Text = .E_Mail
                        End If
                    End With
                End If

                If Me.Type = "S" AndAlso AuthUtil.IsBBUS Then
                    If Me.drpCountry.Items.FindByValue(Me.txtShipToCountry.Text) IsNot Nothing Then
                        Me.drpCountry.Items.FindByValue(Me.txtShipToCountry.Text).Selected = True
                    End If
                    SetTaxInParentASPX()
                    UpdateDropShipRBL()
                End If
            End If
        End If
    End Sub
    Function getCompanyName(ByVal Company_id As String) As String
        Dim CompanyName As Object = dbUtil.dbExecuteScalar("MY", "select top 1 isnull(company_name,'') as companyname  from SAP_DIMCOMPANY where company_id='" & Company_id & "'")
        If Not IsNothing(CompanyName) Then
            Return CompanyName
        End If
        Return ""
    End Function

    Protected Sub GetShiptoID()
        'Frank 20150805 Get account's default Ship-To part and apply it to order master
        Dim _strsql As New StringBuilder
        _strsql.AppendLine(" Select top 1 PARENT_COMPANY_ID as ShipToERPID ")
        _strsql.AppendLine(" From MyAdvantechGlobal.dbo.SAP_COMPANY_PARTNERS ")
        _strsql.AppendLine(" Where COMPANY_ID='" & Session("company_id") & "' and ORG_ID='" & Session("org_id") & "' and PARTNER_FUNCTION='WE' and DEFPA='X' ")
        Dim sid As Object = dbUtil.dbExecuteScalar("MY", _strsql.ToString)
        Dim _HavaDefault As Boolean = False
        If Not sid Is Nothing AndAlso Not String.IsNullOrEmpty(sid.ToString.Trim) Then
            _HavaDefault = True
            txtShipTo.Text = sid.ToString.Trim
        End If

        If Not _HavaDefault Then
            _strsql.Clear()
            _strsql.AppendLine(" Select top 1 PARENT_COMPANY_ID as ShipToERPID ")
            _strsql.AppendLine(" From MyAdvantechGlobal.dbo.SAP_COMPANY_PARTNERS ")
            _strsql.AppendLine(" Where COMPANY_ID='" & Session("company_id") & "' and ORG_ID='" & Session("org_id") & "' and PARTNER_FUNCTION='WE' ")
            sid = dbUtil.dbExecuteScalar("MY", _strsql.ToString)
            If Not sid Is Nothing AndAlso Not String.IsNullOrEmpty(sid.ToString.Trim) Then
                txtShipTo.Text = sid.ToString.Trim
            End If
        End If

        If AuthUtil.IsCheckPointOrder(HttpContext.Current.Session("user_id"), HttpContext.Current.Session("cart_id")) Then
            txtShipTo.Text = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoPartnerFunc_Number(Advantech.Myadvantech.Business.CPDBBusinessLogic.CheckPointOrder2Cart_getOrderNo(HttpContext.Current.Session("cart_id")), "WE")
        End If
    End Sub

    Protected Sub EnableAllforShipto(ByVal _value As Boolean)
        txtShipToName.Enabled = _value
        txtShipToStreet.Enabled = _value
        txtShipToStreet2.Enabled = _value
        txtShipToCity.Enabled = _value
        txtShipToState.Enabled = _value
        txtShipToZipcode.Enabled = _value
        'txtShipToCountry.Enabled = True        
        txtShipToAttention.Enabled = _value
        txtShipToTel.Enabled = _value
        txtShiptoEmail.Enabled = _value

        If AuthUtil.IsBBUS Then
            txtTaxJuri.Enabled = _value
            txtShipToCountry.Enabled = _value
        End If
    End Sub

    Protected Sub btnClear_Click(sender As Object, e As EventArgs)
        txtShipTo.Text = String.Empty
        txtShipToName.Text = String.Empty
        txtShipToStreet.Text = String.Empty
        txtShipToStreet2.Text = String.Empty
        txtShipToCity.Text = String.Empty
        txtShipToState.Text = String.Empty
        txtShipToZipcode.Text = String.Empty
        txtShipToCountry.Text = String.Empty
        txtTaxJuri.Text = String.Empty
        txtShipToAttention.Text = String.Empty
        txtShipToTel.Text = String.Empty
        txtShiptoEmail.Text = String.Empty
    End Sub

    Protected Sub drpCountry_SelectedIndexChanged(sender As Object, e As EventArgs)
        Me.txtShipToCountry.Text = Me.drpCountry.SelectedValue
        SetTaxInParentASPX()
    End Sub

    Protected Sub dlTaxClassification_SelectedIndexChanged(sender As Object, e As EventArgs)
        SetTaxInParentASPX()
    End Sub

    Protected Sub txtShipToState_TextChanged(sender As Object, e As EventArgs)
        Me.txtTaxJuri.Text = Me.txtShipToState.Text.Trim.ToUpper + Me.txtShipToZipcode.Text.Trim
        Me.txtShipToState.Text = Me.txtShipToState.Text.Trim.ToUpper
        SetTaxInParentASPX()
    End Sub

    Protected Sub txtShipToZipcode_TextChanged(sender As Object, e As EventArgs)
        Me.txtTaxJuri.Text = Me.txtShipToState.Text.Trim.ToUpper + Me.txtShipToZipcode.Text.Trim
        Me.txtShipToZipcode.Text = Me.txtShipToZipcode.Text.Trim
        SetTaxInParentASPX()
    End Sub

    Protected Sub txtShipToName_TextChanged(sender As Object, e As EventArgs)
        UpdateDropShipRBL()
    End Sub

    Protected Sub UpdateDropShipRBL()
        If AuthUtil.IsBBUS Then
            Dim ordertotalamount As Decimal = MyCartX.GetTotalAmount(Session("cart_id"))

            Dim rootParent = Me.Parent
            Dim rootParentRBLDropShipment = CType(rootParent.FindControl("rblDropShipment"), RadioButtonList)
            '20180725 Alex: a. soldToName <> ShiptoName b.totalamount <5000 c.is bbdropshipment user
            If txtShipToName.Text.ToUpper().Trim <> Session("company_name").ToUpper().Trim And ordertotalamount < 5000 And AuthUtil.IsBBDropShipmentCustomer Then

                rootParentRBLDropShipment.Items.FindByValue("true").Selected = True
                rootParentRBLDropShipment.Items.FindByValue("false").Selected = False
            Else
                rootParentRBLDropShipment.Items.FindByValue("true").Selected = False
                rootParentRBLDropShipment.Items.FindByValue("false").Selected = True
            End If

            CType(rootParent.FindControl("upBBUSDropShipment"), UpdatePanel).Update()
        End If

    End Sub

    Protected Sub SetTaxInParentASPX()

        If AuthUtil.IsBBUS Then
            Dim WS As New USTaxService
            ' Get tax if country is US and taxble
            If Me.txtShipToCountry.Text.Equals("US") AndAlso Me.dlTaxClassification.SelectedValue.Equals("1") AndAlso WS.getZIPInfo(Me.txtShipToZipcode.Text, "", "", "", True, True) Then

                Dim taxrate As Decimal = 0
                WS.getSalesTaxByZIP(Me.txtShipToZipcode.Text, taxrate)

                Dim ordertotalamount As Decimal = MyCartX.GetTotalAmount(Session("cart_id"))
                Dim taxamount = Decimal.Round(ordertotalamount * taxrate, 2)

                CType(Me.Parent.FindControl("txtBBTaxAmount"), TextBox).Text = taxamount
                CType(Me.Parent.FindControl("lbBBTaxRate"), Label).Text = taxrate
                CType(Me.Parent.FindControl("upBBUS"), UpdatePanel).Update()
            Else
                CType(Me.Parent.FindControl("txtBBTaxAmount"), TextBox).Text = "0"
                CType(Me.Parent.FindControl("lbBBTaxRate"), Label).Text = 0
                CType(Me.Parent.FindControl("upBBUS"), UpdatePanel).Update()
            End If
        End If
    End Sub

</script>
<asp:UpdatePanel ID="upShipTo" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <table style="padding: 2px 8px 8px 0px;">
            <tbody>
                <tr id="trerpid" runat="server">
                    <td class="h5" colspan="5">
                        <h5>ERP ID</h5>
                        <asp:TextBox runat="server" ID="txtShipTo" Style="width: auto" AutoPostBack="true" Enabled="false"></asp:TextBox>
                        <asp:Button runat="server" Text=" Pick " ID="btnShipPick" OnClick="btnShipPick_Click" />
                        <asp:Button runat="server" Text="Clear" ID="btnClear" OnClick="btnClear_Click" Visible="false" />
                        <asp:HyperLink runat="server" ID="hlNewCustomer" Text="create new customer" NavigateUrl="~/order/bborder/NewSAPAccount_ABB.aspx" Visible="false"></asp:HyperLink>
                    </td>
                </tr>
                <tr id="trErpName" runat="server">
                    <td class="h5" colspan="5">
                        <h5>Name</h5>
                        <asp:TextBox runat="server" ID="txtShipToName" Style="width: 99%" Enabled="false" onblur="return checkdate(this,'150')" AutoPostBack="true" OnTextChanged="txtShipToName_TextChanged" ></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="h5" colspan="5">
                        <h5>Address 1</h5>
                        <asp:TextBox runat="server" ID="txtShipToStreet" Style="width: 99%" Enabled="false" onblur="return checkdate(this,'35')"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="h5" colspan="5">
                        <h5>Address 2</h5>
                        <asp:TextBox runat="server" ID="txtShipToStreet2" Style="width: 99%" Enabled="false" onblur="return checkdate(this,'35')"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="h5">
                        <h5>City</h5>
                        <asp:TextBox runat="server" ID="txtShipToCity" Style="width: 60px;" Enabled="false" onblur="return checkdate(this,'50')"></asp:TextBox>
                    </td>
                    <td class="h5">
                        <h5>State</h5>
                        <asp:TextBox runat="server" ID="txtShipToState" Style="width: 35px;" Enabled="false" onblur="return checkdate(this,'10')" AutoPostBack="true" OnTextChanged="txtShipToState_TextChanged"></asp:TextBox>
                    </td>
                    <td class="h5">
                        <h5>Zipcode</h5>
                        <asp:TextBox runat="server" ID="txtShipToZipcode" Style="width: 50px;" Enabled="false" onblur="return checkdate(this,'20')" AutoPostBack="true" OnTextChanged="txtShipToZipcode_TextChanged"></asp:TextBox>
                    </td>
                    <td runat="server" id="tdTaxJuri" visible="false" class="h5">
                        <h5>Tax Juri.</h5>
                        <asp:TextBox runat="server" ID="txtTaxJuri" Style="width: 80px;" Enabled="false" onblur="return checkdate(this,'20')"></asp:TextBox>
                        <div id="divTaxMsg" style="color: Red"></div>
                        <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" TargetControlID="txtTaxJuri"
                            ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetTaxJuri" MinimumPrefixLength="2">
                        </ajaxToolkit:AutoCompleteExtender>
                    </td>
                    <td runat="server" id="tdCountry" class="h5">
                        <h5>Country</h5>
                        <asp:TextBox runat="server" ID="txtShipToCountry" Style="width: 50px;" Enabled="false" onblur="return checkdate(this,'50')"></asp:TextBox>
                    </td>
                </tr>
                <tr id="trDrpCountry" runat="server" visible="false">
                    <td class="h5" colspan="5">
                        <h5>Country</h5>
                        <asp:DropDownList runat="server" ID="drpCountry" AutoPostBack="true" OnSelectedIndexChanged="drpCountry_SelectedIndexChanged"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td class="h5" colspan="3" runat="server" id="tdAttention">
                        <h5>Attention</h5>
                        <asp:TextBox runat="server" ID="txtShipToAttention" Enabled="false" Style="width: 99%" onblur="return checkdate(this,'100')"></asp:TextBox>
                    </td>
                    <td class="h5" colspan="2" runat="server" id="tdTaxClassification" visible="false">
                        <h5>Tax Classification</h5>
                        <asp:DropDownList ID="dlTaxClassification" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SetTaxInParentASPX">
                            <asp:ListItem Value="0" Text="Exempt"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Taxable"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Exempt, Resale "></asp:ListItem>
                            <asp:ListItem Value="3" Text="Exempt, Manufact Equ "></asp:ListItem>
                            <asp:ListItem Value="4" Text="Exempt, Organization "></asp:ListItem>
                            <asp:ListItem Value="5" Text="Exempt, Freight Forwa "></asp:ListItem>
                            <asp:ListItem Value="6" Text="Exempt, Direct Pay "></asp:ListItem>
                            <asp:ListItem Value="7" Text="Exempt, Enterprise Zo "></asp:ListItem>
                            <asp:ListItem Value="8" Text="Exempt, Interstate "></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td class="h5" colspan="3" runat="server" id="tdEmail" visible="false">
                        <h5>EMail
                        </h5>
                        <asp:TextBox runat="server" ID="txtShiptoEmail" Style="width: 99%;" Enabled="false"></asp:TextBox>
                    </td>
                    <td class="h5" colspan="2">
                        <h5>Tel</h5>
                        <asp:TextBox runat="server" ID="txtShipToTel" Style="width: 99%;" Enabled="false" onblur="return checkdate(this,'100')"></asp:TextBox>
                    </td>
                </tr>
                <asp:HiddenField ID="hfIsTaxJuriValid" runat="server" Value="True" />
            </tbody>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:LinkButton runat="server" ID="lk_shipto" />
<ajaxToolkit:ModalPopupExtender runat="server" ID="MP_shipto" PopupControlID="PL_shipto"
    PopupDragHandleControlID="PL_shipto" TargetControlID="lk_shipto" BackgroundCssClass="modalBackground" />
<asp:Panel runat="server" ID="PL_shipto" BackColor="#FFFFFF" Height="80%">
    <asp:UpdatePanel runat="server" ID="up_shipto_c" UpdateMode="Conditional">
        <ContentTemplate>
            <%--   <uc1:shipto id="ucShipTo" runat="server" />--%>
            <uc1:ShipToUS ID="ucShipToUS" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Panel>
<script type="text/javascript">

    $(function () {
        $("#<%=Me.txtTaxJuri.ClientID %>").focusout(function () {
            $.ajax({
                data: JSON.stringify({ q: $("#<%=Me.txtTaxJuri.ClientID %>").val(), isCheck: "Y" }),
                type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetTaxJuri", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    if (data.d == "[]") {
                        $("#divTaxMsg").html("Tax Jurisdiction code is invalid.");
                        $('#<%=hfIsTaxJuriValid.ClientID%>').val("False");
                    } else {
                        $("#divTaxMsg").html("");
                        $('#<%=hfIsTaxJuriValid.ClientID%>').val("True");
                    }

                },
                error: function (msg) {
                    error = msg;
                    alert(msg.responseText);
                }
            });
        });

        $("#<%=Me.txtTaxJuri.ClientID %>").focusin(function () { $("#divTaxMsg").html(""); });
    });
</script>
