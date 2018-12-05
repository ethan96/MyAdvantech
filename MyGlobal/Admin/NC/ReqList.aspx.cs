using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_NC_ReqList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack) {
            var MyRole = NewSAPAccountUtil.getCurrentUserRole();

            var sqlGetReqList = @"
            SELECT ApplicationId, TicketId, CreatedBy, AppliedDate, 
            ApprovalManager, isnull(ManagerApprovalStatus,0) as ManagerApprovalStatus, isnull(ManagerComment,'') as ManagerComment,
            ApprovalOP, isnull(OPApprovalStatus,0) as OPApprovalStatus,isnull(OPComment,'') as OPComment
            FROM NEW_SAP_ACCOUNT_APPLICATIONS_HQ
            where 1=1 
            ";
            if (MyRole == NewSAPAccountUtil.UserRole.Sales) {
                sqlGetReqList += string.Format(@" and (CreatedBy='{0}' or ApprovalManager='{0}') ",User.Identity.Name);
            }
            if (MyRole == NewSAPAccountUtil.UserRole.OPLeader || MyRole == NewSAPAccountUtil.UserRole.MyAdvIT)
            {
               
            }
            if (MyRole== NewSAPAccountUtil.UserRole.NoOne) {
                //sqlGetReqList += @" and ";
                sqlGetReqList += " and 1<>1 ";
            }
            sqlGetReqList += @"Order by AppliedDate desc";

            var dtAppList = dbUtil.dbGetDataTable("MY_EC2", sqlGetReqList);
            gvList.DataSource = dtAppList; gvList.DataBind();
        }
    }

    public static string showSalesOffice(string ApplicationId) {
        var req = NewSAPAccountUtil.getReqDetail(ApplicationId);
        return string.Format("{0}", req.SalesOffice);
    }

    public static string showDetail(string ApplicationId)
    {
        var req = NewSAPAccountUtil.getReqDetail(ApplicationId);
        var sb = new System.Text.StringBuilder();
        sb.AppendFormat("<tr><th align='left' style='width:100px'>Company Name</th><td>{0}</td></tr>",req.CompanyName);
        sb.AppendFormat("<tr><th align='left'>Country</th><td>{0}</td></tr>",req.Country);
        sb.AppendFormat("<tr><th align='left'>Address</th><td>{0}</td></tr>",req.Address1);
        return sb.ToString();
    }

}