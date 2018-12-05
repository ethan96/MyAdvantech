<%@ Control Language="VB" ClassName="ProductInfoBlock_new" %>

<script runat="server">

</script>
 <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'">
      <tr>
        <td width="4" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td>
        <td width="192" height="20" background="/images/table_fold_top.gif" >
            <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>Product Information_new</b></td>
                </tr>
            </table>
        </td>
        <td width="4" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"></td>
      </tr>
    </table>

    <table border="0" width="100%" cellspacing="0" cellpadding="0"> 
      <tr>
        <td width="4" background="/images/table_line_left.gif"></td>
        <td width="192">
        
        <%--start--%>
          <div class="suckerdiv">
<ul id="suckertree6">
<li><asp:HyperLink runat="server" ID="PhaseInOutLink" NavigateUrl="~/Product/Product_PhaseInOut.aspx" Text="Product Phase-in/out" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:HyperLink runat="server" ID="NewProdLink" NavigateUrl="~/Product/New_Product.aspx" Text="New Product Highlight" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:HyperLink runat="server" ID="hlProdSearch" Text="Advanced Product Search" NavigateUrl="/Product/search.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
  <%-- add Warranty Lookup ----%>
<li><asp:HyperLink runat="server" ID="Warranty" Text="Warranty Lookup" NavigateUrl="/Order/MyWarrantyExpireItems.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
  <%-- add  Warranty Lookup end ----%>
<li id="Tr1" visible="false" runat="server"><asp:HyperLink runat="server" ID="hlCTOS" NavigateUrl="" Text="CTOS / System" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li id="Tr2" visible="false" runat="server"><asp:HyperLink runat="server" ID="hlConfiguration" NavigateUrl="" Text="Configuration" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li id="Tr3" visible="false" runat="server"><asp:HyperLink runat="server" ID="hlOEMODM" NavigateUrl="" Text="OEM / ODM Document" ForeColor="#4D6D94" Font-Bold="true" /></li>

</ul>
</div>
      <%--  end--%>
</td>
        <td width="4" background="/images/table_line_right.gif"></td>
      </tr>
     <%-- <tr>
        <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5" alt=""/></td>
      </tr>--%>
    </table> 