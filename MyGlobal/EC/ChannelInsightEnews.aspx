<%@ Page Title="MyAdvantech - Channel Insight Newsletter" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    .at-maincontainer
    {
        background-color: #FFF;
        line-height: 1.5em;
        line-height: normal;
        margin: 0 auto;
        height: auto;
        width: 890px;
        color: #666;
    }
    a:link
    {
        color: #0082d1;
    }
    a:visited
    {
        color: #0082d1;
        font-weight: normal;
    }
    
    .x_01
    {
        font-size: 12px;
        line-height: 18px;
        color: #0082d1;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_02
    {
        font-size: 11px;
        line-height: 18px;
        color: #FFFFFF;
        font-family: Arial, Helvetica, sans-serif;
    }
    a.x_02:link, a.x_02:visited, a.x_02:hover, a.x_02:active
    {
        color: #fff;
    }
    .x_03
    {
        font-size: 18px;
        line-height: 18px;
        color: #ff7800;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_04
    {
        font-size: 15px;
        line-height: 18px;
        color: #0d678e;
        font-weight: bold;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_042
    {
        font-size: 15px;
        line-height: 18px;
        color: #FF8C1A;
        font-weight: bold;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_05
    {
        font-size: 12px;
        line-height: 16px;
        color: #666666;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: normal;
    }
    .x_06
    {
        font-size: 11px;
        line-height: 14px;
        color: #666666;
        text-align: left;
        font-family: Verdana, Arial, Helvetica, sans-serif;
    }
    .x_07
    {
        font-size: 11px;
        line-height: 14px;
        color: #0082d1;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_08
    {
        font-size: 12px;
        line-height: 18px;
        color: #FFFFFF;
        font-weight: bold;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .topmsg
    {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 11px;
        color: #004b85;
    }
    #miss
    {
        color: #FFF;
    }
</style>
<table class="at-maincontainer">
    <tr>
        <td>
            <div id="navtext"><a style="color:Black" href="../home.aspx">Home</a> > Channel Insight Newsletter</div><br />
        </td>
    </tr>
    <tr><td height="10"></td></tr>
    <tr>
        <td>
            <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">                <tr><td bgcolor="#FFFFFF"><img src="http://www.advantech.eu/it/edm/ChannelInsight_archive/image/banner2.jpg" width="750" height="150" /></td></tr>
                <tr>
                    <td align="left" bgcolor="#FFFFFF">
                        <table width="730" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td align="left" valign="bottom">&nbsp;</td>
                                <td align="left" valign="bottom"><img src="http://www.advantech.eu/it/edm/ChannelInsight_archive/image/titb_archive.jpg" width="340" height="50" /></td>
                            </tr>
                            <tr>
                                <td valign="top"></td>
                                <td height="2" valign="top" bgcolor="#04496a"></td>
                            </tr>
                            <tr>
                                <td valign="top">&nbsp;</td>
                                <td valign="top"><img src="http://www.advantech.eu/it/edm/ChannelInsight_archive/image/tabdown.gif" width="730" height="20" /></td>
                            </tr>
                            <tr>                                <td valign="top">&nbsp;</td>                                <td valign="top">                                    <table width="100%" cellpadding="0" cellspacing="0">                                        <tr>                                            <td width="97%">                                                <table border="0" cellspacing="1" cellpadding="0">                                                    <tr><td width="719" class="x_04">Advantech Channel Insight Newsletters</td></tr>                                                    <tr><td height="5"><img src="http://www.advantech.eu/it/edm/ChannelInsight_archive/image/line05.gif" width="700" height="1" /></td></tr>                                                    <tr>                                                        <td width="708" align="center">                                                            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" DataSourceID="sql1" width="96%" CellPadding="5">
                                                                <Columns>
                                                                    <asp:BoundField DataField="actual_send_date" HeaderText="Date" />
                                                                    <asp:BoundField DataField="description" HeaderText="Main theme/Star of the Month" />
                                                                    <asp:HyperLinkField HeaderText="Url" DataNavigateUrlFields="row_id" DataNavigateUrlFormatString="http://my.advantech.com/Includes/GetTemplate.ashx?RowId={0}" DataTextField="url" Target="_blank" />
                                                                </Columns>
                                                            </asp:GridView>
                                                            <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: RFM %>"
                                                                SelectCommand="select top 20 row_id, description, convert(varchar, actual_send_date, 111) as actual_send_date, url, DATENAME(month, created_date) as m from campaign_master where email_subject like '%Channel Insight%' and region='AEU' and actual_send_date is not null and year(actual_send_date)>='2011' order by actual_send_date desc">
                                                            </asp:SqlDataSource>                                                        </td>                                                    </tr>                                                </table>                                            </td>                                        </tr>                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td height="10"></td></tr>
</table>
</asp:Content>

