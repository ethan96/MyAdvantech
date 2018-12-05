<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        'Frank 2012/03/15: Terms and Conditions control
        Dim _org_id As String = Session("org_id")
        If String.IsNullOrEmpty(_org_id) Then
            _org_id = "US"
        Else
            If _org_id.Length > 1 Then
                _org_id = _org_id.Substring(0, 2).ToUpper
            Else
                _org_id = "US"
            End If
        End If
        
        Dim _url As String = "~/files/Terms_USA.aspx"
        
        Select Case _org_id
            Case "EU"
                _url = "~/files/Terms.aspx"
            Case "TW"
                _url = "~/files/Terms_TW.aspx"
            Case Else
                'US and other Region(not include EU and TW) show Terms of USA
                _url = "~/files/Terms_USA.aspx"
        End Select

        Response.Redirect(_url)
        
    End Sub
</script>

<html>
<head runat="server">
    <title></title>
</head>
<body>
</body>
</html>
