<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    MyChampionClubDataContext MyDC = new MyChampionClubDataContext();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var result = from p in MyDC.ChampionClub_SendMail_Histories
                         //where p.Sender == Session["user_id"].ToString().Trim()
                         orderby p.SendTime descending
                         group p by p.Sender
                             into g
                             select new
                             {
                                 Sender = g.Key,
                                 Hlist = g.ToList()
                             };
            if (!IsManager())
            {
                result = result.Where(p => p.Sender == Session["user_id"].ToString().Trim());

            }
            //foreach (var T in result)
            //{
            //    foreach (ChampionClub_SendMail_History p in T.Hlist)
            //    {
            //        Response.Write(p.SendTime.ToString());
            //    }
            //}
            GridView1.DataSource = result;
            GridView1.DataBind();
        }
    }
    protected bool IsManager()
    {
        if (Util.IsAEUIT() || string.Equals(Session["user_id"].ToString(), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) || string.Equals(Session["user_id"].ToString(), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return false;

    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" Width="100%">
        <Columns>
            <asp:BoundField DataField="Sender" HeaderText="Sender" ItemStyle-Width="220" />
            <asp:TemplateField ItemStyle-Width="100%">
                <ItemTemplate>
                    <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" DataSource='<%# Eval("Hlist") %>'
                        Width="100%">
                        <Columns>
                            <asp:BoundField DataField="SendTime" HeaderText="Send Time" ItemStyle-Width="100"
                                DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" />
                            <%--      <asp:BoundField DataField="MailFrom" HeaderText="Mail From"    />--%>
                            <asp:BoundField DataField="MailTO" HeaderText="Mail TO" />
                            <%--        <asp:BoundField DataField="MailCC" HeaderText="Mail CC"    />--%>
                            <asp:TemplateField ItemStyle-Width="100">
                                <ItemTemplate>
                                    <div style="position: relative; cursor: pointer; text-align: center;" onmouseover="document.getElementById('divrs<%# Eval("id")%>').style.display='';"
                                        onmouseout="document.getElementById('divrs<%# Eval("id")%>').style.display='none';">
                                        <img alt="?" src="../../Images/forum_new.gif">
                                        <div id="divrs<%# Eval("id")%>" style="padding: 2px 2px 5px 2px; border: 2px solid #FF9933;
                                            position: absolute; width: 600px; display: none; z-index: 999; background-color: #FFFFFF;
                                            word-wrap: break-word; right: 0px; top: 32px;">
                                            <table border="0" width="100%" style="border-width: 0px; border-color: White; table-layout: fixed;
                                                word-wrap: break-word;">
                                                <tr>
                                                    <td class="mcs">
                                                        From:
                                                    </td>
                                                    <td align="left">
                                                        <%# Eval("MailFrom")%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="mcs">
                                                        TO:
                                                    </td>
                                                    <td align="left">
                                                        <%# Eval("MailTO")%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="mcs">
                                                        CC:
                                                    </td>
                                                    <td align="left">
                                                        <%# Eval("MailCC")%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="mcs">
                                                        Subject:
                                                    </td>
                                                    <td align="left">
                                                        <%# Eval("Subject")%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="mcs">
                                                        Body:
                                                    </td>
                                                    <td align="left">
                                                        <%# Eval("Body")%>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <style>
        .mcs
        {
            width: 50PX;
            font-weight: bold;
        }
    </style>
</asp:Content>
