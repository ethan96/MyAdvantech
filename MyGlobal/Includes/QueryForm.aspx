<%@ Page Language="VB" %>

<%@ Import Namespace="System.Data.SqlClient" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strForceWhere As String
        If Not IsPostBack Then
            strForceWhere = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("ForceWhere")))
            Me.ViewState("SelectSQL") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("SelectSQL")))
            Me.ViewState("ShowColumns") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("ShowColumns")))
            Me.ViewState("ReturnFieldIndex") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("FieldIndex")))
            
            'Me.ViewState("DataType") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("DataType")))
            Me.ViewState("ReturnControlName") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("ConName")))
            Me.ViewState("ForceWhere") = strForceWhere
            Me.ViewState("OptionWhereField") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("WhereField")))
            'Me.ViewState("LableCaption") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("LableCaption")))
            Me.ViewState("Width") = Trim(Request.QueryString("Width"))
            'Me.ViewState("ReturnColumnIndex") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("ReturnColumnIndex")))
            Me.ViewState("Connection") = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("Connection")))
           ' Label1.Text = Me.ViewState("LableCaption")
            If Label1.Text = "" Then Label1.Text = "Please enter Conditions:"
            GridViewBind("")
           ' Page.Response.Write(Me.ViewState("ReturnFieldIndex")+ Me.ViewState("ReturnControlName")+Me.ViewState("OptionWhereField")) : Response.End()
        End If
        If Me.ViewState("Width") <> "" Then
            GridView1.Width = CInt(Me.ViewState("Width")) - 50
        End If
      
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles GridView1.PageIndexChanging
        GridView1.PageIndex = e.NewPageIndex
        GridViewBind(Me.txtEntryData.Text)
    End Sub
    Protected Sub Button2_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnQuery.Click
        GridViewBind(Me.txtEntryData.Text)
    End Sub
    Protected Sub GridView1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles GridView1.SelectedIndexChanged
        
        ReturnSelectData(GridView1.SelectedIndex)
   
    End Sub
    Sub GridViewBind(ByVal OptionWhereData As String)
        Dim strSQL As String
        'Dim myconn As SqlConnection
        Dim ds1 As New DataSet()
        Dim intIndex As Integer
        Dim arrField As Array
        Dim arrHeaders As Array
        Dim strWhere As String = ""
        Dim connection As String = Me.ViewState("Connection")
        Dim g_adoConn As New SqlConnection(ConfigurationManager.ConnectionStrings(connection).ConnectionString)
        strSQL = "SELECT " & Me.ViewState("SelectSQL")
        If OptionWhereData <> "" And Me.ViewState("OptionWhereField") <> "" Then
            arrField = Split(Me.ViewState("OptionWhereField"), ",")
            For intIndex = 0 To UBound(arrField)
                'If Me.ViewState("DataType") = "1" Then
                strWhere = strWhere + arrField(intIndex) + " like '%" & OptionWhereData & "%'"
                'Else
                '    strWhere = strWhere + arrField(intIndex) + " like " & OptionWhereData & ""
                'End If
                If intIndex < UBound(arrField) Then strWhere = strWhere & " or "

            Next
        End If
        If strWhere <> "" Then
            strWhere = "(" & strWhere & ")"
            strSQL = strSQL & " where " & strWhere
            If Me.ViewState("ForceWhere") <> "" Then
                strSQL = strSQL & " and " & Me.ViewState("ForceWhere")
            End If
        Else
            If Me.ViewState("ForceWhere") <> "" Then
                strSQL = strSQL & " where " & Me.ViewState("ForceWhere")
            End If
        End If
        'Page.Response.Write(strSQL) : Response.End()
        Me.GridView1.Columns.Clear()

        Dim CommandField As New CommandField
        CommandField.SelectText = "<span style=""color: #3333ff""><b>pick</b></span>"
        CommandField.ShowSelectButton = True
        Me.GridView1.Columns.Add(CommandField)
  
        Dim sqlAdapter1 As New SqlDataAdapter(strSQL, g_adoConn)
        sqlAdapter1.Fill(ds1, "ds1")

        'intIndex = 1
        ' orders.Tables(0).Columns()
        arrHeaders = Split(Request.QueryString("ShowColumns"), ",")
        For intIndex = 0 To ds1.Tables(0).Columns.Count - 1
            Dim BoundField As BoundField = New BoundField
            BoundField.DataField = ds1.Tables(0).Columns(intIndex).Caption
            BoundField.HeaderText = Trim(arrHeaders(intIndex))
            Me.GridView1.Columns.Add(BoundField)
        Next

        Me.GridView1.DataSource = ds1
        Me.GridView1.DataBind()
        Me.GridView1.Dispose()
        ds1.Dispose()
        sqlAdapter1.Dispose()
        If ds1.Tables(0).Rows.Count = 1 Then
            ReturnSelectData(0)
        End If
    End Sub
   
    Sub ReturnSelectData(ByVal index As Integer)
      
        Dim ReturnControlName As Array = Split(Me.ViewState("ReturnControlName"), ",")
        Dim ReturnFieldIndex As Array = Split(Me.ViewState("ReturnFieldIndex"), ",")
       ' Dim ReturnColumnIndex As Array = Split(Me.ViewState("ReturnColumnIndex"), ",")
        Dim intCount As Integer
        Dim script As String = ""
       
       
       ' Page.Response.Write(Me.ViewState("ReturnControlName")+"---"+Me.ViewState("ReturnFieldIndex")) : Response.End()
        
        
        script += "<script>"
        For intCount = 0 To UBound(ReturnControlName)
         script += "window.opener.document.all." + Trim(ReturnControlName(intCount)) + ".value="
           script += "'" + Me.GridView1.Rows(index).Cells((ReturnFieldIndex(intCount))).Text + "';"
            
       Next
       script += "window.close();"
       script += "<"
       script += "/script>"
       
       ClientScript.RegisterClientScriptBlock(GetType(String), "", script)
    End Sub
 </script>   


<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Pack List</title>
    <script type="text/javascript" language="javascript">
    
   
    </script>
    <link rel="stylesheet" href="../../Includes/ebiz.aeu.style.css"/>
    <style type="text/css">
.dreamduwhite12px 
{ 
	color:white; 
	font-size:12px; 
}

.dreamdublack16px 
{ 
	color:black; 
	font-size:16px; 
}

</style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table>
            <tr>
                <td align="right" style="width: 163px">
                    <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label></td>
                <td style="width: 195px">
        <asp:TextBox ID="txtEntryData" runat="server" Width="185px"></asp:TextBox></td>
                <td style="width: 53px">
                    <asp:Button ID="btnQuery" runat="server" Text="Search" /></td>
                <td style="width: 12px">
                </td>
            </tr>
            <tr>
                <td style="width: 163px">
                </td>
                <td style="width: 195px">
                </td>
                <td style="width: 53px">
                </td>
                <td style="width: 12px">
                </td>
            </tr>
        </table>
        <asp:GridView ID="GridView1" runat="server" AllowPaging="True" 
            AutoGenerateColumns="False" CellPadding="4" Font-Size="Small" 
            ForeColor="#333333" GridLines="None" Height="1px" PageSize="20" Width="440px">
            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
            <Columns>
                <asp:ButtonField Text="Button" />
            </Columns>
            <RowStyle BackColor="#EFF3FB" />
            <EditRowStyle BackColor="#2461BF" />
            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
            <AlternatingRowStyle BackColor="White" />
        </asp:GridView>
        <br />
    </div>       
        
        
    </form>
</body>
</html>
