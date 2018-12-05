$(document).ready(function () {
    $("input[type='text']").focus(function () {
        $(this).css("background-color", "#FFFFD7");
    });
    $("input[type='text']").blur(function () {
        $(this).css("background-color", "#FFFFFF");
    });
    $("textarea").focus(function () {
        $(this).css("background-color", "#FFFFD7");
    });
    $("textarea").blur(function () {
        $(this).css("background-color", "#FFFFFF");
    });
    //
    //20111130 commentted by TC
//    $(".qtyboxOnlyNO").keyup(function (event) {
//        if (!checkQTYInfo($(this))) {
//            $(this).val(0);
//        }
//        else {
//            if ($(this).val().match(/\d{6,}/)) {
//                $(this).val($(this).val().substr(0, 5));
//                alert("too large number");
//                return false;
//            }
//        }
//    });

    //
    function checkQTYInfo(obj) {
        var str = obj.val();
        if (str.match(/^0/g) || str.match(/[^0-9]/g)) {
            return false;
        }
        else {
            return true;
        }
    }


});