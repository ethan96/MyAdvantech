<%@ WebService Language="C#" Class="ProjectRegistration" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections.Generic;
using System.Linq;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class ProjectRegistration  : System.Web.Services.WebService {

    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void GetContactsByPrjRowID()
    {
        List<ProjectContact> contacts = new List<ProjectContact>();
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(Context.Request.QueryString.Get("RowID")))
        {
            try
            {
                InterConPrjRegTableAdapters.MY_PRJ_REG_CONTACTSTableAdapter Prj_C_A = new InterConPrjRegTableAdapters.MY_PRJ_REG_CONTACTSTableAdapter();
                InterConPrjReg.MY_PRJ_REG_CONTACTSDataTable dt = Prj_C_A.GetListByPrjRowID(Context.Request.QueryString.Get("RowID"));
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (System.Data.DataRow dr in dt.Rows)
                    {
                        var row = (InterConPrjReg.MY_PRJ_REG_CONTACTSRow)dr;
                        ProjectContact contact = new ProjectContact();
                        contact.Row_ID = row.ROW_ID;
                        contact.Prj_Row_ID = row.PRJ_ROW_ID;
                        contact.Last_Name = row.LAST_NAME;
                        contact.First_Name = row.FIRST_NAME;
                        contact.Email = row.EMAIL;
                        contact.Tel = row.TEL;
                        contacts.Add(contact);
                    }
                    //Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(contacts));
                }
            }
            catch
            {
                
            }
        }
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(contacts));
        Context.Response.End();
    }

    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void DeleteContact(string RowID)
    {
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(RowID))
        {
            try
            {
                dbUtil.dbExecuteNoQuery("MYLOCAL", string.Format("Delete from MY_PRJ_REG_CONTACTS where ROW_ID = '{0}'", RowID.Trim()));
            }
            catch
            {
                
            }
        }
        Context.Response.Write(string.Empty);
        Context.Response.End();
    }
    
    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void UpdateContacts(string PrjRowID, string JsonData)
    {
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(PrjRowID) && !string.IsNullOrEmpty(JsonData))
        {
            try
            {
                List<ProjectContact> contacts = Newtonsoft.Json.JsonConvert.DeserializeObject<List<ProjectContact>>(JsonData);
                Tuple<bool, string> result = this.CheckContactData(contacts);
                if (result.Item1 == true)
                {
                    System.Data.DataTable oldDt = dbUtil.dbGetDataTable("MYLOCAL", string.Format("select LAST_NAME,FIRST_NAME,EMAIL,TEL from MY_PRJ_REG_CONTACTS where PRJ_ROW_ID = '{0}'", PrjRowID.Trim()));
                    dbUtil.dbExecuteNoQuery("MYLOCAL", string.Format("Delete from MY_PRJ_REG_CONTACTS where PRJ_ROW_ID = '{0}'", PrjRowID.Trim()));

                    System.Text.StringBuilder sql = new System.Text.StringBuilder();
                    foreach (var contact in contacts)
                    {
                        contact.Row_ID = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                        contact.Prj_Row_ID = PrjRowID;
                        sql.AppendFormat("Insert into MY_PRJ_REG_CONTACTS values ('{0}','{1}','', '{2}', '{3}', '{4}', '{5}',  '{6}', GETDATE(), '{6}', GETDATE());", contact.Row_ID, contact.Prj_Row_ID, contact.Last_Name, contact.First_Name, contact.Email, contact.Tel, Context.User.Identity.Name);
                    }
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql.ToString());

                    System.Web.UI.WebControls.GridView gv1 = new System.Web.UI.WebControls.GridView();
                    gv1.DataSource = oldDt.DefaultView;
                    gv1.DataBind();
                    System.Text.StringBuilder stringBuilder = new System.Text.StringBuilder();
                    System.IO.StringWriter stringWrite = new System.IO.StringWriter(stringBuilder);
                    System.Web.UI.HtmlTextWriter htmlWrite = new System.Web.UI.HtmlTextWriter(stringWrite);
                    gv1.RenderControl(htmlWrite);
                    
                    InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter masterAdapter = new InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter();
                    InterConPrjReg.MY_PRJ_REG_MASTERRow master = (InterConPrjReg.MY_PRJ_REG_MASTERRow)masterAdapter.GetDataByRowID(PrjRowID).Rows[0];
                    decimal totalamount = InterConPrjRegUtil.GetTotalAmountByID(PrjRowID);
                    string stage = string.Empty;
                    object obj = dbUtil.dbExecuteScalar("CRMAPPDB", string.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", master.PRJ_OPTY_ID));
                    if (obj != null)
                        stage = obj.ToString();
                    string cpName = string.Empty;
                    obj = dbUtil.dbExecuteScalar("MY", string.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", master.CP_ACCOUNT_ROW_ID));
                    if (obj != null)
                        cpName = obj.ToString();
                    stringBuilder.Insert(0, "<br /><br /><span style='color: blue;'>[Before Change]</span><br /><br />");
                    stringBuilder.Insert(0, String.Format("Project Information has been updated by {0} on {1}.<br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4}<br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), cpName, master.CP_COMPANY_ID, master.PRJ_NAME, stage, totalamount, master.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd")));
                    string html = stringBuilder.ToString();
                    stringBuilder.Clear();
                    
                    gv1.DataSource = contacts.Select(p => new { LAST_NAME = p.Last_Name, FIRST_NAME = p.First_Name, EMAIL = p.Email, TEL = p.Tel });
                    gv1.DataBind();
                    gv1.RenderControl(htmlWrite);
                    stringBuilder.Insert(0, "<br /><br /><span style='color: blue;'>[After Change]</span><br /><br />");

                    html += stringBuilder.ToString();

                    InterConPrjRegUtil.Sendmail(PrjRowID, "A Project registration contact data has been updated by " + HttpContext.Current.User.Identity.Name, -2, html);
                    
                    Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(contacts));
                }
                else
                {
                    Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
                    {
                        Result = result.Item1,
                        Message = result.Item2
                    }));
                }
            }
            catch
            {
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(string.Empty));
            }
        }
        else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(string.Empty));
        Context.Response.End();
    }

    public Tuple<bool, string> CheckContactData(List<ProjectContact> contacts)
    {
        foreach (ProjectContact contact in contacts)
        {
            if (string.IsNullOrWhiteSpace(contact.Last_Name) || string.IsNullOrWhiteSpace(contact.First_Name) || string.IsNullOrWhiteSpace(contact.Email))
                return new Tuple<bool, string>(false, "Name and email can not be empty");
            if (!string.IsNullOrEmpty(contact.Email) && Util.IsValidEmailFormat(contact.Email) == false)
                return new Tuple<bool, string>(false, string.Format("Email format is wrong - {0}", contact.Email));
        }
        return new Tuple<bool, string>(true, string.Empty);
    }

    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void GetCompetitorsByPrjRowID()
    {
        List<ProjectCompetitor> competitors = new List<ProjectCompetitor>();
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(Context.Request.QueryString.Get("RowID")))
        {
            try
            {
                InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter Prj_C_A = new InterConPrjRegTableAdapters.MY_PRJ_REG_COMPETITORSTableAdapter();
                InterConPrjReg.MY_PRJ_REG_COMPETITORSDataTable dt = Prj_C_A.GetListByPrjRowID(Context.Request.QueryString.Get("RowID"));
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (System.Data.DataRow dr in dt.Rows)
                    {
                        var row = (InterConPrjReg.MY_PRJ_REG_COMPETITORSRow)dr;
                        ProjectCompetitor competitor = new ProjectCompetitor();
                        competitor.Row_ID = row.ROW_ID;
                        competitor.Prj_Row_ID = row.PRJ_ROW_ID;
                        competitor.Competitor_Name = row.COMPETITOR_NAME;
                        competitor.Model_No = row.MODEL_NO;
                        competitor.Selling_Price = row.SELLING_PRICE.ToString();
                        competitor.Remark = row.REMARK;
                        competitors.Add(competitor);
                    }
                    //Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(competitors));
                }
            }
            catch
            {
                
            }
        }
        Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(competitors));
        Context.Response.End();
    }

    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void DeleteCompetitor(string RowID)
    {
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(RowID))
        {
            try
            {
                dbUtil.dbExecuteNoQuery("MYLOCAL", string.Format("Delete from MY_PRJ_REG_COMPETITORS where ROW_ID = '{0}'", RowID.Trim()));
            }
            catch
            {

            }
        }
        Context.Response.Write(string.Empty);
        Context.Response.End();
    }

    [WebMethod(EnableSession = true)]
    [System.Web.Script.Services.ScriptMethod(UseHttpGet = true, ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public void UpdateCompetitor(string PrjRowID, string JsonData)
    {
        if (Context.User.Identity.IsAuthenticated == true && !string.IsNullOrEmpty(PrjRowID) && !string.IsNullOrEmpty(JsonData) && Context.Session["COMPANY_CURRENCY"] != null)
        {
            try
            {
                List<ProjectCompetitor> competitors = Newtonsoft.Json.JsonConvert.DeserializeObject<List<ProjectCompetitor>>(JsonData);
                Tuple<bool, string> result = this.CheckCompetitor(competitors);
                if (result.Item1 == true)
                {
                    System.Data.DataTable oldDt = dbUtil.dbGetDataTable("MYLOCAL", string.Format("select COMPETITOR_NAME, MODEL_NO, SELLING_PRICE, REMARK from MY_PRJ_REG_COMPETITORS where PRJ_ROW_ID = '{0}'", PrjRowID.Trim()));
                    dbUtil.dbExecuteNoQuery("MYLOCAL", string.Format("Delete from MY_PRJ_REG_COMPETITORS where PRJ_ROW_ID = '{0}'", PrjRowID.Trim()));
                    System.Text.StringBuilder sql = new System.Text.StringBuilder();
                    string currency = Context.Session["COMPANY_CURRENCY"].ToString();
                    foreach (var competitor in competitors)
                    {
                        decimal price = 0m;
                        decimal.TryParse(competitor.Selling_Price, out price);
                        competitor.Row_ID = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                        competitor.Prj_Row_ID = PrjRowID;
                        sql.AppendFormat("Insert into MY_PRJ_REG_COMPETITORS values ('{0}', '{1}', '{2}', '{3}', {4}, '{5}', '{6}', '{7}', GETDATE(), '{7}', GETDATE());", competitor.Row_ID, competitor.Prj_Row_ID, competitor.Competitor_Name, competitor.Model_No, price, currency, competitor.Remark, Context.User.Identity.Name);
                    }
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql.ToString());

                    System.Web.UI.WebControls.GridView gv1 = new System.Web.UI.WebControls.GridView();
                    gv1.DataSource = oldDt.DefaultView;
                    gv1.DataBind();
                    System.Text.StringBuilder stringBuilder = new System.Text.StringBuilder();
                    System.IO.StringWriter stringWrite = new System.IO.StringWriter(stringBuilder);
                    System.Web.UI.HtmlTextWriter htmlWrite = new System.Web.UI.HtmlTextWriter(stringWrite);
                    gv1.RenderControl(htmlWrite);

                    InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter masterAdapter = new InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter();
                    InterConPrjReg.MY_PRJ_REG_MASTERRow master = (InterConPrjReg.MY_PRJ_REG_MASTERRow)masterAdapter.GetDataByRowID(PrjRowID).Rows[0];
                    decimal totalamount = InterConPrjRegUtil.GetTotalAmountByID(PrjRowID);
                    string stage = string.Empty;
                    object obj = dbUtil.dbExecuteScalar("CRMAPPDB", string.Format("select top 1 a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='{0}'", master.PRJ_OPTY_ID));
                    if (obj != null)
                        stage = obj.ToString();
                    string cpName = string.Empty;
                    obj = dbUtil.dbExecuteScalar("MY", string.Format("select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID='{0}'", master.CP_ACCOUNT_ROW_ID));
                    if (obj != null)
                        cpName = obj.ToString();
                    stringBuilder.Insert(0, "<br /><br /><span style='color: blue;'>[Before Change]</span><br /><br />");
                    stringBuilder.Insert(0, String.Format("Project Competitor has been updated by {0} on {1}.<br />CP name: {2}<br />ERP ID: {3}<br />Project Name: {4}<br />Stage: {5}<br />Total amount: {6}<br />Estimated closed date: {7}<br />", HttpContext.Current.User.Identity.Name, DateTime.Now.ToString("yyyy/MM/dd"), cpName, master.CP_COMPANY_ID, master.PRJ_NAME, stage, totalamount, master.PRJ_EST_CLOSE_DATE.ToString("yyyy/MM/dd")));
                    string html = stringBuilder.ToString();
                    stringBuilder.Clear();
                    gv1.DataSource = competitors.Select(p => new { COMPETITOR_NAME = p.Competitor_Name, MODEL_NO = p.Model_No, SELLING_PRICE = p.Selling_Price, REMARK = p.Remark });
                    gv1.DataBind();
                    gv1.RenderControl(htmlWrite);
                    stringBuilder.Insert(0, "<br /><br /><span style='color: blue;'>[After Change]</span><br /><br />");

                    html += stringBuilder.ToString();

                    InterConPrjRegUtil.Sendmail(PrjRowID, "A Project registration competitor data has been updated by " + HttpContext.Current.User.Identity.Name, -2, html);

                    InterConPrjRegUtil.update_Siebel(PrjRowID, "", 0m, "", "", "", competitors.FirstOrDefault().Competitor_Name);
                    Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(competitors));
                }
            }
            catch
            {
                Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(string.Empty));
            }
        }
        else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(string.Empty));
        Context.Response.End();
    }

    public Tuple<bool, string> CheckCompetitor(List<ProjectCompetitor> competitors)
    {
        foreach (var competitor in competitors)
        {
            decimal price = 0m;
            if (!string.IsNullOrEmpty(competitor.Selling_Price) && decimal.TryParse(competitor.Selling_Price, out price) == false)
                return new Tuple<bool, string>(false, "Selling price error.");
        }
        return new Tuple<bool, string>(true, string.Empty);
    }
}

