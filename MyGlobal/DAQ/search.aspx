<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/daq/MydaqMaster.master" %>

<script runat="server">
    Protected Sub clean_session_data(ByVal table_name As String)
        Dim sql As String = "SELECT *  FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'")
        End If       
    End Sub
    Protected Function getProductDetail() As DataTable
        Dim sql As String = "SELECT a.class, a.channel_type, a.channel_num, a.value_ids, a.description as wish_descr, a.cheap_pid as productids," & _
                            " a.piece, 	b.SKU, b.SKU as model_name, 	b.PRODUCTNAME, b.DESCRIPTION, b.BUYLINK, " & _
                            " b.SUPPORTLINK, b.LISTPRICE,  b.SKU as advise_item , '' as img_url  FROM DAQ_wishlist_tmp as  a " & _
                            " Inner Join DAQ_products as b ON a.productids = b.PRODUCTID " & _
                            "  WHERE sessionid = '" + Session.SessionID + "'  ORDER BY a.productids	"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If Session("user_id").ToString = "ming.zhao@advantech.com.cn" Then
            'Response.Write(sql + Session.SessionID)
        End If
        Dim ADV As New WWWLocal.AdvantechWebServiceLocal
       
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim sku As String = dt.Rows(i).Item("SKU")
                Dim P() As String = Split(sku, "-")
                If P.Length > 2 Then
                    dt.Rows(i).Item("model_name") = P(0) + "-" + P(1)
                    dt.Rows(i).Item("advise_item") = P(0)
                End If
                Dim picurl As String = ADV.getModelImage(dt.Rows(i).Item("SKU").ToString, "img")
                If picurl <> "http://www.advantech.com.tw/images/clear.gif" Then
                    dt.Rows(i).Item("img_url") = picurl
                Else
                    dt.Rows(i).Item("img_url") = "./image/no_image.jpg"
                End If
                ' dt.Rows(i).Item("img_url") = ADV.getModelImage(dt.Rows(i).Item("SKU").ToString, "img")
                
            Next
            dt.AcceptChanges()
        End If

        Return dt
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
       
        If Not IsPostBack Then
          
            Dim SQL = "SELECT * FROM DAQ_wishlist_tmp WHERE sessionid =  '" + Session.SessionID + "'"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)          
            If dt.Rows.Count > 0 Then               
                Dim product_result As DataTable = getProductDetail()
                If product_result.Rows.Count > 0 Then
                    rp1.DataSource = product_result
                    rp1.DataBind()
                    Call getother(product_result.Rows(0).Item("advise_item").ToString)
                    Me.hasno.Visible = False : Me.haslist1.Visible = True : Me.haslist2.Visible = True
                Else
                  
                    Me.haslist1.Visible = False : Me.haslist2.Visible = False : Me.hasno.Visible = True
                End If
            Else
                Me.haslist1.Visible = False : Me.haslist2.Visible = False : Me.hasno.Visible = True
            End If
            Call clean_session_data("DAQ_wishlist_tmp")
        End If
   
    End Sub
    Protected Sub getother(ByVal item As String)
        Dim dt As New DataTable
        dt.Columns.Add(New DataColumn("sku", GetType(String)))
        dt.Columns.Add(New DataColumn("description", GetType(String)))
        dt.Columns.Add(New DataColumn("img_url", GetType(String)))
        dt.Columns.Add(New DataColumn("details", GetType(String)))
        dt.Columns.Add(New DataColumn("item", GetType(String)))
        Dim dr As DataRow = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1671UP" : dr("description") = "IEEE-488.2 Interface Low Profile Universal PCI Card" : dr("img_url") = "PCI-1671UP_S.jpg" : dr("details") = "http://buy.advantech.com/PCI-and-ISA-Cards/PCI-and-ISA-Cards/model-PCI-1671UP-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1680U" : dr("description") = "2-port CAN-bus Universal PCI Communication Card" : dr("img_url") = "PCI-1680U_S.jpg" : dr("details") = "http://buy.advantech.com/Multiport-Serial-Cards/Multiport-Serial-Cards/model-PCI-1680U-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1240U" : dr("description") = "4-axis Stepping and Servo Motor Control Universal PCI Card" : dr("img_url") = "PCI-1240U_S.jpg" : dr("details") = "http://buy.advantech.com/Centralized-Motion-Control/Centralized-Motion-Control/model-PCI-1240U-BE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "ActvieDAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3680" : dr("description") = "2-port CAN-bus PC/104 Modules with Isolation Protection" : dr("img_url") = "PCM-3680_S.jpg" : dr("details") = "http://buy.advantech.com/Industrial-Communication/Industrial-Communication/model-PCM-3680-AE%20.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3642I" : dr("description") = "8-port RS-232 PCI-104 Module" : dr("img_url") = "PCM-3642I_S.jpg" : dr("details") = "http://buy.advantech.com/PCI-104-and-PC-104-Modules/PC-104-Modules/model-PCM-3642I-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3240" : dr("description") = "4-axis Stepping and Servo Motor Control PC/104 Card" : dr("img_url") = "PCM-3240_03_S.jpg" : dr("details") = "http://buy.advantech.com/Centralized-Motion-Control/Centralized-Motion-Control/model-PCM-3240-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "ActvieDAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4622" : dr("description") = "5-port USB 2.0 Hub" : dr("img_url") = "USB-4622_03_S.jpg" : dr("details") = "http://buy.advantech.com/USB-IO-Modules/USB-IO-Modules/model-USB-4622-BE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4671" : dr("description") = "GPIB USB Module" : dr("img_url") = "USB-4671_02_S.jpg" : dr("details") = "http://buy.advantech.com/USB-IO-Modules/USB-IO-Modules/model-USB-4671-A.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4604B" : dr("description") = "4-port RS-232 Serial to USB Converter" : dr("img_url") = "USB-4604B_03_S.jpg" : dr("details") = "http://buy.advantech.com/Device-Servers/Serial-Device-Servers/model-USB-4604B-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "ActvieDAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4520" : dr("description") = "RS-232 to RS-422/485 Converter" : dr("img_url") = "ADAM-4520_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4520-D2E.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4510I" : dr("description") = "Robust RS-422/485 Repeater" : dr("img_url") = "ADAM-4510I_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4510I-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4502" : dr("description") = "Ethernet-enabled Communication Controller" : dr("img_url") = "ADAM-4502_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4502-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4561" : dr("description") = "1-port Isolated USB to RS-232/422/485 Converter" : dr("img_url") = "ADAM-4561_S.jpg" : dr("details") = "http://buy.advantech.com/Device-Servers/Serial-Device-Servers/model-ADAM-4561-BE.htm"
        dt.Rows.Add(dr)
        dt.AcceptChanges()
        'OrderUtilities.showDT(dt)
      
        
        Dim newdt As New DataTable
        newdt = dt.Clone()
        Dim drs() As DataRow = dt.Select("item = '" + item + "'")
        If drs.Length <= 0 Then
            drs = dt.Select("item = 'PCI'")
        End If
        For i As Integer = 0 To drs.Length - 1
            newdt.ImportRow(DirectCast(drs(i), DataRow))
        Next
        
        dl1.DataSource = newdt
        dl1.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
   
   
