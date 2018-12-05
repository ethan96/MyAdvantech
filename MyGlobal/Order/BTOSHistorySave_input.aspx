<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Save Configration"%>


<script runat="server">
    Dim l_strSQLCmd As String = "", iRet As Integer = 0, ConfigurationHTML As String = "", Category_Description As String = ""
    Protected Sub btnSubmit_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim table As String = ""
        If Request("flg") = "quote" Then
            table = "quotation_CATALOG_CATEGORY"
        Else
            table = "CONFIGURATION_CATALOG_CATEGORY"
        End If
        
        l_strSQLCmd = l_strSQLCmd & " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Catalog_id,catalogcfg_seq,CATEGORY_DESC,Extended_desc,Seq_no,Category_price,Category_qty FROM History_CATALOG_CATEGORY WHERE "
        l_strSQLCmd = l_strSQLCmd & " CATALOG_ID=" & "'" & Request("g_CATALOG_ID") & "'"
        l_strSQLCmd = l_strSQLCmd & " AND History_Id='" & Request("History_Id") & "'"
        'Response.Write("<BR><FONT COLOR=#FF0000>" & l_strSQLCmd & "</FONT>")
        Dim l_adoRs_detail_his As DataTable = dbUtil.dbGetDataTable("B2B", Me.l_strSQLCmd)  'g_adoConn.Execute(l_strSQLCmd)
        If l_adoRs_detail_his.Rows.Count = 0 Then '.EOF Then
            'Response.Write("fgfd:" & Request("g_CATALOG_ID") & Request("CATALOGCFG_SEQ") & Request("History_Id") & Session("COMPANY_ID"))
            l_strSQLCmd = " insert History_CATALOG_CATEGORY (Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Catalog_id,catalogcfg_seq,CATEGORY_DESC,Extended_desc,Seq_no,Category_price,Category_qty,ParentSeqNo,ParentRoot,Last_Updated_by) "
            l_strSQLCmd = l_strSQLCmd & " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Catalog_id,catalogcfg_seq,CATEGORY_DESC,Extended_desc,Seq_no,Category_price,Category_qty,ParentSeqNo,ParentRoot,Last_Updated_by FROM " & table & " WHERE "
            l_strSQLCmd = l_strSQLCmd & " CATALOG_ID=" & "'" & Request("g_CATALOG_ID") & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Request("CATALOGCFG_SEQ")
            'l_adoRs_detail_com = g_adoConn.Execute(l_strSQLCmd)
            dbUtil.dbExecuteNoQuery("B2B", Me.l_strSQLCmd)
            
            l_strSQLCmd = " update History_CATALOG_CATEGORY set History_Id ='" & Request("History_Id").Replace("&", "_") & "',Company_Id='" & Session("COMPANY_ID") & "',Created=getdate() WHERE "
            l_strSQLCmd = l_strSQLCmd & " CATALOG_ID=" & "'" & Request("g_CATALOG_ID") & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Request("CATALOGCFG_SEQ")
            l_strSQLCmd = l_strSQLCmd & " AND History_Id is null"
            'l_adoRs_detail_com = g_adoConn.Execute(l_strSQLCmd)
            dbUtil.dbExecuteNoQuery("B2B", Me.l_strSQLCmd)
            REM Response.redirect "ConfigurationPage.asp"
            Response.Redirect("../order/BtosHistory_List.aspx")
		
        Else
            Response.Write("duplicate")
            If Request("flg") = "quote" Then
                Response.Redirect("BtosHistorySave_input.aspx?g_CATALOG_ID=" & Request("g_CATALOG_ID") & "&CATALOGCFG_SEQ=" & Request("CATALOGCFG_SEQ") & "&Category_Name=" & Request("Category_Name") & "&Category_Id=" & Request("Category_Id") & "&ErrorSave=Duplicate Configuration&flg=quote")
            Else
                Response.Redirect("BtosHistorySave_input.aspx?g_CATALOG_ID=" & Request("g_CATALOG_ID") & "&CATALOGCFG_SEQ=" & Request("CATALOGCFG_SEQ") & "&Category_Name=" & Request("Category_Name") & "&Category_Id=" & Request("Category_Id") & "&ErrorSave=Duplicate Configuration")
            End If
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_inc1.ValidationStateCheck()
        
        If Not Page.IsPostBack() Then
            If Integer.TryParse(Request("CATALOGCFG_SEQ"), 0) Then
                l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,Category_price,Category_qty FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = '" & Request("Category_Id") & "')"
                l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & Request("g_CATALOG_ID") & "'"
                l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Request("CATALOGCFG_SEQ")
                Dim l_adoRs_detail_com As DataTable = dbUtil.dbGetDataTable("B2B", Me.l_strSQLCmd) 'g_adoConn.Execute(l_strSQLCmd)
                If l_adoRs_detail_com.Rows.Count > 0 Then 'Not l_adoRs_detail_com.EOF Then
                    Category_Description = l_adoRs_detail_com.Rows(0).Item("CATEGORY_Name")
                End If
                'Me.txtConfigName.Value = UCase(Session("COMPANY_ID") & "_" & Request("Category_Name") & "_" & Request("g_CATALOG_ID") & Request("CATALOGCFG_SEQ"))
                iRet = OrderUtilities.ConfigurationPage_Get(1, Session("G_CATALOG_ID"), Request("CATALOGCFG_SEQ"), ConfigurationHTML)
                'Response.Write(Me.ConfigurationHTML)
                Me.divBTOSC.InnerHtml = Me.ConfigurationHTML
            End If
        End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">

  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <!--td width="1003"><img src="/images/top.jpg" width="1002" height="63"></td-->
    <td width="100%"><!--include virtual="/includes/header_inc.asp" -->
        
    </td>
  </tr>
  <tr>
    <td width="100%"  valign="top"> 

