<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="CTOS Note Category Admin" %>

<script runat="server">
    Dim l_strSQLCmd As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_inc1.ValidationStateCheck()
        SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        l_strSQLCmd = "Select '' as SO_BANK, " & _
      " a.PART_NO as PART_NO, " & _
      " a.SEQ_NUMBER " & _
        " FROM CBOM_CATEGORY_CTOS_NOTE a "
	
        l_strSQLCmd = l_strSQLCmd + " ORDER BY a.SEQ_NUMBER "
        Me.SqlDataSource1.SelectCommand = Me.l_strSQLCmd
        If Not Page.IsPostBack Then
            GridView1.DataBind()
        End If
    End Sub

    Protected Sub btnSubmit_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs)
        If dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select part_no from CBOM_CATEGORY_CTOS_NOTE where part_no ='" & Me.txtPartNo.Value.Trim() & "' and SEQ_NUMBER =" & Me.txtSeqNo.Value.Trim() & "").Rows.Count > 0 Then
            Me.Label1.Text = "Data already exsits."
        Else
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, "insert into CBOM_CATEGORY_CTOS_NOTE(part_no,seq_number) values('" & Me.txtPartNo.Value.Trim() & "'," & Me.txtSeqNo.Value.Trim() & ")")
            Response.Redirect("CtosNoteAdmin.aspx")
        End If
    End Sub
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Then
            e.Row.Cells(1).Text = "No"
            e.Row.Cells(2).Text = "Part No"
            e.Row.Cells(3).Text = "Seq No."
           
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(1).Text = e.Row.RowIndex + 1
            
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td>
                <!--include virtual="/includes/header_inc.asp" -->

            </td>
        </tr>
        <tr>
            <td align="center">
                <table id="Table2" width="60%">
                    <tr>
                        <td align="right">
                            <img src="../images/title-dot.gif" border="0" width="25" height="17"></td>
                        <td class="euPageTitle" width="95%" align="left"><b>CTOS Note Category Admin</b></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td align="center">
                <table width="60%" cellspacing="0" cellpadding="0" border="0">
                    <!--form name="prodCustDict" action="CtosNoteAdd.asp" method="post"-->
                    <!--<input type="hidden" value="etos" name="srcpage"></input>-->
                    <tr>
                        <td style="border: #4f60b2 2px solid">
                            <table width="100%" height="100%" cellspacing="1" cellpadding="2" id="Table1" border="0" bordercolor="#cfcfcf">
                                <tr bgcolor="#bec4e3">
                                    <td colspan="2" height="20" class="text"><font color="#303d83"><b>Please fill in the information below to add products</b></font></td>
                                </tr>
                                <tr>
                                    <td width="160px" align="right" bgcolor="#f0f0f0" class="text">Part No &nbsp;&nbsp;</td>
                                    <td bgcolor="#f0f0f0" class="text">&nbsp;<input type="text" name="txtpartno" id="txtPartNo" runat="server"></input>&nbsp;&nbsp;
										<input type="button" onclick="PickWin('/order/PickPartNo.aspx?Type=CTOSNOTE&Element=ctl00__main_txtPartNo', this.form);" value='Pick' style="cursor: hand" id="btnPick" name="Button1" runat="server" visible="false"></input><asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtPartNo" ErrorMessage="Please input Item No"></asp:RequiredFieldValidator></td>
                                </tr>
                                <tr>
                                    <td align="right" bgcolor="#f0f0f0" class="text">Sequence Number &nbsp;&nbsp;</td>
                                    <td bgcolor="#f0f0f0" class="text">&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;
                                        <input type="text" name="txtSeqNo" id="txtSeqNo" runat="server"></input>&nbsp;&nbsp;<asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ControlToValidate="txtSeqNo"
                                            ErrorMessage="must digit less then 1000" ValidationExpression="\d{3}|\d{2}|\d{1}"></asp:RegularExpressionValidator>
                                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp;&nbsp;
                                </tr>


                                <tr>
                                    <td bgcolor="#ffffff" colspan="2" valign="middle" align="center" height="30px">
                                        <input type="submit" value=">> Submit >>" name="button" id="btnSubmit" style="cursor: hand;" runat="server" onserverclick="btnSubmit_ServerClick"></td>
                                </tr>

                            </table>
                        </td>
                    </tr>
                    <!--/form-->
                    <tr>
                        <td>&nbsp;</td>
                    </tr>
                    &nbsp;<asp:Label ID="Label1" runat="server" Width="320px" ForeColor="Red"></asp:Label><tr>
                        <td colspan="2" width="100%">
                            <!--include file="CtosNoteAdmin_main.asp" -->

                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle" id="Table3">
                                <tr>
                                    <td style="padding-left: 10px; border-bottom: #ffffff 1px solid; height: 20px; background-color: #6699CC" align="left" valign="middle" class="text">
                                        <font color="#ffffff"><b>Product Customer Dictionary</b></font></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="GridView1"
                                            DataSourceID="SqlDataSource1"
                                            OnRowDataBound="GridView1_RowDataBound" DataKeyNames="PART_NO" AllowPaging="True" PageIndex="0" PageSize="30" Width="100%">
                                            <Columns>
                                                <asp:CommandField ShowDeleteButton="true" HeaderText="Del" />
                                            </Columns>
                                        </asp:GridView>




                                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"
                                            DeleteCommand="delete from CBOM_CATEGORY_CTOS_NOTE where PART_NO=@PART_NO">
                                            <DeleteParameters>
                                                <asp:Parameter Type="String" Name="PART_NO" />
                                            </DeleteParameters>

                                        </asp:SqlDataSource>
                                    </td>
                                </tr>
                                <tr>
                                    <td id="tdTotal" align="right" style="background-color: #ffffff" runat="server"></td>
                                </tr>
                            </table>

                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="15"></td>
        </tr>
        <tr>
            <td></td>
        </tr>
    </table>
    <script language="javascript" type="text/javascript">
        function PickWin(Url) {
            //alert (Url)
            //var part_no = document.getElementById("txtPartNo")
            var aa = document.getElementById("ctl00__main_txtPartNo")
            var part_no = aa.value
            //alert (part_no)
            Url = Url + "&PartNo=CTOS-" + part_no
            //alert(Url);
            window.open(Url, "pop", "height=570,width=520,scrollbars=yes");
        }
        //-->
    </script>
</asp:Content>

