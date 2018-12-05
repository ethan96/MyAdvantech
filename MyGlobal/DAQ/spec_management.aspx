<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            Call bind()
        End If
    End Sub
    Public Sub bind()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT classid,class,enable,order_by FROM DAQ_spec_class ORDER BY order_by ASC")
        GridView1.DataSource = dt
        GridView1.DataBind()
    End Sub
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            
            If e.Row.RowState = DataControlRowState.Normal Or e.Row.RowState = DataControlRowState.Alternate Then
                If GridView1.DataKeys(e.Row.RowIndex).Values(1).ToString = "y" Then
                    e.Row.Cells(2).Text = "<input type=""checkbox""  checked=""checked"" />"
                Else
                    e.Row.Cells(2).Text = "<input type=""checkbox"" />"
                End If
            End If
  
        End If
      
       
    End Sub
    Protected Sub GridView1_RowEditing(ByVal sender As Object, ByVal e As GridViewEditEventArgs) Handles GridView1.RowEditing
        GridView1.EditIndex = e.NewEditIndex
        bind()
    End Sub
    Protected Sub GridView1_RowCancelingEdit(ByVal sender As Object, ByVal e As GridViewCancelEditEventArgs) Handles GridView1.RowCancelingEdit
        GridView1.EditIndex = -1
        bind()
    End Sub
    Protected Sub GridView1_RowDeleting(ByVal sender As Object, ByVal e As GridViewDeleteEventArgs) Handles GridView1.RowDeleting
        Dim sql1 As String = "DELETE FROM daq_spec_class WHERE classid ='" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"
        Dim sql2 As String = "DELETE FROM daq_spec_options_values WHERE optionid in (SELECT optionid FROM daq_spec_options WHERE classid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "')"
        Dim sql3 As String = "DELETE FROM daq_spec_options  WHERE classid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"
     
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql1)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql3)
        bind()
    End Sub
    Protected Sub GridView1_RowUpdating(ByVal sender As Object, ByVal e As GridViewUpdateEventArgs) Handles GridView1.RowUpdating    
        Dim sql As String = ""          
        sql = "UPDATE DAQ_spec_class SET enable = '" + CType(GridView1.Rows(e.RowIndex).Cells(2).FindControl("DDL1"), DropDownList).SelectedValue + "', " & _
                  "order_by = '" + CType(GridView1.Rows(e.RowIndex).Cells(0).FindControl("TextBox1"), TextBox).Text.Replace("'", "''") + "'   WHERE classid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"
        ' Response.Write("UPDATE: " + sql + "<HR>")
        
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        GridView1.EditIndex = -1
        bind()
    End Sub

    Protected Sub addbt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql As String = "INSERT INTO DAQ_spec_class (class,enable,order_by ) values ('" + add_spec.Value.Replace("'", "''") + "','y','" + add_order_by.Value.Replace("'", "''") + "')"
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
         bind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

    <link href="css.css" rel="stylesheet" type="text/css" />
<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="200" valign="top"><uc1:Menu ID="Menu1" runat="server" /></td>
    <td width="10"></td>
    <td valign="top">
    
<asp:GridView ID="GridView1" Width="100%" runat="server" DataKeyNames ="classid,enable" AutoGenerateColumns="False" onrowdatabound="GridView1_RowDataBound">
    <Columns>
           <asp:TemplateField HeaderText="Order by" SortExpression="ORDER_BY" >
            <ItemTemplate> 
           <asp:Label  ID ="Label1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:Label> 
           </ItemTemplate>         
            <EditItemTemplate> 
          <asp:TextBox  ID ="TextBox1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:TextBox> 
           </EditItemTemplate> 
             <ItemStyle Width="60px" HorizontalAlign="Center" />
            </asp:TemplateField>
        <asp:HyperLinkField DataNavigateUrlFields="classid"    DataNavigateUrlFormatString="spec_options.aspx?classid={0}" HeaderText="Spec class name"  DataTextField="class" />
       
       <asp:TemplateField HeaderText="Enable">   
                 <ItemTemplate>    </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="DDL1" runat="server">
                                <asp:ListItem  Value="y" Text="Enable"></asp:ListItem><asp:ListItem  Value="n" Text="Disable"></asp:ListItem>
                                </asp:DropDownList>                             
                            </EditItemTemplate>
               </asp:TemplateField>
           <asp:CommandField HeaderText="Update" ShowEditButton="True"  ItemStyle-HorizontalAlign="Center"/>
          <asp:CommandField HeaderText="Delete" ShowDeleteButton="True" ItemStyle-HorizontalAlign="Center"/>
    </Columns>
</asp:GridView>
    <br />
   <table width="600" border="0" align="left" cellpadding="0" cellspacing="2" >
<tr>
<td colspan="3" align="center" bgcolor="#99CCFF" style="text-align:center; font-size:12px; font-weight:bold;">Add new spec class</td>
</tr>
<tr><th  style="width:12%; background-color:#CCCCCC">Order by</th><th style="width:45%; background-color:#CCCCCC">Spec class name</th><th style=" background-color:#CCCCCC" ></th></tr>
<tr>
<td  align="center"><input type="text" size="15" id="add_order_by" runat="server" name="add_order_by"/></td>
<td ><input type="text" size="62" id="add_spec" runat="server" name="add_spec"/></td>
<td   style="text-align:left;">  <asp:Button runat="server" Text="Add" ID="addbt" onclick="addbt_Click"   /> </td>
</tr>
</table>
</td></tr></table>
</asp:Content>


