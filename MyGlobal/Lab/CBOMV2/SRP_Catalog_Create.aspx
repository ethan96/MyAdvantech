<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.IsAuthenticated == false)
            Response.Redirect(string.Format("{0}home.aspx?ReturnUrl=/Lab/CBOMV2/SRP_Catalog_Create.aspx", Request.ApplicationPath));

        if (this.IsAdmin == false)
            Response.Redirect(Request.ApplicationPath);
        
        this.lbMsg.Text = string.Empty;
        
        if (!Page.IsPostBack)
        {
            //ICC 2017/3/20 Only use TW org to create catalog & category tree
            //string orgid = Session["ORG_ID"].ToString().ToUpper().Substring(0, 2);
            //lbOrg.Text = "SRP-Catalog maintenance, ORG: " + orgid;
            lbOrg.Text = "SRP-Catalog maintenance";
            lbMsg.Text = string.Empty;
            BindrpSRP();
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtStandardPartno.Text))
        {
            lbMsg.Text = "Please check all input fields are maintained.";
            return;
        }

        //string orgid = Session["ORG_ID"].ToString().ToUpper().Substring(0, 2);
        string orgid = "TW";
        object count = dbUtil.dbExecuteScalar("CBOMV2", string.Format("SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 WHERE CATEGORY_ID = '{0}' AND ORG = '{1}' ", txtStandardPartno.Text.Trim(), orgid));
        if (count != null && Convert.ToInt32(count) > 0)
        {
            lbMsg.Text = string.Format("This part: {0} has been already maintained in SRP catalog!", txtStandardPartno.Text);
            return;
        }
        
        // need to create 7 nodes: 1.BTOS root, 2.Default, 3.Option, 4. four default category under Default
        String root_guid = String.Empty;
        //String Btos_Name = txtBTO.Text.Trim();
        String Standard_PartName = txtStandardPartno.Text.Trim();

        try
        {
            //1. Create BTOS roots
            root_guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            //String Category_Name = txtBTO.Text;
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(orgid + "_SRP", root_guid, Standard_PartName, 0, Standard_PartName, 1, 0, orgid, "", 1, 0, 0, 0);

            //2. Create Default, Standard_PartName will save in default's description
            String default_guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(root_guid, default_guid, "SRP-Default", 0, Standard_PartName, 1, 0, orgid, "", 1, 0, 0, 0);

            //3. Create Option
            String option_guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(root_guid, option_guid, "SRP-Option", 0, "", 2, 0, orgid, "", 1, 0, 0, 0);

            //4. Four default category under SRP-Default
            String guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(default_guid, guid, "Application Software", 1, "Application Software", 1, 0, orgid, "", 1, 0, 0, 0);

            guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(default_guid, guid, "System Computing", 1, "System Computing", 2, 0, orgid, "", 1, 0, 0, 0);

            guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(default_guid, guid, "Operating System", 1, "Operating System", 3, 0, orgid, "", 1, 0, 0, 0);

            guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(default_guid, guid, "Peripherals", 1, "Peripherals", 4, 0, orgid, "", 1, 0, 0, 0);

            //5. Four option category unser SRP-Option
            String opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Option 100 WISE-PaaS/SaaS Software", 1, "Option 100 WISE-PaaS/SaaS Software", 1, 100, orgid, "", 1, 0, 0, 0);

            opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Option 200 System Computing", 1, "Option 200 System Computing", 2, 200, orgid, "", 1, 0, 0, 0);

            opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Option 300 I/O & Peripherals", 1, "Option 300 I/O & Peripherals", 3, 300, orgid, "", 1, 0, 0, 0);

            opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Option 400 Add-on Accessories", 1, "Option 400 Add-on Accessories", 4, 400, orgid, "", 1, 0, 0, 0);

            opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Option 800 Training & Consulting Service", 1, "Option 800 Training & Consulting Service", 5, 800, orgid, "", 1, 0, 0, 0);

            opt = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.CreateNew(option_guid, opt, "Remark", 1, "Remark", 6, -1, orgid, "", 1, 0, 0, 0);
            
            Response.Redirect(string.Format("SRP_Catalog_Category.aspx?ID={0}", root_guid));
        }
        catch (Exception ex)
        {
            this.lbMsg.Text = ex.ToString();
        }
    }

    protected void rpSRP_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "Delete")
        {
            try
            {
                string guid = e.CommandArgument.ToString();
                StringBuilder sb = new StringBuilder();
                sb.AppendFormat(" DECLARE @ID  hierarchyid SELECT @ID  = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}' ", guid);
                sb.Append(" DELETE FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1;");
                dbUtil.dbExecuteNoQuery("CBOMV2", sb.ToString());
            }
            catch (Exception ex)
            {
                this.lbMsg.Text = ex.ToString();
            }
            BindrpSRP();
        }
        else if (e.CommandName == "Rename")
        {
            ((ImageButton)e.Item.FindControl("btn_rename")).Visible = false;
            ((ImageButton)e.Item.FindControl("btn_update")).Visible = true;
            ((ImageButton)e.Item.FindControl("btn_cancel")).Visible = true;

            ((Label)e.Item.FindControl("lbCategoryName")).Visible = false;
            ((TextBox)e.Item.FindControl("txtCategoryName")).Visible = true;
        }
        else if (e.CommandName == "Update")
        {
            ((ImageButton)e.Item.FindControl("btn_rename")).Visible = true;
            ((ImageButton)e.Item.FindControl("btn_update")).Visible = false;
            ((ImageButton)e.Item.FindControl("btn_cancel")).Visible = false;

            ((Label)e.Item.FindControl("lbCategoryName")).Visible = true;
            ((TextBox)e.Item.FindControl("txtCategoryName")).Visible = false;

            string guid = e.CommandArgument.ToString();
            string categoryname = ((TextBox)e.Item.FindControl("txtCategoryName")).Text;

            if (!string.IsNullOrEmpty(categoryname))
            {
                String str = "update CBOM_CATALOG_CATEGORY_V2 set Category_ID = N'" + categoryname + "' where ID = N'" + guid + "'";
                dbUtil.dbExecuteNoQuery("CBOMV2", str);
                BindrpSRP();
            }
        }
        else if (e.CommandName == "Cancel")
        {
            ((ImageButton)e.Item.FindControl("btn_rename")).Visible = true;
            ((ImageButton)e.Item.FindControl("btn_update")).Visible = false;
            ((ImageButton)e.Item.FindControl("btn_cancel")).Visible = false;

            ((Label)e.Item.FindControl("lbCategoryName")).Visible = true;
            ((TextBox)e.Item.FindControl("txtCategoryName")).Visible = false;
        }
    }

    public void BindrpSRP()
    {
        //string orgid = Session["ORG_ID"].ToString().ToUpper().Substring(0, 2);
        //rpSRP.DataSource = dbUtil.dbGetDataTable("CBOMV2", string.Format("DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}_SRP' SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child", orgid));
        rpSRP.DataSource = dbUtil.dbGetDataTable("CBOMV2", "DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = 'TW_SRP' SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child");
        rpSRP.DataBind();
    }

    private bool? isadmin;
    public bool? IsAdmin
    {
        get
        {
            if (this.isadmin.HasValue == false)
            {
                if (Util.IsMyAdvantechIT() == true)
                    this.isadmin = true;
                else
                {
                    var obj = dbUtil.dbExecuteScalar("MY", string.Format("SELECT COUNT(*) FROM CTOSADMIIN_SRP WHERE USERID = '{0}'", Context.User.Identity.Name));
                    if (obj != null && Convert.ToInt32(obj.ToString()) > 0)
                        this.isadmin = true;
                    else
                        this.isadmin = false;
                }
            }
            return this.isadmin;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
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
            display: inline-block;
            vertical-align: bottom;
        }

        ul.token-input-list-facebook li input {
            border: 0;
            padding: 3px 8px;
            background-color: white;
            margin: 2px 0;
            -webkit-appearance: caret;
            width: 240px;
        }
    </style>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(function () {
            //$("#<%=txtBTO.ClientID%>").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputBTOSPartNo", {
            //    theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type BTOS Name", tokenLimit: 1, preventDuplicates: false, resizeInput: false,
            //    onAdd: function (data) {
            //        $("#<%=txtBTO.ClientID%>").val(data.name);
            //    },
            //    onDelete: function (data) {
            //        $("#<%=txtBTO.ClientID%>").val('');
            //    }
            //});

            $("#<%=txtStandardPartno.ClientID%>").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type Part No.", tokenLimit: 1, preventDuplicates: false, resizeInput: false,
                onAdd: function (data) {
                    $("#<%=txtStandardPartno.ClientID%>").val(data.name);
                },
                onDelete: function (data) {
                    $("#<%=txtStandardPartno.ClientID%>").val('');
                }
            });
        });
    </script>
    <div>
        <asp:Label ID="lbOrg" runat="server" ForeColor="black" Font-Size="Large" Font-Bold="true"></asp:Label>
    </div>
    <div style="height: 15px"></div>
    <div>
        <%--<span>SRP-BTO Part No.:</span>--%>
        <asp:TextBox ID="txtBTO" runat="server" Visible="false"></asp:TextBox>&nbsp;
        <span>SRP Part No.: </span>
        <asp:TextBox ID="txtStandardPartno" runat="server"></asp:TextBox>&nbsp;
        <asp:Button ID="btnCreate" runat="server" Text="Create" OnClick="btnCreate_Click" />&nbsp;
    </div>
    <div style="height: 15px"></div>
    <asp:UpdatePanel ID="upSRP" runat="server">
        <ContentTemplate>
            <div>
                <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato"></asp:Label>
            </div>
            <asp:Repeater ID="rpSRP" runat="server" OnItemCommand="rpSRP_ItemCommand">
                <HeaderTemplate>
                    <table>
                        <thead>
                            <tr>
                                <th>Editor</th>
                                <th>Preview</th>
                                <th>SRP item</th>
                                <% if (this.IsAdmin == true)
                                   { %>
                                <%--<th>Rename</th>--%>
                                <th>Delete</th>
                                <%} %>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td align="center">
                            <a href='<%# string.Format("{0}/Lab/CBOMV2/SRP_Catalog_Category.aspx?ID={1}", Util.GetRuntimeSiteUrl(), Eval("ID")) %>'>Editor</a>
                        </td>
                        <td align="center">
                            <a href='<%# string.Format("{0}/Order/Configurator_SRP.aspx?RootID={1}&QTY=1", Util.GetRuntimeSiteUrl(), Eval("ID")) %>' target="_blank">Preview</a>
                        </td>
                        <td style="width: 150px" align="center">
                            <asp:Label ID="lbCategoryName" runat="server" Text='<%#Eval("CATEGORY_ID") %>'></asp:Label>
                            <asp:TextBox ID="txtCategoryName" runat="server" Text='<%#Eval("CATEGORY_ID") %>' onblur="CheckField(this);" Visible="false"></asp:TextBox>
                        </td>
                        <% if (this.IsAdmin == true)
                           { %>
                        <td align="center" style="display:none;">
                            <asp:ImageButton ID="btn_rename" runat="server" ImageUrl="~/Images/edit.png" CommandName="Rename" CommandArgument='<%#Eval("ID")%>' Enabled="false" />
                            <asp:ImageButton ID="btn_update" runat="server" CommandName="Update" CommandArgument='<%#Eval("ID")%>' ImageUrl="~/Images/12-em-check.png" Visible="false" />&nbsp;
                            <asp:ImageButton ID="btn_cancel" runat="server" CommandName="Cancel" CommandArgument='<%#Eval("ID")  %>' ImageUrl="~/Images/12-em-cross.png" Visible="false" />
                        </td>
                        <td align="center">
                            <asp:ImageButton ID="btn_delete" runat="server" ImageUrl="~/Images/delete.jpg" CommandName="Delete" CommandArgument='<%#Eval("ID")%>' OnClientClick="return confirm('Delete ?')" />
                        </td>
                        <%} %>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                </table>
                </FooterTemplate>
            </asp:Repeater>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger  ControlID="btnCreate"/>
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

