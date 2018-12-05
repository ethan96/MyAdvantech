<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<script runat="server">
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
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            Call pro_bind("ALL")
        End If
    End Sub
    Protected Sub pro_bind(ByVal allorsearch As String)
        Dim SQL As String = ""
        If allorsearch = "ALL" Then
            SQL = "SELECT  a.PRODUCTID, a.SKU, a.PRODUCTNAME, a.DESCRIPTION,c.CATEGORYID, a.ENABLE , '' as category " & _
                                " FROM DAQ_products  as a Inner Join DAQ_products_categories as b ON a.PRODUCTID = b.PRODUCTID  " & _
                                "  Inner Join DAQ_func_categories as c ON b.CATEGORYID = c.CATEGORYID  WHERE " & _
                                " b.MAIN =  '0' 	ORDER BY   a.PRODUCTID ASC ,b.CATEGORYID ASC"
            
        Else
        
            Dim P() As String = Split(allorsearch, "#")
            SQL = "SELECT a.PRODUCTID, a.SKU, a.DESCRIPTION, 	c.CATEGORYID,  a.ENABLE, '' as category FROM daq_products as a " & _
                " Inner Join daq_products_categories as b ON a.PRODUCTID = b.PRODUCTID " & _
                 " Inner Join daq_func_categories as c ON b.CATEGORYID = c.CATEGORYID where " & _
                  " a." + P(1) + " like '%" + P(0) + "%' and b.MAIN = '0'   "
            If P(2) <> "a" Then
                SQL = SQL + " and a.enable='" + P(2) + "'"
            End If
            SQL = SQL + " ORDER BY b.CATEGORYID ASC, a.PRODUCTID ASC"
        End If
        'Response.Write("<hr>"+ SQL )
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                dt.Rows(i).Item("category") = getFullCategoryPath(dt.Rows(i).Item("categoryid").ToString.Trim)
            Next
                
            dt.AcceptChanges()
            GridView2.DataSource = dt
            GridView2.DataBind()
        Else
            GridView2.DataSource = dt
            GridView2.DataBind()
        End If
        
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
        pro_bind("ALL")
    End Sub

    Protected Sub Search_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write("pattern" + pattern.Value + "<br>")
        'Response.Write("search_in" + search_in.SelectedValue + "<br>")
        'Response.Write("status" + Request("status") + "<br>")      
        pro_bind(pattern.Value.ToString.Trim  + "#" + search_in.SelectedValue + "#" + Request("status").ToString)
  
    End Sub

    Protected Sub update_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim arr1 As New ArrayList, arr2 As New ArrayList
        For Each r As GridViewRow In GridView2.Rows
            If r.RowType = DataControlRowType.DataRow Then            
                Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
                If cb IsNot Nothing And cb.Checked Then
                    Dim pid As String = GridView2.DataKeys(r.RowIndex).Values(0).ToString()
                    Dim ddl2_1 As DropDownList = CType(r.FindControl("ddl2_1"), DropDownList)
                    Dim ddl2_2 As DropDownList = CType(r.FindControl("ddl2_2"), DropDownList)
                    arr1.Add(String.Format("UPDATE DAQ_products SET enable = '{0}' WHERE productid = '{1}'", ddl2_2.SelectedValue, pid))
                    arr2.Add(String.Format("UPDATE DAQ_products_categories SET categoryid = '{0}' WHERE productid = '{1}' AND main = 'y'", ddl2_1.SelectedValue, pid))
                End If
               
            End If
        Next
        For Each aa As String In arr1
            'Response.Write(aa + "<br>")
            dbUtil.dbExecuteNoQuery("MYLOCAL", aa.ToString)
            'Response.Write("<hr>")
        Next
        For Each aa As String In arr2
            ' Response.Write(aa + "<br>")
            dbUtil.dbExecuteNoQuery("MYLOCAL", aa.ToString)
        Next
        pro_bind(pattern.Value.ToString.Trim  + "#" + search_in.SelectedValue + "#" + Request("status").ToString)
    End Sub

    Protected Sub delete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim arr1 As New ArrayList, arr2 As New ArrayList
        For Each r As GridViewRow In GridView2.Rows
            If r.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
                If cb IsNot Nothing And cb.Checked Then
                    Dim pid As String = GridView2.DataKeys(r.RowIndex).Values(0).ToString()              
                    arr1.Add(String.Format("DELETE FROM DAQ_products WHERE productid = '{0}'", pid))
                    arr2.Add(String.Format("DELETE FROM daq_products_categories WHERE productid = '{0}'", pid))
                End If
               
            End If
        Next
        For Each aa As String In arr1
            Response.Write(aa + "<br>")
            'dbUtil.dbExecuteNoQuery("MYLOCAL", aa.ToString)
            Response.Write("<hr>")
        Next
        For Each aa As String In arr2
            Response.Write(aa + "<br>")
            'dbUtil.dbExecuteNoQuery("MYLOCAL", aa.ToString)
        Next
          pro_bind(pattern.Value.ToString.Trim  + "#" + search_in.SelectedValue + "#" + Request("status").ToString)
    End Sub

  
        
        
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="css.css" rel="stylesheet" type="text/css" />
<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
  <tr>
    <td width="200" valign="top"><uc1:Menu ID="Menu1" runat="server" /></td>
    <td valign="top">
    
    <table><tr><td valign="top">
    
    
    
    <div class="content_box">
