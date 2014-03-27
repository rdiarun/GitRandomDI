using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace DetectorInspector.Infrastructure.QuickBooks
{
    public class InvoiceTransactionLineItem : InvoiceTransactionItemBase
    {
        public string Item { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public string Description { get; set; }
        public bool Taxable { get; set; }
        public string TaxCode { get { return "GST"; } }
        public decimal TaxAmount { get; set; }
        public string Class { get; set; }

        public override string ToString()
        {
            var stringToBuild = new StringBuilder();

            stringToBuild.Append(string.Format(@"SPL{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}{15}{16}{17}", 
                Delimiter, 
                base.ToString(),
                Delimiter,
                StripDelimiter(Class),
                Delimiter,
                StripDelimiter(Item),
                Delimiter,
                Quantity,
                Delimiter,
                Price.ToString("N2"),
                Delimiter,
                string.Format(@"""{0}""", Description),
                Delimiter,
                Taxable ? "Y" : "N",
                Delimiter,
                StripDelimiter(TaxCode),
                Delimiter,
                TaxAmount.ToString("N2")
                ));

            return stringToBuild.ToString();

        }

    }
}