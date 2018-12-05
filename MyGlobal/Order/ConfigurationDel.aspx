<%@ Page Language="VB" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim strSql As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_inc1.ValidationStateCheck()
        
        if request("flg") = "quote" then
            Me.strSql = "delete from quotation_catalog_category where catalog_id='" & Session("G_CATALOG_ID") & "'"
            dbUtil.dbExecuteNoQuery("b2b", Me.strSql)
            Exit Sub
        end if
        Me.strSql = "delete from configuration_catalog_category where catalog_id='" & Session("G_CATALOG_ID") & "'"
        dbUtil.dbExecuteNoQuery("b2b", Me.strSql)
        'If Session("btos") = True Then
            Me.strSql = "delete from cart_detail where cart_id='" & Session("cart_id") & "'"
        dbUtil.dbExecuteNoQuery("b2b", Me.strSql)
        Me.strSql = "delete from cart_detail_btos where config_id='" & Session("G_CATALOG_ID") & "'"
        dbUtil.dbExecuteNoQuery("b2b", Me.strSql)
        'End If
        Response.Redirect("../order/ConfigurationPage.aspx?BTOITEM=" & Request("BTOITEM") & "&QTY=" & Request("qty"))
        'BTOITEM=CPU-CARD-BTO&QTY=1
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        
    
    </div>
    </form>
</body>
</html>
