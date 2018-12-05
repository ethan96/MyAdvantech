<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<script runat="server">
    Dim subcatid As String = "0"
    Protected Sub get_all_catid(ByVal categoryid As String)
        Dim main_catid As String = categoryid
        '  Response.Write("GEIZI" +categoryid +"<HR>")
        Dim SQL As String = "SELECT categoryid FROM daq_func_categories WHERE parentid = '" + main_catid + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)       
        If dt.Rows.Count > 0 Then
             
            For i As Integer = 0 To dt.Rows.Count - 1
                ' Response.Write("<HR>")
                Dim SQL1 As String = "DELETE FROM DAQ_func_categories WHERE categoryid = '" + dt.Rows(i)("categoryid").ToString.Trim + "'"
                Dim SQL2 As String = "DELETE FROM   DAQ_products WHERE  PRODUCTID  IN (SELECT PRODUCTID   FROM DAQ_products_categories WHERE   CATEGORYID = '" + dt.Rows(i)("categoryid").ToString.Trim + "')"
                Dim SQL3 As String = "DELETE FROM daq_products_categories  WHERE categoryid = '" + dt.Rows(i)("categoryid").ToString.Trim + "'"
                 dbUtil.dbExecuteNoQuery("MYLOCAL", SQL1) : dbUtil.dbExecuteNoQuery("MYLOCAL", SQL2) : dbUtil.dbExecuteNoQuery("MYLOCAL", SQL3)
                get_all_catid(dt.Rows(i)("categoryid").ToString.Trim)
                '  Response.Write("ZHI:  " + dt.Rows(i)("categoryid").ToString.Trim + ":::" + SQL1 + "<BR>" + SQL2 + "<BE>" + SQL3 + "<BR>")
            Next
        End If
        
        Dim SQL_MAIN1 As String = "DELETE FROM DAQ_func_categories WHERE categoryid = '" + main_catid + "'"
        Dim SQL_MAIN2 As String = "DELETE FROM DAQ_products WHERE  PRODUCTID IN (SELECT  PRODUCTID  FROM DAQ_products_categories WHERE  CATEGORYID = '" + main_catid + "')"
        Dim SQL_MAIN3 As String = "DELETE FROM DAQ_products_categories  WHERE categoryid = '" + main_catid + "'"
        dbUtil.dbExecuteNoQuery("MYLOCAL", SQL_MAIN1) : dbUtil.dbExecuteNoQuery("MYLOCAL", SQL_MAIN2) : dbUtil.dbExecuteNoQuery("MYLOCAL", SQL_MAIN3)
        'Response.Write("ZHU:  " + SQL_MAIN1 + "<BR>" + SQL_MAIN2 + "<BE>" + SQL_MAIN3 + "<BR>")
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("subcatid") <> "" Then
            subcatid = Request("subcatid")
            Dim sql As String = "SELECT CATEGORYID, PARENTID, CATEGORY, ORDER_BY 	FROM DAQ_func_categories WHERE CATEGORYID =  " + subcatid + " ORDER BY ORDER_BY ASC"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            If dt.Rows.Count > 0 Then
                Lit1.Text = "<a href=""categories.ASPX?subcatid=" + dt.Rows(0)("parentid").ToString + """><img src=""./image/Back Button_16.gif"">&nbsp;Back to parent category</a>"
                Lit2.Text = dt.Rows(0)("category").ToString
            End If
                     
        End If
        If Not IsPostBack Then
            Call bind()
            If Request("do") = "checkproducts" Then
                Call pro_bind()
            End If
        End If
    End Sub
    Protected Function getFullCategoryList() As DataTable
        Dim sql As String = "SELECT CATEGORYID FROM DAQ_func_categories ORDER BY CATEGORYID ASC, ORDER_BY ASC"
        Dim dt_full As New DataTable
        dt_full.Columns.Add(New DataColumn("key", GetType(String)))
        dt_full.Columns.Add(New DataColumn("full_cat_path", GetType(String)))
       
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim dr_fuu As DataRow = dt_full.NewRow
                dr_fuu("key") = dt.Rows(i)("CATEGORYID").ToString.Trim
                dr_fuu("full_cat_path") = getFullCategoryPath(dt.Rows(i)("CATEGORYID").ToString.Trim)
                dt_full.Rows.Add(dr_fuu)
            Next
        End If
        ' OrderUtilities.showDT(dt_full)
        Return dt_full
    End Function
    Protected Function getFullCategoryPath(ByVal cid As String) As String
        Dim full_category_path As String = "", parentid As String = cid
        Do
            Dim sql As String = "SELECT CATEGORY, CATEGORYID, PARENTID FROM DAQ_func_categories WHERE CATEGORYID = '" + parentid + "'"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            If dt.Rows.Count > 0 Then
                full_category_path = dt.Rows(0)("category").ToString.Trim + "/" + full_category_path
                parentid = dt.Rows(0)("parentid").ToString.Trim
            End If
        Loop While parentid <> "0"          
        Return full_category_path
    End Function
    Protected Sub pro_bind()
        Dim SQL As String = "SELECT  a.PRODUCTID,a.SKU, a.PRODUCTNAME, a.DESCRIPTION,  b.CATEGORYID,  a.ENABLE ,'' AS category " & _
                              " FROM  DAQ_products as a, DAQ_func_categories as b, DAQ_products_categories as c " & _
                              " WHERE  b.CATEGORYID = " + subcatid + " and  	a.PRODUCTID = c.PRODUCTID and  	c.CATEGORYID = b.CATEGORYID  	order by  a.PRODUCTID asc"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1         
                dt.Rows(i).Item("category") = getFullCategoryPath(dt.Rows(i).Item("categoryid").ToString.Trim)
            Next
                
            dt.AcceptChanges()
            GridView2.DataSource = dt
            GridView2.DataBind()
           
        End If
        
    End Sub
    Public Sub bind()
        Dim sql As String = "SELECT  a.CATEGORYID as CATID, a.PARENTID, a.CATEGORY, 	(SELECT count(*) FROM DAQ_func_categories WHERE PARENTID = a.CATEGORYID) as SUBCAT_NO, " & _
                                " (SELECT count(*) FROM DAQ_products_categories WHERE CATEGORYID = a.CATEGORYID) as PRODUCT_NO, " & _
                                " a.ENABLE,  	a.ORDER_BY  FROM DAQ_func_categories  as a 	WHERE a.PARENTID = " + subcatid + "  ORDER BY a.ORDER_BY ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            Me.GridView1.DataSource = dt
            Me.GridView1.DataBind()
        End If
    End Sub
    Protected Sub GridView1_RowEditing(ByVal sender As Object, ByVal e As GridViewEditEventArgs) Handles GridView1.RowEditing
        GridView1.EditIndex = e.NewEditIndex
        Call bind()
    End Sub
    Protected Sub GridView1_RowCancelingEdit(ByVal sender As Object, ByVal e As GridViewCancelEditEventArgs) Handles GridView1.RowCancelingEdit
        GridView1.EditIndex = -1
        bind()
    End Sub
    Protected Sub GridView1_RowDeleting(ByVal sender As Object, ByVal e As GridViewDeleteEventArgs) Handles GridView1.RowDeleting     
        Call get_all_catid(GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim)
        bind()
    End Sub
    Protected Sub GridView1_RowUpdating(ByVal sender As Object, ByVal e As GridViewUpdateEventArgs) Handles GridView1.RowUpdating
    
        Dim sql As String = "UPDATE DAQ_func_categories  SET " & _
                             " category = '" + CType(GridView1.Rows(e.RowIndex).Cells(1).FindControl("TextBox2"), TextBox).Text + "', " & _
                              " enable = '" + CType(GridView1.Rows(e.RowIndex).Cells(4).FindControl("DDL1"), DropDownList).SelectedValue + "', " & _
                               "  order_by = '" + CType(GridView1.Rows(e.RowIndex).Cells(0).FindControl("TextBox1"), TextBox).Text + "' " & _
                                " WHERE categoryid = '" + GridView1.DataKeys(e.RowIndex).Values(0).ToString.Trim + "' "
                             
        ' Response.Write("UPDATE: " + sql + "<HR>")
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
                    e.Row.Cells(4).Text = "<input type=""checkbox""  checked=""checked"" />"
                Else
                    e.Row.Cells(4).Text = "<input type=""checkbox"" />"
                End If
            End If
  
        End If
      
       
    End Sub

    Protected Sub addbt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Object = Nothing : Dim max_CATEGORYID As String
        obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT max(CATEGORYID)+1 as NEWCATEGORYID 	FROM daq_func_categories")
        If obj IsNot Nothing Then
            max_CATEGORYID = obj.ToString()
        Else
            max_CATEGORYID = "10000"
        End If
        Dim SQL As String = "INSERT INTO DAQ_func_categories (categoryid,parentid,category,enable, order_by) values( " & _
                             "'" + max_CATEGORYID + "', " & _
                              "'" + subcatid + "', " & _
                               "  '" + add_cat.Value.Replace("'", "''") + "', " & _
                                " 'y'," & _
                                 " '" + add_order_by.Value.Replace("'", "''") + "' )"
        
        'Response.Write(SQL)
        dbUtil.dbExecuteNoQuery("MYLOCAL", SQL)
        bind()
        				
    End Sub

    Protected Sub GridView2_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            Dim DDL As DropDownList = DirectCast(e.Row.Cells(3).FindControl("ddl2_1"), DropDownList)
            DDL.DataSource = getFullCategoryList()
            DDL.DataBind()
            DDL.SelectedValue = GridView2.DataKeys(e.Row.RowIndex).Values(1).ToString       
            DDL.SelectedItem.Attributes.Add("style", "color:#000000;")
            DDL.Style.Add("color", "#808080")
            '''''''''
            Dim DDL2 As DropDownList = DirectCast(e.Row.Cells(3).FindControl("ddl2_2"), DropDownList)
            DDL2.SelectedValue = GridView2.DataKeys(e.Row.RowIndex).Values(2).ToString
            For i As Integer = 0 To DDL2.Items.Count - 1
                If DDL2.Items(i).Value = "y" Then
                    DDL2.Items(i).Attributes.Add("style", "background:#00FF00;")
                Else
                    DDL2.Items(i).Attributes.Add("style", "background:#FF0000;")
                End If
            Next
            If GridView2.DataKeys(e.Row.RowIndex).Values(2).ToString = "n" Then
                e.Row.BackColor = System.Drawing.Color.FromName("#E1E1E1")
            End If
            
        End If
    End Sub
    Protected Sub GridView2_PageIndexChanging(ByVal sender As Object, ByVal e As GridViewPageEventArgs)
        GridView2.PageIndex = e.NewPageIndex
        pro_bind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
  <tr>
    <td width="200"><uc1:Menu ID="Menu1" runat="server" /></td>
    <td valign="top">
    <table>
  <tr> 
<td  align="center" bgcolor="#99CCFF" style="text-align:center; font-size:12px; font-weight:bold;">
    <asp:Literal runat="server" ID="Lit2"></asp:Literal>&nbsp;</td> 
</tr>
    <tr><td>
        <asp:GridView Width="800px" runat="server" ID="GridView1" AutoGenerateColumns="False"   DataKeyNames ="CATID,ENABLE" onrowdatabound="GridView1_RowDataBound">   
        <Columns>
            <asp:TemplateField HeaderText="Order by" SortExpression="ORDER_BY">
            <ItemTemplate> 
           <asp:Label  ID ="Label1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:Label> 
           </ItemTemplate>         
            <EditItemTemplate> 
          <asp:TextBox  ID ="TextBox1"  runat ="server"  Text ='<%#  Bind("ORDER_BY") %> '> </asp:TextBox> 
           </EditItemTemplate>  
           <ItemStyle HorizontalAlign="Center" />   
            </asp:TemplateField>
                 <asp:TemplateField HeaderText="Category" SortExpression="CATEGORY">
            <ItemTemplate> 
           <asp:Label  ID ="Label2"  runat ="server"  Text ='<%#  Bind("CATEGORY") %> '> </asp:Label> 
           </ItemTemplate>         
            <EditItemTemplate> 
          <asp:TextBox  ID ="TextBox2"  runat ="server"  Text ='<%#  Bind("CATEGORY") %> '> </asp:TextBox> 
           </EditItemTemplate>     
            </asp:TemplateField>
         <asp:HyperLinkField DataNavigateUrlFields="CATID" HeaderText="Subcategories"  ItemStyle-Font-Underline="true" ItemStyle-HorizontalAlign="Center"  DataNavigateUrlFormatString="categories.aspx?subcatid={0}" DataTextField="SUBCAT_NO" />
             <asp:TemplateField HeaderText="Products" SortExpression="ORDER_BY">
            <ItemTemplate> 
         <a href="categories.aspx?subcatid=<%# Eval("CATID")%>&do=checkproducts"> <%# Eval("PRODUCT_NO")%></a>
           </ItemTemplate> 
           <ItemStyle HorizontalAlign="Center" Font-Underline="true" />   
                             
            </asp:TemplateField>
               <asp:TemplateField HeaderText="Enable">   
                               <ItemTemplate>                             
                               
                               </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="DDL1" runat="server">
                                <asp:ListItem  Value="y" Text="Enable"></asp:ListItem><asp:ListItem  Value="n" Text="Disable"></asp:ListItem>
                                </asp:DropDownList>
                              
                            </EditItemTemplate>
               </asp:TemplateField>
           <asp:CommandField HeaderText="Update" ShowEditButton="True" />
          <asp:CommandField HeaderText="Delete" ShowDeleteButton="True" />

        </Columns>
        </asp:GridView>
        <asp:Literal runat="server" ID="Lit1"></asp:Literal>
        <br />
        

    </td></tr>
    <tr><td>
    
   <table width="100%" border="0" align="left" cellpadding="0" cellspacing="2">
<tr>
<td colspan="3" align="center" bgcolor="#99CCFF" style="text-align:center; font-size:12px; font-weight:bold;">Add new category</td>
</tr>
<tr><th  style="width:12%; background-color:#CCCCCC">Order by</th><th style="width:45%; background-color:#CCCCCC">Category</th><th style=" background-color:#CCCCCC" ></th></tr>
<tr>
<td  align="center"><input type="text" size="15" id="add_order_by" style="text-align:center;" runat="server" name="add_order_by"/></td>
<td ><input type="text" size="62" id="add_cat" runat="server" name="add_cat"/></td>
<td   style="text-align:left;">  <asp:Button runat="server" Text="Add" ID="addbt"  onclick="addbt_Click" /> </td>
</tr>
</table>
    
    </td></tr>
    </table>
    
    </td>
  </tr>
  <tr><td></td><td>
  
    <asp:GridView Width="100%" runat="server" ID="GridView2"  DataKeyNames="PRODUCTID,CATEGORYID,ENABLE"
          AutoGenerateColumns="False" onrowdatabound="GridView2_RowDataBound" 
          AllowPaging="True" onpageindexchanging="GridView2_PageIndexChanging" 
          PageSize="20">
    
    <Columns>
                            
                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                    <headertemplate>  No. </headertemplate>
                                    <itemtemplate>    <%# Container.DataItemIndex + 1 %> </itemtemplate>
                                </asp:TemplateField> 
<asp:HyperLinkField DataNavigateUrlFields="PRODUCTID" HeaderText="Part Number"   DataNavigateUrlFormatString="product.ASPX?pid={0}" DataTextField="SKU" />
<asp:BoundField DataField="DESCRIPTION" HeaderText="Description"  ReadOnly="true"  />                               

    
      <asp:TemplateField HeaderText="Main Category">
      <ItemTemplate>     
          <asp:DropDownList  ID="ddl2_1" runat="server" DataTextField="full_cat_path" DataValueField="key">
          </asp:DropDownList>
      </ItemTemplate>
      </asp:TemplateField>
      <asp:TemplateField HeaderText="Enable">
      <ItemTemplate>     
          <asp:DropDownList  ID="ddl2_2" runat="server">
          <asp:ListItem Value="y" Text="y"></asp:ListItem>
           <asp:ListItem Value="n" Text="n"></asp:ListItem>
          </asp:DropDownList>
      </ItemTemplate>
      </asp:TemplateField>
    </Columns>

    </asp:GridView> 
  </td></tr>
</table>

</asp:Content>


