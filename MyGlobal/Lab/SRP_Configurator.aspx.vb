
Partial Class Lab_SBR_Configurator
    Inherits System.Web.UI.Page
    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        If Request.IsAuthenticated = False OrElse String.IsNullOrEmpty(Request("ID")) OrElse String.IsNullOrEmpty(Request("QTY")) OrElse String.IsNullOrEmpty(Request("Name")) Then Response.Redirect(Request.ApplicationPath)

        If Not Page.IsPostBack Then
            Dim qty As Integer = 1
            Integer.TryParse(Request("ID").ToString, qty)
            'SetSourcePath(Request("ID").ToString, qty)

            ltBreadPath.Text = String.Format("<span style='width: 41%;'><font color='Navy'>■</font>&nbsp;&nbsp;<a href='/Order/btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;{0}</strong>", Request("Name"))
        End If
    End Sub
    'Private Sub SetSourcePath(ByVal strBTOItem As String, ByVal intConfigQty As Integer)
    '    Dim strhtml As String = ""
    '    strBTOItem = "SRP-FEC220-U2271AE"
    '    strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='./btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
    '    If MyCBOMDAL.IsEstoreBom(strBTOItem) Then
    '        strhtml += "<a href='./CBOM_eStoreBTO_List1.aspx' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + "eStore BTOS" + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
    '    Else
    '        strhtml += "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(strBTOItem)) + "' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + get_catalog_type(Trim(strBTOItem), 1) + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
    '    End If
    '    strhtml += "<a href='./Configurator.aspx?BTOITEM=" + strBTOItem + "&QTY=" + intConfigQty.ToString() + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + strBTOItem + "</a>"

    '    ltBreadPath.Text = String.Format("")
    '    page_path.InnerHtml = strhtml
    'End Sub
    Private Shared Function get_catalog_type(ByVal name As String, Optional ByVal Flag As Integer = 0) As String
        Dim catalog_name As String = ""
        Dim dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select catalog_type from CBOM_CATALOG where Catalog_org='" & Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2) & "' and CATALOG_NAME = '" + name + "'")
        If dt.Rows.Count > 0 Then
            If Not Convert.IsDBNull(dt.Rows(0).Item("catalog_type")) Then
                catalog_name = dt.Rows(0).Item("catalog_type").ToString.Trim
            End If
        End If
        If Flag = 1 Then
            Dim CBOMWS As New MyCBOMDAL
            Return CBOMWS.getCatalogLocalName(catalog_name, Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2))
        Else
            Return catalog_name
        End If
    End Function
End Class
