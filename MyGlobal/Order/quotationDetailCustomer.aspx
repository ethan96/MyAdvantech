<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim myBody As String = ""
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim WS As New quote.quoteExit
        'WS.Timeout = -1
        'Me.divContent.InnerHtml = WS.getQuotePageStrCustomer(Request("UID"))
        If Not IsPostBack Then
            Dim sHTML As String = ""
            Dim AlertMsg As New Literal
            Dim EQws As New eQ25WS.eQ25WS
            EQws.Timeout = -1
            'JJ：Test use 8300
            If Util.IsTesting() Then
                EQws.Url = "http://eq.advantech.com:8300/Services/eQ25WS.asmx"
            Else
                EQws.Url = "http://eq.advantech.com/Services/eQ25WS.asmx"
            End If
    
            If Request.QueryString("UID") IsNot Nothing AndAlso Request.QueryString("UID") <> "" Then
                Try
                    '20131107 JJ：call eQ25WS 去下載Detail資料後直接show出在頁面上
                    Me.divContent.InnerHtml = EQws.GetAEUTemplateHtml(Request.QueryString("UID"), Session("user_id"), Session("TempID"))
                Catch ex As Exception
                    '20131107 JJ：if call web service error, send mail to myadvantech and show message to user
                    Dim FROM_Email As String = "myadvantech@advantech.com"
                    Dim TO_Email As String = "myadvantech@advantech.com"
                    Dim Subject_Email As String = "Error：quoteid(" + Request.QueryString("UID") + ") | user_id(" + Session("user_id") + ")"
                    Me.divContent.InnerHtml = ""
                    Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, "", "", Subject_Email, "", ex.ToString)
                    Util.JSAlert(Me.Page, ex.Message.ToString)
                End Try
           
            End If
        End If

        'gvdetail.DataSource = eQuotationUtil.GetQuoteDetailByQuoteid(Request("UID"))
        'gvdetail.DataBind()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        .odiv table
        {
            /*   width: 100%;*/
        }
        .odiv td
        {
            border: solid 1px #EEEEEE;
        }
        .odiv p
        {
            line-height: 20px;
        }
    </style>
    <table align="center" width="100%">
        <tr>
            <td align="center">
                <div runat="server" id="divContent" class="odiv">
                </div>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
