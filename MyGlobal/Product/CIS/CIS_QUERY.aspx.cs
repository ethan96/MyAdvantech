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

public partial class CIS_QUERY : System.Web.UI.Page
{
    static string[] strCon = new string[3] { "AVL_Part = 'Advansus'", "((AVL_Part = 'AVL') OR (AVL_Part IS NULL) OR (AVL_Part = '') OR (AVL_Part = 'Non-AVL'))", "AVL_Part = 'Avalue'" };   
    #region Page Load
    private int datasheetindex = 0;
    private int pictureindex = 0;

    /// <summary>
    /// Page Load Function
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        //2010-07-08 Abow.Wang
        //隨機sleep, 避免影響db效能        
        var rnd = new Random();
        System.Threading.Thread.Sleep(rnd.Next(30000,300001));
        Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx");
        if (!Page.IsPostBack)
        {
            //Session["user_id"] = "tc.chen@advantech.com.tw";
            if (false)
            {
                //Response.Redirect("./check_login.aspx?user_id=" + Session["user_id"]);
            }
            Session["UniCode"] = (Request["UNICODE"] == null) ? System.Guid.NewGuid().ToString().Replace("-", "") : Request["UNICODE"];
            //Session["UniCode"] = "3707a54e063f4e909dc6fccf709914b3";
            //初始化SQL Condition
            gvSQLConditionBind(0);

            //初始化欄位選擇
            initSelectItems();

            //初始化SQL Statement
            showSQLStatement();

            //初始化Tree View
            iniTV();
            tvComponent.ExpandDepth = 0;
            tvComponent.SelectedNodeStyle.ForeColor = System.Drawing.Color.Red;
            tvComponent.Nodes[0].Select();
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
        //tn.Text = "Avalue";fv
        //tvComponent.Nodes.Add(tn);
        //tn = null;

        buildSubNode(tvComponent.Nodes[0], 1);
        //buildSubNode(tvComponent.Nodes[1], 1);
        //buildSubNode(tvComponent.Nodes[2], 2);
    }

    private void buildSubNode(TreeNode tnSub, int condition)
    {
       
        string strSQL = "select distinct \"part_type\" from dbo.Advantech where \"part_type\" not like '%\\%' and " + strCon[condition] + " order by \"part_type\"";

        //string strErrMsg = "";
        //DataTable dtSubComp = CISUTILITY.QueryDB(strSQL, "ACLSLQ1-CIS", ref strErrMsg);
        DataTable dtSubComp = dbUtil.dbGetDataTable("ACLSLQ1-CIS", strSQL);
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
        string strSQL = "select distinct \"part_type\" from dbo.Advantech where \"part_type\" like '%" + tnLeave.Text + "\\%' and " + strCon[condition] + " order by \"part_type\"";

        //string strErrMsg = "";
        //DataTable dtLeaveComp = CISUTILITY.QueryDB(strSQL, "ACLSLQ1-CIS", ref strErrMsg);
        DataTable dtLeaveComp = dbUtil.dbGetDataTable("ACLSLQ1-CIS", strSQL);
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
        btnQuery_Click(null, EventArgs.Empty);

    }
    #endregion

