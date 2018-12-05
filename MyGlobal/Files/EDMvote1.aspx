<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Dim camp_id As String = Request("CampId")
            Dim ws As New eCampaign_New.EC
            ws.UseDefaultCredentials = True : ws.Timeout = -1
            If Request("UID") IsNot Nothing And Request("UID") <> "" Then
                Dim email As String = ws.UniqueIdToEmail(Request("UID"))
                ViewState("email") = email
            Else
                ViewState("email") = ""
            End If
            If Request("CampId") IsNot Nothing And Request("CampId") <> "" Then
                ViewState("rowid") = Request("CampId")
                Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select isnull(vote_value,'') as vote_value from campaign_contact_list where campaign_row_id='{0}' and contact_email='{1}'", ViewState("rowid"), ViewState("email")))
                If dt.Rows.Count > 0 Then
                    GetChart()
                    '    lbl1.Text = "" : btnSubmit.Enabled = True
                    '    If dt.Rows(0).Item(0).ToString <> "" Then
                
                    '    End If
                    'Else
                    '    lbl1.Text = "You are not the contact of this campaign."
                    '    btnSubmit.Enabled = False
                End If
            Else
                'Response.Redirect("http://www.advantech.com")
                ViewState("rowid") = ""
            End If
            
        End If
        
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim is_selected As Boolean = False, index As Integer = 0, value As String = ""
        For Each item As ListItem In rbl1.Items
            If item.Selected = True Then
                is_selected = True
                index = CInt(item.Value)
                value = item.Text
                Exit For
            End If
        Next
        If is_selected = True Then
            Dim retValue As Integer = dbUtil.dbExecuteNoQuery("RFM", String.Format("insert into campaign_vote (campaign_row_id,contact_email,vote_index,vote_value) values ('{0}','{1}','{2}','{3}')", ViewState("rowid"), ViewState("email"), index, value))
            If retValue > 0 Then
                lbl1.Text = "Thank you for your feedback."
                GetChart()
            Else
                lbl1.Text = "Submit failed."
                Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "eDM Vote Failed", "Camp ID: " + ViewState("rowid") + "<br/>Email: " + ViewState("email"), True, "", "")
            End If
        Else
            lbl1.Text = "Please select one item."
        End If
    End Sub
    
    Private Sub GetChart()
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select vote_index,contact_email from campaign_vote where campaign_row_id='{0}'", ViewState("rowid")))
            Dim data(rbl1.Items.Count - 1) As Double, label(rbl1.Items.Count - 1) As String
            Dim m_index As Integer = 0
            Dim r() As DataRow = dt.Select("contact_email='" + ViewState("email") + "'")
            If r.Length > 0 Then m_index = CInt(r(0).Item("vote_index"))
            rbl1.Items(m_index).Selected = True
            For Each item As ListItem In rbl1.Items
                data(CInt(item.Value)) = dt.Select("vote_index='" + item.Value + "'").Length
                label(CInt(item.Value)) = item.Text
            Next
            Dim c As XYChart = New XYChart(300, 300)
            c.setPlotArea(30, 10, 250, 250, &HEEEEEE, &HFFFFFF)
            Dim layer As BarLayer = c.addBarLayer()
            layer.addDataSet(data, &H3D7AC2)
            c.xAxis().setLabels(label)
            layer.setBarShape(7)
            layer.setAggregateLabelStyle("Arial Bold", 12)
            layer.setDataLabelStyle()
            Chart.Image = c.makeWebImage(0)
            Chart.ImageMap = c.getHTMLImageMap("", "", "")
            Chart.Visible = True : tr1.Visible = True
            lblVote.Text = "There are <font color='red'>" + dt.Rows.Count.ToString + "</font> votes"
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "error", ex.ToString, True, "", "")
        End Try
        
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">    
    <link runat="server" id="ebizCss" visible="true" href="../Includes/ebiz.aeu.style.css" rel="stylesheet" type="text/css" />
    <link href="../Includes/global.css" rel="Stylesheet" type="text/css" />   
    <link href="../Includes/base.css" rel="Stylesheet" type="text/css" />
    <link href="../Includes/third.css" rel="Stylesheet" type="text/css" />
    <style type="text/css">
        .divCMSContent.Title
        {
	        font-weight: bold;
	        font-size: 18px;
	        color: #cc3300;
        }

        .divCMSContent.Code
        {
	        border: #8b4513 1px solid;
	        padding-right: 5px;
	        padding-left: 5px;
	        color: #000066;
	        font-family: 'Courier New' , Monospace;
	        background-color: #ff9933;
        }

        .ratingStar {
            font-size: 0pt;
            width: 13px;
            height: 12px;
            margin: 0px;
            padding: 0px;
            cursor: pointer;
            display: block;
            background-repeat: no-repeat;
        }

        .filledRatingStar {
            background-image: url(/Images/FilledStar.png);

        }

        .emptyRatingStar {
            background-image: url(/Images/EmptyStar.png);
        }

        .savedRatingStar {
            background-image: url(/Images/SavedStar.png);
        }
        .box{
            background: #fff;
        }
        .boxholder{
            clear: both;
            padding: 5px;
            background: #E5E6F4;
        }
        .tab{
            float: left;
            height: 32px;
            width: 102px;
            margin: 0 1px 0 0;
            text-align: center;
            background: #E5E6F4;
        }
        .tabtxt{
            margin: 0;
            color: #fff;
            font-size: 12px;
            font-weight: bold;
            padding: 9px 0 0 0;
        }
        BODY 
        {
	        color:#333333;
	        font-size:12px;
	        font-family:Arial, Helvetica, sans-serif;
	        line-height:18px;
        }
        SELECT {
	        FONT: 99% arial,helvetica,clean,sans-serif
        }
        INPUT {
	        FONT: 99% arial,helvetica,clean,sans-serif
        }
        TEXTAREA {
	        FONT: 99% arial,helvetica,clean,sans-serif
        }
        PRE {
	        FONT: 100% monospace
        }
        CODE {
	        FONT: 100% monospace
        }
        H1 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        H2 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        H3 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        H4 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        H5 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        H6 {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        UL {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        OL {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        LI {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        DL {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        DT {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        DD {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        P {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        FORM {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        FIELDSET {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        LEGEND {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        INPUT {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        IMG {
	        PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
        }
        IMG {
	        BORDER-RIGHT: 0px; BORDER-TOP: 0px; BORDER-LEFT: 0px; BORDER-BOTTOM: 0px
        }
        FIELDSET {
	        BORDER-RIGHT: 0px; BORDER-TOP: 0px; BORDER-LEFT: 0px; BORDER-BOTTOM: 0px
        }
        LEGEND {
	        FONT-SIZE: 0px; HEIGHT: 0px
        }
        LABEL {
	        CURSOR: hand
        }
        INPUT {
	        outline: none
        }
        CITE {
	        FONT: 85% verdana
        }
        EM {
	        FONT-STYLE: normal
        }
        CITE SPAN {
	        FONT-WEIGHT: bold
        }
        A {
	        color:#004181;
            text-decoration: none;
        }
        A:link {
	        TEXT-DECORATION: none
        }
        A:visited {
	        TEXT-DECORATION: none
        }
        A:hover {
	        TEXT-DECORATION: underline
        }
        .on A:hover {
	        TEXT-DECORATION: none
        }                    
    </style>
    <link runat="server" id="Style1" rel="stylesheet" href="~/includes/style-General.css" type="text/css"/>
    <style type="text/css">
        .ajax__tab_yuitabview-theme .ajax__tab_outer
        {
        	
        }
        .ajax__tab_yuitabview-theme .ajax__tab_inner
        {
            
        }
        .ajax__tab_yuitabview-theme .ajax__tab_header 
        {
            border-bottom:solid 2px #DCDCDC;
        }
        .ajax__tab_yuitabview-theme .ajax__tab_header .ajax__tab_outer 
        {
            background:url(/Images/gray_right.gif) no-repeat right;
        }
        .ajax__tab_yuitabview-theme .ajax__tab_header .ajax__tab_inner 
        {
            background:url(/Images/gray_left.gif) no-repeat left;
        }
        .ajax__tab_yuitabview-theme .ajax__tab_header .ajax__tab_tab
        {    
            margin-right:0px;
            background:url(/Images/gray_bg1.gif);
            width:208px;
            padding:9px 0px 3px 0px;
            text-align:center;    
            color:#4D6D94;
            font-size:12px;
            display:block;
            font-weight: bold;
            font-family:Arial;
        }
        .ajax__tab_yuitabview-theme .ajax__tab_active .ajax__tab_tab 
        {
            padding:6px 0px 3px 0px;
            background:url(/images/fold_blue_bg1.gif); height:18px;
            color:#FFFFFF;
            font-size:12px;
            font-weight: bold;
            font-family:Arial;
        }
        .ajax__tab_yuitabview-theme .ajax__tab_active .ajax__tab_outer
        {
            
        }
        .ajax__tab_yuitabview-theme .ajax__tab_body 
        {
            font-family:verdana,tahoma,helvetica;
            font-size:10pt;
            padding:0.25em 0.5em;    
            border:solid 1px #DCDCDC;
            border-top-width:0px;
            color:#4D6D94;
        }
        
        .ajax__tab_yuitabview-theme-new .ajax__tab_outer
        {
        	
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_inner
        {
            
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_header 
        {
            border-bottom:solid 2px #DCDCDC;
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_header .ajax__tab_outer 
        {
            background:url(/Images/gray_right.gif) no-repeat right;
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_header .ajax__tab_inner 
        {
            background:url(/Images/gray_left.gif) no-repeat left;
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_header .ajax__tab_tab
        {    
            margin-right:0px;
            background:url(/Images/gray_bg11.gif);
            width:145px;
            padding:9px 0px 3px 0px;
            text-align:center;    
            color:#4D6D94;
            font-size:12px;
            display:block;
            font-weight: bold;
            font-family:Arial;
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_active .ajax__tab_tab 
        {
            padding:6px 0px 3px 0px;
            background:url(/images/fold_blue_bg11.gif); height:18px;
            width:146px;
            color:#FFFFFF;
            font-size:12px;
            font-weight: bold;
            font-family:Arial;
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_active .ajax__tab_outer
        {
            
        }
        .ajax__tab_yuitabview-theme-new .ajax__tab_body 
        {
            font-family:verdana,tahoma,helvetica;
            font-size:10pt;
            padding:0.25em 0.5em;    
            border:solid 1px #DCDCDC;
            border-top-width:0px;
            color:#4D6D94;
        }
        
        
        
.modalBackground {
    background-color:Gray;
    filter:alpha(opacity=70);
    opacity:0.7;
}
 
.modalPopup {
    background-color:#ffffdd;
    border-width:3px;
    border-style:solid;
    border-color:Gray;
    padding:3px;
    width:250px;
}
 
.sampleStyleA {
    background-color:#FFF;
}
 
.sampleStyleB {
    background-color:#FFF;
    font-family:monospace;
    font-size:10pt;
    font-weight:bold;
}
 
.sampleStyleC {
    background-color:#ddffdd;
    font-family:sans-serif;
    font-size:10pt;
    font-style:italic;
}
 
.sampleStyleD {
    background-color:Blue;
    color:White;
    font-family:Arial;
    font-size:10pt;
} 
.autocomplete { background:#E0E0E0; position: absolute; border: solid 1px; overflow-y:scroll; overflow-x:auto; height:100px; display: none; }

a.accordionContent:link {color: #ff0000}
a.accordionContent:visited {color: #0000ff}
a.accordionContent:hover {background: #66ff66}
    </style>  
</head>

<body style="height:100%; background-color:#FFFFFF; margin-left:0px; margin-top:0px;">
    <form id="form1" runat="server">        
        <ajaxToolkit:ToolkitScriptManager runat="server" ID="tlsm1" AsyncPostBackTimeout="600"  
            enablescriptglobalization="true" enablescriptlocalization="true" EnablePageMethods="true" ScriptMode="Debug">            
        </ajaxToolkit:ToolkitScriptManager> 

    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table width="100%">
                <tr><td height="30"></td></tr>
                <tr>
                    <td><font size="4"><b>This news make you feel?</b></font></td>
                </tr>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="rbl1" RepeatDirection="Horizontal" Width="200px">
                                        <asp:ListItem Text="Useful" Value="0" />
                                        <asp:ListItem Text="Useless" Value="1" />
                                        <asp:ListItem Text="No idea" Value="2" />
                                    </asp:RadioButtonList>
                                </td>
                                <td width="20"></td>
                                <td><asp:Button runat="server" ID="btnSubmit" Text="Submit" OnClick="btnSubmit_Click" /></td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td><asp:Label runat="server" ID="lbl1" ForeColor="Red" /></td>
                            </tr>
                        </table>
                
                    </td>
                </tr>
                <tr runat="server" id="tr1" visible="false"><td><hr /></td></tr>
                <tr>
                    <td>
                        <chartdir:WebChartViewer id="Chart" runat="server" Visible="false" />
                    </td>
                </tr>
                <tr>
                    <td><asp:Label runat="server" ID="lblVote" /></td>
                </tr>
                <tr><td height="30"></td></tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>

        <asp:UpdateProgress DynamicLayout="false" ID="UpdateProgress2" runat="server">
            <ProgressTemplate>
                <div class="Progress">
                    <asp:Image runat="server" ID="imgMasterLoad" ImageUrl="~/Images/LoadingRed.gif" />
                    <b>Loading ...</b>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1"
            runat="server" TargetControlID="UpdateProgress2" HorizontalSide="Center" VerticalSide="Top" HorizontalOffset="0" />           
        
         <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtenderError" runat="server"
         TargetControlID="ErroPL" VerticalSide="top" HorizontalSide="center" VerticalOffset="0" HorizontalOffset="0"
          ScrollEffectDuration="1">
        </ajaxToolkit:AlwaysVisibleControlExtender>
        <asp:Panel ID= "ErroPL" runat="server">
        <asp:Label ID="lbErroMessage" runat="server" ForeColor ="#ff0000" Font-Size="X-Large" BackColor="#eeeeee"></asp:Label>
        </asp:Panel>         
    </form>
</body>
</html>