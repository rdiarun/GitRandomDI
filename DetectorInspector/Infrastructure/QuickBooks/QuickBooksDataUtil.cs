using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using DetectorInspector.Data;
using DetectorInspector.Data.NHibernateClient;
using DetectorInspector.Model;
using DetectorInspector.Common.Formatters;

namespace DetectorInspector.Infrastructure.QuickBooks
{
	public static class QuickBooksDataUtil
	{
		public static int GetElectricalDetectorCount(Booking booking)
		{
			var detectorCount = (from d in booking.ServiceSheet.ReplacedElectricalJobServiceItems
								 select d).Count();

			return detectorCount;
		}

		public static int GetElectricalDetectorCountMainsOrSecurity(Booking booking)
		{
			var detectorCount = (from d in booking.ServiceSheet.ReplacedElectricalJobServiceItemsMainsOrSecurity
								 select d).Count();

			return detectorCount;
		}


		// RC. Added for security detector invoicing
		public static int GetElectricalDetectorCountMains(Booking booking)
		{
			var detectorCount = (from d in booking.ServiceSheet.ReplacedElectricalJobServiceItemsMainsDetector
								 select d).Count();

			return detectorCount;
		}

		// RC. Added for security detector invoicing
		public static int GetElectricalDetectorCountSecurity(Booking booking)
		{
			var detectorCount = (from d in booking.ServiceSheet.ReplacedElectricalJobServiceItemsSecurityDetector
								 select d).Count();

			return detectorCount;
		}

		public static int GetReplacedServiceItemCount(Booking booking)
		{
			var count = (from d in booking.ServiceSheet.ReplacedServiceItems
						 select d).Count() + (from d in booking.ServiceSheet.AddedServiceItems
											  select d).Count();

			return count;
		}

		public static int GetReplacedServiceItemWithoutMainsCount(Booking booking)
		{
			var count = (from d in booking.ServiceSheet.ReplacedServiceItemsWithoutElectrical
						 select d).Count() + (from d in booking.ServiceSheet.AddedServiceItemsWithoutMains
											  select d).Count();

			return count;
		}

