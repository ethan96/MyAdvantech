<%Response.Expires = 0%>
<!-- include virtual = "/includes/global_inc.asp" -->
<!-- include virtual = "/modules/btos_mod.asp" -->
<!-- include virtual = "/includes/pi_inc_tds.asp" -->
<!-- #include virtual = "/includes/layout/getlayoutformat.asp" -->
<!--include virtual='/modules/logistics_mod.asp' -->
<!--include virtual='/modules/order_mod.asp' -->
<!--include virtual='/includes/cart_inc.asp' -->
<%
g_strMessage    = g_strMessage + ""
%>
<html>
	<head>
		<title>Terms and Conditions</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<link href="/includes/layout/eBizStyle.css" rel="stylesheet">
			<STYLE type="text/css">
.text {
	FONT-SIZE: 9pt; COLOR: #000000; LINE-HEIGHT: 12pt; FONT-STYLE: normal; FONT-FAMILY: "Arial", "Helvetica", "sans-serif"
}
.Stil1 {font-size: x-small}
            .Stil2 {font-size: Kein}
            </STYLE>
			<script language="Javascript">
	<!--
	function confirm(URL)
	{
		window.event.returnValue = false ;
		document.location.href = URL;
	}


	function SaveCart() {
		window.event.returnValue = false ;
		document.FrmSaveCart.submit();
	}

	function SendtoPI() {
		window.event.returnValue = false ;
		document.SendPI.submit();
	}

	function PickEmployee(strSearchString)
	{
		window.open('pick_user.asp?search_str='+strSearchString,'account','height=400,width=500,scrollbars=yes') ;
	}


	//-->
			</script>
	</head>
	<body bgcolor="#FFFFFF" text="#000000" leftmargin="0" topmargin="0">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr valign="top">
				<td>
					<!--#include virtual="/includes/header_inc.asp" -->
				</td>
			</tr>
			<tr>
				<td width="100%" align="center">
				<br>

						<!---------------------------------------------------------------------------------------->
						<!-- Terms And Condition Table -->
						<!---------------------------------------------------------------------------------------->
						<table width  = "73%"
						       border = "0">

						  <!-- Zeile 1 Begin ------------------------------------------------->
						  <tr>
						  	  <td height="37">
						    	  <div align="center"><strong><u><font size = "+1" color="navy">
						    	    RMA and Warranty Policy
								  </font></u></strong><br><br><!--
								  <div align="center"><font color="#FF0000"><u>
								    Due to the local circumstances, these articles could be subject to change. <br>Advantech will keep the right to change these articles at any time in order to comply to those circumstances.
  								  </u></font></div>--></br>
								  <!-- SpeechSelect Start -------------------------------------------->
						    	    <table width="100%"  border="0"><font size = "-1">
                                      <tr>
                                        <th height="26" scope="col">
										  <a href="rmaPolicy/rma_english.htm" target="RMA Policy">
											  <img src="images/flag-uk.gif" alt="English" border="0" width="28" height="19">
										  </a>
										  </br><a href="rmaPolicy/rma_english.htm" target="RMA Policy"><font size = "-1" color="#000000">English</font></a>
										  </br><a href="rmaPolicy/rma_english.pdf"><font size = "-2">( Download )</font></a>
										</th>
                                      </tr>
                                    </table>
								  <!-- SpeechSelect End ---------------------------------------------->

						      </td>
						  </tr>
						  <!-- Zeile 1 End --------------------------------------------------->

						  <!-- Zeile 2 Begin ------------------------------------------------->
						  <tr>
						      <td height="600">
						      	  <iframe border=""
						      	  		  frameborder="1"
						      	  		  scrolling="yes"
						      	  		  name="RMA Policy"
						      	  		  width="100%"
						      	  		  height="95%"
						      	  		  src="rmaPolicy/rma_english.htm">
								   </iframe>
						      </td>
						  </tr>
						  <!-- Zeile 2 End --------------------------------------------------->


						</table>
						<!---------------------------------------------------------------------------------------->

				</td>
			</tr>
			<tr valign="top">
				<td height="10">&nbsp;
				</td>
			</tr>
			<tr valign="top">
				<td>
					<!--#include virtual="/includes/footer_inc.asp" -->
				</td>
			</tr>
		</table>
	</body>
</html>
