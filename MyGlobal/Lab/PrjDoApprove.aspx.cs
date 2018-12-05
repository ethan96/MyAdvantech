using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_PrjDoApprove : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!string.IsNullOrEmpty(Request["UID"]) && !string.IsNullOrEmpty(Request["Status"]))
            {
                //ICC check input parameter
                string UID = Request["UID"];
                int status = 0;
                int.TryParse(Request["Status"], out status);

                //ICC Status 1 means approve. Status 2 means reject. Others are wrong status.
                if (!(status == 1 || status == 2) == true)
                {
                    lbContent.Text = "Wrong status code.";
                    return;
                }

                //ICC check master data exist
                InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter ma = new InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter();
                var master = ma.GetDataByRowID(UID);
                if (master == null || master.Rows.Count == 0)
                {
                    lbContent.Text = "No master data from project ID.";
                    return;
                }

                string primarySales = string.Empty;
                //ICC check primary sales exist
                object obj = dbUtil.dbExecuteScalar("MyLocal", string.Format("SELECT TOP 1 PRIMARY_SALES_EMAIL FROM MY_PRJ_REG_PRIMARY_SALES_EMAIL WHERE PRJ_ROW_ID = '{0}' ", UID));
                if (obj == null || string.IsNullOrEmpty(obj.ToString()))
                {
                    lbContent.Text = "No primary sales data.";
                    return;
                }
                primarySales = obj.ToString();

                //ICC check audit data exist
                InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter aa = new InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter();
                var audit = aa.GetByPRJ_ROW_ID(UID);
                if (audit == null || audit.Rows.Count == 0)
                {
                    lbContent.Text = "No approved data.";
                    return;
                }

                var auditRow = audit[0];
                if (auditRow.STATUS != 0) //ICC Only status = 0 means ready to be approved or rejected
                {
                    lbContent.Text = "This project is not ready to be approved or rejected.";
                    return;
                }

                InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter pa = new InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter();
                var product = pa.GetDataByPRJ_ROW_ID(UID);

                try
                {
                    if (status == 1)
                    {
                        aa.UpdateForSales(status, primarySales, DateTime.Now, "Approved by email link", UID);
                        InterConPrjRegUtil.Sendmail(UID, "Sales Approved project registration", status, "", product);
                        InterConPrjRegUtil.update_Siebel(UID, "25% Proposing/Quoting", InterConPrjRegUtil.GetTotalAmountByID(UID), "");
                        lbContent.Text = string.Format("This project - [{0}] is approved.", master[0].PRJ_NAME);
                    }
                    else if (status == 2)
                    {
                        aa.UpdateReject(status, primarySales, DateTime.Now, "Rejected by email link", UID);
                        InterConPrjRegUtil.Sendmail(UID, "Sales Rejected project registration", status, "", product);
                        InterConPrjRegUtil.update_Siebel(UID, "Rejected by Sales", InterConPrjRegUtil.GetTotalAmountByID(UID), "");
                        lbContent.Text = string.Format("This project - [{0}] is rejected.", master[0].PRJ_NAME);
                    }
                }
                catch (Exception ex)
                {
                    lbContent.Text = "Error! Message: " + ex.ToString();
                }
            }
            else
                lbContent.Text = "No data!";

            hlPrj.NavigateUrl = Util.GetRuntimeSiteUrl() + "/My/InterCon/PrjList.aspx";
        }
    }
}