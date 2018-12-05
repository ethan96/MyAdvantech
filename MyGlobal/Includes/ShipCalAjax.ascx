<%@ Control Language="VB" ClassName="ShipCalAjax" %>

<script runat="server">
    Public Property CalendarHeight() As Integer
        Get
            Return CInt(CalHeight.Style.Item("Height"))
        End Get
        Set(ByVal value As Integer)
            CalHeight.Style.Item("Height") = value
        End Set
    End Property
    Public Property ShowHideDetail() As Boolean
        Get
            Return CBool(hd_Detail.Value)
        End Get
        Set(ByVal value As Boolean)
            hd_Detail.Value = value.ToString()
        End Set
    End Property

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>
<asp:HiddenField runat="server" ID="hd_Detail" Value="false" />
<table width="100%" style="border-style:groove; height:230px">
    <tr valign="top">
        <td align="left" style="color:Navy; display:block;" id="td_mycal" runat="server"><b>My Calendar</b></td>
        <td align="right">
            <select onchange="GetCalHtml(document.getElementById('calYear').options[document.getElementById('calYear').selectedIndex].value,document.getElementById('calMonth').options[document.getElementById('calMonth').selectedIndex].value)" id="calYear">
                <option value="2009">2009</option>  
                <option value="2010">2010</option> 
                <option value="2011">2011</option> 
                <option value="2012">2012</option> 
                <option value="2013">2013</option> 
            </select>
            <select onchange="GetCalHtml(document.getElementById('calYear').options[document.getElementById('calYear').selectedIndex].value,document.getElementById('calMonth').options[document.getElementById('calMonth').selectedIndex].value)" id="calMonth">
                <option value="1">Jan</option>
                <option value="2">Feb</option>
                <option value="3">Mar</option>
                <option value="4">Apr</option>
                <option value="5">May</option>
                <option value="6">Jun</option>
                <option value="7">Jul</option>
                <option value="8">Aug</option>
                <option value="9">Sep</option>
                <option value="10">Oct</option>
                <option value="11">Nov</option>
                <option value="12">Dec</option>
            </select>
        </td>
        <td align="right"><a href="javascript:void(0);" onclick="CloseBlock('tr_MyCal','ctl00__main_tr_MyCal');"><img src="/Images/close.gif" alt="Close" style="border-width:0px" width="20" height="20" /></a></td>
    </tr>
    <tr style="height:500px" runat="server" id="CalHeight">
        <td colspan="3" valign="top" align="center">
            <div id="div_MyCal" runat="server"></div>   
            <div id="div_DayFlyout" style="display:none; background-color:White; height:250px; overflow:scroll; width:600px" runat="server"></div>                                    
        </td>
    </tr>    
