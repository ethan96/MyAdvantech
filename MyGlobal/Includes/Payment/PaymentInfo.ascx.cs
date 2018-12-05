using Advantech.Myadvantech.Business;
using ASP;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_Payment_PaymentInfol : System.Web.UI.UserControl
{
    public string PNReference { private set; get; }

    public string TransactionId { private set; get; }

    public string AuthCode { private set; get; }

    public string ResponseMessage { private set; get; }

    private string apiLoginId;

    private string apiTransactionKey;

    private bool simulation;

    private string street;

    //private OrderAddress billTo;

    //private bool _isCheckoutPage;
    //public bool isCheckoutPage
    //{
    //    set
    //    {
    //        this._isCheckoutPage = value;
    //        if (_isCheckoutPage)
    //        {
    //            this.creditCard_info.Visible = true;
    //            this.payment_validate_result.Visible = false;
    //        }
    //        else
    //        {
    //            this.payment_validate_result.Visible = true;
    //            this.creditCard_info.Visible = false;
    //        }
    //    }

    //    get
    //    {
    //        return _isCheckoutPage;
    //    }
    //}

    //public string CardNumber
    //{
    //    set
    //    {
    //        lblCardNumber.Text = value;
    //    }
    //}

    //public string Cardtype
    //{
    //    set
    //    {
    //        lblcardtype.Text = value;
    //    }
    //}

    //public string CVV2
    //{
    //    set
    //    {
    //        lblCVV2.Text = value;
    //    }
    //}

    //public string CardExpirationDate
    //{
    //    set
    //    {
    //        lblCardExpirationDate.Text = value;
    //    }
    //}

    //public string Cardholder
    //{
    //    set
    //    {
    //        lblCardholder.Text = value;
    //    }
    //}

    //public string  OrderID
    //{
    //    set
    //    {
    //        var myOrderMaster = new order_Master("b2b", "order_master");
    //        try
    //        {
    //            DataTable dt = myOrderMaster.GetDT(String.Format("order_id='{0}'", value), "");
    //            if (dt != null && dt.Rows[0] != null)
    //            {
    //                lblCardNumber.Text = dt.Rows[0]["CREDIT_CARD"] != null ? dt.Rows[0]["CREDIT_CARD"].ToString() : "";
    //                lblcardtype.Text = dt.Rows[0]["CREDIT_CARD_TYPE"] != null ? dt.Rows[0]["CREDIT_CARD_TYPE"].ToString() : "";
    //                lblCVV2.Text = dt.Rows[0]["CREDIT_CARD_VERIFY_NUMBER"] != null ? dt.Rows[0]["CREDIT_CARD_VERIFY_NUMBER"].ToString() : "";
    //                lblCardExpirationDate.Text = dt.Rows[0]["CREDIT_CARD_EXPIRE_DATE"] != null ? Convert.ToDateTime(dt.Rows[0]["CREDIT_CARD_EXPIRE_DATE"]).ToString("yyyy-MM") : "";
    //                lblCardholder.Text = dt.Rows[0]["CREDIT_CARD_HOLDER"] != null ? dt.Rows[0]["CREDIT_CARD_HOLDER"].ToString() : "";
    //            }
                
    //        }
    //        catch { }
    //    }
    //}



    private string CardNum
    {
        get
        {
            return txtCreditCardNumber.Text.Replace("'", "''");
        }
    }

    private string CardHolder
    {
        get
        {
            return txtCCardHolder.Text.Replace("'", "''");
        }
    }

    private string CVVCode
    {
        get
        {
            return txtCCardVerifyValue.Text.Replace("'", "''");
        }
    }

    private DateTime CardExpDate
    {
        get
        {
            return new DateTime(Convert.ToInt32(dlCCardExpYear.SelectedValue), Convert.ToInt32(dlCCardExpMonth.SelectedValue), 1);
        }
    }

    private string CardType
    {
        get
        {
            return dlCCardType.SelectedValue;
        }
    }

    private string FirstName
    {
        get
        {
            if (!String.IsNullOrEmpty(CardHolder))
            {
                if (CardHolder.Contains(" "))
                    return CardHolder.Substring(0, CardHolder.LastIndexOf(" "));
                else
                    return CardHolder;
            }
            return "";
 
        }
    }

    private string LastName
    {
        get
        {
            if (!String.IsNullOrEmpty(CardHolder))
                if (CardHolder.Contains(" "))
                    return CardHolder.Substring(CardHolder.LastIndexOf(" ") + 1);
            return "";

        }
    }

    //private DataTable orderPartnerDT
    //{
    //    get
    //    {
    //        MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter orderPartner = new MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter();
    //        return orderPartner.GetPartnerByOrderIDAndType(OrderId, "B_CC");
    //    }
    //}

    //public string OrderId { get; set; }

    private string UserId
    {
        get
        {
            if (HttpContext.Current.Session["user_id"]!=null)
                return HttpContext.Current.Session["user_id"].ToString();
            return "";
        }
    }

    private string ZipCode { get; set; }

    private string Country { get; set; }

    private string City { get; set; }

    private string Street { get; set; }

    private string State { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        //if (Util.IsTesting())
        //{
        //    this.apiLoginId = ConfigurationManager.AppSettings["AuthorizeNet.BB.Sanbox.Login.US"];
        //    this.apiTransactionKey = ConfigurationManager.AppSettings["AuthorizeNet.BB.Sanbox.TransactionKey.US"];
        //    this.simulation = true;
        //}
        //else
        //{
        //    this.apiLoginId = ConfigurationManager.AppSettings["AuthorizeNet.BB.Login.US"];
        //    this.apiTransactionKey = ConfigurationManager.AppSettings["AuthorizeNet.BB.TransactionKey.US"];
        //    this.simulation = false;
        //}

        var yearFrom = DateTime.Now.Year;
        var yearTo = DateTime.Now.Year + 15;
        for (var i = yearFrom; i<= yearTo; i++)
        {
            dlCCardExpYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }

    }

    

    public bool AuthPaymentAmount(string orderNo, Decimal amount, string firstName, string lastName, string billToStreet, string city, string state, string billToZip, string country,
                     string poNo, string creditCardNum, string cvvCode, DateTime expDate, ref string errorMessage)
    {
        string validresult = "";
        List<string> strFraudAlert = new List<string>();
        try
        {
            var validateResponse = AuthorizeNetSolution.AuthorizePaymentAmount(orderNo, amount, firstName, lastName, billToStreet, city, state,  billToZip, country,
            creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());


            if (validateResponse != null)
            {
                if (validateResponse.Result != "Success")
                {
                    errorMessage = validateResponse.Result + ", Message:" + validateResponse.Message + ", Code:" + validateResponse.AuthCode;


                    validresult = "Invalid";
                    strFraudAlert.Add(String.Format("Auth Pnref: {0}", validateResponse.TransactionID));
                    strFraudAlert.Add(validateResponse.Message);
                    this.ResponseMessage = validateResponse.Message;
                    SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                    lblCardNumber.Text, lblCVV2.Text, lblCardExpirationDate.Text, validresult, strFraudAlert, validateResponse.Result, validateResponse.TransactionID, validateResponse.Message, validateResponse.AuthCode, "", "", "", "", "");
                    return false;
                }
                validresult = "Valid";

                this.TransactionId = validateResponse.TransactionID;
                this.AuthCode =  validateResponse.AuthCode;
                this.ResponseMessage = validateResponse.Message;
                SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                lblCardNumber.Text, lblCVV2.Text, lblCardExpirationDate.Text, validresult, strFraudAlert, validateResponse.Result, validateResponse.TransactionID, validateResponse.Message, validateResponse.AuthCode, "", "", "", "", "");


                return true;
            }
            else
            {
                errorMessage = "Error message: auth credit card no response!";
                this.ResponseMessage = errorMessage;
                validresult = "Invalid";
                strFraudAlert.Add(errorMessage);

                SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                lblCardNumber.Text, lblCVV2.Text, lblCardExpirationDate.Text, validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

                return false;
            }
        }
        catch
        {
            lblResult.Text = "Error";
            lblAuthCode.Text = "NA";
            lblResponseMessage.Text = "Payment API Exception.";

            strFraudAlert.Add(lblResponseMessage.Text);
            this.ResponseMessage = lblResponseMessage.Text;
            validresult = "Invalid";
            SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
            creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

            return false;
        }
    }

    public void CreatePaymnetProfileForCustomer(string transactionId, string erpId, string org)
    {
        string validresult = "";
        List<string> strFraudAlert = new List<string>();

        //Alex: 20170425 create paymnet profile for custoemr in authorize.net CIM
        string customerProfileId = Advantech.Myadvantech.Business.AuthorizeNetSolution.GetOrCreateCustomerProfileId(erpId, org, Util.IsTesting());
        if (!string.IsNullOrEmpty(customerProfileId))
        {
            var createProfileResponse = Advantech.Myadvantech.Business.AuthorizeNetSolution.CreatePaymentProfileForCustomerFromTransaction(transactionId, customerProfileId, Util.IsTesting());
            if (createProfileResponse != null)
            {
                if (createProfileResponse.Result != "Success")
                {
                    validresult = "InValid";
                    strFraudAlert.Add("Create PaymnetProfile For Customer Faild");
                }
                else
                {
                    validresult = "Valid";
                    strFraudAlert.Add("Create PaymnetProfile For Customer Success");
                }
                SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                "", "", "", validresult, strFraudAlert, createProfileResponse.Result, createProfileResponse.TransactionID, createProfileResponse.Message, createProfileResponse.AuthCode, "", "", "", "", "");

            }
            else
            {
                validresult = "InValid";
                strFraudAlert.Add("No response");
                SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                "", "", "", validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");
            }
        }
    }

    //public bool PreviewPaymentResult(string orderNo, Decimal amount, string firstName, string lastName, string billToStreet, string city, string state, string billToZip,
    //                 string poNo, string creditCardNum, string cvvCode, DateTime expDate)
    //{
    //    string validresult = "";
    //    List<string> strFraudAlert = new List<string>();

    //    try
    //    {
    //        trAuthInfoV2.Visible = true;

    //        // auth 0.01 us dollar 
    //        var authResponse = AuthorizeNetSolution.AuthorizePaymentAmount(orderNo,amount, firstName, lastName, billToStreet, city, state, billToZip, creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());
    //        if (authResponse != null)
    //        {
    //            lblResult.Text = authResponse.Result;
    //            lblAuthCode.Text = authResponse.AuthCode;
    //            lblResponseMessage.Text = authResponse.Message;
    //            this.PNReference = authResponse.TransactionID;
    //            if (!string.IsNullOrEmpty(authResponse.TransactionID) && authResponse.Result == "Success")
    //            {
    //                var voidResponse = AuthorizeNetSolution.VoidPayment(authResponse.TransactionID, creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());
    //                if (voidResponse != null)
    //                {
    //                    if (voidResponse.Result != "Success")
    //                    {


    //                        validresult = "Void Transaction Faild";
    //                        this.ResponseMessage = "Void Transaction Faild";
    //                        strFraudAlert.Add(String.Format("Auth Pnref: {0}", authResponse.TransactionID));
    //                        strFraudAlert.Add(String.Format("Void Pnref: {0}, Void RespMsg: {1}", voidResponse.TransactionID, voidResponse.Message));
    //                        //SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                        //creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, voidResponse.Result, voidResponse.TransactionID, voidResponse.Message, voidResponse.AuthCode, "", "", "", "", "");

    //                    }
    //                    else
    //                    {
    //                        validresult = "Valid";
    //                        this.ResponseMessage = validresult;
    //                        //SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                        //creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, authResponse.Result, authResponse.TransactionID, authResponse.Message, authResponse.AuthCode, "", "", "", "", "");

    //                    }
    //                }
    //                else
    //                {

    //                    validresult = "Void Transaction Faild";
    //                    this.ResponseMessage = validresult;
    //                    strFraudAlert.Add(String.Format("Auth Pnref: {0}", authResponse.TransactionID));
    //                    strFraudAlert.Add("No response");
    //                    //SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                    //creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //                }
    //            }
    //            else
    //            {
    //                validresult = "Invalid";
    //                this.ResponseMessage = validresult;
    //                strFraudAlert.Add(lblResponseMessage.Text);

    //                //SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                //creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");
    //            }
    //        }
    //        else
    //        {
    //            lblResult.Text = "No response";
    //            lblAuthCode.Text = "NA";
    //            lblResponseMessage.Text = "No response, please try again.";
    //            this.ResponseMessage = lblResponseMessage.Text;
    //            validresult = "Invalid";
    //            strFraudAlert.Add(lblResponseMessage.Text);

    //            //SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //            //creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //        }
    //        SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //        creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, authResponse.Result, authResponse.TransactionID, authResponse.Message, authResponse.AuthCode, "", "", "", "", "");
    //        return true;
    //    }
    //    catch
    //    {
    //        lblResult.Text = "Error";
    //        lblAuthCode.Text = "NA";
    //        lblResponseMessage.Text = "Payment API Exception.";
    //        this.ResponseMessage = lblResponseMessage.Text;
    //        strFraudAlert.Add(lblResponseMessage.Text);
    //        validresult = "Invalid";
    //        SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //        creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //        return false;
    //    }
    //}

    //public bool ValidatePayment(string orderNo, Decimal amount, string firstName, string lastName, string billToStreet, string city, string state, string billToZip,
    //                 string poNo, string creditCardNum, string cvvCode, DateTime expDate, ref string messsage)
    //{
    //    string validresult = "";
    //    List<string> strFraudAlert = new List<string>();
    //    try
    //    {
    //        // auth 0.01 us dollar 
    //        var authResponse = AuthorizeNetSolution.AuthorizePaymentAmount(orderNo, amount, firstName, lastName, billToStreet, city, state, billToZip, creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());

    //        if (authResponse != null)
    //        {
    //            if (!string.IsNullOrEmpty(authResponse.TransactionID) && authResponse.Result == "Success")
    //            {
    //                var voidResponse = AuthorizeNetSolution.VoidPayment(authResponse.TransactionID, creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());
    //                if (voidResponse != null)
    //                {
    //                    if (voidResponse.Result != "Success")
    //                    {
    //                        validresult = "Void Transaction Faild";
    //                        this.ResponseMessage = validresult;
    //                        strFraudAlert.Add(String.Format("Auth Pnref: {0}", authResponse.TransactionID));
    //                        strFraudAlert.Add(String.Format("Void Pnref: {0}, Void RespMsg: {1}", voidResponse.TransactionID, voidResponse.Message));
    //                        SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                        creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, voidResponse.Result, voidResponse.TransactionID, voidResponse.Message, voidResponse.AuthCode, "", "", "", "", "");

    //                    }
    //                    else
    //                    {
    //                        validresult = "Void Transaction Success";
    //                        this.ResponseMessage = validresult;
    //                        SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                        creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, authResponse.Result, authResponse.TransactionID, authResponse.Message, authResponse.AuthCode, "", "", "", "", "");
    //                    }
    //                }
    //                else
    //                {

    //                    validresult = "Void Transaction Faild";
    //                    this.ResponseMessage = validresult;
    //                    strFraudAlert.Add(String.Format("Auth Pnref: {0}", authResponse.TransactionID));
    //                    strFraudAlert.Add("No response");
    //                    SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                    creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //                }
    //            }
    //            else
    //            {

    //                messsage = "Error message:" + authResponse.Message + " (Code: " + authResponse.AuthCode + ")";
    //                this.ResponseMessage = messsage;
    //                validresult = "Invalid";
    //                strFraudAlert.Add(messsage);

    //                SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //                creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");
    //                return false;
    //            }
    //            return true;

    //        }
    //        else
    //        {
    //            messsage = "Error message: validate credit card no response!";
    //            this.ResponseMessage = messsage;
    //            validresult = "Invalid";
    //            strFraudAlert.Add(messsage);

    //            SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //            creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //            return false;
    //        }
    //    }
    //    catch
    //    {
    //        trAuthInfoV2.Visible = true;
    //        lblResult.Text = "Error";
    //        lblAuthCode.Text = "NA";
    //        lblResponseMessage.Text = "Payment API Exception.";
    //        this.ResponseMessage = lblResponseMessage.Text;

    //        strFraudAlert.Add(lblResponseMessage.Text);
    //        validresult = "Invalid";
    //        SaveLog(amount, firstName, lastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
    //        creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

    //        return false;
    //    }
    //}

    public bool VoidPayment(string transactionId, string creditCardNum, string cvvCode, DateTime expDate, ref string messsage)
    {
        string validresult = "";
        List<string> strFraudAlert = new List<string>();
        try
        {

            var voidResponse = AuthorizeNetSolution.VoidPayment(transactionId, creditCardNum, expDate.ToString("yyyy-MM"), cvvCode, Util.IsTesting());
            if (voidResponse != null)
            {
                if (voidResponse.Result != "Success")
                {
                    validresult = "Void Transaction Faild";
                    this.ResponseMessage = validresult;
                    strFraudAlert.Add(String.Format("Auth Pnref: {0}", transactionId));
                    strFraudAlert.Add(String.Format("Void Pnref: {0}, Void RespMsg: {1}", voidResponse.TransactionID, voidResponse.Message));
                    SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                    creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, voidResponse.Result, voidResponse.TransactionID, voidResponse.Message, voidResponse.AuthCode, "", "", "", "", "");

                }
                else
                {
                    validresult = "Void Transaction Success";
                    this.ResponseMessage = validresult;
                    SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                    creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", transactionId, "", "", "", "", "", "", "");
                }
            }
            else
            {

                validresult = "Void Transaction Faild";
                this.ResponseMessage = validresult;
                strFraudAlert.Add(String.Format("Auth Pnref: {0}", transactionId));
                strFraudAlert.Add("No response");
                SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");
                return false;
            }
            return true;
        }
        catch
        {
            trAuthInfoV2.Visible = true;
            lblResult.Text = "Error";
            lblAuthCode.Text = "NA";
            lblResponseMessage.Text = "Payment API Exception.";
            this.ResponseMessage = lblResponseMessage.Text;
            strFraudAlert.Add(lblResponseMessage.Text);
            validresult = "Invalid";
            SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
            creditCardNum, cvvCode, expDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");

            return false;
        }
    }

    private void SaveLog(decimal amount, string firstName, string lastName, string billToStreet, string city, string state, string billToZip,
        string poNo, string creditCardNum, string cvvCode, string expDate, string validResult, List<string> strFraudAlert,string responseResult,
        string responsePnref, string responseMsg, string responseAuthCode, string responseAVSAddr, string responseAVSZip, string responseIAVS, 
        string responseCVV2MATCH, string responseDuplicate)
    {
        try
        {

            string strCmd = System.String.Format("INSERT INTO MY_CC_LOG VALUES ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}','{24}','{25}')",
            HttpContext.Current.Session.SessionID, HttpContext.Current.User.Identity.Name, amount, 
            firstName, lastName, billToStreet, city, state, billToZip, poNo, creditCardNum, "", expDate,
            responseResult,responsePnref,responseMsg, responseAuthCode, responseAVSAddr, responseAVSZip, 
            responseIAVS, responseCVV2MATCH, responseDuplicate, validResult, 
            (strFraudAlert.Count > 0 ? String.Join("<br />", strFraudAlert.ToArray()) : ""),DateTime.Now, Util.GetClientIP()
            );

            SqlConnection g_adoConn = new SqlConnection(ConfigurationManager.ConnectionStrings["MYLOCAL"].ConnectionString);
            System.Data.SqlClient.SqlCommand dbCmd = g_adoConn.CreateCommand();
            dbCmd.Connection = g_adoConn;
            dbCmd.CommandText = strCmd;
        
            g_adoConn.Open();

            dbCmd.ExecuteNonQuery();
            g_adoConn.Close();
        }
        catch(Exception ex)
        { }

    }



    public bool AuthPaymentAmount(string orderId, string orderNo, string soldToErpId, ref string errorMessage)
    {

        bool paymentRet = false;

        string tempErrMsg = "";
        //update Order Partner type B_CC by using bill to related property
        UpdateBCCOrderPartner(orderId, ref tempErrMsg);

        errorMessage += tempErrMsg;
        decimal totalauthamount = GetBBTotalAmount(orderId, ref tempErrMsg);
        errorMessage += tempErrMsg;

        if (string.IsNullOrEmpty(errorMessage))
        {

            string validresult = "";
            List<string> strFraudAlert = new List<string>();
            
            try
            {
                var authResponse = AuthorizeNetSolution.AuthorizePaymentAmount(orderNo, totalauthamount, FirstName, LastName, Street, City, State, ZipCode, Country,
                CardNum, CardExpDate.ToString("yyyy-MM"), CVVCode, Util.IsTesting());


                if (authResponse != null)
                {
                    if (authResponse.Result == "Success")
                    {
                        if(ProcessAfterAuthSuccess(orderId, orderNo, authResponse.TransactionID, authResponse.AuthCode, authResponse.Message, totalauthamount, UserId, soldToErpId, ref errorMessage))
                        {
                            validresult = "Valid";
                            paymentRet = true;
                        }
                        else
                            validresult = "Invalid";

                    }
                    else
                    {
                        errorMessage = authResponse.Result + ", Message:" + authResponse.Message + ", Code:" + authResponse.AuthCode;
                        validresult = "Invalid";                       
                    }
                                          

                }
                else
                {
                    errorMessage = "Error message: auth credit card no response!";
                    validresult = "Invalid";
                }
                strFraudAlert.Add(errorMessage);
                SaveLog(totalauthamount, FirstName, LastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                    CardNum, CVVCode, CardExpDate.ToString("yyyy-MM"), validresult, strFraudAlert, authResponse.Result, authResponse.TransactionID, authResponse.Message, authResponse.AuthCode, "", "", "", "", "");

            }
            catch(Exception ex)
            {
                errorMessage = ex.Message;
                strFraudAlert.Add(errorMessage);
                SaveLog(totalauthamount, FirstName, LastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                CardNum, CVVCode, CardExpDate.ToString("yyyy-MM"), "Invalid", strFraudAlert, "", "", "", "", "", "", "", "", "");
            }
        }


        try
        {
            if (!String.IsNullOrEmpty(errorMessage))
            {
                MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter a = new MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter();
                a.Insert(orderNo, 0, 0, errorMessage, DateTime.Now, 0, "CC_Error");
            }
        }
        catch (Exception ex)
        {
        }

        return paymentRet;


    }

    public bool VoidPayment(string orderId, string orderNo)
    {
        string  errorMessage = "";
        bool paymentRet = false;
        var orderPartner = new MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter();
        var orderPartnerDT = orderPartner.GetPartnerByOrderIDAndType(orderId, "B_CC");
        string validresult = "";
        List<string> strFraudAlert = new List<string>();

        if (orderPartnerDT.Rows.Count > 0)
        {

            string transactionId = "";
            var Authinfo = dbUtil.dbExecuteScalar("MY", "select ROWID from ORDER_PARTNERS where ORDER_ID = '" + orderId + "' and type = 'B_CC' ");
            if (Authinfo != null && !String.IsNullOrEmpty(Authinfo.ToString()))
            {
                if (Authinfo.ToString().Contains("|"))
                {
                    transactionId = Authinfo.ToString().Split('|')[0];


                    try
                    {
                        var voidResponse = AuthorizeNetSolution.VoidPayment(transactionId, CardNum, CardExpDate.ToString("yyyy-MM"), CVVCode, Util.IsTesting());
                        if (voidResponse != null)
                        {
                            if (voidResponse.Result == "Success")
                            {
                                try
                                {
                                    var ccOrder = new Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER();
                                    ccOrder.ORDER_NO = orderNo;
                                    ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Void.ToString();
                                    ccOrder.STATUS = "Success";
                                    ccOrder.TRANSACTION_ID = transactionId;
                                    ccOrder.AUTH_CODE = voidResponse.AuthCode;
                                    ccOrder.CREATED_DATE = DateTime.Now;
                                    ccOrder.CREATED_By = UserId;
                                    if (voidResponse.Message != null)
                                        ccOrder.MESSAGE = voidResponse.Message;

                                    Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder);
                                    validresult = "Valid";
                                    paymentRet = true;
                                }
                                catch(Exception ex)
                                {
                                    errorMessage = ex.Message;
                                    validresult = "Invalid";
                                }

                            }
                        }
                        else
                        {
                            errorMessage = "Void Transaction Faild";
                            validresult = "Invalid";
                        }
                        strFraudAlert.Add(errorMessage);
                        SaveLog(0, "", "", this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                        CardNum, CVVCode, CardExpDate.ToString("yyyy-MM"), validresult, strFraudAlert, "", "", "", "", "", "", "", "", "");
                    }
                    catch (Exception ex)
                    {
                        errorMessage = ex.Message;
                        strFraudAlert.Add(errorMessage);
                        SaveLog(0, FirstName, LastName, this.billto.Street, this.billto.City, this.billto.State, this.billto.Zipcode, "",
                        CardNum, CVVCode, CardExpDate.ToString("yyyy-MM"), "Invalid", strFraudAlert, "", "", "", "", "", "", "", "", "");

                    }
                }
                 
            }

        }
        return paymentRet;

    }

    /// <summary>
    /// update tranid/authocode in orderpartner bcc type and store partial credit card information in order master ,Add CC transaction reocrd to bb_credtiCard_order table too
    /// </summary>
    /// <param name="orderNo"></param>
    /// <param name="transactionId"></param>
    /// <param name="authCode"></param>
    /// <param name="authMessage"></param>
    /// <param name="totalAmount"></param>
    /// <param name="userId"></param>
    /// <param name="soldToErpId"></param>
    /// <param name="errorMessage"></param>
    /// <returns></returns>
    private bool ProcessAfterAuthSuccess(string orderId, string orderNo,  string transactionId, string authCode, string authMessage, decimal totalAmount, string userId, string soldToErpId, ref string errorMessage)
    {
        try
        {
            //update tranid/authocode in orderpartner bcc type and store partial credit card information in order master 
            dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set ROWID = '{0}' where type = 'B_CC' and ORDER_ID = '{1}'", transactionId + "|" + authCode, orderId));
            string hideCardNum = "************" + CardNum.Substring(CardNum.Length - 4, 4);
            dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_MASTER  set CREDIT_CARD = '{1}',CREDIT_CARD_EXPIRE_DATE = '{2}',CREDIT_CARD_HOLDER = '{3}', CREDIT_CARD_TYPE = '{4}', CREDIT_CARD_VERIFY_NUMBER = '{5}' where  ORDER_ID = '{0}'", orderId, hideCardNum, CardExpDate, CardHolder, CardType, "999"));

            //Add CC transaction reocrd to bb_credtiCard_order table too
            var ccOrder = new Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER();
            ccOrder.ORDER_NO = orderNo;
            ccOrder.CARD_NO = hideCardNum;
            ccOrder.CARD_TYPE = CardType;
            ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Authorization.ToString();
            ccOrder.STATUS = "Success";
            ccOrder.TRANSACTION_ID = transactionId;
            ccOrder.AUTH_CODE = authCode;
            ccOrder.TOTAL_AUTH_AMOUNT = totalAmount;
            ccOrder.CREATED_DATE = DateTime.Now;
            ccOrder.CREATED_By = userId;
            if (authMessage != null)
                ccOrder.MESSAGE = authMessage;

            Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder);
            //Alex: 20170425 create paymnet profile for custoemr in authorize.net CIM
            CreatePaymnetProfileForCustomer(transactionId, soldToErpId, "US10");
            return true;
        }
        catch(Exception ex)
        {
            errorMessage = ex.Message;
            string error = "";
            //更新各TABLE失敗的話也要VOID
            VoidPayment(transactionId, CardNum, CVVCode, CardExpDate, ref error);
        }
        return false;
    }

    private bool UpdateBCCOrderPartner(string orderId, ref string errorMsg)
    {
        try
        {
            if (ckbUserNewBillAddress.Checked)
            {
                string cardholder = "";
                if (String.IsNullOrEmpty(txtCCardHolder.Text.Trim()))
                    cardholder = txtCCardHolder.Text;
                else
                    cardholder = txtNewBillAttention.Text;

                // If customer choice new bill to address for creditCard authorization, then update type b_cc partner
                dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set NAME = '{1}', ATTENTION = '{2}' , TEL = '{3}', ZIPCODE = '{4}', COUNTRY = '{5}', CITY = '{6}', STREET = '{7}',STREET2 = '{8}', STATE = '{9}' where type = 'B_CC' and ORDER_ID = '{0}'",
                                                    orderId, cardholder, txtNewBillAttention.Text, txtNewBillTel.Text, txtNewBillZipCode.Text, txtNewBillCountry.Text, txtNewBillCity.Text, txtNewBillStreet.Text, txtNewBillStreet2.Text, txtNewBillState.Text));
            }
            //else
            //{
            //    //If customer not choice new bill to address for creditCard authorization, then update type b_cc partner tp empty
            //    dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set NAME = '{1}', ATTENTION = '{2}' , TEL = '{3}', ZIPCODE = '{4}', COUNTRY = '{5}', CITY = '{6}', STREET = '{7}',STREET2 = '{8}', STATE = '{9}' where type = 'B_CC' and ORDER_ID = '{0}'",
            //                                    orderId, "", "", "", "", "", "", "", "", ""));
            //}

            MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter orderPartner = new MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter();
            var orderPartnerDT = orderPartner.GetPartnerByOrderIDAndType(orderId, "B_CC");

            if (orderPartnerDT.Rows.Count > 0)
            {
                ZipCode = orderPartnerDT.Rows[0]["ZIPCODE"].ToString();
                Country = orderPartnerDT.Rows[0]["COUNTRY"].ToString();
                City = orderPartnerDT.Rows[0]["CITY"].ToString();
                Street = orderPartnerDT.Rows[0]["STREET"].ToString();
                State = orderPartnerDT.Rows[0]["STATE"].ToString();
                return true;

            }
            else
                errorMsg = "No Credit Card billto information. Authorize payment fail!";
        }
        catch(Exception ex)
        {
            errorMsg = ex.Message;
        }
        return false;

    }

    private decimal GetBBTotalAmount(string orderNo, ref string errorMsg) {
        decimal orderamount = 0;
        decimal taxamount = 0;
        decimal freightamount = 0;

        try
        {
            //Order amount
            var myOrderDetail = new order_Detail("b2b", "order_detail");
            orderamount = myOrderDetail.getTotalAmount(orderNo);

            //Freight amount
            var myFt = new Freight("b2b", "Freight");
            DataTable dtFreight = myFt.GetDT(String.Format("order_id='{0}'", orderNo), "");
            decimal freight = 0;
            if (dtFreight != null && dtFreight.Rows.Count > 0 && dtFreight.Rows[0] != null)
            {

                if (decimal.TryParse(dtFreight.Rows[0]["fvalue"].ToString(), out freight) == false)
                {
                    errorMsg = "Get freight amount error in totalAmount calculation!";

                }
                freightamount += freight;
            }


            //Tax amount
            orderMasterExtensionV2 masterExtension = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(o => o.ORDER_ID == orderNo).FirstOrDefault();
            if (masterExtension != null && masterExtension.OrderTaxRate != null)
                taxamount = Decimal.Round(orderamount * masterExtension.OrderTaxRate.Value, 2, MidpointRounding.AwayFromZero);
            else
                errorMsg = "Get tax amount error in totalAmount calculation!";
        }
        catch(Exception ex)
        {
            errorMsg = ex.Message;
        }
        return orderamount + freightamount + taxamount;
    }
}