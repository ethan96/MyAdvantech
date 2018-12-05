Imports Microsoft.VisualBasic
Public Class IntelPortal
    Public Shared Allowed2UploadFileUsers() As String = {"paul.stevens@advantech.eu", "jean.ko@advantech.com.tw", "smart.ko@advantech.com.tw", _
                                    "cynthia.wang@advantech.com.tw", "sandra.lin@advantech.com.tw", "frank.chung@advantech.com.tw", _
                                    "tc.chen@advantech.com.tw", "jack.lin@advantech.com.tw"}
    Public Shared Function IsIntelUser() As Boolean
        If HttpContext.Current.User.Identity.Name.EndsWith("@intel.com", StringComparison.OrdinalIgnoreCase) Or _
            Util.IsInternalUser2() Or HttpContext.Current.User.Identity.Name.ToLower() = "ncg@advantech.com" Then
            Return True
        End If
        Return False
    End Function
End Class
