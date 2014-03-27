using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DetectorInspector.Infrastructure.QuickBooks
{
    public interface IInvoiceTransactionItem
    {
        string TransactionType { get; }
        DateTime Date { get; set; }
        string Account { get; set; }
        decimal Amount { get; set; }
    }
}