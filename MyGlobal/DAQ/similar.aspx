<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Public pid As String = "1", ggs As String = "Data Sheet",zxgm As  String="Buy Online"
    Public RB1_value As String = "" : Public Category_id As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    ggs = "规格书"
                    zxgm = "在线购买"
                Case "zh-tw"
                    ggs = "規格書"
                    zxgm = "立即購買"                  
                Case Else
                 
            End Select
            
        End If
        notb.Visible = False
        pid = Request("pid")
        If pid = "" Then
            Util.JSAlert(Me.Page, "PID  can't for empty")
            Exit Sub
        End If
        If pid = "YES" Then
            YesBind()
        ElseIf pid = "NO" Then
            YesBind()
        Else
            Dim sql As String = "SELECT a.*,a.PRODUCTID,  a.SKU, '' as MODEL_NAME, '' as img_url, " & _
                       " a.PRODUCTNAME,   a.DESCRIPTION,  a.ENABLE,   a.BUYLINK, a.BUYLINK_J,a.BUYLINK_F,  a.SUPPORTLINK,  a.LISTPRICE,   a.FLAG " & _
                       " FROM    daq_products as a  Inner Join daq_products_categories  as b ON b.PRODUCTID = a.PRODUCTID " & _
                       " WHERE   b.CATEGORYID =  (  SELECT top 1 CATEGORYID FROM   daq_products_categories " & _
                       " WHERE  PRODUCTID =  '" + pid + "' AND   MAIN =  '0'   ) " & _
                       " AND  a.PRODUCTID != '" + pid + "'  AND  b.MAIN =  '0'  AND    a.ENABLE = 'y'   ORDER BY a.sku "
            Bind(sql)
        End If
       
    End Sub
    Protected Sub YesBind()
        
        If Session("q1_vid") IsNot Nothing AndAlso Session("q1_vid").ToString <> "" Then
            RB1_value = Session("q1_vid").ToString
        End If       
        Dim pids As String = "" : pids = get_DAQ_available_list_tmp_pids() + "0" : Dim intersect_pids As String = "" : Dim return_avail_pids As String = ""
        ' Response.Write(pids + "<hr>")
        Dim seq As String = Request("seq") : Dim channel_type As String = "" : Dim ch_valueids As String = "" : Dim aich_pids As String = ""
        If seq = "" Then
            Dim seqObject As Object = dbUtil.dbExecuteScalar("MYLOCAL", "select min(seq) from DAQ_wishlist_tmp where sessionid = '" + Session.SessionID + "'")
            If seqObject IsNot Nothing Then
                seq = seqObject.ToString.Trim
            End If
        End If
        If seq <> "" Then
            Dim sql_seq As String = "select * from DAQ_wishlist_tmp where sessionid = '" + Session.SessionID + "' and seq = " + seq + ""
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_seq)
            If dt.Rows.Count > 0 Then
                 
                channel_type = dt.Rows(0).Item("channel_type").ToString.Trim
                ch_valueids = getOptionVidByChType(channel_type)
                aich_pids = search_wishlist(Session.SessionID, "", "", ch_valueids)
                intersect_pids = intersect_array(aich_pids, pids)
                If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                    Dim a() As String = Split(intersect_pids, ";")
                    Dim arr As New ArrayList
                    For i As Integer = 0 To a.Length - 1
                        If Not arr.Contains(a.GetValue(i)) AndAlso a.GetValue(i) <> "" Then
                            arr.Add(a.GetValue(i))
                        End If
                    Next
                    a = arr.ToArray(GetType(String))
       
                    For i As Integer = 0 To a.Length - 1
                        return_avail_pids = return_avail_pids + a(i) + ","
                    Next
                    return_avail_pids = return_avail_pids + "0"
                End If
                If RB1_value = "1" Then
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "96" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "316"
                            Case "AO" : Category_id = "317"
                            Case "DI" : Category_id = "318"
                            Case "DO" : Category_id = "319"
                            Case "COUNTER" : Category_id = "320"
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "97" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "323"
                            Case "AO" : Category_id = "324"
                            Case "DI" : Category_id = "325"
                            Case "DO" : Category_id = "326"
                            Case "COUNTER" : Category_id = "327"
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "196" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "361"
                            Case "AO" : Category_id = ""
                            Case "DI" : Category_id = ""
                            Case "DO" : Category_id = ""
                            Case "COUNTER" : Category_id = ""
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "197" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "330"
                            Case "AO" : Category_id = "331"
                            Case "DI" : Category_id = "332"
                            Case "DO" : Category_id = "333"
                            Case "COUNTER" : Category_id = "334"
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "198" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "336"
                            Case "AO" : Category_id = "337"
                            Case "DI" : Category_id = "338"
                            Case "DO" : Category_id = "339"
                            Case "COUNTER" : Category_id = "340"
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "200" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "356"
                            Case "AO" : Category_id = ""
                            Case "DI" : Category_id = "357"
                            Case "DO" : Category_id = "358"
                            Case "COUNTER" : Category_id = ""
                        End Select
                    End If
                End If
                If RB1_value = "2" Then
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "201" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "343"
                            Case "AO" : Category_id = "344"
                            Case "DI" : Category_id = "345"
                            Case "DO" : Category_id = "346"
                            Case "COUNTER" : Category_id = "347"
                        End Select
                    End If
                    If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" AndAlso Session("q3_vid").ToString = "202" Then
                        Select Case dt.Rows(0).Item("class").ToString.Trim.ToUpper
                            Case "AI" : Category_id = "348"
                            Case "AO" : Category_id = "349"
                            Case "DI" : Category_id = ""
                            Case "DO" : Category_id = "350"
                            Case "COUNTER" : Category_id = ""
                        End Select
                    End If
                End If
              
                '  Response.Write(return_avail_pids + "<hr>" + Category_id)
                ''''''''''''''''''''''
                If return_avail_pids <> "" Then
                  
                    Dim sql As String = ""
                    If Category_id = "" Then
                        sql = "SELECT a.*,a.PRODUCTID,  a.SKU, '' as MODEL_NAME, '' as img_url, " & _
                             " a.PRODUCTNAME,   a.DESCRIPTION,  a.ENABLE,   a.BUYLINK, a.BUYLINK_J,a.BUYLINK_F,  a.SUPPORTLINK,  a.LISTPRICE,   a.FLAG " & _
                             " FROM    daq_products as a  where a.productid in (" + return_avail_pids + ")  AND a.productid <> '0' and    a.ENABLE = 'y'   ORDER BY a.sku "
                    Else
                        sql = "SELECT a.*,a.PRODUCTID,  a.SKU, '' as MODEL_NAME, '' as img_url, " & _
                             " a.PRODUCTNAME,   a.DESCRIPTION,  a.ENABLE,   a.BUYLINK, a.BUYLINK_J,a.BUYLINK_F,  a.SUPPORTLINK,  a.LISTPRICE,   a.FLAG " & _
                             " FROM    daq_products as a " & _
                 "  Inner Join daq_products_categories  as b ON b.PRODUCTID = a.PRODUCTID " & _
                      " WHERE   b.CATEGORYID = '" + Category_id + "'  and a.productid in (" + return_avail_pids + ")  AND a.productid <> '0' and    a.ENABLE = 'y'   ORDER BY a.sku "
                    End If
                   
                  
                    Bind(sql)
                Else
                    If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
                        Dim lan As String = Session("Browser_lan").ToString.ToLower
                        Select Case lan
                            Case "zh-cn"
                                notb.InnerHtml = "<br>对不起,没有备选方案！"
                            Case "zh-tw"
                                notb.InnerHtml = "<br>很抱歉！無合適方案符合您的需求！"
                            Case Else
                                notb.InnerHtml = "<br>Sorry, there is no alternative option. "
                        End Select
                    Else
                        notb.InnerHtml = "<br>Sorry, there is no alternative option. "
                    End If
                
                    notb.Visible = True
                End If
           
            End If
                      
        End If
      
       
    End Sub
  
    Protected Sub Bind(ByVal sql As String)
             
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", Sql)
             
        If dt.Rows.Count > 0 Then
            notb.Visible = False
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim sku As String = dt.Rows(i).Item("SKU")
                dt.Rows(i).Item("model_name") = dt.Rows(i).Item("SKU")
                        
                dt.Rows(i).Item("img_url") = "http://my-global.advantech.eu/download/downloadlit.aspx?pn=" + dt.Rows(i).Item("SKU").ToString
                
            Next
            dt.AcceptChanges()
            If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
                Dim lan As String = Session("Browser_lan").ToString.ToLower
                For i As Integer = 0 To dt.Rows.Count - 1
                    With dt.Rows(i)
                        If lan = "zh-cn" Then
                            If Not IsDBNull(.Item("BUYLINK_J")) AndAlso .Item("BUYLINK_J").ToString.Trim <> "" Then
                                .Item("BUYLINK") = .Item("BUYLINK_J")
                                .Item("DESCRIPTION") = .Item("DESCRIPTION_J")
                            End If
                        ElseIf lan = "zh-tw" Then
                            If Not IsDBNull(.Item("BUYLINK_F")) AndAlso .Item("BUYLINK_F").ToString.Trim <> "" Then
                                .Item("BUYLINK") = .Item("BUYLINK_F")
                                 .Item("DESCRIPTION") = .Item("DESCRIPTION_F")
                            End If
                        End If
                    End With
                Next
            End If
            dt.AcceptChanges()
            rp.DataSource = dt
            rp.DataBind()
        Else
            notb.Visible = True
        End If
    End Sub
    Protected Function get_DAQ_available_list_tmp_pids() As String
        Dim return_avail_pids As String = ""
      
        Dim sql As String = "SELECT productid FROM DAQ_available_list_tmp WHERE sessionid = '" + Session.SessionID + "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                If Not IsDBNull(dt.Rows(i).Item("productid")) AndAlso dt.Rows(i).Item("productid").ToString <> "" Then
                    return_avail_pids = return_avail_pids + dt.Rows(i).Item("productid").ToString + ";"
                End If
               
            Next
           
        End If
        Return return_avail_pids
    End Function
    Protected Function getOptionVidByChType(ByVal chtype As String) As String
        Dim ch_vids() As String = {}, ch_optionid() As String = {} : Dim return_value As String = ""
        Select Case chtype
            Case "ai" : ch_optionid = {"1", "24"}
            Case "ao" : ch_optionid = {"5"}
            Case "di_ttl" : ch_optionid = {"9"}
            Case "di_isolation" : ch_optionid = {"26"}
            Case "do_ttl" : ch_optionid = {"12"}
            Case "do_isolation" : ch_optionid = {"27"}
            Case "do_relay" : ch_optionid = {"28"}
            Case "counter" : ch_optionid = {"17"}
        End Select : Dim where_cond As String = ""
        For i As Integer = 0 To ch_optionid.Length - 1
            If i = ch_optionid.Length - 1 Then
                where_cond = where_cond + " OPTIONID =  '" + ch_optionid(i) + "' "
            Else
                where_cond = where_cond + " OPTIONID =  '" + ch_optionid(i) + "'  or "
            End If
        Next
        Dim sql As String = "SELECT OPTION_VALUEID FROM DAQ_spec_options_values WHERE ( " + where_cond + " ) AND OPTION_VALUE <>  '-' ORDER BY OPTIONID ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            ReDim ch_vids(dt.Rows.Count - 1)
            For i As Integer = 0 To dt.Rows.Count - 1
                ch_vids(i) = dt.Rows(i)("OPTION_VALUEID")
            Next
        End If
        For k As Integer = 0 To ch_vids.Length - 1
            If ch_vids(k) <> "" Then
                return_value = return_value + ch_vids(k) + ";"
            End If
        Next
        Return return_value
    End Function
    Protected Function search_wishlist(ByVal sid As String, ByVal ch_type As String, ByVal ch_num As String, ByVal optionvid As String) As String
        Dim tmp() As String = Split(optionvid, ";") : Dim p() As String = {}, return_avail_pids As String = "" : Dim all_pids As String = "", ch_productids() As String, avail_pids As String = ""
        Dim pids_intersect() As String = {}, pids() As String = {}
        ReDim p(tmp.Length - 1)
        For i As Integer = 0 To tmp.Length - 1
            all_pids = all_pids + search_option(tmp(i))
        Next
       
        Dim a() As String = Split(all_pids, ";")
        Dim arr As New ArrayList
        For i As Integer = 0 To a.Length - 1
            If Not arr.Contains(a.GetValue(i)) AndAlso a.GetValue(i) <> "" Then
                arr.Add(a.GetValue(i))
            End If
        Next
        a = arr.ToArray(GetType(String))
       
        For i As Integer = 0 To a.Length - 1
            'Dim sql As String = "SELECT * FROM DAQ_available_list_tmp WHERE sessionid = '" + sid + "' AND productid = '" + a(i) + "'"
            'Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            ' If dt.Rows.Count > 0 Then
            return_avail_pids = return_avail_pids + a(i) + ";"
            ' End If
        Next
        Return return_avail_pids
        '''''''''''''''''
    End Function
    Public Shared Function search_option(ByVal optionvid As String) As String
        Dim option_valueid As String = optionvid, optionid As String = "", option_type As String = "", productid() As String = {}
        Dim sql As String = "SELECT a.OPTIONID,b.OPTION_TYPE FROM DAQ_spec_options_values as a Inner Join DAQ_spec_options as b ON b.OPTIONID = a.OPTIONID" & _
                            "  WHERE a.OPTION_VALUEID =  '" + option_valueid + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            optionid = dt.Rows(0)("optionid")
            option_type = dt.Rows(0)("option_type")
        End If
        If option_type = "s" Then
            Dim sql2 As String = "SELECT PRODUCTID FROM  DAQ_product_spec_values WHERE OPTIONID =  '" + optionid + "' AND OPTION_VALUES =  '" + option_valueid + "'  ORDER BY  PRODUCTID"
            Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql2)
            If dt2.Rows.Count > 0 Then
                ReDim productid(dt2.Rows.Count - 1)
                For i As Integer = 0 To dt2.Rows.Count - 1
                    productid(i) = dt2.Rows(i).Item("productid")
                Next
                'OrderUtilities.showDT(dt2)
                'Response.End()
            End If
        End If
        If option_type = "m" Then
            Dim sql3 As String = "SELECT PRODUCTID, OPTION_VALUES FROM DAQ_product_spec_values WHERE OPTIONID =  '" + optionid + "' ORDER BY  PRODUCTID"
            Dim dt3 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql3)
            If dt3.Rows.Count > 0 Then
                ReDim productid(dt3.Rows.Count - 1)
                For i As Integer = 0 To dt3.Rows.Count - 1
                    Dim option_vid() As String = Split(dt3.Rows(i)("option_values"), "|")
                    If DirectCast(option_vid, IList).Contains(option_valueid) Then
                        productid(i) = dt3.Rows(i)("productid")
                    End If
                Next
            End If
        End If
        Dim return_value As String = ""
        For i As Integer = 0 To productid.Length - 1
            If productid(i) <> "" Then
                return_value = return_value + productid(i) + ";"
            End If
   
        Next
            
        Return return_value
    End Function
    Protected Function intersect_array(ByVal str1 As String, ByVal str2 As String) As String
        If str1 = "" OrElse str2 = "" Then Return "0" : Exit Function
        Dim return_pids As String = ""
       
        Dim a() As String = Split(str1, ";") : Dim b() As String = Split(str2, ";")
        Dim arr As New ArrayList
        For i As Integer = 0 To a.Length - 1
            For j As Integer = 0 To b.Length - 1
                If a.GetValue(i) = b.GetValue(j) AndAlso a.GetValue(i) <> "" Then
                    arr.Add(a.GetValue(i))
                End If
            Next
          
        Next
        a = arr.ToArray(GetType(String))
        For i As Integer = 0 To a.Length - 1
            If a(i) <> "" Then
                return_pids = return_pids + a(i) + ";"
            End If
        Next
        Return return_pids
    End Function
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="css.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <table border="0" cellpadding="3" cellspacing="3" width="600">
    <asp:Repeater runat="server" ID="rp">
    <ItemTemplate>
    
    <tr>
<td width="120"><img src="<%# Eval("img_url")%>" alt="<%# Eval("sku")%>" width="100"/></td>
<td bgcolor="#F1FDF9" width="300">
    <table width="100%" border="0" cellspacing="5" cellpadding="0">
      <tr>
        <td class="daq-r-title" ><%# Eval("model_name")%></td>
      </tr>
      <tr>
        <td class="daq-r-title-2"><%# Eval("description")%><br></td>
      </tr>
  </table>
</td>
<td>
        <img src="./image/data_logo.jpg" width="20" height="19">
        <a target="_blank" href="<%# Eval("supportlink")%>" class="text"><%= ggs %></a><br />
        <img src="./image/buy_logo.jpg" width="20" height="20">
        <a target="_blank" href="<%# Eval("buylink")%>" class="text"><%= zxgm %></a>
</td>
</tr>
    
    </ItemTemplate>
    </asp:Repeater>
    </table>

  <div runat="server" id="notb" visible="false"  style="font-family: Arial, Helvetica, sans-serif; font-size: 16px; color: #808080; text-align: center; width: 100%; font-weight: bold;"> <br />Sorry, there is no similar item.    <br /></div>   
     
     
    </form>
</body>
</html>
