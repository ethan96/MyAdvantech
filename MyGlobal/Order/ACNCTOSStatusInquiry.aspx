<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Function getSQL() As String
        
        
        
        If Me.txtOrderNo.Text.Trim.Replace("'", "''") <> "" Then
            
            Dim STR As String = "SELECT MO_NUMBER,SERIAL_NUMBER,MODEL_NAME," & _
                                "decode(GROUP_NAME,'0','0','WAREHOUSE','2','SHIPPING','3','ASM','4','T0','5','1') as status,IN_STATION_TIME FROM SFISM4.R_WIP_TRACKING_T where " & _
                                " MO_NUMBER like '" & Me.txtOrderNo.Text.Trim.Replace("'", "''") & "%' AND rownum<300"
        
       
        
        
            Return STR
        End If
        Return ""
    End Function
    Public Sub getData()
        Dim SQLSTR As String = getSQL()
        If SQLSTR = "" Then Exit Sub
        Dim dt As New DataTable
        dt = OraDbUtil.dbGetDataTable("AKC", SQLSTR)
        If dt.Rows.Count = 0 Then
            dt = OraDbUtil.dbGetDataTable("ABJ", SQLSTR)
        End If
        Me.GridView1.DataSource = dt
    End Sub

    Public Sub ShowData()
        Dim str As String = "select vbeln from SAPRDP.VBAK where KUNNR='" & Session("company_id") & "' and VBELN='" & Me.txtOrderNo.Text.Trim.Replace("'", "''") & "'"
        Dim dt As New DataTable
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", str)
        If dt.Rows.Count = 0 Then
            Util.JSAlert(Me.Page, "Invalid Order No.")
            Exit Sub
        End If
        getData()
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        ShowData()
    End Sub

    
    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowData()
        
    End Sub

    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim o As DataRowView = CType(e.Row.DataItem, DataRowView)
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "0" Then
                e.Row.Cells(0).Text = "待组装"
                'e.Row.Cells(4).Text = ""
            End If
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "1" Then
                e.Row.Cells(0).Text = "组装中"
                'e.Row.Cells(4).Text = ""
            End If
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "2" Then
                e.Row.Cells(0).Text = "入库"
                'e.Row.Cells(4).Text = ""
            End If
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "3" Then
                e.Row.Cells(0).Text = "SHIPPING"
            End If
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "4" Then
                e.Row.Cells(0).Text = "组装中"
            End If
            If Not IsDBNull(o.Item("STATUS")) AndAlso o.Item("STATUS").ToString.Trim = "5" Then
                e.Row.Cells(0).Text = "测试中"
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
 <div style="font-size: large; font-weight: bolder;">
        Assembly Status Inquiry</div>
        <br />
    Order No:
    <asp:TextBox ID="txtOrderNo" runat="server"></asp:TextBox>
    <asp:Button ID="btnQuery" runat="server" Text=" 查询 " OnClick="btnQuery_Click" />
    <asp:GridView DataKeyNames="" EmptyDataText="备料中..." ID="GridView1" AllowPaging="true"
        PageIndex="0" PageSize="50" runat="server" AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging"
        Width="100%" OnRowDataBound="GridView1_RowDataBound">
        <Columns>
            <asp:BoundField HeaderText="Status" DataField="STATUS" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Order No" DataField="MO_NUMBER" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Serial No" DataField="SERIAL_NUMBER" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Model Name" DataField="MODEL_NAME" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Start date" DataField="IN_STATION_TIME" ItemStyle-HorizontalAlign="Left" />
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
   
</asp:Content>
