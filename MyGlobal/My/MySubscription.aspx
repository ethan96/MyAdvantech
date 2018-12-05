<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="My Subscription" %>

<%@ Import Namespace="SiebelBusObjectInterfaces" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        txtEmailId.Text = Session("user_id")
        
    End Sub
    
    Protected Sub cblSubscribed_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If cblSubscribed.Items.Count = 0 Then lblNonEnews.Visible = True Else lblNonEnews.Visible = False
        'Dim strEnews As New ArrayList
        For i As Integer = 0 To cblSubscribed.Items.Count - 1
            cblSubscribed.Items(i).Selected = True
            'strEnews.Add("N'" + cblSubscribed.Items(i).Text + "'")
        Next
        'Dim sql As String = "select * from siebel_contact_interestedEnews_lov where 1=1"
        'If strEnews.Count > 0 Then
        '    sql += " and value not in (" + String.Join(",", strEnews.ToArray(GetType(String))) + ")"
        'End If
        'Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", sql)
        'Dim arr As New ArrayList
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If ContainsChinese(dt.Rows(i).Item(0).ToString) Then
        '        dt.Rows(i).Delete()
        '    Else
        '        arr.Add("'" + dt.Rows(i).Item(0).ToString + "'")
        '    End If
        'Next
        'If arr.Count > 0 Then
        '    SqlDataSource2.SelectCommand = sql + " and value in (" + String.Join(",", arr.ToArray(GetType(String))) + ")"
        'Else
        '    SqlDataSource2.SelectCommand = sql
        'End If
        
    End Sub

    Protected Sub btnSubscribe_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim siebel_ws As New aeu_eai2000.Siebel_WS
        siebel_ws.UseDefaultCredentials = True
        siebel_ws.Timeout = 300000
        
        Dim UnInterestedEnews As New ArrayList
        
        For i As Integer = 0 To cblSubscribed.Items.Count - 1
            If cblSubscribed.Items(i).Selected = False Then
                UnInterestedEnews.Add(cblSubscribed.Items(i).Value)
            End If
        Next
        'Util.JSAlert(Page, String.Join("|", UnInterestedEnews.ToArray(GetType(String))))
        'Exit Sub
        If UnInterestedEnews.Count > 0 Then
            siebel_ws.SubscribeENews2(Session("user_id"), String.Join("|", UnInterestedEnews.ToArray(GetType(String))), False)
            Dim arrEnews As New ArrayList
            For Each enews As String In UnInterestedEnews.ToArray()
                If enews <> "" Then arrEnews.Add("'" + enews + "'")
            Next
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from SIEBEL_CONTACT_INTERESTED_ENEWS where name in ({1}) and contact_row_id in (select row_id from siebel_contact where email_address ='{0}')", Session("user_id"), String.Join(",", arrEnews.ToArray())))
        End If
        
        
        Dim InterestedEnews As New ArrayList
        For i = 0 To cblUnSubscribed.Items.Count - 1
            If cblUnSubscribed.Items(i).Selected = True Then
                InterestedEnews.Add(cblUnSubscribed.Items(i).Value)
            End If
        Next
        'Util.JSAlert(Page, String.Join("|", InterestedEnews.ToArray(Type.GetType("System.String"))))
        If InterestedEnews.Count > 0 Then
            siebel_ws.SubscribeENews2(Session("user_id"), String.Join("|", InterestedEnews.ToArray(Type.GetType("System.String"))), True)
            Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select row_id from siebel_contact where email_address='{0}'", Session("user_id")))
            For Each enews As String In InterestedEnews.ToArray()
                If enews <> "" Then
                    For Each row As DataRow In dt.Rows
                        dbUtil.dbExecuteNoQuery("MY", String.Format("insert into SIEBEL_CONTACT_INTERESTED_ENEWS (contact_row_id,name,primary_flag) values ('{0}','{1}','0')", row.Item(0), enews))
                    Next
                End If
            Next
        End If
        
        cblSubscribed.DataBind() : cblUnSubscribed.DataBind()
        'Response.AddHeader("Refresh", "10")
        Response.Redirect("/My/MySubscription.aspx")
    End Sub
    
    Public Function SubscribeENews2(ByVal Email As String, ByVal eNewsName As String, ByVal IsSubscribe As Boolean) As Boolean
        Dim NewsArray() As String = eNewsName.Split("|")
        If NewsArray.Length = 0 Then Return True
        Dim BusObj As SiebelBusObjectInterfaces.SiebelBusObject = Nothing
        Dim BusComp As SiebelBusObjectInterfaces.SiebelBusComp = Nothing
        Dim retFlag As Boolean = False
        If Not getSiebelConn("Contact", "Contact", BusObj, BusComp, True) Then
            Return False
        End If
        With BusComp
            .ActivateField("Email Address") : .ActivateField("Interested eNews")
            .SetViewMode(9) : .ClearToQuery() : .SetSearchSpec("Email Address", Email) : .ExecuteQuery(1)
        End With
        Dim nextRow As Boolean = BusComp.FirstRecord
        While nextRow
            For Each news As String In NewsArray
                Dim enBComp As SiebelBusComp = BusComp.GetMVGBusComp("Interested eNews")
                If IsSubscribe Then
                    Dim enPick As SiebelBusComp = enBComp.GetAssocBusComp()
                    With enPick
                        If news.Contains("(") Then
                            .ActivateField("Name") : .SetViewMode(3) : .ClearToQuery() : .ExecuteQuery(1)
                            While .NextRecord
                                If .GetFieldValue("Name") = news Then
                                    .Associate(0) : retFlag = True
                                End If
                                If retFlag = True Then Exit While
                            End While
                        Else
                            .ActivateField("Name") : .SetViewMode(3) : .ClearToQuery() : .SetSearchSpec("Name", news) : .ExecuteQuery(1)
                            If .FirstRecord Then
                                .Associate(0) : retFlag = True
                            End If
                        End If
                        
                    End With
                Else
                    If news.Contains("(") Then
                        enBComp.ClearToQuery() : enBComp.ExecuteQuery(1)
                        While enBComp.NextRecord
                            If enBComp.GetFieldValue("Name") = news Then
                                retFlag = enBComp.DeleteRecord()
                            End If
                        End While
                    Else
                        enBComp.ClearToQuery() : enBComp.SetSearchSpec("Name", news) : enBComp.ExecuteQuery(1)
                        If enBComp.FirstRecord Then retFlag = enBComp.DeleteRecord()
                    End If
                End If
            Next
            nextRow = BusComp.NextRecord
        End While
        Return retFlag
    End Function
    
    Public Shared Function getSiebelConn( _
   ByVal BusObjName As String, ByVal BusCompName As String, ByRef BusObj As SiebelBusObject, _
   ByRef BusComp As SiebelBusComp, Optional ByVal ConnectToACLSiebel As Boolean = False) As Boolean
        If Not ConnectToACLSiebel Then
            Dim OwnerID As String = ConfigurationManager.AppSettings("CRMEUId")
            Dim OwnerPassword As String = ConfigurationManager.AppSettings("CRMEUPwd")
            Dim connStr As String = "host=" + """siebel://" + ConfigurationManager.AppSettings("CRMEUConnString") + """"
            Dim lng As String = " lang=" + """ENU"""
            Dim SiebelApplication As New SiebelBusObjectInterfaces.SiebelDataControl
            Dim blnConnected As Boolean = SiebelApplication.Login(connStr + lng, OwnerID, OwnerPassword)
            If Not blnConnected Then
                Throw New Exception("Can't connect to Siebel")
            End If
            BusObj = SiebelApplication.GetBusObject(BusObjName) : BusComp = BusObj.GetBusComp(BusCompName)
            Return True
        Else
            Dim OwnerID As String = ConfigurationManager.AppSettings("CRMHQId")
            Dim OwnerPassword As String = ConfigurationManager.AppSettings("CRMHQPwd")
            Dim connStr As String = "host=" + """siebel://" + ConfigurationManager.AppSettings("CRMHQConnString") + """"
            Dim lng As String = " lang=" + """ENU"""
            Dim SiebelApplication As New SiebelBusObjectInterfaces.SiebelDataControl
            Dim blnConnected As Boolean = SiebelApplication.Login(connStr + lng, OwnerID, OwnerPassword)
            If Not blnConnected Then
                Throw New Exception("Can't connect to Siebel")
            End If
            BusObj = SiebelApplication.GetBusObject(BusObjName) : BusComp = BusObj.GetBusComp(BusCompName)
            Return True
        End If

    End Function
    
    Public Shared Function ContainsChinese(ByVal str As String) As Boolean
        Dim num1 As Integer = 0
        Dim num2 As Integer = 0
        Do
            num2 = Char.ConvertToUtf32(str, num1)
            If ((num2 >= CLng("&H4E00")) And (num2 <= CLng("&H9FFF"))) Then
                Return True
            End If
            num1 += 1
        Loop While (num1 < str.Length)
        Return False
    End Function
    
    Protected Sub cblSubscribed_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", "SELECT distinct a.NAME as value FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID where c.EMAIL_ADDR ='" + Session("user_id") + "' and b.TYPE='Interested eNews'")
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If ContainsChinese(dt.Rows(i).Item(0).ToString()) Then dt.Rows(i).Delete()
        'Next
        'cblSubscribed.DataSource = dt
        'cblSubscribed.DataBind()
    End Sub

    Protected Sub cblUnSubscribed_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim strEnews As New ArrayList
        'For i As Integer = 0 To cblSubscribed.Items.Count - 1
        '    cblSubscribed.Items(i).Selected = True
        '    strEnews.Add("N'" + cblSubscribed.Items(i).Text + "'")
        'Next
        'Dim sql As String = "select * from siebel_contact_interestedEnews_lov"
        'If strEnews.Count > 0 Then
        '    sql += " where value not in (" + String.Join(",", strEnews.ToArray(GetType(String))) + ")"
        'End If
        'Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", sql)
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If ContainsChinese(dt.Rows(i).Item(0).ToString()) Then dt.Rows(i).Delete()
        'Next
        'cblUnSubscribed.DataSource = dt
        'cblUnSubscribed.DataBind()
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim sql As String = "SELECT distinct a.NAME as value FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID where c.EMAIL_ADDR ='" + Session("user_id") + "' and b.TYPE='Interested eNews'"
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sql)
        'Dim arr As New ArrayList
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If ContainsChinese(dt.Rows(i).Item(0).ToString()) Then
        '        dt.Rows(i).Delete()
        '    Else
        '        arr.Add("'" + dt.Rows(i).Item(0).ToString + "'")
        '    End If
        'Next
        'If arr.Count > 0 Then
        '    SqlDataSource1.SelectCommand = "SELECT distinct a.NAME as value FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID where c.EMAIL_ADDR ='" + Session("user_id") + "' and b.TYPE='Interested eNews' and a.NAME in (" + String.Join(",", arr.ToArray(GetType(String))) + ")"
        'End If
        Dim sql As String = String.Format("select distinct name from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID in (select row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}')", Session("user_id"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        Dim arr As New ArrayList
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                arr.Add("N'" + dt.Rows(i).Item(0).ToString + "'")
            Next
        End If
        If arr.Count > 0 Then
            sql = "select text,value from SIEBEL_CONTACT_INTERESTED_ENEWS_MODIFIED where value in (" + String.Join(",", arr.ToArray()) + ")"
            If Not Session("user_id").ToString.Contains("@advantech") Then
                Dim dt1 As DataTable = dbUtil.dbGetDataTable("MY", "select distinct isnull(b.account_status,'') from siebel_contact a left join siebel_account b on a.account_row_id=b.row_id and a.email_address='" + Session("user_id").ToString + "'")
                Dim isPCP As Boolean = False
                For Each row As DataRow In dt1.Rows
                    If row.Item(0).ToString = "01-Premier Channel Partner" Then
                        sql += " and VIEW_MEMBER in ('All','PCP')"
                        isPCP = True
                        Exit For
                    End If
                Next
                If isPCP = False Then sql += " and VIEW_MEMBER = 'All'"
            Else
                sql += " and VIEW_MEMBER in ('All','Internal')"
            End If
            SqlDataSource1.SelectCommand = sql
        End If
    End Sub

    Protected Sub SqlDataSource2_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim sql As String = "SELECT distinct a.NAME as value FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID where c.EMAIL_ADDR ='" + Session("user_id") + "' and b.TYPE='Interested eNews'"
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sql)
        'Dim arr As New ArrayList
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    arr.Add("N'" + dt.Rows(i).Item(0).ToString + "'")
        'Next
        'sql = "select * from siebel_contact_interestedEnews_lov where 1=1"
        'If arr.Count > 0 Then
        '    sql += " and value not in (" + String.Join(",", arr.ToArray(GetType(String))) + ")"
        'End If
        'dt = dbUtil.dbGetDataTable("RFM", sql)
        'arr.Clear()
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If ContainsChinese(dt.Rows(i).Item(0).ToString()) Then
        '        dt.Rows(i).Delete()
        '    Else
        '        arr.Add("'" + dt.Rows(i).Item(0).ToString + "'")
        '    End If
        'Next
        'If arr.Count > 0 Then
        '    SqlDataSource2.SelectCommand = sql + " and value in (" + String.Join(",", arr.ToArray(GetType(String))) + ")"
        'Else
        '    SqlDataSource2.SelectCommand = sql
        'End If
        Dim sql As String = String.Format("select distinct name from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID in (select row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}')", Session("user_id"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        Dim arr As New ArrayList
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                arr.Add("N'" + dt.Rows(i).Item(0).ToString + "'")
            Next
        End If
        If arr.Count > 0 Then
            sql = "select text,value from SIEBEL_CONTACT_INTERESTED_ENEWS_MODIFIED where value not in (" + String.Join(",", arr.ToArray()) + ")"
        Else
            sql = "select text,value from SIEBEL_CONTACT_INTERESTED_ENEWS_MODIFIED where 1=1"
        End If
        If Not Session("user_id").ToString.Contains("@advantech") Then
            Dim dt1 As DataTable = dbUtil.dbGetDataTable("MY", "select distinct isnull(b.account_status,'') from siebel_contact a left join siebel_account b on a.account_row_id=b.row_id and a.email_address='" + Session("user_id").ToString + "'")
            Dim isPCP As Boolean = False
            For Each row As DataRow In dt1.Rows
                If row.Item(0).ToString = "01-Premier Channel Partner" Then
                    sql += " and VIEW_MEMBER in ('All','PCP')"
                    isPCP = True
                    Exit For
                End If
            Next
            If isPCP = False Then sql += " and VIEW_MEMBER = 'All'"
        Else
            sql += " and VIEW_MEMBER in ('All','Internal')"
        End If
        SqlDataSource2.SelectCommand = sql
    End Sub
</script>



<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table runat="server" id="tblContainer" cellpadding="0" cellspacing="0" width="100%">
        <tr><td style="height:20px"></td></tr>
        <tr>
            <td align="center">
                <table cellpadding="0" cellspacing="0" width="80%">
                    <tr>
                        <td>
                        <asp:Panel runat="server" ID="PanelEmail" Width="50%">
                            <table style="Background-color:#eeeeee" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td align="right"><b>Your Email:&nbsp;</b></td>
                                    <td align="left"><asp:TextBox runat="server" ReadOnly="true" id="txtEmailId" Width="250px"></asp:TextBox></td>
                                </tr>
                            </table>
                        </asp:Panel>
                        </td>    
                    </tr>
                    <tr><td style="height:20px"></td></tr>
                    <tr><td><b>You have subscribed to the following newsletter:</b></td></tr>
                    <tr><td style="color:#000099">(Please uncheck in order to unsubscribe the specified newsletters)</td></tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr><td>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td width="10%"></td>
                                    <td align="left">
                                        <asp:CheckBoxList runat="server" ID="cblSubscribed" DataTextField="text" DataValueField="value" 
                                            RepeatColumns="3" Font-Bold="true" Width="100%" DataSourceID="SqlDataSource1" OnPreRender="cblSubscribed_PreRender" OnLoad="cblSubscribed_Load" />
                                        <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$connectionstrings:MY %>"
                                             SelectCommand="" OnLoad="SqlDataSource1_Load">
                                        </asp:SqlDataSource>
                                    </td>
                                <tr>
                                    <td align="center" colspan="2">
                                        <asp:Label runat="server" ID="lblNonEnews" Text="you have no subscribed newsletters" ForeColor="Red" Font-Bold="true" Visible="false" />
                                    </td>
                                </tr>
                            </table>
                    </td></tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr><td><b>Do you want to subscribe other Advantech's newsletters?</b></td></tr>
                    <tr><td style="color:#000099">(Please select the available newsletter to subscribe)</td></tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr><td><hr /></td></tr>
                    <tr>
                        <td>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td width="10%"></td>
                                    <td align="left">
                                        <asp:Panel Width="100%" runat="server" GroupingText="test" ID="PanelNews">
                                            <asp:CheckBoxList runat="server" ID="cblUnSubscribed" DataTextField="TEXT" DataValueField="VALUE" 
                                                RepeatColumns="3" Font-Bold="true" Width="100%" DataSourceID="SqlDataSource2" OnLoad="cblUnSubscribed_Load" />
                                            <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$connectionStrings:MY %>"
                                                 SelectCommand="" OnLoad="SqlDataSource2_Load">
                                            </asp:SqlDataSource>
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr><td><hr /></td></tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr><td ><asp:Button runat="server" ID="btnSubscribe" Text="Confirm Subscription" OnClick="btnSubscribe_Click" /></td></tr>
                    <tr><td style="height:10px"></td></tr>
                </table>
            </td>
        </tr>
    </table>
    <ajaxToolkit:RoundedCornersExtender runat="server" ID="rndemail"
     TargetControlID="PanelEmail" Corners="All" Radius="4" BorderColor="Gray" Color="#eeeeee"></ajaxToolkit:RoundedCornersExtender>
    <ajaxToolkit:CollapsiblePanelExtender runat="server" ID="clsnews"
     TargetControlID="PanelNews" TextLabelID="Test"></ajaxToolkit:CollapsiblePanelExtender>
</asp:Content>