<table width="100%" id="products_box">
<tr><th  colspan="2">Search for products</th></tr>
<tr>
<td width="20%">Search for pattern:</td>
<td><input type="text" value="" size="50" runat="server" id="pattern" name="pattern"/>&nbsp;<asp:Button  runat="server" ID="Search" Text="Search" onclick="Search_Click" /></td>


</tr>
<tr><td>Search in:</td><td>

<asp:DropDownList runat="server" id="search_in" AutoPostBack="false">
<asp:ListItem Value="sku" Text="Part Number" Selected="True"> </asp:ListItem>
<asp:ListItem Value="productname" Text="Product Name"> </asp:ListItem>
<asp:ListItem Value="description" Text="Description"> </asp:ListItem>
    </asp:DropDownList>


  <div style="float:right;"> <IFRAME name="cwin"  border="0" marginWidth="0" marginHeight="0" src="Gridview2Excel.aspx" frameBorder="no" width="50" scrolling="no" height="20" ></IFRAME> </div>
</td>
</tr>
<tr>
<td>Product status:</td><td>
<input type="radio" value="a" checked="checked" name="status" />All&nbsp;
<input type="radio" value="y" name="status" />Enable&nbsp;
<input type="radio" value="n" name="status" />Disable
<%--<input type="hidden" value="1" name="search" />--%>
</td>
</tr>
</table>
</div>
    
    </td></tr>
    
    
    <tr><td>
    
    
     <asp:GridView Width="100%" runat="server" ID="GridView2"  DataKeyNames="PRODUCTID,CATEGORYID,ENABLE"
          AutoGenerateColumns="False" onrowdatabound="GridView2_RowDataBound" 
          AllowPaging="True" onpageindexchanging="GridView2_PageIndexChanging" 
          PageSize="20">
    
    <Columns>
                            
                                <asp:TemplateField HeaderStyle-Width="25px" ItemStyle-HorizontalAlign="Center">
                                    <headertemplate>  <asp:CheckBox ID="all" runat="server" /> </headertemplate>
                                    <itemtemplate>     <asp:CheckBox ID="item" runat="server" />  </itemtemplate>
                                    <ItemStyle  HorizontalAlign="Center"/>
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
  <div> <asp:Button runat="server"  Text="Delete" ID="delete" onclick="delete_Click" />  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      <asp:Button runat="server" ID="update" Text="Update" onclick="update_Click" /></div>

    
    </td></tr>
    </table>
    
    
    
    
    
    </td>
    </tr>
    </table>

</asp:Content>

