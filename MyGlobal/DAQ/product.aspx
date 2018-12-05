<%@ Page Title="DAQ Your Way" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>

<script runat="server">
    Protected Function getFullCategoryPath(ByVal cid As String) As String
        Dim full_category_path As String = "", parentid As String = cid
        Do
            Dim sql As String = "SELECT CATEGORY, CATEGORYID, PARENTID FROM DAQ_func_categories WHERE CATEGORYID = '" + parentid + "'"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            If dt.Rows.Count > 0 Then
                full_category_path = dt.Rows(0)("category").ToString.Trim + "/" + full_category_path
                parentid = dt.Rows(0)("parentid").ToString.Trim
            End If
        Loop While parentid <> "0"
        Return full_category_path
    End Function
    Protected Function getFullCategoryList() As DataTable
        Dim sql As String = "SELECT CATEGORYID FROM DAQ_func_categories ORDER BY CATEGORYID ASC, ORDER_BY ASC"
        Dim dt_full As New DataTable
        dt_full.Columns.Add(New DataColumn("key", GetType(String)))
        dt_full.Columns.Add(New DataColumn("full_cat_path", GetType(String)))
     
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim dr_fuu As DataRow = dt_full.NewRow
                dr_fuu("key") = dt.Rows(i)("CATEGORYID").ToString.Trim
                dr_fuu("full_cat_path") = getFullCategoryPath(dt.Rows(i)("CATEGORYID").ToString.Trim)
                dt_full.Rows.Add(dr_fuu)
            Next
        End If
       
        Return dt_full
    End Function
    Dim pid As String = "" : Public max_proID As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        pid = Request("pid")          
        If Not IsPostBack Then
            categoryid.DataSource = getFullCategoryList() : categoryid.DataBind()
            Dim dt_fuu As DataTable = getFullCategoryList()
            Dim dt2 As DataTable = dt_fuu.Clone()
            Dim dr_fuu_0 As DataRow = dt2.NewRow : dr_fuu_0("key") = 0 : dr_fuu_0("full_cat_path") = "-" : dt2.Rows.Add(dr_fuu_0)
            dt2.Merge(dt_fuu)
            dt2.AcceptChanges()
            add_categoryid_1.DataSource = dt2 : add_categoryid_1.DataBind()
            add_categoryid_2.DataSource = dt2 : add_categoryid_2.DataBind()
            Call set_spec()
        
            If Request("pid") <> "" Then
                pid = Request("pid") : add.Visible = False
                'Dim ADV As New ADVWWWLocal.AdvantechWebServiceLocal
                Dim sql As String = "SELECT a.PRODUCTID, a.SKU, a.PRODUCTNAME, a.DESCRIPTION,a.DESCRIPTION_J,a.DESCRIPTION_F, b.CATEGORYID, b.CATEGORY, a.BUYLINK,  a.BUYLINK_J, a.BUYLINK_F,a.SUPPORTLINK, a.LISTPRICE," & _
                                     " a.ENABLE, a.FLAG  	FROM 	daq_products as a, 	daq_func_categories as b, daq_products_categories as c " & _
                                     " WHERE a.PRODUCTID = '" + pid + "' and c.CATEGORYID = b.CATEGORYID and a.PRODUCTID = c.PRODUCTID order by b.CATEGORYID asc "
                Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
                If dt.Rows.Count > 0 Then
                    ''add for category
                    Dim main_cat_id As Object = Nothing
                    main_cat_id = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT categoryid AS 'first_cat_id' FROM daq_products_categories WHERE productid = '" + pid + "' AND main = '0'")
                    If main_cat_id IsNot Nothing Then
                        categoryid.SelectedValue = main_cat_id.ToString.Trim
                    End If
                    Dim first_cat_id As Object = Nothing
                    first_cat_id = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT categoryid AS 'first_cat_id' FROM daq_products_categories WHERE productid = '" + pid + "' AND main = '1'")
                    If first_cat_id IsNot Nothing Then
                        add_categoryid_1.SelectedValue = first_cat_id.ToString.Trim
                    End If
                    Dim second_cat_id As Object = Nothing
                    second_cat_id = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT categoryid AS 'first_cat_id' FROM daq_products_categories WHERE productid = '" + pid + "' AND main = '2'")
                    If second_cat_id IsNot Nothing Then
                        add_categoryid_2.SelectedValue = second_cat_id.ToString.Trim
                    End If
                    ''
                    'categoryid.SelectedValue = dt.Rows(0)("CATEGORYID").ToString.Trim
                    'If dt.Rows.Count = 2 Then
                    '    add_categoryid_1.SelectedValue = dt.Rows(1)("CATEGORYID").ToString.Trim
                    'End If
                    'If dt.Rows.Count = 3 Then
                    '    add_categoryid_1.SelectedValue = dt.Rows(1)("CATEGORYID").ToString.Trim
                    '    add_categoryid_2.SelectedValue = dt.Rows(2)("CATEGORYID").ToString.Trim
                    'End If
              
                    partno.Value = dt.Rows(0)("SKU").ToString
                    product_name.Value = dt.Rows(0)("PRODUCTNAME").ToString
                    description.Value = dt.Rows(0)("DESCRIPTION").ToString
                    description_j.Value = dt.Rows(0)("DESCRIPTION_J").ToString
                    description_f.Value = dt.Rows(0)("DESCRIPTION_F").ToString
                    buylink.Value = dt.Rows(0)("BUYLINK").ToString
                    buylink_J.Value = dt.Rows(0)("BUYLINK_J").ToString
                    buylink_F.Value = dt.Rows(0)("BUYLINK_F").ToString
                    supportlink.Value = dt.Rows(0)("SUPPORTLINK").ToString
                    listprice.Value = dt.Rows(0)("LISTPRICE").ToString
                    flag.Value = dt.Rows(0)("FLAG").ToString
                    status.SelectedValue = dt.Rows(0)("ENABLE").ToString
                    pro_id.Text = dt.Rows(0)("PRODUCTID").ToString
                    imgpic.ImageUrl = "http://my-global.advantech.eu/download/downloadlit.aspx?pn=" + dt.Rows(0).Item("SKU").ToString
                  
                End If
                
            Else
                update.Visible = False : delete.Visible = False
                Dim obj As Object = Nothing
                obj = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT MAX(productid)+ 1  as max_proid FROM DAQ_products")
                If obj IsNot Nothing Then
                    max_proID = obj.ToString()
                Else
                    max_proID = "10000"
                End If
                Session("maxproid") = max_proID
            End If
        
        End If
        ' Response.Write("wei"+max_proID)
    End Sub

    Protected Sub add_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim pre_sql = "SELECT sku FROM DAQ_products WHERE sku = '" + partno.Value.ToString.Trim + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", pre_sql)
        If dt.Rows.Count > 0 Then
            Util.JSAlert(Me.Page, "Part number is existed!")
            Exit Sub
        End If
        If Session("maxproid") Is Nothing OrElse Session("maxproid").ToString() = "" Then
            Util.JSAlert(Me.Page, "Pid cannot  empty!")
            Exit Sub
        Else
            max_proID = Session("maxproid").ToString
            Dim sql As String = String.Format("insert into daq_products (productid,sku,productname,description,enable,buylink,supportlink,listprice,flag,description_j,description_f,BUYLINK_J,BUYLINK_F) values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',N'{9}',N'{10}','{11}','{12}')", max_proID, partno.Value.Replace("'", "''"), product_name.Value.Replace("'", "''"), description.Value.Replace("'", "''"), status.SelectedValue, buylink.Value.Replace("'", "''"), supportlink.Value.Replace("'", "''"), listprice.Value.Replace("'", "''"), flag.Value.Replace("'", "''"), description_j.Value.Replace("'", "''"), description_f.Value.Replace("'", "''"), buylink_J.Value.Replace("'", "''"), buylink_F.Value.Replace("'", "''"))
            Dim sql2 As String = "insert into daq_products_categories (productid,categoryid,main) values ('" + max_proID + "','" + categoryid.SelectedValue + "','0')"
            'Response.Write("sql::::" + sql + "<hr>")
          '  Response.Write("sq2::::" + sql2 + "<hr>")
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
            If add_categoryid_1.SelectedValue <> "0" Then
                Dim sql3 As String = "insert into daq_products_categories (productid,categoryid,main) values ('" + max_proID + "','" + add_categoryid_1.SelectedValue + "','1')"
                ' Response.Write("add_categoryid_1::::" + sql3 + "<hr>")
                dbUtil.dbExecuteNoQuery("MYLOCAL", sql3)
            End If
            If add_categoryid_2.SelectedValue <> "0" Then
                Dim sql4 As String = "insert into daq_products_categories (productid,categoryid,main) values ('" + max_proID + "','" + add_categoryid_2.SelectedValue + "','2')"
                ' Response.Write("add_categoryid_2::::" + sql4 + "<hr>")
                 dbUtil.dbExecuteNoQuery("MYLOCAL", sql4)
            End If
           ' Util.JSAlert(Me.Page, "Add success!")
            'Response.Redirect("product.aspx?pid=" + max_proID)
            Util.JSAlertRedirect(Me.Page, "Add success!", "product.aspx?pid=" + max_proID + "")
        End If
       
    End Sub

    Protected Sub update_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql As String = "UPDATE daq_products_categories SET  CATEGORYID = '" + categoryid.SelectedValue + "' WHERE PRODUCTID = '" + pid + "' AND MAIN = '0'"
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
        If add_categoryid_1.SelectedValue <> "0" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT * FROM daq_products_categories  WHERE PRODUCTID = '" + pid + "' AND  MAIN = '1'")
            If dt.Rows.Count > 0 Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE daq_products_categories  SET  CATEGORYID = '" + add_categoryid_1.SelectedValue + "' WHERE PRODUCTID = '" + pid + "' AND MAIN = '1'")
            Else
                dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_products_categories (PRODUCTID,CATEGORYID,MAIN)  values ('" + pid + "','" + add_categoryid_1.SelectedValue + "','1')")
            End If
        End If
        If add_categoryid_1.SelectedValue <> "0" AndAlso add_categoryid_2.SelectedValue <> "0" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT * FROM daq_products_categories  WHERE PRODUCTID = '" + pid + "' AND  MAIN = '2'")
            If dt.Rows.Count > 0 Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE daq_products_categories  SET  CATEGORYID = '" + add_categoryid_2.SelectedValue + "' WHERE PRODUCTID = '" + pid + "' AND MAIN = '2'")
            Else
                dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_products_categories (PRODUCTID,CATEGORYID,MAIN)  values ('" + pid + "','" + add_categoryid_2.SelectedValue + "','2')")
            End If
        End If
        If add_categoryid_1.SelectedValue = "0" Then
            dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM daq_products_categories WHERE productid = '" + pid + "' AND main = '1'")
        End If
        If add_categoryid_2.SelectedValue = "0" Then
            dbUtil.dbExecuteNoQuery("MYLOCAL", "DELETE FROM daq_products_categories WHERE productid = '" + pid + "' AND main = '2'")
        End If
        
        Dim sqlpro As String = "UPDATE  daq_products  SET  sku = '" + partno.Value.Replace("'", "''") + "', productname = '" + product_name.Value.Replace("'", "''") + "', description = '" + description.Value.Replace("'", "''") + "', enable = '" + status.SelectedValue + "', buylink = '" + buylink.Value.Replace("'", "''") + "', " & _
                                 " supportlink = '" + supportlink.Value.Replace("'", "''") + "', listprice = '" + listprice.Value.Replace("'", "''") + "', flag = '" + flag.Value + "', description_j = N'" + description_j.Value.Replace("'", "''") + "', description_f = N'" + description_f.Value.Replace("'", "''") + "',BUYLINK_J='"+buylink_J.Value.Replace("'","''")+"',BUYLINK_F='"+buylink_F.Value.Replace("'","''")+"'  WHERE  productid = '" + pid + "' "
        
        dbUtil.dbExecuteNoQuery("MYLOCAL", sqlpro)
        'Response.Write(sqlpro)
        ' Util.JSAlert(Me.Page, "UPDATE success!")
        Util.JSAlertRedirect(Me.Page, "UPDATE success!", "product.aspx?pid=" + pid + "")
    End Sub

    Protected Sub delete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql1 As String = "DELETE FROM daq_products WHERE productid = " + pid + ""
        Dim sql2 As String = "DELETE FROM daq_products_categories WHERE  productid = " + pid + ""
        ' Response.Write("del_1::::" + sql1 + "<hr>")
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql1)
        ' Response.Write("del_2::::" + sql2 + "<hr>")
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
       ' Util.JSAlert(Me.Page, "DELETE success!")
        Util.JSAlertRedirect(Me.Page, "DELETE success!", "index.aspx")
    End Sub
    Protected Sub set_spec()
        Dim proid As String = ""
        If pid = "" Then
            proid = "0"
        Else
            proid = pid
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT * FROM DAQ_spec_class WHERE  ENABLE =  'y' ORDER BY  ORDER_BY ASC")
       ' product_spec.Items.Clear()
        product_spec.DataSource = dt
        product_spec.DataBind()
       ' Response.Write("wei"+proid)
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT  spec_classes FROM  daq_product_spec WHERE productid = '" + proid + "'")       
        ' OrderUtilities.showDT(dt) : OrderUtilities.showDT(dt2)
        Dim p() As String = {}
        If dt2.Rows.Count > 0 Then
            p = Split(dt2.Rows(0)("spec_classes").ToString.Trim, "|")
            For i As Integer = 0 To product_spec.Items.Count - 1
                For J As Integer = 0 To p.Length - 1
                    If product_spec.Items(i).Value = p(J) Then
                        product_spec.Items(i).Selected = True
                        
                    End If
                Next
            Next
            Call get_spec_html()
        Else
            spec_table.InnerHtml =""
        End If
    End Sub
    Protected Sub get_spec_html()
        Dim product_spec_str As String = "<table width=""100%"" cellpadding=""2"" cellspacing=""2"" >"
        For i As Integer = 0 To product_spec.Items.Count - 1
            If product_spec.Items(i).Selected = True Then
                product_spec_str = product_spec_str + getprospecstr(product_spec.Items(i).Value.ToString.Trim, product_spec.Items(i).Text.ToString)
            End If
           
        Next
        product_spec_str += "</table>"
        spec_table.InnerHtml = product_spec_str
       ' Response.Write(product_spec_str)
    End Sub
     
    Protected Function getprospecstr(ByVal spec_classid As String, ByVal spec_name As String) As String
        Dim spechtml As String = "<tr><td width=""20%"" style=""background:#EAEFF2;"">" + spec_name + "</td><td>"
        spechtml += "<table width=""100%"" cellpadding=""2"" cellspacing=""2"" border=""0"">"
        Dim sql As String = "SELECT * FROM daq_spec_options WHERE CLASSID =  '" + spec_classid + "' AND ENABLE =  'y' ORDER BY  ORDER_BY ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                spechtml += " <tr style=""background:#E1E1E1;""><td width=""50%"">" + dt.Rows(i)("option_name").ToString + ""
                If dt.Rows(i)("option_type").ToString = "m" Then
                    spechtml += "<br /><b>*Multiple options, select at least one</b>"
                End If
                spechtml += "</td>"
                
                spechtml += "<td>"
                
                spechtml += getprospec_values_str(dt.Rows(i)("optionid").ToString, dt.Rows(i)("option_type").ToString)
                
                spechtml += "</td></tr>"
            Next
        End If
        spechtml += "</table>"
        spechtml += "</td></tr>"
    
        Return spechtml
    End Function
    Protected Function getprospec_values_str(ByVal optionid As String, ByVal optiontype As String) As String
        Dim prospec_values_str As String = ""
        
        Select Case optiontype
            Case "m"
                prospec_values_str += "<select name=""opt_m[]"" multiple="""" size=""10"" id=""opt_m"" >"
            Case Else
                prospec_values_str += "<select  name=""opt_s[]""  id=""opt_s"" >"
        End Select
        Dim sql As String = "SELECT *  FROM DAQ_spec_options_values WHERE OPTIONID =  '" + optionid + "' ORDER BY ORDER_BY ASC"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                If getpro_option(optiontype).Select("option_values='" + dt.Rows(i)("option_valueid").ToString.Trim + "'").Length > 0 Then
                    prospec_values_str += "<option  style=""color:#333333;background-color:#FF6666;"" value='" + dt.Rows(i)("optionid").ToString.Trim + "-" + dt.Rows(i)("option_valueid").ToString.Trim + "' selected="""" >"
                Else
                    prospec_values_str += "<option  style=""color:#333333;"" value='" + dt.Rows(i)("optionid").ToString.Trim + "-" + dt.Rows(i)("option_valueid").ToString.Trim + "'>"
                End If
              
                prospec_values_str += dt.Rows(i)("option_value").ToString.Trim + "</option>"
            Next
        End If
        prospec_values_str += "</select>"
        Return prospec_values_str
    End Function
    Protected Function getpro_option(ByVal option_type As String) As DataTable
        Dim sql As String = "SELECT a.OPTIONID, b.OPTION_TYPE, a.OPTION_VALUES FROM daq_product_spec_values as a " & _
                             " Inner Join daq_spec_options as b ON a.OPTIONID = b.OPTIONID " & _
                             " WHERE a.PRODUCTID =  '" + pid + "' AND b.OPTION_TYPE =  '" + option_type + "' ORDER BY b.OPTION_TYPE DESC, a.OPTIONID ASC "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
        
            If option_type = "m" Then
                Dim dtclone As DataTable = dt.Clone
                For i As Integer = 0 To dt.Rows.Count - 1                                  
                    Dim p() As String = Split(dt.Rows(i)("option_values").ToString.Trim, "|")
                    For j As Integer = 0 To p.Length - 1
                        Dim dr As DataRow = dtclone.NewRow
                        dr("optionid") = dt.Rows(i)("optionid").ToString.Trim
                        dr("option_type") = dt.Rows(i)("option_type").ToString.Trim
                        dr("option_values") = p(j).ToString.Trim
                        dtclone.Rows.Add(dr)
                    Next    
                Next
                dt.Rows.Clear()
                dt = dtclone.Copy
            End If
            
        End If
        'OrderUtilities.showDT(dt)
        Return dt
    End Function

    Protected Sub edit_spec_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Call get_spec_html()
    End Sub

    Protected Sub Clean_spec_values_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql1 As String = "DELETE FROM daq_product_spec_values WHERE productid = '" + pid + "'"
        Dim sql2 As String = "DELETE FROM daq_product_spec WHERE productid = '" + pid + "'"
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql1)
        dbUtil.dbExecuteNoQuery("MYLOCAL", sql2)
        Util.JSAlert(Me.Page, "Delete success!")
        'Util.JSAlertRedirect(Me.Page, "Delete success!", "product.aspx?pid=" + pid)
         Call set_spec()
    End Sub
    Protected Sub edit_spec_values_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim opt_s As String = Request("opt_s[]")
       
        'Response.Write(opt_s)
        'Response.Write("<hr>")
        'Response.Write(opt_m)
        'Response.Write("<hr>")
        'Response.End()
        Dim p_opt_s() As String = Split(opt_s, ",")
        
        
        For i As Integer = 0 To p_opt_s.Length - 1
            Dim p() As String = Split(p_opt_s(i), "-")
            Dim checksql = "SELECT * FROM  daq_product_spec_values  WHERE productid = '" + pid + "' AND optionid = '" + p(0) + "'"
            'Response.Write(checksql)
            'Response.End()
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", checksql)
            If dt.Rows.Count > 0 Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE daq_product_spec_values SET  option_values = '" + p(1) + "' WHERE  productid = '" + pid + "' AND  optionid = '" + p(0) + "'")
            Else
                dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_product_spec_values (productid,optionid,option_values) values ('" + pid + "','" + p(0) + "','" + p(1) + "') ")
            End If
        Next
        'Response.Write(p_opt_m.Length)
        'Response.Write("zhiwei" + p_opt_m(0))
        'Response.End()
        Dim opt_m As String = Request("opt_m[]")
        If opt_m <> "" OrElse opt_m IsNot Nothing Then
            
            Dim p_opt_m() As String = Split(opt_m, ",")
            Dim dt_arr As New DataTable
            dt_arr.Columns.Add(New DataColumn("optionid", GetType(String)))
            dt_arr.Columns.Add(New DataColumn("option_values", GetType(String)))
            For i As Integer = 0 To p_opt_m.Length - 1
                Dim p() As String = Split(p_opt_m(i), "-")
                Dim dr As DataRow = dt_arr.NewRow
                dr("optionid") = p(0)
                dr("option_values") = p(1)
                dt_arr.Rows.Add(dr)
            Next
  
            Dim dv As DataView = dt_arr.DefaultView
            Dim dt2 As DataTable = dv.ToTable(True, "optionid")
            dt2.Columns.Add(New DataColumn("option_values", GetType(String)))
            For i As Integer = 0 To dt2.Rows.Count - 1
                Dim dr() As DataRow = dt_arr.Select("optionid='" + dt2.Rows(i)("optionid").ToString.Trim + "'")
                For j As Integer = 0 To dr.Length - 1
                    If j = dr.Length - 1 Then
                        dt2.Rows(i)("option_values") += dr(j).Item("option_values")
                    Else
                        dt2.Rows(i)("option_values") += dr(j).Item("option_values") + "|"
                    End If
            
                Next
            
            Next
            dt2.AcceptChanges()
        
            For k As Integer = 0 To dt2.Rows.Count - 1
                Dim checksql = "SELECT * FROM  daq_product_spec_values  WHERE productid = '" + pid + "' AND optionid = '" + dt2.Rows(k)("optionid").ToString.Trim + "'"
                Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", checksql)
                If dt.Rows.Count > 0 Then
                    dbUtil.dbExecuteNoQuery("MYLOCAL", "UPDATE daq_product_spec_values SET  option_values = '" + dt2.Rows(k)("option_values").ToString.Trim + "' WHERE  productid = '" + pid + "' AND  optionid = '" + dt2.Rows(k)("optionid").ToString.Trim + "'")
                Else
                    dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_product_spec_values (productid,optionid,option_values) values ('" + pid + "','" + dt2.Rows(k)("optionid").ToString.Trim + "','" + dt2.Rows(k)("option_values").ToString.Trim + "') ")
                End If
            Next
        End If
            ' OrderUtilities.showDT(dt2)
            'Response.Write("<hr>")
            If pid <> "" Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", "delete from daq_product_spec WHERE productid  = " + pid + "")
            End If
            Dim pro_spec_ids As String = ""
            For i As Integer = 0 To product_spec.Items.Count - 1
                If product_spec.Items(i).Selected = True Then
                    pro_spec_ids = pro_spec_ids + product_spec.Items(i).Value.ToString.Trim + "|"
                End If
           
            Next
            pro_spec_ids = pro_spec_ids.Substring(0, pro_spec_ids.Length - 1)
            If pid <> "" Then
                dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_product_spec (productid ,SPEC_CLASSES) values (" + pid + ",'" + pro_spec_ids + "')")
            Else
                Util.JSAlert(Me.Page, "Error!")
                Exit Sub
                ' dbUtil.dbExecuteNoQuery("MYLOCAL", "INSERT INTO daq_product_spec (productid ,SPEC_CLASSES) values (" + max_proID + ",'" + pro_spec_ids + "')")
            End If
            Util.JSAlert(Me.Page, "Update success!")
            ' Util.JSAlertRedirect(Me.Page, "Update success!", "product.aspx?pid=" + pid)
            Call set_spec()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="css.css" rel="stylesheet" type="text/css" />
