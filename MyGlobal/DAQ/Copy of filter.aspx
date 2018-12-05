<%@ Page Title="DAQ Your Way" validateRequest="false" Language="VB" EnableEventValidation="true" MasterPageFile="~/daq/MyDAQMaster.master" %>

<script runat="server">
    Dim pci_vid As String = "96", pci_id As String = "22", isa_vid As String = "97", isa_id As String = "22", pcie_vid As String = "196", pcie_id As String = "22", pc_sl_104_vid As String = "197", pc_sl_104_id As String = "22", pc_da_104_vid As String = "198", pc_da_104_id As String = "22"
    Dim pc_sl_104_plus_vid As String = "199", pc_sl_104_plus_id As String = "22", usb_vid As String = "200", usb_id As String = "22", winxp_vid As String = "90", winxp_id As String = "20"
    Dim vista_vid As String = "91", vista_id As String = "20", wince_vid As String = "92", wince_id As String = "20", winxpe_vid As String = "93", winxpe_id As String = "20"
    Dim linux_vid As String = "195", linux_id As String = "20", rs485_vid As String = "201", rs485_id As String = "22", ethernet_vid As String = "202", ethernet_id As String = "22", modbus_vid As String = "94", modbus_id As String = "21", ascii_vid As String = "95", ascii_id As String = "21"
    Dim Q1 As String = "1"
    Protected Sub RB1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
       
        'Call clean_session_data("DAQ_available_list_check")
        'Call clean_session_data("DAQ_available_list_tmp")
        Call clean_session_data("DAQ_wishlist_tmp")
        Session("q1_vid") = RB1.SelectedValue 
        Session("q2_vid") = ""
        Session("q3_vid") = ""
        Session("q4_vid") = ""
        If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
            Q3_title.Text = "Available Bus" : Q4_title.Text = "Operating System"
            Call set_Q5_1()
        End If
        If RB1.SelectedValue = "2" Then
            Q3_title.Text = "Preferred Interface" : Q4_title.Text = "Protocal"
            Call set_Q5_2()
        End If
    End Sub
    Protected Sub clean_session_data(ByVal table_name As String)
        Dim sql As String = "SELECT *  FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'")
        End If
        
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
           
        If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
            Response.Redirect("../home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
            Response.End()
        End If
       
       
        If Not IsPostBack Then
            'Call clean_session_data("DAQ_wishlist_tmp")
            'Call clean_session_data("DAQ_wishlist_avail_tmp")
            'Call clean_session_data("DAQ_wishlist_channels_tmp")
            'Call clean_session_data("DAQ_available_list_check")
            'Call clean_session_data("DAQ_available_list_tmp")
            dich_ttl_TR.Visible = True : DI1image_TR.Visible = True
            si_1_1.Visible = True : si_1_2.Visible = True
            dich_ttl_TR2.Visible = True : DI1image_TR2.Visible = True
            si_1_12.Visible = True : si_1_22.Visible = True
        End If
        ''''
        If Not IsPostBack Then
            If Session("q1_vid") IsNot Nothing AndAlso Session("q1_vid").ToString <> "" Then
               RB1.SelectedValue = Session("q1_vid").ToString
            End If
            If Session("q2_vid") IsNot Nothing AndAlso Session("q2_vid").ToString <> "" Then
                RB2.SelectedValue = Session("q2_vid").ToString
            End If
            '''''''''''''''''''''''show av.innerHtml
            Dim ceshi As String = ""
            ceshi = ceshi + Session.SessionID + "<br>" + "q1_vid:" + HttpContext.Current.Session("q1_vid") + "<br>" + "q2_vid:" + HttpContext.Current.Session("q2_vid") + "<br>" + "q3_vid:" + HttpContext.Current.Session("q3_vid") + "<br>" + "q4_vid:" + HttpContext.Current.Session("q4_vid") + "<br>"
            ceshi = ceshi + "<hr>"
            Dim sql_daq_available_list_check As String = "select q_no,q_optionid,q_optionvid from DAQ_available_list_check where sessionid='" + Session.SessionID + "'"
            Dim dtceshi As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_daq_available_list_check)
            If dtceshi.Rows.Count > 0 Then
                For J As Integer = 0 To dtceshi.Rows.Count - 1
               
                    ceshi = ceshi + String.Format("<span style='font-size:11px;'>{0}--{1}--{2}</span><br>", dtceshi.Rows(J).Item("q_no").ToString, _
                                             dtceshi.Rows(J).Item("q_optionid"), dtceshi.Rows(J).Item("q_optionvid"))
                     
                Next
	      
            End If
            ''''''''
            ceshi = ceshi + "<hr>"
            Dim sql_daq_available_list_tmp As String = "select a.* , (select sku from DAQ_products where productid = a.productid) as sku from DAQ_available_list_tmp as a " & _
                                                         " where sessionid='" + Session.SessionID  + "' order by productid asc"
            Dim dtceshi2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_daq_available_list_tmp)
            If dtceshi2.Rows.Count > 0 Then
                For J As Integer = 0 To dtceshi2.Rows.Count - 1
                    If Not IsDBNull(dtceshi2.Rows(J).Item("avail")) Then
                        If dtceshi2.Rows(J).Item("avail") = "q4" Then
                            ceshi = ceshi + String.Format("<span style='font-size:11px;color:#FF0000'>{0}--{1}--{2}--<b>{3}</b></span><br>", dtceshi2.Rows(J).Item("productid").ToString, _
                                            dtceshi2.Rows(J).Item("q_no"), dtceshi2.Rows(J).Item("avail"), dtceshi2.Rows(J).Item("sku"))
                        Else
                            ceshi = ceshi + String.Format("<span style='font-size:11px;'>{0}--{1}--{2}--{3}</span><br>", dtceshi2.Rows(J).Item("productid").ToString, _
                                               dtceshi2.Rows(J).Item("q_no"), dtceshi2.Rows(J).Item("avail"), dtceshi2.Rows(J).Item("sku"))
                        End If
                
                    End If
              
                Next
            End If
            av.InnerHtml = ceshi 
            ''''''''''''''''''''''
        End If
        ''''
        For Each item As ListItem In RB1.Items
            If item.Value = "1" Then
                item.Attributes.Add("onclick", "javascript:xajax_available_list(""q1"",""0"",""1"",""" + Session.SessionID + """);")
                
            End If
            If item.Value = "2" Then
                item.Attributes.Add("onclick", "javascript:xajax_available_list(""q1"",""0"",""2"",""" + Session.SessionID + """);")
            End If
        Next
        ''''''''''''''''''''''''''
        For Each item As ListItem In RB2.Items
            item.Attributes.Add("onclick", "javascript:xajax_available_list2(""" + item.Value + """);")
        Next
        ''''''''''''''''''''''''''''''''''''''''     
        Dim Q3_str As String = "", Q4_str As String = "", q3_old_state As String = "", q4_old_state As String = ""
        Dim c1 As String = "", c2 As String = "", c3 As String = "", c4 As String = "", c5 As String = "", c6 As String = "", c7 As String = ""
        Dim m1 As String = "", m2 As String = "", m3 As String = "", m4 As String = "", m5 As String = ""
        Dim p1 As String = "", p2 As String = "", p3 As String = ""
        Dim k1 As String = "", k2 As String = "", k3 As String = ""
        If Session("q3_vid") IsNot Nothing AndAlso Session("q3_vid").ToString <> "" Then
            q3_old_state = Session("q3_vid").ToString
        End If
        If Session("q4_vid") IsNot Nothing AndAlso Session("q4_vid").ToString <> "" Then
            q4_old_state = Session("q4_vid").ToString
        End If
        Select Case q3_old_state
            Case pci_vid : c1 = "checked='checked'"
            Case isa_vid : c2 = "checked='checked'"
            Case pcie_vid : c3 = "checked='checked'"
            Case pc_sl_104_vid : c4 = "checked='checked'"
            Case pc_da_104_vid : c5 = "checked='checked'"
            Case pc_sl_104_plus_vid : c6 = "checked='checked'"
            Case usb_vid : c7 = "checked='checked'"
            Case rs485_vid : p1 = "checked='checked'"
            Case ethernet_vid : p2 = "checked='checked'"
            Case "0" : p3 = "checked='checked'"
        End Select
        Select Case q4_old_state
            Case winxp_vid : m1 = "checked='checked'"
            Case vista_vid : m2 = "checked='checked'"
            Case wince_vid : m3 = "checked='checked'"
            Case winxpe_vid : m4 = "checked='checked'"
            Case linux_vid : m5 = "checked='checked'"
            Case modbus_vid : k1 = "checked='checked'"
            Case ascii_vid : k2 = "checked='checked'"
            Case "0" : k3 = "checked='checked'"
        End Select
        If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
            Q3_str = "<table width='100%' border='0' height='26' cellspacing='0' cellpadding='0'><tr>" & _
        "<td width='120' class='text'>" & _
        "<input type='radio' name='q3' " + c1 + " id='" + pci_id + "' value='" + pci_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">PCI</td>" & _
        "<td width='120' class='text'>" & _
        "<input type='radio' name='q3' " + c2 + " id='" + isa_id + "' value='" + isa_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">ISA</td>" & _
        "<td width='120' class='text'>" & _
        "<input type='radio' name='q3' " + c3 + " id='" + pcie_id + "' value='" + pcie_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">PCIe</td>" & _
        "<td width='120' class='text'>" & _
          "<input type='radio' name='q3' " + c4 + " id='" + pc_sl_104_id + "' value='" + pc_sl_104_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">PC/104</td>" & _
          "<td width='120' class='text'>" & _
          "<input type='radio' name='q3' " + c5 + " id='" + pc_da_104_id + "' value='" + pc_da_104_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">PCI-104</td>" & _
          "<td width='120' class='text'>" & _
          "<input type='radio' name='q3' " + c6 + " id='" + pc_sl_104_plus_id + "' value='" + pc_sl_104_plus_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">PC/104+</td>" & _
          "<td width='120' class='text'>" & _
          "<input type='radio' name='q3' " + c7 + " id='" + usb_id + "' value='" + usb_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">USB</td>" & _
          "</tr></table>"
            Q4_str = "<table width='100%' border='0' height='26' cellspacing='0' cellpadding='0'>" & _
       "<tr><td width='162' class='text'><input type='radio' " + m1 + " name='q4' id='" + winxp_id + "' value='" + winxp_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Window2000/XP</td>" & _
       "<td width='160' class='text'><input type='radio' " + m2 + " name='q4' id='" + vista_id + "' value='" + vista_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Windows 7</td>" & _
        "<td width='146' class='text'><input type='radio' " + m3 + " name='q4' id='" + wince_id + "' value='" + wince_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">WinCE</td>" & _
       "<td width='204' class='text'><input type='radio' " + m4 + " name='q4' id='" + winxpe_id + "' value='" + winxpe_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Windows XP Embedded</td>" & _
      "<td width='168' class='text'><input type='radio' " + m5 + " name='q4' id='" + linux_id + "' value='" + linux_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Linux</td>" & _
       "</tr></table>"
            If Not IsPostBack Then
             
                Call set_Q5_1()
            End If
        Else
            Q3_str = "<table width='100%' border='0' cellspacing='0' height='26' cellpadding='0'><tr>" & _
           "<td width='162' class='text'><input type='radio' name='q3' " + p1 + " id='" + rs485_id + "' value='" + rs485_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">RS-485/422/232</td>" & _
           "<td width='160' class='text'><input type='radio' name='q3' " + p2 + " id='" + ethernet_id + "' value='" + ethernet_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Ethernet</td>" & _
           "<td width='518' class='text'><input type='radio' name='q3' " + p3 + " id='q3_3' value='0' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Others&nbsp;<input name='q5_o' type='text' id='q5_o' size='10' ></td></tr></table>"
            Q4_str = "<table width='100%' border='0' height='26' cellspacing='0' cellpadding='0'>" & _
             "<tr><td width='168' class='text'><input type='radio' name='q4' " + k1 + " id='" + modbus_id + "' value='" + modbus_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Modbus</td>" & _
             "<td width='168' class='text'><input type='radio' name='q4' " + k2 + " id='" + ascii_id + "' value='" + ascii_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">ASCII</td>" & _
             "<td width='543' class='text'><input type='radio' name='q4' " + k3 + " id='q4_3' value='0' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Others&nbsp;" & _
             "<input name='q6_o' type='text' id='q6_o' size='10' ></td></tr></table>"
            If Not IsPostBack Then
                Call set_Q5_2()
            End If
       
        End If
        Me.Q3.InnerHtml = Q3_str : Me.Q4.InnerHtml = Q4_str

    End Sub
    Private Sub set_Q5_1()
        '''''''''''''''''''''''''''''''''''''''''111111111111111111111111111111111111111111'''''''''''''''''''''''''''''''''''''''''''''''''
        YI5YI.Visible = True : YI5ER.Visible = True : YI5SAN.Visible = True : YI5SI.Visible = True : YI5WU.Visible = True
    
        ER5YI.Visible = False : ER5ER.Visible = False : ER5SAN.Visible = False : ER5SI.Visible = False : ER5WU.Visible = False
        '''''''''''''' Air
        air.Items.Clear()
        air.Items.Add(New ListItem("-select-", "none"))
        Dim airdt As DataTable = getOption("1", "2")
        For Each r As DataRow In airdt.Rows
            Dim Value As String = "2^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            air.Items.Add(New ListItem(Text, Value))
        Next
        air.DataBind()
        '''''''''''Aisr
        aisr.Items.Clear()
        aisr.Items.Add(New ListItem("-select-", "none"))
        Dim aisrdt As DataTable = getOptionValueGroup("3")
        For Each r As DataRow In aisrdt.Rows
            Dim Value As String = "3^" + r("group_daq").ToString() + "^" + r("group_descr").ToString()
            Dim Text As String = r("group_descr").ToString()
            aisr.Items.Add(New ListItem(Text, Value))
        Next
        aisr.DataBind()
        ''''''''''''''Aiir
        aiir.Items.Clear()
        aiir.Attributes.Add("onchange", "aiirselectChange('" + Me.aiir.ClientID + "',""add_aioption"")")
        aiir.Items.Add(New ListItem("-select-", "none"))
        Dim aiirdt As DataTable = getOptionValueGroup("4")
        For Each r As DataRow In aiirdt.Rows
            Dim Value As String = "4^" + r("group_daq").ToString() + "^" + r("group_descr").ToString()
            Dim Text As String = r("group_descr").ToString()
            aiir.Items.Add(New ListItem(Text, Value))
        Next
        aiir.Items.Add(New ListItem("Temperature", "aiir_t^aiir_t^Temperature"))
        aiir.DataBind()
        '''''''''''''''''''''''''''''''''''''''''''''''''''''22222222222222222222222222222222222222'''''''''''''''''''''''''''''''''''''''''''''
        aor.Items.Clear()
        aor.Items.Add(New ListItem("-select-", "none"))
        Dim aordt As DataTable = getOption("2", "6")
        For Each r As DataRow In aordt.Rows
            Dim Value As String = "6^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aor.Items.Add(New ListItem(Text, Value))
        Next
        aor.DataBind()
        ''''''''''''''''
        aoort.Items.Clear()
        aoort.Items.Add(New ListItem("-select-", "none"))
        Dim aoortdt As DataTable = getOption("2", "7")
        For Each r As DataRow In aoortdt.Rows
            Dim Value As String = "7^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aoort.Items.Add(New ListItem(Text, Value))
        Next
        aoort.DataBind()
        ''''''''''''''''''''''''
        aoorg.Items.Clear()
        aoorg.Items.Add(New ListItem("-select-", "none"))
        Dim aoorgdt As DataTable = getOptionValueGroup("8")
        For Each r As DataRow In aoorgdt.Rows
            Dim Value As String = "8^" + r("group_daq").ToString() + "^" + r("group_descr").ToString()
            Dim Text As String = r("group_descr").ToString()
            aoorg.Items.Add(New ListItem(Text, Value))
        Next
        aoorg.Items.Add(New ListItem("0~20 mA", "8^E^0~20mA"))
        aoorg.DataBind()
        '''''''''''''''''''''''''''''''''''''''''''555555555'''''''''''''''''''''''''''''''''''''''
        counter_r.Items.Clear()
        counter_r.Items.Add(New ListItem("-select-", "none"))
        Dim counter_rdt As DataTable = getOption("5", "18")
        For Each r As DataRow In counter_rdt.Rows
            Dim Value As String = "18^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            counter_r.Items.Add(New ListItem(Text, Value))
        Next
        counter_r.DataBind()
        ''''''''''''''''''''''
        counter_mif.Items.Clear()
        counter_mif.Items.Add(New ListItem("-select-", "none"))
        Dim counter_mifdt As DataTable = getOption("5", "19")
        For Each r As DataRow In counter_mifdt.Rows
            Dim Value As String = "19^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            counter_mif.Items.Add(New ListItem(Text, Value))
        Next
        counter_mif.DataBind()
        
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    End Sub
    Private Sub set_Q5_2()
        YI5YI.Visible = False : YI5ER.Visible = False : YI5SAN.Visible = False : YI5SI.Visible = False : YI5WU.Visible = False
      
        ER5YI.Visible = True : ER5ER.Visible = True : ER5SAN.Visible = True : ER5SI.Visible = True : ER5WU.Visible = True
        '''''''''''Aisr2
        aisr2.Items.Clear()
        aisr2.Items.Add(New ListItem("-select-", "none"))
        Dim aisrdt2 As DataTable = getOption(1, 3)
        ' OrderUtilities.showDT(aisrdt2)
        Dim dt2aisr2 As DataTable = aisrdt2.Clone
        For i As Integer = 0 To 1
            Dim dr100 As DataRow = dt2aisr2.NewRow
            dr100("OPTION_VALUE") = aisrdt2.Rows(i).Item("OPTION_VALUE")
            dr100.Item("OPTION_VALUEID") = aisrdt2.Rows(i).Item("OPTION_VALUEID")
            dr100.Item("GROUP_daq") = aisrdt2.Rows(i).Item("GROUP_daq")
            dt2aisr2.Rows.Add(dr100)
        Next
        dt2aisr2.AcceptChanges()
        ' OrderUtilities.showDT(dt2aisr2)
        For Each r As DataRow In dt2aisr2.Rows
            Dim Value As String = "3^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aisr2.Items.Add(New ListItem(Text, Value))
        Next
        aisr2.DataBind()
        ''''''''''''''Aiir2
        aiir2.Items.Clear()
        aiir2.Attributes.Add("onchange", "aiirselectChange('" + Me.aiir2.ClientID + "',""add_aioption2"")")
        aiir2.Items.Add(New ListItem("-select-", "none"))
        Dim aiirdt2 As DataTable = getOptionValueGroup("4")
        ' OrderUtilities.showDT(aiirdt2)
        Dim dt2aiir2 As DataTable = aiirdt2.Clone
        For i As Integer = 3 To aiirdt2.Rows.Count - 1
            Dim dr100 As DataRow = dt2aiir2.NewRow
            dr100("group_daq") = aiirdt2.Rows(i).Item("group_daq")
            dr100.Item("group_descr") = aiirdt2.Rows(i).Item("group_descr")
          
            dt2aiir2.Rows.Add(dr100)
        Next
        dt2aiir2.AcceptChanges()
        ' OrderUtilities.showDT(dt2aiir2)
        For Each r As DataRow In dt2aiir2.Rows
            Dim Value As String = "4^" + r("group_daq").ToString() + "^" + r("group_descr").ToString()
            Dim Text As String = r("group_descr").ToString()
            aiir2.Items.Add(New ListItem(Text, Value))
        Next
        aiir2.Items.Add(New ListItem("Temperature", "aiir_t^aiir_t^Temperature"))
        aiir2.DataBind()
        
        '''''''''''''''''''''''''''''''''''''''''''''''''''''22222222222222222222222222222222222222'''''''''''''''''''''''''''''''''''''''''''''
        aor2.Items.Clear()
        aor2.Items.Add(New ListItem("-select-", "none"))
        Dim aordt2 As DataTable = getOption("2", "6")
        ' OrderUtilities.showDT(aordt2)
        Dim dr() As DataRow = aordt2.Select("OPTION_VALUE='14'")
        aordt2.Rows.Remove(dr(0)) : aordt2.AcceptChanges()
        ' OrderUtilities.showDT(aordt2)
        For Each r As DataRow In aordt2.Rows
            Dim Value As String = "6^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aor2.Items.Add(New ListItem(Text, Value))
        Next
        aor2.DataBind()
          
        ''''''''''''''''''''''''
        aoorg2.Items.Clear()
        aoorg2.Items.Add(New ListItem("-select-", "none"))
        Dim aoorgdt2 As DataTable = getOptionValueGroup("8")
        'OrderUtilities.showDT(aoorgdt2)
        Dim dr2() As DataRow = aoorgdt2.Select("group_descr='0~5V' or group_descr='-5~5V'")
        For i As Integer = 0 To dr2.Length - 1
            aoorgdt2.Rows.Remove(dr2(i))
        Next
        aoorgdt2.AcceptChanges()
        ' OrderUtilities.showDT(aoorgdt2)
        For Each r As DataRow In aoorgdt2.Rows
            Dim Value As String = "8^" + r("group_daq").ToString() + "^" + r("group_descr").ToString()
            Dim Text As String = r("group_descr").ToString()
            aoorg2.Items.Add(New ListItem(Text, Value))
        Next
        aoorg2.Items.Add(New ListItem("0~20 mA", "8^E^0~20mA"))
        aoorg2.DataBind()
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 33333333333333333333333333333333333'''''''''''''''''''''''''''''''''''''''''
    End Sub
   
    Protected Function getOption(ByVal classid As String, ByVal optionid As String) As DataTable
        Dim sql As String = "SELECT DAQ_spec_options_values.OPTION_VALUE,DAQ_spec_options_values.OPTION_VALUEID, DAQ_spec_options_values.GROUP_daq FROM DAQ_spec_class " & _
           " Inner Join DAQ_spec_options ON DAQ_spec_class.CLASSID = DAQ_spec_options.CLASSID" & _
           " Inner Join DAQ_spec_options_values ON DAQ_spec_options.OPTIONID = DAQ_spec_options_values.OPTIONID" & _
           " where DAQ_spec_class.CLASSID = '" + classid + "' AND DAQ_spec_options.OPTIONID ='" + optionid + "' " & _
           " ORDER BY DAQ_spec_class.ORDER_BY ASC,DAQ_spec_options.ORDER_BY ASC,DAQ_spec_options_values.ORDER_BY ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        Return dt
    End Function
    Protected Function getOptionValueGroup(ByVal optionid As String) As DataTable
        Dim sql As String = "SELECT group_daq,group_descr FROM DAQ_spec_options_values WHERE OPTIONID =  '" + optionid + "' AND GROUP_DESCR <> ''" & _
                           " GROUP BY group_daq, group_descr,ORDER_BY ORDER BY ORDER_BY "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        Return dt
    End Function
    <System.Web.Services.WebMethod()> _
    Public Shared Function available_list_server200(ByVal str As String) As String
        HttpContext.Current.Session("q2_vid") = str
        Return "00"
    End Function
    <System.Web.Services.WebMethod()> _
    Public Shared Function available_list_server(ByVal str As String) As String   '$q_no,$oid,$vid
        Dim p() As String = Split(str, "#") : Dim qn As String = p(0) : Dim ceshi As String = ""
        If qn = "q1" Then
            Dim sqldel As String = "DELETE FROM DAQ_available_list_check WHERE sessionid = '" + HttpContext.Current.Session.SessionID + "'"
            dbUtil.dbExecuteNoQuery("MYLOCAL", sqldel)
        End If
        If qn = "q1" Then HttpContext.Current.Session("q1_vid") = p(2)
        If qn = "q3" Then HttpContext.Current.Session("q3_vid") = p(2)
        If qn = "q4" Then HttpContext.Current.Session("q4_vid") = p(2)
        Dim opt_id As String = p(1) : Dim opt_vid As String = p(2)
        Dim sql As String = "SELECT * FROM DAQ_available_list_check WHERE sessionid = '" + p(3) + "' AND q_no = '" + qn + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim sql2 As String = ""
        If dt.Rows.Count > 0 Then
            sql2 = " UPDATE DAQ_available_list_check SET q_optionid = '" + opt_id + "',q_optionvid = '" + opt_vid + "' WHERE sessionid = '" + p(3) + "' AND q_no = '" + qn + "'"
        Else
            sql2 = "INSERT INTO DAQ_available_list_check (sessionid,q_no,q_optionid,q_optionvid) values('" + p(3) + "','" + qn + "','" + opt_id + "',  '" + opt_vid + "')"
        End If
        If opt_id = "q3_3" OrElse opt_id = "q4_3" Then
        Else
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
        End If
      
        
        ''''''''''''''''''''''''
        ' dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp WHERE sessionid = '" + p(3) + "'")
        Dim sql3 As String = "SELECT q_no, q_optionid, q_optionvid FROM DAQ_available_list_check WHERE sessionid = '" + p(3) + "' ORDER BY q_no"
        Dim dt3 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql3)
        If dt3.Rows.Count > 0 Then
            For i As Integer = 0 To dt3.Rows.Count - 1
                If dt3.Rows(i).Item("q_no").ToString = "q1" Then
                    dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp where sessionid = '" + p(3) + "'")
                    Dim dt3_1 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT productid FROM DAQ_products_categories WHERE categoryid = '" + dt3.Rows(i).Item("q_optionvid").ToString + "'")
                  
                    If dt3_1.Rows.Count > 0 Then
                        For ii As Integer = 0 To dt3_1.Rows.Count - 1
                            'Dim sqlcheck As String = "select * from DAQ_available_list_tmp where sessionid='" + p(3) + "' and productid = '" + dt3_1.Rows(ii).Item("productid").ToString + "' and q_no = 'q1' "
                            'Dim dtchech As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sqlcheck)
                            'If dtchech.Rows.Count > 0 Then
                           
                            'Else
                            dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO DAQ_available_list_tmp(sessionid,productid,q_no) values( '" + p(3) + "', '" + dt3_1.Rows(ii).Item("productid").ToString + "', 'q1')")
                            'End If
                          
                        Next
                    End If
                
                End If
                
                If dt3.Rows(i).Item("q_no").ToString = "q3" Then
                    Dim q3_pid As String = search_option(dt3.Rows(i).Item("q_optionvid").ToString)
                    Dim p2() As String = Split(q3_pid, ";")
                    For j As Integer = 0 To p2.Length - 1
                                          
                        dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE DAQ_available_list_tmp SET avail = 'q3' WHERE sessionid = '" + p(3) + "' AND productid = '" + p2(j) + "'")
                    Next
                 
                End If
                
                If dt3.Rows(i).Item("q_no").ToString = "q4" Then
                    Dim q4_pid As String = search_option(dt3.Rows(i).Item("q_optionvid").ToString)
                    Dim p2() As String = Split(q4_pid, ";")
                   
                    For j As Integer = 0 To p2.Length - 1
                        dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE DAQ_available_list_tmp SET avail = 'q4' WHERE sessionid = '" + p(3) + "' AND productid = '" + p2(j) + "' AND avail = 'q3'")
                    
                    Next
                    
                    'dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp WHERE (avail <>  'q4' OR avail IS NULL ) AND sessionid =  '" + p(3) + "'")
                End If
            Next
        End If
        
        '    Dim SQL200 As String = "SELECT A.SKU, D.CATEGORY FROM DAQ_products AS A Inner Join DAQ_available_list_tmp AS B ON B.productid = A.PRODUCTID " & _
        '                             " Inner Join DAQ_products_categories AS C ON A.PRODUCTID = C.PRODUCTID Inner Join DAQ_func_categories AS D ON C.CATEGORYID = D.CATEGORYID " & _
        '                             " WHERE A.PRODUCTID =  B.productid AND B.avail =  'q4' AND B.sessionid =  '" + p(3) + "' AND C.MAIN =  '0' ORDER BY A.sku "
              
        'Dim dtceshi As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL200)
        '    If dtceshi.Rows.Count > 0 Then
        '        For J As Integer = 0 To dtceshi.Rows.Count - 1
        '            ceshi = ceshi + " <span style='font-size:11px;'>" + dtceshi.Rows(J).Item("sku") + "&nbsp;[" + dtceshi.Rows(J).Item("CATEGORY") + "]<span/><br />"
        '        Next
	      
        'End If
        ceshi = ceshi + p(3) + "<br>" + "q1_vid:" + HttpContext.Current.Session("q1_vid") + "<br>" + "q2_vid:" + HttpContext.Current.Session("q2_vid") + "<br>" + "q3_vid:" + HttpContext.Current.Session("q3_vid") + "<br>" + "q4_vid:" + HttpContext.Current.Session("q4_vid") + "<br>"
       ceshi = ceshi+"<hr>"
        Dim sql_daq_available_list_check As String = "select q_no,q_optionid,q_optionvid from DAQ_available_list_check where sessionid='" + p(3) + "'"
        Dim dtceshi As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_daq_available_list_check)
        If dtceshi.Rows.Count > 0 Then
            For J As Integer = 0 To dtceshi.Rows.Count - 1
               
                ceshi = ceshi + String.Format("<span style='font-size:11px;'>{0}--{1}--{2}</span><br>", dtceshi.Rows(J).Item("q_no").ToString, _
                                         dtceshi.Rows(J).Item("q_optionid"), dtceshi.Rows(J).Item("q_optionvid"))
                     
            Next
	      
        End If
        ''''''''
        ceshi = ceshi + "<hr>"
        Dim sql_daq_available_list_tmp As String = "select a.* , (select sku from DAQ_products where productid = a.productid) as sku from DAQ_available_list_tmp as a " & _
                                                     " where sessionid='" + p(3) + "' order by productid asc"
        Dim dtceshi2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_daq_available_list_tmp)
        If dtceshi2.Rows.Count > 0 Then
            For J As Integer = 0 To dtceshi2.Rows.Count - 1
                If Not IsDBNull(dtceshi2.Rows(J).Item("avail")) Then
                    If dtceshi2.Rows(J).Item("avail") = "q4" Then
                        ceshi = ceshi + String.Format("<span style='font-size:11px;color:#FF0000'>{0}--{1}--{2}--<b>{3}</b></span><br>", dtceshi2.Rows(J).Item("productid").ToString, _
                                        dtceshi2.Rows(J).Item("q_no"), dtceshi2.Rows(J).Item("avail"), dtceshi2.Rows(J).Item("sku"))
                    Else
                        ceshi = ceshi + String.Format("<span style='font-size:11px;'>{0}--{1}--{2}--{3}</span><br>", dtceshi2.Rows(J).Item("productid").ToString, _
                                           dtceshi2.Rows(J).Item("q_no"), dtceshi2.Rows(J).Item("avail"), dtceshi2.Rows(J).Item("sku"))
                    End If
                
                End If
              
            Next
        End If
        
        Return ceshi
    End Function
    <System.Web.Services.WebMethod()> _
    Public Shared Function del_wishlist_server(ByVal req_sessionid As String) As String
        Dim p() As String = Split(req_sessionid, ";")
        Dim sqldel As String = "DELETE FROM DAQ_wishlist_tmp WHERE seq = '" + p(0) + "' "
        dbUtil.dbExecuteNoQuery("MYLOCAL", sqldel)
        Dim sql As String = "SELECT seq, class, description,sessionid FROM DAQ_wishlist_tmp WHERE sessionid = '" + p(1) + "' order by seq asc"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim show_items As String = ""
        If dt2.Rows.Count > 0 Then
            For i As Integer = 0 To dt2.Rows.Count - 1
                If i Mod 2 = 0 Then
                    show_items += String.Format("<div class='wishlist_cell_1'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2'><a href='javascript:void(0);'><img src='./image/delete-1.png' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"))
                Else
                    show_items += String.Format("<div class='wishlist_cell_1' style='background-color:#fff;'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2' style='background-color:#fff;'><a href='javascript:void(0);'><img src='./image/delete-1.png' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"))
                End If
                                  
            Next
            
        End If
        Return show_items
    End Function
    <System.Web.Services.WebMethod()> _
    Public Shared Function check_wishlist_server(ByVal req_sessionid As String) As String
        Dim return_value As String = ""
        Dim sql As String = "SELECT *  FROM DAQ_wishlist_tmp WHERE sessionid ='" + HttpContext.Current.Session.SessionID + "'"
        
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt2.Rows.Count > 0 Then
            return_value = "have"
        Else
            return_value = "none"
        End If
        
        Return return_value
    End Function
   

    Protected Sub AIimage_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("AI", String.Format("{0};{1};{2};{3};{4}", aich.Value, air.SelectedValue, aisr.SelectedValue, aiir.SelectedValue, Request("aiir_type")))
    End Sub
    Protected Sub AIimage_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("AI", String.Format("{0};{1};{2};{3}", aich2.Value, aisr2.SelectedValue, aiir2.SelectedValue, Request("aiir_type")))
    End Sub
    Protected Sub AOimage_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("AO", String.Format("{0};{1};{2};{3}", aoch.Value, aor.SelectedValue, aoort.SelectedValue, aoorg.SelectedValue))
    End Sub
    Protected Sub AOimage2_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("AO", String.Format("{0};{1};{2}", aoch2.Value, aor2.SelectedValue, aoorg2.SelectedValue))
        ' Response.Write(aor2.SelectedValue + "\" + aoorg2.SelectedValue)
        '  Response.Write("<hr>")
    End Sub
    Protected Sub DI1image_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DI", String.Format("{0};{1}", "di_ttl", dich_ttl.Value))
    End Sub
    Protected Sub DI1image_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DI", String.Format("{0};{1}", "di_ttl", dich_ttl2.Value))
    End Sub
    Protected Sub DI2image_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DI", String.Format("{0};{1};{2};{3}", "di_isolation", dich_isolation.Value, Request("diir_min"), Request("diir_max")))
    End Sub
    Protected Sub DI2image_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DI", String.Format("{0};{1};{2};{3}", "di_isolation", dich_isolation2.Value, Request("diir_min"), Request("diir_max")))
    End Sub
    Protected Sub DO1image_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1}", "do_ttl", doch_ttl.Value))
    End Sub
    Protected Sub DO1image_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1}", "do_ttl", doch_ttl2.Value))
    End Sub
    Protected Sub DO2image_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1};{2}", "do_isolation", doch_isolation.Value, Request("door")))
    End Sub
    Protected Sub DO2image_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1};{2}", "do_isolation", doch_isolation2.Value, Request("door")))
    End Sub
    Protected Sub DO3image_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1};{2}", "do_relay", doch_relay.Value, Request("docr")))
    End Sub
    Protected Sub DO3image_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("DO", String.Format("{0};{1};{2}", "do_relay", doch_relay2.Value, Request("docr")))
    End Sub
    Protected Sub COimage_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("Counter", String.Format("{0};{1};{2}", counter_ch.Value, counter_r.SelectedValue, counter_mif.SelectedValue))
    End Sub
    Protected Sub COimage_Click2(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        add_wishlist("Counter", String.Format("{0};{1}", counter_ch2.Value, Request("counter_mif")))
    End Sub
    Protected Function getGroupValueId(ByVal optid As String, ByVal gid As String) As String
        Dim optionid As String = optid, group As String = gid, cond As String = "", valueids As String = ""
        
        ' For i As Integer = 0 To group.Length - 1
            
        ' Next
        cond = "%" + group + "%"
	
        Dim sql As String = "SELECT option_valueid FROM DAQ_spec_options_values WHERE OPTIONID =  '" + optionid + "' AND GROUP_daq like '" + cond + "'" & _
                             " ORDER BY OPTION_VALUEID ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                If dt.Rows(i)("option_valueid").ToString <> "" Then
                    valueids = valueids + dt.Rows(i)("option_valueid").ToString + ";"
                End If
            Next
        End If
        Return valueids
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
    Protected Function search_channelpids(ByVal ch_type As String, ByVal ch_num As String) As Array
        Dim ch_pids() As String = {}, ch_optionid As String = ""
        Select Case ch_type
            Case "ai" : ch_optionid = "1"
            Case "ao" : ch_optionid = "5"
            Case "di_ttl" : ch_optionid = "9"
            Case "di_isolation" : ch_optionid = "26"
            Case "do_ttl" : ch_optionid = "12"
            Case "do_isolation" : ch_optionid = "27"
            Case "do_relay" : ch_optionid = "28"
            Case "counter" : ch_optionid = "17"
        End Select
        Dim sql As String = "SELECT PRODUCTID, OPTIONID, OPTION_VALUES FROM DAQ_product_spec_values" & _
                              " WHERE OPTIONID =  '" + ch_optionid + "' ORDER BY PRODUCTID ASC"
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            ReDim ch_pids(dt.Rows.Count - 1)
            For i As Integer = 0 To dt.Rows.Count - 1
                ch_pids(i) = dt.Rows(i)("productid")
            Next
        End If
        
        Return ch_pids
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
            Dim sql As String = "SELECT * FROM DAQ_available_list_tmp WHERE sessionid = '" + sid + "' AND productid = '" + a(i) + "'"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            If dt.Rows.Count > 0 Then
                return_avail_pids = return_avail_pids + a(i) + ";"
            End If
        Next
        Return return_avail_pids
        '''''''''''''''''
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
    Protected Function getCheapProduct(ByVal pids As String, ByVal ch_type As String, ByVal ch_num As String) As Array
        Dim best_product() As String = {}, ch_optionid As String = ""
        Select Case ch_type
            Case "ai" : ch_optionid = "1,24"
            Case "ao" : ch_optionid = "5"
            Case "di_ttl" : ch_optionid = "9"
            Case "di_isolation" : ch_optionid = "26"
            Case "do_ttl" : ch_optionid = "12"
            Case "do_isolation" : ch_optionid = "27"
            Case "do_relay" : ch_optionid = "28"
            Case "counter" : ch_optionid = "17"
        End Select
        Dim dt As New DataTable
        dt.Columns.Add(New DataColumn("productid", GetType(String)))
        dt.Columns.Add(New DataColumn("sku", GetType(String)))
        dt.Columns.Add(New DataColumn("chnum", GetType(String)))
        dt.Columns.Add(New DataColumn("listprice", GetType(String)))
        dt.Columns.Add(New DataColumn("piece", GetType(String)))
        dt.Columns.Add(New DataColumn("total_price", GetType(Decimal)))
        Dim p() As String = Split(pids, ";")
        For i As Integer = 0 To p.Length - 1
            Dim sql As String = "SELECT p.PRODUCTID,  p.SKU,  c.OPTION_VALUE as 'CH_NUM',   p.LISTPRICE  FROM  DAQ_products as p " & _
                                 " Inner Join DAQ_product_spec_values as b ON p.PRODUCTID = b.PRODUCTID " & _
                                 " Inner Join DAQ_spec_options_values as c ON b.OPTION_VALUES = c.OPTION_VALUEID " & _
                                 " WHERE    b.OPTIONID in (" + ch_optionid + ") AND  p.PRODUCTID =  '" + p(i) + "' and  c.OPTION_VALUE <> '-'   ORDER BY  p.PRODUCTID ASC,c.OPTION_VALUE asc"
            
            Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            ' Response.Write(sql) : Response.Write("<hr>")
            If dt2.Rows.Count > 0 Then
                Dim dr As DataRow = dt.NewRow
                dr("productid") = dt2.Rows(0)("productid")
                dr("sku") = dt2.Rows(0)("sku")
                dr("chnum") = dt2.Rows(0)("CH_NUM")
                dr("listprice") = dt2.Rows(0)("listprice")
                Dim piece_int As Int32
                If IsNumeric(dt2.Rows(0)("CH_NUM")) Then
                    piece_int = Convert.ToInt32(dt2.Rows(0)("CH_NUM"))
                Else
                    Dim thisvalue As String = dt2.Rows(0)("CH_NUM")
                    If thisvalue.IndexOf("(") >= 0 Then
                        piece_int = Convert.ToInt32(thisvalue.ToString.Substring(0, thisvalue.ToString.IndexOf("(") - 1).Trim)
                    ElseIf thisvalue.IndexOf("x") >= 0 Then
                        piece_int = Convert.ToInt32(thisvalue.ToString.Substring(0, thisvalue.ToString.IndexOf("x") - 1).Trim)
                        
                    End If
                End If
                If Convert.ToInt32(ch_num) Mod piece_int > 0 Then
                    dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int + 1)
                Else
                    
                    dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int)
                End If
                
                dr("total_price") = Convert.ToInt32(dr("piece")) * Convert.ToInt32(dt2.Rows(0)("listprice"))
             
                dt.Rows.Add(dr)
            End If
        Next
        dt.AcceptChanges()
        'OrderUtilities.showDT(dt)
        If dt.Rows.Count > 0 Then
        
            Dim drmin() As DataRow = dt.Select("", "total_price Asc")
            best_product = {drmin(0)("productid"), drmin(0)("piece"), drmin(0)("total_price")}
       
            '$best_product = array('pid'=>$best_productid,'piece'=>$best_piece); 
            'Response.Write(drmin(0)("productid"))
        Else
            best_product = {"0", "0", "0"}
        End If
        Return best_product
    End Function
        
    Protected Sub add_wishlist(ByVal para1 As String, ByVal para2 As String)
        dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp WHERE (avail <>  'q4' OR avail IS NULL ) AND sessionid =  '" + Session.SessionID + "'")
       
        Dim strArr() As String = Split(para2, ";")
        Dim str As String = "<br>" + para1 + "<br>"
        For i As Integer = 0 To strArr.Length - 1
            str = str + strArr(i) + "<br>"
        Next
        ' test.Text = para1 + "|" + para2
      
        If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
           
            Select Case para1
                Case "AI"
                   
                    Dim ch_type As String = "ai", ch_num As String = strArr(0)
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim air() As String = Split(strArr(1), "^")
                    Dim air_optionid = air(0), air_optvalueid As String = air(1), air_value As String = air(2)
                        
                    Dim aisr() As String = Split(strArr(2), "^")
                    Dim aisr_optionid As String = aisr(0), aisr_optvalueid As String = aisr(1)
                    Dim aisr_valueids As String = getGroupValueId(aisr_optionid, aisr_optvalueid)
                    Dim aisr_value = aisr(2)
                                   
                    Dim aiir() As String = Split(strArr(3), "^")
                    Dim aiir_optionid As String = aiir(0)
                    Dim aiir_optvalueid As String = aiir(1)
                    Dim aiir_valueids As String = "" 'getGroupValueId(aiir_optionid, aiir_optvalueid)
                    Dim aiir_value As String = aiir(2)
                    Dim aiir_type() As String : Dim aiir_typeoptionid As String : Dim aiir_typeoptionvalueid As String = "" : Dim aiir_typevalue As String = ""
                    If aiir_value = "Temperature" Then
                        aiir_type = Split(strArr(4), "^")
                        aiir_typeoptionid = aiir_type(0)
                        aiir_typeoptionvalueid = aiir_type(1)
                        aiir_typevalue = aiir_type(2)
                    Else
                        aiir_valueids = getGroupValueId(aiir_optionid, aiir_optvalueid)
                    End If
                    'insert new item into tmp table

                    Dim tmp_optionvalueid As String = air_optvalueid + "|" + aisr_valueids + "|" + aiir_valueids + "|" + aiir_typeoptionvalueid
                    Dim tmp_list As String = ch_num + ",&nbsp;ch,&nbsp;" + air_value + ",&nbsp;bits;&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + ",&nbsp;" + aiir_typevalue
                    'Dim productids As String = search_wishlist(Session.SessionID, ch_type, ch_num, tmp_optionvalueid)
                    Dim aiir_pids_or_typepids As String = "", intersect_pids As String = ""
                    ''''''''''''''''''''''
                    Dim aich_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                    If aich_pids = "" Or aich_pids = ";" Then aich_pids = "0"
                    Dim air_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, air_optvalueid)
                    If air_pids = "" Or air_pids = ";" Then air_pids = "0"
                    Dim aisr_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aisr_valueids)
                    If aisr_pids = "" Or aisr_pids = ";" Then aisr_pids = "0"
                    If aiir_value <> "Temperature" Then
                        aiir_pids_or_typepids = search_wishlist(Session.SessionID, ch_type, ch_num, aiir_valueids)
                    Else
                        aiir_pids_or_typepids = search_wishlist(Session.SessionID, ch_type, ch_num, aiir_typeoptionvalueid)
                    End If
                    If aiir_pids_or_typepids = "" Or aiir_pids_or_typepids = ";" Then aiir_pids_or_typepids = "0"
                    intersect_pids = intersect_array(intersect_array(air_pids, aisr_pids), intersect_array(aiir_pids_or_typepids, aich_pids))
                                  
                    ''''
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                   
                Case "AO"
                    Dim aor() As String = Split(strArr(1), "^")
                    Dim aor_optionid As String = aor(0)
                    Dim aor_optvalueid As String = aor(1)
                    Dim aor_value As String = aor(2)
                    Dim aoort() As String = Split(strArr(2), "^")
                    Dim aoort_optionid As String = aoort(0)
                    Dim aoort_optvalueid As String = aoort(1)
                    Dim aoort_value As String = aoort(2)
                    Dim aoorg() As String = Split(strArr(3), "^")
                    Dim aoorg_optionid As String = aoorg(0)
                    Dim aoorg_optvalueid As String = aoorg(1)
                    Dim aoorg_valueids As String = getGroupValueId(aoorg_optionid, aoorg_optvalueid)
                    Dim aoorg_value As String = aoorg(2)
                    Dim ch_type As String = "ao"
                    Dim ch_num As String = strArr(0)
                    
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim tmp_optionvalueid As String = aor_optvalueid + "|" + aoort_optvalueid + "|" + aoorg_valueids
                    Dim tmp_list As String = ch_num + "&nbsp;ch,&nbsp;" + aor_value + "&nbsp;bits,&nbsp;" + aoort_value + "&nbsp;,&nbsp;" + aoorg_value
                    Dim aoch_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                    If aoch_pids = "" Or aoch_pids = ";" Then aoch_pids = "0"
                    Dim aor_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aor_optvalueid)
                    If aor_pids = "" Or aor_pids = ";" Then aor_pids = "0"
                    Dim aoort_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aoort_optvalueid)
                    If aoort_pids = "" Or aoort_pids = ";" Then aoort_pids = "0"
                    Dim aoorg_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aoorg_valueids)
                    If aoorg_pids = "" Or aoorg_pids = ";" Then aoorg_pids = "0"
                    
                    Dim intersect_pids As String = intersect_array(intersect_array(aor_pids, aoort_pids), intersect_array(aoorg_pids, aoch_pids))
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, best_pid, best_piece)
                    End If
                    ' Response.Write(sql00)
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                Case "DI"
                    Dim ch_type As String = strArr(0) : Dim optionvalueid As String = ""
                    Dim ch_num As String = strArr(1) : Dim description As String, productids As String
                    If ch_type = "di_isolation" Then
                        Dim diiv_min As String = strArr(2)
                        Dim diiv_max As String = strArr(3)
                        Dim iv_range As String = diiv_min + "," + diiv_max
                        description = ch_num + "&nbsp;Isolation&nbsp;ch,&nbsp;" + diiv_min + "~" + diiv_max + "V<sub>DC</sub>"
                        Select Case iv_range
                            Case "5,12" : optionvalueid = "136;"
                            Case "5,24" : optionvalueid = "136;137"
                            Case "5,30" : optionvalueid = "136;137;135;65"
                            Case "5,50" : optionvalueid = "136;137;135;65;100"
                            Case "10,12" : optionvalueid = "136;"
                            Case "10,24" : optionvalueid = "136;137"
                            Case "10,30" : optionvalueid = "136;137;135;65"
                            Case "10,50" : optionvalueid = "136;137;135;65;100;70"
                        End Select
                    End If
                    Dim ch_valueids As String = getOptionVidByChType(ch_type) : Dim dich_pids As String = "", intersect_pids As String = "", di_iso_pids As String = ""
                    Dim di_iv_pids As String = ""
                    ' Response.Write(ch_valueids):Response.Write("<hr>")
                    Select Case ch_type
                        Case "di_ttl"
                            description = ch_num + "&nbsp;TTL&nbsp;ch"
                            optionvalueid = ch_valueids
                            dich_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                            If dich_pids = "" Or dich_pids = ";" Then dich_pids = "0"
                            intersect_pids = dich_pids
                                                       
                        Case "di_isolation"
                            optionvalueid = ch_valueids
                            di_iso_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                            If di_iso_pids = "" Or di_iso_pids = ";" Then di_iso_pids = "0"
                            di_iv_pids = search_wishlist(Session.SessionID, ch_type, ch_num, optionvalueid)
                            If di_iv_pids = "" Or di_iv_pids = ";" Then di_iv_pids = "0"
                            intersect_pids = intersect_array(di_iso_pids, di_iv_pids)

                    End Select
                    
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                    ' Response.Write(sql00)
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                Case "DO"
                    Dim ch_type As String = strArr(0) : Dim description As String = "" : Dim optionvalueid As String = ""
                    Dim ch_num As String = strArr(1) : Dim door_optionid As String = "", door_optvalueid As String = "", door_value As String = ""
                    Dim docr_optionid As String = "", docr_optvalueid As String = "", docr_value As String = "", productids As String = ""
                                  
                    Dim ch_valueids As String = getOptionVidByChType(ch_type) : Dim intersect_pids As String = "", do_pids As String = "", door_pids As String = ""
                    Dim docr_pids As String = ""
                    Select Case ch_type
                        Case "do_ttl"
                            description = ch_num + "&nbsp;TTL&nbsp;ch,&nbsp;"
                            optionvalueid = ch_valueids
                            intersect_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                            If intersect_pids = "" Or intersect_pids = ";" Then intersect_pids = "0"
                            
                        Case "do_isolation"
                            Dim door() As String = Split(strArr(2), "^")
                            door_optionid = door(0)
                            door_optvalueid = door(1)
                            door_value = door(2)
                            optionvalueid = door_optvalueid
                            
                            do_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                            If do_pids = "" Or do_pids = ";" Then do_pids = "0"
                            door_pids = search_wishlist(Session.SessionID, ch_type, ch_num, door_optvalueid)
                            If door_pids = "" Or door_pids = ";" Then door_pids = "0"
                            intersect_pids = intersect_array(do_pids, door_pids)
                            description = ch_num + "&nbsp;Isolation&nbsp;ch,&nbsp;" + door_value + "&nbspV<sub>DC</sub>"
                        Case "do_relay"
                            Dim docr() As String = Split(strArr(2), "^")
                            docr_optionid = docr(0)
                            docr_optvalueid = docr(1)
                            docr_value = docr(2)
                            optionvalueid = docr_optvalueid
                           
                            do_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                            If do_pids = "" Or do_pids = ";" Then do_pids = "0"
                            docr_pids = search_wishlist(Session.SessionID, ch_type, ch_num, docr_optvalueid)
                            If docr_pids = "" Or docr_pids = ";" Then docr_pids = "0"
                            intersect_pids = intersect_array(do_pids, docr_pids)
                            description = ch_num + "&nbsp;Relay&nbsp;ch,&nbsp;" + docr_value + "&nbsp;"
                    End Select
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                   
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                    
                Case "Counter"
                    Dim ch_type As String = "counter"
                    Dim ch_num As String = strArr(0)
                    
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    
                    
                    Dim counter_r() As String = Split(strArr(1), "^")
                    Dim counter_r_optionid As String = counter_r(0)
                    Dim counter_r_optvalueid As String = counter_r(1)
                    Dim counter_r_value As String = counter_r(2)
						
                        
                     
                    
                    Dim counter_mif() As String = Split(strArr(1), "^")
                    Dim counter_mif_optionid As String = counter_mif(0)
                    Dim counter_mif_optvalueid As String = counter_mif(1)
                    Dim counter_mif_value As String = counter_mif(2)
                               
                    
                    Dim counter_ch_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids)
                    If counter_ch_pids = "" Or counter_ch_pids = ";" Then counter_ch_pids = "0"
                       
                    Dim optionvalueid As String = counter_r_optvalueid + "|" + counter_mif_optvalueid
                    Dim description As String = ch_num + "&nbsp;" + ch_type + "&nbsp;ch,&nbsp;" + counter_r_value + "&nbsp;bits,&nbsp;" + counter_mif_value
						
                    Dim r_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, counter_r_optvalueid)
                    If r_pids = "" Or r_pids = ";" Then r_pids = "0"
                    
                    Dim mif_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, counter_mif_optvalueid)
                    If mif_pids = "" Or mif_pids = ";" Then mif_pids = "0"
                    Dim intersect_pids As String = intersect_array(intersect_array(r_pids, mif_pids), counter_ch_pids)
                    
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                    ' Response.Write(sql00)
                                                          
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
            End Select
                
                
                
            
        Else
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
            Select Case para1
                
                Case "AI"
                    Dim ch_type As String = "ai"
                    Dim ch_num As String = strArr(0)
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim aisr() As String = Split(strArr(1), "^")
                    Dim aisr_optionid As String = aisr(0)
                    Dim aisr_optvalueid As String = aisr(1)
                    Dim aisr_value As String = aisr(2)
                    Dim aiir() As String = Split(strArr(2), "^")
                    Dim aiir_optionid As String = aiir(0)
                    Dim aiir_optvalueid As String = aiir(1)
                    Dim aiir_value As String = aiir(2)
                    Dim aiir_valueids As String = ""
                    Dim aiir_type() As String, aiir_typeoptionid As String = "", aiir_typeoptionvalueid As String = "", aiir_typevalue As String = ""
                    If aiir_value = "Temperature" Then
                        aiir_type = Split(strArr(3), "^")
                        aiir_typeoptionid = aiir_type(0)
                        aiir_typeoptionvalueid = aiir_type(1)
                        aiir_typevalue = aiir_type(2)
                    Else
                        aiir_valueids = getGroupValueId(aiir_optionid, aiir_optvalueid)
                    End If
                    Dim air_value As String = ""
                    Dim tmp_optionvalueid As String = aisr_optvalueid + "|" + aiir_valueids + "|" + aiir_typeoptionvalueid
                    Dim tmp_list As String = strArr(0) + "&nbsp;ch,&nbsp;" + air_value + "&nbsp;bits;&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + ",&nbsp;" + aiir_typevalue
                    Dim aich_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If aich_pids = "" Or aich_pids = ";" Then aich_pids = "0"
                   
                    Dim aisr_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aisr_optvalueid) : If aisr_pids = "" Or aisr_pids = ";" Then aisr_pids = "0"
                    Dim intersect_pids As String = ""
                    If aiir_value <> "Temperature" Then
                        Dim aiir_pids = search_wishlist(Session.SessionID, ch_type, ch_num, aiir_valueids) : If aiir_pids = "" Or aiir_pids = ";" Then aiir_pids = "0"
                        intersect_pids = intersect_array(intersect_array(aisr_pids, aiir_pids), aich_pids)
                    Else
                        Dim aiir_typepids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aiir_typeoptionvalueid) : If aiir_typepids = "" Or aiir_typepids = ";" Then aiir_typepids = "0"
                        intersect_pids = intersect_array(intersect_array(aisr_pids, aiir_typepids), aich_pids)
                    End If
                 
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                Case "AO"
                    
                    Dim ch_type As String = "ao"
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim aor() As String = Split(strArr(1), "^")
                    Dim aor_optionid As String = aor(0)
                    Dim aor_optvalueid = aor(1)
                    Dim aor_value = aor(2)
                    Dim aoorg() As String = Split(strArr(2), "^")
                    Dim aoorg_optionid As String = aoorg(0)
                    Dim aoorg_optvalueid As String = aoorg(1)
                    Dim aoorg_valueids As String = getGroupValueId(aoorg_optionid, aoorg_optvalueid)
                    Dim aoorg_value As String = aoorg(2)
                    Dim ch_num As String = strArr(0)
                    Dim aoort_opetvalueid As String = ""
                    Dim tmp_optionvalueid As String = aor_optvalueid + ";" + aoort_opetvalueid + ";" + aoorg_valueids
                    Dim aoort_value As String = ""
                    Dim tmp_list As String = ch_num + "&nbsp;ch,&nbsp;" + aor_value + "&nbsp;bits,&nbsp;" + aoort_value + "&nbsp;,&nbsp;" + aoorg_value
                    
                    Dim aoch_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If aoch_pids = "" Or aoch_pids = ";" Then aoch_pids = "0"
                    Dim aor_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aor_optvalueid) : If aor_pids = "" Or aor_pids = ";" Then aor_pids = "0"
                    Dim aoorg_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, aoorg_valueids) : If aoorg_pids = "" Or aoorg_pids = ";" Then aoorg_pids = "0"
						
                    Dim intersect_pids As String = intersect_array(intersect_array(aoch_pids, aor_pids), aoorg_pids)
                    
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                    
                    
                Case "DI"
                    Dim ch_type As String = strArr(0)
                    Dim ch_num As String = strArr(1) : Dim description As String = "" : Dim optionvalueid As String = "", intersect_pids As String = ""
                    If ch_type = "di_isolation" Then
                        Dim diiv_min As String = strArr(2)
                        Dim diiv_max As String = strArr(3)
                        Dim iv_range As String = diiv_min + "," + diiv_max
                        description = ch_num + "&nbsp;Isolation&nbsp;ch,&nbsp;" + diiv_min + "~" + diiv_max + " V<sub>DC</sub>"
                       
                        Select Case iv_range
                            Case "5,12" : optionvalueid = "136;"
                            Case "5,24" : optionvalueid = "136;137"
                            Case "5,30" : optionvalueid = "136;137;135;65"
                            Case "5,50" : optionvalueid = "136;137;135;65;100"
                            Case "10,12" : optionvalueid = "136;"
                            Case "10,24" : optionvalueid = "136;137"
                            Case "10,30" : optionvalueid = "136;137;135;65"
                            Case "10,50" : optionvalueid = "136;137;135;65;100;70"
                        End Select
                    End If
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Select Case ch_type
                        Case "di_ttl"
                            description = ch_num + "&nbsp;TTL&nbsp;ch"
                            optionvalueid = ch_valueids
                            Dim dich_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If dich_pids = "" Or dich_pids = ";" Then dich_pids = "0"
                            intersect_pids = dich_pids
                        Case "di_isolation"
                            optionvalueid = ch_valueids
                            Dim di_iso_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If di_iso_pids = "" Or di_iso_pids = ";" Then di_iso_pids = "0"
                            Dim di_iv_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, optionvalueid) : If di_iv_pids = "" Or di_iv_pids = ";" Then di_iv_pids = "0"
                            intersect_pids = intersect_array(di_iso_pids, di_iv_pids)
                    End Select
                    
                            
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                Case "DO"
                    Dim ch_type As String = strArr(0)
                    Dim ch_num As String = strArr(1)
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim description As String = "", optionvalueid As String = "", intersect_pids As String = ""
                    Select Case ch_type
                        Case "do_ttl"
                            description = ch_num + "&nbsp;TTL&nbsp;ch,&nbsp;"
                            optionvalueid = ch_valueids
                            intersect_pids = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If intersect_pids = "" Or intersect_pids = ";" Then intersect_pids = "0"
                    
                        Case "do_isolation"
                            Dim door() As String = Split(strArr(2), "^")
                            Dim door_optionid As String = door(0)
                            Dim door_optvalueid As String = door(1)
                            Dim door_value As String = door(2)
                            optionvalueid = door_optvalueid
                            Dim do_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If do_pids = "" Or do_pids = ";" Then do_pids = "0"
                            Dim door_pids = search_wishlist(Session.SessionID, ch_type, ch_num, door_optvalueid) : If door_pids = "" Or door_pids = ";" Then door_pids = "0"
                            intersect_pids = intersect_array(do_pids, door_pids)
                            description = ch_num + "&nbsp;Isolation&nbsp;ch,&nbsp;" + door_value + "&nbspV<sub>DC</sub>"
                        Case "do_relay"
                            Dim docr() As String = Split(strArr(2), "^")
                            Dim docr_optionid As String = docr(0)
                            Dim docr_optvalueid As String = docr(1)
                            Dim docr_value As String = docr(2)
                            optionvalueid = docr_optvalueid
                            Dim do_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If do_pids = "" Or do_pids = ";" Then do_pids = "0"
                            Dim docr_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, docr_optvalueid) : If docr_pids = "" Or docr_pids = ";" Then docr_pids = "0"
								
                            intersect_pids = intersect_array(do_pids, docr_pids)
                            description = ch_num + "&nbsp;Relay&nbsp;ch,&nbsp;" + docr_value + "&nbsp;"
                    End Select
                        
                    
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
								
                Case "Counter"
                    
                    Dim ch_type As String = "counter"
                    Dim ch_num As String = strArr(0)
                    Dim ch_valueids As String = getOptionVidByChType(ch_type)
                    Dim counter_mif() As String = Split(strArr(1), "^")
                    Dim counter_mif_optionid As String = counter_mif(0)
                    Dim counter_mif_optvalueid As String = counter_mif(1)
                    Dim counter_mif_value As String = counter_mif(2)
                    Dim counter_mif_valueids As String = getGroupValueId(counter_mif_optionid, counter_mif_optvalueid)
                    Dim optionvalueid As String = ch_valueids + "|" + counter_mif_valueids
                    Dim counter_r_value As String = ""
                    Dim description As String = ch_num + "&nbsp;" + ch_type + "&nbsp;ch,&nbsp;" + counter_r_value + "&nbsp;bits,&nbsp;" + counter_mif_value
                    Dim counter_ch_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, ch_valueids) : If counter_ch_pids = "" Or counter_ch_pids = ";" Then counter_ch_pids = "0"
                    Dim mif_pids As String = search_wishlist(Session.SessionID, ch_type, ch_num, counter_mif_valueids) : If mif_pids = "" Or mif_pids = ";" Then mif_pids = "0"
                    Dim intersect_pids As String = intersect_array(mif_pids, counter_ch_pids)
                    
                    Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                    If intersect_pids <> "" AndAlso intersect_pids <> ";" Then
                        best_p = getCheapProduct(intersect_pids, ch_type, ch_num)
                        best_pid = best_p(0)
                        best_piece = best_p(1)
                    
                    End If
                    Dim sql00 As String = ""
                    If best_pid = "0" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, best_pid, best_piece)
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
            End Select
            
            
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
        End If
        
        'get list from DB
        Dim sql As String = "SELECT * FROM DAQ_wishlist_tmp WHERE sessionid = '" + Session.SessionID + "' order by seq asc;"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim show_items As String = "" : Dim ceshi As String = "<hr>"
        If dt2.Rows.Count > 0 Then
            For i As Integer = 0 To dt2.Rows.Count - 1
                If i Mod 2 = 0 Then
                    show_items += String.Format("<div class='wishlist_cell_1'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2'><a href='javascript:void(0);'><img src='./image/delete-1.png' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"))
                Else
                    show_items += String.Format("<div class='wishlist_cell_1' style='background-color:#fff;'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2' style='background-color:#fff;'><a href='javascript:void(0);'><img src='./image/delete-1.png' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"))
                End If
                ceshi = ceshi + String.Format("<b>{0}</b>&nbsp;{1}&nbsp;<b><font color='#FF0000'>[{2}]</font></b>&nbsp;&nbsp;<font color='#FF0000'>({3})</font><br>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("productids").ToString, dt2.Rows(i).Item("piece").ToString)
            Next
            
        End If
        Me.wishlist.InnerHtml = show_items
        ''''''''''''''''''''''test yong
        ''''
      
        test.Text = ceshi
        '''''''''''''''''''''''''''''test yong end
    End Sub
    Protected Function getmaxreq() As Int32
        Dim maxseq As String = dbUtil.dbExecuteScalar("MYLOCAL", "select max(seq) from DAQ_wishlist_tmp")
        Dim numseq As Int32 = Convert.ToInt32(maxseq) + 1
        Return numseq
    End Function
        
    Protected Sub di_channel_type_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If di_channel_type.SelectedValue = "di_channel_ttl" Then
            dich_ttl_TR.Visible = True : DI1image_TR.Visible = True : dich_isolation_TR.Visible = False : sm_TR.Visible = False : HTML_TR.Visible = False : DI2image_TR.Visible = False
           
        End If
        If di_channel_type.SelectedValue = "di_channel_isolation" Then
            DI2image_TR.Visible = True : dich_isolation_TR.Visible = True : sm_TR.Visible = True : HTML_TR.Visible = True : dich_ttl_TR.Visible = False : DI1image_TR.Visible = False
            Dim STR_MIN As String = "", STR_MAX As String = ""
          
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                STR_MIN = "Min.:<select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = "Max:<select name='diir_max' id='diir_max'><option value ='12'>12</option><option value ='24'>24</option><option value ='30'>30</option><option value ='50' >50</option>	</select>"
            End If
            If RB1.SelectedValue = "2" Then
                STR_MIN = "Min.:<select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = "Max:<select name='diir_max' id='diir_max'><option value ='30'>30</option><option value ='50' >50</option></select>"
            End If
            HTML_TD.InnerHtml = STR_MIN + "<BR>" + STR_MAX
        End If
  
    End Sub
    Protected Sub di_channel_type2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If di_channel_type2.SelectedValue = "di_channel_ttl" Then
            dich_ttl_TR2.Visible = True : DI1image_TR2.Visible = True : dich_isolation_TR2.Visible = False : sm_TR2.Visible = False : HTML_TR2.Visible = False : DI2image_TR2.Visible = False
           
        End If
        If di_channel_type2.SelectedValue = "di_channel_isolation" Then
            DI2image_TR2.Visible = True : dich_isolation_TR2.Visible = True : sm_TR2.Visible = True : HTML_TR2.Visible = True : dich_ttl_TR2.Visible = False : DI1image_TR2.Visible = False
            Dim STR_MIN As String = "", STR_MAX As String = ""
          
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                STR_MIN = "Min.:<select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = "Max:<select name='diir_max' id='diir_max'><option value ='12'>12</option><option value ='24'>24</option><option value ='30'>30</option><option value ='50' >50</option>	</select>"
            End If
            If RB1.SelectedValue = "2" Then
                STR_MIN = "Min.:<select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = "Max:<select name='diir_max' id='diir_max'><option value ='30'>30</option><option value ='50' >50</option></select>"
            End If
            HTML_TD2.InnerHtml = STR_MIN + "<BR>" + STR_MAX
        End If
  
    End Sub
    Protected Sub do_channel_type_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        si_1_1.Visible = False : si_1_2.Visible = False
        si_2_1.Visible = False : si_2_2.Visible = False : si_2_3.Visible = False
        si_3_1.Visible = False : si_3_2.Visible = False : si_3_3.Visible = False : Dim or_option As String = "" : Dim cr_option As String = ""
        If do_channel_type.SelectedValue = "do_channel_ttl" Then
            si_1_1.Visible = True : si_1_2.Visible = True
        End If
        If do_channel_type.SelectedValue = "do_channel_isolation" Then
            si_2_1.Visible = True : si_2_2.Visible = True : si_2_3.Visible = True
            Dim sql As String = "SELECT OPTIONID, OPTION_VALUE, OPTION_VALUEID FROM DAQ_spec_options_values WHERE OPTIONID =  '14' AND  option_value <> '-' ORDER BY ORDER_BY ASC"
            or_option = getOption(sql)
            si_2_2TD.InnerHtml = "Output Range (V):<select name ='door' ID='door'>" + or_option + "</select><br><br><br><br>"
        End If
        If do_channel_type.SelectedValue = "do_channel_relay" Then
            si_3_1.Visible = True : si_3_2.Visible = True : si_3_3.Visible = True
            Dim sql As String = ""
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                sql = "SELECT OPTIONID, OPTION_VALUEID, OPTION_VALUE FROM DAQ_spec_options_values WHERE OPTIONID =  '16' AND OPTION_VALUE <>  '-' ORDER BY ORDER_BY ASC"
            ElseIf RB1.SelectedValue = "2" Then
                sql = "SELECT OPTIONID, OPTION_VALUEID, OPTION_VALUE  FROM DAQ_spec_options_values WHERE OPTIONID =  '16' AND OPTION_VALUE <>  '-' AND OPTION_VALUEID <>  '166' " & _
                    "AND OPTION_VALUEID <>  '167'  AND 	OPTION_VALUEID <>  '168'  AND OPTION_VALUEID <>  '227' GROUP BY OPTION_VALUE ,OPTION_VALUEID ,OPTIONID,ORDER_BY ORDER BY  ORDER_BY ASC"
            End If
            cr_option = getOption(sql)
            si_3_2TD.InnerHtml = "Contact Rating:<br /><select name ='docr' id='docr'>" + cr_option + "</select><br><br><br>"
        End If
    End Sub
    Protected Sub do_channel_type2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        si_1_12.Visible = False : si_1_22.Visible = False
        si_2_12.Visible = False : si_2_22.Visible = False : si_2_32.Visible = False
        si_3_12.Visible = False : si_3_22.Visible = False : si_3_32.Visible = False : Dim or_option As String = "" : Dim cr_option As String = ""
        If do_channel_type2.SelectedValue = "do_channel_ttl" Then
            si_1_12.Visible = True : si_1_22.Visible = True
        End If
        If do_channel_type2.SelectedValue = "do_channel_isolation" Then
            si_2_12.Visible = True : si_2_22.Visible = True : si_2_32.Visible = True
            Dim sql As String = "SELECT OPTIONID, OPTION_VALUE, OPTION_VALUEID FROM DAQ_spec_options_values WHERE OPTIONID =  '14' AND  option_value <> '-' ORDER BY ORDER_BY ASC"
            or_option = getOption(sql)
            si_2_2TD2.InnerHtml = "Output Range (V):<select name ='door' ID='door'>" + or_option + "</select><br><br><br><br>"
        End If
        If do_channel_type2.SelectedValue = "do_channel_relay" Then
            si_3_12.Visible = True : si_3_22.Visible = True : si_3_32.Visible = True
            Dim sql As String = ""
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                sql = "SELECT OPTIONID, OPTION_VALUEID, OPTION_VALUE FROM DAQ_spec_options_values WHERE OPTIONID =  '16' AND OPTION_VALUE <>  '-' ORDER BY ORDER_BY ASC"
            ElseIf RB1.SelectedValue = "2" Then
                sql = "SELECT OPTIONID, OPTION_VALUEID, OPTION_VALUE  FROM DAQ_spec_options_values WHERE OPTIONID =  '16' AND OPTION_VALUE <>  '-' AND OPTION_VALUEID <>  '166' " & _
                    "AND OPTION_VALUEID <>  '167'  AND 	OPTION_VALUEID <>  '168'  AND OPTION_VALUEID <>  '227' GROUP BY OPTION_VALUE ,OPTION_VALUEID ,OPTIONID,ORDER_BY ORDER BY  ORDER_BY ASC"
            End If
            cr_option = getOption(sql)
            si_3_2TD2.InnerHtml = "Contact Rating:<br /><select name ='docr' id='docr'>" + cr_option + "</select><br><br><br>"
        End If
    End Sub
    Protected Function getoption(ByVal sql As String) As String
        Dim options As String = ""
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                options += String.Format("<option value='{0}^{1}^{2}'>{2}</option>", dt.Rows(i)("optionid").ToString, dt.Rows(i)("option_valueid").ToString, dt.Rows(i)("option_value").ToString)
            Next
        End If
        Return options
    End Function

    Protected Sub SEARCH_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim sql As String = "", max_no As String = "200"
        Dim obj As Object = Nothing
        obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT MAX(no)+ 1  as max_no FROM DAQ_stats_questions")
        If obj IsNot Nothing Then
            max_no = obj.ToString()
        Else
            max_no = "200"
        End If
        If RB1.SelectedValue = "1" Then
            Dim avail_bus As String = Request("q3")
            Dim os As String = Request("q4")
            sql = "INSERT INTO DAQ_stats_questions (no,sessionid ,daq_type,platform,other_platform,avail_bus,os,timestamp,user_id) values ( " & _
                " " + max_no + ",'" + Session.SessionID + "','" + RB1.SelectedValue + "','" + RB2.SelectedValue + "',N'" + Request("q2_o").ToString.Replace("'", "''") + "','" + avail_bus + "','" + os + "','" + System.DateTime.Now + "','" + Session("user_id").ToString.Trim + "') "
        ElseIf RB1.SelectedValue = "2" Then
            Dim prefer_interface As String = Request("q3")
            Dim prefer_interface_oth As String = Request("q5_o").ToString.Replace("'", "''")
            Dim protocal As String = Request("q4")
            Dim protocal_oth As String = Request("q6_o").ToString.Replace("'", "''")
            sql = "INSERT INTO DAQ_stats_questions  (no,sessionid,daq_type,platform,other_platform,prefer_interface, other_prefer_interface,protocal,other_protocal,timestamp,user_id) values (" & _
                  "  " + max_no + ",'" + Session.SessionID + "', '" + RB1.SelectedValue + "','" + RB2.SelectedValue.Replace("'", "''") + "',N'" + Request("q2_o").ToString.Replace("'", "''") + "','" + prefer_interface + "',N'" + prefer_interface_oth + "', '" + protocal + "', N'" + protocal_oth + "','" + System.DateTime.Now + "','" + Session("user_id").ToString.Trim + "') "
           
        End If
        
        Try
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        Catch ex As Exception
           
            Exit Sub
        End Try
        Session("q2_vid") = RB2.SelectedValue
        Response.Redirect("search.aspx")
    
     
        
    End Sub

    Protected Sub clear_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Call clean_session_data("DAQ_available_list_check")
        Call clean_session_data("DAQ_available_list_tmp")
        Call clean_session_data("DAQ_wishlist_tmp")
        Session("q1_vid") = ""
        Session("q2_vid") = ""
        Session("q3_vid") = ""
        Session("q4_vid") = ""
        Response.Redirect("filter.aspx")
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="css.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function xajax_available_list(q_no, o_id,v_id,sessionid) {
            var arrID = "";
          //  alert("kaishi");
            PageMethods.available_list_server(q_no + "#" + o_id + "#" + v_id + "#" + sessionid, OnPageMethods_1Succeeded, OnGetPriceError, arrID);
        }
        function OnPageMethods_1Succeeded(result, arrID, methodName) {
            document.getElementById('<%=av.ClientID %>').innerHTML = result;
            return true;
        }
        function OnGetPriceError(error, arrID, methodName) {
            if (error !== null) {
                if (error !== null) {
                    document.getElementById('bb').innerHTML = error.get_message();
                   // alert(error.get_message());
                }
            }
        }
        //////////////////////////////////////////////2
        function xajax_available_list2(itemvalue) {
            var arrID = "";
            //alert(itemvalue);
            PageMethods.available_list_server200(itemvalue, OnPageMethods_1Succeeded200, OnGetPriceError200, arrID);
        }
        function OnPageMethods_1Succeeded200(result, arrID, methodName) {
           
            return true;
        }
        function OnGetPriceError200(error, arrID, methodName) {
            if (error !== null) {
                if (error !== null) {
                  
                    alert(error.get_message());
                }
            }
        }
        //////////////////////////////////////////
        function aiirselectChange(objid, id) {
            var obj = document.getElementById(objid);
            if (obj.value == "aiir_t^aiir_t^Temperature") {

                var str = "Type :<br>";
                str += "<select name='aiir_type' id='aiir_type'>";
                str += "<option value='4^207^Thermocouple'>Thermocouple</option>";
                str += "<option value='4^271^RTD'>RTD</option>";
                str += "<option value='4^272^Thermistor'>Thermistor</option>";
                str += "</select>";
                document.getElementById(id).innerHTML = str;
                //  alert(str);
            }
            else {

                document.getElementById(id).innerHTML = "";
            }

        }

    </script>
 
<table  style="margin-left:20px;" width="890" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="42" ></td>  <td class="daq_title_para">
    <table  width="848" border="0" cellpadding="0" cellspacing="0"><tr><td>  <div class="title_para" style="margin-left:0px; color:red; font-size:16px;"><b>Please answer the questions in order.</b></div></td> 
    <td><asp:ImageButton runat="server" ImageAlign="Right"  ID="clear_all"  ImageUrl="./image/clearall.gif" onclick="clear_Click" /> </td></tr></table>   
    </td>
  </tr>
  <!------------------  Questin 1 ------------------>
  <tr>
    <td align="center" width="42"  background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para" ><div style="margin-left:9px;">Q1</div></td>  
   <td width="820" height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg">How Do You Want The Data Acquisition Modules To Integrate  with Your System ?</strong></td>
  </tr>
  <tr>
    <td></td>  
    <td class="daq_text">
        <asp:RadioButtonList id="RB1" runat="server" AutoPostBack="true"  onselectedindexchanged="RB1_SelectedIndexChanged"  >
            <asp:ListItem  Value="1" > Plug-in Data Acquisition Cards</asp:ListItem>
            <asp:ListItem Value="2"> Remote Data Acquisition Modules</asp:ListItem>
        </asp:RadioButtonList>
    </td>
  </tr>
  <!------------------  Questin 1 ------------------>
   <!------------------  Questin 2 ------------------>
  <tr>

    <td align="center" background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para"><div style="margin-left:9px;">Q2</div></td> 
    <td  height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong>Preferred Platform Info ?</strong></td>
  </tr>
  <tr>
    <td></td>  
    <td>
    <asp:RadioButtonList id="RB2" runat="server" AutoPostBack="false"  RepeatColumns="3"  RepeatDirection="Horizontal" Width="90%">       
             <asp:ListItem Value="1" >Single Board Computer </asp:ListItem>
             <asp:ListItem  Value="2">Motherboard </asp:ListItem>
              <asp:ListItem Value="3"> Box PC</asp:ListItem>
              <asp:ListItem Value="4"> Panel PC</asp:ListItem>
              <asp:ListItem Value="5"> Computer On Module</asp:ListItem>
              <asp:ListItem Value="6"> No Preference</asp:ListItem>
              <asp:ListItem Value="7"> others <input type="text" name="q2_o" id="q2_o" > </asp:ListItem>          
        </asp:RadioButtonList>
    </td>
  </tr>
  <!------------------  Questin 2 ------------------>
    <!------------------  Questin 3 ------------------>
   <tr>
    <td align="center" background="./image/q-bg-2.jpg" style="background-repeat:no-repeat;background-position:right;" class="daq_title_para"><div style="margin-left:9px;">Q3</div></td> 
    <td  height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong><asp:Literal ID="Q3_title" runat="server" Text="Available Bus"></asp:Literal></strong></td>
  </tr>
  <tr> <td></td>  <td> <span id="Q3" runat="server"></span></td></tr>
    <!------------------  Questin 3 ------------------>
  
   <!------------------  Questin 4 ------------------>
   <tr>
    <td align="center" background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para"><div style="margin-left:9px;">Q4</div></td> 
    <td  height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong> <asp:Literal ID="Q4_title" runat="server" ></asp:Literal></strong></td>
  </tr>
  <tr> <td></td> <td>  <span id="Q4" runat="server"></span> </td></tr>
    <!------------------  Questin 4 ------------------>
        <!------------------  Questin 5 ------------------>
  <tr>
    <td align="center" background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para"><div style="margin-left:9px;">Q5</div></td> 
    <td height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong> What Kind of Data Acquisition Functions Do You Need ?</strong></td>
  </tr>
  <tr><td colspan="2"><div  style="margin-left:45px; color:red;font-size:12px;font-weight:bold;margin-bottom:5px;">Please click each " Add to Search Criteria " after entering values.</div></td></tr> 
  <tr>
  
    <td colspan="2">
    <table width="100%" border="0" cellspacing="0" cellpadding="0"  style="margin-left:15px;">
  <tr>
   <td valign="top" align="left">
    <!------------------  Questin 1-5-1 ------------------>      
    <table runat="server" id="YI5YI"   border="0" cellspacing="0" cellpadding="0" width="166" height="230"  bgcolor="#beccec" >
  <tr> <td valign="top" height="26"><img src="./image/title-1.jpg" width="166" height="26"></td></tr>
      <tr><td bgcolor="#beccec" class="tdleft">Channel:<input type="text" size="8" runat="server" name="aich" id="aich" /></td>  </tr>
      <tr><td bgcolor="#beccec" class="tdleft">Resolution (bits):<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="air"> </asp:DropDownList>  </td> </tr>
       <tr><td bgcolor="#beccec" class="tdleft">Sampling Rate:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aisr"> </asp:DropDownList></td> </tr>
        <tr><td bgcolor="#beccec" class="tdleft">Input Range:<br /><asp:DropDownList AutoPostBack="false"   runat="server" ID="aiir"   > </asp:DropDownList></td> </tr>
	<tr><td bgcolor="#beccec" class="tdleft">      
    <div id="add_aioption"></div>
    </td>
        </tr>
        <tr><td height="26"><asp:ImageButton runat="server" ID="AIimage" ImageUrl="./image/add.png" OnClientClick="return checkAI();"  onclick="AIimage_Click" /></td></tr>
       
</table>
  <!------------------  Questin 1-5-1 end ------------------>  
  <!------------------  Questin 2-5-1 ------------------>      
    <table  runat="server" id="ER5YI" border="0" cellspacing="0" cellpadding="0" width="166" height="230"  bgcolor="#beccec" >
  <tr> <td valign="top" height="26"><img src="./image/title-1.jpg" width="166" height="26"></td></tr>
      <tr><td bgcolor="#beccec" class="tdleft">Channel:<input type="text" size="8" runat="server" name="aich2" id="aich2" /></td>  </tr>
     
       <tr><td bgcolor="#beccec" class="tdleft">Sampling Rate:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aisr2"> </asp:DropDownList><br /></td> </tr>
        <tr><td bgcolor="#beccec" class="tdleft">Input Range:<br /><asp:DropDownList AutoPostBack="false"   runat="server" ID="aiir2"   > </asp:DropDownList><br /></td> </tr>
	<tr><td bgcolor="#beccec" class="tdleft">      
    <div id="add_aioption2"></div>
    </td>
        </tr>
        <tr><td height="26"><asp:ImageButton runat="server" ID="AIimage2" ImageUrl="./image/add.png" OnClientClick="return checkAI2();"  onclick="AIimage_Click2" /></td></tr>
       
</table>
  <!------------------  Questin 2-5-1 end ------------------> 
  </td>  
    <td valign="top" align="left">
    
    <!------------------  Questin 1-5-2 ------------------>
     <table runat="server" id="YI5ER"  border="0" cellspacing="0" cellpadding="0"  width="166" height="230" bgcolor="#b5d9ef">
  <tr> <td valign="top" height="26"><img src="./image/title-2.jpg" width="166" height="26"></td></tr>
  <tr><td bgcolor="#b5d9ef" class="tdleft">Channel: <input  type="text" size="8" name="aoch" id="aoch"  runat="server"/></td></tr>
  <tr><td bgcolor="#b5d9ef" class="tdleft">Resolution(bits):<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aor"> </asp:DropDownList> </td></tr>
    <tr><td bgcolor="#b5d9ef" class="tdleft">Output Rate:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoort"> </asp:DropDownList></td></tr>
      <tr><td bgcolor="#b5d9ef" class="tdleft">Output Range:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoorg"> </asp:DropDownList></td></tr>
        <tr><td bgcolor="#b5d9ef" height="26"><asp:ImageButton runat="server" ID="AOimage" ImageUrl="./image/add.png" OnClientClick="return checkAO();"  onclick="AOimage_Click" /></td></tr>
      </table>

    <!------------------  Questin 1-5-2 end ------------------>
     <!------------------  Questin 2-5-2 ------------------>
     <table  runat="server" id="ER5ER" border="0" cellspacing="0" cellpadding="0"  width="166" height="230" bgcolor="#b5d9ef">
  <tr> <td valign="top" height="26"><img src="./image/title-2.jpg" width="166" height="26"></td></tr>
  <tr><td bgcolor="#b5d9ef" class="tdleft">Channel: <input  type="text" size="8" name="aoch2" id="aoch2"  runat="server"/></td></tr>
  <tr><td bgcolor="#b5d9ef" class="tdleft">Resolution(bits):<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aor2"> </asp:DropDownList> </td></tr>   
      <tr><td bgcolor="#b5d9ef" class="tdleft">Output Range:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoorg2"> </asp:DropDownList></td></tr>
        <tr><td bgcolor="#b5d9ef" height="26"><asp:ImageButton runat="server" ID="AOimage2" ImageUrl="./image/add.png" OnClientClick="return checkAO2();"  onclick="AOimage2_Click" /></td></tr>
      </table>

    <!------------------  Questin 2-5-2 end ------------------>
    
    </td>  
    <td valign="top"> 
    <!------------------  Questin 1-5-3 ------------------>
     <asp:UpdatePanel id="up153" runat="server" UpdateMode="Conditional"><ContentTemplate>
    <table runat="server" id="YI5SAN"  valign="top"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec">
  <tr> <td  height="26" valign="top"><img src="./image/title-3.jpg" width="166" height="26"></td></tr>
   <tr><td valign="top" bgcolor="#beccec" class="tdleft" style="padding-top:5px;">Channel Type:<br /><asp:DropDownList AutoPostBack="true"  runat="server" ID="di_channel_type"  onselectedindexchanged="di_channel_type_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-Select-"></asp:ListItem>
        <asp:ListItem Value="di_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="di_channel_isolation" Text="Isolation"></asp:ListItem> </asp:DropDownList> </td></tr>

         <tr id="dich_ttl_TR"  visible="false"  runat="server" ><td bgcolor="#beccec" valign="top" class="tdleft" >
         Channel:<input type="text" size="8" name="dich_ttl" id="dich_ttl" runat="server"/><br /><br /><br /><br /><br /><br /><br /></td></tr>
         
       
         <tr id="DI1image_TR" visible="false" runat="server" height="26" ><td bgcolor="#beccec" ><asp:ImageButton runat="server" ID="DI1image" OnClientClick="return checkDI1();" ImageUrl="./image/add.png"   onclick="DI1image_Click" /></td></tr>
           
           
           <tr id="dich_isolation_TR" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec">Channel:<input type="text" size="8" name="dich_isolation" id="dich_isolation" runat="server"/></td></tr>
             <tr id="sm_TR" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec">Input Voltage for Logic 1(V<sub>DC</sub>)</td></tr>
               <tr id="HTML_TR" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec" id="HTML_TD" runat="server" ></td></tr>
             <tr id="DI2image_TR" runat="server" visible="false" height="26"><td bgcolor="#beccec"><asp:ImageButton runat="server" ID="DI2image" OnClientClick="return checkDI2();" ImageUrl="./image/add.png"   onclick="DI2image_Click" /></td></tr>


    </table>
  </ContentTemplate>
  <Triggers> 
      <asp:AsyncPostBackTrigger ControlID="di_channel_type"   EventName="SelectedIndexChanged" /> 
  </Triggers>
   </asp:UpdatePanel>

     <!------------------  Questin 1-5-3 end ------------------>
     <!------------------  Questin 2-5-3 ------------------>
     <asp:UpdatePanel id="up253" runat="server" UpdateMode="Conditional"><ContentTemplate>
    <table runat="server" id="ER5SAN" valign="top"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec">
  <tr> <td  height="26" valign="top"><img src="./image/title-3.jpg" width="166" height="26"></td></tr>
   <tr><td valign="top" bgcolor="#beccec" class="tdleft" style="padding-top:5px;">Channel Type:<br /><asp:DropDownList AutoPostBack="true"  runat="server" ID="di_channel_type2"  onselectedindexchanged="di_channel_type2_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-Select-"></asp:ListItem>
        <asp:ListItem Value="di_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="di_channel_isolation" Text="Isolation"></asp:ListItem> </asp:DropDownList> </td></tr>

         <tr id="dich_ttl_TR2"  visible="false"  runat="server" ><td bgcolor="#beccec" valign="top" class="tdleft" >
         Channel:<input type="text" size="8" name="dich_ttl2" id="dich_ttl2" runat="server"/><br /><br /><br /><br /><br /><br /><br /></td></tr>
         
       
         <tr id="DI1image_TR2" visible="false" runat="server" height="26" ><td bgcolor="#beccec" ><asp:ImageButton runat="server" ID="DI1image2" OnClientClick="return checkDI12();" ImageUrl="./image/add.png"   onclick="DI1image_Click2" /></td></tr>
           
           
           <tr id="dich_isolation_TR2" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec">Channel:<input type="text" size="8" name="dich_isolation2" id="dich_isolation2" runat="server"/></td></tr>
             <tr id="sm_TR2" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec">Input Voltage for Logic 1(V<sub>DC</sub>)</td></tr>
               <tr id="HTML_TR2" runat="server" visible="false" class="tdleft"><td bgcolor="#beccec" id="HTML_TD2" runat="server" ></td></tr>
             <tr id="DI2image_TR2" runat="server" visible="false" height="26"><td bgcolor="#beccec"><asp:ImageButton runat="server" ID="DI2image2" OnClientClick="return checkDI22();" ImageUrl="./image/add.png"   onclick="DI2image_Click2" /></td></tr>


    </table>
  </ContentTemplate>
  <Triggers> 
      <asp:AsyncPostBackTrigger ControlID="di_channel_type2"   EventName="SelectedIndexChanged" /> 
  </Triggers>
   </asp:UpdatePanel>

     <!------------------  Questin 2-5-3 end ------------------>
     </td> 
	 <td valign="top">
      <!------------------  Questin 1-5-4 ------------------>
      <asp:UpdatePanel id="up154" runat="server" UpdateMode="Conditional"><ContentTemplate>
      <table runat="server" id="YI5SI"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#b5d9ef"> <tr> <td valign="top"  height="26"><img src="./image/title-4.jpg" width="166" height="26"></td></tr>
       <tr><td valign="top" bgcolor="#b5d9ef" class="tdleft">Channel Type: <br>
       <asp:DropDownList AutoPostBack="true"  runat="server" ID="do_channel_type"  onselectedindexchanged="do_channel_type_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-Select-"></asp:ListItem>
        <asp:ListItem Value="do_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="do_channel_isolation" Text="Isolation"></asp:ListItem> 
          <asp:ListItem Value="do_channel_relay" Text="Relay"></asp:ListItem></asp:DropDownList>
       </td></tr>
       
       <tr id="si_1_1" runat="server" visible="false" ><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_ttl" id="doch_ttl"  runat="server"/><br /><br /><br /><br /><br /><br /><br /><br /></td></tr>
       <tr id="si_1_2" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO1image" ImageUrl="./image/add.png" OnClientClick="return checkDO1();"  onclick="DO1image_Click" /></td></tr>

        <tr id="si_2_1" runat="server" visible="false"><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_isolation" id="doch_isolation"  runat="server"/></td></tr>
         <tr id="si_2_2" runat="server" visible="false"><td id="si_2_2TD" class="tdleft" runat="server" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_2_3" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO2image" ImageUrl="./image/add.png" OnClientClick="return checkDO2();"  onclick="DO2image_Click" /></td></tr>


           <tr id="si_3_1" runat="server" visible="false"><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_relay" id="doch_relay"  runat="server"/></td></tr>
         <tr id="si_3_2" runat="server" visible="false"><td id="si_3_2TD" runat="server" class="tdleft" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_3_3" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO3image" ImageUrl="./image/add.png" OnClientClick="return checkDO3();"  onclick="DO3image_Click" /></td></tr>
       
       </table>
       </ContentTemplate>      
         <Triggers> 
      <asp:AsyncPostBackTrigger ControlID="do_channel_type"   EventName="SelectedIndexChanged" /> 
  </Triggers>       
       </asp:UpdatePanel>
       <!------------------  Questin 1-5-4 ------------------>

<!------------------  Questin 2-5-4 ------------------>
      <asp:UpdatePanel id="up254" runat="server" UpdateMode="Conditional"><ContentTemplate>
      <table runat="server" id="ER5SI"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#b5d9ef"> <tr> <td valign="top"  height="26"><img src="./image/title-4.jpg" width="166" height="26"></td></tr>
       <tr><td valign="top" bgcolor="#b5d9ef" class="tdleft"><BR />Channel Type: <br>
       <asp:DropDownList AutoPostBack="true"  runat="server" ID="do_channel_type2"  onselectedindexchanged="do_channel_type2_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-Select-"></asp:ListItem>
        <asp:ListItem Value="do_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="do_channel_isolation" Text="Isolation"></asp:ListItem> 
          <asp:ListItem Value="do_channel_relay" Text="Relay"></asp:ListItem></asp:DropDownList>
       </td></tr>
       
       <tr id="si_1_12" runat="server" visible="false" ><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_ttl2" id="doch_ttl2"  runat="server"/><br /><br /><br /><br /><br /><br /><br /><br /></td></tr>
       <tr id="si_1_22" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO1image2" ImageUrl="./image/add.png" OnClientClick="return checkDO12();"  onclick="DO1image_Click2" /></td></tr>

        <tr id="si_2_12" runat="server" visible="false"><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_isolation2" id="doch_isolation2"  runat="server"/></td></tr>
         <tr id="si_2_22" runat="server" visible="false"><td id="si_2_2TD2" class="tdleft" runat="server" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_2_32" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO2image2" ImageUrl="./image/add.png" OnClientClick="return checkDO22();"  onclick="DO2image_Click2" /></td></tr>


           <tr id="si_3_12" runat="server" visible="false"><td bgcolor="#b5d9ef" class="tdleft">Channel:<input type="text" size="8" name="doch_relay2" id="doch_relay2"  runat="server"/></td></tr>
         <tr id="si_3_22" runat="server" visible="false"><td id="si_3_2TD2" runat="server" class="tdleft" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_3_32" runat="server" visible="false"><td bgcolor="#b5d9ef"><asp:ImageButton runat="server" ID="DO3image2" ImageUrl="./image/add.png" OnClientClick="return checkDO32();"  onclick="DO3image_Click2" /></td></tr>
       
       </table>
       </ContentTemplate>      
         <Triggers> 
      <asp:AsyncPostBackTrigger ControlID="do_channel_type2"   EventName="SelectedIndexChanged" /> 
  </Triggers>       
       </asp:UpdatePanel>
       <!------------------  Questin 2-5-4 ------------------>
     </td> 
	 <td valign="top"> 
     <!------------------  Questin 1-5-5 ------------------>
      <table  runat="server" id="YI5WU" border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec" > <tr> <td height="26" valign="top"><img src="./image/title-5.jpg" width="166" height="26"></td></tr>
       <tr><td bgcolor="#beccec" class="tdleft">Channel: <input type="text" size="8" name="counter_ch" id="counter_ch"  runat="server"/></td></tr>
       
        <tr><td bgcolor="#beccec" class="tdleft">Resolution (bits):<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="counter_r"> </asp:DropDownList></td></tr>
         <tr><td bgcolor="#beccec" class="tdleft">Max. Input Frequency:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="counter_mif"> </asp:DropDownList><br /><br /><br /><br /><br /></td></tr>
        
         <tr><td bgcolor="#beccec" height="26"><asp:ImageButton runat="server" ID="COimage" ImageUrl="./image/add.png" OnClientClick="return checkCO();"  onclick="COimage_Click" /></td></tr>
       </table>
      <!------------------  Questin 1-5-5/ ------------------>

       <!------------------  Questin 2-5-5 ------------------>
      <table  runat="server" id="ER5WU" border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec" > <tr> <td height="26" valign="top"><img src="./image/title-5.jpg" width="166" height="26"></td></tr>
       <tr><td bgcolor="#beccec" class="tdleft">Channel: <input type="text" size="8" name="counter_ch2" id="counter_ch2"  runat="server"/></td></tr>
       
        <tr><td bgcolor="#beccec" class="tdleft">
        <input id="counter_mif" name="counter_mif" type="hidden" value="19^A^Less than 1 M">
        <br /><br /><br /><br /><br /><br /></td></tr>

        
         <tr><td bgcolor="#beccec" height="26"><asp:ImageButton runat="server" ID="COimage2" ImageUrl="./image/add.png" OnClientClick="return checkCO2();"  onclick="COimage_Click2" /></td></tr>
       </table>
      <!------------------  Questin 2-5-5/ ------------------>



      </td>
  </tr>
</table>
    </td>
  </tr>
      <!------------------  Questin 5 ------------------>
      <tr><td colspan="2"><br />
 <!------------------   list ------------------>
      
      <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin-left:15px;">
      <tr><td  valign="bottom"  ><img src="./image/title-6.jpg" width="166" height="26"></td><td></td> </tr>
      <tr>
    <td valign="top">

			 <!-- Wishlist box -->
						  <table width="580" height="271" border="1" cellpadding="0" cellspacing="0" bordercolor="#999999" bgcolor="#FFFFFF">
                            <tr>
                              <td valign="top" bordercolor="#FFFFFF" >
							  
                                 <asp:UpdatePanel runat="server" ID="upws" UpdateMode="Conditional">
                                  <ContentTemplate>
                                
                              	<div id="wishlist" runat="server" class="wishlist_container"></div>

                                     
                                </ContentTemplate>
                                    <Triggers>
                                         <asp:AsyncPostBackTrigger ControlID="AIimage" EventName="Click" />
                                           <asp:AsyncPostBackTrigger ControlID="AOimage" EventName="Click" />
                                            <asp:AsyncPostBackTrigger ControlID="DI1image" EventName="Click" />
                                             <asp:AsyncPostBackTrigger ControlID="DI2image" EventName="Click" />
                                              <asp:AsyncPostBackTrigger ControlID="DO1image" EventName="Click" />
                                               <asp:AsyncPostBackTrigger ControlID="DO2image" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="DO3image" EventName="Click" />
                                                 <asp:AsyncPostBackTrigger ControlID="COimage" EventName="Click" />
                                                
                                          <asp:AsyncPostBackTrigger ControlID="AIimage2" EventName="Click" />
                                          <asp:AsyncPostBackTrigger ControlID="AOimage2" EventName="Click" />
                                            <asp:AsyncPostBackTrigger ControlID="DI1image2" EventName="Click" />
                                             <asp:AsyncPostBackTrigger ControlID="DI2image2" EventName="Click" />
                                              <asp:AsyncPostBackTrigger ControlID="DO1image2" EventName="Click" />
                                               <asp:AsyncPostBackTrigger ControlID="DO2image2" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="DO3image2" EventName="Click" />
                                                 <asp:AsyncPostBackTrigger ControlID="COimage2" EventName="Click" />
                                      </Triggers>
                                  </asp:UpdatePanel>
								  </td>
                                </tr>
                                </table>
								<!-- / Wishlist box -->
		
          </td>
      
     <td  valign="top"><img src="./image/q_image-1.jpg" width="271" height="271"></td>
      </tr><tr><td width="600"></td><td  align="right">
    
      
   <!------------------  list/ ------------------>   
    
    

        <asp:ImageButton runat="server" ID="SEARCH"  ImageUrl="./image/q_image-1_02.jpg"  OnClientClick="return checkwish();"   onclick="SEARCH_Click" />
       <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="68" height="49">
                                <param name="movie" value="./image/arrow.swf">
                                <param name="quality" value="high">
                                <embed src="./image/arrow.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="68" height="49"></embed>
                              </object>
                             </td>   </tr>
      </table>
    </td></tr>
</table>

        <script  language="javascript" type="text/javascript">
            var alertstr = "Channel and options can not be empty.";
            function checkAI() {
                if (document.getElementById('<%=aich.ClientID %>').value == "") { alert(alertstr); return false; }
                if (document.getElementById("<%=air.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aisr.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aiir.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAI2() {
                if (document.getElementById('<%=aich2.ClientID %>').value == "") { alert(alertstr); return false; }

                if (document.getElementById("<%=aisr2.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aiir2.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAO() {
                if (document.getElementById('<%=aoch.ClientID %>').value == "") { alert(alertstr); return false; }
                if (document.getElementById("<%=aor.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aoort.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aoorg.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAO2() {
                if (document.getElementById('<%=aoch2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (document.getElementById("<%=aor2.clientid%>").value == "none") { alert(alertstr); return false; }

                if (document.getElementById("<%=aoorg2.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkDI1() {
                if (document.getElementById("<%=di_channel_type.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_ttl.ClientID %>').value == "") { alert(alertstr); return false; }
            }
            function checkDI12() {
                if (document.getElementById("<%=di_channel_type2.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_ttl2.ClientID %>').value == "") { alert(alertstr); return false; }
            }
            function checkDI2() {
                if (document.getElementById("<%=dich_isolation.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_isolation.ClientID %>').value == "") { alert(alertstr); return false; }
            }
            function checkDI22() {
                if (document.getElementById("<%=dich_isolation2.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_isolation2.ClientID %>').value == "") { alert(alertstr); return false; }
            }
             function checkDO1() {
                 if (document.getElementById('<%=doch_ttl.ClientID %>').value == "") { alert(alertstr); return false; }
             }
             function checkDO12() {
                 if (document.getElementById('<%=doch_ttl2.ClientID %>').value == "") { alert(alertstr); return false; }
             }
              function checkDO2() {
                  if (document.getElementById('<%=doch_isolation.ClientID %>').value == "") { alert(alertstr); return false; }

              }
              function checkDO22() {
                  if (document.getElementById('<%=doch_isolation2.ClientID %>').value == "") { alert(alertstr); return false; }

              }
              function checkDO3() {
                  if (document.getElementById('<%=doch_relay.ClientID %>').value == "") { alert(alertstr); return false; }
              }
              function checkDO32() {
                  if (document.getElementById('<%=doch_relay2.ClientID %>').value == "") { alert(alertstr); return false; }
              }
              function checkCO() {
                  if (document.getElementById('<%=counter_ch.ClientID %>').value == "") { alert(alertstr); return false; }
                  if (document.getElementById("<%=counter_r.clientid%>").value == "none") { alert(alertstr); return false; }
                  if (document.getElementById("<%=counter_mif.clientid%>").value == "none") { alert(alertstr); return false; }
              }
              function checkCO2() {
                  if (document.getElementById('<%=counter_ch2.ClientID %>').value == "") { alert(alertstr); return false; }
                
              }
              function del_wishlist(req,sessionid) {
                 
                  var arrID = "";
                  PageMethods.del_wishlist_server(req + ";" + sessionid, OnPageMethods_2Succeeded, OnGetPriceError2, arrID);
              }
            
              
              function OnPageMethods_2Succeeded(result, arrID, methodName) {

                   document.getElementById('<%=wishlist.ClientID %>').innerHTML  = result;
               //   alert(result);
               
              }
             function OnGetPriceError2(error, arrID, methodName) {
                 if (error !== null) { alert(error.get_message()); }
             }

             function checkwish() {

                 ////////////////////////////////////////Q1
                 var result = false;
                 var RB1name = document.getElementsByName("ctl00$_main$RB1");             
                 if (RB1name)   
                       { for (var i = 0; i < RB1name.length; i++)   
                               {
                                   if (RB1name[i].checked)   
                                      { result =true;   break;    }   
                               }   
                       }   
                       if(result ==false) {alert('Please answer Q1'); return false;}
                       /////////////////////////////////////////////Q2
                       var result2 = false;
                       var RB2name = document.getElementsByName("ctl00$_main$RB2");
                       if (RB2name) {
                           for (var i = 0; i < RB2name.length; i++) {
                               if (RB2name[i].checked)
                               { result2 = true; break; }
                           }
                       }
                       if (result2 == false) { alert('Please answer Q2'); return false; }
                       /////////////////////////////////////////////////Q3
                       var result3 = false;
                       var RB3name = document.getElementsByName("q3");
                       if (RB3name) {
                           for (var i = 0; i < RB3name.length; i++) {
                               if (RB3name[i].checked)
                               { result3 = true; break; }
                           }
                       }
                       if (result3 == false) { alert('Please answer Q3'); return false; }
                       /////////////////////////////////////////////////Q4
                       var result4 = false;
                       var RB4name = document.getElementsByName("q4");
                       if (RB4name) {
                           for (var i = 0; i < RB4name.length; i++) {
                               if (RB4name[i].checked)
                               { result4 = true; break; }
                           }
                       }
                       if (result4 == false) { alert('Please answer Q4'); return false; }
                       //////////////////////////////////////////////////////

                 var objstr = document.getElementById('<%=wishlist.ClientID %>').innerHTML;
                 if (objstr == "") { alert("Please answer Q5, 'What Kind of Data Acquisition Functions Do You Need ?'\n(Please make sure to click the ‘Add to Search Criteria’ button in each column after entering values.)"); return false; }
             }
           
        </script>
      <div id="bb"></div>

<ajaxToolkit:AlwaysVisibleControlExtender runat="server" ID="avcext1" 
        TargetControlID="panel1" HorizontalOffset="10" VerticalOffset="10" HorizontalSide="Right" /> 
     
        
        
         <asp:Panel runat="server" ID="panel1" Width="300px" Height="800px" ScrollBars="Auto" BackColor="LightGray">

    <div id="av" runat="server" ></div>
      <asp:UpdatePanel id="upav" runat="server" UpdateMode="Always">
      <ContentTemplate>
       <asp:Literal runat="server" ID="test" ></asp:Literal>
      </ContentTemplate>
      </asp:UpdatePanel>
  
 </asp:Panel>
    

</asp:Content>


