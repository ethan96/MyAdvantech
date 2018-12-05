<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="~/Includes/Banner.ascx" TagName="Banner" TagPrefix="uc10" %>

<script runat="server">
    <Services.WebMethod()> _
            <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetACLATP(ByVal strPartNo As String) As String
        Dim prod_input As New SAPDAL.SAPDALDS.ProductInDataTable, _sapdal As New SAPDAL.SAPDAL
        Dim MainDeliveryPlant As String = "TWH1", _errormsg As String = String.Empty
        Dim inventory_out As New SAPDAL.SAPDALDS.QueryInventory_OutputDataTable
        prod_input.AddProductInRow(strPartNo, 0, MainDeliveryPlant)
        If _sapdal.QueryInventory_V2(prod_input, MainDeliveryPlant, Now, inventory_out, _errormsg) Then
            Dim atpInfoObj As New ATPTotalInfo
            atpInfoObj.PartNo = strPartNo
            atpInfoObj.ATPRecords = New List(Of ATPRecord)
            For Each invRow As SAPDAL.SAPDALDS.QueryInventory_OutputRow In inventory_out
                Dim atpRec As New ATPRecord
                atpRec.Qty = invRow.STOCK : atpRec.AvailableDate = invRow.STOCK_DATE.ToString("yyyy/MM/dd")
                atpInfoObj.ATPRecords.Add(atpRec)
            Next
            Dim serializer = New Script.Serialization.JavaScriptSerializer()
            Dim json As String = serializer.Serialize(atpInfoObj)
            Return json
        End If
        Return ""
    End Function

    Class ATPTotalInfo
        Private _strPN As String, _ATPRecords As List(Of ATPRecord)
        Public Property PartNo As String
            Get
                Return _strPN
            End Get
            Set(value As String)
                _strPN = value
            End Set
        End Property

        Public Property ATPRecords As List(Of ATPRecord)
            Get
                Return _ATPRecords
            End Get
            Set(value As List(Of ATPRecord))
                _ATPRecords = value
            End Set
        End Property

    End Class

    Class ATPRecord
        Private _intQty As Integer, _dtDate As String
        Public Property Qty As Integer
            Get
                Return _intQty
            End Get
            Set(value As Integer)
                _intQty = value
            End Set
        End Property
        Public Property AvailableDate As String
            Get
                Return _dtDate
            End Get
            Set(value As String)
                _dtDate = value
            End Set
        End Property
    End Class
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            getACLATP();
        }
        );

        function getACLATP() {
            $("body").css("cursor", "progress");
            var strPN = 'adam-4520-d2e';
            //console.log('strPN:' + strPN);
            var postData = JSON.stringify({ strPartNo: strPN });
            $.ajax({
                type: "POST",
                url: "jQueryAjaxSample1.aspx/GetACLATP",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //console.log('called atp ok');
                    var ATPTotalInfo = $.parseJSON(msg.d);
                    var divATP = $('#divACLATP');
                    divATP.html('');
                    //console.log(ATPTotalInfo.PartNo);
                    if (ATPTotalInfo.ATPRecords.length > 0) {
                        divATP.append("<tr><th colspan='2' style='color:Black'>ACL Inventory</th></tr>");
                        divATP.append("<tr><th style='color:Black'>Available Date</th><th style='color:Black'>Qty</th></tr>");
                        $.each(ATPTotalInfo.ATPRecords, function (i, item) {
                            divATP.append('<tr><td>' + item.AvailableDate + '</td><td>' + item.Qty + '</td></tr>');
                        });
                    }
                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                    //console.log('err calling atp ' + msg.d);
                    $("body").css("cursor", "auto");
                }
            }
            );
        }
    </script>

    <uc10:Banner runat="server" ID="ucBanner" />

    <table id="divACLATP" style="border-width: thin; border-style: solid">
    </table>
</asp:Content>
