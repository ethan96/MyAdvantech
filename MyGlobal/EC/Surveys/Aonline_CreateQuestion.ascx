<%@ Control Language="VB" ClassName="Aonline_CreateQuestion" %>
<%@ Register TagPrefix="ed" Namespace="OboutInc.Editor" Assembly="obout_Editor" %>

<script runat="server">
    Public Enum QuestionType
        MultipleChoiceOneAnswer
        MultipleChoiceMultipleAnswers
        Essay
        Ranking
        TextBoxs
        Descritive
        ContactInfo
    End Enum

    Public Enum ContactInfo
        Email
        Name
        Company
        Phone
        Job
        Address
        City
        Country
        Zip
    End Enum

    Public Property QuestionIndex() As Integer
        Get
            Return ViewState("Question_Index")
        End Get
        Set(ByVal value As Integer)
            ViewState("Question_Index") = value
        End Set
    End Property

    Protected Sub ddlQuestion_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        VisibleControl()
    End Sub

    Sub VisibleControl()
        PanelQuestion.Visible = True : mvAnswer.ActiveViewIndex = 0 : mvAnswer.Visible = True
        Select Case ddlQuestion.SelectedValue
            Case QuestionType.MultipleChoiceOneAnswer.ToString
                PanelDirection.Visible = True : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
                PanelAnswer.Visible = True : PanelComment.Visible = True : PanelRequired.Visible = True : PanelOther.Visible = False
            Case QuestionType.MultipleChoiceMultipleAnswers.ToString
                PanelDirection.Visible = True : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
                PanelAnswer.Visible = True : PanelComment.Visible = True : PanelRequired.Visible = True : PanelOther.Visible = False
            Case QuestionType.Essay.ToString
                PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
                PanelAnswer.Visible = False : PanelComment.Visible = False : PanelRequired.Visible = True : PanelOther.Visible = False
            Case QuestionType.Ranking.ToString
                PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
                PanelAnswer.Visible = True : PanelComment.Visible = False : PanelRequired.Visible = True : PanelOther.Visible = True
            Case QuestionType.Descritive.ToString
                PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = True
                mvAnswer.Visible = False
            Case QuestionType.ContactInfo.ToString
                PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
                mvAnswer.ActiveViewIndex = 1
            Case Else
                mvAnswer.Visible = False : PanelQuestion.Visible = False : btnUpdate.Enabled = False : PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
        End Select
    End Sub

    Public Event Update()

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CheckValid()
        Dim q_title As String = txtQuestionText.Content.Trim.Replace("'", "''")
        Dim q_index As Integer = ViewState("Question_Index")
        Dim q_type As String = ddlQuestion.SelectedValue
        Dim q_seq As String = GetQuestionSeq(Request("sid"), q_type, q_index)
        Dim question_id As String = NewQuestionId()
        Dim hori_pos As String = ddlHorizontalPos.SelectedValue
        Dim q_bg_color As String = IIf(txtQuestionBgColor.Text <> "", txtQuestionBgColor.Text, "FFFFFF")
        Dim q_interval As String = txtBottomSpace.Text
        If q_interval = "" Then q_interval = "0"
        Dim q_isRequired As Boolean = cbRequired.Checked
        Dim q_err_msg As String = ""
        If q_isRequired Then q_err_msg = txtRequirederrMsg.Text.Replace("'", "''").Trim
        ReRankQuestionIndex(Request("sid"), q_index, q_type, True)
        If CreateQuestion(question_id, q_index, q_type, q_title, q_seq, hori_pos, q_bg_color, q_interval, q_isRequired, q_err_msg) > 0 Then
            CreateAnswer(question_id)
        End If
        RaiseEvent Update()
    End Sub

    Public Function GetQuestionSeq(ByVal survey_id As String, ByVal question_type As String, ByVal question_index As Integer) As String
        If question_type <> QuestionType.Descritive.ToString Then
            If question_index = 1 Then Return "1"
            Dim obj As Object = dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select top 1 question_seq from survey_question where survey_id='{0}' and question_seq<>'' and question_index>='{1}' order by question_index", survey_id, question_index))
            If obj IsNot Nothing Then
                Return obj.ToString
            Else
                obj = dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select top 1 question_seq from survey_question where survey_id='{0}' and question_seq<>'' order by question_index desc", survey_id))
                If obj Is Nothing Then
                    Return "1"
                Else
                    Return (CInt(obj) + 1).ToString
                End If
            End If
        End If
        Return ""
    End Function

    Public Shared Function ReRankQuestionIndex(ByVal survey_id As String, ByVal question_index As Integer, ByVal question_type As String, ByVal add_question As Boolean) As Boolean
        Try
            dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update survey_question set question_index=question_index {0} 1 where survey_id='{1}' and question_index >= '{2}'", IIf(add_question = True, "+", "-"), survey_id, question_index))
            If question_type <> QuestionType.Descritive.ToString Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update survey_question set question_seq= cast((cast(question_seq as int) {0} 1) as varchar(3)) where survey_id='{1}' and question_seq <> '' and question_index >= '{2}'", IIf(add_question = True, "+", "-"), survey_id, question_index))
            End If
            Return True
        Catch ex As Exception
            MailUtil.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Error", ex.ToString, True, "", "")
            Return False
        End Try
    End Function

    Public Sub CheckValid()
        If Request("sid") Is Nothing OrElse Request("sid") = "" Then Util.AjaxJSAlert(up2, "Please select a survey.") : Exit Sub
        If txtQuestionText.Content.Trim.Replace(ControlChars.Lf, "").Replace("<br />", "") = "" Then Util.AjaxJSAlert(up2, "Please input the question text.") : Exit Sub
        If (ddlQuestion.SelectedValue <> QuestionType.Essay.ToString AndAlso ddlQuestion.SelectedValue <> QuestionType.Descritive.ToString) AndAlso txtAnswerText.Text.Trim.Replace(ControlChars.Lf, "") = "" Then Util.AjaxJSAlert(up2, "Please input at least one answer.") : Exit Sub
        If cbComment.Checked AndAlso txtAddComment.Text.Trim.Replace(ControlChars.Lf, "") = "" Then Util.AjaxJSAlert(up2, "Please input the comment text.") : Exit Sub
        If ddlQuestion.SelectedValue = QuestionType.ContactInfo.ToString Then
            If cbEmail.Checked = False AndAlso cbName.Checked = False AndAlso cbCompany.Checked = False AndAlso cbPhone.Checked = False _
                AndAlso cbJob.Checked = False AndAlso cbAddress.Checked = False AndAlso cbCity.Checked = False AndAlso cbCountry.Checked = False _
                AndAlso cbZip.Checked = False Then
                Util.AjaxJSAlert(up2, "Please select at least one contact field.") : Exit Sub
            End If
        End If
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As System.EventArgs)
        RaiseEvent Update()
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If ddlQuestion.SelectedIndex = 0 Then
            PanelQuestion.Visible = False : btnSave.Enabled = False
        Else
            PanelQuestion.Visible = True : btnSave.Enabled = True
        End If
    End Sub

    Private Function CreateQuestion(ByVal question_id As String, ByVal q_index As Integer, ByVal q_type As String, ByVal q_title As String, _
                                    ByVal q_seq As String, ByVal horizontal_pos As String, ByVal q_bg_color As String, ByVal q_interval As String, _
                                    ByVal q_isRequired As Boolean, ByVal q_err_message As String) As Integer
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("insert into survey_question ")
            .AppendFormat("(question_id, question_index, question_title, question_type, last_updated_by, survey_id, HAS_OTHER_FIELD, REPEAT_DIRECTION, REPEAT_COLUMNS, QUESTION_SEQ, HORIZONTAL_POSITION, QUESTION_BG_COLOR, QUESTION_INTERVAL, IS_REQUIRED) ")
            .AppendFormat("values ('{0}','{1}',N'{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}')", question_id, q_index, q_title, q_type, Session("user_id"), Request("sid"), IIf(ddlQuestion.SelectedValue = QuestionType.Ranking.ToString, cbOther.Checked, False), ddlDirection.SelectedValue, txtColumns.Text, q_seq, horizontal_pos, q_bg_color, q_interval, q_isRequired)
        End With
        Dim ret As Integer = dbUtil.dbExecuteNoQuery("MYLocal", sb.ToString)
        If q_isRequired Then
            ret += CreateQuestionErrMsg(question_id, "", q_err_message)
        End If
        Return ret
    End Function

    Private Function CreateAnswer(ByVal question_id As String) As Integer
        Dim ret As Integer = 0
        If ddlQuestion.SelectedValue <> QuestionType.Essay.ToString AndAlso ddlQuestion.SelectedValue <> QuestionType.Descritive.ToString _
            AndAlso ddlQuestion.SelectedValue <> QuestionType.ContactInfo.ToString Then
            Dim answer() As String = txtAnswerText.Text.Replace("'", "''").Split(ControlChars.Lf)
            For i As Integer = 0 To answer.Length - 1
                If answer(i) <> "" Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, answer(i), i, Session("user_id"), Request("sid"), False, "")
            Next
            If cbComment.Checked Then
                ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, txtAddComment.Text.Trim.Replace(ControlChars.Lf, "<br/>"), answer.Length, Session("user_id"), Request("sid"), False, "", True)
            End If
        End If
        If ddlQuestion.SelectedValue = QuestionType.ContactInfo.ToString Then
            If cbEmail.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Email.ToString + "|" + txtEmail.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbEmailReq.Checked, txtErrEmail.Text.Replace("'", "''").Trim)
            If cbName.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Name.ToString + "|" + txtName.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbNameReq.Checked, txtErrName.Text.Replace("'", "''").Trim)
            If cbCompany.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Company.ToString + "|" + txtCompany.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbCompanyReq.Checked, txtErrCompany.Text.Replace("'", "''").Trim)
            If cbPhone.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Phone.ToString + "|" + txtPhone.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbPhoneReq.Checked, txtErrPhone.Text.Replace("'", "''").Trim)
            If cbJob.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Job.ToString + "|" + txtJob.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbJobReq.Checked, txtErrJob.Text.Replace("'", "''").Trim)
            If cbAddress.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Address.ToString + "|" + txtAddress.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbAddressReq.Checked, txtErrAddress.Text.Replace("'", "''").Trim)
            If cbCity.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.City.ToString + "|" + txtCity.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbCityReq.Checked, txtErrCity.Text.Replace("'", "''").Trim)
            If cbCountry.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Country.ToString + "|" + txtCountry.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbCountryReq.Checked, txtErrCountry.Text.Replace("'", "''").Trim)
            If cbZip.Checked Then ret += InsertAnswerSQL(NewAnswerId(question_id), question_id, ContactInfo.Zip.ToString + "|" + txtZip.Text.Replace("'", "''").Trim, ret, Session("user_id"), Request("sid"), cbZipReq.Checked, txtErrZip.Text.Replace("'", "''").Trim)
        End If
        Return ret
    End Function

    Public Function InsertAnswerSQL(ByVal answer_id As String, ByVal question_id As String, ByVal answer As String, ByVal answer_index As Integer, ByVal uploaded_by As String, ByVal survey_id As String, ByVal is_required As Boolean, ByVal err_message As String, Optional ByVal is_comment As Boolean = False) As Integer
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("insert into survey_answer ")
            .AppendFormat("(answer_id, question_id, answer_name, answer_index, last_updated_by, survey_id, is_comment, is_required) ")
            .AppendFormat("values ('{0}','{1}',N'{2}','{3}','{4}','{5}','{6}','{7}')", answer_id, question_id, answer, answer_index, uploaded_by, survey_id, is_comment, is_required)
        End With
        Dim ret As Integer = dbUtil.dbExecuteNoQuery("MYLocal", sb.ToString)
        If is_required Then
            ret += CreateQuestionErrMsg(question_id, answer_id, err_message)
        End If
        Return ret
    End Function

    Public Sub Initial()
        ddlQuestion.SelectedIndex = 0
        ddlDirection.SelectedIndex = 0 : txtColumns.Text = "1"
        txtQuestionText.Content = "" : txtQuestionBgColor.Text = "" : txtQuestionBgColor.BackColor = Drawing.Color.White
        txtBottomSpace.Text = GetQuestionInterval()
        txtAnswerText.Text = ""
        cbComment.Checked = False : txtAddComment.Text = "" : txtAddComment.Visible = False
        cbRequired.Checked = False : txtRequirederrMsg.Visible = False : txtRequirederrMsg.Text = "This question requires an answer."
        cbOther.Checked = False
        mvAnswer.Visible = False : PanelQuestion.Visible = False : btnSave.Enabled = False
        PanelDirection.Visible = False : PanelColumns.Visible = False : PanelHorizontalPos.Visible = False
        btnUpdate.Visible = False : btnSave.Visible = True
        cbEmail.Checked = True : cbEmailReq.Checked = False : cbName.Checked = True : cbNameReq.Checked = False
        cbCompany.Checked = True : cbCompanyReq.Checked = False : cbJob.Checked = True : cbJobReq.Checked = False
        cbPhone.Checked = True : cbPhoneReq.Checked = False : cbAddress.Checked = True : cbAddressReq.Checked = False
        cbCountry.Checked = True : cbCountryReq.Checked = False : cbCity.Checked = True : cbCityReq.Checked = False
        cbZip.Checked = True : cbZipReq.Checked = False
    End Sub

    Private Function GetQuestionInterval() As String
        Return dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select question_interval from survey_master where row_id='{0}'", Request("sid")))
    End Function

    Public Sub LoadQuestion(ByVal Question_Id As String)
        Try
            Initial()
            btnUpdate.Visible = True : btnSave.Visible = False
            hdnQuestionId.Value = Question_Id
            Dim dtQ As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select a.question_title, a.question_type, a.HAS_OTHER_FIELD, a.REPEAT_DIRECTION, a.REPEAT_COLUMNS, a.HORIZONTAL_POSITION, a.QUESTION_BG_COLOR, a.QUESTION_INTERVAL, a.IS_REQUIRED, isnull(b.err_message,'') as err_message from survey_question a left join survey_err_message b on a.question_id=b.question_id and b.answer_id='' where a.question_id='{0}'", Question_Id))
            If dtQ.Rows.Count > 0 Then
                With dtQ.Rows(0)
                    ddlQuestion.SelectedValue = .Item("question_type").ToString
                    VisibleControl()
                    txtQuestionText.Content = .Item("question_title").ToString.Replace("<br/>", ControlChars.Lf)
                    txtQuestionBgColor.BackColor = System.Drawing.Color.FromArgb(Integer.Parse(.Item("question_bg_color").ToString.Replace("#", ""), System.Globalization.NumberStyles.HexNumber))
                    txtQuestionBgColor.Text = .Item("question_bg_color") : txtQuestionBgColor.ForeColor = txtQuestionBgColor.BackColor
                    txtBottomSpace.Text = .Item("question_interval")
                    ddlHorizontalPos.SelectedValue = .Item("horizontal_position").ToString
                    If CBool(.Item("repeat_direction")) Then
                        ddlDirection.SelectedIndex = 1 : PanelColumns.Visible = True : txtColumns.Text = .Item("repeat_columns")
                    Else
                        ddlDirection.SelectedIndex = 0 : PanelColumns.Visible = False : txtColumns.Text = "1"
                    End If
                    cbOther.Checked = CBool(.Item("has_other_field"))
                    If .Item("question_type").ToString = QuestionType.ContactInfo.ToString Then
                        cbEmail.Checked = False : cbName.Checked = False : cbCompany.Checked = False : cbJob.Checked = False
                        cbPhone.Checked = False : cbAddress.Checked = False : cbCountry.Checked = False : cbCity.Checked = False
                        cbZip.Checked = False
                    End If
                    cbRequired.Checked = CBool(.Item("is_required")) : txtRequirederrMsg.Visible = CBool(.Item("is_required"))
                    If cbRequired.Checked Then txtRequirederrMsg.Text = .Item("err_message").ToString
                End With
            End If
            Dim dtA As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select a.answer_name, a.is_comment, a.answer_index, a.is_required, isnull(b.err_message,'') as err_message from survey_answer a left join survey_err_message b on a.question_id=b.question_id and a.answer_id=b.answer_id where a.question_id='{0}' order by a.answer_index", Question_Id))
            If dtA.Rows.Count > 0 Then
                For Each row As DataRow In dtA.Rows
                    If Not CBool(row.Item("is_comment")) Then
                        txtAnswerText.Text += row.Item("answer_name").ToString + ControlChars.Lf
                    Else
                        cbComment.Checked = True : txtAddComment.Visible = True
                        txtAddComment.Text = row.Item("answer_name").ToString.Replace("<br/>", ControlChars.Lf)
                    End If
                    If ddlQuestion.SelectedValue = QuestionType.ContactInfo.ToString Then
                        Select Case row.Item("answer_name").ToString.Split("|")(0)
                            Case ContactInfo.Email.ToString
                                cbEmail.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtEmail.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbEmailReq.Checked = True : PanelErrEmail.Visible = True : txtErrEmail.Text = row.Item("err_message").ToString
                            Case ContactInfo.Name.ToString
                                cbName.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtName.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbNameReq.Checked = True : PanelErrName.Visible = True : txtErrName.Text = row.Item("err_message").ToString
                            Case ContactInfo.Company.ToString
                                cbCompany.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtCompany.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbCompanyReq.Checked = True : PanelErrCompany.Visible = True : txtErrCompany.Text = row.Item("err_message").ToString
                            Case ContactInfo.Phone.ToString
                                cbPhone.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtPhone.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbPhoneReq.Checked = True : PanelErrPhone.Visible = True : txtErrPhone.Text = row.Item("err_message").ToString
                            Case ContactInfo.Job.ToString
                                cbJob.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtJob.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbJobReq.Checked = True : PanelErrJob.Visible = True : txtErrJob.Text = row.Item("err_message").ToString
                            Case ContactInfo.Address.ToString
                                cbAddress.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtAddress.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbAddressReq.Checked = True : PanelErrAddress.Visible = True : txtErrAddress.Text = row.Item("err_message").ToString
                            Case ContactInfo.Country.ToString
                                cbCountry.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtCountry.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbCountryReq.Checked = True : PanelErrCountry.Visible = True : txtErrCountry.Text = row.Item("err_message").ToString
                            Case ContactInfo.City.ToString
                                cbCity.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtCity.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbCityReq.Checked = True : PanelErrCity.Visible = True : txtErrCity.Text = row.Item("err_message").ToString
                            Case ContactInfo.Zip.ToString
                                cbZip.Checked = True
                                If row.Item("answer_name").ToString.Split("|").Length > 1 Then txtZip.Text = row.Item("answer_name").ToString.Split("|")(1)
                                If CBool(row.Item("is_required")) Then cbZipReq.Checked = True : PanelErrZip.Visible = True : txtErrZip.Text = row.Item("err_message").ToString
                        End Select
                    End If
                Next
            End If
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Error", ex.ToString, True, "", "")
        End Try
    End Sub

    Private Shared Function NewQuestionId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MYLocal", String.Format("select count(question_id) as counts from SURVEY_QUESTION where question_id='{0}'", tmpRowId)) _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function

    Private Shared Function NewAnswerId(ByVal question_id As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 5)
            If CInt( _
              dbUtil.dbExecuteScalar("MYLocal", String.Format("select count(answer_id) as counts from SURVEY_ANSWER where question_id='{0}' and answer_id='{1}'", question_id, tmpRowId)) _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function

    Protected Sub cbComment_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbComment.Checked Then txtAddComment.Visible = True Else txtAddComment.Visible = False
    End Sub

    Protected Sub ddlDirection_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If ddlDirection.SelectedIndex = 1 Then PanelColumns.Visible = True Else PanelColumns.Visible = False
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CheckValid()
        Dim question_id As String = hdnQuestionId.Value
        Dim q_title As String = txtQuestionText.Content.Trim.Replace("'", "''")
        Dim q_type As String = ddlQuestion.SelectedValue
        Dim hori_pos As String = ddlHorizontalPos.SelectedValue
        Dim q_bg_color As String = txtQuestionBgColor.Text.Replace("#", "")
        txtQuestionBgColor.BackColor = System.Drawing.Color.FromArgb(Integer.Parse(q_bg_color, System.Globalization.NumberStyles.HexNumber))
        txtQuestionBgColor.ForeColor = txtQuestionBgColor.BackColor
        Dim q_interval As String = txtBottomSpace.Text
        If q_interval = "" Then q_interval = "0"
        Dim q_isRequired As Boolean = cbRequired.Checked
        Dim q_err_msg As String = ""
        If q_isRequired Then q_err_msg = txtRequirederrMsg.Text.Replace("'", "''").Trim
        If UpdateQuestion(question_id, q_type, q_title, hori_pos, q_bg_color, q_interval, q_isRequired, q_err_msg) > 0 Then
            DeleteAnswer(question_id)
            CreateAnswer(question_id)
        End If
        RaiseEvent Update()
    End Sub

    Public Function UpdateQuestion(ByVal question_id As String, ByVal q_type As String, ByVal q_title As String, ByVal horizontal_pos As String, _
                                    ByVal q_bg_color As String, ByVal q_interval As String, ByVal q_isRequired As Boolean, ByVal q_err_msg As String) As Integer
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" update survey_question ")
            .AppendFormat(" set question_title=N'{0}', question_type='{1}', ", q_title, q_type)
            .AppendFormat(" last_updated_by='{0}', HAS_OTHER_FIELD='{1}', ", Session("user_id"), IIf(ddlQuestion.SelectedValue = QuestionType.Ranking.ToString, cbOther.Checked, False))
            .AppendFormat(" REPEAT_DIRECTION='{0}', REPEAT_COLUMNS='{1}', HORIZONTAL_POSITION='{2}',  ", ddlDirection.SelectedValue, txtColumns.Text, horizontal_pos)
            .AppendFormat(" QUESTION_BG_COLOR='{0}', QUESTION_INTERVAL='{1}', IS_REQUIRED='{2}' ", q_bg_color, q_interval, q_isRequired)
            .AppendFormat(" where question_id='{0}' ", question_id)
        End With
        Dim ret As Integer = dbUtil.dbExecuteNoQuery("MYLocal", sb.ToString)
        ret += DeleteQuestionErrMsg(question_id)
        If q_isRequired Then
            ret += CreateQuestionErrMsg(question_id, "", q_err_msg)
        End If
        Return ret
    End Function

    Public Shared Function DeleteQuestionErrMsg(ByVal question_id As String) As Integer
        Return dbUtil.dbExecuteNoQuery("MYLocal", String.Format("delete from survey_err_message where question_id='{0}'", question_id))
    End Function

    Public Function CreateQuestionErrMsg(ByVal question_id As String, ByVal answer_id As String, ByVal err_msg As String) As Integer
        Return dbUtil.dbExecuteNoQuery("MYLocal", String.Format("insert into survey_err_message (question_id, answer_id, err_message) values ('{0}', '{1}', N'{2}') ", question_id, answer_id, err_msg))
    End Function

    Public Shared Function DeleteAnswer(ByVal question_id As String) As Integer
        Return dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("delete from survey_answer where question_id='{0}'", question_id))
    End Function

    Protected Sub cbRequired_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbRequired.Checked Then txtRequirederrMsg.Visible = True Else txtRequirederrMsg.Visible = False
    End Sub

    Protected Sub cbEmailReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbEmailReq.Checked Then PanelErrEmail.Visible = True Else PanelErrEmail.Visible = False
    End Sub

    Protected Sub cbNameReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbNameReq.Checked Then PanelErrName.Visible = True Else PanelErrName.Visible = False
    End Sub

    Protected Sub cbCompanyReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbCompanyReq.Checked Then PanelErrCompany.Visible = True Else PanelErrCompany.Visible = False
    End Sub

    Protected Sub cbPhoneReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbPhoneReq.Checked Then PanelErrPhone.Visible = True Else PanelErrPhone.Visible = False
    End Sub

    Protected Sub cbJobReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbJobReq.Checked Then PanelErrJob.Visible = True Else PanelErrJob.Visible = False
    End Sub

    Protected Sub cbCityReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbCityReq.Checked Then PanelErrCity.Visible = True Else PanelErrCity.Visible = False
    End Sub

    Protected Sub cbCountryReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbCountryReq.Checked Then PanelErrCountry.Visible = True Else PanelErrCountry.Visible = False
    End Sub

    Protected Sub cbAddressReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbAddressReq.Checked Then PanelErrAddress.Visible = True Else PanelErrAddress.Visible = False
    End Sub

    Protected Sub cbZipReq_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbZipReq.Checked Then PanelErrZip.Visible = True Else PanelErrZip.Visible = False
    End Sub
