<%@ Page Language="VB" %>
<%@ Register src="../Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Request("ID")) AndAlso Request("ID") <> "" Then
            If Not IsNothing(Request("USER")) AndAlso Request("USER") <> "" Then
                Dim ID As String = Request("ID")
                Dim USER As String = Request("USER")

                'Dim sso As New SSO.MembershipWebservice, Validated As Boolean = False
                'sso.Timeout = -1
                'Validated = sso.validateTemidEmail(Util.GetClientIP(), ID, "MY", USER)
                'If Validated Then
                '    Access(USER)
                'Else
                '    If CheckSSO(ID, USER) Then
                '        Access(USER)
                '    Else
                '        Response.Write("SSO login failed. please logout and re-login.") : Response.End()
                '    End If
                'End If
                Dim Validated As Boolean = False
                Dim msg As String = ""
                Validated = MYASSO.LoginBySSO(ID, USER, msg)
                If Validated Then
                    Access(USER)
                Else
                    Response.Write(msg) : Response.End()
                End If
            Else
                If Request.IsAuthenticated Then
                    If Not IsNothing(Request("RURL")) AndAlso Request("RURL") <> "" Then
                        Response.Redirect(Request("RURL"))
                    Else
                        Response.Redirect("~/home.aspx")
                    End If
                End If
            End If
        End If
    End Sub
    

    
    Sub Access(ByVal User As String)
        FormsAuthentication.SetAuthCookie(User, False)
        AuthUtil.SetSessionById(User)
        If Not IsNothing(Request("COMPANY")) AndAlso Request("COMPANY") <> "" Then
            Dim Company As String = Request("COMPANY")
            
            'Frank: If company does not exist in local table sap_dimcompany, then executing the real time syne company function
            Dim SyncCompanyErrMsg As String = String.Empty
            If Not MYSAPBIZ.is_Valid_Company_Id(Company) Then
                'Dim sc As New SAPDAL.syncSingleCompany
                Dim cl As New ArrayList
                cl.Add(Company)
                Dim ds As SAPDAL.DimCompanySet = SAPDAL.syncSingleCompany.syncSingleSAPCustomer(cl, False, SyncCompanyErrMsg)
                If ds Is Nothing OrElse IsNothing(ds.Company) OrElse ds.Company.Count <= 0 Then
                    Response.Write("Company id " & Company & " is invalid and cannot be synced from SAP. " & SyncCompanyErrMsg) : Response.End()
                End If
            End If
            
            If MYSAPBIZ.is_Valid_Company_Id(Company) Then
                Me.chgCompany.TargetCompanyId = Company
                Me.chgCompany.ChangeToCompanyId()
            Else
                Response.Write("Company id " & Company & " is invalid and cannot be changed to.") : Response.End()
            End If
        End If
        If Not IsNothing(Request("ORG")) AndAlso Request("ORG") <> "" Then
            Dim au As New AuthUtil : au.ChangeCompanyId(Session("company_id"), Request("ORG"))
        End If
                   
        If Not IsNothing(Request("RURL")) AndAlso Request("RURL") <> "" Then
            Response.Redirect(Request("RURL"))
        Else
            Response.Redirect("~/home.aspx")
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
    <uc1:ChangeCompany runat="server" ID="chgCompany" Visible="false" />
    </div>
    </form>
</body>
</html>
