<%@ Page Title="" Language="VB" Culture="en-US" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="CustomerSegmentation.aspx.vb" Inherits="DM_CustomerSegmentation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Label ID="Label1" runat="server" Text="GKA Threshold (in USD) : "></asp:Label><asp:TextBox ID="GKA" runat="server" Text="20,000" CssClass="ka" Width="100px"></asp:TextBox>
    &nbsp;&nbsp;
    <asp:Label ID="Label2" runat="server" Text="KA/LKA Threshold (in USD) : "></asp:Label><asp:TextBox ID="KA" runat="server" Text="1,000,000" CssClass="ka" Width="100px"></asp:TextBox>
    &nbsp&nbsp;
    <asp:Label ID="Label3" runat="server" Text="NKA Threshold (in USD) : "></asp:Label><asp:TextBox ID="NKA" runat="server" Text="5,000,000" CssClass="ka" Width="100px"></asp:TextBox>
    <br />
    <br />
    <asp:Label ID="Label4" runat="server" Text="Date Range : "></asp:Label>
    <asp:TextBox ID="TextBox4" runat="server" Enabled="False"></asp:TextBox><asp:ImageButton ID="ImageButton1" runat="server" Height="15px" ImageUrl="~/Images/calendar-image-png-3.png" Width="20px" />
    ~  &nbsp
    <asp:TextBox ID="TextBox5" runat="server" Enabled="False"></asp:TextBox><asp:ImageButton ID="ImageButton2" runat="server" Height="15px" ImageUrl="~/Images/calendar-image-png-3.png" Width="20px" />
    <asp:Calendar ID="OneYearFrom" runat="server" SelectionMode="DayWeekMonth" OnSelectionChanged="StartSelection_Change" Visible="False"></asp:Calendar>
    <asp:Calendar ID="OneYearTo" runat="server" SelectionMode="DayWeekMonth" OnSelectionChanged="EndSelection_Change" DayStyle-VerticalAlign="NotSet" Visible="False"></asp:Calendar>
    &nbsp;&nbsp;&nbsp;
    <asp:Label runat="server"></asp:Label><asp:Label runat="server" ForeColor="#CC0000">Notice : The date range must be more than 1 year</asp:Label>
    <br />
    <br />
    <asp:Button ID="Query" runat="server" Text="Query" Height="30px" Width="120px" />
    &nbsp;   &nbsp;   &nbsp;   &nbsp;   &nbsp;
    <asp:Button ID="Excel" runat="server" Text="Output Excel" Height="30px" Width="120px" />
    <br />
    <asp:GridView ID="GridView1" HorizontalAlign="Center" runat="server" AllowPaging="True" OnPageIndexChanging="GridView1_PageIndexChanging" PageSize="100" Width="100%" OnDataBinding="GridView1_DataBinding" AutoGenerateColumns="False">
        <Columns>
            <asp:BoundField DataField="BUYING_GROUP" HeaderText="BUYING GROUP" ItemStyle-Width="20%" ItemStyle-VerticalAlign="Top" />
            <asp:BoundField DataField="CUST_SEG" HeaderText="CUST SEG" ItemStyle-Width="10%" ItemStyle-VerticalAlign="Top" />
            <asp:BoundField DataField="Amount" HeaderText="AMOUNT" ItemStyle-Width="10%" ItemStyle-VerticalAlign="Top" />
            <asp:BoundField DataField="COMPANY" HeaderText="COMPANY" ItemStyle-Width="60%" ItemStyle-VerticalAlign="Top" />
        </Columns>
    </asp:GridView>
    <script>
        var inputs = document.getElementsByClassName('ka');
        for (var i = 0 ; i < inputs.length; i++) {
            var input = inputs[i];
            input.addEventListener('keyup', function (evt) {
                var num = Number(evt.target.value.replace(/,/g, ''));
                if (num == "NaN") {
                    //evt.target.value = "Must be integer";
                }
                else {
                    evt.target.value = num.toLocaleString('en-US', { minimumFractionDigits: 0 });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

