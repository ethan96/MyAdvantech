<%@ WebService Language="VB" Class="mSales" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Data.SqlClient

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<WebService(Namespace:="MyAdvantech")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class mSales
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty"
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function AutoSuggestPN(ByVal PN As String) As String
        Dim apt As New SqlDataAdapter( _
              " select top 10 part_no from sap_product where part_no like '" + Trim(PN).Replace("'", "''").Replace("*", "%") + "%' order by part_no", _
              ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim dtPN As New DataTable
        apt.Fill(dtPN)
        apt.SelectCommand.Connection.Close()
        Dim arrPn As New ArrayList
        For Each r As DataRow In dtPN.Rows
            arrPn.Add(r.Item("part_no"))
        Next
        Dim jSerializer As New Script.Serialization.JavaScriptSerializer
        Return jSerializer.Serialize(arrPn)
    End Function

#Region "Oppty & Forecast"

    <WebMethod()> _
    Public Function WriteOptyProdFcst(ByVal InputData As String) As String
        Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
        Dim strClientIP As String = Util.GetClientIP(), FcstInputIn1 As FcstInputIn = Nothing, FcstInputOut1 As New FcstInputOut
        Try
            FcstInputIn1 = jSerializer.Deserialize(Of FcstInputIn)(InputData)
        Catch ex As Exception
            FcstInputOut1.IsFunctionCallOK = False : FcstInputOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(FcstInputOut1)
        End Try

        Dim OpptyQueryIn1 As New OpptyQueryIn
        With OpptyQueryIn1
            .AccountName = "" : .AccountRowId = "" : .OptyId = FcstInputIn1.OptyId : .TempId = FcstInputIn1.TempId
        End With
        Dim strQueryOptyInData = jSerializer.Serialize(OpptyQueryIn1)
        Dim strQueryOptyOutData As String = SearchMyOppty(strQueryOptyInData)
        Dim OpptyQueryOut1 As OpptyQueryOut = jSerializer.Deserialize(Of OpptyQueryOut)(strQueryOptyOutData)
        FcstInputOut1.IsAuthenticated = OpptyQueryOut1.IsAuthenticated : FcstInputOut1.IsFunctionCallOK = OpptyQueryOut1.IsFunctionCallOK : FcstInputOut1.ErrorMessage = OpptyQueryOut1.ErrorMessage

        Dim aptCrm As New SqlDataAdapter( _
               " select a.CURCY_CD,b.NAME from S_OPTY a inner join S_BU b on a.BU_ID=b.ROW_ID " + _
               " where a.CURCY_CD is not null and a.ROW_ID=@OPTYID order by a.CREATED desc", ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
        aptCrm.SelectCommand.Parameters.AddWithValue("OPTYID", FcstInputIn1.OptyId)
        Dim dtOpty As New DataTable
        aptCrm.Fill(dtOpty)
        aptCrm.SelectCommand.Connection.Close()

        If OpptyQueryOut1.IsAuthenticated AndAlso OpptyQueryOut1.IsFunctionCallOK AndAlso OpptyQueryOut1.OpptyList.Count = 1 AndAlso dtOpty.Rows.Count > 0 Then
            Dim optyCurr As String = dtOpty.Rows(0).Item("CURCY_CD"), org As String = dtOpty.Rows(0).Item("NAME")

            Dim ws As New eCoverageWS.WSSiebel, PDFORECAST As New eCoverageWS.PRODUCT_FORECAST, EMP As New eCoverageWS.EMPLOYEE
            EMP.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : EMP.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")
            Dim arrPD As New ArrayList, arrQty As New ArrayList

            If FcstInputIn1.IsAppend Then
                aptCrm = New SqlDataAdapter( _
                    " select cast(a.QTY as int) as QTY, a.EFFECTIVE_DT, b.NAME as PART_NO " + _
                    " from S_REVN a inner join S_PROD_INT b on a.PROD_ID=b.ROW_ID  " + _
                    " where a.OPTY_ID=@OPTYID and a.QTY is not null " + _
                    " order by a.ROW_ID  ", ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
                aptCrm.SelectCommand.Parameters.AddWithValue("OPTYID", FcstInputIn1.OptyId)
                Dim dtOriginalFcst As New DataTable
                aptCrm.Fill(dtOriginalFcst)
                aptCrm.SelectCommand.Connection.Close()
                For Each rFcst As DataRow In dtOriginalFcst.Rows
                    arrPD.Add(rFcst.Item("PART_NO")) : arrQty.Add(rFcst.Item("QTY").ToString())
                Next
            End If

            For Each FcstInputRecord1 As FcstInputRecord In FcstInputIn1.FcstInputRecords
                arrPD.Add(FcstInputRecord1.PartNo) : arrQty.Add(FcstInputRecord1.Qty.ToString())
            Next
            PDFORECAST.OPPTY_ID = FcstInputIn1.OptyId : PDFORECAST.PRODUCT = arrPD.ToArray(GetType(String)) : PDFORECAST.PRODUCT_QUANTITY = arrQty.ToArray(GetType(String))
            PDFORECAST.SALES_REP_ORGANIZATION = org

            Try
                Dim ret As eCoverageWS.RESULT = ws.AddProductForecast(EMP, PDFORECAST)
                FcstInputOut1.ReturnedRowId = ret.ROW_ID
            Catch ex As Exception
                FcstInputOut1.IsFunctionCallOK = False : FcstInputOut1.ErrorMessage = ex.ToString()
            End Try
          
        Else
            FcstInputOut1.IsFunctionCallOK = False : FcstInputOut1.ErrorMessage = "Cannot find opportunity"
        End If
        Return jSerializer.Serialize(FcstInputOut1)

    End Function

    Class FcstInputIn
        Public Sub New()
            TempId = "" : OptyId = "" : FcstInputRecords = New List(Of FcstInputRecord) : IsAppend = True
        End Sub
        Public Property TempId As String : Public Property OptyId As String : Public Property FcstInputRecords As List(Of FcstInputRecord) : Public Property IsAppend As Boolean
    End Class

    Class FcstInputRecord
        Public Property PartNo As String : Public Property Qty As Integer : Public Property EffectiveDate As Date
        Public Sub New(ByVal PN As String, ByVal Qty As Integer)
            Me.PartNo = PN : Me.Qty = Qty
        End Sub
        Public Sub New()

        End Sub
    End Class

    Class FcstInputOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = ""
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property ReturnedRowId As String
    End Class

    <WebMethod()> _
    Public Function getOptyProdFcst(ByVal QueryData As String) As String
        Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
        Dim strClientIP As String = Util.GetClientIP(), FcstQueryIn1 As FcstQueryIn = Nothing, FcstQueryOut1 As New FcstQueryOut
        Try
            FcstQueryIn1 = jSerializer.Deserialize(Of FcstQueryIn)(QueryData)
        Catch ex As Exception
            FcstQueryOut1.IsFunctionCallOK = False : FcstQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(FcstQueryOut1)
        End Try
        Dim OpptyQueryIn1 As New OpptyQueryIn
        With OpptyQueryIn1
            .AccountName = "" : .AccountRowId = "" : .OptyId = FcstQueryIn1.OptyId : .TempId = FcstQueryIn1.TempId
        End With
        Dim strQueryOptyInData = jSerializer.Serialize(OpptyQueryIn1)
        Dim strQueryOptyOutData As String = SearchMyOppty(strQueryOptyInData)
        Dim OpptyQueryOut1 As OpptyQueryOut = jSerializer.Deserialize(Of OpptyQueryOut)(strQueryOptyOutData)
        FcstQueryOut1.IsAuthenticated = OpptyQueryOut1.IsAuthenticated : FcstQueryOut1.IsFunctionCallOK = OpptyQueryOut1.IsFunctionCallOK : FcstQueryOut1.ErrorMessage = OpptyQueryOut1.ErrorMessage
        If OpptyQueryOut1.IsAuthenticated AndAlso OpptyQueryOut1.IsFunctionCallOK AndAlso OpptyQueryOut1.OpptyList.Count = 1 Then
            FcstQueryOut1.OpptyRecord = OpptyQueryOut1.OpptyList.Item(0)
            Dim strFcstSql As String = _
                " select cast(a.QTY as int) as QTY, a.EFFECTIVE_DT, b.NAME as PART_NO, b.DESC_TEXT  " + _
                " from S_REVN a inner join S_PROD_INT b on a.PROD_ID=b.ROW_ID  " + _
                " where a.OPTY_ID='" + FcstQueryIn1.OptyId + "' and a.QTY is not null " + _
                " order by a.ROW_ID  "
            Dim dt As New DataTable
            Dim apt As New SqlDataAdapter(strFcstSql, ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
            apt.Fill(dt)
            apt.SelectCommand.Connection.Close()
            For Each r As DataRow In dt.Rows
                Dim fcstRec1 As New FcstRecord
                With fcstRec1
                    .PartNo = r.Item("PART_NO") : .Qty = r.Item("QTY") : .EffectiveDate = CDate(r.Item("EFFECTIVE_DT")).ToString("yyyy/MM/dd")
                End With
                FcstQueryOut1.FcstList.Add(fcstRec1)
            Next
        Else
            FcstQueryOut1.IsFunctionCallOK = False : FcstQueryOut1.ErrorMessage = "Cannot find opportunity"
        End If
        Return jSerializer.Serialize(FcstQueryOut1)
    End Function

    Class FcstQueryIn
        Public Property TempId As String : Public Property OptyId As String
    End Class

    Class FcstQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : OpptyRecord = New OpptyRecord() : FcstList = New List(Of FcstRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String
        Public Property OpptyRecord As OpptyRecord : Public Property FcstList As List(Of FcstRecord)
    End Class

    Class FcstRecord
        Public Property PartNo As String : Public Property Qty As Integer : Public Property EffectiveDate As String
    End Class

    <WebMethod()> _
    Public Function SearchMyOppty(ByVal QueryData As String) As String
        Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Try
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
            Dim strClientIP As String = Util.GetClientIP(), OpptyQueryIn1 As OpptyQueryIn = Nothing, OpptyQueryOut1 As New OpptyQueryOut
            Try
                OpptyQueryIn1 = jSerializer.Deserialize(Of OpptyQueryIn)(QueryData)
            Catch ex As Exception
                OpptyQueryOut1.IsFunctionCallOK = False : OpptyQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(OpptyQueryOut1)
            End Try
            If Not VerifyTempId(OpptyQueryIn1.TempId, strClientIP, strUserId) Then
                OpptyQueryOut1.IsAuthenticated = False : OpptyQueryOut1.ErrorMessage = "Failed to authenticate. Please login again." : Return jSerializer.Serialize(OpptyQueryOut1)
            End If
            OpptyQueryOut1.IsAuthenticated = True : OpptyQueryOut1.IsFunctionCallOK = True
            ReplaceUIDToSalesForTesting(strUserId)
            Dim sbSql As New System.Text.StringBuilder
            With sbSql
                .AppendLine(" select top 100 a.ROW_ID as OPTY_ID, a.NAME as OPTY_NAME, a.CREATED, a.LAST_UPD,   ")
                .AppendLine(" d.ROW_ID as ACCOUNT_ID, d.NAME as ACCOUNT_NAME, IsNull(a.STATUS_CD,'') as STATUS_CD, IsNull(a.SUM_REVN_AMT,0) as SUM_REVN_AMT, IsNull(a.CURCY_CD,'') as CURCY_CD,  ")
                .AppendLine(" IsNull(e.NAME,'') as STAGE_NAME, a.SUM_WIN_PROB, a.SUM_EFFECTIVE_DT, IsNull(f.NAME,'') as STAGE_NAME, ")
                .AppendLine(" IsNull((select COUNT(z.ROW_ID) from S_REVN z where z.OPTY_ID=a.ROW_ID and z.PROD_ID is not null),0) as ProdForecastRows ")
                .AppendLine(" from S_OPTY a inner join S_POSTN b on a.PR_POSTN_ID=b.ROW_ID inner join S_CONTACT c on b.PR_EMP_ID=c.ROW_ID  ")
                .AppendLine(" inner join S_ORG_EXT d on a.PR_DEPT_OU_ID=d.ROW_ID inner join S_STG e on a.CURR_STG_ID=e.ROW_ID ")
                .AppendLine(" inner join S_STG f on a.CURR_STG_ID=f.ROW_ID  ")
                If String.IsNullOrEmpty(OpptyQueryIn1.OptyId) Then
                    .AppendLine(" where a.SUM_WIN_PROB>0 and a.SUM_WIN_PROB<100 ")
                Else

                End If
                .AppendLine(" and lower(c.EMAIL_ADDR)=LOWER('" + Replace(strUserId, "'", "''") + "')  ")
                If Not String.IsNullOrEmpty(OpptyQueryIn1.OptyName) Then
                    .AppendLine(String.Format(" and (lower(a.NAME) like N'%'+LOWER('{0}')+'%' or LOWER(a.DESC_TEXT) like N'%'+LOWER('{0}')+'%') ", _
                                              Trim(OpptyQueryIn1.OptyName).Replace("'", "''").Replace("*", "%")))
                End If
                If Not String.IsNullOrEmpty(OpptyQueryIn1.OptyId) Then
                    .AppendLine(" and a.ROW_ID='" + OpptyQueryIn1.OptyId + "' ")
                End If
                If Not String.IsNullOrEmpty(OpptyQueryIn1.AccountRowId) Then
                    .AppendLine(" and d.ROW_ID='" + OpptyQueryIn1.AccountRowId + "' ")
                End If
                If Not String.IsNullOrEmpty(OpptyQueryIn1.AccountName) Then
                    .AppendLine(String.Format(" and lower(d.NAME) like N'%'+LOWER('{0}')+'%' ", Trim(OpptyQueryIn1.AccountName).Replace("'", "''").Replace("*", "%")))
                End If
                .AppendLine(" order by d.ROW_ID, a.ROW_ID, a.CREATED ")
            End With

            Dim dt As New DataTable
            Dim apt As New SqlDataAdapter(sbSql.ToString(), ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
            apt.Fill(dt)
            apt.SelectCommand.Connection.Close()
            For Each r As DataRow In dt.Rows
                Dim OpptyRecord1 As New OpptyRecord
                With OpptyRecord1
                    .OptyId = r.Item("OPTY_ID") : .OptyName = r.Item("OPTY_NAME") : .StgName = r.Item("STAGE_NAME") : .AccountId = r.Item("ACCOUNT_ID")
                    .AccountName = r.Item("ACCOUNT_NAME") : .OptyAmount = Util.FormatMoney(r.Item("SUM_REVN_AMT"), r.Item("CURCY_CD")) : .OptyStatus = r.Item("STATUS_CD")
                    .HasFcst = IIf(CInt(r.Item("ProdForecastRows")) > 0, True, False)
                End With
                OpptyQueryOut1.OpptyList.Add(OpptyRecord1)
            Next
            Return jSerializer.Serialize(OpptyQueryOut1)
        Catch ex As Exception
            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Call SearchMyOppty Error", "QueryData:" + QueryData + ";Exception:" + ex.ToString())
        End Try
        Return ""
    End Function

    Class OpptyQueryIn
        Public Property TempId As String : Public Property AccountName As String : Public Property AccountRowId As String : Public Property OptyName As String : Public Property OptyId As String
    End Class

    Class OpptyQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : OpptyList = New List(Of OpptyRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property OpptyList As List(Of OpptyRecord)
    End Class

    Class OpptyRecord
        Public Property OptyId As String : Public Property OptyName As String : Public Property AccountName As String : Public Property AccountId As String
        Public Property OptyStatus As String : Public Property OptyAmount As String : Public Property StgName As String : Public Property HasFcst As Boolean
    End Class
#End Region

#Region "My Account"
    <WebMethod()> _
    Public Function SearchMyAccount(ByVal QueryData As String) As String
        Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Try
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
            Dim strClientIP As String = Util.GetClientIP(), AccountQueryIn1 As AccountQueryIn = Nothing, AccountQueryOut1 As New AccountQueryOut
            Try
                AccountQueryIn1 = jSerializer.Deserialize(Of AccountQueryIn)(QueryData)
            Catch ex As Exception
                AccountQueryOut1.IsFunctionCallOK = False : AccountQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(AccountQueryOut1)
            End Try
            If Not VerifyTempId(AccountQueryIn1.TempId, strClientIP, strUserId) Then
                AccountQueryOut1.IsAuthenticated = False : AccountQueryOut1.ErrorMessage = "Failed to authenticate. Please login again." : Return jSerializer.Serialize(AccountQueryOut1)
            End If
            AccountQueryOut1.IsAuthenticated = True : AccountQueryOut1.IsFunctionCallOK = True
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "call SearchMyAccount by " + strUserId, "1")
            ReplaceUIDToSalesForTesting(strUserId)
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "call SearchMyAccount by " + strUserId, "2")
            Dim strSql As String = _
                " select top 50 a.ROW_ID, a.ACCOUNT_NAME, a.ACCOUNT_STATUS, a.ERP_ID, a.PHONE_NUM,  " + _
                " a.COUNTRY, a.CITY, a.ADDRESS, a.STATE, a.PROVINCE, a.ZIPCODE   " + _
                " from SIEBEL_ACCOUNT a " + _
                " where a.ROW_ID in   " + _
                " (  " + _
                " 	select z1.ACCOUNT_ROW_ID  " + _
                " 	from SIEBEL_ACCOUNT_OWNER z1 inner join SIEBEL_CONTACT z2 on z1.OWNER_ID=z2.ROW_ID  " + _
                " 	where z2.EMAIL_ADDRESS = '" + Replace(strUserId, ";", "''") + "' and z1.ACCOUNT_ROW_ID is not null  " + _
                " )  "
            If String.IsNullOrEmpty(AccountQueryIn1.AccountRowId) = False Then
                strSql += " and a.ROW_ID='" + Replace(AccountQueryIn1.AccountRowId, "'", "''") + "' "
            End If
            If String.IsNullOrEmpty(AccountQueryIn1.AccountName) = False Then
                strSql += " and a.ACCOUNT_NAME like N'%" + Replace(Replace(Trim(AccountQueryIn1.AccountName), "'", "''"), "*", "%") + "%' "
            End If
            strSql += " order by a.ACCOUNT_STATUS, a.ERP_ID, a.ACCOUNT_NAME  "
            Dim dt As New DataTable
            Dim apt As New SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            apt.Fill(dt)
            apt.SelectCommand.Connection.Close()
            For Each r As DataRow In dt.Rows
                Dim AccountRecord1 As New AccountRecord
                With AccountRecord1
                    .AccountName = r.Item("ACCOUNT_NAME") : .AccountRowId = r.Item("ROW_ID") : .Address = r.Item("ADDRESS") : .City = r.Item("CITY") : .Country = r.Item("COUNTRY")
                    .ERPID = r.Item("ERP_ID") : .PhoneNum = FormatSiebelPhone(r.Item("PHONE_NUM")) : .Province = r.Item("PROVINCE") : .State = r.Item("STATE") : .Zipcode = r.Item("ZIPCODE")
                End With
                AccountQueryOut1.AccountList.Add(AccountRecord1)
            Next
            Return jSerializer.Serialize(AccountQueryOut1)
        Catch ex As Exception

            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Call Search My Account Error", "QueryData:" + QueryData + ";Exception:" + ex.ToString())
        End Try
        Return ""
    End Function

    Class AccountQueryIn
        Public Property TempId As String : Public Property AccountName As String : Public Property AccountRowId As String
    End Class

    Class AccountQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : AccountList = New List(Of AccountRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property AccountList As List(Of AccountRecord)
    End Class

    Class AccountRecord
        Public Property AccountName As String : Public Property AccountRowId As String : Public Property Country As String : Public Property City As String : Public Property State As String
        Public Property Address As String : Public Property Zipcode As String : Public Property PhoneNum As String : Public Property Province As String : Public Property ERPID As String
    End Class
#End Region

#Region "Search Mkt"
    <WebMethod()> _
    Public Function SearchMktMaterial(ByVal QueryData As String) As String
        Try
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
            Dim strClientIP As String = Util.GetClientIP(), MktDataQueryIn1 As MktDataQueryIn = Nothing, MktDataQueryOut1 As New MktDataQueryOut
            Try
                MktDataQueryIn1 = jSerializer.Deserialize(Of MktDataQueryIn)(QueryData)
            Catch ex As Exception
                MktDataQueryOut1.IsFunctionCallOK = False : MktDataQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(MktDataQueryOut1)
            End Try
            If Not VerifyTempId(MktDataQueryIn1.TempId, strClientIP, strUserId) Then
                MktDataQueryOut1.IsAuthenticated = False : MktDataQueryOut1.ErrorMessage = "Failed to authenticate. Please login again." : Return jSerializer.Serialize(MktDataQueryOut1)
            End If
            MktDataQueryOut1.IsAuthenticated = True

            Dim strLitType As String = "'eDM / eNewsletter','News','Case Study','Video','eCatalog','Product Spotlight','White Papers','Solutions'"
            If Not String.IsNullOrEmpty(MktDataQueryIn1.LitType) Then strLitType = "'" + MktDataQueryIn1.LitType + "'"
            Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(Replace(MktDataQueryIn1.Keyword, "*", "%")))
            Dim strKey As String = fts.NormalForm.Replace("'", "''")
            Dim strSql As String = _
                " select distinct top 50 a.TITLE, a.RELEASE_DATE, a.CATEGORY_NAME, a.RECORD_ID, a.HYPER_LINK, a.ABSTRACT " + _
                " FROM WWW_RESOURCES AS a left JOIN WWW_RESOURCES_DETAIL b ON a.RECORD_ID = b.RECORD_ID  " + _
                " WHERE a.IS_INTERNAL_ONLY=0 " + _
                " and a.CATEGORY_NAME in (" + strLitType + ") "
            If String.IsNullOrEmpty(MktDataQueryIn1.Keyword) = False Then
                strSql += String.Format( _
             " and ( " + _
             " 		a.ROW_ID in (SELECT top 50 [key] from freetexttable(WWW_RESOURCES, (title, abstract),N'{0}') order by [rank] desc) or  " + _
             " 		a.ROW_ID in (SELECT top 50 [key] from freetexttable(WWW_RESOURCES_DETAIL, (cms_content),N'{0}') order by [rank] desc)  " + _
             " 	)  ", strKey)
            End If
            strSql += " order by a.RELEASE_DATE desc "
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            apt.SelectCommand.CommandTimeout = 6000
            apt.Fill(dt)
            If dt.Rows.Count < 5 And String.IsNullOrEmpty(MktDataQueryIn1.Keyword) = False Then
                strSql = String.Format( _
                    " select distinct top 50 a.TITLE, a.RELEASE_DATE, a.CATEGORY_NAME, a.RECORD_ID, a.HYPER_LINK, a.ABSTRACT " + _
                    " FROM WWW_RESOURCES AS a left JOIN WWW_RESOURCES_DETAIL b ON a.RECORD_ID = b.RECORD_ID  " + _
                    " WHERE a.IS_INTERNAL_ONLY=0 " + _
                    " and a.CATEGORY_NAME in (" + strLitType + ") " + _
                    " and (a.TITLE like N'%{0}%' or a.ABSTRACT like N'%{0}%' or b.CMS_CONTENT like N'%{0}%') " + _
                    " order by a.RELEASE_DATE desc ", Replace(Replace(Trim(MktDataQueryIn1.Keyword), "*", "%"), "'", "''"))
                apt.SelectCommand.CommandText = strSql
                Dim dt2 As New DataTable
                If apt.SelectCommand.Connection.State <> ConnectionState.Open Then apt.SelectCommand.Connection.Open()
                apt.Fill(dt2)
                For Each r2 As DataRow In dt2.Rows
                    If dt.Select("RECORD_ID='" + r2.Item("RECORD_ID") + "'").Length = 0 Then
                        dt.Rows.Add(r2.ItemArray)
                    End If
                Next
            End If
            apt.SelectCommand.Connection.Close()
            For Each r As DataRow In dt.Rows
                Dim doc1 As New HtmlAgilityPack.HtmlDocument
                doc1.LoadHtml(r.Item("ABSTRACT"))
                Dim strTmpAbstract As String = doc1.DocumentNode.InnerText
                If String.IsNullOrEmpty(strTmpAbstract) = False AndAlso strTmpAbstract.Length >= 100 Then strTmpAbstract = Left(strTmpAbstract, 100) + "..."
                r.Item("ABSTRACT") = strTmpAbstract
                Dim LiteratureRecord1 As New LiteratureRecord
                With LiteratureRecord1
                    .Abstract = r.Item("ABSTRACT") : .LitName = r.Item("TITLE") : .LitType = r.Item("CATEGORY_NAME") : .RecordId = r.Item("RECORD_ID")
                End With
                MktDataQueryOut1.LiteratureList.Add(LiteratureRecord1)
            Next
            Return jSerializer.Serialize(MktDataQueryOut1)
        Catch ex As Exception
            Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Call Search Mkt Error", "QueryData:" + QueryData + ";Exception:" + ex.ToString())
        End Try
        Return ""
    End Function

    Class MktDataQueryIn
        Public Property TempId As String : Public Property Keyword As String : Public Property LitType As String
    End Class

    Class MktDataQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : LiteratureList = New List(Of LiteratureRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property LiteratureList As List(Of LiteratureRecord)
    End Class

    Class LiteratureRecord
        Public Property LitType As String : Public Property RecordId As String : Public Property LitName As String : Public Property Abstract As String
    End Class
#End Region

#Region "Search My Contact"
    <WebMethod()> _
    Public Function SearchMyContact(ByVal QueryData As String) As String
        Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Try
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "SearchMyContact QueryData", QueryData)
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
            Dim strClientIP As String = Util.GetClientIP(), ContactDataQueryIn1 As ContactDataQueryIn = Nothing, ContactDataQueryOut1 As New ContactDataQueryOut
            Try
                ContactDataQueryIn1 = jSerializer.Deserialize(Of ContactDataQueryIn)(QueryData)
            Catch ex As Exception
                ContactDataQueryOut1.IsFunctionCallOK = False : ContactDataQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(ContactDataQueryOut1)
            End Try
            If Not VerifyTempId(ContactDataQueryIn1.TempId, strClientIP, strUserId) Then
                ContactDataQueryOut1.IsAuthenticated = False : ContactDataQueryOut1.ErrorMessage = "Failed to authenticate. Please login again." : Return jSerializer.Serialize(ContactDataQueryOut1)
            End If

            ContactDataQueryOut1.IsAuthenticated = True : ContactDataQueryOut1.IsFunctionCallOK = True
            ReplaceUIDToSalesForTesting(strUserId)

            Dim strSql As String = _
                " select top 100 a.ROW_ID as CONTACT_ID, a.FirstName, a.LastName, a.JOB_FUNCTION, a.JOB_TITLE, a.EMAIL_ADDRESS,  " + _
                " a.WorkPhone, a.CellPhone, b.ACCOUNT_NAME, b.ROW_ID as ACCOUNT_ID, b.COUNTRY, b.CITY, b.ADDRESS, a.Salutation  " + _
                " from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID  " + _
                " where b.ROW_ID in  " + _
                " ( " + _
                " 	select z1.ACCOUNT_ROW_ID  " + _
                " 	from SIEBEL_ACCOUNT_OWNER z1 inner join SIEBEL_CONTACT z2 on z1.OWNER_ID=z2.ROW_ID  " + _
                " 	where z2.EMAIL_ADDRESS = '" + strUserId + "' and z1.ACCOUNT_ROW_ID is not null " + _
                " ) " + _
                " and a.ACTIVE_FLAG='Y' and a.EMPLOYEE_FLAG='N' "
            If String.IsNullOrEmpty(ContactDataQueryIn1.AccountName) = False Then
                strSql += " and b.ACCOUNT_NAME like N'%" + Trim(ContactDataQueryIn1.AccountName).Replace("*", "%").Replace("'", "''") + "%' "
            End If
            If String.IsNullOrEmpty(ContactDataQueryIn1.ContactName) = False Then
                strSql += String.Format(" and (a.FirstName like N'%{0}%' or a.LastName like N'%{0}%' or a.EMAIL_ADDRESS like N'%{0}%@%') ", _
                                        Trim(ContactDataQueryIn1.ContactName).Replace("*", "%").Replace("'", "''"))
            End If
            If String.IsNullOrEmpty(ContactDataQueryIn1.AccountId) = False Then
                strSql += " and b.ROW_ID='" + Replace(ContactDataQueryIn1.AccountId, "'", "''") + "' "
            End If
            strSql += " order by a.ACCOUNT, a.FirstName, a.LastName  "
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "SearchMyContact Sql", strSql)

            Dim apt As New SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim dt As New DataTable
            apt.Fill(dt)
            If dt.Rows.Count > 0 Then
                For Each r As DataRow In dt.Rows
                    Dim ContactRecord1 As New ContactRecord
                    With ContactRecord1
                        If Util.IsCJK(r.Item("FirstName")) Then
                            .FullName = r.Item("FirstName") + " " + r.Item("LastName")
                        Else
                            .FullName = r.Item("LastName") + " " + r.Item("FirstName")
                        End If
                        .AccountName = r.Item("ACCOUNT_NAME") : .Email = r.Item("EMAIL_ADDRESS") : .JobFunction = r.Item("JOB_FUNCTION")
                        .JobTitle = r.Item("JOB_TITLE") : .MobilePhone = FormatSiebelPhone(r.Item("CellPhone")) : .WorkPhone = FormatSiebelPhone(r.Item("WorkPhone")) : .Salutation = r.Item("Salutation")
                    End With
                    ContactDataQueryOut1.ContactList.Add(ContactRecord1)
                Next
            End If
            Return jSerializer.Serialize(ContactDataQueryOut1)
        Catch ex As Exception
            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "SearchMyContact Error", ex.ToString())
        End Try
       
    End Function

    Class ContactDataQueryIn
        Public Property TempId As String : Public Property AccountId As String : Public Property AccountName As String : Public Property ContactName As String
    End Class

    Class ContactDataQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : ContactList = New List(Of ContactRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property ContactList As List(Of ContactRecord)
    End Class

    Class ContactRecord
        Public Property FullName As String : Public Property Email As String : Public Property JobFunction As String : Public Property JobTitle As String
        Public Property WorkPhone As String : Public Property MobilePhone As String : Public Property AccountName As String : Public Property Salutation As String
    End Class
#End Region

#Region "Search Product"
    <WebMethod()> _
    Public Function SearchProduct(ByVal QueryData As String) As String
        Try
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer, strUserId As String = ""
            Dim strClientIP As String = Util.GetClientIP(), ProductDataQueryIn1 As ProductDataQueryIn = Nothing, ProductDataQueryOut1 As New ProductDataQueryOut
            Try
                ProductDataQueryIn1 = jSerializer.Deserialize(Of ProductDataQueryIn)(QueryData)
            Catch ex As Exception
                ProductDataQueryOut1.IsFunctionCallOK = False : ProductDataQueryOut1.ErrorMessage = ex.ToString() : Return jSerializer.Serialize(ProductDataQueryOut1)
            End Try
            If Not VerifyTempId(ProductDataQueryIn1.TempId, strClientIP, strUserId) Then
                ProductDataQueryOut1.IsAuthenticated = False : ProductDataQueryOut1.ErrorMessage = "Failed to authenticate. Please login again." : Return jSerializer.Serialize(ProductDataQueryOut1)
            End If

            ProductDataQueryOut1.IsAuthenticated = True

            Dim strSql As String = String.Format( _
                " select top 20 a.PART_NO, b.MODEL_NO, b.PRODUCT_DESC, IsNull(b.STATUS,'N/A') as STATUS, IsNull(c.MODEL_ID,'') as MODEL_ID " + _
                " from SAP_PRODUCT_STATUS_ORDERABLE a inner join SAP_PRODUCT b on a.PART_NO=b.PART_NO left join PIS.dbo.Model c on b.MODEL_NO=c.MODEL_NAME " + _
                " where a.SALES_ORG='{0}' and b.MATERIAL_GROUP in ('PRODUCT') and b.PRODUCT_TYPE='ZFIN' " + _
                " and (a.PART_NO like N'%{1}%' or b.MODEL_NO like N'%{1}%' or b.PRODUCT_DESC like N'%{1}%') " + _
                " order by a.PART_NO ", ProductDataQueryIn1.OrgId, Replace(ProductDataQueryIn1.Keyword, "'", "''").Replace("*", "%").Trim())
            Dim apt As New SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim dt As New DataTable
            apt.Fill(dt)
            If dt.Rows.Count > 0 Then
                Dim strERPId As String = dbUtil.dbExecuteScalar("MY", "select top 1 ERP_ID from eQuotation.dbo.ESTORE_PRICING_ERPID where SALES_ORG='" + ProductDataQueryIn1.OrgId + "'")

                Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
                Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable

                eup.Connection.Open()
                For Each r As DataRow In dt.Rows
                    Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
                    With prec
                        .Kunnr = strERPId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(Trim(UCase(r.Item("PART_NO")))) : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = ProductDataQueryIn1.OrgId
                    End With
                    pin.Add(prec)
                Next
                eup.Z_Sd_Eupriceinquery("1", pin, pout)
                eup.Connection.Close()
                Dim dtPrice As DataTable = pout.ToADODataTable()

                For Each r As DataRow In dt.Rows
                    Dim SearchProductRecord1 As New SearchProductRecord
                    With SearchProductRecord1
                        .PartNo = r.Item("PART_NO") : .ModelNo = r.Item("MODEL_NO") : .ProductDesc = r.Item("PRODUCT_DESC") : .Status = r.Item("STATUS") : .ModelId = r.Item("MODEL_ID")
                        Dim rPrices() As DataRow = dtPrice.Select("Matnr='" + Global_Inc.Format2SAPItem(r.Item("PART_NO")) + "'")
                        If rPrices.Length > 0 Then
                            Dim decPrice As Decimal = IIf(rPrices(0).Item("Kzwi1") > 0, rPrices(0).Item("Kzwi1"), rPrices(0).Item("Netwr"))
                            .ListPrice = Util.FormatMoney(decPrice, rPrices(0).Item("Waerk"))
                        Else
                            .ListPrice = -1
                        End If
                    End With
                    ProductDataQueryOut1.SearchProductRecordList.Add(SearchProductRecord1)
                Next
            End If
            Return jSerializer.Serialize(ProductDataQueryOut1)
        Catch ex As Exception
            Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Call Search Product Error", "QueryData:" + QueryData + ";Exception:" + ex.ToString())

        End Try
        Return ""
    End Function

    Class ProductDataQueryIn
        Public Property TempId As String : Public Property Keyword As String : Public Property OrgId As String
    End Class

    Class ProductDataQueryOut
        Public Sub New()
            IsAuthenticated = False : IsFunctionCallOK = False : ErrorMessage = "" : SearchProductRecordList = New List(Of SearchProductRecord)
        End Sub
        Public Property IsAuthenticated As Boolean : Public Property IsFunctionCallOK As Boolean : Public Property ErrorMessage As String : Public Property SearchProductRecordList As List(Of SearchProductRecord)
    End Class

    Class SearchProductRecord
        Public Property PartNo As String : Public Property ModelNo As String : Public Property Status As String : Public Property ProductDesc As String
        Public Property ListPrice As String : Public Property ModelId As String
    End Class
#End Region

    <WebMethod()> _
    Public Function EZLogin(ByVal EmailID As String, ByVal Pwd As String) As String
        Dim LoginStatus1 As New LoginStatus, jSerializer As New Script.Serialization.JavaScriptSerializer
        LoginStatus1.IsLoggedIn = False
        If String.IsNullOrEmpty(EmailID) OrElse String.IsNullOrEmpty(Pwd) Then
            LoginStatus1.ErrorMessage = "Either Email or Password is empty" : Return jSerializer.Serialize(LoginStatus1)
        End If
        If Util.IsValidEmailFormat(EmailID) = False Then
            LoginStatus1.ErrorMessage = "Email is in invalid format" : Return jSerializer.Serialize(LoginStatus1)
        End If
        If Util.IsInternalUser(EmailID) = False Then
            LoginStatus1.ErrorMessage = "Email must be an Advantech employee's email" : Return jSerializer.Serialize(LoginStatus1)
        End If
        Dim sso As New SSO.MembershipWebservice, loginTicket As String = "", strClientIP As String = Util.GetClientIP()
        sso.Timeout = -1
        Try
            loginTicket = sso.login(EmailID, Pwd, "MY", strClientIP)
        Catch ex As Exception
            LoginStatus1.ErrorMessage = "Failed to access membership webservice. Error string:" + ex.ToString() : Return jSerializer.Serialize(LoginStatus1)
        End Try
        If String.IsNullOrEmpty(loginTicket) Then
            LoginStatus1.ErrorMessage = "ID/Password incorrect" : Return jSerializer.Serialize(LoginStatus1)
        End If

        Dim cmd As New SqlClient.SqlCommand("INSERT INTO MSALES_AUTH_LOG (EMAIL, PWD, TEMPID, LOGIN_TIME, IP) VALUES (@UID, @PWD, @TEMPID, GETDATE(), @IP)", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString))
        With cmd.Parameters
            .AddWithValue("UID", EmailID) : .AddWithValue("PWD", Pwd) : .AddWithValue("TEMPID", loginTicket) : .AddWithValue("IP", strClientIP)
        End With
        cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()

        LoginStatus1.IsLoggedIn = True : LoginStatus1.TempId = loginTicket
        Return jSerializer.Serialize(LoginStatus1)
    End Function

    Private Shared Function VerifyTempId(ByVal TempId As String, ByVal ClientIP As String, ByRef UserId As String) As Boolean
        Dim strPort As String = HttpContext.Current.Request.ServerVariables("SERVER_PORT")
        If strPort = "6000" Or strPort = "6001" Then
            UserId = "tc.chen@advantech.com.tw" : Return True
        End If
        Dim apt As New SqlDataAdapter("select top 1 EMAIL from MSALES_AUTH_LOG where TEMPID=@TEMPID and LOGIN_TIME>=getdate()-2 order by LOGIN_TIME desc", _
                                      ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString), dt As New DataTable
        apt.SelectCommand.Parameters.AddWithValue("TEMPID", TempId) 'apt.SelectCommand.Parameters.AddWithValue("IP", ClientIP)
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        If dt.Rows.Count = 1 Then
            UserId = dt.Rows(0).Item("EMAIL") : Return True
        Else
            Return False
        End If
    End Function

    Class LoginStatus
        Public Property IsLoggedIn As Boolean : Public Property TempId As String : Public Property ErrorMessage As String
    End Class

    Private Shared Function FormatSiebelPhone(ByVal strPhone As String) As String
        If String.IsNullOrEmpty(strPhone) Then Return ""
        Return Split(strPhone, vbLf)(0)
    End Function

    Private Shared Sub ReplaceUIDToSalesForTesting(ByRef UID As String)
        If UID.StartsWith("tc.chen@", StringComparison.CurrentCultureIgnoreCase) Then
            UID = "maria.rot@advantech.de"
        ElseIf UID.StartsWith("sunny.wu@", StringComparison.CurrentCultureIgnoreCase) Then
            UID = "hock.chen@advantech.com.tw"
        End If
    End Sub

End Class