<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
  <tr>
    <td width="200" valign="top"><uc1:Menu ID="Menu1" runat="server" />
        </td>
    <td>
    
<%--  ----------------  --%>
    
    <div class="content_box">
    <table width="100%" border="0" cellpadding="2" cellspacing="2">
    <tr>
<th colspan="2">Product information</td>
</tr>
<tr><td colspan ="2"   align="LEFT" valign="top" >
<table  width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td width="20%" bgcolor="#EEF6FF">PID</td><td> <asp:Literal ID="pro_id" runat="server"></asp:Literal></td><td rowspan="3">  <asp:Image ID="imgpic" Width="120" ImageUrl="image/no_image.jpg" runat="server" /></td></tr>
<tr><td colspan="2" height="1" bgcolor="#ffffff"></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Part Number</td><td><input name="partno" id="partno" runat="server" type="text" size="50" value="" style="color:red; font-weight:bold;"/></td></tr>
</table>
  
    </td>
 </tr>

<tr><td width="20%" bgcolor="#EEF6FF">Product Name</td><td><input name="product_name" ID="product_name" runat="server"  type="text" size="100" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Description</td><td><input name="description" id="description" runat="server"  type="text" size="100" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Simplified Description</td><td><input name="description_j" id="description_j" runat="server"  type="text" size="100" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Traditional Description</td><td><input name="description_f" id="description_f" runat="server"  type="text" size="100" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Main Category</td><td>
 <asp:DropDownList  ID="categoryid" runat="server" DataTextField="full_cat_path" DataValueField="key">  </asp:DropDownList>

