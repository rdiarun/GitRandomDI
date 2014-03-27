using System.Collections.Generic;
using System.Linq;
using System.Text;
using DetectorInspector.Common.Notifications;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure.QuickBooks;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System;
using System.Web;

namespace DetectorInspector.Areas.PropertyInfo.ViewModels
{
    public class BatchViewModel : ViewModel
    {

        public IEnumerable<string> Documents { get; private set; }
        public IEnumerable<ElectricalQuotationDocumentData> EntryNotificationWordDocData { get; private set; }

        public BatchViewModel(IRepository repository, INotificationTemplateEngine templateEngine, SystemNotification systemNotification, int id)
        {
            var propertyBatch = repository.Get<PropertyBatch>(id);
            var notification = repository.Get<Notification>((int)systemNotification);
            var documents = new List<string>();

            List<ElectricalQuotationDocumentData> entryNotificationWordDocData = new List<ElectricalQuotationDocumentData>();

            foreach (var propertyInfo in propertyBatch.PropertyInfo)
            {
                var service = propertyInfo.LastElectricanRequiredServiceSheet;

                var serviceItems = new StringBuilder();
                var electricalNotes = " ";
                var serviceItemCount = 0;
                var totalPrice = 0.0m;
                var discount = 0.0m;
                var detector = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);

                if (service != null)
                {
                    serviceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
                                            select serviceItem).Count();
                    var serviceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
                                             orderby serviceItem.ExpiryYear
                                             select serviceItem.ExpiryYear).Distinct().ToList();
                    serviceItems.Append(string.Format("{0} x {1} expires {2}", serviceItemCount, detector.Name, string.Join(",", serviceSheetItems)));
                    electricalNotes = service.ServiceSheet.ElectricalNotes;
                }
                