<!--form name="orderinfo_form" action="BtosHistorySave.asp" method="post"-->
    
      <table width="579" border="0" cellspacing="0" cellpadding="0" align="center" >
        <tr> 
          <td width="613" height="40"><font size="1" color="#003366" face="Arial, Helvetica, sans-serif"><br>
            <!--Home &gt; Cart</font><font size="2" color="#003366">--><br>
            </font></td>
        </tr>
        <tr> 
          <td width="613" height="38" > <div class="euPageTitle">
            <!--p><img src="/images/title_order.jpg" width="158" height="18"><br-->
            <p>&nbsp;&nbsp;<img src="../images/b2bf_header.gif" width="12" height="18">&nbsp; 
	    Save Configuration&nbsp;&nbsp;&nbsp;</div><span class="PageMessageBar"><%'=g_strMessage%></span><br>
              <br>
            </p>
          </td>
        </tr>
        <tr> 
          <td width="613" height="12"> 
            <table width="607" border="0" cellspacing="0" cellpadding="0" height="20">
              <tr> 
                <td width="10" height="18" valign="bottom" bgcolor="4F60B2">&nbsp;</td>
                <td bgcolor="4F60B2" height="18" width="116" class="text"> 
                  <div align="center"><b><font color="#FFFFFF">Save Configuration</font></b></div>
                </td>
                <td width="14" height="18" valign="bottom"><img src="/images/folder.jpg" width="8" height="19"></td>
                <td width="467" height="18">&nbsp;</td>
              </tr>
            </table>
          </td>
        </tr>
        <tr> 
          <td width="613"  valign="top"> 
            <table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="4F60B2">
              <tr> 
                <td  valign="top" bgcolor="BEC4E3"> 
                  <table width="611" border="0" cellspacing="1" cellpadding="3" bordercolor="CFCFCF">
                    <tr bgcolor="BEC4E3"> 
                      <td colspan="2" class="text" height="20"><font color="303D83"><b>Please 
                        fill out the information below to save your configuration</b></font></td>
                    </tr>
                    <tr> 
                      <td width="179"  class="text" bgcolor="F0F0F0"> 
                        <div align="right"> BTO Information:</div>
                      </td>
                      <td width="425" class="text" bgcolor="#FFFFFF"> 
                        <div align="left"> <% =Request("Category_Name")%></div>
                    </tr>
                    <tr> 
                      <td width="179" class="text" bgcolor="F0F0F0"> 
                        <div align="right"> Configuration name:</div>
                      </td>
                      <td width="425" class="text" bgcolor="#FFFFFF"> 
                        <input type="text" name="History_Id" size="60" maxlength="50" value=<% =UCASE(Session("COMPANY_ID")) & "_" & Request("Category_Name")& "_"  & Request("g_CATALOG_ID") & Request("CATALOGCFG_SEQ") %>>
                        <BR>( HINT: Please type in unique )</td>
                    </tr>
                    <tr> 
                      <td width="179" class="text" bgcolor="F0F0F0"> 
                        <div align="right"> Description:</div>
                      </td>
                      <td width="425" class="text" bgcolor="#FFFFFF"> 
                        <div align="left"><%=Category_Description%></div>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td width="613" height="2" valign="top"> 
            <div align="center"> <br>              
              <input type="hidden" name="g_CATALOG_ID" value="<%=Request("g_CATALOG_ID")%>" />
              <input type="hidden" name="CATALOGCFG_SEQ" value="<%=Request("CATALOGCFG_SEQ")%> "/>
              <input type="hidden" name="Category_Id" value="<%=Request("Category_Id")%>" />
              <input type="hidden" name="Category_Name" value="<%=Request("Category_Name")%>" />
              <p><input type="hidden" name="func" ID="Hidden1" />
              <% if Request("ErrorSave")<>"" then %>
              </p>
                 <div class="mceLabel"><font size="2" color="red"><B><% =Request("ErrorSave") %></B></font></div>                 
              <% end if %>              
              <input type="hidden" name="logistics_id" value="<%=Request("Logistics_ID")%>" ID="Hidden2">
	      <input type="button" value="Next: Click to save configuration >>" NAME="Submit" ID="btnSubmit" style="font-family: Arial; font-size: 8pt; font-weight:bold;width=200" onserverclick="btnSubmit_ServerClick" runat="server"><br>
                <br>
            </div>
          </td>
        </tr>
        
        <tr>
          <td width="613" height="2" valign="top"> 
            <div align="center" id="divBTOSC" runat="server">
                <!--include file = "ConfigurationPage_main.asp" -->
               
               
              
            </div>
          </td>
        </tr>
        
      </table>
