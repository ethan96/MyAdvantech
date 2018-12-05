<%@ WebHandler Language="C#" Class="DlCISFile" %>

using System;
using System.Web;

public class DlCISFile : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {        
        if (context.Request["fname"] != null && context.Request["ftype"] != null) {            
            switch(context.Request["ftype"].ToString().ToUpper()){
                case "DATASHEET":
                    string fp = "\\\\172.20.1.48\\DataSheets\\" + context.Request["fname"];
                    if (System.IO.File.Exists(fp) == false) {                                                                        
                                fp = "\\\\172.20.1.48\\Advansus\\Datasheets\\" + context.Request["fname"];                    
                    }
                    if (System.IO.File.Exists(fp)) {
                        Byte[] bs = System.IO.File.ReadAllBytes(fp);
                        context.Response.Clear();
                        context.Response.ContentType = "application/pdf";
                        context.Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0};", context.Request["fname"]));
                        context.Response.BinaryWrite(bs);
                        context.Response.End();
                    }
                    
                    break;                    
                case "PICTURES":
                    Byte[] bs2 = System.IO.File.ReadAllBytes("\\\\172.20.1.48\\Pictures\\"+context.Request["fname"]);
                    context.Response.Clear();
                    context.Response.ContentType = "application/jpg";
                    context.Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0};", context.Request["fname"]));
                    context.Response.BinaryWrite(bs2);
                    context.Response.End();
                    break;                    
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}