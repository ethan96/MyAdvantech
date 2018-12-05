<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master"
    Title="CBOM---Phase-Out Checking" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        If Not Page.IsPostBack Then
            BindORGDL()
            BindCList()
            orgdl.Visible = False
            If Util.IsAEUIT() Then
                orgdl.Visible = True
            End If
        End If
    End Sub
    Protected Sub InitialDg()
        Dim StrCategory As String = ""
        'Response.Write(hd1.Value+"<hr/>")
        If hd1.Value <> "" Then
            Me.ViewState("lstElement") = hd1.Value.Trim().Substring(0, hd1.Value.Trim().Length - 1)
            ' Response.Write(Me.ViewState("lstElement"))
            'Exit Sub
            Dim ArrEle() As String = Me.ViewState("lstElement").Split(",")
            Dim i As Integer = 0
            Me.lstParticipants.Items.Clear()
            Dim lstItem As System.Web.UI.WebControls.ListItem
            For i = 0 To ArrEle.Length - 1
                lstItem = New System.Web.UI.WebControls.ListItem
                lstItem.Text = ArrEle(i)
                lstItem.Value = ArrEle(i)
                Me.lstParticipants.Items.Add(lstItem)
                If i = 0 Then
                    StrCategory = StrCategory & "'" & ArrEle(i) & "'"
                Else
                    StrCategory = StrCategory & ",'" & ArrEle(i) & "'"
                End If
            Next
        End If
        If StrCategory = "" Then
            StrCategory = "''"
        End If
        Dim T_strSelect As String = ""
        Dim T_strSelect1 As String = ""
        Dim T_strSelect2 As String = ""
        T_strSelect1 = " Select C.CATEGORY_NAME,P.Status,C.CATEGORY_DESC,C.Parent_Category_ID as PARENT_CATEGORY_ID" & _
                      " from CBOM_CATALOG_CATEGORY as C, SAP_PRODUCT_ORG as P " & _
                      " where P.ORG_ID ='" + Session("org_id") + "' AND C.Category_Type='Component'  " & _
                      " and C.Parent_Category_Id in  (" & StrCategory & ") " & _
                      " and P.Part_No = C.Category_id and P.Status not in ('A','H','N')  and C.ORG ='" + orgdl.SelectedValue + "'"
        T_strSelect2 = " Select C.CATEGORY_NAME,'O' as STATUS,C.CATEGORY_DESC,C.Parent_Category_ID as PARENT_CATEGORY_ID" & _
                      " from CBOM_CATALOG_CATEGORY as C " & _
                      " where C.ORG ='" + orgdl.SelectedValue + "' AND C.Category_Type='Component'  " & _
                      " and C.Parent_Category_Id in  (" & StrCategory & ") " & _
                      " and C.Category_id not in (select distinct p.part_no from SAP_PRODUCT_ORG p where P.ORG_ID ='" + Session("org_id") + "' AND p.status in ('A','H','N')) "
        T_strSelect = T_strSelect1 & " UNION " & T_strSelect2 & " order by C.CATEGORY_NAME"
        SqlDataSource1.SelectCommand = T_strSelect
        'Response.Write(T_strSelect)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        InitialDg()
    End Sub
   
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        
    End Sub

    Protected Sub txtPartNO_TextChanged(sender As Object, e As System.EventArgs)
        ' BindCList()
    End Sub
    Private Sub BindCList()
        Dim strSQLQry As String = ""
        strSQLQry &= "select distinct top 20 category_id,category_name " & _
                     "from CBOM_CATALOG_CATEGORY " & _
                     "where (category_type='Category' or Category_name like '%BTO') " & _
                     "and category_name like '" & Me.txtPartNO.Text.Trim & "%' and org ='" + orgdl.SelectedValue + "'" & _
                     "order by category_name"
        Dim CBOMDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, strSQLQry)
        Me.Element_List.DataSource = CBOMDT.DefaultView
        Me.Element_List.DataTextField = "category_name"
        Me.Element_List.DataValueField = "category_id"
        Me.Element_List.DataBind()
    End Sub
    Private Sub BindORGDL()
        Dim strSQLQry As String = "select distinct ORG from  CBOM_CATALOG_CATEGORY where ORG is not null and  ORG <> ''"
        Dim CBOMDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, strSQLQry)
        Me.orgdl.DataSource = CBOMDT.DefaultView
        Me.orgdl.DataTextField = "ORG"
        Me.orgdl.DataValueField = "ORG"
        Me.orgdl.DataBind()
        For Each lt As ListItem In orgdl.Items
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If lt.Value = Session("org") Then
            If lt.Value = Left(Session("org_id").ToString.ToUpper, 2) Then
                lt.Selected = True
            End If
        Next
    End Sub

    Protected Sub Search1_Click(sender As Object, e As System.EventArgs)
        BindCList()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" language="javascript">
        function Change_List(strKey) {
            var i = 0;
            var Obj = document.getElementById("ctl00__main_Element_List");

            var len = strKey.length;
            for (i = 0; i < Obj.length; i++) {
                if (Obj.options[i].value.substring(0, len).toUpperCase() == strKey.toUpperCase()) {
                    Obj.selectedIndex = i;
                    break;
                }
            }
        }

        function BtnMovOut_onclick(frm_mail) {
            for (var i = frm_mail.ctl00__main_Element_List.length - 1; i >= 0; i--) {
                var idx;
                if (frm_mail.ctl00__main_Element_List.options[i].selected == true) {
                    idx = frm_mail.ctl00__main_lstParticipants.length
                    frm_mail.ctl00__main_lstParticipants.options[idx] = new Option(frm_mail.ctl00__main_Element_List[i].text, frm_mail.ctl00__main_Element_List[i].value);
                    frm_mail.ctl00__main_Element_List.options[i] = null;

                }
            }
        }

        function BtnMovIn_onclick(frm_mail) {
            for (var i = frm_mail.ctl00__main_lstParticipants.length - 1; i >= 0; i--) {
                var idx;
                if (frm_mail.ctl00__main_lstParticipants.options[i].selected == true) {
                    if (frm_mail.ctl00__main_lstParticipants.options[i].value != "") {
                        idx = frm_mail.ctl00__main_Element_List.length;
                        frm_mail.ctl00__main_Element_List.options[idx] = new Option(frm_mail.ctl00__main_lstParticipants[i].text, frm_mail.ctl00__main_lstParticipants[i].value);
                        frm_mail.ctl00__main_lstParticipants.options[i] = null;

                    }
                }
            }
        }

        function DataSheet(frm_mail) {
            for (var i = frm_mail.ctl00__main_lstParticipants.length - 1; i >= 0; i--) {
                frm_mail.ctl00__main_lstParticipants.options[i].selected = true;
            }
        }	
    </script>
    <table width="100%">
        <tr>
            <td style="vertical-align: top;">
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top;" width="98%">
                <table width="100%">
                    <tr>
                        <td style="height: 6px;">
                            <a href="../home_old.aspx">Home</a>>>><a href="../Admin/B2B_Admin_portal.aspx">Admin</a>>>>PhaseOut
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h2>
                                Phase-Out Checking</h2>
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 6px;">
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset style="width: 900px">
                                <legend style="background-color: White;">CBOM Select</legend>
                                <table width="100%">
                                    <tr>
                                        <td colspan="3">
                                            <asp:DropDownList runat="server" ID="orgdl">
                                            </asp:DropDownList>
                                            <asp:TextBox runat="server" ID="txtPartNO" Width="180px" OnTextChanged="txtPartNO_TextChanged"></asp:TextBox>
                                            <asp:Button runat="server" Text="Search" ID="Search1" OnClick="Search1_Click" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <hr />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 350px">
                                            <asp:UpdatePanel runat="server" ID="up1">
                                                <ContentTemplate>
                                                    <asp:ListBox ID="Element_List" runat="server" Rows="10" Width="350px" multiple="true"
                                                        ondblclick="BtnMovOut_onclick(this.form);"></asp:ListBox>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="Search1" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                        <td style="width: 150px" valign="middle" align="center">
                                            <input type="button" id="btnMoveOut" name="btnMoveOut" value="Join >>" onclick="BtnMovOut_onclick(this.form);" /><br />
                                            <br />
                                            <input type="button" id="btnMoveIn" name="btnMoveIn" value="<< Remove" onclick="BtnMovIn_onclick(this.form);" /><br />
                                            <br />
                                            <asp:Button runat="server" ID="btnSubmit" Text="Check" OnClick="btnSubmit_Click"
                                                OnClientClick="SetValues();" />
                                            <asp:HiddenField ID="hd1" runat="server" />
                                            <script type="text/javascript">
                                                function SetValues() {
                                                    var loSelect = document.getElementById("<%= lstParticipants.ClientID  %>");
                                                    var lnlength = loSelect.options.length;
                                                    var values = ""; for (var i = 0; i < lnlength; i++)
                                                    { values += loSelect.options[i].value + ","; }
                                                    document.getElementById('<%= hd1.ClientID  %>').value = values;

                                                }
                                            </script>
                                        </td>
                                        <td style="width: 350px">
                                            <asp:ListBox ID="lstParticipants" runat="server" Rows="10" Width="350px" multiple="true"
                                                ondblclick="BtnMovIn_onclick(this.form);"></asp:ListBox>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 6px;">
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle"
                                id="Table3">
                                <tr>
                                    <td style="padding-left: 10px; border-bottom: #ffffff 1px solid; height: 20px; background-color: #6699CC"
                                        align="left" valign="middle" class="text">
                                        <font color="#ffffff"><b>BtosHistory List</b></font>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="GridView1" DataSourceID="SqlDataSource1" OnRowDataBound="GridView1_RowDataBound"
                                            AllowPaging="True" PageIndex="0" PageSize="30" Width="100%">
                                        </asp:GridView>
                                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
                                        </asp:SqlDataSource>
                                    </td>
                                </tr>
                                <tr>
                                    <td id="tdTotal" align="right" style="background-color: #ffffff" runat="server">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 6px;">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="vertical-align: bottom;">
            </td>
        </tr>
    </table>
</asp:Content>