</td></tr>
    
 <tr><td width="20%" bgcolor="#EEF6FF">Additional 1st. Category</td><td>
  <asp:DropDownList  ID="add_categoryid_1" runat="server" DataTextField="full_cat_path" DataValueField="key">  </asp:DropDownList>
 </td></tr>

 <tr><td width="20%" bgcolor="#EEF6FF">Additional 2nd. Category</td><td>
  <asp:DropDownList  ID="add_categoryid_2" runat="server" DataTextField="full_cat_path" DataValueField="key">  </asp:DropDownList>
 </td></tr>

 <tr><td width="20%" bgcolor="#EEF6FF">Buy Link</td><td><input runat="server" id="buylink"  name="buylink" type="text" size="100" value=""/></td></tr>
 <tr><td width="20%" bgcolor="#EEF6FF">Simplified Buy Link</td><td><input runat="server" id="buylink_J"  name="buylink_J" type="text" size="100" value=""/></td></tr>
 <tr><td width="20%" bgcolor="#EEF6FF">Traditional Buy Link</td><td><input runat="server" id="buylink_F"  name="buylink_F" type="text" size="100" value=""/></td></tr>


<tr><td width="20%" bgcolor="#EEF6FF">Support Link</td><td><input runat="server" ID="supportlink" name="supportlink" type="text" size="100" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">List Price</td><td><input runat="server" ID="listprice" name="listprice" type="text" size="20" value=""/></td></tr>
<tr><td width="20%" bgcolor="#EEF6FF">Enable</td><td>
<asp:DropDownList  ID="status" runat="server">
          <asp:ListItem Value="y" Text="Enable" ></asp:ListItem>
           <asp:ListItem Value="n" Text="Disable"></asp:ListItem>
          </asp:DropDownList>
    </td></tr>
    
 <tr><td width="20%" bgcolor="#EEF6FF">Flag</td><td><input runat="server"  name="flag" id="flag" type="text" size="2" value=""/></td></tr>
