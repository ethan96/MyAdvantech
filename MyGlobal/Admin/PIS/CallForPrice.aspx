<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CallForPrice.aspx.cs" Inherits="Admin_PIS_CallForPrice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <div>
        Year: <asp:DropDownList ID="ddlYear" runat="server"></asp:DropDownList>&nbsp;
        Month: <asp:DropDownList ID="ddlMonth" runat="server"></asp:DropDownList><br />
        <asp:Button ID="btnExport" runat="server" Text="Export" OnClick="btnExport_Click" />
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