[Serializable]
public class ProjectContact
{
    [Newtonsoft.Json.JsonProperty("rowID")]
    public string Row_ID { get; set; }
    
    [Newtonsoft.Json.JsonProperty("projectID")]
    public string Prj_Row_ID { get; set; }
    
    [Newtonsoft.Json.JsonProperty("lastname")]
    public string Last_Name { get; set; }
    
    [Newtonsoft.Json.JsonProperty("firstname")]
    public string First_Name { get; set; }
    
    [Newtonsoft.Json.JsonProperty("email")]
    public string Email { get; set; }
    
    [Newtonsoft.Json.JsonProperty("tel")]
    public string Tel { get; set; }
}

[Serializable]
public class ProjectCompetitor
{
    [Newtonsoft.Json.JsonProperty("rowID")]
    public string Row_ID { get; set; }

    [Newtonsoft.Json.JsonProperty("projectID")]
    public string Prj_Row_ID { get; set; }

    [Newtonsoft.Json.JsonProperty("competitorname")]
    public string Competitor_Name { get; set; }

    [Newtonsoft.Json.JsonProperty("modelno")]
    public string Model_No { get; set; }

    [Newtonsoft.Json.JsonProperty("sellingprice")]
    public string Selling_Price { get; set; }

    [Newtonsoft.Json.JsonProperty("remark")]
    public string Remark { get; set; }
}