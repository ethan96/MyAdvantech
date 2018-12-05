<%@ Page Title="" Language="VB"  %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'myIframe.Attributes.Add("src", "../Files/TermsAndConditions/TandC_english.htm")
        'Response.Write(Session("org_id"))
        'Session("org_id")="EU10"
        If Not IsPostBack Then
            If Session("org_id") Isnot Nothing andalso Session("org_id").ToString() <> "" Then
                Dim Org As String = Session("org_id").ToString.ToUpper.Trim
                Dim SQL As String = "SELECT [Row_ID],[ORG],[Language],[Img_Url] ,[Pdf_url] ,[File_Data]  ,[IsDefault] ,[IsAvailable]  FROM Terms_Conditions "
                Select Case 1
                    Case InStr(Org, "US")
                        If Org.Equals("US01") Then
                            SQL += " WHERE ORG = 'US01'"
                        ElseIf Org.Equals("US10") Then
                            SQL += " WHERE ORG = 'US10'"
                        Else
                            SQL += " WHERE ORG LIKE 'US%'"
                        End If
                    Case InStr(Org, "KR")
                        SQL += " WHERE ORG LIKE 'KR%'"
                    Case InStr(Org, "EU")
                        If Org.Equals("EU10") Then
                            SQL += " WHERE ORG = 'EU10'"
                        ElseIf Org.Equals("EU80") Then
                            SQL += " WHERE ORG = 'EU80'"
                        Else
                            SQL += " WHERE ORG LIKE 'EU%'"
                        End If
                    Case Else
                        SQL += " WHERE ORG LIKE 'EU%'"
                End Select
                SQL += " order by IsAvailable "
                Dim dt As DataTable = dbUtil.dbGetDataTable("my", SQL)
                If dt.Rows.Count > 0 Then
                    DL1.DataSource = dt
                    DL1.DataBind()
                    If Not IsDBNull(dt.Rows(0).Item("File_Data")) Then
                        TCcontent.Text = dt.Rows(0).Item("File_Data").ToString
                    End If
                End If
            End If
        End If
    End Sub

    Protected Sub ImgBT_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim row_id As String = DL1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, DataListItem).ItemIndex).ToString()
        Dim obj As Object = dbUtil.dbExecuteScalar("my", "select File_Data from Terms_Conditions where row_id = '" + row_id + "'")
        If obj IsNot Nothing AndAlso obj.ToString <> "" Then
            TCcontent.Text  = obj.ToString.Trim
        End If
    End Sub

    Protected Sub LinkBT_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim row_id As String = DL1.DataKeys(CType(CType(sender, LinkButton).NamingContainer, DataListItem).ItemIndex).ToString()
        Dim obj As Object = dbUtil.dbExecuteScalar("my", "select File_Data from Terms_Conditions where row_id = '" + row_id + "'")
        If obj IsNot Nothing AndAlso obj.ToString <> "" Then
            TCcontent.Text = obj.ToString.Trim
        End If
    End Sub

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Terms and Conditions </title>
    <style type="text/css">
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
    font-family:Arial, Helvetica, sans-serif;
}
.TClab{
    padding-left: 10px;
}
h1 {
	font-size: 14px;
	font-weight: bold;
    text-align: left;
}
</style>
</head>
<body>  
<form id="form1" runat="server">
<asp:ScriptManager runat="server">
</asp:ScriptManager>
  <asp:UpdatePanel runat="server" UpdateMode="Conditional">
                <ContentTemplate> 
                     <table width="896" border="0" align="center" valign="top" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <div align="center" style="font-family:Arial, Helvetica, sans-serif"><strong><u><font size="+1" color="navy"> General Business Terms and 
									Conditions for Advantech  </font></u></strong>
								</div>
								 <br/>
								<div align="center" style="font-family:Arial, Helvetica, sans-serif"><font color="#FF0000" size="-1"><u> Due to the local circumstances, these 
											articles could be subject to change.<br/>
											Advantech will keep the right to change these articles at any time in order to 
											comply to those circumstances. </u></font>
								</div><br />
                            </td>
                        </tr>
                        <tr>
                            <td align="center" valign="top"  >
                                <asp:DataList runat="server" ID="DL1" RepeatDirection="Horizontal" 
                                    DataKeyField="row_id" Width="98%" BorderWidth="0px" CellPadding="0" 
                                    HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td height="19" align="center">
                                                    <asp:ImageButton runat="server" ID="ImgBT" ImageUrl='<%# Eval("Img_Url") %>' BorderWidth="0" AlternateText='<%# Eval("Language") %>' width="57" height="38" OnClick="ImgBT_Click" />
                                                </td>  
                                            </tr>
                                            <tr>
                                                <td  height="12" align="center">
                                                    <asp:LinkButton runat="server" ID="LinkBT" Font-Size="14px" Font-Underline="false" ForeColor="Black" Font-Bold="true" OnClick="LinkBT_Click"><%# Eval("Language")%></asp:LinkButton>
                                                </td>  
                                            </tr>
                                             <tr>
                                                <td  height="11" align="center">
                                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("Pdf_url") %>' Font-Underline="false" Font-Size="11px">( Download )</asp:HyperLink>
                                                </td>                   
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:DataList>
                            </td>
                        </tr>
                        <tr>
                            <td style="height:173px" align="left" Width="100%" style="padding-top:5px;">                                 
                                        <asp:Panel runat="server" ID="PN1" Width="100%" Height="173px"  CssClass="TClab" ScrollBars="Vertical" BorderColor="#D4D0C8" BorderWidth="2" BorderStyle="Inset">
                                            <asp:Label runat="server" id="TCcontent" Text=""></asp:Label>
                                        </asp:Panel>
             
                            </td>
                        </tr>
                    </table>
   </ContentTemplate>
</asp:UpdatePanel>
<script     language= "javascript" type="text/javascript"> 
function  changeSrc(url) 
{
//    var ifm = document.getElementById('=myIframe.ClientID ');
//    ifm.src = "../Files/TermsAndConditions/TandC_" + url + ".htm";
//    return false;
} 
</script> 
        </form>
    </body>
</html>


