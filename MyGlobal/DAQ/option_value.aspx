<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim optionid As String = ""
    Dim classid As String = ""
    Dim spec_type_description As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        optionid = Request("optionid")
        classid = Request("classid")
        If Not IsPostBack Then
            bind()
        End If
    End Sub
    Protected Sub bind()
        Dim sql As String = " SELECT b.OPTIONID, a.CLASS, b.OPTION_NAME, b.OPTION_TYPE, b.DESCRIPTION " & _
                                 " FROM daq_spec_class as a Inner Join daq_spec_options  as b ON a.CLASSID = b.CLASSID " & _
                                 " WHERE a.CLASSID =  '" + classid + "' AND b.OPTIONID =  '" + optionid + "'"
            
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            spec_class.Text = dt.Rows(0).Item("class")
            spec_option.Text = dt.Rows(0).Item("OPTION_NAME")
            If dt.Rows(0).Item("option_type").ToString = "m" Then
                spec_type.Text = "Multiple option selector"
            Else
                spec_type.Text = "Single option selector"
            End If
            spec_type_description = dt.Rows(0).Item("DESCRIPTION").ToString
            If spec_type_description <> "" Then
                spec_type_description = spec_type_description.Replace("\n", vbCrLf)
            End If
        End If
        Dim sql2 As String = "SELECT ORDER_BY, OPTION_VALUE, GROUP_daq, GROUP_DESCR, OPTION_VALUEID " & _
                               " FROM daq_spec_options_values  WHERE OPTIONID =  '" + optionid + "' ORDER BY ORDER_BY ASC "
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql2)
        If dt2.Rows.Count > 0 Then
            GridView1.DataSource = dt2
            GridView1.DataBind()
        End If
            
    End Sub

    Protected Sub del_link_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim option_valueid_it As String = GridView1.DataKeys(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).RowIndex).Values(0)
        Dim sql As String = "DELETE FROM daq_spec_options_values WHERE option_valueid ='" + option_valueid_it + "'"
       ' Response.Write(sql)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        bind()
     
    End Sub

    Protected Sub updatebt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim arr As New ArrayList
        For Each r As GridViewRow In GridView1.Rows
            If r.RowType = DataControlRowType.DataRow Then          
                Dim tb1 As String = CType(r.FindControl("tb1"), TextBox).Text.Replace("'", "''")
                Dim tb2 As String = CType(r.FindControl("tb2"), TextBox).Text.Replace("'", "''")
                Dim tb3 As String = CType(r.FindControl("tb3"), TextBox).Text.Replace("'", "''")
                Dim tb4 As String = CType(r.FindControl("tb4"), TextBox).Text.Replace("'", "''")
                arr.Add(String.Format("UPDATE daq_spec_options_values SET  option_value = '{0}', group_daq = '{1}',group_descr = '{2}',order_by = '{3}'  WHERE option_valueid = '{4}'",
                                      tb2, tb3, tb4, tb1, GridView1.DataKeys(r.RowIndex).Values(0)))
                        
            End If
        Next
       
        For Each aa As String In arr
            ' Response.Write(aa)
            ' Response.Write("<hr>")
            dbUtil.dbExecuteNoQuery("MYLOCAL", aa.ToString)
        Next
        bind()
    End Sub

    Protected Sub addbt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim MAX_option_valueid As String = ""
        Dim obj As Object = Nothing
        obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT MAX(option_valueid)+ 1  as max_proid FROM DAQ_spec_options_values")
        If obj IsNot Nothing Then
            MAX_option_valueid = obj.ToString()
        Else
            MAX_option_valueid = "10000"
        End If
        
        Dim sql As String = String.Format("INSERT INTO DAQ_spec_options_values (optionid,option_valueid, option_value,order_by,group_daq,group_descr) values('{0}','{1}','{2}','{3}','{4}','{5}')",
                                      optionid, MAX_option_valueid, add_option_value.Value.ToString.Replace("'", "''"), add_order_by.Value.ToString.Replace("'", "''"), add_option_group.Value.ToString.Replace("'", "''"), add_option_group_descr.Value.ToString.Replace("'", "''"))
        'Response.Write(sql)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        bind()
    End Sub
    <System.Web.Services.WebMethod()> _
    Public Shared Function xajax_edit_option_scription_server(ByVal str As String) As String
        Dim returnvalue As String = "0"
        If str <> "" Then
            Dim p() As String = Split(str, "#")
            Dim sql As String = "UPDATE daq_spec_options SET description = '" + p(1) + "' WHERE optionid = '" + p(0) + "'"
            If dbUtil.dbExecuteNoQuery("MYLOCAL", sql) > 0 Then
                returnvalue = "1"
            End If
        End If
        Return returnvalue
    End Function
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <link href="css.css" rel="stylesheet" type="text/css" />
    <asp:ScriptManager runat="server" ID="sm1" EnablePageMethods="true" >
    </asp:ScriptManager>
     <script language="javascript" type="text/javascript">
         function xajax_edit_option_scription(optionid,value) {
            var arrID = "";

            PageMethods.xajax_edit_option_scription_server(optionid + "#" + value, OnPageMethods_1Succeeded, OnGetPriceError, arrID);
        }
        function OnPageMethods_1Succeeded(result, arrID, methodName) {
           
            return true;
        }
        function OnGetPriceError(error, arrID, methodName) {
            if (error !== null) {
                if (error !== null) {
                   
                   alert(error.get_message());
                }
            }
        }</script>
    <div class="content_box">

