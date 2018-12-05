Imports System.IO

Partial Class DM_CustomerSegmentation
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        Dim uid = HttpContext.Current.Session("user_id").ToString().ToLower()

        'If (uid = "claire.hsu@advantech.com.tw" OrElse Util.IsAEUIT()) Then

        'Else
        '    Response.Redirect("/home.aspx")
        'End If

        If (Not Page.IsPostBack) Then
            TextBox4.Text = ""
            TextBox5.Text = ""

            NKA.Text = "20,000"
            KA.Text = "1,000,000"
            GKA.Text = "5,000,000"

            OneYearFrom.SelectedDate = DateTime.Now.AddYears(-1)
            OneYearFrom.VisibleDate = DateTime.Now.AddYears(-1)
            TextBox4.Text = OneYearFrom.SelectedDate.ToShortDateString()
            OneYearTo.SelectedDate = DateTime.Now
            TextBox5.Text = OneYearTo.SelectedDate.ToShortDateString()

        End If

    End Sub

    Protected Sub StartSelection_Change(sender As Object, e As EventArgs)
        TextBox4.Text = OneYearFrom.SelectedDate.ToShortDateString()
        OneYearFrom.Visible = False
    End Sub

    Protected Sub EndSelection_Change(sender As Object, e As EventArgs)
        TextBox5.Text = OneYearTo.SelectedDate.ToShortDateString()
        OneYearTo.Visible = False
    End Sub


    Protected Sub ImageButton1_Click(sender As Object, e As ImageClickEventArgs) Handles ImageButton1.Click
        OneYearFrom.Visible = Not OneYearFrom.Visible
        OneYearTo.Visible = False
        'OneYearFrom.SelectedDate = DateTime.Now.AddYears(-1)
    End Sub
    Protected Sub ImageButton2_Click(sender As Object, e As ImageClickEventArgs) Handles ImageButton2.Click
        OneYearTo.Visible = Not OneYearTo.Visible
        OneYearFrom.Visible = False

    End Sub

    Protected Sub Excel_Click(sender As Object, e As EventArgs) Handles Excel.Click
        If (Not CheckDate()) Then
            Return
        End If
        If (Not CheckField()) Then
            Return
        End If
        Dim sda = SetSqlDataSource("")
        Dim args As New DataSourceSelectArguments
        Dim dv As Data.DataView = sda.Select(args)
        Dim dt = dv.ToTable()

        Dim sheetCount = (dt.Rows.Count \ 65535) + 1

        Util.SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        For i = 0 To sheetCount - 1
            wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
            wb.Worksheets(i).Cells(0, 0).PutValue("BUYING GROUP")
            wb.Worksheets(i).Cells(0, 1).PutValue("CUST SEG")
            wb.Worksheets(i).Cells(0, 2).PutValue("AMOUNT")
            wb.Worksheets(i).Cells(0, 3).PutValue("COMPANY")
        Next

        For i = 0 To dt.Rows.Count - 1

            Dim dr As DataRow = dt.Rows(i)
            Dim s = i \ 65535
            Dim r = i Mod 65535
            wb.Worksheets(s).Cells(r + 1, 0).PutValue(dr("BUYING_GROUP").ToString())
            wb.Worksheets(s).Cells(r + 1, 1).PutValue(dr("CUST_SEG").ToString())
            wb.Worksheets(s).Cells(r + 1, 2).PutValue(dr("Amount").ToString())
            wb.Worksheets(s).Cells(r + 1, 3).PutValue(dr("COMPANY").ToString())
        Next

        'Dim workbook As New XSSFWorkbook
        'Dim mySheet1 As XSSFSheet = workbook.CreateSheet("Sheet1")
        'Dim row As XSSFRow = mySheet1.CreateRow(0)
        'Dim MS As MemoryStream = New MemoryStream()


        'row.CreateCell(0).SetCellValue("BUYING GROUP")
        'row.CreateCell(1).SetCellValue("CUST SEG")
        'row.CreateCell(2).SetCellValue("AMOUNT")
        'row.CreateCell(3).SetCellValue("COMPANY")

        'For i = 0 To dt.Rows.Count - 1
        '    Dim dr As DataRow = dt.Rows(i)
        '    row = mySheet1.CreateRow(i + 1)
        '    row.CreateCell(0).SetCellValue(dr("BUYING_GROUP").ToString())
        '    row.CreateCell(1).SetCellValue(dr("CUST_SEG").ToString())
        '    row.CreateCell(2).SetCellValue(dr("Amount").ToString())
        '    row.CreateCell(3).SetCellValue(dr("COMPANY").ToString())
        'Next

        'Dim Stream As MemoryStream = New MemoryStream()
        'workbook.Write(Stream)

        Response.AddHeader("Content-Disposition", "attachment; filename=CustomerSegmentation.xls")
        Response.BinaryWrite(wb.SaveToStream().ToArray)
        'workbook = Nothing
        'Stream.Close()
        'Stream.Dispose()      
    End Sub

    Protected Sub Query_Click(sender As Object, e As EventArgs) Handles Query.Click
        If (Not CheckDate()) Then
            Return
        End If
        If (Not CheckField()) Then
            Return
        End If
        Dim sda = SetSqlDataSource("Top 1000")
        Dim args As New DataSourceSelectArguments
        Dim dv As Data.DataView = sda.Select(args)
        GridView1.DataSource = dv
        GridView1.DataBind()
    End Sub

    Protected Function SetSqlDataSource(ByVal rowCount As String) As SqlDataSource
        Dim parm = "" &
