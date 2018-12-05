Imports Microsoft.VisualBasic

Public Class ACNUtil
    Private _context As HttpContext = HttpContext.Current
    Public Sub New()
    End Sub
    Public Shared ReadOnly Property Current() As ACNUtil
        Get
            If HttpContext.Current Is Nothing Then   Return Nothing
            If HttpContext.Current.Items("ACNUtil") Is Nothing Then
                Dim _ACNUtil As New ACNUtil()
                HttpContext.Current.Items.Add("ACNUtil", _ACNUtil)
                Return _ACNUtil
            End If
            Return DirectCast(HttpContext.Current.Items("ACNUtil"), ACNUtil)
        End Get
    End Property
    Private _CurrentContext As ACNcustomerDataContext
    Public ReadOnly Property ACNContext() As ACNcustomerDataContext
        Get
            If _CurrentContext Is Nothing Then
                _CurrentContext = New ACNcustomerDataContext()
            End If
            Return _CurrentContext
        End Get
    End Property
    Public Property Item(ByVal key As String) As Object
        Get
            If Me._context Is Nothing Then
                Return Nothing
            End If
            If Me._context.Items(key) IsNot Nothing Then
                Return Me._context.Items(key)
            End If
            Return Nothing
        End Get
        Set(ByVal value As Object)
            If Me._context IsNot Nothing Then
                Me._context.Items.Remove(key)

                Me._context.Items.Add(key, value)
            End If
        End Set
    End Property
    Public Enum ACNStatus
        New_Request = 0
        Approved = 1
        Rejected = -1
    End Enum
    Public Shared Function SendMail(ByVal CustomerRowid As String) As Boolean
        Dim _item As ACNitem = ACNUtil.Current.ACNContext.ACNitems.Where(Function(p) p.RowID = CustomerRowid).FirstOrDefault()
        If _item IsNot Nothing Then
            With _item
                Dim strSubject As String = ""
                Dim strFrom As String = "myadvantech@advantech.com"
                Dim strTo As String = ""
                Dim strCC As String = "shanshan.wang@advantech.com.cn,rong.le@advantech.com.cn,bingxue.jia@advantech.com.cn"
                Dim strBcc As String = "myadvantech@advantech.com"
                'If HttpContext.Current.Session("user_id") IsNot Nothing AndAlso HttpContext.Current.Session("user_id") = "ming.zhao@advantech.com.cn" Then
                '    strBcc = "ming.zhao@advantech.com.cn"
                'End If
                Dim mailbody As String = ""
                Select Case _item.StatusX
                    Case ACNUtil.ACNStatus.New_Request
                        strSubject = String.Format("{1} 于 {2} 申请新客户. 客户名称: {0} ", .sdt_Name, Util.GetNameVonEmail(.ResquestBy), CDate(.RequestDate).ToString("yyyy-MM-dd"))
                        strTo = "chunxia.li@advantech.com.cn"
                        ' strCC = ""
                        mailbody = String.Format("<br/><p></p>请点击链接 <a href=""{0}"">click</a> 查看具体信息. 谢谢.", Util.GetRuntimeSiteUrl + String.Format("/Admin/ACN/CreateCustomer.aspx?rowid={0}",
                                                                                          .RowID))
                    Case ACNUtil.ACNStatus.Approved
                        strSubject = String.Format("新客户已经被 {0} 同意提交到SAP,  公司名称: {1}({2})", Util.GetNameVonEmail(.OPerator), .sdt_Name, .sdt_EripID)
                        strTo = .ResquestBy
                        ' strCC = ""
                        mailbody = String.Format("<br/><p></p>如有问题请联系相关OP. 谢谢.")

                    Case ACNUtil.ACNStatus.Rejected
                        strSubject = String.Format("你申请的新客户被 {0} 拒绝. 客户名称: {1}", Util.GetNameVonEmail(.OPerator), .sdt_Name)
                        strTo = .ResquestBy
                        ' strCC = "ming.zhao@advantech.com.cn"
                        mailbody = String.Format("<br/><p></p>拒绝理由：{0}<p></p>如有问题请联系相关OP. 谢谢.", .Comment)
                End Select
                If Util.IsTesting() Then
                    Dim CCstr As String = strCC
                    If HttpContext.Current.Session("user_id") IsNot Nothing AndAlso HttpContext.Current.Session("user_id") = "ming.zhao@advantech.com.cn" Then
                        CCstr = "ming.zhao@advantech.com.cn"
                    End If
                    Call MailUtil.Utility_EMailPage(strFrom, HttpContext.Current.Session("user_id").ToString.Trim, CCstr, "ming.zhao@advantech.com.cn", strSubject.Trim(), "", "TO:" + strTo + "<BR/>CC:" + strCC + "<BR/>BCC:" + strBcc + "<HR/>" + mailbody.Trim())
                Else
                    Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBcc, strSubject.Trim(), "", mailbody.Trim())
                End If
            End With
        End If
        Return 1
    End Function

    Public Shared Function GetACNBtosMailBody(ByVal _orderid As String) As String
        Dim dtMASTER, dtDetail As DataTable
        Dim sHtml As String = ""
        Dim strSelectSQL As String, strOrderID As String = _orderid

        sHtml += "<div align=center style='width: 100%;'>"

        sHtml += "<div align=center style='width: 700px;text-align:center;'>"
        sHtml += "<img src='../Images/CTOS.jpg' />"
        sHtml += "<span style='margin: 0 0 30px 70px; font-weight: bold; font-size: large;'>Advantech(China) CTOS系统组装单</span>"
        sHtml += "</div>"
        'sHtml += "<div align='center'>"
        'sHtml += "<table style='width: 700px; border-width:thin; border-top-style:solid; border-bottom-style:solid;margin-bottom:5px;'>"
        'sHtml += "<tr><td>"
        sHtml += "<p style='text-align:left; font-size: x-small;display: none;'>.</p>"
        'sHtml += "</td></tr>"
        'sHtml += "</table>"
        'sHtml += "</div>"

        strSelectSQL = String.Format("select SOLDTO_ID, a.ORDER_ID, a.CREATED_BY, a.ORDER_DATE, a.REQUIRED_DATE, a.ORDER_NOTE, c.SALES_CODE + ' ' + c.FULL_NAME as Sales, d.COMPANY_NAME " +
                                     " from ORDER_MASTER a left join ORDER_PARTNERS b on a.ORDER_ID = b.ORDER_ID and b.TYPE = 'E' " +
                                     " left join SAP_EMPLOYEE c on b.ERPID = c.SALES_CODE " +
                                     " left join SAP_DIMCOMPANY d on a.SOLDTO_ID = d.COMPANY_ID " +
                                     " where a.ORDER_ID = '{0}'", strOrderID)
        dtMASTER = dbUtil.dbGetDataTable("MY", strSelectSQL)
        Dim rMASTER As DataRow = Nothing
        Dim SOLDTO_ID As String = "&nbsp;", ORDER_ID As String = "&nbsp;", CREATED_BY As String = "&nbsp;"
        Dim ORDER_DATE As String = "&nbsp;", REQUIRED_DATE As String = "&nbsp;", ORDER_NOTE As String = "&nbsp;"
        Dim Company_Name As String = "&nbsp;", Sales As String = "&nbsp;"

        If dtMASTER.Rows.Count > 0 Then
            rMASTER = dtMASTER.Rows(0)
            SOLDTO_ID = rMASTER.Item("SOLDTO_ID")
            ORDER_ID = rMASTER.Item("ORDER_ID")
            CREATED_BY = rMASTER.Item("CREATED_BY")
            ORDER_DATE = String.Format("{0:yyyy/MM/dd}", rMASTER.Item("ORDER_DATE"))
            REQUIRED_DATE = String.Format("{0:yyyy/MM/dd}", rMASTER.Item("REQUIRED_DATE"))
            ORDER_NOTE = rMASTER.Item("ORDER_NOTE")
            Company_Name = rMASTER.Item("COMPANY_NAME")
            Sales = rMASTER.Item("Sales")
        End If
        sHtml += "<div align=center>"
        sHtml += "<table style='width: 700px; font-weight: bold; font-size: x-small; border-collapse: collapse;'>"
        sHtml += "<tr>"
        sHtml += "<td style='border-width:thin; border-top-style:solid; border-bottom-style:solid;border-color:#a0a0a0;' colspan='4'>"
        sHtml += "<p style='text-align:left; font-size: medium;'>研华科技(中国)有限公司</p>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "<tr>"
        sHtml += "<td style='border: 2px solid #a0a0a0;' colspan='3'>"
        sHtml += "SOLD TO:<span id='SOLDTO'>" + Company_Name + "</span>"
        sHtml += "</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>"
        sHtml += "COMPANY CODE:<span id='COMPANY_CODE'>" + SOLDTO_ID + "</span>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "<tr>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>SALES:"
        sHtml += "<span id='SALES'>" + Sales + "</span>"
        sHtml += "</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>ORDER NO:"
        sHtml += "<span id='ORDER_NO'>" + ORDER_ID + "</span>"
        sHtml += "</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>Placed By:"
        sHtml += "<span id='Placed_By'>"
        sHtml += "<a href='mailto:" + CREATED_BY + "'>" + CREATED_BY + "</a>"
        sHtml += "</span>"
        sHtml += "</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>ORDER DATE:"
        sHtml += "<span id='ORDER_DATE'>" + ORDER_DATE + "</span><br />"
        sHtml += "<span style='color: red;'>REQUIRED DATE:</span><span style='color: red;' id='REQUIRED_DATE'>" + REQUIRED_DATE + "</span>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "</table>"
        sHtml += "</div>"

        sHtml += "<div>&nbsp;</div>"

        sHtml += "<div align=center>"
        sHtml += "<table style='width: 700px; background-color: #dddddd; font-size: x-small;  border: 2px ridge #a0a0a0; border-collapse: collapse;'>"

        strSelectSQL = "select PART_NO,QTY from ORDER_DETAIL " &
                        "where ORDER_ID='" & strOrderID & "' and LINE_NO=100 "
        dtDetail = dbUtil.dbGetDataTable("MY", strSelectSQL)
        Dim rDetail As DataRow = Nothing
        Dim PART_NO As String = "&nbsp;", QTY As String = "&nbsp;"
        If dtDetail.Rows.Count > 0 Then
            rDetail = dtDetail.Rows(0)
            PART_NO = rDetail.Item("PART_NO")
            QTY = rDetail.Item("QTY")
        End If

        sHtml += "<thead>"
        sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
        sHtml += "<td align='center' style='background-color: #33cccc; font-size: large; border: 2px solid #a0a0a0;' colspan='6'>"
        sHtml += "<p style='margin: 0 0 0 0; font-weight: bold;'>CTOS Configuration for "
        sHtml += "<span style='color: blue;'>" + PART_NO + "</span> x"
        sHtml += "<span id='title_num'>" + QTY + "</span>"
        sHtml += "</p>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
        sHtml += "<td style='background-color: #33cccc; border: 2px solid #a0a0a0; width:5%;text-align: center;'>#</td>"
        sHtml += "<td style='background-color: #33cccc; border: 2px solid #a0a0a0; width:35%'>Category</td>"
        sHtml += "<td style='background-color: #33cccc; border: 2px solid #a0a0a0; width:20%'>Advantech No.</td>"
        sHtml += "<td style='background-color: #33cccc; border: 2px solid #a0a0a0; width:35%'> Description</td>"
        sHtml += "<td style='background-color: #33cccc; border: 2px solid #a0a0a0; width:5%;text-align: center;'>QTY</td>"
        sHtml += "</tr>"
        sHtml += "</thead>"

        strSelectSQL = "select ISNULL(Cate, '') as [Cate],PART_NO,Description,QTY,UNIT_PRICE from ORDER_DETAIL " &
                        "where ORDER_ID='" & strOrderID & "' and LINE_NO<>100 " &
                        "order by LINE_NO"
        dtDetail = dbUtil.dbGetDataTable("MY", strSelectSQL)


        sHtml += "<tbody>"
        Dim Total_Price As Decimal = 0
        If dtDetail.Rows.Count > 0 Then
            For i As Integer = 0 To dtDetail.Rows.Count - 1

                Dim bgcolor As String = String.Empty
                Dim cate As String = dtDetail.Rows(i).Item("Cate").ToString()
                If cate.Equals("Others", StringComparison.InvariantCultureIgnoreCase) Then bgcolor = " background-color: #ffff99;"

                sHtml += "<tr style='border: 2px solid #a0a0a0;" + bgcolor + "'>"
                sHtml += "<td style='border: 2px solid #a0a0a0;" + bgcolor + " text-align: center;'>" + CStr(i + 1) + "</td>"
                sHtml += "<td style='border: 2px solid #a0a0a0;" + bgcolor + "'>" + dtDetail.Rows(i).Item("Cate") + "</td>"
                sHtml += "<td style='border: 2px solid #a0a0a0;" + bgcolor + "'>" + dtDetail.Rows(i).Item("PART_NO") + "</td>"
                sHtml += "<td style='border: 2px solid #a0a0a0;" + bgcolor + "'>" + dtDetail.Rows(i).Item("Description") + "</td>"
                sHtml += "<td style='border: 2px solid #a0a0a0;" + bgcolor + " text-align: center;'>" + CStr(dtDetail.Rows(i).Item("QTY")) + "</td>"
                sHtml += "</tr>"

                Total_Price += (CDec(dtDetail.Rows(i).Item("UNIT_PRICE")) * CDec(dtDetail.Rows(i).Item("QTY")))
            Next
        End If
        sHtml += "</tbody>"

        sHtml += "<tfoot>"
        sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
        sHtml += " <td style='border: 2px solid #a0a0a0; text-align: center;'>***</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;'>Configuration File</td>"
        sHtml += "<td style='border: 2px solid #a0a0a0;' colspan='4'>&nbsp;</td>"
        sHtml += "</tr>"
        sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
        sHtml += "<td style='border: 2px solid #a0a0a0; color: red; font-size: small; ' colspan='6'>"
        sHtml += "折扣总金额：&nbsp;<span id='CurrencySign'></span>&nbsp;<span id='totalprice'>" + CStr(Total_Price) + "</span>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
        sHtml += "<td style='border: 2px solid #a0a0a0; color: red; font-size: small;' colspan='6'>"
        sHtml += "<p style='margin: 0 0 0 0; font-weight: bold;'>" + ORDER_NOTE + "</p>"
        sHtml += "</td>"
        sHtml += "</tr>"
        sHtml += "</tfoot>"
        sHtml += "</table>"
        sHtml += "<p style='font-size:xx-small;'>Advantech(China) Configuration & QC Inspection Sheet, Rev. A02, 03-27-00</p>"
        sHtml += "</div>"

        sHtml += "</div>"

        Return sHtml
    End Function

End Class
Partial Public Class ACNitem
    Public ReadOnly Property StatusX As ACNUtil.ACNStatus
        Get
            If IsNumeric(Me.Status) Then
                If [Enum].IsDefined(GetType(ACNUtil.ACNStatus), Me.Status) Then
                    Return CType([Enum].ToObject(GetType(ACNUtil.ACNStatus), Me.Status), ACNUtil.ACNStatus)
                End If
            End If
            Return ACNUtil.ACNStatus.New_Request
        End Get
    End Property
    Public ReadOnly Property StatusDescX As String
        Get
            Return [Enum].GetName(GetType(ACNUtil.ACNStatus), Me.Status).Replace("_", vbTab)
        End Get
    End Property
    Public ReadOnly Property ResquestByX As String
        Get
            Return Util.GetNameVonEmail(Me.ResquestBy)
        End Get
    End Property
End Class