<table  width="890" style="margin-left:20px;"  border="0" cellspacing="0" cellpadding="0" >
<tr>
<td>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>  <td><img src="./image/search_result.png"></td>
                            <td>  <a href="#" title="Email Me My Solution" rel="gb_page_center[640, 200]"><img src="./image/email_me.png" border="0"></a></td>                                                     
                          </tr>
                      </table>
</td>
</tr>

<tr runat="server" id="haslist1" ><td><table>
    <asp:Repeater runat="server" ID="rp1"><ItemTemplate>
    
    <tr>
                            <td bgcolor="#3da1db"><img src="./image/blue_01.jpg" width="5" height="5"></td>
                            <td><table width="100%" border="1"  cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                                <tr>
                                  <td width="130" bordercolor="#ffffff">
                                  <div align="center"><a href="<%# Eval("img_url")%>" rel="gb_imageset[nice_pics]"><img src="<%# Eval("img_url")%>" height="86" border="0"></a></div>
                                  </td>
                                </tr>
                            </table></td>
                            <td valign="center" width="400"><table width="100%" height="90" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                              <tr>
                                <td valign="top" bordercolor="#dae1f3" bgcolor="#dae1f3"><table width="100%" border="0" cellspacing="0" cellpadding="5">
                                    <tr>
                                      <td width="62%" valign="top"><table width="100%" border="0" cellspacing="5" cellpadding="0">
                                          <tr>
                                            <td class="daq-r-title" ><%# Eval("model_name")%>
                                            <span style="font-size:12px;">(pcs:<%# Eval("piece")%>)</span>
                                            </td>
                                          </tr>
                                          <tr>
                                            <td class="daq-r-title-2"><%# Eval("description")%><br></td>
                                          </tr>
                                      </table></td>
                                      <td width="38%" valign="top"><table width="100%" border="0" cellspacing="4" cellpadding="0">
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/data_logo.jpg" width="20" height="19"></div></td>
                                                  <td width="83%"><a target="_blank" href="<%# Eval("supportlink")%>" class="text">Data Sheet</a></td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/buy_logo.jpg" width="20" height="20"></div></td>
                                                  <td width="83%"><a target="_blank" href="<%# Eval("buylink")%>" class="text">Buy Online </a></td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/see_logo.jpg" width="20" height="19"></div></td>
                                                  <td width="83%"><a href="similar.aspx?pid=<%# Eval("productids")%>" class="text" rel="gb_page_center[640, 450]" title="See Similar Items">See Similar Items </a></td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                      </table></td>
                                    </tr>
                                </table></td>
                              </tr>
                            </table></td>
                            <td valign="top"><table width="255" height="90" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                              <tr>
                                <td valign="top" bordercolor="#dae1f3" bgcolor="#dae1f3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                      <td><table width="100%" border="0" cellspacing="3" cellpadding="0">
                                          <tr>
                                            <td class="text">Items in Wish List</td>
                                          </tr>
                                      </table></td>
                                    </tr>
                                    <tr>
                                      <td bgcolor="#bbbbbb"><img src="./image/cube01.jpg" width="1" height="1"></td>
                                    </tr>
                                    <tr>
                                      <td valign="top"  class="text" style="">
                                        <%# Eval("class")%>:&nbsp; <%# Eval("wish_descr")%>  </td>
                                    </tr>
                                </table></td>
                              </tr>
                            </table></td>
                          </tr>
    
    </ItemTemplate>
    </asp:Repeater>
    </table></td></tr>
    <tr runat="server" id="haslist2">
    <td>
        <table width="890" border="0s" align="center" cellpadding="0" cellspacing="0">
            <tr>
                <td width="516" valign="top">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td >
                                <table width="100%" border="0" cellspacing="3" cellpadding="0">
                                    <tr>
                                        <td>
                                            <img src="./image/bar02.jpg" width="523" height="26">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                               
                                <asp:DataList runat="server" ID="dl1" Width="100%" CellSpacing="3" CellPadding="1" RepeatDirection="Horizontal" RepeatColumns="2">
                                <ItemTemplate>
                                <table width="260" height="90" border="1" cellpadding="0" cellspacing="0"bordercolor="#bbbbbb">
    <tr>
        <td valign="top"  bgcolor="#f3eedc"  bordercolor="#f3eedc">
            <table width="100%" border="0" cellspacing="6" cellpadding="0">
                <tr>
                    <td width="26%" valign="top">
                        <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                            <tr>
                                <td  bgcolor="#FFFFFF" bordercolor="#FFFFFF">
                                    <div align="center">   <img src="./image/<%# Eval("img_url") %>"   height="86">
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td width="74%" valign="top">
                        <table width="100%" border="0" cellspacing="5" cellpadding="0">
                            <tr>
                                <td class="text">
                                   <%# Eval("sku")%>
                                </td>
                            </tr>
                            <tr>
                                <td class="daq-r-title-2">
                                     <%# Eval("description")%>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="51%" border="0" align="right" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="32%">
                                                <div align="center">
                                                    <img src="./image/details_logo.jpg" width="15" height="15">
                                                </div>
                                            </td>
                                            <td width="68%">
                                                <a href="http://buy.advantech.com/PCI-and-ISA-Cards/PCI-and-ISA-Cards/model-PCI-1671UP-AE.htm"
                                                target="_blank" class="text">
                                                    Details
                                                </a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
                               
                                </ItemTemplate>
                                            </asp:DataList> 
                               
                            
                            </td>
                        </tr>
                    </table>
                </td>
                <td  valign="top">
                    <table border="0" cellpadding="0" cellspacing="0" width="303">
                        <tr>
                            <td>
                             <%-- -----%>
                             <table border="0" cellpadding="0" cellspacing="0"  style="margin-top:10px;" width="330">

  <tr>
   <td colspan="4"  height="1"></td>
 
  </tr>
  <tr>
   <td colspan="3"><img  src="./image/b_search_r1_c1.jpg" width="330" height="38" border="0" id="b_search_r1_c1" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="38" border="0" alt="" /></td>
  </tr>
  <tr>
   <td rowspan="4"><img  src="./image/b_search_r2_c1.jpg" width="6" height="242" border="0" id="b_search_r2_c1" alt="" /></td>
   <td><a href="filter.aspx"><img  src="./image/b_search_r2_c2.jpg" alt=""  width="145" height="36" border="0" id="b_search_r2_c2" /></a></td>
   <td rowspan="4"><img  src="./image/b_search_r2_c3.jpg" width="179" height="242" border="0" id="b_search_r2_c3" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="36" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><img  src="./image/b_search_r3_c2.jpg" width="145" height="13" border="0" id="b_search_r3_c2" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="13" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><a href="#"><img  title="Customize It!" src="./image/b_search_r4_c2.jpg" alt="" name="b_search_r4_c2" width="145" height="37" border="0" id="b_search_r4_c2" /></a></td>
   <td><img src="spacer.gif" width="1" height="37" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><img  src="./image/b_search_r5_c2.jpg" width="145" height="156" border="0" id="b_search_r5_c2" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="156" border="0" alt="" /></td>
  </tr>
</table>
                              <%--------%>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </td>
</tr>
     
 <%--   --------------------- --%>
       <tr id="hasno" runat="server"><td>
     
   
        <table width="100%" border="0" cellpadding="0" cellspacing="3">
            <tr>
                <td>
                    <table border="0" cellpadding="0" cellspacing="0" width="826">
                        <tr>
                            <td>
                                <img src="./image/spacer.gif" width="528" height="1" border="0" />                            </td>
                            <td>
                                <img src="./image/spacer.gif" width="9" height="1" border="0" />                            </td>
                            <td>
                                <img src="./image/spacer.gif" width="140" height="1" border="0" />                            </td>
                            <td>
                                <img src="./image/spacer.gif" width="149" height="1" border="0" />                            </td>
                            <td>
                                <img src="./image/spacer.gif" width="1" height="1" border="0" />                            </td>
                        </tr>
                        <tr>
                            <td rowspan="5" valign="top" style="background-image:url('./image/no_result_and_try_r1_c1.jpg');">
                                <table cellpadding="0" cellspacing="0" border="0">
                                    <tr>
                                        <td bgcolor="#359EDF" width="5">&nbsp;                                      </td>
                                        <td>&nbsp;                                      </td>
                                        <td>
                                            <div class="no_result">
                                                Sorry, your search did not match any existing products.
                                                <br />
                                                Please try other criteria or click ‘Customize it’ for customization service.                                            </div>                                        </td>
                                    </tr>
                                </table>                            </td>
                            <td colspan="3" rowspan="5">
                     <%-- ----------------%>
							
						<table border="0" cellpadding="0" cellspacing="0" width="330">

  <tr>
   <td colspan="4"  height="1"></td>
 
  </tr>
  <tr>
   <td colspan="3"><img  src="./image/b_search_r1_c1.jpg" width="330" height="38" border="0" id="b_search_r1_c1" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="38" border="0" alt="" /></td>
  </tr>
  <tr>
   <td rowspan="4"><img  src="./image/b_search_r2_c1.jpg" width="6" height="242" border="0" id="b_search_r2_c1" alt="" /></td>
   <td><a href="filter.aspx"><img  src="./image/b_search_r2_c2.jpg" alt=""  width="145" height="36" border="0" id="b_search_r2_c2" /></a></td>
   <td rowspan="4"><img  src="./image/b_search_r2_c3.jpg" width="179" height="242" border="0" id="b_search_r2_c3" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="36" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><img  src="./image/b_search_r3_c2.jpg" width="145" height="13" border="0" id="b_search_r3_c2" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="13" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><a href="#"><img  title="Customize It!" src="./image/b_search_r4_c2.jpg" alt="" name="b_search_r4_c2" width="145" height="37" border="0" id="b_search_r4_c2" /></a></td>
   <td><img src="spacer.gif" width="1" height="37" border="0" alt="" /></td>
  </tr>
  <tr>
   <td><img  src="./image/b_search_r5_c2.jpg" width="145" height="156" border="0" id="b_search_r5_c2" alt="" /></td>
   <td><img src="spacer.gif" width="1" height="156" border="0" alt="" /></td>
  </tr>
</table>	
							
				     <%-- -------------------	--%>
							                            </td>
                            <td>
                                <img src="./image/spacer.gif" width="1" height="37" border="0" />                            </td>
                        </tr>
                        <tr>
                            <td>
                                <img src="./image/spacer.gif" width="1" height="35" border="0" />                            </td>
                        </tr>
                        <tr>
                          <td>
                              <img src="./image/spacer.gif" width="1" height="16" border="0" />                            </td>
                        </tr>
                        <tr>
                          <td>
                              <img src="./image/spacer.gif" width="1" height="36" border="0" />                            </td>
                        </tr>
                        <tr>
                          <td>
                              <img src="./image/spacer.gif" width="1" height="123" border="0" />                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

       
    </td>
</tr>     
</table>


</asp:Content>


