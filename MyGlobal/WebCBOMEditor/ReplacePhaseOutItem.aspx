<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        lbMsg.Text = string.Empty;
        
        if (!Page.IsPostBack)
        {
            if (HttpContext.Current.User == null || !HttpContext.Current.User.Identity.IsAuthenticated)
                Response.Redirect(Request.ApplicationPath);

            if (!(MailUtil.IsInRole("MyAdvantech") || Context.User.Identity.Name.Equals("brian.tsai@advantech.com.tw", StringComparison.OrdinalIgnoreCase)))
                Response.Redirect(Request.ApplicationPath);

            if (Session["ORG_ID"] == null || Session["ORG_ID"].ToString() != "TW01")
                Response.Redirect(Request.ApplicationPath);
            
            ddlOrg.Items.Clear();
            ddlOrg.Items.Add(new ListItem(Session["ORG_ID"].ToString(), Session["ORG_ID"].ToString()));

            ViewState["ReplaceProduct"] = null;
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        InitialRepeater(txtPartNo.Text);
    }

    protected void btnReplace_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtReplace.Text))
        {
            lbMsg.Text = "Please key in part No.";
            return;
        }

        if (ViewState["ReplaceProduct"] == null)
        {
            lbMsg.Text = "Please search component first.";
            return;
        }
        
        try
        {
            List<ReplaceProduct> rps = (List<ReplaceProduct>)ViewState["ReplaceProduct"];
            string org = ddlOrg.SelectedValue.Substring(0, 2).ToUpper();
            StringBuilder sql = new StringBuilder();
            foreach (ReplaceProduct rp in rps)
            {
                //update child first
                string categoryID = rp.Category_ID.Replace(rp.PartNo, txtReplace.Text);
                sql.AppendFormat("update CBOM_CATALOG_CATEGORY set PARENT_CATEGORY_ID = N'{0}' where PARENT_CATEGORY_ID = N'{1}' and ORG = N'{2}' ;", categoryID, rp.Category_ID, org);
                //update component
                sql.AppendFormat("update CBOM_CATALOG_CATEGORY set CATEGORY_ID = N'{0}' where CATEGORY_ID = N'{1}' and PARENT_CATEGORY_ID = N'{2}' and ORG = N'{3}';", categoryID, rp.Category_ID, rp.Parent_Category_ID,org);
            }
            
            dbUtil.dbExecuteNoQuery(Util.IsTesting() ? "MyLocal" : "MY", sql.ToString());
            
            lbMsg.Text = "Success";
            txtPartNo.Text = txtReplace.Text;
            InitialRepeater(txtReplace.Text);
        }
        catch (Exception ex)
        {
            lbMsg.Text = "Error! " + ex.Message;
        }
        
    }

    private void InitialRepeater(string newPartNo)
    {
        if (string.IsNullOrEmpty(newPartNo))
        {
            rpReplace.DataSource = null;
            rpReplace.DataBind();
            ViewState["ReplaceProduct"] = null;
            lbMsg.Text = "Can not be empty";
            return;
        }

        string org = ddlOrg.SelectedValue.Substring(0, 2).ToUpper();
        StringBuilder sql = new StringBuilder();
        sql.Append("select distinct top 999 CATEGORY_ID, Parent_Category_ID from CBOM_CATALOG_CATEGORY where CATEGORY_TYPE= 'Component' ");
        sql.AppendFormat("and PARENT_CATEGORY_ID <>'Root'  and ORG= '{0}' and CATEGORY_ID <> 'No Need' and CATEGORY_ID like '%{1}%' ", org, newPartNo.Trim());
        DataTable dt = dbUtil.dbGetDataTable(Util.IsTesting() ? "MyLocal" : "MY", sql.ToString());

        if (dt == null || dt.Rows.Count == 0)
        {
            rpReplace.DataSource = null;
            rpReplace.DataBind();
            ViewState["ReplaceProduct"] = null;
            lbMsg.Text = "This part does not under any category";
            return;
        }

        List<SAPDAL.ProductX> products = new List<SAPDAL.ProductX>();
        foreach (DataRow dr in dt.Rows)
        {
            string[] parts = dr[0].ToString().Split('|');
            foreach (string part in parts)
            {
                if (part.IndexOf(newPartNo) < 0) continue;
                SAPDAL.ProductX product = new SAPDAL.ProductX();
                product.PartNo = part;
                product.ORG = org;
                products.Add(product);
            }
        }
        SAPDAL.ProductX p = new SAPDAL.ProductX();
        bool flag = true;
        p.GetProductInfo(products, org, ref flag);

        List<ReplaceProduct> rps = new List<ReplaceProduct>();
        foreach (DataRow dr in dt.Rows)
        {
            string[] parts = dr[0].ToString().Split('|');
            foreach (string part in parts)
            {
                if (part.IndexOf(newPartNo) < 0) continue;
                SAPDAL.ProductX x = products.Where(c => c.PartNo == part).FirstOrDefault();
                if (x != null)
                {
                    ReplaceProduct rp = new ReplaceProduct();
                    rp.Category_ID = dr[0].ToString();
                    rp.Parent_Category_ID = dr[1].ToString();
                    rp.PartNo = x.PartNo;
                    rp.ORG = x.ORG;
                    rp.PhaseOut = x.IsPhaseOut == true ? "No" : "Yes";
                    rps.Add(rp);
                }
            }
        }

        if (rps.Count > 0) ViewState["ReplaceProduct"] = rps;
        rpReplace.DataSource = rps;
        rpReplace.DataBind();
    }
    
    [Serializable]
    public class ReplaceProduct
    {
        public string PartNo { get; set; }
        public string ORG { get; set; }
        public string Category_ID { get; set; }
        public string Parent_Category_ID { get; set; }
        public string PhaseOut { get; set; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <style type="text/css">
        ul.token-input-list-facebook {
            overflow: hidden;
            height: auto !important;
            height: 1%;
            border: 1px solid #8496ba;
            cursor: text;
            font-size: 12px;
            font-family: Verdana;
            min-height: 1px;
            z-index: 999;
            margin: 0;
            padding: 0;
            background-color: #fff;
            list-style-type: none;
            clear: left;
            width: 200px;
        }

            ul.token-input-list-facebook li input {
                border: 0;
                padding: 3px 8px;
                background-color: white;
                margin: 2px 0;
                -webkit-appearance: caret;
                width: 200px;
            }
    </style>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(function () {
            $("#<%=txtPartNo.ClientID%>").attr("autocomplete", "off");

            $("#<%=txtReplace.ClientID%>").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type Part No.", tokenLimit: 1, preventDuplicates: true, resizeInput: false,
                onAdd: function (data) {
                    $("#<%=txtReplace.ClientID%>").val(data.name);
                }
            });
        });
    </script>
    <table style="width: 100%">
        <tr>
            <td>
                <asp:DropDownList ID="ddlOrg" runat="server"></asp:DropDownList>
                <asp:TextBox ID="txtPartNo" runat="server"></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />&nbsp;
                <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                <div><asp:TextBox ID="txtReplace" runat="server"></asp:TextBox></div>
                <asp:Button ID="btnReplace" runat="server" Text="Replace" OnClick="btnReplace_Click" OnClientClick="return confirm('Are you sure to replace this part?');" />
            </td>
        </tr>
    </table>
    <asp:Repeater ID="rpReplace" runat="server">
        <HeaderTemplate>
            <table>
                <thead>
                    <tr>
                        <th style="width:30%">Component ID</th>
                        <th style="width:40%">Category ID</th>
                        <th style="width:20%">Phased out ?</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                <tr>
                    <td><%# Eval("Category_ID") %></td>
                    <td><%# Eval("Parent_Category_ID") %></td>
                    <td style="text-align:center"><%# Eval("PhaseOut") %></td>
                </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</asp:Content>

