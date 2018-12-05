<%@ Control Language="VB" AutoEventWireup="false" CodeFile="BTOSService_Center.ascx.vb" Inherits="Home_BTOS_Center" %>
<script runat="server">
    Dim strBtosCenter As String = ""
    Sub BuildBtosServiceCenter()
        Dim strSqlCmd As String
        If Util.IsAEUIT() Or Util.IsInternalUser2() Then
            strSqlCmd = _
            "select DISTINCT IsNull(Catalog_Type, '') as Catalog_Type from CBOM_Catalog WHERE Catalog_Type not in ('','Pre-Configuration')"
        Else
            strSqlCmd = "select DISTINCT IsNull(Catalog_Type, '') as Catalog_Type from CBOM_Catalog WHERE Catalog_Type not in ('CTOS', '','Pre-Configuration') "
        End If
        Dim BtosDT As DataTable
        BtosDT = dbUtil.dbGetDataTable("B2B", strSqlCmd)

        Dim dr As DataRow = BtosDT.NewRow
        dr.Item(0) = "Pre-Configuration"
        BtosDT.Rows.Add(dr)

        Dim strNewRow, strNewCell, strEndRow As String
        Dim xFlag As Boolean = True
        Dim xEndFlag As Boolean = True
        If BtosDT.Rows.Count Mod 2 <> 0 Then
            xEndFlag = True
        End If
        Dim i As Integer = 0
        Do While i <= BtosDT.Rows.Count - 1
            If xFlag = True Then
                strNewRow = "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""1"">"
                strNewRow = strNewRow & "<tr bgcolor='#FFFFFF'>"
                strBtosCenter &= strNewRow
                strNewRow = ""
            End If
            
            strNewCell = "<td width='50%' height='25'>"
            strNewCell = strNewCell & "<table width='100%' height='25' border='0' cellpadding='0' cellspacing='0' class='text'>"
            strNewCell = strNewCell & "<tr onMouseOver='this.style.backgroundColor=""#FFFBC0"";' onMouseOut='this.style.backgroundColor=""#FFFFFF"";'> "
            strNewCell = strNewCell & "<td width='11%' align=""center""><div align='center'><img src='../images/ebiz.aeu.face/square_blue.gif' width='6' height='6'></div></td>"
            strNewCell = strNewCell & "<td width='89%' align=""left"">" & "<a href='../order/CBOM_List.aspx?Catalog_Type=" & BtosDT.Rows(i).Item("Catalog_Type") & "'><b><font color='000099'>" & BtosDT.Rows(i).Item("Catalog_Type") & "</font></b></a>"
            If BtosDT.Rows(i).Item("Catalog_Type") = "Pre-Configuration" Then
                strNewCell = strNewCell & "&nbsp;<img src='../images/new2.gif' alt='' />"
            End If
            strNewCell = strNewCell & "</td>"
            strNewCell = strNewCell & "</tr></table></td>"
            strBtosCenter &= strNewCell
            strNewCell = ""
            
            If Not xFlag Then
                strEndRow = "</tr></table>"
                strBtosCenter &= strNewCell
                strEndRow = ""
            End If
            
            If xFlag = True Then
                xFlag = False
            Else
                xFlag = True
            End If
            i = i + 1
        Loop
        
        If xEndFlag = True Then
            strBtosCenter &= "<td width='50%' height='25'></td></tr></table>"
        End If
    End Sub
</script>

<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<!-- title folder -->
		<td><a name="btos"></a>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table1">
				<tr>
					<td width="28"><img src="../images/ebiz.aeu.face/titlefolder_left.gif" width="28" height="26"></td>
					<td width="142" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text"><div align="center"><font color="000066"><b>BTO 
									Service</b></font></div>
					</td>
					<td width="21"><img src="../images/ebiz.aeu.face/titlefolder_right.gif" width="21" height="26"></td>
					<td background="../images/ebiz.aeu.face/folder_line.gif">&nbsp;</td>
				</tr>
			</table>
            <table cellpadding="0" cellspacing="0" width="98%">
                <tr>
                    <td height="8">
                    </td>
                </tr>
                <tr>
                    <!-- main table -->
                    <td valign="top" bgcolor="EEEEEE">
                        <% =strBtosCenter%>
                                         
                    </td>
                </tr>
            </table>
		</td>
	</tr>
	<!--tr>
		<td height="8px"></td>
	</tr>
	<tr>
		
		<td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table2">
				<tr>
					<td valign="top" bgcolor="EEEEEE">
						
						
					</td>
				</tr>
			</table>
		</td>
	</tr-->
</table>