<%@ Control Language="VB" ClassName="eStoreBlock" %>

<script runat="server">

</script>

<ajaxToolkit:CollapsiblePanelExtender ID="cpe" runat="Server"
    TargetControlID="PanelContent" ExpandControlID="PanelHeader" CollapseControlID="PanelHeader"
    CollapsedSize="0" Collapsed="false" ScrollContents="false" SuppressPostBack="true" ExpandDirection="Vertical" /> 
<asp:Panel runat="server" ID="PanelHeader">
    <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'"> 
        <tr> 
          <td width="4" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td> 
          <td width="192" height="20" background="/images/table_fold_top.gif" >
              <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>eStore</b></td>
                </tr>
              </table>                        
          </td>
          <td width="4" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"></td>
        </tr> 
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelContent">
    <table border="0" width="100%" cellspacing="0" cellpadding="0"> 
        <tr> 
          <td width="4" background="/images/table_line_left.gif"></td> 
          <td width="192"> 
            <table border="0" width="89%" cellspacing="0" cellpadding="0" class="text"> 
                <tr> 
                    <td colspan="2"><a href="http://buy.advantech.eu" target="_blank"><asp:Image runat="server" ID="imgBanner" ImageUrl="/Images/eStore_banner.jpg" /></a></td>
                </tr>
                <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="QuotationLink" Text="My Quotations" NavigateUrl="http://buy.advantech.eu" Target="_blank" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                </tr> 
                <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="OrderLink" Text="My Orders" NavigateUrl="http://buy.advantech.eu" Target="_blank" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                </tr>
            </table>
          </td> 
          <td width="4" background="/images/table_line_right.gif"></td> 
        </tr> 
        <tr> 
          <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5"></td> 
        </tr> 
    </table>
</asp:Panel>
