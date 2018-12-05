<%@ Control Language="VB" ClassName="Outlook" %>

<script runat="server">

</script>

<ajaxToolkit:CollapsiblePanelExtender ID="cpe" runat="Server"
    TargetControlID="PanelContent" ExpandControlID="PanelHeader" CollapseControlID="PanelHeader"
    CollapsedSize="0" Collapsed="false" ScrollContents="false" SuppressPostBack="true" ExpandDirection="Vertical" /> 
<asp:Panel runat="server" ID="PanelHeader">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" onmouseover="this.style.cursor='hand'">
        <tr> 
            <td width="4" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td> 
            <td width="192" height="20" background="/images/table_fold_top.gif" >
                <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                    <tr>
                    <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                    <td width="94%"><b>My Outlook</b></td>
                    </tr>
                </table>                        
            </td>
            <td width="4" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"></td>
        </tr> 
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelContent">    
    <iframe src="http://7.gmodules.com/ig/ifr?url=http://andyast.googlepages.com/MSOutlookWidget.xml&nocache=0&up_DefaultView=Inbox&upt_DefaultView=enum&lang=zh-TW&country=tw&.lang=zh-TW&.country=tw&synd=ig&mid=7&ifpctok=-5127121936294431743&parent=http://my.advantech.eu" 
        width="100%" height="300px" style="border:0px"></iframe>                
</asp:Panel>