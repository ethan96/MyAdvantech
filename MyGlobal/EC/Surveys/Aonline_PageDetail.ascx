<%@ Control Language="VB" ClassName="Aonline_PageDetail" %>
<%@ Register Src="~/EC/Surveys/Aonline_AnswerType.ascx" TagName="AnswerType" TagPrefix="uc1" %>
<%@ Register Src="~/EC/Surveys/Aonline_CreateQuestion.ascx" TagName="CreateQuestion" TagPrefix="uc1" %>

<script runat="server">
    Public Property ShowIndex As Boolean
        Get
            Return ViewState("ShowIndex")
        End Get
        Set(ByVal value As Boolean)
            ViewState("ShowIndex") = value
        End Set
    End Property
    
    Protected Sub gv1_DataBound(sender As Object, e As System.EventArgs)
        
    End Sub
    
    Public Function GetAnswer() As DataSet
        Dim dt As New DataTable("ANSWER")
        dt.Columns.Add("Question_ID") : dt.Columns.Add("Answer") : dt.Columns.Add("Answer_ID") : dt.Columns.Add("Comment_ID")
        Dim dtComment As New DataTable("COMMENT")
        dtComment.Columns.Add("COMMENT_ID") : dtComment.Columns.Add("COMMENT")
        Try
            For Each row As GridViewRow In gv1.Rows
                Dim ucAnswer As Aonline_AnswerType = row.Cells(0).FindControl("ucAnswerType")
                Dim dtAnswers As DataTable = ucAnswer.GetAnswer()
                If dtAnswers IsNot Nothing AndAlso dtAnswers.Rows.Count > 0 Then
                    For Each answer As DataRow In dtAnswers.Rows
                        Dim r As DataRow = dt.NewRow()
                        r.Item("Question_ID") = ucAnswer.QuestionID
                        r.Item("Answer") = answer.Item("answer")
                        r.Item("Answer_ID") = answer.Item("answer_id")
                        r.Item("Comment_ID") = ""
                        If answer.Item("comment").ToString <> "" Then
                            Dim comment_id As String = NewId("SURVEY_RESULT_COMMENT")
                            r.Item("Comment_ID") = comment_id
                            Dim rc As DataRow = dtComment.NewRow()
                            rc.Item("COMMENT_ID") = comment_id
                            rc.Item("COMMENT") = answer.Item("comment")
                            dtComment.Rows.Add(rc)
                        End If
                        dt.Rows.Add(r)
                    Next
                End If
            Next
        Catch ex As Exception
            Throw New Exception("Aonline_PageDetail.aspx error:" + ex.ToString())
        End Try
        Dim ds As New DataSet
        ds.Tables.Add(dt) : ds.Tables.Add(dtComment)
        Return ds
    End Function
    
    Public Function CheckValid() As Boolean
        Dim is_valid As Boolean = True
        For Each row As GridViewRow In gv1.Rows
            Dim ucAnswer As Aonline_AnswerType = row.Cells(0).FindControl("ucAnswerType")
            If CBool(gv1.DataKeys(row.RowIndex).Values("is_required")) = True OrElse gv1.DataKeys(row.RowIndex).Values("question_type").ToString = Aonline_CreateQuestion.QuestionType.ContactInfo.ToString Then
                If ucAnswer.CheckValid() = False Then
                    is_valid = False : CType(row.Cells(0).FindControl("lblErrMsg"), Label).Visible = True
                End If
            End If
        Next
        Return is_valid
    End Function
    
    Private Shared Function NewId(ByVal TableName As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MYLocal", String.Format("select count(row_id) as counts from {1} where row_id='{0}'", tmpRowId, TableName)) _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Public Function GetContactInfo() As DataTable
        For Each row As GridViewRow In gv1.Rows
            Dim ucAnswer As Aonline_AnswerType = row.Cells(0).FindControl("ucAnswerType")
            If ucAnswer.QuestionType = Aonline_AnswerType.QuestionTypeEnum.ContactInfo.ToString Then
                Return ucAnswer.GetContactInfo()
            End If
        Next
        Return Nothing
    End Function

    Protected Sub btnDelQuestion_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "test", "Question ID: " + gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("question_id").ToString, True, "", "")
        Dim question_id As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("question_id").ToString
        Dim question_index As Integer = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("question_index")
        Dim question_type As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("question_type").ToString
        If DeleteQuestion(Request("sid"), question_id, question_index, question_type) Then
            gv1.DataBind()
            RaiseEvent Update()
        End If
    End Sub
    
    Public Shared Function DeleteQuestion(ByVal survey_id As String, ByVal question_id As String, ByVal question_index As Integer, ByVal question_type As String) As Boolean
        If dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("delete from survey_question where survey_id='{0}' and question_id='{1}'", survey_id, question_id)) > 0 Then
            Aonline_CreateQuestion.DeleteAnswer(question_id)
            Return Aonline_CreateQuestion.ReRankQuestionIndex(survey_id, question_index, question_type, False)
        End If
        Return False
    End Function
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If DataBinder.Eval(e.Row.DataItem, "QUESTION_SEQ").ToString = "" Then
                CType(e.Row.Cells(0).FindControl("lblQuestionSeq"), Label).Text = ""
                CType(e.Row.Cells(0).FindControl("lblQuestionTitle"), Label).Font.Bold = False
                CType(e.Row.Cells(0).FindControl("tdQuestionSeq"), HtmlTableCell).Width = "0"
            Else
                CType(e.Row.Cells(0).FindControl("tdQuestionSeq"), HtmlTableCell).Width = "20"
            End If
            CType(e.Row.Cells(0).FindControl("tdQuestionSeq"), HtmlTableCell).Visible = ViewState("ShowIndex")
            If Not ViewState("ShowIndex") Then CType(e.Row.Cells(0).FindControl("tdQuestionTitle"), HtmlTableCell).ColSpan = 2
            CType(e.Row.Cells(0).FindControl("tbQuestion"), HtmlTable).BgColor = DataBinder.Eval(e.Row.DataItem, "question_bg_color")
        End If
    End Sub

    Protected Sub btnDelQuestion_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request.ServerVariables("URL").Contains("EC/Surveys/SurveyContent.aspx") Then CType(sender, Button).Visible = False
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub
    
    Public Event Update()

    Protected Sub btnEditQuestion_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request.ServerVariables("URL").Contains("EC/Surveys/SurveyContent.aspx") Then CType(sender, Button).Visible = False
    End Sub

    Protected Sub btnEditQuestion_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        RaiseEvent Edit(gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("question_id").ToString)
    End Sub
    
    Public Event Edit(ByVal Question_Id As String)
    
    Protected Sub ucCreateQuestion_Update()
        RaiseEvent Update()
    End Sub

    Protected Sub btnAddQuestion_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("ucCreateQuestion"), Aonline_CreateQuestion).Initial()
        CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("mpeCreateQuestion"), ModalPopupExtender).Show()
    End Sub

    Protected Sub tbQuestion_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Request.ServerVariables("URL").Contains("EC/Surveys/SurveyContent.aspx") Then
            CType(sender, HtmlTable).Style.Add("border-style", "dotted")
            CType(sender, HtmlTable).Style.Add("border-width", "3px")
            CType(sender, HtmlTable).Style.Add("border-color", "#ebebeb")
        End If
    End Sub

    Protected Sub PanelAddQuestionForm_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request.ServerVariables("URL").Contains("EC/Surveys/SurveyContent.aspx") Then CType(sender, Panel).Visible = False
    End Sub
