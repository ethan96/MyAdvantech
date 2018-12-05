<script runat="server">
    Dim RoHSTermsHTML As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim xType As String = "Logistics"
        Dim strLogistics_ID As String = ""
        Dim strOrderNO As String = ""
        Dim strCompanyID As String = ""
        Try
            xType = Request("xType")
        Catch ex As Exception
            xType = "LOGISTICS"
        End Try
        If xType = Nothing Or xType = "" Then xType = "LOGISTICS"
        If xType.ToUpper = "LOGISTICS" Then
            strLogistics_ID = Session("Logistics_ID")
        ElseIf xType.ToUpper = "ORDER" Then
            strCompanyID = Request("customerid")
            If strCompanyID = Nothing Or strCompanyID = "" Then Response.Redirect("../login.aspx")
            Try
                strOrderNO = Request("Order_NO")
                Dim OrderIDDT As DataTable = dbUtil.dbGetDataTable("B2B", "select distinct order_id,SoldTo_ID,IsNull(NONERoHS_ACCEPT,'') as NONERoHS_ACCEPT from order_master where order_no='" & strOrderNO & "'")
                strLogistics_ID = OrderIDDT.Rows(0).Item("order_id")
                'Response.Write(OrderIDDT.Rows(0).Item("NONERoHS_ACCEPT").ToString.ToUpper)
                If strCompanyID.ToUpper <> OrderIDDT.Rows(0).Item("SoldTo_ID").ToString.ToUpper Then Response.Redirect("../login.aspx")
                If OrderIDDT.Rows(0).Item("NONERoHS_ACCEPT").ToString.Trim.ToUpper <> "Y" Then
                    Response.Write("<b>This order did not contain RoHS agreement.</b><br/><br/><a href='../home/home.aspx'>HomePage</a>") : Response.End()
                End If
            Catch ex As Exception
                strLogistics_ID = ""
            End Try
        Else
        strLogistics_ID = Session("Logistics_ID")
        End If
        OrderUtilities.GetRoHSTerms(strLogistics_ID, xType, RoHSTermsHTML)
    End Sub
    
    
</script>

<html>
 <div>
    <%=RoHSTermsHTML %>
 </div>
</html>
   