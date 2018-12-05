<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CIS_TEMPLATE.aspx.cs" Inherits="CIS_TEMPLATE" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech CIS Template" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register src="nva.ascx" tagname="nva" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

<table width="100%"> 
    <tr>
        <td>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <table width="100%">
                <tr >
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                        <td style="width: 8px; height: 28px">
                                            &nbsp;</td>
                                        <td align="center" class="text">
                                            &nbsp;</td>
                                        <td align="left" class="text" style="width: 8px; height: 28px">
                                            &nbsp;</td>
                                        <td style="text-align: right">
                                            <uc1:nva ID="nva1" runat="server" />
                                        </td>
                                    </tr>
                            <tr>
                                <td style="width:8px; height: 28px" ><img alt='' src="./Images/frame_new_left.jpg" width="8" height="28" /></td>
                                <td align="center" class="text" style="height: 28px; width:180px; background-image: url(Images/frame_new_BG.jpg); color:#3E7CEE"><b>Query Template</b></td>
                                <td style="width:8px; height: 28px" align="left" class="text"><img alt='' src="./images/frame_new_right.jpg" width="8" height="28" /></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td style="height:1px; background-color:#D0D7DD" colspan="4" align="right" class="text"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>    
                    <td>
                        <asp:GridView ID="gvQueryHistory" runat="server"  CssClass="text"
                            DataSourceID="SqlDataSource1"
                            AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" 
                            GridLines="None" onpageindexchanging="gvQueryHistory_PageIndexChanging" 
                            onrowcommand="gvQueryHistory_RowCommand" 
                            onrowdatabound="gvQueryHistory_RowDataBound" 
                            onrowdeleting="gvQueryHistory_RowDeleting" 
                            OnSorting ="gvQueryHistory_Sorting"
                            PageSize="15" 
                            AllowSorting="True">
                            <RowStyle BackColor="#EFF3FB" Width="720px" />
                            <Columns>
                                <asp:BoundField DataField="SEQ" HeaderText="SEQ" />
                                <asp:BoundField DataField="ID" HeaderText="ID" />
                                <asp:BoundField DataField="FILE_NAME" HeaderText="NAME" SortExpression="FILE_NAME">
                                    <HeaderStyle BorderWidth="1px"/>
                                    <ItemStyle  Font-Names="Times New Roman" />
                                </asp:BoundField>
                                <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" SortExpression ="DESCRIPTION">
                                    <HeaderStyle BorderWidth="1px"  />
                                    <ItemStyle   />
                                </asp:BoundField>
                                <asp:BoundField DataField="CREATE_DATE" HeaderText="CREATE DATE"  SortExpression="CREATE_DATE" ReadOnly="True">
                                    <HeaderStyle BorderWidth="1px" Width="100px" />
                                    <ItemStyle  Font-Names="Times New Roman" />
                                </asp:BoundField>
                                <asp:CommandField HeaderText="Action" ShowDeleteButton="True">
                                    <HeaderStyle BorderWidth="1px" />
                                    <ItemStyle  Font-Names="Times New Roman" HorizontalAlign="center"/>
                                </asp:CommandField>
                                <asp:ButtonField CommandName="implement" HeaderText="Template" ImageUrl="./images/24-tool-a.png" ButtonType="Image"  >
                                    <HeaderStyle BorderWidth="1px" HorizontalAlign="Center" />
                                    <ItemStyle HorizontalAlign="Center"/>
                                </asp:ButtonField>
                                <asp:ButtonField CommandName="query" HeaderText="Query" ImageUrl="images/24-zoom.png" ButtonType="Image" >
                                    <HeaderStyle BorderWidth="1px"  HorizontalAlign="Center"/>
                                    <ItemStyle HorizontalAlign="Center"/>
                                </asp:ButtonField>
                            </Columns>
                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                            <EditRowStyle BackColor="YellowGreen" />
                            <AlternatingRowStyle BackColor="White" />
                        </asp:GridView>
                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString ="<%$ ConnectionStrings:QS %>"></asp:SqlDataSource>
                    </td>
                </tr>
            </table>
            </ContentTemplate>
            </asp:UpdatePanel> 
        </td>
    </tr>
</table>
    
<asp:UpdatePanel ID="upFooter" runat="server">
    <ContentTemplate >
    <table width="1024px">
        <tr>
            <td>
                <asp:Panel ID="pnlFooter" runat="server" Visible="false">
                    <table width="900px" style="border-style: outset; background-color:#CCCCCC">
                        <tr>                            
                            <td style="width:100px">
                                <asp:Label ID="Label1" runat="server" Text="Status" Font-Names="Times New Roman" ForeColor="#000099"></asp:Label>
                            </td>
                            <td style="width:500px">
                                <asp:Label ID="lblMsgContext" runat="server" Width="300px" ForeColor="Red" ></asp:Label>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <cc1:alwaysvisiblecontrolextender ID="pnlFooter_AlwaysVisibleControlExtender" runat="server" Enabled="True" TargetControlID="pnlFooter" VerticalSide="Bottom" HorizontalSide="Center"></cc1:alwaysvisiblecontrolextender>                
            </td>
        </tr>
    </table>
    </ContentTemplate>
    </asp:UpdatePanel>      


</asp:Content>

   
    
    
    