<tr><td>&nbsp;</td><td colspan="2">&nbsp;</td></tr>
<tr><td width="20%" colspan="2">
  <asp:Button runat="server" Text="Add" ID="add" OnClientClick="return check_sku();" onclick="add_Click" />
  <asp:Button runat="server" Text="Update" ID="update" OnClientClick="return check_sku();" onclick="update_Click" />&nbsp;&nbsp;&nbsp;&nbsp;
  <asp:Button runat="server" Text="Delete" ID="delete" OnClientClick="return del_sku();" onclick="delete_Click" />
</td><td></td></tr>
  
</table>   
    </div>
<%-- -------second------------   --%>

<div class="content_box">
<table width="100%" cellpadding="2" cellspacing="2">
<tr><th colspan="2">Product spec</th></tr>
<tr><th width="22%">Required spec class</th><th>Options</th></tr>
<tr><td>
<table width="100%">
<tr>
<td>
   
    <asp:ListBox runat="server" ID="product_spec" Height="250px" DataTextField="CLASS" DataValueField="CLASSID"  SelectionMode="Multiple"></asp:ListBox>

</td>
<td>
<asp:Button runat="server" ID="edit_spec"   Text=" > " onclick="edit_spec_Click"/>
</td>
</tr>

</table>
</td>
<td valign="top">
<!--11111-->

