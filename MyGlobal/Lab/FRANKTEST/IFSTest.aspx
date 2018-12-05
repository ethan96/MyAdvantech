<%@ Page Language="VB" %>

<%@ Import Namespace="advantech" %>
<!DOCTYPE html>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        Dim a = Nothing
        Me.Label1.Text = String.IsNullOrEmpty(a)
        
        Dim _order As New Advantech.Myadvantech.DataAccess.Order()
        Dim _errmsg As String = String.Empty
        Dim _US01_ERPID As String = "UEPP5001"
        Dim _US01_ORGID As String = "US01"
        Dim _DistChannel As String = "10"
        Dim _Division As String = "20"
        Dim _Currency As String = "USD"
        _order.Currency = _Currency
        _order.OrgID = _US01_ORGID
        _order.DistChannel = _DistChannel
        _order.Division = _Division
        
        'Dear Frank,

        '        請參考此SQL()

        'select a.* from  [dbo].[BBESTORE_WEB_PRICE] a
        'INNER JOIN SAP_PRODUCT_ORG b on a.PartNo = b.PART_NO
        'INNER JOIN SAP_PRODUCT c on a.PartNo = c.PART_NO
        'where b.ORG_ID = 'US10'
        'AND c.PRODUCT_LINE NOT IN ('BCEL','BDTN','BDTR','BENI','BESR','BFBR','BOTS','BSRL','BTLM','BUSB','BWFI','BWOT','BWZD','IOTG')

        '主要會從剛才你同步的SI price table
        '因為這是目前所有B+B eStore正式站有上架的產品
        'SAP product org 主要是去確認是不是都在US10有放上去
        'SAP product 則是要比對 product line，因為過去我們曾找出13組的”B+B product line”，因為未來B+B在PLM上產品後，料號開頭不會再是BB-開頭
        '也就是BB-開頭在未來不會是B+B產品判斷依據，我們只能透過此13組來辨別，

        '此SQL可以撈出184組產品，即是 B+B eStore有在賣的研華產品
        '感謝
        'IC.Chen
        
        Dim _sql As New StringBuilder
        _sql.AppendLine(" select a.* from  [dbo].[BBESTORE_WEB_PRICE] a ")
        _sql.AppendLine(" INNER JOIN SAP_PRODUCT_ORG b on a.PartNo = b.PART_NO ")
        _sql.AppendLine(" INNER JOIN SAP_PRODUCT c on a.PartNo = c.PART_NO ")
        _sql.AppendLine(" inner join SAP_PRODUCT_STATUS_ORDERABLE d on a.partno=d.PART_NO ")
        _sql.AppendLine(" where b.ORG_ID = 'US10' and d.SALES_ORG='US01' ")
        _sql.AppendLine(" AND c.PRODUCT_LINE NOT IN  ")
        '_sql.AppendLine(" ('BCEL','BDTN','BDTR','BENI','BESR','BFBR','BSRL','BTLM','BUSB','BWFI','BWOT','BWZD','IOTG') ")
        _sql.AppendLine(" ('BCEL','BDTN','BDTR','BENI','BESR','BFBR','BOTS','BSRL','BTLM','BUSB','BWFI','BWOT','BWZD','IOTG') ")
        Dim _dt As DataTable = dbUtil.dbGetDataTable("MY", _sql.ToString)
        
        
        Dim _party As New Advantech.Myadvantech.DataAccess.OrderPartner("UEPP5001", "US01", Myadvantech.DataAccess.OrderPartnerType.SoldTo)
        
        _order.SetOrderPartnet(New Advantech.Myadvantech.DataAccess.OrderPartner(_US01_ERPID, _US01_ORGID, Advantech.Myadvantech.DataAccess.OrderPartnerType.SoldTo))
        _order.SetOrderPartnet(New Advantech.Myadvantech.DataAccess.OrderPartner(_US01_ERPID, _US01_ORGID, Advantech.Myadvantech.DataAccess.OrderPartnerType.ShipTo))
        _order.SetOrderPartnet(New Advantech.Myadvantech.DataAccess.OrderPartner(_US01_ERPID, _US01_ORGID, Advantech.Myadvantech.DataAccess.OrderPartnerType.BillTo))
        
        
        Dim _newrow As DataRow = Nothing
        
        '_order.AddLooseItem("ADAM-4520-EE")
        For Each _row As DataRow In _dt.Rows
            
            _order.AddLooseItem(_row.Item("PartNo").ToString)
        Next
        
        Advantech.Myadvantech.DataAccess.SAPDAL.SimulateOrder(_order, _errmsg)
        
        Dim _downloadstr As New StringBuilder

        Dim _outputdt As New DataTable("US01ToUS10")
        _outputdt.Columns.Add(New DataColumn("Sales Org."))
        _outputdt.Columns.Add(New DataColumn("Currency"))
        _outputdt.Columns.Add(New DataColumn("Material"))
        _outputdt.Columns.Add(New DataColumn("Amount"))
        _outputdt.Columns.Add(New DataColumn("Price Unit"))
        _outputdt.Columns.Add(New DataColumn("From"))
        _outputdt.Columns.Add(New DataColumn("To"))

        
        For Each _lineitem As Advantech.Myadvantech.DataAccess.Product In _order.LineItems
            _newrow = _outputdt.NewRow
            _newrow.Item("Sales Org.") = "US10"
            _newrow.Item("Currency") = "USD"
            _newrow.Item("Material") = _lineitem.PartNumber
            _newrow.Item("Amount") = _lineitem.ListPrice.ToString("F2")
            _newrow.Item("Price Unit") = "1"
            _newrow.Item("From") = "20171201"
            _newrow.Item("To") = "99991231"
            _outputdt.Rows.Add(_newrow)
            '_downloadstr.AppendLine(_lineitem.PartNumber & " " & _lineitem.ListPrice.ToString("F2"))
        Next
        _outputdt.AcceptChanges()
        
        Dim _filename As String = "EEURLP1226J.xlsx"
        'Util.DataTable2ExcelDownload(_outputdt, "EEURLP1226J.xlsx")
        
        Try
            Dim ms As System.IO.MemoryStream = Advantech.Myadvantech.DataAccess.ExcelUtil.DataTableToMemoryStream(_outputdt)
            Response.AddHeader("Content-Disposition", "attachment; filename=" & _filename)
            
            'Response.AddHeader("content-type", "application/vnd.ms-excel;")
            'Response.AddHeader("Content-Disposition", "inline;filename=" +
            '                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(FileNameFull)))
            'Response.AddHeader("content-length", r.Item("File_Size"))
            'Response.BinaryWrite(r.Item("File_Data"))
            
            Response.BinaryWrite(ms.ToArray())
            ms.Close()
            ms.Dispose()

            'Response.Clear()
            'Response.Buffer = True
            'Response.ContentType = "text/plain"
            'Response.AppendHeader("content-disposition", "attachment;filename=US01ToUS10.txt")
            'Response.Write(_downloadstr.ToString())

            
        Catch ex As Exception
            Util.JSAlert(Me.Page, "Download failed! Error message: " + ex.Message)
        End Try
        Response.Flush()
        Response.End()
        
        
        'Dim aa = 1
        
        'Dim _ifs As New IFSWebService.CTOSDocTunnel
        'Dim _orderno = "6231472"
        ''Dim _ls As List(Of IFSWebService.SalesOrderData) = _ifs.GetSalesOrderData(_orderno)
        'Dim _ls = _ifs.GetSalesOrderData(_orderno)
        ''_ls = _ifs.GetSalesOrderData(_orderno)
        
        'Dim _dt As New DataTable("IFS")
        
        'Dim _col As New DataColumn("DueDate")
        '_dt.Columns.Add(_col)

        '_col = New DataColumn("DueDateSpecified")
        '_dt.Columns.Add(_col)

        '_col = New DataColumn("SalesOrder")
        '_dt.Columns.Add(_col)
        
        '_col = New DataColumn("SalesOrderLine")
        '_dt.Columns.Add(_col)
        
        '_col = New DataColumn("HoldDate")
        '_dt.Columns.Add(_col)
        
        '_col = New DataColumn("HoldDescription")
        '_dt.Columns.Add(_col)

        '_col = New DataColumn("HoldType")
        '_dt.Columns.Add(_col)

        'For Each _item As IFSWebService.SalesOrderData In _ls
        '    Dim _newrow As DataRow = _dt.NewRow
        '    _newrow.Item("DueDate") = _item.DueDate
        '    _newrow.Item("DueDateSpecified") = _item.DueDateSpecified
        '    _newrow.Item("SalesOrder") = _item.SalesOrder
        '    _newrow.Item("SalesOrderLine") = _item.SalesOrderLine
        '    If _item.Hold IsNot Nothing Then
        '        _newrow.Item("HoldDate") = _item.Hold.HoldDate
        '        _newrow.Item("HoldDescription") = _item.Hold.HoldDesc
        '        _newrow.Item("HoldType") = _item.Hold.GetType
        '    End If
        '    _dt.Rows.Add(_newrow)
        'Next
        
        ''Me.gv1.DataSource = _ls
        'Me.gv1.DataSource = _dt
        'Me.gv1.DataBind()
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:GridView ID="gv1" runat="server"></asp:GridView>
        <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
    </div>
    </form>
</body>
</html>
