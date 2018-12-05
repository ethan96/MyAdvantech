<%@ Page Language="VB" Title="UNICA Campaign Zone" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim strRBUs() As String = {"AAU", "ABR", "ACN", "AEU", "AID", "AIN", "AJP", "AKR", "AMY", "ANA", "ASG", "ATH", "ATW", "Inter-Con", "ARU"}
    Dim strSBUs() As String = {"IAG", "Emb’Core", "ESG", "NCG", "Logistics", "Medical", "iService"}

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtFromDate.Text = "2012/12/1" : txtToDate.Text = Now.ToString("yyyy/M/d")
            Run1stLevelReport()
        End If
    End Sub

    Protected Sub btnQuery_Click(sender As Object, e As System.EventArgs)
        Run1stLevelReport()
    End Sub

    Sub Run1stLevelReport()
        Dim dateFrom As Date = New Date(2012, 1, 1), dateTo As Date = Now
        If Not Date.TryParseExact(txtFromDate.Text, "yyyy/M/d", New System.Globalization.CultureInfo("en-US"), Globalization.DateTimeStyles.None, dateFrom) Then
            dateFrom = New Date(2012, 1, 1)
        End If
        If Not Date.TryParseExact(txtToDate.Text, "yyyy/M/d", New System.Globalization.CultureInfo("en-US"), Globalization.DateTimeStyles.None, dateTo) Then
            dateTo = Now
        End If
        txtFromDate.Text = dateFrom.ToString("yyyy/M/d") : txtToDate.Text = dateTo.ToString("yyyy/M/d")
        Dim dtCamp As DataTable = GetCampaignDt(dateFrom, dateTo, "", "")
        Dim sb As New System.Text.StringBuilder
        sb.AppendLine("<table class='dataTable' width='900' border='0' cellspacing='1' cellpadding='0' bgcolor='#999999'>")
        sb.AppendLine("<tr>")
        sb.AppendLine("<td>&nbsp;</td>")
        For Each strSBU As String In strSBUs
            sb.AppendLine("<th>" + strSBU + "</th>")
        Next
        sb.AppendLine("</tr>")
        For Each strRBU As String In strRBUs
            sb.AppendLine("<tr>")
            sb.Append("<th width='9%'>" + strRBU + "</th>")
            For Each strSBU As String In strSBUs
                sb.Append("<td width='13%' align='center'>")
                Dim rs() As DataRow = dtCamp.Select("ProductGroup='" + strSBU + "' and SBU_Name='" + strRBU + "'")
                If rs.Length > 0 Then
                    sb.Append("<a href='javascript:void(0);' onclick=""Show2ndLevelCampaign('" + strSBU + "','" + strRBU + "');"">" + rs.Length.ToString() + "</a>")
                Else
                    sb.Append("--")
                End If
                sb.Append("</td>")
            Next
            sb.AppendLine("</tr>")
        Next
        sb.AppendLine("</table>")
        divCampaignReport.InnerHtml = sb.ToString()
    End Sub

    Public Shared Function GetCampaignDt(ByVal dateFrom As Date, ByVal dateTo As Date, ByVal SBU As String, ByVal RBU As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select CampaignID, CampaignCode, CampaignName, Description, Creator, LastUpdBy, ProductGroup, TargetSolution, ParentCampaignCode, SBU_Name,  "))
            .AppendLine(String.Format(" CreateDate, StartDate, EndDate, IsNull((select top 1 z.Name from UNICADBP.dbo.UA_Campaign z where z.CampaignCode=a.ParentCampaignCode order by z.CreateDate desc),'') as ParentCampaignName  "))
            .AppendLine(String.Format(" from  "))
            .AppendLine(String.Format(" (  "))
            .AppendLine(String.Format(" 	select a.CampaignID, a.CampaignCode, a.Name as CampaignName, a.Description, c.NAME as Creator, d.NAME as LastUpdBy,  "))
            .AppendLine(String.Format(" 	IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=100),'') as ProductGroup,  "))
            .AppendLine(String.Format(" 	IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=101),'') as TargetSolution,  "))
            .AppendLine(String.Format(" 	IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=102),'') as ParentCampaignCode,  "))
            .AppendLine(String.Format(" 	b.Name as SBU_Name, a.CreateDate, a.StartDate, a.EndDate  "))
            .AppendLine(String.Format(" 	from UNICADBP.dbo.UA_Campaign a inner join UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID  "))
            .AppendLine(String.Format(" 	inner join UNICAMPP.dbo.USM_USER c on a.CreateBy=c.ID inner join UNICAMPP.dbo.USM_USER d on a.UpdateBy=d.ID  "))
            .AppendLine(String.Format(" 	where a.FolderID in  "))
            .AppendLine(String.Format(" 	(  "))
            .AppendLine(String.Format(" 		select z.FolderID from UNICADBP.dbo.UA_Folder z where z.Name in ('AAU','ABR','ACN','AEU','AID','AIN','AJP','AKR','AMY','ANA','ASG','ATH','ATW','Inter-Con','ARU') and z.ParentFolderID=2  "))
            .AppendLine(String.Format(" 	)  "))
            .AppendLine(String.Format(" 	and a.CampaignCode in  "))
            .AppendLine(String.Format(" 	(  "))
            .AppendLine(String.Format(" 		select distinct a.CAMPAIGN_CODE from MyAdvantechGlobal.dbo.CAMPAIGN_UNICA a inner join MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID  "))
            .AppendLine(String.Format(" 		where b.ACTUAL_SEND_DATE is not null  "))
            .AppendLine(String.Format(" 	)  "))
            .AppendLine(String.Format(" ) as a  "))
            .AppendLine(String.Format(" where a.StartDate>='" + dateFrom.ToString("yyyy-MM-dd") + "' and a.StartDate<='" + dateTo.ToString("yyyy-MM-dd") + "' "))
            If String.IsNullOrEmpty(SBU) = False Then
                .AppendLine(" and ProductGroup='" + SBU + "' ")
            End If
            If String.IsNullOrEmpty(RBU) = False Then
                .AppendLine(" and SBU_Name='" + RBU + "' ")
            End If
        End With
        Dim dtCamp As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        Return dtCamp
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function Show2ndLevelCampaign(ByVal sbu As String, ByVal rbu As String, ByVal txtFrom As String, ByVal txtTo As String) As String
        'Return sbu + " " + rbu + " " + txtFrom + " " + txtTo
        Dim dtCamp As DataTable = GetCampaignDt(CDate(txtFrom), CDate(txtTo), sbu, rbu)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine("<table class='dataTable' width='100%' border='0' cellspacing='1' cellpadding='0' bgcolor='#999999'>")
            .AppendLine("<tr><th>Campaign Name</th><th>Report</th></tr>")
            For Each rCamp As DataRow In dtCamp.Rows
                .AppendLine(String.Format( _
                            "<tr>" + _
                            "   <td>{0}</td>" + _
                            "   <td><a href='http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode={1}' target='_blank'>Campaign Report</a></td>" + _
                            "</tr>", rCamp.Item("CampaignName"), rCamp.Item("CampaignCode")))
            Next
            .AppendLine("</table>")
        End With
        Return sb.ToString()
    End Function

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link type="text/css" rel="stylesheet" href="http://unica.advantech.com.tw/AOnline/Dashboard/campaign.files/main.css" />
</head>
<body>
    <script type="text/javascript">
        function Show2ndLevelCampaign(sbu, rbu) {
            var div2ndCampaign = document.getElementById('div2ndCampaign');
            div2ndCampaign.style.display = 'block';
            var div_2ndCampaignDetail = document.getElementById('div_2ndCampaignDetail');
            div_2ndCampaignDetail.innerHTML = "<center><img src='../../Images/loading2.gif' alt='Loading...' width='35' height='35' />Loading...</center> ";

            PageMethods.Show2ndLevelCampaign(sbu, rbu, document.getElementById('txtFromDate').value, document.getElementById('txtToDate').value,
                function (pagedResult, eleid, methodName) {
                    //alert(pagedResult);    
                    div_2ndCampaignDetail.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    //divMozDetail.innerHTML = error.get_message();
                });
            }
            function CloseDiv2ndCampaign() {
                var div2ndCampaign = document.getElementById('div2ndCampaign');
                div2ndCampaign.style.display = 'none';
            }
    </script>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="server" ID="tlsm1" AsyncPostBackTimeout="600"
        EnableScriptGlobalization="true" EnableScriptLocalization="true" EnablePageMethods="true"
        ScriptMode="Debug" />
    <div>
        <table width="100%">
            <tr>
                <td>
                    <table>
                        <tr>
                            <th align="left">Time:</th>
                            <td>
                                <ajaxToolkit:CalendarExtender runat="server" ID="calext1" TargetControlID="txtFromDate" Format="yyyy/MM/dd" />
                                <asp:TextBox runat="server" ID="txtFromDate" Width="80px" />
                            </td>
                            <td>-</td>
                            <td>
                                <ajaxToolkit:CalendarExtender runat="server" ID="calext2" TargetControlID="txtToDate" Format="yyyy/MM/dd" />
                                <asp:TextBox runat="server" ID="txtToDate" Width="80px" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <div runat="server" id="divCampaignReport"></div>
                </td>
            </tr>
        </table>
    </div>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="Panel2ndCampaign" HorizontalSide="Left" VerticalSide="Top"
        HorizontalOffset="0" VerticalOffset="0" />
    <asp:Panel runat="server" ID="Panel2ndCampaign">
        <div id="div2ndCampaign" style="display: none; background-color: white;
            border: solid 1px silver; padding: 10px; width: 400px; height: 260px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td><a href="javascript:void(0);" onclick="CloseDiv2ndCampaign();">Close</a></td>
                </tr>
                <tr>
                    <td>
                        <div id="div_2ndCampaignDetail"></div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel> 
    </form>
</body>
</html>
