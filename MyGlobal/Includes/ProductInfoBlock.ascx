<%@ Control Language="VB" ClassName="ProductInfoBlock" %>

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
                  <td width="94%"><b>Product Information</b></td>
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
              <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td width="141"><asp:HyperLink runat="server" ID="PhaseInOutLink" NavigateUrl="~/Product/Product_PhaseInOut.aspx" Text="Product Phase-in/out" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
            <tr>
              <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="NewProdLink" NavigateUrl="~/Product/New_Product.aspx" Text="New Product Highlight" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
            <tr>
              <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="hlProdSearch" Text="Advanced Product Search" NavigateUrl="/Product/search.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
              <%-- add Warranty Lookup ----%>
           <tr>
              <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="Warranty" Text="Warranty Lookup" NavigateUrl="/Order/MyWarrantyExpireItems.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr> 
        <%-- add  Warranty Lookup end ----%>
            <tr id="Tr1" visible="false" runat="server">
              <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="hlCTOS" NavigateUrl="" Text="CTOS / System" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
            <tr id="Tr2" visible="false" runat="server">
              <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="hlConfiguration" NavigateUrl="" Text="Configuration" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
            <tr id="Tr3" visible="false" runat="server">
              <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
              <td><asp:HyperLink runat="server" ID="hlOEMODM" NavigateUrl="" Text="OEM / ODM Document" ForeColor="#4D6D94" Font-Bold="true" /></td>
            </tr>
        </table></td>
        <td width="4" background="/images/table_line_right.gif"></td>
      </tr>
      <tr>
        <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5" alt=""/></td>
      </tr>
    </table> 
</asp:Panel>