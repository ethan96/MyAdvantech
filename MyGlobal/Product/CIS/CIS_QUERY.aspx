<%@ Page Language="C#" Title="MyAdvantech - CIS Query" MasterPageFile="~/includes/MyMaster.master" AutoEventWireup="true" CodeFile="CIS_QUERY.aspx.cs" Inherits="CIS_QUERY" EnableSessionState="True"  %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register src="nva.ascx" tagname="nva" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                          <tr>
                                          <td style="width:8px; height: 28px" >&nbsp;</td>
                                          <td align="center" class="text">&nbsp;</td>
                                            <td style="width:8px; height: 28px" align="left" class="text">&nbsp;</td>
                                            <td style="text-align: right">
                                            <uc1:nva ID="nva1" runat="server" />&nbsp;</td>
                                            </tr>
                                        <tr>
                                            <td style="width: 8px; height: 28px">
                                                <img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" />
                                            </td>
                                            <td align="center" class="text" style="height: 28px; width: 180px; background-image: url(Images/frame_new_BG.jpg);
                                                color: #3E7CEE">
                                                <b>Display Setting</b>
                                            </td>
                                            <td style="width: 8px; height: 28px" align="left" class="text">
                                                <img alt='' src="./images/frame_new_right.jpg" width="8" height="28" />
                                            </td>
                                            <td>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 1px; background-color: #D0D7DD" colspan="4" align="right" class="text">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Panel ID="panelSelectitem" runat="server">
                                        <table width="100%">
                                            <tr>
                                                <td style="width: 300px" align="right">
                                                    <asp:ListBox ID="lbSelItems" runat="server" Width="200px" Height="150px" CssClass="text">
                                                    </asp:ListBox>
                                                </td>
                                                <td style="width: 50px" align="center">
                                                    <asp:Button ID="btnSelall" runat="server" Text=">>" Width="45px" ToolTip="Select all fields"
                                                        OnClick="btnSelall_Click" />
                                                    <asp:Button ID="btnSelone" runat="server" Text=">" Width="45px" ToolTip="Select one field"
                                                        OnClick="btnSelone_Click" />
                                                    <asp:Button ID="btnDelone" runat="server" Text="<" Width="45px" ToolTip="Cancel one field"
                                                        OnClick="btnDelone_Click" />
                                                    <asp:Button ID="btnDelall" runat="server" Text="<<" Width="45px" ToolTip="Cancel all fields"
                                                        OnClick="btnDelall_Click" />
                                                </td>
                                                <td style="width: 200px" align="center">
                                                    <asp:ListBox ID="lbChoiceItems" runat="server" Width="200px" Height="150px" CssClass="text">
                                                    </asp:ListBox>
                                                </td>
                                                <td style="width: 50px" align="left">
                                                    <asp:Button ID="btnFieldUp" runat="server" Text="^" Width="45px" ToolTip="Move field up"
                                                        OnClick="btnFieldUp_Click" />
                                                    <asp:Button ID="btnFieldDown" runat="server" Text="v" Width="45px" ToolTip="Move field down"
                                                        OnClick="btnFieldDown_Click" />
                                                </td>
                                                <td>
                                                    <asp:Panel ID="panelComponent" runat="server" ScrollBars="Auto" Width="350px" Height="200px"
                                                        BorderStyle="Groove">
                                                        <asp:Label ID="txtComSel" runat="server" Text="" Visible="false"></asp:Label>
                                                        <asp:TreeView ID="tvComponent" runat="server" ShowLines="True" Width="330px" Height="180px"
                                                            CssClass="text" OnSelectedNodeChanged="tvComponent_SelectedNodeChanged">
                                                        </asp:TreeView>
                                                    </asp:Panel>
                                                </td>
                                            </tr>
                                        </table>
                                    </asp:Panel>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td style="width: 8px; height: 28px">
                                                <img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" />
                                            </td>
                                            <td align="center" class="text" style="height: 28px; width: 180px; background-image: url(Images/frame_new_BG.jpg);
                                                color: #3E7CEE">
                                                <b>Query Condition</b>
                                            </td>
                                            <td style="width: 8px; height: 28px" align="left" class="text">
                                                <img alt='' src="./images/frame_new_right.jpg" width="8" height="28" />
                                            </td>
                                            <td>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 1px; background-color: #D0D7DD" colspan="4" align="right" class="text">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="80%">
                                        <tr>
                                            <td style="width: 100px">
                                                &nbsp;
                                            </td>
                                            <td class="text">
                                                Operand
                                            </td>
                                            <td class="text">
                                                Bracket
                                            </td>
                                            <td class="text">
                                                Property
                                            </td>
                                            <td class="text">
                                                Condition
                                            </td>
                                            <td class="text">
                                                Values
                                            </td>
                                            <td class="text">
                                                Action
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlOperand" runat="server" CssClass="text">
                                                    <asp:ListItem>AND</asp:ListItem>
                                                    <asp:ListItem>OR</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlBracket" runat="server" CssClass="text" Width="50px">
                                                    <asp:ListItem></asp:ListItem>
                                                    <asp:ListItem>(</asp:ListItem>
                                                    <asp:ListItem>)</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlSubject" runat="server" CssClass="text">
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlCondition" runat="server" CssClass="text" Width="50px">
                                                    <asp:ListItem>=</asp:ListItem>
                                                    <asp:ListItem>&gt;</asp:ListItem>
                                                    <asp:ListItem>&lt;</asp:ListItem>
                                                    <asp:ListItem>≠</asp:ListItem>
                                                    <asp:ListItem>like</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtValues" runat="server" Width="250px" CssClass="text"></asp:TextBox>
                                            </td>
                                            <td>
                                                <asp:Button ID="btnAction" runat="server" Text="ADD" CssClass="text" ToolTip="Add query condition"
                                                    OnClick="btnAction_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="80%">
                                        <tr>
                                            <td style="width: 100px">
                                            </td>
                                            <td align="left">
                                                <asp:GridView ID="gvSQLCondition" runat="server" AutoGenerateColumns="False" CssClass="text"
                                                    OnRowCancelingEdit="gvSQLCondition_RowCancelingEdit" OnRowDataBound="gvSQLCondition_RowDataBound"
                                                    OnRowDeleting="gvSQLCondition_RowDeleting" OnRowEditing="gvSQLCondition_RowEditing"
                                                    OnRowUpdating="gvSQLCondition_RowUpdating">
                                                    <Columns>
                                                        <asp:BoundField DataField="SEQ" HeaderText="SEQ" />
                                                        <asp:BoundField DataField="OPERAND" HeaderText="OPERAND" ReadOnly="true" />
                                                        <asp:BoundField DataField="BRACKET" HeaderText="BRACKET" ReadOnly="true" />
                                                        <asp:BoundField DataField="FIELD_SUBJECT" HeaderText="Subject" ReadOnly="true" />
                                                        <asp:BoundField DataField="CONDITION" HeaderText="Condition" ReadOnly="true" />
                                                        <asp:BoundField DataField="SQL_VALUE" HeaderText="Value" />
                                                        <asp:CommandField ShowEditButton="True" HeaderText="Action" ShowDeleteButton="True" />
                                                    </Columns>
                                                    <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                                </asp:GridView>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 650px">
                                    <asp:TextBox ID="txtSQLStatement" runat="server" TextMode="MultiLine" Height="150px"
                                        Width="650px" Enabled="false" Visible="false"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <table>
                                        <tr>
                                            <td style="width: 100px">
                                            </td>
                                            <td>
                                                <asp:Button ID="btnQuery" runat="server" Text="Query" CssClass="text" OnClick="btnQuery_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td style="width: 8px; height: 28px">
                                                <img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" />
                                            </td>
                                            <td align="center" class="text" style="height: 28px; width: 180px; background-image: url(Images/frame_new_BG.jpg);
                                                color: #3E7CEE">
                                                <b>Query Result</b>
                                            </td>
                                            <td style="width: 8px; height: 28px" align="left" class="text">
                                                <img alt='' src="./images/frame_new_right.jpg" width="8" height="28" />
                                            </td>
                                            <td align="right">
                                                <asp:Button ID="btnSave" runat="server" Text="Save Search" CssClass="text" />
                                                <cc1:ModalPopupExtender ID="btnSave_ModalPopupExtender" runat="server" DynamicServicePath=""
                                                    Enabled="True" TargetControlID="btnSave" DropShadow="True" PopupControlID="pnlModalPopup"
                                                    CancelControlID="imgBtnContinue" PopupDragHandleControlID="pnlModalPopup" BackgroundCssClass="cssModalBackground">
                                                </cc1:ModalPopupExtender>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 1px; background-color: #D0D7DD" colspan="4" align="right" class="text">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <asp:Panel ID="pnlgvShow" runat="server" Width="960px" ScrollBars="Auto">
                                        <table>
                                            <tr>
                                                <td style="width: 100px">
                                                </td>
                                                <td>
                                                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ACLSLQ1-CIS %>">
                                                    </asp:SqlDataSource>
                                                    <asp:GridView ID="gvSQLshow" runat="server" AllowPaging="True" AllowSorting="true"
                                                        AutoGenerateColumns="false" CssClass="text" DataSourceID="SqlDataSource1" BackColor="White"
                                                        BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal"
                                                        PageSize="20" OnPageIndexChanging="gvSQLshow_PageIndexChanging" OnSorting="gvSQLshow_Sorting"
                                                        OnRowDataBound="gvSQLshow_RowDataBound">
                                                        <RowStyle CssClass="RowStyle" />
                                                         <EmptyDataTemplate>
                                            <span lang="EN-US" 
                                                style="font-size: 12.0pt; font-family: &quot;Calibri&quot;,&quot;sans-serif&quot;; mso-fareast-font-family: SimSun; mso-bidi-font-family: SimSun; color: #1F497D; mso-ansi-language: EN-US; mso-fareast-language: ZH-TW; mso-bidi-language: AR-SA">
                                            No records to display.</span>
                                        </EmptyDataTemplate>
                                                        <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                                                        <PagerStyle CssClass="PageStyle" />
                                                        <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                                                        <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                                                        <AlternatingRowStyle BackColor="#F7F7F7" />
                                                    </asp:GridView>
                                                </td>
                                            </tr>
                                        </table>
                                    </asp:Panel>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <!-- Modal Popup-->
    <asp:Panel ID="pnlModalPopup" runat="server" Style="display: none" BackColor="#F0F0F0"
        OnLoad="pnlModalPopup_Load">
        <table style="border-style: ridge">
            <tr>
                <td colspan="2">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="width: 8px; height: 28px">
                                <img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" />
                            </td>
                            <td align="center" class="text" style="height: 28px; width: 180px; background-image: url(Images/frame_new_BG.jpg);
                                color: #3E7CEE">
                                <b>Template Save function</b>
                            </td>
                            <td style="width: 8px; height: 28px" align="left" class="text">
                                <img alt='' src="./images/frame_new_right.jpg" width="8" height="28" />
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 1px; background-color: #D0D7DD" colspan="4" align="right" class="text">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td class="title_big">
                    Name:
                </td>
                <td>
                    <asp:TextBox ID="txtName" runat="server" Width="250px"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="title_big">
                    Description:
                </td>
                <td>
                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Height="180px"
                        Width="250px"></asp:TextBox>
                </td>
            </tr>
            <tr id="trSaveFunction" visible="true" runat="server">
                <td>
                    <asp:ImageButton ID="imgBtnSave" runat="server" ImageUrl="Images/24-tag-pencil.png"
                        Width="30px" Height="30px" OnClick="pnlbtnSave_Click" ToolTip="Save file" />
                    <asp:ImageButton ID="imgBtnSaveAs" Visible="false" Enabled="false" runat="server"
                        ImageUrl="Images/24-tag-manager.png" Width="30px" Height="30px" OnClick="pnlbtnSaveAs_Click"
                        ToolTip="Save as other name" />
                </td>
                <td>
                    <asp:ImageButton ID="imgBtnContinue" runat="server" ImageUrl="Images/stock_refresh.png"
                        Width="20px" Height="20px" ToolTip="Back to user define page" />
                </td>
            </tr>
        </table>
    </asp:Panel>
    <asp:UpdatePanel ID="upFooter" runat="server">
        <ContentTemplate>
            <table width="100%">
                <tr>
                    <td>
                        <asp:Panel ID="pnlFooter" runat="server" Visible="false">
                            <table width="900px" style="border-style: outset; background-color: #CCCCCC">
                                <tr>
                                    <td style="width: 100px">
                                        <asp:Label ID="lblMsgTittle" runat="server" Text="Status" Font-Names="Times New Roman"
                                            ForeColor="#000099"></asp:Label>
                                    </td>
                                    <td style="width: 500px">
                                        <asp:Label ID="lblMsgContext" runat="server" Width="300px" ForeColor="Red"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                        <cc1:AlwaysVisibleControlExtender ID="pnlFooter_AlwaysVisibleControlExtender" runat="server"
                            Enabled="True" TargetControlID="pnlFooter" VerticalSide="Bottom" HorizontalSide="Center">
                        </cc1:AlwaysVisibleControlExtender>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

