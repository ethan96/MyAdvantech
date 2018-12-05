<%@ Control Language="VB" ClassName="Aonline_AnswerType" %>

<script runat="server">
    Dim _question_id As String, _question_type As String, _hasOtherField As Boolean, _direction As Boolean, _columns As Integer, _is_question_required As Boolean
    
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
    
    Public Enum QuestionTypeEnum
        MultipleChoiceOneAnswer
        MultipleChoiceMultipleAnswers
        Essay
        Ranking
        TextBoxs
        Descritive
        ContactInfo
    End Enum
    
    Public Property QuestionID() As String
        Get
            Return ViewState("QID")
        End Get
        Set(ByVal value As String)
            ViewState("QID") = value
        End Set
    End Property
    
    Public Property QuestionType() As String
        Get
            Return ViewState("QType")
        End Get
        Set(ByVal value As String)
            ViewState("QType") = value
        End Set
    End Property
    
    Public Property Direction() As Boolean
        Get
            Return _direction
        End Get
        Set(ByVal value As Boolean)
            _direction = value
        End Set
    End Property
    
    Public Property Columns() As Integer
        Get
            Return _columns
        End Get
        Set(ByVal value As Integer)
            _columns = value
        End Set
    End Property
    
    Public Property HasOtherField() As Boolean
        Get
            Return _hasOtherField
        End Get
        Set(ByVal value As Boolean)
            _hasOtherField = value
        End Set
    End Property
    
    Public Property IsQuestionRequired() As Boolean
        Get
            Return _is_question_required
        End Get
        Set(ByVal value As Boolean)
            _is_question_required = value
        End Set
    End Property
    
    Protected Sub rblOneAnswer_DataBound(sender As Object, e As System.EventArgs)
        If ViewState("QType") = QuestionTypeEnum.MultipleChoiceOneAnswer.ToString Then
            sqlOneAnswer.SelectCommand = GetSql()
            If _direction = True Then rblOneAnswer.RepeatDirection = WebControls.RepeatDirection.Horizontal
            rblOneAnswer.RepeatColumns = _columns
            PanelOneAnswer.Visible = True
        Else
            PanelOneAnswer.Visible = False
        End If
    End Sub

    Protected Sub cblMultiAnswer_DataBound(sender As Object, e As System.EventArgs)
        If ViewState("QType") = QuestionTypeEnum.MultipleChoiceMultipleAnswers.ToString Then
            sqlMultiAnswer.SelectCommand = GetSql()
            PanelMultiAnswer.Visible = True
            If _direction = True Then cblMultiAnswer.RepeatDirection = WebControls.RepeatDirection.Horizontal
            cblMultiAnswer.RepeatColumns = _columns
        Else
            PanelMultiAnswer.Visible = False
        End If
    End Sub
    
    Public Function GetAnswer() As DataTable
        Dim dt As New DataTable
        With dt.Columns
            .Add("ANSWER_ID") : .Add("ANSWER") : .Add("COMMENT")
        End With
        Select Case QuestionType
            Case QuestionTypeEnum.MultipleChoiceOneAnswer.ToString
                For Each i As ListItem In rblOneAnswer.Items
                    If i.Selected = True Then
                        Dim r As DataRow = dt.NewRow()
                        r.Item("ANSWER_ID") = i.Value : r.Item("ANSWER") = i.Text : r.Item("COMMENT") = ""
                        dt.Rows.Add(r)
                    End If
                Next
            Case QuestionTypeEnum.MultipleChoiceMultipleAnswers.ToString
                For Each i As ListItem In cblMultiAnswer.Items
                    If i.Selected = True Then
                        Dim r As DataRow = dt.NewRow()
                        r.Item("ANSWER_ID") = i.Value : r.Item("ANSWER") = i.Text : r.Item("COMMENT") = ""
                        dt.Rows.Add(r)
                    End If
                Next
            Case QuestionTypeEnum.Essay.ToString
                Dim r As DataRow = dt.NewRow()
                r.Item("ANSWER_ID") = "" : r.Item("ANSWER") = "" : r.Item("COMMENT") = txtEssay.Text.Replace("'", "''").Replace(ControlChars.Lf, "<br/>").Trim
                dt.Rows.Add(r)
            Case QuestionTypeEnum.Ranking.ToString
                For i As Integer = 1 To 9
                    If CType(Me.FindControl("lblR" + i.ToString), Label).Text <> "" Then
                        Dim r As DataRow = dt.NewRow()
                        r.Item("ANSWER_ID") = CType(Me.FindControl("hdnR" + i.ToString), HiddenField).Value
                        r.Item("ANSWER") = CType(Me.FindControl("txtR" + i.ToString), TextBox).Text.Replace("'", "''").Trim
                        r.Item("COMMENT") = ""
                        dt.Rows.Add(r)
                    End If
                Next
                If _hasOtherField Then
                    Dim r As DataRow = dt.NewRow()
                    r.Item("ANSWER_ID") = ""
                    r.Item("ANSWER") = CType(Me.FindControl("txtOther"), TextBox).Text.Replace("'", "''").Trim
                    r.Item("COMMENT") = CType(Me.FindControl("txtOtherComment"), TextBox).Text.Replace("'", "''").Trim
                    dt.Rows.Add(r)
                End If
                Return dt
        End Select
        If txtComment1.Text.Replace(ControlChars.Lf, "").Trim <> "" Then
            Dim r As DataRow = dt.NewRow()
            r.Item("ANSWER_ID") = hdnComment1.Value : r.Item("ANSWER") = "" : r.Item("COMMENT") = txtComment1.Text.Replace(ControlChars.Lf, "<br/>").Trim
            dt.Rows.Add(r)
        End If
        If txtComment2.Text.Replace(ControlChars.Lf, "").Trim <> "" Then
            Dim r As DataRow = dt.NewRow()
            r.Item("ANSWER_ID") = hdnComment2.Value : r.Item("ANSWER") = "" : r.Item("COMMENT") = txtComment2.Text.Replace(ControlChars.Lf, "<br/>").Trim
            dt.Rows.Add(r)
        End If
        If dt.Rows.Count > 0 Then Return dt
        Return Nothing
    End Function
    
    Public Function GetContactInfo() As DataTable
        Dim dt As New DataTable
        With dt.Columns
            .Add("EMAIL") : .Add("NAME") : .Add("COMPANY") : .Add("PHONE") : .Add("JOB") : .Add("ADDRESS") : .Add("COUNTRY") : .Add("CITY") : .Add("ZIP")
        End With
        Dim r As DataRow = dt.NewRow()
        r.Item("EMAIL") = txtEmail.Text.Replace("'", "''")
        r.Item("NAME") = txtName.Text.Replace("'", "''")
        r.Item("COMPANY") = txtCompany.Text.Replace("'", "''")
        r.Item("PHONE") = txtPhone.Text.Replace("'", "''")
        r.Item("JOB") = txtJob.Text.Replace("'", "''")
        r.Item("ADDRESS") = txtAddress.Text.Replace("'", "''")
        r.Item("COUNTRY") = txtCountry.Text.Replace("'", "''")
        r.Item("CITY") = txtCity.Text.Replace("'", "''")
        r.Item("ZIP") = txtZip.Text.Replace("'", "''")
        dt.Rows.Add(r)
        Return dt
    End Function
    
    Public Function CheckValid() As Boolean
        Select QuestionType
            Case QuestionTypeEnum.MultipleChoiceOneAnswer.ToString
                For Each i As ListItem In rblOneAnswer.Items
                    If i.Selected = True Then
                        Return True
                    End If
                Next
                Return False
            Case QuestionTypeEnum.MultipleChoiceMultipleAnswers.ToString
                For Each i As ListItem In cblMultiAnswer.Items
                    If i.Selected = True Then
                        Return True
                    End If
                Next
                Return False
            Case QuestionTypeEnum.Essay.ToString
                If txtEssay.Text.Replace("'", "''").Replace(ControlChars.Lf, "").Replace("<br/>", "").Trim = "" Then Return False Else Return True
            Case QuestionTypeEnum.Ranking.ToString
                'For i As Integer = 1 To 9
                '    If CType(Me.FindControl("lblR" + i.ToString), Label).Text <> "" Then
                '        Dim r As DataRow = dt.NewRow()
                '        r.Item("ANSWER_ID") = CType(Me.FindControl("hdnR" + i.ToString), HiddenField).Value
                '        r.Item("ANSWER") = CType(Me.FindControl("txtR" + i.ToString), TextBox).Text.Replace("'", "''").Trim
                '        r.Item("COMMENT") = ""
                '        dt.Rows.Add(r)
                '    End If
                'Next
                'If _hasOtherField Then
                '    Dim r As DataRow = dt.NewRow()
                '    r.Item("ANSWER_ID") = ""
                '    r.Item("ANSWER") = CType(Me.FindControl("txtOther"), TextBox).Text.Replace("'", "''").Trim
                '    r.Item("COMMENT") = CType(Me.FindControl("txtOtherComment"), TextBox).Text.Replace("'", "''").Trim
                '    dt.Rows.Add(r)
                'End If
                'Return dt
                Return True
            Case QuestionTypeEnum.ContactInfo.ToString
                Dim isInvalid As Boolean = True
                If lblTagEmail.Visible = True AndAlso txtEmail.Text.Replace("'", "").Trim = "" Then lblErrEmail.Visible = True : isInvalid = False
                If lblTagName.Visible = True AndAlso txtName.Text.Replace("'", "").Trim = "" Then lblErrName.Visible = True : isInvalid = False
                If lblTagCompany.Visible = True AndAlso txtCompany.Text.Replace("'", "").Trim = "" Then lblErrCompany.Visible = True : isInvalid = False
                If lblTagPhone.Visible = True AndAlso txtPhone.Text.Replace("'", "").Trim = "" Then lblErrPhone.Visible = True : isInvalid = False
                If lblTagJob.Visible = True AndAlso txtJob.Text.Replace("'", "").Trim = "" Then lblErrJob.Visible = True : isInvalid = False
                If lblTagCity.Visible = True AndAlso txtCity.Text.Replace("'", "").Trim = "" Then lblErrCity.Visible = True : isInvalid = False
                If lblTagCountry.Visible = True AndAlso txtCountry.Text.Replace("'", "").Trim = "" Then lblErrCountry.Visible = True : isInvalid = False
                If lblTagAddress.Visible = True AndAlso txtAddress.Text.Replace("'", "").Trim = "" Then lblErrAddress.Visible = True : isInvalid = False
                If lblTagZip.Visible = True AndAlso txtZip.Text.Replace("'", "").Trim = "" Then lblErrZip.Visible = True : isInvalid = False
                Return isInvalid
            Case Else
                Return True
        End Select
    End Function
    
    Public Function GetSql(Optional ByVal GetComment As Boolean = False) As String
        Return String.Format("select a.answer_name, a.answer_id, a.answer_index, a.is_required, isnull(b.err_message,'') as err_message from survey_answer a left join survey_err_message b on a.question_id=b.question_id and a.answer_id=b.answer_id where a.question_id='{0}' and a.is_comment='{1}' order by a.answer_index", ViewState("QID"), GetComment)
    End Function
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)    
        
    End Sub

    Protected Sub PanelRanking_DataBinding(sender As Object, e As System.EventArgs)
        If ViewState("QType") = QuestionTypeEnum.Ranking.ToString Then
            PanelRanking.Visible = True
            Dim dt As DataTable = dbUtil.dbGetDataTable("MyLocal", GetSql())
            For i As Integer = 0 To dt.Rows.Count - 1
                CType(Me.FindControl("lblR" + (i + 1).ToString), Label).Text = dt.Rows(i).Item("answer_name").ToString
                CType(Me.FindControl("hdnR" + (i + 1).ToString), HiddenField).Value = dt.Rows(i).Item("answer_id").ToString
                Me.FindControl("tr" + (i + 1).ToString).Visible = True
            Next
            If _hasOtherField Then PanelOther.Visible = True Else PanelOther.Visible = False
        Else
            PanelRanking.Visible = False
        End If
    End Sub

    Protected Sub PanelEssay_DataBinding(sender As Object, e As System.EventArgs)
        If ViewState("QType") = QuestionTypeEnum.Essay.ToString Then
            PanelEssay.Visible = True
        Else
            PanelEssay.Visible = False
        End If
    End Sub

    Protected Sub PanelComment1_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", GetSql(True))
        If dt.Rows.Count > 0 Then
            lblComment1.Text = dt.Rows(0).Item("answer_name").ToString : hdnComment1.Value = dt.Rows(0).Item("answer_id").ToString
            PanelComment1.Visible = True
        Else
            PanelComment1.Visible = False
        End If
    End Sub
    
    Protected Sub PanelComment2_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", GetSql(True))
        If dt.Rows.Count = 2 Then
            lblComment2.Text = dt.Rows(1).Item("answer_name").ToString : hdnComment2.Value = dt.Rows(0).Item("answer_id").ToString
            PanelComment2.Visible = True
        Else
            PanelComment2.Visible = False
        End If
    End Sub

    Protected Sub PanelContactInfo_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("QType") = QuestionTypeEnum.ContactInfo.ToString Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", GetSql())
            For Each row As DataRow In dt.Rows
                Select Case row.Item("answer_name").ToString.Split("|")(0)
                    Case ContactInfo.Email.ToString
                        PanelEmail.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblEmail.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagEmail.Visible = True : lblErrEmail.Text = row.Item("err_message").ToString
                        If Request.IsAuthenticated Then
                            If Session("user_id") IsNot Nothing Then txtEmail.Text = Session("user_id")
                        End If
                    Case ContactInfo.Name.ToString
                        PanelName.Visible = True : lblName.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblName.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagName.Visible = True : lblErrName.Text = row.Item("err_message").ToString
                    Case ContactInfo.Company.ToString
                        PanelCompany.Visible = True : lblCompany.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblCompany.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagCompany.Visible = True : lblErrCompany.Text = row.Item("err_message").ToString
                    Case ContactInfo.Phone.ToString
                        PanelPhone.Visible = True : lblPhone.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblPhone.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagPhone.Visible = True : lblErrPhone.Text = row.Item("err_message").ToString
                    Case ContactInfo.Job.ToString
                        PanelJob.Visible = True : lblJob.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblJob.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagJob.Visible = True : lblErrJob.Text = row.Item("err_message").ToString
                    Case ContactInfo.Address.ToString
                        PanelAddress.Visible = True : lblAddress.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblAddress.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagAddress.Visible = True : lblErrAddress.Text = row.Item("err_message").ToString
                    Case ContactInfo.Country.ToString
                        PanelCountry.Visible = True : lblCountry.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblCountry.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagCountry.Visible = True : lblErrCountry.Text = row.Item("err_message").ToString
                    Case ContactInfo.City.ToString
                        PanelCity.Visible = True : lblCity.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblCity.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagCity.Visible = True : lblErrCity.Text = row.Item("err_message").ToString
                    Case ContactInfo.Zip.ToString
                        PanelZip.Visible = True : lblZip.Visible = True
                        If row.Item("answer_name").ToString.Split("|").Length > 1 Then lblZip.Text = row.Item("answer_name").ToString.Split("|")(1)
                        If CBool(row.Item("is_required")) Then lblTagZip.Visible = True : lblErrZip.Text = row.Item("err_message").ToString
                End Select
            Next
            PanelContactInfo.Visible = True
        Else
            PanelContactInfo.Visible = False
        End If
    End Sub
