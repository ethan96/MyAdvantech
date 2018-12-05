<%@ Control Language="VB" ClassName="UpdateLead" %>
<%@ Register Src="~/Includes/OptyPtnrContact.ascx" TagName="OptyPtnrContact" TagPrefix="uc1" %>
<script runat="server">
    Public Property OptyRowID() As String
        Get
            Return src1.SelectParameters("OPTYID").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("OPTYID").DefaultValue = value
            'OptyPtnrContact1.OptyRowId = value
        End Set
    End Property
    
    Public Property ReasonWonLost() As String
        Get
            Return dlReasonWonLost.SelectedValue
        End Get
        Set(ByVal value As String)
            For Each li As ListItem In dlReasonWonLost.Items
                li.Selected = False
                If li.Value = value Then
                    li.Selected = True : Exit For
                End If
            Next
        End Set
    End Property
    
    Public Property OptyName() As String
        Get
            Return src1.SelectParameters("OPTYNAME").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("OPTYNAME").DefaultValue = value
            txtName.Text = value
        End Set
    End Property
    
    Public Property OptyStatus() As String
        Get
            Return src1.SelectParameters("STATUS").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("STATUS").DefaultValue = value
            dlStatus.SelectedValue = value
        End Set
    End Property
    Public Property OptyCurrency() As String
        Get
            Return src1.SelectParameters("CURR").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("CURR").DefaultValue = value
            lbCurr.Text = value
        End Set
    End Property
    Public Property OptyAmt() As Double
        Get
            Return src1.SelectParameters("AMOUNT").DefaultValue
        End Get
        Set(ByVal value As Double)
            src1.SelectParameters("AMOUNT").DefaultValue = value
            txtAmt.Text = value.ToString()
        End Set
    End Property
    
    Public Property CreatedDate() As Date
        Get
            Return src1.SelectParameters("CREATEDATE").DefaultValue
        End Get
        Set(ByVal value As Date)
            src1.SelectParameters("CREATEDATE").DefaultValue = value
            Me.lbCreateDate.Text = value.ToString("yyyy/MM/dd")
        End Set
    End Property
    
    Public Property CloseDate() As Date
        Get
            Return src1.SelectParameters("CLOSEDATE").DefaultValue
        End Get
        Set(ByVal value As Date)
            src1.SelectParameters("CLOSEDATE").DefaultValue = value
            Me.txtCloseDate.Text = value.ToString("yyyy/MM/dd")
        End Set
    End Property
    
    Public Property GAccount() As String
        Get
            Return src1.SelectParameters("GACCOUNT").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("GACCOUNT").DefaultValue = value
            lbEndAccount.Text = value
        End Set
    End Property
    Public Property GContact() As String
        Get
            Return src1.SelectParameters("GCONTACT").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("GCONTACT").DefaultValue = value
            lnkLeadContact.HRef = "mailto:" + value : lnkLeadContact.InnerText = value
        End Set
    End Property
    Public Property GAccountTel() As String
        Get
            Return src1.SelectParameters("GAPHONE").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("GAPHONE").DefaultValue = TrimPhone(value)
            lbAccountTel.Text = TrimPhone(value)
        End Set
    End Property
    Public Property GContactTel() As String
        Get
            Return src1.SelectParameters("GCPHONE").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("GCPHONE").DefaultValue = TrimPhone(value)
            lbContactTel.Text = TrimPhone(value)
        End Set
    End Property
    Public Property OptyDesc() As String
        Get
            Return src1.SelectParameters("DESC").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("DESC").DefaultValue = value
            Me.txtDesc.Text = value
        End Set
    End Property
    Public Property AccPriSales() As String
        Get
            Return src1.SelectParameters("PRISALES").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("PRISALES").DefaultValue = value
            hySales.Text = value
        End Set
    End Property
    Public WriteOnly Property AccPriSalesEmail() As String
        'Get
        'Return src1.SelectParameters("PRISALES").DefaultValue
        'End Get
        Set(ByVal value As String)
            'src1.SelectParameters("PRISALES").DefaultValue = value
            hySales.NavigateUrl = "mailto:" + value
        End Set
    End Property
    Public Property AccountROWID() As String
        Get
            Return src1.SelectParameters("PRID").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("PRID").DefaultValue = value
            'OptyPtnrContact1.AccountRowId = value
        End Set
    End Property
    Public Property AccountContactID() As String
        Get
            Return src1.SelectParameters("PRCONTACTID").DefaultValue
        End Get
        Set(ByVal value As String)
            src1.SelectParameters("PRCONTACTID").DefaultValue = value
            'OptyPtnrContact1.ContactRowId = value
        End Set
    End Property
    
    Private Function TrimPhone(ByVal phone As String) As String
        Dim p() As String = Split(phone, vbLf)
        If p.Length > 0 Then Return p(0)
        Return phone
    End Function
    
    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbMsg.Text = ""
        If Double.TryParse(txtAmt.Text, 0) = False Then
            lbMsg.Text = "Amount in incorrect format" : Exit Sub
        End If
        If Date.TryParse(txtCloseDate.Text, Now) = False Then
            lbMsg.Text = "Close Date in incorrect format, should be in yyyy/mm/dd form" : Exit Sub
        End If
        If (dlStatus.SelectedValue = "Won" Or dlStatus.SelectedValue = "Lost") And dlReasonWonLost.SelectedIndex = 0 Then
            lbMsg.Text = "Please choose one reason from reason won/lost" : Exit Sub
        End If
        Dim ws As New aeu_eai2000.Siebel_WS ', gr As GridViewRow = OptyGv.Rows(OptyGv.EditIndex)
        ws.UseDefaultCredentials = True
        Dim b As Boolean = ws.UpdateOpportunityStatus2(Me.OptyRowID, dlStatus.SelectedValue, _
                                                      txtDesc.Text, CDbl(txtAmt.Text), CDate(txtCloseDate.Text), dlReasonWonLost.SelectedValue)
        If Not b Then
            Me.lbMsg.Text = "Error updating lead status back to Siebel"
        Else
            If Session("user_id") <> "tc.chen@advantech.com.tw" Then
                SendCustUpdateOptyActionToSales(Me.OptyRowID, dlStatus.SelectedValue, txtDesc.Text, CDbl(txtAmt.Text), CDate(txtCloseDate.Text), Session("user_id"))
                UpdateLocalOptyTable(Me.OptyRowID, dlStatus.SelectedValue, txtDesc.Text, CDbl(txtAmt.Text), CDate(txtCloseDate.Text))
            End If
            Me.lbMsg.Text = "Lead updated"
            If dlStatus.SelectedValue = "Won" Then
                btnOrder_Click(Nothing, Nothing)
            End If
        End If
    End Sub
    
    Public Sub SendCustUpdateOptyActionToSales(ByVal OptyId As String, ByVal NewStatus As String, ByVal NewDesc As String, ByVal NewAmt As String, ByVal NewCloseDate As Date, ByVal UpdateByEmail As String)
        Dim dt As DataTable = GetOptyDetail(OptyId)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim salesEmail As String = dt.Rows(0).Item("sales_email"), salesName As String = dt.Rows(0).Item("sales"), accountName As String = dt.Rows(0).Item("account_name")
            Dim OptyName As String = dt.Rows(0).Item("name")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format("Dear {0},<br/>", salesName))
                .AppendLine(String.Format(" Account: <b>{0}</b><br/>", accountName))
                .AppendLine(String.Format(" Contact: <b>{0}</b><br/> Updated sales leads <b>{1}</b> to status <b>{2}</b>.<br/>", UpdateByEmail, OptyName, NewStatus))
                .AppendLine(String.Format(" Revenue: <b>{0}</b><br/>", NewAmt))
                .AppendLine(String.Format(" Close Date: <b>{0}</b><br/>", NewCloseDate.ToString("yyyy/MM/dd")))
                .AppendLine(String.Format(" Reason/Description:<br/>{0}<br/>", NewDesc))
                .AppendLine(String.Format("<br/>"))
                .AppendLine(String.Format("Best regards,<br/>"))
                .AppendLine(String.Format("<b><a href='mailto:eBusiness.AEU@advantech.eu'>AEU IT Team</a></b>"))
                '.AppendLine(String.Format(""))
            End With
            If Not salesEmail Like "*@*.*" Then
                salesEmail = "eBusiness.AEU@advantech.eu"
            End If
            'salesEmail = "chentc@gmail.com"
            If Session("company_id") IsNot Nothing Then
                Dim ISDt As DataTable = GetISFromCompanyId(Session("company_id"))
                Dim OptyTeamDt As DataTable = dbUtil.dbGetDataTable("MY", "select email from opty_team where company_id='" + Session("company_id") + "'")
                If ISDt.Rows.Count = 1 AndAlso salesEmail <> "" Then
                    salesEmail += "," + ISDt.Rows(0).Item("email")
                End If
                If OptyTeamDt.Rows.Count > 0 Then
                    For Each r As DataRow In OptyTeamDt.Rows
                        salesEmail += "," + r.Item("email")
                    Next
                End If
            End If
            Util.SendEmail(salesEmail, "eBusiness.AEU@advantech.eu", "MyAdvantech Sales Leads Updated By " + UpdateByEmail, _
                           sb.ToString, True, "eBusiness.AEU@advantech.eu", "")
        End If
    End Sub
    
    Public Function UpdateLocalOptyTable(ByVal OptyId As String, ByVal OptyStatus As String, ByVal OptyDesc As String, ByVal OptyAmt As String, ByVal OptyCloseDate As Date) As Boolean
        Dim sql As New StringBuilder
        With sql
            .AppendFormat("update siebel_opportunity set status_cd='{0}', desc_text='{1}', SUM_REVN_AMT='{2}', SUM_EFFECTIVE_DT='{3}' ", OptyStatus, OptyDesc.Replace("'", "''"), CDbl(OptyAmt), OptyCloseDate)
            If OptyStatus = "Won" Then .AppendFormat(", STAGE_NAME='100% Won-PO Input in SAP' ")
            If OptyStatus = "Lost" Then .AppendFormat(", STAGE_NAME='0% Lost' ")
            .AppendFormat(" where row_id='{0}'; ", OptyId)
            .AppendFormat(" INSERT INTO OPTY_UPDATE_LOG ")
            .AppendFormat(" (ROW_ID, STATUS, DESC_TEXT, SUM_AMOUNT, CLOSE_DATE, UPD_BY, UPD_DATE) ")
            .AppendFormat(" VALUES     (N'{0}', N'{1}', N'{2}', {3}, '{4}', N'{5}', GETDATE()) ", OptyId, OptyStatus, OptyDesc.Replace("'", "''"), CDbl(OptyAmt), OptyCloseDate, Session("user_id"))
        End With
        If dbUtil.dbExecuteNoQuery("RFM", sql.ToString) > 0 Then
            Return True
        End If
        Return False
    End Function
    
    Public Function GetOptyDetail(ByVal OptyId As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select a.ROW_ID, a.NAME, a.STATUS_CD, b.NAME as account_name, IsNull(a.DESC_TEXT,'') as desc_text, ")
            .AppendFormat(" IsNull( ( select EMAIL_ADDR from S_CONTACT where ROW_ID in 	( select PR_EMP_ID from S_POSTN where ROW_ID in 			(		select PR_POSTN_ID	from S_ORG_EXT 	where ROW_ID=b.ROW_ID ) )  	),'ebusiness.aeu@advantech.eu') as SALES_EMAIL, ")
            .AppendFormat(" IsNull( ( select EMAIL_ADDR from S_CONTACT where ROW_ID in 	( select PR_EMP_ID from S_POSTN where ROW_ID in 			(		select PR_POSTN_ID	from S_ORG_EXT 	where ROW_ID=b.ROW_ID ) )  	),'ebusiness.aeu@advantech.eu') as SALES ")
            .AppendFormat(" from S_OPTY a inner join S_ORG_EXT b on a.PR_DEPT_OU_ID=b.ROW_ID ")
            .AppendFormat(" where a.ROW_ID='{0}' ", OptyId)
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        For Each r As DataRow In dt.Rows
            If r.Item("sales").ToString Like "*@*" Then
                Dim mp() As String = Split(r.Item("sales").ToString(), "@")
                r.Item("sales") = mp(0).Trim()
            End If
        Next
        dt.AcceptChanges()
        Return dt
    End Function
    
    Public Function GetISFromCompanyId(ByVal companyid As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format( _
        "select top 1 b.sales_code, b.full_name, b.email " + _
        " from sap_company_employee a inner join sap_employee b on a.sales_code=b.sales_code " + _
        " where a.partner_function='Z2' and a.sales_org='EU10' and b.email like '%@%advantech%.%' and a.company_id in ('{0}')", _
        companyid))
        Return dt
    End Function
    
    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Session("OptyId") = Me.OptyRowID
        Util.AjaxRedirect(Me.upMsg, "/Order/Cart_List.aspx")
        'Response.Redirect("/Order/Cart_List.aspx")
    End Sub

    Protected Sub lnkOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnOrder_Click(Nothing, Nothing)
    End Sub
</script>
<table width="100%">
    <tr valign="top" align="left">
        <td valign="top">
            <table width="100%">
                <tr valign="top">
                    <th style="width:80px">Lead Name</th>
                    <td>
                        <asp:TextBox runat="server" ID="txtName" Width="200px" />
                    </td>              
                </tr>
            </table>
        </td>               
    </tr>
    <tr>
        <td align="left">
            <table>
                <tr>
                    <th style="width:80px">Sales Team</th>
                    <td><asp:HyperLink runat="server" ID="hySales" /></td>  
                </tr>
            </table>                    
        </td>
    </tr>
    <tr valign="top" align="left">
        <td>
            <table width="100%">
                <tr valign="top">
                    <th style="width:80px">Amount</th>
                    <td>
                        <asp:Label runat="server" ID="lbCurr" Width="20px" />&nbsp;<asp:TextBox runat="server" ID="txtAmt" Width="50px" />
                    </td>  
                    <th>Status</th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlStatus" Width="80px">
                            <asp:ListItem Text="Accepted" Value="Accepted" />
                            <asp:ListItem Text="Lost" Value="Lost" />
                            <asp:ListItem Text="Pending" Value="Pending" />
                            <asp:ListItem Text="Rejected" Value="Rejected" />
                            <asp:ListItem Text="Won" Value="Won" />
                        </asp:DropDownList>
                    </td> 
                    <th align="left">Reason Won/Lost</th>                    
                    <td>
                        <asp:DropDownList runat="server" ID="dlReasonWonLost" Width="150px">
                            <asp:ListItem Text="" Value="" Selected="True" />
                            <asp:ListItem Text="Brand Awareness" Value="Brand Awareness" />
                            <asp:ListItem Text="Budget Cancelled" Value="Budget Cancelled" />
                            <asp:ListItem Text="Delivery time" Value="Delivery time" />
                            <asp:ListItem Text="Internal Development" Value="Internal Development" />
                            <asp:ListItem Text="Local Production/Integration" Value="Local Production/Integration" />
                            <asp:ListItem Text="Long-Term Availability" Value="Long-Term Availability" />
                            <asp:ListItem Text="Not a Qualified Lead" Value="Not a Qualified Lead" />
                            <asp:ListItem Text="Other,Price" Value="Other,Price" />
                            <asp:ListItem Text="Product Compatible" Value="Product Compatible" />
                            <asp:ListItem Text="Product Quality" Value="Product Quality" />
                            <asp:ListItem Text="Product Specs" Value="Product Specs" />
                            <asp:ListItem Text="Project Cancelled" Value="Project Cancelled" />
                            <asp:ListItem Text="Relationship" Value="Relationship" />
                            <asp:ListItem Text="Repeat Order" Value="Repeat Order" />
                            <asp:ListItem Text="Technical Support" Value="Technical Support" />
                        </asp:DropDownList>
                    </td>
                    <th>Close Date</th>
                    <td>
                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" Format="yyyy/MM/dd" TargetControlID="txtCloseDate" />
                        <asp:TextBox runat="server" ID="txtCloseDate" Width="80px" />
                    </td>    
                    <th>Create Date</th>
                    <td>                        
                        <asp:Label runat="server" ID="lbCreateDate" Width="80px" />
                    </td>                      
                </tr>
            </table>
        </td>
    </tr>
    <tr valign="top" align="left">
        <td valign="top">
            <table width="100%">
                <tr valign="top">
                    <th align="left" style="width:80px">Description</th>
                    <td valign="top" style="width:250px">
                        <asp:TextBox runat="server" ID="txtDesc" Width="250px" Rows="5" TextMode="MultiLine" />
                    </td>   
                    <td valign="top" style="width:250px">
                        <table width="250px">
                            <tr valign="top">
                                <th align="left" colspan="4">End Customer Contact</th>
                            </tr>
                            <tr valign="top">
                                <th align="left" style="width:80px; color:Navy;">Account</th>
                                <td><asp:Label runat="server" ID="lbEndAccount" /></td>
                                <th align="left" style="width:120px; color:Navy;">Account Phone</th>
                                <td><asp:Label runat="server" ID="lbAccountTel" /></td>
                            </tr>
                            <tr valign="top">
                                <th align="left" style="width:80px; color:Navy;">Contact</th>
                                <td><a runat="server" id="lnkLeadContact"></a></td>
                                <th align="left" style="width:120px; color:Navy;">Contact Phone</th>
                                <td><asp:Label runat="server" ID="lbContactTel" /></td>
                            </tr>
                        </table>
                    </td>                       
                    <td style="width:100px">&nbsp;</td>              
                </tr>
            </table>
        </td>                       
    </tr>
    <tr align="center">
        <td>
            <asp:Button runat="server" ID="btnUpdate" Text="Update" OnClick="btnUpdate_Click" />&nbsp;&nbsp;&nbsp;
            <asp:ImageButton runat="server" ID="btnOrder" AlternateText="Place Order" ImageUrl="~/Images/shopping-cart_1.gif" OnClick="btnOrder_Click" />&nbsp;<asp:LinkButton runat="server" ID="lnkOrder" Text="Place Order" OnClick="lnkOrder_Click" />
            <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="btnUpdate" EventName="Click" />
                </Triggers>
            </asp:UpdatePanel>
        </td>
    </tr>
</table>
<asp:ObjectDataSource runat="server" ID="src1">
    <SelectParameters>
        <asp:Parameter ConvertEmptyStringToNull="false" Name="OPTYID" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="STATUS" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="OPTYNAME" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="CURR" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="AMOUNT" Type="Double" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="CREATEDATE" Type="DateTime" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="CLOSEDATE" Type="DateTime" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="GACCOUNT" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="GAPHONE" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="GCONTACT" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="GCPHONE" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="DESC" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="PRISALES" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="PRID" Type="String" />
        <asp:Parameter ConvertEmptyStringToNull="false" Name="PRCONTACTID" Type="String" />
    </SelectParameters>
</asp:ObjectDataSource>
