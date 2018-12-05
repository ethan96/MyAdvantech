<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Product Forecast"
    ValidateRequest="false" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            Me.txtOrderDateFrom.Text = DateAdd(DateInterval.Month, -1, Now).ToString("yyyy/MM/dd")
            Me.txtOrderDateTo.Text = DateAdd(DateInterval.Month, 12, Now).ToString("yyyy/MM/dd")
            
            GridViewBind()
        End If
        
    End Sub
    
    Function GetData(ByVal SUM_EFFECTIVE_DT_Start As String, ByVal SUM_EFFECTIVE_DT_End As String) As DataTable
        Dim _sql As New StringBuilder
        _sql.AppendLine(" select a.ROW_ID as OPTY_ID, a.NAME as OPTY_NAME, cast(a.SUM_WIN_PROB as integer) as SUM_WIN_PROB ")
        _sql.AppendLine(" , a.STAGE_NAME, b.PART_NO, sum(b.TOTAL_QTY) as TOTAL_QTY, ")
        _sql.AppendLine(" a.SUM_EFFECTIVE_DT as EFFECTIVE_DATE, d.ABC_INDICATOR, d.safety_stock, d.PLANT, c.ACCOUNT_STATUS, c.PRIMARY_SALES_EMAIL, c.ERP_ID     ")
        '_sql.AppendLine(" --,e.MATERIAL_GROUP ")
        _sql.AppendLine(" from SIEBEL_OPPORTUNITY a inner join SIEBEL_PRODUCT_FORECAST b on a.ROW_ID=b.OPTY_ID inner join SIEBEL_ACCOUNT c on a.ACCOUNT_ROW_ID=c.ROW_ID  ")
        _sql.AppendLine(" inner join SAP_PRODUCT_ABC d on b.PART_NO=d.PART_NO  ")
        _sql.AppendLine(" left join SAP_PRODUCT e on d.PART_NO=e.PART_NO ")
        _sql.AppendLine(" where ")
        _sql.AppendLine(" a.SUM_WIN_PROB>=75  ")
        _sql.AppendLine(" and (c.RBU in ('ANADMF','ANA','AENC','AAC','AMX','ALA','AiSA','AUS') or c.ERP_ID like 'U%')  ")
        _sql.AppendLine(" and d.PLANT='USH1'  ")
        _sql.AppendLine(" and (a.SUM_EFFECTIVE_DT>='" & SUM_EFFECTIVE_DT_Start & "' and a.SUM_EFFECTIVE_DT<='" & SUM_EFFECTIVE_DT_End & "') ")
        _sql.AppendLine(" and a.SALES_METHOD_NAME='Funnel Sales Methodology' ")
        _sql.AppendLine(" and e.MATERIAL_GROUP not in('BTOS','CTOS','98') ")
        _sql.AppendLine(" and b.PART_NO not like '%BTO' ")
        _sql.AppendLine(" group by a.ROW_ID, a.NAME, a.SUM_WIN_PROB, b.PART_NO, a.STAGE_NAME, a.SUM_EFFECTIVE_DT, d.ABC_INDICATOR, d.safety_stock, d.PLANT, c.ACCOUNT_STATUS, c.PRIMARY_SALES_EMAIL, c.ERP_ID ")
        ''_sql.AppendLine(" --,e.MATERIAL_GROUP ")
        _sql.AppendLine(" having sum(b.TOTAL_QTY)>=d.safety_stock and sum(b.TOTAL_QTY)>0 ")
        _sql.AppendLine(" order by a.SUM_EFFECTIVE_DT desc, a.ROW_ID, b.PART_NO ")
        
        Return dbUtil.dbGetDataTable("MY", _sql.ToString)
    End Function
    
    Sub GridViewBind()
        
      
        Me.GridView1.DataSource = GetData(Me.txtOrderDateFrom.Text, Me.txtOrderDateTo.Text)
        Me.GridView1.DataBind()

        
    End Sub
    
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles GridView1.PageIndexChanging
        GridView1.PageIndex = e.NewPageIndex
        GridViewBind()
    End Sub
    
    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(GetData(Me.txtOrderDateFrom.Text, Me.txtOrderDateTo.Text), "MyCart.xls")
    End Sub
    
    Protected Sub Button1_Click(sender As Object, e As System.EventArgs)
        GridViewBind()
    End Sub

    'Protected Sub GridView1_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)

    'End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script type="text/javascript">
        function GetAllCheckBox(cbAll) {
            var items = document.getElementsByTagName("input");
            for (i = 0; i < items.length; i++) {
                if (items[i].type == "checkbox") {
                    items[i].checked = cbAll.checked;
                }
            }
        }
    </script>
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > Product Forecast</div>
    <br />
    <div class="menu_title">
        Product Forecast</div>
    <br />
    <asp:Panel  runat="server" ID="Panel1">
        <table width="100%" class="rightcontant3">
            <tr>
                <td width="30%">
                    EFFECTIVE_DATE:
                    <asp:TextBox ID="txtOrderDateFrom" runat="server" Width="86px"></asp:TextBox>&nbsp;~&nbsp;
                    <asp:TextBox ID="txtOrderDateTo" runat="server" Width="86px"></asp:TextBox>
                    <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtOrderDateFrom"
                        Format="yyyy/MM/dd" />
                    <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtOrderDateTo"
                        Format="yyyy/MM/dd" />
                    <span class="date_word">yyyy/mm/dd</span>
                    <asp:Button ID="Button1" runat="server" Text="Query" onclick="Button1_Click" />
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 110px">
                    <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download"
                        OnClick="imgXls_Click" />
                </td>
            </tr>
        </table>
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="true" EmptyDataText="No search results were found."
            Width="100%" AllowPaging="True" PageSize="50" >
        </asp:GridView>
    </asp:Panel>
</asp:Content>