</table>
<script type="text/javascript">
    var MONTH_NAMES=new Array('January','February','March','April','May','June','July','August','September','October','November','December','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
    var DAY_NAMES=new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    function LZ(x) {return(x<0||x>9?"":"0")+x};
    function formatDate(date,format) {
	    format=format+"";
	    var result="";
	    var i_format=0;
	    var c="";
	    var token="";
	    var y=date.getYear()+"";
	    var M=date.getMonth()+1;
	    var d=date.getDate();
	    var E=date.getDay();
	    var H=date.getHours();
	    var m=date.getMinutes();
	    var s=date.getSeconds();
	    var yyyy,yy,MMM,MM,dd,hh,h,mm,ss,ampm,HH,H,KK,K,kk,k;
	    // Convert real date parts into formatted versions
	    var value=new Object();
	    if (y.length < 4) {y=""+(y-0+1900);}
	    value["y"]=""+y;
	    value["yyyy"]=y;
	    value["yy"]=y.substring(2,4);
	    value["M"]=M;
	    value["MM"]=LZ(M);
	    value["MMM"]=MONTH_NAMES[M-1];
	    value["NNN"]=MONTH_NAMES[M+11];
	    value["d"]=d;
	    value["dd"]=LZ(d);
	    value["E"]=DAY_NAMES[E+7];
	    value["EE"]=DAY_NAMES[E];
	    value["H"]=H;
	    value["HH"]=LZ(H);
	    if (H==0){value["h"]=12;}
	    else if (H>12){value["h"]=H-12;}
	    else {value["h"]=H;}
	    value["hh"]=LZ(value["h"]);
	    if (H>11){value["K"]=H-12;} else {value["K"]=H;}
	    value["k"]=H+1;
	    value["KK"]=LZ(value["K"]);
	    value["kk"]=LZ(value["k"]);
	    if (H > 11) { value["a"]="PM"; }
	    else { value["a"]="AM"; }
	    value["m"]=m;
	    value["mm"]=LZ(m);
	    value["s"]=s;
	    value["ss"]=LZ(s);
	    while (i_format < format.length) {
		    c=format.charAt(i_format);
		    token="";
		    while ((format.charAt(i_format)==c) && (i_format < format.length)) {
			    token += format.charAt(i_format++);
			    }
		    if (value[token] != null) { result=result + value[token]; }
		    else { result=result + token; }
		    }
	    return result;
	}

    function ShowDayFlyout(strdate){
        //alert(strdate);
        var cd = new Date(strdate.replace(/(\d\d)(\d\d)$/, "/$1/$2"));
//        var cmonth = cd.getMonth();
//        cmonth=cmonth+1;    
//        var cyear = cd.getYear();
//        var cday = cd.getDay();
//        if (cyear < 1900) { cyear+=1900; }
        var df=document.getElementById('<%=div_DayFlyout.ClientID %>');  
        df.innerHTML = "<table width='100%'><tr><td align='left'><a href='javascript:void(0);' onclick='HideDayFlyout();'>Close</a></td></tr><tr><td><img style='border:0px;' alt='loading' src='../images/loading2.gif' />Loading "+ formatDate(cd,"yyyy/MM/d") +" Detail...</td></tr></table>"; 
        df.style.left=(tempX-450)+'px';
        df.style.top=(tempY-50)+'px';
        df.style.display='block';
        //alert(strdate+"yy");
        PageMethods.GetDayDetail(strdate,
            function(pagedResult, eleid, methodName) {
                df.innerHTML = pagedResult;
            },
            function(error, userContext, methodName) {
                //alert(error.get_message());
                df.innerHTML ="";
            }
        ); 
    }
    function HideDayFlyout(){document.getElementById('<%=div_DayFlyout.ClientID %>').style.display='none';}
    function GetCalHtml(y, m){ 
        SetSelectedYearMonth(y,m);  
        HideDayFlyout();        
        document.getElementById('<%=td_mycal.ClientID %>').style.display="block";
        document.getElementById('<%=div_MyCal.ClientID %>').innerHTML = "<img style='border:0px;' alt='loading' src='../images/loading2.gif' />Loading Calendar"       
        PageMethods.GetCal(y,m,'<%=hd_Detail.Value %>',
            function(pagedResult, eleid, methodName) {
                document.getElementById('<%=div_MyCal.ClientID %>').innerHTML = pagedResult;
            },
            function(error, userContext, methodName) {
                //alert(error.get_message());
                document.getElementById('<%=div_MyCal.ClientID %>').innerHTML ="";
            }
        );
    }  
    function SetSelectedYearMonth(y, m){
        for(var i = 0; i < document.getElementById('calYear').length; i++) {
        if(document.getElementById('calYear').options[i].value == y)
            document.getElementById('calYear').selectedIndex = i;
    }
    for(var i = 0; i < document.getElementById('calMonth').length; i++) {
        if(document.getElementById('calMonth').options[i].value == m)
            document.getElementById('calMonth').selectedIndex = i;
    }  
    }   
    var nowd = new Date();       
    var calmonth = nowd.getMonth();
    calmonth=calmonth+1;    
    var calyear = nowd.getYear();
    if (calyear < 1900) { calyear+=1900; }
    SetSelectedYearMonth(calyear,calmonth);      
    setTimeout("GetCalHtml(document.getElementById('calYear').options[document.getElementById('calYear').selectedIndex].value, document.getElementById('calMonth').options[document.getElementById('calMonth').selectedIndex].value)",1500);       
</script> 
