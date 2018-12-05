<%@ Page Title="MyAdvantech - Channel Partner Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/MyEDM.ascx" TagPrefix="uc7" TagName="MyEDM" %>
<%@ Register Src="~/Includes/CustomContent.ascx" TagName="WCustContent" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Opty/MyLeads.ascx" TagName="MyLeads" TagPrefix="uc7" %>
<%@ Register Src="~/Includes/ShipCalAjax.ascx" TagPrefix="uc1" TagName="ShipCalAjax" %>
<%@ Register Src="~/Includes/SupportBlock.ascx" TagName="SupportBlock" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Banner.ascx" TagName="Banner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/AMDbanner.ascx" TagName="AMDBanner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/eLearningBanner.ascx" TagName="eLearningBanner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/BillboardBlock.ascx" TagName="BillboardBlock" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/AENC_HomePage.ascx" TagPrefix="uc11" TagName="AENC_HomePage" %>
<script runat="server">
    Public BB_Currency As String = String.Empty

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Request.Browser.MSDomVersion.Major = 0) Then
            Response.Cache.SetNoStore()
            ' No client side cashing for non IE browsers 
        End If

        'Ryan 20160425 Save B+B gridview state
        SetGridviewCheckedState(BBGridView, "BBGridView")
        SetGridviewCheckedState(BBTGridView, "BBTGridView")
        SetGridviewCheckedState(BBIRGridView, "BBIRGridView")

        'Ryan 2016/03/22 Set upBB & upBBT Panel visible for B+B user
        If Session("company_id").ToString.Equals("ADVBBUS", StringComparison.OrdinalIgnoreCase) Then
            BB_Currency = "$"
        ElseIf Session("company_id").ToString.Equals("ADVBBIR", StringComparison.OrdinalIgnoreCase) OrElse Util.IsAEUIT() Then
            BB_Currency = "€"
        End If

        If Not Page.IsPostBack Then

            '2014/1/23 JJ：新增 Session("user_id") is nothing 判斷
            If Session("user_id") Is Nothing AndAlso User.Identity.Name Is Nothing Then
                Session.Abandon() : FormsAuthentication.SignOut() : Server.Transfer("~/Logout.aspx")
            Else
                If Session("user_id") Is Nothing Then
                    Session("user_id") = User.Identity.Name
                End If
            End If

            If Session("account_status").ToString() <> "CP" AndAlso Session("account_status").ToString() <> "EZ" Then
                Response.Redirect("home.aspx")
            End If
            Me.Master.EnableAsyncPostBackHolder = False

            'Show ePricer for Broadwin employees
            If Session("company_id") = "T80087921" Then hyePricer.Visible = True

            'Ryan 2016/03/22 Set upBB & upBBT Panel visible for B+B user
            If Session("company_id").ToString.Equals("ADVBBUS", StringComparison.OrdinalIgnoreCase) Then
                upBB.Visible = True
                upBBT.Visible = True
            ElseIf Session("company_id").ToString.Equals("ADVBBIR", StringComparison.OrdinalIgnoreCase) OrElse Util.IsAEUIT() Then
                upBBIR.Visible = True
            End If

            'Ryan 20160425 Define B+B viewstate
            ViewState("BBGridView") = New Dictionary(Of String, String)
            ViewState("BBTGridView") = New Dictionary(Of String, String)
            ViewState("BBIRGridView") = New Dictionary(Of String, String)

            'Me.SrcAddedPN.SelectCommand = GetAddedPNSql()

            'If Session("user_id") IsNot Nothing AndAlso Util.IsInternalUser(Session("user_id")) Then
            'Else
            '    'LiT20_br.Visible = False : LiT20.Visible = False
            'End If

            'Frank 2012/05/22:Channel Insight link buttons for CP AEU user.
            'If Session("org_id") IsNot Nothing AndAlso Session("org_id") = "EU10" Then
            'Me.ucChannelInsightLink.Visible = True
            'End If

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.ToUpper = "US" Then
            If Session("ORG_ID") IsNot Nothing AndAlso Left(Session("ORG_ID").ToString.ToUpper, 2) = "US" Then

                LiT29TR.Visible = False : Ecard_ATR.Visible = False : hyEMarketing.NavigateUrl = "http://www.advantech-eautomation.com/emarketingprograms/ChannelPartner/Channel_Partner_ppt/Advantech_IA_EDMs.htm"

                'Frank remark old code
                'If Session("RBU") = "AAC" Then
                '    'hyDAQ.ImageUrl = "~/Images/TPC-650H_promo_banner_MyAdv.gif"
                '    'hlBanner.ImageUrl = "~/Images/HMI Series_623x110.gif" 'hlBanner.NavigateUrl = "http://www.advantech-eautomation.com/emarketingprograms/automationlink/2010/dec/million/millionka-1.htm"
                'Else
                '    If Session("RBU") = "AENC" Then
                '        lnkMyBO.Visible = False : lnkCartHistory.Visible = False : btnWiki.Visible = False : up1.Visible = False
                '    End If
                'End If

                Select Case Session("RBU")

                    Case "AENC"
                        Me.MultiView1.ActiveViewIndex = 1
                        Dim _aenc As New AENC_HomePage
                        Me.MultiView1.Views(1).Controls.Add(_aenc)

                        lnkMyBO.Visible = False : lnkCartHistory.Visible = False : btnWiki.Visible = False : up1.Visible = False

                        'Me.RemovedControl(Me.SrcAddedPN)
                        'Me.RemovedControl(Me.gvAddedPN)
                        'Me.RemovedControl(Me.MyLeads1)
                        'Me.RemovedControl(Me.gv1)                        
                End Select
            End If

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Not Session("ORG").ToString.StartsWith("US", StringComparison.OrdinalIgnoreCase) Then
            '    hyMyRegPrj.NavigateUrl = "~/My/InterCon/MyPrjList.aspx" : hyPrjReg.NavigateUrl = "~/My/InterCon/PrjReg.aspx"
            'End If
            If Session("ORG_ID") IsNot Nothing AndAlso Not Session("ORG_ID").ToString.ToUpper.StartsWith("US", StringComparison.OrdinalIgnoreCase) Then
                hyMyRegPrj.NavigateUrl = "~/My/InterCon/MyPrjList.aspx" : hyPrjReg.NavigateUrl = "~/My/InterCon/PrjReg.aspx"
            End If

            'Alex 2016/05/24取消以下判斷  只要能進來home_cp的帳號都可以看到trProjectRegist/trProjectRegistlist等連結
            'JJ 2014/3/10 home頁只要是下列company ID："EURA004", "EGBR001", "ELVE001", "ELTG002", "EKZI003", "AHKP006", "ERUP002", "EURP001", "EURP011", "EUAJ001", "EURS006"的就隱藏
            'If Session("company_id") IsNot Nothing AndAlso Util.NoShowProjectRegistrationUser(Session("company_id")) Then
            '    trProjectRegist.Visible = False : trProjectRegistlist.Visible = False
            'End If

            'JJ 2014/4/16 Liliana/Adam那邊要求隱藏北美的Points Request
            Dim org As String = Session("org_id").ToString.Substring(0, 2)
            If AuthUtil.IsInterConUserV2() Then
                org = "InterCon"
            End If

            If org = "US" Then
                Me.tr_Point.Visible = False
            End If

            'IC 2014/06/26 Selina.Shin ask all AKR's CP can not see hyEUGATP link (Check ACL Avaliability)
            If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("KR", StringComparison.OrdinalIgnoreCase) Then
                tdHead.Visible = False
                tdhyEUGATP.Visible = False
            End If

            '20131028 Open Advanced Product search to all CP
            trAdvProdSearch.Visible = True
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then           
            If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                trQuoteHistory.Visible = True : hyEMarketing.NavigateUrl = "~/EC/eMarketingEDMEU.aspx"
                'hyMyRegPrj.Visible = False : hyPrjReg.Visible = False

                'IC 2014/07/28 Stop using hard code to control changing ERP ID. Change this function to MyMaster.master
                'If User.Identity.Name.Equals("bbriani@arroweurope.com", StringComparison.OrdinalIgnoreCase) OrElse _
                '   User.Identity.Name.Equals("vfeletti@arroweurope.com", StringComparison.OrdinalIgnoreCase) Then

                '    trChgCompIdSILVERSTAR.Visible = True
                '    dlChangeCompanyMultiErpId.Items.Clear()
                '    Dim items() As ListItem = { _
                '        New ListItem("SILVERSTAR S.R.L.", "EIITSI04"), _
                '        New ListItem("ARROW NORDIC COMPONENTS AB", "ENSEAR02"), _
                '        New ListItem("ARROW CENTRAL EUROPE GMBH", "EDDEAR09")}
                '    For Each li As ListItem In items
                '        If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                '            li.Selected = True
                '        End If
                '        dlChangeCompanyMultiErpId.Items.Add(li)
                '    Next
                'Else
                '    If User.Identity.Name.Equals("acantoni@irenesrl.it", StringComparison.OrdinalIgnoreCase) _
                '        OrElse User.Identity.Name.Equals("damele@irenesrl.it", StringComparison.OrdinalIgnoreCase) Then
                '        trChgCompIdSILVERSTAR.Visible = True
                '        dlChangeCompanyMultiErpId.Items.Clear()
                '        Dim items() As ListItem = { _
                '            New ListItem("IRENE S.R.L. (EIITIR01)", "EIITIR01"), _
                '            New ListItem("IRENE S.R.L. (EIITIR03)", "EIITIR03")}
                '        For Each li As ListItem In items
                '            If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                '                li.Selected = True
                '            End If
                '            dlChangeCompanyMultiErpId.Items.Add(li)
                '        Next
                '    Else
                '        If User.Identity.Name.Equals("freya.huggard@ecauk.com", StringComparison.OrdinalIgnoreCase) OrElse User.Identity.Name.Equals("ali.oliver@ecauk.com", StringComparison.OrdinalIgnoreCase) Then
                '            trChgCompIdSILVERSTAR.Visible = True
                '            dlChangeCompanyMultiErpId.Items.Clear()
                '            Dim items() As ListItem = { _
                '                New ListItem("ECA Services (EKGBEC01)", "EKGBEC01"), _
                '                New ListItem("ECA Services (EKGBEC02)", "EKGBEC02"), _
                '                New ListItem("ECA Services (EKGBEC03)", "EKGBEC03"), _
                '                New ListItem("ECA Services (EKGBEC04)", "EKGBEC04"), _
                '                New ListItem("ECA Services (EKGBEC05)", "EKGBEC05"), _
                '                New ListItem("ECA Services (EKGBEC06)", "EKGBEC06"), _
                '                New ListItem("ECA Services (EKGBEC07)", "EKGBEC07"), _
                '                New ListItem("ECA Services (EKGBEC08)", "EKGBEC08")}
                '            For Each li As ListItem In items
                '                If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                '                    li.Selected = True
                '                End If
                '                dlChangeCompanyMultiErpId.Items.Add(li)
                '            Next
                '        End If
                '    End If
                '    If User.Identity.Name.Equals("c.bruttomesso@digimax.it", StringComparison.OrdinalIgnoreCase) _
                '        OrElse User.Identity.Name.Equals("l.gabrieletto@digimax.it", StringComparison.OrdinalIgnoreCase) _
                '        OrElse User.Identity.Name.Equals("d.scalabrin@digimax.it", StringComparison.OrdinalIgnoreCase) Then
                '        trChgCompIdSILVERSTAR.Visible = True
                '        dlChangeCompanyMultiErpId.Items.Clear()
                '        Dim items() As ListItem = { _
                '            New ListItem("DIGIMAX SRL (EIITDI01)", "EIITDI01"), _
                '            New ListItem("DIGIMAX SRL (EIITDI23)", "EIITDI23"), _
                '            New ListItem("DIGIMAX Srl (EIITDI26)", "EIITDI26")}
                '        For Each li As ListItem In items
                '            If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                '                li.Selected = True
                '            End If
                '            dlChangeCompanyMultiErpId.Items.Add(li)
                '        Next
                '    End If
                'End If
            End If
            'ICC 2015/8/6 Champion club is no longer valid
            'If Util.IsPCPUser() Then trChampion.Visible = True : trChampion2.Visible = True
            If String.Equals(Session("company_id"), "AIDE001") _
                OrElse String.Equals(Session("company_id"), "SIE002") _
                OrElse String.Equals(Session("company_id"), "MKM028") _
                OrElse String.Equals(Session("company_id"), "AMLE002") _
                OrElse String.Equals(Session("company_id"), "MPX001") Then
                TrMyDB.Visible = True
            Else
                TrMyDB.Visible = False
            End If

            If Util.IsAEUIT() OrElse Util.IsPCP_Marcom(Session("user_id").ToString, "") Then
                trMarcom.Visible = True
            End If

            If Util.IsInternalUser(Session("user_id")) = False Then
                If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then
                    trUpdOrder.Visible = False

                    'Ryan 20170316 Hide Quotation History link if user has no permission to place order
                    If AuthUtil.IsCanSeeCost(Session("user_id")) = False Then
                        trQuoteHistory.Visible = False
                    End If
                End If
            End If

            'Alex 20180314 Tracy ask to hide some information for US10 
            If AuthUtil.IsBBUS Then
                trSysConfig_Orders.Visible = False
                trFuncToolsTitle.Visible = False
                trFuncTools.Visible = False
            End If
        End If
    End Sub

