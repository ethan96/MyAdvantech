<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Util.IsAEUIT() OrElse Util.IsPCP_Marcom(Session("user_id"), "") Then
            Else
                Response.Redirect("~/home.aspx")
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<h2> Visitor Track</h2><div style="height:5px;"></div>
<asp:GridView ID="GridView1" runat="server" AllowPaging="True" 
        AllowSorting="True" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" Width="100%">
        <Columns>
            <asp:BoundField DataField="Visitor" HeaderText="Visitor" ItemStyle-HorizontalAlign="Center" SortExpression="Visitor" />
            <asp:BoundField DataField="filename" HeaderText="File" ItemStyle-HorizontalAlign="Center" ReadOnly="True"  SortExpression="filename" />
            <asp:BoundField DataField="Created_By" HeaderText="File Created By" ItemStyle-HorizontalAlign="Center"   SortExpression="Created_By" />
            <asp:BoundField DataField="Visitor_Date" ItemStyle-HorizontalAlign="Center" HeaderText="Visitor Date"  DataFormatString ="{0:yyyy-MM-dd hh:mm}" SortExpression="Visitor_Date" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CP %>" 
        SelectCommand="SELECT A.Visitor, B.File_Name + '.' + B.File_Ext AS filename, B.Created_By, A.Visitor_Date FROM ChampionClub_Track AS A INNER JOIN B2BDIR_THANKYOU_LETTER_UPLOAD_FILES AS B ON A.File_ID = B.File_ID ORDER BY A.Visitor_Date DESC">
    </asp:SqlDataSource>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

