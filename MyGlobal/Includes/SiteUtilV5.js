function busyMode(mode) {
    (mode == true) ? $("#UpdateProgress2").css("visibility", "visible") : $("#UpdateProgress2").css("visibility", "hidden");
}

function trimZero(str) {
    if (!str) return "";
    if (str.toString().substring(0, 1) == "0") { return trimZero(str.toString().substring(1)); }
    else { return str.toString(); }
}

function formatJDate(jd) { if (jd) return new Date(parseInt(jd.substr(6))).format("yyyy/MM/dd"); }

function formatJDate2(jd, uf) {
    uf = uf.replace("mm", "MM");
    if (jd) return new Date(parseInt(jd.substr(6))).format(uf); 
}

function ShowMasterErr(errStr){
    $("#divMasterAlertWindow").dialog(
        {
            modal: true, width: '50%',
            open: function (type, data) { $("#divMasterAlertWindow").find(".errMsg").text(errStr); },
            close: function (type, data) { $("#divMasterAlertWindow").find(".errMsg").empty(); }
        }
    );
}


//20140508 TC: Function for fixing AjaxControlToolkit CalendarExtender issue, that selected date will be deducted by one day on Germany ADLoG server
//function correctCalExtDateV2(selectedDate) {
//    console.log("selectedDate:" + selectedDate);
//    if (!selectedDate) return "";
//    var timeOffsetMinutes = selectedDate.getTimezoneOffset();
//    console.log("timeOffsetMinutes:" + timeOffsetMinutes);
//    // Convert minutes into milliseconds and create a new date based on the minutes.
//    var correctedDate = new Date(selectedDate.getTime() + timeOffsetMinutes * 60000);
//    console.log("correctedDate:" + correctedDate);
//    return correctedDate;
//}

function correctCalExtDate(localDate) {
    if (!localDate) return "";
    //console.log("localDate:" + localDate);
    var NewDate = new Date(localDate.getUTCFullYear(), localDate.getUTCMonth(), localDate.getDate(),12,0);
    //console.log("NewDate:" + NewDate);
    return NewDate;
}
