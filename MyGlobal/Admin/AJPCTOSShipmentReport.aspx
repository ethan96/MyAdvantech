<%@ Page Title="AJP CTOS Shipment Report" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtDateTo.Text = DateTime.Now.ToString("yyyy/MM/dd")

            If Request.IsAuthenticated Then
                If Not Util.IsInternalUser(User.Identity.Name) Then
                    Response.Redirect("../../home.aspx")
                End If
            End If
        End If
    End Sub

    Protected Sub imgXls_Click(sender As Object, e As ImageClickEventArgs)
        Dim DateFrom As DateTime, DateTo As DateTime

        If DateTime.TryParse(txtDateFrom.Text, DateFrom) AndAlso DateTime.TryParse(txtDateTo.Text, DateTo) AndAlso Not DateFrom > DateTo Then
            Dim str As StringBuilder = New StringBuilder

            'Ryan 20171107 Comment old SQL string out due to Qty field needs to group by
            'str.AppendLine(" select a.order_no, a.order_date, a.efftive_date as billing_date, a.Customer_ID ")
            'str.AppendLine(" , (select top 1 company_name from SAP_DIMCOMPANY z (nolock) where z.COMPANY_ID=a.Customer_ID and z.ORG_ID=a.org) as Customer_Name ")
            'str.AppendLine(" , a.sector, a.item_no as Parent_Item_No, cast(a.qty as int) as Qty, a.Sales_ID, c.FULL_NAME as Sales_Name ")
            'str.AppendLine(" , c.EMAIL as Sales_Email, a.tr_curr as currency ")
            'str.AppendLine(" , (select top 1 z.item_no from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.item_no like 'AGS-CTOS-SYS-%') as Assembly_Item ")
            'str.AppendLine(" , (select sum(z.SOamt) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.item_no like 'AGS-CTOS-SYS-%') as Assembly_Fee ")
            'str.AppendLine(" , (select sum(SOamt) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.org=a.org and a.efftive_date=a.efftive_date and z.fact_1234 = '1' and z.father_item = '') as TotalAmount ")
            'str.AppendLine(" , case when isnull((select count(*) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no And z.item_no = 'OPTION 100 OQC'),0)>0 then 'Y' ")
            'str.AppendLine(" Else 'N' end as IsOQC ")
            'str.AppendLine(" From EAI_SALE_FACT a (nolock) left Join SAP_PRODUCT b (nolock) on a.item_no=b.PART_NO ")
            'str.AppendLine(" Left Join SAP_EMPLOYEE c (nolock) on a.Sales_ID=c.SALES_CODE ")
            'str.AppendLine(" where a.org ='JP01' and b.MATERIAL_GROUP='BTOS' ")
            'str.AppendFormat(" And a.efftive_date between '{0}' and '{1}' ", DateFrom.ToString("yyyy/MM/dd"), DateTo.ToString("yyyy/MM/dd"))
            'str.AppendLine(" And a.Tran_Type='Shipment' ")
            'str.AppendLine(" order by a.efftive_date, a.order_no ")

            'Ryan 20171107 New SQL
            str.AppendLine(" select a.order_no, a.order_date, a.efftive_date as billing_date, a.Customer_ID ")
            str.AppendLine(" , (select top 1 company_name from SAP_DIMCOMPANY z (nolock) where z.COMPANY_ID=a.Customer_ID and z.ORG_ID=a.org) as Customer_Name ")
            str.AppendLine(" , a.item_no as Parent_Item_No, sum(a.qty) as Qty, a.tr_curr as currency ")
            str.AppendLine(" , (select top 1 z.item_no from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.item_no like 'AGS-CTOS-SYS-%') as Assembly_Item ")
            str.AppendLine(" , (select sum(z.SOamt) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.item_no like 'AGS-CTOS-SYS-%') as Assembly_Fee ")
            str.AppendLine(" , (select sum(SOamt) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no and z.org=a.org and a.efftive_date=a.efftive_date and z.fact_1234 = '1' and z.father_item = '') as TotalAmount ")
            str.AppendLine(" , case when isnull((select count(*) from EAI_SALE_FACT z (nolock) where z.order_no=a.order_no And z.item_no = 'OPTION 100 OQC'),0)>0 then 'Y' ")
            str.AppendLine(" Else 'N' end as IsOQC ")
            str.AppendLine(" From EAI_SALE_FACT a (nolock) left Join SAP_PRODUCT b (nolock) on a.item_no=b.PART_NO ")
            str.AppendLine(" Left Join SAP_EMPLOYEE c (nolock) on a.Sales_ID=c.SALES_CODE ")
            str.AppendLine(" where a.org ='JP01' and b.MATERIAL_GROUP='BTOS' ")
            str.AppendFormat(" And a.efftive_date between '{0}' and '{1}' ", DateFrom.ToString("yyyy/MM/dd"), DateTo.ToString("yyyy/MM/dd"))
            str.AppendLine(" And a.Tran_Type='Shipment' ")
            str.AppendLine(" group by a.order_no, a.order_date,a.org, a.efftive_date,a.Customer_ID ,a.item_no, a.tr_curr ")
            str.AppendLine(" order by a.efftive_date, a.order_no ")

            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", str.ToString)

            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Excel download
                Dim stream As IO.MemoryStream = Advantech.Myadvantech.DataAccess.ExcelUtil.DataTableToMemoryStream(dt)
                With HttpContext.Current.Response
                    .Clear()
                    .ContentType = "application/vnd.ms-excel"
                    .AddHeader("Content-Disposition", String.Format("attachment; filename=CTOSShipmentReport.xlsx;"))
                    .BinaryWrite(stream.ToArray)
                End With
                HttpContext.Current.Response.Flush()
                HttpContext.Current.Response.End()
            Else
                Util.JSAlert(Me.Page, "No data returned.")
            End If
        Else
            Util.JSAlert(Me.Page, "Input date is not in a valid format.")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />
    <h2>AJP CTOS Shipment Report</h2>
    <br />

    <div>
        From Date:
        <asp:TextBox ID="txtDateFrom" runat="server" Width="80px"></asp:TextBox>
        <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtDateFrom" Format="yyyy/MM/dd"/>
        &nbsp;-&nbsp;
        To Date:
        <asp:TextBox ID="txtDateTo" runat="server" Width="80px"></asp:TextBox>
        <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtDateTo" Format="yyyy/MM/dd"/>
        &nbsp;
        <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download Excel" OnClick="imgXls_Click" />
    </div>
    <br />
</asp:Content>
