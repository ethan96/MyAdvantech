<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub C_bt_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        '      
         FROM_Email = C_email.Value.ToString.Trim 
        TO_Email = "ia@advantech.com.tw"
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" AndAlso Session("Browser_lan").ToString.ToLower = "zh-tw" Then
            TO_Email = TO_Email + ";buy@advantech.tw"
        End If                  
        BCC_Email = "Tc.Chen@advantech.eu;Nada.Liu@advantech.com.cn;Ming.Zhao@advantech.com.cn"
        Subject_Email = "[DAQ Your Way] You have a new customize request"
        '
        MailBody = MailBody & "<html><body style=""font-family:Arial,Helvetica,sans-serif; font-size:12px;""><center>"
        MailBody = MailBody & "<table width=""600"" cellpadding=""3"" cellspacing=""3"">"
        MailBody = MailBody & " <tr><td colspan=""2"" bgcolor=""#CCFFCC"" align=""center""><b>Customer needs your suggestion</b></td></tr>"
        MailBody = MailBody & " <tr><td width=""180"" bgcolor=""#F3F3F3"">Customer name:</td><td>" + C_name.Value + "</td></tr>"
        MailBody = MailBody & " <tr><td bgcolor=""#F3F3F3"">Customer EMail:</td><td><a href=""mailto=" + C_email.Value + """>" + C_email.Value + "</a></td></tr>"
        MailBody = MailBody & "<tr><td bgcolor=""#F3F3F3"">Customer tel:</td><td>" + C_tel.Value + "</td> </tr>"
        If C_telEXT.Value.ToString <> "" Then
            MailBody = MailBody & "<tr><td bgcolor=""#F3F3F3"">Customer Ext:</td><td>" + C_telEXT.Value + "</td> </tr>"
        End If
        MailBody = MailBody & "<tr><td bgcolor=""#F3F3F3"">Customer country:</td><td>" + C_country.Value + "</td> </tr>"
        MailBody = MailBody & "<tr><td bgcolor=""#F3F3F3"">Customer remark:</td><td>" + C_remark.Value + "</td> </tr></table>"
        MailBody = MailBody & "</center></body></html>"
       
        Try
            MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Catch ex As Exception
                   
        End Try
        pn1.Visible = False : pn2.Visible = True
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
               
                    lt1.Text = "发送成功!"
                Case "zh-tw"
                 
                    lt1.Text = "發送成功!"
                Case Else
                    lt1.Text = "Success!"
            End Select
            
        End If
      
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    Lab01.Text = "客制化解决方案" : Lab02.Text = "请您填写以下信息,研华当地的销售人员可直接联络您."
                    Lab03.Text = "姓名:" : Lab04.Text = "邮件地址:" : Lab05.Text = "电话:" : Lab06.Text = "国家/地址:"
                    Lab07.Text = "备注(可选):"
                    Lab08.Text = "注意：客制化解决方案需有最少订货量的数量限制."
                    Lab09.Text = "以后相关DAQ Your Way的最新动态，请发至我邮箱."
                    C_bt.ImageUrl = "./image/email_icon_01_j.png"
                    hidd1.Value = "jj"
                    Labfj.Text = "分机:"
                Case ("zh-tw")
                    Lab01.Text = "客製化解決方案" : Lab02.Text = "請留下您的聯絡資訊，我們將立即與您聯繫."
                    Lab03.Text = "姓名:" : Lab04.Text = "Email:" : Lab05.Text = "電話:" : Lab06.Text = "縣市:"
                    Lab07.Text = "備註:"
                    Lab08.Text = " 研華產品客製化服務有基本訂單數量(MOQ)的需求限制."
                    Lab09.Text = "我希望收到DAQ Your Way的相關資訊."
                    C_bt.ImageUrl = "./image/email_icon_01_f.png"
                    hidd1.Value = "ff"
                    Labfj.Text = "分機:"
                Case Else
                    hidd1.Value = "else"
            End Select
            
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Advantech</title>
    <style type="text/css">
        body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
.DivBody
{
	background-color:White;
	margin-top:0px;
	margin-left:0px;
	padding:0px;
	width:600px;
	height:449px;
	
	}

.DivAlign
{
    clear:right;
    float:left;
    }
    
.DivAlignRight
{
    float:right;
    }    
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
    <form id="form1" runat="server"><asp:HiddenField runat="server" ID="hidd1" />
    <asp:Panel runat="server" ID="pn1" >

<div align="center" class="email_title"><asp:Label runat="server" ID="Lab01" Text="Customize Solution"></asp:Label><br /></div>
<div class="email_descr" align="center">
<table width="400" align="center" border="0" cellpadding="2" cellspacing="2" class="email_descr_table" >
<tr><td colspan="2">
<asp:Label runat="server" id="Lab02" Text="Please leave the information below for Advantech regional salesperson to contact you directly. Thank you."></asp:Label>
<p></p>
</td></tr>
<tr>
<td><asp:Label runat="server" ID="Lab03" Text="Name:"></asp:Label></td>
<td><input type="text" size="40" runat="server" name="C_name" id="C_name" maxlength="32"/></td>
</tr>
<tr>
<td><asp:Label ID="Lab04" runat="server" Text="Email Address:"></asp:Label></td>
<td><input type="text" size="40" runat="server" name="C_email" id="C_email" maxlength="64" onblur="return emailCheck();"/></td>
</tr>
<tr>
<td><asp:Label runat="server" ID="Lab05" Text="Tel:"></asp:Label></td>
<td><input type="text" size="24" runat="server" name="C_tel" id="C_tel" maxlength="16"/>&nbsp;<asp:Label runat="server" ID="Labfj" Text="Ext:"/> <input type="text" runat="server" size="5" name="C_telEXT" ID="C_telEXT" maxlength="6"/></td>
</tr>
<tr>
<td><asp:Label runat="server" ID="Lab06" Text="Country:"></asp:Label></td>
<td><input type="text" size="40" runat="server" name="C_country" id="C_country" onblur=""/></td>
</tr>
<tr>
<td><asp:Label runat="server" ID="Lab07" Text="Remark(Optional):"></asp:Label></td>
<td><input type="text" size="40" runat="server" name="C_remark" id="C_remark" maxlength="128"/></td>
</tr>
</table>
<span id="msg"></span>
<p style="font-size:11px;">*<asp:Label runat="server" ID="Lab08" Text="Please note that the customize solution requires minimum order quantity(MOQ)."></asp:Label>
</p>

<input type="checkbox" value="scribe_news" checked=""/>
<asp:Label runat="server" ID="Lab09"  Text="I also want to receive the latest News of DAQ Your Way in the future."></asp:Label>
<p>
    <asp:ImageButton runat="server" ID="C_bt" ImageUrl="./image/email_icon_01.png" 
        onclick="C_bt_Click"  OnClientClick="return checkfields();"/>
</p>

</div>    </asp:Panel>
  <asp:Panel runat="server" ID="pn2">
    
    <div align="center" class="email_title">
<asp:Literal runat="server" ID="lt1"></asp:Literal>
</div>
    
    </asp:Panel>
<script language="javascript" type="text/javascript">
    function emailCheck() 
    {
        var strEmail = document.getElementById('<%=C_email.ClientID %>').value;
        if (strEmail.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) {
            document.getElementById("msg").innerHTML = "";
            return true;
        }
        else {
            var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
            if (strValue == "jj") { document.getElementById("msg").innerHTML = "<font color='red'>Email格式不正确！</font>"; }
            if (strValue == "ff") { document.getElementById("msg").innerHTML = "<font color='red'>Email格式不正確！</font>"; }
            if (strValue == "else") { document.getElementById("msg").innerHTML = "<font color='red'>Email is invalid.</font>"; }
         
            return false;
        }
            
    }
     function checkfields()
     {

         if (document.getElementById('<%=C_name.ClientID %>').value == "") {

             var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
             if (strValue == "jj") { alert("请输入姓名!"); }
             if (strValue == "ff") { alert("姓名為必填欄位!"); }
             if (strValue == "else") { alert("Name cannot be empty"); }
            
       return false; }
   if (document.getElementById('<%=C_email.ClientID %>').value == "") {
       var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
       if (strValue == "jj") { alert("请输入邮箱!"); }
       if (strValue == "ff") { alert("請輸入郵箱!"); }
       if (strValue == "else") { alert("Email cannot be empty"); }
       
         return false; }
       var strEmail = document.getElementById('<%=C_email.ClientID %>').value;
       if (strEmail.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) {
           document.getElementById("msg").innerHTML = "";
           //return true;
       }
       else {
           var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
           if (strValue == "jj") {
               document.getElementById("msg").innerHTML = "<font color='red'>邮箱格式不对.</font>";
               alert("邮箱格式不对.");
           }
           if (strValue == "ff") {
               document.getElementById("msg").innerHTML = "<font color='red'>郵箱格式不對.</font>";
               alert("郵箱格式不對.");
           }
           if (strValue == "else") {
               document.getElementById("msg").innerHTML = "<font color='red'>Email is invalid.</font>";
               alert("Email is invalid.");
           }
       
           return false;
       }

       if (document.getElementById('<%=C_tel.ClientID %>').value == "") {


           var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
           if (strValue == "jj") { alert("请输入电话!"); }
           if (strValue == "ff") { alert("請輸入電話!"); }
           if (strValue == "else") { alert("Tel cannot be empty"); }
          
       
       
       return false; }

       if (document.getElementById('<%=C_tel.ClientID %>').value != "") {

           if(checknumber(document.getElementById('<%=C_tel.ClientID %>').value))
           {
               var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
               if (strValue == "jj") { alert("仅使用电话号码!"); }
               if (strValue == "ff") { alert("電話格式需為數字!"); }
               if (strValue == "else") { alert("Tel Uses only numbers!"); }
             
               return false;
           }
        }
       if (document.getElementById('<%=C_telEXT.ClientID %>').value != "") {

           if (checknumber(document.getElementById('<%=C_telEXT.ClientID %>').value)) {


               var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
               if (strValue == "jj") { alert("分机仅使用数字!"); }
               if (strValue == "ff") { alert("分機僅使用數字!"); }
               if (strValue == "else") { alert("Ext Uses only numbers!"); }
            
               return false;
           }
       }
       if (document.getElementById('<%=C_country.ClientID %>').value == "") {

           var strValue = document.getElementById("<%=hidd1.ClientID%>").value;
           if (strValue == "jj") { alert("国家/地址不能为空!"); }
           if (strValue == "ff") { alert("國家/地址不能爲空!"); }
           if (strValue == "else") { alert("Country cannot be empty"); }
          
       
       
        return false; }
     
     }
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
    </form>
</body>
</html>
