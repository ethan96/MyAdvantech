<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<script runat="server">
    Dim classid As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        classid = Request("classid")
        If classid <> "" Then
              
            Dim obj As Object = Nothing
            obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT class FROM DAQ_spec_class  where classid = '" + classid + "'")
            If obj IsNot Nothing Then
                lt1.Text = obj.ToString()
            End If
        End If
        If Not IsPostBack Then
            bind()
        End If
    End Sub
    Protected Sub bind()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT OPTIONID, CLASSID, OPTION_NAME, OPTION_TYPE, ENABLE, ORDER_BY FROM DAQ_spec_options WHERE CLASSID =  '" + classid + "' ORDER BY ORDER_BY ASC")
        GridView1.DataSource = dt
        GridView1.DataBind()
        ' OrderUtilities.showDT(dt)
    End Sub
    Protected Function getdt(ByVal optionid As Object) As DataTable
        Dim sql As String = "SELECT a.OPTIONID,a.OPTION_NAME,a.OPTION_TYPE,	b.OPTION_VALUE,b.ORDER_BY FROM DAQ_spec_options as a Inner Join DAQ_spec_options_values as b ON a.OPTIONID = b.OPTIONID " & _
                             " WHERE a.OPTIONID =  '" + optionid.ToString  + "' AND a.CLASSID = '" + classid + "' ORDER BY 	b.ORDER_BY ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        Return dt
    End Function
  

    Protected Sub GridView1_RowEditing(ByVal sender As Object, ByVal e As GridViewEditEventArgs) Handles GridView1.RowEditing
        GridView1.EditIndex = e.NewEditIndex
        bind()
    End Sub
    Protected Sub GridView1_RowCancelingEdit(ByVal sender As Object, ByVal e As GridViewCancelEditEventArgs) Handles GridView1.RowCancelingEdit
        GridView1.EditIndex = -1
        bind()
    End Sub
    Protected Sub GridView1_RowDeleting(ByVal sender As Object, ByVal e As GridViewDeleteEventArgs) Handles GridView1.RowDeleting
        Dim sql1 As String = "DELETE FROM daq_spec_options WHERE optionid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"
        Dim sql2 As String = "DELETE FROM daq_spec_options_values WHERE optionid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"      
        'Response.Write(sql1)
        'Response.Write("<br>")
        'Response.Write(sql2)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql1)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
        bind()
    End Sub
    Protected Sub GridView1_RowUpdating(ByVal sender As Object, ByVal e As GridViewUpdateEventArgs) Handles GridView1.RowUpdating
        Dim sql As String = "UPDATE DAQ_spec_options SET option_name = '" + CType(GridView1.Rows(e.RowIndex).Cells(3).FindControl("TextBox12"), TextBox).Text.Replace("'", "''") + "', option_type = '" + CType(GridView1.Rows(e.RowIndex).Cells(6).FindControl("DDL21"), DropDownList).SelectedValue + "',enable = '" + CType(GridView1.Rows(e.RowIndex).Cells(5).FindControl("DDL1"), DropDownList).SelectedValue + "',order_by = '" + CType(GridView1.Rows(e.RowIndex).Cells(2).FindControl("TextBox1"), TextBox).Text.Replace("'", "''") + "'" & _
                              " WHERE optionid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "'"
      
        'Response.Write(sql)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)

        GridView1.EditIndex = -1
        bind()
    End Sub
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            
            If e.Row.RowState = DataControlRowState.Normal Or e.Row.RowState = DataControlRowState.Alternate Then
                If GridView1.DataKeys(e.Row.RowIndex).Values(1).ToString = "y" Then
                    e.Row.Cells(5).Text = "<input type=""checkbox""  checked=""checked"" />"
                Else
                    e.Row.Cells(5).Text = "<input type=""checkbox"" />"
                End If
               DirectCast(e.Row.Cells(4).FindControl("DDL20"), DropDownList).SelectedValue = GridView1.DataKeys(e.Row.RowIndex).Values(2).ToString
            End If
            If e.Row.RowState = DataControlRowState.Edit OrElse e.Row.RowState.ToString().Equals("Alternate,Edit") Then
                DirectCast(e.Row.Cells(4).FindControl("DDL21"), DropDownList).SelectedValue = GridView1.DataKeys(e.Row.RowIndex).Values(2).ToString
               ' Response.Write(GridView1.DataKeys(e.Row.RowIndex).Values(2).ToString)
            End If
          
          
        End If
      
    End Sub    

    Protected Sub addbt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Object = Nothing : Dim max_optionid As String = ""
        obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT MAX(optionid)+ 1  as max_option_id FROM daq_spec_options")
        If obj IsNot Nothing Then
            max_optionid = obj.ToString()
        Else
            max_optionid = "10000"
        End If
        Dim sql As String = "INSERT INTO daq_spec_options (optionid,  classid ,option_name,option_type,enable,order_by) values ( " + max_optionid + ",'" + classid + "',  '" + add_option_name.Value.Replace("'", "''") + "'," & _
                               "  '" + Request("add_option_type") + "', '" + Request("add_option_status") + "', '" + add_option_order_by.Value.Replace("'", "''") + "' )"
    
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        bind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
 <link href="css.css" rel="stylesheet" type="text/css" />
 <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
  <tr>
    <td width="200" valign="top"><uc1:Menu ID="Menu1" runat="server" /></td>
    <td width="10"></td>
    <td valign="top">
    <div class="content_box">
   <strong><a href="spec_management.aspx">::: All  Spec class </a>>><asp:Literal ID="lt1" runat="server"></asp:Literal></strong> 

