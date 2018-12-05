<%@ Control Language="VB" ClassName="Menu" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="ajax" %>
<script runat="server">

</script>
<ajax:RoundedCornersExtender runat="server" ID="rce1" 
TargetControlID="txtpnlmenu1" Radius="5"></ajax:RoundedCornersExtender>
<asp:Panel runat="server" ID="txtpnlmenu1" BackColor="#9c9fae" Width="190" Height="250">
    <div ><br />
        <ul style="text-align:left;margin-left:0;padding-left:22px;margin-bottom:0px;list-style-type:square">
            <li style="margin-bottom:2px;color:White">
               <a style="font-weight:bold;color:White" href="./categories.aspx">Category management</a>
            </li>
             <li style="margin-bottom:2px;color:White">
               <a style="font-weight:bold;color:White" href="./index.aspx">Products list</a>
            </li>
              <li style="margin-bottom:2px;color:White">
               <a style="font-weight:bold;color:White" href="./product.aspx">Add product</a>
            </li>
           
              <li style="margin-bottom:2px;color:White">
               <a style="font-weight:bold;color:White" href="./spec_management.aspx">Spec management</a>
            </li>
        </ul>  
    </div>
</asp:Panel>

