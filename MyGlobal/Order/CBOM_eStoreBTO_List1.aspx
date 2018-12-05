<%@ Page Title="MyAdvantech - CBOM List" ValidateRequest="false" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("org_id") Is Nothing OrElse Session("org_id").ToString <> "US01" Then
            Response.End()
        End If
        If Request("CATEGORY") IsNot Nothing AndAlso Request("CATEGORY").ToString <> "" Then
            SqlDataSource1.SelectCommand = ""
        Else
            SqlDataSource1.SelectCommand = String.Format(" SELECT distinct CATEGORY3  from ESTORE_BTOS where storeid='{0}'", "AUS")          
        End If
    End Sub
    Dim CATEGORY3_str As String = ""
    Protected Function GetData(ByVal obj As Object) As DataTable
        Dim sql As String = "SELECT distinct CATEGORY2  from ESTORE_BTOS where CATEGORY3='" + obj.ToString() + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        dt.Columns.Add(New DataColumn("Parent", GetType(String)))
        For i As Integer = 0 To dt.Rows.Count - 1
            dt.Rows(i).Item("Parent") = obj.ToString.Trim
        Next
        dt.AcceptChanges()
        Return dt
    End Function

    Protected Sub DataList1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        CATEGORY3_str = DataList1.DataKeys(e.Item.ItemIndex).ToString().Trim()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <style type="text/css">
        .eStoreList{padding:5px 5px 5px 15px; list-style-image:url(../IMAGES/arrow_black2.jpg); vertical-align:top;}
    </style>
    <table width="100%" border="0" align="center">
      <tr>
        <td><h1>Show All Systems</h1></td>
      </tr>
      <tr>
        <td>
            <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#CCCCCC">
              <tr>
                <td bgcolor="#FFFFFF">
                    <asp:DataList ID="DataList1" runat="server" DataKeyField="CATEGORY3"  RepeatColumns="3"  DataSourceID="SqlDataSource1" Width="100%" RepeatDirection="Horizontal" ItemStyle-Width="33%" ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Top" OnItemDataBound="DataList1_ItemDataBound">
                        <ItemTemplate>
                            <table   border="0" align="center" >
                              <tr><td height="10px"></td></tr>
                              <tr>
                                <td valign="top" width="242px" height="210px" style="background-image:url(../images/bg1.jpg);background-repeat: no-repeat;background-position: left top; padding-left:8px; padding-top:15px;"
                                    onmouseover="this.style.background='url(../images/bg2.jpg)';this.style.backgroundRepeat='no-repeat'"  onmouseout="this.style.background='url(../images/bg1.jpg)'; this.style.backgroundRepeat='no-repeat'" >
                                    <h3><%--<a href="./CBOM_eStoreBTO_List2.aspx?CATEGORY=<%# Eval("CATEGORY3")%>"> --%><%# Eval("CATEGORY3")%><%--</a>--%></h3>       
                                    <ul class="eStoreList"> 
                                        <asp:Repeater ID="Repeater1" runat="server" DataSource='<%# GetData(Eval("CATEGORY3")) %>'>
                                        <ItemTemplate>
                                            <li>
                                                <a href="./CBOM_eStoreBTO_List3.aspx?CATEGORY2=<%# Eval("CATEGORY2")%>&CATEGORY3=<%# Eval("Parent")%>" >
                                                    <%# Eval("CATEGORY2")%>
                                                </a>
                                            </li>
                                        </ItemTemplate>                                    
                                        </asp:Repeater>          
                	                      
                                    </ul>
                                </td>
                              </tr>
                            </table>
                       
                               
                     
                             
                        </ItemTemplate>
                    </asp:DataList>
                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:MY %>"></asp:SqlDataSource>
                </td>
              </tr>
        </table>
    </td>
    </tr>
    </table>

</asp:Content>


