<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_inc1.ValidationStateCheck()
        
        If Request("cart_id") <> "" Then
            dbUtil.dbExecuteNoQuery("B2B", "delete from cart_master_history where cart_id='" & Request("cart_id") & "'")
            'Me.Global_inc1.dbDataReader()
            dbUtil.dbExecuteNoQuery("B2B", "delete from cart_detail_history where cart_id='" & Request("cart_id") & "'")
            'Me.Global_inc1.dbDataReader()
        End If
        
        Response.Redirect("../order/CartHistory_List.aspx")
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
