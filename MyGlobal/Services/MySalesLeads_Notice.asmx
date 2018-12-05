<%@ WebService Language="VB" Class="MySalesLeads_Notice" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Data.SqlClient

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class MySalesLeads_Notice
    Inherits System.Web.Services.WebService 
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty"
    End Function
    <WebMethod()> _
    Public Function SendEmailNotice() As Boolean
        If HttpContext.Current.Request.ServerVariables("REMOTE_ADDR").ToString().StartsWith("172.2") = False _
        AndAlso HttpContext.Current.Request.ServerVariables("REMOTE_ADDR").ToString().StartsWith("127.") = False Then
            Return False
        End If
        Try
            Dim conn As New SqlConnection(ConfigurationManager.ConnectionStrings("CRMAPPDB").ConnectionString)
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select A.NAME, A.STATUS_CD as Status, A.NAME, A.CURCY_CD as Currency, cast(A.SUM_REVN_AMT as numeric(18,2)) as Amount, ")
                .AppendFormat(" IsNull((select top 1 Z.NAME from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as [Account Name], ")
                .AppendFormat(" IsNull((select top 1 IsNull(Z1.ADDR,'')+' '+IsNull(Z1.ADDR_LINE_2,'')+', '+IsNull(Z1.CITY,'')+', '+ IsNull(Z1.COUNTRY,'')  ")
                .AppendFormat(" from S_ADDR_PER Z1 inner join S_ORG_EXT Z2 on Z1.ROW_ID=Z2.PR_ADDR_ID  ")
                .AppendFormat(" where Z2.ROW_ID=A.PR_DEPT_OU_ID),'') as [ACCOUNT ADDRESS], ")
                .AppendFormat(" IsNull((select top 1 Z.MAIN_PH_NUM from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as [Account Phone],  ")
                .AppendFormat(" IsNull((select CN.FST_NAME + ' ' + CN.LAST_NAME from S_CONTACT CN where CN.ROW_ID = CON.PER_ID),'') as CONTACT,  ")
                .AppendFormat(" IsNull((select top 1 G.WORK_PH_NUM from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_PHONE,  ")
                .AppendFormat(" IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_EMAIL,  ")
                .AppendFormat(" A.CREATED, A.SUM_EFFECTIVE_DT, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, IsNull(A.DESC_TEXT,'') as Description,  ")
                .AppendFormat(" (select J.FST_NAME + ' ' + J.LAST_NAME from S_CONTACT J where J.ROW_ID = I.ROW_ID) as SALES_TEAM_NAME,  ")
                .AppendFormat(" IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=X.ATTRIB_46),'') as Assigned_Channel_Contact, A.PR_PRTNR_ID ")
                .AppendFormat(" from S_OPTY A inner join S_OPTY_X X on A.ROW_ID=X.ROW_ID left outer join S_STG B ")
                .AppendFormat("  on A.CURR_STG_ID = B.ROW_ID left outer join S_BU C on A.BU_ID = C.ROW_ID left outer join S_POSTN D  ")
                .AppendFormat("  on A.PR_POSTN_ID = D.ROW_ID left outer join S_USER E on A.CREATED_BY = E.ROW_ID left outer join S_USER F  ")
                .AppendFormat("  on A.LAST_UPD_BY = F.ROW_ID left outer join S_USER I on D.PR_EMP_ID = I.ROW_ID left outer join S_OPTY_T SC on SC.PAR_ROW_ID = A.ROW_ID  ")
                .AppendFormat("  left outer join S_OPTY_CON CON on CON.OPTY_ID = A.ROW_ID where C.NAME in ('ADL','AUK','AFR','AEE','AIT','ABN')  ")
                '.AppendFormat(" and SUM_EFFECTIVE_DT between GETDATE() and DATEADD(day,+4,getdate()) ")
                .AppendFormat(" and (year(SUM_EFFECTIVE_DT)=year(DATEADD(day,-1,getdate())) and month(SUM_EFFECTIVE_DT)=month(DATEADD(day,-1,getdate())) and day(SUM_EFFECTIVE_DT)=day(DATEADD(day,-1,getdate()))) ")
                .AppendFormat(" and A.SUM_WIN_PROB between 1 and 99 and X.ATTRIB_10='Y' and A.PR_PRTNR_ID is not null order by A.CREATED desc ")
            End With
            conn.Open()
            Dim sqldar As New SqlDataAdapter(sb.ToString, conn)
            Dim ds As New DataSet() : sqldar.Fill(ds)
            Dim dt As DataTable = ds.Tables(0)
            If dt.Rows.Count = 0 Then Util.SendEmail("ming.zhao@advantech.com.cn", "ebusiness.aeu@advantech.eu", "MyAdvantech: My Sales Leads Notice, test by ming.", sb.ToString(), True, "", "")
            If dt.Rows.Count > 0 Then
                For Each r As DataRow In dt.Select("Assigned_Channel_Contact=''")
                    r.Delete()
                Next
                dt.AcceptChanges()
                For i As Integer = 0 To dt.Rows.Count - 1
                    ' send Email start                             
                    Dim FROM_Email As String = "ebusiness.aeu@advantech.eu"
                    'Dim To_Email As String = "ming.zhao@advantech.com.cn"
                    Dim To_Email As String = dt.Rows(i).Item("Assigned_Channel_Contact").ToString.Trim
                    Dim CC_Email As String = "Maria.Unger@Advantech.de,Tc.Chen@advantech.eu,Nada.Liu@advantech.com.cn,ming.zhao@advantech.com.cn"
                    Dim BCC_Email As String = ""
                    Dim Subject As String = "MyAdvantech: My Sales Leads Notice"
                    'If To_Email = "ming.zhao@advantech.com.cn" Then
                    '    CC_Email = "Tc.Chen@advantech.eu,Nada.Liu@advantech.com.cn"
                    '    Subject = "MyAdvantech: My Sales Leads Notice, test by ming."
                    'End If
                    Dim Body As String = "<font style='font-family:Arial'>Dear  &nbsp;&nbsp;" + dt.Rows(i).Item("Assigned_Channel_Contact").ToString.Substring(0, dt.Rows(i).Item("Assigned_Channel_Contact").ToString.IndexOf("@")) + "</font><br/><br/>"
                    Body += "<font style='font-family:Arial'>Please be informed below sales lead should have been closed on </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("SUM_EFFECTIVE_DT").ToString + "</font>,"
                    Body += "<font style='font-family:Arial'>please kindly update it in MyAdvantech</font> <font><a style='font-family:Arial' href='http://my.advantech.eu/My/MyLeads.aspx'>My Sales Leads.</a></font><br/><br/>"
      
                    Body += "<font style='font-family:Arial'>Account Name :</font> <font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("Account Name").ToString + "</font><br/>"
                    Body += "<font style='font-family:Arial'>Create Date : </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("CREATED").ToString + "</font><br/>"
                    Body += "<font style='font-family:Arial'>Close Date : </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("SUM_EFFECTIVE_DT").ToString + "</font><br/>"
              
                    Body += "<font style='font-family:Arial'>Sales Lead Name : </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("name").ToString + "</font><br/>"
                    Body += "<font style='font-family:Arial'>Amount : </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("Amount").ToString + " " + dt.Rows(i).Item("Currency").ToString + "</font><br/>"
       
                    Body += "<font style='font-family:Arial'>Description : </font><font size='2' style='font-family:Arial' color='#003399'>" + dt.Rows(i).Item("Description").ToString + "</font><br/><br/>"
                       
                    Body += "<font style='font-family:Arial'>Thank you.</font><br/><br/>"
                    Body += "<font style='font-family:Arial'>Best Regards</font><br/>"
                    Body += "<font style='font-family:Arial'>Advantech Europe</font><br/>"
                
                    Dim CCDt As DataTable = dbUtil.dbGetDataTable("CRMAPPDB", String.Format( _
                    " select d.EMAIL_ADDR " + _
                    " from S_ORG_EXT a left join S_ACCNT_POSTN b on a.ROW_ID=b.OU_EXT_ID " + _
                    " left join S_POSTN c on b.POSITION_ID=c.ROW_ID left join S_CONTACT d on c.PR_EMP_ID=d.ROW_ID inner join S_PARTY e on d.BU_ID=e.ROW_ID " + _
                    " where a.ROW_ID='{0}' and e.NAME in ('ADL','AIT','AUK','AFR','ABN','AEE','AEU') and d.EMAIL_ADDR like '%@advantech%.%' and d.ACTIVE_FLG='Y' " + _
                    " order by d.EMAIL_ADDR ", dt.Rows(i).Item("PR_PRTNR_ID").ToString()))
                    If CCDt.Rows.Count > 0 Then
                        Dim ccArry As New ArrayList
                        For Each cr As DataRow In CCDt.Rows
                            If True Then ccArry.Add(cr.Item("EMAIL_ADDR"))
                        Next
                        CC_Email = String.Join(",", CType(ccArry.ToArray(GetType(String)), String()))
                    End If
                   
                    Util.SendEmail(To_Email, FROM_Email, Subject, Body, True, CC_Email, BCC_Email)
                    ' send Email end   
                Next
                conn.Close()
                Return True
            End If
            conn.Close()
            Return False
        Catch ex As Exception
            Util.SendEmail("ebusiness.aeu@advantech.eu", "ebiz.aeu@advantech.eu", "Error while sending closed leads to contacts", ex.ToString(), True, "", "")
        End Try
        Return False
    End Function
End Class