#Region "B+B Selected Items"
    Protected Sub TimerBB_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerBB.Interval = 99999

        Dim dt As DataTable = BB_GetDT()
        If dt.Rows.Count > 0 Then
            BBGridView.DataSource = dt
            BBGridView.DataBind()
        End If
        TimerBB.Enabled = False
        ImageBB.Visible = False
    End Sub

    Protected Function BB_GetDT() As DataTable
        'use cache mechanism
        Dim BBDT As DataTable = System.Web.HttpRuntime.Cache("BBDT")
        If BBDT Is Nothing Then
            BBDT = New DataTable
            Dim epricer_str As String = "SELECT Item_No FROM Item_TPart_ITP_Master where Customer_ID = 'ADVBBUS' and Approval_No <> 'T0007548'"
            Dim epricer_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("ACLSQL7", epricer_str)
            Dim str_partno As String = String.Empty

            '先從SQL7 epricer 取得所有符合之料號，並做成一個字串待後續select條件使用
            If epricer_dt.Rows.Count > 0 Then
                Dim a As New ArrayList
                For Each r As DataRow In epricer_dt.Rows
                    a.Add("'" + r.Item("Item_No") + "'")
                Next
                str_partno = "(" + String.Join(",", a.ToArray()) + ")"
            End If

            '用剛剛組合好的料號集合在SQL6的SAP_Product撈PRODUCT_DESC
            Dim sapproduct_str As String = "SELECT a.PART_NO, a.PRODUCT_DESC from SAP_PRODUCT a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
                " on a.PART_NO = b.PART_NO WHERE a.PART_NO IN " & str_partno & " and b.SALES_ORG = 'TW01' "
            Dim sapproduct_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("MY", sapproduct_str)

            '組合一個string去SAP內撈內部料號，因Oracle DB限定in至多一千個，處理較繁瑣
            Dim ls As List(Of String) = New List(Of String)
            For Each r As DataRow In sapproduct_dt.Rows
                ls.Add("'" + r.Item("PART_NO") + "'")
            Next
            Dim bbinternal_dt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr = ''")

            For i As Integer = 0 To Math.Floor(ls.Count / 1000) Step 1
                If ls.Count - i * 1000 = 0 Then
                    Continue For
                ElseIf ls.Count - i * 1000 < 1000 Then
                    str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, ls.Count - i * 1000).ToArray()) + ")"
                Else
                    str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, 1000).ToArray()) + ")"
                End If

                Dim bbinternal_str As String = "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr in " + str_partno
                Dim bbinternal_tempdt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", bbinternal_str)
                bbinternal_dt.Merge(bbinternal_tempdt)
            Next

            ' 將sapproduct_dt 與 bbinternal_dt 兩張 dt 用 partno left join起來
            Dim temp = From x In sapproduct_dt.AsEnumerable
                       Group Join y In bbinternal_dt.AsEnumerable
                       On x.Field(Of String)("PART_NO") Equals y.Field(Of String)("matnr")
                       Into Group
                       Let y = Group.FirstOrDefault
                       Select PART_NO = x.Field(Of String)("PART_NO"),
                       PRODUCT_DESC = x.Field(Of String)("PRODUCT_DESC"),
                       KDMAT = If(y Is Nothing, Nothing, y.Field(Of String)("kdmat"))

            BBDT.Columns.Add("PART_NO", Type.GetType("System.String"))
            BBDT.Columns.Add("PRODUCT_DESC", Type.GetType("System.String"))
            BBDT.Columns.Add("kdmat", Type.GetType("System.String"))

            For Each item In temp
                Dim dr As DataRow = BBDT.NewRow
                dr.Item("PART_NO") = item.PART_NO
                dr.Item("PRODUCT_DESC") = item.PRODUCT_DESC
                dr.Item("kdmat") = item.KDMAT
                BBDT.Rows.Add(dr)
            Next

            'PartNO 與 desc.準備好後，去SAP撈unit_price
            BBDT.Columns.Add("unit_price", Type.GetType("System.String"))
            Dim ws As New MYSAPDAL
            Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            For Each r As DataRow In BBDT.Rows
                pin.AddProductInRow(r.Item("part_no"), 1)
            Next
            If ws.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), pin, pout, errMsg) Then
                For Each r As DataRow In BBDT.Rows
                    Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                        r.Item("unit_price") = BB_Currency + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                    End If
                Next
            End If

            'Remove parts which unit_price is 0
            Dim BBDT_Copy As DataTable = BBDT.Copy
            BBDT.Clear()
            For Each d As DataRow In BBDT_Copy.Rows
                If Decimal.Parse(Replace(d.Item("unit_price").ToString, BB_Currency, "")) > 0 Then
                    BBDT.ImportRow(d)
                End If
            Next

            System.Web.HttpRuntime.Cache.Add("BBDT", BBDT, Nothing, Now.AddHours(6), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        ViewState("BBDT") = BBDT
        Return BBDT
    End Function

    Protected Sub BBGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs)

    End Sub

    Protected Sub BBGridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        BBGridView.PageIndex = e.NewPageIndex
        Dim dt As DataTable = ViewState("BBDT")
        BBGridView.DataSource = dt
        BBGridView.DataBind()
        GetGridviewCheckedState(BBGridView, "BBGridView")
    End Sub

    Protected Sub BBGridView_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        GridViewSortExpression = e.SortExpression

        If (Not IsNothing(ViewState("SortDirection"))) Then
            If (ViewState("SortDirection").ToString.Equals("ASC")) Then
                ViewState("SortDirection") = "DESC"
            Else
                ViewState("SortDirection") = "ASC"
            End If
        Else
            ViewState("SortDirection") = "DESC"
        End If

        Dim dv As DataView = New DataView(BB_GetDT())
        dv.Sort = String.Format("{0} {1}", GridViewSortExpression, ViewState("SortDirection"))
        ViewState("BBDT") = dv.ToTable

        BBGridView.DataSource = dv
        BBGridView.DataBind()
        GetGridviewCheckedState(BBGridView, "BBGridView")
    End Sub

    Protected Sub BBSearch_Click(sender As Object, e As EventArgs)
        Dim search_type As String = BBDropDownList.SelectedValue
        Dim search_condition As String = BBTextBox.Text
        Dim dv As DataView = New DataView(ViewState("BBDT"))

        If Not String.IsNullOrEmpty(search_condition) Then
            Select Case search_type
                Case "1"
                    dv.RowFilter = String.Format("PART_NO like '%" & search_condition & "%'")
                Case "2"
                    dv.RowFilter = String.Format("PRODUCT_DESC like '%" & search_condition & "%'")
                Case "3"
                    dv.RowFilter = String.Format("kdmat like '%" & search_condition & "%'")
            End Select
        End If
        BBGridView.DataSource = dv
        BBGridView.DataBind()
        GetGridviewCheckedState(BBGridView, "BBGridView")
    End Sub

    Protected Sub BBAdd2Cart_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Gridview2Cart(BBGridView, "BBGridView")
    End Sub
