<%@ Page Title="MyAdvantech - My Campaigns - Marketing Manager" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If Util.IsAEUIT() OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw") OrElse String.Equals(Session("user_id"), "stefanie.chang@advantech.com.tw") Then
            Else
                Response.Redirect("~/home.aspx")
            End If
            BindGV()
        End If
    End Sub
    Private Sub BindGV()
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As List(Of CAMPAIGN_REQUEST_MarketingManager) = MyDC.CAMPAIGN_REQUEST_MarketingManagers.OrderByDescending(Function(p) p.LAST_UPD_DATE).ToList
        gv1.DataSource = MyCR
        gv1.DataBind()
    End Sub
    Protected Sub gv1_RowCancelingEdit(sender As Object, e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        gv1.EditIndex = -1
        BindGV()
    End Sub

    Protected Sub gv1_RowEditing(sender As Object, e As System.Web.UI.WebControls.GridViewEditEventArgs)
        gv1.EditIndex = e.NewEditIndex
        BindGV()
    End Sub
    Protected Sub gv1_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim id As String = gv1.DataKeys(e.RowIndex).Values(0).ToString()
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As CAMPAIGN_REQUEST_MarketingManager = MyDC.CAMPAIGN_REQUEST_MarketingManagers.Where(Function(p) p.ID = id).First
        MyCR.CAMPAIGN_Request_MarketingManager_RBUs.Clear()
        MyDC.CAMPAIGN_REQUEST_MarketingManagers.DeleteOnSubmit(MyCR)
        MyDC.SubmitChanges()
        BindGV()
    End Sub
    Protected Sub gv2_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim gv2 As GridView = CType(sender, GridView)
        Dim id As String = gv2.DataKeys(e.RowIndex).Values(0).ToString()
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As CAMPAIGN_Request_MarketingManager_RBU = MyDC.CAMPAIGN_Request_MarketingManager_RBUs.Where(Function(p) p.ID = id).First
        MyDC.CAMPAIGN_Request_MarketingManager_RBUs.DeleteOnSubmit(MyCR)
        MyDC.SubmitChanges()
        BindGV()
    End Sub
    Protected Sub gv1_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Dim id As String = gv1.DataKeys(e.RowIndex).Values(0).ToString()
        Dim RowIndex As Integer = e.RowIndex
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As CAMPAIGN_REQUEST_MarketingManager = MyDC.CAMPAIGN_REQUEST_MarketingManagers.Where(Function(p) p.ID = id).First
        MyCR.BU = FindGVtext(RowIndex, 3, 0)
        MyCR.Responsibility = FindGVtext(RowIndex, 4, 0)
        MyCR.Name = FindGVtext(RowIndex, 0, 0)
        MyCR.VOIP = FindGVtext(RowIndex, 5, 0)
        MyCR.Ext = FindGVtext(RowIndex, 6, 0)
        MyCR.LAST_UPD_BY = Session("user_id").ToString
        MyCR.LAST_UPD_DATE = Now
        MyDC.SubmitChanges()
        gv1.EditIndex = -1
        BindGV()
    End Sub 
    Public Function FindGVtext(ByVal RowIndex As String, ByVal CellIndex As Integer, ControlIndex As Integer) As String
        Return CType(gv1.Rows(RowIndex).Cells(CellIndex).Controls(ControlIndex), TextBox).Text.ToString().Trim()
        Return ""
    End Function

    Protected Sub BTadd_Click(sender As Object, e As System.EventArgs)
        If Util.IsValidEmailFormat(TBemail.Text.Trim) = False Then
            Util.JSAlert(Me.Page, " Email is incorrect. ")
            Exit Sub
        End If
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As New CAMPAIGN_REQUEST_MarketingManager
        MyCR.Email = TBemail.Text.Trim
        MyCR.CreateBy = Session("user_id").ToString
        MyCR.CreateDate = Now
        MyCR.LAST_UPD_BY = Session("user_id").ToString
        MyCR.LAST_UPD_DATE = Now
        MyDC.CAMPAIGN_REQUEST_MarketingManagers.InsertOnSubmit(MyCR)
        MyDC.SubmitChanges()
        BindGV()
    End Sub
    Protected Function GetData(ByVal obj As Object) As List(Of CAMPAIGN_Request_MarketingManager_RBU)
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As List(Of CAMPAIGN_Request_MarketingManager_RBU) = MyDC.CAMPAIGN_Request_MarketingManager_RBUs.Where(Function(p) p.MarketingManagerID = obj.ToString).ToList
        Return MyCR
    End Function

    Protected Sub btaddrbu_Click(sender As Object, e As System.EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim Row As GridViewRow = CType(bt.NamingContainer, GridViewRow)
        Dim gv2 As GridView = CType(Row.NamingContainer, GridView)
        Dim id As String = gv2.DataKeys(Row.RowIndex).Values(0).ToString
        Dim rbustr As String = CType(Row.FindControl("tbrbu"), TextBox).Text
        Dim MyDC As New MyCampaignDBDataContext()
        Dim rbu As New CAMPAIGN_Request_MarketingManager_RBU
        rbu.RBU = rbustr.ToUpper.Trim
        rbu.MarketingManagerID = id
        rbu.LAST_UPD_BY = Session("user_id").ToString
        rbu.LAST_UPD_DATE = Now
        MyDC.CAMPAIGN_Request_MarketingManager_RBUs.InsertOnSubmit(rbu)
        MyDC.SubmitChanges()
        BindGV()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td>
                Email:
                <asp:TextBox runat="server" ID="TBemail">
                </asp:TextBox>
                <asp:Button runat="server" Text="Add" ID="BTadd" OnClick="BTadd_Click" />
            </td>
        </tr>
    </table>
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataKeyNames="id"
        OnRowDeleting="gv1_RowDeleting" OnRowCancelingEdit="gv1_RowCancelingEdit" OnRowEditing="gv1_RowEditing"
        OnRowUpdating="gv1_RowUpdating">
        <Columns>
            <asp:BoundField HeaderText="Name" DataField="Name" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Email" DataField="Email" ReadOnly="True" ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="Region" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:GridView ID="gv2" runat="server" EmptyDataText="" OnRowDeleting="gv2_RowDeleting"
                        Width="180" DataKeyNames="id" AutoGenerateColumns="false" DataSource='<%# GetData(Eval("id")) %>'
                        SortedAscendingCellStyle-Wrap="True" ShowHeader="False">
                        <Columns>
                            <asp:BoundField HeaderText="RBU" DataField="RBU" ItemStyle-HorizontalAlign="Center" />
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="false" HeaderText="Delete"
                                ItemStyle-HorizontalAlign="Center" />
                        </Columns>
                    </asp:GridView>
                    <asp:TextBox ID="tbrbu" runat="server"></asp:TextBox>
                    <asp:Button ID="btaddrbu" runat="server" Text="Add" OnClick="btaddrbu_Click" />
                </ItemTemplate>
                <EditItemTemplate>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="BU" DataField="BU" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Responsibility" DataField="Responsibility" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Voip" DataField="VOIP" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Ext" DataField="Ext" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Created by" DataField="CreateBy" ReadOnly="True" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Last updated on" DataField="LAST_UPD_DATE" ReadOnly="True"
                SortExpression="LAST_UPD_DATE" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center"
                HeaderStyle-HorizontalAlign="Center" />
            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" HeaderText="Edite"
                ItemStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
