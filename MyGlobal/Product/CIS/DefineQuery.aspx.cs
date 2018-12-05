using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

public partial class DefineQuery : System.Web.UI.Page
{   
    static string[] strCon = new string[3] { "AVL_Part = 'Advansus'", "((AVL_Part = 'AVL') OR (AVL_Part IS NULL) OR (AVL_Part = '') OR (AVL_Part = 'Non-AVL'))", "AVL_Part = 'Avalue'" };

    #region Page Load
    private int datasheetindex = 0;
    private int pictureindex = 0;
    //private int advansuspartnoindex = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        var rnd = new Random();
        System.Threading.Thread.Sleep(rnd.Next(30000, 300001));
        Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx");
        if (!Page.IsPostBack)
        {
            MsgShow("");

            Session["UniCode"] = (Request["UNICODE"] == null) ? null : Request["UNICODE"];
            if (Session["UniCode"] != null)
            {
                string strErrMsg = "";
                string[] strSQLOld = new string[6];
                strSQLOld[0] = "DELETE b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                strSQLOld[1] = "DELETE b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                strSQLOld[2] = "DELETE b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                strSQLOld[3] = "insert into b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT SELECT ID,SQL_STATEMENT FROM b2bsa.CIS_USER_DEFINE_SQLSTATEMENT WHERE ID = '" + Session["UniCode"] + "'";
                strSQLOld[4] = "insert into b2bsa.CIS_USER_DEFINE_DETAIL_EDIT SELECT ID,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL WHERE ID = '" + Session["UniCode"] + "'";
                strSQLOld[5] = "insert into b2bsa.CIS_USER_DEFINE_FIELD_EDIT SELECT ID,FIELDS_NAME,FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD WHERE ID = '" + Session["UniCode"] + "'";
                CISUTILITY.UpdateDBArray(strSQLOld, "QS", ref strErrMsg);
                if (strErrMsg.Length > 0)
                {
                    MsgShow("DB access error, please contact with system sponsor");
                }
                else
                {


                    DataTable dtFormField = CISUTILITY.GetSchemaTable();
                    if (dtFormField != null)
                    {
                        for (int i = 0; i < dtFormField.Rows.Count; i++)
                        {
                            this.ddlSubject.Items.Add(dtFormField.Rows[i]["DISPLAY_FIELD"].ToString());
                            this.ddlSubject.Items[i].Text = dtFormField.Rows[i]["DISPLAY_FIELD"].ToString();
                            this.ddlSubject.Items[i].Value = dtFormField.Rows[i]["FIELD_NAME"].ToString();
                        }
                    }
                    gvUserDefineBind(0);
                    showSQLStatement();
                    gvUserDefineShowBind(0);
                }
            }
            else
            {
                //Response.Redirect("./check_login.aspx?user_id=" + Session["user_id"]);
            }

            //初始化Tree View
            iniTV();
            tvComponent.ExpandDepth = 0;
            tvComponent.SelectedNodeStyle.ForeColor = System.Drawing.Color.Red;
            
        }
    }
    #endregion

    #region initial TreeView
    private void iniTV()
    {
        //建立母節點 KM
        TreeNode tn = new TreeNode();
        tn.Value = "advantech";
        tn.Text = "CAPS";
        tvComponent.Nodes.Add(tn);
        tn = null;
        //tn = new TreeNode();
        //tn.Value = "advantech";
        //tn.Text = "Advantech";
        //tvComponent.Nodes.Add(tn);
        //tn = null;
        //tn = new TreeNode();
        //tn.Value = "Avalue";
        //tn.Text = "Avalue";
        //tvComponent.Nodes.Add(tn);
        //tn = null;

        buildSubNode(tvComponent.Nodes[0], 1);
        //buildSubNode(tvComponent.Nodes[1], 1);
        //buildSubNode(tvComponent.Nodes[2], 2);
    }

    private void buildSubNode(TreeNode tnSub, int condition)
    {
        //string strSQL = "select distinct \"part_type\" from dbo.Components where \"part_type\" not like '%\\%' and " + strCon[condition] + " order by \"part_type\"";
        string strSQL = "select distinct \"part_type\" from dbo.Advantech where \"part_type\" not like '%\\%' and " + strCon[condition] + " order by \"part_type\"";

        string strErrMsg = "";
        DataTable dtSubComp = CISUTILITY.QueryDB(strSQL, "ACLSLQ1-CIS", ref strErrMsg);
        TreeNode tn;
        if (dtSubComp.Rows.Count > 0)
        {
            for (int j = 0; j < dtSubComp.Rows.Count; j++)
            {
                tn = new TreeNode();
                tn.Value = dtSubComp.Rows[j]["part_type"].ToString() + "&" + condition.ToString();
                tn.Text = dtSubComp.Rows[j]["part_type"].ToString();
                tnSub.ChildNodes.Add(tn);
                tn = null;
                buildLeaveNode(tnSub.ChildNodes[j], condition);
            }
        }

    }

    private void buildLeaveNode(TreeNode tnLeave, int condition)
    {
        //string strSQL = "select distinct \"part_type\" from dbo.Components where \"part_type\" like '%" + tnLeave.Text + "\\%' and " + strCon[condition] + " order by \"part_type\"";
        string strSQL = "select distinct \"part_type\" from dbo.Advantech where \"part_type\" like '%" + tnLeave.Text + "\\%' and " + strCon[condition] + " order by \"part_type\"";

        string strErrMsg = "";
        DataTable dtLeaveComp = CISUTILITY.QueryDB(strSQL, "ACLSLQ1-CIS", ref strErrMsg);
        TreeNode tn;
        if (dtLeaveComp.Rows.Count > 0)
        {
            for (int l = 0; l < dtLeaveComp.Rows.Count; l++)
            {
                tn = new TreeNode();
                tn.Value = dtLeaveComp.Rows[l]["part_type"].ToString() + "&" + condition.ToString();
                tn.Text = dtLeaveComp.Rows[l]["part_type"].ToString();
                tnLeave.ChildNodes.Add(tn);
                tn = null;
            }
        }
    }


    #endregion

    #region tvComponent_SelectedNodeChanged
    protected void tvComponent_SelectedNodeChanged(object sender, EventArgs e)
    {
        txtComSel.Text = (tvComponent.SelectedNode.Text == "CAPS" || tvComponent.SelectedNode.Text == "Advansus" || tvComponent.SelectedNode.Text == "Avalue") ? "" : tvComponent.SelectedNode.Value;
        showSQLStatement();
        gvUserDefineShowBind(0);
    }
    #endregion

    #region Message Show
    private void MsgShow(string message)
    {
        this.lblMsgContext.Text = message;
    }
    #endregion

    #region Footer Button Event
    protected void ibtnQuery_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_QUERY.aspx");
    }
    protected void ibtnTemplate_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_TEMPLATE.aspx");
    }
    #endregion

    #region gvUserDefine event
    private void gvUserDefineBind(int pageindex)
    {
        string strErrMsg = "";
        string strSQL = "SELECT SEQ,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "' ORDER BY SEQ";
        DataTable dt = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);

        if (strErrMsg.Length > 0)
        {
            MsgShow("DB access error, please contact with sponsor");
        }
        else
        {
            if (dt.Rows.Count > 0)
            {
                trUserDefine.Visible = true;
            }
            this.gvUserDefine.DataSource = dt;
            this.gvUserDefine.PageIndex = pageindex;
            this.gvUserDefine.DataBind();
        }
    }

    protected void gvUserDefine_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvUserDefine.EditIndex = -1;
        gvUserDefineBind(0);


    }
    protected void gvUserDefine_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        string strErrMsg = "";
        string strSQL = "DELETE b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = N'" + Session["UniCode"] + "' AND SEQ = N'" + gvUserDefine.Rows[e.RowIndex].Cells[0].Text + "'";
        CISUTILITY.UpdateDB(strSQL, "QS", ref strErrMsg);
        gvUserDefineBind(0);
        showSQLStatement();
        gvUserDefineShowBind(0);
    }
    protected void gvUserDefine_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {

        if (checkUpdateAction())
        {
            string strErrMsg = "";
            string strSQL = "UPDATE b2bsa.CIS_USER_DEFINE_DETAIL_EDIT SET SQL_VALUE = N'" + ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString() + "'  WHERE ID = N'" + Session["UniCode"] + "' AND SEQ = N'" + ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[0].Controls[0]).Text.ToString() + "'";
            CISUTILITY.UpdateDB(strSQL, "QS", ref strErrMsg);
            if (strErrMsg.Length > 0)
            {
                MsgShow("Update Faile, please contact with system sponsor");
            }
            gvUserDefine.EditIndex = -1;
            gvUserDefineBind(0);
            showSQLStatement();
            gvUserDefineShowBind(0);
            MsgShow("");
        }
        gvUserDefine.Columns[1].ControlStyle.Width = 30;
        gvUserDefine.Columns[2].ControlStyle.Width = 30;
        gvUserDefine.Columns[3].ControlStyle.Width = 150;
        gvUserDefine.Columns[4].ControlStyle.Width = 100;
        gvUserDefine.Columns[5].ControlStyle.Width = 250;

    }
    protected bool checkUpdateAction()
    {
        try
        {
            //確認值為非空值
            if (((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString().Trim().Length == 0)
            {
                MsgShow("Please key in value");
                gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0].Focus();
                return false;
            }

            if (((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString().IndexOf("'") > 0)
            {
                MsgShow("please remove the single quote");
                gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0].Focus();
                return false;
            }

            //int countquote = 0;
            //for (int i = 0; i < ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.Trim().Length; i++)
            //{
            //    if (((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text[i].ToString().Equals("'"))
            //    {
            //        countquote++;
            //    }
            //}

            //if (countquote % 2 != 0 || countquote == 0)
            //{
            //    MsgShow("please check the single quote");
            //    gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0].Focus();
            //    return false;
            //}
            //((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text = ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString().Replace("'", "\"");

            //if (((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[4].Controls[0]).Text.ToString().Equals("like"))
            //{
            //    ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text = "\"%" + ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString() + "%\"";
            //}
            //else
            //{
            //    ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text = "\"" + ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString() + "\"";
            //}

            MsgShow("");
            
            return true;

        }
        catch (Exception ee)
        {
            MsgShow("Update function Error,Please contact with sponsor");
            gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0].Focus();
            return false;
        }

    }
    protected void gvUserDefine_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    protected void gvUserDefine_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvUserDefine.EditIndex = e.NewEditIndex;
        gvUserDefineBind(0);
        //((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text = ((TextBox)gvUserDefine.Rows[gvUserDefine.EditIndex].Cells[5].Controls[0]).Text.ToString().Replace("\"", "").Replace("%","");
        //gvUserDefine.Columns[1].ControlStyle.Width = 30;
        //gvUserDefine.Columns[2].ControlStyle.Width = 30;
        //gvUserDefine.Columns[3].ControlStyle.Width = 150;
        //gvUserDefine.Columns[4].ControlStyle.Width = 100;
        //gvUserDefine.Columns[5].ControlStyle.Width = 250;
    }
    #endregion

    #region Add button event
    protected void btnAction_Click(object sender, EventArgs e)
    {
        if (checkbtnActionButton())
        {
            string strSQL = "";
            string strErrMsg = "";

            strSQL = string.Format("INSERT INTO b2bsa.CIS_USER_DEFINE_DETAIL_EDIT (ID,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE) VALUES ('{0}','{1}','{2}','{3}','{4}','{5}')",
                     Session["UniCode"],
                     ddlOperand.SelectedValue,
                     ddlBracket.SelectedValue,
                     ddlSubject.SelectedValue,
                     ddlCondition.SelectedValue,
                     txtValues.Text.ToString());
            CISUTILITY.UpdateDB(strSQL, "QS", ref strErrMsg);
            if (strErrMsg.Length > 0)
            {
                MsgShow("DB communication error, please contact with system sponsor");
            }
            gvUserDefineBind(0);
            showSQLStatement();
            gvUserDefineShowBind(0);

            this.ddlCondition.SelectedIndex = 0;
            this.ddlSubject.SelectedIndex = 0;
            this.ddlOperand.SelectedIndex = 0;
            this.ddlBracket.SelectedIndex = 0;
            this.txtValues.Text = "";
            
        }
    }

    protected bool checkbtnActionButton()
    {
        try
        {
            //確認值為非空值
            if (txtValues.Text.ToString().Trim().Length == 0)
            {
                // MsgShow("please key in value");
                ScriptManager.RegisterStartupScript(UpdatePanel1, this.GetType(), "alert", "alert('please key in value')", true);
                txtValues.Focus();
                return false;
            }

            //確認是否有單引號
            if (txtValues.Text.ToString().IndexOf("'") > 0)
            {
                ScriptManager.RegisterStartupScript(UpdatePanel1, this.GetType(), "alert", "alert('Please remove the single quote')", true);
                // MsgShow("Please remove the single quote");
                txtValues.Focus();
                return false;
            }

            //確認單引號必為偶數個
            //int countquote = 0;
            //for (int i = 0; i < txtValues.Text.Trim().Length; i++)
            //{
            //    if (txtValues.Text[i].ToString().Equals("'"))
            //    {
            //        countquote++;
            //    }
            //}

            //if (countquote % 2 != 0)
            //{
            //    MsgShow("please check the single quote");
            //    txtValues.Focus();
            //    return false;
            //}

            //if (ddlCondition.SelectedValue.Equals("like"))
            //{
            //    this.txtValues.Text = "\"%" + txtValues.Text + "%\"";
            //}
            //else
            //{
            //    this.txtValues.Text = "\"" + txtValues.Text + "\"";
            //}
            MsgShow("");
            return true;

        }
        catch (Exception ee)
        {
            MsgShow("Update function Error , please contact with sponsor");
            txtValues.Focus();
            return false;
        }
    }

    #endregion

    #region check SQL Statement (checkSQLStatement)
    /// <summary>
    /// 檢查SQL statement 有無insert,update,delete
    /// </summary>
    /// <param name="strSQL"></param>
    /// <returns>true:SQL statement 無破壞性字眼</returns>
    protected bool checkSQLStatement(string strSQL)
    {

        if (strSQL.ToLower().IndexOf("insert") > -1)
        {
            return false;
        }
        if (strSQL.ToLower().IndexOf("update") > -1)
        {
            return false;
        }
        if (strSQL.ToLower().IndexOf("delete") > -1)
        {
            return false;
        }

        return true;
    }
    #endregion

    #region gvUserDeinfeShow Event
    private void showSQLStatement()
    {
        string strSQL = "";
        string strErrMsg = "";
        string SQLFIELD = "";
        string SQLWHERE = "";


        //取得欄位列表
        strSQL = "SELECT FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD WHERE ID = '" + Session["UniCode"] + "'";
        DataTable dtFields = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);

        //SQLFIELD += " \"DATASHEET\", ";
        if (dtFields == null || dtFields.Rows.Count == 0)
        {
            //do nothing
        }
        else
        {
            for (int j = 0; j < dtFields.Rows.Count; j++)
            {
                
                SQLFIELD += "\"" + dtFields.Rows[j]["FIELDS_VALUE"].ToString() + "\",";
            }
        }

        if (SQLFIELD.LastIndexOf(',') > 0)
        {
            SQLFIELD = SQLFIELD.Substring(0, SQLFIELD.LastIndexOf(','));
        }

        if (SQLWHERE.LastIndexOf('A') > 0)
        {
            SQLWHERE = SQLWHERE.Substring(0, SQLWHERE.LastIndexOf('A'));
        }

        //取得Where條件
        strSQL = "SELECT OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "' ORDER BY SEQ";

        DataTable dtWhere = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);

        if (dtWhere != null)
        {
            string left_bracket = "";
            string right_bracket = "";
            for (int k = 0; k < dtWhere.Rows.Count; k++)
            {
                left_bracket = (dtWhere.Rows[k]["BRACKET"].ToString().Trim().Equals("(")) ? "(" : "";
                right_bracket = (dtWhere.Rows[k]["BRACKET"].ToString().Trim().Equals(")")) ? ")" : "";

                if (SQLWHERE.Length > 0)
                {
                    SQLWHERE += dtWhere.Rows[k]["OPERAND"].ToString();
                }
                if (dtWhere.Rows[k]["CONDITION"].ToString().Equals("like"))
                {
                    SQLWHERE += " " + left_bracket + "\"" + dtWhere.Rows[k]["FIELD_SUBJECT"].ToString() + "\" " + dtWhere.Rows[k]["CONDITION"].ToString() + " '%" + dtWhere.Rows[k]["SQL_VALUE"].ToString().Replace("%", "[%]") + "%' " + right_bracket + " ";
                }
                else if (dtWhere.Rows[k]["CONDITION"].ToString().Equals("≠"))
                {
                    SQLWHERE += " " + left_bracket + "\"" + dtWhere.Rows[k]["FIELD_SUBJECT"].ToString() + "\" <> '" + dtWhere.Rows[k]["SQL_VALUE"].ToString().Replace("%", "[%]") + "' " + right_bracket + " ";
                }else 
                {
                    SQLWHERE += " " + left_bracket + "\"" + dtWhere.Rows[k]["FIELD_SUBJECT"].ToString() + "\" " + dtWhere.Rows[k]["CONDITION"].ToString() + " '" + dtWhere.Rows[k]["SQL_VALUE"].ToString().Replace("%", "[%]") + "' " + right_bracket + " ";
                }
                //SQLWHERE += " " + left_bracket + "\"" + dtWhere.Rows[k]["FIELD_SUBJECT"].ToString() + "\" " + dtWhere.Rows[k]["CONDITION"].ToString() + " " + dtWhere.Rows[k]["SQL_VALUE"].ToString().Replace("\"", "'") + right_bracket + " ";
            }
        }

        if (txtComSel.Text.Length > 0)
        {
            string[] str = new string[2];
            str = txtComSel.Text.Split('&');
            if (SQLWHERE.Length > 0)
            {
                SQLWHERE += " and \"part_type\" = '" + str[0] + "' and " + strCon[Convert.ToInt16(str[1])];
            }
            else
            {
                SQLWHERE += " \"part_type\" = '" + str[0] + "' and " + strCon[Convert.ToInt16(str[1])];
            }

        }


        if (SQLWHERE.Length > 0)
        {
            SQLWHERE = " WHERE " + SQLWHERE;
        }
        this.txtSQLStatement.Text = "SELECT " + SQLFIELD + " FROM Components " + SQLWHERE;
    }


    private void gvUserDefineShowBind(int pageindex)
    {
        MsgShow("");
        if (checkSQLStatement(txtSQLStatement.Text))
        {
            SqlDataSource1.SelectCommand = txtSQLStatement.Text;
        }
        else
        {
            MsgShow("illegal keyword like 'insert','update' or 'delete'");
        }
    }

    protected void gvUserDefineShow_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        SqlDataSource1.SelectCommand = txtSQLStatement.Text;
    }
    protected void gvUserDefineShow_Sorting(object sender, GridViewSortEventArgs e)
    {
        SqlDataSource1.SelectCommand = txtSQLStatement.Text;
    }

    #endregion

    #region btnSave_Click
    protected void btnSave_Click(object sender, EventArgs e)
    {
        string strErrMsg = "";
        string[] strSQLOld = new string[4];
        strSQLOld[0] = "DELETE b2bsa.CIS_USER_DEFINE_SQLSTATEMENT WHERE ID = '" + Session["UniCode"] + "'";
        strSQLOld[1] = "DELETE b2bsa.CIS_USER_DEFINE_DETAIL WHERE ID = '" + Session["UniCode"] + "'";
        strSQLOld[2] = "insert into b2bsa.CIS_USER_DEFINE_SQLSTATEMENT SELECT ID,SQL_STATEMENT FROM b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
        strSQLOld[3] = "insert into b2bsa.CIS_USER_DEFINE_DETAIL SELECT ID,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "'"; 
        CISUTILITY.UpdateDBArray(strSQLOld, "QS", ref strErrMsg);
        if (strErrMsg.Length > 0)
        {
            MsgShow(strErrMsg);
        }
        else
        {
           // MsgShow("Save Success");
            ScriptManager.RegisterStartupScript(UpdatePanel1, this.GetType(), "alert", "alert('Save Success')", true);
        }
    }
    #endregion

    #region gvUserDefineShow_RowDataBound
    protected void gvUserDefineShow_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            datasheetindex = finddatasheetindex("Datasheet");
            pictureindex  = finddatasheetindex("Picture");
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (datasheetindex != -1)
                {
                    e.Row.Cells[datasheetindex].Text = "<a href='\\CIS\\doc\\DataSheets\\" + e.Row.Cells[datasheetindex].Text + "'>" + e.Row.Cells[datasheetindex].Text + "</a>";
                }
                if (pictureindex != -1)
                {
                    e.Row.Cells[pictureindex].Text = "<a href='\\CIS\\doc\\Pictures\\" + e.Row.Cells[pictureindex].Text + "'>" + e.Row.Cells[pictureindex].Text + "</a>";
                }
            }
        }
    }

    private int finddatasheetindex(string key)
    {
        string strErrMsg = "";
        string strSQL = "SELECT FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD WHERE ID = '" + Session["UniCode"] + "'";
        DataTable dtFields = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);

        if (dtFields == null || dtFields.Rows.Count == 0)
        {
            //do nothing
        }
        else
        {
            for (int j = 0; j < dtFields.Rows.Count; j++)
            {
                if (dtFields.Rows[j]["FIELDS_VALUE"].ToString().Equals(key))
                {
                    return j;
                }
                if (dtFields.Rows[j]["FIELDS_VALUE"].ToString().Equals(key))
                {
                    return j;
                }
            }
        }
        return -1;

    }

    #endregion
    
}

