<%@ Page Title="MyAdvantech - Literature Request" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim l_strMailBody As String
    Sub GetUserInfo(ByVal StrUserID As String)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                                                    " select top 1 a.EMAIL_ADDRESS as email_addr, IsNull(a.FirstName,'') as FirstName, " + _
                                                    " IsNull(a.LastName,'') as LastName, IsNull(a.JOB_TITLE,'') as job_title, a.ACCOUNT as company_name, " + _
                                                    " IsNull(b.ADDRESS,'') as ADDRESS, IsNull(b.CITY,'') as CITY, IsNull(b.ZIPCODE,'') as zip, " + _
                                                    " IsNull(a.WorkPhone,'') as tel_no, IsNull(a.FaxNumber,'') as fax_no, IsNull(a.COUNTRY,'') as COUNTRY " + _
                                                    " from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID " + _
                                                    " where a.EMAIL_ADDRESS='" + StrUserID + "' and a.ACTIVE_FLAG='Y' ", _
                                                    Session("user_id").ToString().Replace("'", "''")))
        If dt.Rows.Count = 1 Then
            Dim p As DataRow = dt.Rows(0)
            tbxstrEmail.Text = p.Item("email_addr") : tbxstrFirstName.Text = p.Item("FirstName")
            tbxstrLastName.Text = p.Item("LastName") : tbxstrJobTitle.Text = p.Item("job_title")
            tbxstrCompany.Text = p.Item("company_name") : tbxstrAddress.Text = p.Item("address")
            tbxstrCity.Text = p.Item("city") : tbxstrZip.Text = p.Item("zip")
            tbxstrPhone.Text = p.Item("tel_no") : tbxstrFax.Text = p.Item("fax_no")
            DropDownList1.SelectedValue = p.Item("COUNTRY")
        End If
        'Dim ws As New SSO.MembershipWebservice
        'Dim p As SSO.SSOUSER = ws.getProfile(StrUserID.Trim(), "my")
        
        'If p IsNot Nothing Then
        '         tbxstrEmail.Text = p.email_addr 

        '         tbxstrFirstName.Text = p.first_name
        '         tbxstrLastName.Text = p.last_name

        '         tbxstrJobTitle.Text = p.job_title
        '         tbxstrCompany.Text = p.company_name

        '         tbxstrAddress.Text = p.address
        '         tbxstrCity.Text = p.city

        '         tbxstrZip.Text = p.zip
        '         tbxstrPhone.Text = p.tel_no
               
        '         tbxstrFax.Text = p.fax_no
        '         'DropDownList1.SelectedValue = oRow.Item("COUNTRY")
           
        '     End If

    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Session("RBU") = "AAC"
        'Response.Write(Session("RBU"))
        If Not IsPostBack And Session("user_id") IsNot Nothing Then
            GetUserInfo(Session("user_id"))
        End If
        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
     
        Dim dt As DataTable
        dt = dbUtil.dbGetDataTable("MY", GetSQL())
        gv1.DataSource = dt
        If Not Page.IsPostBack Then
            gv1.DataBind()
        End If
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''
        If Request("Send") = "YES" Then
            FormPost()
        End If
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    End Sub
    Function FormPost() As Integer
        '----------------------------
        'Get Max ID and Create Next ID 
        '----------------------------
        Dim oRsMaxRequest As String = "", strIDPrefix As String = "", strRequest_ID_NBR As String = "", intRequest_ID_NBR As String = "", strRequest_ID As String = "", strSQL As String = ""
        Dim xDT As DataTable
        xDT = dbUtil.dbGetDataTable("MY", "select isnull(max(request_id),'') as MaxRequest_id from Misc_lit_req_master")
        If xDT.Rows.Count >= 1 Then
            oRsMaxRequest = xDT.Rows(0).Item("MaxRequest_id")
        End If

        strIDPrefix = "M04"
        If oRsMaxRequest <> "" Then

            If Len(oRsMaxRequest(0)) > 3 Then
                strRequest_ID_NBR = Right(oRsMaxRequest(0), Len(oRsMaxRequest(0)) - 3)
                If IsNumeric(strRequest_ID_NBR) Then
                    intRequest_ID_NBR = Int(strRequest_ID_NBR) + 1
                    strRequest_ID_NBR = Replace(FormatNumber(intRequest_ID_NBR, 0), ",", "")

                    Do While Len(strRequest_ID_NBR) < 5
                        strRequest_ID_NBR = "0" & strRequest_ID_NBR
                    Loop
                End If
            Else
                strRequest_ID_NBR = "00001"
            End If
        Else
            strRequest_ID_NBR = "00001"
        End If

        '-------------------------------
        'Make sure request ID is unique
        '--------------------------------
        strRequest_ID = strIDPrefix & strRequest_ID_NBR
        xDT = dbUtil.dbGetDataTable("MY", "select * from Misc_lit_req_master where request_Id = '" & strRequest_ID & "'")
        Do While Not xDT.Rows.Count = 0
            intRequest_ID_NBR = Int(strRequest_ID_NBR) + 1
            strRequest_ID_NBR = Replace(FormatNumber(intRequest_ID_NBR, 0), ",", "")
            Do While Len(strRequest_ID_NBR) < 5
                strRequest_ID_NBR = "0" & strRequest_ID_NBR
            Loop
            strRequest_ID = strIDPrefix & strRequest_ID_NBR
            xDT = dbUtil.dbGetDataTable("MY", "select * from Misc_lit_req_master where request_Id = '" & strRequest_ID & "'")
        Loop

        '----------------------------------
        'ID Creating end
        '----------------------------------


        Dim retVal(), RequestQTY As String
        Dim iLineN, icount As Integer
        iLineN = 0
        For Each oDataGridItem As GridViewRow In gv1.Rows

            If Request("QTY$$$" & oDataGridItem.Cells(4).Text) <> "" Then
                RequestQTY = Request("QTY$$$" & oDataGridItem.Cells(4).Text)
                iLineN = iLineN + 1
                strSQL = " insert into Misc_lit_req_detail ( Request_ID , Ln , Catalog_ID , Request_Qty , Approved_Qty , Approved_Code ) " & _
                  " values ( '" & strRequest_ID & "' , " & _
                      "" & iLineN & " , " & _
                      "N'" & oDataGridItem.Cells(4).Text & "' , " & _
                      "" & RequestQTY & " , " & _
                      "" & RequestQTY & " , " & _
                      "'REQUESTED' )"
                'AdvEBiz35.Utils.DBUtils.SQLUtils.ExecuteScalar(ConfigurationManager.ConnectionStrings("MY").ConnectionString, CommandType.Text, strSQL)
                dbUtil.dbExecuteNoQuery("MY", strSQL)
                If Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    Response.Write("<br>")
                    Response.Write(strSQL)
                    Response.Write("<br>")
                End If
            End If
        Next

      

        Dim strOfferCode, strOrderDetail, strFirstName, strLastName, strEmail, strJobTitle, strCompany, strAddress, strCity, strState, strZip, strPhone, strExt, strFax, strShippment, strHearFrom, strOther As String

        'strRequest_ID  
        strOrderDetail = ""
        strOfferCode = "Catalog_Req"
        strFirstName = tbxstrFirstName.Text
        strLastName = tbxstrLastName.Text
        strEmail = tbxstrEmail.Text
        strJobTitle = tbxstrJobTitle.Text
        strCompany = tbxstrCompany.Text
        strAddress = tbxstrAddress.Text
        strCity = tbxstrCity.Text
        strState = DropDownList1.SelectedValue
        strZip = tbxstrZip.Text
        strPhone = tbxstrPhone.Text
        strExt = tbxstrExt.Text
        strFax = tbxstrFax.Text
        strShippment = "Expedite Code:" & DDLExpediteCode.SelectedValue & "," & "Acct Nbr:" & Request("AcctNumber")
        'strHearFrom = ASP2SQL(Request("strHearFrom"))
        strOther = Request("strOther")
       
        strSQL = "insert into Misc_lit_req_master (COMPANY, " + _
           " OFFER_CODE, " + _
           " [USER_TYPE] , " + _
           " [FIRST_NAME] , " + _
           " [LAST_NAME] , " + _
           " [EMAIL_ADDR] , " + _
           " [ADDRESS] , " + _
           " [CITY] 	, " + _
           " [STATE] , " + _
           " [ZIP] 	, " + _
           " [TEL_NO] , " + _
           " [TEL_EXT] , " + _
           " [FAX_NO]  , " + _
           " [JOB_TITLE] , " + _
           " [REF_1] , " + _
           " [REF_2] , " + _
           " [REF_3] , " + _
           " [REF_4] , " + _
           " [CREATED_BY] 	 , " + _
           " [CREATED_DATE] , [REQUEST_ID] , [Approved_Code] ) VALUES ( " & _
          " @COMPANY, " + _
           " @OFFER_CODE, " + _
           " @USER_TYPE , " + _
           " @FIRST_NAME , " + _
           " @LAST_NAME , " + _
           " @EMAIL_ADDR , " + _
           " @ADDRESS , " + _
           " @CITY 	, " + _
           " @STATE , " + _
           " @ZIP 	, " + _
           " @TEL_NO , " + _
           " @TEL_EXT , " + _
           " @FAX_NO  , " + _
           " @JOB_TITLE , " + _
           " @REF_1 , " + _
           " @REF_2 , " + _
           " @REF_3 , " + _
           " @REF_4 , " + _
           " @CREATED_BY 	 , " + _
           " @CREATED_DATE , @REQUEST_ID , @Approved_Code )"
        ' Dim I As Integer = dbUtil.dbExecuteNoQuery("MY", strSQL)
        Dim P() As SqlClient.SqlParameter = {New SqlClient.SqlParameter("@COMPANY", strCompany.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@OFFER_CODE", strOfferCode),
                                             New SqlClient.SqlParameter("@USER_TYPE", "NEW"),
                                             New SqlClient.SqlParameter("@FIRST_NAME", strFirstName.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@LAST_NAME", strLastName.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@EMAIL_ADDR", strEmail.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@ADDRESS", strAddress.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@CITY", strCity.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@STATE", strState.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@ZIP", strZip.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@TEL_NO", strPhone.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@TEL_EXT", strExt.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@FAX_NO", strFax.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@JOB_TITLE", strJobTitle.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@REF_1", strOrderDetail.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@REF_2", strShippment.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@REF_3", strOther.Replace("'", "''")),
                                             New SqlClient.SqlParameter("@REF_4", strOfferCode),
                                             New SqlClient.SqlParameter("@CREATED_BY", "System"),
                                             New SqlClient.SqlParameter("@CREATED_DATE", Now()),
                                             New SqlClient.SqlParameter("@REQUEST_ID", strRequest_ID),
                                             New SqlClient.SqlParameter("@Approved_Code", "REQUESTED")}
        Dim i As Integer = SAPDAL.dbUtil2.ExecuteNonQuery("MY", CommandType.Text, strSQL, P)
        If I > 0 Then Util.JSAlert(Me.Page, "Catalog Request was submitted")
        If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            'Response.Write("<br>/")
            'Response.Write(strSQL)
            'Response.Write("<br>/")
        End If

        l_strMailBody = "<style type=""text/css"">"
        l_strMailBody = l_strMailBody & ".text {FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #000000; FONT-FAMILY: ""Arial"", ""Helvetica"", ""sans-serif""}"

        l_strMailBody = l_strMailBody & "</style>"


        l_strMailBody = "<span class='text'> <table width='80%' border='1' align='center'><tr><td align='right'>Catalog Request:</td><td> " & strRequest_ID & "</td></tr>" & _
                            " <tr><td align='right'>Email:</td><td> " & strEmail & " </td></tr>" & _
                            " <tr><td align='right'>FirstName:</td><td> " & strFirstName & " </td></tr>" & _
                            " <tr><td align='right'>LastName:</td><td>" & strLastName & " </td></tr>" & _
                            " <tr><td align='right'>JobTitle:</td><td>" & strJobTitle & " </td></tr>" & _
                            " <tr><td align='right'>Company:</td><td>" & strCompany & " </td></tr>" & _
                            " <tr><td align='right'>Address:</td><td>" & strAddress & "</td></tr>" & _
                            "<tr><td align='right'> City:</td><td>" & strCity & " </td></tr>" & _
                            " <tr><td align='right'>State:</td><td>" & strState & "</td></tr>" & _
                            "<tr><td align='right'> Zip	:</td><td>" & strZip & " </td></tr>" & _
                            " <tr><td align='right'>Phone:</td><td>" & strPhone & " </td></tr>" & _
                            " <tr><td align='right'>Ext	:</td><td>" & strExt & " </td></tr>" & _
                            " <tr><td align='right'>Catalog:</td><td>" & strOrderDetail & " </td></tr>" & _
              " <tr><td align='right'>Shippment :</td><td>" & strShippment & " </td></tr>" & _
                            " <tr><td align='right'>Comment :</td><td>  " & strOther & "</td></tr>"

        l_strMailBody = l_strMailBody & "</span>"
        'Util.SendEmail("tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw,nada.liu@advantech.com.cn,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", _
        '   "[B2B Literature Request]", l_strMailBody, False, "", "")
        'Response.Redirect("thankyou.htm")
        If Session("user_id") <> "ming.zhao@advantech.com.cn" Then
            SendEmail(l_strMailBody)
        End If
        Return 1
    End Function
    Public Shared Function SendEmail(ByVal EmailBODY As String) As Integer
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""    
        '
        Dim strStyle As String = ""
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 10pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        
        FROM_Email = HttpContext.Current.Session("USER_ID")
        TO_Email = "Adam.Sturm@advantech.com"
        'TO_Email = "Ming.Zhao@advantech.com.cn"
        CC_Email = "eBusiness.AEU@advantech.eu"
        ' BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "MyAdvantech Literature Request"
        '
        MailBody = MailBody & "<html><body><center>"
        MailBody = MailBody & strStyle & EmailBODY
        'MailBody = MailBody & "<table width='95%' border='0' align='center'><tr><td>Dear Customer</td></tr>"
        'MailBody = MailBody & "<tr><td><br />You have been assigned the permission to view all the sales leads assigned from Advantech to your company."
        'MailBody = MailBody & "<br />Please go to MyAdvantech <a href='http://my.advantech.eu/my/MyLeads.aspx'>My Sales Leads</a> to have a look."
        'MailBody = MailBody & "<br />Thank you.</td></tr>"
        'MailBody = MailBody & String.Format("<tr><td><BR>Best Regards,<br />{0}</td></tr></table>", HttpContext.Current.Session("USER_ID"))        
        MailBody = MailBody & "</center></body></html>"   
        Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Return 1
    End Function
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gv1.RowDataBound
        Dim oType As ListItemType = e.Row.RowType
        If (oType <> ListItemType.Header And oType <> ListItemType.Footer) Then
            If e.Row.Cells(1).Text.ToUpper() <> "" Then             
                e.Row.Cells(1).Text = "<table><tr><td width=""1"" height=""1""><img  src='../Includes/ShowFile.aspx?File_ID=" & e.Row.Cells(1).Text & "' width=""100""  /></td></tr></table>"
            Else
                e.Row.Cells(1).Text = ""
            End If
            If e.Row.Cells(6).Text.ToUpper() <> "" Then
                e.Row.Cells(6).Text = "<a target='_blank' href='../includes/showfile.aspx?File_ID=" & e.Row.Cells(6).Text & "'>" & "Link" & "</a>"
            Else
                e.Row.Cells(6).Text = "-"
            End If
            If e.Row.Cells(9).Text.Trim.ToUpper() = "NOT AVAILABLE" Then
                e.Row.Cells(10).Text = "<input type='text' name='QTY$$$" & e.Row.Cells(4).Text & "' style=""display:none;"" />"
            Else
                e.Row.Cells(10).Text = "<input type='text' name='QTY$$$" & e.Row.Cells(4).Text & "' size=3 style=""text-align: center;"" />PCS"
            End If
            'Response.Write(e.Row.Cells(9).Text.Trim.ToUpper())
        End If
    End Sub

    Protected Sub BTSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetSQL())
        If dt.Rows.Count > 0 Then
            gv1.DataSource = dt
            gv1.DataBind()
        End If
    End Sub
    Public Function GetSQL() As String
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = "select 		" & _
       " [Catalog_Image] , 		" & _
       " [Catalog_Name] , 		" & _
       " [Catalog_Group]  , 	" & _
       " [Catalog_ID]  , 		" & _
       " [Catalog_DESC]  , 		" & _
       " [Catalog_PDF]  , " & _
       " [Catalog_PAGES]  , " & _
       " [Catalog_PerCase]  , " & _
       " [Catalog_Status] , '' as Qty " & _
       " from Misc_Catalog_listing where  Bulk_request = 'YES'  AND (IsDEL <> 1 OR ISDEL IS NULL) "
        If TBName.Text <> "" Then
            l_strSQLCmd += String.Format(" AND  ( Catalog_Name LIKE '%{0}%'  or Catalog_Desc LIKE '%{0}%' )", TBName.Text.Trim.Replace("'", "''"))
        End If           
        l_strSQLCmd += " order by [Catalog_Seq] "           
        Return l_strSQLCmd
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
 <SCRIPT language="JavaScript">

     function ValidEmail(PassedValue) {

         email = PassedValue;
         if ((email.charAt(0) == "h") &&
        (email.charAt(1) == "t") &&
        (email.charAt(2) == "t") &&
        (email.charAt(3) == "p") &&
        (email.charAt(4) == ":") &&
        (email.charAt(5) == "/") &&
        (email.charAt(6) == "/")) {
             email = "";
             for (i = 7; i < PassedValue.length; i++)
                 email = email + PassedValue.charAt(i);
         }
         invalidChars = " /:,;";
         if (email.length == 0) {
             return false;
         }
         for (i = 0; i < invalidChars.length; i++) {
             badChar = invalidChars.charAt(i);
             if (email.indexOf(badChar, 0) != -1) {
                 return false;
             }
         }
         atPos = email.indexOf("@", 0);
         if ((atPos == -1) || (atPos == 0)) {
             return false;
         }
         if (email.indexOf("@", atPos + 1) != -1) {
             return false;
         }
         periodPos = email.indexOf(".", atPos);
         if (periodPos == -1) {
             return false;
         }
         if (periodPos - atPos <= 1)
             return false;
         if (email.length - periodPos <= 1)
             return false;
         return true;
     }


     function isDigit(PassedValue) {
         if ((PassedValue >= "0") && (PassedValue <= "9"))
             return true;
         return false;
     }

     function Trim(PassedValue) {
         for (i = 0; i < PassedValue.length; i++) {
             if (PassedValue.charAt(i) != " ") {
                 x = i;
                 break;
             }
         }
         z = PassedValue.length - 1;
         y = -1;
         while (z >= 0) {
             if (PassedValue.charAt(z) != " ") {
                 y = z;
                 break;
             }
             z = z - 1
         }
         ans = ""
         if (y >= 0) {
             for (i = x; i <= y; i++) {
                 ans = ans + PassedValue.charAt(i);
             }
         }
         return ans
     }



     function isChar(passedVal) {
         if (((passedVal >= "A") && (passedVal <= "Z")) || ((passedVal >= "a") && (passedVal <= "z")))
             return true;
         else
             return false;
     }



     function validate() {
         //Obj = document.MyForm1.continue1
         //if (Obj.value == "No")
         //   return true


         strFlag = "TRUE";



         //    Obj = document.RegisterForm.strCompany
         Obj = document.getElementById("ctl00__main_tbxstrCompany")

         if (Trim(Obj.value) == "") {
             alert("Company name is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }



         // Obj = document.RegisterForm.strAddress
         Obj = document.getElementById("ctl00__main_tbxstrAddress")
         if (Trim(Obj.value) == "") {
             alert("Address is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         // Obj = document.RegisterForm.strCity
         Obj = document.getElementById("ctl00__main_tbxstrCity")
         if (Trim(Obj.value) == "") {
             alert("City is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         // Obj = document.RegisterForm.strState
         Obj = document.getElementById("ctl00__main_DropDownList1")
         if (Trim(Obj.value) == "") {
             alert("State is required.");
             Obj.focus();
             strFlag = "FALSE";
             return false;
         }

         //Obj = document.RegisterForm.strZip
         Obj = document.getElementById("ctl00__main_tbxstrZip")
         if (Trim(Obj.value) == "") {
             alert("Zip code is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }


         //Obj = document.RegisterForm.strPhone
         Obj = document.getElementById("ctl00__main_tbxstrPhone")
         if (Trim(Obj.value) == "") {
             alert("Phone number is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }




         // Obj = document.RegisterForm.strEmail
         Obj = document.getElementById("ctl00__main_tbxstrEmail")
         if (Trim(Obj.value) == "") {
             alert("E-Mail address is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }




         if (ValidEmail(Trim(Obj.value)) == false) {
             alert("Invalid e-mail address.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         // Obj = document.RegisterForm.strProduct
         //if ( Trim(Obj.value) == "" )
         //{
         //	   alert("Product ID is required.");
         //	   Obj.focus();
         //	   Obj.select();
         //	   strFlag = "FALSE";
         //	   return false;
         //}	


         //Obj = document.RegisterForm.strFirstName
         Obj = document.getElementById("ctl00__main_tbxstrFirstName")
         if (Trim(Obj.value) == "") {
             alert("Contact First Name is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         //Obj = document.RegisterForm.strLastName
         Obj = document.getElementById("ctl00__main_tbxstrLastName")
         if (Trim(Obj.value) == "") {
             alert("Contact Last Name is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         //Obj = document.RegisterForm.strJobTitle
         Obj = document.getElementById("ctl00__main_tbxstrJobTitle")
         if (Trim(Obj.value) == "") {
             alert("Job Title is required.");
             Obj.focus();
             Obj.select();
             strFlag = "FALSE";
             return false;
         }

         //Obj = document.RegisterForm.strHearFrom
         //alert("HearAbout= " + Trim(Obj.value))
         //if ( Obj.selectedIndex == 0 )
         //{
         //alert("This is a required field.");
         //Obj.focus();
         //strFlag = "FALSE";
         //return false;
         //}

         if (strFlag != "FALSE") {
             var o = document.getElementById("aspnetForm");
             o.action = "litReqLarge1.aspx?Send=YES";
             o.submit();
             //	document.form1.action="litReqLarge1.aspx?Send=YES";
             //	document.form1.submit();
             //document.location.href = 'litReqLarge1.aspx?Send=YES';
         }

     }
</script>
    	
    	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" id="Table2">
			<tr>
				<td colspan=3>
					<!--Header-->
					<!--include virtual='/utility/header_inc.asp' -->
				</td>
			</tr>
			
    	<tr>
				<td width="15px"></td>
				<td>
					<table cellpadding=0 cellspacing=0 width="100%">
					
                     <tr bordercolor="#999999" bgcolor="#FFFFFF"> 
                        <td height="40" >
                            <font face="Arial, Helvetica, sans-serif" color="#003366"  size="4"><br>
                            <img src="http://www.advantechdirect.com/60DayTrial/point.gif" width="25" height="15"/>
                            <b>Distributor/Representative Literature Request Form</b></font> <hr/>
                        </td>
                     </tr>						
                        <tr>
							<td height="15">
                                Keywords:
                                <asp:TextBox ID="TBName" runat="server"></asp:TextBox>
                                <asp:Button ID="BTSearch" runat="server" Text="Search" OnClick="BTSearch_Click" />
                             </td>
						</tr>
                        <tr><td><asp:Label runat="server" ID="xCount" Text="0" Visible="false" ></asp:Label></td></tr>		
						<tr valign="top">
							<td align="center">

                                    <sgv:SmartGridView runat="server" ID="gv1" ShowWhenEmpty="true" AutoGenerateColumns="false" AllowSorting="true" Width="100%">
								                <Columns>
								                    <asp:TemplateField ItemStyle-Width="25px" ItemStyle-HorizontalAlign="Center">
                                                        <headertemplate>
                                                            No.
                                                        </headertemplate>
                                                        <itemtemplate>
                                                            <%# Container.DataItemIndex + 1 %>
                                                        </itemtemplate>
                                                    </asp:TemplateField>
								                   <asp:BoundField HeaderText="Image" DataField="Catalog_Image" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Name" DataField="Catalog_Name" ReadOnly="true"  ItemStyle-HorizontalAlign="Left"/>
								                    <asp:BoundField HeaderText="Catalog Group" DataField="Catalog_Group" ReadOnly="true" />
								                    <asp:BoundField HeaderText="Catalog ID" DataField="Catalog_ID" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Description" DataField="Catalog_DESC" ReadOnly="true" ItemStyle-Width="210px"  ItemStyle-HorizontalAlign="Left"  />
								                    <asp:BoundField HeaderText=" PDF " DataField="Catalog_PDF" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Pages" DataField="Catalog_PAGES" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />
								                    <asp:BoundField HeaderText="PerCase" DataField="Catalog_PerCase" ReadOnly="true"   />
								                    <asp:BoundField HeaderText=" Avaliability " DataField="Catalog_Status" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Order Qty" DataField="Catalog_Name"  />                                                    								                 								                    
								                </Columns>
								                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
	                                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
	                                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
	                                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
	                                            <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
	                                            <AlternatingRowStyle BackColor="red" ForeColor="#284775" />                              
                                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
								            </sgv:SmartGridView>
                                    </td>
						</tr>
					</table>
				</td>
				<td width="15px"></td>
			</tr>
			<tr>
				<td height="50"></td>
			</tr>
			
		</table>
	<table><tr><td style="width: 15px">
	
	</td>
	<td width="700px"  >
	<div class="theborad" >
	<table cellpadding="0" cellspacing="0"  width="100%"  ID="Table1" align="center">
	<tr><td height=5></td></tr>
	  <tr>
	    <td colspan=4 align="center" bgColor="silver">
	    <font face="Arial, Helvetica, sans-serif" size="4"><strong>Shipping information</strong></font>
	    </td>
	  </tr>
	  <tr><td colspan=4 >&nbsp;</td></tr>
	  
	  <tr>
	  <td width="15px"></td>
	     <td >
	        <table cellSpacing="0" cellPadding="0"  border="0">
	        <tr>
	     <td colspan="2" >
	        <font face="Arial, Helvetica, sans-serif" size="2">
	        <font size="3" face="Arial, Helvetica, sans-serif"><b>
	        <font face="Arial, Helvetica, sans-serif" size="2" >
	        <a href="%5C" target="_blank"></a></font></b></font>
	        <font size=2 face=arial><strong>Please   provide the following information:</strong>
	        <font size="1"> <br> </font>
	        <font size="3" face="Arial, Helvetica, sans-serif"><b>
	        <font face="Arial, Helvetica, sans-serif" size="2" >
	        <a href="%5C" target="_blank"></a></font></b></font>
	        <font color="#FF0000">Note: We cannot ship to PO Box addresses</font></font></font>
	     </td>
	  </tr>
	  <tr>
	     <td colspan="2" >
	     <font face="Arial, Helvetica, sans-serif" size="2"><font size=2 face=arial><font size="1">All  fields marked with a <font color="#ff0000">*</font> must be completed  in full.</font></font></font> 
	     </td>
	  </tr>
	           <tr>
	              <td width="21%">
	              <FONT face="Arial, Helvetica, sans-serif" size="2">First Name:*  </FONT>
	              </td>
	              <td width="79%">
	              <FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrFirstName" runat="server"></asp:TextBox> </FONT>
	              </td>
	           </tr>
	           	<TR> <TD style="height: 14px">&nbsp;<TD style="height: 14px"> </TR>
	           	<TR>
			        <TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Last Name:* </FONT></TD>
			
			        <TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrLastName" runat="server"></asp:TextBox> </FONT></TD>
		        </TR>
		        <TR> <TD>&nbsp;</TD> </TR>
		        <TR>
			        <TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Email:* </FONT></TD>
			
			       <TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrEmail" runat="server" Width="200px"></asp:TextBox> </FONT></TD>
		       </TR>
		       <TR> <TD>&nbsp;</TD> </TR>
		       <TR>
			         <TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Job Title:* 	</FONT></TD>
			
			          <TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrJobTitle" runat="server"></asp:TextBox></FONT></TD>
		       </TR>
		<TR> <TD>&nbsp;<TD> </TR>
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Company:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrCompany" runat="server" Width="250px"></asp:TextBox>
			</FONT></TD>
		</TR>
		
		<TR> <TD>&nbsp;<TD> </TR>
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Address:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrAddress" runat="server" Width="300px"></asp:TextBox>
			</FONT></TD>
		</TR>
		
		<TR> <TD>&nbsp;<TD> </TR>
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">City:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrCity" runat="server"></asp:TextBox>
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">State/Province:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2">
			
                <asp:DropDownList ID="DropDownList1" runat="server">
                <asp:ListItem Text="-- Select Below --" Value=""></asp:ListItem>
                <asp:ListItem Text="Alabama" Value="AL"></asp:ListItem>
                <asp:ListItem Text="Alaska" Value="AK"></asp:ListItem>
                <asp:ListItem Text="Arizona" Value="AZ"></asp:ListItem>
                <asp:ListItem Text="Arkansas" Value="AR"></asp:ListItem>
                <asp:ListItem Text="California" Value="CA"></asp:ListItem>
                <asp:ListItem Text="Colorado" Value="CO"></asp:ListItem>
                <asp:ListItem Text="Connecticut" Value="CT"></asp:ListItem>
                <asp:ListItem Text="D.C." Value="DC"></asp:ListItem>
                <asp:ListItem Text="Delaware" Value="DE"></asp:ListItem>
                <asp:ListItem Text="Florida" Value="FL"></asp:ListItem>
                <asp:ListItem Text="Georgia" Value="GA"></asp:ListItem>
                <asp:ListItem Text="Hawaii" Value="HI"></asp:ListItem>
                <asp:ListItem Text="Idaho" Value="ID"></asp:ListItem>
                <asp:ListItem Text="Illinois" Value="IL"></asp:ListItem>
                <asp:ListItem Text="Indiana" Value="IN"></asp:ListItem>
                <asp:ListItem Text="Iowa" Value="IA"></asp:ListItem>
                <asp:ListItem Text="Kansas" Value="KS"></asp:ListItem>
                <asp:ListItem Text="Kentucky" Value="KY"></asp:ListItem>
                <asp:ListItem Text="Louisiana" Value="LA"></asp:ListItem>
                <asp:ListItem Text="Maine" Value="ME"></asp:ListItem>
                <asp:ListItem Text="Maryland" Value="MD"></asp:ListItem>
                <asp:ListItem Text="Massachusetts" Value="MA"></asp:ListItem>
                <asp:ListItem Text="Michigan" Value="MI"></asp:ListItem>
                <asp:ListItem Text="Minnesota" Value="MN"></asp:ListItem>
                <asp:ListItem Text="Mississippi" Value="MS"></asp:ListItem>
                <asp:ListItem Text="Missouri" Value="MO"></asp:ListItem>
                <asp:ListItem Text="Montana" Value="MT"></asp:ListItem>
                <asp:ListItem Text="Nebraska" Value="NE"></asp:ListItem>
                <asp:ListItem Text="Nevada" Value="NV"></asp:ListItem>
                <asp:ListItem Text="New Hampshire" Value="NH"></asp:ListItem>
                <asp:ListItem Text="New Jersey" Value="NJ"></asp:ListItem>
                <asp:ListItem Text="New Mexico" Value="NM"></asp:ListItem>
                <asp:ListItem Text="New York" Value="NY"></asp:ListItem>
                <asp:ListItem Text="North Carolina" Value="NC"></asp:ListItem>
                <asp:ListItem Text="North Dakota" Value="ND"></asp:ListItem>
                <asp:ListItem Text="Ohio" Value="OH"></asp:ListItem>
                <asp:ListItem Text="Oklahoma" Value="OK"></asp:ListItem>
                <asp:ListItem Text="Oregon" Value="OR"></asp:ListItem>
                <asp:ListItem Text="Pennsylvania" Value="PA"></asp:ListItem>
                <asp:ListItem Text="Rhode Island" Value="RI"></asp:ListItem>
                <asp:ListItem Text="South Carolina" Value="SC"></asp:ListItem>
                <asp:ListItem Text="South Dakota" Value="SD"></asp:ListItem>
                <asp:ListItem Text="Tennessee" Value="TN"></asp:ListItem>
                <asp:ListItem Text="Texas" Value="TX"></asp:ListItem>
                <asp:ListItem Text="Utah" Value="UT"></asp:ListItem>
                <asp:ListItem Text="Vermont" Value="VT"></asp:ListItem>
                <asp:ListItem Text="Virginia" Value="VA"></asp:ListItem>
                <asp:ListItem Text="Washington" Value="WA"></asp:ListItem>
                <asp:ListItem Text="West Virginia" Value="WV"></asp:ListItem>
                <asp:ListItem Text="Wisconsin" Value="WI"></asp:ListItem>
                <asp:ListItem Text="Wyoming" Value="WY"></asp:ListItem>
                <asp:ListItem Text="-- Canada --" Value=""></asp:ListItem>
                <asp:ListItem Text="Alberta" Value="AB"></asp:ListItem>
                <asp:ListItem Text="British Columbia" Value="BC"></asp:ListItem>
                <asp:ListItem Text="Manitoba" Value="MB"></asp:ListItem>                
                <asp:ListItem Text="New Brunswick" Value="NB"></asp:ListItem>
                <asp:ListItem Text="Newfoundland" Value="NF"></asp:ListItem>
                <asp:ListItem Text="Nova Scotia" Value="NS"></asp:ListItem>
                <asp:ListItem Text="Northwest Territories" Value="NT"></asp:ListItem>
                <asp:ListItem Text="Nunavut" Value="Nunavut"></asp:ListItem>
                <asp:ListItem Text="Ontario" Value="ON"></asp:ListItem> 
                <asp:ListItem Text ="Prince Edward Island" Value="PE"></asp:ListItem>  
                <asp:ListItem Text ="Québec" Value="QC"></asp:ListItem>  
                <asp:ListItem Text ="Saskatchewan" Value="SK"></asp:ListItem>  
                <asp:ListItem Text ="YT" Value="Yukon"></asp:ListItem>           
                </asp:DropDownList>
		
			</FONT></TD>
			
			
		<TR> <TD>&nbsp;<TD> </TR>
		
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">ZIP Code:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrZip" runat="server"></asp:TextBox>
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Phone Number:* 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrPhone" runat="server" Width="200px"></asp:TextBox>
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Ext: 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrExt" runat="server" Width="70px"></asp:TextBox>
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Fax Number:
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><asp:TextBox ID="tbxstrFax" runat="server" Width="200px"></asp:TextBox>
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>
		
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">Additional Comments: 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><textarea cols="40" rows="5" name="strOther"></textarea>  
			</FONT></TD>
		</TR>
		
		<TR> <TD>&nbsp;<TD> </TR>
		
		
		
		<TR>
			<TD width="21%"><FONT face="Arial, Helvetica, sans-serif" size="2">&nbsp; 
				</FONT></TD>
			
			<TD width="79%"><FONT face="Arial, Helvetica, sans-serif" size="2"><input id="btnSubmit" name="mySubmit" type="button" value="submit" onclick="validate();"><input id="btnClear" name="myRese" type="reset" value="Clear All"></input>  
			</FONT></TD>
		</TR>
		<TR> <TD>&nbsp;<TD> </TR>	
	        </table>
	     </td>
	     <td valign="top" >
	       <table  align="left"   bgColor=silver border=0 >
	       <TR>
    				<TD align=middle><span id="txtsp" runat=server><FONT size=-1><B>All Shipments are UPS Ground unless 
      				expedited. <BR>
                You should receive your shipment within 10 business days after 
                your order was placed. <BR>
                Expedite requires 3rd party Fed-X Account Number.</B></FONT></span> 
      				<BR><BR><FONT color=navy>Expedite Method</FONT> <BR><INPUT type=hidden 
      				name=CarrierCode> <INPUT type=hidden name=PaymentTermsCode> 
      				
                        <asp:DropDownList ID="DDLExpediteCode" runat="server">
                        <asp:ListItem Text="&nbsp;Select&nbsp;" Value=""></asp:ListItem>
                        <asp:ListItem Text="None" Value="None"></asp:ListItem>
                        <asp:ListItem Text="FP" Value="FP"></asp:ListItem>
                         <asp:ListItem Text="PO" Value="PO"></asp:ListItem>
                        <asp:ListItem Text="SO" Value="SO"></asp:ListItem>
                        </asp:DropDownList>
      				
      				 <BR>&nbsp; 
  				</TD>
  			</TR>
  			<TR>
    			 <TD align=middle><FONT color=navy size=-1>Enter your 3rd Party Fed-X 
      				Account Number</FONT><BR><INPUT maxLength=20 name="AcctNumber"> <BR><!-- End FORM Expedite  --></TD></TR>
  				 <TR>
    				<TD align=middle><FONT size=-1><B>Fed-X Expedite Choices:</B></FONT></TD></TR>
  			<TR>
    				<TD style="FONT-SIZE: 75%">FP = 8:00 AM Next Day Business Only<BR>PO = 
      				10:30 AM Next Bus Day - Bus; 3:00 PM NextDay - Res<BR>SO = 3:00 PM Next 
      				Bus Day - Bus; 4:32 PM Next Bus Day - Res 
			</TD>
			</TR>
	       </table>
	     </td>
	     <td width="15px"></td>
	  </tr>
	</table>
	</div>
	</td>
	<td width="15px"></td>
	</tr></table>	
	
</asp:Content>


