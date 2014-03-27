using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using DetectorInspector.Common.Formatters;

namespace DetectorInspector.Infrastructure.QuickBooks
{
	public class InvoiceTransaction : InvoiceTransactionItemBase
	{
		private IList<InvoiceTransactionLineItem> _invoiceTransactionItems;

		public InvoiceTransaction()
		{
			_invoiceTransactionItems = new List<InvoiceTransactionLineItem>();
			
			//For a transaction, account is always this
			Account = "Accounts Receivable";
		}

		public IList<InvoiceTransactionLineItem> InvoiceTransactionItems
		{
			get { return _invoiceTransactionItems; }
		}

		public string Name { get; set; }
		public string DocNum { get; set; } //invoice #
		public string Class { get; set; } //name of technician
		public bool ToPrint { get { return true; } }
		public string Address1 { get; set; }
		public string Address2 { get; set; }
		public string Address3 { get; set; }
		public string Address4 { get; set; }
		public bool IsTaxable { get; set; }
		public string RefCode { get; set; } //use for client database systems e.g. Console
		public string barCode { get; set; }
		public string barCodeEncoded { get; set; }
		public string propertyAddress1 { get; set; }
		public string propertyAddress2 { get; set; }
		public string termsText { get; set; }

		public override string ToString()
		{
			var stringToBuild = new StringBuilder();



			//Code 128
			//string encodedBarCode = BarcodeConverter128.StringToBarcode(barCode);



			stringToBuild.AppendLine(string.Format(@"TRNS{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}{15}{16}{17}{18}{19}{20}{21}{22}{23}{24}{25}{26}{27}{28}{29}{30}{31}{32}{33}", 
								Delimiter,
								base.ToString(),
								 Delimiter,
								 StripDelimiter(Name),
								 Delimiter,
								 StripDelimiter(DocNum),
								 Delimiter,
								 StripDelimiter(Class),
								 Delimiter,
								 ToPrint ? "Y" : "N",
								 Delimiter,
								 StripDelimiter(Address1),
								 Delimiter,
								 StripDelimiter(Address2),
								 Delimiter,
								 StripDelimiter(Address3),
								 Delimiter,
								 StripDelimiter(Address4),
								 Delimiter,
								 IsTaxable ? "Y" : "N",
								 Delimiter,
								 barCodeEncoded,
								 Delimiter,
								 barCode,
								 Delimiter,
								 "_________________________________",
								 Delimiter,
								 "PROPERTY ADDRESS:",
								 Delimiter,
								 propertyAddress1,
								 Delimiter,
								 propertyAddress2,
								 Delimiter,
								 termsText
								 ));

			foreach(InvoiceTransactionLineItem item in InvoiceTransactionItems)
			{
				stringToBuild.AppendLine(string.Format(@"{0}", item.ToString()));
			}

			stringToBuild.AppendLine(@"ENDTRNS");

			return stringToBuild.ToString();
		}
	}
}