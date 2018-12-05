using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_ScheduleJob : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!MailUtil.IsInRole("MyAdvantech"))
        { 
            Response.Redirect("~/home_ez.aspx");
        }
    }

    protected void ButtonStartBB_Click(object sender, EventArgs e)
    {
        ScheduledJob myJob = new ScheduledJob();

        try
        {
            myJob.StopBBCacheJob();
            myJob.StartBBCacheJob();
            Msg.Text = "Starting BB Job Success";
        }
        catch (Exception ex)
        {
            Msg.Text = ex.ToString();
        }
    }
    protected void ButtonStopBB_Click(object sender, EventArgs e)
    {
        ScheduledJob myJob = new ScheduledJob();

        try
        {
            myJob.StopBBCacheJob();
            Msg.Text = "Stop BB Job Success";
        }
        catch (Exception ex)
        {
            Msg.Text = ex.ToString();
        }
    }
    protected void ButtonClearBB_Click(object sender, EventArgs e)
    {
        System.Web.HttpRuntime.Cache.Remove("BBDT");
        System.Web.HttpRuntime.Cache.Remove("BBTDT");
    }

    protected void ButtonStartCP_Click(object sender, EventArgs e)
    {
        ScheduledJob myJob = new ScheduledJob();

        try
        {
            myJob.StopCheckPointJob();
            myJob.StartCheckPointJob();
            Msg.Text = "Starting CP Job Success";
        }
        catch (Exception ex)
        {
            Msg.Text = ex.ToString();
        }
    }

    protected void ButtonStopCP_Click(object sender, EventArgs e)
    {
        ScheduledJob myJob = new ScheduledJob();

        try
        {
            myJob.StopCheckPointJob();
            Msg.Text = "Stop CP Job Success";
        }
        catch (Exception ex)
        {
            Msg.Text = ex.ToString();
        }
    }
}