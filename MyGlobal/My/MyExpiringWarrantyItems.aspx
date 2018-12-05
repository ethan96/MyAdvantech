<%@ Page Title="MyAdvantech - My Expiring Warranty Items" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/CustWarrantyItem.ascx" TagName="CustWarrantyItem" TagPrefix="uc1" %>
<script runat="server">

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtWFrom.Text = Now.ToString("yyyy/MM/dd") : Me.txtWTo.Text = DateAdd(DateInterval.Month, 3, Now).ToString("yyyy/MM/dd")
            If Request("ContactCode") IsNot Nothing Then
                Dim Email As String = Util.GetEmailByUniqueId(Trim(Request("ContactCode")))
                Dim ea() As String = Email.Trim.Split("@")
                If ea.Length = 2 Then
                    Dim erpidlist As New ArrayList
                    Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", _
                    String.Format(" select distinct z.company_id " + _
                                  " from sap_dimcompany z inner join siebel_account a on z.company_id=a.erp_id " + _
                                  " inner join siebel_contact b on a.row_id=b.account_row_id " + _
                                  " where b.email_address like '%@{0}'", Trim(ea(1))))
                    If dt.Rows.Count > 0 Then
                        For Each r As DataRow In dt.Rows
                            erpidlist.Add("'" + r.Item("company_id") + "'")
                        Next
                    Else
                        Dim sites() As String = {"RMA", "PZ", "MY"}
                        Dim ws As New SSO.MembershipWebservice : ws.Timeout = 120 * 1000 : Dim p As SSO.SSOUSER = Nothing
                        For Each s As String In sites
                            Try
                                p = ws.getProfile(Email, s)
                                If p.AccountID <> "" Then
                                    dt = dbUtil.dbGetDataTable("RFM", String.Format( _
                                    " select distinct z.company_id " + _
                                    " from sap_dimcompany z inner join siebel_account a on z.company_id=a.erp_id " + _
                                    " where a.row_id ='{0}'", p.AccountID))
                                    For Each r As DataRow In dt.Rows
                                        erpidlist.Add("'" + r.Item("company_id") + "'")
                                    Next
                                Else
                                    If p.company_id <> "" Or p.erpid <> "" Then
                                        dt = dbUtil.dbGetDataTable("RFM", String.Format( _
                                        "select distinct company_id from sap_dimcompany where company_id='{0}' or company_id='{1}'", p.company_id, p.erpid))
                                        For Each r As DataRow In dt.Rows
                                            erpidlist.Add("'" + r.Item("company_id") + "'")
                                        Next
                                    End If
                                End If
                            Catch ex As Exception
                            End Try
                            If erpidlist.Count > 0 Then Exit For
                        Next
                    End If
                    If erpidlist.Count > 0 Then
                        ViewState("cid") = String.Join(",", erpidlist.ToArray(GetType(String)))
                        With Me.cw1
                            .CustId = ViewState("cid")
                            .WFrom = CDate(Me.txtWFrom.Text) : .WTo = CDate(Me.txtWTo.Text)
                        End With
                    End If
                End If
            End If
            
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Not Page.IsPostBack And AccountRowId.Value.Trim <> "" Then
        '    Dim obj As Object = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 account_name from siebel_account where row_id='{0}'", AccountRowId.Value))
        '    If obj IsNot Nothing Then lbAccountName.Text = obj.ToString
        'End If
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        With Me.cw1
            .CustId = ViewState("cid")
            .WFrom = CDate(Me.txtWFrom.Text) : .WTo = CDate(Me.txtWTo.Text)
        End With
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <h3>My Expiring Warranty Items</h3>
            </td>
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <th align="left">Warranty Expire Date Range</th>
                        <td>
                            <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtWFrom" Format="yyyy/MM/dd" />
                            <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtWTo" Format="yyyy/MM/dd" />
                             From:&nbsp;<asp:TextBox runat="server" ID="txtWFrom" />&nbsp;to&nbsp;<asp:TextBox runat="server" ID="txtWTo" />
                        </td>
                    </tr>
                    <tr style="display:none;">
                        <td colspan="2">
                            <asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" />
                        </td>
                    </tr>
                </table>
                
            </td>
        </tr>
        <tr>
            <td>
                <uc1:CustWarrantyItem runat="server" ID="cw1" />
            </td>
        </tr>
    </table>   
</asp:Content>

