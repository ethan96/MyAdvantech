<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.Xml" %>

<script runat="server">
   
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "select isnull(YQ,'') as YQ,  isnull(MD,'') as MD,isnull(THORST,'') as THORST,isnull(YR,'') as YR from BillBoard")
            If dt.Rows.Count > 0 Then
                With dt.Rows(0)
                    TB1.Text = .Item("YQ")
                    TB2.Text = .Item("MD")
                    RadioButtonList1.SelectedValue = .Item("THORST")
                    TB3.Text = .Item("YR")
                End With
            End If
        End If
    End Sub

    Protected Sub Button1_Click(sender As Object, e As System.EventArgs)
        If RadioButtonList1.SelectedIndex < 0 Then Exit Sub
        dbUtil.dbExecuteNoQuery("MYLOCAL", " TRUNCATE table  BillBoard")
        dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("INSERT INTO [BillBoard] ([YQ] ,[MD] ,[THORST] ,[YR]) " _
                                                        & " VALUES ('{0}','{1}','{2}','{3}')", TB1.Text.Trim.Replace("'", "''"), _
                                                        TB2.Text.Trim.Replace("'", "''"), _
                                                        RadioButtonList1.SelectedValue, _
                                                        TB3.Text.Trim.Replace("'", "''")))
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <div style="position:relative; width:400px; height:151px;">
        <img alt="" src="../images/Billboard.gif" width="301" height="151" />
        <div style="position:absolute;bottom:107px; right:120px; z-index:101;" >
            <asp:TextBox ID="TB1" runat="server" Width="65px"></asp:TextBox>
        </div>
        <div style="position:absolute;bottom:30px; right:270px; z-index:101;" >
            <asp:TextBox ID="TB2" runat="server" Width="68px"></asp:TextBox>
        </div>
        <div style="position:absolute;bottom:40px; right:216px; z-index:101;" >
            <asp:RadioButtonList ID="RadioButtonList1" runat="server" RepeatDirection="Horizontal">
                <asp:ListItem >th</asp:ListItem>
                <asp:ListItem >st</asp:ListItem>
            </asp:RadioButtonList> 
        </div>
         <div style="position:absolute;bottom:30px; right:137px; z-index:101;" >
            <asp:TextBox ID="TB3" runat="server" Width="68px"></asp:TextBox>
        </div>
    </div>
    <asp:Button ID="Button1" runat="server" Text="Update" OnClick="Button1_Click" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