<div class="content_box">
<div runat="server" id="spec_table"></div>
<table width="100%" cellpadding="2" cellspacing="2" >

<tr><td colspan="3">&nbsp;</td></tr>
<tr><td colspan="3"  style="text-align:center;">

 <asp:Button runat="server" Text="Clean up spec" ID="Clean_spec_values"     OnClientClick ="return check_fields('clean_up');"   onclick="Clean_spec_values_Click" />
  <asp:Button runat="server" Text="Update" ID="edit_spec_values"  OnClientClick="return check_fields('update');" onclick="edit_spec_values_Click" />
</td></tr>
</table>

</div>
<!--111111-->
</td>
</tr>
</table>
</div>

<%-- ---------end----------   --%>
    </td>
    </tr>
    </table>

    <script type="text/javascript">
        function check_fields(op) {
            var i = 0;

            switch (op) {
                case 'update':


                    for (i = 0; i < document.getElementsByName("opt_m[]").length; i++) {
                        // alert(document.getElementsByName("opt_m[]")[i].value);

                        if (document.getElementsByName("opt_m[]")[i].value == '') {
                            alert("Multiple options cannot be empty!");
                            return false;
                        }
                    }

                    break;

                case 'clean_up':
                    if (confirm('Are you sure to clean up all spec?'))
                    { return true; }
                    else 
                    {return false;}
                   
                       
                    break;
            }

        }
