<%@ Page Title="Create New SAP Customer" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.ComponentModel" %>
<script runat="server">
    Public Sub JScallFunction(ByVal Page As Page, ByVal msg As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "  setTimeout('showshipto()',2000);" + vbCrLf + _
        "<" + _
        "/script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSfunction", jscript)
    End Sub
    Public Sub SetDropDownList(ByVal DDid As DropDownList, ByVal strvalue As String)
        strvalue = strvalue.Trim
        If DDid.Items.FindByValue(strvalue) IsNot Nothing Then
            DDid.SelectedValue = strvalue
        End If
    End Sub
    Protected Sub fup1_UploadedComplete(ByVal sender As Object, ByVal e As AjaxControlToolkit.AsyncFileUploadEventArgs)
        lbFupMsg.Text = ""
        ScriptManager.RegisterClientScriptBlock(Me, Me.GetType(), "reply", "document.getElementById('" & lbFupMsg.ClientID & "').innerHTML= 'Done!';", True)
        If fup1.HasFile AndAlso _
                               (fup1.FileName.EndsWith(".xls", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".doc", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".pptx", StringComparison.OrdinalIgnoreCase) _
                                  Or fup1.FileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) _
                                    Or fup1.FileName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase) _
                                      Or fup1.FileName.EndsWith(".gif", StringComparison.OrdinalIgnoreCase) _
                                        Or fup1.FileName.EndsWith(".png", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".ppt", StringComparison.OrdinalIgnoreCase)) Then
            Dim _stream As IO.Stream = fup1.FileContent
            Dim fileData(_stream.Length) As Byte
            _stream.Read(fileData, 0, _stream.Length)
            Dim userid As String = Session("user_id").ToString.Trim
         
            Dim _file As New ACNCustomerFile
            With _file
                .CustomerRowid = HidRowid.Value
                .Files = fileData
                .File_Name = fup1.FileName
                .File_Ext = fup1.FileName.Substring(fup1.FileName.LastIndexOf(".") + 1, fup1.FileName.Length - fup1.FileName.LastIndexOf(".") - 1)
                .File_CreateBy = userid
                .File_CreateTime = Now
            End With

            ACNUtil.Current.ACNContext.ACNCustomerFiles.InsertOnSubmit(_file)
            ACNUtil.Current.ACNContext.SubmitChanges()
           
        End If
 
    End Sub
    <Services.WebMethod()> _
  <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetFiles(ByVal customerrowid As String, ByVal str As String) As String
        Dim sb As New System.Text.StringBuilder
        Dim MyCR As List(Of ACNCustomerFile) = ACNUtil.Current.ACNContext.ACNCustomerFiles.Where(Function(P) P.CustomerRowid = customerrowid).OrderBy(Function(p) p.File_CreateTime).ToList
        With sb
            .AppendLine(String.Format("<table class='mtb2'><tr>"))
            ' .AppendLine(String.Format("<tr><th>File Name</th><th>Uploader</th></tr>"))
            For Each i As ACNCustomerFile In MyCR
                .AppendLine(String.Format("" + _
                                          " <td>" + _
                                          "    <a href='FileShow.ashx?id={0}' target='_blank'> <img height='50' src='FileShow.ashx?id={0}'  /></a>" + _
                                          " </td>" + _
                                          " " + _
                                          "", i.ID, i.File_Name, Util.GetNameVonEmail(i.File_CreateBy)))
            Next
            .AppendLine(String.Format("</tr></table>"))
        End With
        Return sb.ToString()
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            Dim titles As New List(Of ListItem) : titles.Add(New ListItem("Company")) : titles.Add(New ListItem("Mr.")) : titles.Add(New ListItem("Ms.")) : titles.Add(New ListItem("Mr. and Mrs."))
            sdt_Title.Items.Clear() : sdt_Title.DataSource = titles : sdt_Title.DataBind()
            spt_Title.Items.Clear() : spt_Title.DataSource = titles : spt_Title.DataBind()
            Dim RegionDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", " select DISTINCT T005U.BEZEI AS Region,  T005U.BLAND as RegionCode  from  saprdp.T005U  where land1 ='CN' AND MANDT=168 order by BEZEI")
            sdt_Region.DataSource = RegionDt : sdt_Region.DataBind()
            spt_Region.DataSource = RegionDt : spt_Region.DataBind()
            HidRowid.Value = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            ResquestBy.Text = Session("user_id") : ResquestBy.Enabled = False
            If Not String.IsNullOrEmpty(Request("rowid")) Then
                ApproveDIV.Visible = True
                Dim _item As ACNitem = ACNUtil.Current.ACNContext.ACNitems.Where(Function(p) p.RowID = Request("rowid")).FirstOrDefault()
                If _item IsNot Nothing Then
                    HidRowid.Value = _item.RowID
                    sdt_Name.Text = _item.sdt_Name
                    sdt_Sort1.Text = _item.sdt_Sort1
                    sdt_Sort2.Text = _item.sdt_Sort2
                    sdt_EripID.Text = _item.sdt_EripID
                    SetDropDownList(sdt_Title, _item.sdt_Title)
                    SetDropDownList(sdt_Region, _item.sdt_Region)
                    sdt_Telephone.Text = _item.sdt_Telephone
                    sdt_Street.Text = _item.sdt_Street
                    sdt_Housenumber.Text = _item.sdt_Housenumber
                    sdt_Name_co.Text = _item.sdt_Name_co
                    sdt_Tax1.Text = _item.sdt_Tax1
                    sdt_bankkey.Text = _item.sdt_bankkey
                    sdt_bankNo.Text = _item.sdt_bankNo
                    sdt_Post.Text = _item.sdt_Post
                    sdt_City.Text = _item.sdt_City
                    sdt_Country.Text = _item.sdt_Country
                    sdt_Region.Text = _item.sdt_Region
                    '  IsHaveShipto.Text = _item.IsHaveShipto
                    CBisHaveShipTo.Checked = IIf(_item.IsHaveShipto, True, False)
                    spt_Name.Text = _item.spt_Name
                    spt_Sort1.Text = _item.spt_Sort1
                    spt_Sort2.Text = _item.spt_Sort2
                    ' spt_EripID.Text = _item.spt_EripID
                    SetDropDownList(spt_Title, _item.spt_Title)
                    SetDropDownList(spt_Region, _item.spt_Region)
                    spt_Post.Text = _item.spt_Post
                    spt_City.Text = _item.spt_City
                    spt_Country.Text = _item.spt_Country
                    spt_Region.Text = _item.spt_Region
                    spt_Fax.Text = _item.spt_Fax
                    spt_Name_co.Text = _item.spt_Name_co
                    spt_Telephone.Text = _item.spt_Telephone
                    spt_MobilePhone.Text = _item.spt_MobilePhone
                    spt_Street.Text = _item.spt_Street
                    spt_Housenumber.Text = _item.spt_Housenumber
                    ResquestBy.Text = _item.ResquestBy
                    TBComment.Text = _item.Comment
                    BtRequest.Enabled = False
                    BtRequest.Width = 200
                    BtRequest.Text = String.Format(" {0}于 {1} 提交 ", Util.GetNameVonEmail(_item.ResquestBy), CDate(_item.RequestDate).ToString("yyyy-MM-dd"))
                    If CBisHaveShipTo.Checked Then
                        JScallFunction(Me.Page, String.Empty)
                    End If
                End If
            End If
        End If
        'Dim _item As New ACNitem
        'Dim properties = TypeDescriptor.GetProperties(_item)
        'For Each propertyDescriptror As PropertyDescriptor In properties
        '    Response.Write(String.Format(" {0}.Text = _item.{0}", propertyDescriptror.Name))
        '    Response.Write("<br>")
        '    ' Response.Write(String.Format(".{0}=TB{0}.Text.Trim <br/>", propertyDescriptror.Name, propertyDescriptror.GetValue(I_Kna1)))
        'Next
    End Sub
    '$(document).ready(function () {showshipto();});

    <Services.WebMethod()> _
