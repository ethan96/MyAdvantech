<%@ Control Language="VB" ClassName="ProductCP2" %>

<script runat="server">
    Public Property PN() As String
        Get
            Return hdPN.Value
        End Get
        Set(ByVal value As String)
            hdPN.Value = Replace(Trim(value), "'", "")
        End Set
    End Property
    'Function GetSql() As String
    '    Dim sb As New System.Text.StringBuilder
    '    With sb
    '        .AppendLine(String.Format(" SELECT a.ROW_ID, b.COMPANY_ID, c.IDX, a.ACCOUNT_NAME, a.ACCOUNT_STATUS,  "))
    '        .AppendLine(String.Format(" case when a.URL like 'http%' then a.URL else 'http://'+a.URL end as URL,  "))
    '        .AppendLine(String.Format(" a.PHONE_NUM, b.ADDRESS, b.TEL_NO, b.ZIP_CODE, b.CITY, b.COUNTRY_NAME "))
    '        .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT AS a INNER JOIN SAP_DIMCOMPANY AS b ON a.ERP_ID = b.COMPANY_ID inner join "))
    '        .AppendLine(String.Format(" ( "))
    '        .AppendLine(String.Format(" 	select top 30 customer_id, row_number() over(order by sum(qty) desc) as IDX "))
    '        .AppendLine(String.Format(" 	from eai_sale_fact_new where (item_no like '{0}%' or model_no='{0}') and efftive_date>=getdate()-180 and org='EU10' ", Me.PN))
    '        .AppendLine(String.Format(" 	group by customer_id order by sum(qty) desc "))
    '        .AppendLine(String.Format(" ) as c on b.COMPANY_ID=c.customer_id "))
    '        .AppendLine(String.Format(" WHERE a.ACCOUNT_STATUS IN ('01-Platinum Channel Partner', '02-Gold Channel Partner', '03-Certified Channel Partner') AND  "))
    '        .AppendLine(String.Format(" a.PRIMARY_SALES_EMAIL <> '' AND a.PRIMARY_SALES_EMAIL <> 'sieowner@advantech.com.tw'  "))
    '        .AppendLine(String.Format(" AND a.RBU IN ('ADL', 'AFR', 'AIT', 'AEE', 'AUK', 'ABN') AND b.ORG_ID = 'EU10' and a.URL is not null "))
    '        .AppendLine(String.Format(" order by c.IDX "))
    '    End With
    '    Return sb.ToString()
    'End Function
  
</script>
<asp:HiddenField runat="server" ID="hdPN" />
<table width="100%" style="height:400px">
    <tr>
        <td runat="server" id="div_PRODCP"></td>
    </tr>
</table>
<script type="text/javascript">   
    function GetPCP(idx){
        var divProdCP = document.getElementById('<%=div_PRODCP.ClientID %>');
        divProdCP.style.display="block";
        divProdCP.innerHTML = "<img style='border:0px;' alt='loading partner info' src='../images/loading2.gif' />Loading Available Channel Partners..."
        PageMethods.GetProdCP('<%=hdPN.Value %>', idx, 
            function(pagedResult, eleid, methodName) {
                divProdCP.innerHTML = pagedResult;
//                if (browserName != "Microsoft Internet Explorer"){
//                    document.getElementById('td_pcp').style.width = screen.width * 0.8 + 'px';
//                    document.getElementById('tb_pcp').style.width='100%';
//                    //alert(document.getElementById('td_pcp').style.width);            
//                }
            },
            function(error, userContext, methodName) {
                //alert(error.get_message());
                divProdCP.innerHTML ="";
            }
        );
    } 
    GetPCP(0);
</script>
