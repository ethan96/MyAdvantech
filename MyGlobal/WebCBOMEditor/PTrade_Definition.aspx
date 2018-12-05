<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="CBOM---P-Trade List" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Write("on Developing..."):Response.End()
        Dim strSQL As String = ""
        strSQL = " Select C.CATEGORY_NAME,P.Status,C.CATEGORY_DESC,C.Parent_Category_ID as PARENT_CATEGORY_ID from CBOM_CATALOG_CATEGORY as C, Product as P " & _
                 " where C.Category_Type='Component'  " & _
                 " and P.Part_No = C.Category_id " & _
                 " and (C.Category_id like 'P-%' " & _
                 " Or dbo.IsPTrade(C.Category_id)=1) " & _
                 " order by C.CATEGORY_NAME"
        Me.SqlDataSource1.SelectCommand = strSQL
        
    End Sub
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Then
            e.Row.Cells(0).Text = "CATEGORY NAME"
            e.Row.Cells(1).Text = "STATUS"
            e.Row.Cells(2).Text = "CATEGORY DESC"
            e.Row.Cells(3).Text = "PARENT CATEGORY ID"
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(0).HorizontalAlign = HorizontalAlign.Left
            e.Row.Cells(1).HorizontalAlign = HorizontalAlign.Left
            e.Row.Cells(2).HorizontalAlign = HorizontalAlign.Left
            e.Row.Cells(3).HorizontalAlign = HorizontalAlign.Left
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td align="center">
               
            </td>
        </tr>
        <tr>
            <td height="5">&nbsp;
            </td>
        </tr>
        <tr>
            <td align="center">
                <table border="0" width="98%" cellspacing="0" cellpadding="0">
                    <tr>
                        <td align="left" height="5"><a href="../home_old.aspx">Home</a>>>><a href="../Admin/B2B_Admin_portal.aspx">Admin</a>>>>CBOM P-Trade
                        </td>
                    </tr>
                    <tr>
                        <td height="5">&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td align="left">
                            <h2>CBOM P-TRADE Item Listing</h2>
                        </td>
                    </tr>
                    <tr>
                        <td height="5">&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td height="5">
                        
                        
                        
                        </td>
                    </tr>
                    <tr>
                        <td align="center">
                        
                        
                            <table cellpadding="1"  width="100%"><tr><td style="background-color:#666666">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align:middle" ID="Table3">
                    <tr>
                        <td style="padding-left:10px;border-bottom:#ffffff 1px solid;height:20px;background-color:#6699CC" align="left" valign="middle" class="text">
                        <font color="#ffffff"><b>P-TRADE Item Listing</b></font></td></tr>
                        <tr><td>
                                            <asp:GridView runat="server" ID="GridView1" 
                                                            DataSourceID ="SqlDataSource1" 
                                                onrowdatabound="GridView1_RowDataBound" AllowPaging="True" PageIndex="0" PageSize="30" DataKeyNames="CATEGORY_NAME" Width="100%">
                                             
                                            </asp:GridView>		
								
								
								
														
                                            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
                                           
                                           <DeleteParameters>
                                           <asp:Parameter Type="String" Name="CATEGORY_NAME" />
                                           </DeleteParameters>
                                           
                                           <UpdateParameters>
                                           <asp:Parameter Type="String" Name="original_CATEGORY_NAME" />
                                           </UpdateParameters>
                                           
                                            </asp:SqlDataSource>
								 </td></tr><tr><td id="tdTotal" align="right" style="background-color:#ffffff" runat="server"></td></tr></table>
				</td></tr></table>
				
				
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="5">&nbsp;
            </td>
        </tr>
        <tr>
            <td>
               
            </td>
        </tr>
    </table>
</asp:Content>

