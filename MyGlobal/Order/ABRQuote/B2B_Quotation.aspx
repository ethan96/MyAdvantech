<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

    'Dim num_acc As Int16 = 0
    Dim amount_acc As Double = 0
    Dim SAPFTPPath = "172.20.1.6"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(Session("COMPANY_ORG_ID"))
        'Me.Global_Inc1.ValidationStateCheck()
        If Not Page.IsPostBack Then
            Dim ws As New InternalWebService
            If Not ws.CanAccessABRQuotation(User.Identity.Name, Session("RBU"), Session("Account_Status")) Then
                Response.Redirect("~/home.aspx")
            End If
            Dim strSQL As String = ""
            Me.tdErrMsg.InnerText = ""

            txtValidFrom.Text = System.DateTime.Now.ToString("yyyy/MM/dd")
            txtValidTo.Text = System.DateTime.Now.AddDays(15).ToString("yyyy/MM/dd")
            txtPricing_Date.Text = System.DateTime.Now.ToString("yyyy/MM/dd")
            PO_DATE.Text = System.DateTime.Now.ToString("yyyy/MM/dd")
            'strSQL = "SELECT ZTERM FROM SAPRDP.T052 WHERE MANDT = '168' ORDER BY ZTERM "
            'Dim dtPaymentTerm As New DataTable
            ''dtPaymentTerm = Me.Global_Inc1.dbGetDataTable("ACLBI-NEW", "SAP", strSQL)
            ''Frank 2013/08/29
            'dtPaymentTerm = OraDbUtil.dbGetDataTable("SAP_PRD", strSQL)


            'Dim i = 0
            'For i = 0 To dtPaymentTerm.Rows.Count - 1
            '    ddlPaymentTerm.Items.Add(dtPaymentTerm.Rows(i)("ZTERM").ToString())
            'Next

            strSQL = "SELECT INCO1 FROM SAPRDP.TINC WHERE MANDT = '168' ORDER BY INCO1"
            Dim dtIncoterm As New DataTable
            'dtIncoterm = Me.Global_Inc1.dbGetDataTable("ACLBI-NEW", "SAP", strSQL)
            'Frank 2013/08/29
            dtIncoterm = OraDbUtil.dbGetDataTable("SAP_PRD", strSQL)

            For i = 0 To dtIncoterm.Rows.Count - 1
                ddlIncoterm.Items.Add(dtIncoterm.Rows(i)("INCO1").ToString())
            Next

            'Ryan 20160516 Get payment term from database
            ddlPaymentTerm.DataSource = dbUtil.dbGetDataTable("MY", _
                " select distinct CREDIT_TERM from SAP_DIMCOMPANY where ORG_ID='" + Session("org_id") + "' and CREDIT_TERM is not null " + _
                " and CREDIT_TERM <> '' order by CREDIT_TERM")
            ddlPaymentTerm.DataTextField = "CREDIT_TERM" : ddlPaymentTerm.DataValueField = "CREDIT_TERM" : ddlPaymentTerm.DataBind()

            If Request("unicodeid") Is Nothing Then
                Session("unicode") = System.Guid.NewGuid().ToString().Replace("_", "")
                Session("update_flag") = ""
                gvQuoDataList_Bind(0)
            Else

                Session("unicode") = Request("unicodeid")
                'Session("update_flag") = "X"
                Session("update_flag") = ""

                Dim dtHeader As New DataTable
                strSQL = "SELECT COMPANY_ID,COMPANY_NAME,PO,PO_DATE,PAYMENT_TERM,INCOTERM,INCOTERM2,TAX_TYPE,CONDITION_TYPE,CONDITION_RATE,VALIDFROM,VALIDTO,HEADER_DESC,QUOTATIONID,isnull(PRICING_DATE,'') as PRICING_DATE FROM QUOTATION_HEADER_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'"
                dtHeader = dbUtil.dbGetDataTable("EQ", strSQL)
                If dtHeader.Rows.Count > 0 Then
                    Me.company_id.Text = dtHeader.Rows(0)("COMPANY_ID")
                    Me.company_name.Text = dtHeader.Rows(0)("COMPANY_NAME")
                    Me.PO.Text = dtHeader.Rows(0)("PO")
                    Me.PO_DATE.Text = dtHeader.Rows(0)("PO_DATE")
                    Me.ddlPaymentTerm.SelectedIndex = Me.ddlPaymentTerm.Items.IndexOf(Me.ddlPaymentTerm.Items.FindByValue(dtHeader.Rows(0)("PAYMENT_TERM").ToString()))
                    Me.ddlIncoterm.SelectedIndex = Me.ddlIncoterm.Items.IndexOf(Me.ddlIncoterm.Items.FindByValue(dtHeader.Rows(0)("INCOTERM").ToString()))
                    Me.txtIncoterm2.Text = dtHeader.Rows(0)("INCOTERM2")
                    Me.ddlTaxType.SelectedIndex = Me.ddlTaxType.Items.IndexOf(Me.ddlTaxType.Items.FindByValue(dtHeader.Rows(0)("TAX_TYPE").ToString()))
                    Me.ddlConditionType.SelectedIndex = Me.ddlConditionType.Items.IndexOf(Me.ddlConditionType.Items.FindByValue(dtHeader.Rows(0)("CONDITION_TYPE").ToString()))
                    Me.txtConditionRate.Text = dtHeader.Rows(0)("CONDITION_RATE").ToString()
                    'Me.ddlTaxType.Items..Items.FindByValue(dtHeader.Rows(0)("TAX_TYPE").ToString()).
                    Me.txtValidFrom.Text = dtHeader.Rows(0)("VALIDFROM")
                    Me.txtValidTo.Text = dtHeader.Rows(0)("VALIDTO")
                    Me.txtPricing_Date.Text = dtHeader.Rows(0)("PRICING_DATE")
                    Me.txtComment.Text = dtHeader.Rows(0)("HEADER_DESC")
                    Session("QuotationID") = dtHeader.Rows(0)("QUOTATIONID")
                End If
                strSQL = "DELETE QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'"

                'Me.Global_Inc1.dbDataReader("", "", strSQL)
                dbUtil.dbExecuteNoQuery("EQ", strSQL)

                strSQL = "INSERT INTO dbo.QUOTATION_LIST_TEMP_ABR (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE) SELECT UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM dbo.QUOTATION_LIST_ABR WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ"
                'Me.Global_Inc1.dbDataReader("", "", strSQL)
                dbUtil.dbExecuteNoQuery("EQ", strSQL)

                gvQuoDataList_Bind(0)
            End If

        End If
    End Sub

    Private Sub clearForm()
        Dim strSQL As String = ""
        strSQL = "DELETE QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'"
        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)

        Me.company_id.Text = ""
        Me.company_name.Text = ""
        Me.ddlTaxType.SelectedIndex = 0
        Me.ddlConditionType.SelectedIndex = 0
        Me.txtConditionRate.Text = ""
        Me.txtValidFrom.Text = ""
        Me.txtValidTo.Text = ""
        Me.txtPricing_Date.Text = ""
        Me.txtComment.Text = ""
        Me.txtAmount.Text = "0"
        Me.PO.Text = ""
        Me.ddlPaymentTerm.SelectedIndex = 0
        Me.ddlIncoterm.SelectedIndex = 0
        Me.txtIncoterm2.Text = ""
        Me.PO_DATE.Text = ""
        Me.ddlType.SelectedIndex = 0
        Me.txtRate.Text = ""
    End Sub

    Private Function checkSaveFlow(ByRef strErrMsg As String) As Boolean
        If Me.company_id.Text.Length = 0 Then
            Me.company_id.Focus()
            strErrMsg = "please pick comapny id"
            Return False
        End If
        If Me.txtValidFrom.Text.Length = 0 Then
            Me.txtValidFrom.Focus()
            strErrMsg = "please pick valid from"
            Return False
        End If
        If Me.txtValidTo.Text.Length = 0 Then
            Me.txtValidTo.Focus()
            strErrMsg = "please pick valid to"
            Return False
        End If
        If Me.txtPricing_Date.Text.Length = 0 Then
            Me.txtPricing_Date.Focus()
            strErrMsg = "please pick price date"
            Return False
        End If
        If Me.txtConditionRate.Text.Length = 0 Then
            Me.txtConditionRate.Focus()
            strErrMsg = "please key in condition rate"
            Return False
        End If
        Dim strSQL As String = ""
        Dim dtCheck As New DataTable
        strSQL = "SELECT * FROM QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'"

        'dtCheck = Me.Global_Inc1.dbGetDataTable("", "", strSQL)
        dtCheck = dbUtil.dbGetDataTable("EQ", strSQL)

        If dtCheck Is Nothing Or dtCheck.Rows.Count = 0 Then
            strErrMsg = "please key in quotaiton detail"
            Return False
        End If
        'strSQL = "SELECT COMPANY_NAME FROM COMPANY WHERE COMPANY_ID= '" & Me.company_id.Text & "' AND ORG_ID = '" & Session("COMPANY_ORG_ID") & "'"
        strSQL = "SELECT COMPANY_NAME FROM SAP_DIMCOMPANY WHERE COMPANY_ID= '" & Me.company_id.Text & "' AND ORG_ID = 'BR01'"
        dtCheck.Dispose()

        'dtCheck = Me.Global_Inc1.dbGetDataTable("", "", strSQL)
        dtCheck = dbUtil.dbGetDataTable("MY", strSQL)

        If dtCheck Is Nothing Or dtCheck.Rows.Count = 0 Then
            strErrMsg = "company is not found"
            Return False
        Else
            Me.company_name.Text = dtCheck.Rows(0)("COMPANY_NAME").ToString()
        End If
        Return True
    End Function

    'Private Function saveProcess(ByRef strErrMsg As String) As Boolean
    '    Dim strSQL(3) As String
    '    Try
    '        strSQL(0) = "DELETE QUOTATION_HEADER WHERE UNICODE_ID = '" & Session("unicode") & "'"
    '        strSQL(1) = "DELETE QUOTATION_LIST WHERE UNICODE_ID = '" & Session("unicode") & "'"
    '        strSQL(2) = String.Format("INSERT INTO QUOTATION_HEADER (UNICODE_ID,COMPANY_ID,COMPANY_NAME,TAX_TYPE,CONDITION_TYPE,CONDITION_RATE,VALIDFROM,VALIDTO,HEADER_DESC,HEADER_AMOUNT,CREATER,PO,PAYMENT_TERM,INCOTERM,INCOTERM2,PO_DATE) VALUES ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',N'{8}',{9},'{10}','{11}','{12}','{13}','{14}','{15}')", _
    '                                Session("unicode"), _
    '                                Me.company_id.Text, _
    '                                Me.company_name.Text, _
    '                                Me.ddlTaxType.SelectedValue, _
    '                                Me.ddlConditionType.SelectedValue, _
    '                                Me.txtConditionRate.Text, _
    '                                Me.txtValidFrom.Text, _
    '                                Me.txtValidTo.Text, _
    '                                Me.txtComment.Text.Replace("'", """"), _
    '                                Me.txtAmount.Text, _
    '                                Session("user_id"), _
    '                                Me.PO.Text, _
    '                                ddlPaymentTerm.SelectedItem.Text, _
    '                                ddlIncoterm.SelectedItem.Text, _
    '                                Me.txtIncoterm2.Text, _
    '                                Me.PO_DATE.Text)
    '        strSQL(3) = "INSERT INTO dbo.QUOTATION_LIST (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE) SELECT UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM dbo.QUOTATION_LIST_TEMP WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ"

    '        Return SysUtil.dbExecuteNoQueryArray("ACLSQL1", "B2B_ACL_SAP", "b2bsa", "1111", strSQL, strErrMsg)

    '    Catch ex As Exception
    '        strErrMsg = "Save Process Error, please contact B2B sponsor " & ex.ToString()
    '        Return False
    '    End Try
    'End Function
    Private Function saveProcess(ByRef strErrMsg As String) As Boolean
        Dim strSQL As New StringBuilder
        Try
            strSQL.AppendLine("DELETE QUOTATION_HEADER_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'")
            strSQL.AppendLine(";DELETE QUOTATION_LIST_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'")

            dbUtil.dbExecuteNoQuery("EQ", strSQL.ToString)
            strSQL.Clear()
            strSQL.AppendLine("INSERT INTO QUOTATION_HEADER_ABR (UNICODE_ID,COMPANY_ID,COMPANY_NAME,TAX_TYPE,CONDITION_TYPE,CONDITION_RATE,VALIDFROM,VALIDTO,HEADER_DESC,HEADER_AMOUNT,CREATER,PO,PAYMENT_TERM,INCOTERM,INCOTERM2,PO_DATE,PRICING_DATE) ")
            strSQL.AppendLine("VALUES(@UNICODE_ID,@COMPANY_ID,@COMPANY_NAME,@TAX_TYPE,@CONDITION_TYPE,@CONDITION_RATE,@VALIDFROM,@VALIDTO,@HEADER_DESC,@HEADER_AMOUNT,@CREATER,@PO,@PAYMENT_TERM,@INCOTERM,@INCOTERM2,@PO_DATE,@PRICING_DATE)")
            Dim g_adoConn As New SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
            Dim dbCmd As SqlClient.SqlCommand = New SqlCommand(strSQL.ToString, g_adoConn)
            If g_adoConn.State <> ConnectionState.Open Then g_adoConn.Open()

            dbCmd.Parameters.AddWithValue("@UNICODE_ID", Session("unicode"))
            dbCmd.Parameters.AddWithValue("@COMPANY_ID", Me.company_id.Text)
            dbCmd.Parameters.AddWithValue("@COMPANY_NAME", Me.company_name.Text)
            dbCmd.Parameters.AddWithValue("@TAX_TYPE", Me.ddlTaxType.SelectedValue)
            dbCmd.Parameters.AddWithValue("@CONDITION_TYPE", Me.ddlConditionType.SelectedValue)
            dbCmd.Parameters.AddWithValue("@CONDITION_RATE", Me.txtConditionRate.Text)
            dbCmd.Parameters.AddWithValue("@VALIDFROM", Me.txtValidFrom.Text)
            dbCmd.Parameters.AddWithValue("@VALIDTO", Me.txtValidTo.Text)
            dbCmd.Parameters.AddWithValue("@PRICING_DATE", Me.txtPricing_Date.Text)
            dbCmd.Parameters.AddWithValue("@HEADER_DESC", Me.txtComment.Text.Replace("'", """"))
            dbCmd.Parameters.AddWithValue("@HEADER_AMOUNT", Me.txtAmount.Text)
            dbCmd.Parameters.AddWithValue("@CREATER", Session("user_id"))
            dbCmd.Parameters.AddWithValue("@PO", Me.PO.Text)
            dbCmd.Parameters.AddWithValue("@PAYMENT_TERM", ddlPaymentTerm.SelectedItem.Text)
            dbCmd.Parameters.AddWithValue("@INCOTERM", ddlIncoterm.SelectedItem.Text)
            dbCmd.Parameters.AddWithValue("@INCOTERM2", Me.txtIncoterm2.Text)
            dbCmd.Parameters.AddWithValue("@PO_DATE", Me.PO_DATE.Text)

            dbCmd.ExecuteNonQuery()

            strSQL.Clear()
            strSQL.AppendLine("INSERT INTO dbo.QUOTATION_LIST_ABR (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE) SELECT UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM dbo.QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ")

            Return dbUtil.dbExecuteNoQuery("EQ", strSQL.ToString)

            'strSQL.AppendLine(String.Format(";INSERT INTO QUOTATION_HEADER_ABR (UNICODE_ID,COMPANY_ID,COMPANY_NAME,TAX_TYPE,CONDITION_TYPE,CONDITION_RATE,VALIDFROM,VALIDTO,HEADER_DESC,HEADER_AMOUNT,CREATER,PO,PAYMENT_TERM,INCOTERM,INCOTERM2,PO_DATE) VALUES ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',N'{8}',{9},'{10}','{11}','{12}','{13}','{14}','{15}')", _
            '                        Session("unicode"), _
            '                        Me.company_id.Text, _
            '                        Me.company_name.Text, _
            '                        Me.ddlTaxType.SelectedValue, _
            '                        Me.ddlConditionType.SelectedValue, _
            '                        Me.txtConditionRate.Text, _
            '                        Me.txtValidFrom.Text, _
            '                        Me.txtValidTo.Text, _
            '                        Me.txtComment.Text.Replace("'", """"), _
            '                        Me.txtAmount.Text, _
            '                        Session("user_id"), _
            '                        Me.PO.Text, _
            '                        ddlPaymentTerm.SelectedItem.Text, _
            '                        ddlIncoterm.SelectedItem.Text, _
            '                        Me.txtIncoterm2.Text, _
            '                        Me.PO_DATE.Text))
            'strSQL.AppendLine(";INSERT INTO dbo.QUOTATION_LIST_ABR (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE) SELECT UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM dbo.QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ")

            'Return dbUtil.dbExecuteNoQuery("EQ", strSQL.ToString)

        Catch ex As Exception
            strErrMsg = "Save Process Error, please contact B2B sponsor " & ex.ToString()
            Return False
        End Try
    End Function


    Private Function sendProcess(ByRef strErrMsg As String) As Boolean
        'Dim ws As New b2b_ws.B2B_AJP_WS
        'Dim ws As New b2b_ajp_ws.B2B_AJP_WS

        Dim strSQL As String = ""
        Dim i As Integer = 0

        Try
            'Dim WSDL_URL As String = ""

            'Me.Global_Inc1.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
            'Util.GetSiteDefinition("AeuEbizB2BWs", WSDL_URL)

            'ws.Url = WSDL_URL
        Catch ex As Exception
            Response.Write("<Br/>" & ex.Message)
        End Try

        Dim strQuotationID As String = ""
        Dim strQuotation As String = ""

        Dim dtHeader As New DataTable
        Dim dtDetail As New DataTable

        'dtHeader = Me.Global_Inc1.dbGetDataTable("", "", "SELECT UNICODE_ID,COMPANY_ID,COMPANY_NAME,PO,PO_DATE,PAYMENT_TERM,INCOTERM,TAX_TYPE,CONDITION_TYPE,CONDITION_RATE,VALIDFROM,VALIDTO FROM QUOTATION_HEADER WHERE UNICODE_ID = '" & Session("unicode") & "'")
        'dtDetail = Me.Global_Inc1.dbGetDataTable("", "", "SELECT ITEM_NO,HLV_NO,MATERIAL_NO,QTY,PRICE,PRICE_TYPE FROM QUOTATION_LIST WHERE UNICODE_ID = '" & Session("unicode") & "'")

        'dtHeader = Me.Global_Inc1.dbGetDataTable("", "", "SELECT UNICODE_ID,COMPANY_ID,COMPANY_NAME,PO,PO_DATE,PAYMENT_TERM,INCOTERM,INCOTERM2,TAX_TYPE,VALIDFROM,VALIDTO FROM QUOTATION_HEADER WHERE UNICODE_ID = '" & Session("unicode") & "'")
        dtHeader = dbUtil.dbGetDataTable("EQ", "SELECT UNICODE_ID,COMPANY_ID,COMPANY_NAME,PO,PO_DATE,PAYMENT_TERM,INCOTERM,INCOTERM2,TAX_TYPE,VALIDFROM,VALIDTO,PRICING_DATE FROM QUOTATION_HEADER_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'")

        'dtDetail = Me.Global_Inc1.dbGetDataTable("", "", "SELECT ITEM_NO,HLV_NO,MATERIAL_NO,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM QUOTATION_LIST WHERE UNICODE_ID = '" & Session("unicode") & "'")
        dtDetail = dbUtil.dbGetDataTable("EQ", "SELECT ITEM_NO,HLV_NO,MATERIAL_NO,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM QUOTATION_LIST_ABR WHERE UNICODE_ID = '" & Session("unicode") & "'")

        strQuotation = "<QUOTATION>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<UNICODE_ID>" & dtHeader.Rows(0)("UNICODE_ID") & "</UNICODE_ID>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<COMPANY_ID>" & dtHeader.Rows(0)("COMPANY_ID") & "</COMPANY_ID>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<COMPANY_NAME>" & dtHeader.Rows(0)("COMPANY_NAME").ToString.Replace("&", "_") & "</COMPANY_NAME>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<PO>" & dtHeader.Rows(0)("PO") & "</PO>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<PO_DATE>" & dtHeader.Rows(0)("PO_DATE") & "</PO_DATE>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<PAYMENT_TERM>" & dtHeader.Rows(0)("PAYMENT_TERM") & "</PAYMENT_TERM>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<INCOTERM>" & dtHeader.Rows(0)("INCOTERM") & "</INCOTERM>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<INCOTERM2>" & dtHeader.Rows(0)("INCOTERM2") & "</INCOTERM2>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<TAX_TYPE>" & dtHeader.Rows(0)("TAX_TYPE") & "</TAX_TYPE>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        'strQuotation = strQuotation & "<CONDITION_TYPE>" & dtHeader.Rows(0)("CONDITION_TYPE") & "</CONDITION_TYPE>"
        'strQuotation = strQuotation & Chr(13) & Chr(10)
        'strQuotation = strQuotation & "<CONDITION_RATE>" & dtHeader.Rows(0)("CONDITION_RATE") & "</CONDITION_RATE>"
        'strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<VALIDFROM>" & dtHeader.Rows(0)("VALIDFROM") & "</VALIDFROM>"
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<VALIDTO>" & dtHeader.Rows(0)("VALIDTO") & "</VALIDTO>"

        'Frank: insert pricing date
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "<PRICING_DATE>" & dtHeader.Rows(0)("PRICING_DATE") & "</PRICING_DATE>"


        For i = 0 To dtDetail.Rows.Count - 1

            strQuotation = strQuotation & "<DETAIL>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<CONDITION_TYPE>" & dtDetail.Rows(i)("CONDITION_TYPE") & "</CONDITION_TYPE>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<CONDITION_RATE>" & dtDetail.Rows(i)("CONDITION_RATE") & "</CONDITION_RATE>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<ITEM_NO>" & dtDetail.Rows(i)("ITEM_NO") & "</ITEM_NO>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            Dim PN As String = dtDetail.Rows(i)("MATERIAL_NO")
            If IsNumeric(PN) Then
                PN = "00000000" & PN
            End If
            strQuotation = strQuotation & "<MATERIAL_NO>" & PN & "</MATERIAL_NO>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<HLV_NO>" & dtDetail.Rows(i)("HLV_NO") & "</HLV_NO>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<QTY>" & dtDetail.Rows(i)("QTY") & "</QTY>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<PRICE_TYPE>" & dtDetail.Rows(i)("PRICE_TYPE") & "</PRICE_TYPE>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "<PRICE>" & dtDetail.Rows(i)("PRICE") & "</PRICE>"
            strQuotation = strQuotation & Chr(13) & Chr(10)
            strQuotation = strQuotation & "</DETAIL>"
        Next
        strQuotation = strQuotation & Chr(13) & Chr(10)
        strQuotation = strQuotation & "</QUOTATION>"
        'Response.Write(strQuotation)
        Dim rootPath As String = Server.MapPath("~")

        If Session("update_flag") = "X" Then
            SAPDAL.SAPDAL.Update_Quotation_BR("BR01", strQuotation, Session("QuotationID"), strErrMsg)
            If strErrMsg.ToString.Length > 0 Then
                Return False
            Else
                System.Threading.Thread.Sleep(1000)
                SAPDAL.SAPDAL.Create_Quotation_PDF(strQuotationID, strErrMsg)
                Dim ftp As New FTP_OBJ.FTP_GET
                ftp.setFTPIP("ftp://" + SAPFTPPath + "/")
                ftp.setFTPuserid("ebiz")
                ftp.setFTPpassword("ebiz")
                ftp.setFTPpath("SD/out/")
                System.Threading.Thread.Sleep(3000)
                'ftp.downloadFile(Session("QuotationID") & ".pdf", "C:\B2B_ACL_SAP\File\QuotationFile\", strErrMsg)
                ftp.downloadFile(Session("QuotationID") & ".pdf", System.IO.Path.Combine(rootPath, "File\QuotationFile\"), strErrMsg)
                strSQL = "UPDATE QUOTATION_HEADER_ABR SET QUOTATIONID = '" & Session("QuotationID") & "' WHERE UNICODE_ID = '" & Session("unicode") & "'"

                'Me.Global_Inc1.dbDataReader("", "", strSQL)
                dbUtil.dbExecuteNoQuery("EQ", strSQL)

                Return True
            End If
        Else
            'ws.Create_Quotation_BR(UCase(Session("COMPANY_ORG_ID")), strQuotation, strQuotationID, strErrMsg)
            SAPDAL.SAPDAL.Create_Quotation_BR("BR01", strQuotation, strQuotationID, strErrMsg)
            If strQuotationID.Length = 0 Then

                strErrMsg = "RFC : Create_Quotation_BR fail, please contact B2B sponsor" & strErrMsg
                Return False
            Else
                strErrMsg = ""
                System.Threading.Thread.Sleep(1000)
                SAPDAL.SAPDAL.Create_Quotation_PDF(strQuotationID, strErrMsg)
                Dim ftp As New FTP_OBJ.FTP_GET
                ftp.setFTPIP("ftp://" + SAPFTPPath + "/")
                ftp.setFTPuserid("ebiz")
                ftp.setFTPpassword("ebiz")
                ftp.setFTPpath("SD/out/")
                Dim fileName = strQuotationID.Substring(checkFileName(strQuotationID))
                System.Threading.Thread.Sleep(3000)
                'If (ftp.downloadFile(fileName & ".pdf", "C:\B2B_ACL_SAP\File\QuotationFile\", strErrMsg)) Then

                'check Directory Exists
                If Not System.IO.Directory.Exists(System.IO.Path.Combine(rootPath, "Files\ABRQuotationFile\")) Then
                    System.IO.Directory.CreateDirectory(System.IO.Path.Combine(rootPath, "Files\ABRQuotationFile\"))
                End If

                If (ftp.downloadFile(fileName & ".pdf", System.IO.Path.Combine(rootPath, "Files\ABRQuotationFile\"), strErrMsg)) Then
                    strSQL = "UPDATE QUOTATION_HEADER_ABR SET QUOTATIONID = '" & fileName & "' WHERE UNICODE_ID = '" & Session("unicode") & "'"

                    'Me.Global_Inc1.dbDataReader("", "", strSQL)
                    dbUtil.dbExecuteNoQuery("EQ", strSQL)


                    '=====Save file to database=====

                    'Read file to byte 
                    Dim _FilePathName As String = System.IO.Path.Combine(rootPath, "Files\ABRQuotationFile\")
                    _FilePathName = System.IO.Path.Combine(_FilePathName, fileName & ".pdf")
                    Dim _filebyte() As Byte = Me.ConvertImageFiletoBytes(_FilePathName)

                    Dim _MyCon As New SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
                    If _MyCon.State <> ConnectionState.Open Then _MyCon.Open()

                    Dim cmd As New SqlClient.SqlCommand()
                    cmd.Connection = _MyCon


                    Dim _sql As New StringBuilder
                    _sql.AppendLine(" Insert into QUOTATION_FILE_ABR (UNICODE_ID,QuotationID,FILE_DATA,LAST_UPDATED,LAST_UPDATED_BY) ")
                    _sql.AppendLine(" values(@UNICODE_ID,@QuotationID,@FILE_DATA,getdate(),@LAST_UPDATED_BY) ")

                    cmd.CommandText = _sql.ToString
                    cmd.Parameters.AddWithValue("UNICODE_ID", Session("unicode")) : cmd.Parameters.AddWithValue("QuotationID", fileName)
                    cmd.Parameters.AddWithValue("FILE_DATA", _filebyte) : cmd.Parameters.AddWithValue("LAST_UPDATED_BY", HttpContext.Current.User.Identity.Name)
                    cmd.ExecuteNonQuery()
                    cmd = Nothing : _MyCon.Close()

                    'Del File
                    If System.IO.File.Exists(_FilePathName) Then
                        System.IO.File.Delete(_FilePathName)
                    End If
                    'End=====Save file to database=====

                Else
                    strErrMsg = strErrMsg + fileName
                    Return False
                End If

                Return True
            End If
        End If


    End Function


    ''' <summary>
    ''' Converts the Image File to array of Bytes
    ''' </summary>
    ''' <param name="ImageFilePath">The path of the image file</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function ConvertImageFiletoBytes(ByVal ImageFilePath As String) As Byte()
        Dim _tempByte() As Byte = Nothing
        If String.IsNullOrEmpty(ImageFilePath) = True Then
            Throw New ArgumentNullException("Image File Name Cannot be Null or Empty", "ImageFilePath")
            Return Nothing
        End If
        Try
            Dim _fileInfo As New IO.FileInfo(ImageFilePath)
            Dim _NumBytes As Long = _fileInfo.Length
            Dim _FStream As New IO.FileStream(ImageFilePath, IO.FileMode.Open, IO.FileAccess.Read)
            Dim _BinaryReader As New IO.BinaryReader(_FStream)
            _tempByte = _BinaryReader.ReadBytes(Convert.ToInt32(_NumBytes))
            _fileInfo = Nothing
            _NumBytes = 0
            _FStream.Close()
            _FStream.Dispose()
            _BinaryReader.Close()
            Return _tempByte
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Private Function checkFileName(ByVal fileName As String) As Int16
        Dim i As Integer = 0
        For i = 0 To fileName.Length
            If fileName(i) <> "0" Then
                Return i
            End If
        Next
    End Function

    Private Function checkFormat(ByVal strType As String, ByVal strInput As String, ByVal controlName As String) As Boolean
        Try
            If strInput.Length > 0 Then
                Select Case strType
                    Case "INT"
                        Convert.ToInt16(strInput)
                        Return True
                    Case "STRING"
                        Convert.ToString(strInput)
                        Return True
                    Case "DOUBLE"
                        Convert.ToDouble(strInput)
                        Return True
                End Select
            End If
        Catch ex As Exception
            Me.FindControl(controlName).Focus()
            Return False
        End Try
    End Function

    Private Function getPrice(ByVal material As String) As String
        'Dim strSQL As String = ""
        'Dim dtPrice As New DataTable
        'dtPrice = Me.Global_Inc1.dbGetDataTable("", "", "SELECT REPS_PRICE FROM ABR_PRICE_LIST WHERE PART_NO = '" & material & "'")
        'If dtPrice.Rows.Count > 0 Then
        ' Return dtPrice.Rows(0)("REPS_PRICE")
        'Else
        'Return "0"
        'End If

        Dim strUnitPrice As Decimal = 0
        Dim strListPrice As Decimal = 0
        OrderUtilities.B2BACL_GetPrice_ABR(material, Me.company_id.Text, "BR01", 1, strListPrice, strUnitPrice)

        Return strUnitPrice.ToString()

    End Function
    Function getPLMNote(ByVal pn As String, ByVal org As String) As String

        Dim STR As String = String.Format("select * from SAP_PRODUCT_ORDERNOTE where org='{1}' AND part_no='{0}'", pn, org)
        Dim DT As New DataTable
        DT = dbUtil.dbGetDataTable("MY", STR)
        'HttpContext.Current.Response.Write(STR)
        If DT.Rows.Count > 0 Then
            Return DT.Rows(0).Item("txt")
        End If
        Return ""
    End Function
    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.tdErrMsg.InnerText = ""
        Dim strSQL As String = ""
        Dim MaterialDesc As String = ""
        Dim strPrice As String = ""
        Dim strPriceType As String = ""
        Dim dt As New DataTable

        If txtItemNumber.Text.Length = 0 Then
            Me.tdErrMsg.InnerText = "Plz key in Item No!!"
            Me.txtItemNumber.Focus()
            Return
        ElseIf (Convert.ToInt16(txtItemNumber.Text) > 100 And Convert.ToInt16(txtItemNumber.Text) Mod 100 > 0) And txtHLV_NO.Text.Length = 0 Then
            Me.tdErrMsg.InnerText = "Plz key in High level!!"
            Me.txtHLV_NO.Focus()
            Return
        End If


        If txtPrice.Text.Length = 0 Then
            strPriceType = "ZPR0"
        Else
            strPriceType = "ZPN0"
        End If
        Try

            'strSQL = String.Format("SELECT PRODUCT_DESC FROM PRODUCT WHERE PART_NO = '{0}' AND ORG_ID = '{1}'", Me.txtMaterial.Text, Session("COMPANY_ORG_ID"))
            'dt = Me.Global_Inc1.dbGetDataTable("", "", strSQL)
            'strSQL = String.Format("SELECT PRODUCT_DESC,VMSTA,VMSTB FROM BI.dbo.GLOBAL_MATERIAL A INNER JOIN SAP.dbo.TVMST B on A.STATUS = B.VMSTA WHERE PART_NO = '{0}' AND SALES_ORG = '{1}'", _
            'Me.txtMaterial.Text, Session("COMPANY_ORG_ID"))
            'dt = Me.Global_Inc1.dbGetDataTable("ACLBI-NEW", "BI", "b2bsa", "1111", strSQL)
            Dim PartNo As String = Me.txtMaterial.Text.ToUpper.Trim
            If Global_Inc.IsNumericItem(PartNo) Then
                PartNo = Global_Inc.IsNumericItem_Expand(PartNo)
            End If
            strSQL = "select a.matnr as  product,"
            strSQL &= " (select MAKTX from saprdp.makt b where b.matnr=a.matnr and rownum=1 and b.spras='E') as product_desc,"
            strSQL &= " a.vkorg as orgid, a.vmsta, b.vmstb"
            strSQL &= " from saprdp.MVKE a "
            strSQL &= " left join saprdp.TVMST b on a.vmsta=b.vmsta"
            strSQL &= " where a.mandt='168'"
            'strSQL &= " and b.mandt='168' and a.vkorg='" & Session("COMPANY_ORG_ID") & "'"
            strSQL &= " and b.mandt='168' and a.vkorg='BR01'"
            strSQL &= " and a.matnr='" & PartNo & "' and b.spras='E' and rownum=1"
            'Frank 2013/08/29
            dt = OraDbUtil.dbGetDataTable("SAP_PRD", strSQL)

            If dt.Rows.Count > 0 Then
                strPrice = IIf(Me.txtPrice.Text.Length = 0, getPrice(Me.txtMaterial.Text), Me.txtPrice.Text)
                Me.txtQty.Text = IIf(Me.txtQty.Text.Length = 0, "1", Me.txtQty.Text)
                If (checkFormat("STRING", Me.txtMaterial.Text, "txtMaterial") And checkFormat("INT", Me.txtQty.Text, "txtQty") And checkFormat("DOUBLE", strPrice, "txtPrice")) Then
                    If (dt.Rows(0)("VMSTA") <> "A") Then
                        Me.tdErrMsg.InnerText = Me.txtMaterial.Text & "  " & dt.Rows(0)("VMSTB")
                    End If


                    strSQL = "SELECT PART_NO,EXTENDED_DESC FROM SAP_PRODUCT_EXT_DESC"
                    strSQL &= " Where PART_NO=@partno"
                    Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    Dim dt1 As New DataTable
                    Dim apt As New SqlClient.SqlDataAdapter(strSQL, conn)
                    apt.SelectCommand.Parameters.AddWithValue("partno", Me.txtMaterial.Text)
                    apt.Fill(dt1)
                    conn.Close()

                    'MaterialDesc = dt.Rows(0)("PRODUCT_DESC")
                    If dt1 IsNot Nothing AndAlso dt1.Rows.Count > 0 Then
                        MaterialDesc = dt1.Rows(0)("EXTENDED_DESC")
                    Else
                        MaterialDesc = dt.Rows(0)("product_desc")
                    End If

                    'strSQL = String.Format("INSERT INTO QUOTATION_LIST_TEMP_ABR (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,QTY,PRICE,PRICE_TYPE,CONDITION_TYPE,CONDITION_RATE) VALUES ('{0}','{1}','{2}','{3}','{4}',{5},{6},'{7}','{8}','{9}')", Session("unicode"), txtItemNumber.Text, txtHLV_NO.Text, txtMaterial.Text, MaterialDesc, Me.txtQty.Text, strPrice, strPriceType, Me.ddlType.SelectedItem.Text, Me.txtRate.Text)

                    'Me.Global_Inc1.dbDataReader("", "", strSQL)
                    'dbUtil.dbExecuteNoQuery("EQ", strSQL)

                    'JJ 2013/11/27：改成 sql Parameters, 因為某些料號(989KC10000E)的description內含單引號會讓上面的SQL Insert失敗
                    strSQL = "INSERT INTO QUOTATION_LIST_TEMP_ABR (UNICODE_ID,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,QTY,PRICE,PRICE_TYPE,CONDITION_TYPE,CONDITION_RATE) "
                    strSQL += " VALUES (@UNICODE_ID,@ITEM_NO,@HLV_NO,@MATERIAL_NO,@MATERIAL_DESC,@QTY,@PRICE,@PRICE_TYPE,@CONDITION_TYPE,@CONDITION_RATE)"

                    Dim g_adoConn As New SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
                    Dim dbCmd As SqlClient.SqlCommand = New SqlCommand(strSQL, g_adoConn)
                    If g_adoConn.State <> ConnectionState.Open Then g_adoConn.Open()

                    dbCmd.Parameters.AddWithValue("@UNICODE_ID", Session("unicode"))
                    dbCmd.Parameters.AddWithValue("@ITEM_NO", txtItemNumber.Text)
                    dbCmd.Parameters.AddWithValue("@HLV_NO", txtHLV_NO.Text)
                    dbCmd.Parameters.AddWithValue("@MATERIAL_NO", txtMaterial.Text.Replace("'", ""))
                    dbCmd.Parameters.AddWithValue("@MATERIAL_DESC", MaterialDesc)
                    dbCmd.Parameters.AddWithValue("@QTY", Me.txtQty.Text)
                    dbCmd.Parameters.AddWithValue("@PRICE", strPrice)
                    dbCmd.Parameters.AddWithValue("@PRICE_TYPE", strPriceType)
                    dbCmd.Parameters.AddWithValue("@CONDITION_TYPE", Me.ddlType.SelectedItem.Text)
                    dbCmd.Parameters.AddWithValue("@CONDITION_RATE", Me.txtRate.Text)

                    dbCmd.ExecuteNonQuery()

                    gvQuoDataList_Bind(0)
                    Dim _plmnote As String = getPLMNote(txtMaterial.Text, "BR01")

                    If Not String.IsNullOrEmpty(_plmnote) Then

                        If String.IsNullOrEmpty(Me.tdErrMsg.InnerText) Then 'AndAlso (Not String.IsNullOrEmpty(_plmnote)) Then
                            Me.tdErrMsg.InnerText = getPLMNote(txtMaterial.Text, "BR01")
                        Else
                            Me.tdErrMsg.InnerHtml = Me.tdErrMsg.InnerText & "<br>" & getPLMNote(txtMaterial.Text, "BR01")
                        End If


                    End If


                    Me.txtHLV_NO.Text = ""
                    Me.txtMaterial.Text = ""
                    Me.txtItemNumber.Text = ""
                    Me.txtQty.Text = ""
                    Me.txtPrice.Text = ""
                    Me.txtRate.Text = ""
                    Me.ddlType.SelectedIndex = 0

                Else
                    Me.tdErrMsg.InnerText = "Data Type is not correct!!"
                End If

            Else
                Me.tdErrMsg.InnerText = "Part Number does not exist!!"
            End If

        Catch ex As Exception
            Me.tdErrMsg.InnerText = ex.ToString() & "Process error, please call B2B sponsor"
        End Try
    End Sub

    'Public Sub InitProdinfo(ByVal partNo As String, ByVal org As String, ByVal PartDeliveryPlant As String)
    '    tbProdInfo.Visible = True
    '    Me.lbPartNo.Text = partNo : Me.lbProdStatus.Text = Me.getProductStatus(partNo, org)
    '    'Dim DT As New DataTable
    '    'DT = Business.getATPdetail(partNo, org)
    '    'gvAddedPNInventory.DataSource = DT : gvAddedPNInventory.DataBind() : Me.lbPLMNOTE.Text = Business.getPLMNote(partNo, org)

    '    Dim prod_input As New SAPDAL.SAPDALDS.ProductInDataTable, _sapdal As New SAPDAL.SAPDAL
    '    'Dim MainDeliveryPlant As String = "USH1", _errormsg As String = String.Empty
    '    Dim MainDeliveryPlant As String = Me.getPlantByOrgID(org), _errormsg As String = String.Empty
    '    Dim inventory_out As New SAPDAL.SAPDALDS.QueryInventory_OutputDataTable
    '    prod_input.AddProductInRow(partNo, 0, PartDeliveryPlant)
    '    _sapdal.QueryInventory_V2(prod_input, MainDeliveryPlant, Now, inventory_out, _errormsg)
    '    gvAddedPNInventory.DataSource = inventory_out : gvAddedPNInventory.DataBind() : Me.lbPLMNOTE.Text = Me.getPLMNote(partNo, org)
    '    Me.lbABCDindicator.Text = Business.getPartIndicator(partNo, "BR01")
    'End Sub

    Private Function getPlantByOrgID(ByVal ID As String) As String
        Return Left(ID, 2) & "H1"
    End Function


    Private Function getProductStatus(ByVal partNo As String, ByVal org_id As String) As String
        Dim str As String = String.Format("select top 1 * from sap_product_status where PART_NO='{0}' and sales_org='{1}'", partNo, org_id)

        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", str)
        If dt.Rows.Count > 0 Then
            Return dt.Rows(0).Item("product_status").ToString
        End If
        Return ""
    End Function


    Private Sub gvQuoDataList_Bind(ByVal pageInx As Int16)
        Dim dt As New DataTable

        'dt = Me.Global_Inc1.dbGetDataTable("", "", "SELECT SEQ,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM QUOTATION_LIST_TEMP WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ")
        dt = dbUtil.dbGetDataTable("EQ", "SELECT SEQ,ITEM_NO,HLV_NO,MATERIAL_NO,MATERIAL_DESC,CONDITION_TYPE,CONDITION_RATE,QTY,PRICE,PRICE_TYPE FROM QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Session("unicode") & "' ORDER BY SEQ")

        gvQuoList.DataSource = dt
        gvQuoList.PageIndex = pageInx
        gvQuoList.DataBind()
        txtAmount.Text = Me.amount_acc.ToString()
    End Sub

    Protected Sub gvQuoList_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        e.Row.Cells(0).Visible = False
        e.Row.Cells(8).Visible = False
        If (e.Row.RowType = DataControlRowType.DataRow) Then
            'Me.num_acc = Me.num_acc + 1
            'e.Row.Cells(1).Text = Me.num_acc.ToString()
            Try
                e.Row.Cells(7).Text = Convert.ToString(Convert.ToInt16(e.Row.Cells(5).Text) * Convert.ToDouble(e.Row.Cells(6).Text))
                Me.amount_acc = Me.amount_acc + Convert.ToDouble(e.Row.Cells(7).Text)
            Catch ex As Exception
                'do nothing
            End Try


        End If
    End Sub

    Protected Sub gvQuoList_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvQuoDataList_Bind(e.NewPageIndex)
    End Sub

    Protected Sub gvQuoList_RowCancelingEdit(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        Me.gvQuoList.EditIndex = -1
        gvQuoDataList_Bind(Me.gvQuoList.PageIndex)
    End Sub

    Protected Sub gvQuoList_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)
        Me.gvQuoList.EditIndex = e.NewEditIndex
        gvQuoDataList_Bind(Me.gvQuoList.PageIndex)
        Me.gvQuoList.Columns(1).ControlStyle.Width = 30
        Me.gvQuoList.Columns(3).ControlStyle.Width = 30
        Me.gvQuoList.Columns(5).ControlStyle.Width = 30
        Me.gvQuoList.Columns(9).ControlStyle.Width = 30
        Me.gvQuoList.Columns(10).ControlStyle.Width = 30
    End Sub

    Protected Sub gvQuoList_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Me.tdErrMsg.InnerText = ""
        Dim strSQL As String = ""
        'strSQL = String.Format("UPDATE QUOTATION_LIST_TEMP SET ITEM_NO = '{4}',HLV_NO='{5}' ,QTY = {0}, PRICE = {1} WHERE UNICODE_ID = '{2}' AND SEQ = '{3}'", CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(5).Controls(0), TextBox).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(6).Controls(0), TextBox).Text, Session("unicode"), Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(0).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(1).Controls(0), TextBox).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(3).Controls(0), TextBox).Text)
        strSQL = String.Format("UPDATE QUOTATION_LIST_TEMP_ABR SET ITEM_NO = '{4}',HLV_NO='{5}' ,QTY = {0}, PRICE = {1},CONDITION_TYPE = '{6}',CONDITION_RATE = '{7}' WHERE UNICODE_ID = '{2}' AND SEQ = '{3}'", CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(5).Controls(0), TextBox).Text, Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(6).Text, Session("unicode"), Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(0).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(1).Controls(0), TextBox).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(3).Controls(0), TextBox).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(9).Controls(0), TextBox).Text, CType(Me.gvQuoList.Rows(Me.gvQuoList.EditIndex).Cells(10).Controls(0), TextBox).Text)

        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)

        Me.gvQuoList.EditIndex = -1
        gvQuoDataList_Bind(0)
    End Sub

    Protected Sub gvQuoList_RowDeleting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim strSQL As String = ""
        strSQL = "DELETE QUOTATION_LIST_TEMP_ABR WHERE SEQ = '" & Me.gvQuoList.Rows(e.RowIndex).Cells(0).Text & "' AND UNICODE_ID = '" & Session("unicode") & "'"
        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)

        gvQuoDataList_Bind(0)
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        clearForm()
        Session("unicode") = System.Guid.NewGuid().ToString().Replace("_", "")
        gvQuoDataList_Bind(0)
    End Sub

    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        clearForm()
        Response.Redirect(".\B2B_Quotation_List.aspx")
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strErrMsg As String = ""
        If checkSaveFlow(strErrMsg) Then
            If saveProcess(strErrMsg) Then
                clearForm()
                Session("unicode") = System.Guid.NewGuid().ToString().Replace("_", "")
                gvQuoDataList_Bind(0)
                Me.tdErrMsg.InnerText = "Save complete"
            Else
                Me.tdErrMsg.InnerText = "Save fail : (" & strErrMsg & ")"
            End If
        Else
            Me.tdErrMsg.InnerText = "check flow fail : (" & strErrMsg & ")"
        End If


    End Sub

    Protected Sub btnSend_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strErrMsg As String = ""
        If checkSaveFlow(strErrMsg) Then
            If saveProcess(strErrMsg) Then
                If sendProcess(strErrMsg) Then
                    clearForm()
                    Session("unicode") = System.Guid.NewGuid().ToString().Replace("_", "")
                    gvQuoDataList_Bind(0)
                    Me.tdErrMsg.InnerText = "Send complete"
                Else
                    Me.tdErrMsg.InnerText = "Send to SAP fail : (" & strErrMsg & ")"
                End If
            Else
                Me.tdErrMsg.InnerText = "Save fail  : (" & strErrMsg & ")"
            End If
        Else
            Me.tdErrMsg.InnerText = "check flow fail : (" & strErrMsg & ")"
        End If


    End Sub

</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">

<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script type="text/javascript">
    $(function () {
        $("#<%=PO_DATE.ClientID%>").datepicker({ dateFormat: 'yy/mm/dd' });
        $("#<%=txtValidFrom.ClientID%>").datepicker({ dateFormat: 'yy/mm/dd' });
        $("#<%=txtValidTo.ClientID%>").datepicker({ dateFormat: 'yy/mm/dd' });
        $("#<%=txtPricing_Date.ClientID%>").datepicker({ dateFormat: 'yy/mm/dd' });


        //        $(".checkNum").keydown(function (e) {

        //            //注意此處不要用keypress方法，否則不能禁用 Ctrl+V,具體原因請自行查找keyPress與keyDown區分，十分重要
        //            if ($.browser.msie) {  // 判斷瀏覽器

        //                if (((event.keyCode > 47) && (event.keyCode < 58)) || (event.keyCode == 8) || (event.keyCode == 46)) {// 判斷鍵值：46 = Delete,8 = BackSpace
        //                    return true;
        //                } else {
        //                    return false;
        //                }
        //            } else {
        //                if (((e.which > 47) && (e.which < 58)) || (e.which == 8) || (event.keyCode == 17)) {
        //                    return true;
        //                } else {
        //                    return false;
        //                }
        //            }
        //        }).focus(function () {
        //            this.style.imeMode = 'disabled';   // 禁用输入法,禁止输入中文字符
        //        });

        //        $("#<%=txtRate.ClientID%>").keydown(function (e) {

        //            //注意此處不要用keypress方法，否則不能禁用 Ctrl+V,具體原因請自行查找keyPress與keyDown區分，十分重要
        //            if ($.browser.msie) {  // 判斷瀏覽器

        //                if (((event.keyCode > 47) && (event.keyCode < 58)) || (event.keyCode == 8) || (event.keyCode == 46)) {// 判斷鍵值  
        //                    return true;
        //                } else {
        //                    return false;
        //                }
        //            } else {
        //                if (((e.which > 47) && (e.which < 58)) || (e.which == 8) || (event.keyCode == 17)) {
        //                    return true;
        //                } else {
        //                    return false;
        //                }
        //            }

        //        }).focus(function () {
        //            this.style.imeMode = 'disabled';   // 禁用输入法,禁止输入中文字符
        //        });
    });

    //限制只能輸入整數
    function ValidateNumber(e, pnumber) {
        if (!/^\d+$/.test(pnumber)) {
            var newValue = /^\d+/.exec(e.value);
            if (newValue != null) {
                e.value = newValue;
            }
            else {
                e.value = "";
            }
        }
        return false;
    }

    //限制只能輸入數字(包含小數)
    function ValidateFloat(e, pnumber) {
        if (!/^\d+[.]?\d*$/.test(pnumber)) {
            var newValue = /^\d+[.]?\d*/.exec(e.value);
            if (newValue != null) {
                e.value = newValue;
            }
            else {
                e.value = "";
            }
        }
        return false;
    }

    function test1() {
        //alert('aaaa');
        var btn = true;
        if (btn) $("#divMyContactList").dialog({ modal: true, width: $(window).width() * 0.4, height: $(window).height() - 200 });
    }

    function checkCompanyID() {
        if ($("#<%=company_id.ClientID%>").val() == "") {
            alert("Please Pick a Company ID...");
            return false;
        } else {
            return true;
        }
    }
</script>
  <style type="text/css">
    body
    {
       color:#333333;
	  font-size:12px;
 	  font-family:Arial, Helvetica, sans-serif;
	  line-height:18px;
    }
  </style>

<table width="100%" border="0" cellspacing="0" cellpadding="0"> 
	<tr> 
	    <td> 
	        <%--<hdr:header runat="server" ID="Hearder1"></hdr:header >--%>
	    </td> 
	</tr>
	<tr> 
	    <td style="height:3px"> 
	        <!--Buffer--> &nbsp; 
	    </td> 
	</tr> 
	
	<tr> 
	    <td> 
	        <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0"> 
	            <tr> 
	                <td style="width:10px"></td> 
	                <td></td> 
	                <td style="width:20px"></td> 
	            </tr> 
	            <tr> 
	                <td colspan="3" style="height:15px"> </td> 
	            </tr> 
	            <tr> 
	                <td style="width:10px"></td> 
	                <td> <!--Page Title--> 
	                    <div class="euPageTitle">Create Quotation</div> 
	                </td> 
	                <td style="width:20px"></td> 
	            </tr> 
	            <tr> 
	                <td colspan="3" style="height:15px"> </td> 
	            </tr> 
	            <tr> 
	                <td style="width:10px"> </td> 
	                <td valign="top"> 
	                    <table border="0" cellpadding="0" cellspacing="0"> 
	                        <tr valign="top"> 
	                            <td> <!--New Table Start--> 
	                                <table width="900px" border="0" cellpadding="0" cellspacing="0" id="Table1"> 
	                                <tr>
	                                <td>
	                                <table width="500px" border="0" cellpadding="0" cellspacing="0" id="Table2"> 
	                                    <tr> 
	                                        <td> 
	                                            <table width="500px" border="0" cellpadding="0" cellspacing="0" class="text" id="Table5"> 
	                                                <tr> 
	                                                    <td style="width:1%" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_left.jpg" width="7" height="23"/></td> 
	                                                    <td style="width:98%; background-color:#A3BFD4" valign="top" ><img alt="" src="../../images/ebiz.aeu.face/bluefolder_top.jpg" width="138" height="3"/></td> 
	                                                    <td style="width:1%" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_right.jpg" width="7" height="23"/></td> 
	                                                </tr> 
	                                                <tr>
	                                                    <td class="euFormCaption" style="height: 19px">Quoation Header</td>	
													</tr>
												</table>
											</td>
										</tr>
										<tr>
										    <td style="width:500px; height:5px; background-color:#A0BFD3"></td>
										</tr>
										<tr>
										    <td style="height:100px;border:#A4B5BD 1px solid">
											    <table width="100%"  border="0" cellpadding="0" cellspacing="1" style="height:100%; background-color:#F1F2F4">
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Customer ID</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="company_id" runat="Server" Text = "" Width ="250px"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="left" style="width:20px">
                                                            <input name="Pick" style="cursor:pointer;" value="Pick" type="button" onclick="PickCompanyID('<%=company_id.ClientID%>*<%=company_name.ClientID%>*<%=ddlPaymentTerm.ClientID%>','SOLDTO','','<%=Session("ORG_ID") %>');"  id="btnPickCompany"/>
											            </td>											            
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Customer Name</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="company_name" runat="Server" Text = "" Width ="250px"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Purchase Order</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="PO" runat="Server" Text = "" Width ="250px"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>PO Date</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                 <%--<asp:TextBox ID="PO_DATE" runat="Server" Text = "" onclick="javascript:popUpCalendar(this, this, 'yyyy/mm/dd')"></asp:TextBox>--%>
                                                            <asp:TextBox ID="PO_DATE" runat="Server" Text = "" Enabled="false"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Payment Term</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <asp:DropDownList ID="ddlPaymentTerm" runat="server" Width="120px">
                                                                <%--<asp:ListItem Value="CN01" />
                                                                <asp:ListItem Value="CN03" />
                                                                <asp:ListItem Value="CN04" />
                                                                <asp:ListItem Value="CN05" />
                                                                <asp:ListItem Value="CN09" />
                                                                <asp:ListItem Value="CN10" />
                                                                <asp:ListItem Value="CN11" />
                                                                <asp:ListItem Value="CN12" />
                                                                <asp:ListItem Value="CN16" />
                                                                <asp:ListItem Value="COD" />
                                                                <asp:ListItem Value="PPD" />
                                                                <asp:ListItem Value="I001" />
                                                                <asp:ListItem Value="I007" />
                                                                <asp:ListItem Value="I008" />
                                                                <asp:ListItem Value="I010" />
                                                                <asp:ListItem Value="I014" />
                                                                <asp:ListItem Value="I015" />
                                                                <asp:ListItem Value="I021" />
                                                                <asp:ListItem Value="I028" />
                                                                <asp:ListItem Value="I030" />
                                                                <asp:ListItem Value="I035" />
                                                                <asp:ListItem Value="I045" />
                                                                <asp:ListItem Value="M015" />
                                                                <asp:ListItem Value="M030" />
                                                                <asp:ListItem Value="M20" />
                                                                <asp:ListItem Value="M25" />--%>
                                                            </asp:DropDownList>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Incoterms</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:DropDownList ID="ddlIncoterm" runat="server" Width="120px"></asp:DropDownList>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Incoterms 2</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="txtIncoterm2" runat="Server" Text = "" ></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Tax Type</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <asp:DropDownList ID="ddlTaxType" runat="server" Width="120px">
                                                                <asp:ListItem Selected="True">ZQT</asp:ListItem>
                                                                <asp:ListItem>ZQTC</asp:ListItem>
                                                                <asp:ListItem>ZQTI</asp:ListItem>
                                                                <asp:ListItem>ZQTR</asp:ListItem>
                                                            </asp:DropDownList>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <!--
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Condition Type</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <asp:DropDownList ID="ddlConditionType" runat="server" Width="120px">
                                                                <asp:ListItem Selected="True">ZK06</asp:ListItem>
                                                                <asp:ListItem>ZKB6</asp:ListItem>
                                                            </asp:DropDownList>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Condition Rate</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <asp:TextBox ID="txtConditionRate" runat="Server" Text = "0"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        -->
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Valid From</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <%--<asp:TextBox ID="txtValidFrom" runat="Server" Text = "" onclick="javascript:popUpCalendar(this, this, 'yyyy/mm/dd')"></asp:TextBox>--%>
                                                            <asp:TextBox ID="txtValidFrom" runat="Server" Text = "" Enabled="false"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Valid To</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <%--<asp:TextBox ID="txtValidTo" runat="Server" Text = ""  onclick="javascript:popUpCalendar(this, this, 'yyyy/mm/dd')"></asp:TextBox>--%>
                                                            <asp:TextBox ID="txtValidTo" runat="Server" Text = "" Enabled="false"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>

											        <tr runat="server" id="trPricing_Date" class="FormBlank" visible="false">
											            <td class="FormLabel" align="right" style="width:120px"><b>Pricing Date</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <%--<asp:TextBox ID="txtValidTo" runat="Server" Text = ""  onclick="javascript:popUpCalendar(this, this, 'yyyy/mm/dd')"></asp:TextBox>--%>
                                                            <asp:TextBox ID="txtPricing_Date" runat="Server" Text = ""></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>


											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Comment</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="txtComment" runat="Server" TextMode="MultiLine" Height ="100px" Width="250px"></asp:TextBox>
											            </td>
											            <td class="FormLabel" align="right" style="width:20px"></td>
											        </tr>
											    </table>
											</td>
									    </tr>	
	                                </table>
	                                </td>
	                                <td style="width:50px">
	                                </td>
	                                <td>
	                                <table width="250px" border="0" cellpadding="0" cellspacing="0" id="Table6"> 
	                                    <tr>
	                                        <td>
	                                            <table  width="250px" border="0" cellpadding="0" cellspacing="0" class="text" id="Table7"> 
	                                                <tr> 
	                                                    <td style="width:1%" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_left.jpg" width="7" height="23"/></td> 
	                                                    <td style="width:98%; background-color:#A3BFD4" valign="top" ><img alt="" src="../../images/ebiz.aeu.face/bluefolder_top.jpg" width="138" height="3"/></td> 
	                                                    <td style="width:1%" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_right.jpg" width="7" height="23"/></td> 
	                                                </tr> 
	                                                <tr>
	                                                    <td class="euFormCaption" style="height: 19px">Action</td>	
													</tr>
												</table>
	                                            
	                                        </td>
	                                    </tr>
	                                    <tr>
										    <td style="width:250px; height:5px; background-color:#A0BFD3"></td>
										</tr>
										<tr>
										    <td style="height:100px;border:#A4B5BD 1px solid">
											    <table width="100%"  border="0" cellpadding="0" cellspacing="1" style="height:100%; background-color:#F1F2F4">
											        <tr>
											            <td align="center">
											                <asp:Button id="btnSend" runat="server" Text = "Save and send to SAP" Width="200px" TabIndex="2" OnClick="btnSend_Click"/>
											            </td>
											        </tr>
											        <tr>
											            <td align="center">
											                <asp:Button id="btnSave" runat="server" Text = "Save for future edit" Width="200px" OnClick="btnSave_Click" TabIndex="3" /> 
											            </td>
											        </tr>
											        <tr>
											            <td align="center">
											                <asp:Button id="btnClear" runat="server" Text = "Clear" Width="200px" OnClick="btnClear_Click" TabIndex="4" /> 
											            </td>
											        </tr>
											        <tr>
											            <td align="center">
											                <asp:Button id="btnBack" runat="server" Text = "Back to list" Width="200px" OnClick="btnBack_Click" TabIndex="5" /> 
											            </td>
											        </tr>
											    </table>
											</td>
									    </tr>
	                                </table>
	                                </td>
	                                </tr>
	                                </table>
	                                
	                            </td>
	                        </tr>
	                        <tr>
	                            <td style="height:15px"><!--Buffer--> &nbsp;</td>
	                        </tr>
	                        <tr>
	                            <td>
	                                <table width="890px" border="0" cellpadding="0" cellspacing="0" id="Table3" style="vertical-align:top"> 
	                                    <tr> 
	                                        <td> 
	                                            <table width="890px" border="0" cellpadding="0" cellspacing="0" class="text" id="Table4"> 
	                                                <tr> 
	                                                    <td style="width:5px" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_left.jpg" width="7" height="23"/></td> 
	                                                    <td style="width:880px; background-color:#A3BFD4"  valign="top"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_top.jpg" width="138" height="3"/></td> 
	                                                    <td style="width:5px"  rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_right.jpg" width="7" height="23"/></td> 
	                                                </tr> 
	                                                <tr>
	                                                    <td class="euFormCaption" style="height: 19px">Quoation Item</td>	
													</tr>		
												</table>
											</td>
										</tr>
										<tr>
										    <td style="height:5px; width:890px; background-color:#A0BFD3" ></td>
										</tr>
										<tr>
										    <td style="height:50px;border:#A4B5BD 1px solid">
											    <table width="100%" style="height:100%;border:#F1F2F4 1px solid; vertical-align:top" border="0" cellpadding="0" cellspacing="1">
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Item Number</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="txtItemNumber" runat="Server" Text = "" Width ="50px" style="ime-mode:disabled" onkeyup="return ValidateNumber(this,value)"></asp:TextBox>
											            </td>	
											            <td class="FormLabel" align="right" style="width:150px"><b>Material Number</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
                                                            <ajaxToolkit:AutoCompleteExtender ID="ajacAce" runat="server" TargetControlID="txtMaterial"
                                                                ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetSAPPNForABR" MinimumPrefixLength="1" />
                                                            <asp:TextBox ID="txtMaterial" runat="Server" Text = "" Width ="150px"></asp:TextBox>
											            </td>	
											            <td style="width:20px">
<%--											                <input onclick="PickWin('PickPartNo.aspx?Type=QueryPrice&Element=txtMaterial&Quotation=T', this.form);"type="button" value="Pick" />--%>
											            </td>
											            <td class="FormLabel" align="right" style="width:120px"><b>High Level</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="txtHLV_NO" runat="Server" Text = "" Width ="50px" style="ime-mode:disabled" onkeyup="return ValidateNumber(this,value)"></asp:TextBox>
											            </td>
											            
											            <td id="Td1" style="width:20px" runat="server" visible="false"></td>
											            <td id="Td2" class="FormLabel" align="right" style="width:30px" runat="server" visible="false"><b>Price</b></td>
											            <td id="Td3" class="FormLabel" align="left" style="width:5px" runat="server" visible="false"><b>:</b></td>
											            <td id="Td4" class="FormLabel" align="left" runat="server" visible="false" >
											                <asp:TextBox ID="txtPrice" runat="Server" Text = "" Width ="50px"></asp:TextBox>
											            </td>		
											            
											        </tr>
											        <tr class="FormBlank">
											            <td class="FormLabel" align="right" style="width:120px"><b>Qty</b></td>
											            <td class="FormLabel" align="left" style="width:5px"><b>:</b></td>
											            <td class="FormLabel" align="left" >
											                <asp:TextBox ID="txtQty" runat="Server" Text = "" Width ="50px" style="ime-mode:disabled" onkeyup="return ValidateNumber(this,value)"></asp:TextBox>
											            </td>	
											            <td id="Td5" class="FormLabel" align="right" style="width:150px" runat="server" ><b>Condition Type</b></td>
											            <td id="Td6" class="FormLabel" align="left" style="width:5px" runat="server" ><b>:</b></td>
											            <td id="Td7" class="FormLabel" align="left" runat="server" >
											                <asp:DropDownList ID="ddlType" runat="server" Width="120px">
                                                                <asp:ListItem Selected="True">ZK06</asp:ListItem>
                                                                <asp:ListItem>ZKB6</asp:ListItem>
                                                            </asp:DropDownList>
											            </td>	
											            <td></td>
											            <td id="Td8" class="FormLabel" align="right" style="width:120px" runat="server" ><b>Condition Rate</b></td>
											            <td id="Td9" class="FormLabel" align="left" style="width:5px" runat="server" ><b>:</b></td>
											            <td id="Td10" class="FormLabel" align="left" runat="server" >
											                <asp:TextBox ID="txtRate" runat="Server" Text = "" Width ="50px" style="ime-mode:disabled" onkeyup="return ValidateFloat(this,value)"></asp:TextBox>
											            </td>							            
											            <td style="width:55px">
<%--											                <asp:Button ID="btnAdd" runat ="server" Text = "ADD" OnClick="btnAdd_Click" TabIndex="1" />--%>
											                <asp:Button ID="btnAdd" runat ="server" Text = "ADD" OnClick="btnAdd_Click" TabIndex="1" OnClientClick="return checkCompanyID();" />
											            </td>
											            
											        </tr>
											        <tr>
											            <td colspan="14" style="height:10px"><!--Buffer--> &nbsp;

<%--                                                    <asp:UpdatePanel ID="UPpartInfo" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <table runat="server" id="tbProdInfo" visible="false" width="100%">
                                                                <tr>
                                                                    <td>
                                                                        <asp:Panel runat="server" ID="PanelProdInfo" Height="220px" ScrollBars="Vertical"
                                                                            Width="100%">
                                                                            <table>
                                                                                <tr>
                                                                                    <th align="left" style="color: #333333" width="20%">
                                                                                        Part No:
                                                                                    </th>
                                                                                    <td>
                                                                                        <asp:Label ID="lbPartNo" runat="server" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="color: #333333">
                                                                                        Product Status:
                                                                                    </th>
                                                                                    <td>
                                                                                        <asp:Label ID="lbProdStatus" runat="server" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="color: #333333">
                                                                                        PLM Notice:
                                                                                    </th>
                                                                                    <td>
                                                                                        <asp:Label ID="lbPLMNOTE" runat="server" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="color: #333333">
                                                                                        ABCD indicator:
                                                                                    </th>
                                                                                    <td>
                                                                                        <asp:Label ID="lbABCDindicator" runat="server" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="color: #333333">
                                                                                        Inventory:
                                                                                    </th>
                                                                                    <td>
                                                                                        <asp:GridView runat="server" ID="gvAddedPNInventory" AutoGenerateColumns="false"
                                                                                            Width="300">
                                                                                            <Columns>
                                                                                                <asp:TemplateField HeaderText="Available Date" ItemStyle-HorizontalAlign="Center">
                                                                                                    <ItemTemplate>
                                                                                                        <%# TransferLocalTime(Eval("STOCK_DATE"))%>
                                                                                                    </ItemTemplate>
                                                                                                </asp:TemplateField>
                                                                                                <asp:TemplateField HeaderText="Qty" ItemStyle-HorizontalAlign="Center">
                                                                                                    <ItemTemplate>
                                                                                                        <%# GetAvailableQty(Eval("STOCK"))%>
                                                                                                    </ItemTemplate>
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
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>    --%>                                                    
                                                        
                                                        </td>
											        </tr>
											        <tr>
											            <td colspan="14"  style="height:100px" valign="Top">
											                <asp:GridView ID="gvQuoList" runat="server" AutoGenerateColumns ="false" CellPadding ="4" CssClass="text"
											                    ForeColor ="#333333" GridLines ="none"  OnRowDataBound="gvQuoList_RowDataBound" OnPageIndexChanging="gvQuoList_PageIndexChanging" OnRowCancelingEdit="gvQuoList_RowCancelingEdit" OnRowEditing="gvQuoList_RowEditing" OnRowUpdating="gvQuoList_RowUpdating" OnRowDeleting="gvQuoList_RowDeleting">
											                    <FooterStyle BackColor="#507CD1" Font-Bold ="true" ForeColor="white" />
											                    <Columns>
											                        <asp:BoundField DataField = "SEQ" HeaderText = "SEQ" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="10px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "ITEM_NO" HeaderText = "NO" >
											                            <ItemStyle HorizontalAlign="left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="20px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "MATERIAL_NO" HeaderText = "Material" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="150px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "HLV_NO" HeaderText = "High Level" >
											                            <ItemStyle HorizontalAlign="left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="20px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "MATERIAL_DESC" HeaderText = "Description" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="350px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "QTY" HeaderText = "QTY" >
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "PRICE" HeaderText = "PRICE" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller"  />
											                        </asp:BoundField>
											                        <asp:BoundField HeaderText = "AMOUNT" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "PRICE_TYPE" HeaderText = "PRICE_TYPE" ReadOnly ="true" >
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "CONDITION_TYPE" HeaderText = "Condition Type">
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "CONDITION_RATE" HeaderText = "Condition Rate">
											                            <ItemStyle HorizontalAlign="right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="center" Width ="50px" Font-Size="smaller" />
											                        </asp:BoundField>
											                        <asp:CommandField ButtonType ="image" CancelImageUrl="~/Images/12-em-cross.png" EditImageUrl="~/Images/16-em-pencil.png"
											                            HeaderText="Action" ShowEditButton="True" ShowDeleteButton="true" DeleteImageUrl="~/Images/16-circle-red-remove.png" UpdateImageUrl="~/Images/12-em-check.png">
											                            <HeaderStyle HorizontalAlign="Center" Font-Size="smaller"/>
                                                                        <ItemStyle HorizontalAlign="Center" />
											                        </asp:CommandField>     
											                    </Columns>
											                    <RowStyle BackColor ="#EFF3FB" />
											                    <EditRowStyle BackColor="#A0D2FF" />
											                    <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
											                    <PagerStyle BackColor="#2461BF" ForeColor="white" HorizontalAlign="center" />
											                    <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor ="white"  />
											                    <AlternatingRowStyle BackColor ="white" />
											                </asp:GridView>
											            </td>
											            
											        </tr>
											        <tr>
											            <td colspan="18">
											                <table>
											                    <tr>    
											                        <td style="width:890px">
											                        </td>
											                        <td style="width:80px">
											                            <asp:Label ID="lblAmount" runat="Server" Text = "Total amount" Width ="80px"></asp:Label>
											                        </td>
											                        <td style="width:100px">
											                            <asp:TextBox id="txtAmount" runat ="server" Text="0" Width="90px"></asp:TextBox>
											                        </td>
											                    </tr>
											                </table>
											            </td>
											        </tr>
											        <tr id = "trErrMsg" visible="true" style="height:20px; width:290px" runat="server">
											            <td colspan="18"  valign="Top" id = "tdErrMsg" runat="server" style="color:Red"></td>
											        </tr>
											        
											    </table>
											</td>
									    </tr>	
									</table>
	                            </td>
	                        </tr>
	                    </table>
					</td>
					<td style="width:20px"></td>
				</tr>
	        </table>
		</td>
	</tr>
	
	</table>

    <%--<div id="divMyContactList" style="overflow:auto; display:none" title="My Contact List">
        <table width="100%">
            <tr>
                <td>
                    <input type="text" id="txtSearchListKey" onkeyup="setTimeout('getMyList(null)',350);" />                    
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView ID="GridView1" runat="server">
                    </asp:GridView>
                </td>
            </tr>
             
        </table>
    </div>--%>

    <script type="text/javascript">
        function PickCompanyID(xElement, xType, xCompanyID, xOrgID) {
            var Url = "./PickCompanyID.aspx?Element=" + xElement + "&Type=" + xType + "&CompanyID=" + document.getElementById("<%=company_id.ClientID%>").value + "&orgID=" + xOrgID;
            var iTop = (window.screen.availHeight - 30 - 570) / 2;
            var iLeft = (window.screen.availWidth - 10 - 480) / 2;
            window.open(Url, "pop", 'height=570,width=480,scrollbars=yes,top='+iTop+',left='+iLeft+'');
        }

        function PickWin(Url) {
            // var aa = document.form1.elements("txtMaterial")
            var aa = document.getElementById("txtMaterial")
            var part_no = aa.value
            Url = Url + "&PartNo=" + part_no
            window.open(Url, "pop", "height=570,width=520,scrollbars=yes");
        }	
</script>

</asp:Content>

