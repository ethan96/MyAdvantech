using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_QuotationV3_ACN : System.Web.UI.UserControl
{
    protected bool _showCategory = true;
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    public List<CartItem> CartItems
    {
        set
        {
            if (value != null && value.Count > 0)
            {
                var cartitem = value.FirstOrDefault();
                if (cartitem != null && !string.IsNullOrEmpty(cartitem.Cart_Id))
                    CartID = cartitem.Cart_Id;

                this.rpCartDetail.DataSource = value;
                this.rpCartDetail.DataBind();
            }
        }
    }

    private string _CartID;
    public string CartID 
    {
        get
        {
            return this._CartID;
        }
        set
        {
            this._CartID = value;
        }
    }

    public string GetRowStyle(int rowIndex, string lineno)
    {
        if (rowIndex % 2 == 0)
            return "background-color:LightYellow;white-space:nowrap;";
        else
            return "background-color:#EBEBEB;white-space:nowrap;";
    }

    protected void rpCartDetail_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Header)
        {
            if (!string.IsNullOrEmpty(this.CartID) && MyCartX.IsHaveBtos(this.CartID) == true)
                this._showCategory = false;
        }

        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            CartItem item = (CartItem)e.Item.DataItem;

            TextBox txtQty = (TextBox)e.Item.FindControl("txtQty");
            txtQty.Text = item.Qty.ToString();
        }
        //If e.Row.RowType = DataControlRowType.DataRow Then
        //    Dim _CartItem As CartItem = CType(e.Row.DataItem, CartItem)
        //    Dim line_no As Integer = _CartItem.Line_No ' CInt(CType(e.Row.FindControl("hdLineNo"), HiddenField).Value)
        //    Dim cbDel As CheckBox = e.Row.FindControl("chkKey")

        //    Dim part_no As String = _CartItem.Part_No
        //    Dim lable_ListPrice As Label = CType(e.Row.FindControl("lbListPrice"), Label)
        //    Dim TextBox_UnitPrice As TextBox = CType(e.Row.FindControl("txtUnitPrice"), TextBox)
        //    Dim ListPice As Decimal = CDbl(lable_ListPrice.Text)
        //    Dim UnitPrice As Decimal = CDbl(TextBox_UnitPrice.Text)

        //    Dim qty As Decimal = CInt(CType(e.Row.FindControl("txtGVQty"), TextBox).Text)
        //    Dim Discount As Decimal = 0.0
        //    Dim SubTotal As Decimal = 0.0
        //    Dim ewPrice As Decimal = 0.0


        //    '  ewPrice = FormatNumber(Glob.getRateByEWItem(Glob.getEWItemByMonth(CInt(DrpEW.SelectedValue)), _CartItem.Delivery_Plant) * UnitPrice, 2)
        //    CType(e.Row.FindControl("gv_lbEW"), TextBox).Text = ewPrice
        //    If ListPice = 0 AndAlso _CartItem.ItemTypeX <> CartItemType.BtosParent Then
        //        e.Row.Cells(9).Text = "TBD"
        //        e.Row.Cells(11).Text = "TBD"
        //    Else
        //        If ListPice > 0 Then
        //            Discount = FormatNumber((ListPice - UnitPrice) / ListPice, 2)
        //            e.Row.Cells(11).Text = Discount * 100 & "%"
        //        End If
        //    End If
        //    SubTotal = FormatNumber(qty * (UnitPrice), 2)
        //    e.Row.Cells(15).Text = CurrencySign & SubTotal
        //    'If Integer.Parse(DBITEM.Item("Line_No").ToString) >= 100 Then
        //    '    e.Row.Cells(6).Text = ""
        //    'End If
        //    If _CartItem.ItemTypeX = CartItemType.BtosParent Then
        //        e.Row.BackColor = Drawing.Color.LightYellow
        //        e.Row.Cells(1).Text = "" : e.Row.Cells(3).Text = "" : e.Row.Cells(5).Text = "" 'e.Row.Cells(6).Text = ""
        //        e.Row.Cells(7).Text = "" : e.Row.Cells(8).Text = "" : e.Row.Cells(9).Text = "" ': e.Row.Cells(10).Text = ""
        //        e.Row.Cells(11).Text = "" ': e.Row.Cells(13).Text = "" 'e.Row.Cells(14).Text = ""
        //        e.Row.Cells(15).Text = "" ': e.Row.Cells(16).Text = ""
        //        If lable_ListPrice IsNot Nothing Then lable_ListPrice.Text = _CartItem.ChildSubListPriceX
        //        If TextBox_UnitPrice IsNot Nothing Then
        //            TextBox_UnitPrice.Text = FormatNumber(_CartItem.ChildSubUnitPriceX / _CartItem.Qty, 2)
        //            TextBox_UnitPrice.Enabled = False
        //            e.Row.Cells(15).Text = CurrencySign & FormatNumber(_CartItem.ChildSubUnitPriceX, 2)
        //        End If
        //        'Ryan 20160427 If is NoEWParts, DrpEW will disable.
        //        If Advantech.Myadvantech.Business.PartBusinessLogic.IsNoEWParts(part_no) Then
        //            If DrpEW IsNot Nothing Then DrpEW.Enabled = False
        //        End If

        //        If Session("org_id") = "JP01" Then
        //            e.Row.Cells(18).Text = ""
        //        End If
        //    End If

        //    If _CartItem.otype = CartItemType.BtosPart Then
        //        If DrpEW IsNot Nothing Then DrpEW.Enabled = False

        //        Dim TBqty As TextBox = CType(e.Row.FindControl("txtGVQty"), TextBox)
        //        If TBqty IsNot Nothing Then
        //            If String.Equals(Session("org_id"), "EU10") Then
        //                TBqty.Enabled = False
        //                '20150715 Ming只有欧洲才进行ODM的判断
        //                If MyCartOrderBizDAL.isODMCart(CartId) Then
        //                    TBqty.Enabled = True
        //                End If
        //            Else
        //                TBqty.Enabled = True
        //            End If
        //        End If
        //    End If

        //    'Ming20141110      Disable the price edit function for all IMG-XXXXX part numbers  ,	Disable adding an extended warranty option for below product lines
        //    If Not SAPDAL.CommonLogic.isAllowedChangePrice(_CartItem.Part_No, Session("org_id")) Then
        //        TextBox_UnitPrice.Enabled = False
        //    End If
        //    If _CartItem.ItemTypeX = CartItemType.Part AndAlso Not SAPDAL.CommonLogic.isAllowedAddEW(_CartItem.Part_No, "", Session("org_id")) Then
        //        e.Row.Cells(6).Text = ""
        //    End If
        //    If part_no.ToLower.StartsWith("ags-ctos-", StringComparison.CurrentCultureIgnoreCase) Then
        //        CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
        //        CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
        //        If String.Equals(Session("org_id"), "EU10") Then
        //            e.Row.Cells(0).Text = ""
        //        End If

        //        'Ryan 20170519 AJP OP & IS are allowed to modify AGS-CTOS- items price
        //        If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
        //            If MailUtil.IsInMailGroup("AJP_IS", Session("user_id").ToString) OrElse MailUtil.IsInMailGroup("ajp_callcenter", Session("user_id").ToString) OrElse Util.IsMyAdvantechIT() Then
        //                CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = True
        //            End If
        //        End If
        //    End If


        //End If
    }

    public Tuple<bool, string> UpdateCartList()
    {
        if (!string.IsNullOrEmpty(this._CartID))
        {
            this.CartItems = MyCartX.GetCartList(this._CartID);
        }
        return new Tuple<bool, string>(false, "");
    }
    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        UpdateCartList();
    }
}