</div><br />
    <asp:GridView Width="100%" runat="server" ID="GridView1" AutoGenerateColumns="False" DataKeyNames="OPTIONID,ENABLE,OPTION_TYPE" onrowdatabound="GridView1_RowDataBound">
     <Columns>
         <asp:CommandField HeaderText="Delete" ShowDeleteButton="True" />
        <asp:CommandField HeaderText="Update" ShowEditButton="True" />       
       <asp:TemplateField ItemStyle-Width="10px"  HeaderText="Order by" SortExpression="ORDER_BY">
            <ItemTemplate> 
           <asp:Label  ID ="Label1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:Label> 
           </ItemTemplate>         
            <EditItemTemplate> 
          <asp:TextBox  ID ="TextBox1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:TextBox> 
           </EditItemTemplate>  </asp:TemplateField>
     
         <asp:TemplateField HeaderText="Option" SortExpression="OPTION_NAME">
            <ItemTemplate> 
           <asp:Label  ID ="Label12"  runat ="server"  Text ='<%#  Bind("OPTION_NAME") %> '> </asp:Label> 
           </ItemTemplate>         
            <EditItemTemplate> 
          <asp:TextBox  ID ="TextBox12"  runat ="server"  Text ='<%#  Bind("OPTION_NAME") %> '> </asp:TextBox> 
           </EditItemTemplate>  </asp:TemplateField>
         <asp:TemplateField HeaderText="Type" >   
                 <ItemTemplate > 
                  <asp:DropDownList ID="DDL20" runat="server">
                                <asp:ListItem  Value="t" Text="Text field"></asp:ListItem>
                                <asp:ListItem  Value="s" Text="Single option selector"></asp:ListItem>
                                 <asp:ListItem  Value="m" Text="Multiple option selector"></asp:ListItem>
                                </asp:DropDownList>    
                 
                    </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="DDL21" runat="server">
                                <asp:ListItem  Value="t" Text="Text field"></asp:ListItem>
                                <asp:ListItem  Value="s" Text="Single option selector"></asp:ListItem>
                                 <asp:ListItem  Value="m" Text="Multiple option selector"></asp:ListItem>
                                </asp:DropDownList>                             
                            </EditItemTemplate>
               </asp:TemplateField>

          <asp:TemplateField HeaderText="Enable" >   
                 <ItemTemplate>    </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="DDL1" runat="server">
                                <asp:ListItem  Value="y" Text="Enable"></asp:ListItem><asp:ListItem  Value="n" Text="Disable"></asp:ListItem>
                                </asp:DropDownList>                             
                            </EditItemTemplate>
               </asp:TemplateField>
       
       
        <asp:TemplateField HeaderText="Value">
        <ItemTemplate><ul >
           <asp:Repeater runat="server" DataSource='<%# getdt(Eval("optionid")) %>'>
           <ItemTemplate>
           <li  style="color:#8080800;">■  <%# Eval("option_value")%><br /></li>
           </ItemTemplate>
            </asp:Repeater>
            </ul>
        </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField>
        <ItemTemplate>
        <a href="#" id="edid_option_value" onclick="edit_option_value(<%# Eval("optionid")%>,<%= classid%>);" style="background:#99CCFF;">Edit</a>
        </ItemTemplate>
        </asp:TemplateField>
      
        </Columns>
    </asp:GridView>

  <%--  66666666666
--%>



<div class="content_box">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr><td colspan="7">&nbsp;</td></tr>
<tr><th colspan="7" style="background:#99ccff;" style="text-align:center;">Add option</th></tr>
<tr style="text-align:center;"><th width="20"></th><th>Order by</th><th>Option</th><th>Type</th><th>Enable</th>
<th colspan="2"></th></tr>
<td>&nbsp;</td>
<td style="text-align:center;"><input type="text" value="" size="10" runat="server" name="add_option_order_by" id="add_option_order_by" style="text-align:center;"/></td>
<td><input type="text" value="" runat="server" size="40" name="add_option_name" id="add_option_name" style="text-align:center;"/></td>
<td style="text-align:center;">
<select size="1" name="add_option_type" id="add_option_type">
	<option value="t" selected="">Text field</option>
	<option value="s" >Single option selector</option>
	<option value="m" >Multiple option selector</option>
</select>
</td>
<td style="text-align:center;">
<select size="1" name="add_option_status" id="add_option_status">
	<option value="y" selected="" >Enable</option>
	<option value="n" >Disable</option>
</select>
</td>
<td>

<asp:Button runat="server" ID="addbt" Text="Add" onclick="addbt_Click" />


</td>
<td></td>
</tr>
</table></div>





<%--66666666666666666666--%>
    </td></tr></table>



    

    <script language="javascript" type="text/javascript" >


        function edit_option_value(optionid, classid) {
            var optionid;
            var classid;
            var url = "option_value.aspx?optionid=" + optionid + "&classid=" + classid;
            open(url, 'new_win', config = 'scrollbars=yes,location=no,status=yes,width=600,height=500,left=200,top=100');
        }
	
    
    </script><br />
</asp:Content>

