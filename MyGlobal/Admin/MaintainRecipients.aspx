<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public _maillist As DataTable
    Public ReadOnly Property maillist As DataTable
        Get
            If _maillist Is Nothing Then
                _maillist = dbUtil.dbGetDataTable("mylocal", "select  *  from  ScheduleMails ")
            End If
            Return _maillist
        End Get
        'Set(ByVal value As DataTable)
        '    _maillist = value
        'End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not IsPostBack Then
            BindRP()
        End If
    End Sub
    Private Function IsPowerUser() As Boolean
        Dim admins() As String = New String() {"louis.lin@advantech.eu", "erika.molnarova@advantech.nl"}
        'If Session("account_status") IsNot Nothing AndAlso String.Equals(Session("account_status"), "CP") Then
        'End If
        If Util.IsInternalUser2() OrElse Util.IsAEUIT() OrElse admins.Contains(HttpContext.Current.User.Identity.Name.ToLower()) Then
            Return True
        End If
        Return False
    End Function
    Protected Sub BindRP()
        Dim dt As New DataTable
        If IsPowerUser() Then
            dt = dbUtil.dbGetDataTable("mylocal", "select  [ID] ,[COMPANYID],[MON] ,[TUE],[WED] ,[THU] ,[SAT],[SUN] ,[FRI],[LAST_UPD_BY],[LAST_UPD_DATE]  from  ScheduleHead order by companyid ")
            Repeater1.DataSource = dt
            Repeater1.DataBind()
        End If
    End Sub
    Protected Function GetData(ByVal obj As Object) As DataTable
        Dim dt As DataTable = New DataTable()
        If Me.maillist IsNot Nothing Then
            Dim dr As DataRow() = Me.maillist.Select(String.Format(" headid= {0}", obj))
            If dr.Length > 0 Then
                dt = dr.CopyToDataTable()
            End If

        End If
        'Dim dt As DataTable = SqlHelper.GetDataTableBySQLV2("select *  from ReportUnit where parentid={0} order by name", obj)
        Return dt
    End Function

    Protected Sub btadd1_Click(sender As Object, e As EventArgs)
        Dim erpid As String = TBErpID.Text.Trim().Replace("'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select  top 1 COMPANY_ID from SAP_DIMCOMPANY where COMPANY_ID='{0}'", erpid))
        If dt.Rows.Count = 0 Then
            Util.AjaxJSAlert(UpdatePanel1, "CompanyID is invalid")
            TBErpID.Focus()
            Exit Sub
        End If
        
        dt = dbUtil.dbGetDataTable("mylocal", String.Format("select  top 1 COMPANYID   from  ScheduleHead where COMPANYID='{0}'", erpid))
        If dt.Rows.Count > 0 Then
            Util.AjaxJSAlert(UpdatePanel1, "CompanyID already exists")
            TBErpID.Focus()
            Exit Sub
        End If
        Dim SUN As Integer = 0, MON As Integer = 0, TUE As Integer = 0, WED As Integer = 0, THU As Integer = 0, FRI As Integer = 0, SAT As Integer = 0
        If Request("SUNadd") IsNot Nothing Then SUN = 1
        If Request("MONadd") IsNot Nothing Then MON = 1
        If Request("TUEadd") IsNot Nothing Then TUE = 1
        If Request("WEDadd") IsNot Nothing Then WED = 1
        If Request("THUadd") IsNot Nothing Then THU = 1
        If Request("FRIadd") IsNot Nothing Then FRI = 1
        If Request("SATadd") IsNot Nothing Then SAT = 1
        If SUN = 0 AndAlso MON = 0 AndAlso TUE = 0 AndAlso WED = 0 AndAlso THU = 0 AndAlso FRI = 0 AndAlso SAT = 0 Then
            Util.AjaxJSAlert(UpdatePanel1, " Please select at least one day")
            Exit Sub
        End If
        Dim sql As String = String.Format("INSERT INTO [ScheduleHead]  ([COMPANYID] ,SUN,MON,[TUE],[WED] ,[THU],[FRI],[SAT],[LAST_UPD_BY],[LAST_UPD_DATE]) VALUES('{0}',{1},{2},{3},{4},{5},{6},{7},'{8}','{9}')", _
                                        erpid, SUN, MON, TUE, WED, THU, FRI, SAT, HttpContext.Current.User.Identity.Name, DateTime.Now)
        Dim retint As Integer = dbUtil.dbExecuteNoQuery("mylocal", sql)
        If retint > 0 Then
            BindRP()
            Util.AjaxJSAlert(UpdatePanel1, "Add successful")
        End If
        
    End Sub

    Protected Sub btadd_Click(sender As Object, e As EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim headid As String = bt.CommandArgument
        Dim email As String = ""
        If Request("mailadrr" + headid) IsNot Nothing Then
            email = Request("mailadrr" + headid)
        End If
        If Util.IsValidEmailFormat(email) Then
            Dim sql As String = String.Format("INSERT INTO [ScheduleMails] ([MAIL],[HeadID] ,[LAST_UPD_BY] ,[LAST_UPD_DATE]) VALUES('{0}',{1},'{2}','{3}')", email, headid, HttpContext.Current.User.Identity.Name, DateTime.Now)
            Dim retint As Integer = dbUtil.dbExecuteNoQuery("mylocal", sql)
            If retint > 0 Then
                BindRP()
            End If
        
        End If
        'Response.Write(headid)
    End Sub

    Protected Sub imgbt_Click(sender As Object, e As ImageClickEventArgs)
        Dim bt As ImageButton = CType(sender, ImageButton)
        Dim id As String = bt.CommandArgument
        Dim sql As String = String.Format("delete from [ScheduleMails] where id={0}", id)
        Dim retint As Integer = dbUtil.dbExecuteNoQuery("mylocal", sql)
        If retint > 0 Then
            BindRP()
             Util.AjaxJSAlert(UpdatePanel1, "Delete successful")
        End If
    End Sub

    Protected Sub btsave_Click(sender As Object, e As EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim headid As String = bt.CommandArgument
        Dim SUN As Integer = 0, MON As Integer = 0, TUE As Integer = 0, WED As Integer = 0, THU As Integer = 0, FRI As Integer = 0, SAT As Integer = 0
        If Request("SUN" + headid) IsNot Nothing Then SUN = 1
        If Request("MON" + headid) IsNot Nothing Then MON = 1
        If Request("TUE" + headid) IsNot Nothing Then TUE = 1
        If Request("WED" + headid) IsNot Nothing Then WED = 1
        If Request("THU" + headid) IsNot Nothing Then THU = 1
        If Request("FRI" + headid) IsNot Nothing Then FRI = 1
        If Request("SAT" + headid) IsNot Nothing Then SAT = 1
        Dim sql As String = String.Format("update ScheduleHead set mon={0},tue={1},wed={2},thu={3},fri={4},sat={5},sun={6},LAST_UPD_BY='{8}',LAST_UPD_DATE='{9}'  where id={7}", MON, TUE, WED, THU, FRI, SAT, SUN, headid, HttpContext.Current.User.Identity.Name, DateTime.Now)
        Dim retint As Integer = dbUtil.dbExecuteNoQuery("mylocal", sql)
        If retint > 0 Then
            BindRP()
            Util.AjaxJSAlert(UpdatePanel1, "Save successful")
        End If
    End Sub

    Protected Sub Btdel_Click(sender As Object, e As EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim headid As String = bt.CommandArgument

        Dim sql As String = String.Format("delete from  ScheduleMails where headid ={0};delete from ScheduleHead where id= {0}", headid)
        Dim retint As Integer = dbUtil.dbExecuteNoQuery("mylocal", sql)
        If retint > 0 Then
            BindRP()
            Util.AjaxJSAlert(UpdatePanel1, "Remove successful")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style>
        .textcenter {
            text-align: center;
            height: 25px;
            vertical-align: middle;
        }

        .thc td {
            font-weight: 400;
        }

        .table1 {
            background: #808080;
        }

            .table1 td, .table1 th {
                background: #FFFFFF;
            }
    </style>
    <table width="100%" border="0">
        <tr>
            <td width="230" height="30">CompanyID:
                <asp:TextBox ID="TBErpID" runat="server"></asp:TextBox>
            </td>


            <td width="290">
                <input name="SUNadd" type="checkbox" />SUN
            <input name="MONadd" type="checkbox" />MON
            <input name="TUEadd" type="checkbox" />TUE
              <input name="WEDadd" type="checkbox" />WED
              <input name="THUadd" type="checkbox" />THU
              <input name="FRIadd" type="checkbox" />FRI
               <input name="SATadd" type="checkbox" />SAT</td>
            <td>
                <asp:Button ID="btadd1" runat="server" Text="Add" OnClick="btadd1_Click" />

            </td>
        </tr>
    </table>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>


    <table width="100%" cellpadding="3" cellspacing="1" border="0" class="table1">
        <tr class="thc">
            <td class="textcenter"><strong>CompanyID</strong></td> 
            <td class="textcenter"><strong>SUN</strong>
            </td>
            <td class="textcenter"><strong>MON</strong>
            </td>
            <td class="textcenter"><strong>TUE</strong>
            </td>
            <td class="textcenter"><strong>WED</strong>
            </td>
            <td class="textcenter"><strong>THU</strong>
            </td>
            <td class="textcenter"><strong>FRI</strong>
            </td>
            <td class="textcenter"><strong>SAT</strong>
            </td>
            <td></td>
            <td  class="textcenter"><strong>Recipients</strong></td>
               <td class="textcenter"><strong>Remove this companyID ?</strong></td>
        </tr>
        <asp:Repeater ID="Repeater1" runat="server">
            <ItemTemplate>
                <tr>
                    <td class="textcenter"><%#Eval("companyid")%></td>
                    <td class="textcenter">
                        <input name="SUN<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("SUN") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="MON<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("MON") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="TUE<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("TUE") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="WED<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("WED") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="THU<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("THU") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="FRI<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("FRI") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <input name="SAT<%#Eval("id")%>" type="checkbox" <%# IIf(Eval("SAT") = 1, "checked='checked'", "")%> />
                    </td>
                    <td class="textcenter">
                        <asp:Button ID="btsave" runat="server" Text="Save schedule" OnClick="btsave_Click" CommandArgument='<%#Eval("id")%>' />

                    </td>
                    <td>
                        <asp:Repeater ID="Repeater2" runat="server" DataSource='<%# GetData(Eval("id")) %>'>
                            <ItemTemplate>
                                <div>
                                    <%# Eval("mail")%>  &nbsp;&nbsp;<asp:ImageButton ID="imgbt" runat="server" ImageUrl="~/Images/btn_del.gif" CommandArgument='<%#Eval("id")%>' OnClick="imgbt_Click" />
                                </div>

                            </ItemTemplate>
                        </asp:Repeater>
                        <div>
                            <input name="mailadrr<%#Eval("id")%>" type="text" />
                            <asp:Button ID="btadd" runat="server" Text="Add" OnClick="btadd_Click" CommandArgument='<%#Eval("id")%>' />

                        </div>
                    </td>
                        <td class="textcenter">
                        <asp:Button ID="Btdel" runat="server" Text="Remove"  OnClientClick="return confirmjs();"  CommandArgument='<%#Eval("id")%>' OnClick="Btdel_Click" />
                    </td>
                </tr>
            </ItemTemplate>
        </asp:Repeater>
    </table>

            </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btadd1" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
    <script>
        function confirmjs() {
            if (confirm("Are you sure you want to delete it？")) {
                return true;
            }
            else {
                return false;
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

