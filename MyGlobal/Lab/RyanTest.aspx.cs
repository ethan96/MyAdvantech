using Sgml;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

public partial class Lab_RyanTest : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //List<Advantech.Myadvantech.DataAccess.SO_HEADER> sh = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetSoHeader();
            //this.GridView1.DataSource = sh;
            //this.GridView1.DataBind();
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetWSResult(String SO)
    {
        String errMsg = "";
        Advantech.Myadvantech.DataAccess.CPTEST.general cp = new Advantech.Myadvantech.DataAccess.CPTEST.general();
        return cp.GetNotifyEmailHtmlStr(SO, ref errMsg);
    }

    protected void btn_Convert2Order_Click(object sender, EventArgs e)
    {
        String QuoteID = "e9443f0dc311415", USER = "", COMPANY = "T04956189", ORG = "";
        Response.Redirect(String.Format("http://172.20.1.30:4002/ORDER/Quote2CartV3.ASPX?UID={0}&USER={1}&COMPANY={2}&ORG={3}", QuoteID, USER, HttpUtility.UrlEncode(COMPANY), ORG));
    }


    protected void btn_test_Click(object sender, EventArgs e)
    {
        //Byte[] byteArray = (Byte[]) dbUtil.dbExecuteScalar("MY", String.Format("SELECT top 1 FileData FROM InterconUploadedFile where cart_id = '{0}'", "4711B25F6B424BCD9A037B54A9F306DA"));


        //DataTable dt = dbUtil.dbGetDataTable("MY", String.Format("SELECT top 1 * FROM InterconUploadedFile where cart_id = '{0}'", "518153DE25754E03AA8A028831B17507"));
        //if (dt != null && dt.Rows.Count > 0)
        //{
        //    String FileName = dt.Rows[0]["FileName"].ToString();
        //    Byte[] FileData = (Byte[])dt.Rows[0]["FileData"];
        //    System.IO.Stream Stream = new MemoryStream(FileData);

        //    //Advantech.Myadvantech.DataAccess.Common.SendMailUtil.SendMail("yl.huang@advantech.com.tw", "yl.huang@advantech.com.tw", "", "", "Test", "test", true, FileData, FileName);
        //    MailUtil.SendEmailV2("yl.huang@advantech.com.tw", "yl.huang@advantech.com.tw", "", "", "test", "", "test", "", Stream, FileName);
        //}

    }
}