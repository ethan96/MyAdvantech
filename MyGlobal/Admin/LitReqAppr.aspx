<%@ Page Title="Distributor/Representative Literature Approval Form" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim l_strSQLCmd As String
    Dim strCOMPANY, strEmail, dtrOFFER_CODE, strUSER_TYPE, strFIRST_NAME, strLAST_NAME, strEMAIL_ADDR, strADDRESS, strCITY, strSTATE, strZIP, strTEL_NO, strTEL_EXT, strFAX_NO, strJOB_TITLE As String
    Dim strREF_1, strREF_2, strREF_3, strREF_4, strREQUEST_ID, strAPPROVED_CODE, strAPPROVED_DATE, strCREATED_BY, strCREATED_DATE, strOrderDetail, strShippment, strOther As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("State") = "done" Then
            Me.btnClear.Visible = False : Me.btnReject.Visible = False : Me.btnSubmit.Visible = False
        End If
        Dim strRequst As String = ""
        If Not IsPostBack Then
            strRequst = Request("strRequest_ID")
            If strRequst Is Nothing Then
                strRequst = "" : Session("strRequestID") = "" : Response.End()
            End If
            Session("strRequestID") = strRequst
        End If
        If Session("strRequestID") IsNot Nothing Then
            strRequst = Session("strRequestID") : strREQUEST_ID = Session("strRequestID")
        End If
        GetCatlist(strRequst)                
        Dim strRequserCode As String = Request("strRequest_Code")
        RequestUseInfo(strRequst)
        frompost(strRequst, strRequserCode)
         
    End Sub
    Sub GetCatlist(ByVal strRequestID As String)
        l_strSQLCmd = "select 	distinct	" & _
  " [Request_ID] , 		" & _
  " [LN] , 		" & _
  " a.[Catalog_ID] , 		" & _
  " b.[Catalog_Name] , 		" & _
  " b.[Catalog_PerCase]  , " & _
  " b.[Catalog_Status] , " & _
  " [Request_Qty]   , 	" & _
  " [Approved_Qty]  , 		" & _
  " [Approved_Code]  		" & _
  " from Misc_Lit_Req_Detail a , Misc_Catalog_Listing b	" & _
  " where a.[Catalog_Id] = b.[Catalog_ID] and [Request_ID] = '" & strRequestID & "' " & _
  " order by [LN] "

        Dim Err As String = "", xDT As New DataTable, xDS As New DataSet
        xDT = dbUtil.dbGetDataTable("MY", l_strSQLCmd)
        If xDT.Rows.Count > 0 Then
            AdxDatagrid1.Visible = True : xDS.Tables.Add(xDT) : AdxDatagrid1.DataSource = xDS : AdxDatagrid1.DataBind()
        Else
            l_strSQLCmd = "select 		" & _
             " [Request_ID] , 		" & _
             " [LN] , 		" & _
             " a.[Catalog_ID] , 		" & _
             " b.[Catalog_Name] , 		" & _
             " b.[Catalog_PerCase]  , " & _
             " b.[Catalog_Status] , " & _
             " [Request_Qty]   , 	" & _
             " [Approved_Qty]  , 		" & _
             " [Approved_Code]  		" & _
             " from Misc_Lit_Req_Detail a , Misc_Catalog_Listing b	" & _
             " where a.[Catalog_Id] = b.[Catalog_ID] and 1<>1 " & _
             " order by [LN] "
            'xDT = Me.Global_inc1.dbGetDataTable("", "", l_strSQLCmd)
            ' AdvEBiz35.Utils.DBUtils.SQLUtils.ExecuteTable(ConfigurationManager.ConnectionStrings("MY").ConnectionString, Err, xDT, CommandType.Text, l_strSQLCmd)
            xDT = dbUtil.dbGetDataTable("MY", l_strSQLCmd)
            xDS.Tables.Add(xDT) : AdxDatagrid1.DataSource = xDS : AdxDatagrid1.DataBind()
            AdxDatagrid1.Visible = False : Me.btnClear.Visible = False : Me.btnReject.Visible = False : Me.btnSubmit.Visible = False
        End If
    End Sub
    
    Sub RequestUseInfo(ByVal strRequest_ID As String)
        Dim strSQL As String, xDT As New DataTable
        strSQL = "select  distinct isnull([COMPANY] ,'') as COMPANY , " & _
