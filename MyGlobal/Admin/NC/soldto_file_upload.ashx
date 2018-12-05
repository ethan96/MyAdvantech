<%@ WebHandler Language="C#" Class="soldto_cert_upload" %>

using System;
using System.Web;

public class soldto_cert_upload : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        var jsr = new System.Web.Script.Serialization.JavaScriptSerializer();
        var UpdResList = new System.Collections.Generic.List<UploadResponse>();
        var UploadResponse1 =new UploadResponse();
        UpdResList.Add(UploadResponse1);
        if (context.Request.Files.Count > 0 && context.Request.Files[0].ContentLength>0) {
            var ApplicationId = context.Request["appid"].ToString();
            HttpPostedFile file = context.Request.Files[0];
            var FileExt = System.IO.Path.GetExtension(file.FileName).ToLower();
            if (file.ContentLength >= 30 * 1024 * 1024 ||
                    (FileExt!=".doc" && FileExt!=".docx" && FileExt!=".pdf" && FileExt!=".zip" && FileExt!=".rar" && FileExt!=".7z"))
            {
                UploadResponse1.ErrorString =
                        "File size cannot be more than 30M, and file name must ends with .doc, .docx, .pdf, or compressed file";
            }
            else {
                UploadResponse1.IsUploaded = true; UploadResponse1.FileId = Guid.NewGuid().ToString().Replace("-","").Substring(0,5);
                UploadResponse1.FileName = file.FileName;

                var insertFileCmd = new System.Data.SqlClient.SqlCommand(
                    @"
                        INSERT INTO [dbo].[NEW_SAP_ACCOUNT_HQ_FILES]
                           ([ApplicationId]
                           ,[FileId]
                           ,[FILE_CONTENT]
                           ,[FILE_NAME]
                           ,[FILE_EXT]
                           ,[UPLOADED_DATE]
                           ,[UPLOADED_BY])
                        VALUES
                           (@APPID,@FILEID,@FILEBIN,@FILENAME,@FILEEXT,getdate(),@UID)
                        ");
                insertFileCmd.Parameters.AddWithValue("APPID", ApplicationId);
                insertFileCmd.Parameters.AddWithValue("FILEID", UploadResponse1.FileId);
                insertFileCmd.Parameters.AddWithValue("FILEBIN",GetStreamAsByteArray(file.InputStream));
                insertFileCmd.Parameters.AddWithValue("FILENAME", UploadResponse1.FileName);
                insertFileCmd.Parameters.AddWithValue("FILEEXT", FileExt);
                insertFileCmd.Parameters.AddWithValue("UID", HttpContext.Current.User.Identity.Name);
                var insertFileConn = new System.Data.SqlClient.SqlConnection(
                    System.Configuration.ConfigurationManager.ConnectionStrings["MY_EC2"].ConnectionString);
                insertFileCmd.Connection = insertFileConn;
                insertFileConn.Open();insertFileCmd.ExecuteNonQuery();insertFileConn.Close();
            }
        }
        if (context.Request.Files.Count > 0 && context.Request.Files[0].ContentLength == 0) {           
            UploadResponse1.IsUploaded = true;
        }
        context.Response.Clear(); context.Response.Write(jsr.Serialize(UpdResList)); context.Response.End();
    }

    public class UploadResponse {
        public string ErrorString { get; set; }
        public bool IsUploaded { get; set; }
        public string FileId { get; set; }
        public string FileName { get; set; }
        public UploadResponse() {
            ErrorString = ""; IsUploaded = false; FileId = ""; FileName = "";
        }
    }

    public static byte[] GetStreamAsByteArray(System.IO.Stream stream)
    {
        int streamLength = Convert.ToInt32(stream.Length);
        byte[] fileData = new byte[streamLength + 1];
        stream.Read(fileData, 0, streamLength);
        stream.Close();
        return fileData;
    }
    public bool IsReusable {
        get {
            return false;
        }
    }

}