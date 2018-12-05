<%@ Page Language="C#" AutoEventWireup="true" CodeFile="BtosPortal_Hub.aspx.cs" Inherits="Order_BtosPortal_Hub" %>

<!DOCTYPE html>

<script type="text/javascript" src="../Includes/jquery-latest.min.js"></script>
<script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
<link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
<script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
<script type="text/javascript" src="../Includes/LoadingOverlay/loadingoverlay.min.js"></script>
<script type="text/javascript" src="../Includes/LoadingOverlay/loadingoverlay_progress.min.js"></script>
<script>


    $(document).ready(function () {

        //listen close fancy box event from myadvantech core
        window.addEventListener('message', function (event) {
            if (event.data == 'closefancybox') {
                $.fancybox.close();               
            }
        }, false);

        ShowFancyBox();
    });

    function ShowFancyBox() {
        // fancy box iframe settings
        $.fancybox($('#configuratorFrame'), {
            'type': 'iframe',
            'width': ($(window).width() * 0.95),
            'height': ($(window).height() * 0.95),
            'autoDimensions': false,
            'autoScale': false,
            'autosize': true,
            'href': '<%=TargetUrl%>',
            'helpers': {
                overlay: { closeClick: false }
            },
            'afterClose': function () {
                
            },
            'beforeClose': function () {
                OnFancyBoxClose();
            }
        });
    }

    function OnFancyBoxClose() {        
        $.ajax({
            type: "POST",
            url: "BtosPortal_Hub.aspx/ProcessData",
            data: JSON.stringify({ originalRequestTime: '<%=RequestTime%>' }),
            contentType: "application/json; charset=utf-8",
            async: false,
            dataType: "json",
            success: function (result) {
                var res = $.parseJSON(result.d);
                if (res.success) {
                    window.location = res.url;
                }
                else {                    
                    window.location = res.url;
                }
            },
            error: function () {
                alert("error!");
            }
        });
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div id="configuratorFrame"></div>
        </div>
    </form>
</body>
</html>
