Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports SAP.Connector
Imports Z_GET_ATP_LIMITQTY

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantech.SAP.DataAccessLayer")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class MYSAPDAL
    Inherits System.Web.Services.WebService

#Region "Enum Definitions"
    Public Enum EnumCompanyType
        Enum_Z001 ' Customer
        Enum_Z002 ' ShipTo
    End Enum

    Public Enum EnumIndustryCode
        Enum_1000 ' Taiwan
        Enum_2000 ' America
        Enum_3000 ' Europe
        Enum_4000 ' China
        Enum_5000 ' Asia - Others
        Enum_BRCT ' Brazil
        Enum_BRNC ' Non-Contribu.
    End Enum

    Public Enum EnumRegionWestEast
        Enum_0000000001 ' East
        Enum_0000000002 ' West
    End Enum

    Public Enum EnumCustomerClass
        Enum_01 'AXSC
        Enum_02 'RBU
        Enum_03 'External
        Enum_04 'Joint Venture
    End Enum

    Public Enum EnumCreditTerm
        Enum_NONE
        Enum_07D4
        Enum_10D1
        Enum_10D2
        Enum_10D5
        Enum_15D1
        Enum_15D2
        Enum_15D5
        Enum_30D3
        Enum_CN01
        Enum_CN02
        Enum_CN04
        Enum_CN05
        Enum_CN07
        Enum_CN10
        Enum_CN15
        Enum_COD
        Enum_CODC
        Enum_CODM
        Enum_EC30
        Enum_ECBD
        Enum_ECBO
        Enum_ECOB
        Enum_ECOO
        Enum_I001
        Enum_I007
        Enum_I010
        Enum_I014
        Enum_I015
        Enum_I021
        Enum_I028
        Enum_I030
        Enum_I035
        Enum_I045
        Enum_I060
        Enum_I070
        Enum_I075
        Enum_I090
        Enum_I120
        Enum_LC00
        Enum_M014
        Enum_M015
        Enum_M025
        Enum_M030
        Enum_M045
        Enum_M060
        Enum_M075
        Enum_M090
        Enum_M120
        Enum_M150
        Enum_M20
        Enum_M25
        Enum_M30
        Enum_MA15
        Enum_MA30
        Enum_MB60
        Enum_MC30
        Enum_MC60
        Enum_NM25
        Enum_P007
        Enum_P015
        Enum_P030
        Enum_P045
        Enum_P060
        Enum_PPD
        Enum_PPDW
        Enum_T030
        Enum_T045
        Enum_T060
        Enum_T075
        Enum_T090
        Enum_T120
        Enum_TN01
    End Enum

    Public Enum EnumIncoTerm
        Enum_AIR
        Enum_CFR
        Enum_CIF
        Enum_CIP
        Enum_CPT
        Enum_DDP
        Enum_DDU
        Enum_DHL
        Enum_EW1
        Enum_EW3
        Enum_EWS
        Enum_EXW
        Enum_FB1
        Enum_FB2
        Enum_FB4
        Enum_FB5
        Enum_FCA
        Enum_FEX
        Enum_FOB
        Enum_LEX
        Enum_MOE
        Enum_OTR
        Enum_TBD
        Enum_UPS
    End Enum

    Public Enum EnumReconciliationAccount
        Enum_0000113997
        Enum_0000121001
        Enum_0000121002
        Enum_0000121003
        Enum_0000121005
        Enum_0000121006
        Enum_0000121007
        Enum_0000121008
        Enum_0000121009
        Enum_0000123100
        Enum_0000142000
        Enum_0000148009
        Enum_0000245000
        Enum_0000248000
    End Enum

    Public Enum EnumVerticalMarket
        Enum_NONE
        Enum_080
        Enum_081
        Enum_082
        Enum_083
        Enum_084
        Enum_100
        Enum_101
        Enum_103
        Enum_104
        Enum_105
        Enum_106
        Enum_107
        Enum_108
        Enum_109
        Enum_130
        Enum_131
        Enum_132
        Enum_133
        Enum_140
        Enum_141
        Enum_142
        Enum_143
        Enum_144
        Enum_145
        Enum_146
        Enum_150
        Enum_151
        Enum_152
        Enum_153
        Enum_154
        Enum_155
        Enum_156
        Enum_157
        Enum_158
        Enum_170
        Enum_200
        Enum_201
        Enum_202
        Enum_203
        Enum_204
        Enum_221
        Enum_222
        Enum_224
        Enum_227
        Enum_260
        Enum_261
        Enum_262
        Enum_263
        Enum_265
        Enum_266
        Enum_270
        Enum_400
        Enum_401
        Enum_590
        Enum_591
        Enum_592
        Enum_593
        Enum_594
        Enum_610
        Enum_611
        Enum_612
        Enum_614
        Enum_615
        Enum_700
        Enum_710
        Enum_720
        Enum_730
        Enum_740
        Enum_750
        Enum_760
        Enum_770
        Enum_780
        Enum_790
        Enum_800
        Enum_810
        Enum_999
    End Enum

    Public Enum EnumShippingCondition
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_14
        Enum_15
        Enum_16
        Enum_17
        Enum_18
        Enum_19
        Enum_20
        Enum_22
        Enum_23
    End Enum

    Public Enum EnumPlanningGroup
        Enum_A1
        Enum_A2
        Enum_E1
        Enum_E2
        Enum_E3
        Enum_E4
        Enum_P1
        Enum_P3
        Enum_R1
        Enum_R2
        Enum_R3
    End Enum

    Public Enum EnumAccountingClerk
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_14
        Enum_15
        Enum_16
        Enum_17
        Enum_18
        Enum_19
        Enum_20
        Enum_21
        Enum_22
        Enum_23
        Enum_24
        Enum_25
        Enum_26
        Enum_27
        Enum_28
        Enum_29
        Enum_30
        Enum_31
        Enum_32
        Enum_33
        Enum_34
        Enum_35
        Enum_36
        Enum_37
        Enum_38
        Enum_39
        Enum_40
        Enum_41
        Enum_42
        Enum_43
        Enum_44
        Enum_45
        Enum_46
        Enum_47
        Enum_48
        Enum_49
        Enum_50
        Enum_51
        Enum_52
        Enum_53
        Enum_54
        Enum_55
        Enum_56
        Enum_57
        Enum_58
        Enum_59
        Enum_60
        Enum_61
        Enum_62
        Enum_63
        Enum_64
        Enum_65
        Enum_66
        Enum_67
        Enum_68
        Enum_69
        Enum_70
        Enum_71
        Enum_72
        Enum_73
        Enum_74
        Enum_75
        Enum_76
        Enum_77
        Enum_78
        Enum_79
        Enum_81
        Enum_82
        Enum_83
        Enum_84
        Enum_85
        Enum_86
        Enum_87
        Enum_88
        Enum_89
        Enum_90
        Enum_91
        Enum_93
        Enum_94
        Enum_95
        Enum_96
        Enum_97
        Enum_98
        Enum_AC
        Enum_AI
        Enum_CT
        Enum_EI
        Enum_OP
        Enum_TI
        Enum_Z1
    End Enum

    Public Enum EnumSalesDistrict
        Enum_010
        Enum_020
        Enum_030
        Enum_040
        Enum_050
        Enum_060
        Enum_070
        Enum_080
        Enum_090
        Enum_100
        Enum_110
        Enum_120
        Enum_130
        Enum_140
        Enum_150
        Enum_160
        Enum_170
        Enum_180
        Enum_190
        Enum_200
        Enum_210
        Enum_220
        Enum_230
        Enum_240
        Enum_250
        Enum_260
        Enum_270
        Enum_280
        Enum_290
        Enum_330
        Enum_D10
        Enum_D15
        Enum_D20
        Enum_D21
        Enum_D25
        Enum_D30
        Enum_D35
        Enum_D36
        Enum_D39
        Enum_D40
        Enum_D41
        Enum_D45
        Enum_D46
        Enum_D50
        Enum_D51
        Enum_D52
        Enum_D55
        Enum_D56
        Enum_D60
        Enum_D61
        Enum_D70
        Enum_D75
        Enum_D80
        Enum_D85
        Enum_D90
        Enum_D91
        Enum_D94
        Enum_D95
        Enum_D97
        Enum_D98
        Enum_DLG
        Enum_DMS
        Enum_E01
        Enum_E02
        Enum_E03
        Enum_E04
        Enum_E05
        Enum_E06
        Enum_E07
        Enum_E08
        Enum_E09
        Enum_E10
        Enum_I20
        Enum_I90
        Enum_L10
        Enum_L20
        Enum_L30
        Enum_L40
        Enum_L50
        Enum_L60
        Enum_M10
        Enum_M15
        Enum_M20
        Enum_M25
        Enum_M30
        Enum_M35
        Enum_M40
        Enum_M45
        Enum_M50
        Enum_M55
        Enum_M65
        Enum_M70
        Enum_M75
        Enum_M80
        Enum_PC0
    End Enum

    Public Enum EnumCustomerGroup
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_15
        Enum_20
        Enum_30
        Enum_B1
        Enum_D1
        Enum_K1
    End Enum

    Public Enum EnumCurrency
        Enum_AUD
        Enum_BRL
        Enum_CNY
        Enum_EUR
        Enum_GBP
        Enum_JPY
        Enum_KRW
        Enum_MYR
        Enum_SGD
        Enum_THB
        Enum_TWD
        Enum_USD
    End Enum

    Public Enum EnumOrgId
        Enum_AU01
        Enum_BR01
        Enum_CN01
        Enum_CN02
        Enum_CN10
        Enum_CN11
        Enum_CN12
        Enum_CN13
        Enum_CN20
        Enum_CN30
        Enum_CN40
        Enum_EU10
        Enum_EU33
        Enum_EU34
        Enum_EU50
        Enum_HK05
        Enum_JP01
        Enum_KR01
        Enum_MY01
        Enum_SG01
        Enum_TL01
        Enum_TW01
        Enum_TW02
        Enum_TW03
        Enum_TW04
        Enum_TW05
        Enum_TWCP
        Enum_US01
    End Enum

    Public Enum EnumCountryCode
        Enum_AE
        Enum_AL
        Enum_AM
        Enum_AN
        Enum_AO
        Enum_AR
        Enum_AT
        Enum_AU
        Enum_AZ
        Enum_BA
        Enum_BD
        Enum_BE
        Enum_BF
        Enum_BG
        Enum_BH
        Enum_BM
        Enum_BN
        Enum_BO
        Enum_BR
        Enum_BS
        Enum_BW
        Enum_BY
        Enum_BZ
        Enum_CA
        Enum_CH
        Enum_CL
        Enum_CN
        Enum_CO
        Enum_CR
        Enum_CY
        Enum_CZ
        Enum_DE
        Enum_DK
        Enum_DM
        Enum_DO
        Enum_DZ
        Enum_EC
        Enum_EE
        Enum_EG
        Enum_ES
        Enum_FI
        Enum_FJ
        Enum_FK
        Enum_FR
        Enum_GB
        Enum_GD
        Enum_GE
        Enum_GL
        Enum_GR
        Enum_GT
        Enum_HK
        Enum_HN
        Enum_HR
        Enum_HU
        Enum_ID
        Enum_IE
        Enum_IL
        Enum_IN
        Enum_IQ
        Enum_IR
        Enum_IS
        Enum_IT
        Enum_JM
        Enum_JO
        Enum_JP
        Enum_KE
        Enum_KG
        Enum_KH
        Enum_KR
        Enum_KW
        Enum_KY
        Enum_KZ
        Enum_LA
        Enum_LB
        Enum_LI
        Enum_LK
        Enum_LT
        Enum_LU
        Enum_LV
        Enum_LY
        Enum_MA
        Enum_MC
        Enum_MD
        Enum_MF
        Enum_MG
        Enum_MK
        Enum_MM
        Enum_MN
        Enum_MO
        Enum_MR
        Enum_MT
        Enum_MU
        Enum_MV
        Enum_MW
        Enum_MX
        Enum_MY
        Enum_NA
        Enum_NC
        Enum_NE
        Enum_NG
        Enum_NI
        Enum_NL
        Enum_NO
        Enum_NP
        Enum_NZ
        Enum_OM
        Enum_PA
        Enum_PE
        Enum_PH
        Enum_PK
        Enum_PL
        Enum_PR
        Enum_PT
        Enum_PY
        Enum_QA
        Enum_RO
        Enum_RS
        Enum_RU
        Enum_SA
        Enum_SB
        Enum_SE
        Enum_SG
        Enum_SI
        Enum_SK
        Enum_SL
        Enum_SV
        Enum_SY
        Enum_SZ
        Enum_TF
        Enum_TH
        Enum_TJ
        Enum_TN
        Enum_TR
        Enum_TT
        Enum_TW
        Enum_UA
        Enum_UG
        Enum_US
        Enum_UY
        Enum_UZ
        Enum_VA
        Enum_VE
        Enum_VG
        Enum_VI
        Enum_VN
        Enum_YU
        Enum_ZA
        Enum_ZM
        Enum_ZW
    End Enum
#End Region

