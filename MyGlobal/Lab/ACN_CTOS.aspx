<%@ Page Language="VB" AutoEventWireup="false" CodeFile="ACN_CTOS.aspx.vb" Inherits="Lab_ACN_CTOS" %>

    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title></title>
        <style type="text/css">
            .margin_0_0_30_70 {
                margin: 0 0 30px 70px;
            }
             
            .margin_0_0 {
                margin: 0 0 0 0;
            }
            
            .float_left {
                float: left;
            }
            
            .w100p {
                width: 100%;
            }
            
            .w800 {
                width: 700px;
            }
            
            .center {
                text-align: center;
            }
            
            .text_left {
                text-align: left;
            }
            
            .red {
                color: red;
            }
            
            .blue {
                color: blue;
            }
            
            .bk_title {
                background-color: #33cccc;
            }
            
            .bk_gray {
                background-color: #dddddd;
            }
            
            .font_bold {
                font-weight: bold;
            }
             .font_size_xxsmall{
            font-size:xx-small;    
            }

            .font_size_xsmall {
                font-size: x-small;
            }
            
            .font_size_small{
            font-size: small;    
            }
            
            .font_size_larger {
                font-size: x-large;
            }
            
            .font_size_large {
                font-size: large;
            }
                                    
            table {
                border: 2px ridge #a0a0a0;
                border-collapse: collapse;
            }
            
            tr,
            td {
                border: 2px solid #a0a0a0;
            }
            
            thead>tr>td {
                background-color: #33cccc;
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
             <%=strHTML %>
            <%--<div align="center" class="w100p">
                <div class="w800">
                    <img src="../Images/CTOS.jpg" />
                    <span class="margin_0_0_30_70 font_size_large font_bold">Advantech(China) CTOS系统组装单</span>
                    <hr>
                    <p class="text_left font_size_xsmall">研华科技(中国)有限公司 </p>
                    <hr>
                    <table class="font_size_xsmall w100p">
                        <tr>
                            <td colspan="3">
                                SOLD TO:<span id="SOLDTO">上海琪腾计算机科技发展有限公司</span>
                            </td>
                            <td>
                                COMPANY CODE:<span id="COMPANY_CODE">C200497</span>
                            </td>
                        </tr>
                        <tr>
                            <td>SALES:
                                <span id="SALES">41140031(丁颖)</span>
                            </td>
                            <td>ORDER NO:
                                <span id="ORDER_NO">KAA52747</span>
                            </td>
                            <td>Placed By:
                                <span id="Placed_By">
                                    <a href="#">qh_lili@hotmail.com</a>
                                </span>
                            </td>
                            <td>ORDER DATE:
                                <span id="ORDER_DATE">2016/12/09</span><br />
                                <span class="red">REQUIRED DATE:</span><span class="red" id="REQUIRED_DATE">2016/12/15</span>
                            </td>
                        </tr>
                    </table>
                </div>
                <div>&nbsp;</div>
                

                <table class="w800 font_size_xsmall bk_gray">
                    <thead>
                        <tr>
                            <td align="center" class="font_size_large" colspan="6">
                                <p class="font_bold margin_0_0">CTOS Configuration for
                                    <span class="blue">SYS-4U610-BTO</span> x
                                    <span id="title_num">10</span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td style="width:5%">#</td>
                            <td style="width:35%">Category</td>
                            <td style="width:20%">Advantech No.</td>
                            <td style="width:35%">Description</td>
                            <td style="width:5%">QTY</td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>1</td>
                            <td>COM口 Cable 1 </td>
                            <td>1700002204</td>
                            <td>(Del)A Cable 2*5P-2.54 /USB-A 4P(F)*2</td>
                            <td>10</td>
                        </tr>
                        <tr>
                            <td>2</td>
                            <td>Keyboard</td>
                            <td>96KB-104P2-LT-AV</td>
                            <td>ADVANTECH 104KEY PS/2 KEYBOARD LOGO(G)</td>
                            <td>10</td>
                        </tr>
                    </tbody>
                    <tfoot>
                         <tr>
                            <td>***</td>
                            <td>Configuration File</td>
                            <td colspan="4">&nbsp;</td>
                        </tr>
                        <tr>
                            <td class="red font_size_small" colspan="6">
                                折扣总金额：&nbsp;<span id="CurrencySign"></span>&nbsp;<span id="totalprice"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="red font_size_small" colspan="6">
                                <p class="font_bold margin_0_0">请把1701092300换成1700002204 ，扩出并口 USB口,串口，操作系统是WIN7简中32位   谢谢～</p>
                            </td>
                        </tr>
                    </tfoot>
                </table>
                <p class="font_size_xxsmall">Advantech(China) Configuration & QC Inspection Sheet, Rev. A02, 03-27-00</p>
            </div>--%>
        </form>
    </body>

    </html>