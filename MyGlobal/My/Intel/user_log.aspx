<%@ Page Title="MyAdvantech Intel Portal - User Log" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Function ShowActType(ByVal URL As String) As String
        Select Case URL
            Case "/my/intel/home.aspx"
                Return "Home"
            Case "/my/intel/dl_intel_file.ashx"
                Return "Download"
            Case Else
                Return URL
        End Select
    End Function
    
    Function ShowDlFileName(ByVal RID As String) As String
        If String.IsNullOrEmpty(RID) Then Return ""
        If RID.StartsWith("FID=") And RID.EndsWith("&") Then
            RID = RID.Substring(4)
            RID = RID.Substring(0, RID.Length - 1)
            Dim obj As Object = dbUtil.dbExecuteScalar("MyLocal", "select FILE_NAME from INTEL_PORTAL_FILES where ROW_ID='" + RID + "'")
            If obj IsNot Nothing Then
                Return "Downloaded <a target='_blank' href='dl_intel_file.ashx?fid=" + RID + "'>" + obj.ToString() + "</a>"
            End If
        End If
        Return ""
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <br />
    <h2>MyAdvantech Intel Portal User Log</h2>
    <br />
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataSourceID="src1">
        <Columns>
            <asp:BoundField HeaderText="Email" DataField="USERID" SortExpression="USERID" />
            <asp:BoundField HeaderText="Date/Time" DataField="TIMESTAMP" SortExpression="TIMESTAMP" />
            <asp:TemplateField HeaderText="Type">
                <ItemTemplate>
                    <%#ShowActType(Eval("URL"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="">
                <ItemTemplate>
                    <%#ShowDlFileName(Eval("QSTRING"))%>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" 
        SelectCommand="
        select * from (
        select top 500 USERID, TIMESTAMP, URL, QSTRING from USER_LOG 
        where URL in ('/my/intel/dl_intel_file.ashx','/my/intel/home.aspx') and QSTRING not like '_TSM_HiddenField%' 
        union
        select top 500 USERID, TIMESTAMP, URL, QSTRING from DIM_USER_LOG 
        where URL in ('/my/intel/dl_intel_file.ashx','/my/intel/home.aspx') and QSTRING not like '_TSM_HiddenField%' ) as tmp
        order by TIMESTAMP desc" />
</asp:Content>