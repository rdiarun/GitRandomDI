using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using DetectorInspector.Areas.Admin.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Kiandra.Data;

namespace DetectorInspector.Areas.Admin.Controllers
{
	[HandleError]
	[RequirePermission(Permission.AdministerSystem)]
	public class ImportController : SiteController
	{
		private readonly IRepository _repository;
		private readonly IStateRepository _stateRepository;
		private readonly ITechnicianRepository _technicianRepository;
		private readonly ISuburbRepository _suburbRepository;
		private readonly IPropertyRepository _propertyRepository;
		private readonly ITransactionFactory _transactionFactory;

		private readonly IConsolePropertyImporter _consoleImporter;
		private readonly IConsole2007PropertyImporter _console2007Importer;
		private readonly IAgencyRepository _agencyRepository;

		public ImportController(
			ITransactionFactory transactionFactory,
			IRepository repository,
			IStateRepository stateRepository,
			ITechnicianRepository technicianRepository,
			IPropertyRepository propertyRepository,
			ISuburbRepository suburbRepository,
			IBookingRepository bookingRepository,
			IHelpRepository helpRepository,
			IConsolePropertyImporter consoleImporter,
			IConsole2007PropertyImporter console2007Importer,
			IAgencyRepository agencyRepository)
			: base(transactionFactory, repository, helpRepository)
		{
			_console2007Importer = console2007Importer;
			_consoleImporter = consoleImporter;
			_transactionFactory = transactionFactory;
			_propertyRepository = propertyRepository;
			_suburbRepository = suburbRepository;
			_repository = repository;
			_technicianRepository = technicianRepository;
			_stateRepository = stateRepository;
			_agencyRepository = agencyRepository;
		}

