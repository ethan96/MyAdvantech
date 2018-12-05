
Partial Class Order_Configurator_new
    Inherits System.Web.UI.Page

    Public ReadOnly Property CBOM_Org As String
        Get
            Dim orgid As String = Session("org_id").ToString
            If Session("org_id_cbom") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom").ToString) Then
                orgid = Session("org_id_cbom").ToString.ToUpper.Substring(0, 2)
            End If

            'Ryan 20180323 For ADLoG BTOS to distribute to worldwide
            If Request("ID") IsNot Nothing AndAlso Request("NAME") IsNot Nothing Then
                Dim objisADLOG As Object = dbUtil.dbExecuteScalar("CBOMV2", String.Format("SELECT TOP 1 [ORG] FROM [CBOM_CATALOG_CATEGORY_V2] WHERE ID = '{0}' AND CATEGORY_ID = '{1}' ", Request("ID"), Request("NAME")))
                If objisADLOG IsNot Nothing AndAlso objisADLOG.ToString.Equals("DL") Then
                    orgid = objisADLOG.ToString
                End If
            End If

            Return orgid
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Request("ID") IsNot Nothing AndAlso Request("NAME") IsNot Nothing Then
                Dim isEstoreBOM As Boolean = False
                Dim intConfigQty As Integer = 1
                Dim strBTOItem As String = Trim(Request("NAME"))
                Dim strBTOId As String = Trim(Request("ID"))
                If MyCBOMDAL.IsEstoreBom(strBTOItem) Then
                    isEstoreBOM = True
                End If

                If Request("QTY") IsNot Nothing AndAlso Integer.TryParse(Request("QTY"), 1) AndAlso CInt(Request("QTY")) > 0 Then
                    Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initConfigQty",
                   "$('#hdBTOQty').val('" + CInt(Request("QTY")).ToString() + "');", True)
                    intConfigQty = CInt(Request("QTY"))
                End If

                SetSourcePath(strBTOItem, intConfigQty)
                hdBTOId.Value = strBTOId
                hdBTOName.Value = strBTOItem
                hdCurrencySign.Value = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN").ToString
                hdLanguage.Value = Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2)

                'Ryan 20170324 Set dlACNStorageLocation visiblity.
                If Not HttpContext.Current.Session("ACN_StorageLocation") Is Nothing AndAlso HttpContext.Current.Session("Org_id").ToString.ToUpper.Equals("CN10") Then
                    'Me.dlACNStorageLocation.Visible = True

                    If Not Me.dlACNStorageLocation.Items.FindByValue(HttpContext.Current.Session("ACN_StorageLocation")) Is Nothing Then
                        Me.dlACNStorageLocation.Items.FindByValue(HttpContext.Current.Session("ACN_StorageLocation")).Selected = True
                    End If
                End If

            Else
                Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "AlertDialog",
              " AlertDialog('Request cannot be empty!');", True)
            End If
            If Not Me.CBOM_Org.Equals("CN") Then pnOthers.Visible = False
        End If
    End Sub

    Private Sub SetSourcePath(ByVal strBTOItem As String, ByVal intConfigQty As Integer)
        'Dim strhtml As String = ""
        'If get_catalog_type(strBTOItem).ToLower = "iservices group" Then
        '    If Not Util.ISIServices_Group_Account() Then
        '        Response.Redirect("~/home.aspx")
        '    End If
        'End If
        'strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='./btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
        'strhtml += "<a href='./Lab/CBOMV2/CBOM_ListV2.aspx?ID=" + Request("ID") + "' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + get_catalog_type(Trim(Request("BTOITEM")), 1) + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>"
        'strhtml += "<a href='./Order/Configurator_new.aspx?ID=" + Request("ID") + "&NAME=" + Request("NAME") + "&QTY=" + Request("QTY") + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + strBTOItem + "</a>"

        'page_path.InnerHtml = strhtml
    End Sub

    Private Shared Function get_catalog_type(ByVal name As String, Optional ByVal Flag As Integer = 0) As String
        'Dim objCatalog As Object = dbUtil.dbExecuteScalar("CBOMV2", "")

    End Function

    Protected Sub dlACNStorageLocation_SelectedIndexChanged(sender As Object, e As EventArgs)

        If Not Me.dlACNStorageLocation.SelectedItem Is Nothing AndAlso Not Me.dlACNStorageLocation.SelectedValue Is Nothing Then
            HttpContext.Current.Session("ACN_StorageLocation") = Me.dlACNStorageLocation.SelectedValue
        End If

    End Sub

End Class