"DECLARE @NKA int = {0}  /*NKA 門檻*/" & vbCrLf &
"Declare @KA int = {1} /*KA/LKA 門檻*/" & vbCrLf &
"Declare @GKA int = {2};/*GKA 門檻*/" & vbCrLf &
"/* 時間點 */" &
"Declare @OneYearFrom varchar(20) = '{3}'" & vbCrLf &
"Declare @OneYearTo varchar(20) = '{4} 23:59:59'" & vbCrLf &
"Declare @HalfYearFrom varchar(20) = '{5}'" & vbCrLf &
"Declare @HalfYearTo varchar(20) = '{6} 23:59:59';" & vbCrLf &
""

        Dim oneFrom = OneYearFrom.SelectedDate.ToString("yyyy-MM-dd")
        Dim oneTo = OneYearTo.SelectedDate.ToString("yyyy-MM-dd")
        Dim halfFrom = OneYearFrom.SelectedDate.AddMonths(6).ToString("yyyy-MM-dd")
        Dim halfTo = OneYearTo.SelectedDate.ToString("yyyy-MM-dd")
        Dim nkaValue = NKA.Text.Replace(",", "")
        Dim kaValue = KA.Text.Replace(",", "")
        Dim gkaValue = GKA.Text.Replace(",", "")
        parm = String.Format(parm, nkaValue, kaValue, gkaValue, oneFrom, oneTo, halfFrom, halfTo)

        Dim sql = parm + DataSql

        Dim sda As SqlDataSource = New SqlDataSource
        sda.SelectCommand = String.Format(sql, rowCount)
        AddHandler sda.Selecting, AddressOf SqlsourceSelecting
        sda.ConnectionString = ConfigurationManager.ConnectionStrings("MY").ConnectionString
        sda.DataSourceMode = SqlDataSourceMode.DataSet

        Return sda

    End Function

    Protected Sub SqlsourceSelecting(ByVal sender As Object, ByVal e As SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 100000
    End Sub

    Protected Function CheckDate() As Boolean
        Dim result = OneYearFrom.SelectedDate.AddYears(1) <= OneYearTo.SelectedDate

        If (Not result) Then
            Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", "<script>window.onload = function(){alert('The date range must be more than 1 year')}</script>")
            'Response.Write()
        End If

        Return result

    End Function

    Protected Function CheckField() As Boolean
        Dim integerResult = False
        Dim emptyResult = Not String.IsNullOrEmpty(GKA.Text) And Not String.IsNullOrEmpty(KA.Text) And Not String.IsNullOrEmpty(NKA.Text)
        If (Not emptyResult) Then
            Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", "<script>window.onload = function(){alert('The threshold must have value')}</script>")
        End If

        Dim x = 0
        If (Not Integer.TryParse(GKA.Text.Replace(",", ""), x)) Then

        ElseIf (Not Integer.TryParse(KA.Text.Replace(",", ""), x)) Then

        ElseIf (Not Integer.TryParse(NKA.Text.Replace(",", ""), x)) Then

        Else
            integerResult = True
        End If

        If (Not integerResult) Then
            Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", "<script>window.onload = function(){alert('The threshold value must be integer')}</script>")
        End If

        Return emptyResult And integerResult
    End Function

    Protected Sub GridView1_PageIndexChanging(sender As Object, e As GridViewPageEventArgs) Handles GridView1.PageIndexChanging
        GridView1.PageIndex = e.NewPageIndex
        Query_Click(Nothing, Nothing)

    End Sub

    Protected Sub GridView1_DataBinding(sender As Object, e As EventArgs)

    End Sub
End Class

Partial Class DM_CustomerSegmentation

    Protected Property Sda As SqlDataSource

    Protected Shared ReadOnly Property DataSql() As String
        Get
            Return "" & vbCrLf &
"With raw_data As (" & vbCrLf &
        "	Select Case When b.VALUE='' or b.VALUE IS NULL then a.COMPANY_ID else b.VALUE end as BUYING_GROUP," & vbCrLf &
        "   a.COMPANY_ID, a.COMPANY_NAME, a.ORG_ID, c.order_no, c.efftive_date, c.Us_amt, c.item_no" & vbCrLf &
        "from SAP_DIMCOMPANY a (nolock)  " & vbCrLf &
    "left join (               " & vbCrLf &
        "select * from (" & vbCrLf &
            "select *, ROW_NUMBER() over (PARTITION BY z.COMPANY_ID ORDER BY z.VALUE desc) as row " & vbCrLf &
            "from SAP_DIMCOMPANY_EXT z" & vbCrLf &
        ") as z1 " & vbCrLf &
        "where z1.row=1" & vbCrLf &
    ") as b on a.COMPANY_ID=b.COMPANY_ID and b.TYPE='Buying Group'" & vbCrLf &
    "left join (" & vbCrLf &
        "select * from EAI_SALE_FACT z (nolock) " & vbCrLf &
        "where z.efftive_date between @OneYearFrom and @OneYearTo     " & vbCrLf &
        "and z.tran_type = 'Shipment' and z.fact_1234 = '1'         " & vbCrLf &
        "And z.bomseq >= 0 And z.itp_find <> 2  And z.itp_find <> 9   " & vbCrLf &
        "and ( z.qty <> 0 or z.us_amt <> 0 or z.cancel_flag = ' ' )   " & vbCrLf &
        "and z.BreakDown <= 0 --撈出不拆BOM的                   " & vbCrLf &
    ") as c on a.COMPANY_ID=c.Customer_ID And a.ORG_ID=c.org    " & vbCrLf &
    "where a.COMPANY_ID<>'' and a.COMPANY_ID is not null     " & vbCrLf &
")," & vbCrLf &
"company_data As (   " & vbCrLf &
"	Select distinct a.COMPANY_ID, a.COMPANY_NAME, a.ORG_ID, b.VALUE As BUYING_GROUP   " & vbCrLf &
"    From SAP_DIMCOMPANY a (nolock)                                                       " & vbCrLf &
"	inner Join SAP_DIMCOMPANY_EXT b (nolock) on a.COMPANY_ID=b.COMPANY_ID And b.TYPE='Buying Group'  " & vbCrLf &
"	where b.VALUE <>''                                                       " & vbCrLf &
")" & vbCrLf &
"select distinct {0} r.BUYING_GROUP, r.CUST_SEG, r.Amount, " & vbCrLf &
"Replace(" & vbCrLf &
"        Replace(" & vbCrLf &
"            Replace(" & vbCrLf &
"                Replace(" & vbCrLf &
"                    Replace(" & vbCrLf &
"                        Replace(" & vbCrLf &
"                            isnull(" & vbCrLf &
"                                (" & vbCrLf &
"									select distinct top 10 z.COMPANY_ID, z.COMPANY_NAME, z.ORG_ID" & vbCrLf &
"                                   From company_data z" & vbCrLf &
"									Where z.BUYING_GROUP = r.BUYING_GROUP " & vbCrLf &
"                                   order by z.COMPANY_ID asc" & vbCrLf &
"                                   For xml path('')" & vbCrLf &
"								)," & vbCrLf &
"								(" & vbCrLf &
"									Select distinct z.COMPANY_ID,z.COMPANY_NAME,z.ORG_ID" & vbCrLf &
"                                   From SAP_DIMCOMPANY z with (nolock)" & vbCrLf &
"									Where z.COMPANY_ID = r.COMPANY_ID " & vbCrLf &
"                                   order by z.COMPANY_ID asc" & vbCrLf &
"                                   For xml path('')" & vbCrLf &
"								)" & vbCrLf &
"							),'<COMPANY_ID>','{{Company ID: '" & vbCrLf &
"						),'</COMPANY_ID>',';'" & vbCrLf &
"					),'<COMPANY_NAME>','Company Name: ' " & vbCrLf &
"				),'</COMPANY_NAME>',';'      " & vbCrLf &
"			),'<ORG_ID>','Org ID: '    " & vbCrLf &
"		),'</ORG_ID>','}}, '      " & vbCrLf &
"	) as COMPANY  " & vbCrLf &
"from(" & vbCrLf &
    "Select distinct t2.COMPANY_ID, t2.COMPANY_NAME, t2.ORG_ID, t2.BUYING_GROUP," & vbCrLf &
    "case When t1.CUST_TYPE='New' then" & vbCrLf &
        "Case when t.Amount>=@NKA then 'NKA'" & vbCrLf &
        "	 when t.Amount<@NKA then 'NGA'" & vbCrLf &
        "Else 'New Cust Uncategorized'  " & vbCrLf &
            "End" & vbCrLf &
           " Else" & vbCrLf &
           " Case when t.Amount>=@GKA then 'GKA'" & vbCrLf &
            " when t.Amount>=@KA And t.Amount<@GKA then 'KA'" & vbCrLf &
             "when t.Amount<@KA then 'GA'" & vbCrLf &
        "Else 'Existing Cust Uncategorized'" & vbCrLf &
           " End" & vbCrLf &
           " End As CUST_SEG, t.Amount  " & vbCrLf &
    "from(" & vbCrLf &
"select a.BUYING_GROUP, COUNT(distinct a.order_no) as NumOfOrder, SUM(a.Us_amt) as Amount " & vbCrLf &
"		From raw_data a  " & vbCrLf &
"		Where exists(  " & vbCrLf &
"			Select aa.BUYING_GROUP  " & vbCrLf &
"            From raw_data aa   " & vbCrLf &
"			 Where aa.efftive_date between @HalfYearFrom And @HalfYearTo And a.BUYING_GROUP= aa.BUYING_GROUP" & vbCrLf &
"		) And a.efftive_date Is Not null " & vbCrLf &
"		Group by a.BUYING_GROUP     " & vbCrLf &
"	) as t     " & vbCrLf &
"    Left join ( " & vbCrLf &
"		/* 新客戶: N-1年沒有購買紀錄 */" & vbCrLf &
"        Select a.BUYING_GROUP, 'New' as CUST_TYPE" & vbCrLf &
 "       From raw_data a" & vbCrLf &
"		Where Not exists(" & vbCrLf &
"			select * from (" & vbCrLf &
"                Select distinct Case When b.VALUE='' or b.VALUE IS NULL then a.COMPANY_ID else b.VALUE end as BUYING_GROUP, a.COMPANY_ID, c.order_no, c.efftive_date " & vbCrLf &
"                From SAP_DIMCOMPANY a (nolock)" & vbCrLf &
"				Left Join SAP_DIMCOMPANY_EXT b (nolock) on a.COMPANY_ID=b.COMPANY_ID And b.TYPE='Buying Group'   " & vbCrLf &
"				Left Join EAI_SALE_FACT c (nolock) on a.COMPANY_ID=c.Customer_ID And c.efftive_date < @OneYearFrom     " & vbCrLf &
"				where a.COMPANY_ID <>'' and a.COMPANY_ID is not null and c.order_no is not null   " & vbCrLf &
"			) as aa where a.BUYING_GROUP=aa.BUYING_GROUP   " & vbCrLf &
"		)                                               " & vbCrLf &
"	) as t1 on t.BUYING_GROUP=t1.BUYING_GROUP           " & vbCrLf &
"	inner Join raw_data t2 on t.BUYING_GROUP=t2.BUYING_GROUP        " & vbCrLf &
"    union" & vbCrLf &
" /* 瞌睡客戶 : 半年內無需求 */ " & vbCrLf &
" /* LKA: 重要挽回客戶 ; LGA: 一般挽回客戶 */   " & vbCrLf &
"	Select distinct t1.COMPANY_ID, t1.COMPANY_NAME, t1.ORG_ID, t1.BUYING_GROUP, t.CUST_SEG, t.AMOUNT from (           " & vbCrLf &
"    Select a.BUYING_GROUP, SUM(a.Us_amt) As AMOUNT, Case When SUM(a.Us_amt) >= @KA Then 'LKA' else 'LGA' end as CUST_SEG   " & vbCrLf &
"    From raw_data a" & vbCrLf &
"	Where Not exists(" & vbCrLf &
"		select aa.BUYING_GROUP from raw_data aa" & vbCrLf &
"        Where aa.efftive_date between @HalfYearFrom And @HalfYearTo And a.BUYING_GROUP= aa.BUYING_GROUP" & vbCrLf &
"	) And a.efftive_date Is Not null" & vbCrLf &
"	Group by a.BUYING_GROUP" & vbCrLf &
"	) as t" & vbCrLf &
"	inner Join raw_data t1 on t.BUYING_GROUP=t1.BUYING_GROUP" & vbCrLf &
"union" & vbCrLf &
"/* 沉睡客戶 : 一年以上無需求 */" & vbCrLf &
"	Select distinct a.COMPANY_ID, a.COMPANY_NAME, a.ORG_ID, a.BUYING_GROUP, 'SA' as CUST_SEG, 0 as AMOUNT " & vbCrLf &
"    From raw_data a" & vbCrLf &
"	Where Not exists(" & vbCrLf &
"		select * from raw_data aa" & vbCrLf &
"        Where aa.BUYING_GROUP = a.BUYING_GROUP" & vbCrLf &
"		And aa.order_no Is Not null" & vbCrLf &
"	)" & vbCrLf &
") as r   " & vbCrLf &
"   order by  BUYING_GROUP "

        End Get
    End Property
End Class