		public static ServiceItem GetServiceItem(Booking booking, IRepository repository, int detectorCount)
		{
			var serviceItem = new ServiceItem();

			if (booking.ServiceSheet.IsElectrical)
			{
				switch (detectorCount)
				{
					case 1:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector1);
						break;
					case 2:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector2);
						break;
					case 3:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector3);
						break;
					case 4:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector4);
						break;
					case 5:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector5);
						break;
					default:
						serviceItem = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector6);
						break;
				}
			}
			else
			{
				var zone1 = repository.Get<ServiceItem>((int)SystemServiceItem.Zone1);
				var zone2 = repository.Get<ServiceItem>((int)SystemServiceItem.Zone2);
				var zone3 = repository.Get<ServiceItem>((int)SystemServiceItem.Zone3);
				var zones = new List<ServiceItem>() { zone1, zone2, zone3 }.ToArray();

				//var zoneCharge = zones[booking.Zone.Id - 1].Price;
				serviceItem = zones[booking.Zone.Id - 1];
			}

			return serviceItem;
		}

		public static InvoiceTransaction GetTransaction(List<InvoiceTransactionLineItem> lineItems, IRepository repository, PropertyBatch propertyBatch, Booking booking, PropertyInfo item)
		{
			var discountItems = GetDiscountItems(repository, propertyBatch, booking, item);
			String prefix = "";
			//var totalDiscountToApply = discountItems.Select(i => i.Amount).Sum();
			//totalDiscountToApply += (totalDiscountToApply * ApplicationConfig.Current.GstPercentage);

			lineItems.AddRange(discountItems);

			var amount = lineItems.Select(i => i.Amount).Sum();
			var taxAmount = lineItems.Select(i => i.TaxAmount).Sum();


			/* RJC 20130415. 
			 * Added code requested by Jason and revised by Jordan, to prefix part of the property data (propertyNumber) with a letter "A" etc for property numbers above 1000
			 * Note. Initially this code was added into the PropertyInfo model as Jason implied that the change had to be global, but Jordan updated this request 
			 * and indicated that the change must only happen in the invoice.
			*/
			if (item.PropertyNumber > 999)
			{
				prefix += (char)((int)'A' - 1 + item.PropertyNumber / 1000);

				// 26 letters A - Z * 1000 properties per letter (prefix) + 1000 (first 1000 don't have a prefix) = 27000
				if (item.PropertyNumber >= 27000)
				{
					throw new ApplicationException("Property Number too large to create prefix letter");
				}
			}


			/*
* Concole bar code information from http://my.console.com.au/%28X%281%29S%28hcrpacdluozmx0ustjccw1ra%29%29/Default.aspx?TabId=979&kb=350&AspxAutoDetectCookieSupport=1
Scanned barcode - *21200333919008863000007265
Biller - *2120
Ref no – 0333919008863
Amount – $72.65

Example 2

Scanned barcode - 096533429100060000013470
Biller – 096
Ref no – 53342910006
Amount - $134.70

Example 3

Scanned barcode - 16826248768900005511936000892970
Biller – 168
Ref no – 26248768900005511936
Amount - $892.97 
* 
			 
*/

			decimal invoiceAmount = ((amount + taxAmount) * -1);


			//byte []testData = {32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,195,196,197,198,199,200,201,202,203,204,205,206,207};
			// string testChars = "\""+Encoding.ASCII.GetString(testData)+"\"";
			const string billerRef = "1300134563"; // use phone number
			string agencyID = item.Agency != null ? item.Agency.Id.ToString("D4") : "0000";// assign 4 numerical digits to agency
			string propertyNymber = item.PropertyNumber.ToString("D5");// Assign 5 digits to property number at that agency 
			string totalAmountString = Convert.ToInt32(invoiceAmount * 100).ToString("D8");// use 9 digits for dollars and cents, no decimal point i.e show value in cents, with leading zeros to fill 8 digits
			string barcodeText = billerRef + agencyID + propertyNymber + propertyBatch.Date.ToString("MM") + propertyBatch.Date.ToString("yy") + totalAmountString;



#if false

			barcodeText = "408824700338327454024412031145";// Test number that encodes to a string with a double quote in it !
			string enc1 = BarcodeConverter128.StringToBarcode(barcodeText);
			string enc2 = BarcodeConverter128.StringToBarcodeSpecial(barcodeText);
			
			// Test code to find a number that encodes to a bar code text with a double quote in it

			Random random = new Random();
			bool containsQuote=false;
			string encodedText = "";
			int maxCount = 99999999;

			while(containsQuote==false && maxCount-- > 0)
			{
				barcodeText="";
				for(int r=0;r<30;r++)
				{
					barcodeText += random.Next(0, 9).ToString();
				}
				encodedText = BarcodeConverter128.StringToBarcode(barcodeText);
				if (encodedText.IndexOf("\"")!=-1)
				{

					containsQuote = true;
				}
			}
#endif
			String serviceItemPaymentTerms = repository.Get<ServiceItem>((int)SystemServiceItem.PaymentTerms).QuickBooksDescription;

			string addr1="", addr2="", addr3="", addr4="";

			switch (item.JobType)
			{
				case (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged:
					addr1 = "The Owner";
					addr2 = string.Format("C/- {0}", item.Agency.Name);
					addr3 = item.Agency.PostalAddress;
					addr4 = item.Agency.FullPostalSuburb();
					break;

				case (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordWithAgency:
					if (item.PrivateLandlordBillTo == (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.PrivateLandlordBillToTypeEnum.BillToAgency)
					{
						addr1 = item.LandlordName;// "The Owner";
						addr2 = string.Format("C/- {0}", item.PrivateLandlordAgency.Name);
						addr3 = item.PrivateLandlordAgency.PostalAddress;
						addr4 = item.PrivateLandlordAgency.FullPostalSuburb();
					}
					else
					{
						addr1 = item.LandlordName;
						addr2 = item.LandlordAddress;
						addr3 = item.FullLandlordPostalSuburb();
						addr4 = string.Empty;
					}
 
					
					break;
				case (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.PrivateLandlordNoAgency:
					addr1 = item.LandlordName;
					addr2 = item.LandlordAddress;
					addr3 = item.FullLandlordPostalSuburb();
					addr4 = string.Empty;

					break;
				default:
					// Put this in just in case ;-)
					addr1 = "The Owner";
					addr2 = string.Format("C/- {0}", item.Agency.Name);
					addr3 = item.Agency.PostalAddress;
					addr4 = item.Agency.FullPostalSuburb();
					break;
			}



			var transaction = new InvoiceTransaction()
			{

				Date = propertyBatch.Date,
				Amount = invoiceAmount,
				Name = string.Format("{0}:{1}{2}-{3}", item.Agency.Name, prefix, item.FormattedPropertyNumber, item.FullStreetAddress()),
				DocNum = string.Format("{0}-{1}", item.JobCode, propertyBatch.Date.ToString("yy")),
				Class = (booking == null || booking.Technician == null) ? string.Empty : booking.Technician.Name,
				Address1 = addr1,
				Address2 = addr2,
				Address3 = addr3, 
				Address4 = addr4, 
				IsTaxable = true,
				barCode = barcodeText,
				barCodeEncoded = "\"" + BarcodeConverter128.StringToBarcodeSpecial(barcodeText) + "\"",
				propertyAddress1 = item.StreetAddress(),
				propertyAddress2 = item.Suburb + " " + item.State + " " + item.PostCode,
				termsText = serviceItemPaymentTerms
			};

			foreach (var tranItem in lineItems)
			{
				transaction.InvoiceTransactionItems.Add(tranItem);
			}

			return transaction;
		}

		private static List<InvoiceTransactionLineItem> GetDiscountItems(IRepository repository, PropertyBatch propertyBatch, Booking booking, PropertyInfo item)
		{
			var discountItems = new List<InvoiceTransactionLineItem>();
			var serviceSheetDiscountItem = repository.Get<ServiceItem>((int)SystemServiceItem.Discount);
			var propertyDiscountItem = repository.Get<ServiceItem>((int)SystemServiceItem.ServiceFeeDiscount);

			if (booking != null)
			{
				//apply discounts.  This could be:
				//1 - Agency discount - this is handled during the service item callout and is applied directly to the call out fee
				//2 - Property discount
				//3 - Service Sheet discount
				if (booking.ServiceSheet.Discount > 0)
				{
					serviceSheetDiscountItem.Price = booking.ServiceSheet.Discount;
					discountItems.Add(GetDiscountLineItem(propertyBatch, serviceSheetDiscountItem, 1));
				}

				//apply line item discount as a line item on the invoice if a discount exists
				//don't think we need this - think it's just a default.  Left it here just in case


				if (item.Discount > 0)
				{
					propertyDiscountItem.Price = item.Discount;
					discountItems.Add(GetDiscountLineItem(propertyBatch, propertyDiscountItem, 1));
				}
			}

			return discountItems;
		}

		private static InvoiceTransactionLineItem GetDiscountLineItem(PropertyBatch propertyBatch, ServiceItem serviceItem, int quantity)
		{
			var amount = quantity * serviceItem.Price;

			var taxAmount = (amount * ApplicationConfig.Current.GstPercentage);
			taxAmount = Math.Round(taxAmount, 2, System.MidpointRounding.AwayFromZero);
			var transactionLineItem = new InvoiceTransactionLineItem()
			{
				Date = propertyBatch.Date,
				Account = serviceItem.QuickBooksCode,
				Amount = amount,
				Item = serviceItem.Code,
				Quantity = quantity * -1,
				Price = serviceItem.Price * -1,
				Description = serviceItem.QuickBooksDescription,
				Taxable = true,
				TaxAmount = taxAmount
			};

			return transactionLineItem;
		}

		public static InvoiceTransactionLineItem GetAppendedLineItem(PropertyBatch propertyBatch, Booking booking, ServiceItem serviceItem, int quantity, decimal discount, string additionalText)
		{
			var amount = quantity * serviceItem.Price;

			if (discount > 0)
			{
				amount -= discount;
			}

			var taxAmount = Math.Round((amount * ApplicationConfig.Current.GstPercentage), 2, System.MidpointRounding.AwayFromZero);

			var transactionLineItem = new InvoiceTransactionLineItem()
			{
				Date = propertyBatch.Date,
				Account = serviceItem.QuickBooksCode,
				Amount = amount * -1,
				Item = serviceItem.Code,
				Quantity = quantity * -1,
				Price = serviceItem.Price - discount,
				Description = serviceItem.QuickBooksDescription + additionalText,
				Taxable = true,
				TaxAmount = taxAmount * -1,
				Class = LineItemClass(booking)
			};

			return transactionLineItem;
		}

		public static InvoiceTransactionLineItem GetLineItem(PropertyBatch propertyBatch, Booking booking, ServiceItem serviceItem, int quantity, decimal discount)
		{
			var amount = quantity * serviceItem.Price;

			if (discount > 0)
			{
				amount -= discount;
			}

			var taxAmount = Math.Round((amount * ApplicationConfig.Current.GstPercentage), 2, System.MidpointRounding.AwayFromZero);

			var transactionLineItem = new InvoiceTransactionLineItem()
			{
				Date = propertyBatch.Date,
				Account = serviceItem.QuickBooksCode,
				Amount = amount * -1,
				Item = serviceItem.Code,
				Quantity = quantity * -1,
				Price = serviceItem.Price - discount,
				Description = serviceItem.QuickBooksDescription,
				Taxable = true,
				TaxAmount = taxAmount * -1,
				Class = LineItemClass(booking)
			};

			return transactionLineItem;
		}


        //public static InvoiceTransactionLineItem GetLineItemFree(PropertyBatch propertyBatch, Booking booking, ServiceItem serviceItem, int quantity, decimal discount)
        //{
        //    serviceItem.Price = 1;
        //    var amount = quantity * serviceItem.Price;

        //    if (discount > 0)
        //    {
        //        amount -= discount;
        //    }

        //    var taxAmount = Math.Round((amount * ApplicationConfig.Current.GstPercentage), 2, System.MidpointRounding.AwayFromZero);

        //    var transactionLineItem = new InvoiceTransactionLineItem()
        //    {
        //        Date = propertyBatch.Date,
        //        Account = serviceItem.QuickBooksCode,
        //        Amount = amount * -1,
        //        Item = serviceItem.Code,
        //        Quantity = quantity * -1,
        //        Price = serviceItem.Price - discount,
        //        Description = serviceItem.QuickBooksDescription,
        //        Taxable = true,
        //        TaxAmount = taxAmount * -1,
        //        Class = LineItemClass(booking)
        //    };

        //    return transactionLineItem;
        //}

		private static string LineItemClass(Booking booking)
		{
			var className = string.Empty;

			if (booking != null && booking.ServiceSheet != null)
			{
				if (booking.ServiceSheet.IsElectrical)
					className = "Your Sparky";
				else if (booking.Technician != null)
					className = booking.Technician.Name;
			}

			return className;
		}

	}
}