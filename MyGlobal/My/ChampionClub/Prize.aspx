<%@ Page Title="Champion Club - Prize" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<link href="championclub.css" rel="stylesheet" type="text/css" />
<link href="base.css" rel="stylesheet" type="text/css" />
<div id="container">
    <table>
        <tr>
            <td valign="top">
                <uc1:functionblock runat="server" ID="ucFunctionBlock" />
            </td>
            <td>
                <div class="cpclub-content-main">
                  <div class="intro-heading"><span class="intro-title">Prize</span></div>
                  <!-- end .main-intro -->
                  <div class="prize-select">
                    <ol>
                      <li>
                        <asp:RadioButtonList runat="server" ID="rbl1" RepeatLayout="Table" CellPadding="10" CellSpacing="3" CssClass="oplist">
                            <asp:ListItem Text="Send to your company." Value="0" />
                            <asp:ListItem Text="Send to your home address, please fill in bellow." Value="1" />
                        </asp:RadioButtonList>
                      </li>
                      <li>
                        <table cellpadding="0" cellspacing="0" border="0" width="534" class="prize_table">
                          <tr>
                            <td width="81" class="table_title01">Last Name:</td>
                            <td><asp:TextBox runat="server" ID="txtLastName" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">First Name:</td>
                            <td><asp:TextBox runat="server" ID="txtFirstName" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">Address:</td>
                            <td><asp:TextBox runat="server" ID="txtAddress" Width="350" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">Country:</td>
                            <td>
                                <asp:DropDownList runat="server" ID="ddlCountry" AutoPostBack="false" DataSourceID="srcCountry" DataTextField="text" DataValueField="value"></asp:DropDownList>
                                <asp:SqlDataSource runat="server" ID="srcCountry" ConnectionString="<%$ ConnectionStrings : MY %>"
                                    SelectCommand="select '' as text, '' as value union select * from SIEBEL_ACCOUNT_COUNTRY_LOV"></asp:SqlDataSource>
                            </td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">City:</td>
                            <td><asp:TextBox runat="server" ID="txtCity" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">State:</td>
                            <td><asp:TextBox runat="server" ID="txtState" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">Zip Code:</td>
                            <td><asp:TextBox runat="server" ID="txtZip" /></td>
                          </tr>
                          <tr>
                            <td width="81" class="table_title01">Telephone:</td>
                            <td><asp:TextBox runat="server" ID="txtTel" /></td>
                          </tr>
                          <tr>
                            <td colspan="2" align="right">
                                <asp:ImageButton runat="server" ID="btnSubmit" ImageUrl="~/My/ChampionClub/Images/Submit.jpg" />
                                <asp:ImageButton runat="server" ID="btnCancel" ImageUrl="~/My/ChampionClub/Images/Cancel.jpg" />
                            </td>
                          </tr>
                        </table>
                      </li>
                    </ol>
                  </div>
                </div>
            </td>
        </tr>
    </table>
</div>
</asp:Content>


