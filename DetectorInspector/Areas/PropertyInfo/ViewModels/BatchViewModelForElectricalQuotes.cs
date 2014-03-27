using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DetectorInspector.Common.Notifications;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure.QuickBooks;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Web;
using DetectorInspector.Controllers;
using System.Security.Principal;
using System.Security;
using Kiandra.Web.Mvc.Security;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
namespace DetectorInspector.Areas.PropertyInfo.ViewModels
{
    public class BatchViewModelForElectricalQuotes : ViewModel
    {
        private IUserRepository _userRepository;
        public IEnumerable<string> Documents { get; private set; }
        private IMembershipService membershipService;
        private IPropertyRepository property;
        public IEnumerable<ElectricalQuotationDocumentData> ElectricalQuoteData { get; private set; }

        public BatchViewModelForElectricalQuotes(IRepository repository, INotificationTemplateEngine templateEngine, SystemNotification systemNotification, int id, IPropertyRepository propertyrepository, IMembershipService mem)
        {
            var propertyBatch = repository.Get<PropertyBatch>(id);
            var notification = repository.Get<Notification>((int)systemNotification);
            var documents = new List<string>();
            object dataSource;

            foreach (var propertyInfo in propertyBatch.PropertyInfo)
            {
                dataSource = BuildDatasourceObject(repository, propertyBatch, propertyInfo, propertyInfo.LastElectricanRequiredServiceSheet, propertyrepository, mem);

                documents.Add(CleanUpDocument(templateEngine.PrepareDocument(notification, dataSource)));
            }
            Documents = documents;
        }

        // Constructor added for Electrical Quote report (doc) as required for Word Doc creation (in HomeController)
        //public BatchViewModelForElectricalQuotes(IRepository repository, int id)
        //{
        //    bool isFixedFeeService;
        //    var propertyBatch = repository.Get<PropertyBatch>(id);
        //    ElectricalQuotationDocumentData dataSource;
        //    List<ElectricalQuotationDocumentData> electricalQuoteData = new List<ElectricalQuotationDocumentData>();
        //    DetectorInspector.Model.Booking service;


        //    foreach (var propertyInfo in propertyBatch.PropertyInfo)
        //    {

        //        // Only need to process the items which are Not free or fixed fee service, (as those types don't need approval).
        //        isFixedFeeService = propertyInfo.IsFixedFeeService;
        //        var status = propertyInfo.ElectricalWorkStatus;
        //        if (propertyInfo.Agency != null)
        //        {
        //            isFixedFeeService |= (propertyInfo.Agency.IsFixedFeeService == true);
        //        }

        //        if (propertyInfo.PropertyManager != null)
        //        {
        //            isFixedFeeService |= (propertyInfo.PropertyManager.IsFixedFeeService == true);
        //        }

        //        //              if (propertyInfo.IsFreeService == false && propertyInfo.IsFixedFeeService == false && propertyInfo.Agency.IsFixedFeeService == false && propertyInfo.PropertyManager.IsFixedFeeService == false)
        //        if (propertyInfo.IsFreeService == false && isFixedFeeService == false)
        //        {
        //            service = propertyInfo.LastElectricanRequiredServiceSheet;

        //            if (service == null)
        //            {
        //                service = propertyInfo.LastServiceSheetElecricianRequiredAutomatic;
        //            }
        //            dataSource = BuildDatasourceObject(repository, propertyBatch, propertyInfo, service);

        //            electricalQuoteData.Add(dataSource);
        //        }
        //    }
        //    ElectricalQuoteData = electricalQuoteData;
        //}

        //   Change  by Arun 24 Feb 2014   Electricak Automatic

        public BatchViewModelForElectricalQuotes(IRepository repository, PropertyBatch propertBatch, IPropertyRepository propertyrepository)
        {
            bool isFixedFeeService;
            //var propertyBatch = repository.Get<PropertyBatch>(id);
            var propertyBatch = propertBatch;
            ElectricalQuotationDocumentData dataSource;
            List<ElectricalQuotationDocumentData> electricalQuoteData = new List<ElectricalQuotationDocumentData>();
            DetectorInspector.Model.Booking service;


            foreach (var propertyInfo in propertyBatch.PropertyInfo)
            {

                // Only need to process the items which are Not free or fixed fee service, (as those types don't need approval).
                isFixedFeeService = propertyInfo.IsFixedFeeService;
                var status = propertyInfo.ElectricalWorkStatus;
                if (propertyInfo.Agency != null)
                {
                    isFixedFeeService |= (propertyInfo.Agency.IsFixedFeeService == true);
                }

                if (propertyInfo.PropertyManager != null)
                {
                    isFixedFeeService |= (propertyInfo.PropertyManager.IsFixedFeeService == true);
                }

                //              if (propertyInfo.IsFreeService == false && propertyInfo.IsFixedFeeService == false && propertyInfo.Agency.IsFixedFeeService == false && propertyInfo.PropertyManager.IsFixedFeeService == false)
                if (propertyInfo.IsFreeService == false && isFixedFeeService == false)
                {
                    service = propertyInfo.LastElectricanRequiredServiceSheet;

                    if (service == null)
                    {
                        service = propertyInfo.LastServiceSheetElecricianRequiredAutomatic;
                    }
                    dataSource = BuildDatasourceObject(repository, propertyBatch, propertyInfo, service, property, membershipService);
                    Guid TempUserId = new System.Guid();
                    Guid uid = new System.Guid("ABC15DA1-95D3-4C06-AB97-4EA2E7AC4972");
                    propertyrepository.TempUpdateElectricalWorkStatus(propertyInfo.Id, ElectricalWorkStatus.AwaitingElectricalApproval, uid);


                    electricalQuoteData.Add(dataSource);
                }
            }
            ElectricalQuoteData = electricalQuoteData;
        }