</script>
<table width="100%">
    <tr>
        <td>
            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" DataSourceID="sql1" Width="100%" EnableTheming="false" ShowHeader="false" BorderWidth="0" BorderColor="White" AlternatingRowStyle-Width="0" RowStyle-BorderWidth="0" OnDataBound="gv1_DataBound" DataKeyNames="question_id,question_index,question_type,question_seq,question_bg_color,is_required" OnRowDataBound="gv1_RowDataBound">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <table runat="server" id="tbQuestion" width="100%" border="0" cellpadding="0" cellspacing="0" style="padding:5px;" onload="tbQuestion_Load">
                                <tr><td colspan="2"><asp:Label runat="server" ID="lblErrMsg" Text='<%#Eval("err_message") %>' ForeColor="Red" Font-Bold="true" Visible="false" /></td></tr>
                                <tr>
                                    <th align="left" valign="top" runat="server" id="tdQuestionSeq">
                                        <font color="gray" size="3"><asp:Label runat="server" ID="lblQuestionSeq" Text='<%# Eval("question_seq")+"." %>' /></font>
                                    </th>
                                    <td runat="server" id="tdQuestionTitle" align='<%#Eval("horizontal_position") %>'><asp:Label runat="server" ID="lblErrTag" Text="*" ForeColor="Red" Visible='<%#Eval("is_required") %>' />&nbsp;<asp:Label runat="server" ID="lblQuestionTitle" Text='<%#Eval("question_title")%>' Font-Bold="true" />&nbsp;&nbsp;<asp:Button runat="server" ID="btnDelQuestion" Text="Delete" Width="50" OnClick="btnDelQuestion_Click" OnLoad="btnDelQuestion_Load" CausesValidation="false" />&nbsp;&nbsp;<asp:Button runat="server" ID="btnEditQuestion" Text="Edit" Width="50" CausesValidation="false" OnLoad="btnEditQuestion_Load" OnClick="btnEditQuestion_Click" /></td>
                                </tr>
                                <tr><td height="2" colspan="2"></td></tr>
                                <tr>
                                    <td></td>
                                    <td align="left">
                                        <uc1:AnswerType runat="server" ID="ucAnswerType" QuestionID='<%#Eval("question_id") %>' QuestionType='<%#Eval("question_type") %>' HasOtherField='<%#Eval("has_other_field") %>' Direction='<%#Eval("repeat_direction") %>' Columns='<%#Eval("repeat_columns") %>' IsQuestionRequired='<%#Eval("is_required") %>' />
                                    </td>
                                </tr>
                                <tr><td height='<%#Eval("question_interval") %>' colspan="2"></td></tr>
                            </table>
                            <asp:Panel runat="server" ID="PanelAddQuestionForm" OnLoad="PanelAddQuestionForm_Load">
                                <table width="100%" border="0">
                                    <tr><td height="20"></td></tr>
                                    <tr>
                                        <td align="center">
                                            <asp:Button runat="server" ID="btnAddQuestion" Text="Add Question Here" Width="130" Height="30" CausesValidation="false" OnClick="btnAddQuestion_Click" />
                                            <asp:LinkButton runat="server" ID="linkCreateQuestion" CausesValidation="false" />
                                            <ajaxToolkit:ModalPopupExtender runat="server" ID="mpeCreateQuestion" PopupControlID="PanelCreateQuestion" 
                                                TargetControlID="linkCreateQuestion" BackgroundCssClass="modalBackground" />
                                            <asp:Panel runat="server" ID="PanelCreateQuestion" Height="750" ScrollBars="Auto">
                                                <uc1:CreateQuestion runat="server" ID="ucCreateQuestion" QuestionIndex='<%#Eval("question_index")+1 %>' OnUpdate="ucCreateQuestion_Update" />
                                            </asp:Panel>    
                                        </td>
                                    </tr>
                                    <tr><td height="20"></td></tr>
                                </table>
                            </asp:Panel>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings:MYLocal %>"
                SelectCommand="select a.question_id, a.question_index, a.question_title, a.question_type, a.has_other_field, a.repeat_direction, a.repeat_columns, a.question_seq, a.horizontal_position, a.question_bg_color, a.question_interval, a.is_required, isnull(b.err_message,'') as err_message from survey_question a left join survey_err_message b on a.question_id=b.question_id and b.answer_id='' where a.survey_id=@survey_id order by a.question_index">
                <SelectParameters>
                    <asp:QueryStringParameter Name="survey_id" QueryStringField="sid" Type="String" />
                </SelectParameters>
            </asp:SqlDataSource>
        </td>
    </tr>
</table>