<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)

        'If Pivot.CurrentProfile.UserId.ToUpper.Contains(("Cathee.Cao").ToUpper) OrElse _
        '       Pivot.CurrentProfile.UserId.ToUpper.Contains(("Jay.Lee").ToUpper) OrElse _
        '        Role.IsAdmin Then
        '    Me.lbport.Text = HttpContext.Current.Request.ServerVariables("SERVER_PORT")
        '    Me.lbIsTesting.Text = COMM.Util.IsTesting
        '    Dim _con As New SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        '    Me.lbeQDB.Text = _con.Database
        '    _con = Nothing
        Dim appPath As String = HttpContext.Current.Request.ApplicationPath
        Dim physicalPath As String = HttpContext.Current.Request.MapPath(appPath)
        'Me.lbPubPath.Text = physicalPath
        'End If
      
        Dim _oriphone As String = "+820514412228"
        Dim phoneFormat = "(##)###-###-####"
        
        Dim reg = New Regex("###-###-####")
        
        'reg.re()
        
        Dim _phone As String = formatPhoneNumber(_oriphone, phoneFormat)
        Me.lbPubPath.Text = _phone
    End Sub
    
    Public Shared Function formatPhoneNumber(phoneNum As String, phoneFormat As String) As String

        If phoneFormat = "" Then
            ' Default format is (###) ###-####
            phoneFormat = "###-###-####"
        End If

        ' First, remove everything except of numbers
        Dim regexObj As Regex = New Regex("[^\d]")
        phoneNum = regexObj.Replace(phoneNum, "")

        ' Second, format numbers to phone string 
        If phoneNum.Length > 0 Then
            phoneNum = Convert.ToInt64(phoneNum).ToString(phoneFormat)
        End If

        Return phoneNum
    End Function
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Label ID="lbPubPath" runat="server" Text="Label"></asp:Label>
    </div>
    </form>
</body>
</html>
