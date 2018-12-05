<%@ WebHandler Language="C#" Class="dl_soldto_cert" %>

using System;
using System.Web;

public class dl_soldto_cert : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        if (context.Request["fid"] != null && context.Request["appid"] != null) {
            var fileApt = new System.Data.SqlClient.SqlDataAdapter(
                @"select FILE_NAME, FILE_EXT, FILE_CONTENT 
                    from NEW_SAP_ACCOUNT_HQ_FILES where ApplicationId=@APPID and FileId=@FID",
                System.Configuration.ConfigurationManager.ConnectionStrings["MY_EC2"].ConnectionString);
            fileApt.SelectCommand.Parameters.AddWithValue("APPID", context.Request["appid"].ToString().Trim());
            fileApt.SelectCommand.Parameters.AddWithValue("FID", context.Request["fid"].ToString().Trim());
            var dtFileInfo = new System.Data.DataTable();
            fileApt.Fill(dtFileInfo);
            fileApt.SelectCommand.Connection.Close();
            if (dtFileInfo.Rows.Count > 0) {
                    System.Data.DataRow drFileInfo = dtFileInfo.Rows[0];
                context.Response.Clear();
                context.Response.Buffer = true;
                context.Response.AddHeader("content-disposition", 
                    String.Format("attachment;filename={0}", System.IO.Path.GetFileName(drFileInfo["FILE_NAME"].ToString())));
                context.Response.ContentType = "application/" + System.IO.Path.GetExtension(drFileInfo["FILE_NAME"].ToString()).Substring(1);
                context.Response.BinaryWrite((byte[])drFileInfo["FILE_CONTENT"]);
                context.Response.End();
            }
            
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}