" isnull([OFFER_CODE] ,'') as OFFER_CODE , " & _
" isnull([USER_TYPE],'') as USER_TYPE, " & _
" isnull([FIRST_NAME],'') as FIRST_NAME , " & _
" isnull([LAST_NAME],'') as LAST_NAME, " & _
" isnull([EMAIL_ADDR],'') as EMAIL_ADDR , " & _
" isnull([ADDRESS],'') as ADDRESS, " & _
" isnull([CITY],'') as CITY	, " & _
" isnull([STATE],'') as STATE , " & _
" isnull([ZIP],'')  as 	ZIP , " & _
" isnull([TEL_NO],'') as TEL_NO, " & _
" isnull([TEL_EXT],'') as TEL_EXT, " & _
" isnull([FAX_NO],'') as FAX_NO , " & _
" isnull([JOB_TITLE],'') as JOB_TITLE , " & _
" isnull([REF_1],'') as REF_1 , " & _
" isnull([REF_2],'') as REF_2 , " & _
" isnull([REF_3],'') as  REF_3 , " & _
" isnull([REF_4],'') as  REF_4 , " & _
" isnull([REQUEST_ID],'')  as REQUEST_ID	 , " & _
" isnull([APPROVED_CODE],'') as APPROVED_CODE	 , " & _
" isnull([APPROVED_DATE],'') as APPROVED_DATE	 , " & _
" isnull([CREATED_BY],'') as CREATED_BY	 , " & _
" isnull([CREATED_DATE],'') as CREATED_DATE " & _
" from Misc_lit_req_master where   request_id = '" & strRequest_ID & "'"

        'xDT = Me.Global_inc1.dbGetDataTable("", "", strSQL)
        Dim Err As String = ""
        ' AdvEBiz35.Utils.DBUtils.SQLUtils.ExecuteTable(ConfigurationManager.ConnectionStrings("MY").ConnectionString, Err, xDT, CommandType.Text, strSQL)
        xDT = dbUtil.dbGetDataTable("MY", strSQL)
        If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            'Response.Write(strSQL)
        End If
        If xDT.Rows.Count > 0 Then
            For Each oRow As DataRow In xDT.Rows
                strEmail = oRow.Item("email_addr") : strCOMPANY = oRow.Item("COMPANY") : dtrOFFER_CODE = oRow.Item("OFFER_CODE")
                strUSER_TYPE = oRow.Item("USER_TYPE") : strFIRST_NAME = oRow.Item("FIRST_NAME") : strLAST_NAME = oRow.Item("LAST_NAME")
                strEMAIL_ADDR = oRow.Item("EMAIL_ADDR") : Session("strEMAIL_ADDR") = strEMAIL_ADDR : strADDRESS = oRow.Item("ADDRESS")
                strCITY = oRow.Item("CITY") : strSTATE = oRow.Item("STATE") : strZIP = oRow.Item("ZIP")
                strTEL_NO = oRow.Item("TEL_NO") : strTEL_EXT = oRow.Item("TEL_EXT") : strFAX_NO = oRow.Item("FAX_NO")
                strJOB_TITLE = oRow.Item("JOB_TITLE") : strREF_1 = oRow.Item("REF_1") : strREF_2 = oRow.Item("REF_2")
                strREF_3 = oRow.Item("REF_3") : strREF_4 = oRow.Item("REF_4") : strRequest_ID = oRow.Item("REQUEST_ID")
                strAPPROVED_CODE = oRow.Item("APPROVED_CODE")
                'Response.Write(oRow.Item("APPROVED_DATE"))
                If Convert.IsDBNull(oRow.Item("APPROVED_DATE")) Then
                    strAPPROVED_DATE = ""
                ElseIf oRow.Item("APPROVED_DATE").ToString = "1/1/1900 12:00:00 AM" Then
                    strAPPROVED_DATE = "N/A"
                Else
                    strAPPROVED_DATE = Convert.ToDateTime(oRow.Item("APPROVED_DATE")).ToShortDateString
                End If
                
                strCREATED_BY = oRow.Item("CREATED_BY")
                strCREATED_DATE = Convert.ToDateTime(oRow.Item("CREATED_DATE")).ToShortDateString
               
            Next

        End If
    End Sub
    Sub frompost(ByVal strREQUEST_ID As String, ByVal strRequest_Code As String)
        If strREQUEST_ID <> "" And strRequest_Code <> "" Then
           
            Dim approQty As Integer
            Dim strSQL, l_strMailBody As String
            
            l_strMailBody = "<span class='text'> <table width='80%' border='1' align='center'><tr><td align='right'>Catalog Request:</td><td> " & strREQUEST_ID & "</td></tr>" & _
                           " <tr><td align='right'>Email:</td><td> " & strEmail & " </td></tr>" & _
                           " <tr><td align='right'>FirstName:</td><td> " & strFIRST_NAME & " </td></tr>" & _
                           " <tr><td align='right'>LastName:</td><td>" & strLAST_NAME & " </td></tr>" & _
                           " <tr><td align='right'>JobTitle:</td><td>" & strJOB_TITLE & " </td></tr>" & _
                           " <tr><td align='right'>Company:</td><td>" & strCOMPANY & " </td></tr>" & _
                           " <tr><td align='right'>Address:</td><td>" & strADDRESS & "</td></tr>" & _
                           "<tr><td align='right'> City:</td><td>" & strCITY & " </td></tr>" & _
                           " <tr><td align='right'>State:</td><td>" & strSTATE & "</td></tr>" & _
                           "<tr><td align='right'> Zip	:</td><td>" & strZIP & " </td></tr>" & _
                           " <tr><td align='right'>Phone:</td><td>" & strTEL_NO & " </td></tr>" & _
                           " <tr><td align='right'>Ext	:</td><td>" & strTEL_EXT & " </td></tr>" & _
                           " <tr><td align='right'>Catalog:</td><td>" & strOrderDetail & " </td></tr>" & _
             " <tr><td align='right'>Shippment :</td><td>" & strShippment & " </td></tr>" & _
                           " <tr><td align='right'>Comment :</td><td>  " & strOther & "</td></tr>"

            l_strMailBody = l_strMailBody & "</span>"
            
            If UCase(strRequest_Code) = "APPROVED" Then
                For Each oDataGridItem As GridViewRow In AdxDatagrid1.Rows

                    Dim oType As ListItemType = oDataGridItem.RowType

                    If (oType <> ListItemType.Header And oType <> ListItemType.Footer) Then

                        If Request("QTY$$$" & oDataGridItem.Cells(1).Text & "-" & oDataGridItem.Cells(2).Text) <> "" Then
                            
                            approQty = CInt(Request("QTY$$$" & oDataGridItem.Cells(1).Text & "-" & oDataGridItem.Cells(2).Text))

                            strSQL = " update Misc_lit_req_detail " & _
                            " set Approved_Qty = " & approQty & "" & _
                            " ,   Approved_Code = '" & "APPROVED" & "' " & _
                            " where Request_ID = '" & strREQUEST_ID & "' and LN = " & oDataGridItem.Cells(1).Text
                            dbUtil.dbExecuteNoQuery("MY", strSQL)
                            If Session("user_id") = "ming.zhao@advantech.com.cn" Then
                                Response.Write("<hr>")
                                Response.Write(strSQL)
                                Response.Write("<hr>")
                            End If
                        End If


                    End If
                Next
                '''''''''''''''''''''''''''''''''''''''''''''''''''''''
                              
              
                
                '''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strSQL = "update Misc_lit_req_master " & _
                  " set APPROVED_CODE = '" & "APPROVED" & "'" & _
                  " , APPROVED_DATE = getdate() " & _
                  " where request_id = '" & strREQUEST_ID & "'"
                dbUtil.dbExecuteNoQuery("MY", strSQL)

                ' Util.SendEmail("tc.chen@advantech.eu", "tc.chen@advantech.eu", "tc.chen@advantech.eu", "tc.chen@advantech.eu", "[B2B Literature] Approved", "", l_strMailBody)

                SendEmail(l_strMailBody)


            Else ' For Those Reject

                strSQL = " update Misc_lit_req_detail " & _
                  " set Approved_Qty = " & "0" & "" & _
                  " ,   Approved_Code = '" & "REJECTED" & "' " & _
                  " where Request_ID = '" & strREQUEST_ID & "' "
                dbUtil.dbExecuteNoQuery("MY", strSQL)
                If Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    'Response.Write("<hr>")
                    'Response.Write(strSQL)
                    'Response.Write("<hr>")
                End If
                strSQL = "update Misc_lit_req_master " & _
                  " set APPROVED_CODE = '" & "REJECTED" & "'" & _
                  " , APPROVED_DATE = getdate() " & _
                  " where request_id = '" & strREQUEST_ID & "'"

                dbUtil.dbExecuteNoQuery("MY", strSQL)
                If Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    'Response.Write("<hr>")
                    'Response.Write(strSQL)
                    'Response.Write("<hr>")
                End If

            End If
            
            If LCase(HttpContext.Current.Session("user_id")) = "adam.sturm@advantech.com" Then
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select ISNULL(b.PRIMARY_SALES_EMAIL,'') as PRIMARY_SALES_EMAIL from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID where a.EMAIL_ADDRESS='{0}' and a.OrgID='HQDC'", strEmail))
                If obj IsNot Nothing Then
                    If obj.ToString.ToLower = "david.kok@advantech.com" Or obj.ToString.ToLower = "mark.ma2@advantech.com.tw" Then
                        Util.SendEmail("Adam.Sturm@advantech.com", HttpContext.Current.Session("USER_ID"), "MyAdvantech Literature " + strRequest_Code, l_strMailBody, True, "Liliana.Wen@advantech.com.tw,eBusiness.AEU@advantech.eu", "")
                    End If
                End If
            End If
        End If
        GetCatlist(strREQUEST_ID)
    End Sub

    Protected Sub AdxDatagrid1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles AdxDatagrid1.RowDataBound
        Dim oType As ListItemType = e.Row.RowType
        If (oType <> ListItemType.Header And oType <> ListItemType.Footer) Then

            If e.Row.Cells(2).Text <> "" Then
                e.Row.Cells(7).Text = "<input type='text' name='QTY$$$" & e.Row.Cells(1).Text & "-" & e.Row.Cells(2).Text & "' size=3 value='" & e.Row.Cells(7).Text & "' style=""text-align: right;"" />PCS"
            End If
        End If
    End Sub
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
        Subject_Email = "MyAdvantech Literature Approved"
        '
        MailBody = MailBody & "<html><body><center>"
        MailBody = MailBody & strStyle & EmailBODY
        MailBody = MailBody & "</center></body></html>"
        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        
        Return 1
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script  type="text/javascript">

    function JSApprove() {
        document.aspnetForm.action = "litReqAppr.aspx?strRequest_Code=APPROVED";
        document.aspnetForm.submit();
        return true;
    }


    function JSReject() {

        document.aspnetForm.action = "litReqAppr.aspx?strRequest_Code=REJECT";
        document.aspnetForm.submit();
        return true;
    }


    function btnSubmit_onclick() {

    }

    function btnReject_onclick() {

    }

    function btnClear_onclick() {

    }

</script>						



    
    <div>
    <table>

		<tr>
				<td >
					
				</td>
		</tr>
     <tr>
       <td >
      <%-- <asp:DataGrid ID="test" runat="server"></asp:DataGrid>--%>
         
       </td>
     </tr>
      <tr>
        <td height="40" colspan="2"><font size="3" face="Arial, Helvetica, sans-serif"><b><font color="#003366"><br>
                <img src="http://www.advantechdirect.com/60DayTrial/point.gif" width="25" height="15"><font size="4"> 
                 Distributor/Representative Literature Approval Form</font></font></b><font face="Arial, Helvetica, sans-serif" size="2" ><font color="#000000"><br>
               <br>
               </font></font></font> 
               <hr>
             </td>
            </tr> 
            <tr>
              <td >
             <TABLE border="1" style="border:double" >
      <TR>
        <th width="">
            <font face="Arial, Helvetica, sans-serif" size="2">
                Company
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strCOMPANY%>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Name
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strFIRST_NAME & "  " & strLAST_NAME%>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Job Title
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strJOB_TITLE%>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Email
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strEMAIL_ADDR%>
            </font>
        </td>
    </TR>
    <tr>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Request ID
                <br>
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strRequest_ID %>
                    <br>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Order Date
                <br>
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strCreated_Date %>
                    <br>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Approved Status
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <% If strAPPROVED_CODE Is Nothing Then%>
                    N/A
                    <br />
                    <%Else%>
                        <%-- Response.Write(strAPPROVED_CODE)--%>
                            <%=strAPPROVED_CODE %>
                                <br>
                                <% End If %>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Approved Time
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%= strAPPROVED_DATE%>
                    <br />
            </font>
        </td>
    </tr>
    <tr>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Phone
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strTEL_NO & "-" & strTEL_EXT%>
            </font>
        </td>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Shipping Info
            </font>
        </th>
        <td>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strREF_2 %>
            </font>
        </td>
         <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Address
            </font>
        </th>
        <td colspan=3>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%=strADDRESS &"," & strCITY & "," & strSTATE & "," & strZIP%>
            </font>
        </td>
    </tr>
    <tr>
        <th>
            <font face="Arial, Helvetica, sans-serif" size="2">
                Additional Comments
            </font>
        </th>
        <td colspan=7>
            <font face="Arial, Helvetica, sans-serif" size="2">
                <%= strREF_3%>
            </font>
        </td>
    </tr>
</TABLE>
              </td>
            </tr>
            <tr valign="top">
							<td align="center">
							<sgv:SmartGridView runat="server" ID="AdxDatagrid1" ShowWhenEmpty="true" AutoGenerateColumns="false" AllowSorting="true" Width="100%" RowStyle-HorizontalAlign="Center">
								                <Columns>
								                    <asp:BoundField HeaderText="Request ID" DataField="Request_ID" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Ln" DataField="Ln" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Catalog ID" DataField="Catalog_ID" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Catalog Name" DataField="Catalog_Name" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Catalog PerCase" DataField="Catalog_PerCase" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Catalog Status" DataField="Catalog_Status" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Request Qty" DataField="Request_Qty" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Approved Qty" DataField="Approved_Qty" ReadOnly="true"   />    
								                    <asp:BoundField HeaderText="Approved Code" DataField="Approved_Code" ReadOnly="true"   />  
                                                      
                                                </Columns>
								                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
	                                            <RowStyle  BackColor="#F7F6F3" ForeColor="#333333" />
                                                
	                                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
	                                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
	                                            <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
	                                            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
								            </sgv:SmartGridView>

                                    </td>
						</tr>
        <tr> 
          <td height="2" colspan="2"> 
            <p align="right">&nbsp;</p>
          </td>
        </tr>
        	<TR>			
			<TD width="79%" align="Center"><FONT face="Arial, Helvetica, sans-serif" size="2">
			
				<input name=mySubmit id="btnSubmit" type="button" runat="server" value=Approve  onclick='return JSApprove();' >
				<input name=mySubmit2 type="button" id="btnReject" runat="server" value=Reject onclick='return JSReject();' >
				<input name=myReset style="display:none;" type=reset id="btnClear" runat="server" value="Clear All" onclick="return btnClear_onclick()"></input>  
			
			</FONT></TD>
		</TR>
        
         
    </table>
 
     
    </div>
</asp:Content>


