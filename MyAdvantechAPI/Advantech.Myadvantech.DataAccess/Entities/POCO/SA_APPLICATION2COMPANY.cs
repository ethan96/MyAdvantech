//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Advantech.Myadvantech.DataAccess
{
    using System;
    using System.Collections.Generic;
    
    public partial class SA_APPLICATION2COMPANY
    {
        public SA_APPLICATION2COMPANY()
        {
            this.SA_BAPIADDR1 = new HashSet<SA_BAPIADDR1>();
            this.SA_BAPIADDR2 = new HashSet<SA_BAPIADDR2>();
            this.SA_FKNBK = new HashSet<SA_FKNBK>();
            this.SA_FKNVI = new HashSet<SA_FKNVI>();
            this.SA_KNA1 = new HashSet<SA_KNA1>();
            this.SA_KNB1 = new HashSet<SA_KNB1>();
            this.SA_KNVV = new HashSet<SA_KNVV>();
        }
    
        public int ID { get; set; }
        public string CompanyID { get; set; }
        public Nullable<int> CompanyType { get; set; }
        public int ApplicationID { get; set; }
        public Nullable<bool> IsExistSiebel { get; set; }
        public string AccountRowID { get; set; }
        public Nullable<bool> IsExistSAP { get; set; }
        public string SalesCode { get; set; }
        public string InsideSalesCode { get; set; }
        public string OPCode { get; set; }
        public string CustomerType { get; set; }
        public string VerticalMarketDefinition { get; set; }
        public string OfficialRegistrationNo { get; set; }
        public string PriceGrade { get; set; }
        public string DUNSNumber { get; set; }
        public string DBPaymentIndex { get; set; }
        public string CustomerGroup { get; set; }
        public string SiebelRBU { get; set; }
    
        public virtual SA_APPLICATION SA_APPLICATION { get; set; }
        public virtual ICollection<SA_BAPIADDR1> SA_BAPIADDR1 { get; set; }
        public virtual ICollection<SA_BAPIADDR2> SA_BAPIADDR2 { get; set; }
        public virtual ICollection<SA_FKNBK> SA_FKNBK { get; set; }
        public virtual ICollection<SA_FKNVI> SA_FKNVI { get; set; }
        public virtual ICollection<SA_KNA1> SA_KNA1 { get; set; }
        public virtual ICollection<SA_KNB1> SA_KNB1 { get; set; }
        public virtual ICollection<SA_KNVV> SA_KNVV { get; set; }
    }
}
