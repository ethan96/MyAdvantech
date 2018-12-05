Imports Microsoft.VisualBasic
Imports System.Data.SqlClient

Public Class USPrjRegUtil
    Shared Sub SyncUSPrjOpty()
        Dim ridDt As DataTable = dbUtil.dbGetDataTable("MY", "select OPTY_ID from US_PrjReg_Mstr where reg_date>=GETDATE()-90 and OPTY_ID is not null")
        If ridDt.Rows.Count = 0 Then Exit Sub
        Dim ridAr As New ArrayList
        For Each r As DataRow In ridDt.Rows
            ridAr.Add("'" + r.Item("OPTY_ID") + "'")
        Next
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct A.ROW_ID,  "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, "))
            .AppendLine(String.Format(" A.NAME, "))
            .AppendLine(String.Format(" A.SUM_REVN_AMT,  "))
            .AppendLine(String.Format(" A.SUM_REVN_AMT as REVENUE_US_AMT, "))
            .AppendLine(String.Format(" A.SUM_WIN_PROB, "))
            .AppendLine(String.Format(" A.CURR_STG_ID,  "))
            .AppendLine(String.Format(" IsNull(B.NAME,'') as STAGE_NAME, "))
            .AppendLine(String.Format(" A.BU_ID, "))
            .AppendLine(String.Format(" C.NAME as BU_NAME, "))
            .AppendLine(String.Format(" A.CREATED, "))
            .AppendLine(String.Format(" E.LOGIN as CREATED_BY_LOGIN, "))
            .AppendLine(String.Format(" (select G.FST_NAME + ' ' + G.LAST_NAME  from S_CONTACT G where G.ROW_ID = E.ROW_ID) as CREATED_BY_NAME, "))
            .AppendLine(String.Format(" A.CURCY_CD, "))
            .AppendLine(String.Format(" IsNull(A.DESC_TEXT,'') as DESC_TEXT, "))
            .AppendLine(String.Format(" A.LAST_UPD, "))
            .AppendLine(String.Format(" F.LOGIN as LAST_UPD_BY_LOGIN, "))
            .AppendLine(String.Format(" (select H.FST_NAME + ' ' + H.LAST_NAME  from  S_CONTACT H where H.ROW_ID = F.ROW_ID) as LAST_UPD_BY_NAME, "))
            .AppendLine(String.Format(" A.PR_POSTN_ID, "))
            .AppendLine(String.Format(" D.POSTN_TYPE_CD, "))
            .AppendLine(String.Format(" IsNull(A.PR_PROD_ID,'') as PR_PROD_ID, "))
            .AppendLine(String.Format(" IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD, "))
            .AppendLine(String.Format(" A.STATUS_CD, "))
            .AppendLine(String.Format(" IsNull(A.STG_NAME,'') as STG_NAME, "))
            .AppendLine(String.Format(" I.LOGIN as SALES_TEAM_LOGIN, "))
            .AppendLine(String.Format(" (select J.FST_NAME + ' ' + J.LAST_NAME  from  S_CONTACT J where J.ROW_ID = I.ROW_ID) as SALES_TEAM_NAME, "))
            .AppendLine(String.Format(" A.MODIFICATION_NUM, "))
            .AppendLine(String.Format(" A.SUM_EFFECTIVE_DT, "))
            .AppendLine(String.Format(" IsNull(A.PAR_OPTY_ID,'') as PAR_OPTY_ID, "))
            .AppendLine(String.Format(" (case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end) as EXPECT_VAL, "))
            .AppendLine(String.Format(" IsNull((select convert(varchar(300),SCT.CRIT_SUCC_FACTORS) from  S_OPTY_T SCT where SCT.ROW_ID = SC.ROW_ID),'') as FACTOR, "))
            .AppendLine(String.Format(" IsNull((select top 1 CN.FST_NAME + ' ' + CN.LAST_NAME from S_CONTACT CN inner join S_OPTY_CON CON on CN.ROW_ID = CON.PER_ID where CON.OPTY_ID = A.ROW_ID),'') as CONTACT,  "))
            .AppendLine(String.Format(" (select top 1 CON.PER_ID from S_OPTY_CON CON where CON.OPTY_ID = A.ROW_ID) as CONTACT_ROW_ID, "))
            .AppendLine(String.Format(" A.SALES_METHOD_ID,  "))
            .AppendLine(String.Format(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_10 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as Assign_To_Partner, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_06 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as BusinessGroup, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_22 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Incentive_For_RBU, "))
            .AppendLine(String.Format(" IsNull((select X.X_ATTRIB_53 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as Indicator, "))
            .AppendLine(String.Format(" IsNull((select X.X_ATTRIB_54 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Product_Revenue, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_42 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Profile_Revenue, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_14 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Quantity, "))
            .AppendLine(String.Format(" IsNull(A.CHANNEL_TYPE_CD,'') as Channel, "))
            .AppendLine(String.Format(" D.PR_EMP_ID, "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID, "))
            .AppendLine(String.Format(" Year(A.CREATED) as CREATE_YEAR, "))
            .AppendLine(String.Format(" A.PR_PRTNR_ID,  "))
            .AppendLine(String.Format(" cast('' as nvarchar(100)) as PART_NO, "))
            .AppendLine(String.Format(" IsNull(X.ATTRIB_46,'') as ChannelContact,  "))
            .AppendLine(String.Format(" IsNull((select top 1 NAME from S_INDUST where ROW_ID=A.X_PR_OPTY_BAA_ID),'') as Primary_Opty_BAA, A.CREATED_BY "))
            .AppendLine(String.Format(" from  S_OPTY A left outer join S_OPTY_X X on A.ROW_ID=X.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_STG B on A.CURR_STG_ID = B.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_BU C on A.BU_ID = C.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_POSTN D on A.PR_POSTN_ID = D.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER E on A.CREATED_BY = E.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER F on A.LAST_UPD_BY = F.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER I on D.PR_EMP_ID = I.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_OPTY_T SC on SC.PAR_ROW_ID = A.ROW_ID  "))
            .AppendLine(String.Format(" where A.ROW_ID in ({0}) ", String.Join(",", ridAr.ToArray())))
        End With
        Try
            Dim newOptyDt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
            If newOptyDt.Rows.Count > 0 Then
                Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                bk.DestinationTableName = "siebel_opportunity"
                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_opportunity where row_id in ({0})", String.Join(",", ridAr.ToArray())))
                bk.WriteToServer(newOptyDt)
                'Throw New Exception("Sync " + newOptyDt.Rows.Count.ToString())
            End If
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "Sync US Opty list failed", ex.ToString(), False, "", "")
        End Try
    End Sub
    Public Shared Function GetSalesContact(ByVal strRBU As String) As DataTable
        Return dbUtil.dbGetDataTable("MY", _
        String.Format("select SALES_NAME, SALES_EMAIL from MYADVANTECH_ANA_SALESCONTACT where RBU='{0}' order by SALES_NAME ", _
                      Replace(strRBU, "'", "''").Trim()))
    End Function

    Public Shared Function AutoSuggestCustName(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 30 a.ACCOUNT_NAME as NAME, a.ROW_ID   "))
            .AppendLine(String.Format(" from SIEBEL_ACCOUNT a  "))
            .AppendLine(String.Format(" where a.PARENT_ROW_ID<>a.ROW_ID and a.PARENT_ROW_ID<>''  "))
            .AppendLine(String.Format(" and a.PARENT_ROW_ID in (select z.ROW_ID from SIEBEL_ACCOUNT z where z.ERP_ID='{0}' and z.ERP_ID<>'') ", HttpContext.Current.Session("company_id").ToString.Replace("'", "").Trim().ToUpper()))
            .AppendLine(String.Format(" order by a.ACCOUNT_NAME "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        Dim items As New List(Of String)
        If dt.Rows.Count > 0 Then
            'Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                'str(i) = dt.Rows(i).Item(0)
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dt.Rows(i).Item("NAME"), dt.Rows(i).Item("ROW_ID")))
            Next
            Return items.ToArray()
        End If
        Return Nothing
    End Function

    Public Shared Function GetAddrByCustRowId(ByVal rowid As String) As DataTable
        If rowid.Trim() = "" Then Return New DataTable("ACCOUNTADDR")
        rowid = rowid.Trim().Replace("'", "").ToUpper()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1 IsNull(d.ADDR,'') as ADDRESS,IsNull(d.ZIPCODE,'') as ZIPCODE,  "))
            .AppendLine(String.Format(" IsNull(d.STATE,'') as STATE,IsNull(d.COUNTRY,'') as COUNTRY, IsNull(d.CITY,'') as CITY "))
            .AppendLine(String.Format(" from S_ORG_EXT a left join S_ADDR_ORG d on a.PR_ADDR_ID=d.ROW_ID "))
            .AppendLine(String.Format(" where a.ROW_ID='{0}' ", rowid))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        dt.TableName = "ACCOUNTADDR"
        Return dt
    End Function

    Public Shared Function InsertPrj(ByVal Request_id As String, ByVal Appliciant As String, ByVal CPartner As String, _
                                     ByVal Contact As String, ByVal Phone As String, ByVal Email As String, _
                                     ByVal City1 As String, ByVal State1 As String, ByVal AdvSalesContact As String, ByVal Company As String, _
                                     ByVal Address As String, ByVal City2 As String, ByVal State2 As String, ByVal Zip As String, ByVal Project_Name As String, _
                                     ByVal Contact1 As String, ByVal ContactPhone1 As String, ByVal ContactEMail1 As String, ByVal Contact2 As String, _
                                     ByVal ContactPhone2 As String, ByVal ContactEMail2 As String, ByVal Prototype_Date As String, _
                                     ByVal Production_Date As String, ByVal Org_ID As String) As Integer
        Dim Reg_date As String = Date.Now
        Dim Status As String = "Request"
        Dim Comment As String = "", Reject_Reason As String = "", Approve_Date1 As String = "", Approve_Date2 As String = ""
        Dim Expire_Date As String = "", Approve_Code As String = "", internal_comment As String = "", Approve_Date3 As String = ""
        Dim Add_query As String = ""
        'Dim Areq_id As String = tid

        Add_query = _
                   " Insert into US_PrjReg_Mstr Values( " & _
                   " '" + Request_id + "', " & _
                   " '" + Appliciant + "', " & _
                   " N'" + CPartner + "', " & _
                   " N'" + Contact + "', " & _
                   " '" + Phone + "', " & _
                   " '" + Email + "', " & _
                   " N'" + City1 + "', " & _
                   " N'" + State1 + "', " & _
                   " '" + AdvSalesContact + "', " & _
                   " N'" + Company + "', " & _
                   " N'" + Address + "', " & _
                   " N'" + City2 + "', " & _
                   " N'" + State2 + "', " & _
                   " N'" + Zip + "', " & _
                   " N'" + Project_Name + "', " & _
                   " N'" + Comment + "', " & _
                   " '" + Reg_date + "', " & _
                   " N'" + Reject_Reason + "', " & _
                   " '" + Expire_Date + "', " & _
                   " N'" + Contact1 + "', " & _
                   " '" + ContactPhone1 + "', " & _
                   " '" + ContactEMail1 + "', " & _
                   " N'" + Contact2 + "', " & _
                   " '" + ContactPhone2 + "', " & _
                   " '" + ContactEMail2 + "', " & _
                   " '" + Approve_Code + "', " & _
                   " '" + Prototype_Date + "', " & _
                   " '" + Production_Date + "', " & _
                   " N'" + internal_comment + "', " & _
                   " '" + Org_ID + "', " & _
                   " '" + Status + "', " & _
                   " '" + Approve_Date1 + "', " & _
                   " '" + Approve_Date2 + "', " & _
                   " '" + Approve_Date3 + "','') "
        Return dbUtil.dbExecuteNoQuery("b2b", Add_query)
        'Return Add_query
    End Function

    Public Shared Function UpdatePrj(ByVal tid As String, ByVal Appliciant As String, ByVal CPartner As String, _
                                     ByVal Contact As String, ByVal Phone As String, ByVal Email As String, _
                                     ByVal City1 As String, ByVal State1 As String, ByVal AdvSalesContact As String, ByVal Company As String, _
                                     ByVal Address As String, ByVal City2 As String, ByVal State2 As String, ByVal Zip As String, ByVal Project_Name As String, _
                                     ByVal Contact1 As String, ByVal ContactPhone1 As String, ByVal ContactEMail1 As String, ByVal Contact2 As String, _
                                     ByVal ContactPhone2 As String, ByVal ContactEMail2 As String, ByVal Prototype_Date As String, _
                                     ByVal Production_Date As String, ByVal Org_ID As String) As Integer
        Dim Reg_date As String = Date.Now
        Dim Status As String = "Request"
        Dim Comment As String = "", Reject_Reason As String = "", Approve_Date1 As String = "", Approve_Date2 As String = ""
        Dim Expire_Date As String = "", Approve_Code As String = "", internal_comment As String = "", Approve_Date3 As String = ""
        Dim Add_query As String = ""
        Dim Areq_id As String = tid
        Add_query = _
            " update US_PrjReg_Mstr    " & _
            " SET [Request_id] = '" + tid + "' " & _
            "   ,[Appliciant] = '" + Appliciant + "' " & _
            "   ,[CPartner] = N'" + CPartner + "' " & _
            "   ,[Contact] = N'" + Contact + "' " & _
            "   ,[Phone] = '" + Phone + "'" & _
            "   ,[Email] = '" + Email + "'" & _
            "   ,[City1] =  N'" + City1 + "' " & _
            "   ,[State1] =    N'" + State1 + "'" & _
            "   ,[AdvSalesContact] =    '" + AdvSalesContact + "'" & _
            "   ,[Company] =   N'" + Company + "' " & _
            "   ,[Address] =  N'" + Address + "' " & _
            "   ,[City2] =    N'" + City2 + "'" & _
            "   ,[State2] =    N'" + State2 + "'" & _
            "   ,[Zip] =    N'" + Zip + "'" & _
            "   ,[Project_Name] =  N'" + Project_Name + "' " & _
            "   ,[Status] =  '" + Status + "' " & _
            "   ,[Comment] =  N'" + Comment + "' " & _
            "   ,[Reg_date] = '" + Reg_date + "'  " & _
            "   ,[Reject_Reason] = N'" + Reject_Reason + "'  " & _
            "   ,[Approve_Date1] =  '" + Approve_Date1 + "' " & _
            "   ,[Approve_Date2] =  '" + Approve_Date2 + "'  " & _
            "   ,[Expire_Date] =  '" + Expire_Date + "' " & _
            "   ,[Contact1] =   N'" + Contact1 + "'" & _
            "   ,[ContactPhone1] = '" + ContactPhone1 + "'  " & _
            "   ,[ContactEMail1] = '" + ContactEMail1 + "' " & _
            "   ,[Contact2] =   N'" + Contact2 + "' " & _
            "   ,[ContactPhone2] =  '" + ContactPhone2 + "' " & _
            "   ,[ContactEMail2] =   '" + ContactEMail2 + "'" & _
            "   ,[Approve_Code] =  '" + Approve_Code + "' " & _
            "   ,[Prototype_Date] =  '" + Prototype_Date + "'  " & _
            "   ,[Production_Date] =   '" + Production_Date + "'" & _
            "   ,[internal_comment] =  N'" + internal_comment + "'" & _
            "   ,[Org_ID] =  '" + Org_ID + "' " & _
            "   ,[Approve_Date3] =  '" + Approve_Date3 + "' " & _
            "   ,[OPTY_ID] =''    where Request_id = '" + tid + "' "
        ' Return Add_query
        Return dbUtil.dbExecuteNoQuery("b2b", Add_query)
    End Function

    Public Shared Function NewRowId(ByVal table_name As String, ByVal connName As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            If CInt( _
              dbUtil.dbExecuteScalar(connName, "select count(*) as counts from " + table_name + " where request_id='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    Public Shared Function GetDTList(ByVal Request_id As String) As DataTable
        Dim DtList As New DataTable
        Dim sql As String = String.Format("select * from US_PRJREG_DET where Request_id ='{0}' order by line", Request_id)
        DtList = dbUtil.dbGetDataTable("b2b", sql)
        Return DtList
    End Function
    Public Shared Function GetProjectByRequest_id(ByVal Request_id As String) As DataTable
        Dim sql_query As String = " Select * From US_PrjReg_Mstr  Where Request_id = '" + Request_id.ToString.Trim + "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql_query)
        Return dt
    End Function
    Public Shared Function DTList_AddLine(ByVal Request_id As String, ByVal Part_no As String _
                                          , ByVal Qty As Integer, ByVal DebitPricing As Double, ByVal CPricing As Double, ByVal TargetPricing As Double, ByVal Comments As String) As Integer

        Dim LineNO As Integer = 1
        Dim MAXLINE As Object = dbUtil.dbExecuteScalar("B2B", "select MAX(LINE) FROM US_PRJREG_DET WHERE Request_id ='" + Request_id + "'")
        If MAXLINE IsNot Nothing AndAlso MAXLINE.ToString <> "" Then
            LineNO = Integer.Parse(MAXLINE.ToString) + 1
        End If
        Dim insertsql As String = "INSERT INTO [US_PRJREG_DET] ([Request_id],[Part_no],[Qty],[DebitPricing],[CPricing],[SPPricing],[Line],[TargetPricing],[ApprovedPricing],[Comments])VALUES(" & _
            " '" + Request_id + "','" + Part_no.Replace("'", "''") + "'," + Qty.ToString + "," + DebitPricing.ToString + "," + CPricing.ToString + ",0," + LineNO.ToString + "," + TargetPricing.ToString + ",0,N'" + Comments.Replace("'", "''") + "')"

        dbUtil.dbExecuteNoQuery("B2B", insertsql)
        Return 1
    End Function
    Public Shared Function DTList_updateLine(ByVal Request_id As String, ByVal Line As Integer _
                                          , ByVal Qty As Integer, ByVal DebitPricing As Double, ByVal CPricing As Double, ByVal ApprovedPricing As Double, ByVal TargetPricing As Double, ByVal comments As String) As Integer
        Dim updatesql As String = String.Format("update   US_PRJREG_DET  set Qty ={0},CPricing={1} ,ApprovedPricing={2},TargetPricing={5},Comments=N'{6}' where Request_id = '{3}'" & _
                                               " and Line ={4}", Qty, CPricing, ApprovedPricing, Request_id, Line, TargetPricing, comments)
        dbUtil.dbExecuteNoQuery("B2B", updatesql)
        Return 1
    End Function
    Public Shared Function DTList_DelLine(ByVal Request_id As String, ByVal Line As Integer) As Integer
        Dim delsql As String = String.Format("delete from    US_PRJREG_DET  where Request_id = '{0}'" & _
                                                " and Line ={1}", Request_id, Line)
        dbUtil.dbExecuteNoQuery("B2B", delsql)
        Dim sql As String = String.Format("select * from US_PRJREG_DET where Line > {0} and Request_id ='{1}'", Line, Request_id)
        If dbUtil.dbGetDataTable("b2b", sql).Rows.Count > 0 Then
            dbUtil.dbExecuteNoQuery("B2B", "update US_PRJREG_DET set Line = line -1 where Request_id ='" + Request_id + "' and line > " + Line.ToString + " ")
        End If
        Return 1
    End Function
    Public Shared Function checkprods(ByVal Request_id As String) As Boolean
        Dim sql As String = String.Format("select Request_id from US_PRJREG_DET where Request_id ='{0}'", Request_id)
        If dbUtil.dbGetDataTable("b2b", sql).Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetTOTALrevenue(ByVal Request_id As String) As String
        Dim TOTALrevenue As String = ""
        Dim obj As Object = dbUtil.dbExecuteScalar("b2b", "select  SUM(QTY * CPricing)  from US_PrjReg_Det  where request_id='" + Request_id + "'")
        If obj IsNot Nothing AndAlso Double.Parse(obj) > 0 Then
            TOTALrevenue = obj.ToString()
        Else
            obj = dbUtil.dbExecuteScalar("b2b", "select  SUM(QTY * DebitPricing)  from US_PrjReg_Det  where request_id='" + Request_id + "'")
            If obj IsNot Nothing AndAlso Double.Parse(obj) > 0 Then
                TOTALrevenue = obj.ToString()
            End If
        End If
        If Double.TryParse(TOTALrevenue, 0) = False OrElse CDbl(TOTALrevenue) < 0 Then TOTALrevenue = "0"
        Return TOTALrevenue
    End Function
    Public Shared Function GetPrimaryUseridByEmal(ByVal Email As String) As String
        Dim PrimaryUserid As String = ""
        Dim obj As Object = dbUtil.dbExecuteScalar("b2b", "select top 1 a.USER_LOGIN  from SIEBEL_POSITION as  a inner join SIEBEL_CONTACT as b on a.CONTACT_ID = b.ROW_ID and b.EMAIL_ADDRESS ='" + Email + "'")
        If obj IsNot Nothing AndAlso obj.ToString.Trim <> "" Then
            PrimaryUserid = obj.ToString.Trim
        End If
        Return PrimaryUserid
    End Function
    Public Shared Function Get_Owner_PosId(ByVal AccountRowID As String, ByRef strOwner As String, ByRef strPosId As String) As Integer
        strPosId = "5R-1HMM"  'Lynette's position id
        strOwner = "LYNETTEA"
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT  b.USER_LOGIN, b.EMAIL_ADDR, a.primary_flag, b.ROW_ID as POSITION_ID "))
            .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT_OWNER AS a INNER JOIN SIEBEL_POSITION AS b ON a.OWNER_ID = b.CONTACT_ID "))
            .AppendLine(String.Format(" where b.USER_LOGIN is not null and b.USER_LOGIN<>'' and a.account_row_id='{0}' ", AccountRowID.Replace("'", "")))
            .AppendLine(String.Format(" order by a.primary_flag desc  "))
        End With
        Dim odt As DataTable = dbUtil.dbGetDataTable("b2b", sb.ToString())
        If odt.Rows.Count > 0 Then
            strOwner = odt.Rows(0).Item("EMAIL_ADDR") 'ICC 2016/3/8 Change user_login to email_addr
            strPosId = odt.Rows(0).Item("POSITION_ID")
        End If
        Return 1
    End Function
    Public Shared Function GetCurr(ByVal AccountRowID As String) As String
        Dim Curr As String = "USD"
        Dim curObj As Object = dbUtil.dbExecuteScalar("CRMDB75", String.Format("select top 1 IsNull(BASE_CURCY_CD,'USD') as BASE_CURCY_CD from S_ORG_EXT where ROW_ID='{0}'", AccountRowID.Replace("'", "''")))
        If curObj IsNot Nothing AndAlso curObj.ToString <> "" Then Curr = curObj.ToString()
        '  If curObj <> "USD" Then curObj = "USD"
        Return Curr
    End Function
    Public Shared Function GetContactRowId(ByVal user_id As String) As String
        Dim ContactRowId As String = ""
        Dim obj As Object = dbUtil.dbExecuteScalar("b2b", "select top 1 row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='" + user_id.ToString.Trim + "' order by ACCOUNT_STATUS")
        If obj IsNot Nothing Then ContactRowId = obj.ToString()
        Return ContactRowId
    End Function
    Public Shared Function GetAccountRowID(ByVal company_id As String) As String
        Dim AccountRowID As String = "1-2TAAS7"
        Dim obj As Object = dbUtil.dbExecuteScalar("b2b", "Select top 1 ROW_ID from SIEBEL_ACCOUNT where ERP_ID='" + company_id.ToString.Trim + "' order by account_Status")
        If obj IsNot Nothing Then AccountRowID = obj.ToString()
        Return AccountRowID
    End Function
    Public Shared Function checkdatemin(ByVal o As DateTime) As String
        ' If o = DateTime.MinValue Then
        If CType(o, DateTime) < CDate("1900/01/02") Then
            Return ""
        Else
            Return DateTime.Parse(o).ToString("yyyy/MM/dd") 'o.ToShortDateString
        End If
    End Function
    Public Shared Function Getdatetime(ByVal o As Object) As String
        If Date.TryParse(o, Now) = True AndAlso CDate(o) > CDate("2/1/1900") Then
            Return CDate(o).ToString("MM/dd/yyyy")
        Else
            Return DateAdd(DateInterval.Month, 6, CDate(o)).ToString("MM/dd/yyyy")
        End If
    End Function
    Public Shared Function GetSiebelAccountList(ByVal searchkey As String) As DataTable
        'Dim dt As DataTable = dbUtil.dbGetDataTable("my", "select top 10 ROW_ID,(ROW_ID + '&'+ACCOUNT_NAME ) as ACCOUNT_NAME from SIEBEL_ACCOUNT where  ACCOUNT_NAME like N'%" + searchkey.Trim + "%' and ERP_ID <>'' and ERP_ID is not null")
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", "select top 10 ROW_ID,(ROW_ID + '&'+ACCOUNT_NAME ) as ACCOUNT_NAME from SIEBEL_ACCOUNT where  ACCOUNT_NAME like N'%" + searchkey.Trim + "%' ")
        Return dt
    End Function
    Public Shared Function GetSiebelOPPORTUNITYListByAccountRowID(ByVal searchkey As String) As DataTable
        Dim SQL As New StringBuilder
        'SQL.Append("  select top 12 A.NAME + ' ( ' + ")
        'SQL.Append("  (select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID = A.ACCOUNT_ROW_ID AND ACCOUNT_NAME <>'' and ACCOUNT_NAME is not null) ")
        'SQL.AppendFormat("   + ' )' as ACCOUNT,*  from  SIEBEL_OPPORTUNITY A where A.NAME LIKE '%{0}%'  and A.ACCOUNT_ROW_ID <>'' and A.ACCOUNT_ROW_ID is not null", searchkey)
        SQL.AppendFormat(" select top 12  (A.NAME + case when DESC_TEXT is null or DESC_TEXT = '' then '' else ' ('+ DESC_TEXT +')'  end ) as name  from  SIEBEL_OPPORTUNITY A where A.ACCOUNT_ROW_ID = '{0}' ", searchkey)
        SQL.AppendLine(" and A.ACCOUNT_ROW_ID <>'' and A.ACCOUNT_ROW_ID is not null")
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", SQL.ToString())
        Return dt
    End Function
    Public Shared Function GetSiebelOPPORTUNITYListfromname(ByVal searchkey As String) As DataTable
        Dim SQL As New StringBuilder
        SQL.Append("  select top 12 A.NAME + ' ( ' + ")
        SQL.Append("  (select top 1 ACCOUNT_NAME from SIEBEL_ACCOUNT where ROW_ID = A.ACCOUNT_ROW_ID AND ACCOUNT_NAME <>'' and ACCOUNT_NAME is not null) ")
        SQL.AppendFormat("   + ' )' as ACCOUNT,*  from  SIEBEL_OPPORTUNITY A where A.NAME LIKE '%{0}%'  and A.ACCOUNT_ROW_ID <>'' and A.ACCOUNT_ROW_ID is not null", searchkey)
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", SQL.ToString())
        Return dt
    End Function
    Public Shared Function GetSiebelOpportunityPosition(ByVal OptyId As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.NAME from S_POSTN a where a.ROW_ID in (select z.PR_POSTN_ID from S_OPTY z where z.ROW_ID='{0}')", OptyId))
        If dt.Rows.Count > 0 Then
            Return dt
        End If
        Return Nothing
    End Function
    Public Shared Function GetParEmail(ByVal StrAdvSalesContact As String) As String
        Dim ParEmail As String = ""
        Dim Par_DT As DataTable = dbUtil.dbGetDataTable("b2b", String.Format( _
                                   " select distinct PAR_EMAIL  from  SIEBEL_SALES_HIERARCHY  " + _
                                   " where email ='{0}' and PAR_EMAIL <> '' and PAR_EMAIL is not null  " + _
                                   " and dbo.IsEmail(PAR_EMAIL) =1  ", _
                                    StrAdvSalesContact))
        If Par_DT.Rows.Count > 0 Then
            For i As Integer = 0 To Par_DT.Rows.Count - 1
                ParEmail += Par_DT.Rows(i).Item("PAR_EMAIL") + ","
            Next
        End If
        If ParEmail.Trim.EndsWith(",") Then
            ParEmail = ParEmail.Trim.Substring(0, ParEmail.Length - 1)
        End If
        Return ParEmail
    End Function
    Public Shared Function GetRSMforAAC(ByVal StrAdvSalesContact As String) As String
        Dim RSM As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 PARENT_SALES from MYADVANTECH_ANA_SALESCONTACT where SALES_EMAIL='{0}' and RBU='AAC'", StrAdvSalesContact)) 'GetParEmail(M.AdvSalesContact)
        If RSM IsNot Nothing Then Return RSM.ToString
        Return ""
    End Function
    Public Shared Function SendEmail(ByVal Request_id As String, ByVal TypeInt As Integer) As Integer
        Dim strHeader As String = "", strFooter As String = "", strFrom As String = ""
        Dim DT As DataTable = dbUtil.dbGetDataTable("my", "select isnull(HEADER,'') as  HEADER,isnull(FOOTER,'') as FOOTER ,isnull(EMAIL_FROM,'') as  EMAIL_FROM from dbo.EMAIL_TEMPLATE where ORG_ID ='" + HttpContext.Current.Session("RBU") + "'")
        If DT.Rows.Count = 0 Then strFrom = "eBusiness.AEU@advantech.eu"
        If DT.Rows.Count > 0 Then
            strHeader = DT.Rows(0).Item("HEADER")
            strFooter = DT.Rows(0).Item("FOOTER")
            strFrom = DT.Rows(0).Item("EMAIL_FROM")
        End If
        '-------------------------------------------------------------------------------------------
        Dim App_Email As String = ""
        Dim AdvSalesContact As String = ""
        Dim AccountOwner As String = ""
        Dim ManagementEmail As String = ""

        Dim M As New Us_Prjreg_M(Request_id)
        App_Email = M.Email
        AdvSalesContact = IIf(LCase(M.AdvSalesContact) Like "*@*", M.AdvSalesContact, "")

        If M.Org_ID = "AENC" Then
            AccountOwner = GetParEmail(M.AdvSalesContact)
            ManagementEmail = "MyAdvantech.AENC@advantech.com,Marady.Pek@advantech.com,christine.huang@advantech.com,peter.kim@advantech.com"
        ElseIf M.Org_ID = "AAC" Then
            AccountOwner = GetRSMforAAC(M.AdvSalesContact)
            ManagementEmail = "" 'Roy.Wang@advantech.com
        End If
        If TestSendEmail() = True Then
            ManagementEmail = "ming.zhao@advantech.com.cn,lynette.andersen@advantech.com"
        End If
        '------------------------------------------------------------------------------------------
        Dim strSubject As String = ""
        Dim strTo As String = ""
        Dim strCC As String = ""
        Dim strBcc As String = "eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn,lynette.andersen@advantech.com"
        Dim mailbody As String = ""
        '----------------------------------------------------------------------------------------
        Select Case TypeInt
            Case 0
                strSubject = " "  'CP submit
                strTo = App_Email
                strCC = ""
                SendEmail_External(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
                strSubject = "" 'Sent to SalesContact After  CP submitted
                If M.Org_ID = "AAC" Then
                    strTo = AdvSalesContact
                    strCC = AccountOwner
                Else
                    strTo = AdvSalesContact
                    strCC = ManagementEmail
                End If
                SendEmail_Internal(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
            Case 1
                strSubject = " "  'SalesContact Approve
                If M.Org_ID = "AAC" Then
                    strTo = AccountOwner
                    strCC = ""
                Else
                    strTo = ManagementEmail
                    strCC = ""
                End If
                SendEmail_Internal(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
            Case 2
                strSubject = " " 'SalesContact Reject
                strTo = App_Email
                strCC = ""
                SendEmail_External(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
                If M.Org_ID = "AAC" Then
                    strTo = AdvSalesContact
                    strCC = AccountOwner
                Else
                    strTo = AdvSalesContact
                    strCC = ManagementEmail
                End If
                SendEmail_Internal(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
            Case 3, 4, 5, 6
                strTo = App_Email
                strCC = ""
                SendEmail_External(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
                If M.Org_ID = "AAC" Then
                    strTo = AdvSalesContact
                    strCC = AccountOwner
                Else
                    strTo = AdvSalesContact
                    strCC = ManagementEmail
                End If
                SendEmail_Internal(strTo, strFrom, strSubject, strCC, strBcc, Request_id, strHeader, strFooter)
        End Select
        'If String.IsNullOrEmpty(strTo) Then   strTo = "eBusiness.AEU@advantech.eu"
        Return 1
    End Function
    Public Shared Function SendEmail_External(ByVal strTo As String, ByVal strFrom As String, ByVal strSubject As String, ByVal strCC As String, ByVal strBcc As String, ByVal Request_id As String, ByVal strHeader As String, ByVal strFooter As String) As Integer
        Dim mailbody As String = USPrjRegUtil.getmailbody(Request_id, strHeader, strFooter, False)
        strTo = strTo.Trim
        strFrom = strFrom.Trim
        strCC = strCC.Trim
        strBcc = strBcc.Trim
        If strSubject.Trim = "" Then strSubject = "MyAdvantech Project Registration"
        If TestSendEmail() = True Then
            mailbody = "<br>to:" + strTo + "<br/>cc:" + strCC + "<br>Bcc: " + strBcc + "<br/><br/>" + mailbody
            Util.SendEmail(HttpContext.Current.Session("user_id").ToString, strFrom, strSubject, mailbody, True, "eBusiness.AEU@advantech.eu", "")
        Else
            Util.SendEmail(strTo, strFrom, strSubject, mailbody, True, strCC, strBcc)
        End If
        Return 1
    End Function
    Public Shared Function SendEmail_Internal(ByVal strTo As String, ByVal strFrom As String, ByVal strSubject As String, ByVal strCC As String, ByVal strBcc As String, ByVal Request_id As String, ByVal strHeader As String, ByVal strFooter As String) As Integer
        Dim mailbody As String = USPrjRegUtil.getmailbody(Request_id, strHeader, strFooter, True)
        strTo = strTo.Trim
        strFrom = strFrom.Trim
        strCC = strCC.Trim
        strBcc = strBcc.Trim
        If strSubject.Trim = "" Then strSubject = "MyAdvantech Project Registration"
        If TestSendEmail() = True Then
            mailbody = "<br>to:" + strTo + "<br/>cc:" + strCC + "<br>Bcc: " + strBcc + "<br/><br/>" + mailbody
            Util.SendEmail(HttpContext.Current.Session("user_id").ToString, strFrom, strSubject, mailbody, True, "eBusiness.AEU@advantech.eu", "")
        Else
            Util.SendEmail(strTo, strFrom, strSubject, mailbody, True, strCC, strBcc)
        End If
        Return 1
    End Function
    Public Shared Function TestSendEmail() As Boolean
        Return False
        If Util.IsAEUIT() Or HttpContext.Current.Session("user_id").ToString.Trim = "mingzhao12021@163.com" Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function getmailbody(ByVal requestid As String, ByVal strHeader As String, ByVal strFooter As String, Optional ByVal IsShowComment As Boolean = False) As String
        Dim url As String = "http://" & HttpContext.Current.Request.Url.Host & ":" & HttpContext.Current.Request.Url.Port & "" & HttpContext.Current.Request.ApplicationPath & "/" & "My/ProjectApprove.aspx?req=" & requestid
        Dim s As String = ""
        Dim M As New Us_Prjreg_M(requestid)
        Dim t1 As String = checkdatemin(M.Prototype_Date)
        Dim t2 As String = checkdatemin(M.Production_Date)
        s = "<style type=""text/css"">.bg0{background-color:#46A6D6;text-align:left;height:25px;font-weight:bold;color:#FFFFFF;font-size:14px;vertical-align:middle;}.bg1{font-weight: bold;background-color:#DFF4F7;text-align:right;width:40%;vertical-align:middle;height:23px;}.bg2{background-color:#EFF9FB;}body{font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#666666;}</style>" & _
            " <table width=""90%"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""2""> " & _
            " <tr><td valign=""middle"" align=""left"" colspan=""2"">" + strHeader + "</td></tr> "
        If M.Status.Trim.ToLower = "request" Then
            s += " <tr><td valign=""middle"" align=""left"" colspan=""2"">This email is to confirm that the below project registration information was submitted to Advantech. Advantech is currently reviewing your submission.  You will receive a status update soon. If you have any questions, please contact your Advantech account manager.  </td></tr>"
        Else
            s += " <tr><td valign=""middle"" align=""left"" colspan=""2"">This email is to confirm that the below project registration information was processed by Advantech. See below for the status update. If you have any questions, please contact your Advantech account manager.  </td></tr>"
        End If
        s += " <tr><td valign=""middle"" colspan=""2"" class=""bg0""> Applicant Info</td></tr> " & _
           " <tr><td valign=""middle"" class=""bg1"">Applicant：</td><td valign=""middle"" class=""bg2"">" & M.Appliciant & "</td></tr> " & _
           " <tr><td valign=""middle"" class=""bg1"">Channel Partner：</td><td valign=""middle"" class=""bg2"">" & M.CPartner & "</td></tr> " & _
           " <tr><td valign=""middle""class=""bg1"">Contact Person：</td><td valign=""middle"" class=""bg2"">" & M.Contact & "</td></tr> " & _
           " <tr><td valign=""middle"" class=""bg1"">Phone Number：</td><td valign=""middle"" class=""bg2"">" & M.Phone & "</td></tr> " & _
           "<tr><td valign=""middle"" class=""bg1"">Email Address:</td><td valign=""middle"" class=""bg2"">" & M.Email & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">City and State:</td><td valign=""middle"" class=""bg2""><b>City:</b> " & M.City1 & " &nbsp;<b>State:</b> " & M.State1 & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Advantech Sales Contact:</td><td valign=""middle"" class=""bg2"">" & M.AdvSalesContact & "</td></tr>" & _
           "<tr><td  height='15'></td><td></td></tr>" & _
           "<tr><td valign=""middle"" colspan='2' class=""bg0""> Project Registration Info</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Company:</td><td valign=""middle"" class=""bg2"">" & M.Company & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Address:</td><td valign=""middle"" class=""bg2"">" & M.Address & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">City/State:</td><td valign=""middle"" class=""bg2""><b>City:</b> " & M.City2 & " &nbsp;<b>State:</b> " & M.State2 & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Project Name:</td><td valign=""middle"" class=""bg2"">" & M.Project_Name & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Procument Contact:</td><td valign=middle class=""bg2"" >" & M.Contact1 & "" & _
           "&nbsp;&nbsp;<b>Phone:</b>" & M.ContactPhone1 & "&nbsp;&nbsp;<b>eMail:</b>" & M.ContactEMail1 & "</span>" & _
           "</td></tr><tr><td valign=""middle"" class=""bg1"">Engineering Contact:</td><td valign=middle class=""bg2"">" & M.Contact2 & "" & _
           "&nbsp;&nbsp;<b>Phone:</b>" & M.ContactPhone2 & "&nbsp;&nbsp;<b>eMail:</b>" & M.ContactEMail2 & "" & _
           "<tr><td valign=""middle"" class=""bg1"">Prototype Date:</td><td valign=""middle"" class=""bg2"">" & t1 & "</td></tr>" & _
           "<tr><td valign=""middle"" class=""bg1"">Production Date:</td><td valign=""middle"" class=""bg2"">" & t2 & "</td></tr>"
        If IsShowComment = True Then
            s += "<tr><td valign=""middle"" class=""bg1"" >Internal Communication:</td><td valign=""middle"" class=""bg2"">" & M.Internal_Comment & "</td></tr>"
        End If
        If M.Reject_Reason <> "" Then
            s += "</tr><tr><td valign=""middle"" class=""bg1"">Reject Reason:</td><td valign=""middle"" class=""bg2"">" & M.Reject_Reason & "</td></tr>"
        End If

        Dim dtpro As DataTable = dbUtil.dbGetDataTable("B2B", "select * ,0 as Margin from US_PrjReg_Det where request_id = '" + requestid + "'")
        If dtpro.Rows.Count > 0 Then
            s += "<tr>" & _
                    "<td colspan=2  height='15'></td></tr>" & _
                    "<tr><td colspan=2 valign=""middle"" class=""bg0""> Products included in Project</td></tr>" & _
                    "<tr><td  height='15'></td><td align=left></td></tr>" & _
                    "<tr><td width='100%' colspan=2>" & _
                    "<div><table  cellspacing='0' border='1'  style='width:100%;border-collapse:collapse;'>" & _
                                "<tr align='center' style='color:#333399;background-color:#EBEADB;font-weight:bold;'>" & _
                                "<th scope='col'>No.</th>" & _
                                "<th scope='col'>Items #</th>" & _
                                "<th scope='col'>Distributor PO Price</th>" & _
                                "<th scope='col'>Annual Qty</th>"
            If M.Opty_Id.Trim.ToUpper <> "AAC" Then
                s += "<th scope='col'>Dist Target Price</th>" & _
                                "<th scope='col'>End user cost</th>"
            End If

            s += "<th scope='col'>Approved Debit Pricing</th>" & _
           "<th scope='col'>Comments</th>" & _
           "</tr>"
            For i As Integer = 0 To dtpro.Rows.Count - 1
                s += "<tr style='color:#333333;background-color:White;'><td align='center' style='width:50px;'>" & i + 1 & _
                "</td><td align='left'>" & dtpro.Rows(i)("Part_no") & "</td>" & _
                "<td>" & String.Format("{0:N2}", dtpro.Rows(i)("DebitPricing")) & "</td>" & _
                "<td align='left'>" & dtpro.Rows(i)("Qty") & "</td>"
                If M.Opty_Id.Trim.ToUpper <> "AAC" Then
                    s += "<td>" & String.Format("{0:N2}", dtpro.Rows(i)("CPricing")) & "</td>" & _
              "<td align='left'>" & String.Format("{0:N2}", dtpro.Rows(i)("TargetPricing")) & "</td>"
                End If
                s += "<td>" & String.Format("{0:N2}", dtpro.Rows(i)("ApprovedPricing")) & "</td>" & _
               "<td>" & dtpro.Rows(i)("Comments") & "</td>" & _
                "</tr>"
            Next
            s += "</table></div></td></tr><tr><td height='15' colspan=""2""></td></tr>"
            s += String.Format("<tr><td align=""center"" colspan=""2"">{0}</table></td></tr>", GetApproveHtml(M.Request_id))
            s += "<tr><td  align=""left""  colspan=""2""><br /><a href='" & url & "'>Click Here To See</a></td></tr>"
            s += String.Format("<tr><td  colspan=""2""><br><br>{0}</td></tr></table>", strFooter)

        End If
        Return s
    End Function
    Public Shared Function GetApproveHtml(ByVal Requestid As String) As String
        Dim M As New Us_Prjreg_M(Requestid)
        Dim Str As String = String.Format("<table width=""570"" border=""0"" align=""center""><tr><td width=""180""  align=""right""><b>Submitted for Review : </b> </td><td>  by {0}  on {1}</td></tr>", M.Appliciant, M.Reg_date)
        Select Case M.Status
            Case "Approve1", "Reject1"
                Str += GetApprovelStep(M.Request_id, 1)
            Case "Approve2", "Reject2"
                Str += GetApprovelStep(M.Request_id, 2)
            Case "WON", "LOST"
                Str += GetApprovelStep(M.Request_id, 3)
        End Select
        Return Str
    End Function
    Public Shared Function GetApprovelStep(ByVal Requestid As String, ByVal Step_Int As String) As String
        Dim M As New Us_Prjreg_M(Requestid), Str As String = ""
        Str += String.Format("<tr><td  align=""right""><b>Sales Review : </b></td><td> {2}  by {0}  on {1}</td></tr>", M.Approve_By1, M.Approve_Date1, M.AorR1)
        If Step_Int > 1 Then
            Str += String.Format("<tr><td  align=""right""><b>Sales Management Approval  : </b> </td><td>{2}  by {0}  on {1}</td></tr>", M.Approve_By2, M.Approve_Date2, M.AorR2)
        End If
        If Step_Int > 2 Then
            Str += String.Format("<tr><td  align=""right""><b>Project Win or Lost :</b>  </td><td>{2}  by {0}  on {1}</td></tr>", M.Approve_By3, M.Approve_Date3, M.AorR3)
        End If
        Return Str
    End Function
    Public Shared Function update_Siebel(ByVal Request_id As String, ByVal Stage As String) As Boolean
        Dim M As New Us_Prjreg_M(Request_id)
        If M.Opty_Id = "" Then
            Return False
            Exit Function
        End If
        Dim TOTALrevenue As String = "", obj As Object
        obj = dbUtil.dbExecuteScalar("b2b", "select  SUM(QTY * CPricing)  from US_PrjReg_Det  where request_id='" + Request_id + "'")
        If obj IsNot Nothing AndAlso Double.Parse(obj) > 0 Then
            TOTALrevenue = obj.ToString()
        Else
            obj = dbUtil.dbExecuteScalar("b2b", "select  SUM(QTY * DebitPricing)  from US_PrjReg_Det  where request_id='" + Request_id + "'")
            If obj IsNot Nothing AndAlso Double.Parse(obj) > 0 Then
                TOTALrevenue = obj.ToString()
            End If
        End If
        If Double.TryParse(TOTALrevenue, 0) = False OrElse CDbl(TOTALrevenue) < 0 Then TOTALrevenue = "0"
        'Dim DESC_TEXT As String = ""
        'obj = dbUtil.dbExecuteScalar("CRMDB75", " select DESC_TEXT  from  S_OPTY WHERE ROW_ID = '" + M.Opty_Id + "' ")
        'If obj IsNot Nothing Then DESC_TEXT = obj.ToString()
        Try
            Dim ws As New aeu_eai2000.Siebel_WS
            ws.Timeout = -1 : ws.UseDefaultCredentials = True
            ws.UpdateOpportunityStage_Proj(M.Opty_Id, M.EndCustomer, Stage, "", TOTALrevenue, M.Expire_Date, M.Reject_Reason)
            Return True
        Catch ex As Exception
            Util.SendEmail("ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", _
                           String.Format("Update Opty to Siebel for OptyID:{0} by {1}", M.Opty_Id, HttpContext.Current.Session("user_id").ToString), ex.ToString(), True, "", "")
        End Try
        Return False
    End Function
    Public Shared Function IsSalesContact(ByVal M_AdvSalesContact As String, ByVal M_RBU As String) As Boolean
        If IsSalesLeader(M_RBU) Then Return True
        If HttpContext.Current.Session("user_id").ToString.ToLower.Trim = M_AdvSalesContact.ToLower.Trim Then Return True
        Return False
    End Function
    Public Shared Function IsSalesLeader(ByVal RBU As String) As Boolean
        Dim user_id As String = LCase(Trim(HttpContext.Current.Session("user_id")))
        If user_id = "lynette.andersen@advantech.com" Then Return True
        Select Case UCase(RBU)
            Case "AAC"
                Select Case user_id
                    Case "roy.wang@advantech.com", "roy.wang@advantech.com.tw", "ming.zhaoTEST@advantech.com.cn", "tc.chen@advantech.com.tw", "tc.chen@advantech.eu"
                        Return True
                    Case Else
                        Return False
                End Select
            Case "AENC"
                Select Case user_id
                    Case "al.zelasko@advantech.com", "cliffc@advantech.com", "ming.zhaoTEST@advantech.com.cn", "tc.chen@advantech.com.tw", "tc.chen@advantech.eu"
                        Return True
                    Case Else
                        Return False
                End Select
            Case Else
                Return False
        End Select
    End Function
    Public Shared Function IsProjLeader(ByVal RBU As String) As Boolean
        If IsSalesLeader(RBU) Then Return True
        Return False
    End Function
    Public Shared Function DTList_updateLine2(ByVal tid As String, ByVal Part_no As String, ByVal qty As Integer, ByVal lineNo As Integer _
                                              , ByVal targetPricing As Decimal, ByVal appdebPricing As Decimal, ByVal appPricing As Decimal, ByVal CPricing As Decimal) As Integer

        Dim Update_query As String = _
        " Update US_PrjReg_Det Set " & _
        " Request_id = @Request_id, " & _
        " Qty = @Qty, " & _
        " Line = @Line, " & _
        " TargetPricing = @TargetPricing, " & _
        " ApprovedPricing = @ApprovedPricing, " & _
        " CPricing = @CPricing " & _
        " Where Request_id = @Request_id And " & _
        " Line = @Line "
        Dim parms = New SqlParameter() { _
                New SqlParameter("@Request_id", SqlDbType.NVarChar, 100), _
                New SqlParameter("@Qty", SqlDbType.Int, 4), _
                New SqlParameter("@Line", SqlDbType.Int, 4), _
                New SqlParameter("@TargetPricing", SqlDbType.Money, 8), _
                New SqlParameter("@ApprovedPricing", SqlDbType.Money, 8), _
                New SqlParameter("@CPricing", SqlDbType.Money, 8) _
            }
        parms(0).Value = tid
        parms(1).Value = qty
        parms(2).Value = lineNo
        parms(3).Value = targetPricing
        parms(4).Value = appdebPricing
        parms(5).Value = CPricing
        dbUtil.dbExecuteNoQuery2("b2b", Update_query, parms)
        Return 1
    End Function
    Public Shared Function getappcode(ByVal Request_id As String) As String
        Dim result As String = "", Request_id_str As String = ""
        Dim obj As Object = Nothing
        obj = dbUtil.dbExecuteScalar("b2b", "SELECT Count(Request_id)+ 1  as max_id FROM US_PrjReg_Mstr")
        If obj IsNot Nothing Then
            Request_id_str = obj.ToString()
        End If
        Dim sql_query As String = " Select * From US_PrjReg_Mstr  Where Request_id = '" + Request_id + "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql_query)
        If dt.Rows.Count > 0 Then
            ''''' 
            If dt.Rows(0)("Org_ID").ToString.Trim.ToUpper = "AENC" Then
                result = dt.Rows(0)("CPartner").ToString().Substring(3, 3)
                'Dim t As Integer = (CType(oMstr.Request_id, Integer)) Mod 10
                Dim t As Integer = 5 - Request_id_str.Length
                For i = 1 To t
                    result += "0"
                Next
                result += Request_id_str.Trim
            ElseIf dt.Rows(0)("Org_ID").ToString.Trim.ToUpper = "AAC" Then
                'Donald fix the bug which happen when CPartner length is too short
                If dt.Rows(0)("CPartner").ToString().Length <= 3 Then
                    result = dt.Rows(0)("CPartner").ToString().Substring(1, dt.Rows(0)("CPartner").ToString().Length - 1)
                Else
                    result = dt.Rows(0)("CPartner").ToString().Substring(1, 3)
                End If
                Dim t As Integer = 5 - Request_id_str.Length
                For i = 1 To t
                    result += "0"
                Next
                result += Request_id_str
            End If

            '''''' 
        End If

        Return result
    End Function
    Public Shared Function IsSalesContactAdmin() As Boolean
        Dim user_id As String = HttpContext.Current.Session("user_id").ToString.Trim.ToLower
        If Util.IsAEUIT() OrElse user_id = "feik@advantech.com" OrElse user_id = "ednag@advantech.com" OrElse user_id = "lynette.andersen@advantech.com" _
            OrElse user_id = "al.zelasko@advantech.com" Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function CheckEndCustomer(ByVal EndCustomerRowID As String, ByRef Error_Str As String) As Boolean
        If EndCustomerRowID.Trim = "" Then
            Error_Str = " End Customer cannot be empty."
            Return False
        End If
        If dbUtil.dbGetDataTable("my", "select top 1 ROW_ID  from dbo.SIEBEL_ACCOUNT where ROW_ID ='" + EndCustomerRowID.Trim.Replace("'", "''") + "'").Rows.Count = 0 Then
            Error_Str = " End Customer is not exist."
            Return False
        End If
        Return True
    End Function
    Public Shared Function GetEndCustomerRowidByOptyid(ByVal Optyid As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("CRMDB75", "select top 1  b.PR_DEPT_OU_ID from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID where b.ROW_ID ='" + Optyid.Trim + "'")
        If obj IsNot Nothing AndAlso obj.ToString.Trim <> "" Then
            Return obj.ToString.Trim
        End If
        Return ""
    End Function
End Class
Public Class Us_Prjreg_M
    Protected m_request_id As String
    Protected m_appliciant As String
    Protected m_cPartner As String
    Protected m_contact As String
    Protected m_phone As String
    Protected m_email As String
    Protected m_city1 As String
    Protected m_state1 As String
    Protected m_advSalesContact As String
    Protected m_company As String
    Protected m_address As String
    Protected m_city2 As String
    Protected m_state2 As String
    Protected m_zip As String
    Protected m_project_Name As String
    Protected m_comment As String
    Protected m_reg_date As DateTime
    Protected m_reject_Reason As String
    Protected m_expire_Date As DateTime
    Protected m_contact1 As String
    Protected m_contactPhone1 As String
    Protected m_contactEMail1 As String
    Protected m_contact2 As String
    Protected m_contactPhone2 As String
    Protected m_contactEMail2 As String
    Protected m_approve_Code As String
    Protected m_prototype_Date As DateTime
    Protected m_production_Date As DateTime
    Protected m_internal_Comment As String
    Protected m_org_ID As String
    Protected m_status As String
    Protected m_approve_Date1 As DateTime
    Protected m_approve_Date2 As DateTime
    Protected m_approve_Date3 As DateTime
    Protected m_Approve_By1 As String
    Protected m_Approve_By2 As String
    Protected m_Approve_By3 As String
    Protected m_opty_Id As String
    Protected m_EndCustomer As String
    Protected m_AorR1 As String
    Protected m_AorR2 As String
    Protected m_AorR3 As String

    Sub New()

    End Sub
    Sub New(ByVal Requestid As String)
        Dim sql_query As String = "SELECT Request_id,Appliciant,CPartner,Contact,Phone,Email,City1,State1,AdvSalesContact,Company,Address,isnull(City2,'') as City2,isnull(State2,'') as State2,isnull(Zip,'') as Zip,isnull(Reject_Reason,'') as Reject_Reason,isnull(Contact1,'') as Contact1,isnull(ContactPhone1,'') as ContactPhone1,isnull(ContactEMail1,'') as ContactEMail1,isnull(Contact2,'') as Contact2,isnull(ContactPhone2,'') as ContactPhone2,isnull(ContactEMail2,'') as ContactEMail2,isnull(Approve_Code,'') as Approve_Code,isnull(internal_comment,'') as internal_comment,isnull(OPTY_ID,'') as OPTY_ID,Project_Name,Comment,Reg_date,Expire_Date,Prototype_Date,Production_Date,Org_ID,Status,Approve_Date1,Approve_Date2,Approve_Date3 ,isnull(Approve_By1,'') as Approve_By1 ,isnull(Approve_By2,'') as Approve_By2  ,isnull(Approve_By3,'') as Approve_By3,isnull(AorR1,'') as AorR1,isnull(AorR2,'') as AorR2,isnull(AorR3,'') as AorR3,isnull(EndCustomer,'') as EndCustomer FROM [US_PRJREG_MSTR] Where Request_id = '" + Requestid.ToString.Trim + "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql_query)
        If dt.Rows.Count > 0 Then
            With dt.Rows(0)
                Request_id = .Item("Request_id").ToString.Trim
                Appliciant = .Item("Appliciant").ToString.Trim
                CPartner = .Item("CPartner").ToString.Trim
                Contact = .Item("Contact").ToString.Trim
                Phone = .Item("Phone").ToString.Trim
                Email = .Item("Email").ToString.Trim
                City1 = .Item("City1").ToString.Trim
                State1 = .Item("State1").ToString.Trim
                AdvSalesContact = .Item("AdvSalesContact").ToString.Trim
                Company = .Item("Company").ToString.Trim
                Address = .Item("Address").ToString.Trim
                City2 = .Item("City2").ToString.Trim
                State2 = .Item("State2").ToString.Trim
                Zip = .Item("Zip").ToString.Trim
                Project_Name = .Item("Project_Name").ToString.Trim
                Comment = .Item("Comment").ToString.Trim
                Reg_date = IIf(Date.TryParse(.Item("Reg_date"), Now()) = True, CDate(.Item("Reg_date")), Now())
                Reject_Reason = .Item("Reject_Reason").ToString.Trim
                Expire_Date = CDate(.Item("Expire_Date"))
                Contact1 = .Item("Contact1").ToString.Trim
                ContactPhone1 = .Item("ContactPhone1").ToString.Trim
                ContactEMail1 = .Item("ContactEMail1").ToString.Trim
                Contact2 = .Item("Contact2").ToString.Trim
                ContactPhone2 = .Item("ContactPhone2").ToString.Trim
                ContactEMail2 = .Item("ContactEMail2").ToString.Trim
                Approve_Code = .Item("Approve_Code").ToString.Trim
                If Date.TryParse(.Item("Prototype_Date"), Now) AndAlso CDate(.Item("Prototype_Date")) > CDate("1900-1-2") Then
                    Prototype_Date = CDate(.Item("Prototype_Date"))
                End If
                If Date.TryParse(.Item("Production_Date"), Now) AndAlso CDate(.Item("Production_Date")) > CDate("1900-1-2") Then '
                    Prototype_Date = CDate(.Item("Production_Date"))
                End If
                Internal_Comment = .Item("Internal_Comment").ToString.Trim
                Org_ID = .Item("Org_ID").ToString.Trim.ToUpper
                Status = .Item("Status").ToString.Trim
                Approve_Date1 = CDate(.Item("Approve_Date1"))
                Approve_Date2 = CDate(.Item("Approve_Date2"))
                Approve_Date3 = CDate(.Item("Approve_Date3"))
                Approve_By1 = .Item("Approve_By1").ToString.Trim
                Approve_By2 = .Item("Approve_By2").ToString.Trim
                Approve_By3 = .Item("Approve_By3").ToString.Trim
                AorR1 = .Item("AorR1").ToString.Trim
                AorR2 = .Item("AorR2").ToString.Trim
                AorR3 = .Item("AorR3").ToString.Trim
                Opty_Id = .Item("Opty_Id").ToString.Trim
                EndCustomer = .Item("EndCustomer").ToString.Trim
            End With
        End If
    End Sub
    Function T(ByVal str As String) As String
        Return str.Replace("'", "''").ToString.Trim
    End Function
    Sub UPDAYE_M()
        Dim SQL As String = "update Us_Prjreg_Mstr set " _
& "  Appliciant        ='" + T(Me.Appliciant) + "' ," _
& "  CPartner          ='" + T(Me.CPartner) + "' ," _
& "  Contact           ='" + T(Me.Contact) + "' ," _
& "  Phone             ='" + T(Me.Phone) + "' ," _
& "  Email             ='" + T(Me.Email) + "' ," _
& "  City1             ='" + T(Me.City1) + "' ," _
& "   State1            ='" + T(Me.State1) + "' ," _
& "  AdvSalesContact   ='" + T(Me.AdvSalesContact) + "' ," _
& "  Company           ='" + T(Me.Company) + "' ," _
& "  Address           ='" + T(Me.Address) + "' ," _
& "  City2             ='" + T(Me.City2) + "' ," _
& "   State2            ='" + T(Me.State2) + "' ," _
& "  Zip               ='" + T(Me.Zip) + "' ," _
& "  Project_Name      ='" + T(Me.Project_Name) + "' ," _
& "   Comment           ='" + T(Me.Comment) + "' ," _
& "  Reg_date          ='" + Me.Reg_date + "' ," _
& "   Reject_Reason     ='" + T(Me.Reject_Reason) + "' ," _
& "  Expire_Date       ='" + Me.Expire_Date + "' ," _
& "   Contact1          ='" + T(Me.Contact1) + "' ," _
& "  ContactPhone1     ='" + T(Me.ContactPhone1) + "' ," _
& "   ContactEMail1     ='" + T(Me.ContactEMail1) + "' ," _
& "   Contact2          ='" + T(Me.Contact2) + "' ," _
& "  ContactPhone2     ='" + T(Me.ContactPhone2) + "' ," _
& "  ContactEMail2     ='" + T(Me.ContactEMail2) + "' ," _
& "  Approve_Code      ='" + Me.Approve_Code + "' ," _
& "  Prototype_Date    ='" + Me.Prototype_Date + "' ," _
& "  Production_Date   ='" + Me.Production_Date + "' ," _
& "  Internal_Comment  ='" + T(Me.Internal_Comment) + "' ," _
& "  Org_ID            ='" + Me.Org_ID + "' ," _
& "  Status            ='" + Me.Status + "' ," _
& "  Approve_Date1     ='" + Me.Approve_Date1 + "' ," _
& "  Approve_Date2     ='" + Me.Approve_Date2 + "' ," _
& "  Approve_Date3     ='" + Me.Approve_Date3 + "' ," _
& "  Approve_By1     =N'" + Me.Approve_By1 + "' ," _
& "  Approve_By2     =N'" + Me.Approve_By2 + "' ," _
& "  Approve_By3     =N'" + Me.Approve_By3 + "' ," _
& "  AorR1     =N'" + T(Me.AorR1) + "' ," _
& "  AorR2     =N'" + T(Me.AorR2) + "' ," _
& "  AorR3     =N'" + T(Me.AorR3) + "' ," _
& "  Opty_Id           ='" + Me.Opty_Id + "', " _
& "  EndCustomer           ='" + T(Me.EndCustomer) + "' " _
& " where Request_id ='" + Me.Request_id + "'"
        dbUtil.dbExecuteNoQuery("my", SQL)

    End Sub
    Sub Insert_M()
        Dim SQL As String = "insert into Us_Prjreg_Mstr(Request_id,Appliciant,CPartner,Contact,Phone,Email,City1,State1,AdvSalesContact,Company,Address,City2,State2,Zip,Project_Name,Comment,Reg_date,Reject_Reason,Expire_Date,Contact1,ContactPhone1,ContactEMail1,Contact2,ContactPhone2,ContactEMail2,Approve_Code,Prototype_Date,Production_Date,Internal_Comment,Org_ID,Status,Approve_Date1,Approve_Date2,Approve_Date3,Approve_By1,Approve_By2,Approve_By3,Opty_Id,EndCustomer) values( " _
                            & " '" + Me.Request_id + "','" + Me.Appliciant + "','" + Me.CPartner + "','" + Me.Contact + "','" + Me.Phone + "','" + Me.Email + "','" + Me.City1 + "','" + Me.State1 + "','" + Me.AdvSalesContact + "','" + Me.Company + "','" + Me.Address + "','" + Me.City2 + "','" + Me.State2 + "','" + Me.Zip + "','" + Me.Project_Name + "','" + Me.Comment + "','" + Me.Reg_date + "','" + Me.Reject_Reason + "','" + Me.Expire_Date + "','" + Me.Contact1 + "','" + Me.ContactPhone1 + "','" + Me.ContactEMail1 + "','" + Me.Contact2 + "','" + Me.ContactPhone2 + "','" + Me.ContactEMail2 + "','" + Me.Approve_Code + "','" + Me.Prototype_Date + "','" + Me.Production_Date + "',N'" + Me.Internal_Comment + "','" + Me.Org_ID + "','" + Me.Status + "','" + Me.Approve_Date1 + "','" + Me.Approve_Date2 + "','" + Me.Approve_Date3 + "','" + Me.Approve_By1 + "','" + Me.Approve_By2 + "','" + Me.Approve_By3 + "','" + Me.Opty_Id + "',N'" + Me.EndCustomer + "')  "

        dbUtil.dbExecuteNoQuery("my", SQL)

    End Sub
    Public Property Request_id() As String
        Get
            Return m_request_id
        End Get
        Set(ByVal value As String)
            m_request_id = value
        End Set
    End Property
    Public Property Appliciant() As String
        Get
            Return m_appliciant
        End Get
        Set(ByVal value As String)
            m_appliciant = value
        End Set
    End Property
    Public Property CPartner() As String
        Get
            Return m_cPartner
        End Get
        Set(ByVal value As String)
            m_cPartner = value
        End Set
    End Property
    Public Property Contact() As String
        Get
            Return m_contact
        End Get
        Set(ByVal value As String)
            m_contact = value
        End Set
    End Property
    Public Property Phone() As String
        Get
            Return m_phone
        End Get
        Set(ByVal value As String)
            m_phone = value
        End Set
    End Property
    Public Property Email() As String
        Get
            Return m_email
        End Get
        Set(ByVal value As String)
            m_email = value
        End Set
    End Property
    Public Property City1() As String
        Get
            Return m_city1
        End Get
        Set(ByVal value As String)
            m_city1 = value
        End Set
    End Property
    Public Property State1() As String
        Get
            Return m_state1
        End Get
        Set(ByVal value As String)
            m_state1 = value
        End Set
    End Property
    Public Property AdvSalesContact() As String
        Get
            Return m_advSalesContact
        End Get
        Set(ByVal value As String)
            m_advSalesContact = value
        End Set
    End Property
    Public Property Company() As String
        Get
            Return m_company
        End Get
        Set(ByVal value As String)
            m_company = value
        End Set
    End Property
    Public Property Address() As String
        Get
            Return m_address
        End Get
        Set(ByVal value As String)
            m_address = value
        End Set
    End Property
    Public Property City2() As String
        Get
            Return m_city2
        End Get
        Set(ByVal value As String)
            m_city2 = value
        End Set
    End Property
    Public Property State2() As String
        Get
            Return m_state2
        End Get
        Set(ByVal value As String)
            m_state2 = value
        End Set
    End Property
    Public Property Zip() As String
        Get
            Return m_zip
        End Get
        Set(ByVal value As String)
            m_zip = value
        End Set
    End Property
    Public Property Project_Name() As String
        Get
            Return m_project_Name
        End Get
        Set(ByVal value As String)
            m_project_Name = value
        End Set
    End Property
    Public Property Comment() As String
        Get
            Return m_comment
        End Get
        Set(ByVal value As String)
            m_comment = value
        End Set
    End Property
    Public Property Reg_date() As DateTime
        Get
            Return m_reg_date
        End Get
        Set(ByVal value As DateTime)
            m_reg_date = value
        End Set
    End Property
    Public Property Reject_Reason() As String
        Get
            Return m_reject_Reason
        End Get
        Set(ByVal value As String)
            m_reject_Reason = value
        End Set
    End Property
    Public Property Expire_Date() As DateTime
        Get
            Return m_expire_Date
        End Get
        Set(ByVal value As DateTime)
            m_expire_Date = value
        End Set
    End Property
    Public Property Contact1() As String
        Get
            Return m_contact1
        End Get
        Set(ByVal value As String)
            m_contact1 = value
        End Set
    End Property
    Public Property ContactPhone1() As String
        Get
            Return m_contactPhone1
        End Get
        Set(ByVal value As String)
            m_contactPhone1 = value
        End Set
    End Property
    Public Property ContactEMail1() As String
        Get
            Return m_contactEMail1
        End Get
        Set(ByVal value As String)
            m_contactEMail1 = value
        End Set
    End Property
    Public Property Contact2() As String
        Get
            Return m_contact2
        End Get
        Set(ByVal value As String)
            m_contact2 = value
        End Set
    End Property
    Public Property ContactPhone2() As String
        Get
            Return m_contactPhone2
        End Get
        Set(ByVal value As String)
            m_contactPhone2 = value
        End Set
    End Property
    Public Property ContactEMail2() As String
        Get
            Return m_contactEMail2
        End Get
        Set(ByVal value As String)
            m_contactEMail2 = value
        End Set
    End Property
    Public Property Approve_Code() As String
        Get
            Return m_approve_Code
        End Get
        Set(ByVal value As String)
            m_approve_Code = value
        End Set
    End Property
    Public Property Prototype_Date() As DateTime
        Get
            Return m_prototype_Date
        End Get
        Set(ByVal value As DateTime)
            m_prototype_Date = value
        End Set
    End Property
    Public Property Production_Date() As DateTime
        Get
            Return m_production_Date
        End Get
        Set(ByVal value As DateTime)
            m_production_Date = value
        End Set
    End Property
    Public Property Internal_Comment() As String
        Get
            Return m_internal_Comment
        End Get
        Set(ByVal value As String)
            m_internal_Comment = value
        End Set
    End Property
    Public Property Org_ID() As String
        Get
            Return m_org_ID
        End Get
        Set(ByVal value As String)
            m_org_ID = value
        End Set
    End Property
    Public Property Status() As String
        Get
            Return m_status
        End Get
        Set(ByVal value As String)
            m_status = value
        End Set
    End Property
    Public Property Approve_Date1() As DateTime
        Get
            Return m_approve_Date1
        End Get
        Set(ByVal value As DateTime)
            m_approve_Date1 = value
        End Set
    End Property
    Public Property Approve_Date2() As DateTime
        Get
            Return m_approve_Date2
        End Get
        Set(ByVal value As DateTime)
            m_approve_Date2 = value
        End Set
    End Property
    Public Property Approve_Date3() As DateTime
        Get
            Return m_approve_Date3
        End Get
        Set(ByVal value As DateTime)
            m_approve_Date3 = value
        End Set
    End Property
    Public Property Approve_By1() As String
        Get
            Return m_Approve_By1
        End Get
        Set(ByVal value As String)
            m_Approve_By1 = value
        End Set
    End Property
    Public Property Approve_By2() As String
        Get
            Return m_Approve_By2
        End Get
        Set(ByVal value As String)
            m_Approve_By2 = value
        End Set
    End Property
    Public Property Approve_By3() As String
        Get
            Return m_Approve_By3
        End Get
        Set(ByVal value As String)
            m_Approve_By3 = value
        End Set
    End Property
    Public Property AorR1() As String
        Get
            Return m_AorR1
        End Get
        Set(ByVal value As String)
            m_AorR1 = value
        End Set
    End Property
    Public Property AorR2() As String
        Get
            Return m_AorR2
        End Get
        Set(ByVal value As String)
            m_AorR2 = value
        End Set
    End Property
    Public Property AorR3() As String
        Get
            Return m_AorR3
        End Get
        Set(ByVal value As String)
            m_AorR3 = value
        End Set
    End Property
    Public Property Opty_Id() As String
        Get
            Return m_opty_Id
        End Get
        Set(ByVal value As String)
            m_opty_Id = value
        End Set
    End Property
    Public Property EndCustomer() As String
        Get
            Return m_EndCustomer
        End Get
        Set(ByVal value As String)
            m_EndCustomer = value
        End Set
    End Property

End Class