#End Region

#Region "B+B T Parts"
    Protected Sub TimerBBT_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerBBT.Interval = 99999

        Dim dt As DataTable = BBT_GetDT()
        If dt.Rows.Count > 0 Then
            BBTGridView.DataSource = dt
            BBTGridView.DataBind()
        End If
        TimerBBT.Enabled = False
        ImageBBT.Visible = False
    End Sub

    Protected Function BBT_GetDT() As DataTable
        'use cache mechanism
        Dim BBTDT As DataTable = System.Web.HttpRuntime.Cache("BBTDT")
        If BBTDT Is Nothing Then
            BBTDT = New DataTable
            Dim epricer_str As String = "SELECT Item_No FROM Item_TPart_ITP_Master where Customer_ID = 'ADVBBUS' and Approval_No <> 'T0007548'"
            Dim epricer_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("ACLSQL7", epricer_str)
            Dim str_partno As String = String.Empty

            '先從SQL7 epricer 取得所有符合之料號，並做成一個字串待後續select條件使用
            If epricer_dt.Rows.Count > 0 Then
                Dim a As New ArrayList
                For Each r As DataRow In epricer_dt.Rows
                    a.Add("'" + r.Item("Item_No") + "'")
                Next
                str_partno = "(" + String.Join(",", a.ToArray()) + ")"
            End If

            '用剛剛組合好的料號集合在SQL6的SAP_Product撈PRODUCT_DESC
            Dim sapproduct_str As String = "SELECT a.PART_NO, a.PRODUCT_DESC from SAP_PRODUCT a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
                "on a.PART_NO = b.PART_NO WHERE a.PART_NO IN " & str_partno &
                " and a.MATERIAL_GROUP in ('ODM','T') and b.SALES_ORG = 'TW01'"
            Dim sapproduct_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("MY", sapproduct_str)

            '組合一個string去SAP內撈內部料號，因Oracle DB限定in至多一千個，處理較繁瑣
            Dim ls As List(Of String) = New List(Of String)
            For Each r As DataRow In sapproduct_dt.Rows
                ls.Add("'" + r.Item("PART_NO") + "'")
            Next
            Dim bbinternal_dt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr = ''")

            For i As Integer = 0 To Math.Floor(ls.Count / 1000) Step 1
                If ls.Count - i * 1000 = 0 Then
                    Continue For
                ElseIf ls.Count - i * 1000 < 1000 Then
                    str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, ls.Count - i * 1000).ToArray()) + ")"
                Else
                    str_partno = "(" + String.Join(",", ls.GetRange(i * 1000, 1000).ToArray()) + ")"
                End If

                Dim bbinternal_str As String = "select matnr, kdmat from saprdp.knmt where kunnr='ADVBBUS' and matnr in " + str_partno
                Dim bbinternal_tempdt As DataTable = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", bbinternal_str)
                bbinternal_dt.Merge(bbinternal_tempdt)
            Next

            ' 將sapproduct_dt 與 bbinternal_dt 兩張 dt 用 partno left join起來
            Dim temp = From x In sapproduct_dt.AsEnumerable
                       Group Join y In bbinternal_dt.AsEnumerable
                       On x.Field(Of String)("PART_NO") Equals y.Field(Of String)("matnr")
                       Into Group
                       Let y = Group.FirstOrDefault
                       Select PART_NO = x.Field(Of String)("PART_NO"),
                       PRODUCT_DESC = x.Field(Of String)("PRODUCT_DESC"),
                       KDMAT = If(y Is Nothing, Nothing, y.Field(Of String)("kdmat"))

            BBTDT.Columns.Add("PART_NO", Type.GetType("System.String"))
            BBTDT.Columns.Add("PRODUCT_DESC", Type.GetType("System.String"))
            BBTDT.Columns.Add("kdmat", Type.GetType("System.String"))

            For Each item In temp
                Dim dr As DataRow = BBTDT.NewRow
                dr.Item("PART_NO") = item.PART_NO
                dr.Item("PRODUCT_DESC") = item.PRODUCT_DESC
                dr.Item("kdmat") = item.KDMAT
                BBTDT.Rows.Add(dr)
            Next

            'PartNO 與 desc.準備好後，去SAP撈unit_price
            BBTDT.Columns.Add("unit_price", Type.GetType("System.String"))
            Dim ws As New MYSAPDAL
            Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            For Each r As DataRow In BBTDT.Rows
                pin.AddProductInRow(r.Item("part_no"), 1)
            Next

            If ws.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), pin, pout, errMsg) Then
                For Each r As DataRow In BBTDT.Rows
                    Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                        r.Item("unit_price") = BB_Currency + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                    End If
                Next
            End If

            'Remove parts which unit_price is 0
            Dim BBTDT_Copy As DataTable = BBTDT.Copy
            BBTDT.Clear()
            For Each d As DataRow In BBTDT_Copy.Rows
                If Decimal.Parse(Replace(d.Item("unit_price").ToString, BB_Currency, "")) > 0 Then
                    BBTDT.ImportRow(d)
                End If
            Next

            System.Web.HttpRuntime.Cache.Add("BBTDT", BBTDT, Nothing, Now.AddHours(6), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        ViewState("BBTDT") = BBTDT
        Return BBTDT
    End Function

    Protected Sub BBTGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs)

    End Sub

    Protected Sub BBTGridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        BBTGridView.PageIndex = e.NewPageIndex
        Dim dt As DataTable = ViewState("BBTDT")
        BBTGridView.DataSource = dt
        BBTGridView.DataBind()
        GetGridviewCheckedState(BBTGridView, "BBTGridView")
    End Sub

    Protected Sub BBTGridView_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        GridViewSortExpression = e.SortExpression

        If (Not IsNothing(ViewState("SortDirection"))) Then
            If (ViewState("SortDirection").ToString.Equals("ASC")) Then
                ViewState("SortDirection") = "DESC"
            Else
                ViewState("SortDirection") = "ASC"
            End If
        Else
            ViewState("SortDirection") = "DESC"
        End If

        Dim dv As DataView = New DataView(BBT_GetDT())
        dv.Sort = String.Format("{0} {1}", GridViewSortExpression, ViewState("SortDirection"))
        ViewState("BBTDT") = dv.ToTable

        BBTGridView.DataSource = dv
        BBTGridView.DataBind()
        GetGridviewCheckedState(BBTGridView, "BBTGridView")
    End Sub

    Protected Sub BBTSearch_Click(sender As Object, e As EventArgs)
        Dim search_type As String = BBTDropDownList.SelectedValue
        Dim search_condition As String = BBTTextBox.Text
        Dim dv As DataView = New DataView(ViewState("BBTDT"))

        If Not String.IsNullOrEmpty(search_condition) Then
            Select Case search_type
                Case "1"
                    dv.RowFilter = String.Format("PART_NO like '%" & search_condition & "%'")
                    'Ryan 20160622 If searching result is empty, go to ePricer and search again
                    If dv.Count = 0 Then
                        Dim search_again As Boolean = BBT_SearchAgain(search_condition)
                        If search_again Then
                            dv = New DataView(ViewState("BBTDT"))
                            dv.RowFilter = String.Format("PART_NO like '%" & search_condition & "%'")
                        End If
                    End If
                Case "2"
                    dv.RowFilter = String.Format("PRODUCT_DESC like '%" & search_condition & "%'")
                Case "3"
                    dv.RowFilter = String.Format("kdmat like '%" & search_condition & "%'")
            End Select
        End If
        BBTGridView.DataSource = dv
        BBTGridView.DataBind()
        GetGridviewCheckedState(BBTGridView, "BBTGridView")
    End Sub

    Protected Sub BBTAdd2Cart_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Gridview2Cart(BBTGridView, "BBTGridView")
    End Sub

    Protected Function BBT_SearchAgain(ByVal searchterm As String) As Boolean
        Dim BBTDT As DataTable = Cache("BBTDT")

        Dim epricer_str As String = "SELECT Item_No FROM Item_TPart_ITP_Master where Customer_ID = 'ADVBBUS' and Approval_No <> 'T0007548' and Item_No = '" + searchterm + "'"
        Dim epricer_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("ACLSQL7", epricer_str)
        '若精確比對沒有結果，則離開
        If epricer_dt.Rows.Count = 0 Then
            Return False
        End If

        '去SQL6的SAP_Product撈PRODUCT_DESC
        Dim sapproduct_str As String = "SELECT a.PART_NO, a.PRODUCT_DESC from SAP_PRODUCT a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
            "on a.PART_NO = b.PART_NO WHERE a.PART_NO = '" + searchterm + "' " + _
            " and a.MATERIAL_GROUP in ('ODM','T') and b.SALES_ORG = 'TW01'"
        Dim sql6_dt As DataTable = Advantech.Myadvantech.DataAccess.SqlProvider.dbGetDataTable("MY", sapproduct_str)
        '若精確比對沒有結果，則離開
        If sql6_dt.Rows.Count = 0 Then
            Return False
        End If

        'PartNO 與 desc.準備好後，去SAP撈unit_price
        Dim ws As New MYSAPDAL
        Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
        pin.AddProductInRow(searchterm, 1)

        Dim price As String = String.Empty
        If ws.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), pin, pout, errMsg) Then
            Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + searchterm + "'")
            If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                price = BB_Currency + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
            Else
                Return False
            End If
        End If

        If Decimal.Parse(Replace(price, BB_Currency, "")) = 0 Then
            Return False
        End If

        Dim dr = BBTDT.NewRow()
        dr.Item("part_no") = searchterm
        dr.Item("PRODUCT_DESC") = sql6_dt.Rows(0).Item("PRODUCT_DESC").ToString
        dr.Item("unit_price") = price
        BBTDT.Rows.Add(dr)

        Cache.Add("BBTDT", BBTDT, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        ViewState("BBTDT") = BBTDT

        BBTGridView.DataSource = BBTDT
        BBTGridView.DataBind()
        Return True
    End Function

#End Region

#Region "B+B Ireland T Parts"
    Protected Sub TimerBBIR_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerBBIR.Interval = 99999

        Dim dt As DataTable = BBIR_GetDT()
        If dt.Rows.Count > 0 Then
            BBIRGridView.DataSource = dt
            BBIRGridView.DataBind()
        End If
        TimerBBIR.Enabled = False
        ImageBBIR.Visible = False
    End Sub

    Protected Function BBIR_GetDT() As DataTable
        Dim BB_ERPID As String = "ADVBBIR"

        'use cache mechanism
        Dim BBIRDT As DataTable = System.Web.HttpRuntime.Cache("BBIRDT")
        If BBIRDT Is Nothing Then
            BBIRDT = New DataTable
            Dim knmt_str As String = "select a.MATNR as Part_No,b.MAKTG as PRODUCT_DESC ,a.KDMAT " + _
                                     " from saprdp.knmt a left join saprdp.makt b " + _
                                     " on a.matnr = b.matnr where a.kunnr = '" + BB_ERPID + "' and b.spras = 'E'"
            BBIRDT = Advantech.Myadvantech.DataAccess.OracleProvider.GetDataTable("SAP_PRD", knmt_str)

            'PartNO 與 desc.準備好後，去SAP撈unit_price
            BBIRDT.Columns.Add("unit_price", Type.GetType("System.String"))
            Dim ws As New MYSAPDAL
            Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            For Each r As DataRow In BBIRDT.Rows
                pin.AddProductInRow(r.Item("part_no"), 1)
            Next

            If ws.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), pin, pout, errMsg) Then
                For Each r As DataRow In BBIRDT.Rows
                    Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) Then
                        r.Item("unit_price") = BB_Currency + FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                    End If
                Next
            End If

            'Remove parts which unit_price is 0
            Dim BBIRDT_Copy As DataTable = BBIRDT.Copy
            BBIRDT.Clear()
            For Each d As DataRow In BBIRDT_Copy.Rows
                If Decimal.Parse(Replace(d.Item("unit_price").ToString, BB_Currency.ToString(), "")) > 0 Then
                    BBIRDT.ImportRow(d)
                End If
            Next

            System.Web.HttpRuntime.Cache.Add("BBIRDT", BBIRDT, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        ViewState("BBIRDT") = BBIRDT
        Return BBIRDT
    End Function

    Protected Sub BBIRGridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        BBIRGridView.PageIndex = e.NewPageIndex
        Dim dt As DataTable = ViewState("BBIRDT")
        BBIRGridView.DataSource = dt
        BBIRGridView.DataBind()
        GetGridviewCheckedState(BBIRGridView, "BBIRGridView")
    End Sub

    Protected Sub BBIRGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs)

    End Sub

    Protected Sub BBIRGridView_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        GridViewSortExpression = e.SortExpression

        If (Not IsNothing(ViewState("SortDirection"))) Then
            If (ViewState("SortDirection").ToString.Equals("ASC")) Then
                ViewState("SortDirection") = "DESC"
            Else
                ViewState("SortDirection") = "ASC"
            End If
        Else
            ViewState("SortDirection") = "DESC"
        End If

        Dim dv As DataView = New DataView(BBIR_GetDT())
        dv.Sort = String.Format("{0} {1}", GridViewSortExpression, ViewState("SortDirection"))
        ViewState("BBIRDT") = dv.ToTable

        BBIRGridView.DataSource = dv
        BBIRGridView.DataBind()
        GetGridviewCheckedState(BBIRGridView, "BBIRGridView")
    End Sub

    Protected Sub BBIRSearch_Click(sender As Object, e As EventArgs)
        Dim search_type As String = BBIRDropDownList.SelectedValue
        Dim search_condition As String = BBIRTextBox.Text
        Dim dv As DataView = New DataView(ViewState("BBIRDT"))

        If Not String.IsNullOrEmpty(search_condition) Then
            Select Case search_type
                Case "1"
                    dv.RowFilter = String.Format("PART_NO like '%" & search_condition & "%'")
                Case "2"
                    dv.RowFilter = String.Format("PRODUCT_DESC like '%" & search_condition & "%'")
                Case "3"
                    dv.RowFilter = String.Format("kdmat like '%" & search_condition & "%'")
            End Select
        End If
        BBIRGridView.DataSource = dv
        BBIRGridView.DataBind()
        GetGridviewCheckedState(BBIRGridView, "BBIRGridView")
    End Sub

    Protected Sub BBIRAdd2Cart_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Gridview2Cart(BBIRGridView, "BBIRGridView")
    End Sub

