<%@ Page Title="Literature Request Online Report " Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim strFromdate, strTodate As DateTime
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            strFromdate = Now.Date.AddDays(-7).ToShortDateString
            strTodate = Now.Date.ToShortDateString
            txtOrderDateFrom.Text = strFromdate
            txtOrderDateTo.Text = strTodate
            labDate.Text = strFromdate & "~" & strTodate
            GetCatlist(strFromdate, strTodate)
        End If
    End Sub
    Function GetCatlist(ByVal strFromDate As Date, ByVal strToDate As Date)
        Dim strSQL As String
        strSQL = "select  distinct [COMPANY] ,REQUEST_ID, " & _
       " [OFFER_CODE] , " & _
       " [USER_TYPE] , " & _
       " [FIRST_NAME] , " & _
       " [LAST_NAME] , " & _
       " [EMAIL_ADDR] , " & _
       " [ADDRESS] , " & _
       " [CITY] 	, " & _
       " [STATE] , " & _
       " [ZIP] 	, " & _
       " [TEL_NO] , " & _
       " [TEL_EXT] , " & _
       " [FAX_NO]  , " & _
       " [JOB_TITLE] , " & _
       " [REF_1] , " & _
       " [REF_2] , " & _
       " [REF_3] , " & _
       " [REF_4] , " & _
       " [REQUEST_ID] 	 , " & _
       " [APPROVED_CODE] 	 , " & _
       " [CREATED_BY] 	 , " & _
       " [CREATED_DATE]  , [SEND_DATE]" & _
        " from Misc_lit_req_master where  [Created_date] >= '" & Trim(strFromDate) & "' and [Created_date] <= '" & Trim(strToDate.AddDays(1)) & "' "
        If RadioButtonList1.SelectedIndex > 0 Then
            strSQL = strSQL + " and APPROVED_CODE= '" + RadioButtonList1.SelectedValue + "' "
        End If      
        strSQL = strSQL + " and REF_4 like 'Catalog_req%' order by Created_date desc"
        Dim xDT As New DataTable
        Dim xDS As New DataSet
        xDT = dbUtil.dbGetDataTable("MY", strSQL)
        'Response.Write(strSQL)
        If xDT.Rows.Count > 0 Then
            xDS.Tables.Add(xDT)
            gv1.DataSource = xDS
            gv1.DataBind()
        Else
            gv1.EmptyDataText="No Data."
            gv1.DataSource = xDT
            gv1.DataBind()
            If txtOrderDateFrom.Text.Trim = "" OrElse txtOrderDateTo.Text.Trim = "" Then
                txtOrderDateFrom.Text = Now.Date.AddDays(-7).ToShortDateString
                txtOrderDateTo.Text = Now.Date.ToShortDateString
                labDate.Text = txtOrderDateFrom.Text & "~" & txtOrderDateTo.Text
            End If
        End If
    End Function
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click       
        strFromdate = txtOrderDateFrom.Text 'Calendar1.SelectedDate         
        strTodate = txtOrderDateTo.Text  'Calendar2.SelectedDate
        labDate.Text = strFromdate & "~" & strTodate
        GetCatlist(strFromdate, strTodate)
      
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gv1.RowDataBound
        Dim oType As ListItemType = e.Row.RowType
        If e.Row.RowType = DataControlRowType.DataRow Then '(oType <> ListItemType.Header And oType <> ListItemType.Footer)
            e.Row.Cells(1).Text = Convert.ToDateTime(e.Row.Cells(1).Text).ToString("yyyy-MM-dd")
            If e.Row.Cells(7).Text = "" Or e.Row.Cells(7).Text Is Nothing Then
                e.Row.Cells(7).Text = "<A href='LitReqAppr.aspx?strRequest_ID=" & e.Row.Cells(12).Text & "'>" & "APPROVE IT" & "</A>"
            ElseIf e.Row.Cells(7).Text = "REQUESTED" Then
                e.Row.Cells(7).Text = "<A href='LitReqAppr.aspx?strRequest_ID=" & e.Row.Cells(12).Text & "'>" & e.Row.Cells(7).Text & "</A>"
            ElseIf e.Row.Cells(7).Text = "APPROVED" Or e.Row.Cells(7).Text = "REJECTED" Then
                e.Row.Cells(7).Text = "<A href='LitReqAppr.aspx?State=done&strRequest_ID=" & e.Row.Cells(12).Text & "'>" & e.Row.Cells(7).Text & "</A>"
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript">
    function clearall() {
        document.getElementById("tbxFromDate").value = "";

        document.getElementById("tbxToDate").value = "";

    }

    function onPickerChange1(picker) {
        Calendar1.SetSelectedDate(picker.GetSelectedDate());
    }
    function onCalendarChange1(calendar) {
        Picker1.SetSelectedDate(calendar.GetSelectedDate());
    }
    function onPickerChange2(picker) {
        Calendar2.SetSelectedDate(picker.GetSelectedDate());
    }
    function onCalendarChange2(calendar) {
        Picker2.SetSelectedDate(calendar.GetSelectedDate());
    }
    function onPickerChange3(picker) {
        Calendar3.SetSelectedDate(picker.GetSelectedDate());
    }
    function onCalendarChange3(calendar) {
        Picker3.SetSelectedDate(calendar.GetSelectedDate());
    }