		public ActionResult Index()
		{
			var showClearButton = ApplicationConfig.Current.Environment != "Release";

			var model = new ImportViewModel(_repository, _propertyRepository) { ShowClearDatabaseButton = showClearButton };
			return View(model);
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Index(HttpPostedFileBase uploadedFile, FormCollection form)
		{
			var model = new ImportViewModel(_repository, _propertyRepository);
			
			if (TryUpdateModel(model, form.ToValueProvider()) && uploadedFile != null)
			{
				try
				{
					var propertyNumber = _propertyRepository.GetPropertyNumber(model.Agency.Id);
					var result = GetImportProperties(model.ImportType, model.ImportFormat, model.Agency, propertyNumber, uploadedFile.InputStream);
					foreach (var propertyInfo in result.Added.ToArray())
					{
						try
						{
							if (propertyInfo.Zone == null)
							{
								result.AddSkippedProperty(propertyInfo, "No Zone");
								continue;
							}
							using (var tx = _transactionFactory.BeginTransaction("Import Properties - Added"))
							{
								_repository.Save(propertyInfo);
								tx.Commit();
								propertyNumber++;
							}
						}
						catch (Exception ex)
						{
							result.AddSkippedProperty(propertyInfo, ex.ToString());
						}
					}
					foreach (var propertyInfo in result.Updated)
					{
						using (var tx = _transactionFactory.BeginTransaction("Import Properties - Updated"))
						{
							_repository.Save(propertyInfo);
							tx.Commit();
						}
					}
					foreach (var propertyInfo in result.Cancelled)
					{
						using (var tx = _transactionFactory.BeginTransaction("Import Properties - Cancelled"))
						{
							// Need to find a reference to the property if it already exists
							var p = _propertyRepository.GetPropertyByPropertyNumberAndAgency(propertyInfo.PropertyNumber, propertyInfo.Agency);

							// if it already exists - update the cancellation status
							if (p != null)
							{
								// Add notes
								p.IsCancelled = true;
								p.CancellationDate = propertyInfo.CancellationDate;
								p.CancellationNotes = propertyInfo.CancellationNotes;
								// Save
								_repository.Save(p);
							}
							else
							{
								_repository.Save(propertyInfo);
							}

							tx.Commit();
						}
					}

					ShowInfoMessage("Success", "Import completed - see import log");
					return GetPropertyImportLog(result);
				}
				catch (OleDbException ex)
				{
					ShowErrorMessage("Import Error", "File format is invalid.  Please contact the system administrator to investigate.");
					return RedirectToAction("Index");
				}
				//catch (Exception ex)
				//{
				//    ShowErrorMessage("Import Error", "There was an error trying to import the selected file.  Please contact the system administrator to investigate the cause.");
				//    return RedirectToAction("Index");
				//}
				
			}
			else if (uploadedFile == null)
			{
				ModelState.AddModelError("UploadedFile", "Please select a file to import.");
			}

			return View(model);
		}

		[HttpPost]
		public JsonResult ClearDatabase()
		{
			var success = _propertyRepository.ClearDatabase();

			return Json(new { success });
		}

		private FileStreamResult GetPropertyImportLog(PropertyImportResult propertyImportResult)
		{
			var result = new List<string>();
			result.Add(string.Format("{0} properties added", propertyImportResult.Added.Count()));
			result.AddRange(propertyImportResult.AddedText.Select(val => string.Format("Added: {0}", val)));

			result.Add(string.Format("{0} properties updated", propertyImportResult.Updated.Count()));
			result.AddRange(propertyImportResult.UpdatedText.Select(val => string.Format("Updated: {0}", val)));
			
			result.Add(string.Format("{0} properties matched", propertyImportResult.Matched.Count()));
			result.AddRange(propertyImportResult.MatchedText.Select(val => string.Format("Matched: {0}", val)));
			
			result.Add(string.Format("{0} properties skipped", propertyImportResult.SkippedText.Count()));
			result.AddRange(propertyImportResult.SkippedText.Select(val => string.Format("Skipped: {0}", val)));

			result.Add(string.Format("{0} properties cancelled", propertyImportResult.Cancelled.Count()));
			result.AddRange(propertyImportResult.Cancelled.Select(val => string.Format("Cancelled: {0}", val)));

			byte[] byteArray = Encoding.ASCII.GetBytes(string.Join(System.Environment.NewLine, result));
			var stream = new MemoryStream(byteArray);
			return File(stream, "text/plain", "import-log.txt");
		}

		private static string GetIndexedValue(string searchString, int index, string delimiter)
		{
			var results = searchString.Split(delimiter.ToCharArray());
			if (index < results.Length)
			{
				return results[index].Trim();
			}
			else
			{
				return string.Empty;
			}
		}

		public PropertyImportResult GetImportProperties(ImportType importType, ImportFormat importFormat, Model.Agency agency, int seedPropertyNumber, Stream stream)
		{
			var propertyImportResult = new PropertyImportResult();
			
			// Legacy - Import Only
			if(importFormat.Equals(ImportFormat.Legacy))
			{
				if(importType.Equals(ImportType.NewProperties))
				{
					ProcessLegacyNew(agency, stream, propertyImportResult);
				}
			}
			
			// Console
			if(importFormat.Equals(ImportFormat.Console))
			{
				var filePath = SaveStreamToFile(stream);

				// Updates to existing properties
				if(importType.Equals(ImportType.UpdateProperties))
				{
					propertyImportResult =
						_consoleImporter.UpdateProperties(
							string.Format(ApplicationConfig.Current.ImportConnectionString, filePath), agency);
				}
				// Import new properties
				else if (importType.Equals(ImportType.NewProperties))
				{
					propertyImportResult =
						_consoleImporter.ImportProperties(
							string.Format(ApplicationConfig.Current.ImportConnectionString, filePath), agency);
				}
			}

			// Console 2007
			if (importFormat.Equals(ImportFormat.Console2007))
			{
				var filePath = SaveStreamToFile(stream);

				// Updates to existing properties
				if (importType.Equals(ImportType.UpdateProperties))
				{
					propertyImportResult = _console2007Importer.UpdateProperties(
						string.Format(ApplicationConfig.Current.ImportConnectionString, filePath),
						_repository.GetReference<State>(ApplicationConfig.Current.DefaultStateId),
						agency);
				}
				// Import new properties
				else if (importType.Equals(ImportType.NewProperties))
				{
					propertyImportResult = _console2007Importer.ImportProperties(
						string.Format(ApplicationConfig.Current.ImportConnectionString, filePath),
						_repository.GetReference<State>(ApplicationConfig.Current.DefaultStateId),
						agency);
				}
			}

			return propertyImportResult;
		}

		private void ProcessLegacyNew(Model.Agency agency, Stream stream, PropertyImportResult propertyImportResult)
		{
			var dataSet = LegacyToDataSet(stream);

			foreach (DataRow row in dataSet.Tables["PropertyInfo"].Rows)
			{
				var propertyInfo = new Model.PropertyInfo();

				propertyInfo.JobType = (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged;

				propertyInfo.PrivateLandlordAgency = _agencyRepository.Get(_agencyRepository.GetPrivateLandlordsID());// RJC Hot fix. This value needs to contain something even when its not used. in order for validity of the data.


				propertyInfo.Agency = agency;
				var propertyManagers = (from m in agency.ActivePropertyManagers
									   where m.Name.Equals(row["Property Manager"])
									   select m);

				if (propertyManagers.Count() > 0)
				{
					var p = (from pm in propertyManagers
							 where pm.Name.Equals(row["Property Manager"].ToString())
							 select pm).FirstOrDefault() ?? propertyManagers.FirstOrDefault();

					propertyInfo.PropertyManager = p;
				}
			  
				if (row["Property ID Code"].Equals(DBNull.Value) || row["Street Name"].Equals(string.Empty))
				{
					propertyImportResult.AddSkipped(row["Occupant Name"].ToString(), row["Property Number"].ToString(), row["Street Name"].ToString(), row["Suburb"], row["Post Code"], " (Invalid Data)");
					continue;
				}

				propertyInfo.PropertyNumber = Convert.ToInt32(row["Property ID Code"]);

				var propertyAddressNumber = row["Property Number"].ToString().Trim().Split("/".ToCharArray());
				if (propertyAddressNumber.Length > 1)
				{
					propertyInfo.UnitShopNumber = propertyAddressNumber[0];
					propertyInfo.StreetNumber = propertyAddressNumber[1];
				}
				else
				{
					propertyInfo.StreetNumber = propertyAddressNumber[0];
				}
				propertyInfo.StreetName = row["Street Name"].ToString().Trim();
				propertyInfo.KeyNumber = row["Key Number"].ToString().Trim();

				AssignSuburb(row["Suburb"].ToString(), row["Post Code"].ToString().Trim(), propertyInfo);

				if (String.IsNullOrEmpty(row["State"].ToString()))
				{
					_repository.GetReference<State>(ApplicationConfig.Current.DefaultStateId);
				}
				else
				{
					propertyInfo.State = row["State"] == DBNull.Value
											 ? _repository.GetReference<State>(ApplicationConfig.Current.DefaultStateId)
											 : _stateRepository.GetStateByName(row["State"].ToString());
				}

				propertyInfo.OccupantName = row["Occupant Name"].ToString().Trim();
				propertyInfo.OccupantEmail = row["Email"].ToString().Trim();

				ParseContactEntry(row, propertyInfo);
				propertyInfo.ApplyUpdatedContactDetails();

				DataRow service = null;
				foreach (DataRow serviceRow in dataSet.Tables["ServiceSheet"].Rows)
				{
					if (propertyInfo.PropertyNumber.ToString().Equals(serviceRow["Property ID Code"].ToString()))
					{
						service = serviceRow;
						break;
					}
				}

				if (service != null)
				{
					var parsedServiceDate = new DateTime();
					if (DateTime.TryParse(service["Last Service Date"].ToString(), out parsedServiceDate))
					{
						propertyInfo.LastServicedDate = parsedServiceDate;
					}
					

					var serviceBooking = new Model.Booking(propertyInfo);

					var technicianName = service["Technician"].ToString();
					if (!technicianName.Equals(string.Empty))
					{
						var technician = _technicianRepository.GetTechnicianByName(technicianName.ToLower());
						if (technician != null)
						{
							serviceBooking.Technician = technician;
						}
					}

					serviceBooking.Date = propertyInfo.LastServicedDate;
					var serviceSheet = new Model.ServiceSheet(serviceBooking, false);
					serviceBooking.AssignServiceSheet(serviceSheet);
					serviceSheet.Notes = service["Service Notes"].ToString();
					

					if (service["Left Card"].ToString().Equals("Y"))
					{
						serviceSheet.IsCardLeft = true;
					}
					if (service["Signature"].ToString().Equals("Y"))
					{
						serviceSheet.HasSignature = true;
					}
					serviceSheet.IsCompleted = true;

					var detectors = service["Detector Type"].ToString().Replace(" ", string.Empty).Split(",".ToCharArray());
					for (var j = 0; j < detectors.Length; j++)
					{
						var detector = new Detector(propertyInfo);
						var expiryYear = GetIndexedValue(service["Expiry Date"].ToString(), j, ",");
						if (expiryYear.Equals(string.Empty))
						{
							expiryYear = service["Expiry Date"].ToString().Trim();
						}
						var newExpiryYear = GetIndexedValue(service["New Expiry Date"].ToString(), j, ",");
						if (newExpiryYear.Equals(string.Empty))
						{
							newExpiryYear = service["New Expiry Date"].ToString().Trim();
						}
						var detectorExpiryYear = expiryYear.Equals(string.Empty) || expiryYear.Equals("-") || expiryYear.Equals("Missing") || expiryYear.Equals("Faulty") || expiryYear.Equals("Expired") ? newExpiryYear : expiryYear;
						if (!(detectorExpiryYear.Equals(string.Empty) || detectorExpiryYear.Equals("-")))
						{
							int parsedExpiryYear;
							if (int.TryParse(detectorExpiryYear, out parsedExpiryYear))
							{
								detector.ExpiryYear = parsedExpiryYear;
							}
						}

						detector.Manufacturer = "Unknown";
						detector.Location = "Unknown";
						switch (detectors[j])
						{
							case "M":
								detector.DetectorType = _repository.GetReference<DetectorType>((int)SystemDetectorType.Mains);
								break;
							case "MR":
								detector.DetectorType = _repository.GetReference<DetectorType>((int)SystemDetectorType.MainsRecharge);
								break;
							case "S":
								detector.DetectorType = _repository.GetReference<DetectorType>((int)SystemDetectorType.Security);
								break;
							case "DR":
								detector.DetectorType = _repository.GetReference<DetectorType>((int)SystemDetectorType.DetachableRecharge);
								break;
							default:
								detector.DetectorType = _repository.GetReference<DetectorType>((int)SystemDetectorType.Detachable);
								break;
						}

						int newParsedExpiryYear;

						//if (int.TryParse(newExpiryYear, out newParsedExpiryYear))
						//{
						//    detector.NewExpiryYear = newParsedExpiryYear;
						//}

						propertyInfo.AddDetector(detector);
						var serviceSheetItem = new Model.ServiceSheetItem(serviceSheet, detector);
						if (!(newExpiryYear.Equals(string.Empty) || newExpiryYear.Equals("-")))
						{
							if (int.TryParse(newExpiryYear, out newParsedExpiryYear))
							{
								serviceSheetItem.NewExpiryYear = newParsedExpiryYear;
							}
						}
						if (!(expiryYear.Equals(string.Empty) || expiryYear.Equals("-")))
						{
							if (int.TryParse(expiryYear, out newParsedExpiryYear))
							{
								serviceSheetItem.ExpiryYear = newParsedExpiryYear;
							}
							
						}
						if (serviceSheetItem.DetectorType.Equals(SystemDetectorType.MainsRecharge) && !serviceSheetItem.NewExpiryYear.HasValue)
						{
							serviceSheetItem.IsBatteryReplaced = false;
						}

						if (serviceSheetItem.DetectorType.Equals(SystemDetectorType.Mains) || serviceSheetItem.DetectorType.Equals(SystemDetectorType.MainsRecharge))
						{
							if (serviceSheetItem.NewExpiryYear.HasValue)
							{
								serviceSheetItem.IsReplacedByElectrician = true;
							}
						}
						serviceSheet.AddServiceSheetItem(serviceSheetItem);

						if (serviceSheet.ShouldSheetBeMarkedAsElectricianRequired)
						{
							serviceSheet.IsElectricianRequired = true;
						}

					}

					propertyInfo.AddBooking(serviceBooking);
					propertyInfo.ElectricalWorkStatus = ElectricalWorkStatus.ElectricianRequired;
					serviceSheet.Consolidate(serviceSheet.IsElectricianRequired);
					
					if (!serviceSheet.HasMainsExpired)
					{
						serviceBooking.IsInvoiced = true;
						serviceSheet.IsCompleted = true;
						propertyInfo.ElectricalWorkStatus = ElectricalWorkStatus.NoElectricianRequired;
						propertyInfo.UpdateExpiryYears();
					}
					propertyInfo.InspectionStatus = InspectionStatus.ReadyForService;
				}

				foreach (DataRow bookingRow in dataSet.Tables["Booking"].Rows)
				{
					if (propertyInfo.PropertyNumber.ToString().Equals(bookingRow["Property ID Code"].ToString()))
					{
						var bookingDate = new DateTime();
						if (DateTime.TryParse(bookingRow["Booking Date"].ToString(), out bookingDate))
						{
							var booking = new Model.Booking(propertyInfo) {Date = bookingDate};

							// Booking Time
							// The booking times are in the following format: 12:00-12:30
							try
							{
								var bookingTime = bookingRow["Booking Time"].ToString().Trim();
								if (!string.IsNullOrEmpty(bookingTime))
								{
									var startTime = bookingTime.Split(Convert.ToChar("-"))[0];
									var endTime = bookingTime.Split(Convert.ToChar("-"))[1];
									TimeSpan duration = new TimeSpan(
															Convert.ToInt16(endTime.Split(Convert.ToChar(":"))[0]),
															Convert.ToInt16(endTime.Split(Convert.ToChar(":"))[1]),
															0) -
														new TimeSpan(
															Convert.ToInt16(startTime.Split(Convert.ToChar(":"))[0]),
															Convert.ToInt16(startTime.Split(Convert.ToChar(":"))[1]),
															0);

									booking.Time = new DateTime().AddHours(
										Convert.ToDouble(startTime.Split(Convert.ToChar(":"))[0]))
										.AddMinutes(Convert.ToInt16(startTime.Split(Convert.ToChar(":"))[1]));

									booking.Duration = (int) duration.TotalMinutes;

								}
							}
							catch(Exception ex)
							{
								propertyImportResult.AddSkipped(row["Occupant Name"].ToString(), row["Property Number"].ToString(), row["Street Name"].ToString(), row["Suburb"], row["Post Code"], " (Invalid Booking Data)");
								continue;
							}
							booking.Notes = bookingRow["Comments"].ToString();
							booking.KeyNumber = propertyInfo.KeyNumber;
							booking.Consolidate();
							propertyInfo.AddBooking(booking);
						}
						break;
					}
				}

				propertyImportResult.Added.Add(propertyInfo);
			}

			foreach (DataRow row in dataSet.Tables["Cancelled"].Rows)
			{
				// Check if the property exists in the database
				// If it exists - add a cancellation record, else add a property
				// and a cancellation record
				var propertyInfo = new Model.PropertyInfo();
				propertyInfo.JobType = (int)DetectorInspector.Areas.PropertyInfo.ViewModels.PropertyInfoViewModel.JobTypeTypeEnum.AgencyManaged;

				propertyInfo.Agency = agency;
			   
				if (row["Property ID Code"].Equals(DBNull.Value) || row["Street Name"].Equals(string.Empty))
				{
					break;
				}
			   
				propertyInfo.PropertyNumber = Convert.ToInt32(row["Property ID Code"]);

				var propertyAddressNumber = row["Property Number"].ToString().Trim().Split("/".ToCharArray());
				if (propertyAddressNumber.Length > 1)
				{
					propertyInfo.UnitShopNumber = propertyAddressNumber[0];
					propertyInfo.StreetNumber = propertyAddressNumber[1];
				}
				else
				{
					propertyInfo.StreetNumber = propertyAddressNumber[0];
				}

				propertyInfo.StreetName = row["Street Name"].ToString().Trim();

				// There are no post codes and therefore we are not able 
				// to accurately assign a post code here
				propertyInfo.Suburb = row["Suburb"].ToString();

				propertyInfo.State = _repository.GetReference<State>(ApplicationConfig.Current.DefaultStateId);

				// Add a cancellation record
				propertyInfo.IsCancelled = true;
				propertyInfo.CancellationDate = DateTime.Today;
				propertyInfo.CancellationNotes = row["Cancellation Notes"].ToString();

				propertyImportResult.Cancelled.Add(propertyInfo);
			}
		}

		private void AssignSuburb(string suburbName, string postCode, Model.PropertyInfo propertyInfo)
		{
			suburbName = suburbName.Replace(",", string.Empty).Replace(".", string.Empty).Trim();

			var suburb = _suburbRepository.GetByNameAndPostCode(suburbName, postCode);

			if (suburb != null)
			{
				propertyInfo.Suburb = suburb.Name;
				propertyInfo.Zone = suburb.Zone;
				propertyInfo.PostCode = suburb.PostCode;
			}
		}

		private void ParseContactEntry(DataRow row, Model.PropertyInfo propertyInfo)
		{

			var homePhone = row["Tenant Phone (Home)"].ToString().Replace("&", ",").Split(",".ToCharArray());
			foreach(var contactNumber in homePhone)
			{
				string cleanNumber;
				ContactNumberType contactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Home);
				ContactNumberType newContactType;
				GetContactNumber(contactNumber, contactType, out cleanNumber, out newContactType);
				if (!cleanNumber.Equals(string.Empty))
				{
					var homeContact = new ContactEntry(propertyInfo)
										  {
											  ContactNumber = cleanNumber,
											  ContactNumberType = contactType
										  };
					propertyInfo.AddContactEntry(homeContact);
				}
			}

			var mobilePhone = row["Tenant Phone (Mobile)"].ToString().Replace("&", ",").Split(",".ToCharArray());
			foreach (var contactNumber in mobilePhone)
			{
				string cleanNumber;
				ContactNumberType contactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Mobile);
				ContactNumberType newContactType;
				GetContactNumber(contactNumber, contactType, out cleanNumber, out newContactType);
				if (!cleanNumber.Equals(string.Empty))
				{
					var mobileContact = new ContactEntry(propertyInfo)
											{
												ContactNumber = cleanNumber,
												ContactNumberType = contactType
											};
					propertyInfo.AddContactEntry(mobileContact);
				}
			}

			var businessPhone = row["Tenant Phone (Business)"].ToString().Replace("&", ",").Split(",".ToCharArray());
			foreach (var contactNumber in businessPhone)
			{
				string cleanNumber;
				ContactNumberType contactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Business);
				ContactNumberType newContactType;
				GetContactNumber(contactNumber, contactType, out cleanNumber, out newContactType);
				if (!cleanNumber.Equals(string.Empty))
				{
					var businessContact = new ContactEntry(propertyInfo)
											  {
												  ContactNumber = cleanNumber,
												  ContactNumberType = newContactType
											  };
					propertyInfo.AddContactEntry(businessContact);
				}
			}

