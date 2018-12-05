<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Context.User.Identity.IsAuthenticated == false)
            Response.Redirect(Request.ApplicationPath);

        if (DateTime.Now.Year > 2017 && DateTime.Now.Month > 1)
            Response.Redirect(Request.ApplicationPath);
        
        if (MailUtil.IsInRole2("MyAdvantech", Context.User.Identity.Name) == false &&
            Context.User.Identity.Name.Equals("Amber.Chen@advantech.com.tw", StringComparison.InvariantCultureIgnoreCase) == false)
            Response.Redirect(Request.ApplicationPath);

        lbText.Text = string.Empty;
    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        try
        {
            System.Data.DataTable dt = dbUtil.dbGetDataTable("CP", string.Format(@"SELECT EMAIL,LAST_NAME,FIRST_NAME,TEL,ACCOUNT_NAME,COUNTRY, [INTPROD] AS [INT_PRODUCT],
                [TIMESTAMP] AS [REGI_TIME], [STATE], [CITY], [ADDRESS], [ZIPCODE] 
                FROM CURATION_ACTIVITY_IMPORTED_LOG 
                WHERE [URL] like '%utm_source=fb&utm_medium=banner&utm_campaign=estore%' 
                ORDER BY [TIMESTAMP]"));
            if (dt != null && dt.Rows.Count > 0)
            {
                System.IO.MemoryStream ms = Advantech.Myadvantech.DataAccess.ExcelUtil.DataTableToMemoryStream(dt);
                Response.AddHeader("Content-Disposition", string.Format("attachment; filename=eStoreRegistration_{0}.xlsx", DateTime.Now.ToString("yyyy_MM_dd")));
                Response.BinaryWrite(ms.ToArray());
                ms.Close();
                ms.Dispose();
            }
            else
                lbText.Text = "No data!";
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            lbText.Text = ex.ToString();
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <div>
        <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" /><br />
        <asp:Label ID="lbText" runat="server" ForeColor="Tomato"></asp:Label>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

