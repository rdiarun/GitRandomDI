using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DetectorInspector.Infrastructure.QuickBooks
{
    public class InvoiceTransactionItemBase : IInvoiceTransactionItem
    {
        public string Delimiter { get { return ","; } }
        
        public string TransactionType
        {
            get { return "INVOICE"; }
        }

        public DateTime Date{get; set;}

        public string Account { get; set; }

        public decimal Amount { get; set; }

        public char Clear { get { return 'N'; } }

        public override string ToString()
        {
            return string.Format(@"{0}{1}{2}{3}{4}{5}{6}{7}{8}", 
                StripDelimiter(TransactionType),
                Delimiter,
                Date.ToString("MM/dd/yy"),
                Delimiter,
                StripDelimiter(Account),
                Delimiter,
                Amount.ToString("N2"),
                Delimiter,
                Clear);
        }

        protected string StripDelimiter(string value)
        {
            if (value == null)
            {
                return null;
            }

            return value.Replace(Delimiter, "");
        }
    }
}