                var electricalService = new ServiceItem();
                switch (serviceItemCount)
                {
                    case 1:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector1);
                        break;
                    case 2:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector2);
                        break;
                    case 3:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector3);
                        break;
                    case 4:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector4);
                        break;
                    case 5:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector5);
                        break;
                    default:
                        electricalService = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector6);
                        break;
                }

                var zoneCharge = 0.0m;
                switch (propertyInfo.Zone.Id)
                {
                    case 1:
                        zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone1).Price;
                        break;
                    case 2:
                        zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone2).Price;
                        break;
                    default:
                        zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone3).Price;
                        break;
                }

                // rjc TO DO. Calculate discount etc based on whether its an electrical service or not
                /*
                if (booking.ServiceSheet.IsElectrical)
                {
                    propertyInfo.Discount = detectorServiceItem.Price * propertyInfo.DiscountPercentage / 100;// rjc. 20130319 Hack to use property % discount on electrical service items, as requested by Jason.

                }
                else
                {
                    pPropertyInfo.Discount = zoneCharge * booking.PropertyInfo.DiscountPercentage / 100;
                }
                 */

                if (propertyInfo.Discount > 0)
                {
                    discount = propertyInfo.Discount;
                }

                if (propertyInfo.Agency.Discount > 0)
                {
                    zoneCharge -= propertyInfo.Agency.Discount;
                }

                var certificate = repository.Get<ServiceItem>((int) SystemServiceItem.Certificate);

                totalPrice = certificate.Price + electricalService.Price + (detector.Price * serviceItemCount) - discount;
                totalPrice = totalPrice + Math.Round((totalPrice * ApplicationConfig.Current.GstPercentage),2,System.MidpointRounding.AwayFromZero);

                var address = string.Format("{0} {1}", propertyInfo.UnitShopNumber == null || propertyInfo.UnitShopNumber.Equals(string.Empty) ? propertyInfo.StreetNumber : string.Format("{0}/{1}", propertyInfo.UnitShopNumber, propertyInfo.StreetNumber), propertyInfo.StreetName);
                var postalAddress = address;
                var postalSuburb = propertyInfo.Suburb;
                var postalState = propertyInfo.State;
                var postalPostCode = propertyInfo.PostCode;
                if(propertyInfo.PostalAddress!=null && !propertyInfo.PostalAddress.Equals(string.Empty))
                {
                    postalAddress = propertyInfo.PostalAddress;
                    postalSuburb = propertyInfo.PostalSuburb;
                    postalState = propertyInfo.PostalState;
                    postalPostCode = propertyInfo.PostalPostCode;
                }

                var detachableNotes = string.Empty;
                var replacedItemsNotMainsCount = 0;

                if (service != null)
                    replacedItemsNotMainsCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(service);

                if (service != null && service.ServiceSheet.IsElectricianRequired && replacedItemsNotMainsCount > 0)
                    detachableNotes = @"<p style=""color:red"">+ Extra Detachable smoke detector replaced during initial service $22.00 + GST (required according to building commission regulations and Australian Standards AS 3786)</p>";

                if (templateEngine != null)
                { 
                    var dataSource = new 
                    {
                        AgencyName = propertyInfo.Agency.Name,
                        NotificationDate = propertyBatch.Date.ToLongDateString(),
                        PropertyAddress = propertyInfo.ToString(),
                        TenantName = propertyInfo.OccupantName,
                        StreetAddress = address,
                        Suburb = propertyInfo.Suburb,
                        State = propertyInfo.State.ToString(),
                        PostalAddress = postalAddress,
                        PostalState = postalState.ToString(),
                        PostalSuburb = postalSuburb,
                        PostalPostCode = postalPostCode,
                        ElectricalCallOut = string.Format("{0:C}", repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut).Price),
                        ZoneCharge = string.Format("{0:C}", zoneCharge),
                        DetectorQuantity = serviceItemCount,
                        DetectorDescription = detector.Name,
                        DetectorPrice = string.Format("{0:C}", detector.Price),
                        ServiceDescription = electricalService.Name,
                        ServicePrice = string.Format("{0:C}", electricalService.Price),
                        DiscountDescription = discount> 0?"Discount":string.Empty,
                        DiscountPrice = discount > 0? string.Format(@"{0:C}", discount):string.Empty,
                        CertificateDescription = certificate.Name,
                        CertificatePrice = string.Format("{0:C}", certificate.Price),
                        TotalPrice = string.Format("{0:C}", totalPrice),
                        DetectorLineItem = serviceItems.ToString(),
                        ElectricalNotes = electricalNotes,
                        DetachableNotes = detachableNotes
                    };

                    documents.Add(CleanUpDocument(templateEngine.PrepareDocument(notification, dataSource)));
                }
                else
                {
                    string signoffName = propertyInfo.Agency.EntryNotificationSignoffName;
                    string signoffPosition = propertyInfo.Agency.EntryNotificationSignoffPosition;

                    if (propertyInfo.PropertyManager != null)
                    {
                        if (propertyInfo.PropertyManager.UsePersonalisedEntryNotification==true)
                        {
                            signoffName = propertyInfo.PropertyManager.Name;
                            signoffPosition = propertyInfo.PropertyManager.Position;
                        }
                    }

                    try {
                        ElectricalQuotationDocumentData  dataSource = new ElectricalQuotationDocumentData
                        {
                            AgencyName = propertyInfo.Agency.Name,
                            NotificationDate = propertyBatch.Date.ToLongDateString(),
                            PropertyAddress = propertyInfo.ToString(),
                            TenantName = propertyInfo.OccupantName.ToString(),
                            StreetAddress = address,
                            Suburb = propertyInfo.Suburb,
                            State = propertyInfo.State.ToString(),
                            PostalAddress = postalAddress,
                            PostalState = postalState.ToString(),
                            PostalSuburb = postalSuburb,
                            PostalPostCode = postalPostCode,
                            ElectricalCallOut = string.Format("{0:C}", repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut).Price),
                            ZoneCharge = string.Format("{0:C}", zoneCharge),
                            DetectorQuantity = serviceItemCount,
                            DetectorDescription = detector.Name,
                            DetectorPrice = string.Format("{0:C}", detector.Price),
                            ServiceDescription = electricalService.Name,
                            ServicePrice = string.Format("{0:C}", electricalService.Price),
                            DiscountDescription = discount > 0 ? "Discount" : string.Empty,
                            DiscountPrice = discount > 0 ? string.Format(@"{0:C}", discount) : string.Empty,
                            CertificateDescription = certificate.Name,
                            CertificatePrice = string.Format("{0:C}", certificate.Price),
                            TotalPrice = string.Format("{0:C}", totalPrice),
                            DetectorLineItem = serviceItems.ToString(),
                            ElectricalNotes = electricalNotes,
                            DetachableNotes = detachableNotes,
                            AgencyObject = propertyInfo.Agency,
                            EntryNotificationSignoffName = signoffName,
                            EntryNotificationSignoffPosition = signoffPosition,
                            CurrentDate = DateTime.Now.ToLongDateString(),
                        };
     
                        entryNotificationWordDocData.Add(dataSource);
                    }
                    catch (Exception e)
                    {
                        throw (new Exception("Error processing " + propertyInfo.ToString()));
                    }
                }
            }
            Documents = documents;
            EntryNotificationWordDocData = entryNotificationWordDocData;
        }

        private string CleanUpDocument(string document)
        {
            var header = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html><head><title></title></head><body>";
            var footer = "</body></html>";
            return document.Replace(System.Environment.NewLine, string.Empty).Replace(header, string.Empty).Replace(footer, string.Empty);
        }

    }
}