    #region Footer Button Event
    /// <summary>
    /// Query / My favorite function
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ibtnQuery_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_QUERY.aspx");
    }
    protected void ibtnTemplate_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_TEMPLATE.aspx");
    }
    #endregion

    #region Message Show
    /// <summary>
    /// Show Message 
    /// </summary>
    /// <param name="message"></param>
    private void MsgShow(string message)
    {
        lblMsgContext.Text = message;
    }
    #endregion

    #region Init Select Item
    /// <summary>
    /// 初始化欄位選擇
    /// </summary>
    protected void initSelectItems()
    {
        MsgShow("");
        try
        {
            lbSelItems.Items.Clear();
            lbChoiceItems.Items.Clear();
            ddlSubject.Items.Clear();
            DataTable dtFormField = CISUTILITY.GetSchemaTable();
            
            //dtFormField.ReadXmlSchema(Server.MapPath("~/Product/CIS/FIELD_SCHEMA/")+"Components_SCHEMA.XML");
            //dtFormField.ReadXml(Server.MapPath("~/Product/CIS/FIELD_DEFINE/") + "Components.XML");
            if (dtFormField != null)
            {
                for (int i = 0; i < dtFormField.Rows.Count; i++)
                {
                    this.lbSelItems.Items.Add(dtFormField.Rows[i]["DISPLAY_FIELD"].ToString());
                    this.lbSelItems.Items[i].Text = dtFormField.Rows[i]["DISPLAY_FIELD"].ToString();
                    this.lbSelItems.Items[i].Value = dtFormField.Rows[i]["FIELD_NAME"].ToString();
                    this.ddlSubject.Items.Add(dtFormField.Rows[i]["DISPLAY_FIELD"].ToString());
                    this.ddlSubject.Items[i].Text = dtFormField.Rows[i]["DISPLAY_FIELD"].ToString();
                    this.ddlSubject.Items[i].Value = dtFormField.Rows[i]["FIELD_NAME"].ToString();
                }
            }

            //當已存在檔案，
            string strSQL = "SELECT * FROM b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
            //string strErrMsg = "";
            DataTable dtFileds = dbUtil.dbGetDataTable ( "QS",strSQL);
            if (dtFileds != null && dtFileds.Rows.Count > 0)
            {
                lbChoiceItems.Items.Clear();
                for (int i = 0; i < dtFileds.Rows.Count; i++)
                {
                    lbChoiceItems.Items.Add(dtFileds.Rows[i]["FIELDS_NAME"].ToString());
                    lbChoiceItems.Items[i].Text = dtFileds.Rows[i]["FIELDS_NAME"].ToString();
                    lbChoiceItems.Items[i].Value = dtFileds.Rows[i]["FIELDS_VALUE"].ToString();
                    lbSelItems.Items.Remove(lbSelItems.Items.FindByValue(dtFileds.Rows[i]["FIELDS_VALUE"].ToString()));
                }
            }
            else
            {
                //lbChoiceItems.Items.Add("Part NO");
                //lbChoiceItems.Items[0].Text = "Part NO";
                //lbChoiceItems.Items[0].Value = "Part Number";
                //lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Part Number"));
                lbChoiceItems.Items.Add("Part_Number");
                lbChoiceItems.Items[0].Text = "Part_Number";
                lbChoiceItems.Items[0].Value = "Part_Number";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Part_Number"));
                lbChoiceItems.Items.Add("Part_Status");
                lbChoiceItems.Items[1].Text = "Part_Status";
                lbChoiceItems.Items[1].Value = "Part_Status";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Part_Status"));
                lbChoiceItems.Items.Add("Description");
                lbChoiceItems.Items[2].Text = "Description";
                lbChoiceItems.Items[2].Value = "Description";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Description"));
                lbChoiceItems.Items.Add("Datasheet");
                lbChoiceItems.Items[3].Text = "Datasheet";
                lbChoiceItems.Items[3].Value = "Datasheet";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Datasheet"));
                lbChoiceItems.Items.Add("Picture");
                lbChoiceItems.Items[4].Text = "Picture";
                lbChoiceItems.Items[4].Value = "Picture";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Picture"));
                lbChoiceItems.Items.Add("Manufacture");
                lbChoiceItems.Items[5].Text = "Manufacture";
                lbChoiceItems.Items[5].Value = "Manufacture";
                lbSelItems.Items.Remove(lbSelItems.Items.FindByValue("Manufacture"));
            }
        }
        catch (Exception ee)
        {
            MsgShow("Read filed error, please contact with sponsor");
        }
    }
    #endregion

    #region btnAction Event
    /// <summary>
    /// Add SQL condition
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
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


            dbUtil.dbExecuteNoQuery ( "QS", strSQL);
            if (strErrMsg.Length > 0)
            {
                MsgShow("DB communication error, please contact with system sponsor");
            }

            gvSQLConditionBind(0);

            this.ddlCondition.SelectedIndex = 0;
            this.ddlSubject.SelectedIndex = 0;
            this.ddlOperand.SelectedIndex = 0;
            this.ddlBracket.SelectedIndex = 0;
            this.txtValues.Text = "";
            showSQLStatement();
        }
    }

    protected bool checkbtnActionButton()
    {
        try
        {
            //確認值為非空值
            if (txtValues.Text.ToString().Trim().Length == 0)
            {
                MsgShow("please key in value");
                txtValues.Focus();
                return false;
            }

            //確認是否有單引號
            if (txtValues.Text.ToString().IndexOf("'") > 0)
            {
                MsgShow("Please remove the single quote");
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
            MsgShow("Add function faile, please contact with IT sponsor");
            txtValues.Focus();
            return false;
        }
    }
    #endregion

    #region 欄位全選，單選功能
    /// <summary>
    /// 欄位全選，單選功能
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSelall_Click(object sender, EventArgs e)
    {
        for (int i = 0; i < lbSelItems.Items.Count; i++)
        {
            lbChoiceItems.Items.Add(lbSelItems.Items[i].Text);
            lbChoiceItems.Items[lbChoiceItems.Items.Count - 1].Text = lbSelItems.Items[i].Text;
            lbChoiceItems.Items[lbChoiceItems.Items.Count - 1].Value = lbSelItems.Items[i].Value;

        }
        lbSelItems.Items.Clear();
        showSQLStatement();
    }
    protected void btnDelall_Click(object sender, EventArgs e)
    {
        for (int i = 0; i < lbChoiceItems.Items.Count; i++)
        {
            lbSelItems.Items.Add(lbChoiceItems.Items[i].Text);
            lbSelItems.Items[lbSelItems.Items.Count - 1].Text = lbChoiceItems.Items[i].Text;
            lbSelItems.Items[lbSelItems.Items.Count - 1].Value = lbChoiceItems.Items[i].Value;

        }
        lbChoiceItems.Items.Clear();

        showSQLStatement();
    }
    protected void btnSelone_Click(object sender, EventArgs e)
    {
        if (lbSelItems.SelectedIndex > -1)
        {
            lbChoiceItems.Items.Add(lbSelItems.SelectedItem.Text);
            lbChoiceItems.Items[lbChoiceItems.Items.Count - 1].Text = lbSelItems.SelectedItem.Text;
            lbChoiceItems.Items[lbChoiceItems.Items.Count - 1].Value = lbSelItems.SelectedItem.Value;
            lbSelItems.Items.Remove(lbSelItems.SelectedItem);
        }
        showSQLStatement();
    }
    protected void btnDelone_Click(object sender, EventArgs e)
    {
        if (lbChoiceItems.SelectedIndex > -1)
        {
            lbSelItems.Items.Add(lbChoiceItems.SelectedItem.Text);
            lbSelItems.Items[lbSelItems.Items.Count - 1].Text = lbChoiceItems.SelectedItem.Text;
            lbSelItems.Items[lbSelItems.Items.Count - 1].Value = lbChoiceItems.SelectedItem.Value;
            lbChoiceItems.Items.Remove(lbChoiceItems.SelectedItem);
        }
        showSQLStatement();
    }
    #endregion

    #region 欄位上移、下移功能
    /// <summary>
    /// 欄位上移、下移功能
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnFieldUp_Click(object sender, EventArgs e)
    {
        if (lbChoiceItems.SelectedIndex > 0)
        {
            string tempText = lbChoiceItems.SelectedItem.Text;
            string tempValue = lbChoiceItems.SelectedItem.Value;

            lbChoiceItems.Items[lbChoiceItems.SelectedIndex].Text = lbChoiceItems.Items[lbChoiceItems.SelectedIndex - 1].Text;
            lbChoiceItems.Items[lbChoiceItems.SelectedIndex].Value = lbChoiceItems.Items[lbChoiceItems.SelectedIndex - 1].Value;

            lbChoiceItems.Items[lbChoiceItems.SelectedIndex - 1].Text = tempText;
            lbChoiceItems.Items[lbChoiceItems.SelectedIndex - 1].Value = tempValue;
            lbChoiceItems.SelectedIndex--;

            showSQLStatement();
        }

    }
    protected void btnFieldDown_Click(object sender, EventArgs e)
    {
        if (lbChoiceItems.SelectedIndex < lbChoiceItems.Items.Count - 1)
        {
            string tempText = lbChoiceItems.SelectedItem.Text;
            string tempValue = lbChoiceItems.SelectedItem.Value;

            lbChoiceItems.Items[lbChoiceItems.SelectedIndex].Text = lbChoiceItems.Items[lbChoiceItems.SelectedIndex + 1].Text;
            lbChoiceItems.Items[lbChoiceItems.SelectedIndex].Value = lbChoiceItems.Items[lbChoiceItems.SelectedIndex + 1].Value;

            lbChoiceItems.Items[lbChoiceItems.SelectedIndex + 1].Text = tempText;
            lbChoiceItems.Items[lbChoiceItems.SelectedIndex + 1].Value = tempValue;
            lbChoiceItems.SelectedIndex++;

            showSQLStatement();
        }
    }
    #endregion

    #region Show SQL statement
    /// <summary>
    /// showSQLStatement
    /// </summary>
    private void showSQLStatement()
    {
        string strSQL = "";
        string strErrMsg = "";
        string SQLFIELD = "";
        string SQLWHERE = "";


        //取得欄位列表
        for (int j = 0; j < lbChoiceItems.Items.Count; j++)
        {
            SQLFIELD += "\"" + lbChoiceItems.Items[j].Value + "\",";
        }

        //消除多餘字元
        SQLFIELD = (SQLFIELD.LastIndexOf(',') > 0) ? SQLFIELD.Substring(0, SQLFIELD.LastIndexOf(',')) : SQLFIELD;
        SQLWHERE = (SQLWHERE.LastIndexOf('A') > 0) ? SQLWHERE.Substring(0, SQLWHERE.LastIndexOf('A')) : SQLWHERE;


        //取得Where條件
        strSQL = "SELECT OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "' ORDER BY SEQ";

        DataTable dtWhere = dbUtil.dbGetDataTable ( "QS",strSQL);

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
                }
                else
                {
                    SQLWHERE += " " + left_bracket + "\"" + dtWhere.Rows[k]["FIELD_SUBJECT"].ToString() + "\" " + dtWhere.Rows[k]["CONDITION"].ToString() + " '" + dtWhere.Rows[k]["SQL_VALUE"].ToString().Replace("%", "[%]") + "' " + right_bracket + " ";
                }

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
            SQLWHERE = " AND ( " + SQLWHERE + ")";
        }
        if (SQLFIELD.Equals(String.Empty)) {
            SQLFIELD = " * ";
        }
        this.txtSQLStatement.Text = "SELECT " + SQLFIELD + " FROM dbo.Advantech WHERE \"Part_Number \" IS NOT NULL AND LEN(\"Part_Number \") >0 " + SQLWHERE;
    }
    #endregion

    #region gvSQLCondition event
    /// <summary>
    /// gvSQLCondition RowEditing
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLCondition_RowEditing(object sender, GridViewEditEventArgs e)
    {
        try
        {
            gvSQLCondition.EditIndex = e.NewEditIndex;
            gvSQLConditionBind(0);
        }
        catch (Exception ee)
        {
            MsgShow(ee.ToString());
        }
    }

    /// <summary>
    /// gvSQLCondition RowCancel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLCondition_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvSQLCondition.EditIndex = -1;
        gvSQLConditionBind(0);
    }

    /// <summary>
    /// gvSQLCondition RowUpdate
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLCondition_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        if (checkUpdateAction())
        {
            string strErrMsg = "";
            string strSQL = "UPDATE b2bsa.CIS_USER_DEFINE_DETAIL_EDIT SET  SQL_VALUE = N'" + ((TextBox)gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0]).Text.ToString() + "'  WHERE ID = N'" + Session["UniCode"] + "' AND SEQ = N'" + ((TextBox)gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[0].Controls[0]).Text.ToString() + "'";

            dbUtil.dbExecuteNoQuery ("QS",strSQL);

            if (strErrMsg.Length > 0)
            {
                MsgShow("Update job faile , please contact with system sponsor" + strSQL);
            }
            gvSQLCondition.EditIndex = -1;
            gvSQLConditionBind(0);
            showSQLStatement();
        }
        gvSQLCondition.Columns[1].ControlStyle.Width = 30;
        gvSQLCondition.Columns[2].ControlStyle.Width = 30;
        gvSQLCondition.Columns[3].ControlStyle.Width = 150;
        gvSQLCondition.Columns[4].ControlStyle.Width = 50;
        gvSQLCondition.Columns[5].ControlStyle.Width = 250;
    }

    /// <summary>
    /// Check illegal character
    /// </summary>
    /// <returns></returns>
    protected bool checkUpdateAction()
    {
        try
        {
            //確認值為非空值
            if (((TextBox)gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0]).Text.ToString().Trim().Length == 0)
            {
                MsgShow("Please key in value");
                gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0].Focus();
                return false;
            }

            if (((TextBox)gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0]).Text.ToString().IndexOf("'") > 0)
            {
                MsgShow("please remove the single quote");
                gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0].Focus();
                return false;
            }
            MsgShow("");
            return true;
        }
        catch (Exception ee)
        {
            MsgShow("Update job faile , please contact with system sponsor" + ee.ToString());
            gvSQLCondition.Rows[gvSQLCondition.EditIndex].Cells[5].Controls[0].Focus();
            return false;
        }

    }

    /// <summary>
    /// gvSQLCondition Delete
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLCondition_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        //string strErrMsg = "";
        string strSQL = "DELETE b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = N'" + Session["UniCode"] + "' AND SEQ = N'" + gvSQLCondition.Rows[e.RowIndex].Cells[0].Text + "'";
        dbUtil.dbExecuteNoQuery ( "QS",strSQL);
        gvSQLConditionBind(0);
        showSQLStatement();
    }

    /// <summary>
    /// gvSQLCondition Binding data
    /// </summary>
    /// <param name="pageindex"></param>
    private void gvSQLConditionBind(int pageindex)
    {
        string strErrMsg = "";
        string strSQL = "SELECT SEQ,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "' ORDER BY SEQ";
        DataTable dt = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);
        this.gvSQLCondition.DataSource = dt;
        this.gvSQLCondition.PageIndex = pageindex;
        this.gvSQLCondition.DataBind();
    }

    /// <summary>
    /// gvSQLCondition RowDataBound
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLCondition_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    #endregion

    #region Query button event
    /// <summary>
    /// Query preview
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (checkSQLStatement(this.txtSQLStatement.Text))
        {
            if (gvSQLshow.Columns.Count > 0)
            {
                gvSQLshow.Columns.Clear();

            }

            BoundField bf;

            for (int j = 0; j < lbChoiceItems.Items.Count; j++)
            {
                bf = new BoundField();
                bf.HeaderText = lbChoiceItems.Items[j].Text.ToString();
                bf.DataField = lbChoiceItems.Items[j].Value.ToString();
                bf.SortExpression = lbChoiceItems.Items[j].Value.ToString();
                gvSQLshow.Columns.Add(bf);
                bf = null;
            }
            SqlDataSource1.SelectCommand = txtSQLStatement.Text.ToString();

        }
        else
        {
            MsgShow("illegal keyword like 'insert','update' or 'delete'");
        }
    }
    #endregion

    #region gvSQLShow event
    /// <summary>
    /// gvSQLshow event related
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSQLshow_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        SqlDataSource1.SelectCommand = txtSQLStatement.Text;
    }
    protected void gvSQLshow_Sorting(object sender, GridViewSortEventArgs e)
    {
        SqlDataSource1.SelectCommand = txtSQLStatement.Text;
    }
    protected void gvSQLshow_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.Header)
        {
            datasheetindex = finddatasheetindex("Datasheet");
            pictureindex = finddatasheetindex("Picture");
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (e.Row.Cells[datasheetindex].Text.Trim() != string.Empty)
                {
                    if (datasheetindex != -1)
                    {
                        string n = e.Row.Cells[datasheetindex].Text;
                        e.Row.Cells[datasheetindex].Text = string.Format("<a target='_blank' href='includes//DlCISFile.ashx?ftype=Datasheet&fname={0}'>{0}</a>", n);
                        //e.Row.Cells[datasheetindex].Text = "";
                        //e.Row.Cells[datasheetindex].Text = "<a target='_blank' href='\\CIS\\doc\\DataSheets\\" + e.Row.Cells[datasheetindex].Text + "'>" + e.Row.Cells[datasheetindex].Text + "</a>";
                        //e.Row.Cells[datasheetindex].Text = "<a target='_blank' href='includes/DlCISFile.ashx?ftype=Datasheet&fname=" + e.Row.Cells[datasheetindex].Text + "'>" + e.Row.Cells[datasheetindex].Text + "</a>";
                    }
                   
                    if (pictureindex != -1)
                    {
                        string n = e.Row.Cells[pictureindex].Text;
                        e.Row.Cells[pictureindex].Text = string.Format("<a target='_blank' href='includes//DlCISFile.ashx?ftype=Pictures&fname={0}'>{0}</a>", n);
                        //e.Row.Cells[pictureindex].Text = "<a target='_blank' href='\\CIS\\doc\\Pictures\\" + e.Row.Cells[pictureindex].Text + "'>" + e.Row.Cells[pictureindex].Text + "</a>";
                        //e.Row.Cells[datasheetindex].Text = "<a target='_blank' href='includes/DlCISFile.ashx?ftype=Pictures&fname=" + e.Row.Cells[datasheetindex].Text + "'>" + e.Row.Cells[datasheetindex].Text + "</a>";
                    }              
                }
                else
                {
                    e.Row.Visible=false;
                }
               
            }            
        }
    }

    /// <summary>
    /// Find DataSheet column
    /// </summary>
    /// <returns></returns>
    private int finddatasheetindex(string key)
    {
        for (int j = 0; j < lbChoiceItems.Items.Count; j++)
        {
            if (lbChoiceItems.Items[j].Value.ToString().Equals(key))
            {
                return j;
            }
            if (lbChoiceItems.Items[j].Value.ToString().Equals(key))
            {
                return j;
            }
        }
        return -1;
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

    #region insert data to temp table
    /// <summary>
    /// insert 2 editTable
    /// </summary>
    /// <returns></returns>
    private bool insert2editTable()
    {
        string strErrMsg = "";
        string[] strSQLField = new string[lbChoiceItems.Items.Count + 1];
        strSQLField[0] = "DELETE b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
        for (int i = 0; i < lbChoiceItems.Items.Count; i++)
        {
            strSQLField[i + 1] = "INSERT INTO b2bsa.CIS_USER_DEFINE_FIELD_EDIT (ID,FIELDS_NAME,FIELDS_VALUE) VALUES ('" + Session["UniCode"] + "',N'" + lbChoiceItems.Items[i].Text + "','" + lbChoiceItems.Items[i].Value + "')";
        }
        CISUTILITY.UpdateDBArray(strSQLField, "QS", ref strErrMsg);
        if (strErrMsg.Length > 0)
        {
            MsgShow("DB communication error, please contact with sponsor");
            return false;
        }

        string[] strSQLStatement = new string[2];
        strSQLStatement[0] = "DELETE b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
        strSQLStatement[1] = "INSERT INTO b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT (ID,SQL_STATEMENT) VALUES ('" + Session["UniCode"] + "','" + txtSQLStatement.Text.Replace("'", "\"") + "')";
        CISUTILITY.UpdateDBArray(strSQLStatement, "QS", ref strErrMsg);
        if (strErrMsg.Length > 0)
        {
            MsgShow("DB communication error, please contact with sponsor");
            return false;
        }
        return true;
    }
    #endregion

    #region Save Click Event
    /// <summary>
    /// Save function
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void pnlbtnSave_Click(object sender, EventArgs e)
    {

        if (Session["UniCode"] == null)
        {
            Response.Redirect("./CIS_TEMPLATE.aspx");
        }
        if (Session["user_id"] == null)
        {
            Response.Redirect("./check_login.aspx");
        }
        else
        {
            //檢查必填欄位及內容
            if (checkInput())
            {
                if (insert2editTable())
                {
                    string strErrMsg = "";
                    //已存在資料用Update，新資料用Insert
                    if (imgBtnSaveAs.Enabled)
                    {
                        string[] strSQL = new string[8];
                        strSQL[0] = "DELETE b2bsa.CIS_USER_DEFINE_MAIN WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[1] = "DELETE b2bsa.CIS_USER_DEFINE_SQLSTATEMENT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[2] = "DELETE b2bsa.CIS_USER_DEFINE_DETAIL WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[3] = "DELETE b2bsa.CIS_USER_DEFINE_FIELD WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[4] = "insert into b2bsa.CIS_USER_DEFINE_MAIN (ID,CREATE_BY,FILE_NAME,DESCRIPTION,CREATE_DATE) VALUES('" + Session["UniCode"] + "','" + Session["user_id"] + "','" + txtName.Text + "','" + txtDescription.Text + "',GETDATE())";
                        strSQL[5] = "insert into b2bsa.CIS_USER_DEFINE_SQLSTATEMENT SELECT ID,SQL_STATEMENT FROM b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[6] = "insert into b2bsa.CIS_USER_DEFINE_DETAIL SELECT ID,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[7] = "insert into b2bsa.CIS_USER_DEFINE_FIELD SELECT ID,FIELDS_NAME,FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        CISUTILITY.UpdateDBArray(strSQL, "QS", ref strErrMsg);
                    }
                    else
                    {
                        string[] strSQL = new string[5];
                        strSQL[0] = "DELETE b2bsa.CIS_USER_DEFINE_MAIN WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[1] = "insert into b2bsa.CIS_USER_DEFINE_MAIN (ID,CREATE_BY,FILE_NAME,DESCRIPTION,CREATE_DATE) VALUES('" + Session["UniCode"] + "','" + Session["user_id"] + "','" + txtName.Text + "','" + txtDescription.Text + "',GETDATE())";
                        strSQL[2] = "insert into b2bsa.CIS_USER_DEFINE_SQLSTATEMENT SELECT ID,SQL_STATEMENT FROM b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[3] = "insert into b2bsa.CIS_USER_DEFINE_DETAIL SELECT ID,OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[4] = "insert into b2bsa.CIS_USER_DEFINE_FIELD SELECT ID,FIELDS_NAME,FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        CISUTILITY.UpdateDBArray(strSQL, "QS", ref strErrMsg);
                        MsgShow(strSQL[2]);
                    }
                    if (strErrMsg.Length > 0)
                    {
                        MsgShow("save faile, please contact with system sponsor");
                    }
                    else
                    {
                        Response.Redirect("./CIS_TEMPLATE.aspx");
                    }
                }
                else
                {
                    MsgShow("save faile, please contact with system sponsor");
                }
            }
        }
    }
    #endregion

    #region Check Input Function
    /// <summary>
    /// 檢查Name必填
    /// 檢查Name/Description無單引號
    /// </summary>
    /// <returns>true：無錯誤</returns>
    private bool checkInput()
    {
        if (txtName.Text.ToString().Length == 0)
        {
            MsgShow("please key in name");
            txtName.Focus();
            return false;
        }
        if (txtName.Text.ToString().IndexOf("'") >= 0)
        {
            MsgShow("please remove keyword (single quote)");
            txtName.Focus();
            return false;
        }
        if (this.txtDescription.Text.ToString().IndexOf("'") >= 0)
        {
            MsgShow("please remove keyword (single quote)");
            txtDescription.Focus();
            return false;
        }
        return true;
    }
    #endregion

    #region Save As Function
    /// <summary>
    /// Save As function
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void pnlbtnSaveAs_Click(object sender, EventArgs e)
    {

        if (Session["user_id"] == null)
        {
            Response.Redirect("./check_login.aspx");
        }

        if (Session["UniCode"] == null)
        {
            Response.Redirect("./CIS_TEMPLATE.aspx");
        }
        else
        {
            //檢查必填欄位及內容
            if (checkInput())
            {
                if (insert2editTable())
                {
                    try
                    {
                        string strErrMsg = "";
                        string newUniCode = System.Guid.NewGuid().ToString().Replace("-", "");
                        string[] strSQL = new string[4];
                        strSQL[0] = "insert into b2bsa.CIS_USER_DEFINE_MAIN (ID,CREATE_BY,FILE_NAME,DESCRIPTION,CREATE_DATE) VALUES ('" + newUniCode + "','" + Session["user_id"] + "','" + txtName.Text + "','" + txtDescription.Text + "',GETDATE())";
                        strSQL[1] = "insert into b2bsa.CIS_USER_DEFINE_SQLSTATEMENT SELECT '" + newUniCode + "',SQL_STATEMENT FROM b2bsa.CIS_USER_DEFINE_SQLSTATEMENT_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[2] = "insert into b2bsa.CIS_USER_DEFINE_DETAIL SELECT '" + newUniCode + "',OPERAND,BRACKET,FIELD_SUBJECT,CONDITION,SQL_VALUE FROM b2bsa.CIS_USER_DEFINE_DETAIL_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        strSQL[3] = "insert into b2bsa.CIS_USER_DEFINE_FIELD SELECT '" + newUniCode + "',FIELDS_NAME,FIELDS_VALUE FROM b2bsa.CIS_USER_DEFINE_FIELD_EDIT WHERE ID = '" + Session["UniCode"] + "'";
                        CISUTILITY.UpdateDBArray(strSQL, "QS", ref strErrMsg);


                        if (strErrMsg.Length > 0)
                        {
                            MsgShow("DB access error , please contact with sponsor");
                        }
                        else
                        {
                            Response.Redirect("./CIS_TEMPLATE.aspx");
                        }

                    }
                    catch (Exception ee)
                    {

                        MsgShow("system error , please contact with sponsor");
                    }
                }
                else
                {
                    MsgShow("save faile, please contact with system sponsor");
                }
            }
        }
    }
    #endregion

    #region pnlModalPopup_Load
    /// <summary>
    /// Save panel popup load
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void pnlModalPopup_Load(object sender, EventArgs e)
    {
        //檢查為新增或更新資料
        if (!Page.IsPostBack)
        {
            string strSQL = "SELECT * FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE ID = '" + Session["UniCode"] + "'";
            string strErrMsg = "";
            DataTable dt = CISUTILITY.QueryDB(strSQL, "QS", ref strErrMsg);
            if (dt != null && dt.Rows.Count > 0)
            {
                this.imgBtnSaveAs.Enabled = true;
                txtName.Text = dt.Rows[0]["FILE_NAME"].ToString();
                txtDescription.Text = dt.Rows[0]["DESCRIPTION"].ToString();
            }
            if (strErrMsg.Length > 0)
            {
                MsgShow("DB access error, please contact with sponsor");
            }
        }
    }
    #endregion
}
