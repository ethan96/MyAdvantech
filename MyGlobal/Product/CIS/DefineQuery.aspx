<%@ Page Language="C#" EnableEventValidation = "false" AutoEventWireup="true" CodeFile="DefineQuery.aspx.cs" Inherits="DefineQuery" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Define CIS Query" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register src="nva.ascx" tagname="nva" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<table width="100%"> 
    <tr>
        <td>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <table>
                <tr>
                    <td >
                     <table width="100%">  <tr>   <td>&nbsp;</td>
					                <td style="text-align: right;">
					                    <uc1:nva ID="nva1" runat="server" />
					                </td></tr>
	    		                </table>
                        <asp:Panel ID="plUserDefine" runat="server" Width="100%">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0" class="text" style="height:25px" >
				                <tr>
                                 
					                <td style="background-image: url('images/lb_ll.gif'); width:10px"></td>
					                <td style="background-image: url('images/lb_lm.gif'); width:930px">
					                    <table style="padding:5px ; cursor:pointer;" class="text">
                                            <tr>
                                                <td style="width:20px"></td>
                                                <td style="width:930px" align="left">
                                                    <asp:Label ID="lblMainTittleDefine" runat="server" Text="Query Function" ForeColor="White"></asp:Label>
                                                </td>
                                                <td style="width:80px">
                                                    <asp:Image ID="imgMainTittleDefine" runat="server" ImageUrl="Images/icon_down.gif" />
                                                    <asp:Label ID="lblCollapsibleStatusDefine" runat="server" Text="Close" ForeColor="White" ></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
					                </td>
					                <td style="background-image: url('images/lb_lr.gif'); width:10px"></td>
    				            </tr>
	    		            </table>
                        </asp:Panel>
                        <asp:Panel ID="plSubUserDefine" runat ="server" Width="100%">
                            <table width="100%" >
                                <tr >
                                    <td class="text">Operand</td>
                                    <td class="text">Bracket</td>
                                    <td class="text">Property</td>
                                    <td class="text">Condition</td>
                                    <td class="text">Values</td>
                                    <td class="text">Action</td>
                                </tr>
                                <tr>
                                    <td class="text" valign="top">
                                        <asp:DropDownList ID="ddlOperand" runat="server" CssClass="text">
                                            <asp:ListItem>AND</asp:ListItem>
                                            <asp:ListItem>OR</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td class="text" valign="top">
                                        <asp:DropDownList ID="ddlBracket" runat="server" CssClass="text">
                                            <asp:ListItem></asp:ListItem>
                                            <asp:ListItem>(</asp:ListItem>
                                            <asp:ListItem>)</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td valign="top">
                                        <asp:DropDownList ID="ddlSubject" runat="server" CssClass="text"></asp:DropDownList>
                                    </td>
                                    <td class="text" valign="top">
                                        <asp:DropDownList ID="ddlCondition" runat="server" CssClass="text">
                                            <asp:ListItem>=</asp:ListItem>
                                            <asp:ListItem>&gt;</asp:ListItem>
                                            <asp:ListItem>&lt;</asp:ListItem>
                                            <asp:ListItem>≠</asp:ListItem>
                                            <asp:ListItem>like</asp:ListItem>                        
                                        </asp:DropDownList>
                                    </td>
                                    <td valign="top">
                                        <asp:TextBox ID="txtValues" runat="server" Width="250px" CssClass="text"></asp:TextBox>
                                    </td>
                                    <td valign="top">
                                        <asp:Button ID="btnAction" runat="server" Text="ADD" onclick="btnAction_Click" CssClass="text"/>
                                    </td>
                                    <td rowspan="6">
                                        <asp:Panel ID="panelComponent" runat="server" ScrollBars="Auto" Width="300px" Height="200px" BorderStyle="Groove">
                                            <asp:TreeView ID="tvComponent" runat="server" ShowLines="True" Width="280px" Height = "180px" CssClass="text" OnSelectedNodeChanged="tvComponent_SelectedNodeChanged"></asp:TreeView>
                                            <asp:Label ID="txtComSel" runat="server" Text="" Visible="false"></asp:Label>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                
                                <tr id="trUserDefine"  runat ="server" visible = "false">
                                    <td colspan = "6">
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td style="width:8px; height: 28px" ><img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" /></td>
                                                <td align="center" class="text" style="height: 28px; width:180px; background-image: url(Images/frame_new_BG.jpg); color:#3E7CEE"><b>User Define</b></td>
                                                <td style="width:8px; height: 28px" align="left" class="text"><img alt='' src="images/frame_new_right.jpg" width="8" height="28" /></td>
                                                <td align="right"> <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="text" onclick="btnSave_Click" /></td>
                                            </tr>
                                            <tr>
                                                <td style="height:1px; background-color:#D0D7DD" colspan="4" align="right" class="text"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6" style="widows:700px">
                                    
                                        <asp:GridView ID="gvUserDefine" runat="server"  CssClass="text"
                                            AutoGenerateColumns="False" OnRowCancelingEdit="gvUserDefine_RowCancelingEdit" 
                                            OnRowDataBound="gvUserDefine_RowDataBound" 
                                            OnRowDeleting="gvUserDefine_RowDeleting" OnRowEditing="gvUserDefine_RowEditing" 
                                            OnRowUpdating="gvUserDefine_RowUpdating">
                                            <Columns>
                                                <asp:BoundField DataField="SEQ" HeaderText="SEQ" />
                                                <asp:BoundField DataField="OPERAND" HeaderText="Operand" ReadOnly="true" />
                                                <asp:BoundField DataField="BRACKET" HeaderText="Bracket" ReadOnly="true" />
                                                <asp:BoundField DataField="FIELD_SUBJECT" HeaderText="FIELD" ReadOnly="true"/>
                                                <asp:BoundField DataField="CONDITION" HeaderText="CONDITION" ReadOnly="true"/>
                                                <asp:BoundField DataField="SQL_VALUE" HeaderText="VALUE" />
                                                <asp:CommandField HeaderText="Action" ShowDeleteButton="True" ShowEditButton="True" />
                                            </Columns>
                                              <EmptyDataTemplate>
                                                <span lang="EN-US" style="font-size:12.0pt;font-family:
&quot;Calibri&quot;,&quot;sans-serif&quot;;mso-fareast-font-family:SimSun;mso-bidi-font-family:
SimSun;color:#1F497D;mso-ansi-language:EN-US;mso-fareast-language:ZH-TW;
mso-bidi-language:AR-SA">No records to display.</span>
                                            </EmptyDataTemplate>
                                            <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                            <RowStyle  />
                                        </asp:GridView>
                                    </td>
                                </tr>
                                <tr id="trPreview"  runat ="server" visible = "false">
                                    <td colspan = "6">
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td style="width:8px; height: 28px" ><img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" /></td>
                                                <td align="center" class="text" style="height: 28px; width:180px; background-image: url(Images/frame_new_BG.jpg); color:#3E7CEE"><b>PreView</b></td>
                                                <td style="width:8px; height: 28px" align="left" class="text"><img alt='' src="images/frame_new_right.jpg" width="8" height="28" /></td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td style="height:1px; background-color:#D0D7DD" colspan="4" align="right" class="text"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trPreviewData"  runat ="server" visible = "false ">
                                    <td colspan="6" style="width:650px">
                                        <asp:TextBox ID="txtSQLStatement" runat="server" TextMode="MultiLine" Height="150px" Width="650px" Enabled ="false" Visible= "true"></asp:TextBox>
                                    </td>
                                </tr>    
                            </table> 
                        </asp:Panel>
                        <cc1:CollapsiblePanelExtender ID="cpeQuery" runat="server" Enabled="True" TargetControlID="plSubUserDefine" CollapseControlID="plUserDefine" ExpandControlID="plUserDefine" TextLabelID="lblCollapsibleStatusDefine" ImageControlID="imgMainTittleDefine" CollapsedImage ="Images/icon_down.gif" ExpandedImage="Images/icon_up.gif" CollapsedText="Expand" ExpandedText="Close" ExpandDirection="Vertical" SuppressPostBack="true" collapsed = "true" >
                        </cc1:CollapsiblePanelExtender>
                    </td>
                </tr>
            
                <tr>
                    <td colspan="2">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td style="width:8px; height: 28px" ><img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" /></td>
                                <td align="center" class="text" style="height: 28px; width:180px; background-image: url(Images/frame_new_BG.jpg); color:#3E7CEE"><b>Show</b></td>
                                <td style="width:8px; height: 28px" align="left" class="text"><img alt='' src="images/frame_new_right.jpg" width="8" height="28" /></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td style="height:1px; background-color:#D0D7DD" colspan="4" align="right" class="text"></td>
                            </tr>
                        </table>       
                    </td>
                </tr>
                <tr>
                    <td >
                        <asp:Panel ID="pnlgvShow" runat="server"  Height ="600px" Width="980px" ScrollBars="Auto">
                            <table>
                            <tr>
                                <td style="width:100px"></td>
                                <td>
                                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString ="<%$ connectionStrings: ACLSLQ1-CIS %>"></asp:SqlDataSource>
                                    <asp:GridView ID="gvUserDefineShow" runat="server" CellPadding="4"  CssClass="text"
                                        DataSourceID="SqlDataSource1"
                                        ForeColor="#333333" GridLines="None" AllowSorting="True" 
                                        AllowPaging="true" PageSize="20"
                                        onpageindexchanging="gvUserDefineShow_PageIndexChanging" 
                                        onsorting="gvUserDefineShow_Sorting" 
                                        onrowdatabound="gvUserDefineShow_RowDataBound">
                                        <RowStyle BackColor="#EFF3FB" />
                                        <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                        <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="left" />
                                        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                        <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                        <EditRowStyle BackColor="#2461BF" />
                                        <AlternatingRowStyle BackColor="White" />
                                    </asp:GridView>
                                </td>
                            </tr>
                            </table>
                        </asp:Panel>
                        
                    </td>
                </tr>
            </table>
            </ContentTemplate>
            </asp:UpdatePanel>
        </td>
    </tr>
</table>

<!-- Footer -->
<asp:UpdatePanel ID="upFooter" runat="server">
<ContentTemplate >
<table width="1024px">
    <tr>
        <td>
            <asp:Panel ID="pnlFooter" runat="server" Visible="false">
                <table width="900px" style="border-style: outset; background-color:#CCCCCC">
                    <tr> 
                        <td style="width:100px"><asp:Label ID="lblMsgTittle" runat="server" Text="Status" Font-Names="Times New Roman" ForeColor="#000099"></asp:Label></td>
                        <td style="width:500px"><asp:Label ID="lblMsgContext" runat="server" Width="300px" ForeColor="Red" ></asp:Label></td>
                    </tr>
                </table>
            </asp:Panel>
            <cc1:alwaysvisiblecontrolextender ID="pnlFooter_AlwaysVisibleControlExtender" runat="server" Enabled="True" TargetControlID="pnlFooter" VerticalSide="Bottom" HorizontalSide="Center"></cc1:alwaysvisiblecontrolextender>                
        </td>
    </tr>
</table>
</ContentTemplate>
</asp:UpdatePanel>  

<script language="javascript" type="text/javascript" src="JS/Right_Lock.js"></script>

</asp:Content>