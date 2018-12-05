<%@ Page Title="MyAdvantech - Preview Registered Project" ValidateRequest="false" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="../Includes/ProjectDetail.ascx" tagname="ProjectDetail" tagprefix="uc1" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsInternalUser(Session("user_id")) = False Then
                If Session("account_status") <> "CP" Then
                    Server.Transfer("~/home.aspx")
                Else
                    If Session("RBU") <> "AENC" And Session("RBU") <> "AAC" Then
                        Server.Transfer("~/home.aspx")
                    End If
                End If
            End If
            If Session("RBU") = "AAC" Then
                HideforAAC.Visible = False 
            End If
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("req") Is Nothing Then Response.Redirect("ProjectRegList.aspx")
        If Not IsPostBack AndAlso Request("req") IsNot Nothing Then
            Dim M As New Us_Prjreg_M(Request("req"))
            If M Is Nothing Then Response.Redirect("ProjectRegList.aspx")
            txtexpdate.Text = USPrjRegUtil.Getdatetime(M.Expire_Date)
            tbincomm.Text = M.Internal_Comment
            lblSubmitDate.Text = M.Reg_date
            TBEndCustomer.Text = M.EndCustomer
            BindAuth(M)
            If Util.IsInternalUser2() Then tric.Visible = True
            If USPrjRegUtil.IsSalesContact(M.AdvSalesContact, M.Org_ID) Then
               ' TBEndCustomer.Enabled = True
                txtexpdate.Enabled = True
            Else
                Internal_Infor.Visible = False
                dlRejReason.Enabled = False 
            End If
        End If
    End Sub
    Public Sub BindAuth(ByVal M As Us_Prjreg_M)
        Select Case M.Status
            Case "Request"
                If USPrjRegUtil.IsSalesContact(M.AdvSalesContact, M.Org_ID) Then
                    btapp1.Enabled = True : btrej1.Enabled = True
                End If
            Case "Approve1"
                SetShow1(M)
                'Response.Write(USPrjRegUtil.GetParEmail(M.AdvSalesContact).Trim.ToLower)
                If USPrjRegUtil.IsSalesLeader(M.Org_ID) OrElse (Session("RBU") = "AAC" AndAlso USPrjRegUtil.GetRSMforAAC(M.AdvSalesContact).Trim.ToLower = Session("user_id").ToString.ToLower.Trim) Then
                    btapp2.Enabled = True : btrej2.Enabled = True
                End If
            Case "Approve2"
                SetShow1(M) : SetShow2(M)
                If USPrjRegUtil.IsProjLeader(M.Org_ID) Then
                    btapp3.Enabled= True : btrej3.Enabled= True 
                End If
            Case "WON"
                SetShow1(M) : SetShow2(M) : SetShow3(M)               
            Case "Reject1"
                SetShow1(M)
                If USPrjRegUtil.IsSalesLeader(M.Org_ID) OrElse (Session("RBU") = "AAC" AndAlso USPrjRegUtil.GetRSMforAAC(M.AdvSalesContact).Trim.ToLower = Session("user_id").ToString.ToLower.Trim) Then
                    btapp2.Enabled = True : btrej2.Enabled = True
                End If
            Case "Reject2"
                SetShow1(M) : SetShow2(M)
                If USPrjRegUtil.IsProjLeader(M.Org_ID) Then
                    btapp3.Enabled = True : btrej3.Enabled = True
                End If
            Case "LOST"
                SetShow1(M) : SetShow2(M) : SetShow3(M)
        End Select
        If M.Status.ToLower.Trim.StartsWith("reject") OrElse M.Status.ToLower.Trim.StartsWith("lost") Then dlRejReason.Items.FindByValue(M.Reject_Reason).Selected = True
    End Sub
    Public Sub SetShow1(ByVal M As Us_Prjreg_M)
        btapp1.Visible = False : btrej1.Visible = False : Lab1.Text = GetColor(M.AorR1) + " by " + GetColor(M.Approve_By1) + " on   " + GetColor(M.Approve_Date1)
    End Sub
    Public Sub SetShow2(ByVal M As Us_Prjreg_M)
        btapp2.Visible = False : btrej2.Visible = False : Lab2.Text = GetColor(M.AorR2) + " by " + GetColor(M.Approve_By2) + " on   " + GetColor(M.Approve_Date2)
    End Sub
    Public Sub SetShow3(ByVal M As Us_Prjreg_M)
        btapp3.Visible = False : btrej3.Visible = False : Lab3.Text = GetColor(M.AorR3) + " by " + GetColor(M.Approve_By3) + " on   " + GetColor(M.Approve_Date3)
    End Sub
    Public Function GetColor(ByVal str As String) As String
        If str.Contains("Approved") OrElse str.Contains("Rejected") Then
            Return (String.Format(" <font color=""Green""> ( {0} ) </font>", str))
        Else
            Return (String.Format(" <font color=""Red""> ( {0} ) </font>", str))
        End If
    End Function
    Protected Sub btapp_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btapp1.Click, btapp2.Click, btapp3.Click
        Message3.Text = ""
        Dim Error_Str As String = ""
        'If USPrjRegUtil.CheckEndCustomer(TBEndCustomer.Text, Error_Str) = False Then
        '    Message3.Text = Error_Str
        '    Exit Sub
        'End If
        Dim M As New Us_Prjreg_M(Request("req"))       
            TBEndCustomer.Text = USPrjRegUtil.GetEndCustomerRowidByOptyid(M.Opty_Id)
            If TBEndCustomer.Text.Trim = "" Then
                Message3.Text = "End Customer cannot be empty."
                Exit Sub
            End If
            Dim Stage As String = "", EmailTypeInt As Integer = 0
            Dim BT As Button = CType(sender, Button)
            Select Case BT.ID.ToLower.Trim
                Case "btapp1"
                    M.Status = "Approve1"
                    Stage = "25% Proposing/Quoting"
                    M.Approve_Date1 = Date.Now
                    M.Approve_By1 = Session("user_id")
                    M.AorR1 = "Approved"
                    EmailTypeInt = 1
                Case "btapp2"
                    M.Status = "Approve2"
                    Stage = "50% Negotiating"
                    M.Approve_Date2 = Date.Now
                    M.Approve_By2 = Session("user_id")
                    M.AorR2 = "Approved"
                    EmailTypeInt = 3
                Case "btapp3"
                    M.Status = "WON"
                    Stage = "100% Won-PO Input in SAP"
                    M.Approve_Date3 = Date.Now
                    M.Approve_By3 = Session("user_id")
                    M.AorR3 = "Won"
                    EmailTypeInt = 5
            End Select
            M.Reject_Reason = ""
            M.Internal_Comment = tbincomm.Text.Replace("'", "''")
            M.Expire_Date = CDate(txtexpdate.Text.Trim)
            M.EndCustomer = TBEndCustomer.Text.Trim.Replace("'", "''")
            M.UPDAYE_M()
            USPrjRegUtil.update_Siebel(M.Request_id, Stage)
            USPrjRegUtil.SendEmail(Request("req"), EmailTypeInt)
            Response.Redirect("ProjectApprove.aspx?Req=" & Request("req"))
    End Sub
    Protected Sub btrej_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btrej1.Click, btrej2.Click, btrej3.Click
        If dlRejReason.SelectedValue = "0" Then
            LBWarn3.Text = "Please select a reason for rejection."
            Exit Sub
        End If
        Dim EmailTypeInt As Integer = 0
        Dim M As New Us_Prjreg_M(Request("req"))
        Dim BT As Button = CType(sender, Button)
        Select Case BT.ID.ToLower.Trim
            Case "btrej1"
                M.Status = "Reject1"
                M.AorR1 = "Rejected"
                M.Approve_Date1 = Date.Now
                M.Approve_By1 = Session("user_id")
                EmailTypeInt = 2               
            Case "btrej2"
                M.Status = "Reject2"
                M.AorR2 = "Rejected"
                M.Approve_Date2 = Date.Now
                M.Approve_By2 = Session("user_id")
                EmailTypeInt = 4
            Case "btrej3"
                M.Status = "LOST"
                M.AorR3 = "Lost"
                M.Approve_Date3 = Date.Now
                M.Approve_By3 = Session("user_id")
                EmailTypeInt = 6
        End Select
        M.Reject_Reason = dlRejReason.SelectedValue.Replace("'", "''")
        M.Internal_Comment = tbincomm.Text.Replace("'", "''")
        M.Expire_Date = DateTime.Parse(txtexpdate.Text.Trim)
        M.EndCustomer = TBEndCustomer.Text.Trim.Replace("'", "''")
        M.UPDAYE_M()
        USPrjRegUtil.update_Siebel(M.Request_id, "0% Lost")
        USPrjRegUtil.SendEmail(Request("req"), EmailTypeInt)
        Response.Redirect("ProjectApprove.aspx?req=" & Request("req"))
        
    End Sub    

    Protected Sub TBEndCustomer_Load(sender As Object, e As System.EventArgs)
        If TBEndCustomer.Text.Trim <> "" Then
            Dim CustomerName As Object = dbUtil.dbExecuteScalar("CRMDB75", "select top 1 NAME from S_ORG_EXT where ROW_ID='" + TBEndCustomer.Text.Trim.Replace("'", "''") + "'")
            If CustomerName IsNot Nothing AndAlso CustomerName.ToString <> "" Then TBEndCustomerName.Text = CustomerName.ToString().Trim()
        End If   
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table style="height:100%" cellpadding="0"  align="center" cellspacing="0" width="100%" border="0">
        <tr>
            <td valign="top">
			    <table width="100%">
                    <tr>
                        <td style="height: 10px" colspan="2"></td>
                    </tr>
		            <tr>
			            <td valign="top" colspan="2" style="width: 82%">
                            <h2> Channel Partner Project Registration Application</h2>
			                <div> This project registration is subject to Advantech review.Upon approval you will received an email notification</div>
			            </td>
			        </tr>	       
			    </table>                   
			    <table border="0" cellpadding="2" cellspacing="0" width="100%">			
                    <tr>
                        <td colspan="2">
                             <uc1:ProjectDetail ID="ProjectDetail1" runat="server" />         
                        </td>
                  </tr>     
                   <tr>
                        <td colspan="2" id="Internal_Infor" runat="server">
                             <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#CCCCCC">
                                <tr >                                 
                                    <td  style="font-weight:bolder" align="center" bgcolor="#FFFFFF" width="420px">
                                        <table>
                                            <tr>
                                                   <td align="right">
                                                        End Customer:
                                                   </td>
                                                   <td>
                                                        <asp:TextBox ID="TBEndCustomer" runat="server" Visible="false" Enabled="false" OnLoad="TBEndCustomer_Load"></asp:TextBox>
                                                         <asp:Label ID="TBEndCustomerName" runat="server"  ForeColor="#f45959"></asp:Label>
                                                   </td>
                                            </tr>
                                            <tr>
                                                <td align="left" colspan="2">
                                                    <asp:Label ID="Lbalert" runat="server" Text="This field is auto fill after Added the “end customer’s name” into the “Account” field in Siebel." ForeColor="Gray"  Font-Size="12px"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right">
                                                      Expired date :
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtexpdate" runat="server" Enabled="false"></asp:TextBox>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtexpdate" Format="MM/dd/yyyy" />
                                                </td>
                                            </tr>
                                        </table>                                       
			                        </td>                  
                                    <td style="font-weight:bolder" align="left"  runat="server" valign="top" id="tric" visible="false" bgcolor="#FFFFFF">
                                         Internal Communication:<br />
                                        <asp:TextBox ID="tbincomm" TextMode="MultiLine" Height="70" Width="100%" runat="server" ></asp:TextBox>                                   
                                    </td>                                 
                                </tr>
                             </table>    
                        </td>
                  </tr>            
                    <tr>
                        <td  style="font-weight:bolder; font-size:medium; " align="left" colspan="2">Project Status Update:</td>
                    </tr>
                    <tr>
                        <td width="20%"></td>
                        <td align="left"><asp:Label ID="Message3" runat="server" Text="" ForeColor="Red" Font-Bold="false" Font-Size="12px"></asp:Label></td>
                    </tr>
                    <tr>
                        <td width="20%" style="font-weight:bolder" align="right">Submit for Review:</td>
                        <td align="left"><asp:Label ID="lblSubmitDate" runat="server"></asp:Label></td>
                    </tr>
                    <tr >
                        <td width="20%" style="font-weight:bolder" align="right">Sales Review:</td>
                        <td align="left">                      
                            <asp:Button ID="btapp1" runat="server" Text="Approve"  CssClass="btwidth"  Enabled="false" /> 
                            <asp:Button ID="btrej1" runat="server" Text="Reject"  Enabled="false" CssClass="btwidth" /> 
                            <asp:Label ID="Lab1" runat="server" Text=""></asp:Label>    
                        </td>                        
                    </tr>   
                     <tr >
                        <td width="20%" style="font-weight:bolder" align="right">Sales Management Approval:</td>
                        <td align="left">                      
                            <asp:Button ID="btapp2" runat="server" Text="Approve"  Enabled="false" CssClass="btwidth" /> 
                            <asp:Button ID="btrej2" runat="server" Text="Reject"  Enabled="false" CssClass="btwidth" />   
                            <asp:Label ID="Lab2" runat="server" Text=""></asp:Label>                         
                        </td>
                    </tr>
                    <tr  runat="server" id="HideforAAC">
                        <td width="20%" style="font-weight:bolder" align="right">Project Win or Lost:</td>
                        <td align="left">                      
                            <asp:Button ID="btapp3" runat="server" Text="Approve"  Enabled="false" CssClass="btwidth" /> 
                            <asp:Button ID="btrej3" runat="server" Text="Reject"  Enabled="false" CssClass="btwidth" />   
                            <asp:Label ID="Lab3" runat="server" Text=""></asp:Label>                         
                        </td>
                    </tr>                               
                    <tr >
                        <td width="20%" style="font-weight:bolder" align="right">Reject Reason:</td>
                        <td align="left">                            
                            <asp:DropDownList runat="server" ID="dlRejReason">
                                <asp:ListItem Value="0" >--select reason for rejection--</asp:ListItem>
                                <asp:ListItem Value="Brand Awareness" />
                                <asp:ListItem Value="Budget Cancelled" />
                                <asp:ListItem Value="Delivery time" />
                                <asp:ListItem Value="Existing Advantech Business" />
                                <asp:ListItem Value="Internal Development" />
                                <asp:ListItem Value="Local Production/Integration" />
                                <asp:ListItem Value="Long-Term Availability" />
                                <asp:ListItem Value="Not a Qualified Lead" />
                                <asp:ListItem Value="Other" />
                                <asp:ListItem Value="Price" />
                                <asp:ListItem Value="Product Compatible" />
                                <asp:ListItem Value="Product Quality" />
                                <asp:ListItem Value="Product Specs" />
                                <asp:ListItem Value="Project Cancelled" />
                                <asp:ListItem Value="Relationship" />
                                <asp:ListItem Value="Repeat Order" />
                                <asp:ListItem Value="Technical Support" />
                                <asp:ListItem Value="Need More Discovery" />
                                <asp:ListItem Value="Registered with Another Partner" />
                            </asp:DropDownList>
                            <asp:Label ID="LBWarn3" runat="server" Text="" ForeColor="Red" Font-Bold="false" Font-Size="12px"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td  colspan="2" height="15"></td>
                     </tr>
                    <tr>
                        <td width="20%" style="font-weight:bolder" align="right" ></td>
                        <td style="font-weight:bolder" align="right">
                            <asp:Label ID="lbdate" runat="server" Text="" Visible="false"></asp:Label>
                        </td>
                    </tr>
	            </table>
            </td>
        </tr>
    </table>
    <script language="javascript">
        function CheckApp() {
                var o = document.getElementById('<%=txtexpdate.ClientID %>');
                if(o.value == "")
                {
                    alert("Expired date is required!")
                    o.focus();
                    return false;
                }
        }
    </script>
</asp:Content>


