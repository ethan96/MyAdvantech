<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not IsPostBack Then
            BindRP()
        End If
    End Sub
    Private Sub BindRP()
        Dim SB As New StringBuilder
        SB.AppendFormat(" select distinct  A.CATALOG_TYPE, ISNULL(B.LOCAL_NAME,'') AS LOCAL_NAME   from CBOM_CATALOG A ")
        SB.AppendFormat(" left JOIN CBOM_CATALOG_LOCALNAME B ON A.CATALOG_TYPE =B.CATALOG_TYPE and  B.ORG=A.CATALOG_ORG ")
        SB.AppendFormat(" where  A.CATALOG_ORG='{0}'  AND A.CATALOG_TYPE IS NOT NULL AND A.CATALOG_TYPE <> '' ", "EU")
        Dim DT As DataTable = dbUtil.dbGetDataTable("MY", SB.ToString())
        HF1.Value = DT.Rows.Count()
        RP1.DataSource = DT
        RP1.DataBind()
    End Sub

    Protected Sub btupdate_Click(sender As Object, e As EventArgs)
      
        Dim QTY As String = Request.Form("ctl00$_main$HF1")
        Dim _QTY As Integer = 0
        If Integer.TryParse(QTY, 0) Then
            _QTY = Integer.Parse(QTY)
        End If
        Dim sb As New StringBuilder
        For j As Integer = 0 To _QTY
            Dim displayname = Request.Form("displayname" + j.ToString())
            Dim catalogname = Request.Form("catalogname" + j.ToString())
            
            If displayname IsNot Nothing AndAlso Not String.IsNullOrEmpty(displayname) Then
                If catalogname IsNot Nothing AndAlso Not String.IsNullOrEmpty(catalogname) Then
                    Dim _cname = catalogname.Trim().Replace("'", "''")
                    sb.AppendFormat(" DELETE  from  CBOM_CATALOG_LOCALNAME where org='EU'  AND  CATALOG_TYPE='{0}'; INSERT CBOM_CATALOG_LOCALNAME VALUES ('{0}','{1}','EU');", _cname, displayname.Replace("'", "''").Trim())
                End If
            End If
        Next
        'Dim Dname() As String = displayname.Split(New Char() {","}, StringSplitOptions.None)
        'Dim Cname() As String = catalogname.Split(New Char() {","}, StringSplitOptions.None)
        'Response.Write(Cname.Length.ToString() + "<br>" + Dname.Length.ToString())
      
        'Dim i As Integer = 0
        'For Each item As String In Dname
           
        '    i = i + 1
        'Next
        Dim retint As Integer = dbUtil.dbExecuteNoQuery("MY", sb.ToString())
        If retint > 0 Then
            Util.JSAlert(Me.Page, "Update successful")
        Else
            Util.JSAlert(Me.Page, "Update failed")   
        End If
        'Response.Write(sb.ToString())
        BindRP()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Button ID="btupdate" runat="server" Text="Update" OnClick="btupdate_Click" />
    <asp:HiddenField ID="HF1" runat="server" />
    <table width="900" align="center" border="1" cellspacing="0" bordercolor="#000000" width="80%" style="border-collapse: collapse; margin-top: 10px;">

        <tr>
            <td style="text-align: center" width="50"></td>
            <td style="text-align: center"><b>Catalog Name</b></td>
            <td style="text-align: center;"><b>Display Name</b></td>
        </tr>
        <asp:Repeater runat="server" ID="RP1">
            <ItemTemplate>

                <tr>
                    <td style="text-align: center" height="25"><%#Container.ItemIndex + 1%></td>
                    <td style="padding-left: 10px;" width="400"><b><%#Eval("CATALOG_TYPE")%></b></td>
                    <td>
                        <input name="displayname<%#Container.ItemIndex%>" type="text" value="<%#Eval("LOCAL_NAME")%>" style="width: 90%; margin-left: 10px;" />
                        <input name="catalogname<%#Container.ItemIndex%>" type="hidden" value="<%#Eval("CATALOG_TYPE")%>" />
                    </td>
                </tr>

            </ItemTemplate>

        </asp:Repeater>
    </table>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

