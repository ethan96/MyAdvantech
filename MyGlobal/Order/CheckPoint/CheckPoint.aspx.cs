using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Order_CheckPoint_CheckPoint : System.Web.UI.Page
{
    public void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            List<Advantech.Myadvantech.DataAccess.SO_HEADER> soh = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoHeaderWithWSResult(Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSOFromMYAWithWS());
            this.GridView1.DataSource = soh;
            this.GridView1.DataBind();
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetWSResult(String SO)
    {
        String errMsg = "";
        Advantech.Myadvantech.DataAccess.CPTEST.general cp = new Advantech.Myadvantech.DataAccess.CPTEST.general();
        string[] a = cp.GetNotifyEmailHtmlStr(SO, ref errMsg).Split(new string[] { "</style>" }, StringSplitOptions.None);
        String b = "<style>table {*border-collapse: collapse; /* IE7 and lower */border-spacing: 0;}.bordered {border: solid #ccc 1px};-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;-webkit-box-shadow: 0 1px 1px #ccc;-moz-box-shadow: 0 1px 1px #ccc;box-shadow: 0 1px 1px #ccc;}.bordered tr:hover {background: #fbf8e9;-o-transition: all 0.1s ease-in-out;-webkit-transition: all 0.1s ease-in-out;-moz-transition: all 0.1s ease-in-out;-ms-transition: all 0.1s ease-in-out;transition: all 0.1s ease-in-out;}.bordered td, .bordered th {border-left: 1px solid #ccc;border-top: 1px solid #ccc;padding: 10px;text-align: left;}.bordered caption {border-left: 1px solid #ccc;border-top: 1px solid #ccc;padding: 10px;font-weight: bold;font-size: 18px;}.bordered th {background-color: #dce9f9;background-image: -webkit-gradient(linear, left top, left bottom, from(#ebf3fc), to(#dce9f9));background-image: -webkit-linear-gradient(top, #ebf3fc, #dce9f9);background-image: -moz-linear-gradient(top, #ebf3fc, #dce9f9);background-image: -ms-linear-gradient(top, #ebf3fc, #dce9f9);background-image: -o-linear-gradient(top, #ebf3fc, #dce9f9);background-image: linear-gradient(top, #ebf3fc, #dce9f9);-webkit-box-shadow: 0 1px 0 rgba(255,255,255,.8) inset;-moz-box-shadow: 0 1px 0 rgba(255,255,255,.8) inset;box-shadow: 0 1px 0 rgba(255,255,255,.8) inset;border-top: none;text-shadow: 0 1px 0 rgba(255,255,255,.5);}.bordered td:first-child, .bordered th:first-child {border-left: none;}.bordered th:first-child {-moz-border-radius: 6px 0 0 0;-webkit-border-radius: 6px 0 0 0;border-radius: 6px 0 0 0;}.bordered th:last-child {-moz-border-radius: 0 6px 0 0;-webkit-border-radius: 0 6px 0 0;border-radius: 0 6px 0 0;}.bordered th:only-child {-moz-border-radius: 6px 6px 0 0;-webkit-border-radius: 6px 6px 0 0;border-radius: 6px 6px 0 0;}.bordered tr:last-child td:first-child {-moz-border-radius: 0 0 0 6px;-webkit-border-radius: 0 0 0 6px;border-radius: 0 0 0 6px;}.bordered tr:last-child td:last-child {-moz-border-radius: 0 0 6px 0;-webkit-border-radius: 0 0 6px 0;border-radius: 0 0 6px 0;}</style>";
        return b + a[1];
    }

    //hf1 is click event for convert2order button
    protected void hf1_valueChanged(object sender, EventArgs e)
    {
        SOInfo_Processing(hf1.Value, 1);
    }

    //hf2 is click event for add2cart button
    protected void hf2_valueChanged(object sender, EventArgs e)
    {
        SOInfo_Processing(hf2.Value, 2);
    }

    public void SOInfo_Processing(String hf_value, int sendername)
    {
        try
        {
            String user_id = User.Identity.Name;
            String Currency = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoDetail_Currency(hf_value);            
            String sopo = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoPo_BySo(hf_value);

            String ERP_id = "UZISCHE01";
            String shiptoid = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoPartnerFunc_Number(hf_value,"WE");

            if (String.IsNullOrEmpty(shiptoid))
            {
                shiptoid = Advantech.Myadvantech.Business.CPDBBusinessLogic.ProcessCPShipto(hf_value, sopo, Util.IsTesting());
                Advantech.Myadvantech.Business.CPDBBusinessLogic.UpdatePartnerFuncTable(hf_value, shiptoid);
            }

            if (MYSAPBIZ.is_Valid_Company_Id(ERP_id))
            {
                AuthUtil.SetSessionById(user_id, "", ERP_id);
            }
            else
            {
                String script = "alert('Error Message: ERP ID " + ERP_id + " is invalid');";
                ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", script, true);
                return;
            }

            if (String.IsNullOrEmpty(shiptoid))
            {
                String script = "alert('Error Message: ShipToID is invalid');";
                ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", script, true);
                return;
            }

            String cart_id = Session["cart_id"].ToString();
            String org_id = Session["org_id"].ToString();

            Advantech.Myadvantech.Business.CPDBBusinessLogic.Detail2Cart(hf_value, cart_id, ERP_id, user_id, Currency, org_id);
            Advantech.Myadvantech.Business.CPDBBusinessLogic.SaveAllInfo(hf_value, cart_id, ERP_id, user_id, sopo);

            if (sendername == 1)
                Response.Redirect(String.Format("~/Order/Cart_listV2.aspx?CheckPoint_Convert2Order={0}", Session["cart_id"].ToString()));
            else if (sendername == 2)
                Response.Redirect("~/Order/Cart_listV2.aspx");
        }
        catch (Exception e)
        {
            String script = "alert('Error Message: " + e.Message + "');";
            ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", script, true);
        }
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        Advantech.Myadvantech.DataAccess.CheckPointWS.Job j = new Advantech.Myadvantech.DataAccess.CheckPointWS.Job();
        j.job();
    }
}