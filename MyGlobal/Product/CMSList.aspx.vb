Imports Newtonsoft.Json

Partial Class Product_CMSList
    Inherits System.Web.UI.Page

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Not (Session("RBU").ToString().ToUpper() = "ACN" Or Util.IsAEUIT())) Then
            Response.Redirect("/home.aspx")
        End If
    End Sub



    Private ReadOnly Property JsonRequest() As Boolean
        Get
            Return Request.QueryString("json") = "1"
        End Get
    End Property

    Protected Overrides Sub Render(writer As HtmlTextWriter)
        If Me.JsonRequest Then
            Dim output = New CMSViewModel() With
            {
                .CMSList = Me.GetCMSList(),
                .Sort = New CMSViewModel.SortConifg() With {.NameAsc = True, .SortColumn = "NAME", .DESC = False}
            }
            Dim json = JsonConvert.SerializeObject(output)
            json = String.Format("var data = {0} ;", json)
            Response.Write(json)
        Else
            MyBase.Render(writer)
        End If
    End Sub

    Private Function GetCMSList() As DataTable
        Dim sql As String = "Select /*T.RECORD_ID,*/ T.TITLE AS NAME, /* T.ABSTRACT,*/ CONVERT(CHAR, T.RELEASE_DATE, 111) AS RELEASEDATE,  T.HYPER_LINK AS URL " &
                            "FROM (" &
                                "Select A.RECORD_ID, A.TITLE, A.ABSTRACT, A.RELEASE_DATE, A.HYPER_LINK, ROW_NUMBER() OVER (PARTITION BY A.RECORD_ID ORDER BY A.RECORD_ID) As ROW " &
                                "From CURATIONPOOL.DBO.CMSTOMYADV_RESOURCES A (NOLOCK) INNER Join CURATIONPOOL.DBO.CMSTOMYADV_RESOURCESEXT B (NOLOCK) On A.RECORD_ID= B.RECORD_ID " &
                                "Where A.CATEGORY_NAME ='Video' AND (" &
                                    "(B.TYPE='RBU' AND B.ATTRIBUTE='ABJ') OR (B.TYPE='MyAdvantech' AND B.ATTRIBUTE='PCP (PREMIER CHANNEL PARTNER)') OR (B.TYPE='LOCATION' AND B.ATTRIBUTE='MyAdvantech')" &
                                ")" &
                             ") AS T " &
                            "WHERE T.ROW=3 ORDER BY /*T.RELEASE_DATE DESC,*/ T.TITLE"

        Dim result = dbUtil.dbGetDataTable("MY", sql)

        Return result
    End Function

End Class

Public Class CMSViewModel

    Public Property Sort As SortConifg

    Public Property CMSList As DataTable

    Public Class SortConifg
        Public Property NameAsc As Boolean

        Public Property NameDesc As Boolean

        Public Property DateAsc As Boolean

        Public Property DateDesc As Boolean

        Public Property SortColumn As String

        Public Property DESC As Boolean

    End Class
End Class