        public BatchViewModelForElectricalQuotes(IRepository repository, PropertyBatch propertBatch)
        {
            bool isFixedFeeService;
            //var propertyBatch = repository.Get<PropertyBatch>(id);
            var propertyBatch = propertBatch;
            ElectricalQuotationDocumentData dataSource;
            List<ElectricalQuotationDocumentData> electricalQuoteData = new List<ElectricalQuotationDocumentData>();
            DetectorInspector.Model.Booking service;


            foreach (var propertyInfo in propertyBatch.PropertyInfo)
            {

                // Only need to process the items which are Not free or fixed fee service, (as those types don't need approval).
                isFixedFeeService = propertyInfo.IsFixedFeeService;
                var status = propertyInfo.ElectricalWorkStatus;
                if (propertyInfo.Agency != null)
                {
                    isFixedFeeService |= (propertyInfo.Agency.IsFixedFeeService == true);
                }

                if (propertyInfo.PropertyManager != null)
                {
                    isFixedFeeService |= (propertyInfo.PropertyManager.IsFixedFeeService == true);
                }

                //              if (propertyInfo.IsFreeService == false && propertyInfo.IsFixedFeeService == false && propertyInfo.Agency.IsFixedFeeService == false && propertyInfo.PropertyManager.IsFixedFeeService == false)
                if (propertyInfo.IsFreeService == false && isFixedFeeService == false)
                {
                    service = propertyInfo.LastElectricanRequiredServiceSheet;

                    if (service == null)
                    {
                        service = propertyInfo.LastServiceSheetElecricianRequiredAutomatic;
                    }
                    dataSource = BuildDatasourceObject(repository, propertyBatch, propertyInfo, service, property, membershipService);


                    electricalQuoteData.Add(dataSource);
                }
            }
            ElectricalQuoteData = electricalQuoteData;
        }

        private static ElectricalQuotationDocumentData BuildDatasourceObject(IRepository repository, PropertyBatch propertyBatch, Model.PropertyInfo propertyInfo, DetectorInspector.Model.Booking service, IPropertyRepository propertyrepository, IMembershipService mem)
        {
            const int MAX_EXPIRY_YEARS = 10;

            ElectricalQuotationDocumentData dataSource;
            // rjc had to create

            // After discussion with Jason about Electrican Required (Automatic), he said for electrical quotes that we need to just get the last service sheet regardless of whether its an electrical job or not
            //      DetectorInspector.Model.Booking service = propertyInfo.LastServiceSheetNoConditions;// LastElectricanRequiredServiceSheet;

            var mainsServiceItems = new StringBuilder();
            var securityServiceItems = new StringBuilder();
            var electricalNotes = " ";
            var mainsServiceItemCount = 0;
            var securityServiceItemCount = 0;
            var allServiceItemCount = 0;


            var totalPrice = 0.0m;
            var totalPriceExGST = 0.0m;
            var totalPriceGST = 0.0m;
            var discount = 0.0m;
            var detectorMains = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);
            var detectorSecurity = repository.Get<ServiceItem>((int)SystemServiceItem.SecurityDetector);
            var anyMainsDetectorExpired = false;
            var anySecurityDetectorExpired = false;
            var anyDetectorExpired = false;
            int earliestMainsExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
            int earliestSecurityExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
            int earliestExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
            bool aDepectorExpiresNextYear = false;
            var automaticFlag = 1;
            var expireFlag = 0;

            if (service != null)
            {

                /*
                  old code that used to retrieve items which were both mains and mains security detectors, this has been now split into 2 separate funcs 

                allServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
                                         select serviceItem).Count();

                var allServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
                                              orderby serviceItem.ExpiryYear
                                              select serviceItem.ExpiryYear).Distinct().ToList();
                */



                // ------------------------------ Do normal mains detectors -------------------------------------
                mainsServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsMainsNotSecurityDetector
                                         select serviceItem).Count();

                var mainsServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsMainsNotSecurityDetector
                                              orderby serviceItem.ExpiryYear
                                              select serviceItem.ExpiryYear).Distinct().ToList();


                string detectorPluralMains = "";
                if (mainsServiceItemCount > 1)
                {
                    detectorPluralMains = "s";
                }
                string expiryMains = "with an expiry year of";// default string for when there are multiple detectors with different dates
                if (mainsServiceSheetItems.Count == 1)
                {
                    if (mainsServiceSheetItems[0] < System.DateTime.Now.Year)
                    {
                        expiryMains = "expired";

                    }
                    else
                    {
                        expiryMains = "expires";
                    }
                }

                if (mainsServiceSheetItems.Count >= 1)
                {
                    // Its possible that there is nothing in this record for detectors where there is a problem
                    // but the vars setup in this won't get used anyway.
                    if (mainsServiceSheetItems[0] != null)
                    {
                        earliestMainsExpiryYear = (int)mainsServiceSheetItems[0];
                        if (mainsServiceSheetItems[0] <= System.DateTime.Now.Year)
                        {
                            expiryMains = "expired";
                            anyMainsDetectorExpired = true;
                        }
                        else
                        {
                            expiryMains = "expires";
                            anyMainsDetectorExpired = false;
                        }

                    }
                }
                mainsServiceItems.Append(string.Format("{0} x {1}{2} {3} {4}", mainsServiceItemCount, detectorMains.Name, detectorPluralMains, expiryMains, string.Join(", ", mainsServiceSheetItems)));

