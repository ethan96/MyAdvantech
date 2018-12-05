<%@ Control Language="VB" ClassName="MyPerfAjax" %>

<script runat="server">

</script>
<table width="100%" style="border-style:groove;">
    <tr>
        <th align="center" style="color:Navy;"><b>My Performance</b></th>
    </tr>
    <tr>
        <td valign="top">
            <div id="div_MyPerf" runat="server" style="height:180px; overflow:auto; width:98%"></div>
        </td>
    </tr>
</table>
<script type="text/javascript">    
    function RefreshMyPerf(){
        document.getElementById('<%=div_MyPerf.ClientID %>').style.display="block";
        document.getElementById('<%=div_MyPerf.ClientID %>').innerHTML = "<img style='border:0px;' alt='loading' src='../images/loading2.gif' />Loading My Performance..." 
        PageMethods.GetMyPerfImgUrl(
            function(pagedResult, eleid, methodName) {
                document.getElementById('<%=div_MyPerf.ClientID %>').innerHTML = pagedResult;
                if(pagedResult==""){
                    document.getElementById('<%=div_MyPerf.ClientID %>').style.height="15px";
                }
            },
            function(error, userContext, methodName) {
                alert('myperf error:'+error.get_message());
                document.getElementById('<%=div_MyPerf.ClientID %>').innerHTML ="";
            }
        );
    }
    setTimeout("RefreshMyPerf()",1200);    
</script>
