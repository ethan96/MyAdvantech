<%@ Page Title="MyAdvantech - Project Detail" ValidateRequest="false" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="../Includes/ProjectDetail.ascx" TagName="ProjectDetail" TagPrefix="uc1" %>
<%@ Register Src="../Includes/ProjectProducts.ascx" TagName="ProjectProducts" TagPrefix="uc2" %>
<script runat="server">  
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPrice(ByVal pn As String) As Double
        If pn.Trim() = "" OrElse HttpContext.Current.Session Is Nothing _
            OrElse HttpContext.Current.Session("company_id") Is Nothing _
            OrElse HttpContext.Current.Session("company_id").ToString() = "" Then Return 999999
        pn = pn.Trim().Replace("'", "''").ToUpper()
        Dim rp As Double = Util.GetSAPPrice(pn, HttpContext.Current.Session("company_id"))
        Return rp
    End Function
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestPN(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 20 a.PART_NO  "))
            .AppendLine(String.Format(" from sap_product a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO  "))
            .AppendLine(String.Format(" where left(a.part_no,1) not in ('1','2','9','Y','#','$') and a.material_group not in ('T','ODM') and a.PART_NO like '{0}%' and b.ORG_ID='{1}' and c.PRODUCT_STATUS in ('A','N','H','M1') and c.DLV_PLANT='{2}H1' ", _
                                      prefixText.Trim().Replace("'", "").Replace("*", "%"), HttpContext.Current.Session("org_id").ToString(), Left(HttpContext.Current.Session("org_id"), 2)))
            .AppendLine(String.Format(" order by a.PART_NO  "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.tbPI.Attributes("autocomplete") = "off" : Me.cpprice.Attributes("readonly") = "readonly"
            If Session("org_id") IsNot Nothing AndAlso Session("org_id") = "EU50" Then Session("org_id") = "EU10"
            If Util.IsANAPowerUser() OrElse Util.IsAEUIT() Then hySyncPN.Visible = True
            If Request("req") IsNot Nothing Then
                tid.Value = Trim(Request("req")) : hlback.NavigateUrl = "./ProjectRegist.aspx?req=" + tid.Value
            Else
                Response.Redirect("./ProjectRegist.aspx")
            End If
            ProjectProducts1.bindsmg()
            If Session("RBU") = "AAC" Then
                TRdtp.Visible = False
                TReuc.Visible = False
            End If
        End If
    End Sub
    Protected Sub btnAddProduct_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            lbAddProdMsg.Text = ""
            If tbPI.Text.Trim() = "" _
                OrElse CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(part_no) from sap_product where part_no='{0}'", tbPI.Text.Trim().Replace("'", "")))) <> 1 Then
                lbAddProdMsg.Text = "Input product is invalid." : Exit Sub
            End If
            If Double.TryParse(cpprice.Text, 0) = False Then
                lbAddProdMsg.Text = "CP Price is empty, please contact Advantech."
                Exit Sub
            End If
            If Session("RBU") = "AAC" Then
                tbcpricing.Text = "0"
                tbTP.Text = "0"
            End If
            If tbcpricing.Text.Trim <> "" AndAlso Double.TryParse(tbcpricing.Text, 0) = False Then
                lbAddProdMsg.Text = "Dist Target Price should be a numeric number."
                Exit Sub
            End If
            If Integer.TryParse(tbQTY.Text, 0) = False Then
                lbAddProdMsg.Text = "Qty should be an integer."
                Exit Sub
            End If
            If tbTP.Text.Trim <> "" AndAlso Double.TryParse(tbTP.Text, 0) = False Then
                lbAddProdMsg.Text = "End User Cost should be a numeric number."
                Exit Sub
            End If
            Dim CPricing As Double = 0, TargetPricing As Double = 0
            If Double.TryParse(tbcpricing.Text, 0) = True Then
                CPricing = Double.Parse(tbcpricing.Text.Trim)
            End If
            If Double.TryParse(tbTP.Text, 0) = True Then
                TargetPricing = Double.Parse(tbTP.Text.Trim)
            End If
            USPrjRegUtil.DTList_AddLine(tid.Value, tbPI.Text, Integer.Parse(tbQTY.Text), _
                                                 IIf(cpprice.Text.Trim <> "", Double.Parse(cpprice.Text), 0), _
                                                 CPricing, _
                                                TargetPricing, _
                                                 HttpUtility.HtmlEncode(tbcomm.Text.Trim).Replace("'", "''").Replace(vbCrLf, "<br/>"))
            ProjectProducts1.bindsmg()
            cpprice.Text = ""
            tbPI.Text = ""                        
        Catch ex As Exception
            lbAddProdMsg.Text = ex.ToString()
            Exit Sub
        End Try
    End Sub
    

    Protected Sub btnSubmitProj_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbMsg.Text = "" : lbAddProdMsg.Text = ""
        If Not USPrjRegUtil.checkprods(tid.Value) Then
            lbMsg.Text = "Please add at least one product"
            Exit Sub
        End If
        Dim M As New Us_Prjreg_M(tid.Value)
        If M IsNot Nothing AndAlso M.Opty_Id.ToString.Trim <> "" Then
            lbMsg.Text = "This Project Registration have been submitted. "
            Exit Sub
        End If
        '------------------------------------------
        Dim AccountRowID As String = USPrjRegUtil.GetAccountRowID(Session("company_id"))
        Dim ContactRowId As String = USPrjRegUtil.GetContactRowId(Session("user_id"))
        Dim TOTALrevenue As String = USPrjRegUtil.GetTOTALrevenue(M.Request_id)
        Dim strPosId As String = "", strOwner As String = ""
        Dim Returnint As Integer = USPrjRegUtil.Get_Owner_PosId(AccountRowID, strOwner, strPosId)
        Dim PrimaryUserid As String = USPrjRegUtil.GetPrimaryUseridByEmal(M.AdvSalesContact)
        Dim Curr As String = USPrjRegUtil.GetCurr(AccountRowID)
        Dim ws As New aeu_eai2000.Siebel_WS
        ws.Timeout = -1 : ws.UseDefaultCredentials = True
        Dim EndCustomerRowID As String = ""
        Dim eCoveWs As New eCoverageWS.WSSiebel, res As eCoverageWS.RESULT = Nothing
        Try
            'Dim OptyId As String = ws.Import_OpportunityNew(M.Org_ID, strPosId, PrimaryUserid, EndCustomerRowID, "", "", ContactRowId, "", "", "", M.Project_Name, M.Project_Name, "", "", "Funnel Sales Methodology", _
            '                                         "10% Validating", "", M.Expire_Date, TOTALrevenue, "10", "Pending", "", "", "", "", "", True, AccountRowID)
            
            eCoveWs.Timeout = 500 * 1000
            Dim emp As New eCoverageWS.EMPLOYEE, oppty As New eCoverageWS.OPPTY
            emp.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : emp.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")
            With oppty
                .PROJ_NAME = M.Project_Name : .DESP = M.Project_Name : .BIZ_GROUP = Nothing
                .CHANNEL = "CSF" : .IS_ASSIGN_TO_PARTNER = True : .CLOSE_DATE = M.Expire_Date
                .ORG = M.Org_ID : .LEAD_QUALITY = "3-High" : .PROGRAM = Nothing
                .SUPPORT_REQUEST = Nothing : .REVENUE = TOTALrevenue : .SUCCESS_FACTOR = Nothing
                .REASON_WON_LOST = Nothing : .CURRENCY_CODE = "USD" : .SALES_METHOD = "Funnel Sales Methodology"
                .SALES_STAGE = "10% Validating" : .ACC_ROW_ID = Nothing : .CON_ROW_ID = ContactRowId
                .PARTNER_ROW_ID = AccountRowID : .PRI_POS_ID = strPosId
                .SRC_ID = "1-IZH87V" 'MyAdvantech Project Registration
            End With
            res = eCoveWs.AddOppty(emp, oppty)
            Dim OptyId As String = res.ROW_ID
            If OptyId.ToLower.Trim = "false" OrElse OptyId.Trim = "" Then
                Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", _
                               "Create Opty Failed in US Prj RegId:" + M.Request_id, "eCoverage WS returned error message:" + res.ERR_MSG, True, "", "")
                lbMsg.Text = " Sieble Create Opty Failed."
                Exit Sub
            End If
            M.Opty_Id = OptyId : M.UPDAYE_M() : Threading.Thread.Sleep(2000) : MYSIEBELDAL.SyncSiebelOpty(OptyId)
        Catch ex As Exception
            If res IsNot Nothing Then ex.Data("eCoverageWSErr") = res.ERR_MSG
            Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Create Opty Failed in US Prj RegId:" + M.Request_id, ex.ToString(), True, "", "")
            lbMsg.Text = " Sieble Create Opty Failed."
            Exit Sub
        End Try
        Try
            USPrjRegUtil.SendEmail(M.Request_id, 0)
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Send Email Failed in US Prj RegId:" + M.Request_id, ex.ToString(), True, "", "")
        End Try
        lbMsg.Text = " Thanks for submitting your project registration application.  An Advantech representative will be in contact with you shortly."
        If Not (Session("user_id").ToString = "ming.zhao@advantech.com.cn.cn") Then TimerGo2ProjList.Enabled = True
    End Sub
    Protected Sub TimerGo2ProjList_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim jscript As String = "location.href = 'ProjectRegList.aspx';"
        UI.ScriptManager.RegisterStartupScript(Me.upMsg, Me.upMsg.GetType(), "jalert", jscript, True)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="tid" />
    <table style="height: 100%;" cellpadding="0" cellspacing="0" width="95%" align="center"
        border="0">
        <tr>
            <td valign="middle" colspan="2" height="50">
                <h2>
                    Channel Partner Project Registration Application <span style="text-align: right;
                        float: right;">
                        <asp:HyperLink ID="hlback" Font-Bold="true" ForeColor="Tomato" runat="server"> << Previous</asp:HyperLink></span>
                </h2>
                <div>
                    This project registration is subject to Advantech review. Upon approval, you will
                    receive an email notification.</div>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <uc1:ProjectDetail ID="ProjectDetail1" runat="server" />
            </td>
        </tr>
        <tr>
            <td colspan="2" class="projecttitle">
                Products included in Project:
            </td>
        </tr>
        <tr>
            <td width="100%" colspan="2">
                <asp:UpdatePanel runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <uc2:ProjectProducts ID="ProjectProducts1" runat="server" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnAddProduct" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td colspan="2" class="projecttitle">
                Add Products:
            </td>
        </tr>
        <tr>
            <td colspan="2">
                For configured systems please enter the main Advantech product(s) and make a note
                in the Comments field that this is a configured system.
            </td>
        </tr>
        <tr>
            <td width="520" valign="top">
                <asp:UpdatePanel runat="server" ID="upAddProd" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td width="140" style="font-weight: bolder" align="right">
                                    Product Item:<span style="color: Red">*</span>
                                </td>
                                <td align="left">
                                    <asp:TextBox ID="tbPI" runat="server" Width="150px" />
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="tbPI"
                                        ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="0"
                                        OnClientItemSelected="PNSelected" />
                                    <asp:HyperLink runat="server" ID="hySyncPN" Text="<br>Sync Product (internal only)"
                                        Visible="false" NavigateUrl="~/Admin/SyncSingleProduct.aspx" Target="_blank" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bolder" align="right">
                                    Distributor PO Price:<span style="color: Red">*</span>
                                </td>
                                <td>
                                    <asp:TextBox ID="cpprice" BackColor="#c0c0c0" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="TRdtp">
                                <td style="font-weight: bolder" align="right">
                                    Distributor Target Price:<span style="color: Red"></span>
                                </td>
                                <td align="left">
                                    <asp:TextBox ID="tbcpricing" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bolder" align="right">
                                    Annual Qty:<span style="color: Red">*</span>
                                </td>
                                <td align="left">
                                    <asp:TextBox ID="tbQTY" runat="server" />
                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                                        TargetControlID="tbQTY" FilterMode="ValidChars" FilterType="Numbers" />
                                </td>
                            </tr>
                            <tr runat="server" id="TReuc">
                                <td style="font-weight: bolder" align="right">
                                    End User Cost:<span style="color: Red"></span>
                                </td>
                                <td align="left">
                                    <asp:TextBox ID="tbTP" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnAddProduct" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
            <td align="left">
                <table border="0">
                    <tr>
                        <td style="font-weight: bolder" align="left">
                            Comments:
                        </td>
                    </tr>
                    <tr>
                        <td align="left">
                            <asp:TextBox ID="tbcomm" TextMode="MultiLine" Height="100" Width="400" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight: bolder" align="center">
                            <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbAddProdMsg" Font-Bold="true" ForeColor="Red" Font-Size="Larger" />
                                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Red" Font-Size="Larger" />
                                    <br />
                                    <asp:Button ID="btnAddProduct" runat="server" Text="Add Product" OnClick="btnAddProduct_Click" />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    <asp:Button ID="btnSubmitProj" runat="server" Text="Submit" OnClick="btnSubmitProj_Click" /><br />
                                    <asp:Label runat="server" ID="Label1" ForeColor="Gray" Font-Size="12px" Text="Please wait about two minutes after the submission." />
                                    <asp:Timer runat="server" ID="TimerGo2ProjList" Interval="2500" Enabled="false" OnTick="TimerGo2ProjList_Tick" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnSubmitProj" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                        </tr>
                    <tr>
                            <td style="font-weight: bolder" align="right">
                                Dated:<asp:Label ID="lbdate" runat="server" Text=""></asp:Label>
                            </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function PNSelected(source, eventArgs) {
            //            alert(" Key : " + eventArgs.get_text() + " Value : " + eventArgs.get_value());
            //            alert(source.get_element().id);
            var txtID = source.get_element().id;
            //alert(txtID);
            if (txtID) {
                FillModelCPPrice(eventArgs.get_value(), txtID);
                //                alert('1');
                //                document.getElementById(txtID).value = 'aaaaaaaa';
                //                alert('2');
            }
        }
        function FillModelCPPrice(modelno, sourceid) {
            PageMethods.GetPrice(modelno,
                function (pagedResult, eleid, methodName) {
                    //alert(pagedResult);
                    var p = pagedResult;
                    if (p) {
                        if (p > 0) {
                            // var pid = sourceid.replace('_main$tbPI', '_main$cpprice');
                            //alert(p);
                            document.getElementById('<%=cpprice.ClientID %>').value = p;
                        }
                        else { document.getElementById('<%=cpprice.ClientID %>').value = -1; }
                    }
                    else { document.getElementById('<%=cpprice.ClientID %>').value = -1; }
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                }
            );
        }
    </script>
    <script language="javascript">
        function $(o) { return document.getElementById(o); }
        //            function validatenum(tobj) {
        //                var re = /^[0-9]+.?[0-9]*$/;

        //                if (!re.test(tobj.value)) {
        //                    return true;
        //                }

        //            }
        //            function Validate() {
        //                var obj;
        //                obj = $('<%=tbQTY.ClientID %>');

        //                if (validatenum(obj) || obj.value == "") {
        //                    alert("Input quantity should be a numeric number")
        //                    obj.focus();
        //                    return false;
        //                }
        //                obj = $('<%=tbTP.ClientID %>');
        //                if (validatenum(obj) || obj.value == "") {
        //                    alert("The Target Pricing should be a numeric number")
        //                    obj.focus();
        //                    return false;
        //                }




        //        }
    </script>
</asp:Content>
