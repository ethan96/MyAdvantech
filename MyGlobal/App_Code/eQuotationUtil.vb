Imports Microsoft.VisualBasic

Public Class eQuotationUtil
    Public Shared Function CurrentDC() As eQuotationDBDataContext
        Dim MyDC As New eQuotationDBDataContext
        Return MyDC
    End Function
    Public Shared Function GetQuoteMasterByQuoteid(ByVal Quoteid As String) As QuotationMaster
        If Not String.IsNullOrEmpty(Quoteid) Then
            Dim QuoteMaster As QuotationMaster = MyUtil.Current.EQContext.QuotationMasters.SingleOrDefault(Function(p) p.quoteId = Quoteid)
            If QuoteMaster IsNot Nothing Then Return QuoteMaster
        End If
        Return Nothing
    End Function
    Public Shared Function GetQuoteMasterByCompanyid(ByVal Companyid As String, ByVal keywords As String) As List(Of QuotationMaster)
        If Not String.IsNullOrEmpty(Companyid) Then
            Dim _QuotationMasterList As List(Of QuotationMaster) = (MyUtil.Current.EQContext.QuotationMasters.Where(Function(p) p.quoteToErpId = Companyid AndAlso (p.DOCSTATUS = 1 OrElse p.qstatus = "FINISH") AndAlso (p.quoteNo.Contains(keywords) OrElse p.quoteId.Contains(keywords) OrElse p.customId.Contains(keywords))).OrderByDescending(Function(p) p.createdDate)).ToList()
            If _QuotationMasterList IsNot Nothing Then Return _QuotationMasterList
        End If
        Return Nothing
    End Function
    Public Shared Function GetQuoteDetailByQuoteid(ByVal Quoteid As String) As List(Of QuotationDetail)
        If Not String.IsNullOrEmpty(Quoteid) Then
            Dim QuotationDetails As List(Of QuotationDetail) = (MyUtil.Current.EQContext.QuotationDetails.Where(Function(p) p.quoteId = Quoteid).OrderBy(Function(p) p.line_No)).ToList()
            If QuotationDetails IsNot Nothing Then Return QuotationDetails
        End If
        Return Nothing
    End Function
    Public Shared Function GetEQPartnerByQuoteid(ByVal Quoteid As String) As List(Of EQPARTNER)
        If Not String.IsNullOrEmpty(Quoteid) Then
            Dim EQPARTNERs As List(Of EQPARTNER) = (MyUtil.Current.EQContext.EQPARTNERs.Where(Function(p) p.QUOTEID = Quoteid)).ToList()
            If EQPARTNERs IsNot Nothing Then Return EQPARTNERs
        End If
        Return Nothing
    End Function
    Public Shared Function GetQuotationNoteByQuoteid(ByVal Quoteid As String) As List(Of QuotationNote)
        If Not String.IsNullOrEmpty(Quoteid) Then
            Dim QuotationNotes As List(Of QuotationNote) = (MyUtil.Current.EQContext.QuotationNotes.Where(Function(p) p.quoteid = Quoteid)).ToList()
            If QuotationNotes IsNot Nothing Then Return QuotationNotes
        End If
        Return Nothing
    End Function
    Public Shared Function GetoptyQuoteByQuoteid(ByVal Quoteid As String) As optyQuote
        If Not String.IsNullOrEmpty(Quoteid) Then
            Dim optyQuote As optyQuote = MyUtil.Current.EQContext.optyQuotes.Where(Function(p) p.quoteId = Quoteid).FirstOrDefault()
            If optyQuote IsNot Nothing Then Return optyQuote
        End If
        Return Nothing
    End Function
    Public Shared Function GetOptyidQuoteByQuoteid(ByVal Quoteid As String) As String
        Dim optyQuote As optyQuote = GetoptyQuoteByQuoteid(Quoteid)
        If optyQuote IsNot Nothing Then Return optyQuote.optyId
        Return ""
    End Function
    Public Shared Function GetExpressCompanyByQuoteid(ByVal Quoteid As String) As String
        Dim EC As Object = dbUtil.dbExecuteScalar("EQ", String.Format("select top 1 isnull(ExpressCompany,'') as ExpressCompany   from  QuotationExtension where QuoteID='{0}'", Quoteid))
        If EC IsNot Nothing AndAlso Not String.IsNullOrEmpty(EC) Then
            Return EC.ToString.Trim
        End If
        Return ""
    End Function
End Class
Partial Public Class QuotationMaster
    Public Function X_isExpired() As Boolean
        'Return False
        Dim expDate As Date = CType(Me.expiredDate, Date)
        If DateDiff(DateInterval.Day, expDate, Now()) > 0 Then
            Return True
        End If
        'Dim WS As New quote.quoteExit : WS.Timeout = -1
        'Return WS.isQuoteExpired(Me.quoteNo)
        Return False
    End Function
    Public Function Is2_0X() As Boolean
        If Me.quoteNo IsNot Nothing AndAlso String.Equals(Me.quoteNo, Me.quoteId, StringComparison.CurrentCultureIgnoreCase) Then
            Return True
        End If
        If Me.quoteNo Is Nothing AndAlso Me.quoteId.Length < 11 Then
            Return True
        End If
        Return False
    End Function
    Public ReadOnly Property QuoteNoX() As String
        Get
            If Me.quoteNo IsNot Nothing AndAlso Not String.IsNullOrEmpty(Me.quoteNo) Then
                Return Me.quoteNo
            End If
            Return Me.quoteId
        End Get
    End Property
End Class