<table width="560" cellpadding="2" cellspacing="2"   border="0">
<tr><th colspan="4" >Edit option values</th></tr>
<tr><td width="" colspan="2">Class:</td><td colspan="2"><asp:Literal id="spec_class" runat="server"></asp:Literal></td></tr>
<tr><td colspan="2">Option:</td><td colspan="2"><asp:Literal id="spec_option" runat="server"></asp:Literal></td></tr>
<tr><td colspan="2">Option type:</td><td colspan="2">
<asp:Literal id="spec_type" runat="server"></asp:Literal>
</td></tr>
<tr><td colspan="2">Notes:</td>
<td colspan="2">
<textarea cols="70" rows="8"  style="width:450px;" onblur="xajax_edit_option_scription('<%= optionid %>',this.value);" ><%= spec_type_description%></textarea><%--wrap="Off"--%>
</td>
</tr></table>
        <asp:GridView runat="server"  Width="560px" AutoGenerateColumns="false" DataKeyNames="option_valueid" ID="GridView1">
        <Columns>
        <asp:TemplateField HeaderText="Del">
        <ItemTemplate>
            <asp:LinkButton runat="server" ID="del_link" Font-Underline="false"   ForeColor="Red" Font-Bold="true" onclick="del_link_Click">X</asp:LinkButton>
        </ItemTemplate>
        </asp:TemplateField>
        
         <asp:TemplateField HeaderText="Order by">
        <ItemTemplate>
            <asp:TextBox runat="server" ID="tb1" Width="25"  Text='<%# Eval("order_by") %>'></asp:TextBox>
        </ItemTemplate>
        </asp:TemplateField>
         <asp:TemplateField HeaderText="Value">
        <ItemTemplate>
            <asp:TextBox runat="server" ID="tb2" Text='<%# Eval("OPTION_VALUE") %>'></asp:TextBox>
        </ItemTemplate>
        </asp:TemplateField>
         <asp:TemplateField HeaderText="Group">
        <ItemTemplate>
            <asp:TextBox runat="server" ID="tb3" Text='<%# Eval("GROUP_daq") %>'></asp:TextBox>
        </ItemTemplate>
        </asp:TemplateField>
         <asp:TemplateField >
        <ItemTemplate>
            <asp:TextBox runat="server" ID="tb4" Text='<%# Eval("GROUP_DESCR") %>'></asp:TextBox>
        </ItemTemplate>
        </asp:TemplateField>
        </Columns>
        </asp:GridView>



   <div style="height:25px; text-align:center; margin-top:10px;"> <asp:Button runat="server" ID="updatebt" Text="Update"   onclick="updatebt_Click" /></div>

<table width="560" style="margin-top:10px;">


<tr><td colspan="5">&nbsp;</td></tr>
<tr><th colspan="5">Add new value</th></tr>
<tr style="text-align:center;">
<th width="20"></th><th>Order by</th><th>value</th><th>group</th><th>group descr</th>

</tr>
<tr><td>&nbsp;</td>
<td style="text-align:center;"><input type="text" value="" size="10"   id="add_order_by" runat="server" style="text-align:center;width:25px;"/></td>
<td><input type="text" value="" size="30" id="add_option_value"  runat="server" style="text-align:center;width:70px;"/></td>
<td><input type="text" value="" size="10" id="add_option_group" runat="server" style="text-align:center;width:50px;"/>

</td>
<td><input type="text" value="" size="25" id="add_option_group_descr" runat="server" style="text-align:center;width:100px;"/></td>
</tr>
<tr><td colspan="5"><div align="center">
    <asp:Button runat="server" ID="addbt" Text="Add" onclick="addbt_Click" />
</div></td></tr>
</table>
</div><p align="center"><input type="button" value="Close" onclick="window.close();" onclick=""/></p>
    </form>
</body>
</html>
