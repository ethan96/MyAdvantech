<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CBOM_ListV2.aspx.cs" Inherits="Lab_CBOMV2_CBOM_ListV2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">

    <table width="100%">
        <tr>
            <td>
                <table width="100%" id="Table2">
                    <tr valign="top">
                        <td height="2">&nbsp;
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="pagetitle">
                            <table width="100%" id="Table1" border="0">
                                <tr>
                                    <td width="230">
                                        <div class="euPageTitle">Configuration List</div>
                                    </td>
                                    <td><font face="Tahoma" size="2" color="Crimson"><b>::: <%=GetLocalName()%></b></font></td>
                                    <td align="right" valign="bottom"><font face="Arial" color="RoyalBlue">
                                        <a href="mailto:myadvantech@advantech.com">? Feedbacks to Advantech BTOS Contacts</a></font>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="230"></td>
                                    <td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="15"></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="plSearch" DefaultButton="btndm">
                                <label class="lbStyle">Search:</label>
                                <asp:TextBox ID="txtSearch" runat="server" onkeyup="filter('ctl00__main_AdxGrid1',this.value)"></asp:TextBox>
                                <asp:Label ID="errMsg" runat="server" ForeColor="Red"></asp:Label>
                                <asp:Button runat="server" ID="btndm" Enabled="false" Style="display: none" />
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td align="center">
                            <table cellpadding="1" width="100%">
                                <tr>
                                    <td style="background-color: #666666">
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle" id="Table3">
                                            <tr>
                                                <td style="padding-left: 10px; border-bottom: #ffffff 1px solid; height: 20px; background-color: #6699CC"
                                                    align="left" valign="middle" class="text">
                                                    <font color="#ffffff"><b>Configuration Listing</b></font>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:GridView runat="server" ID="gvList" Width="100%" DataKeyNames="ID" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound" DataSourceID="SqlDataSource1">
                                                        <Columns>
                                                            <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                                                                <HeaderTemplate>
                                                                    No.
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <%# Container.DataItemIndex + 1 %>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:BoundField DataField="CATALOG_NAME" HeaderText="BTO Description" ItemStyle-CssClass="Tnowrap" ItemStyle-Width="15%" />
                                                            <asp:BoundField DataField="CATALOG_DESC" HeaderText="Group Description" />
                                                            <asp:BoundField DataField="" HeaderText="Image" Visible="false" />
                                                            <asp:BoundField DataField="COMPANY_ID" HeaderText="Company ID" Visible="false" />
                                                            <asp:TemplateField HeaderText="QTY" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="5%">
                                                                <ItemTemplate>
                                                                    <asp:TextBox runat="server" ID="txtQty" Text="1" Width="30px" Style="text-align: right" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Assemble" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                                                <ItemTemplate>
                                                                    <asp:ImageButton runat="server" ID="imgBtnConfig" ImageUrl="~/Images/ebiz.aeu.face/btn_Config.GIF" OnClick="imgBtnConfig_Click"/>
                                                                    <asp:HiddenField runat="server" ID="hfConfig1" Value='<%#Eval("CATEGORY_GUID")%>' />
                                                                    <asp:HiddenField runat="server" ID="hfConfig2" Value='<%#Eval("CATEGORY_NAME")%>' />
                                                                    <asp:HiddenField runat="server" ID="hfVisibilityCount" Value='<%#Eval("VisibilityCount")%>' />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Center" Visible="false" ItemStyle-Width="10%">
                                                                <ItemTemplate>
                                                                    <asp:ImageButton runat="server" ID="imgBtnEdit" ImageUrl="~/Images/ebiz.aeu.face/btn_Edit.GIF" OnClick="imgBtnEdit_Click" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:CBOMV2 %>" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdTotal" align="right" style="background-color: #ffffff" runat="server"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td height="2">&nbsp;</td>
                    </tr>
                </table>
                <asp:HiddenField ID="value1" runat="server" />
            </td>
        </tr>
    </table>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

