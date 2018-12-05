<%@ Page Title="Advantech DAQ Your Way - Click, Search, and Discover the Perfect Data Acquisition Solution" Language="VB" MasterPageFile="~/DAQ/MyDAQMaster.master" %>
<%@ Register assembly="FlashControl" namespace="Bewise.Web.UI.WebControls" tagprefix="Bewise" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)       
        Dim PN As String = Request("PN")                  
        If Session("Browser_lan") IsNot Nothing AndAlso Session("Browser_lan").ToString() <> "" Then
            Dim lan As String = Session("Browser_lan").ToString.ToLower
            Select Case lan
                Case "zh-cn"
                    If PN = "2" Then
                        FlashControl1.MovieUrl = "./image/jw-1-2.swf"
                    Else
                        FlashControl1.MovieUrl = "./image/jw-1.swf"
                    End If
                Case "zh-tw"
                    If PN = "2" Then
                        FlashControl1.MovieUrl = "./image/fw-1-2.swf"
                    Else
                        FlashControl1.MovieUrl = "./image/fw-1.swf"
                    End If
                Case Else
                    If PN = "2" Then
                        FlashControl1.MovieUrl = "./image/w-1-2.swf"
                    Else
                        FlashControl1.MovieUrl = "./image/w-1.swf"
                    End If
            End Select
        End If               
        Call clean_session_data("DAQ_available_list_check")
        Call clean_session_data("DAQ_available_list_tmp")
        Call clean_session_data("DAQ_wishlist_tmp")
        Session("q1_vid") = ""
        Session("q2_vid") = ""
        Session("q3_vid") = ""
        Session("q4_vid") = ""
    End Sub
    Protected Sub clean_session_data(ByVal table_name As String)
        Dim sql As String = "SELECT *  FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM " + table_name + " WHERE sessionid = '" + Session.SessionID + "'")
        End If
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
  <%--  <asp:Panel runat="server" ID="pn1">--%>

<table style="margin-left:20px;" width="890" border="0" cellspacing="0" cellpadding="0">
  <tr><td height="4"></td></tr>
  <tr>
    <td>	
	<%--  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="890" height="450">
        <param name="movie" value="./image/w-1.swf" />
        <param name="quality" value="high" />
        <param name="wmode" value="opaque" />
        <embed src="./image/w-1.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="890" height="450"></embed>
      </object>--%>
      
      <Bewise:FlashControl ID="FlashControl1" runat="server" Height="450px" 
        Width="890px" MovieUrl="./image/w-1.swf" Loop="True"  WMode="Opaque"/>
        
      	</td>

  </tr>
</table>
   <%-- </asp:Panel>
      <asp:Panel runat="server" ID="pn2">

<table style="margin-left:20px;" width="890" border="0" cellspacing="0" cellpadding="0">
  <tr><td height="4"></td></tr>
  <tr>
    <td>	
	  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="890" height="450">
        <param name="movie" value="./image/w-1-2.swf" />
        <param name="quality" value="high" />
        <param name="wmode" value="opaque" />
        <embed src="./image/w-1-2.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="890" height="450"></embed>
      </object>	</td>

  </tr>
</table>
    </asp:Panel>--%>
    <script language="javascript" type="text/javascript">
        function onload_get_wishlist() { }
    
    </script>
</asp:Content>

