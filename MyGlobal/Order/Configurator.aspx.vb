
Partial Class Lab_ConfiguratorJQ
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Request("BTOItem") IsNot Nothing Then
                Dim isEstoreBOM As Boolean = False
                Dim strBTOItem As String = Trim(Request("BTOItem"))

                If MyCBOMDAL.IsEstoreBom(strBTOItem) Then
                    isEstoreBOM = True
                End If

                Dim intConfigQty As Integer = 1, blIsEstoreOrOneLevelBTO As Boolean = False

                '20130619 Check if BTOItem is valid, if not, diable continue button
                Dim cmdCheckBTOItemValid As New SqlClient.SqlCommand(
                    "select count(category_id) as c from cbom_catalog_category where category_id=@RootId and org=@ORG and parent_category_id='Root' ",
                    New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString))
                With cmdCheckBTOItemValid.Parameters
                    .AddWithValue("RootId", strBTOItem) : .AddWithValue("ORG", MYSAPBIZ.RBU2Org(Session("RBU"), Session("org_id")).Substring(0, 2))
                End With
                cmdCheckBTOItemValid.Connection.Open()
                Dim retCount As Integer = CInt(cmdCheckBTOItemValid.ExecuteScalar())
                cmdCheckBTOItemValid.Connection.Close()
                If Not isEstoreBOM AndAlso retCount = 0 Then
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initConfigQty", "$('.continueBtn').prop('disabled', true);", True) : Exit Sub
                End If

                If Request("Qty") IsNot Nothing AndAlso Integer.TryParse(Request("Qty"), 1) AndAlso CInt(Request("Qty")) > 0 Then
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initConfigQty", _
                   "$('#hdConfigQty').val('" + CInt(Request("Qty")).ToString() + "');", True)
                    intConfigQty = CInt(Request("Qty"))
                End If

                '20150401 TC:   For AJP sales, when required category is missing selectable options, do not force to disable "continue" button,
                '               because they can still add items afterward in shopping cart. This mechanism might be applied to other regions in the future
                If Session("org_id") = "JP01" AndAlso Util.IsInternalUser2() Then
                    'hdIsForceChooseReqCat
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "setNoForceClickReqCategory", "$('#hdIsForceChooseReqCat').val('0');", True)
                End If

                If isEstoreBOM OrElse MyCBOMDAL.IsOnlyOneLevelBOM(strBTOItem) Then
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "setOnlyOneLevel", "$('#hdIsOneLevel').val('1');", True)
                    blIsEstoreOrOneLevelBTO = True
                Else
                    If Session("org_id").ToString().StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                        Dim _sql As New StringBuilder
                        _sql.AppendLine(" Select a.Catalog_Org,a.CATALOG_TYPE,b.LOCAL_NAME,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.CREATED ")
                        _sql.AppendLine(" From CBOM_CATALOG a inner join CBOM_CATALOG_LOCALNAME b on a.CATALOG_TYPE=b.CATALOG_TYPE ")
                        _sql.AppendLine(" Where a.Catalog_Org='EU' and a.CATALOG_TYPE like '%Pre-Configuration' and a.CATALOG_NAME ='" & Replace(strBTOItem, "'", "''") & "' ")
                        Dim _dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, _sql.ToString)
                        If Not IsNothing(_dt) AndAlso _dt.Rows.Count > 0 AndAlso _
                            _dt.Rows(0).Item("LOCAL_NAME").ToString.Equals("Pre-Configuration for AEU eStore (buy.advantech.eu) Configuration", _
                            StringComparison.InvariantCultureIgnoreCase) Then
                            '_IsAEUeStore = True
                            Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "setOnlyOneLevel", "$('#hdIsOneLevel').val('1');", True)
                            blIsEstoreOrOneLevelBTO = True
                        End If
                    End If
                End If

                Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initBTOValue", _
                    "$('#hdBTOId').val('" + strBTOItem + "'); InitLoadBOM();", True)

                Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initCurrencySign", "$($('.totalPriceCurrSign')[0]).html('" + Session("company_currency_sign") + "');", True)
                SetSourcePath(strBTOItem, intConfigQty)
                If Not blIsEstoreOrOneLevelBTO Then
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "DefaultExpandAll", "collapseExpandAll();", True)
                End If
            Else
                If Request("ReConfigId") IsNot Nothing Then
                    Dim strReconfigId As String = Trim(Request("ReConfigId"))
                    Dim apt As New SqlClient.SqlDataAdapter( _
                        " select ROOT_CATEGORY_ID, CONFIG_QTY, CONFIG_TREE_HTML, ORG_ID " + _
                        " from eQuotation.dbo.CTOS_CONFIG_LOG " + _
                        " where ROW_ID=@RID and USERID=@UID and COMPANY_ID=@ERPID ", _
                        ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
                    With apt.SelectCommand.Parameters
                        .AddWithValue("RID", strReconfigId) : .AddWithValue("UID", HttpContext.Current.User.Identity.Name) : .AddWithValue("ERPID", HttpContext.Current.Session("company_id").ToString())
                    End With
                    Dim reconfigDt As New DataTable
                    apt.Fill(reconfigDt) : apt.SelectCommand.Connection.Close()
                    If reconfigDt.Rows.Count = 1 Then

                        Dim hdoc1 As New HtmlAgilityPack.HtmlDocument
                        hdoc1.LoadHtml(reconfigDt.Rows(0).Item("CONFIG_TREE_HTML"))
                        Dim priceNodes As HtmlAgilityPack.HtmlNodeCollection = hdoc1.DocumentNode.SelectNodes("//div[@class='divPriceValue']")

                        For Each priceNode As HtmlAgilityPack.HtmlNode In priceNodes
                            Dim partNoNode As HtmlAgilityPack.HtmlNode = priceNode.ParentNode.ParentNode.SelectSingleNode("input[@class='compOption']")
                            If partNoNode IsNot Nothing Then
                                Dim strCatId As String = partNoNode.ParentNode.ParentNode.ParentNode.ParentNode.Attributes("catname").Value
                                Dim strCompId As String = partNoNode.Attributes("compname").Value
                                If Not MyCBOMDAL.IsOrderable(strCompId, reconfigDt.Rows(0).Item("ORG_ID")) Then
                                    Response.Redirect("ReConfigureCTOSCheck.aspx?ReConfigId=" + strReconfigId)
                                    Exit Sub
                                End If
                            End If
                        Next

                        Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initReconfigTree", _
                        "InitReconfigData('" + Trim(Request("ReConfigId")) + "');", True)
                    End If
                Else
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initConfigQty", "$('.continueBtn').prop('disabled', true);", True) : Exit Sub
                End If
            End If
        End If
    End Sub

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetReconfigTree(ByVal ReConfigId As String) As String
        Dim ReconfigTreeObject1 As New MyCBOMDAL.ReconfigTreeObject
        Dim apt As New SqlClient.SqlDataAdapter( _
                       " select ROOT_CATEGORY_ID, CONFIG_QTY, CONFIG_TREE_HTML, ORG_ID " + _
                       " from eQuotation.dbo.CTOS_CONFIG_LOG " + _
                       " where ROW_ID=@RID and USERID=@UID and COMPANY_ID=@ERPID ", _
                       ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        With apt.SelectCommand.Parameters
            .AddWithValue("RID", ReConfigId) : .AddWithValue("UID", HttpContext.Current.User.Identity.Name) : .AddWithValue("ERPID", HttpContext.Current.Session("company_id").ToString())
        End With
        Dim reconfigDt As New DataTable
        apt.Fill(reconfigDt) : apt.SelectCommand.Connection.Close()
        If reconfigDt.Rows.Count = 1 Then

            Dim hdoc1 As New HtmlAgilityPack.HtmlDocument
            hdoc1.LoadHtml(reconfigDt.Rows(0).Item("CONFIG_TREE_HTML"))
            Dim priceNodes As HtmlAgilityPack.HtmlNodeCollection = hdoc1.DocumentNode.SelectNodes("//div[@class='divPriceValue']")
            Dim atpNodes As HtmlAgilityPack.HtmlNodeCollection = hdoc1.DocumentNode.SelectNodes("//div[@class='divATPValue']")
          
            For Each pNode As HtmlAgilityPack.HtmlNode In priceNodes
                Dim partNoNode As HtmlAgilityPack.HtmlNode = pNode.ParentNode.ParentNode.SelectSingleNode("input[@class='compOption']")
                pNode.InnerHtml = MyCBOMDAL.GetPrice(partNoNode.Attributes("compname").Value)
            Next
            For Each atpNode As HtmlAgilityPack.HtmlNode In atpNodes
                Dim partNoNode As HtmlAgilityPack.HtmlNode = atpNode.ParentNode.ParentNode.SelectSingleNode("input[@class='compOption']")
                atpNode.InnerHtml = MyCBOMDAL.GetATP(partNoNode.Attributes("compname").Value, reconfigDt.Rows(0).Item("CONFIG_QTY")).ToString("yyyy/MM/dd")
            Next
            With ReconfigTreeObject1
                .BTOItem = reconfigDt.Rows(0).Item("ROOT_CATEGORY_ID") : .ReConfigQty = reconfigDt.Rows(0).Item("CONFIG_QTY")
                .ReConfigTreeHtml = hdoc1.DocumentNode.InnerHtml
            End With
        End If
        Dim serializer = New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(ReconfigTreeObject1)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function SaveConfigResult(ByVal RootComp As ConfiguredComponent, ByVal ConfigQty As Integer, ByVal ConfigTreeHtml As String) As String
        'Save config tree html to eQuotation.dbo.CTOS_CONFIG_LOG for re-configuration purpose
        Dim eqCmd As New SqlClient.SqlCommand( _
            " insert into CTOS_CONFIG_LOG (ROW_ID, ROOT_CATEGORY_ID, CONFIG_QTY, USERID, COMPANY_ID, ORG_ID, CONFIG_TREE_HTML, CART_ID) " + _
            " values(@RID, @BTOITEM, @QTY, @UID, @ERPID, @ORGID, @CONFIGHTML, @CARTID)", _
            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString))
        With eqCmd.Parameters
            .AddWithValue("RID", System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)) : .AddWithValue("BTOITEM", RootComp.CategoryId) : .AddWithValue("QTY", ConfigQty)
            .AddWithValue("UID", HttpContext.Current.User.Identity.Name) : .AddWithValue("ERPID", HttpContext.Current.Session("company_id").ToString()) : .AddWithValue("ORGID", HttpContext.Current.Session("org_id").ToString())
            .AddWithValue("CONFIGHTML", ConfigTreeHtml) : .AddWithValue("CARTID", HttpContext.Current.Session("cart_id").ToString())
        End With
        eqCmd.Connection.Open() : eqCmd.ExecuteNonQuery() : eqCmd.Connection.Close()

        Dim procObj As New MyCBOMDAL.SaveToCartResult
        Try
            Dim dt As DataTable = Util.GetConfigOrderCartDt()
            If Not dt.Columns.Contains("Level") Then dt.Columns.Add("Level", GetType(Integer))
            If Not dt.Columns.Contains("ATP_DATE") Then dt.Columns.Add("ATP_DATE", GetType(Date))
            RecursiveGetConfigResult(RootComp, "Root", dt, ConfigQty, 0)

            '20130619 TC: comment below logic for calculating price, inventory and ex-warranty, because it has been handled in save2cart function
            'Find if AGS-EW is selected
            'Dim blHasEW As Boolean = False, dEwRate As Double = 0
            'For Each rComp As DataRow In dt.Rows
            '    If rComp.Item("category_type") = "Component" AndAlso _
            '        rComp.Item("category_id").ToString.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
            '        dEwRate = Glob.getRateByEWItem(rComp.Item("category_id"), Left(HttpContext.Current.Session("org_id"), 2) + "H1")
            '        blHasEW = True
            '        Exit For
            '    End If
            'Next

            ''If AGS-EW is selected, calculate EW fee
            'If blHasEW Then
            '    Dim dTotalAmt As Double = 0
            '    For Each rComp As DataRow In dt.Rows
            '        If rComp.Item("category_type") = "Component" AndAlso _
            '            Not rComp.Item("category_id").ToString.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
            '            dTotalAmt += rComp.Item("category_price")
            '        End If
            '    Next
            '    For Each rComp As DataRow In dt.Rows
            '        If rComp.Item("category_type") = "Component" AndAlso _
            '            rComp.Item("category_id").ToString.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
            '            rComp.Item("category_price") = dTotalAmt * dEwRate
            '            Exit For
            '        End If
            '    Next
            '    dt.AcceptChanges()
            'End If

            Dim retbool As Boolean = False
            'If Util.IsTestingQuote2Order() Then
            retbool = MyCBOMDAL.SaveConfig2Cart_V2(dt, RootComp.CategoryId, ConfigQty)
            'Else
            '    retbool = MyCBOMDAL.SaveConfig2Cart(dt, RootComp.CategoryId, ConfigQty)
            'End If
            'If MyCBOMDAL.SaveConfig2Cart(dt, RootComp.CategoryId, ConfigQty) Then
            If retbool Then
                procObj.ProcessStatus = True : procObj.ProcessMessage = "ok"
            Else
                procObj.ProcessStatus = False : procObj.ProcessMessage = "not ok"
            End If
        Catch ex As Exception
            procObj.ProcessStatus = False : procObj.ProcessMessage = ex.ToString()
        End Try
        Dim serializer = New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(procObj)
    End Function

    Private Shared Sub RecursiveGetConfigResult( _
        ByRef Comp As ConfiguredComponent, ByVal ParentCatId As String, ByRef dt As DataTable, ByRef ConfigQty As Integer, ByVal intLevel As Integer)
        '\ Ming add 20140821 
        If Comp.CategoryId.Contains("|") Then
            Dim PartNOs As String() = Comp.CategoryId.Trim.Split(New Char() {"|"}, System.StringSplitOptions.RemoveEmptyEntries)
            For Each Part As String In PartNOs
                Dim compRow As DataRow = dt.NewRow()
                With compRow
                    .Item("category_id") = Part : .Item("Level") = intLevel : .Item("category_name") = Part
                    .Item("category_qty") = ConfigQty : .Item("PARENT_CATEGORY_ID") = ParentCatId
                End With
                Select Case Comp.CategoryType
                    Case "category"
                        compRow.Item("CATEGORY_TYPE") = "Category"
                    Case "component"
                        compRow.Item("CATEGORY_TYPE") = "Component" : compRow.Item("category_price") = MyCBOMDAL.GetPrice(Comp.CategoryId)
                        compRow.Item("ATP_DATE") = MyCBOMDAL.GetATP(Part, ConfigQty)
                End Select
                dt.Rows.Add(compRow)
            Next
        Else
            Dim compRow As DataRow = dt.NewRow()
            With compRow
                .Item("category_id") = Comp.CategoryId : .Item("Level") = intLevel : .Item("category_name") = Comp.CategoryId
                .Item("category_qty") = ConfigQty : .Item("PARENT_CATEGORY_ID") = ParentCatId
            End With
            Select Case Comp.CategoryType
                Case "category"
                    compRow.Item("CATEGORY_TYPE") = "Category"
                Case "component"
                    compRow.Item("CATEGORY_TYPE") = "Component" : compRow.Item("category_price") = MyCBOMDAL.GetPrice(Comp.CategoryId)
                    compRow.Item("ATP_DATE") = MyCBOMDAL.GetATP(Comp.CategoryId, ConfigQty)
            End Select
            dt.Rows.Add(compRow)
        End If
        '/end
        For Each childComp As ConfiguredComponent In Comp.ChildComps
            RecursiveGetConfigResult(childComp, Comp.CategoryId, dt, ConfigQty, intLevel + 1)
        Next
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetCompPriceATP(ByVal ComponentCategoryId As String, ByVal ConfigQty As Integer) As String
        Dim objPriceATP As MyCBOMDAL.PriceATP = MyCBOMDAL.GetCompPriceATP(ComponentCategoryId, ConfigQty)
        Dim serializer = New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(objPriceATP)
    End Function

    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function GetCBOM(ByVal ParentCategoryId As String, ByVal ConfigQty As Integer, ByVal RootId As String) As String
        'Return ParentCategoryId
        Try
            Dim cBomDal As New MyCBOMDAL
            Dim dtBom As CBOMDS.CBOM_CATALOG_CATEGORYDataTable = cBomDal.GetCBOM2(ParentCategoryId, HttpContext.Current.Session("RBU"), HttpContext.Current.Session("org_id"), RootId)
            Dim lsCBom As New List(Of CBom)
            For Each rBom As CBOMDS.CBOM_CATALOG_CATEGORYRow In dtBom.Rows
                Dim bom1 As New CBom
                bom1.ChildCategories = New List(Of CBom)
                With bom1
                    .CategoryType = rBom.CATEGORY_TYPE : .CategoryId = rBom.CATEGORY_ID : .Description = rBom.CATEGORY_NAME
                    .IsCatRequired = IIf(String.Equals(rBom.CONFIGURATION_RULE, "REQUIRED", StringComparison.CurrentCultureIgnoreCase), True, False)
                    '.ClientId = AEUIT_Rijndael.EncryptDefault(rBom.CATEGORY_ID)
                    .CalcClientId(rBom.PARENT_CATEGORY_ID + rBom.CATEGORY_ID + rBom.SEQ_NO.ToString())
                    .IsCompRoHS = False : .IsHot = False
                End With
                lsCBom.Add(bom1)
                If String.Equals(bom1.CategoryType, "Category", StringComparison.CurrentCultureIgnoreCase) Or String.Equals(bom1.CategoryType, "extendedcategory", StringComparison.CurrentCultureIgnoreCase) Then
                    Dim dtComps As CBOMDS.CBOM_CATALOG_CATEGORYDataTable = cBomDal.GetCBOM2(bom1.CategoryId, HttpContext.Current.Session("RBU"), HttpContext.Current.Session("org_id"), RootId)
                    For Each rComp As CBOMDS.CBOM_CATALOG_CATEGORYRow In dtComps.Rows
                        Dim compBom As New CBom
                        With compBom
                            .CategoryId = rComp.CATEGORY_ID : .CategoryType = rComp.CATEGORY_TYPE : .IsCatRequired = False : .Description = rComp.CATEGORY_DESC
                            '.ClientId = AEUIT_Rijndael.EncryptDefault(rComp.CATEGORY_ID)
                            .CalcClientId(rComp.PARENT_CATEGORY_ID + rComp.CATEGORY_ID + rComp.SEQ_NO.ToString())
                            .IsCompDefault = IIf(String.Equals(rComp.CONFIGURATION_RULE, "DEFAULT", StringComparison.CurrentCultureIgnoreCase) AndAlso bom1.IsCatRequired = True, True, False)
                            .IsCompRoHS = IIf(String.Equals(rComp.RoHS, "y", StringComparison.CurrentCultureIgnoreCase), True, False)

                            'Ryan 20160704 Add for EU hot icon validation for Ptrade products
                            If HttpContext.Current.Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                                If Glob.IsPTD(rComp.CATEGORY_ID) Then
                                    Dim abc_indicator As String = Advantech.Myadvantech.Business.PartBusinessLogic.GetABCIndicator(rComp.CATEGORY_ID, "EUH1")
                                    .IsHot = IIf((abc_indicator.StartsWith("A", StringComparison.OrdinalIgnoreCase) OrElse abc_indicator.StartsWith("B", StringComparison.OrdinalIgnoreCase)), True, False)
                                Else
                                    .IsHot = False
                                End If
                            Else
                                .IsHot = False
                            End If

                        End With
                        bom1.ChildCategories.Add(compBom)
                    Next
                End If
            Next
            Dim serializer = New Script.Serialization.JavaScriptSerializer()
            Return serializer.Serialize(lsCBom)
        Catch ex As Exception
            Return ex.ToString()
        End Try

    End Function

    Private Sub SetSourcePath(ByVal strBTOItem As String, ByVal intConfigQty As Integer)
        Dim strhtml As String = ""
        If get_catalog_type(strBTOItem).ToLower = "iservices group" Then
            If Not Util.ISIServices_Group_Account() Then
                Response.Redirect("~/home.aspx")
            End If
        End If
        strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='./btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
        If MyCBOMDAL.IsEstoreBom(strBTOItem) Then
            strhtml += "<a href='./CBOM_eStoreBTO_List1.aspx' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + "eStore BTOS" + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
        Else
            strhtml += "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(Request("BTOITEM"))) + "' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + get_catalog_type(Trim(Request("BTOITEM")), 1) + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
        End If
        strhtml += "<a href='./Configurator.aspx?BTOITEM=" + strBTOItem + "&QTY=" + intConfigQty.ToString() + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + strBTOItem + "</a>"

        page_path.InnerHtml = strhtml
    End Sub

    Private Shared Function get_catalog_type(ByVal name As String, Optional ByVal Flag As Integer = 0) As String
        Dim catalog_name As String = ""
        Dim dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select catalog_type from CBOM_CATALOG where Catalog_org='" & Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2) & "' and CATALOG_NAME = '" + name + "'")
        If dt.Rows.Count > 0 Then
            If Not Convert.IsDBNull(dt.Rows(0).Item("catalog_type")) Then
                catalog_name = dt.Rows(0).Item("catalog_type").ToString.Trim
            End If
        End If
        If Flag = 1 Then
            Dim CBOMWS As New MyCBOMDAL
            Return CBOMWS.getCatalogLocalName(catalog_name, Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2))
        Else
            Return catalog_name
        End If
    End Function

End Class
