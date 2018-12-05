using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Advantech.Myadvantech.DataAccess;
using Advantech.Myadvantech.DataAccess.DataCore.ConfigurationHub;

public partial class Order_BtosPortal_Hub : System.Web.UI.Page
{
    public string TargetUrl = string.Empty;
    public DateTime RequestTime = DateTime.Now;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.IsAuthenticated == false || Session["company_id"] == null || Session["ORG_ID"] == null)
            Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));

        if (!AuthUtil.IsADloG() || !Util.IsTesting())
            Response.Redirect(string.Format("{0}/Lab/CBOMV2/BTOS_PortalV2.aspx", Util.GetRuntimeSiteUrl()));

        if (!Page.IsPostBack)
        {
            string sourceId = Session["cart_id"].ToString();
            int sourceLineNo = MyCartX.getBtosParentLineNo(sourceId);
            string salesOrg = Session["ORG_ID"].ToString();
            string companyId = Session["company_id"].ToString();
            string currency = MyCartX.GetCurrency(sourceId);

            TargetUrl = String.Format("http://myacore.advantech.com/Configurator/ParametersCheck?sourceId={0}&sourceLineNo={1}&sourceSite=MyAdvantech&salesOrg={2}&companyId={3}&currency={4}", sourceId, sourceLineNo, salesOrg, companyId, currency);

        }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod]
    public static string ProcessData(string originalRequestTime)
    {
        string sourceId = HttpContext.Current.Session["cart_id"].ToString();
        int sourceLineNo = MyCartX.getBtosParentLineNo(sourceId);
        string salesOrg = HttpContext.Current.Session["ORG_ID"].ToString();
        string companyId = HttpContext.Current.Session["company_id"].ToString();
        string currency = MyCartX.GetCurrency(sourceId);
        DateTime requestTime = DateTime.Now;

        HubConfiguredResult configuredResult = MyAdvantechDAL.GetHubConfiguredResultsWithLineNo(sourceId, sourceLineNo);

        if (configuredResult != null && DateTime.TryParse(originalRequestTime, out requestTime) && configuredResult.CreatedTime > requestTime)
        {
            UpdateResult updateResult = ConfigurationHubDAL.Configurator2Cart(sourceId, sourceLineNo, salesOrg);
            if (updateResult.IsUpdated)
            {
                return JsonConvert.SerializeObject(new { success = true, msg = "", url = string.Format("{0}/Order/Cart_ListV2.aspx", Util.GetRuntimeSiteUrl()) });
            }
            else
                return JsonConvert.SerializeObject(new { success = false, msg = "Failed to add items to cart, reason: " + updateResult.ServerMessage, url = string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()) });
        }

        return JsonConvert.SerializeObject(new { success = false, msg = "Redirect to home.", url = string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()) });
    }
}