			var otherPhone = row["Another Phone"].ToString().Replace("&", ",").Split(",".ToCharArray());
			foreach (var contactNumber in otherPhone)
			{
				string cleanNumber;
				ContactNumberType contactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Other);
				ContactNumberType newContactType;
				GetContactNumber(contactNumber, contactType, out cleanNumber, out newContactType);
				if (!cleanNumber.Equals(string.Empty))
				{
					var otherContact = new ContactEntry(propertyInfo)
										   {
											   ContactNumber = cleanNumber,
											   ContactNumberType = newContactType
										   };
					propertyInfo.AddContactEntry(otherContact);
				}
			}
		}

		private void GetContactNumber(string contactNumber, ContactNumberType contactType, out string cleanNumber, out ContactNumberType newContactType)
		{
			cleanNumber = contactNumber.Trim().Replace("B:", string.Empty).Replace("-", string.Empty).Trim();
			newContactType = contactType;
			if (cleanNumber.StartsWith("04"))
			{
				newContactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Mobile);
			}
			else
			{
				if(contactType.Equals(SystemContactNumberType.Mobile))
				{
					newContactType = _repository.GetReference<ContactNumberType>((int)SystemContactNumberType.Other);
				}
			}
		}

		string SaveStreamToFile(Stream stream)
		{   
			var filePath = Path.Combine(ApplicationConfig.Current.SystemBasePath, "write", Guid.NewGuid().ToString());

			if (stream.Length == 0)
			{
				return string.Empty;
			}

			// Create a FileStream object to write a stream to a file
			using (FileStream fileStream = System.IO.File.Create(filePath, (int)stream.Length))
			{
				// Fill the bytes[] array with the stream data
				byte[] bytesInStream = new byte[stream.Length];
				stream.Read(bytesInStream, 0, (int)bytesInStream.Length);

				// Use FileStream object to write to the specified file
				fileStream.Write(bytesInStream, 0, bytesInStream.Length);
			 }
			return filePath;
		}


		private DataSet LegacyToDataSet(Stream stream)
		{
			var ds = new DataSet();
			var filePath = SaveStreamToFile(stream);
			OleDbConnection con = new OleDbConnection(string.Format(ApplicationConfig.Current.ImportConnectionString, filePath));
			OleDbDataAdapter da = new OleDbDataAdapter("select * from [Property Info Sheet$];", con);
			DataTable dt = new DataTable("PropertyInfo");
			da.Fill(dt);
			ds.Tables.Add(dt);

			da = new OleDbDataAdapter("select * from [Property Service Sheet$];", con);
			dt = new DataTable("ServiceSheet");
			da.Fill(dt);
			ds.Tables.Add(dt);


			da = new OleDbDataAdapter("select * from [Cancelled Properties$];", con);
			dt = new DataTable("Cancelled");
			da.Fill(dt);
			ds.Tables.Add(dt);


			da = new OleDbDataAdapter("select * from [Need To Service$];", con);
			dt = new DataTable("Booking");
			da.Fill(dt);

			ds.Tables.Add(dt);

			con.Close();
			da.Dispose();
			return ds;
		}

		private string CleanUpMobileNumber(string mobileNumber)
		{
			return Regex.Replace(mobileNumber, "[^0-9]", "");

		}
	}



	enum ImportTable
	{
		PropertyInfo = 0,
		ServiceSheet,
		Booking,
		Cancelled
	}
}
