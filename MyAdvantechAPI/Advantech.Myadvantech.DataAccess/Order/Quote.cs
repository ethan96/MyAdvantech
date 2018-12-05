﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool
//     Changes to this file will be lost if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

[assembly: InternalsVisibleTo("Advantech.Myadvantech.Business")]
namespace Advantech.Myadvantech.DataAccess
{
    [Serializable]
    public class Quote
    {
        public Quote() { }

        public Quote(QuotationMaster master)
        {
            this.QuoteID = master.quoteId;
            this.QuoteNo = master.quoteNo;
            this.CustomID = master.customId;
            this.AttentionEmail = master.attentionEmail;
            this.CreatedDate = master.createdDate;
            this.ExpiredDate = master.expiredDate;
            this.TotalAmount = master.Revenue;
            this.QuoteItems = master.QuotationDetail.Select(p => new QuoteItem(p)).ToList();
            this.QuotePartners = master.QuotationPartner;
            this.DoctStatus = master.DOCSTATUS;
            this.Currency = master.currency;
            this.Tax = master.tax;
            this.Org = master.org;
        }

        public string QuoteID { get; set; }

        public string QuoteNo { get; set; }

        public string CustomID { get; set; }

        public string AttentionEmail { get; set; }
        
        public DateTime? CreatedDate { get; set; }

        public DateTime? ExpiredDate { get; set; }

        public int TotalAmount { get; set; }

        public  List<QuoteItem> QuoteItems { get; set; }

        public List<EQPARTNER> QuotePartners { get; set; }

        public int? DoctStatus { get; set; }

        public string Currency { get; set; }

        public decimal? Tax { get; set; }

        public string Org { get; set; }
    }
}