#End Region

#Region "B+B Function"

    Protected Sub SetGridviewCheckedState(ByVal gv As GridView, ByVal input_name As String)
        Dim CheckBoxState As Dictionary(Of String, String) = DirectCast(ViewState(input_name), Dictionary(Of String, String))

        Dim PartNo_Index As String
        For i As Integer = 0 To gv.Rows.Count - 1
            If gv.Rows(i).RowType = DataControlRowType.DataRow Then
                Dim chk As CheckBox = DirectCast(gv.Rows(i).FindControl("CheckBox1"), CheckBox)
                PartNo_Index = gv.Rows(i).Cells(0).Text
                If chk.Checked Then
                    If Not CheckBoxState.ContainsKey(PartNo_Index) Then
                        CheckBoxState.Add(PartNo_Index, CType(gv.Rows(i).FindControl("qty_TextBox"), TextBox).Text)
                    Else
                        If Not CType(gv.Rows(i).FindControl("qty_TextBox"), TextBox).Text.Equals(CheckBoxState(PartNo_Index).ToString) Then
                            CheckBoxState(PartNo_Index) = CType(gv.Rows(i).FindControl("qty_TextBox"), TextBox).Text
                        End If
                    End If
                Else
                    If CheckBoxState.ContainsKey(gv.Rows(i).Cells(0).Text) Then
                        CheckBoxState.Remove(PartNo_Index)
                    End If
                End If
            End If
        Next
        ViewState(input_name) = CheckBoxState
    End Sub

    Protected Sub GetGridviewCheckedState(ByVal gv As GridView, ByVal input_name As String)
        Dim CheckBoxState As Dictionary(Of String, String) = DirectCast(ViewState(input_name), Dictionary(Of String, String))

        For i As Integer = 0 To gv.Rows.Count - 1
            If gv.Rows(i).RowType = DataControlRowType.DataRow Then
                Dim PartNo_Index As String = gv.Rows(i).Cells(0).Text
                If CheckBoxState.ContainsKey(PartNo_Index) Then
                    Dim chk As CheckBox = DirectCast(gv.Rows(i).FindControl("CheckBox1"), CheckBox)
                    chk.Checked = True
                    CType(gv.Rows(i).FindControl("qty_TextBox"), TextBox).Text = CheckBoxState(PartNo_Index).ToString
                    'gv.Rows(i).BackColor = Drawing.Color.FromName("#FFFF77")
                End If
            End If
        Next
    End Sub

    Protected Sub Gridview2Cart(ByVal gv As GridView, Src As String)
        Dim cart_id As String = Session("cart_id").ToString
        Dim company_id As String = HttpContext.Current.Session("company_id").ToString
        Dim org_id As String = HttpContext.Current.Session("org_id").ToString
        Dim lineno As Integer = 1

        Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
        mycart.Delete(String.Format("cart_id='{0}'", cart_id))

        Dim dt As DataTable = New DataTable
        If Src.Equals("BBGridView", StringComparison.OrdinalIgnoreCase) Then
            dt = BB_GetDT()
        ElseIf Src.Equals("BBTGridView", StringComparison.OrdinalIgnoreCase) Then
            dt = BBT_GetDT()
        Else
            dt = BBIR_GetDT()
        End If

        Dim CheckBoxState As Dictionary(Of String, String) = DirectCast(ViewState(Src), Dictionary(Of String, String))

        For Each row As DataRow In dt.Rows
            If CheckBoxState.ContainsKey(row.Item("PART_NO").ToString) Then
                Dim CartDetail As Advantech.Myadvantech.DataAccess.cart_DETAIL_V2 = New Advantech.Myadvantech.DataAccess.cart_DETAIL_V2

                CartDetail.Cart_Id = cart_id
                CartDetail.Line_No = lineno
                CartDetail.Part_No = row.Item("PART_NO").ToString
                CartDetail.Qty = CheckBoxState(row.Item("PART_NO").ToString).ToString
                CartDetail.Description = row.Item("PRODUCT_DESC").ToString
                'CartDetail.CustMaterial = d.CUST_MATERIAL
                CartDetail.QUOTE_ID = ""
                CartDetail.CustMaterial = ""
                CartDetail.Ew_Flag = 0
                CartDetail.SatisfyFlag = 0

                CartDetail.Delivery_Plant = Advantech.Myadvantech.Business.PartBusinessLogic.GetDeliveryPlant _
                    (company_id, org_id, CartDetail.Part_No, Advantech.Myadvantech.DataAccess.QuoteItemType.Part)
                CartDetail.higherLevel = 0
                CartDetail.otype = 0
                CartDetail.req_date = DateTime.Now.AddDays(2)
                CartDetail.otype = Advantech.Myadvantech.DataAccess.QuoteItemType.Part
                CartDetail.due_date = CartDetail.req_date

                CartDetail.List_Price = row.Item("unit_price").ToString.Replace(BB_Currency, "")
                CartDetail.Unit_Price = row.Item("unit_price").ToString.Replace(BB_Currency, "")
                CartDetail.Itp = 0

                lineno += 1
                Advantech.Myadvantech.DataAccess.MyAdvantechContext.Current.cart_DETAIL_V2.Add(CartDetail)
            End If
        Next

        Advantech.Myadvantech.DataAccess.MyAdvantechContext.Current.SaveChanges()
        Response.Redirect("~/Order/Cart_listV2.aspx")
    End Sub
