<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Import Namespace="Quartz" %>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //if (System.Web.HttpContext.Current.User == null || !System.Web.HttpContext.Current.User.Identity.IsAuthenticated)
            //    Response.Redirect(Request.ApplicationPath);

            //bool b = MailUtil.IsInRole("MyAdvantech");
            //if (!b && !MailUtil.IsInRole("ChannelManagement.ACL"))
            //    Response.Redirect(Request.ApplicationPath);
            
            //if (b == true)
            //    pJob.Visible = true;
            
            //rpPrjOpty.DataSource = dbUtil.dbGetDataTable("MyLocal", " select distinct ma.ROW_ID,ma.PRJ_NAME,ma.CREATED_BY, ma.CP_COMPANY_ID,se.PRIMARY_SALES_EMAIL ,ma.CREATED_DATE " +
            //           " from MY_PRJ_REG_MASTER ma left join MY_PRJ_REG_AUDIT au on ma.ROW_ID = au.PRJ_ROW_ID inner join MY_PRJ_REG_PRIMARY_SALES_EMAIL se " +
            //           " on ma.ROW_ID= se.PRJ_ROW_ID where au.STATUS is null order by ma.CREATED_DATE desc ");
            //rpPrjOpty.DataBind();
        }
    }

    protected void rpPrjOpty_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "ReCreateOpty" && e.CommandArgument != null)
        {
            string rid = e.CommandArgument.ToString();
            string emial = dbUtil.dbExecuteScalar("MyLocal", String.Format(" select top 1 ISNULL(PRIMARY_SALES_EMAIL,'') from MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}' ", rid)).ToString();
            string result = InterConPrjRegUtil.Prj2Siebel(rid, emial);

            if (!string.IsNullOrEmpty(result))
            {
                InterConPrjRegUtil.CreateStatus(rid);
                InterConPrjRegUtil.Sendmail(rid);
                Util.AjaxJSAlertRedirect(this.up1, "Success", Request.RawUrl);
            }
            else
                Util.AjaxJSAlertRedirect(this.up1, "Failed", Request.RawUrl);
        }
    }

    protected void btnStart_Click(object sender, EventArgs e)
    {
        //ScheduledJob myJob = new ScheduledJob();
        try
        {
            //myJob.StopRecreateOptyJob();
            //myJob.StartRecreateOptyJob();
            StopCheckRegisterJob();
            StartCheckRegisterJob();
            lbMsg.Text = "OK";
        }
        catch (Exception ex)
        {
            lbMsg.Text = ex.ToString();
        }
    }

    protected void btnStop_Click(object sender, EventArgs e)
    {
        //ScheduledJob myJob = new ScheduledJob();

        try
        {
            StopCheckRegisterJob();
            //myJob.StopRecreateOptyJob();
            lbMsg.Text = "OK";
        }
        catch (Exception ex)
        {
            lbMsg.Text = ex.ToString();
        }
    }

    public void StartCheckRegisterJob()
    {
        Quartz.Impl.StdSchedulerFactory scheduleFactory = new Quartz.Impl.StdSchedulerFactory();
        var schedular = scheduleFactory.GetScheduler();
        IJobDetail registerjob = JobBuilder.Create<CheckNewRegisterEveryHour>().WithIdentity("CheckNewRegisterEveryHourJob").Build();
        ITrigger registertrigger = TriggerBuilder.Create().WithCronSchedule("0 0/10 * 1/1 * ? *").WithIdentity("CheckNewRegisterEveryHourJobTrigger").Build();
        schedular.ScheduleJob(registerjob, registertrigger);
        schedular.Start();
    }

    public void StopCheckRegisterJob()
    {
        var scheduleFactory = new Quartz.Impl.StdSchedulerFactory().GetScheduler();
        scheduleFactory.UnscheduleJob(new TriggerKey("CheckNewRegisterEveryHourJob"));
        scheduleFactory.DeleteJob(new JobKey("CheckNewRegisterEveryHourJobTrigger"));
    }

    public class CheckNewRegisterEveryHour : Quartz.IJob
    {
        public void Execute(Quartz.IJobExecutionContext context)
        {
            try
            {
                DataTable dt = dbUtil.dbGetDataTable("MY", "select distinct a.EMAIL from CurationPool.dbo.CURATION_ACTIVITY_IMPORTED_LOG a where a.ACTIVITY_TYPE like '%Registration%' and a.SOURCE_TYPE in ('eStore','Corporate_Website') and a.TIMESTAMP between DATEADD(hour,-1,getdate()) and GETDATE() ");
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        object obj = dbUtil.dbExecuteScalar("MYLOCAL", string.Format(" select count(*) from RewardRecord where UserID = '{0}'  and RewardID=0 and ActivityID=0 and TransactionType=0 ", dr[0].ToString()));
                        int count = 0;
                        if (obj != null && int.TryParse(obj.ToString(), out count) == true)
                        {
                            if (count == 0)
                            {
                                decimal point = DateTime.Compare(DateTime.Now, new DateTime(2016, 11, 30)) < 0 ? 4 : 2;
                                StringBuilder sb = new StringBuilder();
                                sb.Append(" insert into RewardRecord (StoreID,UserID,RewardID,ActivityID,TransactionType,RecordType,OrderNo,Qty,Point,TotalPoint,CreatedBy,CreatedDate,SendMailStatus_Internal,SendMailStatus_Corporate,SendMailStatus_Sales) values ");
                                sb.AppendFormat(" ('ATW', '{0}', 0, 0, 0, 1, '', 1, {1}, {1}, 'NewRegister', GETDATE(), 1, 1, 1);", dr[0].ToString(), point);
                                dbUtil.dbExecuteNoQuery("MYLOCAL", sb.ToString());
                            }
                            
                        }
                        
                    }
                }
            }
            catch
            {

            }
        }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:UpdatePanel ID="up1" runat="server">
        <ContentTemplate>
            <asp:Repeater runat="server" ID="rpPrjOpty" OnItemCommand="rpPrjOpty_ItemCommand">
                <HeaderTemplate>
                    <table width="100%">
                        <thead>
                            <tr>
                                <th>Project Name</th>
                                <th>Registered By</th>
                                <th>ERP ID</th>
                                <th>Primary sales email</th>
                                <th>Create date</th>
                                <th>Re create</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr style="text-align:center">
                        <td><%# Eval("PRJ_NAME") %></td>
                        <td><%# Eval("CREATED_BY") %></td>
                        <td><%# Eval("CP_COMPANY_ID") %></td>
                        <td><%# Eval("PRIMARY_SALES_EMAIL") %></td>
                        <td><%# Eval("CREATED_DATE") %></td>
                        <td>
                            <asp:LinkButton ID="lb_ReCreateOpty" runat="server" CommandName="ReCreateOpty" CommandArgument='<%#Eval("ROW_ID") %>' Text="Re-create"></asp:LinkButton></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
            </table>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pJob" runat="server" Visible="true">
                <asp:Button ID="btnStart" runat="server" Text="Start Job" OnClick="btnStart_Click" />&nbsp;
                <asp:Button ID="btnStop" runat="server" Text="Stop Job" OnClick="btnStop_Click" /><br />
                <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato"></asp:Label>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

