<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
   
        Dim pid As String = Request("pid")
        If pid = "" Then
            Util.JSAlert(Me.Page, "PID  can't for empty")
            Exit Sub
        End If
        Dim sql As String = "SELECT a.PRODUCTID,  a.SKU, '' as MODEL_NAME, '' as img_url, " & _
                         " a.PRODUCTNAME,   a.DESCRIPTION,  a.ENABLE,   a.BUYLINK,   a.SUPPORTLINK,  a.LISTPRICE,   a.FLAG " & _
                         " FROM    daq_products as a  Inner Join daq_products_categories  as b ON b.PRODUCTID = a.PRODUCTID " & _
                         " WHERE   b.CATEGORYID =  (  SELECT top 1 CATEGORYID FROM   daq_products_categories " & _
                         " WHERE  PRODUCTID =  '" + pid + "' AND   MAIN =  '0'   ) " & _
                         " AND  a.PRODUCTID != '" + pid + "'  AND  b.MAIN =  '0'  AND    a.ENABLE = 'y'   ORDER BY a.sku "
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        Dim ADV As New WWWLocal.AdvantechWebServiceLocal
       
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim sku As String = dt.Rows(i).Item("SKU")
                Dim P() As String = Split(sku, "-")
                If P.Length > 2 Then
                    ' dt.Rows(i).Item("model_name") = P(0) + "-" + P(1)
                    dt.Rows(i).Item("model_name") = P(0)
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
            rp.DataSource = dt
            rp.DataBind()
        End If
    End Sub
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
        <a target="_blank" href="<%# Eval("supportlink")%>" class="text">Data Sheet</a><br />
        <img src="./image/buy_logo.jpg" width="20" height="20">
        <a target="_blank" href="<%# Eval("buylink")%>" class="text">Buy Online </a>
</td>
</tr>
    
    </ItemTemplate>
    </asp:Repeater>
    </table>
    </form>
</body>
</html>