#End Region

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999
        Dim dt As DataTable = MyCalData.GetBOAB(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("org_id"), Now.ToString("yyyy-MM-dd"), DateAdd(DateInterval.Day, 30, Now).ToString("yyyy-MM-dd"), "", "", "")
        If dt.Rows.Count > 0 Then
            gv1.DataSource = dt : gv1.DataBind()
            ViewState("boDt") = dt
        End If
        Timer1.Enabled = False
        imgLoading.Visible = False
    End Sub

    Public Shared Function FDate(ByVal d As String) As String
        If Date.TryParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        End If
        Return d
    End Function

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(ViewState("boDt"), False)
        gv1.DataBind()
        gv1.PageIndex = pageIndex
    End Sub

    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function

    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property

    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function

    Protected Sub gv1_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Timer1) AndAlso Timer1.Enabled = True Then
            Timer1.Enabled = False
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gv1.PageIndex = e.NewPageIndex
        gv1.DataSource = ViewState("boDt")
        gv1.DataBind()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(3).Text = CInt(e.Row.Cells(3).Text)
        End If
    End Sub

    'Function GetAddedPNSql() As String
    '    Dim sb As New System.Text.StringBuilder
    '    With sb
    '        .AppendLine(String.Format(" select top 10000 a.PART_NO, b.product_desc ,b.MODEL_NO  "))
    '        .AppendLine(String.Format(" from MYADVANTECH_PRODUCT_PROMOTION a inner join SAP_PRODUCT b on a.part_no=b.part_no  "))
    '        .AppendLine(String.Format(" where a.RBU='AENC' "))
    '        .AppendLine(String.Format(" order by a.PART_NO "))
    '    End With
    '    Return sb.ToString()
    'End Function

    'Protected Sub gvAddedPN_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
    '    Me.SrcAddedPN.SelectCommand = GetAddedPNSql()
    'End Sub

    'Protected Sub gvAddedPN_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
    '    Me.SrcAddedPN.SelectCommand = GetAddedPNSql()
    'End Sub
    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub

    Protected Sub btnWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "MY")
        If p IsNot Nothing Then
            Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}", Session("user_id"), p.login_password))
        End If
    End Sub

    Protected Sub TRMyDashboard_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If CInt(dbUtil.dbExecuteScalar("MY", String.Format(
                                          " select count(company_id) as c from SAP_DIMCOMPANY " +
                                          " where company_id='{0}' ", Session("company_id")))) > 0 Then
            TRMyDashboard.Visible = True
        Else
            TRMyDashboard.Visible = False
        End If
    End Sub

    Protected Sub dlChangeCompanyMultiErpId_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim au As New AuthUtil
        au.ChangeCompanyId(dlChangeCompanyMultiErpId.SelectedValue, "EU10")
        Response.Redirect("home_cp.aspx")
    End Sub

    Protected Sub dlChangeCompanyMultiErpId_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim curCompId As String = Session("company_id")
        For Each li As ListItem In dlChangeCompanyMultiErpId.Items
            li.Selected = False
            If li.Value.Equals(curCompId, StringComparison.OrdinalIgnoreCase) Then
                li.Selected = True
                Exit For
            End If
        Next
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        #nav {
            z-index: 50;
            position: absolute;
            vertical-align: bottom;
            text-align: right;
            top: 315px;
        }

            #nav a {
                margin: 0 5px;
                padding: 3px 5px;
                border: 1px solid #ccc;
                background: gray;
                text-decoration: none;
                color: White;
                font-weight: bold;
            }

                #nav a.activeSlide {
                    background: #aaf;
                }

                #nav a:focus {
                    outline: none;
                }
    </style>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(beginRequest);
        function beginRequest() {
            prm._scrollPosition = null;
        }
    </script>
    <script type="text/javascript" src='./EC/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript" src='./EC/Includes/jquery.cycle.all.latest.js'></script>
    <script type="text/javascript">
        $(document).ready(function () {
            getCoBranding();
            canAccessABRQuotation();
            var sidebar = $('#sidebar-connect');
            sidebar.hide();

            $("#<%=me.HyCobranding.ClientID %>").click(function (e) {
                //alert($("#<%=me.HyCobranding.ClientID %>").attr("href"));
                if ($("#<%=me.HyCobranding.ClientID %>").attr("href") == undefined || $("#<%=me.HyCobranding.ClientID %>").attr("href") == '') {
                    sidebar.toggle();
                }
            });
            $('#slideshow').cycle({
                fx: 'fade',
                timeout: 300000000,
                pager: '#nav',
                slideExpr: 'table'
            });
        }
        );

        function getCoBranding() {
            $("body").css("cursor", "progress");
            $("#<%=me.TrCobranding.ClientID %>").hide();
            var temp_id = '<%=Session("TempId") %>';
            var user_id = '<%=User.Identity.Name %>';
            //alert(user_id);
            //user_id = 'Stefanie.Chang@advantech.com.tw';
            //temp_id = '0a50ce8c-053c-4f82-bbe3-edb171ee7f50-::1'
            //var postData = JSON.stringify({ UserID: user_id });

            $.ajax({
                type: "POST",
                url: "./Services/MyServices.asmx/GetCoBranding",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    var ATPTotalInfo = $.parseJSON(msg.d);

                    if (ATPTotalInfo.length > 0) {

                        $("#<%=me.TrCobranding.ClientID %>").show();

                        if (ATPTotalInfo.length == 1) {
                            //alert(ATPTotalInfo[0].AdminSiteURL);
                            $("#<%=me.HyCobranding.ClientID %>").attr("href", ATPTotalInfo[0].AdminSiteURL + '?id=' + user_id + '&tempid=' + temp_id);
                            $("#<%=me.HyCobranding.ClientID %>").attr("target", '_blank');

                        } else {
                            var divCoBrandingURLs = $('#sidebar-connect');
                            //divCoBrandingURLs.append('<ul>');
                            $.each(ATPTotalInfo, function (i, item) {
                                //divCoBrandingURLs.append('<a href="' + item.AdminSiteURL + '" target="_blank">' + item.SiteName + '</a><br/>');
                                //2014/1/20 Liliana要求factory system重覆(factory-syst & factorysystemes) 移除factory-syst連結
                                if (item.SiteName != "factory-syst") {
                                    divCoBrandingURLs.append('<li><a href="' + item.AdminSiteURL + '?id=' + user_id + '&tempid=' + temp_id + '" target="_blank">' + item.SiteName + '</a>');
                                }
                            });
                            //divCoBrandingURLs.append('</ul>');
                        }
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                    //$("body").css("cursor", "auto");
                    //alert("error:" + msg.d);
                    //var divATP = $('#divACLATP');
                    //divATP.html('');
                }
            }
            );
        }
        function canAccessABRQuotation() {
            $("body").css("cursor", "progress");
            var user_id = '<%=User.Identity.Name %>';
            $("#<%=me.TRABRQuotation.ClientID %>").hide();
            $.ajax({
                type: "POST",
                url: "./Services/InternalWebService.asmx/CanAccessABRQuotation",
                data: JSON.stringify({
                    UserID: user_id,
                    RBU: '<%=Session("RBU") %>',
                    AccountStatus: '<%=Session("Account_Status") %>'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var ATPTotalInfo = $.parseJSON(msg.d);

                    if (ATPTotalInfo) {
                        $("#<%=me.TRABRQuotation.ClientID %>").show();
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                }
            }
            );
        }
    </script>
    <div class="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td height="5"></td>
            </tr>
            <uc10:BillboardBlock runat="server" ID="ucBillboardBlock" />
            <%--            <tr>
                <td align="center"  height="35">
                    <uc12:ChannelInsightLink runat="server" ID="ucChannelInsightLink" Visible="false" />
                </td>
            </tr>
            --%>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT0" runat="server" OnLoad="LiTs_Load">Online Ordering</asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Order/cart_list.aspx">
                                                <asp:Literal ID="Literal1" runat="server" OnLoad="LiTs_Load">Place Component Orders</asp:Literal>
                                            </asp:HyperLink>
                                            <%--<a href="../Order/cart_list.aspx">
                                                    <asp:Literal ID="LiT16" runat="server" OnLoad="LiTs_Load">Place Component Orders</asp:Literal>
                                                </a>--%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trSysConfig_Orders">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="~/Order/btos_portal.aspx">
                                                <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">System Configuration/Orders</asp:Literal>
                                            </asp:HyperLink>
                                            <%--
                                                <a href="../Order/btos_portal.aspx">
                                                    <asp:Literal ID="LiT17" runat="server" OnLoad="LiTs_Load">System Configuration/Orders</asp:Literal>
                                                </a>
                                            --%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trUpdOrder">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyUploadOrder" NavigateUrl="~/order/UploadOrderFromExcel.aspx">
                                                <asp:Literal ID="LiT32" runat="server" Text="Upload Order" OnLoad="LiTs_Load" />
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trChkPrice_Aval">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl="~/Order/PriceAndATP.aspx">
                                                <asp:Literal ID="LiT15" runat="server" OnLoad="LiTs_Load">Check Price & Availability</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr_EUGATP">
                            <td height="25" id="tdHead" runat="server"></td>
                            <td id="tdhyEUGATP" runat="server">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyEUGATP" NavigateUrl="~/Order/QueryACLATP.aspx"
                                                Text="Check ACL Availability" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="lnkMyBO">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink4" runat="server" NavigateUrl="~/Order/BO_OrderTracking.aspx">
                                                <asp:Literal ID="LiT13" runat="server" OnLoad="LiTs_Load">Order Tracking</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trQuoteHistory">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCompanyQuoteHistory" NavigateUrl="~/Order/QuoteByCompany.aspx"
                                                Text="Quotation History" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="lnkCartHistory">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink5" runat="server" NavigateUrl="~/Order/CartHistory_List.aspx">
                                                <asp:Literal ID="LiT34" runat="server" OnLoad="LiTs_Load">Cart & Configuration History</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="TRMyDashboard" onload="TRMyDashboard_Load">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink6" runat="server" NavigateUrl="~/my/MyDashboard.aspx">
                                                <asp:Literal ID="LiT340" runat="server">My Dashboard</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="TRABRQuotation">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink21" runat="server" NavigateUrl="~/Order/ABRQuote/B2B_Quotation_List.aspx">
                                                <asp:Literal ID="Literal11" runat="server">New Quotation</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%--        </table>
        </td></tr>--%><%--<tr>
                    <td height="25"></td>
                    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                          <td width="5%" valign="top"><img src="images/point_02.gif" alt="" width="7" height="14"/></td>
                          <td class="menu_title02">Gift Shop</td>
                        </tr>
                    </table></td>
                  </tr></table>
        </td></tr>--%><tr>
            <td height="5"></td>
        </tr>
            <tr runat="server" id="trChampion" visible="false">
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal4" runat="server" OnLoad="LiTs_Load">Advantech Champion Club</asp:Literal></td>
            </tr>
            <tr runat="server" id="trChampion2" visible="false">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink11" runat="server" NavigateUrl="~/My/ChampionClub/ChampionClub.aspx">
                                                <asp:Literal ID="Literal5" runat="server">Program Introduction</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink10" runat="server" NavigateUrl="~/My/ChampionClub/ProgramCriteria.aspx">
                                                <asp:Literal ID="Literal3" runat="server">Regional Program & Registration</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink16" runat="server" NavigateUrl="~/My/ChampionClub/PersonalInfo.aspx">
                                                <asp:Literal ID="Literal10" runat="server">Personal Info</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="tr_Point" runat="server">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink19" runat="server" NavigateUrl="~/My/ChampionClub/ReportsUpload.aspx">
                                                <asp:Literal ID="Literal13" runat="server">Point Request</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink12" runat="server" NavigateUrl="~/My/ChampionClub/PointManagement.aspx">
                                                <asp:Literal ID="Literal6" runat="server">Point Management</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink13" runat="server" NavigateUrl="~/My/ChampionClub/Redemption.aspx">
                                                <asp:Literal ID="Literal7" runat="server">Redemption</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <%--     <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink17" runat="server" NavigateUrl="~/My/ChampionClub/RedeemRecord.aspx">
                                                <asp:Literal ID="Literal11" runat="server">Redemption Record</asp:Literal></asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>--%><tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink14" runat="server" NavigateUrl="~/My/ChampionClub/RankingList.aspx">
                                                <asp:Literal ID="Literal8" runat="server">Ranking List</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink15" runat="server" NavigateUrl="~/My/ChampionClub/ChampionClub_QA.aspx">
                                                <asp:Literal ID="Literal9" runat="server">FAQ</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trMarcom" visible="false">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink18" runat="server" NavigateUrl="~/My/ChampionClub/MarcomPlatform.aspx">
                                                <asp:Literal ID="Literal12" runat="server">Advantech Marcom Login</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT3" runat="server" OnLoad="LiTs_Load">Product Info.</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink7" runat="server" NavigateUrl="~/Product/ProductSearch.aspx">
                                                <asp:Literal ID="LiT21" runat="server" OnLoad="LiTs_Load">Search</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trAdvProdSearch" visible="false">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyAdvProdSearch" Text="Advanced Product Search"
                                                NavigateUrl="~/Product/Search.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx"
                                                Text="Phase In/ Out" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink8" runat="server" NavigateUrl="~/Product/New_Product.aspx">
                                                <asp:Literal ID="LiT23" runat="server" OnLoad="LiTs_Load">New Product Highlight</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink9" runat="server" Text="Warranty Lookup" NavigateUrl="~/Order/RMAWarrantyLookup.aspx" />
                                            <%--<asp:HyperLink ID="HyperLink9" runat="server" NavigateUrl="~/Order/MyWarrantyExpireItems.aspx">
                                                <asp:Literal ID="LiT24" runat="server" OnLoad="LiTs_Load">Warranty Lookup</asp:Literal></asp:HyperLink>--%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT4" runat="server" OnLoad="LiTs_Load">Support & Download</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <uc9:SupportBlock runat="server" ID="ucSupportBlock" IsCP="true" />
                    <asp:HyperLink runat="server" ID="hyePricer" Target="_blank" Text="ePricer" NavigateUrl="~/Includes/ToEIP.ashx?EIPPID=ePricer_SSO"
                        Visible="false" />
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr runat="server" id="trFuncToolsTitle">
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT10" runat="server" OnLoad="LiTs_Load">Functional Tools</asp:Literal></td>
            </tr>
            <tr runat="server" id="trFuncTools">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr runat="server" id="trProjectRegist">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPrjReg" Text="" NavigateUrl="~/My/ProjectRegist.aspx">
                                                <asp:Literal ID="LiT30" runat="server" OnLoad="LiTs_Load">Project Registration Request</asp:Literal><asp:Literal
                                                    ID="LiT31" runat="server" OnLoad="LiTs_Load" Visible="false">Special Price Request</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink22" Text="" NavigateUrl="~/My/InterCon/PrjTmpList.aspx">
                                                <asp:Literal ID="Literal14" runat="server" OnLoad="LiTs_Load">My Temporary Projects</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trProjectRegistlist">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyMyRegPrj" Text="" NavigateUrl="~/My/ProjectRegList.aspx">
                                                <asp:Literal ID="LiT36" runat="server" OnLoad="LiTs_Load">My Registered Projects</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="LiT29TR">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyLeadMgt" Text="Leads Management" NavigateUrl="~/My/MyLeads.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyEMarketing" NavigateUrl="http://www.advantech-eautomation.com/emarketingprograms/ChannelPartner/Channel_Partner_ppt/Advantech_IA_EDMs.htm"
                                                Target="_blank" Text="eMarketing" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hleDMTool" NavigateUrl="http://my.advantech.com/EC/AllEDMNewsletters.aspx"
                                                Text="eDM Tool" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="Ecard_ATR">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <a href="http://partner.advantech.com.tw/Utility/App_Login.aspx?App=ecard" id="Ecard_A"
                                                runat="server" target="_blank">eCard System</a>
                                            <asp:LinkButton runat="server" ID="btnWiki" Text="AdvantechWiki" OnClick="btnWiki_Click"
                                                Visible="false" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="Tr1">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink17" Target="_blank" NavigateUrl="~/My/AOnline/UNICA_SBU_Campaigns_New.aspx"
                                                Text="Advantech Campaign Overview" />
                                            <img src="./images/new2.gif" alt="Advantech Campaign Overview" style="border: 0px"
                                                width="28" height="11" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="20"></td>
                                        <td class="menu_list" style="padding-left: 10px;">
                                            <asp:HyperLink runat="server" ID="hyMyCampaigns" Target="_blank" Text="My Campaigns"
                                                NavigateUrl="~/My/Campaign/CampaignList.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCatalogPriceATP" NavigateUrl="~/DM/Marketing/Catalog_Price_Inventory.aspx"
                                                Text="Catalog Price & Inventory" /><img src="/Images/new2.gif" alt="New QR Code Campaign Tracking Function"
                                                    style="border: 0px" width="28" height="11" />

                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <%--                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink20" NavigateUrl="http://crm-partner.advantech.com.tw/"
                                                Text="PRM System" Target="_blank" /><img src="/Images/new2.gif" alt="PRM System"
                                                    style="border: 0px" width="28" height="11" /> 
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>--%>
                        <tr runat="server" id="TrMyDB" visible="false">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyMyDB" NavigateUrl="~/My/MyDashboard.aspx" Text="My Dashboard (For Channel Partner)" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="TrCobranding" visible="true">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" alt="" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyCobranding" runat="server">Co-branding Website Maintenance</asp:HyperLink></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" width="100%">
                                            <div id="sidebar-connect" style="display: none; position: absolute; border-style: solid; background-color: white; padding: 15px; width: 195px; overflow: auto;">
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr runat="server" id="trChgCompIdSILVERSTAR" visible="false">
                <td>
                    <b>Change Company:</b><br />
                    <asp:DropDownList runat="server" ID="dlChangeCompanyMultiErpId" AutoPostBack="true"
                        OnSelectedIndexChanged="dlChangeCompanyMultiErpId_SelectedIndexChanged" OnDataBound="dlChangeCompanyMultiErpId_DataBound" />
                </td>
            </tr>
            <tr>
                <td>
                    <uc10:eLearningBanner runat="server" ID="ucElBanner" Visible="false" />
                </td>
            </tr>
            <tr>
                <td>
                    <uc10:AMDBanner runat="server" ID="ucAMDBanner" />
                </td>
            </tr>
            <tr>
                <td height="139">
                    <asp:HyperLink runat="server" ID="hyDAQ" NavigateUrl="~/DAQ/Default.aspx"> <img src="images/DAQ_Your_Way.jpg" width="246" height="138" style="border:0px" /></asp:HyperLink></td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td height="139">
                    <a href="http://adamforum.com/" target="_blank">
                        <img src="images/banner_adm.jpg" width="246" height="138" alt="" /></a> </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td>
                    <a href="http://iservicesblog.advantech.eu/IServiceBlog/" target="_blank">
                        <img alt="" src="images/promotionbutton1.jpg" /></a> </td>
            </tr>
        </table>
    </div>
    <div class="right">
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0">
                        <asp:View ID="ViewTab1" runat="server">
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td height="10"></td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="rightcontant">
                                            <div id="slideshow">
                                                <table height="330">
                                                    <tr>
                                                        <td valign="top">
                                                            <iframe width="450" height="300" src="http://www.youtube.com/embed/FFd3qIWk4HE" frameborder="0" allowfullscreen></iframe>
                                                        </td>
                                                        <td width="10"></td>
                                                        <td valign="top" style="padding-top: 10px">
                                                            <a href="http://youtu.be/FFd3qIWk4HE" target="_blank">From Good to Great</a><br />
                                                            <br />
                                                            For 30 years, "Good to great" has always been Advantech's core philosophy, which
                                                            lead us keep growing."Good to Great" is based on the 3-Circle Principle from Jim
                                                            Collins' book. Advantech has put it into action by clearly defining Advantech's
                                                            particular 3-Circle Principle. Watch the video to know more about Advantech's business
                                                            philosophy! </td>
                                                    </tr>
                                                </table>
                                                <table height="340">
                                                    <tr>
                                                        <td valign="top">
                                                            <iframe width="450" height="300" src="http://www.youtube.com/embed/LyPsdwSN6wQ" frameborder="0" allowfullscreen></iframe>
                                                            <%--<object width='450' height='300'>
                                                                <param name='movie' value='https://youtube.googleapis.com/v/LyPsdwSN6wQ'></param>
                                                                <param name='wmode' value='transparent'></param>
                                                                <embed src='https://youtube.googleapis.com/v/LyPsdwSN6wQ' type='application/x-shockwave-flash'
                                                                    wmode='transparent' width='450' height='300'></embed></object>--%></td>
                                                        <td width="10"></td>
                                                        <td valign="top" style="padding-top: 5px">
                                                            <a href="http://www.youtube.com/watch?v=LyPsdwSN6wQ" target="_blank">Visit Advantech's
                                                                headquarter through the video with us.</a><br />
                                                            <b>Advantech Mission:</b><br />
                                                            <li>Enabling an intelligent Plant through our IoT and Embedded Platforms designed for
                                                                system integrators.</li>
                                                            <li>Working & Learning Toward a Beautiful Life under our Altruistic
                                                                    (LITA) Philosophy.</li>
                                                            <b>Advantech Values:</b><br />
                                                            <li>Customer Partnership and Talent Invigoration</li>
                                                            <li>Integrity and Certitude</li>
                                                            <li>Focused Leadership</li>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <table height="330">
                                                    <tr>
                                                        <td valign="top">
                                                            <iframe width="450" height="300" src="http://www.youtube.com/embed/hr_htF0_zdI" frameborder="0" allowfullscreen></iframe>
                                                            <%--<object width='450' height='300'>
                                                                <param name='movie' value='https://youtube.googleapis.com/v/hr_htF0_zdI'></param>
                                                                <param name='wmode' value='transparent'></param>
                                                                <embed src='https://youtube.googleapis.com/v/hr_htF0_zdI' type='application/x-shockwave-flash'
                                                                    wmode='transparent' width='450' height='300'></embed></object>--%></td>
                                                        <td width="10"></td>
                                                        <td valign="top" style="padding-top: 5px">
                                                            <a href="http://www.youtube.com/watch?v=hr_htF0_zdI" target="_blank">Progressing the
                                                                Advantech Story</a><br />
                                                            <br />
                                                            Established in 1983, Advantech has grown from a small business to an international
                                                            enterprise. In the 30 years, the core spirit and management philosophy of Advantech
                                                            Corporation is well presented in this corporate altruistic LITA tree.<br />
                                                            <br />
                                                            The video illustrates the story of what we have done in the past 30 years and our
                                                            vision for the next 30 years. </td>
                                                    </tr>
                                                </table>
                                                <div id="nav">
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="10"></td>
                                </tr>
                                <tr runat="server" id="tr_banner1">
                                    <td align="left">
                                        <uc10:Banner runat="server" ID="ucBanner" />
                                    </td>
                                </tr>
                                <tr>
                                    <td height="10"></td>
                                </tr>
                                <tr valign="top">
                                    <td align="left">
                                        <uc9:WCustContent runat="server" ID="WCont1" />
                                    </td>
                                </tr>
                                <tr>
                                    <td height="10"></td>
                                </tr>
                                <tr>
                                    <td height="10"></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upBB" UpdateMode="Conditional" Visible="false">
                                            <ContentTemplate>
                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td align="left" class="h3" height="30">Selected Products for Advantech B+B</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Timer runat="server" ID="TimerBB" Interval="3500" OnTick="TimerBB_Tick" />
                                                            <asp:Panel runat="server" ID="PanelBBSelectedItems" DefaultButton="BBSearch">
                                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td align="left">
                                                                            <asp:DropDownList ID="BBDropDownList" runat="server">
                                                                                <asp:ListItem Value="1" Text="Search by Part No."></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Search by Product Desc."></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Search by B+B Part Name"></asp:ListItem>
                                                                            </asp:DropDownList>&nbsp;
                                                                            <asp:TextBox ID="BBTextBox" runat="server"> </asp:TextBox>&nbsp;
                                                                            <asp:Button ID="BBSearch" OnClick="BBSearch_Click" runat="server" Text="Search" />
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:Button runat="Server" ID="BBAdd2Cart" OnClick="BBAdd2Cart_Click" Text="Add to Cart" Visible="true" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td height="5"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="center" colspan="2">
                                                                            <asp:Image runat="server" ID="ImageBB" ImageUrl="~/Images/loading2.gif" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top" colspan="2">
                                                                            <asp:GridView runat="server" Width="100%" ID="BBGridView" AutoGenerateColumns="false" AllowPaging="true"
                                                                                EnableTheming="false" AllowSorting="true" PageSize="25" RowStyle-BackColor="#FFFFFF"
                                                                                AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" BorderWidth="1"
                                                                                BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                                                                PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnPageIndexChanging="BBGridView_PageIndexChanging"
                                                                                OnSorting="BBGridView_Sorting" OnRowDataBound="BBGridView_RowDataBound">
                                                                                <Columns>
                                                                                    <asp:BoundField HeaderText="Part No." DataField="PART_NO" SortExpression="PART_NO" ItemStyle-Width="25%" />
                                                                                    <asp:BoundField HeaderText="Product Desc." DataField="PRODUCT_DESC" SortExpression="PRODUCT_DESC">
                                                                                        <ItemStyle Width="50%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <%--<asp:BoundField HeaderText="B+B Part Name" DataField="kdmat" SortExpression="kdmat">
                                                                                        <ItemStyle Width="20%"></ItemStyle>
                                                                                    </asp:BoundField>--%>
                                                                                    <asp:BoundField HeaderText="Unit Price" DataField="unit_price" ItemStyle-HorizontalAlign="Right">
                                                                                        <ItemStyle Width="15%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:TemplateField HeaderText="Qty">
                                                                                        <ItemTemplate>
                                                                                            <asp:TextBox ID="qty_TextBox" runat="server" Text="1" Width="25px"></asp:TextBox>
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="25px" HorizontalAlign="Center" />
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField ShowHeader="false" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:CheckBox ID="CheckBox1" runat="server" />
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="3%" />
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20"></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upBBT" UpdateMode="Conditional" Visible="false">
                                            <ContentTemplate>
                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td align="left" class="h3" height="30">T Products for Advantech B+B</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Timer runat="server" ID="TimerBBT" Interval="3500" OnTick="TimerBBT_Tick" />
                                                            <asp:Panel runat="server" ID="Panel1" DefaultButton="BBSearch">
                                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td align="left">
                                                                            <asp:DropDownList ID="BBTDropDownList" runat="server">
                                                                                <asp:ListItem Value="1" Text="Search by Part No."></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Search by Product Desc."></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Search by B+B Part Name"></asp:ListItem>
                                                                            </asp:DropDownList>&nbsp;
                                                                            <asp:TextBox ID="BBTTextBox" runat="server"> </asp:TextBox>&nbsp;
                                                                            <asp:Button ID="BBTSearch" OnClick="BBTSearch_Click" runat="server" Text="Search" />
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:Button runat="Server" ID="Button1" OnClick="BBTAdd2Cart_Click" Text="Add to Cart" Visible="true" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td height="5"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="center" colspan="2">
                                                                            <asp:Image runat="server" ID="ImageBBT" ImageUrl="~/Images/loading2.gif" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top" colspan="2">
                                                                            <asp:GridView runat="server" Width="100%" ID="BBTGridView" AutoGenerateColumns="false" AllowPaging="true"
                                                                                EnableTheming="false" AllowSorting="true" PageSize="25" RowStyle-BackColor="#FFFFFF"
                                                                                AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" BorderWidth="1"
                                                                                BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                                                                PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnPageIndexChanging="BBTGridView_PageIndexChanging"
                                                                                OnSorting="BBTGridView_Sorting" OnRowDataBound="BBTGridView_RowDataBound">
                                                                                <Columns>
                                                                                    <asp:BoundField HeaderText="Part No." DataField="PART_NO" SortExpression="PART_NO" ItemStyle-Width="25%" />
                                                                                    <asp:BoundField HeaderText="Product Desc." DataField="PRODUCT_DESC" SortExpression="PRODUCT_DESC">
                                                                                        <ItemStyle Width="50%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:BoundField HeaderText="B+B Part Name" DataField="kdmat" SortExpression="kdmat">
                                                                                        <ItemStyle Width="20%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:BoundField HeaderText="Unit Price" DataField="unit_price" ItemStyle-HorizontalAlign="Right">
                                                                                        <ItemStyle Width="10%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:TemplateField HeaderText="Qty">
                                                                                        <ItemTemplate>
                                                                                            <asp:TextBox ID="qty_TextBox" runat="server" Text="1" Width="25px"></asp:TextBox>
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="25px" HorizontalAlign="Center" />
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField ShowHeader="false" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:CheckBox ID="CheckBox1" runat="server" />
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="3%" />
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20"></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upBBIR" UpdateMode="Conditional" Visible="false">
                                            <ContentTemplate>
                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td align="left" class="h3" height="30">T Products for Advantech B+B (Ireland)</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Timer runat="server" ID="TimerBBIR" Interval="3500" OnTick="TimerBBIR_Tick" />
                                                            <asp:Panel runat="server" ID="PanelBBIR" DefaultButton="BBIRSearch">
                                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td align="left">
                                                                            <asp:DropDownList ID="BBIRDropDownList" runat="server">
                                                                                <asp:ListItem Value="1" Text="Search by Part No."></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Search by Product Desc."></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Search by B+B Part Name"></asp:ListItem>
                                                                            </asp:DropDownList>&nbsp;
                                                                            <asp:TextBox ID="BBIRTextBox" runat="server"> </asp:TextBox>&nbsp;
                                                                            <asp:Button ID="BBIRSearch" OnClick="BBIRSearch_Click" runat="server" Text="Search" />
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:Button runat="Server" ID="Button2" OnClick="BBIRAdd2Cart_Click" Text="Add to Cart" Visible="true" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td height="5"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="center" colspan="2">
                                                                            <asp:Image runat="server" ID="ImageBBIR" ImageUrl="~/Images/loading2.gif" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top" colspan="2">
                                                                            <asp:GridView runat="server" Width="100%" ID="BBIRGridView" AutoGenerateColumns="false" AllowPaging="true"
                                                                                EnableTheming="false" AllowSorting="true" PageSize="25" RowStyle-BackColor="#FFFFFF"
                                                                                AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" BorderWidth="1"
                                                                                BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                                                                PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnPageIndexChanging="BBIRGridView_PageIndexChanging"
                                                                                OnSorting="BBIRGridView_Sorting" OnRowDataBound="BBIRGridView_RowDataBound">
                                                                                <Columns>
                                                                                    <asp:BoundField HeaderText="Part No." DataField="PART_NO" SortExpression="PART_NO" ItemStyle-Width="25%" />
                                                                                    <asp:BoundField HeaderText="Product Desc." DataField="PRODUCT_DESC" SortExpression="PRODUCT_DESC">
                                                                                        <ItemStyle Width="50%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:BoundField HeaderText="B+B Part Name" DataField="kdmat" SortExpression="kdmat">
                                                                                        <ItemStyle Width="20%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:BoundField HeaderText="Unit Price" DataField="unit_price" ItemStyle-HorizontalAlign="Right">
                                                                                        <ItemStyle Width="10%"></ItemStyle>
                                                                                    </asp:BoundField>
                                                                                    <asp:TemplateField HeaderText="Qty">
                                                                                        <ItemTemplate>
                                                                                            <asp:TextBox ID="qty_TextBox" runat="server" Text="1" Width="25px"></asp:TextBox>
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="25px" HorizontalAlign="Center" />
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField ShowHeader="false" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:CheckBox ID="CheckBox1" runat="server" />
                                                                                        </ItemTemplate>
                                                                                        <ItemStyle Width="3%" />
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20"></td>
                                </tr>

                                <tr valign="top">
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td align="left" class="h3" height="30">My Backorder </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            <asp:Timer runat="server" ID="Timer1" Interval="3500" OnTick="Timer1_Tick" />
                                                            <table width="100%" cellpadding="0" cellspacing="0">
                                                                <tr>
                                                                    <td align="center">
                                                                        <asp:Image runat="server" ID="imgLoading" ImageUrl="~/Images/loading2.gif" />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <asp:GridView runat="server" Width="100%" ID="gv1" AutoGenerateColumns="false" AllowPaging="true"
                                                                            EnableTheming="false" AllowSorting="true" PageSize="5" RowStyle-BackColor="#FFFFFF"
                                                                            AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" BorderWidth="1"
                                                                            BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                                                            OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting" OnRowCreated="gv1_RowCreated"
                                                                            PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnRowDataBound="gv1_RowDataBound">
                                                                            <Columns>
                                                                                <asp:BoundField HeaderText="SO No." DataField="ORDERNO" SortExpression="ORDERNO" />
                                                                                <asp:BoundField HeaderText="PO No." DataField="PONO" SortExpression="PONO" />
                                                                                <asp:BoundField HeaderText="Part No." DataField="PRODUCTID" SortExpression="PRODUCTID" />
                                                                                <asp:BoundField HeaderText="Qty." DataField="SCHDLINECONFIRMQTY" SortExpression="SCHDLINECONFIRMQTY"
                                                                                    ItemStyle-HorizontalAlign="Center" />
                                                                                <asp:TemplateField HeaderText="Order Date" SortExpression="ORDERDATE" ItemStyle-HorizontalAlign="Center">
                                                                                    <ItemTemplate>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                                <asp:TemplateField HeaderText="Due Date" SortExpression="DUEDATE" ItemStyle-HorizontalAlign="Center">
                                                                                    <ItemTemplate>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </asp:View>
                        <asp:View ID="ViewTab2" runat="server">
                            <%-- dynamic load user control "AENC_HomePage"   <uc11:AENC_HomePage runat="server" ID="AENC_HomePage1"  Visible="false" />
                            --%>
                        </asp:View>
                    </asp:MultiView>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
