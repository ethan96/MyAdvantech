<%@ Page Title="DataMining - Catalog Price & Inventory" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %> 

<script runat="server">

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Util.IsInternalUser2 Then
                Dim btnGetPrice As Button = CType(e.Row.FindControl("btnGetPrice"), Button)
                btnGetPrice.Visible = False
            Else
                Dim lbPrice As Label = CType(e.Row.FindControl("lbPrice"), Label)
                lbPrice.Visible = False
            End If
        End If
    End Sub

    Function GetCatalogs() As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendLine(String.Format(" select top 999 a.PART_NO, a.PRODUCT_DESC, a.PRODUCT_HIERARCHY, a.EGROUP, a.EDIVISION, " +
                                      " a.MATERIAL_GROUP, a.MODEL_NO, a.CREATE_DATE, a.STATUS "))
            .AppendLine(String.Format(" from SAP_PRODUCT a "))
            .AppendLine(String.Format(" where (a.PART_NO like '20000%' or a.PART_NO like '86%') and a.PRODUCT_HIERARCHY in ('AGSG-CTOS-0000','OTHR-MEMO-0000')  "))
            If Trim(Me.txtPN.Text) <> String.Empty Then .AppendLine(String.Format(" and a.part_no like N'%{0}%' ", Replace(Trim(Me.txtPN.Text), "'", "''")))
            If Trim(Me.txtDesc.Text) <> String.Empty Then .AppendLine(String.Format(" and a.PRODUCT_DESC like N'%{0}%' ", Replace(Trim(Me.txtDesc.Text), "'", "''")))
            .AppendLine(String.Format(" order by a.CREATE_DATE desc  "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        With dt.Columns
            .Add("Price") : .Add("ATP") : .Add("Owner") : .Add("Owner_Email") : .Add("Owner_Group")
        End With

        'Dim paDt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", "select a.part_no, a.price, a.atp, IsNull((select top 1 z.EXTENDED_DESC from MyLocal.dbo.SAP_PRODUCT_EXT_DESC z where z.PART_NO=a.part_no),'N/A') as ext_desc from catalog_price_atp a")
        'ICC 2016/5/13 SAP prodcut long description is no longer in MyLocal DB, we have changed sync program to MyGlobal
        Dim descExtend As Object = dbUtil.dbExecuteScalar("MY", String.Format(" select TOP 1 ISNULL(EXTENDED_DESC, '') AS [EXTENDED_DESC] from SAP_PRODUCT_EXT_DESC where PART_NO = '{0}' ", Replace(Trim(Me.txtPN.Text), "'", "''")))
        Dim paDt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", "select a.part_no, a.price, a.atp from catalog_price_atp a")
        For Each r As DataRow In dt.Rows
            r.Item("ATP") = 0
            Dim rs() As DataRow = paDt.Select("part_no='" + r.Item("part_no") + "'")
            If rs.Length > 0 Then
                If Double.TryParse(rs(0).Item("price"), 0) AndAlso CDbl(rs(0).Item("price")) > 0 Then r.Item("Price") = FormatNumber(rs(0).Item("price"), 2).ToString()
                If Double.TryParse(rs(0).Item("ATP"), 0) AndAlso CDbl(rs(0).Item("ATP")) > 0 Then r.Item("ATP") = rs(0).Item("ATP").ToString()
                'If rs(0).Item("ext_desc").ToString().Trim() <> "N/A" And rs(0).Item("ext_desc").ToString().Trim() <> "" Then
                '    r.Item("PRODUCT_DESC") = rs(0).Item("ext_desc").ToString()
                'End If
                'ICC 2016/5/13 Use MyGlobal data
                If Not descExtend Is Nothing AndAlso Not String.IsNullOrEmpty(descExtend.ToString()) Then
                    r.Item("PRODUCT_DESC") = descExtend.ToString()
                End If
            End If
            If Date.TryParseExact(r.Item("CREATE_DATE"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, Now) Then
                r.Item("CREATE_DATE") = Date.ParseExact(r.Item("CREATE_DATE"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd")
            End If
        Next
        Dim ndt As DataTable = dt.Clone()
        For Each r As DataRow In dt.Rows
            Dim createDate As Date = CDate(r.Item("CREATE_DATE"))
            If DateDiff(DateInterval.Year, createDate, Now) < 2 OrElse r.Item("ATP") > 0 Then
                ndt.ImportRow(r)
            End If
        Next
        dt = ndt
        Dim ownerDt As DataTable = dbUtil.dbGetDataTable("MY",
            " select a.PART_NO, a.OWNER, a.OWNER_EMAIL, c.Name  " +
            " from FORECAST_CATALOG_LIST a left join ADVANTECH_ADDRESSBOOK b on a.OWNER_EMAIL=b.PrimarySmtpAddress  " +
            " left join ADVANTECH_ADDRESSBOOK_GROUP c on b.ID=c.ID inner join SAP_PRODUCT d on a.PART_NO=d.PART_NO  " +
            " where c.Name in ('MARCOM.ACG.ACL','MARCOM.IAG.ACL','MARCOM.eP.ACL') ")

        '20170324 TC: Per Wen's request get catalog owner from eFlow instead
        Dim PNOwnerList As List(Of CatalogPN_Owner) = Nothing
        If ViewState("Eflow_PN_Owner") Is Nothing Then
            ViewState("Eflow_PN_Owner") = Get_EFlowCatalogOnwer()
        End If
        PNOwnerList = ViewState("Eflow_PN_Owner")
        For Each r As DataRow In dt.Rows
            Dim rs() As DataRow = ownerDt.Select("part_no='" + r.Item("part_no") + "'")
            If rs.Length > 0 Then
                r.Item("Owner") = rs(0).Item("Owner")
                r.Item("OWNER_EMAIL") = rs(0).Item("OWNER_EMAIL")
                r.Item("Owner_Group") = rs(0).Item("Name")
            Else
                r.Item("Owner") = "" : r.Item("OWNER_EMAIL") = "" : r.Item("Owner_Group") = "Corporate"
            End If

            Dim EFOwner = From q In PNOwnerList Where String.Equals(q.PN, r.Item("part_no"), StringComparison.CurrentCultureIgnoreCase)

            If EFOwner.Count() > 0 Then
                r.Item("Owner") = Util.GetNameVonEmail(EFOwner.First.Owner)
                r.Item("OWNER_EMAIL") = EFOwner.First.Owner
            End If

        Next
        Return dt
    End Function

    Function Get_EFlowCatalogOnwer() As List(Of CatalogPN_Owner)
        Dim dtEFlowCatOwner As New DataTable
        '20171019 TC: Per dba's request, eFlow db is migrated to ACLFLOWAP2
        Dim aptEFlow As New SqlClient.SqlDataAdapter("SELECT [EMAIL] , [Catalog_PN] FROM [FlowER].[dbo].[VW_FORM_BASFORM1033]  where Catalog_PN is not null and EMAIL is not null",
                                         "Data Source=ACLFLOWAP2;Initial Catalog=FlowER;Persist Security Info=True;User ID=MyAdvanReader;Password=MyAdvanReader;async=true;Connect Timeout=180;pooling='true'")
        aptEFlow.Fill(dtEFlowCatOwner)
        aptEFlow.SelectCommand.Connection.Close()
        Dim PNOwnerList As New List(Of CatalogPN_Owner)
        For Each CatOwnerRow As DataRow In dtEFlowCatOwner.Rows
            Dim pns() As String = Split(CatOwnerRow.Item("Catalog_PN"), "/")
            For Each pn In pns
                If Trim(pn).Length >= 8 Then
                    PNOwnerList.Add(New CatalogPN_Owner(Trim(pn), CatOwnerRow.Item("EMAIL")))
                End If
            Next
        Next
        Return PNOwnerList
    End Function

    <Serializable>
    Class CatalogPN_Owner
        Public Property PN As String : Public Property Owner As String
        Public Sub New(PN As String, Owner As String)
            Me.PN = PN : Me.Owner = Owner
        End Sub
    End Class

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function WSGetOwnerDetail(ByVal owneremail As String) As String
        'Return owneremail

        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        '    " select distinct a.PrimarySmtpAddress, a.Name, IsNull(a.BusinessTelephoneNumber,'') as BusinessTelephoneNumber, " + _
        '    " IsNull(a.Department,'') as Department, IsNull(a.OfficeLocation,'') as OfficeLocation, IsNull(c.Name,'') as group_name  " + _
        '    " from ADVANTECH_ADDRESSBOOK a left join ADVANTECH_ADDRESSBOOK_ALIAS b on a.ID=b.ID left join ADVANTECH_ADDRESSBOOK_GROUP c on a.ID=c.ID  " + _
        '    " where (a.PrimarySmtpAddress='{0}' or b.Email='{0}') and c.Name in ('MARCOM.ACG.ACL','MARCOM.IAG.ACL','MARCOM.eP.ACL') order by IsNull(c.Name,'')  ", Replace(owneremail, "'", "''")))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
            " select distinct a.PrimarySmtpAddress, a.Name, IsNull(a.BusinessTelephoneNumber,'') as BusinessTelephoneNumber, " + _
            " IsNull(a.Department,'') as Department, IsNull(a.OfficeLocation,'') as OfficeLocation, IsNull(c.GROUP_NAME,'') as group_name  " + _
            " from AD_MEMBER a left join AD_MEMBER_ALIAS b on a.PrimarySmtpAddress=b.EMAIL left join AD_MEMBER_GROUP c on a.PrimarySmtpAddress=c.EMAIL " + _
            " where (a.PrimarySmtpAddress='{0}' or b.ALIAS_EMAIL='{0}') and c.GROUP_NAME in ('MARCOM.ACG.ACL','MARCOM.IAG.ACL','MARCOM.eP.ACL') order by IsNull(c.GROUP_NAME,'')  ", Replace(owneremail, "'", "''")))


        If dt.Rows.Count > 0 Then
            Dim sb As New System.Text.StringBuilder
            sb.AppendLine("<table width='100%'>")
            sb.AppendLine(String.Format("<tr valign='top'><th colspan='2'><h2>{0}</h2></th></tr>", dt.Rows(0).Item("Name")))
            sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td><a href='mailto:{1}'>{1}</a><td/></tr>", "Email", dt.Rows(0).Item("PrimarySmtpAddress")))
            sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "VoIP", dt.Rows(0).Item("BusinessTelephoneNumber")))
            sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Department", dt.Rows(0).Item("Department")))
            sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "OfficeLocation", dt.Rows(0).Item("OfficeLocation")))
            Dim grp As New ArrayList
            For Each r As DataRow In dt.Rows
                If r.Item("group_name").ToString() <> String.Empty AndAlso Not grp.Contains(r.Item("group_name")) Then grp.Add(r.Item("group_name"))
            Next
            If grp.Count > 0 Then
                Dim grps As String = String.Join("<br />", grp.ToArray())
                sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Member of:", grps))
            End If
            sb.AppendLine("</table>")
            Return sb.ToString()
        End If
        Return "No Data"
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request.IsAuthenticated Then
                '20130723 Per AMY Chloe's request, open access to janelourd.h@advantech.com
                'If MailUtil.IsInRole("ITD.ACL") = False AndAlso MailUtil.IsInRole("Marketing.ACL") = False _
                '    AndAlso MailUtil.IsInRole("Marketing.Worldwide") = False _
                '    AndAlso String.Equals(User.Identity.Name, "janelourd.h@advantech.com", StringComparison.CurrentCultureIgnoreCase) = False Then
                '    Response.Redirect("../../home.aspx")
                'End If
                If Not Util.IsInternalUser(User.Identity.Name) AndAlso Not Session("account_status") = "CP" Then
                    Response.Redirect("../../home.aspx")
                End If
                gv1.DataSource = GetCatalogs() : gv1.DataBind()
            End If
        End If
    End Sub

    Protected Sub imgXls_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(GetCatalogs(), "Catalog_Price_Inventory.xls")
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        gv1.DataSource = GetCatalogs() : gv1.DataBind()
        If Trim(txtPN.Text) <> "" And gv1.Rows.Count = 0 Then
            gv1.EmptyDataText = txtPN.Text + " is either not found or it was created for more than two years and has no inventory"
        End If
    End Sub

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetCatlogPN(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        " select top 10 a.part_no from sap_product a where a.PART_NO like '20000%' and a.part_no like '{0}%' " + _
        " and a.PRODUCT_HIERARCHY in ('AGSG-CTOS-0000','OTHR-MEMO-0000') order by a.part_no ", prefixText.Trim().Replace("'", "''").Replace("*", "%")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub btnGetPrice_Click(sender As Object, e As EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim PartNo As String = row.Cells(0).Text
        Dim lbPrice As Label = CType(row.FindControl("lbPrice"), Label)
        lbPrice.Visible = True
        lbPrice.Text = 0
        obj.Visible = False

        'Get Price
        Dim dtPriceRec As New DataTable
        SAPtools.getSAPPriceByTable(PartNo, 1, Session("ORG_ID"), Session("COMPANY_ID"), "USD", dtPriceRec)
        Dim USDPrice As Decimal = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
        If dtPriceRec.Rows.Count > 0 And IsNumeric(USDPrice) Then
            lbPrice.Text = USDPrice
        End If

    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <h2>Catalog Price & Inventory</h2>  
    <br />
    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" TargetControlID="txtPN" CompletionInterval="200" MinimumPrefixLength="3" ServiceMethod="GetCatlogPN" />    
    <asp:Panel runat="server" ID="panSearchPN" DefaultButton="btnSearch">
        <b>Part Number:</b>&nbsp;<asp:TextBox runat="server" ID="txtPN" Width="200px" />&nbsp;
        <b>Description:</b>&nbsp;<asp:TextBox runat="server" ID="txtDesc" Width="120px" />&nbsp;
        <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
    </asp:Panel>    
    <br />
    <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download Excel" OnClick="imgXls_Click" />
    <asp:GridView runat="server" ID="gv1" Width="100%" AllowSorting="false" AutoGenerateColumns="false" 
        OnRowDataBound="gv1_RowDataBound" OnRowCreated="gvRowCreated" ShowHeaderWhenEmpty="true" EmptyDataText="No data">
        <Columns>
            <asp:BoundField HeaderText="Part No." DataField="PART_NO" SortExpression="PART_NO" />
            <asp:BoundField HeaderText="Description" DataField="PRODUCT_DESC" SortExpression="PRODUCT_DESC" />
            <asp:TemplateField HeaderText="USD Price" ItemStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:Button ID="btnGetPrice" runat="server" Text="GetPrice" OnClick="btnGetPrice_Click" />
                    <asp:Label ID="lbPrice" runat="server" Text='<%#Eval("Price")%>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <%--<asp:BoundField HeaderText="USD Price" DataField="Price" SortExpression="Price" ItemStyle-HorizontalAlign="Center" />--%>
            <asp:BoundField HeaderText="Inventory" DataField="ATP" SortExpression="ATP" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Created Date" DataField="CREATE_DATE" SortExpression="CREATE_DATE" />            
            <asp:TemplateField HeaderText="Owner">
                <ItemTemplate>
                    <a href="javascript:void(0);" onclick=ShowOwnerDetail('<%#Eval("OWNER_EMAIL") %>')><%#Eval("Owner")%></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Owner's Group" DataField="Owner_Group" SortExpression="Owner_Group" />
        </Columns>
    </asp:GridView>
    <script type="text/javascript">
        function ShowOwnerDetail(oemail) {
            var divOwner = document.getElementById('div_Owner');
            divOwner.style.display = 'block';
            var divOwnerDetail = document.getElementById('div_OwnerDetail');
            divOwnerDetail.innerHTML = "<center><img src='../../Images/loading2.gif' alt='Loading...' width='35' height='35' />Loading...</center> ";
            PageMethods.WSGetOwnerDetail(oemail,
                function (pagedResult, eleid, methodName) {
                    divOwnerDetail.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    //alert(error.get_message());
                    divOwnerDetail.innerHTML = error.get_message();
                });
        }
        function CloseDivOwner() {
            var divOwner = document.getElementById('div_Owner');
            divOwner.style.display = 'none';
        }
    </script>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="PanelOwnerDetail" HorizontalSide="Center" VerticalSide="Middle"
        HorizontalOffset="250" VerticalOffset="200" />
    <asp:Panel runat="server" ID="PanelOwnerDetail">
        <div id="div_Owner" style="display: none; background-color: white;
            border: solid 1px silver; padding: 10px; width: 500px; height: 350px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td><a href="javascript:void(0);" onclick="CloseDivOwner();">Close</a></td>
                </tr>
                <tr>
                    <td>
                        <div id="div_OwnerDetail"></div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>  
</asp:Content>