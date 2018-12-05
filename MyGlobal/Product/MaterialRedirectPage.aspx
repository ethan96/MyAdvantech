<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Try
            Dim page_type As String = ""
            Dim url As String = Request("url")
            Select Case LCase(Request("Type"))
                Case "cms"
                    page_type = MyLog.PageType.CMS.ToString
                    url = "http://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=" + Request("rid")
                    If Request("C") = "white papers" Then url = "http://member.advantech.com/yourcontactinformation.aspx?formid=7379e3b5-11fb-4d47-b962-0de7b8df2a32&CMSID=" + Request("rid") + "&callbackurl=" + Request("url")
                Case "lit"
                    page_type = MyLog.PageType.DownloadDocument.ToString
                Case "prod"
                    page_type = MyLog.PageType.ViewProduct.ToString
                Case "wish"
                    page_type = MyLog.PageType.WishList.ToString
            End Select
            Dim type As String = MyLog.GetCateType(Request("C"))
            MyLog.UpdateLog(Session("user_id"), type, Request("rid"), page_type)
            Response.Redirect(url, False)
        Catch ex As Exception
            'Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
        End Try
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        
    </div>
    </form>
</body>
</html>
