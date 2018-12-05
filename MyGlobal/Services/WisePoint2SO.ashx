<%@ WebHandler Language="VB" Class="WisePoint2SO" %>

Imports System
Imports System.Web

Public Class WisePoint2SO : Implements IHttpHandler

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim WiseOrderUtil1 As New WiseOrderUtil()
        Dim jsr As New Script.Serialization.JavaScriptSerializer()
        If Util.GetRuntimeSiteUrl().ToLower().Contains("my.advantech.com:4002") Then
            WiseOrderUtil1.IsToSAPPRD = False
        ElseIf Util.GetRuntimeSiteUrl().ToLower().Contains("my.advantech.com") And HttpContext.Current.Request.ServerVariables("SERVER_PORT") = "80" Then
            WiseOrderUtil1.IsToSAPPRD = True
        End If

        If context.Request("input") IsNot Nothing Then
            Dim strInput = context.Request("input")
            Dim Input = jsr.Deserialize(Of WiseOrderUtil.WISEPoint2OrderV2Input)(strInput)
            If Not String.IsNullOrEmpty(Input.AssetId) Then
                '20171016 TC: If SAP SO has been created for an assetid then ignore this API request (to avoid mktplace places duplicated orders)
                '20171020 TC: select from SAP directly
                'select vbeln from saprdp.vbkd where mandt='168' and vbeln='WISE002269' and posnr='000001' and bstkd='1-1E8OI2A'
                Dim SuccessOrderCount = dbUtil.dbExecuteScalar("MyLocal", String.Format(
                               " select count(ROW_ID) from WISE_PORTAL_REDEEM_RECORD_V2 where AssetId='{0}' " +
                               " and SONO like 'WISE%' and IsSuccess=1", Input.AssetId.Replace("'", "''")))
                If CInt(SuccessOrderCount) > 0 Then
                    context.Response.End()
                End If
            End If

            Dim smtpServer As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
            smtpServer.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw,frank.chung@advantech.com.tw,yl.huang@advantech.com.tw", "WS WISEPoint2OrderV2 is invoked from " + Util.GetClientIP() + ", IsToSAPPRD:" + WiseOrderUtil1.IsToSAPPRD.ToString(),
                            String.Format("Email:{0},RedeemPN:{1},AssetId:{2}, Server URL:{3}", Input.MembershipEmail, Input.RedeemPartNo, Input.AssetId, Util.GetRuntimeSiteUrl()))


            Dim result As WiseOrderUtil.ReturnResult = Nothing
            If String.IsNullOrEmpty(Input.WisePointOrderSONO) Then
                result = WiseOrderUtil1.WISEPoint2OrderV2(Input)
            Else
                result = WiseOrderUtil1.WISEPoint2OrderV3(Input)
            End If
            context.Response.Clear()
            context.Response.Write(jsr.Serialize(result))
            context.Response.End()
        ElseIf context.Request("aid") IsNot Nothing Then    ' Query SO List by Asset Id
            Dim SOList = WiseOrderUtil.GetSOByAssetId(context.Request("aid"))
            context.Response.Clear()
            context.Response.Write(jsr.Serialize(SOList))
            context.Response.End()
        ElseIf context.Request("inputV2") IsNot Nothing Then
            Dim strInput = context.Request("inputV2")
            Dim Input = jsr.Deserialize(Of WiseOrderUtil.WISEPoint2OrderEnSaaSInput)(strInput)
            Dim result As WiseOrderUtil.ReturnResult = WiseOrderUtil1.WISEPoint2OrderEnSaaS(Input)
            context.Response.Clear()
            context.Response.Write(jsr.Serialize(result))
            context.Response.End()
        End If
    End Sub

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property


End Class