<Web.Script.Services.ScriptMethod()> _
    Public Shared Function Getbankkey(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", " select  BNKA.BANKL as bankcode,BNKA.BANKA AS bankname  from  saprdp.BNKA WHERE BANKS='CN' AND MANDT=168  and rownum <=20 and BNKA.BANKL like '" + prefixText.Trim.ToUpper + "%'  ORDER BY BANKL ")
        If dt.Rows.Count > 0 Then
            'Dim str(dt.Rows.Count - 1) As String
            Dim items As New List(Of String)(dt.Rows.Count - 1)
            For i As Integer = 0 To dt.Rows.Count - 1
                '  str(i) = dt.Rows(i).Item(0)
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dt.Rows(i).Item(0) + vbTab + dt.Rows(i).Item(1), dt.Rows(i).Item(0)))
            Next
            ' Return str
            Return items.ToArray()
        End If
        Return Nothing
    End Function

    Protected Function insetDB(ByRef err As String) As Boolean
        Dim _item As New ACNitem
        Dim _curritem As ACNitem = ACNUtil.Current.ACNContext.ACNitems.Where(Function(p) p.RowID = HidRowid.Value).FirstOrDefault()
        If _curritem IsNot Nothing Then
            _item = _curritem
        End If
        _item.RowID = HidRowid.Value
        _item.sdt_Name = T(sdt_Name.Text)
        _item.sdt_Title = T(sdt_Title.Text)
        _item.sdt_Telephone = T(sdt_Telephone.Text)
        _item.sdt_Street = T(sdt_Street.Text)
        _item.sdt_Housenumber = T(sdt_Housenumber.Text)
        _item.sdt_Name_co = T(sdt_Name_co.Text)
        _item.sdt_Tax1 = T(sdt_Tax1.Text)
        _item.sdt_bankkey = T(sdt_bankkey.Text)
        _item.sdt_bankNo = T(sdt_bankNo.Text)
        _item.sdt_Post = T(sdt_Post.Text)
        _item.sdt_City = T(sdt_City.Text)
        _item.sdt_Country = T(sdt_Country.Text)
        _item.sdt_Region = T(sdt_Region.Text)
        _item.IsHaveShipto = IIf(CBisHaveShipTo.Checked, 1, 0)
        _item.spt_Name = T(spt_Name.Text)
        _item.spt_Title = T(spt_Title.Text)
        _item.spt_Post = T(spt_Post.Text)
        _item.spt_City = T(spt_City.Text)
        _item.spt_Country = T(spt_Country.Text)
        _item.spt_Region = T(spt_Region.Text)
        _item.spt_Fax = T(spt_Fax.Text)
        _item.spt_Name_co = T(spt_Name_co.Text)
        _item.spt_Telephone = T(spt_Telephone.Text)
        _item.spt_MobilePhone = T(spt_MobilePhone.Text)
        _item.spt_Street = T(spt_Street.Text)
        _item.spt_Housenumber = T(spt_Housenumber.Text)
        _item.ResquestBy = T(ResquestBy.Text)
        _item.RequestDate = Now
        _item.Status = ACNUtil.ACNStatus.New_Request
        _item.OPerator = ""
        _item.sdt_Sort1 = sdt_Sort1.Text
        _item.sdt_Sort2 = sdt_Sort2.Text
        _item.spt_Sort1 = spt_Sort1.Text
        _item.spt_Sort2 = spt_Sort2.Text
        ' _item.Comment = T(TBComment.Text)
        _item.LAST_UPD_BY = T(Session("user_id"))
        _item.LAST_UPD_DATE = Now
        If String.IsNullOrEmpty(T(_item.RowID)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Name)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Title)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Telephone)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Street)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Name_co)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Tax1)) OrElse
String.IsNullOrEmpty(T(_item.sdt_bankkey)) OrElse
String.IsNullOrEmpty(T(_item.sdt_bankNo)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Post)) OrElse
String.IsNullOrEmpty(T(_item.sdt_City)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Country)) OrElse
String.IsNullOrEmpty(T(_item.sdt_Region)) Then
            err = "* 请填写完整Sold-to资料，带星号为必填"
            Return False
            Exit Function
        End If
        If _item.IsHaveShipto = 1 Then
            If String.IsNullOrEmpty(T(_item.spt_Name)) OrElse