</script>
<script type="text/javascript">
    function colorChanged(sender) {
        sender.get_element().blur();
        sender.get_element().style.color = '#' + sender.get_selectedColor();
        sender.get_element().style.backgroundColor = '#' + sender.get_selectedColor();
    }
</script>
<asp:UpdatePanel runat="server" ID="up2">
    <ContentTemplate>
        <table width="600" style="border-bottom:1px solid #d7d0d0;border-top:1px solid #d7d0d0; border-left:1px solid #d7d0d0; border-right:1px solid #d7d0d0; background-color:White; padding-left:5px; padding-right:5px">
            <tr><td valign="top" height="5"></td></tr>
            <tr><th align="left" valign="top" height="10"><font size="3">Question: </font></th></tr>
            <tr>
                <td valign="top">
                    <table width="100%" style="border-bottom:1px solid #d7d0d0;border-top:1px solid #d7d0d0; border-left:1px solid #d7d0d0; border-right:1px solid #d7d0d0; background-color:#d7d0d0;">
                        <tr>
                            <td valign="top" align="left">
                                <asp:DropDownList runat="server" ID="ddlQuestion" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="ddlQuestion_SelectedIndexChanged">
                                    <asp:ListItem Text="-- Choose Question Type --" Value="" />
                                    <asp:ListItem Text="Multiple Choice (Only One Answer)" Value="MultipleChoiceOneAnswer" />
                                    <asp:ListItem Text="Multiple Choice (Multiple Answers)" Value="MultipleChoiceMultipleAnswers" />
                                    <asp:ListItem Text="Essay Question" Value="Essay" />
                                    <asp:ListItem Text="Ranking Box" Value="Ranking" />
                                    <asp:ListItem Text="Descritive Text" Value="Descritive" />
                                    <asp:ListItem Text="Contact Information" Value="ContactInfo" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td align="left">
                                <asp:Panel runat="server" ID="PanelQuestion">
                                    <table width="100%">
                                        <tr><td><hr style="color:White" /></td></tr>
                                        <tr>
                                            <th align="left">Descriptive Text: </th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <ed:Editor runat="server" ID="txtQuestionText" Appearance="custom" ShowQuickFormat="false" Submit="false" CausesValidation="false" NoScript="true" Width="500" Height="150">
                                                    <Buttons>
                                                        <ed:Method Name="Undo"/>
                                                        <ed:Method Name="Redo"/>
                                                        <ed:HorizontalSeparator/>
                                                        <ed:Toggle Name="Bold"/>
                                                        <ed:Toggle Name="Italic"/>
                                                        <ed:Toggle Name="Underline"/>
                                                        <ed:HorizontalSeparator/>
                                                        <ed:Method Name="ClearStyles"/>
                                                        <ed:HorizontalSeparator/>
                                                        <ed:Method Name="Paragraph"/>
                                                        <ed:Method Name="JustifyLeft"/>
                                                        <ed:Method Name="JustifyCenter"/>
                                                        <ed:Method Name="JustifyRight"/>
                                                        <ed:Method Name="JustifyFull"/>
                                                        <ed:Method Name="RemoveAlignment"/>
                                                        <ed:HorizontalSeparator/>
                                                        <ed:Method Name="CreateLink" />
                                                        <ed:Method Name="ForeColor" />
                                                        <ed:Method Name="InsertIMG" />
                                                    </Buttons>
                                                </ed:Editor>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">Set background color as <asp:TextBox runat="server" ID="txtQuestionBgColor" Width="50" />
                                                <ajaxToolkit:ColorPickerExtender ID="cpeQuestionBgColor" runat="server"
                                                        Enabled="True" TargetControlID="txtQuestionBgColor" OnClientColorSelectionChanged="colorChanged">
                                                </ajaxToolkit:ColorPickerExtender>
                                            </th>
                                        </tr>
                                        <tr>
                                            <th align="left">Question bottom spacing interval: <asp:TextBox runat="server" ID="txtBottomSpace" Width="50" />
                                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeBottomSpace" TargetControlID="txtBottomSpace" FilterMode="ValidChars" FilterType="Numbers">
                                                </ajaxToolkit:FilteredTextBoxExtender>
                                            </th>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                        <tr>
                            <td align="left">
                                <asp:Panel runat="server" ID="PanelDirection" Visible="false">
                                    <table>
                                        <tr>
                                            <th>Show answers as </th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlDirection" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="ddlDirection_SelectedIndexChanged">
                                                    <asp:ListItem Text="Vertical" Value="0" />
                                                    <asp:ListItem Text="Horizontal" Value="1" />
                                                </asp:DropDownList>
                                            </td>
                                            <th> direction.</th>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                <asp:Panel runat="server" ID="PanelColumns" Visible="false">
                                    <table>
                                        <tr>
                                            <th>Show answers in </th>
                                            <td><asp:TextBox runat="server" ID="txtColumns" Width="20" Text="1" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe1" TargetControlID="txtColumns" FilterType="Numbers" FilterMode="ValidChars" /></td>
                                            <th> columns.</th>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                <asp:Panel runat="server" ID="PanelHorizontalPos" Visible="false">
                                    <table>
                                        <tr>
                                            <th>Horizontal position at </th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlHorizontalPos">
                                                    <asp:ListItem Text="Left" Value="Left" />
                                                    <asp:ListItem Text="Center" Value="Center" />
                                                    <asp:ListItem Text="Right" Value="Right" />
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td height="5"></td></tr>
            <tr>
                <td valign="top">
                    <asp:MultiView runat="server" ID="mvAnswer" Visible="false">
                        <asp:View runat="server" ID="vGeneral">
                            <table width="100%">
                                <tr><th align="left" valign="top" height="10"><font size="3">Answer: </font></th></tr>
                                <tr>
                                    <td>
                                        <table width="100%" style="border-bottom:1px solid #d7d0d0;border-top:1px solid #d7d0d0; border-left:1px solid #d7d0d0; border-right:1px solid #d7d0d0; background-color:#d7d0d0;">
                                            <tr>
                                                <td>
                                                    <asp:Panel runat="server" ID="PanelAnswer">
                                                        <table>
                                                            <tr>
                                                                <th align="left">Answer Choices: <font color="gray">Enter each choice on a separate line.</font></th>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <asp:TextBox runat="server" ID="txtAnswerText" Width="500" Height="100" TextMode="MultiLine" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                    <asp:Panel runat="server" ID="PanelComment">
                                                        <table>
                                                            <tr>
                                                                <td valign="top"><asp:CheckBox runat="server" ID="cbComment" AutoPostBack="true" OnCheckedChanged="cbComment_CheckedChanged" /></td>
                                                                <td><b>Add "Other" or a comment field</b> <font color="gray">(Optional)<br />Allow respondents to add a comment to clarify their answer.</font></td>
                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                                <td><asp:TextBox runat="server" ID="txtAddComment" TextMode="MultiLine" Width="300" Height="50" Visible="false" /><ajaxToolkit:TextBoxWatermarkExtender runat="server" ID="tbweAddComment" TargetControlID="txtAddComment" WatermarkText="Please input the comment description." WatermarkCssClass="watermarked" /></td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                    <asp:Panel runat="server" ID="PanelOther" Visible="false">
                                                        <table>
                                                            <tr>
                                                                <td valign="top"><asp:CheckBox runat="server" ID="cbOther" /></td>
                                                                <td><b>Add "Other" field choice.</b> <font color="gray">(Optional)<br />Allow respondents to add custom answer for ranking.</font></td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                    <asp:Panel runat="server" ID="PanelRequired">
                                                        <table>
                                                            <tr>
                                                                <td valign="top"><asp:CheckBox runat="server" ID="cbRequired" AutoPostBack="true" OnCheckedChanged="cbRequired_CheckedChanged" /></td>
                                                                <td><b>Require an answer to this question</b> <font color="gray">(Optional)<br />Display a custom error message when respondents try to skip this question.</font></td>
                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                                <td><asp:TextBox runat="server" ID="txtRequirederrMsg" Text="This question requires an answer." Width="300" Visible="false" /></td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </asp:View>
                        <asp:View runat="server" ID="vContactInfo">
                            <table width="100%">
                                <tr><th align="left" valign="top" height="10"><font size="3">Contact Information: </font></th></tr>
                                <tr>
                                    <td>
                                        <table width="100%" style="border-bottom:1px solid #d7d0d0;border-top:1px solid #d7d0d0; border-left:1px solid #d7d0d0; border-right:1px solid #d7d0d0; background-color:#d7d0d0;">
                                            <tr><td height="10"></td></tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <th align="left">Email Address: </th>
                                                            <td><asp:TextBox runat="server" ID="txtEmail" Text="Email Address:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbEmail" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbEmailReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbEmailReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrEmail" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrEmail" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrEmail" Text="Please input your email address." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Name: </th>
                                                            <td><asp:TextBox runat="server" ID="txtName" Text="Name:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbName" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbNameReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbNameReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrName" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrName" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrName" Text="Please input your name." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Company: </th>
                                                            <td><asp:TextBox runat="server" ID="txtCompany" Text="Company:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCompany" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCompanyReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbCompanyReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrCompany" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrCompany" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrCompany" Text="Please input your company name." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Phone Number: </th>
                                                            <td><asp:TextBox runat="server" ID="txtPhone" Text="Phone Number:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbPhone" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbPhoneReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbPhoneReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrPhone" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrPhone" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrPhone" Text="Please input your phone number." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Job Name: </th>
                                                            <td><asp:TextBox runat="server" ID="txtJob" Text="Job Name:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbJob" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbJobReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbJobReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrJob" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrJob" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrJob" Text="Please input your job name." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Address: </th>
                                                            <td><asp:TextBox runat="server" ID="txtAddress" Text="Address:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbAddress" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbAddressReq" Text="Answer Required"  AutoPostBack="true" OnCheckedChanged="cbAddressReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrAddress" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrAddress" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrAddress" Text="Please input your address." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">City: </th>
                                                            <td><asp:TextBox runat="server" ID="txtCity" Text="City:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCity" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCityReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbCityReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrCity" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrCity" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrCity" Text="Please input your city." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Country: </th>
                                                            <td><asp:TextBox runat="server" ID="txtCountry" Text="Country:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCountry" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbCountryReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbCountryReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrCountry" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrCountry" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrCountry" Text="Please input your country." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">ZIP: </th>
                                                            <td><asp:TextBox runat="server" ID="txtZip" Text="ZIP:" Width="250" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbZip" Text="Visible" Checked="true" /></td>
                                                            <td><asp:CheckBox runat="server" ID="cbZipReq" Text="Answer Required" AutoPostBack="true" OnCheckedChanged="cbZipReq_CheckedChanged" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td colspan="3">
                                                                <asp:Panel runat="server" ID="PanelErrZip" Visible="false">
                                                                    <table width="100%">
                                                                        <tr><td><asp:Label runat="server" ID="lblErrZip" Text="Please input custome error message" ForeColor="Gray" /></td></tr>
                                                                        <tr><td><asp:TextBox runat="server" ID="txtErrZip" Text="Please input your zip number." Width="100%" /></td></tr>
                                                                        <tr><td height="5"></td></tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr><td height="10"></td></tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </asp:View>
                    </asp:MultiView>
                </td>
            </tr>
            <tr>
                <td align="center" valign="bottom">
                    <asp:Button runat="server" ID="btnSave" Text="Save" Width="50" CausesValidation="false" OnClick="btnSave_Click" /><asp:Button runat="server" ID="btnUpdate" Text="Update" Width="50" Visible="false" CausesValidation="false" OnClick="btnUpdate_Click" /><asp:Button runat="server" ID="btnCancel" Text="Cancel" Width="50" CausesValidation="false" OnClick="btnCancel_Click" />
                </td>
            </tr>
            <tr><td height="5"></td></tr>
        </table>
        <asp:HiddenField runat="server" ID="hdnQuestionId" />
    </ContentTemplate>
</asp:UpdatePanel>