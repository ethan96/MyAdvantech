<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim dt As New CreateSAPCustomer.GetAllDataTable
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            'If Session("ORG_ID") Is Nothing OrElse Session("ORG_ID").ToString.ToUpper <> "EU10" Then
            '    Response.Redirect("~/home.aspx") : Exit Sub
            'End If
            If Request("ApplicationID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("ApplicationID")) Then
                Dim ApplicationID As String = Trim(Request("ApplicationID").ToString)
                Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
                dt = A.GetDataByApplicationID(ApplicationID)
                gv1.DataSource = dt
                gv1.DataBind()
                If Boolean.Parse(dt.Rows(0).Item("HASSHIPTODATA")) Then
                    gv2.DataSource = dt : gv2.DataBind()
                    shiptohr.Visible = True
                End If
                If Boolean.Parse(dt.Rows(0).Item("HASBILLINGDATA")) Then
                    gv3.DataSource = dt : gv3.DataBind()
                    Billinghr.Visible = True
                End If
            End If
        End If
    End Sub

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If dt.Rows(0).Item("STATUS").ToString = "2" Then
            e.Row.Cells(10).Visible = False
            e.Row.Cells(11).Visible = False
        ElseIf dt.Rows(0).Item("STATUS").ToString = "1" Then
            e.Row.Cells(12).Visible = False
            e.Row.Cells(13).Visible = False
        End If
        'If e.Row.RowType = DataControlRowType.DataRow Then
        '    Dim dt As System.Data.DataRowView = CType(e.Row.DataItem, System.Data.DataRowView)
        '    Dim STATUS As String = dt.DataView(e.Row.RowIndex)("STATUS").ToString
        '    If STATUS = "1" Then
        '        e.Row.BackColor = Drawing.Color.Tomato
        '    End If
        'End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />
    <div id="divdetail">
        <h2>
            Sold-to</h2>
        <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" OnRowDataBound="gv1_RowDataBound">
            <Columns>
                <asp:BoundField HeaderText="Company ID" DataField="CompanyID" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="COMPANY NAME" DataField="COMPANYNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="ADDRESS" DataField="ADDRESS" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="CITY" DataField="CITY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="POST CODE" DataField="POSTCODE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="VATNUMBER" DataField="VATNUMBER" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
  <%--              <asp:BoundField HeaderText="TEL NUMBER" DataField="TELNUMBER" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="FAX NUMBER" DataField="FAXNUMBER" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />--%>
                <asp:BoundField HeaderText="CONTACT PERSONNAME" DataField="CONTACTPERSONNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="CONTACT PERSONEMAIL" DataField="CONTACTPERSONEMAIL" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="REQUEST BY" DataField="REQUEST_BY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="REQUEST DATE" DataField="REQUEST_DATE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="APPROVED BY" DataField="APPROVED_BY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="APPROVED DATE" DataField="APPROVED_DATE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="REJECTED BY" DataField="REJECTED_BY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="REJECTED DATE" DataField="REJECTED_DATE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="COMMENT" DataField="COMMENT" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
            </Columns>
            <FixRowColumn FixRowType="Header" FixColumns="-1" FixRows="-1" TableWidth="900px" />
        </sgv:SmartGridView>
        <br />
        <h2 runat="server" id="shiptohr" visible="false">
            Ship-to</h2>
        <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="false" Width="900">
            <Columns>
             <asp:BoundField HeaderText="Company ID" DataField="SHIPTOERPID" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO COMPANYNAME" DataField="SHIPTOCOMPANYNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO VATNUMBER" DataField="SHIPTOVATNUMBER" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO ADDRESS" DataField="SHIPTOADDRESS" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO POSTCODE" DataField="SHIPTOPOSTCODE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO COUNTRY" DataField="SHIPTOCOUNTRY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO CITY" DataField="SHIPTOCITY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
<%--                <asp:BoundField HeaderText="SHIPTO TEL" DataField="SHIPTOTEL" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO FAX" DataField="SHIPTOFAX" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />--%>
                <asp:BoundField HeaderText="SHIPTO CONTACTNAME" DataField="SHIPTOCONTACTNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="SHIPTO CONTACTEMAIL" DataField="SHIPTOCONTACTEMAIL" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
            </Columns>
        </asp:GridView>
        <br />
        <h2 id="Billinghr" runat="server" visible="false">
            Billing Address</h2>
        <asp:GridView runat="server" ID="gv3" AutoGenerateColumns="false" Width="900">
            <Columns>
             <asp:BoundField HeaderText="Company ID" DataField="BILLTOERPID" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING COMPANYNAME" DataField="BILLINGCOMPANYNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING VATNUMBER" DataField="BILLINGVATNUMBER" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING ADDRESS" DataField="BILLINGADDRESS" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING POSTCODE" DataField="BILLINGPOSTCODE" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING COUNTRY" DataField="BILLINGCOUNTRY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING CITY" DataField="BILLINGCITY" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
<%--                <asp:BoundField HeaderText="BILLING TEL" DataField="BILLINGTEL" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING FAX" DataField="BILLINGFAX" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />--%>
                <asp:BoundField HeaderText="BILLING CONTACTNAME" DataField="BILLINGCONTACTNAME" HeaderStyle-HorizontalAlign="Center"
                    ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField HeaderText="BILLING CONTACTEMAIL" DataField="BILLINGCONTACTEMAIL"
                    HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