</script>
<script type="text/javascript">
function check_sku(){

    if (document.getElementById('<%=partno.ClientID %>').value == "") { alert("Part Number cannot be empty!"); return false; }
    if (document.getElementById('<%=product_name.ClientID %>').value == "") { alert("Product Name cannot be empty!"); return false; }
    if (document.getElementById('<%=listprice.ClientID %>').value == "") { alert("List Price cannot be empty!"); return false; }
  if (document.getElementById('<%=listprice.ClientID %>').value.length > 0)
   {
       if (fucCheckNUM(document.getElementById('<%=listprice.ClientID %>').value) == "0") { alert("List Price Must be  number!"); return false; }
       
   }
  if (document.getElementById('<%=flag.ClientID %>').value.length > 1)
  { alert("The ength of  Flag cannot be more than 1"); return false; }



}
function del_sku(sku, pid) {
    if (confirm('Are you sure to delete this product ?'))
    { return true; }
    else {return false;}
}
function fucCheckNUM(NUM) {
    var i, j, strTemp;
    strTemp = "0123456789.";
    if (NUM.length == 0)
        return 0
    for (i = 0; i < NUM.length; i++) {
        j = strTemp.indexOf(NUM.charAt(i));
        if (j == -1) {  //说明有字符不是数字
            return 0;
        }
    }
    //说明是数字
    return 1;
} 
</script>
</asp:Content>

