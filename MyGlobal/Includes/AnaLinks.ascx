<%@ Control Language="VB" ClassName="AnaLinks" %>
<%@ Register TagPrefix="obout" Namespace="OboutInc.Flyout2" Assembly="obout_Flyout2_NET"%>
<script runat="server">
 
    Public Property FlyoutPosition() As OboutInc.Flyout2.PositionStyle
        Get
            Return Me.microsoft_flyout.Position
        End Get
        Set(ByVal value As OboutInc.Flyout2.PositionStyle)
            Me.microsoft_flyout.Position = value
        End Set
    End Property
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.microsoft_flyout.po
    End Sub
</script>

<style type="text/css">
    body {
	    font:11px Verdana;
	    color:#333333;
    }
    a {
	    font:11px Verdana;
	    color:#315686;
	    text-decoration:underline;
    }
    a:hover {
	    color:crimson;
    }
    .QuickLinksFlyoutPopup
    {
        background-color:white;
        border: solid 1px silver;
        padding:10px;

    }
    h4
    {
        font-style:bold;
        color:darkblue;
        font-family:Verdana;
        font-size:8pt;
        height:5px;
        
    }


    .listitem
    { font-family:Verdana;font-size:8pt;color:black; text-decoration:none;}
    a.listitem:visited{ font-family:Verdana;font-size:8pt;color:black;text-decoration:none;}
    a.listitem:hover{ font-family:Verdana;font-size:8pt;color:black;text-decoration:none;}   
        
    a.mlink:link{ font-family:Tahoma;font-size:8pt;color:white; text-decoration:none;}
    a.mlink:visited{ font-family:Tahoma;font-size:8pt;color:white; text-decoration:none;}
    a.mlink:hover{ font-family:Tahoma;font-size:8pt;color:white; text-decoration:none;}        


    .mHoverin
    {
        background-color: green;
        border:solid 1px blue;
    }

    .mHoverout
    {
        background-color:none;
        border:none;
    }
            

    .list
    {
        width:160px;
        padding-left:10px;
    }
    .QuickLinksFlyoutPopupHr
    {
        background-color:#D6E3EF;
        width:5px;
    }     
    .QuickLinksFlyoutStaticLink_msdn
    {
    border:solid 1px;
    }   
    .QuickLinksFlyoutStaticLink_msdn
    {
     font-family:Tahoma;
     font-size:8pt;
     color:white;
     cursor:hand;
     width:90px;
     height:auto;
    }        
</style> 

<table style="width:100%;" cellpadding=0 cellspacing=0>
    <tr>
        <td>&nbsp;</td>
        <td style="width:100px;background-color:#3165CE">&nbsp;</td>
        
        <td align="center" style="width:110px;height:25px;background-color:#3165CE">
           <div id="microsoft_link" class="QuickLinksFlyoutStaticLink_msdn"> 
            <a href="javascript:void();" class="mlink" >Mining Functions&nbsp;<img class="QuickLinksPopArrow" src="/Images/popdownarrow-msdn-right.gif" alt="Dropdown arrow" style="height:4px;width:7px;border-width:0px;" />
           </div>
        </td>
    </tr>
    
</table>	
<obout:Flyout runat="server" ID="microsoft_flyout" Opacity="92"  AttachTo="microsoft_link" Position="MIDDLE_CENTER">
    <div class="QuickLinksFlyoutPopup">
        <table>
            <tr>
                <td valign="top">
                    <h4>Product Analysis</h4>
                    <div class="list">                        
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink8" Text="Product Analysis" NavigateUrl="~/Datamining/ProductAnalysis.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink1" Text="Product Dashboard" NavigateUrl="~/Datamining/ProductProfile.aspx"/></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="CTOSReportLink" Text="CTOS Sales Analysis" NavigateUrl="~/DataMining/CTOS/CTOSalesAnalysis.aspx"/></div>                        
                    </div>
                </td>
                <td valign="top">
                    <h4>Customer Analysis</h4>
                    <div class="list">
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink2" Text="Siebel Customer" NavigateUrl="~/Datamining/CustomerAnalysis.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink6" Text="SAP Customer" NavigateUrl="~/Datamining/SAPAccountAnalysis.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink7" Text="Contact Analysis" NavigateUrl="~/Datamining/ContactAnalysis.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink9" Text="Customer Dashboard" NavigateUrl="~/Datamining/AccountProfile.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink5" Text="Activity Analysis" NavigateUrl="~/Datamining/GlobalActivityAnalysis.aspx" /></div>
                    </div>                    
                </td>
                <td valign="top">
                    <h4>Sales Analysis</h4>
                    <div class="list">                        
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink10" Text="Opportunity Analysis" NavigateUrl="~/Datamining/OptyAnalysis.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink14" Text="Opportunity Search" NavigateUrl="~/Datamining/OptySearch.aspx" /></div>
                    </div>
                </td>
            </tr>
            <tr><td colspan="10" class="QuickLinksFlyoutPopupHr" /></tr>
            <tr>
                <td valign="top">
                    <h4>DMF Analysis</h4>
                    <div class="list">
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink4" Text="DMF Order Report" NavigateUrl="~/Datamining/DMF/DMFOrderReport.aspx" /></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="Link7" Text="eStore Product Analysis" NavigateUrl="~/Datamining/DMF/eStoreProductAnalysis.aspx" /></div>
                        <div><asp:HyperLink runat="server" ID="Link8" Text="eStore Registration Report" NavigateUrl="~/Datamining/DMF/eStoreRegReport.aspx" /></div>
                    </div>
                </td>
                <td valign="top">
                    <h4>Post-Sales Analysis Function</h4>
                    <div class="list">
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink11" Text="Service Request Inquiry" NavigateUrl="~/Datamining/SearchSR.aspx"/></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink12" Text="SR Report" NavigateUrl="~/Datamining/SRReport.aspx"/></div>
                        <div class="listitem"><asp:HyperLink runat="server" ID="HyperLink13" Text="Global RMA Report" NavigateUrl="~/Datamining/RMA/GlobalRMAReport.aspx"/></div>                        
                    </div>
                </td>
            </tr>
        </table>
    </div>
</obout:Flyout>	
      
    <%--<table width="300px">        
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink1" Text="Customer Analysis" NavigateUrl="~/Datamining/CustomerAnalysis.aspx" /></td></tr>
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink6" Text="Sales Trend Analysis" NavigateUrl="~/Datamining/PERF/CustomerSalesTrend.aspx" /></td></tr>
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink2" Text="Product Analysis" NavigateUrl="~/Datamining/ProductAnalysis.aspx" /></td></tr>
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink3" Text="Activity Analysis" NavigateUrl="~/Datamining/GlobalActivityAnalysis.aspx" /></td></tr>
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink4" Text="Opportunity Analysis" NavigateUrl="~/Datamining/OptyAnalysis.aspx" /></td></tr>
        <tr align="left" style="background-color:#F5F6F7"><td><asp:HyperLink runat="server" ID="HyperLink5" Text="Contact Analysis" NavigateUrl="~/Datamining/ContactAnalysis.aspx" /></td></tr>
    </table>--%>