String.IsNullOrEmpty(T(_item.spt_Title)) OrElse
String.IsNullOrEmpty(T(_item.spt_Post)) OrElse
String.IsNullOrEmpty(T(_item.spt_City)) OrElse
String.IsNullOrEmpty(T(_item.spt_Country)) OrElse
String.IsNullOrEmpty(T(_item.spt_Region)) OrElse
String.IsNullOrEmpty(T(_item.spt_Fax)) OrElse
String.IsNullOrEmpty(T(_item.spt_Name_co)) OrElse
String.IsNullOrEmpty(T(_item.spt_Telephone)) OrElse
String.IsNullOrEmpty(T(_item.spt_Street)) Then
                err = "* 请填写完整Ship-to，带星号为必填"
                Return False
                Exit Function
            End If
        End If
        If _curritem Is Nothing Then
            ACNUtil.Current.ACNContext.ACNitems.InsertOnSubmit(_item)
        End If
        ACNUtil.Current.ACNContext.SubmitChanges()
        Return True
    End Function
    Protected Sub BtRequest_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim err As String = String.Empty
        If insetDB(err) = False Then
            LitError.Text = err
            Exit Sub
        End If
        ACNUtil.SendMail(HidRowid.Value)
        Dim AlertStr As String = "申请成功,OP审核通过后系统会邮件通知您."
        Util.AjaxJSConfirm(Me.UpdatePanel1, AlertStr + "\n还需要申请另外一家客户吗? ", "./CreateCustomer.aspx")
        BtRequest.Enabled = False
        ' LitError.Text = "提交成功"
    End Sub
    Public Function T(ByVal str As Object) As String
        Try
            Return str.ToString.Trim.ToUpper
        Catch ex As Exception
            Return ""
        End Try
    End Function
    Protected Sub BtApprove_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim err As String = String.Empty
        If insetDB(err) = False Then
            LitError.Text = err
            Exit Sub
        End If
        Dim Erpid As String = sdt_EripID.Text.Trim
        If CreateSAPCustomerDAL.IsERPIDExist(Erpid) Then
            lbERPIDMsg2.Text = Erpid + " already exists"
            up1.Update()
            Exit Sub
            'Else
            '    lbERPIDMsg2.Text = Erpid + " is new and ok to be created"
        End If
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", " select  BNKA.BANKL as bankcode,BNKA.BANKA AS bankname  from  saprdp.BNKA WHERE BANKS='CN' AND MANDT=168  and rownum =1 and BNKA.BANKL = '" + sdt_bankkey.Text.Trim.ToUpper + "'  ORDER BY BANKL ")
        If dt.Rows.Count = 0 Then
            lbERPIDMsg2.Text = "开户行不正确"
            up1.Update()
        End If
        Dim _item As ACNitem = ACNUtil.Current.ACNContext.ACNitems.Where(Function(p) p.RowID = HidRowid.Value).FirstOrDefault()
        If _item IsNot Nothing Then
            _item.sdt_EripID = Erpid
            _item.Comment = TBComment.Text
            _item.OPerateDate = Now
            _item.OPerator = Session("user_id")
            _item.Status = ACNUtil.ACNStatus.Approved
            CreateSoldTo(_item)
            If _item.IsHaveShipto() Then
                Dim tempShiptoErpid As String = String.Empty
                CreateSAPCustomerDAL.NewCompanyIdforACN(Erpid, tempShiptoErpid, "")
                If Not String.IsNullOrEmpty(tempShiptoErpid) Then
                    _item.spt_EripID = tempShiptoErpid
                    CreateShipTo(_item)
                    'Create sales/op/is code in knvp table, and ship-to if specified              
                    Dim knvpTable As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable
                    Dim salesRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
                    Dim opRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
                    Dim isRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
                    Dim ShipToRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
                    Dim BillingRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
                    Dim OrgId As String = "CN10"
                    With ShipToRow
                        .Defpa = "" : .Knref = ""
                        .Kunn2 = tempShiptoErpid : .Kunnr = Erpid
                        .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "WE"
                        .Parza = CreateSAPCustomerDAL.New_knvp_Parza(Erpid, "WE") : .Pernr = "00000000" : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
                    End With
                    knvpTable.Add(ShipToRow)

                    If knvpTable.Count > 0 Then
                        'System.Threading.Thread.Sleep(15000)
                        For i As Integer = 0 To 3
                            If CreateSAPCustomerDAL.checkSAPErp(Erpid) Then
                                Exit For
                            End If
                            If i = 3 Then
                                Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Find SAP Erp Failed:", "", True, "", "")
                                Exit For
                            End If
                            Threading.Thread.Sleep(1000)
                        Next
                        Dim p1 As New ZCUSTOMER_UPDATE_SALES_AREA.ZCUSTOMER_UPDATE_SALES_AREA
                        Dim SAPconnection2 As String = "SAP_PRD"
                        If Util.IsTesting() Then
                            SAPconnection2 = "SAPConnTest"
                        End If
                        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection2))
                        p1.Connection.Open()
                        p1.Zcustomer_Update_Sales_Area( _
                            New ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable, knvpTable, New ZCUSTOMER_UPDATE_SALES_AREA.KNVVTable, _
                            New ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable, New ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable)
                        p1.CommitWork() : p1.Connection.Close()
                    End If
                    'end 
                End If
         
            End If
            _item.LAST_UPD_BY = Session("user_id")
            _item.LAST_UPD_DATE = Now
            ACNUtil.Current.ACNContext.SubmitChanges()
            '  lbERPIDMsg2.Text = " 客户主档创建成功 。"
            up1.Update()
            'Util.AjaxJSAlert(Me.UpdatePanel1, "客户主档创建成功")
            Util.AjaxJSAlertRedirect(Me.UpdatePanel1, "客户主档创建成功", "CustomerList.aspx")
            ACNUtil.SendMail(HidRowid.Value)
        End If
    End Sub
    
    Public Function CreateSoldTo(ByVal _customer As ACNitem) As Boolean
        Dim ERPID As String = _customer.sdt_EripID, strTitle As String = _customer.sdt_Title
        Dim strCompanyName As String = T(_customer.sdt_Name)
        Dim strAddress As String = _customer.sdt_Street + vbTab + _customer.sdt_Housenumber
        Dim strcity As String = _customer.sdt_City
        Dim strPostCode As String = _customer.sdt_Post
        Dim strSort1 As String = _customer.sdt_Sort1 : Dim strSort2 As String = _customer.sdt_Sort2
        Dim strTelNumber1 As String = _customer.sdt_Telephone
        Dim strTelNumber2 As String = ""
        Dim strFaxNumber As String = "" ' _customer.sdt_Fax
        Dim Name_co As String = _customer.sdt_Name_co : Dim strEmail As String = ""
        Dim strWebSiteUrl As String = ""
        Dim strBankkey As String = _customer.sdt_bankkey
        Dim strKahao As String = _customer.sdt_bankNo
        Dim strCustomerClass As String = "03"
        Dim strCountryCode As String = "CN"
        Dim strCompanyType As String = "Z001", strTaxNumber1 As String = _customer.sdt_Tax1, strTaxNumber2 As String = ""
        Dim VATNumber As String = ""
        Dim strIndustryCode As String = "4000"
        Dim strRegionWestEast As String = "0000000001"
        Dim strCreditTerm As String = "PPD"
        Dim strOrgId As String = "CN10"
        Dim strPlant As String = Left(strOrgId, 2) + "H1"
        Dim strInco1 As String = "FOB" : Dim strInco2 As String = ""
        Dim strSalesGroup As String = "600"
        Dim strSalesOffice As String = "6100"
        Dim strRegion As String = _customer.sdt_Region
        Dim VerticalMarketDefinition As String = ""
        Dim CondGrp1 As String = "L0", CondGrp2 As String = "L0", CondGrp3 As String = "L0", CondGrp4 As String = "L0", CondGrp5 As String = "R4"
        Dim Attribute1 As String, Attribute2 As String, Attribute3 As String = "01", Attribute4 As String, Attribute5 As String, Attribute6 As String, Attribute8 As String, Attribute10 As String
        '  If VerticalMarketDefinition = "NONE" Then strVM = ""
        ' If strCreditTerm = "NONE" Then strCreditTerm = ""
        'strCreditTerm = "P98"
        Dim strCurrency As String = "CNY"
        Dim strCreateDate As String = Now.ToString("yyyyMMdd"), strCreator As String = "b2baeu"
        Dim p1 As New SAPCustomerRFC.SAPCustomerRFC
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAPConnTest"
        End If
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection))
        Dim I_Bapiaddr1 As New SAPCustomerRFC.BAPIADDR1, I_Bapiaddr2 As New SAPCustomerRFC.BAPIADDR2
        Dim I_Customer_Is_Consumer As String = "", I_Force_External_Number_Range As String = "", I_From_Customermaster As String = ""
        Dim I_Kna1 As New SAPCustomerRFC.KNA1, I_Knb1 As New SAPCustomerRFC.KNB1
        Dim I_Knb1_Reference As String = "", I_Knvv As New SAPCustomerRFC.KNVV, I_Maintain_Address_By_Kna1 As String = "X"
        Dim I_No_Bank_Master_Update As String = "", I_Raise_No_Bte As String = "", Pi_Add_On_Data As New SAPCustomerRFC.CUST_ADD_ON_DATA
        Dim Pi_Cam_Changed As String = "", Pi_Postflag As String = ""
        ''Return Arguments
        Dim E_Kunnr As String = "", E_Sd_Cust_1321_Done As String = "", O_Kna1 As New SAPCustomerRFC.KNA1
        Dim T_Upd_Txt As New SAPCustomerRFC.FKUNTXTTable, T_Xkn As New SAPCustomerRFC.FKNASTable
        Dim T_Xknb5 As New SAPCustomerRFC.FKNB5Table, T_Xknbk As New SAPCustomerRFC.FKNBKTable
        Dim T_Xknex As New SAPCustomerRFC.FKNEXTable, T_Xknva As New SAPCustomerRFC.FKNVATable
        Dim T_Xknvd As New SAPCustomerRFC.FKNVDTable, T_Xknvi As New SAPCustomerRFC.FKNVITable
        Dim T_Xknvk As New SAPCustomerRFC.FKNVKTable, T_Xknvl As New SAPCustomerRFC.FKNVLTable
        Dim T_Xknvp As New SAPCustomerRFC.FKNVPTable, T_Xknza As New SAPCustomerRFC.FKNZATable
        Dim T_Ykn As New SAPCustomerRFC.FKNASTable, T_Yknb5 As New SAPCustomerRFC.FKNB5Table
        Dim T_Yknbk As New SAPCustomerRFC.FKNBKTable, T_Yknex As New SAPCustomerRFC.FKNEXTable
        Dim T_Yknva As New SAPCustomerRFC.FKNVATable, T_Yknvd As New SAPCustomerRFC.FKNVDTable
        Dim T_Yknvi As New SAPCustomerRFC.FKNVITable, T_Yknvk As New SAPCustomerRFC.FKNVKTable
        Dim T_Yknvl As New SAPCustomerRFC.FKNVLTable, T_Yknvp As New SAPCustomerRFC.FKNVPTable
        Dim T_Yknza As New SAPCustomerRFC.FKNZATable
        'Assignment 
        Dim T_Xknvidr As New SAPCustomerRFC.FKNVI
        With T_Xknvidr

            .Tatyp = "MWST"
            .Aland = "NL"
            .Kunnr = T(ERPID)
            .Mandt = "168"
            .Taxkd = "8"
           
        End With
        With T_Xknvi
            ' '' '' '' '' '' '' '' '' '' ''.Add(T_Xknvidr)
        End With
        Dim T_Xknvidr2 As New SAPCustomerRFC.FKNVI
        With T_Xknvidr2
            .Tatyp = "MWST"
            .Aland = "TW"
            .Kunnr = T(ERPID)
            .Mandt = "168"
            .Taxkd = "0"

        End With
        With T_Xknvi
            '' '' '' '' '' '' '' '' '' '' ''.Add(T_Xknvidr2)
        End With
        Dim T_FKNBK As New SAPCustomerRFC.FKNBK
        With T_FKNBK
            .Mandt = "168"
            .Banks = "CN"
            .Kunnr = ERPID
            .Bankl = strBankkey
            ' .Bankn = "11001070400056001506"
            .Koinh = strKahao
        End With
        T_Xknbk.Add(T_FKNBK)
        With I_Bapiaddr1

            .Langu = "EN"
            .Comm_Type = "INT"
       
            
            'If GeneralData.LegalForm IsNot Nothing AndAlso GeneralData.LegalForm.ToString.Trim <> "" Then
            '    CompanyName += " " + GeneralData.LegalForm.ToString.Trim
            'End If
            
            If strCompanyName.Length <= 40 Then
                .Name = strCompanyName
            ElseIf 40 < strCompanyName.Length <= 80 Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40)
            ElseIf 80 < strCompanyName.Length <= 120 Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40, 80)
                .Name_3 = strCompanyName.Substring(80)
            ElseIf 120 < strCompanyName.Length Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40, 80)
                .Name_3 = strCompanyName.Substring(80, 120)
                .Name_4 = strCompanyName.Substring(120)
            End If
            '.Street = T(GeneralData.Address.Replace("|", " "))
            '.Str_Suppl3 = ""
            '.Location = ""
           
            'If strAddress.Contains("|") Then
            '    Dim p() As String = Split(strAddress, "|")
            '    .Street = T(p(0))
            '    '.Str_Suppl1 = T(p(1))
            '    'If p.Length >= 3 Then
            '    '    .Str_Suppl2 = T(p(2))
            '    'End If
            '    'If p.Length >= 4 Then
            '    '    .Str_Suppl3 = T(p(3))
            '    'End If
            '    'If p.Length >= 5 Then
            '    '    .Location = T(p(4))
            '    'End If
            '    .Str_Suppl3 = T(p(1))
            '    If p.Length >= 3 Then
            '        .Location = T(p(2))
            '    End If
            '    If p.Length >= 4 Then
            '        .Str_Suppl1 = T(p(3))
            '    End If
            '    If p.Length >= 5 Then
            '        .Str_Suppl2 = T(p(4))
            '    End If
            'Else
            '    .Street = T(strAddress)
            'End If
            .Street = _customer.sdt_Street
            .House_No = _customer.sdt_Housenumber
            .Postl_Cod1 = strPostCode
            .Addr_No = "" : .City = strcity : .C_O_Name = Name_co : .E_Mail = strEmail
            .Sort1 = strSort1
            .Sort2 = strSort2
            .Homepage = strWebSiteUrl
            .Fax_Number = strFaxNumber
            .Tel1_Numbr = strTelNumber1
            .Tel1_Ext = "" '分机号
  
            .Title = strTitle
            .Country = "CN"
            .Region = strRegion
            '.Sort1 = T("NL0002032")
            '.Sort2 = T(GeneralData.SearchTerm2.Replace(" ", ""))
        End With
        With I_Bapiaddr2
           
            '.Country = "CN"
            '.Region = strRegion
            '.Comm_Type = "INT"
            '.Sort1_P = T(GeneralData.SearchTerm1)
            '.Sort2_P = T(GeneralData.SearchTerm2)
            ' .Namcountry = GeneralData.CountryCode.ToString().Substring(5)
            ' .Postl_Cod1 = GeneralData.PostCode
            '.C_O_Name = T(GeneralData.ContactPersonName)
            '.Tel1_Numbr = "1233444"
            '.City = strcity : .C_O_Name = Name_co : .E_Mail = strEmail
            .Addr_No = ""
        End With
        I_Customer_Is_Consumer = "" : I_Force_External_Number_Range = "1" : I_From_Customermaster = "1"
        With I_Kna1
            .Mandt = "168"
            .Kunnr = T(ERPID)
            .Land1 = T(strCountryCode)
            .Name1 = T(strCompanyName)
            .Name2 = ""
            .Ort01 = T(strcity)
            .Pstlz = T(strPostCode)
            .Regio = " "
            .Sortl = strSort1 : .Stras = strAddress : .Telf1 = strTelNumber1 : .Telfx = strFaxNumber
            .Telf2 = "1122"
            .Telbx = ""
            .Teltx = "" : .Telx1 = ""
            .Xcpdk = " "
            '.Adrnr = "0000090780"
            .Mcod1 = T(strCompanyName)
            .Mcod2 = " "
            .Mcod3 = T(strAddress) : .Anred = strTitle
            .Aufsd = " " : .Bahne = " " : .Bahns = " " : .Begru = " "
            .Bbbnr = "0000000" : .Bbsnr = "00000" 'International location number  (part 1 & 2), not a variable value so far
            .Bubkz = "0"    'Check digit for the international location number           
            .Brsch = T(strIndustryCode)
            .Datlt = " " : .Erdat = strCreateDate : .Ernam = T(strCreator)
            .Exabl = " " : .Faksd = " " : .Fiskn = " " : .Knazk = " " : .Knrza = " " : .Konzs = " "
            .Ktokd = strCompanyType
            .Kukla = strCustomerClass
            .Lifnr = " " : .Lifsd = " " : .Locco = " " : .Loevm = " " : .Name3 = " " : .Name4 = " "
            .Niels = " " : .Ort02 = " " : .Pfach = " " : .Pstl2 = " " : .Counc = " " : .Cityc = " " : .Rpmkr = " "
            .Sperr = " " : .Spras = "E" : .Stcd1 = strTaxNumber1 : .Stcd2 = strTaxNumber2 : .Stkza = " " : .Stkzu = " "
           
            .Lzone = strRegionWestEast
            .Xzemp = " " : .Vbund = " "
            .Stceg = VATNumber

            .Dear1 = " " : .Dear2 = " " : .Dear3 = " " : .Dear4 = " " : .Dear5 = " "
            .Gform = " " : .Bran1 = " " : .Bran2 = " " : .Bran3 = " " : .Bran4 = " " : .Bran5 = " " : .Ekont = " "
            .Umsat = "0" : .Umjah = "0000" : .Uwaer = " " : .Jmzah = "000000" : .Jmjah = "0000"
            .Katr1 = T(Attribute1) : .Katr2 = T(Attribute2)
         
            .Katr3 = T(Attribute3)
            ' '' '' '' '' '' '' ''If GeneralData.SalesOffice.Trim = "3000" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "02"
            ' '' '' '' '' '' '' ''ElseIf GeneralData.SalesOffice.Trim = "3300" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "03"
            ' '' '' '' '' '' '' ''ElseIf GeneralData.SalesOffice.Trim = "3200" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "04"
            ' '' '' '' '' '' '' ''End If
            .Katr4 = T(Attribute4) : .Katr5 = T(Attribute5) : .Katr6 = T(Attribute6)
            'Dim strCustomerType As String = T(GeneralData.CustomerType.ToString.Substring(5))
            'If strCustomerType = "NONE" Then strCustomerType = ""
            .Katr7 = "" 'T(strCustomerType) 'Customer Type - ex: 315 - GA eAutomation
            .Katr8 = T(Attribute8)
            .Katr9 = "" 'T(strVM) 'Vertical Market
            .Katr10 = T(Attribute10)
            .Stkzn = " " : .Umsa1 = "0" : .Txjcd = " " : .Periv = " " : .Abrvw = " "
            .Inspbydebi = " " : .Inspatdebi = " " : .Ktocd = " " : .Pfort = " " : .Werks = " " : .Dtams = " "
            .Dtaws = " " : .Duefl = "X" : .Hzuor = "00" : .Sperz = " " : .Etikg = " " : .Civve = "X" : .Milve = " "
            .Kdkg1 = T(CondGrp1) : .Kdkg2 = T(CondGrp2) : .Kdkg3 = T(CondGrp3)
            .Kdkg4 = T(CondGrp4) : .Kdkg5 = T(CondGrp5)
            .Xknza = " "
            .Fityp = " " : .Stcdt = " " : .Stcd3 = " " : .Stcd4 = " " : .Xicms = " " : .Xxipi = " " : .Xsubt = " "
            .Cfopc = " " : .Txlw1 = " " : .Txlw2 = " " : .Ccc01 = " " : .Ccc02 = " " : .Ccc03 = " " : .Ccc04 = " "
            .Cassd = " "
            .Knurl = T(strWebSiteUrl)
            .J_1kfrepre = " " : .J_1kftbus = " " : .J_1kftind = " " : .Confs = " "
            .Updat = "00000000" : .Uptim = "000000" : .Nodel = " " : .Dear6 = " " : .Alc = " " : .Pmt_Office = " " : .Psofg = " "
            .Psois = " " : .Pson1 = " " : .Pson2 = " " : .Pson3 = " " : .Psovn = " " : .Psotl = " " : .Psohs = " " : .Psost = " "
            .Psoo1 = " " : .Psoo2 = " " : .Psoo3 = " " : .Psoo4 = " " : .Psoo5 = " "
        End With
        With I_Knb1
        
            .Mandt = "168" : .Kunnr = T(ERPID) : .Bukrs = strOrgId : .Pernr = "00000000" : .Erdat = strCreateDate
            .Ernam = T(strCreator) : .Sperr = " " : .Loevm = " "
            .Zuawa = "001" 'Sort Key
            Dim strAccountingClerk As String = "01"
            Dim ReconciliationAccount As String = "0000121001"
            If True Then 'GeneralData.HasCreditData
                .Busab = T(strAccountingClerk) 'Accounting clerk
                .Akont = T(ReconciliationAccount)
                .Vlibb = 0 'CreditData2.AmountInsured
                .Fdgrv = "A1" 'T(CreditData2.PlanningGroup.ToString().Substring(5))
                .Vrsnr = "" 'CreditData2.InsurePolicyNumber
            End If
          
            .Begru = " " : .Knrze = " " : .Knrzb = " " : .Zamim = " " : .Zamiv = " " : .Zamir = " " : .Zamib = " "
            .Zamio = " " : .Zwels = " " : .Xverr = " " : .Zahls = " " : .Zterm = strCreditTerm : .Wakon = " " : .Vzskz = " "
            .Zindt = "00000000" : .Zinrt = "00" : .Eikto = " " : .Zsabe = " " : .Kverm = " "
            .Vrbkz = " " : .Vrszl = "0" : .Vrspr = "0" : .Verdt = "00000000"
            .Perkz = " " : .Xdezv = " " : .Xausz = " " : .Webtr = "0" : .Remit = " " : .Datlz = "00000000" : .Xzver = "X"
            .Togru = " " : .Kultg = "0" : .Hbkid = " " : .Xpore = " " : .Blnkz = " " : .Altkn = " " : .Zgrup = " "
            .Urlid = " "
            .Mgrup = "01" 'Dunning group - currently only one option 01
            .Lockb = " " : .Uzawe = " " : .Ekvbd = " " : .Sregl = " " : .Xedip = " "
            .Frgrp = " " : .Vrsdg = " " : .Tlfxs = " " : .Intad = " " : .Xknzb = " " : .Guzte = " " : .Gricd = " "
            .Gridt = " " : .Wbrsl = " " : .Confs = " " : .Updat = "00000000" : .Uptim = "000000" : .Nodel = " "
            .Tlfns = " " : .Cession_Kz = " " : .Gmvkzd = " "
        End With
        I_Knb1_Reference = ""
        If True Then 'GeneralData.HasCreditData
            With I_Knvv
            
                .Mandt = "168" : .Kunnr = ERPID : .Vkorg = strOrgId : .Vtweg = "00" : .Spart = "00"
                .Ernam = strCreator : .Erdat = strCreateDate : .Begru = " " : .Loevm = " " : .Versg = " "
                .Aufsd = " " : .Kalks = "1"
                ' If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Kdgrp = T(CreditData2.CustomerGroup.ToString().Substring(5))
                ' If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Bzirk = T(CreditData2.SalesDistrict.ToString().Substring(5)) 'Sales District
                .Kdgrp = "01"
                .Bzirk = "010"
                .Konda = "00" : .Pltyp = "00"
                .Awahr = "100" 'Order probability
                .Inco1 = T(strInco1) : .Inco2 = strInco2
                .Lifsd = " " : .Autlf = " "
                .Antlf = "9" 'Maximum Number of Partial Deliveries Allowed Per Item
                .Kztlf = " " : .Kzazu = "X" : .Chspl = " "
                .Lprio = "02" 'Delivery Priority
                .Eikto = " " : .Vsbed = "01"
                .Faksd = " " : .Mrnkz = " " : .Perfk = " " : .Perrl = " " : .Kvakz = " " : .Kvawt = "0"
                .Waers = T(strCurrency) : .Klabc = " " : .Ktgrd = "02" : .Zterm = T(strCreditTerm) : .Vwerk = T(strPlant)
                .Vkgrp = T(strSalesGroup) : .Vkbur = T(strSalesOffice)
                .Vsort = " " : .Kvgr1 = " " : .Kvgr2 = " " : .Kvgr3 = "D0" : .Kvgr4 = " "
                .Kvgr5 = " " : .Bokre = " " : .Boidt = "00000000" : .Kurst = " " : .Prfre = " " : .Prat1 = " "
                .Prat2 = " " : .Prat3 = " " : .Prat4 = " " : .Prat5 = " " : .Prat6 = " " : .Prat7 = " " : .Prat8 = " "
                .Prat9 = " " : .Prata = " " : .Kabss = " " : .Kkber = " " : .Cassd = " " : .Rdoff = " " : .Agrel = " "
                .Megru = " " : .Uebto = "0" : .Untto = "0" : .Uebtk = " " : .Pvksm = " " : .Podkz = " " : .Podtg = "0"
                .Blind = " " : .Bev1_Emlgforts = " " : .Bev1_Emlgpfand = " "
            End With
        End If

        I_Maintain_Address_By_Kna1 = "" : I_No_Bank_Master_Update = "" : I_Raise_No_Bte = ""
        With Pi_Add_On_Data
            '  .Kunnr = "EFFRFA05"
        End With
        Pi_Cam_Changed = "" : Pi_Postflag = ""
        'Try
        p1.Zsd_Customer_Maintain_All(I_Bapiaddr1, I_Bapiaddr2, I_Customer_Is_Consumer, _
                                   I_Force_External_Number_Range, I_From_Customermaster, _
                                   I_Kna1, I_Knb1, I_Knb1_Reference, I_Knvv, I_Maintain_Address_By_Kna1, _
                                   I_No_Bank_Master_Update, I_Raise_No_Bte, _
                                   Pi_Add_On_Data, Pi_Cam_Changed, Pi_Postflag, _
                                   E_Kunnr, E_Sd_Cust_1321_Done, O_Kna1, T_Upd_Txt, _
                                   T_Xkn, T_Xknb5, T_Xknbk, T_Xknex, T_Xknva, T_Xknvd, T_Xknvi, _
                                   T_Xknvk, T_Xknvl, T_Xknvp, T_Xknza, T_Ykn, T_Yknb5, T_Yknbk, T_Yknex, T_Yknva, _
                                   T_Yknvd, T_Yknvi, T_Yknvk, T_Yknvl, T_Yknvp, T_Yknza)
        p1.CommitWork()
        p1.Connection.Close()


        'Catch ex As Exception

        'End Try
        'Dim ConnectToSAPPRD As Boolean = True
        '  If Util.IsTesting() Then ConnectToSAPPRD = False
        'MYSAPDAL.UpdateTranspZoneV2(GeneralData.CompanyId.Trim, "EU10", T(GeneralData.SearchTerm1), T(GeneralData.SearchTerm2), ConnectToSAPPRD)
        Return True
    End Function
    Public Function CreateShipTo(ByVal _customer As ACNitem) As Boolean
        Dim ERPID As String = _customer.spt_EripID, strTitle As String = _customer.spt_Title
        Dim strCompanyName As String = T(_customer.spt_Name)
        Dim strAddress As String = _customer.spt_Street + vbTab + _customer.spt_Housenumber
        Dim strcity As String = _customer.spt_City
        Dim strPostCode As String = _customer.spt_Post
        Dim strSort1 As String = _customer.spt_Sort1 : Dim strSort2 As String = _customer.spt_Sort2
        Dim strTelNumber1 As String = _customer.spt_Telephone
        Dim strTelNumber2 As String = ""
        Dim strFaxNumber As String = _customer.spt_Fax
        Dim Name_co As String = _customer.spt_Name_co : Dim strEmail As String = ""
        Dim strWebSiteUrl As String = ""
        Dim strBankkey As String = "" '_customer.sdt_bankkey
        Dim strKahao As String = "" ' _customer.sdt_bankNo
        Dim strCustomerClass As String = "03"
        Dim strCountryCode As String = "CN"
        Dim strCompanyType As String = "Z002", strTaxNumber1 As String = "", strTaxNumber2 As String = ""
        Dim VATNumber As String = ""
        Dim strIndustryCode As String = "4000"
        Dim strRegionWestEast As String = "0000000001"
        Dim strCreditTerm As String = "PPD"
        Dim strOrgId As String = "CN10"
        Dim strPlant As String = Left(strOrgId, 2) + "H1"
        Dim strInco1 As String = "FOB" : Dim strInco2 As String = ""
        Dim strSalesGroup As String = "600"
        Dim strSalesOffice As String = "6100"
        Dim strRegion As String = _customer.sdt_Region
        Dim VerticalMarketDefinition As String = ""
        Dim CondGrp1 As String = "L0", CondGrp2 As String = "L0", CondGrp3 As String = "L0", CondGrp4 As String = "L0", CondGrp5 As String = "R4"
        Dim Attribute1 As String, Attribute2 As String, Attribute3 As String = "01", Attribute4 As String, Attribute5 As String, Attribute6 As String, Attribute8 As String, Attribute10 As String
        '  If VerticalMarketDefinition = "NONE" Then strVM = ""
        ' If strCreditTerm = "NONE" Then strCreditTerm = ""
        'strCreditTerm = "P98"
        Dim strCurrency As String = "CNY"
        Dim strCreateDate As String = Now.ToString("yyyyMMdd"), strCreator As String = "b2baeu"
        Dim p1 As New SAPCustomerRFC.SAPCustomerRFC
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAPConnTest"
        End If
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection))
        Dim I_Bapiaddr1 As New SAPCustomerRFC.BAPIADDR1, I_Bapiaddr2 As New SAPCustomerRFC.BAPIADDR2
        Dim I_Customer_Is_Consumer As String = "", I_Force_External_Number_Range As String = "", I_From_Customermaster As String = ""
        Dim I_Kna1 As New SAPCustomerRFC.KNA1, I_Knb1 As New SAPCustomerRFC.KNB1
        Dim I_Knb1_Reference As String = "", I_Knvv As New SAPCustomerRFC.KNVV, I_Maintain_Address_By_Kna1 As String = "X"
        Dim I_No_Bank_Master_Update As String = "", I_Raise_No_Bte As String = "", Pi_Add_On_Data As New SAPCustomerRFC.CUST_ADD_ON_DATA
        Dim Pi_Cam_Changed As String = "", Pi_Postflag As String = ""
        ''Return Arguments
        Dim E_Kunnr As String = "", E_Sd_Cust_1321_Done As String = "", O_Kna1 As New SAPCustomerRFC.KNA1
        Dim T_Upd_Txt As New SAPCustomerRFC.FKUNTXTTable, T_Xkn As New SAPCustomerRFC.FKNASTable
        Dim T_Xknb5 As New SAPCustomerRFC.FKNB5Table, T_Xknbk As New SAPCustomerRFC.FKNBKTable
        Dim T_Xknex As New SAPCustomerRFC.FKNEXTable, T_Xknva As New SAPCustomerRFC.FKNVATable
        Dim T_Xknvd As New SAPCustomerRFC.FKNVDTable, T_Xknvi As New SAPCustomerRFC.FKNVITable
        Dim T_Xknvk As New SAPCustomerRFC.FKNVKTable, T_Xknvl As New SAPCustomerRFC.FKNVLTable
        Dim T_Xknvp As New SAPCustomerRFC.FKNVPTable, T_Xknza As New SAPCustomerRFC.FKNZATable
        Dim T_Ykn As New SAPCustomerRFC.FKNASTable, T_Yknb5 As New SAPCustomerRFC.FKNB5Table
        Dim T_Yknbk As New SAPCustomerRFC.FKNBKTable, T_Yknex As New SAPCustomerRFC.FKNEXTable
        Dim T_Yknva As New SAPCustomerRFC.FKNVATable, T_Yknvd As New SAPCustomerRFC.FKNVDTable
        Dim T_Yknvi As New SAPCustomerRFC.FKNVITable, T_Yknvk As New SAPCustomerRFC.FKNVKTable
        Dim T_Yknvl As New SAPCustomerRFC.FKNVLTable, T_Yknvp As New SAPCustomerRFC.FKNVPTable
        Dim T_Yknza As New SAPCustomerRFC.FKNZATable
        'Assignment 
        Dim T_Xknvidr As New SAPCustomerRFC.FKNVI
        With T_Xknvidr

            .Tatyp = "MWST"
            .Aland = "NL"
            .Kunnr = T(ERPID)
            .Mandt = "168"
            .Taxkd = "8"
           
        End With
        With T_Xknvi
            ' '' '' '' '' '' '' '' '' '' ''.Add(T_Xknvidr)
        End With
        Dim T_Xknvidr2 As New SAPCustomerRFC.FKNVI
        With T_Xknvidr2
            .Tatyp = "MWST"
            .Aland = "TW"
            .Kunnr = T(ERPID)
            .Mandt = "168"
            .Taxkd = "0"

        End With
        With T_Xknvi
            '' '' '' '' '' '' '' '' '' '' ''.Add(T_Xknvidr2)
        End With
        Dim T_FKNBK As New SAPCustomerRFC.FKNBK
        With T_FKNBK
            .Mandt = "168"
            .Banks = "CN"
            .Kunnr = ERPID
            .Bankl = strBankkey
            ' .Bankn = "11001070400056001506"
            .Koinh = strKahao
        End With
        'T_Xknbk.Add(T_FKNBK)
        With I_Bapiaddr1

            .Langu = "EN"
            .Comm_Type = "INT"
       
            
            'If GeneralData.LegalForm IsNot Nothing AndAlso GeneralData.LegalForm.ToString.Trim <> "" Then
            '    CompanyName += " " + GeneralData.LegalForm.ToString.Trim
            'End If
            
            If strCompanyName.Length <= 40 Then
                .Name = strCompanyName
            ElseIf 40 < strCompanyName.Length <= 80 Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40)
            ElseIf 80 < strCompanyName.Length <= 120 Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40, 80)
                .Name_3 = strCompanyName.Substring(80)
            ElseIf 120 < strCompanyName.Length Then
                .Name = strCompanyName.Substring(0, 40)
                .Name_2 = strCompanyName.Substring(40, 80)
                .Name_3 = strCompanyName.Substring(80, 120)
                .Name_4 = strCompanyName.Substring(120)
            End If
            '.Street = T(GeneralData.Address.Replace("|", " "))
            '.Str_Suppl3 = ""
            '.Location = ""
            'If strAddress.Contains("|") Then
            '    Dim p() As String = Split(strAddress, "|")
            '    .Street = T(p(0))
            '    '.Str_Suppl1 = T(p(1))
            '    'If p.Length >= 3 Then
            '    '    .Str_Suppl2 = T(p(2))
            '    'End If
            '    'If p.Length >= 4 Then
            '    '    .Str_Suppl3 = T(p(3))
            '    'End If
            '    'If p.Length >= 5 Then
            '    '    .Location = T(p(4))
            '    'End If
            '    .Str_Suppl3 = T(p(1))
            '    If p.Length >= 3 Then
            '        .Location = T(p(2))
            '    End If
            '    If p.Length >= 4 Then
            '        .Str_Suppl1 = T(p(3))
            '    End If
            '    If p.Length >= 5 Then
            '        .Str_Suppl2 = T(p(4))
            '    End If
            'Else
            '    .Street = T(strAddress)
            'End If
            .Street = _customer.spt_Street
            .House_No = _customer.spt_Housenumber
            .Postl_Cod1 = strPostCode
            .Addr_No = "" : .City = strcity : .C_O_Name = Name_co : .E_Mail = strEmail
            .Sort1 = strSort1
            .Sort2 = strSort2
            .Homepage = strWebSiteUrl
            .Fax_Number = strFaxNumber
            .Tel1_Numbr = strTelNumber1
            .Tel1_Ext = "" '分机号
  
            .Title = strTitle
            .Country = "CN"
            .Region = strRegion
            '.Sort1 = T("NL0002032")
            '.Sort2 = T(GeneralData.SearchTerm2.Replace(" ", ""))
        End With
        With I_Bapiaddr2
           
            '.Country = "CN"
            '.Region = strRegion
            '.Comm_Type = "INT"
            '.Sort1_P = T(GeneralData.SearchTerm1)
            '.Sort2_P = T(GeneralData.SearchTerm2)
            ' .Namcountry = GeneralData.CountryCode.ToString().Substring(5)
            ' .Postl_Cod1 = GeneralData.PostCode
            '.C_O_Name = T(GeneralData.ContactPersonName)
            '.Tel1_Numbr = "1233444"
            '.City = strcity : .C_O_Name = Name_co : .E_Mail = strEmail
            .Addr_No = ""
        End With
        I_Customer_Is_Consumer = "" : I_Force_External_Number_Range = "1" : I_From_Customermaster = "1"
        With I_Kna1
            .Mandt = "168"
            .Kunnr = T(ERPID)
            .Land1 = T(strCountryCode)
            .Name1 = T(strCompanyName)
            .Name2 = ""
            .Ort01 = T(strcity)
            .Pstlz = T(strPostCode)
            .Regio = " "
            .Sortl = strSort1 : .Stras = strAddress : .Telf1 = strTelNumber1 : .Telfx = strFaxNumber
            .Telf2 = "1122"
            .Telbx = ""
            .Teltx = "" : .Telx1 = ""
            .Xcpdk = " "
            '.Adrnr = "0000090780"
            .Mcod1 = T(strCompanyName)
            .Mcod2 = " "
            .Mcod3 = T(strAddress) : .Anred = strTitle
            .Aufsd = " " : .Bahne = " " : .Bahns = " " : .Begru = " "
            .Bbbnr = "0000000" : .Bbsnr = "00000" 'International location number  (part 1 & 2), not a variable value so far
            .Bubkz = "0"    'Check digit for the international location number           
            .Brsch = T(strIndustryCode)
            .Datlt = " " : .Erdat = strCreateDate : .Ernam = T(strCreator)
            .Exabl = " " : .Faksd = " " : .Fiskn = " " : .Knazk = " " : .Knrza = " " : .Konzs = " "
            .Ktokd = strCompanyType
            .Kukla = strCustomerClass
            .Lifnr = " " : .Lifsd = " " : .Locco = " " : .Loevm = " " : .Name3 = " " : .Name4 = " "
            .Niels = " " : .Ort02 = " " : .Pfach = " " : .Pstl2 = " " : .Counc = " " : .Cityc = " " : .Rpmkr = " "
            .Sperr = " " : .Spras = "E" : .Stcd1 = strTaxNumber1 : .Stcd2 = strTaxNumber2 : .Stkza = " " : .Stkzu = " "
           
            .Lzone = strRegionWestEast
            .Xzemp = " " : .Vbund = " "
            .Stceg = VATNumber

            .Dear1 = " " : .Dear2 = " " : .Dear3 = " " : .Dear4 = " " : .Dear5 = " "
            .Gform = " " : .Bran1 = " " : .Bran2 = " " : .Bran3 = " " : .Bran4 = " " : .Bran5 = " " : .Ekont = " "
            .Umsat = "0" : .Umjah = "0000" : .Uwaer = " " : .Jmzah = "000000" : .Jmjah = "0000"
            .Katr1 = T(Attribute1) : .Katr2 = T(Attribute2)
         
            .Katr3 = T(Attribute3)
            ' '' '' '' '' '' '' ''If GeneralData.SalesOffice.Trim = "3000" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "02"
            ' '' '' '' '' '' '' ''ElseIf GeneralData.SalesOffice.Trim = "3300" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "03"
            ' '' '' '' '' '' '' ''ElseIf GeneralData.SalesOffice.Trim = "3200" Then
            ' '' '' '' '' '' '' ''    .Katr3 = "04"
            ' '' '' '' '' '' '' ''End If
            .Katr4 = T(Attribute4) : .Katr5 = T(Attribute5) : .Katr6 = T(Attribute6)
            'Dim strCustomerType As String = T(GeneralData.CustomerType.ToString.Substring(5))
            'If strCustomerType = "NONE" Then strCustomerType = ""
            .Katr7 = "" 'T(strCustomerType) 'Customer Type - ex: 315 - GA eAutomation
            .Katr8 = T(Attribute8)
            .Katr9 = "" 'T(strVM) 'Vertical Market
            .Katr10 = T(Attribute10)
            .Stkzn = " " : .Umsa1 = "0" : .Txjcd = " " : .Periv = " " : .Abrvw = " "
            .Inspbydebi = " " : .Inspatdebi = " " : .Ktocd = " " : .Pfort = " " : .Werks = " " : .Dtams = " "
            .Dtaws = " " : .Duefl = "X" : .Hzuor = "00" : .Sperz = " " : .Etikg = " " : .Civve = "X" : .Milve = " "
            .Kdkg1 = T(CondGrp1) : .Kdkg2 = T(CondGrp2) : .Kdkg3 = T(CondGrp3)
            .Kdkg4 = T(CondGrp4) : .Kdkg5 = T(CondGrp5)
            .Xknza = " "
            .Fityp = " " : .Stcdt = " " : .Stcd3 = " " : .Stcd4 = " " : .Xicms = " " : .Xxipi = " " : .Xsubt = " "
            .Cfopc = " " : .Txlw1 = " " : .Txlw2 = " " : .Ccc01 = " " : .Ccc02 = " " : .Ccc03 = " " : .Ccc04 = " "
            .Cassd = " "
            .Knurl = T(strWebSiteUrl)
            .J_1kfrepre = " " : .J_1kftbus = " " : .J_1kftind = " " : .Confs = " "
            .Updat = "00000000" : .Uptim = "000000" : .Nodel = " " : .Dear6 = " " : .Alc = " " : .Pmt_Office = " " : .Psofg = " "
            .Psois = " " : .Pson1 = " " : .Pson2 = " " : .Pson3 = " " : .Psovn = " " : .Psotl = " " : .Psohs = " " : .Psost = " "
            .Psoo1 = " " : .Psoo2 = " " : .Psoo3 = " " : .Psoo4 = " " : .Psoo5 = " "
        End With
        With I_Knb1
        
            .Mandt = "168" : .Kunnr = T(ERPID) : .Bukrs = strOrgId : .Pernr = "00000000" : .Erdat = strCreateDate
            .Ernam = T(strCreator) : .Sperr = " " : .Loevm = " "
            .Zuawa = "001" 'Sort Key
            Dim strAccountingClerk As String = "01"
            Dim ReconciliationAccount As String = "0000121001"
            If True Then 'GeneralData.HasCreditData
                .Busab = T(strAccountingClerk) 'Accounting clerk
                .Akont = T(ReconciliationAccount)
                .Vlibb = 0 'CreditData2.AmountInsured
                .Fdgrv = "A1" 'T(CreditData2.PlanningGroup.ToString().Substring(5))
                .Vrsnr = "" 'CreditData2.InsurePolicyNumber
            End If
          
            .Begru = " " : .Knrze = " " : .Knrzb = " " : .Zamim = " " : .Zamiv = " " : .Zamir = " " : .Zamib = " "
            .Zamio = " " : .Zwels = " " : .Xverr = " " : .Zahls = " " : .Zterm = strCreditTerm : .Wakon = " " : .Vzskz = " "
            .Zindt = "00000000" : .Zinrt = "00" : .Eikto = " " : .Zsabe = " " : .Kverm = " "
            .Vrbkz = " " : .Vrszl = "0" : .Vrspr = "0" : .Verdt = "00000000"
            .Perkz = " " : .Xdezv = " " : .Xausz = " " : .Webtr = "0" : .Remit = " " : .Datlz = "00000000" : .Xzver = "X"
            .Togru = " " : .Kultg = "0" : .Hbkid = " " : .Xpore = " " : .Blnkz = " " : .Altkn = " " : .Zgrup = " "
            .Urlid = " "
            .Mgrup = "01" 'Dunning group - currently only one option 01
            .Lockb = " " : .Uzawe = " " : .Ekvbd = " " : .Sregl = " " : .Xedip = " "
            .Frgrp = " " : .Vrsdg = " " : .Tlfxs = " " : .Intad = " " : .Xknzb = " " : .Guzte = " " : .Gricd = " "
            .Gridt = " " : .Wbrsl = " " : .Confs = " " : .Updat = "00000000" : .Uptim = "000000" : .Nodel = " "
            .Tlfns = " " : .Cession_Kz = " " : .Gmvkzd = " "
        End With
        I_Knb1_Reference = ""
        If True Then 'GeneralData.HasCreditData
            With I_Knvv
            
                .Mandt = "168" : .Kunnr = ERPID : .Vkorg = strOrgId : .Vtweg = "00" : .Spart = "00"
                .Ernam = strCreator : .Erdat = strCreateDate : .Begru = " " : .Loevm = " " : .Versg = " "
                .Aufsd = " " : .Kalks = "1"
                ' If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Kdgrp = T(CreditData2.CustomerGroup.ToString().Substring(5))
                ' If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Bzirk = T(CreditData2.SalesDistrict.ToString().Substring(5)) 'Sales District
                .Kdgrp = "01"
                .Bzirk = "010"
                .Konda = "00" : .Pltyp = "00"
                .Awahr = "100" 'Order probability
                .Inco1 = T(strInco1) : .Inco2 = strInco2
                .Lifsd = " " : .Autlf = " "
                .Antlf = "9" 'Maximum Number of Partial Deliveries Allowed Per Item
                .Kztlf = " " : .Kzazu = "X" : .Chspl = " "
                .Lprio = "02" 'Delivery Priority
                .Eikto = " " : .Vsbed = "01"
                .Faksd = " " : .Mrnkz = " " : .Perfk = " " : .Perrl = " " : .Kvakz = " " : .Kvawt = "0"
                .Waers = T(strCurrency) : .Klabc = " " : .Ktgrd = "02" : .Zterm = T(strCreditTerm) : .Vwerk = T(strPlant)
                .Vkgrp = T(strSalesGroup) : .Vkbur = T(strSalesOffice)
                .Vsort = " " : .Kvgr1 = " " : .Kvgr2 = " " : .Kvgr3 = "D0" : .Kvgr4 = " "
                .Kvgr5 = " " : .Bokre = " " : .Boidt = "00000000" : .Kurst = " " : .Prfre = " " : .Prat1 = " "
                .Prat2 = " " : .Prat3 = " " : .Prat4 = " " : .Prat5 = " " : .Prat6 = " " : .Prat7 = " " : .Prat8 = " "
                .Prat9 = " " : .Prata = " " : .Kabss = " " : .Kkber = " " : .Cassd = " " : .Rdoff = " " : .Agrel = " "
                .Megru = " " : .Uebto = "0" : .Untto = "0" : .Uebtk = " " : .Pvksm = " " : .Podkz = " " : .Podtg = "0"
                .Blind = " " : .Bev1_Emlgforts = " " : .Bev1_Emlgpfand = " "
            End With
        End If

        I_Maintain_Address_By_Kna1 = "" : I_No_Bank_Master_Update = "" : I_Raise_No_Bte = ""
        With Pi_Add_On_Data
            '  .Kunnr = "EFFRFA05"
        End With
        Pi_Cam_Changed = "" : Pi_Postflag = ""
        'Try
        p1.Zsd_Customer_Maintain_All(I_Bapiaddr1, I_Bapiaddr2, I_Customer_Is_Consumer, _
                                   I_Force_External_Number_Range, I_From_Customermaster, _
                                   I_Kna1, I_Knb1, I_Knb1_Reference, I_Knvv, I_Maintain_Address_By_Kna1, _
                                   I_No_Bank_Master_Update, I_Raise_No_Bte, _
                                   Pi_Add_On_Data, Pi_Cam_Changed, Pi_Postflag, _
                                   E_Kunnr, E_Sd_Cust_1321_Done, O_Kna1, T_Upd_Txt, _
                                   T_Xkn, T_Xknb5, T_Xknbk, T_Xknex, T_Xknva, T_Xknvd, T_Xknvi, _
                                   T_Xknvk, T_Xknvl, T_Xknvp, T_Xknza, T_Ykn, T_Yknb5, T_Yknbk, T_Yknex, T_Yknva, _
                                   T_Yknvd, T_Yknvi, T_Yknvk, T_Yknvl, T_Yknvp, T_Yknza)
        p1.CommitWork()
        p1.Connection.Close()


        'Catch ex As Exception

        'End Try
        'Dim ConnectToSAPPRD As Boolean = True
        '  If Util.IsTesting() Then ConnectToSAPPRD = False
        'MYSAPDAL.UpdateTranspZoneV2(GeneralData.CompanyId.Trim, "EU10", T(GeneralData.SearchTerm1), T(GeneralData.SearchTerm2), ConnectToSAPPRD)
        Return True
    End Function
    Protected Sub BtReject_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim _item As ACNitem = ACNUtil.Current.ACNContext.ACNitems.Where(Function(p) p.RowID = HidRowid.Value).FirstOrDefault()
        If _item IsNot Nothing Then
            If String.IsNullOrEmpty(TBComment.Text.Trim) Then
                lbERPIDMsg2.Text = " 请输入拒绝理由"
                up1.Update()
                Exit Sub
            End If
            _item.Comment = T(TBComment.Text)
            _item.Status = ACNUtil.ACNStatus.Rejected
            _item.OPerator = Session("user_id")
            _item.OPerateDate = Now
            ACNUtil.Current.ACNContext.SubmitChanges()
            '  lbERPIDMsg2.Text = " 已拒绝"
            Util.AjaxJSAlert(Me.UpdatePanel1, "拒绝成功")
            up1.Update()
            ACNUtil.SendMail(HidRowid.Value)
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script src="../../Includes/jquery-1.9.1.min.js" type="text/javascript"></script>
    <asp:HiddenField ID="HidRowid" runat="server" />
    <asp:Panel runat="server" ID="ApproveDIV" Visible="false">
        <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
            <ContentTemplate>
                <table width="600">
                    <tr runat="server" id="TBCompanyId2">
                        <td width="120">
                            <b>CustomerID:</b>
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="sdt_EripID" Width="80px" AutoPostBack="true" />
                            <asp:Label runat="server" ID="lbERPIDMsg2" ForeColor="red" Font-Bold="true" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b>Comment:</b>
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="TBComment" TextMode="MultiLine" Width="500"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" colspan="2">
                            <asp:Button runat="server" Text="Approved" ID="BtApprove" OnClick="BtApprove_Click" />&nbsp;
                            &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;
                            <asp:Button runat="server" Text="Rejected" ID="BtReject" OnClick="BtReject_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Label runat="server" ID="lbDoneMsg2" Font-Bold="true" ForeColor="Tomato" />
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>
        <br />
    </asp:Panel>
    <table border="0" cellspacing="0" cellpadding="0" class="Mtb">
        <tr>
            <td class="tb1 tbm">
                <div class="logistics-title">
                    <strong>Sold-to</strong><span class="shadow"></span>
                </div>
            </td>
            <td class="tb2">
                <span class="bt">开发票必填信息</span>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Title</strong>
            </td>
            <td class="tb2">
                <asp:DropDownList ID="sdt_Title" runat="server">
                </asp:DropDownList>
                <i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Name</strong><strong>客户名称</strong><strong>&nbsp; </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Name" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>搜索码1<strong>&nbsp; </strong></td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Sort1" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>搜索码2<strong>&nbsp; </strong></td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Sort2" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Telephone</strong><strong>开票电话</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Telephone" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>C/o</strong><strong>发票Name_co联系人</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Name_co" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Tax Number</strong><strong>Tax1</strong><strong>税号</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Tax1" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>开户行（填写bank key） </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_bankkey" runat="server"></asp:TextBox><i>*</i>
                <ajaxToolkit:AutoCompleteExtender runat="server" ID="acebankkey" CompletionInterval="1000"
                    OnClientItemSelected="OnACEItemSelected" ServiceMethod="Getbankkey" TargetControlID="sdt_bankkey"
                    MinimumPrefixLength="2" />
                <script language="javascript">
                    function OnACEItemSelected(source, eventArgs) {
                        document.getElementById("<%=sdt_bankkey.ClientID%>").value = eventArgs.get_value();
                        // alert("Value值："+eventArgs.get_value()+"\nText值："+eventArgs.get_text());   
                    }
                </script>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>帐号 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_bankNo" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>申请业务 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="ResquestBy" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr style="display: none;">
            <td class="tb1">
                <strong>Country</strong><strong>国家 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Country" runat="server">CN</asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Region</strong><strong>省 </strong>
            </td>
            <td class="tb2">
                <asp:DropDownList ID="sdt_Region" runat="server" DataTextField="Region" DataValueField="Regioncode">
                </asp:DropDownList>
                <i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>City</strong><strong>城市 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_City" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Post</strong><strong>邮编 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Post" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>Street</strong><strong>开票地址</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Street" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr style="display: none;">
            <td class="tb1">
                <strong>House Number</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="sdt_Housenumber" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td class="tb1">
                <strong>相关证件</strong>
            </td>
            <td class="tb2">
                <ajaxToolkit:AsyncFileUpload runat="server" ID="fup1" OnClientUploadError="uploadError"
                    OnClientUploadStarted="StartUpload" OnClientUploadComplete="UploadComplete" CompleteBackColor="Lime"
                    UploaderStyle="Traditional" ErrorBackColor="Red" UploadingBackColor="#66CCFF"
                    OnUploadedComplete="fup1_UploadedComplete" CssClass="mytb2" />
                <asp:Label runat="server" ID="lbFupMsg"></asp:Label>
                <div id="FupMsg">
                </div>
                <script type="text/javascript">

                    window.onload = function () {
                        var rowid = $("#<%=HidRowid.ClientID %>").val();
                        if (rowid != "") {
                            ShowFilesDiv(rowid);
                        }
                    }
                    function uploadError(sender, args) {
                        console.log(args);
                        $("#<%=lbFupMsg.ClientID %>").html('Error during upload');
                    }

                    function StartUpload(sender, args) {
                        $("#<%=lbFupMsg.ClientID %>").html('<img src="../../Images/loading2.gif">');
                    }

                    function UploadComplete(sender, args) {
                        var rowid = $("#<%=HidRowid.ClientID %>").val();
                        ShowFilesDiv(rowid);
                    }

                    function ShowFilesDiv(rowid) {
                        PageMethods.GetFiles(rowid, "",
                function (pagedResult, eleid, methodName) {
                    $("#<%=lbFupMsg.ClientID %>").html('');
                    $('#FupMsg').html(pagedResult);
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    $('#FupMsg').html("");
                });
            }
                </script>
            </td>
        </tr>
        <tr>
            <td class="tb1" style="color: tomato;">
                <strong>是否创建新的Ship-To</strong>
            </td>
            <td class="tb2">
                <asp:CheckBox ID="CBisHaveShipTo" runat="server" CssClass="wh20" />
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1 tbm">
                <div class="logistics-title">
                    <strong>Ship-to</strong><span class="shadow"></span>
                </div>
            </td>
            <td class="tb2">
                <span class="bt">如果收货地址与发票地址不一致，请填写Ship-To </span>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Title</strong>
            </td>
            <td class="tb2">
                <asp:DropDownList ID="spt_Title" runat="server">
                </asp:DropDownList>
                <i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Name</strong><strong>客户名称</strong><strong>&nbsp; </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Name" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>搜索码1<strong>&nbsp; </strong></td>
            <td class="tb2">
                <asp:TextBox ID="spt_Sort1" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>搜索码2<strong>&nbsp; </strong></td>
            <td class="tb2">
                <asp:TextBox ID="spt_Sort2" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Post</strong><strong>邮编 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Post" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>City</strong><strong>城市 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_City" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr style="display: none;">
            <td class="tb1">
                <strong>Country</strong><strong>国家 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Country" runat="server">CN</asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Region</strong><strong>省 </strong>
            </td>
            <td class="tb2">
                <asp:DropDownList ID="spt_Region" runat="server" DataTextField="Region" DataValueField="Regioncode">
                </asp:DropDownList>
                <i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Fax</strong><strong>传真 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Fax" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>收货联系人 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Name_co" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>收货电话 </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Telephone" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>手机（不必填） </strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_MobilePhone" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr class="mntr">
            <td class="tb1">
                <strong>Street</strong><strong>收货地址</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Street" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr class="mntr2" style="display: none;">
            <td class="tb1">
                <strong>House Number</strong>
            </td>
            <td class="tb2">
                <asp:TextBox ID="spt_Housenumber" runat="server"></asp:TextBox><i>*</i>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="padding-left: 330px; padding-bottom: 20px;">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <div class="tb2m"><i>
                        <asp:Literal ID="LitError" runat="server"></asp:Literal></i></div>
                        <asp:Button ID="BtRequest" runat="server" Text="提交" OnClick="BtRequest_Click" Height="30" Width="80" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="BtRequest" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <style>
        table.Mtb, table.Mtb td {
            border: 1px solid #D8D8D8;
            padding: 0 10px;
            line-height: 25px;
        }

        table.Mtb {
            width: 100%;
            margin-top: 10px;
            margin-bottom: 10px;
            border-collapse: collapse;
        }

        .tb1 {
            text-align: right;
            width: 300px;
        }

        .tb2 input {
            width: 300px;
            height: 18px;
        }

        .tb2 .wh20 input {
            width: 20px;
            height: 18px;
        }

        .tb2 i {
            color: tomato;
            padding-left: 5PX;
            font-variant: normal;
            font-style: normal;
        }

        .tb2m i {
            color: tomato;
            padding-left: 5PX;
            font-variant: normal;
            font-style: normal;
        }

        table.Mtb .tbm {
            padding: 0 0px;
        }

        span.bt {
            color: tomato;
        }

        .mntr {
            display: none;
        }

        table.mtb2 td {
            padding: 5px 5px;
            border: 2px solid #CCC;
            cursor: pointer;
        }


        .logistics-title {
            background: none repeat scroll 0 0 #ff7300;
            color: #fff;
            text-align: center; /*width: 85px;
float: left;*/
            padding: 6px 0;
            line-height: 1.5;
            position: relative;
        }

        .shadow {
            position: absolute;
            height: 10px;
            top: 30px;
            left: 0;
            width: 85px;
            background: url(http://img.china.alibaba.com/cms/upload/2012/209/854/458902_532208266.png) no-repeat;
            _filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src=http://img.china.alibaba.com/cms/upload/2012/209/854/458902_532208266.png);
            _background: 0;
        }

        #ctl00__main_ApproveDIV {
            border: 2px solid tomato;
            padding: 10px;
        }
    </style>
    <script language="javascript">
        $(document).ready(function () {
            $('#<%=CBisHaveShipTo.ClientID%>').click(function () {
                var sk = $(this).prop("checked");
                if (sk == true) {
                    $(".mntr").show("slow");
                }
                else {
                    $(".mntr").hide("slow");
                }

            })
        });
        function showshipto() {
            // alert("55");
            $(".mntr").show("slow");
        }
    </script>
</asp:Content>
