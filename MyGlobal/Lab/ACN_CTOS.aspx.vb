
Partial Class Lab_ACN_CTOS
    Inherits System.Web.UI.Page
    Public strHTML As String
    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim dtMASTER, dtDetail As DataTable
            Dim sHtml As String = ""
            Dim strSelectSQL As String, strOrderID As String = "TWO018142"
            '

            sHtml += "<div align='center' style='width: 100%;'>"
            sHtml += "<div style='width: 700px;'>"
            sHtml += "<img src='../Images/CTOS.jpg' />"
            sHtml += "<span style='margin: 0 0 30px 70px; font-weight: bold; font-size: large;'>Advantech(China) CTOS系统组装单</span>"
            sHtml += "<hr>"
            sHtml += "<p style='text-align: left; font-size: x-small;'>研华科技(中国)有限公司 </p>"
            sHtml += "<hr>"


            strSelectSQL = "select SOLDTO_ID,ORDER_ID,CREATED_BY,ORDER_DATE,REQUIRED_DATE,ORDER_NOTE from ORDER_MASTER  " &
                            "where ORDER_ID='" & strOrderID & "' "

            dtMASTER = dbUtil.dbGetDataTable("MY", strSelectSQL)
            Dim rMASTER As DataRow = Nothing
            Dim SOLDTO_ID As String = "&nbsp;", ORDER_ID As String = "&nbsp;", CREATED_BY As String = "&nbsp;"
            Dim ORDER_DATE As String = "&nbsp;", REQUIRED_DATE As String = "&nbsp;", ORDER_NOTE As String = "&nbsp;"

            If dtMASTER.Rows.Count > 0 Then
                rMASTER = dtMASTER.Rows(0)
                SOLDTO_ID = rMASTER.Item("SOLDTO_ID")
                ORDER_ID = rMASTER.Item("ORDER_ID")
                CREATED_BY = rMASTER.Item("CREATED_BY")
                ORDER_DATE = String.Format("{0:yyyy/MM/dd}", rMASTER.Item("ORDER_DATE"))
                REQUIRED_DATE = String.Format("{0:yyyy/MM/dd}", rMASTER.Item("REQUIRED_DATE"))
                ORDER_NOTE = rMASTER.Item("ORDER_NOTE")
            End If
            sHtml += "<table style='width: 100%; font-weight: bold; font-size: x-small; border: 2px ridge #a0a0a0; border-collapse: collapse;'>"
            sHtml += "<tr>"
            sHtml += "<td style='border: 2px solid #a0a0a0;' colspan='3'>"
            sHtml += "SOLD TO:<span id='SOLDTO'>" + SOLDTO_ID + "</span>"
            sHtml += "</td>"
            sHtml += "<td style='border: 2px solid #a0a0a0;'>"
            sHtml += "COMPANY CODE:<span id='COMPANY_CODE'>" + SOLDTO_ID + "</span>"
            sHtml += "</td>"
            sHtml += "</tr>"
            sHtml += "<td style='border: 2px solid #a0a0a0;'>SALES:"
            sHtml += "<span id='SALES'>&nbsp;</span>"
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

            strSelectSQL = "select Cate,PART_NO,Description,QTY,UNIT_PRICE from ORDER_DETAIL " &
                            "where ORDER_ID='" & strOrderID & "' and LINE_NO<>100 " &
                            "order by LINE_NO"
            dtDetail = dbUtil.dbGetDataTable("MY", strSelectSQL)


            sHtml += "<tbody>"
            Dim Total_Price As Decimal = 0
            If dtDetail.Rows.Count > 0 Then
                For i As Integer = 0 To dtDetail.Rows.Count - 1
                    sHtml += "<tr style='border: 2px solid #a0a0a0;'>"
                    sHtml += "<td style='border: 2px solid #a0a0a0; text-align: center;'>" + CStr(i + 1) + "</td>"
                    sHtml += "<td style='border: 2px solid #a0a0a0;'>" + dtDetail.Rows(i).Item("Cate") + "</td>"
                    sHtml += "<td style='border: 2px solid #a0a0a0;'>" + dtDetail.Rows(i).Item("PART_NO") + "</td>"
                    sHtml += "<td style='border: 2px solid #a0a0a0;'>" + dtDetail.Rows(i).Item("Description") + "</td>"
                    sHtml += "<td style='border: 2px solid #a0a0a0; text-align: center;'>" + CStr(dtDetail.Rows(i).Item("QTY")) + "</td>"
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

            strHTML = sHtml
        End If
    End Sub
End Class
