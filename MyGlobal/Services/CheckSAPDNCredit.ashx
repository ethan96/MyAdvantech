<%@ WebHandler Language="C#" Class="CheckSAPDNCredit" %>

using System;
using System.Text;
using System.Web;
using Advantech.Myadvantech.Business;
using System.Linq;
using System.Collections.Generic;
using Newtonsoft.Json;

public class CheckSAPDNCredit : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        var result = new {
            isAuthorized = true
        };
        if(context.Request["DN"] !=null)
        {
            try
            {
                string dnNo = context.Request["DN"];
                StringBuilder sb = new StringBuilder();
                sb.AppendFormat("Select vgbel as SoNo From saprdp.LIPS where mandt ='168'  and vbeln= '{0}' group by vgbel", dnNo);
                string conn = "SAP_PRD";
                if (Util.IsTesting())
                    conn = "SAP_Test";

                var dtRelatedSO = OraDbUtil.dbGetDataTable(conn, sb.ToString());


                if (dtRelatedSO != null && dtRelatedSO.Rows.Count > 0)
                {
                    var unsettledResult = AuthorizeNetSolution.GetUnsettledList(Util.IsTesting());
                    var unsettledOrderNoList = unsettledResult.TransactionRecords.Where(r=>r.Status=="authorizedPendingCapture").Select(r => r.OrderNo).ToList();
                    foreach (System.Data.DataRow row in dtRelatedSO.Rows)
                    {
                        var relatedSO = row["SoNo"].ToString();
                        if (!unsettledOrderNoList.Contains(relatedSO))
                        {
                            result = new {
                                isAuthorized = false
                            };
                            //context.Response.ContentType = "text/plain";
                            //context.Response.Clear();
                            //context.Response.Write("0");
                            //context.Response.End();
                        }
                    }

                }
            }
            catch { }

        }

        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.ContentType = "application/json";
        context.Response.Write(JsonConvert.SerializeObject(result));
        //context.Response.Clear();
        //context.Response.ContentType = "text/plain";
        //context.Response.Write("1");
        //context.Response.End();
    }

    public bool IsReusable {
        get {
            return false;
        }
    }



}