</script>   
    <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" >
            <tr bordercolor="#999999" bgcolor="#FFFFFF"> 
                 <td height="40" colspan="2"><font size="3" face="Arial, Helvetica, sans-serif">
                    <b> <font color="#003366"><br><img src="http://www.advantechdirect.com/60DayTrial/point.gif" width="25" height="15">
                     <font size="4">Literature Request Online Report</font></font></b>
                     <font face="Arial, Helvetica, sans-serif" size="2" ><font color="#000000"><br><br></font></font></font> 
                     <hr><font face="Arial, Helvetica, sans-serif" size="2">
                     <font size="3" face="Arial, Helvetica, sans-serif"><b>
                     <font face="Arial, Helvetica, sans-serif" size="2" ><a href="%5C" target="_blank">
                     <img src="http://www.advantechdirect.com/60DayTrial/BlankSpace.gif" width="25" height="8" border="0"></a></font></b></font>
                     <font size=2 face=arial><strong>Please provide the following information:</strong><font size="1"> <br>
                           </font><font size="3" face="Arial, Helvetica, sans-serif"><b>
                           <font face="Arial, Helvetica, sans-serif" size="2" >
                           <a href="%5C" target="_blank"><img src="http://www.advantechdirect.com/60DayTrial/BlankSpace.gif" width="25" height="8" border="0"></a></font></b></font>
                           <font size="1">Note: All fields marked with a <font color="#ff0000">*</font> must be completed 
                          in full.</font></font></font> 
                  </td>
              </tr>
              <tr> 
                  <td height="19" colspan="2"><font face="Arial, Helvetica, sans-serif" size="2"><font size=2 face=arial></font></font></td>
                </tr>               
                <tr> 
                  <td width="23%" height="25"><font face="Arial, Helvetica, sans-serif" size="2">
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Order Date From:<font color="#FF0000">*</font></font>               
                        <asp:TextBox ID="txtOrderDateFrom" runat="server" Width="76px"></asp:TextBox>
                        <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtOrderDateFrom" Format="MM/dd/yyyy" />
                  </td>              
                  <td><font face="Arial, Helvetica, sans-serif" size="2">Order Date To:</font>
                  <asp:TextBox ID="txtOrderDateTo" runat="server" Width="76px"></asp:TextBox>
                  <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtOrderDateTo" Format="MM/dd/yyyy" />
                </td>
                </tr>
                <tr> 
                  <td width="23%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Status:</td>
                  <td width="73%">
                      <asp:RadioButtonList ID="RadioButtonList1" runat="server" RepeatDirection="Horizontal">
                      <asp:ListItem Selected ="True" Text="All" Value="0"></asp:ListItem>
                      <asp:ListItem  Text="Requested" Value="REQUESTED"></asp:ListItem>
                      <asp:ListItem  Text="Approved" Value="APPROVED"></asp:ListItem>
                      <asp:ListItem  Text="Rejected" Value="REJECTED"></asp:ListItem>
                      </asp:RadioButtonList>
                  </td>
                </tr>      
                <tr> 
                  <td width="27%"><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Report Range  Date:  <font size="3" face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif" size="2" ><font color="#000000"></font></font></font></font></td>
                  <td width="73%" height="25"><font face="Arial, Helvetica, sans-serif" size="2" > 
                    <asp:Label ID="labDate" runat="server" ></asp:Label></font></td>
                </tr>               
                <tr> 
                  <td width="27%"></td>
                  <td width="73%"> <asp:Button ID="btnSubmit" runat="server" Text="Submit" /> </td>
                </tr>
                <tr>
                  <td align="right" colspan="2" height="5">
                     
                  </td>
                  <%--<td align="left"><input  name="btnReset" type="button" value="Clear All" onclick="clearall();"/></td>--%>
                </tr>
               
                <tr valign="top"> 
                  <td colspan=2 align="center">
                  
                  
                                    <sgv:SmartGridView runat="server" ID="gv1" ShowWhenEmpty="true" AutoGenerateColumns="false" AllowSorting="true" Width="100%">
								                <Columns>
								                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                        <headertemplate>
                                                            No.
                                                        </headertemplate>
                                                        <itemtemplate>
                                                            <%# Container.DataItemIndex + 1 %>
                                                        </itemtemplate>
                                                    </asp:TemplateField>
                                                   <asp:BoundField HeaderText="Order Date" DataField="Created_Date" ReadOnly="true"  ItemStyle-HorizontalAlign="Right"/>
								                   <asp:BoundField HeaderText="Company" DataField="COMPANY" ReadOnly="true"   />
                                                    <asp:BoundField HeaderText="Frist Name" DataField="FIRST_NAME" ReadOnly="true"   />
                                                    <asp:BoundField HeaderText="Last Name" DataField="LAST_NAME" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Job Title" DataField="JOB_TITLE" ReadOnly="true" />
								                    <asp:BoundField HeaderText="Phone" DataField="TEL_NO" ReadOnly="true" />
								                    <asp:BoundField HeaderText="Catalog Ordered" DataField="APPROVED_CODE" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Shipping Info" DataField="REF_2" ReadOnly="true"   />
								                    <asp:BoundField HeaderText=" Email " DataField="EMAIL_ADDR" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />
								                    <asp:BoundField HeaderText="Send Date" DataField="SEND_DATE" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Address" DataField="ADDRESS" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="Request ID" DataField="REQUEST_ID" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="CITY" DataField="CITY" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="STATE" DataField="STATE" ReadOnly="true"   />
								                    <asp:BoundField HeaderText="ZIP" DataField="ZIP" ReadOnly="true"   />                                                    
								                 
								                    
								                </Columns>
								                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
	                                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
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
              
        <tr> 
          <td height="2" colspan="2"> 
            <p align="right">&nbsp;</p>
          </td>
        </tr>  
    </table>


</asp:Content>





