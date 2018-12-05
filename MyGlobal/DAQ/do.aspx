<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("L") IsNot Nothing AndAlso Request("L").ToString <> "" Then
            Select Case Request("L").ToString.ToLower.Trim
                Case "zh-cn"
                    Session("Browser_lan") = "zh-cn"
                Case "zh-tw"
                    Session("Browser_lan") = "zh-tw"
                Case "en"
                    Session("Browser_lan") = "en"
            End Select
        Else
            Dim lan As String = Request.ServerVariables("HTTP_ACCEPT_LANGUAGE").ToString.ToLower
            Select Case 1
                Case InStr(lan, "zh-cn")
                    Session("Browser_lan") = "zh-cn"
                Case InStr(lan, "zh-tw")
                    Session("Browser_lan") = "zh-tw"
                Case Else
                    Session("Browser_lan") = "en"
            End Select
        End If
      Response.Redirect("default.aspx")
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DAQ</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
