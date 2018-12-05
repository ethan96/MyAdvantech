<%@ Control Language="VB" ClassName="eLearningBanner" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Session("user_id") IsNot Nothing Then
            
            'Frank :Below requirement by Jay 2012/06/07            
            'MyAdvantech
            '1.	If the user is Cincinnati employee, Avnet or Arrow users, show eLearning banner and link to external eLearning site at www.advantechpartner.com
            '2.	If the user is AOnline or AENC employees, show eLearning banner and link to internal eLearning at www.advantechaenc.com 
            '3.	Otherwise, not to show eLearning banner

            Dim _ExternalURL As String = "www.advantechpartner.com", _InternalURL As String = "www.advantechaenc.com", _LinkUrl As String = "", _IsShowBanner As Boolean = False
            Dim ws1 As New MyServices, _up As New MyServices.ElearningUserProperties, _user_id As String = HttpContext.Current.User.Identity.Name
            
            If ws1.IsElearningUserV2(_user_id, _up) Then
                Select Case _up.UserType
                    Case MyServices.ElearningUserType.CP 'logic 1 : external user
                        'TC: Please use below ERPIDs to identify the two channel partners, thanks.
                        'Arrow – UCOARR002,  'Avnet – UAZAVN003
                        Select Case _up.AccountErpId.ToUpper
                            Case "UCOARR002", "UAZAVN003" 'Arrow – UCOARR002,'Avnet – UAZAVN003
                                _LinkUrl = _ExternalURL : _IsShowBanner = True
                            Case Else
                                _IsShowBanner = False
                        End Select
                    Case MyServices.ElearningUserType.EZ 'logic 2 : internal user                        
                        Select Case _up.RBU.ToUpper
                            Case "AENC" 'West American
                                'Even AENC employees logged in, we still need to check which homepage he is visiting.
                                'When he visits home_cp.aspx, he will still see what CP sees
                                Dim file() As String = Request.CurrentExecutionFilePath.Split("/")
                                Dim CurrentPage As String = file(file.Length - 1).ToUpper
                                Select Case CurrentPage
                                    Case "HOME_CP.ASPX"
                                        _LinkUrl = _ExternalURL : _IsShowBanner = True
                                    Case Else
                                        _LinkUrl = _InternalURL : _IsShowBanner = True
                                End Select
                            Case "ANADMF" 'AOnLine
                                _LinkUrl = _InternalURL : _IsShowBanner = True
                            Case "AAC" 'Cincinnati employee
                                _LinkUrl = _ExternalURL : _IsShowBanner = True
                            Case Else
                                _IsShowBanner = False
                        End Select
                End Select
            Else
                _IsShowBanner = False
            End If
            hl1.Visible = _IsShowBanner
            If _IsShowBanner Then
                hl1.NavigateUrl = "http://" & _LinkUrl & "?tempid=" + Session("tempid") + "&id=" + _user_id
            End If
        End If
    End Sub
</script>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td>
            <asp:HyperLink runat="server" ID="hl1" Target="_blank" ImageUrl="~/images/elearning.gif" />
        </td>
    </tr>
    <tr>
        <td height="10">
        </td>
    </tr>
</table>