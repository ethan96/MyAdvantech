<%@ Page Title="MyAdvantech - Advantech Gift List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">      

    Protected Sub btnUploadNewPN_Click(sender As Object, e As System.EventArgs)
        lbAddMsg.Text = ""
        If Not txtNewGiftPN.Text.StartsWith("GIFT", StringComparison.CurrentCultureIgnoreCase) Then
            lbAddMsg.Text = "PN should start with GIFT" : Exit Sub
        End If
        If Not IsImgFileValid(FileNewPNImg, lbAddMsg.Text) Then
            Exit Sub
        End If

        Dim uploadSql As String = _
            " insert into ADV_GIFT_LIST (ROW_ID, PART_NO, MARCOM_DESC, IMAGE_FILE, NOTE, IS_ACTIVE, LAST_UPD_BY, SEQ_NO, CATEGORY, CREATED_DATE) " + _
            " values (@ROWID, @PN, @DESC, @FBIN, @NOTE, @ACTIVE, @UID, -1, @CATEGORY, @CREATED_DATE); update ADV_GIFT_LIST set seq_no=seq_no+1;"
        Dim cmd As New SqlClient.SqlCommand(uploadSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
        With cmd.Parameters
            .AddWithValue("ROWID", Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)) : .AddWithValue("PN", UCase(Trim(txtNewGiftPN.Text)))
            .AddWithValue("DESC", txtNewDesc.Text) : .AddWithValue("FBIN", FileNewPNImg.FileBytes) : .AddWithValue("NOTE", txtNewNote.Text) : .AddWithValue("CREATED_DATE", DateTime.Now)
            .AddWithValue("ACTIVE", IIf(rblIsPnActive.SelectedIndex = 0, 1, 0)) : .AddWithValue("UID", User.Identity.Name) : .AddWithValue("CATEGORY", txtNewCategory.Text)
        End With
        cmd.Connection.Open()
        cmd.ExecuteNonQuery()
        cmd.Connection.Close()
        txtNewGiftPN.Text = "" : txtNewDesc.Text = "" : txtNewNote.Text = ""
        lbAddMsg.Text = "Added"
        LoadGiftList(txtNewCategory.Text) 'ICC 2014/08/22 After creating new gift item, automatically put the category text to query this type of category.
        If gvInactiveList.Rows.Count > 0 AndAlso rblIsPnActive.SelectedIndex = 1 Then 'ICC 2015/1/12 If inactive has data, then reload gridview 
            LoadInActiveList()
            upInactiveList.Update()
        End If
    End Sub

    Public Shared Function IsImgFileValid(fup As FileUpload, ErrMsg As String) As Boolean
        If fup.HasFile = False OrElse fup.FileBytes.Length = 0 OrElse fup.FileBytes.Length >= 1024 * 1000 * 10 Then
            ErrMsg = "No file or file size is too huge" : Return False
        End If
        If Not fup.FileName.EndsWith(".png", StringComparison.CurrentCultureIgnoreCase) _
            And Not fup.FileName.EndsWith(".jpg", StringComparison.CurrentCultureIgnoreCase) _
            And Not fup.FileName.EndsWith(".gif", StringComparison.CurrentCultureIgnoreCase) _
            And Not fup.FileName.EndsWith(".bmp", StringComparison.CurrentCultureIgnoreCase) Then
            ErrMsg = "Uploaded file is not an image" : Return False
        End If
        Return True
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("IMGID") IsNot Nothing Then
            Response.Clear()
            Dim imgId As String = Trim(Request("IMGID"))
            Dim dicGiftImgCache As Dictionary(Of String, Byte()) = Cache("GiftImgCache")
            If dicGiftImgCache Is Nothing Then
                dicGiftImgCache = New Dictionary(Of String, Byte())
                Cache.Add("GiftImgCache", dicGiftImgCache, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            End If
            If Not dicGiftImgCache.ContainsKey(imgId) Then
                Dim fbin As Byte() = dbUtil.dbExecuteScalar("MYLOCAL_NEW", "select top 1 IMAGE_FILE from ADV_GIFT_LIST where ROW_ID='" + Replace(imgId, "'", "''") + "'")
                If fbin IsNot Nothing AndAlso fbin.Length > 0 Then
                    dicGiftImgCache.Add(imgId, fbin)
                End If
            End If
            If dicGiftImgCache.ContainsKey(imgId) Then
                Dim fbin As Byte() = dicGiftImgCache.Item(imgId)
                : Response.ContentType = "image/png" : Response.BinaryWrite(fbin)
            End If
            Response.End()
        End If
        'IC 2014/07/28 Add thumbnail image
        If Request("THUMBID") IsNot Nothing Then
            Response.Clear()
            Try
                Dim imgId As String = Trim(Request("THUMBID"))
                Dim dicGiftThumbCache As Dictionary(Of String, Byte()) = Cache("GiftThumbCache")
                If dicGiftThumbCache Is Nothing Then
                    dicGiftThumbCache = New Dictionary(Of String, Byte())
                    Cache.Add("GiftThumbCache", dicGiftThumbCache, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
                End If
                If Not dicGiftThumbCache.ContainsKey(imgId) Then
                    Dim obj As Object = dbUtil.dbExecuteScalar("MYLOCAL_NEW", "select top 1 THUMBNAIL_FILE from ADV_GIFT_LIST where ROW_ID='" + Replace(imgId, "'", "''") + "'")
                    If obj IsNot DBNull.Value AndAlso obj IsNot Nothing Then
                        dicGiftThumbCache.Add(imgId, CType(obj, Byte()))
                    Else
                        Dim fbin As Byte() = dbUtil.dbExecuteScalar("MYLOCAL_NEW", "select top 1 IMAGE_FILE from ADV_GIFT_LIST where ROW_ID='" + Replace(imgId, "'", "''") + "'")
                        If fbin IsNot Nothing AndAlso fbin.Length > 0 Then
                            Dim tbin As Byte() = OutputThumbnail(fbin)
                            If tbin IsNot Nothing AndAlso tbin.Length > 0 Then
                                Dim uploadSql As String = "update ADV_GIFT_LIST set THUMBNAIL_FILE = @FBIN where ROW_ID= @ROWID "
                                Dim cmd As New SqlClient.SqlCommand(uploadSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
                                With cmd.Parameters
                                    .AddWithValue("ROWID", Replace(imgId, "'", "''")) : .AddWithValue("FBIN", tbin)
                                End With
                                cmd.Connection.Open()
                                cmd.ExecuteNonQuery()
                                cmd.Connection.Close()
                                dicGiftThumbCache.Add(imgId, tbin)
                            End If
                        End If
                    End If
                End If
                If dicGiftThumbCache.ContainsKey(imgId) Then
                    Dim fbin As Byte() = dicGiftThumbCache.Item(imgId)
                    : Response.ContentType = "image/png" : Response.BinaryWrite(fbin)
                End If
            Catch ex As Exception
                Util.InsertMyErrLog("GiftList.aspx Show thumbnail error:" + ex.ToString)
            End Try
            Response.End()
        End If
        '20150715 TC: Per PR Jennifer.Huang's request, block access for none-employee users 20150907 ICC change code to here
        If MailUtil.IsInMailGroup("CRM.ACL", User.Identity.Name) OrElse MailUtil.IsInMailGroup("EIP.ACL", User.Identity.Name) OrElse Session("account_status") <> "EZ" Then
            Response.Redirect("../../home.aspx")
        End If
        'ICC 2014/08/25 Dynamically create LinkButton by all kinds of category type
        Dim dtCategory As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", "SELECT CATEGORY FROM ADV_GIFT_LIST WHERE IS_ACTIVE='1' GROUP BY CATEGORY ORDER BY MIN(CREATED_DATE)")
        If Not dtCategory Is Nothing AndAlso dtCategory.Rows.Count > 0 Then
            For i As Integer = 0 To dtCategory.Rows.Count - 1
                Dim lnkBtn As New LinkButton()
                lnkBtn.Text = dtCategory(i)(0).ToString()
                lnkBtn.Font.Size = FontUnit.Medium
                AddHandler lnkBtn.Click, AddressOf LinkButton_Click
                Dim image As New Image()
                image.ImageUrl = "~/Images/fenceline.jpg"
                image.AlternateText = ""
                image.Height = Unit.Pixel(10)
                image.Width = Unit.Pixel(2)
                giftPH.Controls.Add(lnkBtn)
                giftPH.Controls.Add(New LiteralControl("&nbsp;"))
                giftPH.Controls.Add(image)
                giftPH.Controls.Add(New LiteralControl("&nbsp;"))
                CType(Master.FindControl("tlsm1"), ToolkitScriptManager).RegisterAsyncPostBackControl(lnkBtn) 'ICC 2014/10/22 Register dynamic LinkButtons to ScriptManager
            Next
            Dim lnkBtnAll As New LinkButton()
            lnkBtnAll.Text = "All"
            lnkBtnAll.Font.Size = FontUnit.Medium
            CType(Master.FindControl("tlsm1"), ToolkitScriptManager).RegisterAsyncPostBackControl(lnkBtnAll) 'ICC 2014/10/22 Register dynamic LinkButtons to ScriptManager
            AddHandler lnkBtnAll.Click, AddressOf LinkButton_Click
            giftPH.Controls.Add(lnkBtnAll)
            giftPH.Controls.Add(New LiteralControl("&nbsp;<br />"))
        End If
        lbInactMsg.Text = String.Empty
        lbAddMsg.Text = String.Empty
        lbUpdMsg.Text = String.Empty
        If Not Page.IsPostBack Then
            LoadGiftList("Corporate Gift") 'Defualt category is "Corporate Gift" request by Wen
            tabcon1.Tabs(1).Visible = IsGiftAdmin() : tabcon1.Tabs(2).Visible = IsGiftAdmin() : tabcon1.Tabs(3).Visible = IsGiftAdmin()
        End If
    End Sub
    'ICC 2014/08/25 Create LinkButton click event
    Protected Sub LinkButton_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lnkBtn As LinkButton
        lnkBtn = CType(sender, LinkButton)
        lnkBtn.Font.Bold = True
        lnkBtn.BackColor = Drawing.Color.LightGray
        lblCategory.Text = lnkBtn.Text
        LoadGiftList(lblCategory.Text)
        'ICC 2015/4/13 When select Clothing or All type, then show the clothing size picture link
        If lblCategory.Text = "Clothing" OrElse lblCategory.Text = "All" Then
            SizeMap.Visible = True
        Else
            SizeMap.Visible = False
        End If
        upGiftList.Update() ''ICC 2014/10/22 Update UpdatePanel as dynamic LinkButtons be clicked
    End Sub

    Sub LoadGiftList(ByVal category As String)
        Dim LastUpdDate As Date = Date.MinValue
        Dim giftDt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", _
                              " SELECT a.ROW_ID, a.PART_NO, a.MARCOM_DESC, a.NOTE, a.LAST_UPD_DATE, a.CREATED_DATE, a.LAST_UPD_BY, a.SEQ_NO, a.CATEGORY " + _
                              " FROM ADV_GIFT_LIST a " + _
                              " where a.IS_ACTIVE=1 " + _
                              " ORDER BY a.SEQ_NO, a.PART_NO ")
        giftDt.Columns.Add("ATP", GetType(Decimal)) : giftDt.Columns.Add("USD_PRICE", GetType(Decimal)) : giftDt.Columns.Add("TWD_PRICE", GetType(Decimal)) : giftDt.Columns.Add("COST", GetType(String)) 'ICC 2014/10/22 Add new column COST
        Dim exchRateUsd2Twd As Object = dbUtil.dbExecuteScalar("MY", "select top 1 UKURS from SAP_EXCHANGERATE where FCURR='USD' and TCURR='TWD' order by EXCH_DATE desc")
        If exchRateUsd2Twd Is Nothing Then exchRateUsd2Twd = "30"
        Dim ws As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim QueryInTable As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, QueryOutTable As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable ', errMsg As String = ""
        Dim pnList As New List(Of String)

        For Each gr As DataRow In giftDt.Rows
            If DateDiff(DateInterval.Day, LastUpdDate, gr.Item("LAST_UPD_DATE")) > 0 Then
                LastUpdDate = gr.Item("LAST_UPD_DATE")
            End If

            Dim QInRec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With QInRec
                .Kunnr = "ASPA001" : .Mandt = "168" : .Matnr = UCase(gr.Item("PART_NO")) : .Mglme = 1 : .Vkorg = "TW01" : .Prsdt = Now.ToString("yyyyMMdd")
            End With
            QueryInTable.Add(QInRec)
            'pin.AddProductInRow(gr.Item("PART_NO"), 1)
            pnList.Add(gr("PART_NO").ToString)
        Next

        'ICC 2014/10/22 Get cost from sap and add it to cache
        Dim dicCost As Dictionary(Of String, Object) = Cache("GiftCostCache")
        If dicCost Is Nothing Then
            dicCost = New Dictionary(Of String, Object)
            Cache.Add("GiftCostCache", dicCost, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        Try
            Dim zeroPN As New List(Of String)
            For Each pn As String In pnList
                If Not dicCost.ContainsKey(pn) Then
                    zeroPN.Add(pn)
                End If
            Next
            If zeroPN.Count > 0 Then
                Dim msd As New MYSAPDAL
                Dim dtCost As New DataTable
                dtCost = msd.GetSAPPNCost(zeroPN.ToArray(), "TW01")
                If Not dtCost Is Nothing AndAlso dtCost.Rows.Count > 0 Then
                    For Each dr As DataRow In dtCost.Rows
                        If Not dicCost.ContainsKey(dr("PART_NO").ToString) AndAlso dr("COST") IsNot DBNull.Value Then
                            Dim cost As Decimal = 0D
                            Decimal.TryParse(dr("COST").ToString, cost)
                            If cost > 0 Then dicCost.Add(dr("PART_NO").ToString, dr("COST")) 'ICC 20150907 Only cache cost  is bigger then 0
                        End If
                    Next
                End If
            End If
        Catch ex As Exception
            Throw New Exception("GetSAPPNCost error! " + ex.Message)
        End Try
        ws.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        ws.Connection.Open()
        Try
            ws.Z_Sd_Eupriceinquery("1", QueryInTable, QueryOutTable)
            ws.Connection.Close()
        Catch ex As Exception
            ws.Connection.Close()
            Throw New Exception("call SAP RFC Z_SD_EUPRICEINQUERY error:" + ex.ToString())
        End Try
        'gvPrice.DataSource = QueryOutTable.ToADODataTable() : gvPrice.DataBind()
        Dim PriceList As New List(Of Z_SD_EUPRICEINQUERY.ZSSD_02_EU) '= QueryOutTable.AsQueryable()
        For Each OutRec As Z_SD_EUPRICEINQUERY.ZSSD_02_EU In QueryOutTable
            PriceList.Add(OutRec)
        Next
        'ws.GetPrice("ASPA001", "ASPA001", "TW01", pin, pout, errMsg)

        'ICC 2015/3/6 Change get atp source from GetAllGiftATP() to RFC.
        'Dim atpDt As DataTable = GetAllGiftATP()
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        For Each gr As DataRow In giftDt.Rows
            Dim currentGiftPN As String = UCase(gr.Item("part_no"))
            'Dim prs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + gr.Item("part_no") + "'")
            'If prs.Length > 0 Then
            '    gr.Item("USD_PRICE") = prs(0).LIST_PRICE
            'End If
            Dim p = From q In PriceList Where q.Matnr = currentGiftPN
            If p.Count > 0 Then
                gr.Item("USD_PRICE") = p(0).Kzwi1
                If p(0).Kzwi1 = 0 Then gr.Item("USD_PRICE") = p(0).Netwr
                gr.Item("TWD_PRICE") = FormatNumber(p(0).Kzwi1 * CDbl(exchRateUsd2Twd), 0)
            Else
                gr.Item("USD_PRICE") = -1
            End If

            gr.Item("ATP") = 0
            'Dim rrs() As DataRow = atpDt.Select("matnr='" + gr.Item("part_no") + "'")
            'If rrs.Length > 0 Then
            '    gr.Item("ATP") = rrs(0).Item("qty")
            'End If
            Dim Inventory As Integer = 0
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd")
            retTb.Add(rOfretTb)
            p1.Bapi_Material_Availability("", "ZG", "", New Short, "", "", "", currentGiftPN, UCase("TWH1"), "", "", "", "", "PC", "", Inventory, "", "", _
                                          New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            Inventory = 0
            Dim atpRFC As DataTable = atpTb.ToADODataTable()
            If atpRFC.Rows.Count > 0 Then
                Inventory = CType(atpRFC.Rows(0).Item("com_qty"), Int64)
            End If
            gr.Item("ATP") = Inventory
            'ICC 2014/10/22 Get cost by part no
            If Not dicCost Is Nothing AndAlso dicCost.ContainsKey(gr.Item("PART_NO").ToString) Then
                gr.Item("COST") = String.Format("TWD {0} ", Convert.ToInt32(dicCost(gr.Item("PART_NO").ToString)))
            Else
                gr.Item("COST") = "N/A"
            End If
            If gr.Item("COST") Is DBNull.Value Then gr.Item("COST") = "N/A" 'ICC 2015/5/5 Prevent DB NULL value
        Next
        p1.Connection.Close()
        lbLastUpdDate.Text = LastUpdDate.ToShortDateString()
        'ICC 2014/08/22 Select the type of category
        If Not category = "All" AndAlso giftDt.Select(String.Format("CATEGORY = '{0}'", category)).Count > 0 Then
            giftDt = giftDt.Select(String.Format("CATEGORY = '{0}'", category)).CopyToDataTable()
        End If
        For Each c As Control In giftPH.Controls
            If TypeOf (c) Is LinkButton Then
                Dim lb As LinkButton = CType(c, LinkButton)
                If lb.Text = category Then
                    lb.BackColor = Drawing.Color.LightGray
                    lb.Font.Bold = True
                Else
                    lb.BackColor = Drawing.Color.White
                    lb.Font.Bold = False
                End If
            End If
        Next
        gvGiftList.DataSource = giftDt.DefaultView
        gvGiftList.DataBind()
        gvGiftList.Columns(gvGiftList.Columns.Count - 1).Visible = IsGiftAdmin()
        gvGiftList.Columns(4).Visible = IsGiftAdmin() 'ICC 2014/10/22 The cost column can only be read by IT members and Wen 
    End Sub

    Function IsGiftAdmin() As Boolean
        Dim AdminList() As String = {"tc.chen@advantech.com.tw", "wen.chiang@advantech.com.tw", "frank.chung@advantech.com.tw", "jennifer.huang@advantech.com.tw"} '2015/4/13 Add Jennifer admin rights
        Return AdminList.Contains(User.Identity.Name.ToLower())
    End Function

    Function GetAllGiftATP() As DataTable
        Return OraDbUtil.dbGetDataTable("SAP_PRD", _
                                 " select a.matnr, sum(a.labst) as qty " + _
                                 " from saprdp.mard a where a.mandt='168' and a.matnr like 'GIFT%' and a.werks='TWH1' " + _
                                 " group by a.matnr having sum(a.labst)>0 " + _
                                 " order by a.matnr ")
    End Function

    Protected Sub lnkDel_Click(sender As Object, e As System.EventArgs)
        Dim DelRowId As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hdRowId"), HiddenField).Value
        dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", "delete from ADV_GIFT_LIST where ROW_ID='" + DelRowId + "'")
        LoadGiftList(lblCategory.Text)
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestGiftPN(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                              " select top 10 a.part_no from sap_product a where a.part_no like N'{0}%' and a.part_no like 'GIFT%' order by a.part_no ", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub lnkUpDown_Click(sender As Object, e As System.EventArgs)
        Dim RowId As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hdRowId"), HiddenField).Value
        Dim OSeq As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hSeq"), HiddenField).Value
        Dim PlusMinus As String = ""
        Select Case CType(sender, LinkButton).ID
            Case "lnkUp"
                'PlusMinus = "-"
                Dim dtNextSeqId As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", String.Format("select top 1 row_id,seq_no from ADV_GIFT_LIST where seq_no < {0} order by seq_no desc", OSeq))
                If Not IsNothing(dtNextSeqId) AndAlso dtNextSeqId.Rows.Count > 0 Then
                    Dim nextId As String = dtNextSeqId.Rows(0).Item("row_id")
                    Dim nextSeq As Integer = dtNextSeqId.Rows(0).Item("seq_no")
                    Dim strSQL As String = String.Format("update ADV_GIFT_LIST set SEQ_NO = {0}, LAST_UPD_DATE = GETDATE() where ROW_ID='{1}' ;update ADV_GIFT_LIST set SEQ_NO = {2}, LAST_UPD_DATE = GETDATE() where ROW_ID='{3}' ", nextSeq, RowId, OSeq, nextId)
                    dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", strSQL)
                End If
            Case "lnkDown"
                'PlusMinus = "+"
                Dim dtNextSeqId As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", String.Format("select top 1 row_id,seq_no from ADV_GIFT_LIST where seq_no > {0} order by seq_no", OSeq))
                If Not IsNothing(dtNextSeqId) AndAlso dtNextSeqId.Rows.Count > 0 Then
                    Dim nextId As String = dtNextSeqId.Rows(0).Item("row_id")
                    Dim nextSeq As Integer = dtNextSeqId.Rows(0).Item("seq_no")
                    Dim strSQL As String = String.Format("update ADV_GIFT_LIST set SEQ_NO = {0}, LAST_UPD_DATE = GETDATE() where ROW_ID='{1}' ;update ADV_GIFT_LIST set SEQ_NO = {2}, LAST_UPD_DATE = GETDATE() where ROW_ID='{3}'", nextSeq, RowId, OSeq, nextId)
                    dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", strSQL)
                End If
        End Select
        LoadGiftList(lblCategory.Text)
    End Sub

    Protected Sub txtSeqNo_TextChanged(sender As Object, e As System.EventArgs)
        Dim RowId As String = CType(CType(sender, TextBox).NamingContainer.FindControl("hdRowId"), HiddenField).Value
        Dim newSeqNo As String = CType(sender, TextBox).Text
        dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", "update ADV_GIFT_LIST set SEQ_NO=" + newSeqNo + " where ROW_ID='" + RowId + "'")
        LoadGiftList(lblCategory.Text)
    End Sub

    Protected Sub btnUpd_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim RowId As String = CType(CType(sender, ImageButton).NamingContainer.FindControl("hdRowId"), HiddenField).Value
        Dim dtPNInfo As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", "select PART_NO, MARCOM_DESC, NOTE, IS_ACTIVE, SEQ_NO, CATEGORY from ADV_GIFT_LIST where ROW_ID='" + RowId + "'")
        If dtPNInfo.Rows.Count = 1 Then
            With dtPNInfo.Rows(0)
                hdUpdRowId.Value = RowId : lbUpdPn.Text = .Item("PART_NO") : txtUpdDesc.Text = .Item("MARCOM_DESC") : txtUpdNote.Text = .Item("NOTE") : rblUpdActive.SelectedIndex = IIf(.Item("IS_ACTIVE") = "1", 0, 1) : txtUpdCategory.Text = .Item("CATEGORY")
            End With
            tabcon1.ActiveTabIndex = 2
        End If
    End Sub

    Protected Sub btnUpdPN_Click(sender As Object, e As System.EventArgs)
        lbUpdMsg.Text = ""
        If fupUpdImgFile.HasFile Then
            If Not IsImgFileValid(fupUpdImgFile, lbUpdMsg.Text) Then
                Exit Sub
            End If
        End If

        Dim sbSql As New System.Text.StringBuilder
        With sbSql
            .AppendLine(" update ADV_GIFT_LIST set MARCOM_DESC=@DESC, NOTE=@NOTE, IS_ACTIVE=@ACT, CATEGORY = @CATEGORY, LAST_UPD_DATE = GETDATE() ")
            If fupUpdImgFile.HasFile Then
                .AppendLine(", IMAGE_FILE=@IMGBIN, THUMBNAIL_FILE=@THUMBBIN ")
            End If
            .AppendLine(" where ROW_ID=@RID ")
        End With
        Dim MyLocalCmd As New SqlClient.SqlCommand(sbSql.ToString(), New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
        With MyLocalCmd.Parameters
            .AddWithValue("DESC", txtUpdDesc.Text) : .AddWithValue("NOTE", txtUpdNote.Text) : .AddWithValue("ACT", IIf(rblUpdActive.SelectedIndex = 0, 1, 0)) : .AddWithValue("CATEGORY", txtUpdCategory.Text)
            If fupUpdImgFile.HasFile Then
                .AddWithValue("IMGBIN", fupUpdImgFile.FileBytes) : .AddWithValue("THUMBBIN", OutputThumbnail(fupUpdImgFile.FileBytes))
            End If
            .AddWithValue("RID", hdUpdRowId.Value)
        End With
        MyLocalCmd.Connection.Open() : MyLocalCmd.ExecuteNonQuery() : MyLocalCmd.Connection.Close()
        Dim dicGiftImgCache As Dictionary(Of String, Byte()) = Cache("GiftImgCache")
        If dicGiftImgCache IsNot Nothing Then
            If dicGiftImgCache.ContainsKey(hdUpdRowId.Value) Then
                dicGiftImgCache.Remove(hdUpdRowId.Value)
            End If
        End If
        Dim dicGiftThumbCache As Dictionary(Of String, Byte()) = Cache("GiftThumbCache")
        If dicGiftThumbCache IsNot Nothing Then
            If dicGiftThumbCache.ContainsKey(hdUpdRowId.Value) Then
                dicGiftThumbCache.Remove(hdUpdRowId.Value)
            End If
        End If
        lbUpdMsg.Text = "Updated"
        LoadGiftList(txtNewCategory.Text)
        If gvInactiveList.Rows.Count > 0 AndAlso rblUpdActive.SelectedIndex = 1 Then  'ICC 2015/1/12 If inactive has data, then reload gridview 
            LoadInActiveList()
            upInactiveList.Update()
        End If
    End Sub
    'IC 2014/07/28 Add OutputThumbnail function to transfer image
    Public Function OutputThumbnail(ByVal fbin As Byte()) As Byte()
        Dim ms As New IO.MemoryStream
        Try
            Dim stream As IO.Stream = New IO.MemoryStream(fbin)
            Dim img As New System.Drawing.Bitmap(stream)
            Dim width As Double = img.Width
            Dim height As Double = img.Height
            Dim rate As Double = width / height
            If rate > (ThumbnailSize.Width / ThumbnailSize.Height) Then
                Dim bmp As New System.Drawing.Bitmap(ThumbnailSize.Width, CType(ThumbnailSize.Width / rate, Integer))
                bmp.SetResolution(img.HorizontalResolution, img.VerticalResolution)
                Dim graphics As System.Drawing.Graphics = System.Drawing.Graphics.FromImage(bmp)
                graphics.CompositingQuality = Drawing.Drawing2D.CompositingQuality.HighQuality
                graphics.InterpolationMode = Drawing.Drawing2D.InterpolationMode.HighQualityBicubic
                graphics.SmoothingMode = Drawing.Drawing2D.SmoothingMode.HighQuality
                graphics.PixelOffsetMode = Drawing.Drawing2D.PixelOffsetMode.HighQuality
                graphics.DrawImage(img, 0, 0, ThumbnailSize.Width, CType(ThumbnailSize.Width / rate, Integer))
                bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
            Else
                Dim bmp As New System.Drawing.Bitmap(CType(ThumbnailSize.Height * rate, Integer), ThumbnailSize.Height)
                bmp.SetResolution(img.HorizontalResolution, img.VerticalResolution)
                Dim graphics As System.Drawing.Graphics = System.Drawing.Graphics.FromImage(bmp)
                graphics.CompositingQuality = Drawing.Drawing2D.CompositingQuality.HighQuality
                graphics.InterpolationMode = Drawing.Drawing2D.InterpolationMode.HighQualityBicubic
                graphics.SmoothingMode = Drawing.Drawing2D.SmoothingMode.HighQuality
                graphics.PixelOffsetMode = Drawing.Drawing2D.PixelOffsetMode.HighQuality
                graphics.DrawImage(img, 0, 0, CType(ThumbnailSize.Height * rate, Integer), ThumbnailSize.Height)
                bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
            End If
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
        Return ms.ToArray()
    End Function
    Public Enum ThumbnailSize
        Width = 95
        Height = 120
    End Enum

    'ICC 2014/08/22 Show the "New" gif picture if create date within 3 months
    Protected Function ShowNew(ByRef dt As DateTime) As Boolean
        If DateDiff(DateInterval.Month, dt, Date.Now) <= 3 AndAlso dt > Date.Parse("08/25/2014") Then '2015/3/31 Fix logic
            Return True
        Else
            Return False
        End If
    End Function
    'ICC 2014/08/22 Change "linkUp" and "linDown" event to RowCommand event. Switch two row's SEQ_NO.
    Protected Sub gvGiftList_RowCommand(sender As Object, e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Try
            If String.IsNullOrEmpty(e.CommandName) Then Return 'ICC 2014/12/26 Fixed bug when click edit buttom.
            Dim rowIndex As Integer = Convert.ToInt32(e.CommandArgument)
            Dim oRowID As String = CType(gvGiftList.Rows(rowIndex).Cells(7).FindControl("hdRowId"), HiddenField).Value
            Dim oSeq As String = CType(gvGiftList.Rows(rowIndex).Cells(0).FindControl("hSeq"), HiddenField).Value
            If e.CommandName = "lnkUp" AndAlso rowIndex > 0 Then
                Dim nRowID As String = CType(gvGiftList.Rows(rowIndex - 1).Cells(7).FindControl("hdRowId"), HiddenField).Value
                Dim nSeq As String = CType(gvGiftList.Rows(rowIndex - 1).Cells(0).FindControl("hSeq"), HiddenField).Value
                'ICC 2015/1/12 Fixed sql command. Add LAST_UPD_BY to record someone's name when update data
                Dim strSQL As String = String.Format("update ADV_GIFT_LIST set SEQ_NO = {0}, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{4}' where ROW_ID='{1}' ;update ADV_GIFT_LIST set SEQ_NO = {2}, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{4}' where ROW_ID='{3}' ", nSeq, oRowID, oSeq, nRowID, User.Identity.Name)
                dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", strSQL)
            ElseIf e.CommandName = "lnkDown" AndAlso rowIndex <> gvGiftList.Rows.Count - 1 Then
                Dim nRowID As String = CType(gvGiftList.Rows(rowIndex + 1).Cells(7).FindControl("hdRowId"), HiddenField).Value
                Dim nSeq As String = CType(gvGiftList.Rows(rowIndex + 1).Cells(0).FindControl("hSeq"), HiddenField).Value
                'ICC 2015/1/12 Fixed sql command. Add LAST_UPD_BY to record someone's name when update data
                Dim strSQL As String = String.Format("update ADV_GIFT_LIST set SEQ_NO = {0}, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{4}' where ROW_ID='{1}' ;update ADV_GIFT_LIST set SEQ_NO = {2}, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{4}' where ROW_ID='{3}' ", nSeq, oRowID, oSeq, nRowID, User.Identity.Name)
                dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", strSQL)
            Else
                Util.AjaxJSAlert(upGiftList, "This item is already the first or last one")
                Return
            End If
            LoadGiftList(lblCategory.Text)
        Catch ex As Exception
            Util.InsertMyErrLog("GiftList.aspx lnkUp or lnkDown error: " + ex.ToString)
        End Try
    End Sub

    Sub LoadInActiveList()
        Dim giftDt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", _
                              " SELECT a.ROW_ID, a.PART_NO, a.MARCOM_DESC, a.NOTE, a.LAST_UPD_DATE, a.CREATED_DATE, a.LAST_UPD_BY, a.SEQ_NO, a.CATEGORY " + _
                              " FROM ADV_GIFT_LIST a " + _
                              " where a.IS_ACTIVE=0 " + _
                              " ORDER BY a.SEQ_NO, a.PART_NO ")
        If Not giftDt Is Nothing AndAlso giftDt.Rows.Count > 0 Then
            giftDt.Columns.Add("ATP", GetType(Decimal)) : giftDt.Columns.Add("USD_PRICE", GetType(Decimal)) : giftDt.Columns.Add("TWD_PRICE", GetType(Decimal)) : giftDt.Columns.Add("COST", GetType(Decimal)) 'ICC 2014/10/22 Add new column COST
            Dim exchRateUsd2Twd As Object = dbUtil.dbExecuteScalar("MY", "select top 1 UKURS from SAP_EXCHANGERATE where FCURR='USD' and TCURR='TWD' order by EXCH_DATE desc")
            If exchRateUsd2Twd Is Nothing Then exchRateUsd2Twd = "30"
            Dim ws As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
            Dim QueryInTable As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, QueryOutTable As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable ', errMsg As String = ""
            Dim pnList As New List(Of String)

            For Each gr As DataRow In giftDt.Rows
                Dim QInRec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
                With QInRec
                    .Kunnr = "ASPA001" : .Mandt = "168" : .Matnr = UCase(gr.Item("PART_NO")) : .Mglme = 1 : .Vkorg = "TW01" : .Prsdt = Now.ToString("yyyyMMdd")
                End With
                QueryInTable.Add(QInRec)
                pnList.Add(gr("PART_NO").ToString)
            Next

            Dim dicCost As Dictionary(Of String, Object) = Cache("InactiveGiftCostCache")
            If dicCost Is Nothing Then
                Dim msd As New MYSAPDAL
                Dim dtCost As New DataTable
                dicCost = New Dictionary(Of String, Object)
                Try
                    dtCost = msd.GetSAPPNCost(pnList.ToArray(), "TW01")
                    If Not dtCost Is Nothing AndAlso dtCost.Rows.Count > 0 Then
                        For Each dr As DataRow In dtCost.Rows
                            If Not dicCost.ContainsKey(dr("PART_NO").ToString) Then
                                dicCost.Add(dr("PART_NO").ToString, dr("COST"))
                            End If
                        Next
                        Cache.Add("GiftCostCache", dicCost, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
                    End If
                Catch ex As Exception
                    Throw New Exception("GetSAPPNCost error! " + ex.Message)
                End Try
            End If

            ws.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
            ws.Connection.Open()
            Try
                ws.Z_Sd_Eupriceinquery("1", QueryInTable, QueryOutTable)
                ws.Connection.Close()
            Catch ex As Exception
                ws.Connection.Close()
                Throw New Exception("call SAP RFC Z_SD_EUPRICEINQUERY error:" + ex.ToString())
            End Try
            Dim PriceList As New List(Of Z_SD_EUPRICEINQUERY.ZSSD_02_EU)
            For Each OutRec As Z_SD_EUPRICEINQUERY.ZSSD_02_EU In QueryOutTable
                PriceList.Add(OutRec)
            Next
            'ICC 2015/3/6 Change get atp source from GetAllGiftATP() to RFC.
            'Dim atpDt As DataTable = GetAllGiftATP()
            Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
            p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            p1.Connection.Open()
            For Each gr As DataRow In giftDt.Rows
                Dim currentGiftPN As String = UCase(gr.Item("part_no"))
                Dim p = From q In PriceList Where q.Matnr = currentGiftPN
                If p.Count > 0 Then
                    gr.Item("USD_PRICE") = p(0).Kzwi1
                    If p(0).Kzwi1 = 0 Then gr.Item("USD_PRICE") = p(0).Netwr
                    gr.Item("TWD_PRICE") = FormatNumber(p(0).Kzwi1 * CDbl(exchRateUsd2Twd), 0)
                Else
                    gr.Item("USD_PRICE") = -1
                End If

                gr.Item("ATP") = 0
                'Dim rrs() As DataRow = atpDt.Select("matnr='" + gr.Item("part_no") + "'")
                'If rrs.Length > 0 Then
                '    gr.Item("ATP") = rrs(0).Item("qty")
                'End If
                Dim Inventory As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
                rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd")
                retTb.Add(rOfretTb)
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", currentGiftPN, UCase("TWH1"), "", "", "", "", "PC", "", Inventory, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                Inventory = 0
                Dim atpRFC As DataTable = atpTb.ToADODataTable()
                If atpRFC.Rows.Count > 0 Then
                    Inventory = CType(atpRFC.Rows(0).Item("com_qty"), Int64)
                End If
                gr.Item("ATP") = Inventory
                If Not dicCost Is Nothing AndAlso dicCost.ContainsKey(gr.Item("PART_NO").ToString) Then
                    gr.Item("COST") = dicCost(gr.Item("PART_NO").ToString)
                End If
                If gr.Item("COST") Is DBNull.Value Then gr.Item("COST") = 0 'ICC 2015/5/5 Prevent DB NULL value
            Next
            p1.Connection.Close()
            gvInactiveList.DataSource = giftDt.DefaultView
            gvInactiveList.DataBind()
        Else
            Util.AjaxJSAlert(upInactiveList, "No inactive item")
        End If
    End Sub

    Protected Sub lnkInactive_Click(sender As Object, e As System.EventArgs)
        LoadInActiveList()
    End Sub

    Protected Sub gvInactiveList_RowCommand(sender As Object, e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Try
            If String.IsNullOrEmpty(e.CommandName) Then Return
            Dim rowIndex As Integer = Convert.ToInt32(e.CommandArgument)
            Dim oRowID As String = CType(gvInactiveList.Rows(rowIndex).Cells(7).FindControl("hdRowId"), HiddenField).Value
            If e.CommandName = "reAct" Then
                Dim strSQL As String = String.Format("update ADV_GIFT_LIST set IS_ACTIVE = 1, LAST_UPD_DATE = GETDATE(), LAST_UPD_BY = '{0}' where ROW_ID = '{1}' ", User.Identity.Name, oRowID)
                dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", strSQL)
                LoadInActiveList()
                LoadGiftList("Corporate Gift")
                upGiftList.Update()
                lbInactMsg.Text = "Updated"
            End If
        Catch ex As Exception
            lbInactMsg.Text = "Error"
            Util.InsertMyErrLog("GiftList.aspx reActive error: " + ex.ToString)
        End Try
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td align="left">
                            <h2>
                                <u>Advantech Gift Shop</u></h2>
                        </td>
                        <td align="right">
                            <i>Last Updated By:</i>&nbsp;<asp:Label runat="server" ID="lbLastUpdDate" Font-Italic="true" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td style="width: 75px">
                            Order Notice:
                        </td>
                        <td>
                            Fewer stock by each item, over 100-PCS production time should be
                            <div style="color: Red; display: inline">
                                [Order time +30 Days]</div>. Please follow the order process with OP’s help, the site information is for reference only.
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 75px">
                            Policy:
                        </td>
                        <td>
                            Advantech gifts should follow brand spirit with theme focused, encouraging RBUs
                            to buy corporate items which are unique designs to deliver positive and high quality
                            characteristic. We don’t do one-time usage gifts, toys or low quality objects to
                            avoid misunderstanding on Advantech brand.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <ajaxToolkit:TabContainer runat="server" ID="tabcon1">
                    <ajaxToolkit:TabPanel runat="server" ID="tabGiftList" HeaderText="Gift List">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upGiftList" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:PlaceHolder runat="server" ID="giftPH">
                                                    <asp:Label runat="server" ID="lblCategory" Visible="false"></asp:Label>
                                                </asp:PlaceHolder>
                                                <%--2015/3/2 Add a url for users to see clothing size --%>
                                                <div align="right" style="height:18px;">
                                                        <asp:HyperLink ID="SizeMap" runat="server" NavigateUrl="../../Images/ClothingSize.png" Target="_blank" Visible="false">Clothing Size</asp:HyperLink>
                                                </div>
                                                <asp:GridView runat="server" ID="gvGiftList" Width="100%" 
                                                    AutoGenerateColumns="false" onrowcommand="gvGiftList_RowCommand">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="Part No." SortExpression="PART_NO" ItemStyle-Width="150px"
                                                            ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("PART_NO")%>
                                                                <asp:Image runat="server" ID="NewImg" Visible='<%#ShowNew(Eval("CREATED_DATE"))%>' ImageUrl="~/Images/new2.gif" />
                                                                <asp:HiddenField ID="hSeq" runat="server" Value='<%#Eval("SEQ_NO")%>' />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Category" SortExpression="CATEGORY" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("CATEGORY")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Stock" SortExpression="ATP" ItemStyle-HorizontalAlign="Center"
                                                            ItemStyle-Width="80px">
                                                            <ItemTemplate>
                                                                <%#Eval("ATP")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Price" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px">
                                                            <ItemTemplate>
                                                                USD&nbsp;<%#Eval("USD_PRICE")%>&nbsp;
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Cost" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px">
                                                            <ItemTemplate>
                                                                <%--TWD&nbsp;<%#Convert.ToInt32(Eval("COST"))%>&nbsp;--%>
                                                                <%#Eval("COST") %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Advantech Gift" SortExpression="MARCOM_DESC" ItemStyle-Width="200px">
                                                            <ItemTemplate>
                                                                <%#Eval("MARCOM_DESC")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Image" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-Height="120px">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='<%#IO.Path.GetFileName(Request.PhysicalPath) + "?IMGID=" + Eval("ROW_ID")%>'>
                                                                    <img style="border-width:0px; width:auto; height:auto" 
                                                                        src='<%#IO.Path.GetFileName(Request.PhysicalPath) + "?THUMBID=" + Eval("ROW_ID")%>'
                                                                    alt='<%#Eval("PART_NO") %>' />
                                                                </a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Note" SortExpression="NOTE" ItemStyle-Width="300px">
                                                            <ItemTemplate>
                                                                &nbsp;<%#Eval("NOTE")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="" ItemStyle-Width="15px">
                                                            <ItemTemplate>
                                                                <asp:HiddenField runat="server" ID="hdRowId" Value='<%#Eval("ROW_ID")%>' />
                                                                <asp:UpdatePanel runat="server" ID="upRow1" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <asp:ImageButton runat="server" ID="btnUpd" ImageUrl="~/Images/16-em-pencil.png" OnClick="btnUpd_Click" />
                                                                    </ContentTemplate>
                                                                    <Triggers>
                                                                        <asp:PostBackTrigger ControlID="btnUpd" />
                                                                    </Triggers>
                                                                </asp:UpdatePanel>                                                                
                                                                <asp:LinkButton runat="server" ID="lnkDel" Text="X" Font-Bold="true" OnClick="lnkDel_Click" 
                                                                    OnClientClick="return confirm('Action cannot be reversed. Are you sure to delete?');" />&nbsp;
                                                                <asp:LinkButton runat="server" ID="lnkUp" Text="↑" CommandName="lnkUp" CommandArgument='<%# CType(Container, GridViewRow).RowIndex%>' />&nbsp;
                                                                <asp:LinkButton runat="server" ID="lnkDown" Text="↓" CommandName="lnkDown" CommandArgument='<%# CType(Container, GridViewRow).RowIndex%>' />&nbsp;
                                                                <asp:TextBox runat="server" ID="txtSeqNo" Visible="false" Text='<%#Eval("SEQ_NO") %>' 
                                                                    Width="13px" AutoPostBack="true" OnTextChanged="txtSeqNo_TextChanged" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tabAdminNew" HeaderText="Add New Gift">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <th align="left">
                                        Gift Part No.:
                                    </th>
                                    <td>
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender" TargetControlID="txtNewGiftPN" MinimumPrefixLength="1" ServiceMethod="AutoSuggestGiftPN" />
                                        <asp:TextBox runat="server" ID="txtNewGiftPN" Width="120px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Category:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtNewCategory" Width="120px" MaxLength="100"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Description:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtNewDesc" TextMode="MultiLine" Width="400px" Height="50px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Image:
                                    </th>
                                    <td>
                                        <asp:FileUpload runat="server" ID="FileNewPNImg" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Note:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtNewNote" TextMode="MultiLine" Width="400px" Height="50px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:RadioButtonList runat="server" ID="rblIsPnActive" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Active" Selected="True" />
                                            <asp:ListItem Text="Inactive" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Button runat="server" ID="btnUploadNewPN" Text="Add" OnClick="btnUploadNewPN_Click" />
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lbAddMsg" ForeColor="Tomato" Font-Bold="true" />
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tabAdminUpd" HeaderText="Update Gift">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <th align="left">
                                        Gift Part No.:
                                    </th>
                                    <td>                                        
                                        <asp:Label runat="server" ID="lbUpdPn" />
                                        <asp:HiddenField runat="server" ID="hdUpdRowId" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Category:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtUpdCategory" Width="120px" MaxLength="100"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Description:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtUpdDesc" TextMode="MultiLine" Width="400px" Height="50px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Image:
                                    </th>
                                    <td>
                                        <asp:FileUpload runat="server" ID="fupUpdImgFile" />
                                        (Specify a new file path will replace existing image file)
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Note:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtUpdNote" TextMode="MultiLine" Width="400px" Height="50px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:RadioButtonList runat="server" ID="rblUpdActive" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Active" />
                                            <asp:ListItem Text="Inactive" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Button runat="server" ID="btnUpdPN" Text="Update" OnClick="btnUpdPN_Click" />
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lbUpdMsg" ForeColor="Tomato" Font-Bold="true" />
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tabAdminInactiveList" HeaderText="Inactive Gift List">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upInactiveList" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:LinkButton runat="server" ID="lnkInactive" Text="Show Inactive List" onclick="lnkInactive_Click"></asp:LinkButton>&nbsp;
                                                <asp:Label runat="server" ID="lbInactMsg" ForeColor="Tomato" Font-Bold="true"></asp:Label>
                                                <br />
                                                <asp:GridView runat="server" ID="gvInactiveList" Width="100%" 
                                                    AutoGenerateColumns="false" onrowcommand="gvInactiveList_RowCommand">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="Part No." SortExpression="PART_NO" ItemStyle-Width="150px"
                                                            ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("PART_NO")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Category" SortExpression="CATEGORY" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("CATEGORY")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Stock" SortExpression="ATP" ItemStyle-HorizontalAlign="Center"
                                                            ItemStyle-Width="80px">
                                                            <ItemTemplate>
                                                                <%#Eval("ATP")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Price" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px">
                                                            <ItemTemplate>
                                                                USD&nbsp;<%#Eval("USD_PRICE")%>&nbsp;
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Cost" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px">
                                                            <ItemTemplate>
                                                                TWD&nbsp;<%#Convert.ToInt32(Eval("COST"))%>&nbsp;
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Advantech Gift" SortExpression="MARCOM_DESC" ItemStyle-Width="200px">
                                                            <ItemTemplate>
                                                                <%#Eval("MARCOM_DESC")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Image" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-Height="120px">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='<%#IO.Path.GetFileName(Request.PhysicalPath) + "?IMGID=" + Eval("ROW_ID")%>'>
                                                                    <img style="border-width:0px; width:auto; height:auto" 
                                                                        src='<%#IO.Path.GetFileName(Request.PhysicalPath) + "?THUMBID=" + Eval("ROW_ID")%>'
                                                                    alt='<%#Eval("PART_NO") %>' />
                                                                </a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Note" SortExpression="NOTE" ItemStyle-Width="300px">
                                                            <ItemTemplate>
                                                                &nbsp;<%#Eval("NOTE")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="" ItemStyle-Width="15px">
                                                            <ItemTemplate>
                                                                <asp:HiddenField runat="server" ID="hdRowId" Value='<%#Eval("ROW_ID")%>' />
                                                                <asp:LinkButton runat="server" ID="btnAct"  Text="Reactive" CommandName="reAct" CommandArgument='<%# CType(Container, GridViewRow).RowIndex%>' OnClientClick="return confirm('Action cannot be reversed. Are you sure to re-Active?');"  />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </td>
        </tr>
    </table>
</asp:Content>