</script>
<style type="text/css">
    table.mylist input 
    {
        text-align: left;
        padding-left:2px;
    }
    table.mylist label 
    {
        text-align: left;
        padding-left:2px;
    }
</style>
<asp:Panel runat="server" ID="PanelOneAnswer" Visible="false">
    <table width="100%">
        <tr>
            <td>
                <asp:RadioButtonList runat="server" ID="rblOneAnswer" Width="80%" DataSourceID="sqlOneAnswer" RepeatDirection="Vertical" DataTextField="answer_name" DataValueField="answer_id" RepeatLayout="Table" CssClass="mylist" Font-Size="Small" OnDataBound="rblOneAnswer_DataBound">
                </asp:RadioButtonList>
                <asp:SqlDataSource runat="server" ID="sqlOneAnswer" ConnectionString="<%$ connectionStrings:MyLocal %>"
                    SelectCommand="">
                </asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelMultiAnswer" Visible="false">
    <table width="100%">
        <tr>
            <td>
                <asp:CheckBoxList runat="server" ID="cblMultiAnswer" Width="80%" DataSourceID="sqlMultiAnswer" RepeatDirection="Vertical" DataTextField="answer_name" DataValueField="answer_id" RepeatLayout="Table" CssClass="mylist" Font-Size="Small" OnDataBound="cblMultiAnswer_DataBound">
                </asp:CheckBoxList>
                <asp:SqlDataSource runat="server" ID="sqlMultiAnswer" ConnectionString="<%$ connectionStrings:MyLocal %>"
                    SelectCommand="">
                </asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelEssay" Visible="false" OnDataBinding="PanelEssay_DataBinding">
    <table width="100%">
        <tr>
            <td><asp:TextBox runat="server" ID="txtEssay" TextMode="MultiLine" Width="400" Height="100" /></td>
        </tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelRanking" Visible="false" OnDataBinding="PanelRanking_DataBinding">
    <table>
        <tr runat="server" id="tr1" visible="false">
            <td><asp:TextBox runat="server" ID="txtR1" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR1" /><asp:HiddenField runat="server" ID="hdnR1" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe1" TargetControlID="txtR1" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr2" visible="false">
            <td><asp:TextBox runat="server" ID="txtR2" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR2" /><asp:HiddenField runat="server" ID="hdnR2" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe2" TargetControlID="txtR2" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr3" visible="false">
            <td><asp:TextBox runat="server" ID="txtR3" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR3" /><asp:HiddenField runat="server" ID="hdnR3" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe3" TargetControlID="txtR3" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr4" visible="false">
            <td><asp:TextBox runat="server" ID="txtR4" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR4" /><asp:HiddenField runat="server" ID="hdnR4" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe4" TargetControlID="txtR4" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr5" visible="false">
            <td><asp:TextBox runat="server" ID="txtR5" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR5" /><asp:HiddenField runat="server" ID="hdnR5" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe5" TargetControlID="txtR5" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr6" visible="false">
            <td><asp:TextBox runat="server" ID="txtR6" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR6" /><asp:HiddenField runat="server" ID="hdnR6" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe6" TargetControlID="txtR6" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr7" visible="false">
            <td><asp:TextBox runat="server" ID="txtR7" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR7" /><asp:HiddenField runat="server" ID="hdnR7" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe7" TargetControlID="txtR7" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr8" visible="false">
            <td><asp:TextBox runat="server" ID="txtR8" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR8" /><asp:HiddenField runat="server" ID="hdnR8" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe8" TargetControlID="txtR8" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="tr9" visible="false">
            <td><asp:TextBox runat="server" ID="txtR9" Width="50" />&nbsp;<asp:Label runat="server" ID="lblR9" /><asp:HiddenField runat="server" ID="hdnR9" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbe9" TargetControlID="txtR9" FilterType="Numbers" FilterMode="ValidChars" /></td>
        </tr>
        <tr runat="server" id="trOther">
            <td>
                <asp:Panel runat="server" ID="PanelOther" Visible="false">
                    <asp:TextBox runat="server" ID="txtOther" Width="50" />&nbsp;<asp:Label runat="server" ID="lblOther" Text="Others" />&nbsp;<asp:TextBox runat="server" ID="txtOtherComment" Width="300px" /><ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeOther" TargetControlID="txtOther" FilterType="Numbers" FilterMode="ValidChars" />
                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelComment1" Visible="false" OnDataBinding="PanelComment1_DataBinding">
    <table>
        <tr><td><asp:Label runat="server" ID="lblComment1" /><asp:HiddenField runat="server" ID="hdnComment1" /></td></tr>
        <tr><td><asp:TextBox runat="server" ID="txtComment1" TextMode="MultiLine" Width="300" Height="60" /></td></tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelComment2" Visible="false" OnDataBinding="PanelComment2_DataBinding">
    <table>
        <tr><td><asp:Label runat="server" ID="lblComment2" /><asp:HiddenField runat="server" ID="hdnComment2" /></td></tr>
        <tr><td><asp:TextBox runat="server" ID="txtComment2" TextMode="MultiLine" Width="300" Height="60" /></td></tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelContactInfo" Visible="false" OnDataBinding="PanelContactInfo_DataBinding">
    <asp:Panel runat="server" ID="PanelEmail" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagEmail" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblEmail" Text="Email Address: " /></td>
                <td><asp:TextBox runat="server" ID="txtEmail" Width="250" /><asp:Label runat="server" ID="lblErrEmail" ForeColor="Red" Visible="false" /> <%--<asp:RequiredFieldValidator runat="server" ID="rfvEmail" ControlToValidate="txtEmail" ForeColor="Red" ErrorMessage=" Please input your email." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelName" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagName" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblName" Text="Name: " /></td>
                <td><asp:TextBox runat="server" ID="txtName" Width="250" /><asp:Label runat="server" ID="lblErrName" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvName" ControlToValidate="txtName" ForeColor="Red" ErrorMessage=" Please input your name." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelCompany" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagCompany" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblCompany" Text="Company: " /></td>
                <td><asp:TextBox runat="server" ID="txtCompany" Width="250" /><asp:Label runat="server" ID="lblErrCompany" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvCompany" ControlToValidate="txtCompany" ForeColor="Red" ErrorMessage=" Please input your company." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelPhone" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagPhone" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblPhone" Text="Phone Number: " /></td>
                <td><asp:TextBox runat="server" ID="txtPhone" Width="250" /><asp:Label runat="server" ID="lblErrPhone" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvPhone" ControlToValidate="txtEmail" ForeColor="Red" ErrorMessage=" Please input your phone number." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelJob" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagJob" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblJob" Text="Job Name: " /></td>
                <td><asp:TextBox runat="server" ID="txtJob" Width="250" /><asp:Label runat="server" ID="lblErrJob" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvJob" ControlToValidate="txtJob" ForeColor="Red" ErrorMessage=" Please input your job." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelAddress" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagAddress" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblAddress" Text="Address: " /></td>
                <td><asp:TextBox runat="server" ID="txtAddress" Width="250" /><asp:Label runat="server" ID="lblErrAddress" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvAddress" ControlToValidate="txtAddress" ForeColor="Red" ErrorMessage=" Please input your address." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelCity" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagCity" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblCity" Text="City: " /></td>
                <td><asp:TextBox runat="server" ID="txtCity" Width="250" /><asp:Label runat="server" ID="lblErrCity" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvCity" ControlToValidate="txtCity" ForeColor="Red" ErrorMessage=" Please input your city." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelCountry" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagCountry" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblCountry" Text="Country: " /></td>
                <td><asp:TextBox runat="server" ID="txtCountry" Width="250" /><asp:Label runat="server" ID="lblErrCountry" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvCountry" ControlToValidate="txtCountry" ForeColor="Red" ErrorMessage=" Please input your country." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel runat="server" ID="PanelZip" Visible="false">
        <table>
            <tr>
                <td align="left" width="100"><asp:Label runat="server" ID="lblTagZip" ForeColor="Red" Text="* " Visible="false" /><asp:Label runat="server" ID="lblZip" Text="ZIP: " /></td>
                <td><asp:TextBox runat="server" ID="txtZip" Width="250" /><asp:Label runat="server" ID="lblErrZip" ForeColor="Red" Visible="false" /><%--<asp:RequiredFieldValidator runat="server" ID="rfvZip" ControlToValidate="txtZip" ForeColor="Red" ErrorMessage=" Please input your zip." Enabled="false" />--%></td>
            </tr>
        </table>
    </asp:Panel>
</asp:Panel>
<asp: