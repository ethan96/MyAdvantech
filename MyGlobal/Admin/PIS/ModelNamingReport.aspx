<%@ Page Title="MyAdvantech - Model Naming Report" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    'For Jie Tang on 20150713
    Function GetPNModelData() As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select distinct a.MODEL_NO, b.PM, b.PD_Head, b.PG_Head, ")
            .AppendLine(" (select COUNT(distinct z.PART_NO) from SAP_PRODUCT z (nolock) where z.MODEL_NO=a.MODEL_NO and z.MATERIAL_GROUP in ('PRODUCT','BTOS','CTOS','ODM','T','ES')) as [# of PNs] ")
            .AppendLine(" from SAP_PRODUCT a (nolock) left join CurationPool.dbo.APS_PD_PM b (nolock) on a.PRODUCT_LINE=b.PDL  ")
            .AppendLine(" where a.PRODUCT_TYPE='ZFIN' ")
            .AppendLine(" and a.MATERIAL_GROUP in ('PRODUCT','BTOS','CTOS','ODM','T','ES') ")
            .AppendLine(" and a.MODEL_NO<>'' ")
            .AppendLine(" order by a.MODEL_NO, b.PM  ")
        End With
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            Dim dt = GetPNModelData()
            With dt.Columns
                .Add("MODEL_PREFIX") : .Add("MODEL_SUFFIX")
            End With
            For Each r As DataRow In dt.Rows
                If r.Item("MODEL_NO") IsNot DBNull.Value Then
                    Dim modelSegs() As String = Split(r.Item("MODEL_NO").ToString(), "-")
                    If modelSegs.Length <= 1 Then
                        r.Item("MODEL_PREFIX") = r.Item("MODEL_NO") : r.Item("MODEL_SUFFIX") = ""
                    Else
                        r.Item("MODEL_PREFIX") = modelSegs(0)
                        r.Item("MODEL_SUFFIX") = r.Item("MODEL_NO").ToString().Substring(r.Item("MODEL_NO").ToString().IndexOf("-") + 1)
                    End If
                End If
            Next
            gvModel.DataSource = dt
            gvModel.DataBind()
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <table></table>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:GridView runat="server" ID="gvModel" Width="100%" AutoGenerateColumns="true">
                                <Columns>

                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>