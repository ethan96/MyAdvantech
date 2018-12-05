<%@ WebHandler Language="C#" Class="soldto_cert_upload" %>

using System;
using System.Web;

public class soldto_cert_upload : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        var jsr = new System.Web.Script.Serialization.JavaScriptSerializer();
        var UpdResList = new System.Collections.Generic.List<UploadResponse>();
        if (context.Request.Files.Count > 0) {
            HttpPostedFile file = context.Request.Files[0]; var UploadResponse1 =new UploadResponse();
            var FileExt = System.IO.Path.GetExtension(file.FileName).ToLower();
            if (file.ContentLength >= 30 * 1024 * 1024 || (FileExt!=".doc" && FileExt!=".docx" && FileExt!=".pdf"))
            {
                UploadResponse1.ErrorString = "File size cannot be more than 30M, and file name must ends with .doc, .docx or .pdf";
            }
            else {
                UploadResponse1.IsUploaded = true; UploadResponse1.FileId = Guid.NewGuid().ToString().Replace("-","");
                UploadResponse1.FileName = file.FileName;

                var insertFileCmd = new System.Data.SqlClient.SqlCommand(
                    @"
                        INSERT INTO [dbo].[SAP_ACCOUNT_FILES]
                           ([DOC_ID]
                           ,[COMPANY_ID]
                           ,[FILE_CONTENT]
                           ,[FILE_NAME]
                           ,[FILE_EXT]
                           ,[FILE_CREATEDBY]
                           ,[FILE_CREATEDDATE])
                        VALUES
                           (@FILEID,'',@FILEBIN,@FILENAME,@FILEEXT,@UID,getdate())
                        ");
                insertFileCmd.Parameters.AddWithValue("FILEID", UploadResponse1.FileId);
                insertFileCmd.Parameters.AddWithValue("FILEBIN",GetStreamAsByteArray(file.InputStream));
                insertFileCmd.Parameters.AddWithValue("FILENAME", UploadResponse1.FileName);
                insertFileCmd.Parameters.AddWithValue("FILEEXT", FileExt);
                insertFileCmd.Parameters.AddWithValue("UID", HttpContext.Current.User.Identity.Name);
                var insertFileConn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["MY"].ConnectionString);
                insertFileCmd.Connection = insertFileConn;
                insertFileConn.Open();insertFileCmd.ExecuteNonQuery();insertFileConn.Close();
            }

            UpdResList.Add(UploadResponse1);
            context.Response.Clear(); context.Response.Write(jsr.Serialize(UpdResList)); context.Response.End();
        }
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