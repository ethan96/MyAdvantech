<%@ WebService Language="VB" Class="eBizAEU_WS" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="eBizAEU")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class eBizAEU_WS
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty!"
    End Function
    
    'Dim strSAP As String = "user id=ebiz;password=ebiz;data source=(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.20.1.166)(PORT=1527))(CONNECT_DATA=(SERVICE_NAME=RDP)))"
    
    <WebMethod()> _
    Public Function GetOrdTrkSpeedByMail(VKORG As String, DATEB As String, DATEE As String, email As String, _
                                         MATNR As String, BSTNK As String, VBELN As String, ByRef strADONETXMLout As String) As Integer
        Dim proxy As New ZSD_SODN_INQ_WSF7.ZSD_SODN_INQ_WSF7(), p2 As New BAPISDORDER_GETDETAILEDLIST.BAPISDORDER_GETDETAILEDLIST
        Dim t_VKORG As String = VKORG, t_DATEB As String = DATEB, t_DATEE As String = DATEE, t_KUNNR As String = ""
        Dim t_MATNR As String = MATNR, t_BSTNK As String = BSTNK, t_VBELN As String = VBELN, t_email As String = email
        If IsNumeric(t_VBELN) Then
            Dim intZeroCount As Integer = 10 - t_VBELN.Length
            For i As Integer = 0 To intZeroCount - 1
                t_VBELN = "0" + t_VBELN
            Next
        End If
        Dim zsD_SOF_DTable4 As New ZSD_SODN_INQ_WSF7.ZSD_SOF_D1Table(), zsD_SOF_HTable4 As New ZSD_SODN_INQ_WSF7.ZSD_SOF_HTable()
        Dim zsD_SOFSTable4 As New ZSD_SODN_INQ_WSF7.ZSD_SOFSTable()
        Dim viewTb As New BAPISDORDER_GETDETAILEDLIST.ORDER_VIEW, condOut As New BAPISDORDER_GETDETAILEDLIST.BAPISDCONDTable
        viewTb.Sdcond = "X"
        
        Dim conn As New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Try
            proxy.Connection = conn : p2.Connection = conn
            proxy.Connection.Open()
            proxy.Zsd_Sodn_Inq_Wsf7(t_BSTNK, t_DATEB, t_DATEE, t_email, t_KUNNR, t_MATNR, _
             t_VBELN, t_VKORG, zsD_SOF_DTable4, zsD_SOF_HTable4, zsD_SOFSTable4)
            Dim dtOrderLines As DataTable = zsD_SOF_DTable4.ToADODataTable(), dtOrderHeader As DataTable = zsD_SOF_HTable4.ToADODataTable()
            Dim dtOrderSch As DataTable = zsD_SOFSTable4.ToADODataTable()
            Dim dtShipSoldBillTo As New DataTable
            Dim sdocTb As New BAPISDORDER_GETDETAILEDLIST.SALES_KEYTable
            For Each orderRow As DataRow In dtOrderHeader.Rows
                Dim sdoc As New BAPISDORDER_GETDETAILEDLIST.SALES_KEY : sdoc.Vbeln = orderRow.Item("Vbeln") : sdocTb.Add(sdoc)
                dtShipSoldBillTo.Merge(OraDbUtil.dbGetDataTable("SAP_PRD", _
                   " select a.vbeln, a.kunnr, a.parvw, b.name1, " + _
                   " (select adrc.street || adrc.str_suppl3 || adrc.location from saprdp.adrc where adrc.country=b.land1 and adrc.addrnumber=a.adrnr and rownum=1) as Address, " + _
                   " (select adrc.city1 from saprdp.adrc where adrc.country=a.land1 and adrc.addrnumber=b.adrnr and rownum=1) as City, " + _
                   " (select t005u.bezei from saprdp.adrc inner join saprdp.t005u on adrc.region=t005u.bland and adrc.country=t005u.land1 where t005u.mandt='168' and t005u.spras='E' and adrc.addrnumber=b.adrnr and rownum=1) as state, " + _
                   " (select adrc.post_code1 from saprdp.adrc where adrc.country=b.land1 and adrc.addrnumber=b.adrnr and rownum=1) as Zip_Code, " + _
                   " (select c.landx from saprdp.t005t c where c.land1=b.land1 and c.spras='E' and rownum=1) as country_name, " + _
                   " b.telf1 as tel_no " + _
                   " from saprdp.vbpa a inner join saprdp.kna1 b on a.kunnr=b.kunnr " + _
                   " where a.mandt='168' and b.mandt='168' and a.vbeln='" + orderRow.Item("Vbeln") + "' "))
            Next
            p2.Bapisdorder_Getdetailedlist(viewTb, "", Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, _
                                           Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, _
                                           Nothing, Nothing, condOut, Nothing, Nothing, Nothing, Nothing, Nothing, _
                                           Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, sdocTb)
            proxy.Connection.Close()
            
            For Each sr As DataRow In dtShipSoldBillTo.Rows
                Select Case sr.Item("PARVW")
                    Case "AG"
                        sr.Item("PARVW") = "Sold-to party"
                    Case "WE"
                        sr.Item("PARVW") = "Ship-to party"
                    Case "RE"
                        sr.Item("PARVW") = "Bill-to party"
                    Case "RG"
                        sr.Item("PARVW") = "Payer"
                End Select
            Next
            
            Dim DsOut As System.Data.DataSet = New DataSet(), dtCondTmp As DataTable = condOut.ToADODataTable()
            Dim dtCond As New DataTable
            With dtCond.Columns
                .Add("Sd_Doc") : .Add("Itm_Number") : .Add("Cond_Type") : .Add("Currency") : .Add("Condvalue")
            End With
            For Each r As DataRow In dtCondTmp.Rows
                Dim cond As String = r.Item("Cond_Type")
                Select Case cond
                    Case "UTXJ", "JR2", "ZHD0"
                        Dim nr As DataRow = dtCond.NewRow()
                        For Each c As DataColumn In dtCond.Columns
                            nr.Item(c.ColumnName) = r.Item(c.ColumnName)
                        Next
                        dtCond.Rows.Add(nr)
                End Select
            Next
            dtOrderLines.TableName = "Order Lines" : dtOrderHeader.TableName = "Order Header" : dtOrderSch.TableName = "Order Schedules" : dtShipSoldBillTo.TableName = "Ship/Sold/Bill to" : dtCond.TableName = "Conditions"
            DsOut.Tables.Add(dtOrderLines) : DsOut.Tables.Add(dtOrderHeader) : DsOut.Tables.Add(dtOrderSch) : DsOut.Tables.Add(dtShipSoldBillTo) : DsOut.Tables.Add(dtCond)
            'GridView0.DataSource = dtOrderLines : GridView1.DataSource = dtOrderHeader : GridView2.DataSource = dtOrderSch : gv3.DataSource = dtCond
            'GridView0.DataBind() : GridView1.DataBind() : GridView2.DataBind() : gv3.DataBind()
            'GridView3.DataSource = dtShipSoldBillTo : GridView3.DataBind()
            strADONETXMLout = DsOut.GetXml()
        Catch ex As Exception
            proxy.Connection.Close()
            strADONETXMLout = ex.ToString()
            Return -1
        End Try
        Return 0
    End Function
    
    
    <WebMethod()> _
    Function UpdateSAPOrderBillTo(ByVal Doc_Number As String, ByVal BillToID As String, ByRef strErrMsg As String, ByRef SAPReturnTable As DataTable) As Boolean
        Doc_Number = Trim(UCase(Doc_Number))
        Dim p1 As New SO_CHANGE_COMMIT.SO_CHANGE_COMMIT(), OrderHeader As New SO_CHANGE_COMMIT.BAPISDH1()
        Dim OrderHeaderX As New SO_CHANGE_COMMIT.BAPISDH1X(), ItemIn As New SO_CHANGE_COMMIT.BAPISDITMTable()
        Dim OrderText As New SO_CHANGE_COMMIT.BAPISDTEXTTable(), ScheLine As New SO_CHANGE_COMMIT.BAPISCHDLTable()
        Dim PartNr As New SO_CHANGE_COMMIT.BAPIPARNRTable(), PartNrc As New SO_CHANGE_COMMIT.BAPIPARNRCTable()
        Dim retTable As New SO_CHANGE_COMMIT.BAPIRET2Table()

        Dim oldBillToDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select kunnr from saprdp.vbpa where vbeln='" + Doc_Number + "' and parvw='RE'")
        Dim oldPayTermDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select zterm from saprdp.vbkd where vbeln='" + Doc_Number + "' ")
        If oldBillToDt.Rows.Count = 0 Or oldPayTermDt.Rows.Count = 0 Then
            strErrMsg = "Old billto or payment term not found in SAP" : Return False
        End If
        'OrderHeader.Sd_Doc_Cat = "C" : OrderHeaderX.Updateflag = "X"
        OrderHeader.Pmnttrms = oldPayTermDt.Rows(0).Item("zterm") : OrderHeaderX.Pmnttrms = "X" : OrderHeaderX.Updateflag = "U"
        'OrderHeader.Pmnttrms = "CODC"

        Dim PartNrc_RE As New SO_CHANGE_COMMIT.BAPIPARNRC()
        With PartNrc_RE
            .Document = Doc_Number : .Partn_Role = "RE" : .Updateflag = "U" : .P_Numb_Old = oldBillToDt.Rows(0).Item("kunnr") : .P_Numb_New = BillToID
        End With

        PartNrc.Add(PartNrc_RE)

        Dim l_BAPIPAREXTable As New SO_CHANGE_COMMIT.BAPIPAREXTable(), l_BAPICUBLBTable As New SO_CHANGE_COMMIT.BAPICUBLBTable()
        Dim l_BAPICUINSTable As New SO_CHANGE_COMMIT.BAPICUINSTable(), l_BAPICUPRTTable As New SO_CHANGE_COMMIT.BAPICUPRTTable()
        Dim l_BAPICUCFGTable As New SO_CHANGE_COMMIT.BAPICUCFGTable(), l_BAPICUREFTable As New SO_CHANGE_COMMIT.BAPICUREFTable()
        Dim l_BAPICUVALTable As New SO_CHANGE_COMMIT.BAPICUVALTable(), l_BAPICUVKTable As New SO_CHANGE_COMMIT.BAPICUVKTable()
        Dim l_BAPICONDTable As New SO_CHANGE_COMMIT.BAPICONDTable(), l_BAPICONDXTable As New SO_CHANGE_COMMIT.BAPICONDXTable()
        Dim l_BAPISDITMXTable As New SO_CHANGE_COMMIT.BAPISDITMXTable(), l_BAPISDKEYTable As New SO_CHANGE_COMMIT.BAPISDKEYTable()
        Dim l_BAPISCHDLXTable As New SO_CHANGE_COMMIT.BAPISCHDLXTable(), l_BAPIADDR1Table As New SO_CHANGE_COMMIT.BAPIADDR1Table()
        Dim strError As String = "", strpintnumassign As String = "", strSimulation As String = ""
        p1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        p1.Connection.Open()
        Try
            p1.Bapi_Salesorder_Change(strError, strpintnumassign, New SO_CHANGE_COMMIT.BAPISDLS(), OrderHeader, OrderHeaderX, _
                              Doc_Number, strSimulation, l_BAPICONDTable, l_BAPICONDXTable, l_BAPIPAREXTable, l_BAPICUBLBTable, _
                              l_BAPICUINSTable, l_BAPICUPRTTable, l_BAPICUCFGTable, l_BAPICUREFTable, l_BAPICUVALTable, _
                              l_BAPICUVKTable, ItemIn, l_BAPISDITMXTable, l_BAPISDKEYTable, OrderText, l_BAPIADDR1Table, _
                              PartNrc, PartNr, retTable, ScheLine, l_BAPISCHDLXTable)
            p1.CommitWork()
        Catch ex As Exception
            p1.RollbackWork()
            p1.Connection.Close()
            strErrMsg = ex.ToString()
            Return False
        End Try
    
        p1.Connection.Close()
        SAPReturnTable = retTable.ToADODataTable()
        Return True
    End Function
    
    <Web.Services.WebMethod()> _
    Public Function AddSAPCustomerContact( _
        ByVal CompanyId As String, ByVal Email As String, ByRef ErrMsg As String) As Boolean
        'Return False
        CompanyId = Trim(UCase(CompanyId))
        Dim kna1Dt As DataTable = GetKNA1(CompanyId)
        If kna1Dt.Rows.Count = 0 Then
            ErrMsg = "cannot find company " + CompanyId : Return False
        End If
        Dim proxy1 As New ZADDR_SAVE_INTERN.ZADDR_SAVE_INTERN
        Dim NewADR6Table As New ZADDR_SAVE_INTERN.ADR6Table, NewADR6Row As New ZADDR_SAVE_INTERN.ADR6
        With NewADR6Row
            .Addrnumber = kna1Dt.Rows(0).Item("adrnr") : .Client = "168" : .Consnumber = "001" : .Date_From = "00010101"
            .Dft_Receiv = "" : .Encode = "" : .Flg_Nouse = ""
            .Flgdefault = "X" : .Home_Flag = "X" : .Persnumber = ""
            .R3_User = "" : .Smtp_Addr = Email : .Smtp_Srch = Email : .Tnef = ""
        End With
        NewADR6Table.Add(NewADR6Row)
        'proxy1.ConnectionString = strSAPTest
        proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        proxy1.Connection.Open()
        Try
            proxy1.Zaddr_Save_Intern(New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, _
                               New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, _
                               New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, _
                               New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, _
                               New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, _
                               New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, _
                               New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, _
                               New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, _
                               New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, _
                               New ZADDR_SAVE_INTERN.ADR6Table, NewADR6Table, New ZADDR_SAVE_INTERN.ADR6Table, _
                               New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, _
                               New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, _
                               New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, _
                               New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable, _
                               New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, _
                               New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, _
                               New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, _
                               New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, _
                              New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, _
                               New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, _
                               New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, _
                               New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable)
        Catch ex As Exception
            ErrMsg = ex.ToString() : Return False
        End Try
        proxy1.Connection.Close()
        Return True
    End Function
    
    <Web.Services.WebMethod()> _
    Public Function UpdateSAPCustomerContact( _
        ByVal CompanyId As String, ByVal NewEmail As String, ByRef ErrMsg As String) As Boolean
        CompanyId = Trim(UCase(CompanyId))
        Dim OldEmail As String = ""
        Dim oldEmailDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
                                    " select b.SMTP_ADDR  " + _
                                    " from saprdp.kna1 a inner join saprdp.adr6 b on a.adrnr=b.addrnumber  " + _
                                    " where b.SMTP_ADDR like '%@%.%' and a.mandt='168' and a.kunnr='" + Replace(CompanyId, "'", "") + "' " + _
                                    " and b.flgdefault='X' and rownum=1 ")
        If oldEmailDt.Rows.Count = 0 Then
            oldEmailDt = OraDbUtil.dbGetDataTable("SAP_PRD", _
                                    " select b.SMTP_ADDR  " + _
                                    " from saprdp.kna1 a inner join saprdp.adr6 b on a.adrnr=b.addrnumber  " + _
                                    " where b.SMTP_ADDR like '%@%.%' and a.mandt='168' and a.kunnr='" + Replace(CompanyId, "'", "") + "' " + _
                                    " and rownum=1 ")
        End If
        If oldEmailDt.Rows.Count = 0 Then
            ErrMsg = "cannot find default contact email in company " + CompanyId : Return False
        End If
        OldEmail = oldEmailDt.Rows(0).Item("SMTP_ADDR")
        Dim dtADR6 As DataTable = GetADR6(CompanyId, OldEmail)
        Dim dtADRC As DataTable = GetADRC(CompanyId)
        If dtADR6.Rows.Count = 0 Then
            ErrMsg = OldEmail + " not found in company " + CompanyId : Return False
        End If
        If dtADRC.Rows.Count = 0 Then
            ErrMsg = CompanyId + " not found" : Return False
        End If
        Dim UpdateADR6Table As New ZADDR_SAVE_INTERN.ADR6Table, UpdateADR6Row As New ZADDR_SAVE_INTERN.ADR6
        Dim UpdateADRCTable As New ZADDR_SAVE_INTERN.ADRCTable, UpdateADRCRow As New ZADDR_SAVE_INTERN.ADRC

        Dim sapRow As DataRow = dtADR6.Rows(0)
        With UpdateADR6Row
            .Addrnumber = sapRow.Item("Addrnumber") : .Client = "168" : .Consnumber = sapRow.Item("Consnumber") : .Date_From = sapRow.Item("Date_From")
            .Dft_Receiv = sapRow.Item("Dft_Receiv") : .Encode = sapRow.Item("Encode") : .Flg_Nouse = sapRow.Item("Flg_Nouse")
            .Flgdefault = sapRow.Item("Flgdefault") : .Home_Flag = sapRow.Item("Home_Flag") : .Persnumber = sapRow.Item("Persnumber")
            .R3_User = sapRow.Item("R3_User") : .Smtp_Addr = NewEmail : .Smtp_Srch = NewEmail : .Tnef = sapRow.Item("Tnef")
        End With
        UpdateADR6Table.Add(UpdateADR6Row)

        sapRow = dtADRC.Rows(0)
        With UpdateADRCRow
            .Addr_Group = sapRow.Item("ADDR_GROUP") : .Address_Id = sapRow.Item("ADDRESS_ID") : .Addrnumber = sapRow.Item("ADDRNUMBER")
            .Addrorigin = sapRow.Item("Addrorigin") : .Building = sapRow.Item("BUILDING") : .Chckstatus = sapRow.Item("Chckstatus")
            .City_Code = sapRow.Item("City_Code") : .City_Code2 = sapRow.Item("City_Code2") : .City1 = sapRow.Item("City1") : .City2 = sapRow.Item("City2")
            .Cityh_Code = sapRow.Item("Cityh_Code") : .Cityp_Code = sapRow.Item("Cityp_Code") : .Client = "168"
            .Country = sapRow.Item("Country") : .Date_From = sapRow.Item("DATE_FROM") : .Date_To = sapRow.Item("DATE_TO")
            'Set Company's Std.Comm.Method to E-mail
            .Deflt_Comm = "INT"
            .Dont_Use_P = sapRow.Item("DONT_USE_P") : .Dont_Use_S = sapRow.Item("Dont_Use_S")
            .Extension1 = sapRow.Item("Extension1") : .Extension2 = sapRow.Item("Extension2") : .Fax_Extens = sapRow.Item("FAX_EXTENS")
            .Fax_Number = sapRow.Item("FAX_NUMBER") : .Flagcomm10 = sapRow.Item("FLAGCOMM10") : .Flagcomm11 = sapRow.Item("FLAGCOMM11")
            .Flagcomm12 = sapRow.Item("FLAGCOMM12") : .Flagcomm13 = sapRow.Item("FLAGCOMM13") : .Flagcomm2 = sapRow.Item("FLAGCOMM2")
            .Flagcomm3 = sapRow.Item("FLAGCOMM3") : .Flagcomm4 = sapRow.Item("FLAGCOMM4") : .Flagcomm5 = sapRow.Item("FLAGCOMM5")
            .Flagcomm6 = sapRow.Item("FLAGCOMM6") : .Flagcomm7 = sapRow.Item("FLAGCOMM7") : .Flagcomm8 = sapRow.Item("FLAGCOMM8")
            .Flagcomm9 = sapRow.Item("FLAGCOMM9") : .Flaggroups = sapRow.Item("Flaggroups") : .Floor = sapRow.Item("FLOOR")
            .Home_City = sapRow.Item("Home_City") : .House_Num1 = sapRow.Item("House_Num1") : .House_Num2 = sapRow.Item("House_Num2")
            .House_Num3 = sapRow.Item("House_Num3") : .Langu = sapRow.Item("Langu") : .Langu_Crea = sapRow.Item("Langu_Crea")
            .Location = sapRow.Item("Location") : .Mc_City1 = sapRow.Item("Mc_City1") : .Mc_Name1 = sapRow.Item("Mc_Name1")
            .Mc_Street = sapRow.Item("Mc_Street") : .Name_Co = sapRow.Item("Name_Co") : .Name_Text = sapRow.Item("Name_Text")
            .Name1 = sapRow.Item("Name1") : .Name2 = sapRow.Item("Name2") : .Name3 = sapRow.Item("Name3") : .Name4 = sapRow.Item("Name4")
            .Nation = sapRow.Item("Nation") : .Pcode1_Ext = sapRow.Item("Pcode1_Ext") : .Pcode2_Ext = sapRow.Item("Pcode2_Ext")
            .Pcode3_Ext = sapRow.Item("Pcode3_Ext") : .Pers_Addr = sapRow.Item("Pers_Addr") : .Po_Box = sapRow.Item("Po_Box")
            .Po_Box_Cty = sapRow.Item("Po_Box_Cty") : .Po_Box_Loc = sapRow.Item("Po_Box_Loc")
            .Po_Box_Num = sapRow.Item("Po_Box_Num") : .Po_Box_Reg = sapRow.Item("Po_Box_Reg")
            .Post_Code1 = sapRow.Item("Post_Code1") : .Post_Code2 = sapRow.Item("Post_Code2")
            .Post_Code3 = sapRow.Item("Post_Code3") : .Postalarea = sapRow.Item("Postalarea")
            .Regiogroup = sapRow.Item("Regiogroup") : .Region = sapRow.Item("Region")
            .Roomnumber = sapRow.Item("Roomnumber") : .Nation = sapRow.Item("NATION")
            .Roomnumber = sapRow.Item("ROOMNUMBER")
            .Sort_Phn = sapRow.Item("SORT_PHN") : .Sort1 = sapRow.Item("SORT1") : .Sort2 = sapRow.Item("SORT2")
            .Str_Suppl1 = sapRow.Item("Str_Suppl1") : .Str_Suppl2 = sapRow.Item("Str_Suppl2") : .Str_Suppl3 = sapRow.Item("Str_Suppl3")
            .Street = sapRow.Item("Street") : .Streetabbr = sapRow.Item("Streetabbr") : .Streetcode = sapRow.Item("Streetcode")
            .Taxjurcode = sapRow.Item("Taxjurcode") : .Tel_Extens = sapRow.Item("Tel_Extens") : .Tel_Number = sapRow.Item("Tel_Number")
            .Time_Zone = sapRow.Item("Time_Zone") : .Title = sapRow.Item("Title") : .Transpzone = sapRow.Item("Transpzone")
            .Tel_Extens = sapRow.Item("TEL_EXTENS") : .Tel_Number = sapRow.Item("TEL_NUMBER")
        End With
        UpdateADRCTable.Add(UpdateADRCRow)

        Dim proxy1 As New ZADDR_SAVE_INTERN.ZADDR_SAVE_INTERN
        'proxy1.ConnectionString = strSAPTest
        proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        proxy1.Connection.Open()
        Try
            proxy1.Zaddr_Save_Intern(New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, _
                               New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, _
                               New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, _
                               New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, _
                               New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, _
                               New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, _
                               New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, _
                               New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, _
                               New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, _
                               New ZADDR_SAVE_INTERN.ADR6Table, New ZADDR_SAVE_INTERN.ADR6Table, UpdateADR6Table, _
                               New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, _
                               New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, _
                               New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, _
                               New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable, UpdateADRCTable, _
                               New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, _
                               New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, _
                               New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, _
                               New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, _
                              New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, _
                               New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, _
                               New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, _
                               New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable)
        Catch ex As Exception
            ErrMsg = ex.ToString() : Return False
        End Try
        proxy1.Connection.Close()
        Return True
    End Function

    <Web.Services.WebMethod()> _
    Public Function UpdateSAPCustomerAddress( _
        ByVal CompanyId As String, ByVal NameCO As String, ByVal CompanyName As String, ByVal Street As String, _
        ByVal City As String, ByVal PostalCode As String, ByVal TaxJuriCode As String, ByRef ErrMsg As String) As Boolean
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select b.CLIENT, b.ADDRNUMBER, b.DATE_FROM, b.NATION, b.DATE_TO, b.TITLE, b.NAME1,  "))
            .AppendLine(String.Format(" b.NAME2, b.NAME3, b.NAME4, b.NAME_TEXT, b.NAME_CO, b.CITY1, b.CITY2, b.CITY_CODE,  "))
            .AppendLine(String.Format(" b.CITYP_CODE, b.HOME_CITY, b.CITYH_CODE, b.CHCKSTATUS, b.REGIOGROUP, b.POST_CODE1,  "))
            .AppendLine(String.Format(" b.POST_CODE2, b.POST_CODE3, b.PCODE1_EXT, b.PCODE2_EXT, b.PCODE3_EXT, b.PO_BOX,  "))
            .AppendLine(String.Format(" b.DONT_USE_P, b.PO_BOX_NUM, b.PO_BOX_LOC, b.CITY_CODE2, b.PO_BOX_REG,  "))
            .AppendLine(String.Format(" b.PO_BOX_CTY, b.POSTALAREA, b.TRANSPZONE, b.STREET, b.DONT_USE_S, b.STREETCODE,  "))
            .AppendLine(String.Format(" b.STREETABBR, b.HOUSE_NUM1, b.HOUSE_NUM2, b.HOUSE_NUM3, b.STR_SUPPL1, b.STR_SUPPL2,  "))
            .AppendLine(String.Format(" b.STR_SUPPL3, b.LOCATION, b.BUILDING, b.FLOOR, b.ROOMNUMBER, b.COUNTRY, b.LANGU,  "))
            .AppendLine(String.Format(" b.REGION, b.ADDR_GROUP, b.FLAGGROUPS, b.PERS_ADDR, b.SORT1, b.SORT2, b.SORT_PHN,  "))
            .AppendLine(String.Format(" b.DEFLT_COMM, b.TEL_NUMBER, b.TEL_EXTENS, b.FAX_NUMBER, b.FAX_EXTENS, b.FLAGCOMM2,  "))
            .AppendLine(String.Format(" b.FLAGCOMM3, b.FLAGCOMM4, b.FLAGCOMM5, b.FLAGCOMM6, b.FLAGCOMM7, b.FLAGCOMM8,  "))
            .AppendLine(String.Format(" b.FLAGCOMM9, b.FLAGCOMM10, b.FLAGCOMM11, b.FLAGCOMM12, b.FLAGCOMM13, b.ADDRORIGIN,  "))
            .AppendLine(String.Format(" b.MC_NAME1, b.MC_CITY1, b.MC_STREET, b.EXTENSION1, b.EXTENSION2, b.TIME_ZONE,  "))
            .AppendLine(String.Format(" b.TAXJURCODE, b.ADDRESS_ID, b.LANGU_CREA  "))
            .AppendLine(String.Format(" from saprdp.kna1 a inner join saprdp.adrc b on a.adrnr=b.addrnumber  "))
            .AppendLine(String.Format(" where a.mandt='168' and a.kunnr='{0}' and rownum=1 ", Replace(Trim(UCase(CompanyId)), "''", "")))
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        If dt.Rows.Count = 0 Then
            ErrMsg = CompanyId + " not found" : Return False
        End If
        'Return False
        Dim updateDt As New ZADDR_SAVE_INTERN.ADRCTable, updateRow As New ZADDR_SAVE_INTERN.ADRC
        Dim sapRow As DataRow = dt.Rows(0)
        With updateRow
            .Addr_Group = sapRow.Item("ADDR_GROUP") : .Address_Id = sapRow.Item("ADDRESS_ID")

            .Addrnumber = sapRow.Item("ADDRNUMBER") : .Addrorigin = sapRow.Item("Addrorigin")

            '.Alt_Compny = sapRow.Item("")
            .Building = sapRow.Item("BUILDING") : .Chckstatus = sapRow.Item("Chckstatus")
            .City_Code = sapRow.Item("City_Code") : .City_Code2 = sapRow.Item("City_Code2")
            .City1 = sapRow.Item("City1") : .City2 = sapRow.Item("City2")
            .Cityh_Code = sapRow.Item("Cityh_Code") : .Cityp_Code = sapRow.Item("Cityp_Code")
            .Client = "168"
            .Country = sapRow.Item("Country")

            '.Comp_Pers = sapRow.Item("")
            .Date_From = sapRow.Item("DATE_FROM") : .Date_To = sapRow.Item("DATE_TO")

            .Deflt_Comm = sapRow.Item("DEFLT_COMM") : .Dont_Use_P = sapRow.Item("DONT_USE_P")
            .Dont_Use_S = sapRow.Item("Dont_Use_S") : .Extension1 = sapRow.Item("Extension1")
            .Extension2 = sapRow.Item("Extension2") : .Fax_Extens = sapRow.Item("FAX_EXTENS") : .Fax_Number = sapRow.Item("FAX_NUMBER")
            .Flagcomm10 = sapRow.Item("FLAGCOMM10") : .Flagcomm11 = sapRow.Item("FLAGCOMM11") : .Flagcomm12 = sapRow.Item("FLAGCOMM12")
            .Flagcomm13 = sapRow.Item("FLAGCOMM13") : .Flagcomm2 = sapRow.Item("FLAGCOMM2") : .Flagcomm3 = sapRow.Item("FLAGCOMM3")
            .Flagcomm4 = sapRow.Item("FLAGCOMM4") : .Flagcomm5 = sapRow.Item("FLAGCOMM5") : .Flagcomm6 = sapRow.Item("FLAGCOMM6")
            .Flagcomm7 = sapRow.Item("FLAGCOMM7") : .Flagcomm8 = sapRow.Item("FLAGCOMM8") : .Flagcomm9 = sapRow.Item("FLAGCOMM9")
            .Flaggroups = sapRow.Item("Flaggroups") : .Floor = sapRow.Item("FLOOR")
            .Home_City = sapRow.Item("Home_City") : .House_Num1 = sapRow.Item("House_Num1")
            .House_Num2 = sapRow.Item("House_Num2") : .House_Num3 = sapRow.Item("House_Num3")
            .Langu = sapRow.Item("Langu") : .Langu_Crea = sapRow.Item("Langu_Crea")
            .Location = sapRow.Item("Location") : .Mc_City1 = sapRow.Item("Mc_City1")
            .Mc_Name1 = sapRow.Item("Mc_Name1") : .Mc_Street = sapRow.Item("Mc_Street")
            .Name_Co = sapRow.Item("Name_Co") : .Name_Text = sapRow.Item("Name_Text")
            .Name1 = sapRow.Item("Name1") : .Name2 = sapRow.Item("Name2")
            .Name3 = sapRow.Item("Name3") : .Name4 = sapRow.Item("Name4")
            .Nation = sapRow.Item("Nation") : .Pcode1_Ext = sapRow.Item("Pcode1_Ext")
            .Pcode2_Ext = sapRow.Item("Pcode2_Ext") : .Pcode3_Ext = sapRow.Item("Pcode3_Ext")
            .Pers_Addr = sapRow.Item("Pers_Addr") : .Po_Box = sapRow.Item("Po_Box")
            .Po_Box_Cty = sapRow.Item("Po_Box_Cty") : .Po_Box_Loc = sapRow.Item("Po_Box_Loc")
            .Po_Box_Num = sapRow.Item("Po_Box_Num") : .Po_Box_Reg = sapRow.Item("Po_Box_Reg")
            .Post_Code1 = sapRow.Item("Post_Code1") : .Post_Code2 = sapRow.Item("Post_Code2")
            .Post_Code3 = sapRow.Item("Post_Code3") : .Postalarea = sapRow.Item("Postalarea")
            .Regiogroup = sapRow.Item("Regiogroup") : .Region = sapRow.Item("Region")
            .Roomnumber = sapRow.Item("Roomnumber") : .Nation = sapRow.Item("NATION")
            '.Persnumber = sapRow.Item("")
            .Roomnumber = sapRow.Item("ROOMNUMBER") '.So_Key = sapRow.Item("")
            .Sort_Phn = sapRow.Item("SORT_PHN") : .Sort1 = sapRow.Item("SORT1") : .Sort2 = sapRow.Item("SORT2")
            .Str_Suppl1 = sapRow.Item("Str_Suppl1") : .Str_Suppl2 = sapRow.Item("Str_Suppl2") : .Str_Suppl3 = sapRow.Item("Str_Suppl3")
            .Street = sapRow.Item("Street") : .Streetabbr = sapRow.Item("Streetabbr") : .Streetcode = sapRow.Item("Streetcode")
            .Taxjurcode = sapRow.Item("Taxjurcode") : .Tel_Extens = sapRow.Item("Tel_Extens") : .Tel_Number = sapRow.Item("Tel_Number")
            .Time_Zone = sapRow.Item("Time_Zone") : .Title = sapRow.Item("Title") : .Transpzone = sapRow.Item("Transpzone")
            .Tel_Extens = sapRow.Item("TEL_EXTENS") : .Tel_Number = sapRow.Item("TEL_NUMBER")
            If Trim(NameCO) <> "" Then
                .Name_Co = NameCO
            End If
            If Trim(CompanyName) <> "" Then
                .Name1 = CompanyName
            End If
            If Trim(Street) <> "" Then
                .Street = Street
            End If
            If Trim(City) <> "" Then
                .City1 = City
            End If
            If Trim(PostalCode) <> "" Then
                .Post_Code1 = PostalCode
            End If
            If Trim(TaxJuriCode) <> "" Then
                .Taxjurcode = TaxJuriCode
            End If
        End With
        updateDt.Add(updateRow)
        Dim proxy1 As New ZADDR_SAVE_INTERN.ZADDR_SAVE_INTERN
        'proxy1.ConnectionString = strSAPTest
        proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        proxy1.Connection.Open()
        Try
            proxy1.Zaddr_Save_Intern(New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, New ZADDR_SAVE_INTERN.ADCPTable, _
                               New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, New ZADDR_SAVE_INTERN.ADR10Table, _
                               New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, New ZADDR_SAVE_INTERN.ADR11Table, _
                               New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, New ZADDR_SAVE_INTERN.ADR12Table, _
                               New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, New ZADDR_SAVE_INTERN.ADR13Table, _
                               New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, New ZADDR_SAVE_INTERN.ADR2Table, _
                               New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, New ZADDR_SAVE_INTERN.ADR3Table, _
                               New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, New ZADDR_SAVE_INTERN.ADR4Table, _
                               New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, New ZADDR_SAVE_INTERN.ADR5Table, _
                               New ZADDR_SAVE_INTERN.ADR6Table, New ZADDR_SAVE_INTERN.ADR6Table, New ZADDR_SAVE_INTERN.ADR6Table, _
                               New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, New ZADDR_SAVE_INTERN.ADR7Table, _
                               New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, New ZADDR_SAVE_INTERN.ADR8Table, _
                               New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, New ZADDR_SAVE_INTERN.ADR9Table, _
                               New ZADDR_SAVE_INTERN.ADRCTable, New ZADDR_SAVE_INTERN.ADRCTable, updateDt, _
                               New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, New ZADDR_SAVE_INTERN.ADRCOMCTable, _
                               New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, New ZADDR_SAVE_INTERN.ADRCTTable, _
                               New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, New ZADDR_SAVE_INTERN.ADRGTable, _
                               New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, New ZADDR_SAVE_INTERN.ADRGPTable, _
                              New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, New ZADDR_SAVE_INTERN.ADRPTable, _
                               New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, New ZADDR_SAVE_INTERN.ADRTTable, _
                               New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, New ZADDR_SAVE_INTERN.ADRVTable, _
                               New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable, New ZADDR_SAVE_INTERN.ADRVPTable)
        Catch ex As Exception
            'Console.WriteLine("Call SAP error:" + ex.ToString())
            ErrMsg = ex.ToString() : Return False
        End Try
        proxy1.Connection.Close()
        Return True
    End Function

    Function GetADR6(ByVal CompanyId As String, ByVal Email As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select b.CLIENT, b.ADDRNUMBER, b.PERSNUMBER, b.DATE_FROM, b.CONSNUMBER,  "))
            .AppendLine(String.Format(" b.FLGDEFAULT, b.FLG_NOUSE, b.HOME_FLAG, b.SMTP_ADDR, b.SMTP_SRCH,  "))
            .AppendLine(String.Format(" b.DFT_RECEIV, b.R3_USER, b.ENCODE, b.TNEF  "))
            .AppendLine(String.Format(" from saprdp.kna1 a inner join saprdp.adr6 b on a.adrnr=b.addrnumber  "))
            .AppendLine(String.Format(" where a.mandt='168' and a.kunnr='{0}' and lower(b.SMTP_ADDR)='{1}' ", _
                                      Replace(Trim(UCase(CompanyId)), "''", ""), Replace(Trim(LCase(Email)), "'", "''")))
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        Return dt
    End Function

    Function GetADRC(ByVal CompanyId As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select b.CLIENT, b.ADDRNUMBER, b.DATE_FROM, b.NATION, b.DATE_TO, b.TITLE, b.NAME1,  "))
            .AppendLine(String.Format(" b.NAME2, b.NAME3, b.NAME4, b.NAME_TEXT, b.NAME_CO, b.CITY1, b.CITY2, b.CITY_CODE,  "))
            .AppendLine(String.Format(" b.CITYP_CODE, b.HOME_CITY, b.CITYH_CODE, b.CHCKSTATUS, b.REGIOGROUP, b.POST_CODE1,  "))
            .AppendLine(String.Format(" b.POST_CODE2, b.POST_CODE3, b.PCODE1_EXT, b.PCODE2_EXT, b.PCODE3_EXT, b.PO_BOX,  "))
            .AppendLine(String.Format(" b.DONT_USE_P, b.PO_BOX_NUM, b.PO_BOX_LOC, b.CITY_CODE2, b.PO_BOX_REG,  "))
            .AppendLine(String.Format(" b.PO_BOX_CTY, b.POSTALAREA, b.TRANSPZONE, b.STREET, b.DONT_USE_S, b.STREETCODE,  "))
            .AppendLine(String.Format(" b.STREETABBR, b.HOUSE_NUM1, b.HOUSE_NUM2, b.HOUSE_NUM3, b.STR_SUPPL1, b.STR_SUPPL2,  "))
            .AppendLine(String.Format(" b.STR_SUPPL3, b.LOCATION, b.BUILDING, b.FLOOR, b.ROOMNUMBER, b.COUNTRY, b.LANGU,  "))
            .AppendLine(String.Format(" b.REGION, b.ADDR_GROUP, b.FLAGGROUPS, b.PERS_ADDR, b.SORT1, b.SORT2, b.SORT_PHN,  "))
            .AppendLine(String.Format(" b.DEFLT_COMM, b.TEL_NUMBER, b.TEL_EXTENS, b.FAX_NUMBER, b.FAX_EXTENS, b.FLAGCOMM2,  "))
            .AppendLine(String.Format(" b.FLAGCOMM3, b.FLAGCOMM4, b.FLAGCOMM5, b.FLAGCOMM6, b.FLAGCOMM7, b.FLAGCOMM8,  "))
            .AppendLine(String.Format(" b.FLAGCOMM9, b.FLAGCOMM10, b.FLAGCOMM11, b.FLAGCOMM12, b.FLAGCOMM13, b.ADDRORIGIN,  "))
            .AppendLine(String.Format(" b.MC_NAME1, b.MC_CITY1, b.MC_STREET, b.EXTENSION1, b.EXTENSION2, b.TIME_ZONE,  "))
            .AppendLine(String.Format(" b.TAXJURCODE, b.ADDRESS_ID, b.LANGU_CREA  "))
            .AppendLine(String.Format(" from saprdp.kna1 a inner join saprdp.adrc b on a.adrnr=b.addrnumber  "))
            .AppendLine(String.Format(" where a.mandt='168' and a.kunnr='{0}' and rownum=1 ", Replace(Trim(UCase(CompanyId)), "''", "")))
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        Return dt
    End Function
    
    Function GetKNA1(ByVal CompanyId As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format("select a.adrnr, a.kunnr, a.name1 from saprdp.kna1 a "))
            .AppendLine(String.Format(" where a.mandt='168' and a.kunnr='{0}' and rownum=1 ", Replace(Trim(UCase(CompanyId)), "''", "")))
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        Return dt
    End Function
    
    <Web.Services.WebMethod()> _
    Function GetMultiPrice(ByVal Org As String, ByVal CompanyId As String, ByVal Products As DataTable, ByRef ErrorMessage As String) As DataTable
        CompanyId = UCase(Trim(CompanyId)) : ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        If Org = "US01" Then
            Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) from SAP_DIMCOMPANY where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", CompanyId))
            If N > 0 Then
                strDistChann = "10" : strDivision = "20"
            Else
                strDistChann = "30" : strDivision = "10"
            End If
        Else

        End If
        Dim OutList As New DataTable("Output")
        Dim phaseOutItems As New ArrayList
        With OutList.Columns
            .Add("PartNo") : .Add("NetPrice", GetType(Decimal)) : .Add("RecycleFee", GetType(Decimal))
        End With
        Dim ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim RemoveAddedItem As Boolean = False : Dim AddedItemLineNo As String = ""
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE("CLIENT=168 USER=b2bacl PASSWD=aclacl ASHOST=172.20.1.88 SYSNR=0")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable

        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each i As DataRow In Products.Rows
            Dim chkSql As String = _
                " select a.part_no, a.ITEM_CATEGORY_GROUP, IsNull(b.ProfitCenter,'N/A') as ProfitCenter " + _
                " from sap_product_status a left join SAP_PRODUCT_ABC b on a.PART_NO=b.PART_NO and a.DLV_PLANT=b.PLANT  " + _
                " where a.part_no='" + i.Item("PartNo").Trim().ToUpper() + "' and a.product_status in ('A','N','H','O') and a.sales_org='" + Org + "' "
            Dim chkDt As New DataTable, sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close() : ErrorMessage = ex.ToString() : Return Nothing
            End Try
            If chkDt.Rows.Count > 0 AndAlso (Org <> "TW01" Or (Org = "TW01") And chkDt.Rows(0).Item("ProfitCenter") <> "N/A") Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(i.Item("PartNo").Trim().ToUpper())
                    item.Req_Qty = i.Item("Qty").ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = i.Item("PartNo").Trim().ToUpper() : zr.Item("Qty") = i.Item("Qty") : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(i.Item("PartNo").Trim().ToUpper())
            End If
        Next
        sqlMA.Close()
        
        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = "ADAM-4520-D2E"
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            RemoveAddedItem = True : AddedItemLineNo = LineNo.ToString()
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = CompanyId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = CompanyId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)
        proxy1.Connection.Open()
        Try
            
            
            
            Dim dtItem As New DataTable
            Dim dtPartNr As New DataTable
            Dim dtcon As New DataTable
            Dim DTRET As New DataTable
      
            dtItem = ItemsIn.ToADODataTable()
            dtPartNr = Partners.ToADODataTable()
            dtcon = Conditions.ToADODataTable()

         
            
            
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
                    ErrorMessage += String.Format("Type:{0};Msg:{1}", retMsgRec.Item("Type"), retMsgRec.Item("Message")) + vbCrLf
                End If
            Next
            'GridView1.DataSource = retDt.ToADODataTable() : GridView1.DataBind()
            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()
            
            
            DTRET = retDt.ToADODataTable()
            'Dim str As String = Utilities.getDTHtml(dtItem) & Utilities.getDTHtml(dtPartNr) & Utilities.getDTHtml(dtcon) & Utilities.getDTHtml(DTRET) & Utilities.getDTHtml(POutDt)
            'Utilities.Utility_EMailPage("nada.liu@advantech.com.cn", "nada.liu@advantech.com.cn", "", "", _
            '   "so_create return 0", "", str)
            
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim pout As DataRow = OutList.NewRow()
                pout.Item("PartNo") = RemoveZeroString(PIn.Item("Material"))
                pout.Item("NetPrice") = 0 : pout.Item("RecycleFee") = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            pout.Item("NetPrice") = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            pout.Item("RecycleFee") = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                If IsNumericItem(PIn.Item("Material")) Then
                    Dim rs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If pout.Item("NetPrice") <= 0 AndAlso rs.Length > 0 Then
                        pout.Item("NetPrice") = rs(0).Item("net_value1") / rs(0).Item("req_qty")
                    End If
                End If
                If Not RemoveAddedItem Or (RemoveAddedItem And RemoveZeroString(PIn.Item("Itm_Number")) <> AddedItemLineNo) Then
                    'Response.Write(pout.Item("PartNo") + ":" + PIn.Item("Itm_Number") + ";" + AddedItemLineNo.ToString() + "<br/>")
                    OutList.Rows.Add(pout)
                End If
                
            Next
            For Each itm As String In phaseOutItems
                Dim pout As DataRow = OutList.NewRow()
                pout.Item("PartNo") = itm
                pout.Item("NetPrice") = -1 : pout.Item("RecycleFee") = -1
                OutList.Rows.Add(pout)
            Next
        Catch ex As Exception
            ErrorMessage += vbCrLf + "Exception Message:" + ex.ToString()
        End Try
        proxy1.Connection.Close()
        Return OutList
    End Function
    
    <Web.Services.WebMethod()> _
    Function GetMultiPrice_Old_20110907(ByVal Org As String, ByVal CompanyId As String, ByVal Products As DataTable, ByRef ErrorMessage As String) As DataTable
        CompanyId = UCase(Trim(CompanyId)) : ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        If Org = "US01" Then
            Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) from SAP_DIMCOMPANY where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", CompanyId))
            If N > 0 Then
                strDistChann = "10" : strDivision = "20"
            Else
                strDistChann = "30" : strDivision = "10"
            End If
        Else

        End If
        Dim OutList As New DataTable("Output")
        Dim phaseOutItems As New ArrayList
        With OutList.Columns
            .Add("PartNo") : .Add("NetPrice", GetType(Decimal)) : .Add("RecycleFee", GetType(Decimal))
        End With
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE("CLIENT=168 USER=b2bacl PASSWD=aclacl ASHOST=172.20.1.88 SYSNR=0")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable

        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        'Dim sqlMA As New SqlClient.SqlConnection(MyConn)
        Dim dbCmd As New SqlClient.SqlCommand
        dbCmd.Connection = sqlMA
        sqlMA.Open()
        For Each i As DataRow In Products.Rows
            dbCmd.CommandText = "select count(part_no) as c from sap_product_status where part_no='" + i.Item("PartNo").Trim().ToUpper() + "' and product_status in ('A','N','H','M1') and sales_org='" + Org + "'"
            If CInt(dbCmd.ExecuteScalar()) > 0 Then
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(i.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = i.Item("Qty").ToString()
                If IsNumericItem(item.Material) Then item.Req_Qty = CInt(item.Req_Qty) * 1000
                ItemsIn.Add(item)
                LineNo += 1
            Else
                phaseOutItems.Add(i.Item("PartNo").Trim().ToUpper())
            End If
        Next
        sqlMA.Close()
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = CompanyId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = CompanyId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

        proxy1.Connection.Open()
        Try
            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, New BAPI_SALESORDER_SIMULATE.BAPIRET2Table, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim pout As DataRow = OutList.NewRow()
                pout.Item("PartNo") = RemoveZeroString(PIn.Item("Material"))
                pout.Item("NetPrice") = 0 : pout.Item("RecycleFee") = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            pout.Item("NetPrice") = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            pout.Item("RecycleFee") = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                If IsNumericItem(PIn.Item("Material")) Then
                    Dim rs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If pout.Item("NetPrice") <= 0 AndAlso rs.Length > 0 Then
                        pout.Item("NetPrice") = rs(0).Item("net_value1") / rs(0).Item("req_qty")
                    End If
                End If
                OutList.Rows.Add(pout)
            Next
            For Each itm As String In phaseOutItems
                Dim pout As DataRow = OutList.NewRow()
                pout.Item("PartNo") = itm
                pout.Item("NetPrice") = -1 : pout.Item("RecycleFee") = -1
                OutList.Rows.Add(pout)
            Next
        Catch ex As Exception
            ErrorMessage = ex.ToString()
        End Try
        proxy1.Connection.Close()
        Return OutList
    End Function
    
    <WebMethod()> _
    Function GetMultiPrice_Old(ByVal Org As String, ByVal CompanyId As String, ByVal Products As DataTable, ByRef ErrorMessage As String) As DataTable
        CompanyId = UCase(Trim(CompanyId)) : ErrorMessage = ""
        Dim OutList As New DataTable("Output")
        With OutList.Columns
            .Add("PartNo") : .Add("NetPrice", GetType(Decimal)) : .Add("RecycleFee", GetType(Decimal))
        End With
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE("CLIENT=168 USER=b2bacl PASSWD=aclacl ASHOST=172.20.1.88 SYSNR=0")
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable

        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = "10" : .Division = "20"
        End With
        Dim LineNo As Integer = 1
        For Each i As DataRow In Products.Rows
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(i.Item("PartNo").Trim().ToUpper())
            item.Req_Qty = i.Item("Qty").ToString()
            If IsNumericItem(item.Material) Then item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            LineNo += 1
        Next

        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = CompanyId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = CompanyId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

        proxy1.Connection.Open()
        Try
            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, New BAPI_SALESORDER_SIMULATE.BAPIRET2Table, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()
            For Each PIn As DataRow In PInDt.Rows
                'Dim pout As New ProductOut(RemoveZeroString(PIn.Item("Material")))
                Dim pout As DataRow = OutList.NewRow()
                pout.Item("PartNo") = RemoveZeroString(PIn.Item("Material"))
                pout.Item("NetPrice") = 0 : pout.Item("RecycleFee") = 0
                Dim rs2() As DataRow = ConditionOut.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                For Each r As DataRow In rs2
                    Select Case r.Item("Cond_Type").ToString().ToUpper()
                        Case "ZPN0", "ZPR0"
                            pout.Item("NetPrice") = FormatNumber(r.Item("Cond_Value"), 2)
                        Case "ZHB0"
                            pout.Item("RecycleFee") = FormatNumber(r.Item("Cond_Value"), 2)
                    End Select
                Next
                If IsNumericItem(PIn.Item("Material")) Then
                    Dim rs() As DataRow = POutDt.Select("Itm_Number='" + PIn.Item("Itm_Number") + "'")
                    If pout.Item("NetPrice") <= 0 AndAlso rs.Length > 0 Then
                        pout.Item("NetPrice") = rs(0).Item("net_value1") / rs(0).Item("req_qty")
                    End If
                End If

                OutList.Rows.Add(pout)
            Next
        Catch ex As Exception
            ErrorMessage = ex.ToString()
        End Try
        proxy1.Connection.Close()
        Return OutList
    End Function
    
    <WebMethod()> _
    Public Function GetMultiPrice2(ByVal Org As String, ByVal CompanyId As String, _
                                         ByVal Products As DataTable, ByVal PricingDate As Date, ByRef ErrorMessage As String) As DataTable
        CompanyId = UCase(Trim(CompanyId)) : ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        If Org = "US01" Then
            Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) from SAP_DIMCOMPANY where SALESOFFICE in ('2300','2700') and COMPANY_ID='{0}' and ORG_ID='US01'", CompanyId))
            If N > 0 Then
                strDistChann = "10" : strDivision = "20"
            Else
                strDistChann = "30" : strDivision = "10"
            End If
        Else

        End If

        Dim OutList As New DataTable("Output")
        With OutList.Columns
            .Add("Mandt") : .Add("Vkorg") : .Add("Kunnr") : .Add("Matnr") : .Add("Mglme", GetType(Double)) : .Add("Kzwi1", GetType(Double)) : .Add("Netwr", GetType(Double))
        End With
        Dim ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim phaseOutItems As New ArrayList
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            .Price_Date = PricingDate.ToString("yyyyMMdd")
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each i As DataRow In Products.Rows
            'Check if item exists in current org, and if it is a non-standard p-trade ZSWL
            Dim chkSql As String = "select part_no, ITEM_CATEGORY_GROUP from sap_product_status where part_no='" + i.Item("PartNo").Trim().ToUpper() + "' and product_status in ('A','N','H') and sales_org='" + Org + "'"
            Dim chkDt As New DataTable
            Dim sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close()
                Throw ex
            End Try
            If chkDt.Rows.Count > 0 Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(i.Item("PartNo").Trim().ToUpper())
                    item.Req_Qty = i.Item("Qty").ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = i.Item("PartNo").Trim().ToUpper() : zr.Item("Qty") = i.Item("Qty") : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(i.Item("PartNo").Trim().ToUpper())
            End If
        Next
        sqlMA.Close()
        'Put non-standard p=trade to end of order lines, and point their higher level item to the first order line's line no.
        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = "ADAM-4520-D2E"
            item.Req_Qty = 1
            item.Req_Qty = CInt(item.Req_Qty) * 1000
            ItemsIn.Add(item)
            LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = CompanyId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = CompanyId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

        proxy1.Connection.Open()
        Try
            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            'Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()
            For Each r As DataRow In POutDt.Rows
                Dim outRow As DataRow = OutList.NewRow()
                outRow.Item("Mandt") = ""
                outRow.Item("Vkorg") = Org
                outRow.Item("Kunnr") = CompanyId
                outRow.Item("Matnr") = RemoveZeroString(r.Item("Material"))
                outRow.Item("Mglme") = 1.0
                outRow.Item("Kzwi1") = CDbl(r.Item("SUBTOTAL1")) / CDbl(r.Item("REQ_QTY"))
                outRow.Item("Netwr") = CDbl(r.Item("SUBTOTAL2")) / CDbl(r.Item("REQ_QTY"))
                OutList.Rows.Add(outRow)
            Next
        Catch ex As Exception
            ErrorMessage = ex.ToString()
        End Try
        proxy1.Connection.Close()
        Return OutList
    End Function
    
    'ICC 2015/11/04 Create web method to get order no. by prefix.
    <WebMethod()> _
    Public Function GetOrderNumber(ByVal preFix As String) As String
        Return SAPDAL.SAPDAL.SO_GetNumber(preFix.ToUpper())
    End Function
    
    <Serializable()> _
    Public Class ProductIn
        Public PartNo As String
        Public Qty As Integer
        Public Sub New(ByVal PN As String, ByVal Qty As Integer)
            PartNo = PN : Me.Qty = Qty
        End Sub
        Sub New()
            
        End Sub
    End Class

    <Serializable()> _
    Public Class ProductOut
        Public PartNo As String
        Public NetPrice As Decimal
        Public RecycleFee As Decimal
        Public Sub New(ByVal PN As String)
            PartNo = PN : NetPrice = 0 : RecycleFee = 0
        End Sub
        Sub New()
            
        End Sub
    End Class

    Function FormatItmNumber(ByVal ItemNumber As Integer) As String
        Dim Zeros As Integer = 6 - ItemNumber.ToString.Length
        If Zeros = 0 Then Return ItemNumber.ToString()
        Dim strItemNumber As String = ItemNumber.ToString()
        For i As Integer = 0 To Zeros - 1
            strItemNumber = "0" + strItemNumber
        Next
        Return strItemNumber
    End Function

    Public Function Format2SAPItem(ByVal Part_No As String) As String

        Try
            If IsNumericItem(Part_No) And Not Part_No.Substring(0, 1).Equals("0") Then
                Dim zeroLength As Integer = 18 - Part_No.Length
                For i As Integer = 0 To zeroLength - 1
                    Part_No = "0" & Part_No
                Next
                Return Part_No
            Else
                Return Part_No
            End If
        Catch ex As Exception
            Return Part_No
        End Try

    End Function

    Public Function IsNumericItem(ByVal part_no As String) As Boolean

        Dim pChar() As Char = part_no.ToCharArray()

        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next

        Return True
    End Function

    Public Function RemoveZeroString(ByVal NumericPart_No As String) As String

        If IsNumericItem(NumericPart_No) Then
            For i As Integer = 0 To NumericPart_No.Length - 1
                If Not NumericPart_No.Substring(i, 1).Equals("0") Then
                    Return NumericPart_No.Substring(i)
                    Exit For
                End If
            Next
            Return NumericPart_No
        Else
            Return NumericPart_No
        End If

    End Function

End Class
