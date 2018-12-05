<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataTable dt = dbUtil.dbGetDataTable("MyLocal", string.Format("select  top 1 isnull(EXMSG,'') as  MSG  from  MY_ERR_LOG where ROW_ID ='{0}'", Request["Rowid"]));
                    if (dt.Rows.Count ==1)
                    {
                      LitError.Text= dt.Rows[0]["MSG"].ToString().Trim();
                    }
                    if (Page.Request.UrlReferrer != null)
                    {
                        Areturn.HRef = Page.Request.UrlReferrer.ToString();
                        Areturn.Visible = true;
                    }
        }

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family:  arial, helvetica, sans-serif;
            line-height: 1.5;
            color: #3c3c3c;
        }

        .err {
            width: 800px;
          padding:10px 15px 10px 20px;
            margin: 0;
            margin-top: 10%;
            font-size: 108%;
            position: static;
            margin-bottom: 10px;
            border: 1px solid #ff6600;
            background: #f7f3e8;
        }

            .err span {
                word-wrap: break-word;
                word-break: break-all;
                display: block;
                width: 100%;
                white-space: normal;
                color: #ff6600;
                font-size: 122%;
                font-weight: bold;
            }
        .ra {   text-decoration: underline;        font-size: 122%;           color: #ff6600;
                font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
   
            <table width="800" border="0" align="center">
  <tr>
    <td align="left">
<img src="Images/logo2.jpg" alt="" style="border-width:0px;">
    </td>
  </tr>
  <tr>
    <td align="left">
          <div class="err">
                <span> 
              <asp:Literal ID="LitError" runat="server"></asp:Literal>
                </span>
          </div>
       
    
    </td>
  </tr>
                <tr>
    <td align="center" style="padding-top:10px;">

                <a id="Areturn" runat="server"   class="ra" visible="false"><strong>Return</strong></a>

    </td></tr>
</table>

    </form>
</body>
</html>
