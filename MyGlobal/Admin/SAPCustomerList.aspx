<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="CreateSAPCustomerDAL" %>
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            'If Session("ORG_ID") Is Nothing OrElse Session("ORG_ID").ToString.ToUpper <> "EU10" Then
            '    Response.Redirect("~/home.aspx") : Exit Sub
            'End If
            BindGV()
            'Dim ws As New SAPCustomer.CreateSAPCustomerDAL
            'ws.Timeout = -1
            'Dim ds As New DataSet
            'Dim dt As DataTable = ws.GetDTApplication()
            'Dim dr As DataRow = dt.NewRow()
            'For i As Integer = 0 To dt.Columns.Count - 1
            '    Response.Write(dt.Columns(i).ColumnName+"<BR/>" )
            'Next
            ''Response.Write(ws.CreateSAPCustomer(ds))
            'Dim objGeneralData As New SAPCustomerGeneralData,  objCreditData As New SAPCustomerCreditData
        End If
    End Sub
    Private Sub BindGV()
        Dim sql As New StringBuilder
        sql.AppendFormat(" SELECT A.ROW_ID,G.APLICATIONNO,G.COMPANYNAME,G.COMPANYID,G.ISEXIST, A.STATUS,   A.REQUEST_BY,  A.REQUEST_DATE ")
        sql.AppendFormat(" FROM SAPCUSTOMER_APPLICATION A INNER JOIN SAPCUSTOMER_CREDITDATA C ON  A.ROW_ID = C.APPLICATIONID ")
        sql.AppendFormat(" INNER JOIN SAPCUSTOMER_GENERALDATA G ON  A.ROW_ID = G.APPLICATIONID  ")
        'If Not Util.IsTesting() Then
        '    sql.Append(" WHERE A.REQUEST_BY<>'ming.zhao@advantech.com.cn' ")
        'End If
        If Not (String.Equals(HttpContext.Current.User.Identity.Name, "xiaoya.hua@advantech.com.cn") _
                OrElse String.Equals(HttpContext.Current.User.Identity.Name, "ming.zhao@advantech.com.cn")) Then
            sql.Append(" WHERE A.REQUEST_BY<>'xiaoya.hua@advantech.com.cn'  and A.REQUEST_BY<>'ming.zhao@advantech.com.cn' ")
        End If
        sql.Append("  ORDER BY A.request_date DESC ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("mylocal", sql.ToString())
        gv1.DataSource = dt
        gv1.DataBind()
    End Sub
    Public Function GetSTATUS(ByVal STATUS As String) As String
        Select Case STATUS.ToString.Trim
            Case 0
                Return "Request"
            Case 1
                Return "Approve"
            Case 2
                Return "Reject"
            Case Else
                Return ""
        End Select
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataKeyNames="row_id">
        <Columns>
            <asp:TemplateField HeaderText="Ticket Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" Target="_blank" runat="server" NavigateUrl='<%# Eval("ROW_ID", "CreateSAPCustomer.aspx?ApplicationID={0}") %>'>
                                    <%# Eval("APLICATIONNO")%>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Company Name" DataField="COMPANYNAME" HeaderStyle-HorizontalAlign="Center"   ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="Is Exist" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:CheckBox runat="server" ID="tj" Checked='<%#Eval("ISEXIST")%> ' Enabled="false" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Company ID" DataField="CompanyID" HeaderStyle-HorizontalAlign="Center"
                ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <%# GetSTATUS(Eval("STATUS"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Registered By" DataField="REQUEST_BY" SortExpression="REQUEST_BY"
                HeaderStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Registered on" DataField="REQUEST_DATE" SortExpression="REQUEST_DATE"
                DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</asp:Content>
