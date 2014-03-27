using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace DetectorInspector.Infrastructure.QuickBooks
{
    public class InvoiceExport
    {
        private IList<InvoiceTransaction> _invoiceTransactions;
        private static string Delimiter = ",";

        //private static string _tranHeaderText = string.Format(@"TRNSTYPE{0}DATE{1}ACCNT{2}AMOUNT{3}CLEAR{4}NAME{5}DOCNUM{6}CLASS{7}TOPRINT{8}ADDR1{9}ADDR2{10}ADDR3{11}ADDR4{12}NAMEISTAXABLE{13}INVMEMO{14}SADDR1{14}SADDR2{15}SADDR3{16}SADDR4{17}SADDR5{18}TERMS",
        //                                                    Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter);

        private static string _tranHeaderText = string.Format(@"TRNSTYPE{0}DATE{1}ACCNT{2}AMOUNT{3}CLEAR{4}NAME{5}DOCNUM{6}CLASS{7}TOPRINT{8}ADDR1{9}ADDR2{10}ADDR3{11}ADDR4{12}NAMEISTAXABLE{13}PONUM{14}SADDR1{14}SADDR2{15}SADDR3{16}SADDR4{17}SADDR5{18}TERMS",
                                                           Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter);

        private static string _tranItemHeaderText = string.Format(@"TRNSTYPE{0}DATE{1}ACCNT{2}AMOUNT{3}CLEAR{4}CLASS{5}INVITEM{6}QNTY{7}PRICE{8}MEMO{9}TAXABLE{10}TAXCODE{11}TAXAMOUNT",
                                                            Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter, Delimiter);

        public InvoiceExport()
        {
            _invoiceTransactions = new List<InvoiceTransaction>();
        }

        public IList<InvoiceTransaction> InvoiceTransactions
        {
            get { return _invoiceTransactions; }
        }

        public override string ToString()
        {
            var stringToBuild = new StringBuilder();

            stringToBuild.AppendLine(string.Format(@"!TRNS{0}{1}", Delimiter, _tranHeaderText));
            stringToBuild.AppendLine(string.Format(@"!SPL{0}{1}", Delimiter, _tranItemHeaderText));
            stringToBuild.AppendLine(string.Format(@"!ENDTRNS"));

            foreach (var item in InvoiceTransactions)
            {
                stringToBuild.AppendLine(item.ToString());
            }

            return stringToBuild.ToString();
        }
    }
}