<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ScheduleJob.aspx.cs" Inherits="Lab_ScheduleJob" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <table>
            <tr>
                <td>
                    <asp:Label ID="Msg" runat="server" Text="" ForeColor="Tomato"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    BB Job
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Button runat="server" ID="ButtonStartBB" Text="StartBB" OnClick="ButtonStartBB_Click" />
                    <asp:Button runat="server" ID="ButtonStopBB" Text="StopBB" OnClick="ButtonStopBB_Click" />
                    <asp:Button runat="server" ID="ButtonClearBB" Text="ClearCache" OnClick="ButtonClearBB_Click" />                    
                </td>
            </tr>
            <tr>
                <td style="height:20px">                   
                </td>
            </tr>
            <tr>
                <td>
                    CP Job
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Button runat="server" ID="ButtonStartCP" Text="StartCP" OnClick="ButtonStartCP_Click" />
                    <asp:Button runat="server" ID="ButtonStopCP" Text="StopCP" OnClick="ButtonStopCP_Click" />
                    <asp:Label ID="Label1" runat="server" Text="" ForeColor="Tomato"></asp:Label>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