<!--/Form-->
    </td>
  </tr>
  
  <tr>
    <td width="100%"  height="21" class="text"> 
        
      
    </td>
  </tr>
</table>
  
  <script language="javascript" type="text/javascript">

function ConfigQty_onchange(szQty,element) {
//		var g_catalog_id='<%=Session("G_CATALOG_ID")%>';
//		var g_cart_id='<%=SESSION("CART_ID")%>';
//		var category_id,str_id;
//  
//         str_id = element.name;
//        
//		CATALOGCFG_SEQ = str_id.substr(9,1);
//		category_id = str_id.substr(10);
//		
//		var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
////		xmlhttp.Open("POST","<% = "http://" & Request.ServerVariables("Server_Name") & ":" & Request.ServerVariables("Server_Port") & "/order/UpdateConfigurationConfigQty.aspx" %>",false);
//        xmlhttp.Open("POST","<% = "UpdateConfigurationConfigQty.aspx" %>",false);
//		xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//		xmlhttp.send('strCATALOGCFG_SEQ=' + CATALOGCFG_SEQ + '&' + 'strCatalog_Id=' + g_catalog_id + '&' + 'strCategory_Id=' + category_id + '&' + 'strCategory_Value=' + element.value + '&' + 'strCart_Id=' + g_cart_id+ '&' + 'strLine_No=' + szQty);	
//			//alert('strCATALOGCFG_SEQ=' + CATALOGCFG_SEQ + '&' + 'strCatalog_Id=' + g_catalog_id + '&' + 'strCategory_Id=' + category_id + '&' + 'strCategory_Value=' + element.value + '&' + 'strCart_Id=' + g_cart_id+ '&' + 'strLine_No=' + szQty);
//        document.location.reload();
	}   
	
	
	function LinePrice_onchange(szCartLine,intCost,element) {
//	var g_catalog_id='<%=Session("G_CATALOG_ID")%>';
//	var g_cart_id='<%=SESSION("CART_ID")%>';
//	var category_id,str_id;

//         str_id = element.name;       
//	CATALOGCFG_SEQ = str_id.substr(9,1);
//	category_id = str_id.substr(10);
//	//if ( parseInt(element.value) < parseInt(intCost) )
//	//{
//	//	alert("Lower than cost!!-->" + "Unit Price:" + element.value + " < Cost Price:" + intCost);

//	//	return false;
//	//}
//	// Rem == Replace a blank with vbSpace ==
//	category_id = Script2Script(category_id);

// 	var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
//	//xmlhttp.Open("POST","<% = "http://" & Request.ServerVariables("Server_Name") & ":" & Request.ServerVariables("Server_Port") & "/BTOS/UpdateConfigurationLinePrice.asp" %>",false);
//	xmlhttp.Open("POST","<% = "UpdateConfigurationLinePrice.aspx" %>",false);
//	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//	xmlhttp.send('strCATALOGCFG_SEQ=' + CATALOGCFG_SEQ + '&' + 'strCatalog_Id=' + g_catalog_id + '&' + 'strCategory_Id=' + category_id + '&' + 'strCategory_Value=' + element.value + '&' + 'strCart_Id=' + g_cart_id+ '&' + 'strLine_No=' + szCartLine);	
       	}
       	
       	function Script2Script ( strString ) {
		var re = '' ;
		
		re = /\x20/g ;
		strString = strString.replace(re, '%20');
		return strString ;			
        }
        
        function Del()
        {
            //window.location="ConfigurationDel.aspx"
//         if(confirm('are you sure to delete this item'))
//         {
//			 var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
////		xmlhttp.Open("POST","<% = "http://" & Request.ServerVariables("Server_Name") & ":" & Request.ServerVariables("Server_Port") & "/order/UpdateConfigurationConfigQty.aspx" %>",false);
//        xmlhttp.Open("POST","<% = "ConfigurationDel.aspx" %>",false);
//		xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//		xmlhttp.send(); //'strCATALOGCFG_SEQ=' + CATALOGCFG_SEQ + '&' + 'strCatalog_Id=' + g_catalog_id + '&' + 'strCategory_Id=' + category_id + '&' + 'strCategory_Value=' + element.value + '&' + 'strCart_Id=' + g_cart_id+ '&' + 'strLine_No=' + szQty);	
//			//alert('strCATALOGCFG_SEQ=' + CATALOGCFG_SEQ + '&' + 'strCatalog_Id=' + g_catalog_id + '&' + 'strCategory_Id=' + category_id + '&' + 'strCategory_Value=' + element.value + '&' + 'strCart_Id=' + g_cart_id+ '&' + 'strLine_No=' + szQty);
//        document.location.reload();
//        }
//		else
//			{return ;}   
//            alert ("Can't delete")
           
        }
</script>  
</asp:Content>