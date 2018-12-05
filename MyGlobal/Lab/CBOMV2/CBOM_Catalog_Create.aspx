<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    public string Org_ID
    {
        get
        {
            string orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
            if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
                orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);
            return orgid;
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.IsAuthenticated == false)
            Response.Redirect(string.Format("{0}home.aspx?ReturnUrl=/Lab/CBOMV2/CBOM_Catalog_Create.aspx", Request.ApplicationPath));

        if (this.IsAdmin == false)
            Response.Redirect(Request.ApplicationPath);
        
        if (!Page.IsPostBack)
        {
            lbOrg.Text = "ORG: " + this.Org_ID;
            lbMsg.Text = string.Empty;
            rpBTO.DataSource = dbUtil.dbGetDataTable("CBOMV2", string.Format("DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}_BTOS' SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child ORDER BY CATEGORY_ID", this.Org_ID));
            rpBTO.DataBind();
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtBTO.Text))
        {
            lbMsg.Text = "Please enter BTO item.";
            return;
        }

        int count = (int)dbUtil.dbExecuteScalar("CBOMV2", string.Format("DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{1}_BTOS' SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child and CATEGORY_ID = N'{0}' ", txtBTO.Text.Trim(), this.Org_ID));
        if (count > 0)
        {
            lbMsg.Text = string.Format("{0} has already in system.", txtBTO.Text);
            return;
        }

        try
        {
            string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            bool result = this.CreateNew(this.Org_ID + "_BTOS", guid, txtBTO.Text.Trim(), 0, string.Empty, 0, 0, 0, 1, 1, this.Org_ID, string.Empty);
            if (result == true)
                Response.Redirect(string.Format("CBOM_Catalog_Category.aspx?ID={0}", guid));
            else
                lbMsg.Text = "Failed! Please contact MyAdvantech@advantech.com";
        }
        catch (Exception ex)
        {
            lbMsg.Text = ex.ToString();
        }

    }

    public Boolean CreateNew(String _parentid, String _guid, String _categoryid, int _categorytype,
           String _categorynote, int _seq, int _rule, int _reqflag, int _expflag, int _deflag, String _org, String _sharedcategoryid)
    {
        System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["CBOMV2"].ConnectionString);
        System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SP_Insert_CBOM_Category_V2", conn);

        cmd.CommandType = System.Data.CommandType.StoredProcedure;

        cmd.Parameters.Add("@parentID", System.Data.SqlDbType.NVarChar, 30);
        cmd.Parameters["@parentID"].Value = _parentid;

        cmd.Parameters.Add("@guid", System.Data.SqlDbType.NVarChar, 30);
        cmd.Parameters["@guid"].Value = _guid;

        cmd.Parameters.Add("@categoryID", System.Data.SqlDbType.NVarChar, 200);
        cmd.Parameters["@categoryID"].Value = _categoryid;

        cmd.Parameters.Add("@categoryType", System.Data.SqlDbType.Int);
        cmd.Parameters["@categoryType"].Value = _categorytype;

        cmd.Parameters.Add("@categoryNote", System.Data.SqlDbType.NVarChar, 200);
        cmd.Parameters["@categoryNote"].Value = _categorynote;

        cmd.Parameters.Add("@seq", System.Data.SqlDbType.Int);
        cmd.Parameters["@seq"].Value = _seq;

        cmd.Parameters.Add("@rule", System.Data.SqlDbType.Int);
        cmd.Parameters["@rule"].Value = _rule;

        cmd.Parameters.Add("@reqflag", System.Data.SqlDbType.TinyInt);
        cmd.Parameters["@reqflag"].Value = _reqflag;

        cmd.Parameters.Add("@expflag", System.Data.SqlDbType.TinyInt);
        cmd.Parameters["@expflag"].Value = _expflag;

        cmd.Parameters.Add("@deflag", System.Data.SqlDbType.TinyInt);
        cmd.Parameters["@deflag"].Value = _deflag;

        cmd.Parameters.Add("@ORG", System.Data.SqlDbType.NVarChar, 10);
        cmd.Parameters["@ORG"].Value = _org;

        cmd.Parameters.Add("@Share", System.Data.SqlDbType.NVarChar, 200);
        cmd.Parameters["@Share"].Value = _sharedcategoryid;

        cmd.Parameters.Add("@MaxQty", System.Data.SqlDbType.Int);
        cmd.Parameters["@MaxQty"].Value = 10;

        System.Data.SqlClient.SqlParameter returnData = cmd.Parameters.Add("@OutputID", SqlDbType.NVarChar, 200);
        returnData.Direction = ParameterDirection.Output;

        try
        {
            conn.Open();
            int result = cmd.ExecuteNonQuery();
        }
        catch
        {
            return false;
        }
        finally
        {
            conn.Close();
            conn.Dispose();
        }
        return true;

    }

    protected void rpBTO_ItemCommand(object source, RepeaterCommandEventArgs e)
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
            rpBTO.DataSource = dbUtil.dbGetDataTable("CBOMV2", string.Format("DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}_BTOS' SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child", this.Org_ID));
            rpBTO.DataBind();
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

                rpBTO.DataSource = dbUtil.dbGetDataTable("CBOMV2", string.Format("DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}_BTOS' SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child", this.Org_ID));
                rpBTO.DataBind();
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
                    var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + this.Org_ID + "'");
                    if (obj != null && Convert.ToInt32(obj.ToString()) > 0)
                        this.isadmin = true;
                    else
                        this.isadmin = false;
                }
            }
            return this.isadmin.Value;
        }
        set
        {
            this.isadmin = value;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../Includes/jquery-latest.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $('#<%=txtBTO.ClientID%>').attr('autocomplete', 'off');
        })
    </script>
    <div>
        <asp:Label ID="lbOrg" runat="server" ForeColor="black" Font-Size="Larger" Font-Bold="true"></asp:Label>
    </div>
    <div>
        <asp:TextBox ID="txtBTO" runat="server"></asp:TextBox>&nbsp;
        <asp:Button ID="btnCreate" runat="server" Text="Create" OnClick="btnCreate_Click" />&nbsp;
        <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato"></asp:Label>
    </div>
    <div>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>
                <asp:Repeater ID="rpBTO" runat="server" OnItemCommand="rpBTO_ItemCommand">
                    <HeaderTemplate>
                        <table>
                            <thead>
                                <tr>
                                    <th>Editor</th>
                                    <th>Configurator</th>
                                    <th>BTO</th>
                                    <th>Rename</th>
                                    <th>Delete</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td style="text-align:center">
                                <a href='<%# string.Format("{0}/Lab/CBOMV2/CBOM_Catalog_Category.aspx?ID={1}", Util.GetRuntimeSiteUrl(), Eval("ID")) %>'>Editor</a>
                            </td>
                            <td style="text-align:center">
                                <a href='<%# string.Format("{0}/Order/Configurator_new.aspx?ID={1}&NAME={2}&QTY=1", Util.GetRuntimeSiteUrl(), Eval("ID"),Eval("CATEGORY_ID")) %>'>Configurator</a>
                            </td>
                            <td style="width: 150px" align="center">
                                <asp:Label ID="lbCategoryName" runat="server" Text='<%#Eval("CATEGORY_ID") %>'></asp:Label>
                                <asp:TextBox ID="txtCategoryName" runat="server" Text='<%#Eval("CATEGORY_ID") %>' onblur="CheckField(this);" Visible="false"></asp:TextBox>
                            </td>
                            <td align="center">
                                <asp:ImageButton ID="btn_rename" runat="server" ImageUrl="~/Images/edit.png" CommandName="Rename" CommandArgument='<%#Eval("ID")%>' />
                                <asp:ImageButton ID="btn_update" runat="server" CommandName="Update" CommandArgument='<%#Eval("ID")%>' ImageUrl="~/Images/12-em-check.png" Visible="false" />&nbsp;
                                <asp:ImageButton ID="btn_cancel" runat="server" CommandName="Cancel" CommandArgument='<%#Eval("ID")  %>' ImageUrl="~/Images/12-em-cross.png" Visible="false" />
                            </td>
                            <td align="center">
                                <asp:ImageButton ID="btn_delete" runat="server" ImageUrl="~/Images/delete.jpg" CommandName="Delete" CommandArgument='<%#Eval("ID")%>' OnClientClick="return confirm('Delete ?')" />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                </table>
                    </FooterTemplate>
                </asp:Repeater>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

