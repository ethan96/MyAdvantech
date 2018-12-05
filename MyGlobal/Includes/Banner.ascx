<%@ Control Language="VB" ClassName="Banner" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim url As String = Request.ServerVariables("URL").ToLower()
        Dim strRuntimeSiteUrl As String = Util.GetRuntimeSiteUrl()
        
        'Frank: If running as debug move, url will begin with /MyGlobal 
        'url = url.Replace("/myglobal", "")
        
        'Lynette' banner
        '/Images/Banner/SalesTraining_banner632x110.gif -->for AAC CP only 2012/04/12
        '/Images/Banner/TPC-71Series_Banner_632x110.gif
        '/Images/Banner/ADAM-4100_632x110.gif
        
        Select Case url
            Case "/home.aspx"
                
                divBannerRotator.InnerHtml = _
                    "<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                    "<img src='" + strRuntimeSiteUrl + "/images/banner_new.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' />"
                
            Case "/home_ez.aspx"
                divBannerRotator.InnerHtml = _
                "<a href='http://www2.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_UNO_Family_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                "<a href='http://www2.advantech.com/EDM/8EEBF4A8-A302-4813-8DAB-E7383BFFAFE1/2014_TPC-1251T_1551T_eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_TPC-1251T_1551T_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                "<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2013/ADAM-6200/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2013_ADAM-6200_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>" + _
                "<a href='" + strRuntimeSiteUrl + "/Includes/ToEIP.ashx?EIPPID='><img src='" + strRuntimeSiteUrl + "/images/banner_employee.jpg' style='border: 0px' /></a>"
                '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech-eautomation.com/emarketingprograms/sunlight/sunlightga.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/Sunlight_Readable_632x110_R.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                '"<a href='http://www.advantechdirect.com/eMarketingPrograms/TPC71H/TPC71H_MyA.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/TPC-71Series_Banner_632x110.gif' /></a>" + _
                '"<a href='http://www.advantech-eautomation.com/emarketingprograms/adam41002012/adam4100.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/ADAM-4100_632x110.gif' /></a>" + _
                '"<a href='" + strRuntimeSiteUrl + "/WebOP' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/MyAdvantech_WebOPbanner_FINAL.GIF' /></a>" + _
                '"<a href='" + strRuntimeSiteUrl + "/home.aspx'><img src='" + strRuntimeSiteUrl + "/images/HMI Series_623x110.gif' style='border-width=0px' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2011/icom-its/index_flash.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Icom_road_banner_632x110.gif' style='border: 0px' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2011/railway/index_1.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Icom_railway_banner_632x110.gif' style='border: 0px' /></a>"
                '"<a href='http://www.advantech.com/EDM/42a49801-016b-fd10-6a7f-d3cb9c7f02f8/webinar2014.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_Free_webinar_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
           
            Case "/home_ga.aspx"
                divBannerRotator.InnerHtml = _
                    "<a href='http://www2.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_UNO_Family_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www2.advantech.com/EDM/8EEBF4A8-A302-4813-8DAB-E7383BFFAFE1/2014_TPC-1251T_1551T_eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_TPC-1251T_1551T_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech-eautomation.com/emarketingprograms/sunlight/sunlightga.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/Sunlight_Readable_632x110_R.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' /></a>"
                '"<a href='http://buy.advantech.com/Single-Board-Computer/Full-size-SBC/SB_Full-size_SBC.mx.htm' target='_blank'><img id='ImgBanner1' src='/images/banner_general2.jpg' width='632' height='109' style='border-width:0px;' /></a>" + _
                '"<a href='http://www.advantech.com/eAutomation/Embedded-Automation-Computer-Video-Promotion/' target='_blank'><img src='/images/UNO_video_banner_632x109.jpg' width='632' height='109' style='border-width:0px;' /></a>" + _
                '"<a href='http://www.advantech.com.tw/VirtualTradeshow/' target='_blank'><img src='/images/banner632.jpg' width='632' height='109' style='border-width:0px;' /></a>"
            Case "/home_ka.aspx"
                divBannerRotator.InnerHtml = _
                    "<a href='http://www2.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_UNO_Family_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www2.advantech.com/EDM/8EEBF4A8-A302-4813-8DAB-E7383BFFAFE1/2014_TPC-1251T_1551T_eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_TPC-1251T_1551T_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2013/ADAM-6200/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2013_ADAM-6200_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                '"<a href='http://wiki.advantech.com/wiki/Solution_Day_Packages' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/banner_channel.jpg' Width='632' Height='111' target='_blank' /></a>"
                '"<a href='http://www.advantech.com/EDM/42a49801-016b-fd10-6a7f-d3cb9c7f02f8/webinar2014.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_Free_webinar_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                
                If Session("RBU") IsNot Nothing Then
                    If String.Compare(Session("RBU").ToString, "AAC", True) = 0 Then
                        divBannerRotator.InnerHtml = _
                            "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                            "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>" + _
                            "<a href='http://www.advantech-eautomation.com/emarketingprograms/sunlight/sunlight.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/Sunlight_Readable_632x110_R.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' /></a>"
                        '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                        '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                        '"<a href='http://www.advantechdirect.com/eMarketingPrograms/TPC71H/TPC71H_MyA.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/TPC-71Series_Banner_632x110.gif' /></a>" + _
                        '"<a href='http://www.advantech-eautomation.com/emarketingprograms/adam41002012/adam4100.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/ADAM-4100_632x110.gif' /></a>" + _
                        '"<a href='http://www.advantech.com/WebOP' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/MyAdvantech_WebOPbanner_FINAL.GIF' /></a>" + _
                        '"<a href='" + strRuntimeSiteUrl + "/home.aspx'><img src='" + strRuntimeSiteUrl + "/Images/HMI Series_623x110.gif' Width='632' Height='111' target='_blank' /></a>"
                    End If
                End If
            Case "/home_cp.aspx"
                divBannerRotator.InnerHtml = _
                    "<a href='http://www2.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_UNO_Family_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www2.advantech.com/EDM/8EEBF4A8-A302-4813-8DAB-E7383BFFAFE1/2014_TPC-1251T_1551T_eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_TPC-1251T_1551T_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2013/ADAM-6200/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2013_ADAM-6200_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                '"<a href='http://wiki.advantech.com/wiki/Solution_Day_Packages' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/banner_channel.jpg' Width='632' Height='111' target='_blank' /></a>"
                '"<a href='http://www.advantech.com/EDM/42a49801-016b-fd10-6a7f-d3cb9c7f02f8/webinar2014.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_Free_webinar_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                
                If Session("RBU") IsNot Nothing Then
                    If String.Compare(Session("RBU").ToString, "AAC", True) = 0 Then
                        divBannerRotator.InnerHtml = _
                            "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                            "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>" + _
                            "<a href='http://www.advantech-eautomation.com/emarketingprograms/sunlight/sunlight.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/Sunlight_Readable_632x110_R.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' /></a>"
                        '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                        '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                        '"<a href='http://www.advantech-eautomation.com/ChannelTraining2012/invitation.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/SalesTraining_banner632x110.gif' /></a>" + _
                        '"<a href='http://www.advantechdirect.com/eMarketingPrograms/TPC71H/TPC71H_MyA.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/TPC-71Series_Banner_632x110.gif' /></a>" + _
                        '"<a href='http://www.advantech-eautomation.com/emarketingprograms/adam41002012/adam4100.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/ADAM-4100_632x110.gif' /></a>" + _
                        '"<a href='http://www.advantech.com/WebOP' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/MyAdvantech_WebOPbanner_FINAL.GIF' /></a>" + _
                        '"<a href='" + strRuntimeSiteUrl + "/home.aspx'><img src='" + strRuntimeSiteUrl + "/Images/HMI Series_623x110.gif' Width='632' Height='111' target='_blank' /></a>"
                    End If
                End If
                'Case "/home_hqdc.aspx"
                '    divBannerRotator.InnerHtml = _
                '        "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '        "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '        "<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '        "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                '    '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                '    '"<a href='" + strRuntimeSiteUrl + "/home.aspx'><img src='" + strRuntimeSiteUrl + "/Images/HMI Series_623x110.gif' Width='632' Height='111' target='_blank' /></a>"
                '    '"<a href='http://www.advantech.com/EDM/42a49801-016b-fd10-6a7f-d3cb9c7f02f8/webinar2014.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_Free_webinar_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
            
            Case "/home_fc.aspx"
                divBannerRotator.InnerHtml = _
                    "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                '"<a href='http://www.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=2013UNOseries' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/UNOseries_Banner2_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                '"<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2012/icom_5rs/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/5rs_myadvantech_632x110.jpg' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='MyAdvantech' /></a>" + _
                '"<a href='http://wiki.advantech.com/wiki/Solution_Day_Packages' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/banner_channel.jpg' Width='632' Height='111' target='_blank' /></a>"
                '"<a href='http://www.advantech.com/EDM/42a49801-016b-fd10-6a7f-d3cb9c7f02f8/webinar2014.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_Free_webinar_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _

            Case "/home_premier.aspx"
                'ICC 2015/8/6 Premier page can get banner data
                divBannerRotator.InnerHtml = _
                    "<a href='http://www2.advantech.com/products/Embedded-Automation-Computers/sub_1-2MLCKB.aspx' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_UNO_Family_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www2.advantech.com/EDM/8EEBF4A8-A302-4813-8DAB-E7383BFFAFE1/2014_TPC-1251T_1551T_eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/201508_TPC-1251T_1551T_banner_630x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/EDM/9d7e6712-7f82-d6b0-00dd-67907ea6fad5/PCIE%20eDM/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2014_PCIE_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com.tw/ia/popcorn/eDM/2013/ADAM-6200/index.html' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/2013_ADAM-6200_banner_632x110.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.advantech.com/industrial-automation/hmi/?utm_source=MyAdvantech&utm_medium=banner&utm_campaign=HMI2013' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/HMI-Banner-630x110_FINAL.jpg' width='630' height='110' style='border: 1px solid #D7D0D0;' /></a>" + _
                    "<a href='http://www.automationworld.com/leadership/in/ashkm5u5' title='Vote Now!' target='_blank'><img src='" + strRuntimeSiteUrl + "/images/Banner/TPC-xx71_629x110-banner.gif' width='629' height='110' style='border: 1px solid #D7D0D0;' alt='Leadership in Packaging 2012: Vote Now!' title='Vote Now!' /></a>"
                
        End Select
        If Session("RBU") IsNot Nothing Then
            If String.Compare(Session("RBU").ToString, "AAC", True) = 0 Then
                If Now >= New Date(2012, 3, 5) And Now <= New Date(2012, 3, 22) Then
                    divBannerRotator.InnerHtml = "<a href='http://migotracking.advantech.com.tw/web_service/counter/wmax_event.aspx?eMarketing:eMarketing:MyAdvantech01' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/banner_w632h110.jpg' /></a>" + divBannerRotator.InnerHtml
                End If
            End If
        End If
        If Session("RBU") IsNot Nothing Then
            If String.Compare(Session("RBU").ToString, "ATW", True) = 0 Then
                If Now >= New Date(2012, 4, 3) And Now < New Date(2012, 4, 21) Then
                    divBannerRotator.InnerHtml = "<a href='http://www.advantech.com.tw/epc/newsletter/ATW/2012/20120328/' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/IPC eDM-632x110.jpg' /></a>" + divBannerRotator.InnerHtml
                End If
            End If
        End If
        If Session("RBU") IsNot Nothing Then
            If String.Compare(Session("RBU").ToString, "ABN", True) = 0 OrElse String.Compare(Session("RBU").ToString, "ADL", True) = 0 _
                OrElse String.Compare(Session("RBU").ToString, "AEE", True) = 0 OrElse String.Compare(Session("RBU").ToString, "AIT", True) = 0 _
                OrElse String.Compare(Session("RBU").ToString, "AUK", True) = 0 OrElse String.Compare(Session("RBU").ToString, "AMEA-Medical", True) = 0 _
                OrElse String.Compare(Session("RBU").ToString, "AFR", True) = 0 Then
                divBannerRotator.InnerHtml = "<a href='http://www.advantech.eu/de/edm/2012_BoxPC/index.htm' target='_blank'><img src='" + strRuntimeSiteUrl + "/Images/Banner/banner_0403.gif' /></a>" + divBannerRotator.InnerHtml
            End If
        End If
    End Sub
</script>
<script type="text/javascript" src="../EC/Includes/jquery-latest.min.js"></script>
<script type="text/javascript" src="../EC/Includes/jquery.cycle.all.latest.js"></script>
<script language="javascript" type="text/javascript">
    $(document).ready(
        function () { }
    );
</script>
<div id="divBannerRotator" runat="server" style="height:111px; position:static; text-align:center">
    
</div>

<script type="text/javascript">
    $('#<%=divBannerRotator.ClientID %>').cycle({
        fx: 'fade',
        speed: 10000
    });
</script>