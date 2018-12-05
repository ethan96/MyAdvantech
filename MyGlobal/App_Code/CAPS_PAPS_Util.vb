Imports Microsoft.VisualBasic

Public Class CAPS_PAPS_Util
    Public Shared Function GetAdvantechPNByCAPSMPN(ByVal MPN As String) As String
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
           " select a.bmatn, a.ematn from saprdp.ztmm_46 a " + _
           " where a.mandt='168' and a.activ='X' and a.werks in ('ADK1','TWH1') " + _
           " and a.ematn = '" + Trim(MPN).ToUpper().Replace("'", "''") + "' and rownum=1 " + _
           " order by a.bmatn ")
        If dt.Rows.Count = 0 Then
            dt = OraDbUtil.dbGetDataTable("SAP_PRD", _
                                          " select a.bmatn, a.ematn from saprdp.ztmm_45 a " + _
                                          " where a.mandt='168' " + _
                                          " and a.ematn = '" + Trim(MPN).ToUpper().Replace("'", "''") + "' and rownum=1 " + _
                                          " order by a.bmatn ")

        End If

        If dt.Rows.Count > 0 Then
            Return Util.RemovePrecedingZeros(dt.Rows(0).Item("bmatn"))
        Else
            Return ""
        End If

    End Function

    Public Shared Function VerifyCAPSAdvantechPN(ByVal AdvPN As String, ByRef MPN As String) As String
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
           " select a.bmatn, a.ematn from saprdp.ztmm_46 a " + _
           " where a.mandt='168' and a.activ='X' and a.werks in ('ADK1','TWH1') " + _
           " and a.bmatn = '" + Trim(AdvPN).ToUpper().Replace("'", "''") + "' and rownum=1 " + _
           " order by a.bmatn ")
        If dt.Rows.Count = 0 Then
            dt = OraDbUtil.dbGetDataTable("SAP_PRD", _
                                          " select a.bmatn, a.ematn from saprdp.ztmm_45 a " + _
                                          " where a.mandt='168' " + _
                                          " and a.bmatn = '" + Trim(AdvPN).ToUpper().Replace("'", "''") + "' and rownum=1 " + _
                                          " order by a.bmatn ")

        End If

        If dt.Rows.Count > 0 Then
            MPN = dt.Rows(0).Item("ematn")
            Return Util.RemovePrecedingZeros(dt.Rows(0).Item("bmatn"))
        Else
            Return ""
        End If

    End Function

End Class