                foreach (var item in mainsServiceSheetItems)
                {
                    if (item == (System.DateTime.Now.Year + 1))
                    {
                        aDepectorExpiresNextYear = true;
                        break;// No need to look for any more, one is enough ;-)
                    }
                }



                /* ------------------------- Do Security detectors (these are a different sort of mains detector ------------------------ */

                securityServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsSecurityDetector
                                            select serviceItem).Count();

                var securityServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsSecurityDetector
                                                 orderby serviceItem.ExpiryYear
                                                 select serviceItem.ExpiryYear).Distinct().ToList();


                string detectorPluralSecurity = "";
                if (securityServiceItemCount > 1)
                {
                    detectorPluralSecurity = "s";
                }
                string expirySecurity = "with an expiry year of";// default string for when there are multiple detectors with different dates
                if (securityServiceSheetItems.Count == 1)
                {
                    if (securityServiceSheetItems[0] < System.DateTime.Now.Year)
                    {
                        expirySecurity = "expired";

                    }
                    else
                    {
                        expirySecurity = "expires";
                    }
                }

                if (securityServiceSheetItems.Count >= 1)
                {
                    // Its possible that there is nothing in this record for detectors where there is a problem
                    // but the vars setup in this won't get used anyway.
                    if (securityServiceSheetItems[0] != null)
                    {
                        earliestSecurityExpiryYear = (int)securityServiceSheetItems[0];
                        if (securityServiceSheetItems[0] <= System.DateTime.Now.Year)
                        {
                            expirySecurity = "expired";
                            anySecurityDetectorExpired = true;
                        }
                        else
                        {
                            expirySecurity = "expire";
                            anySecurityDetectorExpired = false;
                        }
                    }
                }

                if (aDepectorExpiresNextYear == false)
                {
                    // only need to do this if we've not already found a detector that expires next year
                    foreach (var item in securityServiceSheetItems)
                    {
                        if (item == (System.DateTime.Now.Year + 1))
                        {
                            aDepectorExpiresNextYear = true;
                            break;// No need to look for any more, one is enough ;-)
                        }
                    }
                }

                // Note. Hack below to include name of the security detector, but the text required on the Quote is different to the name stored in the detector table.
                // Ideally the way to fix this is to have a name and a description in the detector table, but that change is beyond the budget available from Jason.
                securityServiceItems.Append(string.Format("{0} x {1}{2} {3} {4}", securityServiceItemCount, "Security 12 Volt smoke detector", detectorPluralSecurity, expirySecurity, string.Join(",", securityServiceSheetItems)));

                electricalNotes = service.ServiceSheet.ElectricalNotes;

                if (string.IsNullOrWhiteSpace(electricalNotes) == false)
                {
                    electricalNotes = " (" + electricalNotes + ")";
                }

                earliestExpiryYear = earliestMainsExpiryYear < earliestSecurityExpiryYear ? earliestMainsExpiryYear : earliestSecurityExpiryYear;

                if (anySecurityDetectorExpired == true || anyMainsDetectorExpired == true)
                {
                    anyDetectorExpired = true;
                }

            }


            var es = new ServiceItem();
            switch (mainsServiceItemCount + securityServiceItemCount)
            {
                case 1:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector1);
                    break;
                case 2:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector2);
                    break;
                case 3:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector3);
                    break;
                case 4:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector4);
                    break;
                case 5:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector5);
                    break;
                default:
                    es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector6);
                    break;
            }

            if ((HttpContext.Current.Application["ServiceStatus"] == "AlarmExpired") || (HttpContext.Current.Application["ServiceStatusMains"] == "AlarmExpiredMains"))
            {
                expireFlag = 1;

                HttpContext.Current.Application["ServiceStatus"] = "";
                HttpContext.Current.Application["ServiceStatusMains"] = "";
            }
            // NF. Fix for bug where the es.Price was being set in the code below this (apply agency discounts first code). Looks like nhibernate caches objects its previously loaded
            // so changing the Price property then meant the next load got the adjusted price, not the price from the db. The solution is not to touch the value in the object, put it 
            // in a local variable and use this in the rest of the code below.
            var esPrice = es.Price;
            //   if ((propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.NoElectricianRequired || propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.ElectricianRequired))
            if (propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.NoElectricianRequired)
            {
                //  esPrice = 0;
                automaticFlag = 0;
                //  string a = "";
                //   MaintainElectricalWorkStatus(Convert.ToInt32(propertyInfo.Id), "Automatic");
                //  MaintainElectricalWorkStatus(2, a);
                SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"].ConnectionString);
                using (var cmd = new SqlCommand("p_PropertyBatchItemAutomaticTable_Update", (SqlConnection)conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@PropertyInfo", propertyInfo.Id);
                    cmd.Parameters.AddWithValue("@ElectricalWorkStatusId", ElectricalWorkStatus.NoElectricianRequired);
                    // cmd.Parameters.AddWithValue("@CustomerCode", "");

                    if (conn.State == ConnectionState.Closed)
                    {
                        conn.Open();
                    }
                    var result = cmd.ExecuteScalar();

                }
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

            // Apply agency discounts first as they are $ values
            if (propertyInfo.Agency.Discount > 0)
            {
                zoneCharge -= propertyInfo.Agency.Discount;
                // NF 20140110 removed as Jason/Jordan say the discounts should only be applied to service charges, not electrical ones which would seem to go against notes from RJC below
                // so commenting this so that there is some documentation on the pushmepullme type nature of this work.
                //                esPrice -= propertyInfo.Agency.Discount;// rjc 20130430. Jason said Agency discount needs to come off electrical service price
            }

            // Now apply property discount %
            if (propertyInfo.DiscountPercentage > 0)
            {
                discount = esPrice * (propertyInfo.DiscountPercentage / 100);// rjc 20130430 use discount percentage instead of $ (and is % of callout fee)
            }



            var detachableNotes = string.Empty;
            var replacedItemsNotMainsCount = 0;
            bool hasDetachableNotes = false;

            if (service != null)
                replacedItemsNotMainsCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(service);

            if (service != null && service.ServiceSheet.IsElectricianRequired && replacedItemsNotMainsCount > 0)
            {
                detachableNotes = @"<p style=""color:red"">+ Extra Detachable smoke detector replaced during initial service $22.00 + GST (required according to building commission regulations and Australian Standards AS 3786)</p>";
                hasDetachableNotes = true;
            }


            var certificate = repository.Get<ServiceItem>((int)SystemServiceItem.Certificate);
            var detachablePrice = repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector).Price;

            totalPriceExGST = certificate.Price + esPrice + (detectorMains.Price * mainsServiceItemCount) + (detectorSecurity.Price * securityServiceItemCount) + (replacedItemsNotMainsCount * detachablePrice) - discount;
            totalPriceGST = Math.Round(totalPriceExGST * ApplicationConfig.Current.GstPercentage, 2, System.MidpointRounding.AwayFromZero);

            totalPrice = totalPriceExGST + totalPriceGST;

            var address = string.Format("{0} {1}", propertyInfo.UnitShopNumber == null || propertyInfo.UnitShopNumber.Equals(string.Empty) ? propertyInfo.StreetNumber : string.Format("{0}/{1}", propertyInfo.UnitShopNumber, propertyInfo.StreetNumber), propertyInfo.StreetName);
            var postalAddress = address;
            var postalSuburb = propertyInfo.Suburb;
            var postalState = propertyInfo.State;
            var postalPostCode = propertyInfo.PostCode;
            if (propertyInfo.PostalAddress != null && !propertyInfo.PostalAddress.Equals(string.Empty))
            {
                postalAddress = propertyInfo.PostalAddress;
                postalSuburb = propertyInfo.PostalSuburb;
                postalState = propertyInfo.PostalState;
                postalPostCode = propertyInfo.PostalPostCode;
            }



            // Guid TempUserId = new System.Guid();
            //TempUserId =(Guid)HttpContext.Current.User.Identity.GetUserId().Value;
            //propertyrepository.UpdateElectricalWorkStatus(propertyInfo.Id, ElectricalWorkStatus.AwaitingElectricalApproval,);
            //var userId = mem.GetUserIdForUserName("admin1");
            //  Guid uid = new System.Guid("ABC15DA1-95D3-4C06-AB97-4EA2E7AC4972");
            //  uid = (Guid)userId;
            //  uid = (Guid)userId;
            //   propertyrepository.UpdateElectricalWorkStatus(propertyInfo.Id, ElectricalWorkStatus.AwaitingElectricalApproval, uid);

            //propertyrepository.TempUpdateElectricalWorkStatus(propertyInfo.Id, ElectricalWorkStatus.AwaitingElectricalApproval, uid);

            // propertyrepository.UpdateElectricalWorkStatus(IEnumerable<propertyInfo>(propertyInfo.Id), ElectricalWorkStatus.AwaitingElectricalApproval, uid);
            //ElectricalQuotationDocumentData ds = new ElectricalQuotationDocumentData();
            try
            {
                dataSource = new ElectricalQuotationDocumentData
                {
                    // AgencyName = propertyInfo.Agency.Name,
                    NotificationDate = propertyBatch.Date.ToLongDateString(),
                    PropertyAddress = propertyInfo.ToString(),
                    TenantName = propertyInfo.OccupantName,
                    StreetAddress = address,
                    Suburb = propertyInfo.Suburb,
                    State = propertyInfo.State.ToString(),
                    PostalAddress = postalAddress,
                    //   PostalState = postalState.ToString(),
                    //  PostalSuburb = postalSuburb,
                    //  PostalPostCode = postalPostCode,
                    ElectricalCallOut = string.Format("{0:C}", repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut).Price),
                    ZoneCharge = string.Format("{0:C}", zoneCharge),

                    DetectorQuantity = mainsServiceItemCount,
                    DetectorPlural = mainsServiceItemCount > 1 ? "s" : string.Empty,
                    DetectorDescription = detectorMains.Name + (mainsServiceItemCount > 1 ? "s" : string.Empty),
                    DetectorPrice = mainsServiceItemCount > 0 ? string.Format("{0:F2}", detectorMains.Price * mainsServiceItemCount) : string.Empty,
                    DetectorMainsLineItem = mainsServiceItemCount > 0 ? mainsServiceItemCount + " x " + detectorMains.Name + (mainsServiceItemCount > 1 ? "s" : string.Empty) : string.Empty,
                    DMLD = (mainsServiceItemCount > 0 ? "$" : string.Empty),

                    DetectorAllPlural = (mainsServiceItemCount + securityServiceItemCount) > 1 ? "s" : string.Empty,

                    DetectorSecurityQuantity = securityServiceItemCount,
                    DetectorSecurityPlural = securityServiceItemCount > 1 ? "s" : string.Empty,
                    DetectorSecurityDescription = detectorSecurity.Name + (securityServiceItemCount > 1 ? "s" : string.Empty),
                    DetectorSecurityPrice = securityServiceItemCount > 0 ? string.Format("{0:F2}", detectorSecurity.Price * securityServiceItemCount) : string.Empty,
                    DSLD = (securityServiceItemCount > 0 ? "$" : string.Empty),
                    DetectorSecurityLineItem = securityServiceItemCount > 0 ? securityServiceItemCount + " x " + detectorSecurity.Name + (securityServiceItemCount > 1 ? "s" : string.Empty) : string.Empty,
                    DetectorSecurityDisplayItem = securityServiceItems.ToString(),

                    ServiceDescription = "Electrical call out fee and installation of new units",//electricalService.Name +
                    ServicePrice = string.Format("{0:F2}", esPrice),
                    DiscountDescription = discount > 0 ? "Property Discount" : string.Empty,
                    DiscountPrice = discount > 0 ? string.Format("-{0:F2}", discount) : string.Empty,
                    CertificateDescription = certificate.Name,
                    CertificatePrice = string.Format("{0:F2}", certificate.Price),
                    TotalPrice = string.Format("{0:F2}", totalPrice),// "{0:C}"
                    TotalPriceExGST = string.Format("{0:F2}", totalPriceExGST),// "{0:C}",
                    TotalPriceGST = string.Format("{0:F2}", totalPriceGST),
                    DetectorLineItem = mainsServiceItems.ToString(),
                    ElectricalNotes = electricalNotes,
                    DetachableNotes = detachableNotes,
                    HasDetachableNotes = hasDetachableNotes,
                    DetachablesCount = replacedItemsNotMainsCount,
                    DDLD = (replacedItemsNotMainsCount > 0 ? "$" : string.Empty),
                    DetachablesTotalCost = replacedItemsNotMainsCount > 0 ? (string.Format("{0:F2}", (replacedItemsNotMainsCount * detachablePrice))) : String.Empty,
                    InvoiceDateCreated = System.DateTime.Now.ToString("dd MMMM yyyy"),
                    AnyDetectorExpired = anyDetectorExpired,
                    EarliestExpiryYear = earliestExpiryYear.ToString(),
                    EarliestExpiryDate = "31/12/" + (earliestExpiryYear - 1),
                    DetachablePrice = string.Format("{0:F2}", detachablePrice),
                    ADetectorExiresNextYear = aDepectorExpiresNextYear,
                    ADetectorExiresNextYearYearNum = (System.DateTime.Now.Year + 1).ToString(),
                    ADetectorExiresNextYearDate = "31/12/" + System.DateTime.Now.Year.ToString(),
                    ADPL = (((mainsServiceItemCount + securityServiceItemCount + replacedItemsNotMainsCount) > 1) ? "s" : string.Empty),
                    AutomaticFlag = automaticFlag,
                    ExpireFlag = expireFlag,
                    Expireyear = (System.DateTime.Now.Year + 2).ToString()
                };
                return dataSource;
            }
            catch
            {
                string s; ;

                try
                {
                    s = propertyInfo.ToString();
                }
                catch (System.NullReferenceException)
                {
                    s = "NO ADDRESS";
                }
                throw (new DetectorInspectorInvalidDataException("Invalid data for property " + s));
            }


        }


        //private static ElectricalQuotationDocumentData BuildDatasourceObject(IRepository repository, PropertyBatch propertyBatch, Model.PropertyInfo propertyInfo, DetectorInspector.Model.Booking service)
        //{
        //    const int MAX_EXPIRY_YEARS = 10;

        //    ElectricalQuotationDocumentData dataSource;
        //    // rjc had to create

        //    // After discussion with Jason about Electrican Required (Automatic), he said for electrical quotes that we need to just get the last service sheet regardless of whether its an electrical job or not
        //    //      DetectorInspector.Model.Booking service = propertyInfo.LastServiceSheetNoConditions;// LastElectricanRequiredServiceSheet;

        //    var mainsServiceItems = new StringBuilder();
        //    var securityServiceItems = new StringBuilder();
        //    var electricalNotes = " ";
        //    var mainsServiceItemCount = 0;
        //    var securityServiceItemCount = 0;
        //    var allServiceItemCount = 0;


        //    var totalPrice = 0.0m;
        //    var totalPriceExGST = 0.0m;
        //    var totalPriceGST = 0.0m;
        //    var discount = 0.0m;
        //    var detectorMains = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalMainDetector);
        //    var detectorSecurity = repository.Get<ServiceItem>((int)SystemServiceItem.SecurityDetector);
        //    var anyMainsDetectorExpired = false;
        //    var anySecurityDetectorExpired = false;
        //    var anyDetectorExpired = false;
        //    int earliestMainsExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
        //    int earliestSecurityExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
        //    int earliestExpiryYear = System.DateTime.Now.Year + MAX_EXPIRY_YEARS;
        //    bool aDepectorExpiresNextYear = false;
        //    var automaticFlag = 1;
        //    var expireFlag = 0;

        //    if (service != null)
        //    {

        //        /*
        //          old code that used to retrieve items which were both mains and mains security detectors, this has been now split into 2 separate funcs 

        //        allServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
        //                                 select serviceItem).Count();

        //        var allServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItems
        //                                      orderby serviceItem.ExpiryYear
        //                                      select serviceItem.ExpiryYear).Distinct().ToList();
        //        */



        //        // ------------------------------ Do normal mains detectors -------------------------------------
        //        mainsServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsMainsNotSecurityDetector
        //                                 select serviceItem).Count();

        //        var mainsServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsMainsNotSecurityDetector
        //                                      orderby serviceItem.ExpiryYear
        //                                      select serviceItem.ExpiryYear).Distinct().ToList();


        //        string detectorPluralMains = "";
        //        if (mainsServiceItemCount > 1)
        //        {
        //            detectorPluralMains = "s";
        //        }
        //        string expiryMains = "with an expiry year of";// default string for when there are multiple detectors with different dates
        //        if (mainsServiceSheetItems.Count == 1)
        //        {
        //            if (mainsServiceSheetItems[0] < System.DateTime.Now.Year)
        //            {
        //                expiryMains = "expired";

        //            }
        //            else
        //            {
        //                expiryMains = "expires";
        //            }
        //        }

        //        if (mainsServiceSheetItems.Count >= 1)
        //        {
        //            // Its possible that there is nothing in this record for detectors where there is a problem
        //            // but the vars setup in this won't get used anyway.
        //            if (mainsServiceSheetItems[0] != null)
        //            {
        //                earliestMainsExpiryYear = (int)mainsServiceSheetItems[0];
        //                if (mainsServiceSheetItems[0] <= System.DateTime.Now.Year)
        //                {
        //                    expiryMains = "expired";
        //                    anyMainsDetectorExpired = true;
        //                }
        //                else
        //                {
        //                    expiryMains = "expires";
        //                    anyMainsDetectorExpired = false;
        //                }

        //            }
        //        }
        //        mainsServiceItems.Append(string.Format("{0} x {1}{2} {3} {4}", mainsServiceItemCount, detectorMains.Name, detectorPluralMains, expiryMains, string.Join(", ", mainsServiceSheetItems)));

        //        foreach (var item in mainsServiceSheetItems)
        //        {
        //            if (item == (System.DateTime.Now.Year + 1))
        //            {
        //                aDepectorExpiresNextYear = true;
        //                break;// No need to look for any more, one is enough ;-)
        //            }
        //        }



        //        /* ------------------------- Do Security detectors (these are a different sort of mains detector ------------------------ */

        //        securityServiceItemCount = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsSecurityDetector
        //                                    select serviceItem).Count();

        //        var securityServiceSheetItems = (from serviceItem in service.ServiceSheet.ExpiredAndProblematicElectricalJobServiceItemsSecurityDetector
        //                                         orderby serviceItem.ExpiryYear
        //                                         select serviceItem.ExpiryYear).Distinct().ToList();


        //        string detectorPluralSecurity = "";
        //        if (securityServiceItemCount > 1)
        //        {
        //            detectorPluralSecurity = "s";
        //        }
        //        string expirySecurity = "with an expiry year of";// default string for when there are multiple detectors with different dates
        //        if (securityServiceSheetItems.Count == 1)
        //        {
        //            if (securityServiceSheetItems[0] < System.DateTime.Now.Year)
        //            {
        //                expirySecurity = "expired";

        //            }
        //            else
        //            {
        //                expirySecurity = "expires";
        //            }
        //        }

        //        if (securityServiceSheetItems.Count >= 1)
        //        {
        //            // Its possible that there is nothing in this record for detectors where there is a problem
        //            // but the vars setup in this won't get used anyway.
        //            if (securityServiceSheetItems[0] != null)
        //            {
        //                earliestSecurityExpiryYear = (int)securityServiceSheetItems[0];
        //                if (securityServiceSheetItems[0] <= System.DateTime.Now.Year)
        //                {
        //                    expirySecurity = "expired";
        //                    anySecurityDetectorExpired = true;
        //                }
        //                else
        //                {
        //                    expirySecurity = "expire";
        //                    anySecurityDetectorExpired = false;
        //                }
        //            }
        //        }

        //        if (aDepectorExpiresNextYear == false)
        //        {
        //            // only need to do this if we've not already found a detector that expires next year
        //            foreach (var item in securityServiceSheetItems)
        //            {
        //                if (item == (System.DateTime.Now.Year + 1))
        //                {
        //                    aDepectorExpiresNextYear = true;
        //                    break;// No need to look for any more, one is enough ;-)
        //                }
        //            }
        //        }

        //        // Note. Hack below to include name of the security detector, but the text required on the Quote is different to the name stored in the detector table.
        //        // Ideally the way to fix this is to have a name and a description in the detector table, but that change is beyond the budget available from Jason.
        //        securityServiceItems.Append(string.Format("{0} x {1}{2} {3} {4}", securityServiceItemCount, "Security 12 Volt smoke detector", detectorPluralSecurity, expirySecurity, string.Join(",", securityServiceSheetItems)));

        //        electricalNotes = service.ServiceSheet.ElectricalNotes;

        //        if (string.IsNullOrWhiteSpace(electricalNotes) == false)
        //        {
        //            electricalNotes = " (" + electricalNotes + ")";
        //        }

        //        earliestExpiryYear = earliestMainsExpiryYear < earliestSecurityExpiryYear ? earliestMainsExpiryYear : earliestSecurityExpiryYear;

        //        if (anySecurityDetectorExpired == true || anyMainsDetectorExpired == true)
        //        {
        //            anyDetectorExpired = true;
        //        }

        //    }


        //    var es = new ServiceItem();
        //    switch (mainsServiceItemCount + securityServiceItemCount)
        //    {
        //        case 1:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector1);
        //            break;
        //        case 2:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector2);
        //            break;
        //        case 3:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector3);
        //            break;
        //        case 4:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector4);
        //            break;
        //        case 5:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector5);
        //            break;
        //        default:
        //            es = repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalSmokeDetector6);
        //            break;
        //    }

        //    if ((HttpContext.Current.Application["ServiceStatus"] == "AlarmExpired") || (HttpContext.Current.Application["ServiceStatusMains"] == "AlarmExpiredMains"))
        //    {
        //        expireFlag = 1;

        //        HttpContext.Current.Application["ServiceStatus"] = "";
        //        HttpContext.Current.Application["ServiceStatusMains"] = "";
        //    }
        //    // NF. Fix for bug where the es.Price was being set in the code below this (apply agency discounts first code). Looks like nhibernate caches objects its previously loaded
        //    // so changing the Price property then meant the next load got the adjusted price, not the price from the db. The solution is not to touch the value in the object, put it 
        //    // in a local variable and use this in the rest of the code below.
        //    var esPrice = es.Price;
        //    if ((propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.NoElectricianRequired || propertyInfo.ElectricalWorkStatus == ElectricalWorkStatus.ElectricianRequired))
        //    {
        //        esPrice = 0;
        //        automaticFlag = 0;
        //    }
        //    var zoneCharge = 0.0m;
        //    switch (propertyInfo.Zone.Id)
        //    {
        //        case 1:
        //            zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone1).Price;
        //            break;
        //        case 2:
        //            zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone2).Price;
        //            break;
        //        default:
        //            zoneCharge = repository.Get<ServiceItem>((int)SystemServiceItem.Zone3).Price;
        //            break;
        //    }

        //    // rjc TO DO. Calculate discount etc based on whether its an electrical service or not
        //    /*
        //    if (booking.ServiceSheet.IsElectrical)
        //    {
        //        propertyInfo.Discount = detectorServiceItem.Price * propertyInfo.DiscountPercentage / 100;// rjc. 20130319 Hack to use property % discount on electrical service items, as requested by Jason.

        //    }
        //    else
        //    {
        //        pPropertyInfo.Discount = zoneCharge * booking.PropertyInfo.DiscountPercentage / 100;
        //    }
        //     */

        //    // Apply agency discounts first as they are $ values
        //    if (propertyInfo.Agency.Discount > 0)
        //    {
        //        zoneCharge -= propertyInfo.Agency.Discount;
        //        // NF 20140110 removed as Jason/Jordan say the discounts should only be applied to service charges, not electrical ones which would seem to go against notes from RJC below
        //        // so commenting this so that there is some documentation on the pushmepullme type nature of this work.
        //        //                esPrice -= propertyInfo.Agency.Discount;// rjc 20130430. Jason said Agency discount needs to come off electrical service price
        //    }

        //    // Now apply property discount %
        //    if (propertyInfo.DiscountPercentage > 0)
        //    {
        //        discount = esPrice * (propertyInfo.DiscountPercentage / 100);// rjc 20130430 use discount percentage instead of $ (and is % of callout fee)
        //    }



        //    var detachableNotes = string.Empty;
        //    var replacedItemsNotMainsCount = 0;
        //    bool hasDetachableNotes = false;

        //    if (service != null)
        //        replacedItemsNotMainsCount = QuickBooksDataUtil.GetReplacedServiceItemWithoutMainsCount(service);

        //    if (service != null && service.ServiceSheet.IsElectricianRequired && replacedItemsNotMainsCount > 0)
        //    {
        //        detachableNotes = @"<p style=""color:red"">+ Extra Detachable smoke detector replaced during initial service $22.00 + GST (required according to building commission regulations and Australian Standards AS 3786)</p>";
        //        hasDetachableNotes = true;
        //    }


        //    var certificate = repository.Get<ServiceItem>((int)SystemServiceItem.Certificate);
        //    var detachablePrice = repository.Get<ServiceItem>((int)SystemServiceItem.SmokeDetector).Price;

        //    totalPriceExGST = certificate.Price + esPrice + (detectorMains.Price * mainsServiceItemCount) + (detectorSecurity.Price * securityServiceItemCount) + (replacedItemsNotMainsCount * detachablePrice) - discount;
        //    totalPriceGST = Math.Round(totalPriceExGST * ApplicationConfig.Current.GstPercentage, 2, System.MidpointRounding.AwayFromZero);

        //    totalPrice = totalPriceExGST + totalPriceGST;

        //    var address = string.Format("{0} {1}", propertyInfo.UnitShopNumber == null || propertyInfo.UnitShopNumber.Equals(string.Empty) ? propertyInfo.StreetNumber : string.Format("{0}/{1}", propertyInfo.UnitShopNumber, propertyInfo.StreetNumber), propertyInfo.StreetName);
        //    var postalAddress = address;
        //    var postalSuburb = propertyInfo.Suburb;
        //    var postalState = propertyInfo.State;
        //    var postalPostCode = propertyInfo.PostCode;
        //    if (propertyInfo.PostalAddress != null && !propertyInfo.PostalAddress.Equals(string.Empty))
        //    {
        //        postalAddress = propertyInfo.PostalAddress;
        //        postalSuburb = propertyInfo.PostalSuburb;
        //        postalState = propertyInfo.PostalState;
        //        postalPostCode = propertyInfo.PostalPostCode;
        //    }


        //    //ElectricalQuotationDocumentData ds = new ElectricalQuotationDocumentData();

        //    //     _propertyRepository.UpdateElectricalWorkStatus(propertyInfo.Id, ElectricalWorkStatus.AwaitingElectricalApproval, User.Identity.GetUserId().Value);

        //    try
        //    {
        //        dataSource = new ElectricalQuotationDocumentData
        //        {
        //            // AgencyName = propertyInfo.Agency.Name,
        //            NotificationDate = propertyBatch.Date.ToLongDateString(),
        //            PropertyAddress = propertyInfo.ToString(),
        //            TenantName = propertyInfo.OccupantName,
        //            StreetAddress = address,
        //            Suburb = propertyInfo.Suburb,
        //            State = propertyInfo.State.ToString(),
        //            PostalAddress = postalAddress,
        //            //   PostalState = postalState.ToString(),
        //            //  PostalSuburb = postalSuburb,
        //            //  PostalPostCode = postalPostCode,
        //            ElectricalCallOut = string.Format("{0:C}", repository.Get<ServiceItem>((int)SystemServiceItem.ElectricalCallOut).Price),
        //            ZoneCharge = string.Format("{0:C}", zoneCharge),

        //            DetectorQuantity = mainsServiceItemCount,
        //            DetectorPlural = mainsServiceItemCount > 1 ? "s" : string.Empty,
        //            DetectorDescription = detectorMains.Name + (mainsServiceItemCount > 1 ? "s" : string.Empty),
        //            DetectorPrice = mainsServiceItemCount > 0 ? string.Format("{0:F2}", detectorMains.Price * mainsServiceItemCount) : string.Empty,
        //            DetectorMainsLineItem = mainsServiceItemCount > 0 ? mainsServiceItemCount + " x " + detectorMains.Name + (mainsServiceItemCount > 1 ? "s" : string.Empty) : string.Empty,
        //            DMLD = (mainsServiceItemCount > 0 ? "$" : string.Empty),

        //            DetectorAllPlural = (mainsServiceItemCount + securityServiceItemCount) > 1 ? "s" : string.Empty,

        //            DetectorSecurityQuantity = securityServiceItemCount,
        //            DetectorSecurityPlural = securityServiceItemCount > 1 ? "s" : string.Empty,
        //            DetectorSecurityDescription = detectorSecurity.Name + (securityServiceItemCount > 1 ? "s" : string.Empty),
        //            DetectorSecurityPrice = securityServiceItemCount > 0 ? string.Format("{0:F2}", detectorSecurity.Price * securityServiceItemCount) : string.Empty,
        //            DSLD = (securityServiceItemCount > 0 ? "$" : string.Empty),
        //            DetectorSecurityLineItem = securityServiceItemCount > 0 ? securityServiceItemCount + " x " + detectorSecurity.Name + (securityServiceItemCount > 1 ? "s" : string.Empty) : string.Empty,
        //            DetectorSecurityDisplayItem = securityServiceItems.ToString(),

        //            ServiceDescription = "Electrical call out fee and installation of new units",//electricalService.Name +
        //            ServicePrice = string.Format("{0:F2}", esPrice),
        //            DiscountDescription = discount > 0 ? "Property Discount" : string.Empty,
        //            DiscountPrice = discount > 0 ? string.Format("-{0:F2}", discount) : string.Empty,
        //            CertificateDescription = certificate.Name,
        //            CertificatePrice = string.Format("{0:F2}", certificate.Price),
        //            TotalPrice = string.Format("{0:F2}", totalPrice),// "{0:C}"
        //            TotalPriceExGST = string.Format("{0:F2}", totalPriceExGST),// "{0:C}",
        //            TotalPriceGST = string.Format("{0:F2}", totalPriceGST),
        //            DetectorLineItem = mainsServiceItems.ToString(),
        //            ElectricalNotes = electricalNotes,
        //            DetachableNotes = detachableNotes,
        //            HasDetachableNotes = hasDetachableNotes,
        //            DetachablesCount = replacedItemsNotMainsCount,
        //            DDLD = (replacedItemsNotMainsCount > 0 ? "$" : string.Empty),
        //            DetachablesTotalCost = replacedItemsNotMainsCount > 0 ? (string.Format("{0:F2}", (replacedItemsNotMainsCount * detachablePrice))) : String.Empty,
        //            InvoiceDateCreated = System.DateTime.Now.ToString("dd MMMM yyyy"),
        //            AnyDetectorExpired = anyDetectorExpired,
        //            EarliestExpiryYear = earliestExpiryYear.ToString(),
        //            EarliestExpiryDate = "31/12/" + (earliestExpiryYear - 1),
        //            DetachablePrice = string.Format("{0:F2}", detachablePrice),
        //            ADetectorExiresNextYear = aDepectorExpiresNextYear,
        //            ADetectorExiresNextYearYearNum = (System.DateTime.Now.Year + 1).ToString(),
        //            ADetectorExiresNextYearDate = "31/12/" + System.DateTime.Now.Year.ToString(),
        //            ADPL = (((mainsServiceItemCount + securityServiceItemCount + replacedItemsNotMainsCount) > 1) ? "s" : string.Empty),
        //            AutomaticFlag = automaticFlag,
        //            ExpireFlag = expireFlag,
        //            Expireyear = (System.DateTime.Now.Year + 2).ToString()
        //        };
        //        return dataSource;
        //    }
        //    catch
        //    {
        //        string s; ;

        //        try
        //        {
        //            s = propertyInfo.ToString();
        //        }
        //        catch (System.NullReferenceException)
        //        {
        //            s = "NO ADDRESS";
        //        }
        //        throw (new DetectorInspectorInvalidDataException("Invalid data for property " + s));
        //    }


        //}




        private string CleanUpDocument(string document)
        {
            var header = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html><head><title></title></head><body>";
            var footer = "</body></html>";
            return document.Replace(System.Environment.NewLine, string.Empty).Replace(header, string.Empty).Replace(footer, string.Empty);
        }


        public void MaintainElectricalWorkStatus(int PropertyInfo, string ElectricalWorkStatus)
        {
            Guid ids = Guid.NewGuid();
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"].ConnectionString);
            using (var cmd = new SqlCommand("p_PropertyBatchItemAutomaticTable_Update", (SqlConnection)conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PropertyInfo", PropertyInfo);
                cmd.Parameters.AddWithValue("@ElectricalWorkStatus", ElectricalWorkStatus);
               

                if (conn.State == ConnectionState.Closed)
                {
                    conn.Open();
                }
                var result = cmd.ExecuteScalar();
                
            }
        }
    }
}
