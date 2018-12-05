<%@ Page Title="Champion Club - Point Management" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            BindRtAction2()
            If Session("org_id").ToString.StartsWith("CN") Then
                Lithead.Text = "积分记录" : LitTAP.Text = "当前积分"
                'LitFileName.Text = "附件/奖品 名"
                'LitDate.Text = "日期"
                'LitStatus.Text = "状态"
                'LitPoints.Text = "积分"
                'LitCC.Text = "备注/取消"
            End If
        End If
    End Sub
    Dim MyDC As New MyChampionClubDataContext
    Private Sub BindRtAction2()
        gvActionM.DataSource = GetRtAction() : gvActionM.DataBind()
    End Sub
    Function GetRtAction() As DataTable
        Dim MyCR As List(Of ChampionClub_Action) = MyDC.ChampionClub_Actions.Where(Function(P) P.CreateBy = Session("user_id").ToString AndAlso P.Status <> 0).OrderBy(Function(P) P.CreateTime).ToList
        'RtActionM.DataSource = MyCR
        'RtActionM.DataBind()
        Dim MyCR2 As List(Of ChampionClub_Reddem) = MyDC.ChampionClub_Reddems.Where(Function(P) P.CreateBy = Session("user_id").ToString).OrderByDescending(Function(P) P.CreateTime).ToList
        'RtRecord.DataSource = MyCR2
        'RtRecord.DataBind()
        Dim dt As New DataTable
        With dt.Columns
            .Add("ID") : .Add("CreateTime") : .Add("FileID") : .Add("FileName") : .Add("StatusID") : .Add("Status") : .Add("Points") : .Add("Comment") : .Add("Type") : .Add("Revenue") ': .Add("Description")
        End With
        For Each item As ChampionClub_Action In MyCR
            With item
                Dim r As DataRow = dt.NewRow()
                r.Item("ID") = .ID : r.Item("CreateTime") = .CreateTime : r.Item("FileID") = .FileID : r.Item("FileName") = .File_NameX : r.Item("Revenue") = .RevenueAchievement
                r.Item("StatusID") = .Status : r.Item("Status") = .StatusX : r.Item("Points") = .Points : r.Item("Comment") = .MarcomComments : r.Item("Type") = "Action" ': r.Item("Description") = .Description
                dt.Rows.Add(r)
            End With
        Next
        For Each item As ChampionClub_Reddem In MyCR2
            With item
                Dim r As DataRow = dt.NewRow()
                r.Item("ID") = .ReddemID : r.Item("CreateTime") = .CreateTime : r.Item("FileID") = .PrizeID : r.Item("FileName") = .Prize_NameX : r.Item("Revenue") = ""
                r.Item("StatusID") = .Status : r.Item("Status") = .StatusX : r.Item("Points") = -.Prize_PointX : r.Item("Comment") = "" : r.Item("Type") = "Redem"
                dt.Rows.Add(r)
            End With
        Next
        Dim dv As DataView = dt.DefaultView : dv.Sort = "CreateTime"
        Return dv.ToTable()
    End Function

    Protected Sub gvActionM_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim bt As Button = CType(e.Row.FindControl("BTCancel"), Button)
            If Session("org_id").ToString.StartsWith("CN") Then
                bt.Text = "取消"
            End If
            If DataBinder.Eval(e.Row.DataItem, "Type") = "Redem" AndAlso DataBinder.Eval(e.Row.DataItem, "StatusID") = 0 Then
                bt.Visible = True : CType(e.Row.FindControl("LitComment"), Literal).Visible = False
            Else
                If DataBinder.Eval(e.Row.DataItem, "Type") = "Action" Then
                    Dim MyAchievement As List(Of ChampionClub_Action_Achievement) = MyDC.ChampionClub_Action_Achievements.Where(Function(P) P.ACTION_ID = CInt(DataBinder.Eval(e.Row.DataItem, "ID"))).OrderBy(Function(p) p.RULE_ID).ToList
                    Dim Comment As String = "<table>"
                    For Each Achievement As ChampionClub_Action_Achievement In MyAchievement
                        Comment += "<tr><td>Rule " + Achievement.RULE_ID.ToString + " : " + Achievement.ACHIEVEMENT + "K</td><td>&nbsp;Point : " + Achievement.POINT + "</td></tr>"
                    Next
                    CType(e.Row.FindControl("LitComment"), Literal).Text = Comment + "<tr><td colspan='2'>" + CType(e.Row.FindControl("LitComment"), Literal).Text + "</td></tr></table>"
                End If
            End If
        End If
        If Session("org_id").ToString.StartsWith("CN") Then
            If e.Row.RowType = DataControlRowType.Header Then
                e.Row.Cells(2).Text = "附件/奖品 名"
                e.Row.Cells(1).Text = "日期"
                e.Row.Cells(3).Text = "达成的业绩"
                e.Row.Cells(4).Text = "状态"
                e.Row.Cells(5).Text = "积分"
                e.Row.Cells(6).Text = "备注/取消"
            End If
        End If
        
    End Sub

    'Protected Sub RtRecord_ItemDataBound(sender As Object, e As System.Web.UI.WebControls.RepeaterItemEventArgs)
    '    If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
    '        Dim drv As ChampionClub_Reddem = CType(e.Item.DataItem, ChampionClub_Reddem)
    '        Dim bt As Button = CType(e.Item.FindControl("BTCancel"), Button)
    '        If Session("org_id").ToString.StartsWith("CN") Then
    '            bt.Text="取消"
    '        End If
    '        If drv.Status = 0 Then
    '            bt.Visible = True
    '        End If
    '    End If
    'End Sub

    Protected Sub BTCancel_Click(sender As Object, e As System.EventArgs)
        Dim bt As Button = CType(sender, Button)
        'Dim _RepeaterItem As RepeaterItem = CType(bt.NamingContainer, RepeaterItem)
        'Dim drv As ChampionClub_Reddem = CType(_RepeaterItem.DataItem, ChampionClub_Reddem)
        'Response.Write(drv.ReddemID)
        Dim ReddemID As String = bt.CommandArgument
        Dim Reddem As ChampionClub_Reddem = MyDC.ChampionClub_Reddems.Where(Function(P) P.ReddemID = ReddemID).FirstOrDefault
        If Reddem IsNot Nothing Then
            Reddem.Status = -1
            Reddem.UpdateBy = Session("USER_ID").ToString
            Reddem.UpdateTime = Now
        End If
        MyDC.SubmitChanges()
        BindRtAction2()
    End Sub

    Protected Sub gvActionM_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvActionM.PageIndex = e.NewPageIndex : gvActionM.DataSource = SortDataTable(GetRtAction(), True) : gvActionM.DataBind()
    End Sub
    
    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function
    
    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property
    
    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function
    
    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        tbody tr.odd0 td
        {
            border-top: #ccc 1px solid;
            text-align: center;
            background: #fff;
            color: #333;
            height: 25px;
            border-right: #ccc 1px solid;
        }
        tbody tr.odd1 td
        {
            text-align: center;
            background: #ebebeb;
            color: #333;
            height: 25px;
            border-top: #ccc 1px solid;
            border-right: #ccc 1px solid;
        }
    </style>
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <div class="cpclub-content-main">
            <div class="main-intro" style="margin-top: 0px">
                <div class="intro-heading">
                    <asp:Literal ID="Lithead" runat="server">Point Managemant</asp:Literal>
                    </div>
                <!-- end .main-intro -->
            </div>
            <div class="main-content">
                <div class="content-heading" style="margin-top: 10px"><asp:Literal ID="LitTAP" runat="server" Text="Total Available Points"/>
                    :<span style="text-decoration: underline; color: #FF0000">
                        <%=MyChampionClubUtil.GetAvailablePoint(Session("user_id")) %></span></div>
                <div id="Opp_table">
                    <asp:GridView runat="server" ID="gvActionM" Width="100%" AutoGenerateColumns="false" AllowPaging="true" PageSize="20"
                        RowStyle-HorizontalAlign="Center" RowStyle-Height="30" OnRowDataBound="gvActionM_RowDataBound" OnPageIndexChanging="gvActionM_PageIndexChanging">
                        <Columns>
                            <asp:TemplateField HeaderText="#" ItemStyle-Width="5%">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Date" ItemStyle-Width="15%">
                                <ItemTemplate>
                                    <asp:Literal runat="server" ID="litDate" Text='<%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:HyperLinkField HeaderText="File/Prize Name" DataNavigateUrlFormatString="Files.aspx?id={0}" DataNavigateUrlFields="FileID" DataTextField="FileName" Target="_blank" ItemStyle-Width="20%" Visible="false" />
                            <asp:BoundField HeaderText="Revenue Achievement" DataField="Revenue" ItemStyle-Width="15%" />
                           <%-- <asp:BoundField HeaderText="Achievement Description" DataField="Description" ItemStyle-Width="25%" />--%>
                            <asp:BoundField HeaderText="Status" DataField="Status" ItemStyle-Width="20%" HtmlEncode="false" />
                            <asp:BoundField HeaderText="Points" DataField="Points" ItemStyle-Width="15%" />
                            <asp:TemplateField HeaderText="Content/Cancel" ItemStyle-Width="30%">
                                <ItemTemplate>
                                        <asp:Literal runat="server" ID="LitComment" Text='<%#Eval("Comment") %>' />
                                        <asp:Button ID="BTCancel" runat="server" Visible="false" Text="Cancel" CssClass="btcss"
                                            CommandArgument='<%# Eval("ID")%>' OnClick="BTCancel_Click" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <%--<br /><br />
                    <table width="100%" id="myallTable">
                        <thead>
                            <tr>
                                <th width="5%" scope="col">
                                    #
                                </th>
                                <th width="15%" scope="col">
                                    <asp:Literal ID="LitDate" runat="server" Text="Date"/>
                                </th>
                                <th width="15%" scope="col">
                                    <asp:Literal ID="LitFileName" runat="server" Text="File/Prize Name"/>
                                </th>
                                <th width="20%" scope="col">
                                    <asp:Literal ID="LitStatus" runat="server" Text="Status"/>
                                </th>
                                <th width="20%" scope="col">
                                    <asp:Literal ID="LitPoints" runat="server" Text="Points"/>
                                </th>
                                <th width="20%" scope="col">
                                    <asp:Literal ID="LitCC" runat="server" Text="Content/Cancel"/>
                                </th>
                                <th class="hide">
                                    seqno
                                </th>
                            </tr>
                        </thead>
                        <tbody id="myTable1">
                            <asp:Repeater ID="RtActionM" runat="server">
                                <ItemTemplate>
                                    <tr class="odd<%# (Container.ItemIndex) mod 2 %>">
                                        <td>
                                            <%# (Container.ItemIndex + 1)%>
                                        </td>
                                        <td>
                                            <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                        </td>
                                        <td>
                                            <a href="Files.aspx?id=<%# Eval("FileID")%>">
                                                <%# Eval("File_NameX")%></a>
                                        </td>
                                        <td>
                                            <%# Eval("StatusX")%>
                                        </td>
                                        <td>
                                            <%# Eval("Points")%>
                                        </td>
                                        <td>
                                            <%# Eval("MarcomComments")%>
                                        </td>
                                        <td class="hide">
                                            <%# CDate(Eval("CreateTime")).ToString("yyyyMMddmmss")%>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>--%>
                </div>
                <%--            <div class="intro-heading" style="margin-top:10px;">
                    Redemption Record</div>--%>
                <%--<div id="Opp_table2" class="hide">
                    <table width="100%">
                        <thead>
                            <tr>
                                <th width="5%" scope="col">
                                    #
                                </th>
                                <th width="15%" scope="col">
                                    Date
                                </th>
                                <th width="40%" scope="col">
                                    Prize Name
                                </th>
                                <th width="20%" scope="col">
                                    Status
                                </th>
                                <th width="20%" scope="col">
                                    Points
                                </th>
                                <th width="20%" scope="col">
                                    Content
                                </th>
                                <th class="hide">
                                    seqno
                                </th>
                            </tr>
                        </thead>
                        <tbody id="myTable2">
                            <asp:Repeater ID="RtRecord" runat="server" OnItemDataBound="RtRecord_ItemDataBound">
                                <ItemTemplate>
                                    <tr class="odd<%# (Container.ItemIndex) mod 2 %>">
                                        <td>
                                            <%# (Container.ItemIndex + 1)%>
                                        </td>
                                        <td>
                                            <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                        </td>
                                        <td>
                                            <%# Eval("Prize_NameX")%>
                                        </td>
                                        <td>
                                            <%# Eval("StatusX")%>
                                        </td>
                                        <td>
                                            -
                                            <%# Eval("Prize_PointX")%>
                                        </td>
                                        <td>
                                            <asp:Button ID="BTCancel" runat="server" Visible="false" Text="Cancel" CssClass="btcss"
                                                CommandArgument='<%# Eval("ReddemID")%>' OnClick="BTCancel_Click" />
                                        </td>
                                        <td class="hide">
                                            <%# CDate(Eval("CreateTime")).ToString("yyyyMMddmmss")%>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>--%>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <script src="js/jquery-latest.js" type="text/javascript"></script>
    <script src="js/jquery.tablesorter.min.js" type="text/javascript"></script>
    <script>
//        $(document).ready(function () {
//            var VAL = document.getElementById("myTable2");
//            $("#myTable1").append(VAL.innerHTML);
//            $("#myallTable").tablesorter({
//                sortList: [[6, 0], [6, 0]]
//            });
//        }
//);
    </script>
</asp:Content>
