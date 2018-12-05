<%@ Page Title="Advantech DAQ Your Way - Click, Search, and Discover the Perfect Data Acquisition Solution" validateRequest="false" Language="VB" EnableEventValidation="true" MasterPageFile="~/daq/MyDAQMaster.master" %>

<script runat="server">
    Dim pci_vid As String = "96", pci_id As String = "22", isa_vid As String = "97", isa_id As String = "22", pcie_vid As String = "196", pcie_id As String = "22", pc_sl_104_vid As String = "197", pc_sl_104_id As String = "22", pc_da_104_vid As String = "198", pc_da_104_id As String = "22"
    Dim pc_sl_104_plus_vid As String = "199", pc_sl_104_plus_id As String = "22", usb_vid As String = "200", usb_id As String = "22", winxp_vid As String = "90", winxp_id As String = "20"
    Dim vista_vid As String = "91", vista_id As String = "20", wince_vid As String = "92", wince_id As String = "20", winxpe_vid As String = "93", winxpe_id As String = "20"
    Dim linux_vid As String = "195", linux_id As String = "20", rs485_vid As String = "201", rs485_id As String = "22", ethernet_vid As String = "202", ethernet_id As String = "22", modbus_vid As String = "94", modbus_id As String = "21", ascii_vid As String = "95", ascii_id As String = "21"
    Dim Q1 As String = "1"
    Public min_str As String = "Min", max_str As String = "Max", jg1 As String = "Data Sheet", jg2 As String = "Buy Online", jg3 As String = "See Similar Items"
    Public jg4 As String = "Items in Search Criteria", jg5 As String = "Details"
    Public fsdwyx As String = "Email Me My Solution", xqkz As String = "Customize It!"
    Public AI_Str As String = "A1", AO_Str As String = "AO", DI_Str As String = "DI", DO_Str As String = "DO", Counter_Str As String = "Counter"
    Protected Sub RB1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
       
        Call clean_session_data("DAQ_available_list_check")
        Call clean_session_data("DAQ_available_list_tmp")
        Call clean_session_data("DAQ_wishlist_tmp")
        ''''''''''''''''''''''''for fanti
      
        Dim sqldel As String = "DELETE FROM DAQ_available_list_check WHERE sessionid = '" + HttpContext.Current.Session.SessionID + "'"
        dbUtil.dbExecuteNoQuery("MYLOCAL", sqldel)
         
        Dim opt_id As String = "0" : Dim opt_vid As String = RB1.SelectedValue
        Dim sql As String = "SELECT * FROM DAQ_available_list_check WHERE sessionid = '" + Session.SessionID + "' AND q_no = 'q1'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim sql2 As String = ""
        If dt.Rows.Count > 0 Then
            sql2 = " UPDATE DAQ_available_list_check SET q_optionid = '" + opt_id + "',q_optionvid = '" + opt_vid + "' WHERE sessionid = '" + Session.SessionID + "' AND q_no = 'q1'"
        Else
            sql2 = "INSERT INTO DAQ_available_list_check (sessionid,q_no,q_optionid,q_optionvid) values('" + Session.SessionID + "','q1','" + opt_id + "',  '" + opt_vid + "')"
        End If
        If opt_id = "q3_3" OrElse opt_id = "q4_3" Then
        Else
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
        End If
        ''''''''''''''''''''''''''end for fanti
        Session("q1_vid") = RB1.SelectedValue      
        If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
            Q3_title.Text = Q3title_str1 : Q4_title.Text = Q4title_str1
            Call set_Q5_1()
        End If
        If RB1.SelectedValue = "2" Then
            Q3_title.Text = Q3title_str2 : Q4_title.Text = Q4title_str2
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
        
        If IsPostBack Then
            Session("q1_vid") = RB1.SelectedValue
        End If
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn", "zh-tw"
                    min_str = "最小" : max_str = "最大"
                Case Else
            End Select
        Else
        
        End If
        If Session("q1_vid") IsNot Nothing AndAlso Session("q1_vid").ToString <> "" Then
            RB1.SelectedValue = Session("q1_vid").ToString
        End If
        If Session("q2_vid") IsNot Nothing AndAlso Session("q2_vid").ToString <> "" Then
            RB2.SelectedValue = Session("q2_vid").ToString
        End If
        If Not IsPostBack Then
            Session("q1_vid") = ""
            Session("q2_vid") = ""
            Session("q3_vid") = ""
            Session("q4_vid") = ""
            Call clean_session_data("DAQ_available_list_check")
            Call clean_session_data("DAQ_available_list_tmp")
            Call clean_session_data("DAQ_wishlist_tmp")
            Me.MultiView1.ActiveViewIndex = 0
            dich_ttl_TR.Visible = True : DI1image_TR.Visible = True : dich_ttl_TR_br.Visible = True
            si_1_1.Visible = True : si_1_2.Visible = True : si_1_1_br.Visible = True
            dich_ttl_TR2.Visible = True : DI1image_TR2.Visible = True : dich_ttl_TR2_br.Visible = True
            si_1_12.Visible = True : si_1_22.Visible = True : si_1_12_br.Visible = True
        End If
        ''''
      
        If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
            Q3_title.Text = Q3title_str1 : Q4_title.Text = Q4title_str1
         
        End If
        If RB1.SelectedValue = "2" Then
            Q3_title.Text = Q3title_str2 : Q4_title.Text = Q4title_str2
         
        End If
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
          "<input type='radio' name='q3' " + c7 + " id='" + usb_id + "' value='" + usb_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">USB</td>" & _
          "</tr></table>"
            Q4_str = "<table width='100%' border='0' height='26' cellspacing='0' cellpadding='0'>" & _
       "<tr><td width='162' class='text'><input type='radio' " + m1 + " name='q4' id='" + winxp_id + "' value='" + winxp_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Window2000/XP</td>" & _
       "<td width='160' class='text'><input type='radio' " + m2 + " name='q4' id='" + vista_id + "' value='" + vista_vid + "' onclick=""xajax_available_list(this.name,this.id,this.value,'" + Session.SessionID + "');"">Windows 7/ Windows 8</td>" & _
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
        ''''''
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Dim DLs() As DropDownList = {di_channel_type, di_channel_type2, do_channel_type, do_channel_type2}
            Select Case lan
                Case "zh-cn"
                    For i As Integer = 0 To DLs.Length - 1
                        '
                        For j As Integer = 0 To DLs(i).Items.Count - 1
                            If DLs(i).Items(j).Value.Trim.ToLower = "none" Then
                                DLs(i).Items(j).Text = "-选择-"
                                Exit For
                            End If
                        Next
                        '
                    Next
                   
                Case "zh-tw"
                    For i As Integer = 0 To DLs.Length - 1
                        '
                        For j As Integer = 0 To DLs(i).Items.Count - 1
                            If DLs(i).Items(j).Value.Trim.ToLower = "none" Then
                                DLs(i).Items(j).Text = "-選擇-"
                                Exit For
                            End If
                        Next
                        '
                    Next
                Case Else
                   
            End Select
        Else
            
        End If
       
        ''''''
    End Sub
    Private Sub set_Q5_1()
        '''''''''''''''''''''''''''''''''''''''''111111111111111111111111111111111111111111'''''''''''''''''''''''''''''''''''''''''''''''''
        YI5YI.Visible = True : YI5ER.Visible = True : YI5SAN.Visible = True : YI5SI.Visible = True : YI5WU.Visible = True
    
        ER5YI.Visible = False : ER5ER.Visible = False : ER5SAN.Visible = False : ER5SI.Visible = False : ER5WU.Visible = False
        '''''''''''''' Air
        air.Items.Clear()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    air.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    air.Items.Add(New ListItem("-選擇-", "none"))
                Case Else                  
            End Select
        Else
            air.Items.Add(New ListItem("-select-", "none"))
        End If
       
        Dim airdt As DataTable = getOption("1", "2")
        For Each r As DataRow In airdt.Rows
            Dim Value As String = "2^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            air.Items.Add(New ListItem(Text, Value))
        Next
        air.DataBind()
        '''''''''''Aisr
        aisr.Items.Clear()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aisr.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aisr.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aisr.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aisr.Items.Add(New ListItem("-select-", "none"))
        End If     
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aiir.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aiir.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aiir.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aiir.Items.Add(New ListItem("-select-", "none"))
        End If
       
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aor.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aor.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aor.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aor.Items.Add(New ListItem("-select-", "none"))
        End If
      
        Dim aordt As DataTable = getOption("2", "6")
        For Each r As DataRow In aordt.Rows
            Dim Value As String = "6^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aor.Items.Add(New ListItem(Text, Value))
        Next
        aor.DataBind()
        ''''''''''''''''
        aoort.Items.Clear()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aoort.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aoort.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aoort.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aoort.Items.Add(New ListItem("-select-", "none"))
        End If
    
        Dim aoortdt As DataTable = getOption("2", "7")
        For Each r As DataRow In aoortdt.Rows
            Dim Value As String = "7^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            aoort.Items.Add(New ListItem(Text, Value))
        Next
        aoort.DataBind()
        ''''''''''''''''''''''''
        aoorg.Items.Clear()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aoorg.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aoorg.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aoorg.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aoorg.Items.Add(New ListItem("-select-", "none"))
        End If
     
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    counter_r.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    counter_r.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    counter_r.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            counter_r.Items.Add(New ListItem("-select-", "none"))
        End If
     
        Dim counter_rdt As DataTable = getOption("5", "18")
        For Each r As DataRow In counter_rdt.Rows
            Dim Value As String = "18^" + r("option_valueid").ToString() + "^" + r("option_value").ToString()
            Dim Text As String = r("option_value").ToString()
            counter_r.Items.Add(New ListItem(Text, Value))
        Next
        counter_r.DataBind()
        ''''''''''''''''''''''
        counter_mif.Items.Clear()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    counter_mif.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    counter_mif.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    counter_mif.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            counter_mif.Items.Add(New ListItem("-select-", "none"))
        End If
    
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aisr2.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aisr2.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aisr2.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aisr2.Items.Add(New ListItem("-select-", "none"))
        End If
      
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aiir2.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aiir2.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aiir2.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aiir2.Items.Add(New ListItem("-select-", "none"))
        End If
      
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aor2.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aor2.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aor2.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
           aor2.Items.Add(New ListItem("-select-", "none")) 
        End If
       
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
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    aoorg2.Items.Add(New ListItem("-选择-", "none"))
                Case "zh-tw"
                    aoorg2.Items.Add(New ListItem("-選擇-", "none"))
                Case Else
                    aoorg2.Items.Add(New ListItem("-select-", "none"))
            End Select
        Else
            aoorg2.Items.Add(New ListItem("-select-", "none"))
        End If
      
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
        Dim p() As String = Split(str, "#") : Dim qn As String = p(0) : Dim ceshi As String = "1"
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
         dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp where sessionid = '" + HttpContext.Current.Session.SessionID + "'")
        Dim sql3 As String = "SELECT q_no, q_optionid, q_optionvid FROM DAQ_available_list_check WHERE sessionid = '" + p(3) + "' ORDER BY q_no"
        Dim dt3 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql3)
        If dt3.Rows.Count > 0 Then
            For i As Integer = 0 To dt3.Rows.Count -1
                If dt3.Rows(i).Item("q_no").ToString = "q1" Then
                   
                    Dim dt3_1 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT a.productid FROM DAQ_products_categories as a, DAQ_products as b WHERE a.PRODUCTID = b.PRODUCTID and b.ENABLE='y' and a.categoryid= '" + dt3.Rows(i).Item("q_optionvid").ToString + "'")
                  
                    If dt3_1.Rows.Count > 0 Then
                        For ii As Integer = 0 To dt3_1.Rows.Count - 1
                           
                            dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO DAQ_available_list_tmp(sessionid,productid,q_no) values( '" + p(3) + "', '" + dt3_1.Rows(ii).Item("productid").ToString + "', 'q1')")
                          
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
            Dim delimgurl As String = "./image/delete-1.png"
            If HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "" Then
                If HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-cn" OrElse HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-tw" Then
                    delimgurl = "./image/jdelete-1.png"
                End If
            End If
            For i As Integer = 0 To dt2.Rows.Count - 1
                If i Mod 2 = 0 Then
                    show_items += String.Format("<div class='wishlist_cell_1'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"), delimgurl)
                Else
                    show_items += String.Format("<div class='wishlist_cell_1' style='background-color:#fff;'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2' style='background-color:#fff;'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"), delimgurl)
                End If
                                  
            Next
            
        End If
        Return show_items
    End Function
    <System.Web.Services.WebMethod()> _
    Public Shared Function onload_wishlist_server(ByVal req_sessionid As String) As String
       
        Dim sql As String = "SELECT seq, class, description,sessionid FROM DAQ_wishlist_tmp WHERE sessionid = '" + HttpContext.Current.Session.SessionID + "' order by seq asc"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim show_items As String = ""
        Dim delimgurl As String = "./image/delete-1.png"
        If HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "" Then
            If HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-cn" OrElse HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-tw" Then
                delimgurl = "./image/jdelete-1.png"
            End If
        End If
        If dt2.Rows.Count > 0 Then
            For i As Integer = 0 To dt2.Rows.Count - 1
                If i Mod 2 = 0 Then
                    show_items += String.Format("<div class='wishlist_cell_1'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"), delimgurl)
                Else
                    show_items += String.Format("<div class='wishlist_cell_1' style='background-color:#fff;'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2' style='background-color:#fff;'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"), delimgurl)
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
            'Dim sql As String = "SELECT * FROM DAQ_available_list_tmp WHERE sessionid = '" + sid + "' AND productid = '" + a(i) + "'"
            'Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            ' If dt.Rows.Count > 0 Then
            return_avail_pids = return_avail_pids + a(i) + ";"
            ' End If
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
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        For i As Integer = 0 To p.Length - 1
            If p(i) <> "77" AndAlso p(i) <> "78" Then
           
                Dim sql As String = "SELECT p.PRODUCTID,  p.SKU,  c.OPTION_VALUE as 'CH_NUM',   p.LISTPRICE  FROM  DAQ_products as p " & _
                                 " Inner Join DAQ_product_spec_values as b ON p.PRODUCTID = b.PRODUCTID " & _
                                 " Inner Join DAQ_spec_options_values as c ON b.OPTION_VALUES = c.OPTION_VALUEID " & _
                                 " WHERE    b.OPTIONID in (" + ch_optionid + ") AND  p.PRODUCTID =  '" + p(i) + "' and  c.OPTION_VALUE <> '-'   ORDER BY  p.PRODUCTID ASC,c.OPTION_VALUE desc"
            
                Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
          
                If dt2.Rows.Count > 0 Then
                    Dim dr As DataRow = dt.NewRow
                    dr("productid") = dt2.Rows(0)("productid")
                    dr("sku") = dt2.Rows(0)("sku")
                    dr("chnum") = dt2.Rows(0)("CH_NUM")
                    dr("listprice") = dt2.Rows(0)("listprice")
                    '''''''''''''''''''''''''''''''''''''''''''''''
                    Dim piece_int As Int32
                    If IsNumeric(dt2.Rows(0)("CH_NUM")) Then
                        piece_int = Convert.ToInt32(dt2.Rows(0)("CH_NUM"))
                    Else
                        Dim thisvalue As String = dt2.Rows(0)("CH_NUM")
                        If thisvalue.IndexOf("(") >= 0 Then
                            Try
                                piece_int = Convert.ToInt32(thisvalue.ToString.Substring(0, thisvalue.ToString.IndexOf("(") - 1).Trim)
                            Catch ex As Exception
                                Util.SendEmail("ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "DAQ Error email,piece_int:" + thisvalue.ToString + "", ex.ToString(), False, "", "")
                            End Try
                        
                        ElseIf thisvalue.IndexOf("x") >= 0 Then
                            Try
                                piece_int = Convert.ToInt32(thisvalue.ToString.Substring(0, thisvalue.ToString.IndexOf("x") - 1).Trim)
                            Catch ex As Exception
                                Util.SendEmail("ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "DAQ Error email,piece_int:" + thisvalue.ToString + "", ex.ToString(), False, "", "")
                            End Try
                       
                        End If
                    End If
                    '''''''''''''''''''''''''''''''''for max
                    Dim piece2_int As Int32
                    If dt2.Rows.Count = 2 Then
                        If IsNumeric(dt2.Rows(1)("CH_NUM")) Then
                            piece2_int = Convert.ToInt32(dt2.Rows(1)("CH_NUM"))
                        Else
                            Dim thisvalue2 As String = dt2.Rows(1)("CH_NUM").ToString
                            If thisvalue2.IndexOf("(") >= 0 Then
                                piece2_int = Convert.ToInt32(thisvalue2.ToString.Substring(0, thisvalue2.ToString.IndexOf("(") - 1).Trim)
                            ElseIf thisvalue2.IndexOf("x") >= 0 Then
                                piece2_int = Convert.ToInt32(thisvalue2.ToString.Substring(0, thisvalue2.ToString.IndexOf("x") - 1).Trim)
                            End If
                        End If
                        If piece_int < piece2_int Then
                            piece_int = piece2_int
                        End If
                    End If
                    '''''''''''''''''''''''''''''''
                    If Convert.ToInt32(ch_num) Mod piece_int > 0 Then
                        dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int + 1)
                    Else
                        dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int)
                    End If
                    Try
                        dr("total_price") = Integer.Parse(dr("piece")) * Decimal.Parse(dt2.Rows(0)("listprice"))
                        dt.Rows.Add(dr)
                    Catch ex As Exception
                        Util.SendEmail("tc.chen@advantech.eu,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "DAQ Error email,Ptoductids:" + pids + "| Channel:" + dt2.Rows(0)("CH_NUM").ToString + " | Piece:" + dr("piece").ToString + " | listprice:" + dt2.Rows(0)("listprice").ToString, ex.ToString(), False, "", "")
                    End Try
                                    
                End If
            Else
                If p(i) = "78" Then p(i) = "77"
                If Convert.ToInt32(ch_num) <= 96 Then
                    ''''zc
                 
                    Dim sql As String = "SELECT p.PRODUCTID,  p.SKU,  c.OPTION_VALUE as 'CH_NUM',   p.LISTPRICE  FROM  DAQ_products as p " & _
                                " Inner Join DAQ_product_spec_values as b ON p.PRODUCTID = b.PRODUCTID " & _
                                " Inner Join DAQ_spec_options_values as c ON b.OPTION_VALUES = c.OPTION_VALUEID " & _
                                " WHERE    b.OPTIONID in (" + ch_optionid + ") AND  p.PRODUCTID =  '" + p(i) + "' and  c.OPTION_VALUE <> '-'   ORDER BY  p.PRODUCTID ASC,c.OPTION_VALUE desc"
            
                    Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
          
                    If dt2.Rows.Count > 0 Then
                        Dim dr As DataRow = dt.NewRow
                        dr("productid") = dt2.Rows(0)("productid")
                        dr("sku") = dt2.Rows(0)("sku")
                        dr("chnum") = dt2.Rows(0)("CH_NUM")
                        dr("listprice") = dt2.Rows(0)("listprice")
                        '''''''''''''''''''''''''''''''''''''''''''''''
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
                        '''''''''''''''''''''''''''''''''for max
                        Dim piece2_int As Int32
                        If dt2.Rows.Count = 2 Then
                            If IsNumeric(dt2.Rows(1)("CH_NUM")) Then
                                piece2_int = Convert.ToInt32(dt2.Rows(1)("CH_NUM"))
                            Else
                                Dim thisvalue2 As String = dt2.Rows(1)("CH_NUM").ToString
                                If thisvalue2.IndexOf("(") >= 0 Then
                                    piece2_int = Convert.ToInt32(thisvalue2.ToString.Substring(0, thisvalue2.ToString.IndexOf("(") - 1).Trim)
                                ElseIf thisvalue2.IndexOf("x") >= 0 Then
                                    piece2_int = Convert.ToInt32(thisvalue2.ToString.Substring(0, thisvalue2.ToString.IndexOf("x") - 1).Trim)
                                End If
                            End If
                            If piece_int < piece2_int Then
                                piece_int = piece2_int
                            End If
                        End If
                        '''''''''''''''''''''''''''''''
                        If Convert.ToInt32(ch_num) Mod piece_int > 0 Then
                            dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int + 1)
                        Else
                            dr("piece") = Convert.ToString(Convert.ToInt32(ch_num) \ piece_int)
                        End If
                        dr("total_price") = Convert.ToInt32(dr("piece")) * Convert.ToInt32(dt2.Rows(0)("listprice"))
                        dt.Rows.Add(dr)
                  
                    End If
                    ' '''zc-end
                ElseIf Convert.ToInt32(ch_num) > 96 AndAlso Convert.ToInt32(ch_num) < 192 Then
                    Dim dr As DataRow = dt.NewRow
                    dr("productid") = "77"
                    dr("sku") = "PCI-1753-BE"
                    dr("chnum") = "96"
                    dr("listprice") = "250"
                    dr("total_price") = 450
                    dr("piece") = "<br>1* PCI-1753 + 1* PCI-1753E&nbsp;"
                     
                Else
                  
                    Dim dr As DataRow = dt.NewRow
                    dr("productid") = "77"
                    dr("sku") = "PCI-1753-BE"
                    dr("chnum") = "96"
                    dr("listprice") = "250"
                    Dim qiqi_piece As Int32
                    If Convert.ToInt32(ch_num) Mod 96 > 0 Then
                        qiqi_piece = Convert.ToInt32(ch_num) \ 96 + 1
                    Else
                        qiqi_piece = Convert.ToInt32(ch_num) \ 96 
                    End If
                    If qiqi_piece Mod 2 = 1 Then 'ji                     
                        dr("total_price") = Convert.ToString((qiqi_piece \ 2 + 1) * 250 + (qiqi_piece \ 2) * 200)
                        dr("piece") = "<br>" + Convert.ToString(qiqi_piece \ 2 + 1) + "* PCI-1753 + " + Convert.ToString(qiqi_piece \ 2) + "* PCI-1753E&nbsp;"
                        dt.Rows.Add(dr)
                    Else 'ou
                        dr("total_price") = Convert.ToString((qiqi_piece \ 2) * 450)
                        dr("piece") = "<br>" + Convert.ToString(qiqi_piece \ 2) + "* PCI-1753 + " + Convert.ToString(qiqi_piece \ 2) + "* PCI-1753E&nbsp;"
                        dt.Rows.Add(dr)
                    End If
                End If
                
            End If
        Next
        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        dt.AcceptChanges()
        ' OrderUtilities.showDT(dt)
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    Dim obj As Object = Nothing
        '    obj = dbUtil.dbExecuteScalar("MYLOCAL", "select enable from DAQ_products where PRODUCTID = '" + dt.Rows(i).Item("productid").ToString.Trim + "'")
        '    If obj IsNot Nothing AndAlso obj.ToString = "n" Then
        '        dt.Rows.Remove(dt.Rows(i))
        '    End If
        'Next
        'dt.AcceptChanges()
        'OrderUtilities.showDT(dt)
        If dt.Rows.Count > 0 Then
        
            Dim drmin() As DataRow = dt.Select("", "total_price Asc")
            best_product = {drmin(0)("productid"), drmin(0)("piece"), drmin(0)("total_price")}
       
        Else
            best_product = {"0", "0", "0"}
        End If
        Return best_product
    End Function
        
    Protected Sub add_wishlist(ByVal para1 As String, ByVal para2 As String)
       
       
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
                    Dim aisr_optionid As String = aisr(0), aisr_optvalueid As String = ""
                    Try
                        aisr_optvalueid = aisr(1)
                    Catch ex As Exception
                        Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", _
                                       "MyAdvan-Global Error encountered by DAQ in the " + Request.ServerVariables("URL"), _
                                        strArr(2).ToString.Trim, False, "", "")
                    End Try
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
                    Dim tmp_list As String = ""
                    If aiir_typevalue <> "" Then
                        tmp_list = ch_num + "&nbsp;ch,&nbsp;" + air_value + "&nbsp;bits,&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + ",&nbsp;" + aiir_typevalue
                    Else
                        tmp_list = ch_num + "&nbsp;ch,&nbsp;" + air_value + "&nbsp;bits,&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + "&nbsp;" + aiir_typevalue
                    End If
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
                    'If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        'sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, best_pid, best_piece)
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, intersect_pids, "")
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
                   
                Case "AO"
                    Dim aor() As String = Split(strArr(1), "^")
                    Dim aor_optionid As String = aor(0)
                    Dim aor_optvalueid As String = ""
                    Dim aor_value As String = ""
                    Try
                        aor_optvalueid = aor(1)
                        aor_value = aor(2)
                    Catch ex As Exception
                        Util.SendEmail("tc.chen@advantech.eu,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "DAQ Error email,AO:" + strArr(1).ToString(), ex.ToString(), False, "", "")
                    End Try                   
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
                    ' If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, intersect_pids, "")
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
                    ' If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
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
                            description = ch_num + "&nbsp;TTL&nbsp;ch&nbsp;"
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
                    'If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
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
						
                        
                     
                    
                    Dim counter_mif() As String = Split(strArr(2), "^")
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
                    ' If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
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
                    Dim tmp_list As String =  ""
                    If aiir_typevalue <> "" Then
                        tmp_list = strArr(0) + "&nbsp;ch,&nbsp;" + air_value + "&nbsp;bits,&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + ",&nbsp;" + aiir_typevalue
                    Else
                        tmp_list  = strArr(0) + "&nbsp;ch,&nbsp;" + air_value + "&nbsp;bits,&nbsp;" + aisr_value + ",&nbsp;" + aiir_value + "&nbsp;" + aiir_typevalue
                    End If
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
                    'If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, intersect_pids, "")
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
                    Dim tmp_list As String = ch_num + "&nbsp;ch,&nbsp;" + aor_value + "&nbsp;bits,&nbsp;" + aoort_value + "&nbsp;" + aoorg_value
                    
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
                    'If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, tmp_optionvalueid, tmp_list, intersect_pids, "")
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
                    ' If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
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
                            description = ch_num + "&nbsp;TTL&nbsp;ch&nbsp;"
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
                    'If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
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
                    ' If best_pid = "0" Then
                    If intersect_pids = "" OrElse intersect_pids = ";" Then
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, "", "")
                    Else
                        sql00 = "insert into  DAQ_wishlist_tmp (seq,sessionid,class,channel_type,channel_num,value_ids,description,productids,piece)"
                        sql00 = sql00 + String.Format(" values ({0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", getmaxreq(), Session.SessionID, para1, ch_type, ch_num, optionvalueid, description, intersect_pids, "")
                    End If
                    ''''                                     
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
            End Select
            
            
            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
        End If
        
        'get list from DB'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        Dim sql As String = "SELECT * FROM DAQ_wishlist_tmp WHERE sessionid = '" + Session.SessionID + "' order by seq asc;"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql) : Dim show_items As String = "" : Dim ceshi As String = "<hr>"
        Dim delimgurl As String = "./image/delete-1.png"
        If HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "" Then
            If HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-cn" OrElse HttpContext.Current.Session("Browser_lan").ToString.ToLower = "zh-tw" Then
                delimgurl = "./image/jdelete-1.png"
            End If
        End If
        If dt2.Rows.Count > 0 Then
            For i As Integer = 0 To dt2.Rows.Count - 1
                If i Mod 2 = 0 Then
                    show_items += String.Format("<div class='wishlist_cell_1'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"), delimgurl)
                Else
                    show_items += String.Format("<div class='wishlist_cell_1' style='background-color:#fff;'><b>{0}:</b>&nbsp;{1}</div><div class='wishlist_cell_2' style='background-color:#fff;'><a href='javascript:void(0);'><img src='{4}' onclick=""del_wishlist('{2}','{3}');"" border='0'></a></div>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("seq"), dt2.Rows(i).Item("sessionid"),delimgurl)
                End If
                'ceshi = ceshi + String.Format("<b>{0}</b>&nbsp;{1}&nbsp;<b><font color='#FF0000'>[{2}]</font></b>&nbsp;&nbsp;<font color='#FF0000'>({3})</font><br>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("productids").ToString, dt2.Rows(i).Item("piece").ToString)
            Next
            
        End If
        Me.wishlist.InnerHtml = show_items
        ''''''''''''''''''''''test yong
        ''''
      
        'test.Text = ceshi
        '''''''''''''''''''''''''''''test yong end
    End Sub
    Protected Function getmaxreq() As Int32
        Dim maxseq As String = dbUtil.dbExecuteScalar("MYLOCAL", "select max(seq) from DAQ_wishlist_tmp")
        Dim numseq As Int32 = Convert.ToInt32(maxseq) + 1
        Return numseq
    End Function
        
    Protected Sub di_channel_type_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If dich_ttl.Value.Trim <> "" Then
            dich_isolation.Value = dich_ttl.Value.Trim
        End If
        If dich_isolation.Value.Trim <> "" Then
            dich_ttl.Value = dich_isolation.Value.Trim
        End If
        If di_channel_type.SelectedValue = "di_channel_ttl" Then
            dich_ttl_TR.Visible = True : DI1image_TR.Visible = True : dich_isolation_TR.Visible = False : sm_TR.Visible = False : HTML_TR.Visible = False : DI2image_TR.Visible = False
            dich_ttl_TR_br.Visible = True
        End If
        If di_channel_type.SelectedValue = "di_channel_isolation" Then
            DI2image_TR.Visible = True : dich_isolation_TR.Visible = True : sm_TR.Visible = True : HTML_TR.Visible = True : dich_ttl_TR.Visible = False : DI1image_TR.Visible = False
            dich_ttl_TR_br.Visible = False 
            
            Dim STR_MIN As String = "", STR_MAX As String = ""
          
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                STR_MIN = min_str + ": <select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = max_str + ": <select name='diir_max' id='diir_max'><option value ='12'>12</option><option value ='24'>24</option><option value ='30'>30</option><option value ='50' >50</option>	</select>"
            End If
            If RB1.SelectedValue = "2" Then
                STR_MIN = min_str + ": <select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = max_str + ": <select name='diir_max' id='diir_max'><option value ='30'>30</option><option value ='50' >50</option></select>"
            End If
            HTML_TD.InnerHtml = STR_MIN + "<BR>" + STR_MAX
        End If
  
    End Sub
    Protected Sub di_channel_type2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim getdichnennl As String = ""
        If dich_ttl2.Value.Trim <> "" Then getdichnennl = dich_ttl2.Value.Trim
        If dich_isolation2.Value.Trim <> "" Then getdichnennl = dich_isolation2.Value.Trim
        dich_isolation2.Value = getdichnennl
        dich_ttl2.Value = getdichnennl 
      
        
        
        If di_channel_type2.SelectedValue = "di_channel_ttl" Then
            dich_ttl_TR2.Visible = True : dich_ttl_TR2_br.Visible = True : DI1image_TR2.Visible = True : dich_isolation_TR2.Visible = False : sm_TR2.Visible = False : HTML_TR2.Visible = False : DI2image_TR2.Visible = False
           
        End If
        If di_channel_type2.SelectedValue = "di_channel_isolation" Then
            DI2image_TR2.Visible = True : dich_isolation_TR2.Visible = True : sm_TR2.Visible = True : HTML_TR2.Visible = True : dich_ttl_TR2_br.Visible = False : dich_ttl_TR2.Visible = False : dich_ttl_TR2_br.Visible = False : DI1image_TR2.Visible = False
            Dim STR_MIN As String = "", STR_MAX As String = ""
          
            If RB1.SelectedValue = "1" OrElse RB1.SelectedValue = "" Then
                STR_MIN = min_str + ": <select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = max_str + ": <select name='diir_max' id='diir_max'><option value ='12'>12</option><option value ='24'>24</option><option value ='30'>30</option><option value ='50' >50</option>	</select>"
            End If
            If RB1.SelectedValue = "2" Then
                STR_MIN = min_str + ": <select name='diir_min' id='diir_min'><option value ='5'>5</option><option value ='10'>10</option></select>"
                STR_MAX = max_str + ": <select name='diir_max' id='diir_max'><option value ='30'>30</option><option value ='50' >50</option></select>"
            End If
            HTML_TD2.InnerHtml = STR_MIN + "<BR>" + STR_MAX
        End If
  
    End Sub
    Protected Sub do_channel_type_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim do_chnanel_value As String = ""
        If doch_ttl.Value.Trim <> "" Then do_chnanel_value = doch_ttl.Value.Trim
        If doch_isolation.Value.Trim <> "" Then do_chnanel_value = doch_isolation.Value.Trim
        If doch_relay.Value.Trim <> "" Then do_chnanel_value = doch_relay.Value.Trim
        doch_ttl.Value = do_chnanel_value
        doch_isolation.Value = do_chnanel_value
        doch_relay.Value = do_chnanel_value
        
        
        si_1_1.Visible = False : si_1_2.Visible = False : si_1_1_br.Visible = False
        si_2_1.Visible = False : si_2_2.Visible = False : si_2_3.Visible = False
        si_3_1.Visible = False : si_3_2.Visible = False : si_3_3.Visible = False : Dim or_option As String = "" : Dim cr_option As String = ""
        If do_channel_type.SelectedValue = "do_channel_ttl" Then
            si_1_1.Visible = True : si_1_2.Visible = True : si_1_1_br.Visible = True
        End If
        If do_channel_type.SelectedValue = "do_channel_isolation" Then
            si_2_1.Visible = True : si_2_2.Visible = True : si_2_3.Visible = True
            Dim sql As String = "SELECT OPTIONID, OPTION_VALUE, OPTION_VALUEID FROM DAQ_spec_options_values WHERE OPTIONID =  '14' AND  option_value <> '-' ORDER BY ORDER_BY ASC"
            or_option = getOption(sql)
            If (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-cn") Then
                si_2_2TD.InnerHtml = "输出范围 (V<sub>DC</sub>):<select name ='door' ID='door'>" + or_option + "</select>"
            ElseIf (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-tw") Then
                si_2_2TD.InnerHtml = "輸出範圍 (V<sub>DC</sub>):<select name ='door' ID='door'>" + or_option + "</select>"
            Else
                si_2_2TD.InnerHtml = "Output Range (V):<select name ='door' ID='door'>" + or_option + "</select>"
            End If
           
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
            If (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-cn") Then
                si_3_2TD.InnerHtml = "触点容量:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            ElseIf (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-tw") Then
                si_3_2TD.InnerHtml = "觸點負載:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            Else
                si_3_2TD.InnerHtml = "Contact Rating:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            End If
            
        End If
    End Sub
    Protected Sub do_channel_type2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim getdovalue As String = ""
        If doch_ttl2.Value.Trim <> "" Then getdovalue = doch_ttl2.Value.Trim
        If doch_isolation2.Value.Trim <> "" Then getdovalue = doch_isolation2.Value.Trim
        If doch_relay2.Value.Trim <> "" Then getdovalue = doch_relay2.Value.Trim
        doch_ttl2.Value = getdovalue : doch_isolation2.Value = getdovalue : doch_relay2.Value = getdovalue
        
        
            si_1_12.Visible = False : si_1_22.Visible = False : si_1_12_br.Visible = False
            si_2_12.Visible = False : si_2_22.Visible = False : si_2_32.Visible = False
            si_3_12.Visible = False : si_3_22.Visible = False : si_3_32.Visible = False : Dim or_option As String = "" : Dim cr_option As String = ""
            If do_channel_type2.SelectedValue = "do_channel_ttl" Then
                si_1_12.Visible = True : si_1_22.Visible = True : si_1_12_br.Visible = True
            End If
            If do_channel_type2.SelectedValue = "do_channel_isolation" Then
                si_2_12.Visible = True : si_2_22.Visible = True : si_2_32.Visible = True
                Dim sql As String = "SELECT OPTIONID, OPTION_VALUE, OPTION_VALUEID FROM DAQ_spec_options_values WHERE OPTIONID =  '14' AND  option_value <> '-' ORDER BY ORDER_BY ASC"
            or_option = getOption(sql)
            If (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-cn") Then
                si_2_2TD2.InnerHtml = "输出范围 (V<sub>DC</sub>):<select name ='door' ID='door'>" + or_option + "</select>"
            ElseIf (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-tw") Then
                si_2_2TD2.InnerHtml = "輸出範圍 (V<sub>DC</sub>):<select name ='door' ID='door'>" + or_option + "</select>"
            Else
                si_2_2TD2.InnerHtml = "Output Range (V):<select name ='door' ID='door'>" + or_option + "</select>"
            End If
                
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
            If (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-cn") Then
                si_3_2TD2.InnerHtml = "触点容量:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            ElseIf (HttpContext.Current.Session("Browser_lan") IsNot Nothing AndAlso HttpContext.Current.Session("Browser_lan").ToString() <> "") AndAlso (Session("Browser_lan").ToString.ToLower = "zh-tw") Then
                si_3_2TD2.InnerHtml = "觸點負載:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            Else
                si_3_2TD2.InnerHtml = "Contact Rating:<br /><select name ='docr' id='docr'>" + cr_option + "</select>"
            End If
           
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
        Dim userid As String = ""
        If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
        Else
            userid = Session("user_id").ToString()
        End If
        If RB1.SelectedValue = "1" Then
            Dim avail_bus As String = Request("q3")
            Dim os As String = Request("q4")
            sql = "INSERT INTO DAQ_stats_questions (no,sessionid ,daq_type,platform,other_platform,avail_bus,os,timestamp,user_id) values ( " & _
                " " + max_no + ",'" + Session.SessionID + "','" + RB1.SelectedValue + "','" + RB2.SelectedValue + "',N'" + Request("q2_o").ToString.Replace("'", "''") + "','" + avail_bus + "','" + os + "','" + System.DateTime.Now + "','" + userid + "') "
        ElseIf RB1.SelectedValue = "2" Then
            Dim prefer_interface As String = Request("q3")
            'Dim prefer_interface_oth As String = Request("q5_o").ToString.Replace("'", "''")
            Dim prefer_interface_oth As String = ""
            If Request("q5_o") IsNot Nothing Then
                prefer_interface_oth = Request("q5_o").ToString.Replace("'", "''")
            End If
            Dim protocal As String = Request("q4")
            Dim protocal_oth As String = Request("q6_o").ToString.Replace("'", "''")
            sql = "INSERT INTO DAQ_stats_questions  (no,sessionid,daq_type,platform,other_platform,prefer_interface, other_prefer_interface,protocal,other_protocal,timestamp,user_id) values (" & _
                  "  " + max_no + ",'" + Session.SessionID + "', '" + RB1.SelectedValue + "','" + RB2.SelectedValue.Replace("'", "''") + "',N'" + Request("q2_o").ToString.Replace("'", "''") + "','" + prefer_interface + "',N'" + prefer_interface_oth + "', '" + protocal + "', N'" + protocal_oth + "','" + System.DateTime.Now + "','" + userid + "') "
           
        End If
        
        Try
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        Catch ex As Exception
           
            Exit Sub
        End Try
    
        '''''''''''''''''''''''''''''
         dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM DAQ_available_list_tmp WHERE (avail <>  'q4' OR avail IS NULL ) AND sessionid =  '" + Session.SessionID + "'")
        Dim sql_out As String = "SELECT * FROM DAQ_wishlist_tmp WHERE sessionid = '" + Session.SessionID + "' order by seq asc;"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql_out)  : Dim ceshi As String = "<hr>"
        If dt2.Rows.Count > 0 Then
            For i As Integer = 0 To dt2.Rows.Count - 1               
               ' ceshi = ceshi + String.Format("<b>{0}</b>&nbsp;{1}&nbsp;<b><font color='#FF0000'>[{2}]</font></b>&nbsp;&nbsp;<font color='#FF0000'>({3})</font><br>", dt2.Rows(i).Item("class"), dt2.Rows(i).Item("description"), dt2.Rows(i).Item("productids").ToString, dt2.Rows(i).Item("piece").ToString)
          
                Dim goodpidlist As String = intersect_array(dt2.Rows(i).Item("productids").ToString, get_DAQ_available_list_tmp_pids)
               
                
                Dim best_pid As String = "", best_p() As String, best_piece As String = ""
                If goodpidlist <> "" AndAlso goodpidlist <> ";" Then
                    best_p = getCheapProduct(goodpidlist, dt2.Rows(i).Item("channel_type").ToString, dt2.Rows(i).Item("channel_num").ToString)
                    best_pid = best_p(0)
                    best_piece = best_p(1)                    
                End If
                Dim sql00 As String = ""
                If best_pid = "0" Then
                    sql00 = "update DAQ_wishlist_tmp set cheap_pid ='' , piece = '' where seq = '" + dt2.Rows(i).Item("seq").ToString + "'"
                    
                ElseIf best_pid = "77" Then
                    sql00 = "update DAQ_wishlist_tmp set cheap_pid ='" + best_pid + "' , piece = '',other_col= '" + best_piece + "' where seq = '" + dt2.Rows(i).Item("seq").ToString + "'"
                Else
                        
                    sql00 = "update DAQ_wishlist_tmp set cheap_pid ='" + best_pid + "' , piece = '" + best_piece + "' where seq = '" + dt2.Rows(i).Item("seq").ToString + "'"
                                     
                End If
                ''''                                     
                dbUtil.dbExecuteNoQuery("MYLOCAL", sql00)
               
            Next
        End If    
        Call search_fun()
        Me.MultiView1.ActiveViewIndex = 1
        
       ' searchview2.Update()
        ''''''''''''''''''''''''''''''''''
    End Sub
    Protected Function get_DAQ_available_list_tmp_pids() As String
        Dim return_avail_pids As String = ""
      
        Dim sql As String = "SELECT productid FROM DAQ_available_list_tmp WHERE sessionid = '" + Session.SessionID + "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                If Not IsDBNull(dt.Rows(i).Item("productid")) AndAlso dt.Rows(i).Item("productid").ToString <> "" Then
                    return_avail_pids = return_avail_pids + dt.Rows(i).Item("productid").ToString  + ";"
                End If
               
            Next
           
        End If
        Return return_avail_pids
    End Function
    
        
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
        
    '''''''''''''''''''''''''''''''''''''' search
    Protected Sub search_fun()
        emailme.Visible =True 
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
                  
                Me.haslist1.Visible = False : Me.haslist2.Visible = False : Me.hasno.Visible = True : emailme.Visible = False
            End If
            '' chepidisnull
            Dim dtnullcheap As DataTable = getnullProductDetail()
            If dtnullcheap.Rows.Count > 0 Then
                rp2.DataSource = dtnullcheap
                rp2.DataBind()
            Else
                rp2.DataSource = ""
                rp2.DataBind()
            End If
            ''end
        Else
            Me.haslist1.Visible = False : Me.haslist2.Visible = False : Me.hasno.Visible = True : emailme.Visible = False
        End If
        
    End Sub
    Protected Function getnullProductDetail() As DataTable
        Dim sqlnullcheepid As String = "select * from DAQ_wishlist_tmp WHERE sessionid =  '" + Session.SessionID + "' and cheap_pid = '' order by seq"
        Dim dtnull As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sqlnullcheepid)
        Return dtnull
    End Function
    Protected Function getProductDetail() As DataTable
      
        Dim sql As String = "SELECT a.class, a.channel_type, a.channel_num, a.value_ids, a.description as wish_descr, a.cheap_pid,a.other_col," & _
                           " a.piece, 	b.SKU, b.SKU as model_name, 	b.PRODUCTNAME, b.DESCRIPTION,b.DESCRIPTION_J,b.DESCRIPTION_F, b.BUYLINK, " & _
                           " b.BUYLINK_J,b.BUYLINK_F,b.SUPPORTLINK, b.LISTPRICE,  b.SKU as advise_item , '' as img_url  FROM DAQ_wishlist_tmp as  a " & _
                           " Inner Join DAQ_products as b ON a.cheap_pid = b.PRODUCTID " & _
                           "  WHERE a.sessionid = '" + Session.SessionID + "'  and a.cheap_pid <> ''  ORDER BY a.cheap_pid	"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)             
        If dt.Rows.Count > 0 Then          
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim sku As String = dt.Rows(i).Item("SKU")
                Dim P() As String = Split(sku, "-")
                If P.Length > 2 Then
                    dt.Rows(i).Item("model_name") = P(0) + "-" + P(1)
                    dt.Rows(i).Item("advise_item") = P(0)
                End If             
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
                            End If                          
                        ElseIf lan = "zh-tw" Then
                            If Not IsDBNull(.Item("BUYLINK_F")) AndAlso .Item("BUYLINK_F").ToString.Trim <> "" Then
                                .Item("BUYLINK") = .Item("BUYLINK_F")
                            End If
                        End If
                    End With
                Next
            End If
            dt.AcceptChanges()
        End If
      
        Return dt
    End Function
    Protected Sub getother(ByVal item As String)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT top 4 * FROM DAQ_Other_Prods where item ='" + item + "'")     
        dt.AcceptChanges()
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            For i As Integer = 0 To dt.Rows.Count - 1
                With dt.Rows(i)
                    If lan = "zh-cn" Then
                        .Item("description") = .Item("Simplified_Description")
                        .Item("details") = .Item("Simplified_Details")
                    ElseIf lan = "zh-tw" Then
                        .Item("description") = .Item("Traditional_Description")
                        .Item("details") = .Item("Traditional_Details")
                    End If
                End With
            Next             
        End If
        dt.AcceptChanges()
        dl1.DataSource = dt
        dl1.DataBind()
    End Sub

    Protected Sub again1_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
         Me.MultiView1.ActiveViewIndex = 0
    End Sub
    Protected Sub rp1_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            Dim ltl As Literal = DirectCast(e.Item.FindControl("L1"), Literal)
            If DataBinder.Eval(e.Item.DataItem, "cheap_pid").ToString.Trim = "77" Then
                ltl.Text = DataBinder.Eval(e.Item.DataItem, "other_col").ToString
            End If                 
            Dim ltl2 As Literal = DirectCast(e.Item.FindControl("L2"), Literal)
            If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
                Dim lan As String = Session("Browser_lan").ToString.ToLower
                Select Case lan
                    Case "zh-cn"
                        If DataBinder.Eval(e.Item.DataItem, "DESCRIPTION_J").ToString.Trim <> "" Then
                            ltl2.Text = DataBinder.Eval(e.Item.DataItem, "DESCRIPTION_J").ToString.Trim                     
                        Else
                            ltl2.Text = DataBinder.Eval(e.Item.DataItem, "DESCRIPTION").ToString.Trim
                        End If
                    Case "zh-tw"
                        If DataBinder.Eval(e.Item.DataItem, "DESCRIPTION_F").ToString.Trim <> "" Then
                            ltl2.Text = DataBinder.Eval(e.Item.DataItem, "DESCRIPTION_F").ToString.Trim
                        Else
                            ltl2.Text = DataBinder.Eval(e.Item.DataItem, "DESCRIPTION").ToString.Trim
                        End If
                    Case Else
                        ltl2.Text = DataBinder.Eval(e.Item.DataItem, "DESCRIPTION").ToString.Trim
                End Select
            
            End If
        End If
    End Sub
    Protected Sub rp2_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            Dim ltl As Literal = DirectCast(e.Item.FindControl("rp2lit"), Literal)                   
            If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
                Dim lan As String = Session("Browser_lan").ToString.ToLower
                Select Case lan
                    Case "zh-cn"
                        ltl.Text = "未找到和您的查询 - <b>" + DataBinder.Eval(e.Item.DataItem, "description").ToString + "</b> - 相匹配的<br>产品." & _
                              " 您可以点击 <a href=""similar.aspx?pid=YES&seq=" + DataBinder.Eval(e.Item.DataItem, "seq").ToString + """ rel=""gb_page_center[640, 450]"" style=""text-decoration: underline;"" title=""备选方案"">" & _
                              "备选方案.</a>"
                    Case "zh-tw"
                        ltl.Text = "很抱歉! 無合適方案符合 - <b>" + DataBinder.Eval(e.Item.DataItem, "description").ToString + "</b> - 您的需求.<br>" & _
                               " 請參考其它 <a href=""similar.aspx?pid=YES&seq=" + DataBinder.Eval(e.Item.DataItem, "seq").ToString + """ rel=""gb_page_center[640, 450]"" style=""text-decoration: underline;"" title=""备选方案"">" & _
                               "替代方案.</a>"
                    Case Else
                        ltl.Text = "Sorry, your search - <b>" + DataBinder.Eval(e.Item.DataItem, "description").ToString + "</b> - did not match <br>any existing products." & _
                            "Or <a href=""similar.aspx?pid=YES&seq=" + DataBinder.Eval(e.Item.DataItem, "seq").ToString + """ rel=""gb_page_center[640, 450]"" style=""text-decoration: underline;"" title=""See Alternative Options"">" & _
                            "see alternative options.</a>"
                End Select
            Else
                ltl.Text = "Sorry, your search - <b>" + DataBinder.Eval(e.Item.DataItem, "description").ToString + "</b> - did not match <br>any existing products." & _
                           "Or <a href=""similar.aspx?pid=YES&seq=" + DataBinder.Eval(e.Item.DataItem, "seq").ToString + """ rel=""gb_page_center[640, 450]"" style=""text-decoration: underline;"" title=""See Alternative Options"">" & _
                           "see alternative options.</a>"
            End If
        End If
    End Sub

    Protected Sub sendemail_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        '     
       FROM_Email = EMAIL.Text.ToString.Trim 
        TO_Email = "ia@advantech.com.tw"      
        BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "[DAQ Your Way] You have a new comment"
        '
        MailBody = MailBody & "<html><body><center>"
        ' MailBody = MailBody & strStyle
        MailBody = MailBody & "<table width=""600"" cellpadding=""3"" cellspacing=""3"">"
        MailBody = MailBody & "<tr><td colspan=""2"" bgcolor=""#CCFFCC"" align=""center""><b>Customer left comment on DAQ Your Way</b></td></tr>"
        MailBody = MailBody & "<tr><td width=""180"" bgcolor=""#F3F3F3"">Customer name:</td><td>" + name.Value + "</td></tr>"
        MailBody = MailBody & "<tr><td bgcolor=""#F3F3F3"">Customer EMail:</td><td><a href=""mailto=" + EMAIL.Text + """>" + EMAIL.Text + "</a></td></tr>"
        MailBody = MailBody & " <tr><td bgcolor=""#F3F3F3"">Customer comment:</td><td align=""left"">" + rp(message.Value.ToString) + "</td> </tr> </table>"
        MailBody = MailBody & "</center></body></html>"
       
        Try
            Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Catch ex As Exception
                   
        End Try
        name.Value = ""
        EMAIL.Text = ""
        message.Value = ""
        Util.JSAlert(Me.Page, "Thanks for your comment!")
    End Sub
    Protected Function rp(ByVal str As String) As String
        If str.Length > 0 Then
            str = Replace(str, "<", "﹤")
            str = Replace(str, ">", ",﹥")
            str = Replace(str, vbcrlf, "<br/>")
         
        End If
        Return str
    End Function
    Public title_str As String = "", clear_all_src As String = "./image/clearall_j.gif", tb_bg As String = "./IMAGE/BG2.jpg", custom As String = "./image/AGAIN-2_r4_c2.jpg"
    Public tb_bgno As String = "./IMAGE/BG2.jpg"
    Public Q1title_str As String = "", search_crlterla_src As String = "", Q5_sm_str As String = "", Q2title_str As String = "", Q5title_str As String = ""
    Public Q3title_str1 As String = "", Q3title_str2 As String = "", Q4title_str1 As String = "", Q4title_str2 As String = ""
    Public img_search_result_id_src As String = "", emailme_str As String = "", yaneed_src As String = ""
    Public pinglunid_src As String = "", sendemail_src As String = ""
    Public tjpl1_str As String = "", tjpl2_str As String = "", tjpl3_str As String = "", tjpl4_str As String = ""
    Public no_resultid1_str As String, no_resultid2_str As String, no_resultid3_str As String, no_resultid4_str As String
    Public no_resultid5_str As String, no_resultid6_str As String, no_resultid7_str As String
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    title_str = "请依序回答如下问题："
                    Q1title_str = "您想要如何将数据模块集成到您的系统中?"
                    Q2title_str = "首选的平台信息?"
                    Q3title_str1 = "可用接线方式" : Q3title_str2 = "接口界面"
                    Q4title_str1 = "操作系统" : Q4title_str2 = "协议"
                    labQ1titleid.CssClass = "zhls"
                    search_crlterla_src = "./image/title-6_j.jpg"
                    Q5_sm_str = "在输入有效值后，请点选每个""添加至搜索条件"""
                    img_search_result_id_src = "./image/search_result_j.png"
                    emailme_str = "./image/email_me_j.png"
                    yaneed_src = "./image/bar02_j.jpg"
                    pinglunid_src = "./image/w-2_09_j.jpg"
                    sendemail_src = "./image/w-2_14_j.jpg"
                    tjpl1_str = "我们非常感谢您能分享您的意见,建议,或者反馈下面信息。"
                    tjpl2_str = "您的评论" : tjpl3_str = "您的姓名:" : tjpl4_str = "您的邮箱:" : Q5title_str = "您需要什么样的数据采集功能?"
                    no_resultid1_str = "未找到和您查询相匹配的产品."
                    no_resultid2_str = "建议您可以:"
                    no_resultid3_str = "选择备选方案."
                    no_resultid4_str = "尝试其他规格产品."
                    no_resultid5_str = "点击"
                    no_resultid6_str = """ 客制化 """
                    no_resultid7_str = "，选择客制化服务。"
                    tb_bg = "./IMAGE/BG2_1_j.jpg" : again1.ImageUrl = "./image/AGAIN-2_r2_c2_j.jpg" : again2.ImageUrl = "./image/AGAIN-2_r2_c2_j.jpg"
                    custom = "./image/AGAIN-2_r4_c2_j.jpg" : tb_bgno = "./IMAGE/BG2_j.jpg"
                    'Q1text
                    For i As Integer = 0 To RB1.Items.Count - 1
                        If Me.RB1.Items(i).Value = "1" Then
                            Me.RB1.Items(i).Text = "插入式数据卡"
                        End If
                        If Me.RB1.Items(i).Value = "2" Then
                            Me.RB1.Items(i).Text = "远程数据采集模块"
                        End If
                    Next
                    'end
                    'Q2text
                    For i As Integer = 0 To RB2.Items.Count - 1
                        If Me.RB2.Items(i).Value = "1" Then Me.RB2.Items(i).Text = "单板计算机"
                        If Me.RB2.Items(i).Value = "2" Then Me.RB2.Items(i).Text = "主板"
                        If Me.RB2.Items(i).Value = "3" Then Me.RB2.Items(i).Text = "嵌入式计算机"
                        If Me.RB2.Items(i).Value = "4" Then Me.RB2.Items(i).Text = "平板计算机"
                        If Me.RB2.Items(i).Value = "5" Then Me.RB2.Items(i).Text = "计算机样机"
                        If Me.RB2.Items(i).Value = "6" Then Me.RB2.Items(i).Text = "没有优先选择"
                        If Me.RB2.Items(i).Value = "7" Then Me.RB2.Items(i).Text = "其它 <input type=""text"" name=""q2_o"" id=""q2_o"" >"
                    Next
                    'end
                    'Q5 tupian
                    img5Yi.ImageUrl = "./image/jtitle-1.jpg" : img5Er.ImageUrl = "./image/jtitle-2.jpg" : img5San.ImageUrl = "./image/jtitle-3.jpg"
                    img5Si.ImageUrl = "./image/jtitle-4.jpg" : img5Wu.ImageUrl = "./image/jtitle-5.jpg"
                    img5Yi2.ImageUrl = "./image/jtitle-1.jpg" : img5Er2.ImageUrl = "./image/jtitle-2.jpg" : img5San2.ImageUrl = "./image/jtitle-3.jpg"
                    img5Si2.ImageUrl = "./image/jtitle-4.jpg" : img5Wu2.ImageUrl = "./image/jtitle-5.jpg"
                    'end
                    'add.png
                    Dim imgCop() As ImageButton = {Me.AIimage, AIimage, AIimage2, AOimage, AOimage2, DI1image, _
                                                  DI2image, DI1image2, DI2image2, DO1image, DO2image, DO3image, DO1image2, _
                                                  DO2image2, DO3image2, COimage, COimage2}
                    For i As Integer = 0 To imgCop.Length - 1
                        Dim img As ImageButton = imgCop(i)
                        img.ImageUrl = "./image/jadd.png"
                    Next
                    ''end
                    '5
                    Dim channels() As Label = {channel1, channel2, channel3, channel4, channel5, channel6, channel7, channel8, channel9, channel10, _
                                               channel11, channel12, channel13, channel14, channel15, channel16}
                    'For i As Integer = 1 To 16
                    '    Dim channel As Label = Me.FindControl("channel" + i.ToString())                      
                    'Next
                    For i As Integer = 0 To channels.Length - 1
                        Dim Lab As Label = channels(i)
                        Lab.Text = "通道"
                    Next
                    Dim fbls() As Label = {fbl1, fbl2, fbl3, fbl4}
                    For i As Integer = 0 To fbls.Length - 1
                        CType(fbls(i), Label).Text = "分辨率"
                    Next
                    Dim tdlxs() As Label = {tdlx1, tdlx2, tdlx3, tdlx4}
                    For i As Integer = 0 To tdlxs.Length - 1
                        CType(tdlxs(i), Label).Text = "通道类型"
                    Next
                    scpl1.Text = "输出频率"
                    scfw1.Text = "输出范围" : scfw2.Text = "输出范围"
                    srfw1.Text = "输入范围" : srfw2.Text = "输入范围"
                    cyl1.Text = "采样率" : cyl2.Text = "采样率"
                    zdsrfw1.Text = "最大输入范围"
                    hidd1.Value = "jj"
                    'end
                    '''''''''''''''
                    imgbzy.ImageUrl = "./image/jq_image-1.jpg"
                    '''''''''''''''
                    lastimg.ImageUrl = "./image/jjw-2_11.jpg"
                    nn1.Text = "Logic 1 输入电压(V<sub>DC</sub>)"
                    jg1 = "规格书" : jg2 = "在线购买" : jg3 = "备选方案" : jg4 = "主要规格" : jg5 = "详情"
                    fsdwyx = "发送搜索结果到我的邮箱"
                    xqkz = "寻求客制化服务"
                    '''''''''''''''
                  
                Case "zh-tw"
                    title_str = "請依序回答下列問題："
                     clear_all_src = "./image/clearall_f.gif"
                    Q1title_str = "資料擷取產品的Form Factor?"
                    Q2title_str = "電腦平台規格?"
                    Q3title_str1 = "匯流排規格" : Q3title_str2 = "接口界面"
                    Q4title_str1 = "作業系統" : Q4title_str2 = "協議"
                    labQ1titleid.CssClass = "zhls"
                    search_crlterla_src = "./image/title-6_f.jpg"
                    Q5_sm_str = "當您完成規格需求的設定，請按『加入搜尋清單』"
                    img_search_result_id_src = "./image/search_result_f.png"
                    emailme_str = "./image/email_me_f.png"
                    yaneed_src = "./image/bar02_f.jpg"
                    pinglunid_src = "./image/w-2_09_f.jpg"
                    sendemail_src = "./image/w-2_14_f.jpg"
                    tjpl1_str = "歡迎提供對DAQ Your Way的建議，您寶貴的意見將作為研華改進的參考。"
                    tjpl2_str = "您的評論" : tjpl3_str = "姓名:" : tjpl4_str = "eMail:" : Q5title_str = "資料擷取的需求規格?"
                    no_resultid1_str = "很抱歉！無合適方案符合您的需求."
                    no_resultid2_str = "其它建議:"
                    no_resultid3_str = "其它替代方案建議."
                    no_resultid4_str = "選擇其它規格."
                    no_resultid5_str = "請點選尋求"
                    no_resultid6_str = """ 客製化"""
                    no_resultid7_str = "服務."
                    tb_bg = "./IMAGE/BG2_1_f.jpg" : again1.ImageUrl = "./image/AGAIN-2_r2_c2_f.jpg": again2.ImageUrl = "./image/AGAIN-2_r2_c2_f.jpg"
                     custom = "./image/AGAIN-2_r4_c2_f.jpg" : tb_bgno = "./IMAGE/BG2_f.jpg"
                    'Q1text
                    For i As Integer = 0 To RB1.Items.Count - 1
                        If Me.RB1.Items(i).Value = "1" Then
                            Me.RB1.Items(i).Text = "Plug-in資料擷取卡"
                        End If
                        If Me.RB1.Items(i).Value = "2" Then
                            Me.RB1.Items(i).Text = "遠端資料擷取模組"
                        End If
                    Next
                    'end
                    'Q2text
                    For i As Integer = 0 To RB2.Items.Count - 1
                        If Me.RB2.Items(i).Value = "1" Then Me.RB2.Items(i).Text = "單板電腦"
                        If Me.RB2.Items(i).Value = "2" Then Me.RB2.Items(i).Text = "主機板"
                        If Me.RB2.Items(i).Value = "3" Then Me.RB2.Items(i).Text = "嵌入式電腦(Box PC)"
                        If Me.RB2.Items(i).Value = "4" Then Me.RB2.Items(i).Text = "平台電腦(Panel PC)"
                        If Me.RB2.Items(i).Value = "5" Then Me.RB2.Items(i).Text = "嵌入式電腦模組"
                        If Me.RB2.Items(i).Value = "6" Then Me.RB2.Items(i).Text = "無"
                        If Me.RB2.Items(i).Value = "7" Then Me.RB2.Items(i).Text = "其它 <input type=""text"" name=""q2_o"" id=""q2_o"" >"
                    Next
                    'end
                    'Q5 tupian
                    img5Yi.ImageUrl = "./image/ftitle-1.jpg" : img5Er.ImageUrl = "./image/ftitle-2.jpg" : img5San.ImageUrl = "./image/ftitle-3.jpg"
                    img5Si.ImageUrl = "./image/ftitle-4.jpg" : img5Wu.ImageUrl = "./image/ftitle-5.jpg"
                    img5Yi2.ImageUrl = "./image/ftitle-1.jpg" : img5Er2.ImageUrl = "./image/ftitle-2.jpg" : img5San2.ImageUrl = "./image/ftitle-3.jpg"
                    img5Si2.ImageUrl = "./image/ftitle-4.jpg" : img5Wu2.ImageUrl = "./image/ftitle-5.jpg"
                    'end
                    'add.png
                    Dim imgCop() As ImageButton = {Me.AIimage, AIimage, AIimage2, AOimage, AOimage2, DI1image, _
                                                     DI2image, DI1image2, DI2image2, DO1image, DO2image, DO3image, DO1image2, _
                                                     DO2image2, DO3image2, COimage, COimage2}
                    For i As Integer = 0 To imgCop.Length - 1
                        Dim img As ImageButton = imgCop(i)
                        img.ImageUrl = "./image/fadd.png"
                    Next
                    'end
                    '5
                    Dim channels() As Label = {channel1, channel2, channel3, channel4, channel5, channel6, channel7, channel8, channel9, channel10, _
                                               channel11, channel12, channel13, channel14, channel15, channel16}                 
                    For i As Integer = 0 To channels.Length - 1
                        Dim Lab As Label = channels(i)
                        Lab.Text = "通道數"
                    Next
                    Dim fbls() As Label = {fbl1, fbl2, fbl3, fbl4}
                    For i As Integer = 0 To fbls.Length - 1
                        CType(fbls(i), Label).Text = "解析度(位元)"
                    Next
                    Dim tdlxs() As Label = {tdlx1, tdlx2, tdlx3, tdlx4}
                    For i As Integer = 0 To tdlxs.Length - 1
                        CType(tdlxs(i), Label).Text = "通道類型"
                    Next
                    scpl1.Text = "輸出速率"
                    scfw1.Text = "輸出範圍" : scfw2.Text = "輸出範圍"
                    srfw1.Text = "輸入範圍" : srfw2.Text = "輸入範圍"
                    cyl1.Text = "取樣速率" : cyl2.Text = "取樣速率"
                    zdsrfw1.Text = "最大輸出頻率"
                    hidd1.Value = "ff"
                    'end
                    '''''''''''''''
                    imgbzy.ImageUrl = "./image/fq_image-1.jpg"
                    SEARCH.ImageUrl="./image/fq_image-1_02.jpg"
                    '''''''''''''''
                    ACum.HRef = "https://member.advantech.com/profile.aspx?pass=estore_tw&lang=zh-tw"
                    lastimg.ImageUrl = "./image/ffw-2_11.jpg"
                    nn1.Text = "Logic 1 輸入電壓(V<sub>DC</sub>)"
                    jg1 = "規格表" : jg2 = "立即購買" : jg3 = "相近規格產品" : jg4 = "清單中的搜尋條件" : jg5 = "詳細資訊"
                    fsdwyx = "Email本方案給我"
                    xqkz = "尋求客製化解決方案服務"
                    '''''''''''''''
                Case Else
                    title_str = "Please answer the questions in order."
                    clear_all_src = "./image/clearall.gif"
                    Q1title_str = "How Do You Want The Data Acquisition Modules To Integrate with Your System ?"
                    Q2title_str = "Preferred Platform Info ?"
                    Q3title_str1 = "Available Bus" : Q3title_str2 = "Preferred Interface"
                    Q4title_str1 = "Operating System" : Q4title_str2 = "Protocal"
                    search_crlterla_src = "./image/title-6.jpg"
                    Q5_sm_str = "Please click each "" Add to Search Criteria "" after entering values."
                    img_search_result_id_src = "./image/search_result.png"
                    emailme_str = "./image/email_me.png"
                    yaneed_src = "./image/bar02.jpg"
                    pinglunid_src = "./image/w-2_09.jpg"
                    sendemail_src = "./image/w-2_14.jpg"
                    tjpl1_str = "We would appreciate it if you would share your comments, suggestions, or feedback below."
                    tjpl2_str = "Your Comments" : tjpl3_str = "Your Name" : tjpl4_str = "Your eMail" : Q5title_str = "What Kind of Data Acquisition Functions Do You Need ?"
                    no_resultid1_str = "Sorry, your search did not match any existing products."
                    no_resultid2_str = "Suggestions:"
                    no_resultid3_str = "See alternative options."
                    no_resultid4_str = "Try other criteria."
                    no_resultid5_str = "Click"
                    no_resultid6_str = "'Customize it'"
                    no_resultid7_str = "for customization service."
                    'Q5 tupian
                    img5Yi.ImageUrl = "./image/title-1.jpg" : img5Er.ImageUrl = "./image/title-2.jpg" : img5San.ImageUrl = "./image/title-3.jpg"
                    img5Si.ImageUrl = "./image/title-4.jpg" : img5Wu.ImageUrl = "./image/title-5.jpg"
                    img5Yi2.ImageUrl = "./image/title-1.jpg" : img5Er2.ImageUrl = "./image/title-2.jpg" : img5San2.ImageUrl = "./image/title-3.jpg"
                    img5Si2.ImageUrl = "./image/title-4.jpg" : img5Wu2.ImageUrl = "./image/title-5.jpg"
                    'end
            End Select
            
        End If
        labtitleid.Text = title_str
        clear_all.ImageUrl = clear_all_src
        labQ1titleid.Text = Q1title_str : labQ2titleid.Text = Q2title_str
        search_crlterla.ImageUrl = search_crlterla_src
        Q5_sm.Text = Q5_sm_str
        img_search_result_id.ImageUrl = img_search_result_id_src
        emailme.ImageUrl = emailme_str
        yaneed.ImageUrl = yaneed_src
        pinglunid.ImageUrl = pinglunid_src
        sendemail.ImageUrl = sendemail_src
        tjpl1.Text = tjpl1_str : tjpl2.Text = tjpl2_str : tjpl3.Text = tjpl3_str : tjpl4.Text = tjpl4_str : labQ5titleid.Text = Q5title_str
        no_resultid1.Text = no_resultid1_str : no_resultid2.Text = no_resultid2_str : no_resultid3.Text = no_resultid3_str : no_resultid4.Text = no_resultid4_str
        no_resultid5.Text = no_resultid5_str : no_resultid6.Text = no_resultid6_str : no_resultid7.Text = no_resultid7_str
        again1.ImageUrl = "./image/bai1.gif"
        again2.ImageUrl = "./image/bai1.gif"
        custom = "./image/bai1.gif"
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:HiddenField runat="server" ID="hidd1" />
    <script language="javascript" type="text/javascript">
        function xajax_available_list(q_no, o_id,v_id,sessionid) {
            var arrID = "";
         
            PageMethods.available_list_server(q_no + "#" + o_id + "#" + v_id + "#" + sessionid, OnPageMethods_1Succeeded, OnGetPriceError, arrID);
        }
        function OnPageMethods_1Succeeded(result, arrID, methodName) {        
            return true;
        }
        function OnGetPriceError(error, arrID, methodName) {

        }
        //////////////////////////////////////////////2
        function xajax_available_list2(itemvalue) {
            var arrID = "";          
            PageMethods.available_list_server200(itemvalue, OnPageMethods_1Succeeded200, OnGetPriceError200, arrID);
        }
        function OnPageMethods_1Succeeded200(result, arrID, methodName) {
           
            return true;
        }
        function OnGetPriceError200(error, arrID, methodName) {
//            if (error !== null) {  alert(error.get_message());  }
        }
        //////////////////////////////////////////
        function aiirselectChange(objid, id) {
            var obj = document.getElementById(objid);
            if (obj.value == "aiir_t^aiir_t^Temperature") {
                var str = "Type :<br>";
                var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
                if (strValue == "jj") { str = "类型 :<br>"; }
                if (strValue == "ff") { str = "類型 :<br>"; }
                str += "<select name='aiir_type' id='aiir_type'>";
                str += "<option value='4^207^Thermocouple'>Thermocouple</option>";
                str += "<option value='4^271^RTD'>RTD</option>";
                str += "<option value='4^272^Thermistor'>Thermistor</option>";
                str += "</select>";
                document.getElementById(id).innerHTML = str;
                
            }
            else {

                document.getElementById(id).innerHTML = "";
            }

        }

    </script>
  <asp:MultiView ID="MultiView1" runat="server">
            <asp:View ID="View1" runat="server">
<table  style="margin-left:20px;" width="890" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="42" ></td> <a name="mao_q2" id="mao_q2"></a> <td class="daq_title_para">
      <div class="title_para" style="margin-left:0px; width:500px; display:inline;float:left;color:red; font-size:14px;">
          <b><asp:Literal ID="labtitleid" runat="server"></asp:Literal></b>
      </div>
    <div style="display:inline; width:200px; float:right;"><asp:ImageButton runat="server" ImageAlign="Right"  ID="clear_all"  ImageUrl="./image/clearall.gif" onclick="clear_Click" /></div>
    </td>
  </tr>
  <!------------------  Questin 1 ------------------>
  <tr>
    <td align="center" width="42"  background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para" ><div style="margin-left:9px;">Q1</div></td>  
   <td width="820" height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong><asp:Label ID="labQ1titleid" runat="server"></asp:Label></strong></td>
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
    <td  height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg">
      <strong><asp:Label ID="labQ2titleid" runat="server" ></asp:Label> </strong>
   </td>
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
    <td  height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg"><strong> <asp:Literal ID="Q4_title" runat="server" Text="Operating System" ></asp:Literal></strong></td>
  </tr>
  <tr> <td></td> <td>  <span id="Q4" runat="server"></span> </td></tr>
    <!------------------  Questin 4 ------------------>
        <!------------------  Questin 5 ------------------>
  <tr>
    <td align="center" background="./image/q-bg-2.jpg" style="background-repeat: no-repeat;background-position: right;" class="daq_title_para"><div style="margin-left:9px;">Q5</div></td> 
    <td height="35" class="daq_title_para" background="./image/Advantech_Wiki_15.jpg">
      <strong> <asp:Label runat="server" ID="labQ5titleid"  Text="Label"></asp:Label></strong>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div  style="margin-left:45px; color:red;font-size:12px;font-weight:bold;margin-bottom:5px;">
          <asp:Label runat="server" ID="Q5_sm" Text="Label"></asp:Label></div>
    </td>
  </tr> 
  <tr> 
    <td colspan="2">
    <table width="100%" border="0" cellspacing="0" cellpadding="0"  style="margin-left:15px;">
  <tr>
   <td valign="top" align="left">
    <!------------------  Questin 1-5-1 ------------------>      
    <table runat="server" id="YI5YI"   border="0" cellspacing="0" cellpadding="0" width="166" height="230"  bgcolor="#beccec" >
       <tr>
           <td valign="top" height="26">
              <%-- <img src="./image/title-1.jpg" width="166" height="26">--%>
               <asp:Image runat="server" Width="166" Height="26" ID="img5Yi" />
           </td>
       </tr>
      <tr><td bgcolor="#beccec" valign="top" class="tdleft"  style="padding-top:5px;"><asp:Label ID="channel1" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" runat="server" name="aich" id="aich" /></td>  </tr>
      <tr><td bgcolor="#beccec"  valign="top" class="tdleft"><asp:Label ID="fbl1" runat="server" Text="Resolution (bits)"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="air"> </asp:DropDownList>  </td> </tr>
       <tr><td bgcolor="#beccec" class="tdleft"><asp:Label ID="cyl1" runat="server" Text="Sampling Rate"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aisr"> </asp:DropDownList></td> </tr>
        <tr><td bgcolor="#beccec" class="tdleft"><asp:Label ID="srfw1" runat="server" Text="Input Range"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false"   runat="server" ID="aiir"   > </asp:DropDownList></td> </tr>
	<tr><td bgcolor="#beccec" class="tdleft">      
    <div id="add_aioption"></div>
    </td>
        </tr>
        <tr><td height="26" valign="bottom"><asp:ImageButton runat="server" ID="AIimage" ImageUrl="./image/add.png" OnClientClick="return checkAI();"  onclick="AIimage_Click" /></td></tr>
       
</table>
  <!------------------  Questin 1-5-1 end ------------------>  
  <!------------------  Questin 2-5-1 ------------------>      
    <table  runat="server" id="ER5YI" border="0" cellspacing="0" cellpadding="0" width="166" height="230"  bgcolor="#beccec" >
  <tr> <td valign="top" height="26"><asp:Image runat="server" Width="166" Height="26" ID="img5Yi2" /></td></tr>
      <tr><td bgcolor="#beccec" class="tdleft"  valign="top" style="padding-top:5px;"><asp:Label ID="channel2" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" runat="server" name="aich2" id="aich2" /></td>  </tr>
     
       <tr><td bgcolor="#beccec" valign="top" class="tdleft"><asp:Label ID="cyl2" runat="server" Text="Sampling Rate"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aisr2"> </asp:DropDownList><br /></td> </tr>
        <tr><td bgcolor="#beccec" valign="top" class="tdleft"><asp:Label ID="srfw2" runat="server" Text="Input Range"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false"   runat="server" ID="aiir2"   > </asp:DropDownList><br /></td> </tr>
	<tr><td bgcolor="#beccec" valign="top" class="tdleft">    <div id="add_aioption2" style="height:30px;clear:both;"></div> </td> </tr>
 
        <tr><td height="26" valign="bottom"><asp:ImageButton runat="server" ID="AIimage2" ImageUrl="./image/add.png" OnClientClick="return checkAI2();"  onclick="AIimage_Click2" /></td></tr>
       
</table>
  <!------------------  Questin 2-5-1 end ------------------> 
  </td>  
    <td valign="top" align="left">
    
    <!------------------  Questin 1-5-2 ------------------>
     <table runat="server" id="YI5ER"  border="0" cellspacing="0" cellpadding="0"  width="166" height="230" bgcolor="#b5d9ef">
  <tr> <td valign="top" height="26"><asp:Image runat="server" Width="166" Height="26" ID="img5Er" /></td></tr>
  <tr><td bgcolor="#b5d9ef"  valign="top" class="tdleft"  style="padding-top:5px;"><asp:Label ID="channel3" runat="server" Text="Channel"></asp:Label>: <input  type="text" size="8" name="aoch" id="aoch"  runat="server"/></td></tr>
  <tr><td bgcolor="#b5d9ef"  valign="top"  class="tdleft"><asp:Label ID="fbl3" runat="server" Text="Resolution (bits)"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aor"> </asp:DropDownList> </td></tr>
    <tr><td bgcolor="#b5d9ef" class="tdleft"><asp:Label ID="scpl1" runat="server" Text="Output Rate"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoort"> </asp:DropDownList></td></tr>
      <tr><td bgcolor="#b5d9ef"  class="tdleft"><asp:Label ID="scfw1" runat="server" Text="Output Range"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoorg"> </asp:DropDownList></td></tr>
        <tr><td bgcolor="#b5d9ef" valign="bottom" height="26"><asp:ImageButton runat="server" ID="AOimage" ImageUrl="./image/add.png" OnClientClick="return checkAO();"  onclick="AOimage_Click" /></td></tr>
      </table>

    <!------------------  Questin 1-5-2 end ------------------>
     <!------------------  Questin 2-5-2 ------------------>
     <table  runat="server" id="ER5ER" border="0" cellspacing="0" cellpadding="0"  width="166" height="230" bgcolor="#b5d9ef">
  <tr> <td valign="top" height="26"><asp:Image runat="server" Width="166" Height="26" ID="img5Er2" /></td></tr>
  <tr><td bgcolor="#b5d9ef" valign="top" class="tdleft"  style="padding-top:5px;"><asp:Label ID="channel4" runat="server" Text="Channel"></asp:Label>: <input  type="text" size="8" name="aoch2" id="aoch2"  runat="server"/></td></tr>
  <tr><td bgcolor="#b5d9ef" valign="top" class="tdleft"><asp:Label ID="fbl4" runat="server" Text="Resolution (bits)"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aor2"> </asp:DropDownList> </td></tr>   
      <tr><td bgcolor="#b5d9ef" valign="top" class="tdleft"><asp:Label ID="scfw2" runat="server" Text="Output Range"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="aoorg2"> </asp:DropDownList></td></tr>
       <tr><td bgcolor="#b5d9ef"> <div style="height:30px;clear:both;"></div> </td></tr>
       
        <tr><td bgcolor="#b5d9ef" valign="bottom" height="26"><asp:ImageButton runat="server" ID="AOimage2" ImageUrl="./image/add.png" OnClientClick="return checkAO2();"  onclick="AOimage2_Click" /></td></tr>
      </table>

    <!------------------  Questin 2-5-2 end ------------------>
    
    </td>  
    <td valign="top"> 
    <!------------------  Questin 1-5-3 ------------------>
     <asp:UpdatePanel id="up153" runat="server" UpdateMode="Conditional"><ContentTemplate>
    <table runat="server" id="YI5SAN"  valign="top"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec">
  <tr> <td  height="26" valign="top"><asp:Image runat="server" Width="166" Height="26" ID="img5San" /></td></tr>
  
  <tr id="dich_ttl_TR"  visible="false"  runat="server" ><td bgcolor="#beccec" valign="top" class="tdleft"  style="padding-top:5px;"> <asp:Label ID="channel5" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="dich_ttl" id="dich_ttl" runat="server"/></td></tr>
 <tr id="dich_isolation_TR" runat="server" visible="false" ><td bgcolor="#beccec"  valign="top" style="padding-top:5px;" class="tdleft"><asp:Label ID="channel6" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="dich_isolation" id="dich_isolation" runat="server"/></td></tr>
  
   <tr><td valign="top" bgcolor="#beccec" class="tdleft"><asp:Label ID="tdlx1" runat="server" Text="Channel Type"></asp:Label>:<br /><asp:DropDownList AutoPostBack="true"  runat="server" ID="di_channel_type"  onselectedindexchanged="di_channel_type_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-select-"></asp:ListItem>
        <asp:ListItem Value="di_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="di_channel_isolation" Text="Isolation"></asp:ListItem> </asp:DropDownList> </td></tr>

         
       <tr id="dich_ttl_TR_br"  visible="false"  runat="server" ><td bgcolor="#beccec" height="90" valign="top" class="tdleft"  ></td></tr>
         <tr id="DI1image_TR" visible="false" runat="server" height="26" ><td bgcolor="#beccec" ><asp:ImageButton runat="server" ID="DI1image" OnClientClick="return checkDI1();" ImageUrl="./image/add.png"   onclick="DI1image_Click" /></td></tr>
           
           
        
             <tr id="sm_TR" runat="server" visible="false" ><td bgcolor="#beccec" class="tdleft" >
                 <asp:Label runat="server" ID="nn1" Text="Input Voltage for Logic 1(V<sub>DC</sub>)"></asp:Label></td></tr>
               <tr id="HTML_TR" runat="server" visible="false" ><td bgcolor="#beccec" class="tdleft" id="HTML_TD" runat="server" ></td></tr>
             <tr id="DI2image_TR" runat="server" visible="false" height="26"><td bgcolor="#beccec" ><asp:ImageButton runat="server" ID="DI2image" OnClientClick="return checkDI2();" ImageUrl="./image/add.png"   onclick="DI2image_Click" /></td></tr>


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
  <tr> <td  height="26" valign="top"><asp:Image runat="server" Width="166" Height="26" ID="img5San2" /></td></tr>
  
   <tr id="dich_ttl_TR2"  visible="false"  runat="server" ><td bgcolor="#beccec" valign="top" class="tdleft" style="padding-top:5px;"><asp:Label ID="channel7" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="dich_ttl2" id="dich_ttl2" runat="server"/></td></tr>
     <tr id="dich_isolation_TR2" runat="server" visible="false" ><td class="tdleft" valign="top" style="padding-top:5px;" bgcolor="#beccec"><asp:Label ID="channel8" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="dich_isolation2" id="dich_isolation2" runat="server"/></td></tr>

   <tr><td valign="top" bgcolor="#beccec" class="tdleft" ><asp:Label ID="tdlx2" runat="server" Text="Channel Type"></asp:Label>:<br /><asp:DropDownList AutoPostBack="true"  runat="server" ID="di_channel_type2"  onselectedindexchanged="di_channel_type2_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-select-"></asp:ListItem>
        <asp:ListItem Value="di_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="di_channel_isolation" Text="Isolation"></asp:ListItem> </asp:DropDownList> </td></tr>

        
         <tr id="dich_ttl_TR2_br"  visible="false"  runat="server" ><td bgcolor="#beccec" height="90" valign="top" class="tdleft"  ></td></tr> 
       
         <tr id="DI1image_TR2" visible="false" runat="server" height="26" ><td bgcolor="#beccec" ><asp:ImageButton runat="server" ID="DI1image2" OnClientClick="return checkDI12();" ImageUrl="./image/add.png"   onclick="DI1image_Click2" /></td></tr>
           
           
         
             <tr id="sm_TR2" runat="server" visible="false" ><td class="tdleft" bgcolor="#beccec">Input Voltage for Logic 1(V<sub>DC</sub>)</td></tr>
               <tr id="HTML_TR2" runat="server" visible="false" ><td class="tdleft" bgcolor="#beccec" id="HTML_TD2" runat="server" ></td></tr>
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
      <table runat="server" id="YI5SI"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#b5d9ef"> 
      <tr> <td valign="top"  height="26"><asp:Image runat="server" Width="166" Height="26" ID="img5Si" /></td></tr>
      
       <tr id="si_1_1" runat="server" visible="false" ><td bgcolor="#b5d9ef" valign="top" style="padding-top:5px;" class="tdleft"><asp:Label ID="channel9" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_ttl" id="doch_ttl"  runat="server"/></td></tr>
        <tr id="si_2_1" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="top" class="tdleft" style="padding-top:5px;"><asp:Label ID="channel10" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_isolation" id="doch_isolation"  runat="server"/></td></tr>
         <tr id="si_3_1" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="top" class="tdleft" style="padding-top:5px;"><asp:Label ID="channel11" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_relay" id="doch_relay"  runat="server"/></td></tr>

       <tr><td valign="top" bgcolor="#b5d9ef" class="tdleft" ><asp:Label ID="tdlx3" runat="server" Text="Channel Type"></asp:Label>: <br>
       <asp:DropDownList AutoPostBack="true"  runat="server" ID="do_channel_type"  onselectedindexchanged="do_channel_type_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-select-"></asp:ListItem>
        <asp:ListItem Value="do_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="do_channel_isolation" Text="Isolation"></asp:ListItem> 
          <asp:ListItem Value="do_channel_relay" Text="Relay"></asp:ListItem></asp:DropDownList>
       </td></tr>
       
      <tr id="si_1_1_br" runat="server" visible="false" ><td bgcolor="#b5d9ef" valign="top" height="90" ></td></tr>
       <tr id="si_1_2" runat="server" visible="false" height="26" ><td bgcolor="#b5d9ef"  valign="bottom"><asp:ImageButton runat="server" ID="DO1image" ImageUrl="./image/add.png" OnClientClick="return checkDO1();"  onclick="DO1image_Click" /></td></tr>

       
         <tr id="si_2_2" runat="server" visible="false"><td id="si_2_2TD" class="tdleft"  valign="top" runat="server" height="85" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_2_3" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="bottom"><asp:ImageButton runat="server" ID="DO2image" ImageUrl="./image/add.png" OnClientClick="return checkDO2();"  onclick="DO2image_Click" /></td></tr>


          
         <tr id="si_3_2" runat="server" visible="false"><td id="si_3_2TD"  valign="top" runat="server" height="85" class="tdleft" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_3_3" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="bottom"><asp:ImageButton runat="server" ID="DO3image" ImageUrl="./image/add.png" OnClientClick="return checkDO3();"  onclick="DO3image_Click" /></td></tr>
       
       </table>
       </ContentTemplate>      
         <Triggers> 
      <asp:AsyncPostBackTrigger ControlID="do_channel_type"   EventName="SelectedIndexChanged" /> 
  </Triggers>       
       </asp:UpdatePanel>
       <!------------------  Questin 1-5-4 ------------------>

<!------------------  Questin 2-5-4 ------------------>
      <asp:UpdatePanel id="up254" runat="server" UpdateMode="Conditional"><ContentTemplate>
      <table runat="server" id="ER5SI"  border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#b5d9ef">
       <tr> <td valign="top"  height="26"><asp:Image runat="server" Width="166" Height="26" ID="img5Si2" /></td></tr>
      
         <tr id="si_1_12" runat="server" visible="false" ><td bgcolor="#b5d9ef" valign="top" style="padding-top:5px;" class="tdleft"><asp:Label ID="channel12" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_ttl2" id="doch_ttl2"  runat="server"/></td></tr>
       <tr id="si_2_12" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="top" style="padding-top:5px;" class="tdleft"><asp:Label ID="channel13" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_isolation2" id="doch_isolation2"  runat="server"/></td></tr>
         <tr id="si_3_12" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="top" style="padding-top:5px;" class="tdleft"><asp:Label ID="channel14" runat="server" Text="Channel"></asp:Label>:<input type="text" size="8" name="doch_relay2" id="doch_relay2"  runat="server"/></td></tr>

       <tr><td valign="top" bgcolor="#b5d9ef" class="tdleft" ><asp:Label ID="tdlx4" runat="server" Text="Channel Type"></asp:Label>: <br>
       <asp:DropDownList AutoPostBack="true"  runat="server" ID="do_channel_type2"  onselectedindexchanged="do_channel_type2_SelectedIndexChanged">
       <asp:ListItem Value="none" Text="-select-"></asp:ListItem>
        <asp:ListItem Value="do_channel_ttl" Text="TTL"></asp:ListItem>
         <asp:ListItem Value="do_channel_isolation" Text="Isolation"></asp:ListItem> 
          <asp:ListItem Value="do_channel_relay" Text="Relay"></asp:ListItem></asp:DropDownList>
       </td></tr>
       
     <tr id="si_1_12_br" runat="server" visible="false" ><td bgcolor="#b5d9ef" valign="top" height="90" ></td></tr>
       <tr id="si_1_22" runat="server" visible="false" height="26" ><td bgcolor="#b5d9ef" valign="bottom"><asp:ImageButton runat="server" ID="DO1image2" ImageUrl="./image/add.png" OnClientClick="return checkDO12();"  onclick="DO1image_Click2" /></td></tr>

       
         <tr id="si_2_22" runat="server" visible="false"><td id="si_2_2TD2" valign="top" class="tdleft" height="85" runat="server" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_2_32" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="bottom"><asp:ImageButton runat="server" ID="DO2image2" ImageUrl="./image/add.png" OnClientClick="return checkDO22();"  onclick="DO2image_Click2" /></td></tr>


         
         <tr id="si_3_22" runat="server" visible="false"><td id="si_3_2TD2" valign="top" runat="server" height="85" class="tdleft" bgcolor="#b5d9ef"></td></tr>
          <tr id="si_3_32" runat="server" visible="false"><td bgcolor="#b5d9ef" valign="bottom"><asp:ImageButton runat="server" ID="DO3image2" ImageUrl="./image/add.png" OnClientClick="return checkDO32();"  onclick="DO3image_Click2" /></td></tr>
       
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
      <table  runat="server" id="YI5WU" border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec" >
       <tr> <td height="26" valign="top"><asp:Image runat="server" Width="166" Height="26" ID="img5Wu" /></td></tr>
       <tr><td bgcolor="#beccec" valign="top" class="tdleft" style="padding-top:5px;"><asp:Label ID="channel15" runat="server" Text="Channel"></asp:Label>: <input type="text" size="8" name="counter_ch" id="counter_ch"  runat="server"/></td></tr>
       
        <tr><td bgcolor="#beccec" valign="top"  class="tdleft"><asp:Label ID="fbl2" runat="server" Text="Resolution (bits)"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="counter_r"> </asp:DropDownList></td></tr>
         <tr><td bgcolor="#beccec" valign="top"  class="tdleft">
             <asp:Label ID="zdsrfw1" runat="server" Text="Max. Input Frequency"></asp:Label>:<br /><asp:DropDownList AutoPostBack="false" runat="server" ID="counter_mif"> </asp:DropDownList><br /><br /><br /></td></tr>
        
         <tr><td bgcolor="#beccec" height="26"><asp:ImageButton runat="server" ID="COimage" ImageUrl="./image/add.png" OnClientClick="return checkCO();"  onclick="COimage_Click" /></td></tr>
       </table>
      <!------------------  Questin 1-5-5/ ------------------>

       <!------------------  Questin 2-5-5 ------------------>
      <table  runat="server" valign="top" id="ER5WU" border="0" cellspacing="0" cellpadding="0" width="166" height="230" bgcolor="#beccec" >
       <tr> <td height="26" valign="top"><asp:Image runat="server" Width="166" Height="26" ID="img5Wu2" /></td></tr>
       <tr><td bgcolor="#beccec" valign="top" class="tdleft" style="padding-top:5px;">
            <asp:Label ID="channel16" runat="server" Text="Channel"></asp:Label>:
            <input type="text" size="8" name="counter_ch2" id="counter_ch2"  runat="server"/>
           </td></tr>
       <tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr>
       <tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr>
        <tr><td bgcolor="#beccec" class="tdleft" >
        <input id="counter_mif" name="counter_mif" type="hidden" value="19^A^Less than 1 M">  </td></tr>

       
         <tr><td bgcolor="#beccec" height="26" valign="bottom"><asp:ImageButton runat="server" ID="COimage2" ImageUrl="./image/add.png" OnClientClick="return checkCO2();"  onclick="COimage_Click2" /></td></tr>
       </table>
      <!------------------  Questin 2-5-5/ ------------------>



      </td>
  </tr>
</table>
    </td>
  </tr>
      <!------------------  Questin 5end ------------------>
      <tr><td colspan="2"><br />
 <!------------------   list ------------------>
      
      <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin-left:15px;">
      <tr>
         <td  valign="bottom" >
              <asp:Image runat="server" id="search_crlterla" ImageUrl="./image/title-6.jpg" width="166" height="26"/>
         </td>
         <td></td> 
      </tr>
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
      
     <td  valign="top">
         <asp:Image runat="server" id="imgbzy" ImageUrl="./image/q_image-1.jpg" width="271" height="271"/>
     </td>
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
            var alterstr2 = "Channel Uses only numbers!";
            var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
            if (strValue == "jj") { alertstr = "请输入该项目选项!";alterstr2 = "通道请输入数字!";}
            if (strValue == "ff") { alertstr = "通道數及其它選項為必選欄位!"; alterstr2 = "通道數格式請輸入數字!"; }
            function checkAI() {
                if (document.getElementById('<%=aich.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=aich.ClientID %>').value)) { alert(alterstr2); return false; }
                if (document.getElementById("<%=air.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aisr.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aiir.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAI2() {
                if (document.getElementById('<%=aich2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=aich2.ClientID %>').value)) { alert(alterstr2); return false; }
                if (document.getElementById("<%=aisr2.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aiir2.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAO() {
                if (document.getElementById('<%=aoch.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=aoch.ClientID %>').value)) { alert(alterstr2); return false; }
                if (document.getElementById("<%=aor.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aoort.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=aoorg.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkAO2() {
                if (document.getElementById('<%=aoch2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=aoch2.ClientID %>').value)) { alert(alterstr2); return false; }
                if (document.getElementById("<%=aor2.clientid%>").value == "none") { alert(alertstr); return false; }

                if (document.getElementById("<%=aoorg2.ClientID%>").value == "none") { alert(alertstr); return false; }
            }
            function checkDI1() {
                if (document.getElementById("<%=di_channel_type.ClientID%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_ttl.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=dich_ttl.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDI12() {
                if (document.getElementById("<%=di_channel_type2.ClientID%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_ttl2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=dich_ttl2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDI2() {
                if (document.getElementById("<%=di_channel_type.ClientID%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_isolation.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=dich_isolation.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDI22() {
                if (document.getElementById("<%=di_channel_type2.ClientID%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById('<%=dich_isolation2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=dich_isolation2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO1() {
                if (document.getElementById('<%=doch_ttl.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_ttl.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO12() {
                if (document.getElementById('<%=doch_ttl2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_ttl2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO2() {
                if (document.getElementById('<%=doch_isolation.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_isolation.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO22() {
                if (document.getElementById('<%=doch_isolation2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_isolation2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO3() {
                if (document.getElementById('<%=doch_relay.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_relay.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkDO32() {
                if (document.getElementById('<%=doch_relay2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=doch_relay2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
            function checkCO() {
                if (document.getElementById('<%=counter_ch.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=counter_ch.ClientID %>').value)) { alert(alterstr2); return false; }
                if (document.getElementById("<%=counter_r.clientid%>").value == "none") { alert(alertstr); return false; }
                if (document.getElementById("<%=counter_mif.clientid%>").value == "none") { alert(alertstr); return false; }
            }
            function checkCO2() {
                if (document.getElementById('<%=counter_ch2.ClientID %>').value == "") { alert(alertstr); return false; }
                if (checknumber(document.getElementById('<%=counter_ch2.ClientID %>').value)) { alert(alterstr2); return false; }
            }
              function del_wishlist(req,sessionid) {
                 
                  var arrID = "";
                  PageMethods.del_wishlist_server(req + ";" + sessionid, OnPageMethods_2Succeeded, OnGetPriceError2, arrID);
              }
            
              
              function OnPageMethods_2Succeeded(result, arrID, methodName) {

                  var obj = document.getElementById('<%=wishlist.ClientID %>');
                  if (obj) {obj.innerHTML = result; }
               //   alert(result);
               
              }
             function OnGetPriceError2(error, arrID, methodName) {
                 if (error !== null) { alert(error.get_message()); }
             }
            
             function checkwish() {
                 var Q1str = ""; var Q2str = ""; var Q3str = ""; var Q4str = ""; var Q5str = "";
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
                              if (result == false) {Q1str = "Q1"; }
                       /////////////////////////////////////////////Q2
                       var result2 = false;
                       var RB2name = document.getElementsByName("ctl00$_main$RB2");
                       if (RB2name) {
                           for (var i = 0; i < RB2name.length; i++) {
                               if (RB2name[i].checked)
                               { result2 = true; break; }
                           }
                       }
                       if (result2 == false) {Q2str = "Q2"; }
                       /////////////////////////////////////////////////Q3
                       var result3 = false;
                       var RB3name = document.getElementsByName("q3");
                       if (RB3name) {
                           for (var i = 0; i < RB3name.length; i++) {
                               if (RB3name[i].checked)
                               { result3 = true; break; }
                           }
                       }
                       if (result3 == false) {Q3str = "Q3"; }
                       /////////////////////////////////////////////////Q4
                       var result4 = false;
                       var RB4name = document.getElementsByName("q4");
                       if (RB4name) {
                           for (var i = 0; i < RB4name.length; i++) {
                               if (RB4name[i].checked)
                               { result4 = true; break; }
                           }
                       }
                       if (result4 == false) {Q4str = "Q4"; }
                       //////////////////////////////////////////////////////
                       /////////////////////////////////////////////////Q5
                       var result5 = false;
                       var RB5name = document.getElementById('<%=wishlist.ClientID %>').innerHTML;

                       if (RB5name == "") { Q5str = "Q5"; }
                       //////////////////////////////////////////////////////
                       var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
                       var alertstr0 = "Please answer "
                       if (strValue == "jj") { alertstr0 = "请回答 "; }
                       if (strValue == "ff") { alertstr0 = "請回答 "; }
                       alertstr = alertstr0;
                       var mycars = new Array()
                       if (Q1str != "") mycars.push(Q1str);
                       if (Q2str != "") mycars.push(Q2str);
                       if (Q3str != "") mycars.push(Q3str);
                       if (Q4str != "") mycars.push(Q4str);
                       if (Q5str != "") mycars.push(Q5str);
                       for (var i = 0; i < mycars.length; ++i) {
                           if (i == mycars.length - 1) { alertstr = alertstr + mycars[i] + " !"; }
                           else { alertstr = alertstr + mycars[i] + ","; }
                       }

                       if (alertstr == alertstr0 + "Q5 !") {
                           var alertstr = "Please answer Q5, 'What Kind of Data Acquisition Functions Do You Need ?'\n(Please make sure to click the ‘Add to Search Criteria’ button in each column after entering values.)";
                           if (strValue == "jj") { alertstr = "请回答问题Q5,在输入有效值后，请点选每个“添加至搜索条件”!"; }
                           if (strValue == "ff") { alertstr = "請回答問題Q5,在輸入有效值後，請點選每個“添加至搜索條件”!"; }
                           alert(alertstr);
                         return false; }
                     
                     
                       if (alertstr != alertstr0) {
                           alert(alertstr);
                           if (Q1str != "") { window.location.hash = "mao_q2"; return false; }
                           if (Q2str != "") { window.location.hash = "mao_q2"; return false; }
                           if (Q3str != "") { window.location.hash = "mao_q2"; return false; }
                           if (Q4str != "") { window.location.hash = "mao_q2"; return false; }
                           return false;
                       }
                       ///
                // var objstr = document.getElementById('<%=wishlist.ClientID %>').innerHTML;
                // if (objstr == "") { alert("Please answer Q5, 'What Kind of Data Acquisition Functions Do You Need ?'\n(Please make sure to click the ‘Add to Search Criteria’ button in each column after entering values.)"); return false; }
             }
           
        </script>
      


       </asp:View>
            <asp:View ID="View2" runat="server"  >

<%-- search.aspx-start   --%> 
            <%--    <asp:UpdatePanel runat="server" ID="searchview2" UpdateMode="Always">
                <ContentTemplate>--%>
    <table style="margin-left:20px;" width="890" border="0"  cellspacing="0" cellpadding="0"><tr><td align="center">      
   
<table   align="center"  border="0" cellspacing="0" cellpadding="0" >
<tr>
<td align="center">
<table width="830" border="0" align="center" cellspacing="0" cellpadding="0">
                          <tr> 
                           <td><asp:Image runat="server" ID="img_search_result_id" /></td>
                            <td>  
                              <a href="email_solution.aspx" title="<%=fsdwyx %>" rel="gb_page_center[640, 200]">                        
                                <asp:Image runat="server" id="emailme" ImageUrl="./image/email_me.png" BorderWidth="0"/>
                              </a>
                            </td>                                                     
                          </tr>
                      </table>
</td>
</tr>

<tr runat="server" id="haslist1" ><td><table align="center" width="830" border="0"  cellspacing="0" cellpadding="2">
    <asp:Repeater runat="server" ID="rp1" onitemdatabound="rp1_ItemDataBound"><ItemTemplate>
    
    <tr>
                            <td bgcolor="#3da1db"><img src="./image/blue_01.jpg" width="5" height="5"></td>
                            <td><table width="100%" border="1"  cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                                <tr>
                                  <td width="130" bordercolor="#ffffff">
                                  <div align="center"><a href="<%# Eval("buylink")%>"  target="_blank"><img src="<%# Eval("img_url")%>" height="86" border="0"></a></div>
                                  </td>
                                </tr>
                            </table></td><td width="2"></td>
                            <td valign="center" width="415"><table width="100%" height="90" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                              <tr>
                                <td valign="top" bordercolor="#dae1f3" bgcolor="#dae1f3"><table width="100%" border="0" cellspacing="0" cellpadding="5">
                                    <tr>
                                      <td width="62%" valign="top"><table width="100%" border="0" cellspacing="5" cellpadding="0">
                                          <tr>
                                            <td class="daq-r-title" ><a href="<%# Eval("buylink")%>"  target="_blank"><%# Eval("model_name")%></a>
                                            <span style="font-size:12px;">(pcs: <asp:Literal runat="server" ID="L1" Text='<%# Eval("piece")%>'></asp:Literal>)</span>
                                            </td>
                                          </tr>
                                          <tr>
                                            <td class="daq-r-title-2">
                                            <asp:Literal runat="server" ID="L2" Text='<%# Eval("description")%>'></asp:Literal>
                                            <br></td>
                                          </tr>
                                      </table></td>
                                      <td width="38%" valign="top"><table width="100%" border="0" cellspacing="4" cellpadding="0">
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/data_logo.jpg" width="20" height="19"></div></td>
                                                  <td width="83%">
                                                    <a target="_blank" href="<%# Eval("supportlink")%>" class="text">
                                                        <%= jg1 %>                                                 
                                                   </a>    </td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/buy_logo.jpg" width="20" height="20"></div></td>
                                                  <td width="83%">
                                                  <a target="_blank" href="<%# Eval("buylink")%>" class="text">
                                                    <%= jg2%>   
                                                  </a></td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                          <tr>
                                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td width="17%"><div align="center"><img src="./image/see_logo.jpg" width="20" height="19"></div></td>
                                                  <td width="83%"><a href="similar.aspx?pid=<%# Eval("cheap_pid")%>" class="text" rel="gb_page_center[640, 450]" title="<%=jg3 %>">
                                                  <%=jg3 %></a></td>
                                                </tr>
                                            </table></td>
                                          </tr>
                                      </table></td>
                                    </tr>
                                </table></td>
                              </tr>
                            </table></td><td width="2"></td>
                            <td valign="top"><table width="265" height="90" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                              <tr>
                                <td valign="top" bordercolor="#dae1f3" bgcolor="#dae1f3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                      <td><table width="100%" border="0" cellspacing="3" cellpadding="0">
                                          <tr>
                                            <td class="text"><%=jg4 %></td>
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
    <asp:Repeater runat="server" ID="rp2" onitemdatabound="rp2_ItemDataBound" >
    <ItemTemplate>
    <tr><td colspan="5" height="2"></td></tr>
    <tr> <td bgcolor="#3da1db"><img src="./image/blue_01.jpg" width="5" height="5"></td>
                            <td colspan="5" height="70" ><div style="margin-left:20px">
                                <asp:Literal ID="rp2lit" runat="server"></asp:Literal>    </div>                       
                            </td>
							
                          </tr>
    </ItemTemplate>
    </asp:Repeater>
    </table></td></tr>
    <tr runat="server" id="haslist2">
    <td>
        <table width="825" border="0" align="center" cellpadding="0" cellspacing="0">
         <tr><td height="8"></td></tr>
            <tr>
                <td width="516" valign="top">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td >
                                <table width="100%" border="0" cellspacing="3" cellpadding="0">
                                    <tr>
                                        <td>
                                          
                                            <asp:Image runat="server"  width="523" height="26" ID="yaneed"/>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                               
                                <asp:DataList runat="server" ID="dl1" Width="100%" CellSpacing="3" CellPadding="1" RepeatDirection="Horizontal" RepeatColumns="2">
                                <ItemTemplate>
                                <table width="260" height="90" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                                    <tr>
                                        <td valign="top"  bgcolor="#f3eedc"  bordercolor="#f3eedc">
                                            <table width="100%" border="0" cellspacing="6" cellpadding="0">
                                                <tr>
                                                    <td width="26%" valign="top">
                                                        <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#bbbbbb">
                                                            <tr>
                                                                <td  bgcolor="#FFFFFF" bordercolor="#FFFFFF">
                                                                    <div align="center">  
                                                                        <a href="<%# Eval("details")%>" target="_blank" >  <img src="./image/<%# Eval("img_url") %>"  border="0"  height="86"></a>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td width="74%" valign="top" >
                                                        <table width="100%" border="0" cellspacing="5" height="100%" cellpadding="0">
                                                            <tr>
                                                                <td class="text">
                                                                  <a href="<%# Eval("details")%>" target="_blank" class="text">  <b><%# Eval("sku")%></b></a>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="daq-r-title-2" >
                                                                     <div style="overflow: hidden;height:40px;">
                                                                        <%# Eval("description")%>
                                                                     </div>                                                                   
                                                                </td>
                                                            </tr>
                                                           <%-- <tr>
                                                                <td valign="bottom" align="right">
                                                                   
                                                                </td>
                                                            </tr>--%>
                                                        </table>
                                                        <table valign="bottom" width="100%" border="0" cellspacing="5"  cellpadding="0">
                                                            <tr>
                                                                <td>
                                                                     <table border="0" align="right" valign="bottom"  cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td width="32%">
                                                                                <div align="center">
                                                                                    <img src="./image/details_logo.jpg" width="15" height="15">
                                                                                </div>
                                                                            </td>
                                                                            <td width="68%" >
                                                                                <a href="<%# Eval("details")%>" target="_blank" class="text">
                                                                                    <%= jg5%>
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
                    <table border="0" valign="top" cellpadding="0" cellspacing="0" width="303">
                        <tr>
                            <td valign="top">
                             <%-- -----%>
                             		<table border="0" cellpadding="0" cellspacing="0" width="292" height="243" background="<%= tb_bg %>" style="background-repeat: no-repeat;">
                                        <tr>
                                        <td  valign="top" align="left" height="72" style="padding-left:6px; padding-top:37px;"> 
	                                        <asp:ImageButton runat="server"  AlternateText="Try Again" ImageUrl="./image/AGAIN-2_r2_c2.jpg"  width="144" height="36" ID="again1"  BorderWidth="0" onclick="again1_Click"/>	  
                                            <div style="margin-top:10px;">
	                                            <a href="customize_solution.aspx"  title="<%=xqkz %>" rel="gb_page_center[600, 450]"><img  src="<%= custom %>" alt="<%=xqkz %>" width="144" height="36" border="0" /></a>
	                                        </div>
                                        </td>
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
     
   
        <table align="center" width="825" border="0"  cellpadding="0" cellspacing="3">
            <tr>
                <td>
                    <table border="0" cellpadding="0" cellspacing="0" >
                        <tr>
                            <td colspan="5">
                                <img src="./image/spacer.gif"  height="1" border="0" />                            </td>
                           
                        </tr>
                        <tr>
                            <td rowspan="5" valign="top" style="background-image:url('./image/no_result_and_try_r1_c1.jpg');" style="background-repeat: no-repeat;">
                                <table cellpadding="0" width="527" cellspacing="0" border="0">
                                    <tr>
                                        <td bgcolor="#359EDF" width="5">   </td>
                                        <td>  </td>
                                        <td>
                                            <div class="no_result">
                                               <asp:Literal runat="server" id="no_resultid1"></asp:Literal>
                                                <br />
                                               <b><asp:Literal runat="server" id="no_resultid2"></asp:Literal></b>
                                               <ul style="margin-top: 0px;">
                                               <li>
                                               <a href="similar.aspx?pid=NO" rel="gb_page_center[640, 450]" style="text-decoration: underline;" title="<%=no_resultid3_str %>">
                                                    <asp:Literal runat="server" id="no_resultid3"></asp:Literal></a>
                                               </li>
                                               <li><asp:Literal runat="server" id="no_resultid4"></asp:Literal></li>
                                               <li><asp:Literal runat="server" id="no_resultid5"></asp:Literal> 
                                                   <a href="customize_solution.aspx"  title="<%= xqkz %>" rel="gb_page_center[640, 450]"><asp:Literal runat="server" id="no_resultid6"></asp:Literal></a> 
                                                   <asp:Literal runat="server" id="no_resultid7"></asp:Literal>
                                                </li>
                                               </ul>      
                                                
                                                 </div>   
                                           </td>
                                    </tr>
                                </table>                            </td>
                            <td colspan="3" rowspan="5" valign="top" >
                     <%-- ----------------%>
							
		<table border="0" cellpadding="0" cellspacing="0" width="292" height="243" background="<%= tb_bgno %>" style="background-repeat: no-repeat;">
  <tr>
    <td  valign="top" align="left" height="72" style="padding-left:6px; padding-top:37px;"> 
	   <asp:ImageButton runat="server"  AlternateText="Try Again" ImageUrl="./image/AGAIN-2_r2_c2.jpg"  width="144" height="36" ID="again2"  BorderWidth="0" onclick="again1_Click"/>	
	
  
  <div style="margin-top:10px;"  >
	 <a href="customize_solution.aspx"  title="Customize It!" rel="gb_page_center[640, 450]"><img  src="<%= custom %>" alt="Customize It!" width="144" height="36" border="0" /></a>
	</div>
    </td>
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
<tr><td align="left">
<%--send email start--%>

<table align="center" width="830" border="0"  cellspacing="0" cellpadding="0">             
                    <tr>
                      <td width="516" valign="top" ><table border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td width="529"><table width="100%" border="0" cellspacing="3" cellpadding="0">
                              <tr>
                                <td>
                                   
                                    <asp:Image runat="server" ID="pinglunid" width="523" height="27"/>
                                 </td>
                              </tr>
                            </table></td>
                          </tr>
                          <tr>
                            <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                              <tr>
                                <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                  <tr>
                                    <td width="2%">&nbsp;</td>
                                    <td width="98%" class="text style5">
                                      
                                        <asp:Literal runat="server" ID="tjpl1"> We would appreciate it if you would share your  comments, suggestions, or feedback  below.</asp:Literal>
                                    </td>
                                  </tr>
                                </table></td>
                              </tr>
                              <tr>
                                <td>
                              
                                
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                  <tr>
                                    <td width="53%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="3">
                                      <tr>
                                        <td class="text"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                          <tr>
                                            <td width="3%">&nbsp;</td>
                                            <td width="96%" class="text">
                                               <asp:Label runat="server" ID="tjpl2" ></asp:Label>
                                            </td>
                                          </tr>
                                        </table>
                                          </td>
                                      </tr>
                                      <tr>
                                        <td><textarea cols="50" name="message" rows="4" class="text" runat="server" id="message"></textarea></td>
                                      </tr>
                                    </table></td>
                                    <td width="47%"><table width="100%" border="0" cellspacing="0" cellpadding="3">
                                      <tr>
                                        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                          <tr>
                                            <td width="31%" class="text"><asp:Literal ID="tjpl3" runat="server"></asp:Literal></td>
                                            <td width="69%"><input type="text" name="name" style="width:173px;" class="text" runat="server" id="name" size="28"></td>
                                          </tr>
                                        </table></td>
                                      </tr>
                                      <tr>
                                        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                          <tr>
                                            <td width="31%" class="text"><asp:Literal ID="tjpl4" runat="server"></asp:Literal></td>
                                            <td width="69%">
                                                <asp:TextBox runat="server" ID="EMAIL" Width="173"></asp:TextBox>
                                            </td>
                                          </tr>
                                        </table></td>
                                      </tr>
                                      <tr>
                                        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                          <tr>
                                            <td width="28%" class="text">&nbsp;</td>
                                            <td width="72%">
                                        
         <asp:ImageButton runat="server" id="sendemail" ImageUrl="./image/w-2_14.jpg"  OnClientClick="return checkemail();"   onclick="sendemail_Click"/>
                                          
                                          </td>
                                          </tr>
                                        </table></td>
                                      </tr>
                                    </table></td>
                                  </tr>
                                </table>
                         
                                </td>
                              </tr>
                            </table></td>
                          </tr>
                      </table></td>
                      <td align="left"  valign="bottom">
                        <a runat="server" id="ACum" href="https://member.advantech.com/profile.aspx?Pass=mya&id=&lang=&tempid=&callbackurl=http://daqyourway.advantech.com/DAQ/default.aspx&CallBackURLName=Go%20To%20DAQ20%Yourway  " target="_blank">                          
                            <asp:Image runat="server" ID="lastimg"  ImageUrl="./image/w-2_11.jpg"  width="303" height="148" BorderWidth="0"/>
                        </a>
                      </td>
                    </tr>
                  </table>
                  <script language="javascript" type="text/javascript">
                      function checkemail() {

                          if (document.getElementById('<%=name.ClientID %>').value == "") { alert("Name cannot empty"); return false; }
                          if (document.getElementById('<%=EMAIL.ClientID %>').value == "") { alert("Email cannot empty"); return false; }
                          //
                          var strEmail = document.getElementById('<%=EMAIL.ClientID %>').value;
                          if (strEmail.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) {

                          }
                          else {

                              alert("Email incorrect");
                              return false;
                          }
                          //
                          if (document.getElementById('<%=message.ClientID %>').value == "") { alert("Comments cannot empty"); return false; }
                      
                      
                      }
                  
                  
                  </script>

<%--send email end--%>

</td></tr>  
<tr><td>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td>
					<img src="./image/b01.jpg" width="892" height="40">
					</td>
                  </tr>
                </table>


</td></tr>
</table>
<%--again--%>
</td></tr></table>    
       
<%-- search.aspx-end   --%>               
            </asp:View>
            </asp:MultiView>
<script language="javascript" type="text/javascript">
    ///////////////////////////////onload get wishlist
    function onload_get_wishlist() {
        var arrID = "";
        //alert("good");
        var obj1 = document.getElementById("ctl00__main_aiir");
        var obj2 = document.getElementById("ctl00__main_aiir2");
        if (obj1) { aiirselectChange("ctl00__main_aiir", "add_aioption"); }
        if (obj2) { aiirselectChange("ctl00__main_aiir2", "add_aioption2"); }

     
        //
        PageMethods.onload_wishlist_server("", OnPageMethodsonloadSucceeded, OnGetPriceErroronload, arrID);
    }
    function OnPageMethodsonloadSucceeded(result, arrID, methodName) {

        var obj = document.getElementById('<%=wishlist.ClientID %>');
        if (obj) { obj.innerHTML = result; }
        //   alert(result);

    }
    function OnGetPriceErroronload(error, arrID, methodName) {
        if (error !== null) { alert(error.get_message()); }
    }
    /////////////////////////////////
    function checknumber(String) {
        var Letters = "1234567890";
        var i;
        var c;
        for (i = 0; i < String.length; i++) {
            c = String.charAt(i);
            if (Letters.indexOf(c) == -1) {
                return true;
            }
        }
        return false;
    }
</script>
</asp:Content>


