using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Advantech.Myadvantech.DataAccess;
using System.Drawing;
using System.Web.UI.HtmlControls;

public partial class Includes_BBFreightCalculation : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    protected void gvShippingResult_RowDataBound(Object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblErrmsg = (Label)e.Row.FindControl("lblErrmsg");
            if (!string.IsNullOrEmpty(lblErrmsg.Text))
            {
                Label lblName = (Label)e.Row.FindControl("lblName");
                lblName.Text = "<span style=\"color: #ff0033\"><b>" + lblName.Text + "</b></span>";
                lblName.ForeColor = Color.Red;

                //HtmlInputRadioButton rb = (HtmlInputRadioButton)e.Row.FindControl("rb");
                //rb.Disabled = true;
                
            }
        }
    }

    public Boolean GetFreight(SAP_DIMCOMPANY _Soldto, SAP_DIMCOMPANY _Shipto, SAP_DIMCOMPANY _Billto, List<cart_DETAIL_V2> _CartItems)
    {
        tbShippingResult.Visible = true;
        tbTotalMessage.Visible = false;
        lblResultTitle.Text = "Freight Info";
        List<ShippingMethod> shippingmethods = new List<ShippingMethod>();
        List<FreightOption> freightOptions = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetAllFreightOptions();
        foreach(var option in freightOptions)
        {
            ShippingMethod method = new ShippingMethod();
            method.MethodName = option.SAPCode + ": " + option.Description;
            method.MethodValue = option.CarrierCode + ": " + option.Description;
            method.DisplayShippingCost = "N/A";
            if (option.EStoreServiceName != null)
                method.EstoreServiceName = option.EStoreServiceName;
            shippingmethods.Add(method);
        }

        Tuple <bool, Advantech.Myadvantech.DataAccess.bbeStoreFreightAPI.Response> result = Advantech.Myadvantech.Business.FreightCalculateBusinessLogic.CalculateBBFreight(_Soldto, _Shipto, _Billto, _CartItems);
        if (result.Item1)
        {          
            if (result.Item2.ShippingRates != null)
            {
                foreach (var item in result.Item2.ShippingRates)
                {                
                    foreach(var method in shippingmethods)
                    {
                        if (method.EstoreServiceName == item.Nmae)
                        {
                            if (string.IsNullOrEmpty(item.ErrorMessage))
                            {
                                method.ShippingCost = item.Rate;
                                method.DisplayShippingCost = item.Rate.ToString();
                            }
                            else
                                method.ErrorMessage = item.ErrorMessage;
                        }
                    }

                }

            }

            if (result.Item2.Boxex[0] != null)
            {
                lbWeight.Text = "Total weight: " + Decimal.Round(result.Item2.Boxex[0].Weight, 2) + " pounds.";
            }
            
        }
        gvShippingResult.DataSource = shippingmethods;
        gvShippingResult.DataBind();
        return true;

    }

    public class ShippingMethod
    {
        public string MethodName { get; set; }
        public string MethodValue { get; set; }
        public float ShippingCost { get; set; }
        public string DisplayShippingCost { get; set; }
        public string EstoreServiceName { get; set; }
        public string ErrorMessage { get; set; }
        
    }

}