<%@ Control Language="VB" ClassName="OptyUpdDraft" %>

<script runat="server">
    Public Property OptyRowId() As String
        Get
            Return ViewState("OPTYRID")
        End Get
        Set(ByVal value As String)
            ViewState("OPTYRID") = value
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" SELECT top 1 a.PROJECT_NAME, a.DESCRIPTION, a.STATUS, ")
                .AppendFormat(" a.PROBABILITY, cast(a.REVENUE as numeric(18,0)) as REVENUE, a.CURRENCY, dbo.DateOnly(a.CLOSE_DATE) as CLOSE_DATE, " + _
                              " dbo.DateOnly(a.CREATE_DATE) as CREATE_DATE, a.CREATE_BY, a.LAST_UPD_BY, " + _
                              " dbo.DateOnly(a.LAST_UPD_DATE) as LAST_UPD_DATE ")
                .AppendFormat(" FROM CP_FEEDBACK_LEADS a ")
                .AppendFormat(" where a.ROW_ID='{0}' and approval_status='UPDATING' ", ViewState("OPTYRID"))
            End With
            
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            If dt.Rows.Count = 1 Then
                With dt.Rows(0)
                    txtPrjName.Text = .Item("PROJECT_NAME")
                    txtDesc.Text = .Item("DESCRIPTION")
                    dlPrjStatus.SelectedValue = .Item("STATUS")
                    txtRev.Text = .Item("REVENUE")
                    txtPrjCloseDate.Text = CDate(.Item("CLOSE_DATE")).ToString("yyyy/MM/dd")
                    tdReqBy.InnerText = .Item("CREATE_BY")
                    dlProb.SelectedValue = .Item("PROBABILITY")
                End With
                tb1.Visible = True
            End If
        End Set
    End Property
    
    Public Event OptyUpdatedEvent()
    
    Protected Sub btnADD_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        tdMsg.InnerText = ""
        If Double.TryParse(txtRev.Text, 0) = False OrElse Date.TryParse(txtPrjCloseDate.Text, Now) = False Then
            tdMsg.InnerText = "Amount or Close Date format incorrect" : Exit Sub
        End If
        
        Dim ws As New aeu_eai2000.Siebel_WS
        ws.UseDefaultCredentials = True
        Dim b As Boolean = ws.UpdateOpportunityStatusAmtCloseDateProb( _
        ViewState("OPTYRID"), dlPrjStatus.SelectedItem.Text, txtDesc.Text, txtRev.Text, CDate(txtPrjCloseDate.Text), dlProb.SelectedValue)
        If b Then
            dbUtil.dbExecuteNoQuery("MY", String.Format("update CP_FEEDBACK_LEADS set approval_status='UPDATED', last_upd_by='{1}' where row_id='{0}'", ViewState("OPTYRID"), Session("user_id")))
            tb1.Visible = False
            Util.JSAlert(Me.Page, "Opportunity updated")
            RaiseEvent OptyUpdatedEvent()
        Else
            tdMsg.InnerText = "Update Opportunity to Siebel failed, please contact AEU IT"
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Session("user_id") Like "*@*advantech*.*" Then
            btnADD.Enabled = False : btnDel.Enabled = False
        End If
    End Sub

    Protected Sub btnDel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        dbUtil.dbExecuteNoQuery("MY", String.Format("update CP_FEEDBACK_LEADS set approval_status='REJECTED', last_upd_by='{1}' where row_id='{0}'", ViewState("OPTYRID"), Session("user_id")))
        RaiseEvent OptyUpdatedEvent()
    End Sub
</script>
<table width="100%" runat="server" id="tb1" visible="false">
    <tr>
        <th align="left">Requested by</th><td colspan="3" runat="server" id="tdReqBy"></td>
    </tr>
    <tr>
        <th align="left" style="width:170px">Project Name</th>
        <td colspan="3">
            <asp:TextBox runat="server" ID="txtPrjName" Width="250px" />
        </td>
    </tr>
    <tr>
        <th align="left" style="width:170px">Description</th>
        <td colspan="3">
            <asp:TextBox runat="server" ID="txtDesc" Width="300px" TextMode="MultiLine" Rows="4" />
        </td>
    </tr>
    <tr>
        <th align="left" style="width:170px">Status</th>
        <td>
            <asp:DropDownList runat="server" ID="dlPrjStatus" Width="200px">
                <asp:ListItem Text="Accepted" Value="Accepted" />
                <asp:ListItem Text="Lost" Value="Lost" />
                <asp:ListItem Text="Pending" Value="Pending" />
                <asp:ListItem Text="Rejected" Value="Rejected" />
                <asp:ListItem Text="Won" Value="Won" />
            </asp:DropDownList>
        </td>
        <th align="left" style="width:170px">Probability</th>
        <td>
            <asp:DropDownList runat="server" ID="dlProb" Width="200px">
                <asp:ListItem Value="0" Text="0" />
                <asp:ListItem Value="25" Text="25" />
                <asp:ListItem Value="50" Text="50" />
                <asp:ListItem Value="75" Text="75" />
                <asp:ListItem Value="100" Text="100" />
            </asp:DropDownList>
        </td>
    </tr>
    <tr>
        <th align="left" style="width:170px">Amount</th>
        <td>
            <asp:TextBox runat="server" ID="txtRev" Width="70px"  Text="0"/>
        </td>
        <th align="left" style="width:170px">Close Date</th>
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalPrjCloseDateExt" TargetControlID="txtPrjCloseDate" Format="yyyy/MM/dd" />
            <asp:TextBox runat="server" ID="txtPrjCloseDate" Width="80px" />
        </td>
    </tr>
    <tr>
        <td colspan="3">
            <asp:Button runat="server" ID="btnADD" Text="Approve" OnClick="btnADD_Click" />&nbsp;
            <asp:Button runat="server" ID="btnDel" Text="Reject" OnClick="btnDel_Click" />
        </td>
        <th align="left" runat="server" id="tdMsg" style="color:Tomato"/>
    </tr>
</table>