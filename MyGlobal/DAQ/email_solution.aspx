<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Function getProductDetail() As DataTable
      
        Dim sql As String = "SELECT a.class, a.channel_type, a.channel_num, a.value_ids, a.description as wish_descr, a.cheap_pid,a.other_col," & _
                           " a.piece, a.other_col,	b.SKU, b.SKU as model_name, 	b.PRODUCTNAME, b.DESCRIPTION, b.BUYLINK, " & _
                           " b.SUPPORTLINK, b.LISTPRICE,  b.SKU as advise_item , '' as img_url  FROM DAQ_wishlist_tmp as  a " & _
                           " Inner Join DAQ_products as b ON a.cheap_pid = b.PRODUCTID " & _
                           "  WHERE sessionid = '" + Session.SessionID + "'  ORDER BY a.cheap_pid	"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
       ' Dim ADV As New ADVWWWLocal.AdvantechWebServiceLocal
       
        If dt.Rows.Count > 0 Then
          
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim sku As String = dt.Rows(i).Item("SKU")
                Dim P() As String = Split(sku, "-")
                If P.Length > 2 Then
                    dt.Rows(i).Item("model_name") = P(0) + "-" + P(1)
                    dt.Rows(i).Item("advise_item") = P(0)
                End If
                'Dim picurl As String = ADV.getModelImage(dt.Rows(i).Item("SKU").ToString, "img")
                'If picurl <> "http://www.advantech.com.tw/images/clear.gif" Then
                '    dt.Rows(i).Item("img_url") = picurl
                'Else
                dt.Rows(i).Item("img_url") = "http://my-global.advantech.eu/download/downloadlit.aspx?pn=" + dt.Rows(i).Item("SKU").ToString
                ' End If
                   
            Next
            dt.AcceptChanges()
        End If
      
        Return dt
    End Function

    Protected Sub pt_Click1(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        FROM_Email = "ia@advantech.com.tw"
        TO_Email = emailaddr.Text.ToString.Trim
        BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "[DAQ Your Way] Your Search Results"
        MailBody = MailBody & "<html><body style=""font-family:Arial,Helvetica,sans-serif; font-size:12px;"">"
        MailBody = MailBody & "<font size=""3"">Here are the results from your search on Advantech’s DAQ Your Way website. Let us know if you have any questions!</font><br><br>"
        MailBody = MailBody & "<table>"
        Dim product_result As DataTable = getProductDetail()
        If product_result.Rows.Count > 0 Then
            For i As Integer = 0 To product_result.Rows.Count - 1
                MailBody = MailBody & "<tr><td bgcolor=""#3da1db""><img src=""http://my-global.advantech.eu/daq/image/comblue_01.jpg"" width=""5"" height=""5""></td><td>"
                MailBody = MailBody & "<table width=""100%"" border=""1"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#bbbbbb""><tr><td bordercolor=""#FFFFFF"" bgcolor=""#FFFFFF"" width=""130""><div align=""center"">"
                MailBody = MailBody & String.Format("<a href=""{1}"" target=""_blank""><img src=""{0}"" height=""86"" border=""0""></a></div></td></tr></table></td><td valign=""center"" width=""400"">", product_result.Rows(i).Item("img_url"), product_result.Rows(i).Item("BUYLINK"))
                MailBody = MailBody & "<table width=""100%"" height=""90"" border=""1"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#bbbbbb""><tr><td valign=""top"" bordercolor=""#dae1f3"" bgcolor=""#dae1f3""><table "
                MailBody = MailBody & "width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""5""><tr><td width=""62%"" valign=""top""><table width=""100%"" border=""0"" cellspacing=""5"" cellpadding=""0""><tr><td class="
                If product_result.Rows(i).Item("cheap_pid") = "77" Then
                    MailBody = MailBody & String.Format("""daq-r-title"" ><a href=""{3}"" target=""_blank"">{0}</a><font size=""10px""> (pcs: {2})</font></td></tr><tr><td class=""daq-r-title-2"">{1}<br></td></tr></table></td><td width=""38%""", product_result.Rows(i).Item("model_name"), product_result.Rows(i).Item("description"), product_result.Rows(i).Item("other_col"), product_result.Rows(i).Item("BUYLINK"))
                Else
                    MailBody = MailBody & String.Format("""daq-r-title"" ><a href=""{3}"" target=""_blank"">{0}</a><font size=""10px""> (pcs: {2})</font></td></tr><tr><td class=""daq-r-title-2"">{1}<br></td></tr></table></td><td width=""38%""", product_result.Rows(i).Item("model_name"), product_result.Rows(i).Item("description"), product_result.Rows(i).Item("piece"), product_result.Rows(i).Item("BUYLINK"))
                End If
              
                MailBody = MailBody & "valign=""top""><table width=""100%"" border=""0"" cellspacing=""4"" cellpadding=""0""><tr><td><table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td width=""17%"""
                MailBody = MailBody & "><div align=""center""><img src=""http://my-global.advantech.eu/daq/image/data_logo.jpg"" width=""20"" height=""19""></div></td><td width=""83%""><a target=""_blank"" href="
                MailBody = MailBody & String.Format("""{0}"" class=""text"">Data Sheet</a></td></tr></table></td></tr><tr><td><table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=", product_result.Rows(i).Item("supportlink"))
                MailBody = MailBody & """0""><tr><td width=""17%""><div align=""center""><img src=""http://my-global.advantech.eu/daq/image/buy_logo.jpg"" width=""20"" height=""20""></div></td><td width=""83%""><a target=""_blank"" href="
                MailBody = MailBody & String.Format("""{0}"" class=""text"">Buy Online </a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td><td valign=""top"" height=""100%""  ><table ", product_result.Rows(i).Item("buylink"))
                MailBody = MailBody & "width=""255"" height=""90"" border=""1"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#bbbbbb""><tr><td valign=""top"" bordercolor=""#dae1f3"" height=""100%"" bgcolor=""#dae1f3""><table width="
                MailBody = MailBody & """100%"" border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td ><table width=""100%"" border=""0"" cellspacing=""3"" cellpadding=""0""><tr><td class=""text"">Items in Wish "
                MailBody = MailBody & String.Format("List</td></tr></table></td></tr><tr><td bgcolor=""#bbbbbb""><img src=""{0}cube01.jpg"" width=""1"" height=""1""></td></tr><tr><td valign=""top"" ", "http://my-global.advantech.eu/daq/image/")
                MailBody = MailBody & String.Format("class=""text"">{0}:&nbsp;{1}</td></tr></table></td></tr></table></td></tr>", product_result.Rows(i).Item("class"), product_result.Rows(i).Item("wish_descr"))
            Next
        End If
    
        MailBody = MailBody & "</table></body></html>"
        Try
            Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Catch ex As Exception
                   
        End Try
        Try
            Dim ck As Integer = 0
            If ck1.Checked Then ck = 1
            Dim sqlinto As String = "insert into DAQ_EmailSolution (sessionid,Email_addr,check_box,Ip_addr,Request_date,Email_body) values " & _
                                    " ('" + Session.SessionID + "','" + emailaddr.Text.Replace("'", "''") + "'," + ck.ToString + ",'" + Util.GetClientIP() + "','" + System.DateTime.Now().ToString + "','" + MailBody.Replace("'", "''") + "')"
            ' Response.Write(sqlinto)
            dbUtil.dbExecuteNoQuery("MYLOCAL", sqlinto)
        Catch ex As Exception
            ' Response.Write( ex.ToString())     
        End Try
        pn1.Visible = False : pn2.Visible = True
        'lt1.Text = "Success!"
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
               
                    lt1.Text = "发送成功!"
                Case "zh-tw"
                 
                    lt1.Text = "成功送出!"
                Case Else
                    lt1.Text = "Success!"
            End Select
            
        End If
       
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim SQL = "SELECT * FROM DAQ_wishlist_tmp WHERE sessionid =  '" + Session.SessionID + "' and cheap_pid <> ''"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)
        If dt.Rows.Count > 0 Then
            pn1.Visible = True : pn2.Visible = False
        Else
            pn1.Visible = False : pn2.Visible = True
            lt1.Text = "Sorry, your search did not match any existing products."
        End If
      
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    fyx1.Text = "将搜索结果的链接发至我的邮箱"
                    fyx2.Text = "我的邮箱地址:"
                    fyx3.Text = "以后相关DAQ Your Way的最新动态，请发至我邮箱"
                    pt.ImageUrl = "./image/email_icon_01_j.png"
                    hidd1.Value = "jj"
                Case "zh-tw"
                    fyx1.Text = "Email DAQ Your Way的建議方案給我"
                    fyx2.Text = "我的Email:"
                    fyx3.Text = "我希望收到DAQ Your Way的相關資訊"
                    pt.ImageUrl = "./image/email_icon_01_f.png"
                    hidd1.Value = "ff"
                Case Else
                    hidd1.Value = "else"
            End Select
            
        End If
    End Sub
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>EMail</title>
<style type="text/css">
.email_title{
    line-height: 60px;
    font-family: Arial, Helvetica, sans-serif; font-size: 20px; color: #333399;
    font-weight: bold; 
    text-align: center;
}

.email_descr{
    text-align: center;
        font-family: Arial, Helvetica, sans-serif; font-size: 14px; color: #808080;
}

.email_descr_table{
    text-align: center;
}

.email_descr_table tr td{
    text-align: left;
}
</style>
</head>
<body class="DivBody">
    <form id="form1" runat="server"> <asp:HiddenField runat="server" ID="hidd1" />
    <asp:Panel runat="server" ID="pn1">
  
<div align="center" class="email_title">
<asp:Label runat="server" ID="fyx1" Text="Send the search result links to my email."></asp:Label><br />
</div>
<div class="email_descr" >
<asp:Label runat="server" ID="fyx2" Text="My E-Mail Address:"></asp:Label>
    <asp:TextBox runat="server" ID="emailaddr"  Width="154px"></asp:TextBox>

<br />

    <asp:CheckBox runat="server" ID="ck1" Checked="true" />
    <asp:Label runat="server" ID="fyx3" Text="I also want to receive the latest News of DAQ Your Way in the future."></asp:Label>
<p>
    <asp:ImageButton runat="server" ID="pt" ImageUrl="./image/email_icon_01.png" OnClientClick="return checkemail();" onclick="pt_Click1" />
</p>
</div>
  </asp:Panel>
    <asp:Panel runat="server" ID="pn2">
    
    <div align="center" class="email_title">
<asp:Literal runat="server" ID="lt1"></asp:Literal><br />
</div>
    
    </asp:Panel>
    <script language="javascript" type="text/javascript">
        function checkemail() {
            var strEmail = document.getElementById('<%=emailaddr.ClientID %>').value;
            if (strEmail == "") {

                var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
                if (strValue == "jj") { alert("邮箱不能为空!"); }
                if (strValue == "ff") { alert("郵箱不能爲空!"); }
                if (strValue == "else") { alert("Email cannot be empty!"); }
              
            
            
            return false; }
            if (strEmail.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) {
              
                return true;
            }
            else {
                var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
                if (strValue == "jj") { alert("邮箱格式不对!"); }
                if (strValue == "ff") { alert("Email格式不正確!"); }
                if (strValue == "else") { alert("EMail incorrect!"); }
             
                return false;
            }
        
        }
    
  
    </script>
    </form>
</body>
</html>
