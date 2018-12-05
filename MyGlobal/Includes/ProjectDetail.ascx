<%@ Control Language="VB" ClassName="ProjectDetail" %>
<%@ Register src="../Includes/ProjectProducts.ascx" tagname="ProjectProducts" tagprefix="uc2" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Request("req") IsNot Nothing Then
                If LCase(Request.ServerVariables("PATH_INFO")) Like "*projectregdetail*" Then
                    TabContainer1.Tabs.Item(2).Visible = False
                End If

                Dim M As New Us_Prjreg_M(Request("req"))
                If M IsNot Nothing Then
                    tbapp.Text = M.Appliciant
                    tbcpartner.Text = M.CPartner
                    tbcperson.Text = M.Contact
                    tbpn.Text = M.Phone
                    tbemal.Text = M.Email
                    tbc1.Text = M.City1
                    tbs1.Text = M.State1
                    tbASC.Text = M.AdvSalesContact
                    tbcomp.Text = M.Company
                    tbadd.Text = M.Address
                    tbc2.Text = M.City2
                    tbs2.Text = M.State2
                    tbZip.Text = M.Zip
                    tbProName.Text = M.Project_Name 'lbdate.Text = M.Reg_date
                    tbPC.Text = M.Contact1 : tbPhone1.Text = M.ContactPhone1
                    tbeMail1.Text = M.ContactEMail1 : tbEC.Text = M.Contact2
                    tbPhone2.Text = M.ContactPhone2 : tbeMail2.Text = M.ContactEMail2
                    tbprotodate.Text = USPrjRegUtil.checkdatemin(M.Prototype_Date)
                    tbproductiondate.Text = USPrjRegUtil.checkdatemin(M.Production_Date)
                    lblOrg.Text = M.Org_ID
                End If
                     
                tdOrg.Visible = False
                If Util.IsANAPowerUser() Or Util.IsAEUIT() Then tdOrg.Visible = True         
                'ProjectProducts1.bindsmg()
                'ProjectProducts1.SetGV1(False)
                'If USPrjRegUtil.IsSalesLeader(Session("user_id"), .Item("Org_ID")) Then
                '    ProjectProducts1.SetGV1(True)
                'End If      
            End If
            
        End If
    End Sub
</script>

                   <ajaxToolkit:TabContainer ID="TabContainer1" runat="server"  ActiveTabIndex="1">
                       <ajaxToolkit:TabPanel runat="server" HeaderText="Applicant Info" ID="TabPanel1">
                       <ContentTemplate>
                            <table  width="100%" bgcolor="#EBEBEB">
                                <tr>
                                    <td  colspan="2" style="font-weight:bolder; font-size:medium " align="left" colspan="2">Applicant Info:</td>
                               </tr>
			                    <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Applicant:</td>
                                    <td align=left><asp:Label ID="tbapp" runat="server"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Channel:</td>
                                    <td align=left><asp:Label ID="tbcpartner" runat="server"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Contact Person:</td>
                                    <td align=left><asp:Label ID="tbcperson" runat="server"></asp:Label></td></tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Phone Number:</td>
                                    <td align=left><asp:Label ID="tbpn" runat="server"></asp:Label></td></tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Email Address:</td>
                                    <td align=left><asp:Label ID="tbemal" runat="server"></asp:Label></td></tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>City:</td>
                                    <td align=left> <asp:Label ID="tbc1" runat="server"></asp:Label> </td></tr>
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>State:</td>
                                    <td align=left> <asp:Label ID="tbs1" runat="server"></asp:Label></td></tr>                             
                                <tr>
                                    <td width="40%" style="font-weight:bolder" align=right>Advantech Sales Contact:</td>
                                    <td align=left><asp:Label ID="tbASC" runat="server"></asp:Label></td></tr>
                            <tr id="tdOrg" runat="server" >
                                  <td  style="font-weight:bolder" align=right>Org ID <font color='red' >(Internal Only):</font></td>
                                  <td align=left><asp:Label ID="lblOrg" runat="server"></asp:Label></td></tr>
                                <tr>
                            </table>
                       </ContentTemplate>
                       </ajaxToolkit:TabPanel>
                       <ajaxToolkit:TabPanel ID="TabPanel2" runat="server" HeaderText="Project Registration Info">
                       <ContentTemplate>
                        <table  width="100%" bgcolor="#EBEBEB">
                                    <tr>
                                        <td style="font-weight:bolder; font-size:medium " align="left" colspan="2">Project Registration Info:</td>
                                    </tr>
                                    <tr>
                                        <td width="40%"  style="font-weight:bolder" align=right>Company:</td>
                                        <td align=left><asp:Label ID="tbcomp" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                        <td  style="font-weight:bolder" align=right>Address:</td>
                                        <td align=left><asp:Label ID="tbadd" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                        <td  style="font-weight:bolder" align=right>City and State:</td>
                                        <td align=left> City: <asp:Label ID="tbc2" runat="server"></asp:Label> &nbsp; State: <asp:Label ID="tbs2" runat="server"></asp:Label></td>
                                   </tr>
                                   <tr>
                                        <td  style="font-weight:bolder" align=right>Zip:</td>
                                        <td align=left> <asp:Label ID="tbZip" runat="server"></asp:Label></td>
                                   </tr>
                                   <tr>
                                        <td  style="font-weight:bolder" align=right>Project Name:</td>
                                        <td align=left><asp:Label ID="tbProName" runat="server"></asp:Label></td>
                                   </tr>
                                   <tr>
                                        <td style="font-weight:bolder" align=right>Procument Contact:</td>
                                        <td valign=middle align=left ><asp:Label ID="tbPC" runat="server"></asp:Label>
			                                &nbsp;&nbsp;<span style="font-weight:bolder">Phone:</span><asp:Label ID="tbPhone1" runat="server"></asp:Label>&nbsp;&nbsp;<span style="font-weight:bolder">eMail:</span><asp:Label ID="tbeMail1" runat="server"></asp:Label>
			                            </td>
                                    </tr>
			                        <tr>
                                        <td  style="font-weight:bolder" align=right>Engineering Contact:</td>
                                        <td valign=middle align=left><asp:Label ID="tbEC" runat="server"></asp:Label>
			                                &nbsp;&nbsp;<span style="font-weight:bolder">Phone:</span><asp:Label ID="tbPhone2" runat="server"></asp:Label>&nbsp;&nbsp;<span style="font-weight:bolder">eMail:</span><asp:Label ID="tbeMail2" runat="server"></asp:Label>
			                            </td>
                                   </tr>
			                       <tr>
                                       <td  style="font-weight:bolder" align=right>Prototype Date:</td>
                                       <td align=left><asp:Label ID="tbprotodate" runat="server"></asp:Label></td>
                                   </tr>
			                       <tr>
                                       <td  style="font-weight:bolder" align=right>Production Date:</td>
                                       <td align=left><asp:Label ID="tbproductiondate" runat="server"></asp:Label></td>
                                  </tr>                                
                              </table>
                       </ContentTemplate>
                       </ajaxToolkit:TabPanel>
                          <ajaxToolkit:TabPanel ID="TabPanel3" runat="server" HeaderText="Products included in Project">
                               <ContentTemplate>
                                    <asp:UpdatePanel runat="server" ID="upGvProduct" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <uc2:ProjectProducts ID="ProjectProducts1" runat="server" />       
                                        </ContentTemplate>
                                    </asp:UpdatePanel>      
                               </ContentTemplate>
                           </ajaxToolkit:TabPanel>
                   </ajaxToolkit:TabContainer>
     


