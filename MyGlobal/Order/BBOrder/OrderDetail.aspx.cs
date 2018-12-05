using Advantech.Myadvantech.DataAccess;
using Advantech.Myadvantech.DataAccess.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Order_BBOrder_OrderDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (Util.IsBBCustomerCare() == false)
                Response.Redirect(Request.ApplicationPath);

            if (Request["OrderNo"] != null && !string.IsNullOrEmpty(Request["OrderNo"]))
            {
                string orderNo = Request["OrderNo"].ToString();
                Advantech.Myadvantech.DataAccess.Entities.Order order = BBeStoreDAL.GetBBeStoreOrderByOrderNo(orderNo);
                if (order != null && order.Cart != null)
                {
                    lbOrderNo.Text = order.OrderNo;
                    lbEmail.Text = order.UserID;
                    SoldTo.IsCanPick = false;
                    ShipTo.IsCanPick = false;
                    BillTo.IsCanPick = false;

                    var sERPID = SoldTo.FindControl("trerpid");
                    if (sERPID != null)
                        sERPID.Visible = false;
                    var shERPID = ShipTo.FindControl("trerpid");
                    if (shERPID != null)
                        shERPID.Visible = false;
                    var bERPID = BillTo.FindControl("trerpid");
                    if (bERPID != null)
                        bERPID.Visible = false;

                    if (order.Cart.SoldToContact != null)
                    {
                        SoldTo.Name = order.Cart.SoldToContact.AttCompanyName;
                        SoldTo.Street = order.Cart.SoldToContact.Address1;
                        SoldTo.City = order.Cart.SoldToContact.City;
                        SoldTo.State = order.Cart.SoldToContact.State;
                        SoldTo.Zipcode = order.Cart.SoldToContact.ZipCode;
                        SoldTo.Country = order.Cart.SoldToContact.Country;
                        SoldTo.Attention = order.Cart.SoldToContact.FirstName + " " + order.Cart.SoldToContact.LastName;
                        SoldTo.EMAIL = order.Cart.SoldToContact.UserID;
                        SoldTo.Tel = order.Cart.SoldToContact.TelNo + order.Cart.SoldToContact.TelExt;
                    }

                    if (order.Cart.ShipToContact != null)
                    {
                        ShipTo.Name = order.Cart.ShipToContact.AttCompanyName;
                        ShipTo.Street = order.Cart.ShipToContact.Address1;
                        ShipTo.City = order.Cart.ShipToContact.City;
                        ShipTo.State = order.Cart.ShipToContact.State;
                        ShipTo.Zipcode = order.Cart.ShipToContact.ZipCode;
                        ShipTo.Country = order.Cart.ShipToContact.Country;
                        ShipTo.Attention = order.Cart.ShipToContact.FirstName + " " + order.Cart.ShipToContact.LastName;
                        ShipTo.EMAIL = order.Cart.ShipToContact.UserID;
                        ShipTo.Tel = order.Cart.ShipToContact.TelNo + order.Cart.ShipToContact.TelExt;

                        hfAddress1.Value = ShipTo.Street;
                        if (order.Cart.ShipToContact.ToBeVerifiedShipToAddress == true ||
                            order.Cart.ShipToContact.ValidationStatusX == CartContact.AddressValidationStatus.CCRConfirmed)
                        {
                            dvValidShipToAddr.Visible = true;
                            btnUpdShitpAddr.Visible = true;
                            btnUpdShitpAddr.ToolTip = order.Cart.ShipToContact.ContactID.ToString();
                            if (order.Cart.ShipToContact.ValidationStatusX == CartContact.AddressValidationStatus.CCRConfirmed)
                                lbValidAddr.Text = "CCRConfirmed";
                            else
                                lbValidAddr.Text = "Address was flagged as invalid, please review.";
                        }
                        else
                        {
                            dvValidShipToAddr.Visible = false;
                            btnUpdShitpAddr.Visible = false;
                        }
                    }

                    if (order.Cart.BillToContact != null)
                    {
                        BillTo.Name = order.Cart.BillToContact.AttCompanyName;
                        BillTo.Street = order.Cart.BillToContact.Address1;
                        BillTo.City = order.Cart.BillToContact.City;
                        BillTo.State = order.Cart.BillToContact.State;
                        BillTo.Zipcode = order.Cart.BillToContact.ZipCode;
                        BillTo.Country = order.Cart.BillToContact.Country;
                        BillTo.Attention = order.Cart.BillToContact.FirstName + " " + order.Cart.BillToContact.LastName;
                        BillTo.EMAIL = order.Cart.BillToContact.UserID;
                        BillTo.Tel = order.Cart.BillToContact.TelNo + order.Cart.BillToContact.TelExt;
                    }

                    txtCustComm.Text = order.CustomerComment;
                    lbPoNo.Text = order.PurchaseNO;
                    lbFreight.Text = order.FreightX;
                    lbTax.Text = order.TaxX;
                    lbTaxRate.Text = order.TaxRateX;
                    lbTotalAmount.Text = order.TotalAmountX;
                    lbShippingMethod.Text = order.ShippingMethod;

                    List<string> emergencyshipment = new List<string>() { "FedEx 2 Day®", "FedEx Standard Overnight®", "FedEx Priority Overnight®", "FedEx First Overnight®", "UPS Next Day Air®", "UPS Second Day Air®", "USPS Priority Mail®" };
                    if (emergencyshipment.Contains(order.ShippingMethod))
                        lbShippingMethod.ForeColor = System.Drawing.Color.Red;

                    rpOrderDetail.DataSource = order.Cart.CartItem;
                    rpOrderDetail.DataBind();


                    BBCustomer c = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getBBcustomerByUserID(order.UserID);
                    if (c != null)
                    {
                        lbERPID.Text = c.CustomerID;
                        btnCreateNewSAPaccount.Visible = false;
                        btnCreateContactPerson.Visible = false;
                    }
                    
                    //Show failed order message
                    object status = dbUtil.dbExecuteScalar("MY", string.Format("select top 1 ORDER_STATUS from BB_ESTORE_ORDER where ORDER_NO = '{0}' ", orderNo));
                    if (status != null && string.Equals(status.ToString(), BBeStoreOrderStatus.FailedToSAP.ToString(), StringComparison.OrdinalIgnoreCase))
                    {
                        dvFailedMessage.Visible = true;
                        System.Data.DataTable dt = dbUtil.dbGetDataTable("MY", string.Format("select ISNULL([MESSAGE],'') AS MSG from ORDER_PROC_STATUS2 where ORDER_NO = '{0}' order by LINE_SEQ", orderNo));
                        if (dt != null && dt.Rows.Count > 0)
                        {
                            System.Text.StringBuilder msg = new System.Text.StringBuilder();
                            foreach (System.Data.DataRow dr in dt.Rows)
                                msg.AppendFormat("<font color='red'>&nbsp;&nbsp;+&nbsp;{0}</font><br />", dr[0].ToString());
                            ltFailedMessage.Text = msg.ToString();
                        }
                    }

                    //Check is resale?
                    rbResale.Items.Clear();
                    ListItem yes = new ListItem("Yes");
                    ListItem no = new ListItem("No");
                    if (!string.IsNullOrEmpty(order.ResellerID))
                    {
                        yes.Selected = true;
                        trResaleID.Visible = true;
                        lbResaleID.Text = order.ResellerID;
                        trResaleDocURL.Visible = true;

                        if (!string.IsNullOrEmpty(order.ResellerCertificate))
                        {
                            hlResaleCer.Visible = true;
                            hlResaleCer.NavigateUrl = string.Format("https://buy.advantech-bb.com/resource/Reseller/{0}", order.ResellerCertificate);
                        }
                        else
                            hlResaleCer.Visible = false;
                    }
                    else
                    {
                        no.Selected = true;
                        trResaleID.Visible = false;
                        trResaleDocURL.Visible = false;
                    }
                    rbResale.Items.Add(yes);
                    rbResale.Items.Add(no);
                }
                else
                {
                    lbMsg.Text = "No eStore order data.";
                    dvMain.Visible = false;
                }
            }
            else
            {
                lbMsg.Text = "No eStore order data.";
                dvMain.Visible = false;
            }
        }
    }

    protected void btnCreateNewSAPaccount_Click(object sender, EventArgs e)
    {
        if (Request["OrderNo"] != null && !string.IsNullOrEmpty(Request["OrderNo"]))
            Response.Redirect(string.Format("{0}Order/BBorder/NewSAPAccount_ABB.aspx?StoreOrderNo={1}", Request.ApplicationPath, Request["OrderNo"].ToString()));
        else
            return;
    }
    protected void btnBackToOrderList_Click(object sender, EventArgs e)
    {
        Response.Redirect(string.Format("{0}Order/BBOrder/OrderList.aspx", Request.ApplicationPath));
    }
}