#Region "Create SAP Data"
    Public Shared Function CreateSAPCustomer() As Boolean
        Dim p1 As New ZSD_CUSTOMER_MAINTAIN_ALL.ZSD_CUSTOMER_MAINTAIN_ALL
        p1.Connection = New SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim I_Bapiaddr1 As New ZSD_CUSTOMER_MAINTAIN_ALL.BAPIADDR1
        Dim I_Bapiaddr2 As New ZSD_CUSTOMER_MAINTAIN_ALL.BAPIADDR2
        Dim I_Customer_Is_Consumer As String = ""
        Dim I_Force_External_Number_Range As String = ""
        Dim I_From_Customermaster As String = ""
        Dim I_Kna1 As New ZSD_CUSTOMER_MAINTAIN_ALL.KNA1
        Dim I_Knb1 As New ZSD_CUSTOMER_MAINTAIN_ALL.KNB1
        Dim I_Knb1_Reference As String = ""
        Dim I_Knvv As New ZSD_CUSTOMER_MAINTAIN_ALL.KNVV
        Dim I_Maintain_Address_By_Kna1 As String = ""
        Dim I_No_Bank_Master_Update As String = ""
        Dim I_Raise_No_Bte As String = ""
        Dim Pi_Add_On_Data As New ZSD_CUSTOMER_MAINTAIN_ALL.CUST_ADD_ON_DATA
        Dim Pi_Cam_Changed As String = ""
        Dim Pi_Postflag As String = ""
        ''Return Arguments
        Dim E_Kunnr As String = ""
        Dim E_Sd_Cust_1321_Done As String = ""
        Dim O_Kna1 As New ZSD_CUSTOMER_MAINTAIN_ALL.KNA1
        Dim T_Upd_Txt As New ZSD_CUSTOMER_MAINTAIN_ALL.FKUNTXTTable
        Dim T_Xkn As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNASTable
        Dim T_Xknb5 As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNB5Table
        Dim T_Xknbk As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNBKTable
        Dim T_Xknex As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNEXTable
        Dim T_Xknva As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVATable
        Dim T_Xknvd As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVDTable
        Dim T_Xknvi As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVITable
        Dim T_Xknvk As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVKTable
        Dim T_Xknvl As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVLTable
        Dim T_Xknvp As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVPTable
        Dim T_Xknza As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNZATable
        Dim T_Ykn As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNASTable
        Dim T_Yknb5 As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNB5Table
        Dim T_Yknbk As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNBKTable
        Dim T_Yknex As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNEXTable
        Dim T_Yknva As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVATable
        Dim T_Yknvd As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVDTable
        Dim T_Yknvi As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVITable
        Dim T_Yknvk As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVKTable
        Dim T_Yknvl As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVLTable
        Dim T_Yknvp As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNVPTable
        Dim T_Yknza As New ZSD_CUSTOMER_MAINTAIN_ALL.FKNZATable
        'Assignment 
        With I_Bapiaddr1
            .Addr_No = ""
            .City = ""
        End With
        With I_Bapiaddr2
            .Addr_No = ""
        End With
        I_Customer_Is_Consumer = ""
        I_Force_External_Number_Range = "1"
        I_From_Customermaster = "1"
        With I_Kna1
            .Mandt = "168"
            .Kunnr = "EFFRFA05"
            .Land1 = "FR"
            .Name1 = "FACTORY SYSTEMES SAS"
            .Name2 = " "
            .Ort01 = "MARNE LA VALLEE CEDE"
            .Pstlz = "77437"
            .Regio = " "
            .Sortl = "FR89423785"
            .Stras = "22 RUE VLADIMIR JANKELEVITCH"
            .Telf1 = "0033 164616868"
            .Telfx = "0033 164616734"
            .Xcpdk = " "
            .Adrnr = "0000090780"
            .Mcod1 = "FACTORY SYSTEMES SAS"
            .Mcod2 = " "
            .Mcod3 = "MARNE LA VALLEE CEDE"
            .Anred = "Company"
            .Aufsd = " "
            .Bahne = " "
            .Bahns = " "
            .Bbbnr = "0000000"
            .Bbsnr = "00000"
            .Begru = " "
            .Brsch = "3000"
            .Bubkz = "0"
            .Datlt = " "
            .Erdat = "20051206"
            .Ernam = "AMBER.TSENG"
            .Exabl = " "
            .Faksd = " "
            .Fiskn = " "
            .Knazk = " "
            .Knrza = " "
            .Konzs = " "
            .Ktokd = "Z001"
            .Kukla = "03"
            .Lifnr = " "
            .Lifsd = " "
            .Locco = " "
            .Loevm = " "
            .Name3 = " "
            .Name4 = " "
            .Niels = " "
            .Ort02 = " "
            .Pfach = " "
            .Pstl2 = " "
            .Counc = " "
            .Cityc = " "
            .Rpmkr = " "
            .Sperr = " "
            .Spras = "E"
            .Stcd1 = " "
            .Stcd2 = " "
            .Stkza = " "
            .Stkzu = " "
            .Telbx = " "
            .Telf2 = " "
            .Teltx = " "
            .Telx1 = " "
            .Lzone = "0000000001"
            .Xzemp = " "
            .Vbund = " "
            .Stceg = "FR89423785492"
            .Dear1 = " "
            .Dear2 = " "
            .Dear3 = " "
            .Dear4 = " "
            .Dear5 = " "
            .Gform = " "
            .Bran1 = " "
            .Bran2 = " "
            .Bran3 = " "
            .Bran4 = " "
            .Bran5 = " "
            .Ekont = " "
            .Umsat = "0"
            .Umjah = "0000"
            .Uwaer = " "
            .Jmzah = "000000"
            .Jmjah = "0000"
            .Katr1 = " "
            .Katr2 = " "
            .Katr3 = "04"
            .Katr4 = " "
            .Katr5 = " "
            .Katr6 = " "
            .Katr7 = "620"
            .Katr8 = " "
            .Katr9 = " "
            .Katr10 = " "
            .Stkzn = " "
            .Umsa1 = "0"
            .Txjcd = " "
            .Periv = " "
            .Abrvw = " "
            .Inspbydebi = " "
            .Inspatdebi = " "
            .Ktocd = " "
            .Pfort = " "
            .Werks = " "
            .Dtams = " "
            .Dtaws = " "
            .Duefl = "X"
            .Hzuor = "00"
            .Sperz = " "
            .Etikg = " "
            .Civve = "X"
            .Milve = " "
            .Kdkg1 = "A5"
            .Kdkg2 = "E5"
            .Kdkg3 = "A6"
            .Kdkg4 = "A6"
            .Kdkg5 = "R2"
            .Xknza = " "
            .Fityp = " "
            .Stcdt = " "
            .Stcd3 = " "
            .Stcd4 = " "
            .Xicms = " "
            .Xxipi = " "
            .Xsubt = " "
            .Cfopc = " "
            .Txlw1 = " "
            .Txlw2 = " "
            .Ccc01 = " "
            .Ccc02 = " "
            .Ccc03 = " "
            .Ccc04 = " "
            .Cassd = " "
            .Knurl = " "
            .J_1kfrepre = " "
            .J_1kftbus = " "
            .J_1kftind = " "
            .Confs = " "
            .Updat = "00000000"
            .Uptim = "000000"
            .Nodel = " "
            .Dear6 = " "
            .Alc = " "
            .Pmt_Office = " "
            .Psofg = " "
            .Psois = " "
            .Pson1 = " "
            .Pson2 = " "
            .Pson3 = " "
            .Psovn = " "
            .Psotl = " "
            .Psohs = " "
            .Psost = " "
            .Psoo1 = " "
            .Psoo2 = " "
            .Psoo3 = " "
            .Psoo4 = " "
            .Psoo5 = " "

        End With
        With I_Knb1
            .Mandt = "168"
            .Kunnr = "EFFRFA05"
            .Bukrs = "EU10"
            .Pernr = "00000000"
            .Erdat = "20051207"
            .Ernam = "TED.TSAO"
            .Sperr = " "
            .Loevm = " "
            .Zuawa = "001"
            .Busab = "EI"
            .Akont = "0000121007"
            .Begru = " "
            .Knrze = " "
            .Knrzb = " "
            .Zamim = " "
            .Zamiv = " "
            .Zamir = " "
            .Zamib = " "
            .Zamio = " "
            .Zwels = " "
            .Xverr = " "
            .Zahls = " "
            .Zterm = "M030"
            .Wakon = " "
            .Vzskz = " "
            .Zindt = "00000000"
            .Zinrt = "00"
            .Eikto = " "
            .Zsabe = " "
            .Kverm = " "
            .Fdgrv = "R2"
            .Vrbkz = " "
            .Vlibb = "400000"
            .Vrszl = "0"
            .Vrspr = "0"
            .Vrsnr = "7818005"
            .Verdt = "00000000"
            .Perkz = " "
            .Xdezv = " "
            .Xausz = " "
            .Webtr = "0"
            .Remit = " "
            .Datlz = "00000000"
            .Xzver = "X"
            .Togru = " "
            .Kultg = "0"
            .Hbkid = " "
            .Xpore = " "
            .Blnkz = " "
            .Altkn = " "
            .Zgrup = " "
            .Urlid = " "
            .Mgrup = "01"
            .Lockb = " "
            .Uzawe = " "
            .Ekvbd = " "
            .Sregl = " "
            .Xedip = " "
            .Frgrp = " "
            .Vrsdg = " "
            .Tlfxs = " "
            .Intad = " "
            .Xknzb = " "
            .Guzte = " "
            .Gricd = " "
            .Gridt = " "
            .Wbrsl = " "
            .Confs = " "
            .Updat = "00000000"
            .Uptim = "000000"
            .Nodel = " "
            .Tlfns = " "
            .Cession_Kz = " "
            .Gmvkzd = " "
        End With
        I_Knb1_Reference = ""
        With I_Knvv
            .Mandt = "168"
            .Kunnr = "EFFRFA05"
            .Vkorg = "EU10"
            .Vtweg = "00"
            .Spart = "00"
            .Ernam = "AMBER.TSENG"
            .Erdat = "20051206"
            .Begru = " "
            .Loevm = " "
            .Versg = " "
            .Aufsd = " "
            .Kalks = "1"
            .Kdgrp = "02"
            .Bzirk = "E04"
            .Konda = "00"
            .Pltyp = "00"
            .Awahr = "100"
            .Inco1 = "EWS"
            .Inco2 = " "
            .Lifsd = " "
            .Autlf = " "
            .Antlf = "9"
            .Kztlf = " "
            .Kzazu = "X"
            .Chspl = " "
            .Lprio = "02"
            .Eikto = " "
            .Vsbed = "15"
            .Faksd = " "
            .Mrnkz = " "
            .Perfk = " "
            .Perrl = " "
            .Kvakz = " "
            .Kvawt = "0"
            .Waers = "EUR"
            .Klabc = " "
            .Ktgrd = "02"
            .Zterm = "M030"
            .Vwerk = "EUH1"
            .Vkgrp = "321"
            .Vkbur = "3200"
            .Vsort = " "
            .Kvgr1 = " "
            .Kvgr2 = " "
            .Kvgr3 = "D4"
            .Kvgr4 = " "
            .Kvgr5 = " "
            .Bokre = " "
            .Boidt = "00000000"
            .Kurst = " "
            .Prfre = " "
            .Prat1 = " "
            .Prat2 = " "
            .Prat3 = " "
            .Prat4 = " "
            .Prat5 = " "
            .Prat6 = " "
            .Prat7 = " "
            .Prat8 = " "
            .Prat9 = " "
            .Prata = " "
            .Kabss = " "
            .Kkber = " "
            .Cassd = " "
            .Rdoff = " "
            .Agrel = " "
            .Megru = " "
            .Uebto = "0"
            .Untto = "0"
            .Uebtk = " "
            .Pvksm = " "
            .Podkz = " "
            .Podtg = "0"
            .Blind = " "
            .Bev1_Emlgforts = " "
            .Bev1_Emlgpfand = " "
        End With
        I_Maintain_Address_By_Kna1 = ""
        I_No_Bank_Master_Update = ""
        I_Raise_No_Bte = ""
        With Pi_Add_On_Data
            '  .Kunnr = "EFFRFA05"
        End With
        Pi_Cam_Changed = ""
        Pi_Postflag = ""
        '
        p1.Zsd_Customer_Maintain_All(I_Bapiaddr1, I_Bapiaddr2, I_Customer_Is_Consumer, _
                               I_Force_External_Number_Range, I_From_Customermaster, _
                               I_Kna1, I_Knb1, I_Knb1_Reference, I_Knvv, I_Maintain_Address_By_Kna1, _
                               I_No_Bank_Master_Update, I_Raise_No_Bte, _
                               Pi_Add_On_Data, Pi_Cam_Changed, Pi_Postflag, _
                               E_Kunnr, E_Sd_Cust_1321_Done, O_Kna1, T_Upd_Txt, _
                               T_Xkn, T_Xknb5, T_Xknbk, T_Xknex, T_Xknva, T_Xknvd, T_Xknvi, _
                               T_Xknvk, T_Xknvl, T_Xknvp, T_Xknza, T_Ykn, T_Yknb5, T_Yknbk, T_Yknex, T_Yknva, _
                               T_Yknvd, T_Yknvi, T_Yknvk, T_Yknvl, T_Yknvp, T_Yknza)
        p1.CommitWork()
        Return True
    End Function
    Public Shared Function IsCreatePO(ByVal CompanyID As String) As Boolean
        Dim POcompanys As String() = {"AJPADV", "ADVAJP", "ADVAVN", "AALP003", "ASPA001", "EDEA002", "EWGD002", "T27957723"}
        If POcompanys.Contains(CompanyID) Then
            Return True
        End If
        Return False
    End Function
    Public Shared Sub CreatePo(ByVal orderno As String, ByVal pono As String, ByRef result As String, ByRef retCode As Boolean, Optional ByVal IsRecover As Boolean = False)
        retCode = False
        Dim po_Po_Number As String = ""
        Dim po_Comp_Code As String = ""
        Dim po_Doc_Type As String = ""
        Dim po_Purch_Org As String = ""
        Dim po_Purch_Group As String = ""
        Dim po_Vendor_ID As String = ""
        Dim po_Plant As String = ""
        Dim po_Preq_Name As String = ""
        Dim po_Costcenter As String = ""
        Dim po_Shipto As String = ""
        Dim ordid As String = ""
        Dim po_Currency As String = "USD"
        Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(orderno)
        If ordermasterDT.Rows.Count > 0 Then
            Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
            With ordermasterDR
                po_Po_Number = orderno
                'If Not .IsPO_NONull AndAlso Not .PO_NO.Trim = "" Then
                '    po_Po_Number = .PO_NO.Trim
                'Else
                '    po_Po_Number = orderno
                'End If
                po_Shipto = .SHIPTO_ID
                ordid = .ORDER_ID
            End With
        End If

        po_Doc_Type = "PO"

        'response.write("po_Shipto: " & po_Shipto)
        Select Case po_Shipto
            '20160324 TC: New RBU code for AJP has been changed to ADVAJP, so when this ID place BTOS SO to ACL, auto create a PO for AJP
            Case "AJPADV", "ADVAJP"
                po_Comp_Code = "JP01"
                po_Purch_Org = "JP01"
                po_Purch_Group = "J01"
                po_Vendor_ID = "ADVACL"
                po_Plant = "JPH1"
                po_Preq_Name = orderno ' "AJP PO"
                '20161116 TC:
                'Liling 's request:
                'ACL CTOS組装費用P / N: AGS-CTOS - SYS - B　AJP設定的cost center 是JP01_COGS1.
                '請問可以改為JP01_COGS1嗎？現状是下完PO後, OP得自己手動去修正, 容易漏掉…  謝謝.
                po_Costcenter = "JP01_COGS1"
                po_Currency = "JPY"

            Case "ADVAVN"
                'Ryan 20180625 AVN launch
                po_Comp_Code = "VN01"
                po_Purch_Org = "VN01"
                po_Purch_Group = "VN2"
                po_Vendor_ID = "ADVACL"
                po_Plant = "VNH1"
                po_Preq_Name = orderno
                po_Costcenter = "VN1300"
                po_Currency = "USD"

            Case "AALP003"
                po_Comp_Code = "AU01"
                po_Purch_Org = "AU01"
                po_Purch_Group = "J01"
                po_Vendor_ID = "AACL"
                po_Plant = "AUH1"
                po_Preq_Name = orderno ' "AAU PO"
                po_Costcenter = "A6230"
            Case "ASPA001"
                po_Comp_Code = "SG01"
                po_Purch_Org = "SG01"
                po_Purch_Group = "SC1"
                po_Vendor_ID = "S9ACL"
                po_Plant = "SGH1"
                po_Preq_Name = orderno '"ASG PO"
                po_Costcenter = "S7000"
            Case "EDEA002"
                po_Comp_Code = "EU80"
                po_Purch_Org = "EU80"
                po_Purch_Group = "DL2"
                po_Vendor_ID = "DLV103055"
                po_Plant = "DLM1"
                po_Preq_Name = orderno
                po_Costcenter = "DLCOFGK"
                po_Currency = "EUR"
            Case "EWGD002"
                po_Comp_Code = "EU80"
                po_Purch_Org = "EU80"
                po_Purch_Group = "DL2"
                'Frank 20160314 update new vendor id
                'po_Vendor_ID = "DLV102839"
                po_Vendor_ID = "ADVACL"
                po_Plant = "DLM1"
                po_Preq_Name = orderno
                po_Costcenter = "DLCOFGK"
                po_Currency = "EUR"
            Case "T27957723"
                po_Comp_Code = "TW09"
                po_Purch_Org = "TW09"
                po_Purch_Group = "AP4"
                po_Vendor_ID = "T05155853"
                po_Plant = "APH1"
                po_Preq_Name = orderno
                po_Costcenter = "T96200"
                po_Currency = "USD"
        End Select
        Dim myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim dt As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", orderno), "line_No")
        If dt.Rows.Count() <= 0 Then
            result = "No such order"
            retCode = False
            Exit Sub
        End If

        Dim PoHead As New SAPDAL.PO_Head
        PoHead.Po_Number = po_Po_Number
        PoHead.Comp_Code = po_Comp_Code
        PoHead.Currency = po_Currency
        PoHead.Doc_Type = po_Doc_Type
        PoHead.Purch_Org = po_Purch_Org
        PoHead.Purch_Group = po_Purch_Group
        PoHead.Vendor_ID = po_Vendor_ID
        PoHead.IsTesting = 0
        'Ming 如果是测试环境就不呼叫CommitWork事件
        If Util.IsTesting() Then PoHead.IsTesting = 1
        Dim POitems As New List(Of SAPDAL.PO_Item)
        Dim i As Integer
        Dim BtosParentDeliveryDate As DateTime = Now
        For i = 0 To dt.Rows.Count() - 1
            Dim item As New SAPDAL.PO_Item
            item.Po_Item = dt.Rows(i).Item("LINE_NO").ToString()
            item.Material = dt.Rows(i).Item("PART_NO").ToString()
            If IsNumericItem(item.Material) Then
                item.Material = SAPDAL.Global_Inc.FormatToSAPPartNo(item.Material)
            End If
            item.EMaterial = dt.Rows(i).Item("PART_NO").ToString()
            If IsNumericItem(item.EMaterial) Then
                item.EMaterial = SAPDAL.Global_Inc.FormatToSAPPartNo(item.EMaterial)
            End If


            item.Plant = po_Plant
            item.Storage_Location = "1000"
            item.Item_Qty = dt.Rows(i).Item("QTY").ToString()
            item.Net_Price = dt.Rows(i).Item("UNIT_PRICE").ToString()
            item.Preq_Name = po_Preq_Name

            ' Dim BtosParentDeliveryDate As DateTime = FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy") ' Now
            If dt.Rows(i).Item("ORDER_LINE_TYPE") IsNot Nothing AndAlso String.Equals(dt.Rows(i).Item("ORDER_LINE_TYPE").ToString.Trim, "-1") Then
                BtosParentDeliveryDate = FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy")
            End If

            'Frank 20160329
            'item.Delivery_Date = BtosParentDeliveryDate 'FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy")
            item.Delivery_Date = BtosParentDeliveryDate.ToString("yyyyMMdd")

            ' 专为ADLOG 设置的TaxCode,Storage_Location，其它companyid 不需要
            Select Case po_Shipto
                Case "EDEA002"
                    item.Tax_Code = "V6"
                    item.Storage_Location = "1100"
                Case "EWGD002"
                    item.Tax_Code = "V9"
                    item.Storage_Location = "1100"
                Case "T27957723"
                    item.Tax_Code = "V1"
                    item.Storage_Location = "0005"
            End Select

            ' 以下部分是来设置Btos Parent的相关参数
            If item.Material.ToUpper() = "OPTION100" Or item.Material.ToUpper() = "OPTION100I" Then
                item.Matl_Group = "EXPENSE23"
                item.Acctasscat = "K"
                item.Short_Text = "CTOS Assembly Fee"
                item.Gl_Account = "0000651615"
                item.Costcenter = po_Costcenter
                item.Co_Area = "SA00"
                item.Serial_No = "01"
            ElseIf item.Material.ToUpper() = "PTRADE-BTO" Then
                item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
            ElseIf InStr(item.Material.ToUpper(), "BTO") > 0 Then
                item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
                ' end
            Else
                '以下部分是来设置Btos chidren的相关参数，服务料号，延保料等规则
                Dim tempTB As DataTable = dbUtil.dbGetDataTable("MY", "select product_type from SAP_PRODUCT where part_no = '" & dt.Rows(i).Item("PART_NO").ToString() & "'")
                If tempTB.Rows.Count <= 0 Then
                    result = "No such part_no " & item.Material & ""
                    retCode = False
                    Exit Sub
                End If
                If tempTB.Rows(0).Item("PRODUCT_TYPE").ToString().ToUpper().Trim() = "ZCTO" Then
                    item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
                ElseIf tempTB.Rows(0).Item("PRODUCT_TYPE").ToString().ToUpper().Trim() = "ZSRV" Then
                    item.Matl_Group = "EXPENSE23"
                    item.Acctasscat = "K"
                    item.Short_Text = item.Material ' "CTOS Assembly Fee"
                    item.Gl_Account = "0000651615"
                    item.Costcenter = po_Costcenter
                    item.Co_Area = "SA00"   '  "EU00" "US00"  "BR00"
                    Select Case po_Shipto
                        Case "EDEA002"
                            item.Co_Area = "EU00"
                            item.Tax_Code = "V7"
                        Case "EWGD002"
                            item.Co_Area = "EU00"
                        Case "T27957723"
                            item.Gl_Account = "0000651606"
                            item.Matl_Group = "EXPENSE23"
                    End Select
                    item.Serial_No = "01"
                End If
            End If

            POitems.Add(item)
        Next
        pono = po_Po_Number
        'retCode = True
        SAPDAL.SAPDAL.CreatePo(PoHead, POitems, result, retCode)
        If Not IsRecover Then MYSAPDAL.PO_SendMail(orderno, pono, result, retCode)
    End Sub
    Public Shared Sub CreatePoForCermate(ByVal orderno As String, ByVal pono As String, ByRef result As String, ByRef retCode As Boolean, Optional ByVal IsRecover As Boolean = False)
        Dim sb As New StringBuilder
        sb.AppendFormat("select  [ID] ,[ORDER_ID],[LINE_NO],[PRODUCT_LINE],[PART_NO],[ORDER_LINE_TYPE],[QTY],[LIST_PRICE],[UNIT_PRICE],[REQUIRED_DATE],[DUE_DATE],[ERP_SITE],[ERP_LOCATION],[AUTO_ORDER_FLAG],[AUTO_ORDER_QTY],[SUPPLIER_DUE_DATE],[LINE_PARTIAL_FLAG],[RoHS_FLAG],[EXWARRANTY_FLAG],[CustMaterialNo],[DeliveryPlant],[NoATPFlag],[DMF_Flag],[OptyID],[Cate],[Description],[HigherLevel],[itp] from ORDER_DETAIL  where ORDER_ID='{0}' ", orderno)
        sb.Append(" and PART_NO in (select  PART_NO  from  sap_product  where PRODUCT_LINE='CWOP') ")
        sb.Append(" order by LINE_NO ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        If dt.Rows.Count() <= 0 Then
            result = "No Cermate's partnos"
            retCode = False
            Exit Sub
        End If
        retCode = False
        Dim po_Po_Number As String = ""
        Dim po_Comp_Code As String = ""
        Dim po_Doc_Type As String = ""
        Dim po_Purch_Org As String = ""
        Dim po_Purch_Group As String = ""
        Dim po_Vendor_ID As String = ""
        Dim po_Plant As String = ""
        Dim po_Preq_Name As String = ""
        Dim po_Costcenter As String = ""
        Dim po_Shipto As String = ""
        Dim ordid As String = ""
        Dim po_Currency As String = "USD"
        Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(orderno)
        If ordermasterDT.Rows.Count > 0 Then
            Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
            With ordermasterDR
                po_Po_Number = orderno
                po_Shipto = .SHIPTO_ID
                ordid = .ORDER_ID
            End With
        End If

        po_Doc_Type = "PO"
        po_Comp_Code = "JP01"
        po_Purch_Org = "JP01"
        po_Purch_Group = "J01"
        po_Vendor_ID = "ADVACL"
        po_Plant = "JPH1"
        po_Preq_Name = orderno ' "AJP PO"
        '20161116 TC
        'ACL CTOS組装費用P / N: AGS-CTOS - SYS - B　AJP設定的cost center 是JP01_ADM_G.
        '請問可以改為JP01_COGS1嗎？現状是下完PO後, OP得自己手動去修正, 容易漏掉…  謝謝.
        po_Costcenter = "JP01_COGS1"
        po_Currency = "JPY"

        Dim PoHead As New SAPDAL.PO_Head
        PoHead.Po_Number = po_Po_Number
        PoHead.Comp_Code = po_Comp_Code
        PoHead.Currency = po_Currency
        PoHead.Doc_Type = po_Doc_Type
        PoHead.Purch_Org = po_Purch_Org
        PoHead.Purch_Group = po_Purch_Group
        PoHead.Vendor_ID = po_Vendor_ID
        PoHead.IsTesting = 0
        'Ming 如果是测试环境就不呼叫CommitWork事件
        If Util.IsTesting() Then PoHead.IsTesting = 1
        Dim POitems As New List(Of SAPDAL.PO_Item)
        Dim i As Integer
        Dim BtosParentDeliveryDate As DateTime = Now
        For i = 0 To dt.Rows.Count() - 1
            Dim item As New SAPDAL.PO_Item
            item.Po_Item = dt.Rows(i).Item("LINE_NO").ToString()
            item.Material = dt.Rows(i).Item("PART_NO").ToString()
            If IsNumericItem(item.Material) Then
                item.Material = SAPDAL.Global_Inc.FormatToSAPPartNo(item.Material)
            End If
            item.EMaterial = dt.Rows(i).Item("PART_NO").ToString()
            If IsNumericItem(item.EMaterial) Then
                item.EMaterial = SAPDAL.Global_Inc.FormatToSAPPartNo(item.EMaterial)
            End If


            item.Plant = po_Plant
            item.Storage_Location = "1000"
            item.Item_Qty = dt.Rows(i).Item("QTY").ToString()
            item.Net_Price = dt.Rows(i).Item("UNIT_PRICE").ToString()
            item.Preq_Name = po_Preq_Name

            ' Dim BtosParentDeliveryDate As DateTime = FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy") ' Now
            If dt.Rows(i).Item("ORDER_LINE_TYPE") IsNot Nothing AndAlso String.Equals(dt.Rows(i).Item("ORDER_LINE_TYPE").ToString.Trim, "-1") Then
                BtosParentDeliveryDate = FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy")
            End If
            item.Delivery_Date = BtosParentDeliveryDate 'FormatDate(dt.Rows(i).Item("DUE_DATE").ToString(), "mm/dd/yy")
            ' 专为ADLOG 设置的TaxCode,Storage_Location，其它companyid 不需要
            Select Case po_Shipto
                Case "EDEA002"
                    item.Tax_Code = "V6"
                    item.Storage_Location = "1100"
                Case "EWGD002"
                    item.Tax_Code = "V9"
                    item.Storage_Location = "1100"
                Case "T27957723"
                    item.Tax_Code = "V1"
                    item.Storage_Location = "0005"
            End Select

            ' 以下部分是来设置Btos Parent的相关参数
            If item.Material.ToUpper() = "OPTION100" Or item.Material.ToUpper() = "OPTION100I" Then
                item.Matl_Group = "EXPENSE23"
                item.Acctasscat = "K"
                item.Short_Text = "CTOS Assembly Fee"
                item.Gl_Account = "0000651615"
                item.Costcenter = po_Costcenter
                item.Co_Area = "SA00"
                item.Serial_No = "01"
            ElseIf item.Material.ToUpper() = "PTRADE-BTO" Then
                item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
            ElseIf InStr(item.Material.ToUpper(), "BTO") > 0 Then
                item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
                ' end
            Else
                '以下部分是来设置Btos chidren的相关参数，服务料号，延保料等规则
                Dim tempTB As DataTable = dbUtil.dbGetDataTable("MY", "select product_type from SAP_PRODUCT where part_no = '" & dt.Rows(i).Item("PART_NO").ToString() & "'")
                If tempTB.Rows.Count <= 0 Then
                    result = "No such part_no " & item.Material & ""
                    retCode = False
                    Exit Sub
                End If
                If tempTB.Rows(0).Item("PRODUCT_TYPE").ToString().ToUpper().Trim() = "ZCTO" Then
                    item.Free_Item = "X" : If po_Shipto = "EDEA002" Then item.Tax_Code = "V7"
                ElseIf tempTB.Rows(0).Item("PRODUCT_TYPE").ToString().ToUpper().Trim() = "ZSRV" Then
                    item.Matl_Group = "EXPENSE23"
                    item.Acctasscat = "K"
                    item.Short_Text = item.Material ' "CTOS Assembly Fee"
                    item.Gl_Account = "0000651615"
                    item.Costcenter = po_Costcenter
                    item.Co_Area = "SA00"   '  "EU00" "US00"  "BR00"
                    Select Case po_Shipto
                        Case "EDEA002"
                            item.Co_Area = "EU00"
                            item.Tax_Code = "V7"
                        Case "EWGD002"
                            item.Co_Area = "EU00"
                        Case "T27957723"
                            item.Gl_Account = "0000651606"
                            item.Matl_Group = "EXPENSE23"
                    End Select
                    item.Serial_No = "01"
                End If
            End If

            POitems.Add(item)
        Next
        pono = po_Po_Number
        'retCode = True
        SAPDAL.SAPDAL.CreatePo(PoHead, POitems, result, retCode)
        If Not IsRecover Then MYSAPDAL.PO_SendMail(orderno, pono, result, retCode)
    End Sub
    Public Shared Sub CreatePo_Sap(ByVal ordno As String, ByVal pono As String, ByRef retXml As String, ByRef retValue As Boolean)
        Dim xml As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 PO_XML from ORDER_PO where ORDER_NO='{0}' and PO_NO='{1}'", ordno, pono))
        If xml IsNot Nothing Then
            Dim ws As New b2b_ws.B2B_AJP_WS
            ws.Timeout = 99999999
            ws.CreatePo(xml.ToString, retXml, retValue)
        End If

    End Sub

    Public Shared Sub PO_SendMail(ByVal order_no As String, ByVal po_no As String, ByVal retXml As String, ByVal result As Boolean)

        Dim strStyle As String = ""
        Dim strBody As String = ""
        Dim t_strHTML As String = ""

        Dim FROM_Email As String = ""
        Dim TO_Email As String = ""
        Dim CC_Email As String = ""
        Dim BCC_Email As String = "myadvantech@advantech.com"
        Dim Subject_Email As String = ""
        Dim AttachFile As String = ""
        Dim MailBody As String = ""
        Dim strCompanyId As String = ""

        FROM_Email = "MyAdvantech@advantech.com"
        Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(order_no)
        If ordermasterDT.Rows.Count > 0 Then
            Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
            With ordermasterDR
                TO_Email = .CREATED_BY
                If Util.IsTesting() Then
                    TO_Email = "myadvantech@advantech.com"
                End If
                strCompanyId = .SOLDTO_ID
            End With
        End If

        Dim strCompanyName As String = dbUtil.dbExecuteScalar("MY", "select company_name from SAP_DIMCOMPANY where company_id ='" & strCompanyId & "'")
        Subject_Email = "Advantech PO Process Status(" & po_no & "/" & order_no & ") for " & strCompanyName & " (" & strCompanyId & ")"


        '--Mail Style  
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        '--Mail Style
        '--Mail Body	
        Dim testMsg As String = String.Empty
        If Util.IsTesting() Then testMsg = " Test by Ming"
        strBody = strBody & "<html><body><center>"
        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td colspan=""3"">"
        strBody = strBody & "&nbsp;<font size=5 color=""#000000""><b>PO Process Message " + testMsg + "</b></font>&nbsp;&nbsp;&nbsp;&nbsp;" & "<br><br>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"


        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff"">"
        strBody = strBody & "&nbsp;<b>Message</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">"
        strBody = strBody & "&nbsp;<b>PO Process Massages(<font color=""green"">" & po_no & "/" & order_no & "</font>)</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td>"
        strBody = strBody & "<table width=""731"" bgcolor=""#DCDCDC"" style=""border:#CFCFCF 1px solid"" class=""text"" cellspacing=""0"" cellpadding=""0"">"

        Dim order_status As Boolean = True

        If result = False Then

            order_status = False

            If retXml <> "" Then
                strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & retXml
                strBody = strBody & "</font></td></tr>"
            Else
                strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & "Call SAP function error!!"
                strBody = strBody & "</font></td></tr>"
            End If
        Else

            Dim sr As New System.IO.StringReader(retXml)
            Dim ds As New DataSet
            ds.ReadXml(sr)
            Dim DT As New DataTable
            DT = ds.Tables("BAPIRET2Table")

            Dim i As Integer = 0
            While i <= DT.Rows.Count - 1

                If DT.Rows(i).Item("Type") = "E" Then
                    order_status = False
                End If

                If DT.Rows(i).Item("Type") <> "W" Then

                    strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                    strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & DT.Rows(i).Item("Message")
                    strBody = strBody & "</font></td></tr>"

                End If
                i = i + 1
            End While

        End If

        If order_status = False Then
            strBody = strBody & "<tr><td height=""5"" bgcolor=""#ffffff"">"
            strBody = strBody & "&nbsp;"
            strBody = strBody & "</td></tr>"
            strBody = strBody & "<tr><td height=""5"" align=""center"" bgcolor=""#ffffff""><font size=3><i><u>"
            strBody = strBody & "<a href=""http://" & HttpContext.Current.Request.ServerVariables("HTTP_HOST") & "/order/PO_Recovery.aspx?Order_No=" & order_no & """><i><b><font size=4 color=""red"">Press Link To Recover This Order</font></b></i></a>"
            strBody = strBody & "</u></i></font></td></tr>"
        End If


        strBody = strBody & "</table>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"
        strBody = strBody & "</body></html>"

        t_strHTML = Replace(strBody, "<body>", "<body>" & strStyle)
        '--Mail Body

        MailBody = t_strHTML

        MailUtil.SendEmail(TO_Email, FROM_Email, Subject_Email, MailBody, True, CC_Email, BCC_Email)
        'MailUtil.SendEmail("rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw", FROM_Email, Subject_Email, MailBody, True, "", "")
    End Sub
#End Region

#Region "PRICING"

    <WebMethod()> _
    Public Function GetListPrice(ByVal SAPOrg As String, ByVal SiebelOrg As String, ByVal Currency As String, _
                                 ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                 ByRef ErrorMessage As String) As Boolean
        Dim strERPID As String = "", strOrgId As String = Trim(UCase(SAPOrg))
        Currency = Trim(UCase(Currency))
        Select Case Left(strOrgId, 2)
            Case "AU"
                strERPID = "AAU105" : strOrgId = "AU01"
                'Case "BR"
                '    strERPID = ""
            Case "CN"
                strERPID = "C100001" : strOrgId = "CN10"
            Case "EU"
                strERPID = "EDATEV01" : strOrgId = "EU10"
                'Case "HK"
                '    strERPID = ""
            Case "JP"
                strERPID = "JJCBOM" : strOrgId = "JP01"
            Case "KR"
                strERPID = "AKRC00485" : strOrgId = "KR01"
                'Case "MY"
                '    strERPID = ""
            Case "SG"
                strERPID = "SSAONLINE" : strOrgId = "SG01"
                'Case "TL"
                '    strERPID = ""
            Case "TW"
                strERPID = "2NC00001" : strOrgId = "TW01"
            Case "US"
                strERPID = "UEPP5001" : strOrgId = "US01"
            Case Else
                ErrorMessage = "Org " + SAPOrg + " is not yet defined in WS GetListPrice" : Return False
        End Select
        ProductOut = New SAPDALDS.ProductOutDataTable
        Dim tmpProdOut As New SAPDALDS.ProductOutDataTable
        If strOrgId = "EU10" And (Currency = "USD" Or Currency = "EUR" Or Currency = "GBP") Then
            Dim eQConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString), cmd As SqlClient.SqlCommand = Nothing
            eQConn.Open()
            For Each pinRec As SAPDALDS.ProductInRow In ProductIn.Rows
                'cmd = New SqlClient.SqlCommand( _
                '     "select top 1 LIST_PRICE from eQuotation.dbo.PRODUCT_LIST_PRICE " + _
                '    " where ORG='EU10' and PART_NO=@PN and CURRENCY=@CUR and LIST_PRICE>0", eQConn)
                cmd = New SqlClient.SqlCommand( _
                     "select top 1 LIST_PRICE from PRODUCT_LIST_PRICE " + _
                    " where ORG='EU10' and PART_NO=@PN and CURRENCY=@CUR and LIST_PRICE>0", eQConn)
                cmd.Parameters.AddWithValue("PN", pinRec.PART_NO) : cmd.Parameters.AddWithValue("CUR", pinRec.PART_NO)
                Dim tmpLP As Object = cmd.ExecuteScalar()
                If tmpLP IsNot Nothing AndAlso Double.TryParse(tmpLP, 0) Then
                    tmpProdOut.AddProductOutRow(pinRec.PART_NO, tmpLP.ToString(), tmpLP.ToString(), "0", "0")
                End If
            Next
            eQConn.Close()
        End If
        For Each poutRec As SAPDALDS.ProductOutRow In tmpProdOut.Rows
            Dim InRs() = ProductIn.Select("PART_NO='" + poutRec.PART_NO + "'")
            For Each inR As SAPDALDS.ProductInRow In InRs
                inR.Delete()
            Next
        Next
        If ProductIn.Rows.Count > 0 Then
            If GetPrice(strERPID, strERPID, strOrgId, ProductIn, ProductOut, ErrorMessage) Then
                ProductOut.Merge(tmpProdOut)
                Return True
            Else
                Return False
            End If
        End If
    End Function

    <WebMethod()> _
    Public Function GetPriceV2(ByVal SoldToId As String, ByVal ShipToId As String, ByVal Org As String, ByVal DocOrderType As SAPOrderType, _
                             ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                             ByRef ErrorMessage As String) As Boolean
        Dim PipeLinePIn As New SAPDALDS.ProductInDataTable
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Contains("|") Then
                Dim strProds() As String = Split(OriPInRec.PART_NO, "|")
                If strProds.Length > 1 Then
                    OriPInRec.PART_NO = strProds(0)
                    For i As Integer = 1 To strProds.Length - 1
                        PipeLinePIn.AddProductInRow(strProds(i), OriPInRec.QTY)
                    Next
                End If
            End If
        Next
        For Each pipePInRec As SAPDALDS.ProductInRow In PipeLinePIn.Rows
            ProductIn.AddProductInRow(pipePInRec.PART_NO, pipePInRec.QTY)
        Next
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Equals(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then
                OriPInRec.Delete()
            End If
        Next
        Try
            ErrorMessage = ""
            SoldToId = UCase(Trim(SoldToId)) : Org = Trim(UCase(Org))
            If String.IsNullOrEmpty(ShipToId) Then ShipToId = SoldToId
            Dim strDistChann As String = "10", strDivision As String = "00"
            If Org = "US01" Then
                Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format( _
                                                          "select COUNT(COMPANY_ID) from SAP_DIMCOMPANY " + _
                                                          " where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", SoldToId))
                If N > 0 Then
                    strDistChann = "10" : strDivision = "20"
                Else
                    strDistChann = "30" : strDivision = "10"
                End If
            End If
            For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
                PInRow.PART_NO = PInRow.PART_NO.ToUpper()
            Next
            If True Then
                Return GetMultiPrice_eStoreV2(Org, SoldToId, ShipToId, strDistChann, strDivision, DocOrderType, ProductIn, ProductOut, ErrorMessage)
            Else
                Dim eup As New Get_Price.Get_Price
                Dim pin As New Get_Price.ZSSD_01Table, pout As New Get_Price.ZSSD_02Table
                For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
                    Dim prec As New Get_Price.ZSSD_01
                    With prec
                        .Kunnr = SoldToId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(PInRow.PART_NO) : .Mglme = 1 : .Vkorg = Org
                        ' .Prsdt = Now.Date.ToString("yyyyMMdd")
                    End With
                    pin.Add(prec)
                Next
                eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                eup.Connection.Open()
                Try
                    eup.Z_Ebizaeu_Priceinquiry(strDistChann, strDivision, SoldToId, Org, SoldToId, New Get_Price.BAPIRETURN, pin, pout)
                Catch ex As Exception
                    ErrorMessage = "Call Z_Ebizaeu_Priceinquiry error:" + ex.ToString()
                    eup.Connection.Close() : Return False
                End Try
                eup.Connection.Close()
                For Each x As Get_Price.ZSSD_02 In pout
                    If x.Kzwi1 < x.Netwr Then
                        x.Kzwi1 = x.Netwr
                    End If
                Next
                Dim retTable As DataTable = pout.ToADODataTable()
                ProductOut = New SAPDALDS.ProductOutDataTable
                For Each retRec As DataRow In retTable.Rows
                    'pout.Item(0).Matnr : pout.Item(0).Netwr : pout.Item(0).Kzwi1
                    Dim ProductOutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                    ProductOutRec.PART_NO = Global_Inc.RemoveZeroString(retRec.Item("Matnr"))
                    ProductOutRec.LIST_PRICE = retRec.Item("Kzwi1")
                    ProductOutRec.UNIT_PRICE = retRec.Item("Netwr")
                    ProductOut.AddProductOutRow(ProductOutRec)
                Next
                Return True
            End If
        Catch ex As Exception
            ErrorMessage += ".Runtime exception:" + ex.ToString()
            MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "MYSAPDAL WS GetPrice error", ex.ToString(), False, "", "")
            Return False
        End Try
    End Function

    ''' <summary>
    ''' 20150429 TC: This V4 function will call GetMultiPrice_eStoreV3 which contains US recycling fee
    ''' </summary>
    ''' <param name="SoldToId"></param>
    ''' <param name="ShipToId"></param>
    ''' <param name="Org"></param>
    ''' <param name="DocOrderType"></param>
    ''' <param name="ProductIn"></param>
    ''' <param name="ProductOut"></param>
    ''' <param name="ErrorMessage"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    <WebMethod()> _
    Public Function GetPriceV4(ByVal SoldToId As String, ByVal ShipToId As String, ByVal Org As String, ByVal DocOrderType As SAPOrderType, _
                             ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                             ByRef ErrorMessage As String) As Boolean
        Dim PipeLinePIn As New SAPDALDS.ProductInDataTable
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Contains("|") Then
                Dim strProds() As String = Split(OriPInRec.PART_NO, "|")
                If strProds.Length > 1 Then
                    OriPInRec.PART_NO = strProds(0)
                    For i As Integer = 1 To strProds.Length - 1
                        PipeLinePIn.AddProductInRow(strProds(i), OriPInRec.QTY)
                    Next
                End If
            End If
        Next
        For Each pipePInRec As SAPDALDS.ProductInRow In PipeLinePIn.Rows
            ProductIn.AddProductInRow(pipePInRec.PART_NO, pipePInRec.QTY)
        Next
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Equals(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then
                OriPInRec.Delete()
            End If
        Next
        Try
            ErrorMessage = ""
            SoldToId = UCase(Trim(SoldToId)) : Org = Trim(UCase(Org))
            If String.IsNullOrEmpty(ShipToId) Then ShipToId = SoldToId
            Dim strDistChann As String = "10", strDivision As String = "00"
            If Org = "US01" Then
                Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format( _
                                                          "select COUNT(COMPANY_ID) from SAP_DIMCOMPANY " + _
                                                          " where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", SoldToId))
                If N > 0 Then
                    strDistChann = "10" : strDivision = "20"
                Else
                    strDistChann = "30" : strDivision = "10"
                End If
            End If
            For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
                PInRow.PART_NO = PInRow.PART_NO.ToUpper()
            Next

            Return GetMultiPrice_eStoreV3(Org, SoldToId, ShipToId, strDistChann, strDivision, DocOrderType, ProductIn, ProductOut, ErrorMessage)

           
        Catch ex As Exception
            ErrorMessage += ".Runtime exception:" + ex.ToString()
            MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "MYSAPDAL WS GetPrice error", ex.ToString(), False, "", "")
            Return False
        End Try
    End Function


    <WebMethod()> _
    Public Function GetPrice(ByVal SoldToId As String, ByVal ShipToId As String, ByVal Org As String, _
                             ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                             ByRef ErrorMessage As String) As Boolean
        Dim PipeLinePIn As New SAPDALDS.ProductInDataTable
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Contains("|") Then
                Dim strProds() As String = Split(OriPInRec.PART_NO, "|")
                If strProds.Length > 1 Then
                    OriPInRec.PART_NO = strProds(0)
                    For i As Integer = 1 To strProds.Length - 1
                        PipeLinePIn.AddProductInRow(strProds(i), OriPInRec.QTY)
                    Next
                End If
            End If
        Next
        For Each pipePInRec As SAPDALDS.ProductInRow In PipeLinePIn.Rows
            ProductIn.AddProductInRow(pipePInRec.PART_NO, pipePInRec.QTY)
        Next
        For Each OriPInRec As SAPDALDS.ProductInRow In ProductIn.Rows
            If OriPInRec.PART_NO.Equals(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then
                OriPInRec.Delete()
            End If
        Next
        Try
            ErrorMessage = ""
            SoldToId = UCase(Trim(SoldToId)) : Org = Trim(UCase(Org))
            If String.IsNullOrEmpty(ShipToId) Then ShipToId = SoldToId
            Dim strDistChann As String = "10", strDivision As String = "00"
            If Org = "US01" Then
                Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format( _
                                                          "select COUNT(COMPANY_ID) from SAP_DIMCOMPANY " + _
                                                          " where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", SoldToId))
                If N > 0 Then
                    strDistChann = "10" : strDivision = "20"
                Else
                    strDistChann = "30" : strDivision = "10"
                End If
            End If
            For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
                PInRow.PART_NO = PInRow.PART_NO.ToUpper()
            Next
            If True Then
                Return GetMultiPrice_eStore(Org, SoldToId, ShipToId, strDistChann, strDivision, ProductIn, ProductOut, ErrorMessage)
            Else
                Dim eup As New Get_Price.Get_Price
                Dim pin As New Get_Price.ZSSD_01Table, pout As New Get_Price.ZSSD_02Table
                For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
                    Dim prec As New Get_Price.ZSSD_01
                    With prec
                        .Kunnr = SoldToId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(PInRow.PART_NO) : .Mglme = 1 : .Vkorg = Org
                        ' .Prsdt = Now.Date.ToString("yyyyMMdd")
                    End With
                    pin.Add(prec)
                Next
                eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                eup.Connection.Open()
                Try
                    eup.Z_Ebizaeu_Priceinquiry(strDistChann, strDivision, SoldToId, Org, SoldToId, New Get_Price.BAPIRETURN, pin, pout)
                Catch ex As Exception
                    ErrorMessage = "Call Z_Ebizaeu_Priceinquiry error:" + ex.ToString()
                    eup.Connection.Close() : Return False
                End Try
                eup.Connection.Close()
                For Each x As Get_Price.ZSSD_02 In pout
                    If x.Kzwi1 < x.Netwr Then
                        x.Kzwi1 = x.Netwr
                    End If
                Next
                Dim retTable As DataTable = pout.ToADODataTable()
                ProductOut = New SAPDALDS.ProductOutDataTable
                For Each retRec As DataRow In retTable.Rows
                    'pout.Item(0).Matnr : pout.Item(0).Netwr : pout.Item(0).Kzwi1
                    Dim ProductOutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                    ProductOutRec.PART_NO = Global_Inc.RemoveZeroString(retRec.Item("Matnr"))
                    ProductOutRec.LIST_PRICE = retRec.Item("Kzwi1")
                    ProductOutRec.UNIT_PRICE = retRec.Item("Netwr")
                    ProductOut.AddProductOutRow(ProductOutRec)
                Next
                Return True
            End If
        Catch ex As Exception
            ErrorMessage += ".Runtime exception:" + ex.ToString()
            MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "MYSAPDAL WS GetPrice error", ex.ToString(), False, "", "")
            Return False
        End Try
    End Function
    <WebMethod()> _
    Public Function GetPriceV3(ByVal SoldToId As String, ByVal ShipToId As String, ByVal Org As String, _
                             ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                             ByRef ErrorMessage As String) As Boolean
        Try
            Dim sapdal As New SAPDAL.SAPDAL
            Dim _ProductIn As New SAPDAL.SAPDALDS.ProductInDataTable : Dim _ProductOut As New SAPDAL.SAPDALDS.ProductOutDataTable

            For Each r As SAPDALDS.ProductInRow In ProductIn.Rows
                Dim _PIr As SAPDAL.SAPDALDS.ProductInRow = _ProductIn.NewProductInRow()
                _PIr.PART_NO = r.PART_NO
                _PIr.QTY = r.QTY
                _PIr.PLANT = ""
                _ProductIn.AddProductInRow(_PIr)
            Next
            Dim Currency As String = String.Empty
            sapdal.GetPrice(SoldToId, ShipToId, Org, Currency, "", _ProductIn, _ProductOut, ErrorMessage)
            For Each r As SAPDAL.SAPDALDS.ProductOutRow In _ProductOut.Rows
                Dim _POr As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                _POr.PART_NO = r.PART_NO
                _POr.LIST_PRICE = r.LIST_PRICE
                _POr.UNIT_PRICE = r.UNIT_PRICE
                _POr.RECYCLE_FEE = r.RECYCLE_FEE
                _POr.TAX = r.TAX
                ProductOut.AddProductOutRow(_POr)
            Next
            Return True
        Catch ex As Exception
            ErrorMessage += ".Runtime exception:" + ex.ToString()
            MailUtil.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", "MYSAPDAL WS GetPriceV3 error", ex.ToString(), False, "", "")
            Return False
        End Try
    End Function
    Private Shared Function GetMultiPrice_eStoreV2(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                          ByVal strDivision As String, ByVal OrderDocType As SAPOrderType, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                          ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                          ByRef ErrorMessage As String) As Boolean
        'Util.SendEmail("nada.liu@advantech.com.cn", "myadvanteh@advantech.com", "test price", "AAAA", True, "", "")
        ErrorMessage = ""
        Dim HasPhaseOutItem As Boolean = False
        Dim phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAPConnTest")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = OrderDocType.ToString() : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            'If Org = "BR01" Then .Doc_Type = "ZORB"
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in ('A','N','H','O','M1') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()



            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = retAdoDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()

            ProductOut = New SAPDALDS.ProductOutDataTable
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim poutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material"))
                poutRec.LIST_PRICE = 0 : poutRec.RECYCLE_FEE = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            poutRec.LIST_PRICE = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            poutRec.RECYCLE_FEE = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If Global_Inc.IsNumericItem(PIn.Item("Material")) Then
                    If poutRec.LIST_PRICE <= 0 AndAlso POutRs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(POutRs(0).Item("net_value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If POutRs.Length > 0 Then
                    poutRec.TAX = FormatNumber(POutRs(0).Item("Tx_Doc_Cur") / POutRs(0).Item("req_qty"), 2)
                    poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    If Org = "BR01" Then

                        'If Util.IsTesting Then
                        '    'ICC 2016/6/6 Add net value and tax value into list price
                        '    poutRec.LIST_PRICE = poutRec.UNIT_PRICE
                        '    Dim listprice As Decimal = 0
                        '    Dim tax As Decimal = 0
                        '    If Decimal.TryParse(poutRec.TAX, tax) = True AndAlso Decimal.TryParse(poutRec.UNIT_PRICE, listprice) = True Then
                        '        poutRec.LIST_PRICE = (listprice + tax).ToString
                        '    End If
                        'Else
                        '    Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                        '    If cond_rs.Length > 0 Then
                        '        poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        '    End If
                        'End If
                        'poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)

                        'ICC 22016/6/15 Rollback to original logic.
                        Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                        If cond_rs.Length > 0 Then
                            poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        End If
                    End If
                End If
                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.RECYCLE_FEE = 0 : pout.UNIT_PRICE = 0
                ProductOut.AddProductOutRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If HasPhaseOutItem Then
            Return GetEUPrice(Org, SoldToId, ShipToId, strDistChann, strDivision, ProductIn, ProductOut, ErrorMessage)
        End If
        For Each pOutRow As SAPDALDS.ProductOutRow In ProductOut.Rows
            If IsNumeric(pOutRow.LIST_PRICE) AndAlso IsNumeric(pOutRow.UNIT_PRICE) AndAlso CDbl(pOutRow.LIST_PRICE) < CDbl(pOutRow.UNIT_PRICE) Then
                pOutRow.LIST_PRICE = pOutRow.UNIT_PRICE
            End If
        Next
        ProductOut.AcceptChanges()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function

    'This V3 function is called by GetPriceV4 which will be provided to Mike Liu for testing getting US recycling fee
    Private Shared Function GetMultiPrice_eStoreV3(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                          ByVal strDivision As String, ByVal OrderDocType As SAPOrderType, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                          ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                          ByRef ErrorMessage As String) As Boolean
        'Util.SendEmail("nada.liu@advantech.com.cn", "myadvanteh@advantech.com", "test price", "AAAA", True, "", "")
        ErrorMessage = ""
        Dim HasPhaseOutItem As Boolean = False
        Dim phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAPConnTest")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = OrderDocType.ToString() : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            'If Org = "BR01" Then .Doc_Type = "ZORB"
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in ('A','N','H','O','M1') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()



            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = retAdoDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()

            ProductOut = New SAPDALDS.ProductOutDataTable
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim poutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material"))
                poutRec.LIST_PRICE = 0 : poutRec.RECYCLE_FEE = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            poutRec.LIST_PRICE = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            poutRec.RECYCLE_FEE = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next

                '20150429 TC: If recycle fee is greater than zero than use it to deduct from list price, and thus list price is purly list price without recycling fee
                If poutRec.RECYCLE_FEE > 0 Then
                    poutRec.LIST_PRICE = poutRec.LIST_PRICE - poutRec.RECYCLE_FEE
                    If poutRec.LIST_PRICE < 0 Then poutRec.LIST_PRICE = 0
                End If

                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If Global_Inc.IsNumericItem(PIn.Item("Material")) Then
                    If poutRec.LIST_PRICE <= 0 AndAlso POutRs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(POutRs(0).Item("net_value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If POutRs.Length > 0 Then
                    poutRec.TAX = FormatNumber(POutRs(0).Item("Tx_Doc_Cur") / POutRs(0).Item("req_qty"), 2)
                    poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    If Org = "BR01" Then
                        Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                        If cond_rs.Length > 0 Then
                            poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        End If
                        'poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.RECYCLE_FEE = 0 : pout.UNIT_PRICE = 0
                ProductOut.AddProductOutRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If HasPhaseOutItem Then
            Return GetEUPriceV2(Org, SoldToId, ShipToId, strDistChann, strDivision, ProductIn, ProductOut, ErrorMessage)
        End If
        For Each pOutRow As SAPDALDS.ProductOutRow In ProductOut.Rows
            If IsNumeric(pOutRow.LIST_PRICE) AndAlso IsNumeric(pOutRow.UNIT_PRICE) AndAlso CDbl(pOutRow.LIST_PRICE) < CDbl(pOutRow.UNIT_PRICE) Then
                pOutRow.LIST_PRICE = pOutRow.UNIT_PRICE
            End If
        Next
        ProductOut.AcceptChanges()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function


    Public Shared Function GetMultiPrice_eStore_PricingDate(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                         ByVal strDivision As String, ByVal OrderDocType As SAPOrderType, ByVal PricingDate As Date, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                         ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                         ByRef ErrorMessage As String) As Boolean
        'Util.SendEmail("nada.liu@advantech.com.cn", "myadvanteh@advantech.com", "test price", "AAAA", True, "", "")
        ErrorMessage = ""
        Dim HasPhaseOutItem As Boolean = False
        Dim phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAPConnTest")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = OrderDocType.ToString() : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            .Price_Date = PricingDate.ToString("yyyyMMdd")
            'If Org = "BR01" Then .Doc_Type = "ZORB"
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in ('A','N','H','O','M1') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()



            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = retAdoDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()

            ProductOut = New SAPDALDS.ProductOutDataTable
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim poutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material"))
                poutRec.LIST_PRICE = 0 : poutRec.RECYCLE_FEE = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            poutRec.LIST_PRICE = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            poutRec.RECYCLE_FEE = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If Global_Inc.IsNumericItem(PIn.Item("Material")) Then
                    If poutRec.LIST_PRICE <= 0 AndAlso POutRs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(POutRs(0).Item("net_value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If POutRs.Length > 0 Then
                    poutRec.TAX = FormatNumber(POutRs(0).Item("Tx_Doc_Cur") / POutRs(0).Item("req_qty"), 2)
                    poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    If Org = "BR01" Then
                        Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                        If cond_rs.Length > 0 Then
                            poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        End If
                        'poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.RECYCLE_FEE = 0 : pout.UNIT_PRICE = 0
                ProductOut.AddProductOutRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If HasPhaseOutItem Then
            Return GetEUPrice(Org, SoldToId, ShipToId, strDistChann, strDivision, ProductIn, ProductOut, ErrorMessage)
        End If
        For Each pOutRow As SAPDALDS.ProductOutRow In ProductOut.Rows
            If IsNumeric(pOutRow.LIST_PRICE) AndAlso IsNumeric(pOutRow.UNIT_PRICE) AndAlso CDbl(pOutRow.LIST_PRICE) < CDbl(pOutRow.UNIT_PRICE) Then
                pOutRow.LIST_PRICE = pOutRow.UNIT_PRICE
            End If
        Next
        ProductOut.AcceptChanges()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function
    <Obsolete()>
    Protected Shared Function GetMultiPrice_eStore(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                          ByVal strDivision As String, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                          ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                          ByRef ErrorMessage As String) As Boolean
        'Util.SendEmail("nada.liu@advantech.com.cn", "myadvanteh@advantech.com", "test price", "AAAA", True, "", "")
        If SoldToId = "CKM4" Then Return False
        ErrorMessage = ""
        Dim HasPhaseOutItem As Boolean = False
        Dim phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAPConnTest")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable

        Dim _epricer_exch_rate_EURtoUSD As Decimal = 1
        If SoldToId.Equals("AAEA010", StringComparison.InvariantCultureIgnoreCase) Then
            'Currency = "USD"
            Dim _Year As Integer = Date.Now.Year
            Dim _Quarter As Integer = Math.Ceiling(DateTime.Today.Month / 3)

            Dim _exch_rate_sql As String = String.Empty
            _exch_rate_sql &= " SELECT [Year],[Quarter],[Currency_Origin],[Currency_Target],[ExchangeRate],[Modified_User],[Modified_Time] "
            _exch_rate_sql &= " FROM ExchangeRate_Pricing "
            _exch_rate_sql &= " WHERE Year = " & _Year & " AND Quarter = " & _Quarter & " AND Currency_Origin = 'EUR' AND Currency_Target = 'USD' "
            _exch_rate_sql &= " Order by Year Desc,Quarter Desc "
            Dim _exch_rate_dt As DataTable = Nothing
            Try
                _exch_rate_dt = dbUtil.dbGetDataTable("ACLSQL7", _exch_rate_sql)
            Catch ex As Exception
            End Try
            If _exch_rate_dt IsNot Nothing AndAlso _exch_rate_dt.Rows.Count > 0 Then
                _epricer_exch_rate_EURtoUSD = _exch_rate_dt.Rows(0).Item("ExchangeRate")
            End If
        End If


        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            If Org = "BR01" Then .Doc_Type = "ZORB"
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus").ToString + " and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000

                    'Ryan 20180718 Temporary add for TW20 per Tina's suggestion
                    If Org = "TW20" Then
                        item.Plant = "ASH1"
                    End If

                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Dim isZPN0MT As Boolean = False
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()



            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = retAdoDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()

            ProductOut = New SAPDALDS.ProductOutDataTable
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim poutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material"))
                poutRec.LIST_PRICE = 0 : poutRec.RECYCLE_FEE = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            If Org.ToUpper.StartsWith("CN") AndAlso r.Item("Cond_Type").ToString().ToUpper().Equals("ZPN0") Then
                                Continue For
                            End If
                            If Double.TryParse(poutRec.LIST_PRICE, 0) AndAlso Double.TryParse(r.Item("Cond_Value"), 0) Then
                                If r.Item("Cond_Value") > poutRec.LIST_PRICE Then
                                    poutRec.LIST_PRICE = FormatNumber(r.Item("Cond_Value"), 2)
                                    isZPN0MT = True
                                End If
                            End If
                        Case "ZHB0"
                            poutRec.RECYCLE_FEE = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If Global_Inc.IsNumericItem(PIn.Item("Material")) Then
                    If poutRec.LIST_PRICE <= 0 AndAlso POutRs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(POutRs(0).Item("net_value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If POutRs.Length > 0 Then
                    poutRec.TAX = FormatNumber(POutRs(0).Item("Tx_Doc_Cur") / POutRs(0).Item("req_qty"), 2)
                    poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    'Frank 20170323
                    'CN's sales and customer only check the price which includes tax(17%)
                    If Org.StartsWith("CN", StringComparison.InvariantCultureIgnoreCase) Then
                        poutRec.UNIT_PRICE = Decimal.Round(poutRec.UNIT_PRICE * (1 + ConfigurationManager.AppSettings("ACNTaxRate")), 2, MidpointRounding.AwayFromZero)
                        poutRec.LIST_PRICE = Decimal.Round(poutRec.LIST_PRICE * (1 + ConfigurationManager.AppSettings("ACNTaxRate")), 2, MidpointRounding.AwayFromZero)
                    End If

                    'Frank 20170328
                    'Account AAEA010 need to make transation with Advantech in EUR currency,
                    'but it's a Intercon's account and the currency only can be setup as USD in SAP.
                    'So we need to transfer the price from USD to EUR
                    If SoldToId.Equals("AAEA010", StringComparison.InvariantCultureIgnoreCase) Then
                        poutRec.UNIT_PRICE = poutRec.UNIT_PRICE / _epricer_exch_rate_EURtoUSD
                        poutRec.LIST_PRICE = poutRec.LIST_PRICE / _epricer_exch_rate_EURtoUSD
                    End If


                    If Org = "BR01" Then
                        Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                        If cond_rs.Length > 0 Then
                            poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        End If
                        'poutRec.UNIT_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    End If
                End If
                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.RECYCLE_FEE = 0 : pout.UNIT_PRICE = 0
                ProductOut.AddProductOutRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If HasPhaseOutItem Then
            Return GetEUPrice(Org, SoldToId, ShipToId, strDistChann, strDivision, ProductIn, ProductOut, ErrorMessage)
        End If
        For Each pOutRow As SAPDALDS.ProductOutRow In ProductOut.Rows
            If IsNumeric(pOutRow.LIST_PRICE) AndAlso IsNumeric(pOutRow.UNIT_PRICE) AndAlso CDbl(pOutRow.LIST_PRICE) < CDbl(pOutRow.UNIT_PRICE) Then
                pOutRow.LIST_PRICE = pOutRow.UNIT_PRICE
            End If
            'Ryan 20160324 For JingjingJiang request 
            'If is CN org and no List Price maintained in SAP , set List Price as 0
            If Org.ToUpper.StartsWith("CN") AndAlso isZPN0MT = False Then
                'pOutRow.UNIT_PRICE = 0
                pOutRow.LIST_PRICE = 0
            End If
        Next


        ProductOut.AcceptChanges()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function

    <WebMethod()> _
    Public Function GetMultiPrice_ABR_TAX(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, _
                                           ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOut_ABRDataTable, ByRef ErrorMessage As String) As Boolean
        ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        Dim HasPhaseOutItem As Boolean = False, phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = "ZORB" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in ('A','N','H','O') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()

            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = POutDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()
            Dim ctrlCodeConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim ctrlCodeCmd As New SqlClient.SqlCommand()
            ctrlCodeCmd.Connection = ctrlCodeConn
            ProductOut = New SAPDALDS.ProductOut_ABRDataTable
            For Each PIn As DataRow In PInDt.Rows
                Dim poutRec As SAPDALDS.ProductOut_ABRRow = ProductOut.NewProductOut_ABRRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material")) : poutRec.LIST_PRICE = 0
                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If POutRs.Length > 0 Then
                    poutRec.NET_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ICMI' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.PR_UNIT = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        poutRec.PR_TOTAL = FormatNumber(cond_rs(0).Item("Condvalue"), 2)
                    Else
                        poutRec.PR_UNIT = -1 : poutRec.PR_TOTAL = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                    Else
                        poutRec.LIST_PRICE = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX13' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX13 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX13 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX23' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX23 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX23 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX72' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX72 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX72 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX82' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX82 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX82 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='IPVA' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.IPI = FormatNumber(cond_rs(0).Item("Cond_Value"), 2).ToString()
                    Else
                        poutRec.IPI = -1
                    End If

                    If ctrlCodeCmd.Connection.State <> ConnectionState.Open Then ctrlCodeCmd.Connection.Open()
                    ctrlCodeCmd.CommandText = "select top 1 Ctrl_Code from SAP_PRODUCT_ABC where PART_NO='" + poutRec.PART_NO + "' and PLANT='BRH1' and Ctrl_Code<>'' and Ctrl_Code is not null"
                    Dim obj As Object = ctrlCodeCmd.ExecuteScalar()
                    If obj IsNot Nothing Then poutRec.NCM = obj.ToString()
                End If

                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            If ctrlCodeCmd.Connection.State <> ConnectionState.Closed Then ctrlCodeCmd.Connection.Close()
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOut_ABRRow = ProductOut.NewProductOut_ABRRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.NET_PRICE = 0
                ProductOut.AddProductOut_ABRRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function
    'ICC 2016/6/6 Add ZQTR order type for ABR get list price
    Public Enum SAPOrderType
        ZOR
        ZOR2
        ZORB
        ZORC
        ZORR
        ZORI
        ZQTR
    End Enum

    <WebMethod()> _
    Public Function GetMultiPrice_ABR_TAX_2(ByVal Org As String, ByVal OrderType As SAPOrderType, ByVal SoldToId As String, ByVal ShipToId As String, _
                                           ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOut_ABRDataTable, _
                                           ByRef ErrorMessage As String) As Boolean
        ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        Dim HasPhaseOutItem As Boolean = False, phaseOutItems As New ArrayList, ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        If SoldToId = "SAID" Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = OrderType.ToString() : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each PInRow As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + PInRow.PART_NO + "' and a.product_status in ('A','N','H','O') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(PInRow.PART_NO.ToUpper())
                    item.Req_Qty = PInRow.QTY.ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = PInRow.PART_NO.ToUpper() : zr.Item("Qty") = PInRow.QTY : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(PInRow.PART_NO.ToUpper())
            End If
        Next
        sqlMA.Close()

        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Global_Inc.Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try

            Dim dtItem As New DataTable, dtPartNr As New DataTable, dtcon As New DataTable, DTRET As New DataTable

            dtItem = ItemsIn.ToADODataTable() : dtPartNr = Partners.ToADODataTable() : dtcon = Conditions.ToADODataTable()

            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim retAdoDt As DataTable = retDt.ToADODataTable()

            For Each retMsgRec As DataRow In retAdoDt.Rows
                If retMsgRec.Item("Type") = "E" Then
                    HasPhaseOutItem = True
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message_V1")) + vbCrLf
                End If
            Next

            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()

            'gv2.DataSource = POutDt : gv2.DataBind()

            DTRET = retDt.ToADODataTable()
            Dim ctrlCodeConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim ctrlCodeCmd As New SqlClient.SqlCommand()
            ctrlCodeCmd.Connection = ctrlCodeConn
            ProductOut = New SAPDALDS.ProductOut_ABRDataTable
            For Each PIn As DataRow In PInDt.Rows
                Dim poutRec As SAPDALDS.ProductOut_ABRRow = ProductOut.NewProductOut_ABRRow()
                poutRec.PART_NO = Global_Inc.RemoveZeroString(PIn.Item("Material")) : poutRec.LIST_PRICE = 0
                Dim POutRs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                If POutRs.Length > 0 Then
                    poutRec.NET_PRICE = FormatNumber(POutRs(0).Item("Net_Value1") / POutRs(0).Item("req_qty"), 2)
                    Dim cond_rs() As DataRow = ConditionOut.Select("Cond_Type='ICMI' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.PR_UNIT = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                        poutRec.PR_TOTAL = FormatNumber(cond_rs(0).Item("Condvalue"), 2)
                    Else
                        poutRec.PR_UNIT = -1 : poutRec.PR_TOTAL = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='ZPR0' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.LIST_PRICE = FormatNumber(cond_rs(0).Item("Cond_Value"), 2)
                    Else
                        poutRec.LIST_PRICE = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX13' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX13 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX13 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX23' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX23 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX23 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX72' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX72 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX72 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='BX82' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.BX82 = FormatNumber(cond_rs(0).Item("Condvalue") / POutRs(0).Item("req_qty"), 2).ToString()
                    Else
                        poutRec.BX82 = -1
                    End If
                    cond_rs = ConditionOut.Select("Cond_Type='IPVA' AND Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If cond_rs.Length > 0 Then
                        poutRec.IPI = FormatNumber(cond_rs(0).Item("Cond_Value"), 2).ToString()
                    Else
                        poutRec.IPI = -1
                    End If

                    If ctrlCodeCmd.Connection.State <> ConnectionState.Open Then ctrlCodeCmd.Connection.Open()
                    ctrlCodeCmd.CommandText = "select top 1 Ctrl_Code from SAP_PRODUCT_ABC where PART_NO='" + poutRec.PART_NO + "' and PLANT='BRH1' and Ctrl_Code<>'' and Ctrl_Code is not null"
                    Dim obj As Object = ctrlCodeCmd.ExecuteScalar()
                    If obj IsNot Nothing Then poutRec.NCM = obj.ToString()
                End If

                If Not RemoveAddedItem Or (RemoveAddedItem And Global_Inc.RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    ProductOut.Rows.Add(poutRec)
                End If

            Next
            If ctrlCodeCmd.Connection.State <> ConnectionState.Closed Then ctrlCodeCmd.Connection.Close()
            For Each itm As String In phaseOutItems
                Dim pout As SAPDALDS.ProductOut_ABRRow = ProductOut.NewProductOut_ABRRow()
                pout.PART_NO = itm
                pout.LIST_PRICE = 0 : pout.NET_PRICE = 0
                ProductOut.AddProductOut_ABRRow(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message of calling Bapi_Salesorder_Simulate:" + ex.ToString() : proxy1.Connection.Close() : Return False
        End Try
        proxy1.Connection.Close()
        If String.IsNullOrEmpty(ErrorMessage) = False Then Return False
        Return True
    End Function

    Private Shared Function GetMultiPrice_BR(ByVal SoldToId As String, ByVal ShipToId As String, _
                                      ByVal ProductIn As SAPDALDS.ProductInDataTable, ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                      ByRef strErrMsg As String) As Boolean
        Dim Vkorg As String = "BR01"
        SoldToId = Trim(UCase(SoldToId))
        Dim proxy1 As New Z_EBIZAEU_PRICEINQUIRY_BR.Z_EBIZAEU_PRICEINQUIRY_BR(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim zssD_01Table1 As New Z_EBIZAEU_PRICEINQUIRY_BR.ZSSD_01Table, zssD_02Table1 As New Z_EBIZAEU_PRICEINQUIRY_BR.ZSSD_02Table
        Dim distr_chann As String = "10", Division As String = "00"
        For Each prodRec As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim zssd_1 As New Z_EBIZAEU_PRICEINQUIRY_BR.ZSSD_01
            With zssd_1
                .Kunnr = SoldToId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(prodRec.PART_NO) : .Mglme = prodRec.QTY : .Vkorg = Vkorg
            End With
            zssD_01Table1.Add(zssd_1)
        Next
        Try
            proxy1.Connection.Open()
            proxy1.Z_Ebizaeu_Priceinquiry_Br("ZORB", distr_chann, Division, SoldToId, Vkorg.Trim().ToUpper(), ShipToId, _
                                              New Z_EBIZAEU_PRICEINQUIRY_BR.BAPIRETURN, zssD_01Table1, zssD_02Table1)

        Catch ex As Exception
            strErrMsg = "Call Z_Ebizaeu_Priceinquiry_Br error:" + ex.ToString()
            proxy1.Connection.Close() : Return False
        End Try

        proxy1.Connection.Close()
        ProductOut = New SAPDALDS.ProductOutDataTable
        Dim sapPOutDt As DataTable = zssD_02Table1.ToADODataTable()
        For Each sapPOutRec As DataRow In sapPOutDt.Rows
            Dim pOutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
            pOutRec.PART_NO = Global_Inc.RemoveZeroString(sapPOutRec.Item("Matnr"))
            pOutRec.LIST_PRICE = sapPOutRec.Item("Kzwi1")
            pOutRec.UNIT_PRICE = sapPOutRec.Item("Netwr")
            If (pOutRec.LIST_PRICE = 0) Then pOutRec.LIST_PRICE = -1
            If (pOutRec.UNIT_PRICE = 0) Then pOutRec.UNIT_PRICE = -1
            If pOutRec.LIST_PRICE < pOutRec.UNIT_PRICE Then pOutRec.LIST_PRICE = pOutRec.UNIT_PRICE
            ProductOut.AddProductOutRow(pOutRec)
        Next

        Return True

    End Function

    Public Shared Function GetEUPrice(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                          ByVal strDivision As String, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                          ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                          ByRef ErrorMessage As String) As Boolean
        ProductOut = New SAPDALDS.ProductOutDataTable
        Dim pDate As String = Now.ToString("yyyyMMdd")
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each pinRec As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = SoldToId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(pinRec.PART_NO)
                .Mglme = pinRec.QTY : .Prsdt = pDate : .Vkorg = Org
            End With
            pin.Add(prec)
        Next

        'Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : ErrorMessage += vbCrLf + ex.ToString() : Return False
        End Try
        eup.Connection.Close()
        'OrderUtilities.showDT(pout.ToADODataTable)
        For i As Integer = 0 To pout.Count - 1
            Dim pOutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
            Dim retRec As Z_SD_EUPRICEINQUERY.ZSSD_02_EU = pout.Item(i)
            pOutRec.PART_NO = Global_Inc.RemoveZeroString(retRec.Matnr)
            If retRec.Mglme > 0 Then
                pOutRec.LIST_PRICE = retRec.Kzwi1 / retRec.Mglme
                pOutRec.UNIT_PRICE = retRec.Netwr / retRec.Mglme
            Else
                pOutRec.LIST_PRICE = retRec.Kzwi1 : pOutRec.UNIT_PRICE = retRec.Netwr
            End If

            'If pOutRec.LIST_PRICE < pOutRec.UNIT_PRICE Then pOutRec.LIST_PRICE = pOutRec.UNIT_PRICE

            If Decimal.TryParse(pOutRec.LIST_PRICE, 0) AndAlso Decimal.TryParse(pOutRec.UNIT_PRICE, 0) Then
                If Decimal.Parse(pOutRec.LIST_PRICE) < Decimal.Parse(pOutRec.UNIT_PRICE) Then pOutRec.LIST_PRICE = pOutRec.UNIT_PRICE
            End If

            pOutRec.TAX = 0 : pOutRec.RECYCLE_FEE = 0

            ProductOut.AddProductOutRow(pOutRec)
        Next
        Return True
        'Return pdt
    End Function

    '20150429 TC: add recycling fee in the product out table, for eStore getting price's purpose
    Private Shared Function GetEUPriceV2(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                         ByVal strDivision As String, ByVal ProductIn As SAPDALDS.ProductInDataTable, _
                                         ByRef ProductOut As SAPDALDS.ProductOutDataTable, _
                                         ByRef ErrorMessage As String) As Boolean
        ProductOut = New SAPDALDS.ProductOutDataTable
        Dim pDate As String = Now.ToString("yyyyMMdd")
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each pinRec As SAPDALDS.ProductInRow In ProductIn.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = SoldToId : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(pinRec.PART_NO)
                .Mglme = pinRec.QTY : .Prsdt = pDate : .Vkorg = Org
            End With
            pin.Add(prec)
        Next

        'Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : ErrorMessage += vbCrLf + ex.ToString() : Return False
        End Try
        eup.Connection.Close()
        'OrderUtilities.showDT(pout.ToADODataTable)
        For i As Integer = 0 To pout.Count - 1
            Dim pOutRec As SAPDALDS.ProductOutRow = ProductOut.NewProductOutRow()
            Dim retRec As Z_SD_EUPRICEINQUERY.ZSSD_02_EU = pout.Item(i)
            pOutRec.PART_NO = Global_Inc.RemoveZeroString(retRec.Matnr)
            If retRec.Mglme > 0 Then
                pOutRec.LIST_PRICE = retRec.Kzwi1 / retRec.Mglme
                pOutRec.UNIT_PRICE = retRec.Netwr / retRec.Mglme
            Else
                pOutRec.LIST_PRICE = retRec.Kzwi1 : pOutRec.UNIT_PRICE = retRec.Netwr
            End If

            'If pOutRec.LIST_PRICE < pOutRec.UNIT_PRICE Then pOutRec.LIST_PRICE = pOutRec.UNIT_PRICE

            If Decimal.TryParse(pOutRec.LIST_PRICE, 0) AndAlso Decimal.TryParse(pOutRec.UNIT_PRICE, 0) Then
                If Decimal.Parse(pOutRec.LIST_PRICE) < Decimal.Parse(pOutRec.UNIT_PRICE) Then pOutRec.LIST_PRICE = pOutRec.UNIT_PRICE
            End If


            pOutRec.TAX = 0
            pOutRec.RECYCLE_FEE = 0
            ProductOut.AddProductOutRow(pOutRec)
        Next

        '20150504 TC: When org=US01 get recycling fee from eQuotation.dbo.SAP_PRODUCT_PRICE_COND, which is updated daily by MyLocal SSIS
        If Org = "US01" Then
            Dim PartNoSet As New ArrayList
            For Each pOutRec In ProductOut
                PartNoSet.Add("'" + pOutRec.PART_NO + "'")
            Next

            Dim sqlRecycFee As String = _
                " select PART_NO, cast(CONDITION_AMOUNT_PERCENT/CONDITION_PRICE_UNIT as numeric(10,2)) as COND_VALUE " + _
                " from eQuotation.dbo.SAP_PRODUCT_PRICE_COND  " + _
                " where ORG_ID='US01' and SD_DOC_CURRENCY='USD' and CONDITION_TYPE='ZHB0' and '20150504'  " + _
                " between VALID_FROM_DATE and VALID_TO_DATE  " + _
                " and PART_NO in (" + String.Join(",", PartNoSet.ToArray()) + ") " + _
                " order by PART_NO  "
            Dim dtRecycFee As New DataTable
            Dim aptRecycFee As New SqlClient.SqlDataAdapter(sqlRecycFee, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            aptRecycFee.Fill(dtRecycFee)
            aptRecycFee.SelectCommand.Connection.Close()
            For Each pOutRec In ProductOut
                Dim rs() As DataRow = dtRecycFee.Select("PART_NO='" + pOutRec.PART_NO + "'")
                If rs.Length > 0 Then
                    pOutRec.RECYCLE_FEE = rs(0).Item("COND_VALUE")
                    pOutRec.LIST_PRICE = pOutRec.LIST_PRICE - pOutRec.RECYCLE_FEE
                    pOutRec.UNIT_PRICE = pOutRec.UNIT_PRICE - pOutRec.RECYCLE_FEE
                End If
            Next
        End If

        Return True
        'Return pdt
    End Function

    Class PNDetail
        Public Property StoreId As String : Public Property ListPriceCurrency As String : Public Property ListPrice As Decimal
        Public Property CostCurrency As String : Public Property Cost As Decimal : Public Property InventoryQty As Integer
        Public Property eStoreFlag As String : Public Property ProductStatus As String : Public Property ABCDIndicator As String
        Public Property SAPPlant As String : Public Property SAPSalesOrg As String
    End Class


    Public Shared Function GetSAPPNCost(ByVal PartNo As String) As DataTable
        Return OraDbUtil.dbGetDataTable("SAP_PRD", _
                                " select distinct a.matnr as part_no, a.bwkey as plant, b.vkorg as sales_org, c.waers as currency, " + _
                                " a.STPRS as standard_price,  " + _
                                " a.VERPR as moving_price, a.VPRSV as price_control, a.PEINH as price_unit, a.STPRS as external_standard_price, 0 as update_flag  " + _
                                " from saprdp.mbew a inner join saprdp.tvkwz b on a.bwkey=b.werks inner join saprdp.t001 c on b.vkorg=c.bukrs " + _
                                " where a.mandt='168' and b.mandt='168' and c.mandt='168' and a.matnr='" + Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PartNo)).ToUpper() + "' ")
    End Function

    Public Shared Function FormatCost(ByVal StandardPrice As Decimal, ByVal PriceUnit As Integer, ByVal SalesOrg As String) As Decimal
        Dim cost As Decimal = StandardPrice / PriceUnit
        If SalesOrg = "KR01" Or SalesOrg = "JP01" Then
            cost = cost * 100
        ElseIf SalesOrg = "TW01" Then
            If PriceUnit = 1000 Then
                cost = cost * 100
            End If
        End If
        Return cost
    End Function


    Public Shared Function GetPNDetail(ByVal PartNo As String, ByVal _IsQueryeStore As Boolean, Optional ByVal StoreId As String = "") As List(Of PNDetail)
        PartNo = Trim(PartNo.ToUpper())
        Dim dtSAPCost As DataTable = GetSAPPNCost(PartNo)

        Dim dtSAPStatus As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
           " select a.matnr as PART_NO, a.werks as PLANT, a.maabc as ABC_INDICATOR, a.EISBE as safety_stock,  " + _
           " a.EISLO as min_safety_stock, b.vmsta as status, b.vkorg as org_id " + _
           " from saprdp.marc a inner join saprdp.mvke b on a.matnr=b.matnr and a.werks=b.dwerk " + _
           " where a.mandt='168' and b.mandt='168' and a.matnr='" + Global_Inc.Format2SAPItem(UCase(PartNo)) + "'")
        Dim dtEstoreStatus As DataTable = Nothing
        If _IsQueryeStore Then
            dtEstoreStatus = dbUtil.dbGetDataTable("Estore", _
            "SELECT [StoreID], [PublishStatus],[Status] FROM [eStoreProduction].[dbo].[Product] where DisplayPartno='" + Replace(PartNo, "'", "''") + "'")
        End If

        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable

        Dim PNDetailSet As New List(Of PNDetail)
        Dim dtStore As DataTable = dbUtil.dbGetDataTable("MY", _
            "select a.ERP_ID, a.SALES_ORG, a.STORE_ID from eQuotation.dbo.ESTORE_PRICING_ERPID a " + _
            IIf(StoreId <> "", " where a.STORE_ID='" + StoreId + "' ", "") + " order by a.STORE_ID")
        eup.Connection.Open()
        If dtStore IsNot Nothing AndAlso dtStore.Rows.Count > 0 Then
            For Each rStore As DataRow In dtStore.Rows
                Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
                With prec
                    .Kunnr = rStore.Item("ERP_ID") : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(Trim(UCase(PartNo))) : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = rStore.Item("SALES_ORG")
                End With
                pin.Add(prec)
            Next
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
            eup.Connection.Close()
        End If
        Dim dtPrice As DataTable = pout.ToADODataTable()


        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()

        For Each rStore As DataRow In dtStore.Rows
            Dim PNDetail1 As New PNDetail
            PNDetail1.SAPSalesOrg = rStore.Item("SALES_ORG")
            Dim rStatus() As DataRow = dtSAPStatus.Select("org_id='" + rStore.Item("SALES_ORG") + "'")
            If rStatus.Length > 0 Then
                PNDetail1.ProductStatus = rStatus(0).Item("status") : PNDetail1.ABCDIndicator = rStatus(0).Item("ABC_INDICATOR") : PNDetail1.SAPPlant = rStatus(0).Item("PLANT")
            Else
                PNDetail1.ProductStatus = "N/A" : PNDetail1.ABCDIndicator = "N/A"
            End If

            Dim rPrice() As DataRow = dtPrice.Select("Kunnr='" + rStore.Item("ERP_ID") + "' and Vkorg='" + rStore.Item("SALES_ORG") + "'")
            If rPrice.Length > 0 AndAlso Not String.IsNullOrEmpty(PNDetail1.SAPPlant) Then
                PNDetail1.ListPrice = rPrice(0).Item("Kzwi1") : PNDetail1.ListPriceCurrency = rPrice(0).Item("Waerk")
                Dim rCost() As DataRow = dtSAPCost.Select("PLANT='" + PNDetail1.SAPPlant + "' and SALES_ORG='" + rStore.Item("SALES_ORG") + "'")
                If rCost.Length > 0 Then
                    PNDetail1.Cost = FormatCost(rCost(0).Item("STANDARD_PRICE"), rCost(0).Item("PRICE_UNIT"), rStore.Item("SALES_ORG"))
                    PNDetail1.CostCurrency = rCost(0).Item("CURRENCY")

                End If
                If PNDetail1.ListPrice = 0 Then
                    'And rStore.Item("SALES_ORG").ToString().StartsWith("CN")
                    Dim ItemOutAndPriceCondition1 = MYSAPBIZ.OrderSimulation(rStore.Item("ERP_ID"), rStore.Item("SALES_ORG").ToString(), "10", "00", PartNo)
                    Dim r = From q In ItemOutAndPriceCondition1.ItemOut Where q.Material = Util.FormatToSAPPartNo(PartNo)

                    If r.Count > 0 Then
                        PNDetail1.ListPrice = r.First.Subtotal2 : PNDetail1.ListPriceCurrency = r.First.Currency
                    End If
                End If
            End If

            'ICC 2018/1/22 Use original get price function to get list price from SAP
            Dim ws As New MYSAPDAL, pdin As New SAPDALDS.ProductInDataTable, pdout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            pdin.AddProductInRow(PartNo, 1)
            If ws.GetPrice(rStore.Item("ERP_ID").ToString, rStore.Item("ERP_ID").ToString, rStore.Item("SALES_ORG").ToString, pdin, pdout, errMsg) Then
                Dim rs() As SAPDALDS.ProductOutRow = pdout.Select("part_no='" + PartNo + "'")
                If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).LIST_PRICE, 0) AndAlso Decimal.TryParse(rs(0).LIST_PRICE, 0) Then
                    PNDetail1.ListPrice = FormatNumber(rs(0).LIST_PRICE, 2).Replace(",", "")
                End If
            End If

            If _IsQueryeStore AndAlso dtEstoreStatus IsNot Nothing Then
                Dim rEstoreStatus() As DataRow = dtEstoreStatus.Select("StoreID='" + rStore.Item("STORE_ID") + "'")
                If rEstoreStatus.Length > 0 Then
                    PNDetail1.eStoreFlag = rEstoreStatus(0).Item("Status")
                Else
                    PNDetail1.eStoreFlag = "N/A"
                End If
            End If

            Dim Inventory As Integer = 0
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd") : retTb.Add(rOfretTb)
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, UCase(Left(rStore.Item("SALES_ORG"), 2) + "H1"), _
                                          "", "", "", "", "PC", "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            Dim ATPtable As DataTable = atpTb.ToADODataTable()
            Dim intCulATPQty As Integer = 0
            For Each r As DataRow In ATPtable.Rows
                intCulATPQty += CType(r.Item("com_qty"), Int64)
            Next

            With PNDetail1
                .InventoryQty = intCulATPQty : .StoreId = rStore.Item("STORE_ID")
            End With
            PNDetailSet.Add(PNDetail1)
        Next
        p1.Connection.Close()

        Return PNDetailSet
    End Function

    <WebMethod()> _
    Public Function GetProductCost(ByVal PartNo As String, ByVal StoreId As String, _
                             ByRef ErrorMessage As String) As List(Of PNDetail)
        Try
            Return GetPNDetail(PartNo, False, StoreId)
        Catch ex As Exception
            ErrorMessage = ex.Message
        End Try
        Return Nothing
    End Function


#End Region

#Region "Credit"

    <WebMethod()> _
    Public Function GetCustomerCreditExposure(ByVal CustomerId As String, ByVal Org As String, ByRef CreditLimit As Decimal, _
                                              ByRef CreditExposure As Decimal, ByRef Percentage As String) As Boolean
        CustomerId = Trim(UCase(CustomerId)) : Org = Trim(UCase(Org))
        Select Case Left(Org, 2)
            Case "EU", "AU", "JP", "MY", "BR", "SG", "TL", "TW"
                Org = Left(Org, 2) + "01"
            Case "CN"
                Org = Left(Org, 2) + "C1"
            Case "US"
                Org = Left(Org, 2) + "C1"
            Case "HK"
                Org = Left(Org, 2) + "05"
        End Select
        Dim strHorizonDate As String = DateAdd(DateInterval.Month, 1, Now).ToString("yyyyMMdd")
        Dim p As New GetCreditExposure.GetCreditExposure(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim cmware As String = "", Delta2Limit As Decimal, dtKnkk As GetCreditExposure.KNKK = Nothing, Knkli As String = ""
        Dim OpenDelivery As Decimal, OpenDeliverySecure As Decimal, OpenInvoice As Decimal, OpenInvoiceSecure As Decimal
        Dim OpenItems As Decimal, OpenOrders As Decimal, OpenOrderSecure As Decimal, OpenSepcial As Decimal, SumOpen As Decimal
        p.Connection.Open()
        Try
            p.Zcredit_Exposure(strHorizonDate, Org, CustomerId, cmware, CreditLimit, Delta2Limit, dtKnkk, Knkli, OpenDelivery, OpenDeliverySecure, _
                       OpenInvoice, OpenInvoiceSecure, OpenItems, OpenOrders, OpenOrderSecure, OpenSepcial, Percentage, SumOpen)
        Catch ex As Exception
            p.Connection.Close() : Return False
        End Try
        p.Connection.Close()
        CreditExposure = CreditLimit + Delta2Limit
        Return True
    End Function
#End Region

#Region "Inventory"

    <WebMethod()> _
    Public Sub QueryLimitQuantity(ByVal VK_ORG As String, ByVal PART_NO() As String, ByRef Result As DataSet, ByRef strErrMsg As String)

        Try

            Dim proxy1 As New Z_GET_ATP_LIMITQTY.Z_GET_ATP_LIMITQTY(ConfigurationManager.AppSettings("SAP_PRD"))
            'Dim proxy1 As New Z_GET_ATP_LIMITQTY.Z_GET_ATP_LIMITQTY(ConfigurationManager.AppSettings("SAPConnTest"))
            Dim dtZTBLATP As New ZTBLATPTable
            Dim dtZTBLMATNR As New ZTBLMATNRTable
            Dim i As Integer
            For i = 0 To PART_NO.Length - 1
                Dim drZTBLMATNR As New ZTBLMATNR
                drZTBLMATNR.Matnr = PART_NO(i)
                dtZTBLMATNR.Add(drZTBLMATNR)
            Next

            proxy1.Connection.Open()
            proxy1.Zget_Atp_Limitqty("X", VK_ORG, dtZTBLMATNR, dtZTBLATP)
            proxy1.Connection.Close()
            Result.Tables.Add(dtZTBLATP.ToADODataTable())
            strErrMsg = ""
        Catch ex As Exception
            strErrMsg = ex.ToString()
        End Try

    End Sub



    '    ''' <summary>
    '    ''' Query Product Inventory
    '    ''' </summary>
    '    ''' <param name="PartNos"></param>
    '    ''' <param name="plant"></param>
    '    ''' <returns></returns>
    '    ''' <remarks></remarks>
    '    <WebMethod()> _
    '    Public Function QueryInventory(ByVal PartNos As SAPDALDS.ProductInDataTable, ByVal plant As String, _
    '                                   ByRef QueryResult As SAPDALDS.QueryInventory_OutputDataTable, _
    '                                   ByRef ErrorMsg As String) As Boolean


    '        Return Me.QueryInventory_V2(PartNos, plant, "V1", QueryResult, ErrorMsg)

    '        'Try

    '        '    If PartNos Is Nothing Then
    '        '        'ErrorMsg = "Input value PartNos Is Nothing"
    '        '        Throw New Exception("Input value PartNos Is Nothing")
    '        '    End If
    '        '    If PartNos.Rows.Count = 0 Then
    '        '        'ErrorMsg = "Input value PartNos Is Nothing"
    '        '        Throw New Exception("Input value PartNos Is Nothing")
    '        '    End If

    '        '    'return value:Inventory Information(called by reference)
    '        '    'Dim _returndt As New SAPDALDS.QueryInventory_OutputDataTable()
    '        '    If QueryResult Is Nothing Then QueryResult = New SAPDALDS.QueryInventory_OutputDataTable()

    '        '    Dim dt As DataTable = Nothing

    '        '    'Create GET_MATERIAL_ATP object of SAP API 
    '        '    Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
    '        '    'Set connect string
    '        '    p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
    '        '    'Open connection
    '        '    p1.Connection.Open()

    '        '    Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0

    '        '    'format partno string
    '        '    'PartNo = Global_Inc.Format2SAPItem(Trim(UCase(PartNo)))

    '        '    Dim culQty As Integer = 0

    '        '    'Create object as parameter for calling GET_MATERIAL_ATP.Bapi_Material_Availability
    '        '    Dim retTb As GET_MATERIAL_ATP.BAPIWMDVSTable = Nothing, atpTb As GET_MATERIAL_ATP.BAPIWMDVETable = Nothing, rOfretTb As GET_MATERIAL_ATP.BAPIWMDVS = Nothing

    '        '    Dim Inventory As Int16 = 0

    '        '    Dim _PartNo As String = String.Empty, _FormatPartNo As String = String.Empty, _Qty As String = String.Empty
    '        '    Dim _newrow As DataRow = Nothing, sumObject As Integer = 0

    '        '    PartNos.DefaultView.Sort = "PART_NO"
    '        '    'PartNos = PartNos.DefaultView.ToTable
    '        '    Dim _lastPartNo As String = ""
    '        '    'For Each _row As DataRow In PartNos.Rows
    '        '    For Each _row As DataRow In PartNos.DefaultView.ToTable.Rows
    '        '        _PartNo = Trim(UCase(_row.Item("PART_NO") & ""))
    '        '        'if part no is "" then skips this recourd
    '        '        If _PartNo.Length = 0 Then Continue For
    '        '        If _lastPartNo = _PartNo Then Continue For
    '        '        _lastPartNo = _PartNo
    '        '        'Getting QTY and sum the total qty per part_no from input datatable
    '        '        sumObject = 0
    '        '        sumObject = PartNos.Compute("Sum(QTY)", "PART_NO = '" & _row.Item("PART_NO") & "'")
    '        '        '_Qty = Trim(_row.Item("QTY") & "")
    '        '        _Qty = Trim(sumObject & "")

    '        '        'Format partno string
    '        '        _FormatPartNo = Global_Inc.Format2SAPItem(_PartNo)
    '        '        retTb = New GET_MATERIAL_ATP.BAPIWMDVSTable : atpTb = New GET_MATERIAL_ATP.BAPIWMDVETable : rOfretTb = New GET_MATERIAL_ATP.BAPIWMDVS
    '        '        Try
    '        '            rOfretTb.Req_Qty = Decimal.Parse(_Qty)
    '        '        Catch ex As Exception
    '        '            'If QTY can not be parsed then set QTY=9999
    '        '            rOfretTb.Req_Qty = 9999
    '        '        End Try
    '        '        retTb.Add(rOfretTb)

    '        '        'call Bapi_Material_Availability to get inventory information
    '        '        p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", _FormatPartNo, UCase(plant), "", "", "", "", "PC", _
    '        '                                      "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
    '        '        'Get inventory result
    '        '        'dt = New DataTable("InventoryInfo")
    '        '        dt = atpTb.ToADODataTable()

    '        '        'write to datatable for return value
    '        '        For Each _InventoryRow As DataRow In dt.Rows
    '        '            If IsDBNull(_InventoryRow.Item("Com_Qty")) Then
    '        '                Continue For
    '        '            End If

    '        '            If _InventoryRow.Item("Com_Qty") = 0 Then
    '        '                Continue For
    '        '            End If

    '        '            _newrow = QueryResult.NewRow : _newrow.Item("PART_NO") = _PartNo
    '        '            '_newrow.Item("STOCK_DATE") = New DateTime(_InventoryRow.Item("Com_Date"))
    '        '            'DateTime.ParseExact(_InventoryRow.Item("Com_Date"), "yyyyMMdd", Nothing)
    '        '            _newrow.Item("STOCK_DATE") = DateTime.ParseExact(_InventoryRow.Item("Com_Date"), "yyyyMMdd", Nothing)
    '        '            _newrow.Item("STOCK") = _InventoryRow.Item("Com_Qty")
    '        '            QueryResult.Rows.Add(_newrow)

    '        '        Next

    '        '    Next

    '        '    'close connection
    '        '    p1.Connection.Close()

    '        'Catch ex As Exception
    '        '    ErrorMsg = ex.Message : Return False
    '        'End Try
    '        'Return True

    '    End Function

    '    ''' <summary>
    '    ''' Query Product Inventory V2
    '    ''' </summary>
    '    ''' <param name="PartNos"></param>
    '    ''' <param name="plant"></param>
    '    ''' <param name="Req_Date">format is yyyyMMdd(Ex 20120101)</param>
    '    ''' <param name="QueryResult"></param>
    '    ''' <param name="ErrorMsg"></param>
    '    ''' <returns></returns>
    '    ''' <remarks></remarks>
    '    <WebMethod()> _
    '    Public Function QueryInventory_V2(ByVal PartNos As SAPDALDS.ProductInDataTable, ByVal plant As String, _
    '                                   ByVal Req_Date As String, ByRef QueryResult As SAPDALDS.QueryInventory_OutputDataTable, _
    '                                   ByRef ErrorMsg As String) As Boolean
    '        Try

    '            If PartNos Is Nothing Then
    '                ErrorMsg = "Input value PartNos Is null"
    '                'Return False
    '                Throw New Exception(ErrorMsg)
    '            End If
    '            If PartNos.Rows.Count = 0 Then
    '                ErrorMsg = "Input value PartNos has no recoder"
    '                'Return False
    '                Throw New Exception(ErrorMsg)
    '            End If

    '            If Not Req_Date.ToUpper.Equals("V1") Then
    '                If String.IsNullOrEmpty(Req_Date) Then
    '                    ErrorMsg = "Input value Req_Date is null. The correct format is yyyyMMdd(20120101)"
    '                    'Return False
    '                    Throw New Exception(ErrorMsg)
    '                End If

    '                If Req_Date.Length <> 8 Then
    '                    ErrorMsg = "Input value Req_Date is incorrect format. The correct format is yyyyMMdd(20120101)"
    '                    'Return False
    '                    Throw New Exception(ErrorMsg)
    '                End If

    '                If Not IsNumeric(Req_Date) Then
    '                    ErrorMsg = "Input value Req_Date is incorrect format. The correct format is yyyyMMdd(20120101)"
    '                    'Return False
    '                    Throw New Exception(ErrorMsg)
    '                End If


    '                'Dim ResultDate As Date
    '                'if Not IsDate(Req_Date) Then
    '                If Not IsDate(Req_Date.Substring(0, 4) & "/" & Req_Date.Substring(4, 2) & "/" & Req_Date.Substring(6, 2)) Then
    '                    ErrorMsg = "Input value Req_Date is incorrect format. The correct format is yyyyMMdd(20120101)"
    '                    'Return False
    '                    Throw New Exception(ErrorMsg)
    '                End If
    '            Else
    '                Req_Date = Nothing
    '            End If


    '            'return value:Inventory Information(called by reference)
    '            'Dim _returndt As New SAPDALDS.QueryInventory_OutputDataTable()
    '            If QueryResult Is Nothing Then QueryResult = New SAPDALDS.QueryInventory_OutputDataTable()

    '            Dim dt As DataTable = Nothing

    '            'Create GET_MATERIAL_ATP object of SAP API 
    '            Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
    '            'Set connect string
    '            p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
    '            'Open connection
    '            p1.Connection.Open()

    '            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0

    '            'format partno string
    '            'PartNo = Global_Inc.Format2SAPItem(Trim(UCase(PartNo)))

    '            Dim culQty As Integer = 0

    '            'Create object as parameter for calling GET_MATERIAL_ATP.Bapi_Material_Availability
    '            Dim retTb As GET_MATERIAL_ATP.BAPIWMDVSTable = Nothing, atpTb As GET_MATERIAL_ATP.BAPIWMDVETable = Nothing, rOfretTb As GET_MATERIAL_ATP.BAPIWMDVS = Nothing

    '            Dim Inventory As Int16 = 0

    '            Dim _PartNo As String = String.Empty, _FormatPartNo As String = String.Empty, _Qty As String = String.Empty
    '            Dim _newrow As DataRow = Nothing, sumObject As Integer = 0

    '            PartNos.DefaultView.Sort = "PART_NO"
    '            'PartNos = PartNos.DefaultView.ToTable
    '            Dim _lastPartNo As String = ""
    '            'For Each _row As DataRow In PartNos.Rows
    '            For Each _row As DataRow In PartNos.DefaultView.ToTable.Rows
    '                _PartNo = Trim(UCase(_row.Item("PART_NO") & ""))
    '                'if part no is "" then skips this recourd
    '                If _PartNo.Length = 0 Then Continue For
    '                If _lastPartNo = _PartNo Then Continue For
    '                _lastPartNo = _PartNo
    '                'Getting QTY and sum the total qty per part_no from input datatable
    '                sumObject = 0
    '                sumObject = PartNos.Compute("Sum(QTY)", "PART_NO = '" & _row.Item("PART_NO") & "'")
    '                '_Qty = Trim(_row.Item("QTY") & "")
    '                _Qty = Trim(sumObject & "")

    '                'Format partno string
    '                _FormatPartNo = Global_Inc.Format2SAPItem(_PartNo)
    '                retTb = New GET_MATERIAL_ATP.BAPIWMDVSTable : atpTb = New GET_MATERIAL_ATP.BAPIWMDVETable : rOfretTb = New GET_MATERIAL_ATP.BAPIWMDVS
    '                Try
    '                    rOfretTb.Req_Qty = Decimal.Parse(_Qty)
    '                Catch ex As Exception
    '                    'If QTY can not be parsed then set QTY=9999
    '                    rOfretTb.Req_Qty = 9999
    '                End Try

    '                'Default Req_Date is nothing. Means from now
    '                rOfretTb.Req_Date = Req_Date

    '                retTb.Add(rOfretTb)

    '                'call Bapi_Material_Availability to get inventory information
    '                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", _FormatPartNo, UCase(plant), "", "", "", "", "PC", _
    '                                              "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
    '                'Get inventory result
    '                'dt = New DataTable("InventoryInfo")
    '                dt = atpTb.ToADODataTable()

    '                'write to datatable for return value
    '                For Each _InventoryRow As DataRow In dt.Rows
    '                    If IsDBNull(_InventoryRow.Item("Com_Qty")) Then
    '                        Continue For
    '                    End If

    '                    If _InventoryRow.Item("Com_Qty") = 0 Then
    '                        Continue For
    '                    End If

    '                    _newrow = QueryResult.NewRow : _newrow.Item("PART_NO") = _PartNo
    '                    '_newrow.Item("STOCK_DATE") = New DateTime(_InventoryRow.Item("Com_Date"))
    '                    'DateTime.ParseExact(_InventoryRow.Item("Com_Date"), "yyyyMMdd", Nothing)
    '                    _newrow.Item("STOCK_DATE") = DateTime.ParseExact(_InventoryRow.Item("Com_Date"), "yyyyMMdd", Nothing)
    '                    _newrow.Item("STOCK") = _InventoryRow.Item("Com_Qty")
    '                    QueryResult.Rows.Add(_newrow)

    '                Next

    '            Next

    '            'close connection
    '            p1.Connection.Close()

    '        Catch ex As Exception
    '            ErrorMsg = ex.Message : Return False
    '        End Try
    '        Return True

    '    End Function


#End Region

    Public Shared Function GetCustomerDataSet(ByVal companyid As String, ByRef ds As DataSet) As Boolean

    End Function

    Public Shared Function GetDefaultDistChannDivisionSalesGrpOfficeByCompanyId( _
        ByVal CompanyId As String, ByRef dist_chann As String, ByRef division As String, ByRef SalesGroup As String, ByRef SalesOffice As String) As Boolean
        Dim strSql As String = _
            " select b.vtweg as dist_chann, b.SPART as division, b.VKBUR as SalesOffice, b.VKGRP as SalesGroup " + _
            " from saprdp.knvv b " + _
            " where b.mandt='168' and b.kunnr = '" + UCase(CompanyId) + "' and rownum=1 " + _
            " order by b.VKGRP, b.VKBUR "
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
        If dt.Rows.Count > 0 Then
            With dt.Rows(0)
                dist_chann = .Item("dist_chann") : division = .Item("division") : SalesGroup = .Item("SalesGroup") : SalesOffice = .Item("SalesOffice")
            End With
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function checkSAPQuote(ByVal Quoteid As String) As Boolean
        Dim strSql As String = " select vbak.vbeln from saprdp.vbak where vbak.vbeln = '" + UCase(Quoteid) + "'"
        Dim SAPconnStr As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnStr = "SAP_Test"
        End If
        Dim dt As DataTable = OraDbUtil.dbGetDataTable(SAPconnStr, strSql)
        If dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function checkOptyIDForATWSO(ByVal orderid As String) As Boolean
        Dim _CartMaster As CartMaster = MyCartX.GetCartMaster(HttpContext.Current.Session("CART_ID").ToString.Trim)
        If Not IsNothing(_CartMaster) AndAlso _CartMaster.OpportunityID IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.OpportunityID.Trim) Then
        Else
            Return True
        End If
        Dim strSql As String = " select  nvl(vbak.VSNMR_V,'') as OrderVersion from saprdp.vbak where vbak.vbeln = '" + UCase(orderid.Trim) + "'  and ROWNUM = 1"
        Dim SAPconnStr As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnStr = "SAP_Test"
        End If
        Dim OptyID As Object = OraDbUtil.dbExecuteScalar(SAPconnStr, strSql)
        If OptyID IsNot Nothing AndAlso Not String.IsNullOrEmpty(OptyID.ToString.Trim) Then
        Else
            Util.SendEmail("myadvantech@advantech.com,show.liaw@advantech.com.tw", "myadvantech@advantech.com", "OptyID cannot insert SO: " + orderid, "OptyID: " + _CartMaster.OpportunityID, True, "", "")
        End If
        Return True
    End Function

    Public Shared Function AddSAPADR6RecordsByADRNR(ByVal _AddrNumber As String, ByVal _Emails As List(Of String), ByVal _isTesting As Boolean) As Boolean
        Dim result As Boolean = False

        Dim proxy1 As New ZADDR_SAVE_INTERN.ZADDR_SAVE_INTERN
        Dim NewADR6Table As New ZADDR_SAVE_INTERN.ADR6Table

        If _Emails.Count > 0 Then
            Try
                Dim dtCurrentADR6 As DataTable = OraDbUtil.dbGetDataTable(IIf(_isTesting, "SAP_Test", "SAP_PRD"), String.Format("select * from saprdp.adr6 WHERE addrnumber = '{0}' order by consnumber", _AddrNumber))
                Dim MaxSeq As Integer = 0
                If dtCurrentADR6.Rows.Count > 0 Then
                    For Each dr As DataRow In dtCurrentADR6.Rows
                        If _Emails.Contains(dr.Item("SMTP_ADDR").ToString) Then
                            _Emails.Remove(dr.Item("SMTP_ADDR").ToString)
                        End If
                        Integer.TryParse(dr.Item("CONSNUMBER").ToString, MaxSeq)
                    Next
                End If

                If _Emails.Count > 0 AndAlso Not String.IsNullOrEmpty(_AddrNumber) Then

                    For Each email As String In _Emails
                        MaxSeq = MaxSeq + 1
                        Dim NewADR6Row As New ZADDR_SAVE_INTERN.ADR6
                        With NewADR6Row
                            .Addrnumber = _AddrNumber : .Client = "168" : .Consnumber = MaxSeq.ToString("D3") : .Date_From = "00010101"
                            .Dft_Receiv = "" : .Encode = "" : .Flg_Nouse = ""
                            .Flgdefault = "" : .Home_Flag = "" : .Persnumber = ""
                            .R3_User = "" : .Smtp_Addr = email : .Smtp_Srch = email : .Tnef = ""
                        End With
                        NewADR6Table.Add(NewADR6Row)
                    Next

                    proxy1.ConnectionString = ConfigurationManager.AppSettings(IIf(_isTesting, "SAPConnTest", "SAP_PRD"))
                    proxy1.Connection.Open()

                    proxy1.Zaddr_Save_Intern(New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable,
                                   New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table,
                                   New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table,
                                   New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table,
                                   New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table,
                                   New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table,
                                   New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table,
                                   New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table,
                                   New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table,
                                   New ZADDR_SAVE_INTERN.ADR6Table, NewADR6Table, New ZADDR_SAVE_INTERN.ADR6Table,
                                   New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table,
                                   New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table,
                                   New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table,
                                   New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable,
                                   New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable,
                                   New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable,
                                   New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable,
                                   New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable,
                                  New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable,
                                   New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable,
                                   New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable,
                                   New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable)
                    proxy1.Connection.Close()
                    result = True
                End If
            Catch ex As Exception
                result = False
            End Try
        End If
        Return result
    End Function

    Shared Function FormatItmNumber(ByVal ItemNumber As Integer) As String
        Dim Zeros As Integer = 6 - ItemNumber.ToString.Length
        If Zeros = 0 Then Return ItemNumber.ToString()
        Dim strItemNumber As String = ItemNumber.ToString()
        For i As Integer = 0 To Zeros - 1
            strItemNumber = "0" + strItemNumber
        Next
        Return strItemNumber
    End Function

#Region "Get Data From Local"
    Public Shared Function GetCompanyDataFromLocal(ByVal companyid As String, ByVal OrgId As String) As DataTable
        Dim strSql As String = _
            " SELECT TOP 1 COMPANY_ID, ORG_ID, PARENTCOMPANYID, COMPANY_NAME, ADDRESS, FAX_NO, TEL_NO,  " + _
            " COMPANY_TYPE, PRICE_CLASS, CURRENCY, COUNTRY, REGION_CODE, ZIP_CODE, CITY, ATTENTION,  " + _
            " CREDIT_TERM, SHIP_VIA, URL, SHIPCONDITION, ATTRIBUTE4, SALESOFFICE, SALESGROUP, AMT_INSURED,  " + _
            " CREDIT_LIMIT, CONTACT_EMAIL, DELETION_FLAG, COUNTRY_NAME, SALESOFFICENAME, SAP_SALESNAME,  " + _
            " SAP_SALESCODE, SAP_ISNAME, SAP_OPNAME " + _
            " FROM SAP_DIMCOMPANY " + _
            " WHERE COMPANY_ID = @CID AND ORG_ID =@OID "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        apt.SelectCommand.Parameters.AddWithValue("CID", companyid) : apt.SelectCommand.Parameters.AddWithValue("OID", OrgId)
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function
#End Region
    Class OrgPN
        Private _Org As String = ""
        Public Property Org As String
            Get
                Return _Org
            End Get
            Set(ByVal value As String)
                _Org = value
            End Set
        End Property
        Private _Plant As String = ""
        Public Property Plant As String
            Get
                Return _Plant
            End Get
            Set(ByVal value As String)
                _Plant = value
            End Set
        End Property
        Private _PN As String = ""
        Public Property PN As String
            Get
                Return _PN
            End Get
            Set(ByVal value As String)
                _PN = value
            End Set
        End Property
    End Class
    Class PNCostInfo
        Private _Org As String = ""
        Public Property Org As String
            Get
                Return _Org
            End Get
            Set(ByVal value As String)
                _Org = value
            End Set
        End Property
        Private _PN As String = ""
        Public Property PN As String
            Get
                Return _PN
            End Get
            Set(ByVal value As String)
                _PN = value
            End Set
        End Property
        Private _CostCurrency As String = ""
        Public Property CostCurrency As String
            Get
                Return _CostCurrency
            End Get
            Set(ByVal value As String)
                _CostCurrency = value
            End Set
        End Property
        Private _Cost As Decimal = 0
        Public Property Cost As Decimal
            Get
                Return _Cost
            End Get
            Set(ByVal value As Decimal)
                _Cost = value
            End Set
        End Property
        Private _Inventory As Integer = 0
        Public Property Inventory As Integer
            Get
                Return _Inventory
            End Get
            Set(ByVal value As Integer)
                _Inventory = value
            End Set
        End Property
        Private _ProductStatus As String = ""
        Public Property ProductStatus As String
            Get
                Return _ProductStatus
            End Get
            Set(ByVal value As String)
                _ProductStatus = value
            End Set
        End Property
        Private _Plant As String = ""
        Public Property Plant As String
            Get
                Return _Plant
            End Get
            Set(ByVal value As String)
                _Plant = value
            End Set
        End Property
    End Class
    <WebMethod()> _
    Public Function GetProductCostByOrg(ByVal LPNByPlant As List(Of OrgPN), _
                             ByRef ErrorMessage As String) As List(Of PNCostInfo)
        Try
            Dim LRet As New List(Of PNCostInfo)
            Dim APN As New ArrayList
            If Not IsNothing(LPNByPlant) AndAlso LPNByPlant.Count > 0 Then
                For Each PO As OrgPN In LPNByPlant
                    Dim o As New PNCostInfo : o.PN = PO.PN : o.Plant = PO.Plant : o.Org = PO.Org
                    LRet.Add(o)
                    APN.Add(Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PO.PN)).ToUpper())
                Next
            End If
            Dim partCond As String = ""
            If Not IsNothing(APN) AndAlso APN.Count > 0 Then
                partCond = " and a.matnr in ('" & String.Join("','", APN.ToArray) & "')"
            End If

            Dim dtCost As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
                               " select distinct a.matnr as part_no, a.bwkey as plant, b.vkorg as sales_org, c.waers as currency, " + _
                               " a.STPRS as standard_price, s.vmsta as status,  " + _
                               " a.VERPR as moving_price, a.VPRSV as price_control, a.PEINH as price_unit, a.STPRS as external_standard_price, 0 as update_flag  " + _
                               " from saprdp.mbew a inner join saprdp.tvkwz b on a.bwkey=b.werks inner join saprdp.t001 c on b.vkorg=c.bukrs inner join saprdp.mvke s on a.matnr=s.matnr and a.bwkey=s.dwerk " + _
                               " where a.mandt='168' and b.mandt='168' and c.mandt='168' and s.mandt='168' " & partCond)

            If Not IsNothing(dtCost) AndAlso dtCost.Rows.Count > 0 Then
                For Each r As PNCostInfo In LRet
                    Dim dtr As DataRow = dtCost.Select("part_no='" & Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(r.PN)).ToUpper() & "' and plant='" & r.Plant.ToUpper & "' and sales_org='" & r.Org.ToUpper & "'").FirstOrDefault
                    If Not IsNothing(dtr) AndAlso Not IsDBNull(dtr.Item("part_no")) AndAlso Not IsDBNull(dtr.Item("plant")) _
                        AndAlso Not IsDBNull(dtr.Item("currency")) AndAlso Not IsDBNull(dtr.Item("standard_price")) Then
                        r.CostCurrency = dtr.Item("currency")
                        r.Cost = dtr.Item("standard_price")
                        If Not IsDBNull(dtr.Item("status")) Then
                            r.ProductStatus = dtr.Item("status")
                        End If
                    End If
                Next
                Return LRet
            End If
            Return Nothing
        Catch ex As Exception
            ErrorMessage = ex.Message
        End Try
        Return Nothing
    End Function
    <WebMethod()> _
    Public Function GetSAPCustomerPartnerFunction(ByVal ERPID As String, ByVal Org_id As String) As DataTable
        Dim dt As New DataTable
        If String.IsNullOrEmpty(ERPID) Or String.IsNullOrEmpty(Org_id) Then Return New DataTable("SAPPF")
        ERPID = Replace(Trim(ERPID).ToUpper, "'", "")
        Dim sb As New System.Text.StringBuilder
        'With sb
        '    .AppendLine(" SELECT A.KUNN2 AS company_id,B.NAME1 AS COMPANY_NAME, B.STRAS AS ADDRESS, ")
        '    .AppendLine(" B.Land1 AS  COUNTRY,B.Ort01 AS CITY, B.PSTLZ AS ZIP_CODE, ")
        '    .AppendLine(" (select adrc.region from saprdp.adrc where adrc.country=B.land1 and adrc.addrnumber=B.adrnr and rownum=1) AS STATE,  ")
        '    .AppendLine(" C.smtp_addr AS CONTACT_EMAIL,B.TELF1 AS TEL_NO,B.TELFX AS FAX_NO, ")
        '    .AppendLine(" case A.PARVW when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' when 'RE' then 'Bill-To' end as PARTNER_FUNCTION  ")
        '    .AppendLine("  FROM saprdp.knvp A ")
        '    .AppendLine("  INNER JOIN saprdp.kna1 B on A.KUNN2 = B.KUNNR inner join saprdp.adr6 C on B.adrnr=C.addrnumber ")
        '    .AppendFormat("  where A.Kunnr ='{0}'  AND A.PARVW in ('WE','AG','RE') ORDER BY A.Kunn2 ", ERPID)
        'End With
        With sb
            .AppendLine(" SELECT A.KUNN2 AS company_id,B.NAME1 AS COMPANY_NAME, B.STRAS AS ADDRESS,  B.Land1 AS  COUNTRY,B.Ort01 AS CITY, B.PSTLZ AS ZIP_CODE, D.region AS STATE,  C.smtp_addr AS CONTACT_EMAIL,B.TELF1 AS TEL_NO,B.TELFX AS FAX_NO, ")
            .AppendLine(" case A.PARVW when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' when 'RE' then 'Bill-To' end as PARTNER_FUNCTION ")
            .AppendLine(" FROM saprdp.knvp A  ")
            .AppendLine(" INNER JOIN saprdp.kna1 B on A.KUNN2 = B.KUNNR inner join saprdp.adr6 C on B.adrnr=C.addrnumber ")
            .AppendLine(" inner join saprdp.adrc D on  D.country=B.land1 and D.addrnumber=B.adrnr  ")
            .AppendLine(" where ")
            .AppendFormat("  A.Kunnr = '{0}' ", ERPID)
            .AppendFormat(" AND A.PARVW = 'AG' AND A.VKORG='{0}' and rownum=1 ORDER BY A.Kunn2 ", Org_id)
        End With
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "SAPPF"
        'If dt.Rows.Count > 0 Then
        '    Return dt
        'End If
        Return dt
    End Function
    <WebMethod()> _
    Public Function GetSAPCustomerPartnerFunctionByParameters(ByVal ERPID As String, ByVal Org_id As String, ByVal CompanyName As String, ByVal Address As String, ByVal State As String) As DataTable
        Dim dt As New DataTable
        If String.IsNullOrEmpty(ERPID) Then Return New DataTable("SAPPF")
        ERPID = Replace(Trim(ERPID).ToUpper, "'", "")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT A.KUNN2 AS company_id,B.NAME1 AS COMPANY_NAME, B.STRAS AS ADDRESS,  B.Land1 AS  COUNTRY,B.Ort01 AS CITY, B.PSTLZ AS ZIP_CODE, D.region AS STATE,  C.smtp_addr AS CONTACT_EMAIL,B.TELF1 AS TEL_NO,B.TELFX AS FAX_NO, ")
            .AppendLine(" case A.PARVW when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' when 'RE' then 'Bill-To' end as PARTNER_FUNCTION ")
            .AppendLine(" FROM saprdp.knvp A  ")
            .AppendLine(" INNER JOIN saprdp.kna1 B on A.KUNN2 = B.KUNNR inner join saprdp.adr6 C on B.adrnr=C.addrnumber ")
            .AppendLine(" inner join saprdp.adrc D on  D.country=B.land1 and D.addrnumber=B.adrnr  ")
            .AppendLine(" where ")
            .AppendFormat(" D.region LIKE '%{0}%' AND B.STRAS LIKE '%{1}%' AND B.NAME1 LIKE '%{2}%' AND A.Kunnr LIKE '%{3}%' ", State.Replace("'", "''").Trim, Address.Replace("'", "''").Trim, CompanyName.Replace("'", "''").Trim, ERPID)
            .AppendFormat(" AND A.PARVW in ('WE','AG','RE') AND A.VKORG='{0}' ORDER BY A.Kunn2 ", Org_id)
        End With
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "SAPPF"
        Return dt
    End Function
    <WebMethod()> _
    Public Function GetOrderListFromSAP(ByVal PoNo As String, ByVal SoNo As String, ByVal CompanyID As String, ByVal OrgID As String, ByVal OrderDateFrom As DateTime, ByVal OrderDateTo As DateTime) As DataTable
        '  If String.IsNullOrEmpty(OrgID) Then Return New DataTable("SAPPF")
        PoNo = Replace(Trim(PoNo.ToUpper), "'", "")
        SoNo = Replace(Trim(SoNo.ToUpper), "'", "")
        CompanyID = Replace(Trim(CompanyID.ToUpper), "'", "")
        OrgID = Replace(Trim(OrgID.ToUpper), "'", "")
        If DateTime.TryParse(OrderDateFrom, Date.Now()) = False OrElse DateTime.TryParse(OrderDateTo, Date.Now()) = False Then
            Return New DataTable("SAPPF")
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select VBAK.VBELN AS SoNo, VBAK.BSTNK AS PoNo, VBAK.KUNNR as SOLDTOID, ")
            .AppendLine(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='RE' and rownum=1) AS BILLTOID, ")
            .AppendLine(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID,    VBAK.BUKRS_VF AS ORG_ID,")
            .AppendFormat(" VBAK.AUDAT AS ORDERDATE  from SAPRDP.VBAK where VBAK.AUDAT between '{0}' and '{1}' and ", OrderDateFrom.ToString("yyyyMMdd"), OrderDateTo.ToString("yyyyMMdd"))
            .AppendFormat(" VBAK.KUNNR like '%{0}%' and ", CompanyID)
            .AppendFormat("  VBAK.BSTNK like '%{0}%' and VBAK.VBELN like '%{1}%' and VBAK.BUKRS_VF LIKE '%{2}%' AND ", PoNo, SoNo, OrgID)
            .AppendFormat(" rownum<=30 ")
            .AppendLine("  order by  VBAK.AUDAT desc")
        End With
        Dim dt As New DataTable
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "SAPOrders"
        If dt.Rows.Count > 0 Then
            Return dt
        End If
        Return New DataTable("SAPOrders")
    End Function
    <WebMethod()> _
    Public Function GetOrderDetailFromSAPByPoNo(ByVal PoNo As String) As DataTable
        If String.IsNullOrEmpty(PoNo) Then Return New DataTable("SAPDT")
        PoNo = Replace(Trim(PoNo.ToUpper), "'", "")
        If Global_Inc.IsNumericItem(PoNo) Then
            PoNo = Global_Inc.Format2SAPItem2(PoNo)
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine("  select cast(VBAP.POSNR as integer) AS Lineno, VBAP.MATWA AS  Partno,  ")
            .AppendLine("  VBAP.LSMENG AS  Qty, VBAP.ZZ_EDATU AS ReqDate, VBAP.NETPR AS UnitPrice,VBAP.NETWR AS  Amount ")
            .AppendFormat(" from   saprdp.VBAP where VBAP.VBELN ='{0}'  ", PoNo)
            .AppendLine(" order by Lineno ")
        End With
        Dim dt As New DataTable
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "SAPOrders"
        If dt.Rows.Count > 0 Then
            Return dt
        End If
        Return New DataTable("SAPDT")
    End Function
    Public Shared Function UpdateTranspZoneV2(ByVal CompanyId As String, _
        ByVal Orgid As String, ByVal Sort1 As String, ByVal Sort2 As String, Optional ByVal ConnectToSAPPRD As Boolean = True) As Boolean
        Try
            For i As Integer = 0 To 3
                If CreateSAPCustomerDAL.checkSAPErp(CompanyId) Then
                    Exit For
                End If
                If i = 3 Then
                    Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Find SAP Erp Failed.", "", True, "", "")
                    Exit For
                End If
                Threading.Thread.Sleep(1000)
            Next
            'Dim p2 As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPI_CUSTOMER_CHANGEFROMDATA1
            'Dim SAPconnection2 As String = "SAP_PRD"
            'If ConnectToSAPPRD = False Then
            '    SAPconnection2 = "SAPConnTest"
            'End If
            'p2.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection2))
            'p2.Connection.Open()
            'Dim p_info As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA101_1
            'Dim p_info_x As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA101_1X
            'Dim c_info As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA105
            'Dim c_info_x As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA105X
            'Dim ret As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIRETURN1
            'c_info.Transpzone = "0000000001" : c_info_x.Transpzone = "X"

            'p_info.City = City : p_info.Country = CountryCode : p_info.E_Mail = "ebiz.aeu@advantech.eu" : p_info.Firstname = "ebiz" : p_info.Lastname = "aeu"
            'p_info.Street = Address : p_info.Langu_P = "English" : p_info.Currency = "EUR" : p_info.Postl_Cod1 = "00000"
            'p2.Bapi_Customer_Changefromdata1(CompanyId, Nothing, Nothing, "00", "00", Nothing, Nothing, c_info, c_info_x, p_info, p_info_x, "EU10", ret)
            'p2.CommitWork() : p2.Connection.Close()
            Dim SAPconnection2 As String = "SAP_PRD"
            If ConnectToSAPPRD = False Then
                SAPconnection2 = "SAPConnTest"
            End If
            Dim p1 As New BAPI_ZSD_CHANGE_CUSTOMER.BAPI_ZSD_CHANGE_CUSTOMER
            p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection2))
            p1.Connection.Open()
            Dim errstr As String = String.Empty
            p1.Zsd_Change_Customer(Orgid, CompanyId, Sort1, Sort2, "0000000001", errstr)
            p1.CommitWork() : p1.Connection.Close()
            If Not String.IsNullOrEmpty(errstr) Then
                Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn", _
                                             "tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", _
                                             "Bapi_Customer_Changefromdata1 succeeded updated by " + HttpContext.Current.Session("user_id").ToString, "", CompanyId + ": ->  " + errstr)
            End If
        Catch ex As Exception
            Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn", _
                                                "tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", _
                                                "Bapi_Customer_Changefromdata1 Failed updated by " + HttpContext.Current.Session("user_id").ToString, "", CompanyId + ": ->  " + ex.ToString)
            Return False
        End Try
        Return True
    End Function
    Public Shared Function UpdateTranspZone(ByVal CompanyId As String,
         ByVal City As String, ByVal CountryCode As String, ByVal Address As String, Optional ByVal ConnectToSAPPRD As Boolean = True) As Boolean
        Try
            For i As Integer = 0 To 3
                If CreateSAPCustomerDAL.checkSAPErp(CompanyId) Then
                    Exit For
                End If
                If i = 3 Then
                    Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Find SAP Erp Failed.", "", True, "", "")
                    Exit For
                End If
                Threading.Thread.Sleep(1000)
            Next
            Dim p2 As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPI_CUSTOMER_CHANGEFROMDATA1
            Dim SAPconnection2 As String = "SAP_PRD"
            If ConnectToSAPPRD = False Then
                SAPconnection2 = "SAPConnTest"
            End If
            p2.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection2))
            p2.Connection.Open()
            Dim p_info As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA101_1
            Dim p_info_x As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA101_1X
            Dim c_info As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA105
            Dim c_info_x As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIKNA105X
            Dim ret As New BAPI_CUSTOMER_CHANGEFROMDATA1.BAPIRETURN1
            c_info.Transpzone = "0000000001" : c_info_x.Transpzone = "X"

            p_info.City = City : p_info.Country = CountryCode : p_info.E_Mail = "ebiz.aeu@advantech.eu" : p_info.Firstname = "ebiz" : p_info.Lastname = "aeu"
            p_info.Street = Address : p_info.Langu_P = "English" : p_info.Currency = "EUR" : p_info.Postl_Cod1 = "00000"
            p2.Bapi_Customer_Changefromdata1(CompanyId, Nothing, Nothing, "00", "00", Nothing, Nothing, c_info, c_info_x, p_info, p_info_x, "EU10", ret)
            p2.CommitWork() : p2.Connection.Close()
            If ret IsNot Nothing AndAlso ret.Message IsNot Nothing Then
                Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn",
                                             "tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn",
                                             "Bapi_Customer_Changefromdata1 succeeded", "", CompanyId + ": ->  " + ret.Message.ToString)
            End If
        Catch ex As Exception
            Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn",
                                                "tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn",
                                                "Bapi_Customer_Changefromdata1 Failed", "", CompanyId + ": ->  " + ex.ToString)
            Return False
        End Try
        Return True
    End Function



    Public Shared Function UpdateCustomerCreditLimit(
       ByVal CompanyId As String, ByVal CreditControlArea As String, ByVal CreditLimit As Decimal, ByVal RiskInventoryCode As String,
       ByVal CreditRepGrpCode As String, ByRef ErrMsg As String, Optional ByVal ConnectToSAPPRD As Boolean = True) As Boolean

        CompanyId = Trim(UCase(CompanyId)) : CreditControlArea = Trim(UCase(CreditControlArea))
        Dim SAPconnection As String = "SAP_PRD"
        If ConnectToSAPPRD = False Then
            SAPconnection = "SAP_Test"
        End If
        'For i As Integer = 0 To 3
        '    If CreateSAPCustomerDAL.checkSAPErp(CompanyId) Then
        '        Exit For
        '    End If
        '    If i = 3 Then
        '        ErrMsg = "Cannot find " + CompanyId + " in kna1"
        '        Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "UpdateCustomerCreditLimit Failed...", ErrMsg, True, "", "")
        '        Exit For
        '    End If
        '    Threading.Thread.Sleep(1000)
        'Next
        '\原来逻辑，确保成功，先暂时保留
        Dim kna1_dt As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, "select Name1 from  saprdp.kna1  where Kunnr ='" + CompanyId + "'")
        'Dim dtKNKA As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, "select * from saprdp.knka where kunnr='" + CompanyId + "'")
        Dim dtKNKK As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, "select * from saprdp.knkk where kunnr='" + CompanyId + "' and Kkber='" + CreditControlArea + "'")
        Dim willdo As String = "U"
        If kna1_dt.Rows.Count = 0 Then
            ErrMsg = "Cannot find " + CompanyId + " in kna1"
            Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn", "tc.chen@advantech.com.tw",
                                              "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "UpdateCustomerCreditLimit Failed..", "", ErrMsg)
            Return False
        End If
        '/ end
        'If dtKNKA.Rows.Count = 0 Then 'And dtKNKK.Rows.Count = 0 Then
        '    ' ErrMsg = "Cannot find " + CompanyId + " in " + CreditControlArea : Return False
        'End If
        If dtKNKK.Rows.Count = 0 Then
            willdo = "I"
            ' dtKNKK = OraDbUtil.dbGetDataTable("SAP_PRD", "select * from saprdp.knkk where kunnr='ENBECE01' and Kkber='" + CreditControlArea + "'")
        End If
        Dim p1 As New ZCREDITLIMIT_CHANGE.ZCREDITLIMIT_CHANGE
        Dim strSAPConn As String = ConfigurationManager.AppSettings("SAP_PRD")
        If Not ConnectToSAPPRD Then strSAPConn = ConfigurationManager.AppSettings("SAPConnTest")
        p1.Connection = New SAP.Connector.SAPConnection(strSAPConn)
        'Dim updKNKA As New ZCREDITLIMIT_CHANGE.KNKA
        Dim updKNKK As New ZCREDITLIMIT_CHANGE.KNKK
        'If dtKNKA.Rows.Count > 0 Then
        '    With updKNKA
        '        .Dlaus = dtKNKA.Rows(0).Item("Dlaus") : .Klime = dtKNKA.Rows(0).Item("Klime") : .Klimg = dtKNKA.Rows(0).Item("Klimg")
        '        .Kunnr = dtKNKA.Rows(0).Item("Kunnr") : .Mandt = dtKNKA.Rows(0).Item("Mandt") : .Waers = dtKNKA.Rows(0).Item("Waers")
        '    End With
        'End If
        With updKNKK
            If dtKNKK.Rows.Count > 0 Then
                .Absbt = dtKNKK.Rows(0).Item("Absbt") : .Aedat = dtKNKK.Rows(0).Item("Aedat") : .Aenam = dtKNKK.Rows(0).Item("Aenam") : .Aetxt = dtKNKK.Rows(0).Item("Aetxt")
                .Casha = dtKNKK.Rows(0).Item("Casha") : .Cashc = dtKNKK.Rows(0).Item("Cashc") : .Cashd = dtKNKK.Rows(0).Item("Cashd") : .Crblb = dtKNKK.Rows(0).Item("Crblb")
                .Ctlpc = dtKNKK.Rows(0).Item("Ctlpc") : .Dbekr = dtKNKK.Rows(0).Item("Dbekr") : .Dbmon = dtKNKK.Rows(0).Item("Dbmon") : .Dbpay = dtKNKK.Rows(0).Item("Dbpay")
                .Dbrat = dtKNKK.Rows(0).Item("Dbrat") : .Dbrtg = dtKNKK.Rows(0).Item("Dbrtg") : .Dbwae = dtKNKK.Rows(0).Item("Dbwae") : .Dtrev = dtKNKK.Rows(0).Item("Dtrev")
                .Erdat = dtKNKK.Rows(0).Item("Erdat") : .Ernam = dtKNKK.Rows(0).Item("Ernam") : .Grupp = dtKNKK.Rows(0).Item("Grupp") : .Kdgrp = dtKNKK.Rows(0).Item("Kdgrp")
                .Kkber = dtKNKK.Rows(0).Item("Kkber") : .Klimk = dtKNKK.Rows(0).Item("Klimk") : .Knkli = dtKNKK.Rows(0).Item("Knkli") : .Kraus = dtKNKK.Rows(0).Item("Kraus")
                .Kunnr = CompanyId 'dtKNKK.Rows(0).Item("Kunnr")
                .Mandt = dtKNKK.Rows(0).Item("Mandt") : .Nxtrv = dtKNKK.Rows(0).Item("Nxtrv") : .Paydb = dtKNKK.Rows(0).Item("Paydb")
                .Revdb = dtKNKK.Rows(0).Item("Revdb") : .Sauft = dtKNKK.Rows(0).Item("Sauft") : .Sbdat = dtKNKK.Rows(0).Item("Sbdat") : .Sbgrp = dtKNKK.Rows(0).Item("Sbgrp")
                .Skfor = dtKNKK.Rows(0).Item("Skfor") : .Ssobl = dtKNKK.Rows(0).Item("Ssobl") : .Uedat = dtKNKK.Rows(0).Item("Uedat") : .Xchng = dtKNKK.Rows(0).Item("Xchng")
                .Kunnr = CompanyId : .Klimk = CreditLimit : .Ctlpc = RiskInventoryCode
                If Not String.IsNullOrEmpty(CreditRepGrpCode.Trim) Then
                    .Sbgrp = CreditRepGrpCode
                End If
                ' .Kkber = CreditControlArea 
            Else
                .Mandt = 168 : .Kunnr = CompanyId : .Kkber = CreditControlArea
                .Klimk = CreditLimit : .Knkli = CompanyId : .Sauft = 0 : .Skfor = 0 : .Ssobl = 0
                .Uedat = 0 : .Xchng = "" : .Ernam = "B2BAEU"
                .Erdat = Now.ToString("yyyyMMdd") : .Ctlpc = RiskInventoryCode
                .Dtrev = "0" : .Crblb = "" : .Sbgrp = CreditRepGrpCode : .Nxtrv = "0"
                .Kraus = "" : .Paydb = "0" : .Dbrat = ""
                .Revdb = "0" : .Aedat = Now.ToString("yyyyMMdd") : .Aetxt = Now.ToString("yyyyMMdd")
                .Grupp = "" : .Aenam = "B2BAEU" : .Sbdat = "0"
                .Kdgrp = "" : .Cashd = "20100824" : .Casha = 103
                .Cashc = "EUR" : .Dbpay = "" : .Dbrtg = ""
                .Dbekr = 0 : .Dbwae = "" : .Dbmon = "0" : .Absbt = 0
                If String.IsNullOrEmpty(CreditRepGrpCode.Trim) Then
                    .Sbgrp = "330"
                End If
            End If
        End With
        p1.Connection.Open()
        Try
            'p1.Zcreditlimit_Change(updKNKA, updKNKK, "U", willdo, " ", " ", updKNKA, updKNKK)
            p1.Zcreditlimit_Change(Nothing, updKNKK, "", willdo, " ", " ", Nothing, updKNKK)
            p1.CommitWork()
            p1.Connection.Close()
            Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn",
                                             "ming.zhao@advantech.com.cn,ming.zhao@advantech.com.cn", "UpdateCustomerCreditLimit succeeded: ErpID (" + CompanyId + ") ", "", ErrMsg + "<hr/>" + willdo)
            Return True
        Catch ex As Exception
            ErrMsg = ex.ToString()
            Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "ming.zhao@advantech.com.cn", "tc.chen@advantech.com.tw",
                                                "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "UpdateCustomerCreditLimit Failed: ErpID (" + CompanyId + ") ", "", ErrMsg)
            p1.Connection.Close()
            Return False
        End Try


    End Function

    Public Shared Function UpdateCustomerCreditLimitV2(
       ByVal CompanyId As String, ByVal CreditControlArea As String, ByVal CreditLimit As Decimal, ByVal RiskCategoryCode As String,
       ByVal CreditRepGrpCode As String, ByVal Currency As String, ByRef ErrMsg As String, Optional ByVal ConnectToSAPPRD As Boolean = True) As Boolean
        CompanyId = Trim(UCase(CompanyId)) : CreditControlArea = Trim(UCase(CreditControlArea))
        Dim SAPconnection As String = "SAP_PRD"
        If ConnectToSAPPRD = False Then SAPconnection = "SAP_Test"
        Dim UpdateFlag As String = ""
        If Currency = "TWD" Then CreditLimit = CreditLimit / 100
        Dim dtKNKK As DataTable = OraDbUtil.dbGetDataTable(SAPconnection,
            "select * from saprdp.knkk where kunnr='" + CompanyId + "' and Kkber='" + CreditControlArea + "'")
        Dim p1 As New ZCREDITLIMIT_CHANGE.ZCREDITLIMIT_CHANGE
        Dim strSAPConn As String = ConfigurationManager.AppSettings("SAP_PRD")
        If Not ConnectToSAPPRD Then strSAPConn = ConfigurationManager.AppSettings("SAPConnTest")
        p1.Connection = New SAPConnection(strSAPConn)
        Dim updKNKK As New ZCREDITLIMIT_CHANGE.KNKK
        With updKNKK
            If dtKNKK.Rows.Count > 0 Then
                UpdateFlag = "U"
                .Absbt = dtKNKK.Rows(0).Item("Absbt") : .Aedat = dtKNKK.Rows(0).Item("Aedat") : .Aenam = dtKNKK.Rows(0).Item("Aenam") : .Aetxt = dtKNKK.Rows(0).Item("Aetxt")
                .Casha = dtKNKK.Rows(0).Item("Casha") : .Cashc = dtKNKK.Rows(0).Item("Cashc") : .Cashd = dtKNKK.Rows(0).Item("Cashd") : .Crblb = dtKNKK.Rows(0).Item("Crblb")
                .Ctlpc = dtKNKK.Rows(0).Item("Ctlpc") : .Dbekr = dtKNKK.Rows(0).Item("Dbekr") : .Dbmon = dtKNKK.Rows(0).Item("Dbmon") : .Dbpay = dtKNKK.Rows(0).Item("Dbpay")
                .Dbrat = dtKNKK.Rows(0).Item("Dbrat") : .Dbrtg = dtKNKK.Rows(0).Item("Dbrtg") : .Dbwae = dtKNKK.Rows(0).Item("Dbwae") : .Dtrev = dtKNKK.Rows(0).Item("Dtrev")
                .Erdat = dtKNKK.Rows(0).Item("Erdat") : .Ernam = dtKNKK.Rows(0).Item("Ernam") : .Grupp = dtKNKK.Rows(0).Item("Grupp") : .Kdgrp = dtKNKK.Rows(0).Item("Kdgrp")
                .Kkber = dtKNKK.Rows(0).Item("Kkber") : .Klimk = dtKNKK.Rows(0).Item("Klimk") : .Knkli = dtKNKK.Rows(0).Item("Knkli") : .Kraus = dtKNKK.Rows(0).Item("Kraus")
                .Kunnr = CompanyId
                .Mandt = dtKNKK.Rows(0).Item("Mandt") : .Nxtrv = dtKNKK.Rows(0).Item("Nxtrv") : .Paydb = dtKNKK.Rows(0).Item("Paydb")
                .Revdb = dtKNKK.Rows(0).Item("Revdb") : .Sauft = dtKNKK.Rows(0).Item("Sauft") : .Sbdat = dtKNKK.Rows(0).Item("Sbdat")
                .Sbgrp = dtKNKK.Rows(0).Item("Sbgrp") : .Skfor = dtKNKK.Rows(0).Item("Skfor") : .Ssobl = dtKNKK.Rows(0).Item("Ssobl")
                .Uedat = dtKNKK.Rows(0).Item("Uedat") : .Xchng = dtKNKK.Rows(0).Item("Xchng")
                .Kunnr = CompanyId : .Klimk = CreditLimit : .Ctlpc = dtKNKK.Rows(0).Item("Ctlpc")
                If Not String.IsNullOrEmpty(RiskCategoryCode.Trim) Then .Ctlpc = RiskCategoryCode
                If Not String.IsNullOrEmpty(CreditRepGrpCode.Trim) Then .Sbgrp = CreditRepGrpCode
            Else
                UpdateFlag = "I"
                .Mandt = 168 : .Kunnr = CompanyId : .Kkber = CreditControlArea
                .Klimk = CreditLimit : .Knkli = CompanyId : .Sauft = 0 : .Skfor = 0 : .Ssobl = 0
                .Uedat = 0 : .Xchng = "" : .Ernam = "B2BAEU"
                .Erdat = Now.ToString("yyyyMMdd") : .Ctlpc = RiskCategoryCode
                .Dtrev = "0" : .Crblb = "" : .Sbgrp = CreditRepGrpCode : .Nxtrv = "0"
                .Kraus = "" : .Paydb = "0" : .Dbrat = ""
                .Revdb = "0" : .Aedat = Now.ToString("yyyyMMdd") : .Aetxt = Now.ToString("yyyyMMdd")
                .Grupp = "" : .Aenam = "B2BAEU" : .Sbdat = "0"
                .Kdgrp = ""
                .Cashd = "00000000" 'Date of last payment
                .Casha = 0 ' Amount of last payment
                .Cashc = Currency : .Dbpay = "" : .Dbrtg = ""
                .Dbekr = 0 : .Dbwae = "" : .Dbmon = "0" : .Absbt = 0
            End If
        End With
        p1.Connection.Open()
        p1.Zcreditlimit_Change(Nothing, updKNKK, "", UpdateFlag, " ", " ", Nothing, updKNKK)
        p1.CommitWork()
        p1.Connection.Close()
        Return True
    End Function

    Public Shared Function IsNumericItem(ByVal part_no As String) As Boolean

        Dim pChar() As Char = part_no.ToCharArray()

        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next

        Return True
    End Function

    Public Shared Function FormatDate(ByVal xDate, ByVal xFormat) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"

        If IsDate(xDate) = True Then
            xYear = Year(xDate).ToString
            xMonth = Month(xDate).ToString
            xDay = Day(xDate).ToString
        Else
            Dim ArrDate() As String = xDate.Split("/")

            If ArrDate(0).Length = 4 Then
                xYear = ArrDate(0)
                xMonth = ArrDate(1)
                xDay = ArrDate(2)
            ElseIf UBound(ArrDate) >= 2 Then
                xYear = ArrDate(2)
                xMonth = ArrDate(0)
                xDay = ArrDate(1)
            ElseIf UBound(ArrDate) = 0 Then
                If ArrDate(0).Length = 8 Then
                    xYear = Left(ArrDate(0), 4)
                    xMonth = Mid(ArrDate(0), 5, 2)
                    xDay = Right(ArrDate(0), 2)
                End If
            End If
        End If

        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        Select Case LCase(xFormat)
            Case "yyyy/mm/dd"
                FormatDate = xYear & "/" & xMonth & "/" & xDay
            Case "mm/dd/yy"
                FormatDate = xMonth & "/" & xDay & "/" & xYear
            Case Else
                FormatDate = xYear & "/" & xMonth & "/" & xDay
        End Select
        'If xYear = "0000" And xMonth = "00" And xDay = "00" Then               ' Modified by Siaowei.Jhai    2006/12/27
        '    FormatDate = ""
        'Else
        '    FormatDate = xYear & "/" & xMonth & "/" & xDay
        'End If
    End Function

    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty!"
    End Function
    <WebMethod()> _
    Public Function GetSAPPartnerAddressesTableByKunnr(ByVal ErpID As String) As SAPDAL.SalesOrder.PartnerAddressesDataTable
        If String.IsNullOrEmpty(ErpID) Then Return Nothing
        Dim Ptnrdt As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(ErpID)
        If Ptnrdt.Rows.Count > 0 Then
            Return Ptnrdt
        End If
        Return Nothing
    End Function

    'IC 2014/07/31 Supply web method for eStore to get SAP parts cost by ORG_ID and Part_No
    <WebMethod()> _
    Public Function GetSAPPNCost(ByVal PartNos() As String, ByVal OrgID As String) As DataTable
        If PartNos.Count > 0 AndAlso Not String.IsNullOrEmpty(OrgID) Then
            Dim sb As New StringBuilder()
            For i = 0 To PartNos.Count - 1
                PartNos(i) = Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PartNos(i))).ToUpper()
                If i > 0 Then
                    sb.Append(String.Format(" or a.matnr = '{0}' ", PartNos(i)))
                Else
                    sb.Append(String.Format(" a.matnr = '{0}' ", PartNos(i)))
                End If
            Next
            Dim dtSAPStatus As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format(" select a.matnr as PART_NO, a.werks as PLANT, a.maabc as ABC_INDICATOR, " & _
                    " a.EISBE as safety_stock, a.EISLO as min_safety_stock, b.vmsta as status, b.vkorg as org_id " & _
                    " from saprdp.marc a inner join saprdp.mvke b on a.matnr=b.matnr and a.werks=b.dwerk " & _
                    " where a.mandt='168' and b.mandt='168' and b.vkorg='{0}' and ({1}) ", OrgID, sb.ToString()))
            If Not dtSAPStatus Is Nothing AndAlso dtSAPStatus.Rows.Count > 0 Then
                Dim dtSAPCost As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format(" select distinct a.matnr as part_no, a.bwkey as plant, b.vkorg as sales_org, c.waers as currency, " & _
                     " a.STPRS as standard_price, a.VERPR as moving_price, a.VPRSV as price_control, a.PEINH as price_unit, a.STPRS as external_standard_price " & _
                     " from saprdp.mbew a inner join saprdp.tvkwz b on a.bwkey=b.werks inner join saprdp.t001 c on b.vkorg=c.bukrs " & _
                     " where a.mandt='168' and b.mandt='168' and c.mandt='168' and ({0})", sb.ToString()))
                If Not dtSAPCost Is Nothing AndAlso dtSAPCost.Rows.Count > 0 Then
                    Dim dtCost As New DataTable()
                    dtCost.Columns.Add(New DataColumn("PART_NO", GetType(String)))
                    dtCost.Columns.Add(New DataColumn("SALES_ORG", GetType(String)))
                    dtCost.Columns.Add(New DataColumn("PLANT", GetType(String)))
                    dtCost.Columns.Add(New DataColumn("CURRENCY", GetType(String)))
                    dtCost.Columns.Add(New DataColumn("COST", GetType(Decimal)))
                    For Each dr As DataRow In dtSAPStatus.Rows
                        Dim rCost() As DataRow = dtSAPCost.Select(String.Format("PLANT = '{0}' AND SALES_ORG = '{1}' AND PART_NO = '{2}' ", dr.Item("PLANT").ToString(), dr.Item("ORG_ID").ToString(), dr.Item("PART_NO").ToString()))
                        If Not rCost Is Nothing AndAlso rCost.Length > 0 Then
                            For Each cost As DataRow In rCost
                                Dim row As DataRow = dtCost.NewRow()
                                row("PART_NO") = cost.Item("PART_NO").ToString()
                                row("SALES_ORG") = cost.Item("SALES_ORG").ToString()
                                row("PLANT") = cost.Item("PLANT").ToString()
                                row("CURRENCY") = cost.Item("CURRENCY").ToString()
                                row("COST") = FormatCost(Convert.ToDecimal(cost.Item("STANDARD_PRICE")), Convert.ToInt32(cost.Item("PRICE_UNIT")), cost.Item("SALES_ORG").ToString())
                                dtCost.Rows.Add(row)
                            Next
                        End If
                    Next
                    dtCost.TableName = "Cost"
                    Return dtCost
                Else
                    Return Nothing
                End If
            Else
                Return Nothing
            End If
        Else
            Return Nothing
        End If
    End Function

    'ICC 2016/6/28 Check company ID can see CLA items
    <WebMethod()> _
    Public Function CanSee968TParts(ByVal CompanyID As String) As Boolean
        Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(CompanyID)
    End Function
End Class

Public Class GlobalATP
    Dim gdt As DataTable, _pn As String, _plants As String
    Public rdt As DataTable
    Public Sub New(ByVal PN As String, ByVal Plants As String)
        _pn = Trim(UCase(PN)) : _plants = Plants
    End Sub
    Public Sub Query()
        Try
            rdt = Query(_plants, _pn)
        Catch ex As Exception

        End Try
    End Sub
    Public Function Query( _
    ByVal PlantArray As String, ByVal PartNo As String, ByVal maximumRows As Integer, ByVal startRowIndex As Integer, _
    ByVal SortExpression As String, ByVal Direction As WebControls.SortDirection) As DataTable
        If gdt Is Nothing Then
            gdt = New DataTable
            gdt.Columns.Add("plant") : gdt.Columns.Add("atp_date") : gdt.Columns.Add("atp_qty", Type.GetType("System.Double"))
        Else
            gdt.Clear()
        End If
        PartNo = Trim(PartNo).ToUpper()
        If PartNo = "" Then Return Nothing
        Dim plants() As String = Split(PlantArray, ",")
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        For Each plant As String In plants
            plant = Trim(plant).ToUpper()
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, plant, "", "", "", "", "PC", "", 9999, "", "", _
                                          New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            Dim adt As DataTable = atpTb.ToADODataTable()
            For Each r As DataRow In adt.Rows
                If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                    Dim r2 As DataRow = gdt.NewRow
                    r2.Item("plant") = plant
                    r2.Item("atp_date") = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
                    r2.Item("atp_qty") = CDbl(r.Item(4))
                    gdt.Rows.Add(r2)
                End If
            Next
        Next
        p1.Connection.Close()
        If gdt IsNot Nothing AndAlso gdt.Rows.Count > 0 Then
            Dim ndt As DataTable = gdt.Copy()
            If SortExpression <> "" Then
                If Direction = SortDirection.Ascending Then
                    ndt.DefaultView.Sort = SortExpression + " asc"
                Else
                    ndt.DefaultView.Sort = SortExpression + " desc"
                End If
                ndt = gdt.DefaultView.ToTable()
            End If
            Return ndt
        Else
            Return Nothing
        End If
    End Function

    Public Function Query(ByVal PlantArray As String, ByVal PartNo As String) As DataTable
        Return Query(PlantArray, PartNo, 0, 0, "", SortDirection.Descending)
    End Function

End Class
