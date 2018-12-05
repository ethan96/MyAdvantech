<%@ Page Title="Champion Club - Reports Upload" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Function upload() As System.IO.Stream
        If FileUpload1.HasFile AndAlso Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            'Me.FileUpload1.SaveAs(fileName)
            Return MSM
        End If
        Return Nothing
    End Function
    Dim Othercss As String = "hide"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            'Dim MyProfile As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = User.Identity.Name).FirstOrDefault()
            'If MyProfile Is Nothing Then BTtj.Enabled = False
            
            'JJ 2014/6/17：新管控權限，必須有申請過且Marcom有加入當年度參加的人才能送出Points
            If Not Util.IsAdminUser() Then BTtj.Enabled = False
           
            BindRtAction()
            If Session("org_id").ToString.StartsWith("CN") Then
                'LitSubDesc.Text = "请将您欲上传的资料统合成一个ppt, pdf, rar, 或 zip档后再上传"
                LitSF.Text = "上传Excel文件"
                LitRev.Text = "达成的业绩"
                LitReportDesc.Text = "包含的研华产品"
                Lithead.Text = "提交积分申请"
                BTtj.Text = "提交"
                LitDate.Text = "日期"
                LitSize.Text = "附件大小"
                LitFileName.Text = "文件名"
                LitRevAchi.Text = LitRev.Text
                LitDescription.Text = LitReportDesc.Text
                LitAction.Text = "操作"
                Litsm.Text = "Ex: TPC-1780H"
                Litzp.Visible= False 
                TRupload.Visible = True
                TRtemplate.Visible = True
               
            End If
        End If
        If Session("org_id").ToString.StartsWith("CN") Then
             Othercss = ""
        End If
    End Sub
    Dim MyDC As New MyChampionClubDataContext
    Protected Sub BTtj_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim userid As String = Session("user_id").ToString.Trim
        Dim MyFile As New ChampionClub_File
        Dim filestream As System.IO.Stream = upload()
        If Not IsNothing(filestream) Then
            Dim fileData(filestream.Length) As Byte
            filestream.Read(fileData, 0, filestream.Length)
            
          
            With MyFile
                .File_Name = FileUpload1.FileName
                .FileBits = fileData
                .File_Ext = FileUpload1.FileName.Substring(FileUpload1.FileName.LastIndexOf(".") + 1, FileUpload1.FileName.Length - FileUpload1.FileName.LastIndexOf(".") - 1)
                .File_Size = fileData.Length
                .File_CreateBy = userid
                .File_CreateTime = Now
            End With
            
            'Else
            '    Util.JSAlert(Me.Page, " Please select a file")
        End If
       
        Dim MyActive As New ChampionClub_Action
        MyActive.Description = TBdesc.Text.Replace("'", "''")
        MyActive.RevenueAchievement = TBRevenue.Text.Replace("'", "''")
        MyActive.Points = 0
        MyActive.Status = 0
        MyActive.CreateBy = userid
        MyActive.CreateTime = Now
        MyDC.ChampionClub_Files.InsertOnSubmit(MyFile)
        MyDC.SubmitChanges()
        MyActive.FileID = MyFile.FileID
        MyDC.ChampionClub_Actions.InsertOnSubmit(MyActive)
        MyDC.SubmitChanges()
        MyChampionClubUtil.SendEmail(Session("user_id").ToString, 2, MyActive.ID, "")
        BindRtAction()
        If Session("org_id").ToString.StartsWith("CN") Then
            Util.JSAlert(Me.Page, " 申请提交成功. ")
        Else
            Util.JSAlert(Me.Page, " Succeed. ")
        End If
    End Sub
    Protected Sub BTan_Click(sender As Object, e As System.EventArgs)
        Dim BT As Button = CType(sender, Button)
        Dim ID As String = BT.CommandArgument
        Dim CRE As ChampionClub_Action = MyDC.ChampionClub_Actions.Where(Function(P) P.ID = ID).FirstOrDefault
        If CRE IsNot Nothing Then
            MyDC.ChampionClub_Actions.DeleteOnSubmit(CRE)
            MyDC.SubmitChanges()
        End If
        ' CampaignUtil.SendEmailV2(lab_requestno.Text.Trim, 0, AN.Text)
        BindRtAction()
    End Sub
    Private Sub BindRtAction()
        Dim MyCR As List(Of ChampionClub_Action) = MyDC.ChampionClub_Actions.Where(Function(P) P.CreateBy = Session("user_id").ToString AndAlso P.Status = 0).OrderBy(Function(P) P.CreateTime).ToList
        RtAction.DataSource = MyCR
        RtAction.DataBind()
    End Sub
    Private Sub BindRtAction2()
        Dim MyCR As List(Of ChampionClub_Action) = MyDC.ChampionClub_Actions.Where(Function(P) P.CreateBy = Session("user_id").ToString AndAlso P.Status <> 0).OrderBy(Function(P) P.CreateTime).ToList
        RtActionM.DataSource = MyCR
        RtActionM.DataBind()
    End Sub

    Protected Sub RtAction_ItemDataBound(sender As Object, e As System.Web.UI.WebControls.RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            If Session("org_id").ToString.StartsWith("CN") Then
                Dim Buttondel As Button = CType(e.Item.FindControl("BTan"), Button)
                Buttondel.Text = "删除"
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
<style type="text/css">
tbody tr.odd0 td{
	border-top:#ccc 1px solid;
    text-align: center;
	background: #fff;
	color: #333;
	height:25px;
	border-right:#ccc 1px solid;
}
tbody tr.odd1 td{
    text-align: center;
	background: #ebebeb;
	color: #333;
	height:25px;
	border-top:#ccc 1px solid;
	border-right:#ccc 1px solid;
}</style>
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <div class="cpclub-content-main">
            <div class="main-intro">
                <div class="intro-heading">
                    <asp:Literal ID="Lithead" runat="server" Text="Points Request"/>
                    </div>
                <!-- end .main-intro -->
            </div>
            <div class="main-content">
                <table>
           <%--         <tr><th colspan="3" align="left"><asp:Literal runat="server" ID="LitSubDesc" Text="Please combine all sources/papers into one ppt, pdf, rar, or zip file when you submit." Visible="false" /></th></tr>
                    <tr><td colspan="3" height="10"></td></tr>
                    <tr><td colspan="3" height="5"></td></tr>--%>
                    <tr>
                        <td align="left"><asp:Literal runat="server" ID="LitRev" Text="Revenue Achievement:" /></td>
                        <td align="left">
                            <asp:TextBox runat="server" ID="TBRevenue" Width="100" />&nbsp;&nbsp;<font color="gray">(Ex: 150K)</font>
                        </td>
                    </tr>
              
                    <tr style="padding-top:8px;">
                        <td align="left"><asp:Literal runat="server" ID="LitReportDesc" Text="Achievement Description:" /></td>
                        <td align="left" valign="top">
                            <asp:TextBox ID="TBdesc" runat="server" TextMode="MultiLine" Width="350" Height="80"></asp:TextBox><font color="gray">(
                                <asp:Literal ID="Litsm" runat="server">Ex: achieve 50K in rule#3</asp:Literal>
                            )</font>
                        </td>
                    </tr>
                     <tr id="TRupload" runat="server" visible="false" style="padding-top:8px;">
                        <td align="left"><asp:Literal runat="server" ID="LitSF" Text="Select a file:"  /></td>
                        <td align="left">
                            <asp:FileUpload ID="FileUpload1" runat="server"  /><br /><font color="gray">
                           <asp:Literal ID="Litzp" runat="server"> 请将您欲上传的资料统合成一个ppt, pdf, rar, 或 zip档后再上传</asp:Literal>
                            
                            </font>
                        </td>
                    </tr>
                  <tr id="TRtemplate" runat="server" visible="false"><td></td>
                        <td align="left" style="padding-top:8px;">
                           <table>
                           <tr>
                           <td>Excel模板: </td>
                           <td>
                             <a href="Txt/提交积分申请-for业绩达成.xlsx">【业绩达成.xlsx】 </a> </td>
                           <td>
                               <a href="Txt/提交积分申请-for特殊产品.xlsx">【特殊产品.xlsx】 </a></td>
                           <td>
                              <a href="Txt/提交积分申请-for大案达成.xlsx">【大案达成.xlsx】 </a>  </td>
                           </tr>
                           </table>
                        </td>
                    </tr>
                    <tr><td></td>
                        <td align="left" style="padding-top:8px;">
                            <asp:Button ID="BTtj" runat="server" Text="Submit" OnClick="BTtj_Click" Width="100" Height="30" />
                        </td>
                    </tr>
                </table>
               
                <div id="Opp_table">
                    <table width="100%">
                        <thead>
                            <tr>
                                <th width="15" scope="col">
                                    #
                                </th>
                                <th width="75" scope="col">
                                    <asp:Literal ID="LitDate" runat="server" Text="Date"/>
                                </th>
                                <th  scope="col" class="<%=Othercss%>">
                                    <asp:Literal ID="LitFileName" runat="server" Text="File Name"/>
                                </th>
                                <th  scope="col" class="<%=Othercss%>">
                                     <asp:Literal ID="LitSize" runat="server" Text="Size"/>
                                </th> 
                                <th scope="col">
                                    <asp:Literal ID="LitRevAchi" runat="server" Text="Revenue Achivement"/>
                                </th>
                                 <th  scope="col">
                                    <asp:Literal ID="LitDescription" runat="server" Text="Description"/>
                                </th>
                               
                                <th  scope="col">
                                    <asp:Literal ID="LitAction" runat="server" Text="Action"/>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                              <asp:Repeater ID="RtAction" runat="server" OnItemDataBound="RtAction_ItemDataBound">
                <ItemTemplate>
                            <tr  class="odd<%# (Container.ItemIndex) mod 2 %>">
                                <td>
                                   <%# (Container.ItemIndex + 1)%>
                                </td>
                                <td>
                                     <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                </td>
                                <td class="<%=Othercss%>">
                                 <a href="Files.aspx?id=<%# Eval("FileID")%>"><%# Eval("File_NameX")%></a>      
                                </td>
                                <td class="<%=Othercss%>">
                                   <%# Eval("File_SizeX")%>
                                </td>
                                 <td>
                                    <%# Eval("RevenueAchievement")%>
                                </td>
                                  <td>
                                   <%# Eval("Description")%>
                                </td>
                                <td >
                          
                                      <asp:Button ID="BTan" runat="server" Text="Delete" OnClick="BTan_Click" CommandArgument='<%# Eval("ID")%>' />
                                </td>
                            </tr>
               </ItemTemplate>
            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="main-intro" style="margin-top: 30px; display:none;">
                <div class="intro-heading">
                    Point Managemant</div>
                <!-- end .main-intro -->
            </div>
            <div class="main-content"  style="display:none;">
                <div class="content-heading">
                    Total Available Points:<span style="text-decoration: underline; color: #FF0000"> <%=MyChampionClubUtil.GetAvailablePoint(Session("user_id")) %></span></div>
                <div id="Opp_table">
                    <table width="100%">
                        <thead>
                            <tr>
                                <th width="5%" scope="col">
                                    #
                                </th>
                                <th width="15%" scope="col">
                                    Date
                                </th>
                                <th width="15%" scope="col">
                                    File Name
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
                           
                            </tr>
                        </thead>
                        <tbody>
                          <asp:Repeater ID="RtActionM" runat="server">
                <ItemTemplate>
                            <tr  class="odd<%# (Container.ItemIndex) mod 2 %>">
                                <td>
                                    <%# (Container.ItemIndex + 1)%>
                                </td>
                                <td>
                                     <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                </td>
                                <td>
                               <a href="Files.aspx?id=<%# Eval("FileID")%>"><%# Eval("File_NameX")%></a>      
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
                            </tr>
                  
                            </ItemTemplate>
            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
