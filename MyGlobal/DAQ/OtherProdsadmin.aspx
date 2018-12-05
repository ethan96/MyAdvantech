<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub bt_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As New DataTable
        dt.Columns.Add(New DataColumn("sku", GetType(String)))
        dt.Columns.Add(New DataColumn("description", GetType(String)))
        dt.Columns.Add(New DataColumn("img_url", GetType(String)))
        dt.Columns.Add(New DataColumn("details", GetType(String)))
        dt.Columns.Add(New DataColumn("item", GetType(String)))
        Dim dr As DataRow = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1671UP" : dr("description") = "IEEE-488.2 Interface Low Profile Universal PCI Card" : dr("img_url") = "PCI-1671UP_S.jpg" : dr("details") = "http://buy.advantech.com/PCI-and-ISA-Cards/PCI-and-ISA-Cards/model-PCI-1671UP-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1680U" : dr("description") = "2-port CAN-bus Universal PCI Communication Card" : dr("img_url") = "PCI-1680U_S.jpg" : dr("details") = "http://buy.advantech.com/Multiport-Serial-Cards/Multiport-Serial-Cards/model-PCI-1680U-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "PCI-1240U" : dr("description") = "4-axis Stepping and Servo Motor Control Universal PCI Card" : dr("img_url") = "PCI-1240U_S.jpg" : dr("details") = "http://buy.advantech.com/Centralized-Motion-Control/Centralized-Motion-Control/model-PCI-1240U-BE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCI" : dr("sku") = "A-DAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3680" : dr("description") = "2-port CAN-bus PC/104 Modules with Isolation Protection" : dr("img_url") = "PCM-3680_S.jpg" : dr("details") = "http://buy.advantech.com/Industrial-Communication/Industrial-Communication/model-PCM-3680-AE%20.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3642I" : dr("description") = "8-port RS-232 PCI-104 Module" : dr("img_url") = "PCM-3642I_S.jpg" : dr("details") = "http://buy.advantech.com/PCI-104-and-PC-104-Modules/PC-104-Modules/model-PCM-3642I-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "PCM-3240" : dr("description") = "4-axis Stepping and Servo Motor Control PC/104 Card" : dr("img_url") = "PCM-3240_03_S.jpg" : dr("details") = "http://buy.advantech.com/Centralized-Motion-Control/Centralized-Motion-Control/model-PCM-3240-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "PCM" : dr("sku") = "A-DAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4622" : dr("description") = "5-port USB 2.0 Hub" : dr("img_url") = "USB-4622_03_S.jpg" : dr("details") = "http://buy.advantech.com/USB-IO-Modules/USB-IO-Modules/model-USB-4622-BE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4671" : dr("description") = "GPIB USB Module" : dr("img_url") = "USB-4671_02_S.jpg" : dr("details") = "http://buy.advantech.com/USB-IO-Modules/USB-IO-Modules/model-USB-4671-A.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "USB-4604B" : dr("description") = "4-port RS-232 Serial to USB Converter" : dr("img_url") = "USB-4604B_03_S.jpg" : dr("details") = "http://buy.advantech.com/Device-Servers/Serial-Device-Servers/model-USB-4604B-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "USB" : dr("sku") = "A-DAQ Pro" : dr("description") = "ActiveX Control-based Software for Data Acquisition" : dr("img_url") = "ActiveDAQ Pro.jpg" : dr("details") = "http://buy.advantech.com/Data-Acquisition-Software/Data-Acquisition-Software/model-PCLS-ADPSTD-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4520" : dr("description") = "RS-232 to RS-422/485 Converter" : dr("img_url") = "ADAM-4520_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4520-D2E.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4510I" : dr("description") = "Robust RS-422/485 Repeater" : dr("img_url") = "ADAM-4510I_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4510I-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4502" : dr("description") = "Ethernet-enabled Communication Controller" : dr("img_url") = "ADAM-4502_S.jpg" : dr("details") = "http://buy.advantech.com/RS-485-IO-Modules/RS-485-IO-Modules/model-ADAM-4502-AE.htm"
        dt.Rows.Add(dr) : dr = dt.NewRow
        dr("item") = "ADAM" : dr("sku") = "ADAM-4561" : dr("description") = "1-port Isolated USB to RS-232/422/485 Converter" : dr("img_url") = "ADAM-4561_S.jpg" : dr("details") = "http://buy.advantech.com/Device-Servers/Serial-Device-Servers/model-ADAM-4561-BE.htm"
        dt.Rows.Add(dr)
        dt.AcceptChanges()
        For i As Integer = 0 To dt.Rows.Count - 1
            With dt.Rows(i)
                Dim sql As String = String.Format("INSERT INTO DAQ_Other_Prods " & _
          " ([ROW_ID] ,[sku] ,[item] ,[description] " & _
          "  ,[img_url] ,[details])  VALUES('{0}','{1}','{2}','{3}','{4}','{5}') ", Util.NewRowId("DAQ_Other_Prods", "MYLOCAL"), .Item("sku").ToString.Trim.Trim _
          , .Item("item").ToString.Trim.Trim, .Item("description").ToString.Trim.Trim, .Item("img_url").ToString.Trim.Trim, _
          .Item("details").ToString.Trim.Trim
          )
                dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
            End With            
        Next           
    End Sub
    Protected Sub btnImPort_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim xlsConn As New System.Data.OleDb.OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" & _
        "Data Source=" & Server.MapPath("./") & "\Download\DAQ.xls;" & _
        "Extended Properties=""Excel 8.0;""")
        Dim xlsCmd As New System.Data.OleDb.OleDbCommand("SELECT * FROM [ProductsList$]", xlsConn)
        Dim xlsAdp As New System.Data.OleDb.OleDbDataAdapter(xlsCmd)
        Dim ds As New System.Data.DataSet()
        xlsAdp.Fill(ds, "T1")
        Me.gv2.DataSource = ds.Tables("T1")
        gv2.DataBind()
        For i As Integer = 0 To ds.Tables("T1").Rows.Count - 1
            With ds.Tables("T1").Rows(i)
                dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("UPDATE DAQ_products SET DESCRIPTION_F =N'{0}',DESCRIPTION_J=N'{1}' WHERE PRODUCTID ='{2}' AND SKU ='{3}'", _
                                                                 .Item("TraditionalDescription").ToString.Trim, .Item("SimplifiedDescription").ToString.Trim, _
                                                                .Item("PRODUCTID").ToString.Trim, .Item("SKU").ToString.Trim
                                                                 ))
            End With                                       
        Next

    End Sub

    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Me.FileUpload1.SaveAs(Server.MapPath("./") & "\Download\DAQ.xls")
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") IsNot Nothing AndAlso Session("user_id").ToString <> "" Then
            If Util.IsAEUIT() OrElse Session("user_id").ToString.Trim.ToLower = "ming.zhao@advantech.com.cn" Then
            Else
                Response.End()
            End If
        Else
            Response.End()
        End If
       
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
 <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false" AllowSorting="false" 
                DataSourceID="src1" DataKeyNames="ROW_ID"  Width="98%" >
                <Columns>
                    <asp:CommandField ShowEditButton="true" EditText="Edit" ShowCancelButton="true" CancelText="Cancel" ShowDeleteButton="false" />
                    <asp:BoundField HeaderText="ROW_ID" DataField="ROW_ID" SortExpression="ROW_ID" ItemStyle-Width="50"  ReadOnly="true" Visible="false"/>
                    <asp:BoundField HeaderText="sku" DataField="sku" SortExpression="sku" />
                    <asp:BoundField HeaderText="item" DataField="item" SortExpression="item" />
                    <asp:BoundField HeaderText="description" DataField="description" SortExpression="description" />
                    <asp:BoundField HeaderText="Traditional_Description" DataField="Traditional_Description" SortExpression="Traditional_Description" />
                    <asp:BoundField HeaderText="Simplified_Description" DataField="Simplified_Description" SortExpression="Simplified_Description" />
                    <asp:BoundField HeaderText="img_url" DataField="img_url" SortExpression="img_url" />
                    <asp:BoundField HeaderText="Details" DataField="details" SortExpression="details" />
                    <asp:BoundField HeaderText="Traditional_Details" DataField="Traditional_Details" SortExpression="Traditional_Details" />
                    <asp:BoundField HeaderText="Simplified_Details" DataField="Simplified_Details" SortExpression="Simplified_Details" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MYLOCAL %>" 
                SelectCommand="SELECT * FROM DAQ_Other_Prods order by item"
                UpdateCommand="UPDATE DAQ_Other_Prods SET ROW_ID = @ROW_ID, sku = @sku, item = @item, description = @description, Traditional_Description = @Traditional_Description, 
                 Simplified_Description = @Simplified_Description, img_url = @img_url, details = @details,
                 Simplified_Details=@Simplified_Details,Traditional_Details=@Traditional_Details where row_id=@ROW_ID">              
            </asp:SqlDataSource> 
        </ContentTemplate>
  </asp:UpdatePanel>

    <asp:Button runat="server" ID="bt" Text="Button" OnClick="bt_Click"  Enabled="false" Visible="false"/>
    <hr />
    <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="true">
    </asp:GridView>
     
    <asp:FileUpload ID="FileUpload1" runat="server"  Visible="false"/>
    <asp:Button ID="btnUpload" runat="server" Text="UpLoud" OnClick="btnUpload_Click"  Visible="false"/>
    <asp:Button ID="btnImPort" runat="server" Text="ImPort" OnClick="btnImPort_Click" Visible="false" />
</asp:Content>


