<%@ WebHandler Language="C#" Class="PriceGradeHandler" %>

using System;
using System.Web;

public class PriceGradeHandler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        if (context.Request["group"] != null)
        {
            string group = context.Request["group"].ToString().Trim();
            if (this.GroupDic.ContainsKey(group))
            {
                System.Data.DataTable dt;
                if (context.Cache["ATW_PriceGrade"] == null)
                {
                    dt = dbUtil.dbGetDataTable("EPRICER", "select distinct NEW_GRADE as GRADE, ORG from New_Grade2 where ORG in ('HQDC','HQDC2') order by NEW_GRADE ");
                    context.Cache.Add("ATW_PriceGrade", dt, null, DateTime.Now.AddHours(12), System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Default, null);
                }
                else
                    dt = (System.Data.DataTable)context.Cache["ATW_PriceGrade"];
                
                System.Collections.Generic.List<MyGroup> list = new System.Collections.Generic.List<MyGroup>();
                foreach (System.Data.DataRow dr in dt.Select(string.Format("ORG = '{0}'", this.GroupDic[group])))
                {
                    MyGroup mg = new MyGroup();
                    mg.Grade = dr[0].ToString();
                    list.Add(mg);
                }
                context.Response.Clear();
                context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list));
            }
        }
        context.Response.End();
    }

    public class MyGroup
    {
        private string group = string.Empty;
        public string Grade
        {
            get
            {
                return this.group;
            }
            set
            {
                this.group = value;
            }
        }
    }
    
    public System.Collections.Generic.Dictionary<string, string> GroupDic
    {
        get
        {
            System.Collections.Generic.Dictionary<string, string> dic = new System.Collections.Generic.Dictionary<string, string>();
            dic.Add("D1", "HQDC");
            dic.Add("D2", "HQDC2");
            return dic;
        }
    }
    
    public bool IsReusable {
        get
        {
            return false;
        }
    }

}