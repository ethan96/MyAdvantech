<%@ Control Language="VB" ClassName="Catalog" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql As String = ""
        Dim aa As System.Web.UI.HtmlControls.HtmlGenericControl = Me.FindControl("catalogid")
        Dim htmlPage As String = "<ul id='suckertree1'>"
        sql = "SELECT * FROM CATALOG_SHOW ORDER BY SEQ_NO"
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", sql)
        If Not IsNothing(dt) And dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                htmlPage = htmlPage & String.Format("<li><a href='./Product/Product_Line_New.aspx#{0}'><b>{1}</b></a>", dt.Rows(i).Item("category_id"), dt.Rows(i).Item("catalog_desc"))
                Dim sqltwo As String
                sqltwo = String.Format("SELECT CATEGORY_ID, CATEGORY_NAME, DISPLAY_NAME, IMAGE_ID, SEQ_NO FROM SIEBEL_CATALOG_CATEGORY WHERE PARENT_CATEGORY_ID = '{0}' AND ACTIVE_FLG = 'Y' AND CATEGORY_TYPE = 'Category'", dt.Rows(i).Item("category_id"))
                Dim dttwo As New DataTable
                dttwo = dbUtil.dbGetDataTable("MY", sqltwo)
                If Not IsNothing(dttwo) And dttwo.Rows.Count > 0 Then
                 
                    htmlPage = htmlPage & "<ul>"
                    'htmlPage = htmlPage & dttwo.Rows.Count.ToString
                    For j As Integer = 0 To dttwo.Rows.Count - 1
                        htmlPage = htmlPage & String.Format("<li><a href='./Product/SubCategory.aspx?category_id={0}'>{1}</a></li>", dttwo.Rows(j).Item("CATEGORY_ID"), dttwo.Rows(j).Item("DISPLAY_NAME"))
                    Next

                    htmlPage = htmlPage & "</ul></li>"
                    
                Else
                    htmlPage = htmlPage & "</li>"
                End If
            Next
        End If
        htmlPage = htmlPage & "</ul>"
        
       
        aa.InnerHtml = htmlPage
    End Sub
</script>



    <table width="100%" border="0" cellpadding="0"  cellspacing="0" onmouseover="this.style.cursor='hand'">
        <tr> 
            <td width="2%" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></p></td> 
            <td width="96%" height="20" background="/images/table_fold_top.gif" >
                <table width="100%"  border="0" cellpadding="0" cellspacing="0" class="text">
                    <tr>
                    <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                    <td width="94%"><b>Product Catalog</b></td>
                    </tr>
                </table>                        
            </td>
            <td width="4" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"></td>
        </tr> 
    </table>

    <table width="100%" border="0" width="200" cellpadding="0" cellspacing="0" align="right" >
      
        <tr><td>  <%--    start--%>				        
				    <div class="suckerdiv" id="catalogid" runat="server"></div>    				          
				    <%--    end--%></td></tr>
        <tr><td height="7"></td></tr>
    </table>
<%--</asp:Panel>--%>
