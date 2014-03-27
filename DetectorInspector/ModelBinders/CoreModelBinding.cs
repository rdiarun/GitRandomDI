using System;
using System.Reflection;
using System.Web.Mvc;
using Kiandra.Entities.Validation;
using Kiandra.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using scm = System.ComponentModel;
using Kiandra.Entities;
using System.Linq;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.ComponentModel;
using Kiandra.Web.Mvc.Security;
using System.Web.Security;
using System.Text.RegularExpressions;

namespace DetectorInspector
{
	public class CoreModelBinder : DefaultModelBinder
	{		
		private MethodInfo _bindEntityMethodInfo;
		private MethodInfo _bindEntityCollectionMethodInfo;
		private MethodInfo _bindEnumCollectionMethodInfo;

		private static readonly BindModelAttribute _bindModelAttribute = new BindModelAttribute();

		public CoreModelBinder(IRepository referenceDataRepository,
                                IMembershipService membershipService)
		{
            Repository = referenceDataRepository;
            MembershipService = membershipService;

			_bindEntityMethodInfo = 
				GetType().GetMethod("BindEntity", BindingFlags.Instance | BindingFlags.NonPublic);

			_bindEntityCollectionMethodInfo =
				GetType().GetMethod("BindEntityCollection", BindingFlags.Instance | BindingFlags.NonPublic);

			_bindEnumCollectionMethodInfo =
				GetType().GetMethod("BindEnumCollection", BindingFlags.Instance | BindingFlags.NonPublic);
		}

        protected IRepository Repository { get; private set; }

        protected IMembershipService MembershipService { get; private set; }

        protected void ValidateModelAttributes(ControllerContext controllerContext, ModelBindingContext bindingContext)
        {           
            Attribute attribute;

            //get properties to validate
            var properties = TypeDescriptor.GetProperties(bindingContext.Model);

            //loop through properties and check whether to validate
            foreach (PropertyDescriptor property in properties)
            {
                var propertyName =
                   DefaultModelBinder.CreateSubPropertyName(bindingContext.ModelName, property.Name);

                //check whether to validate property
                if (bindingContext.PropertyFilter(propertyName) && bindingContext.ModelState.IsValidField(propertyName))
                {

                    //try to get ValidatePasswordAttribute
                    attribute = property.Attributes[typeof(ValidateUniqueUsernameAttribute)];

                    if (attribute != null)
                    {
                        ValidateDuplicateUsername(controllerContext, bindingContext, propertyName);
                    }

                    //try to get ValidatePasswordAttribute
                    attribute = property.Attributes[typeof(ValidatePasswordAttribute)];

                    if (attribute != null)
                    {
                        ValidatePassword(controllerContext, bindingContext, propertyName, (ValidatePasswordAttribute)attribute); 
                    }
                }
            }
            
        }

        protected void ValidateDuplicateUsername(ControllerContext controllerContext, ModelBindingContext bindingContext, string fieldName)
        {
            var model = (UserProfile)bindingContext.Model;
            Guid? userId;

            //check if username exists
            userId = MembershipService.GetUserIdForUserName(model.UserName);

            //if userId found and the userId is not equal to user against the model
            if (userId.HasValue && userId.Value != Guid.Empty && userId.Value != model.Id)
            {
                bindingContext.ModelState.AddModelError(fieldName, "Username already exists");
            }
        }


        protected void ValidatePassword(ControllerContext controllerContext, ModelBindingContext bindingContext, string fieldName, ValidatePasswordAttribute attribute)
        {
            var password = bindingContext.ValueProvider.GetValue(fieldName).AttemptedValue;
            
            int minRequiredPasswordLength = attribute.MinRequiredPasswordLength.HasValue ? attribute.MinRequiredPasswordLength.Value :  Membership.MinRequiredPasswordLength;
            int minRequiredNonAlphanumericCharacters = attribute.MinRequiredNonAlphanumericCharacters.HasValue ? attribute.MinRequiredNonAlphanumericCharacters.Value : Membership.MinRequiredNonAlphanumericCharacters;
            
            //check password meets requirements
            if (!string.IsNullOrEmpty(password)
                && !CheckPasswordComplexity(password, minRequiredPasswordLength, minRequiredNonAlphanumericCharacters))
            {
                bindingContext.ModelState.AddModelError(fieldName, string.Format("Password must be at least {0} characters long and contain {1} non-alpha/numeric characters", Membership.MinRequiredPasswordLength, Membership.MinRequiredNonAlphanumericCharacters));
            }
        }

        protected bool CheckPasswordComplexity(string password, int minRequiredPasswordLength, int minRequiredNonAlphanumericCharacters)
        {
            int nonAlnumCount = 0;

            //check password length
            if (password.Length < Membership.MinRequiredPasswordLength)
            {
                return false;
            }

            //check characters are allowed
            if (!string.IsNullOrEmpty(Membership.PasswordStrengthRegularExpression)
                && !Regex.IsMatch(password, Membership.PasswordStrengthRegularExpression))
            {
                return false;
            }

            //check minimum number of non alpha characters
            for (int i = 0; i < password.Length; i++)
            {
                if (!char.IsLetterOrDigit(password, i))
                {
                    nonAlnumCount++;
                }
            }

            if (nonAlnumCount < Membership.MinRequiredNonAlphanumericCharacters)
            {
                return false;
            }


            return true;
        }

		protected override void BindProperty(
			ControllerContext controllerContext, 
			ModelBindingContext bindingContext, 
			scm.PropertyDescriptor propertyDescriptor)
		{
			var bindableAttribute = propertyDescriptor.Attributes[typeof(BindModelAttribute)] as BindModelAttribute;
			var bindableCollectionAttribute = propertyDescriptor.Attributes[typeof(BindCollectionAttribute)] as BindCollectionAttribute;
			var bindableEnumCollectionAttribute = propertyDescriptor.Attributes[typeof(BindEnumCollectionAttribute)] as BindEnumCollectionAttribute;

			var isEntity = typeof(IEntity).IsAssignableFrom(propertyDescriptor.PropertyType);

			var propertyName =
				DefaultModelBinder.CreateSubPropertyName(bindingContext.ModelName, propertyDescriptor.Name);

			if (isEntity && bindableAttribute != null)
			{
				propertyName += ".Id";

				if (bindingContext.PropertyFilter(propertyName))
				{
					var genericMethodInfo = 
						_bindEntityMethodInfo.MakeGenericMethod(new Type[] { propertyDescriptor.PropertyType, bindableAttribute.KeyType });

					genericMethodInfo.Invoke(this, new object [] { controllerContext, bindingContext, propertyDescriptor, propertyName });
				}
			}
			else if (bindableCollectionAttribute != null)
			{
				if (bindingContext.PropertyFilter(propertyName))
				{
					var genericMethodInfo =
						_bindEntityCollectionMethodInfo.MakeGenericMethod(new Type[] { bindableCollectionAttribute.EntityType });

					genericMethodInfo.Invoke(this, new object[] { controllerContext, bindingContext, propertyDescriptor, propertyName });
				}
				else
				{
					base.BindProperty(controllerContext, bindingContext, propertyDescriptor);
				}
			}
			else if (bindableEnumCollectionAttribute != null)
			{
				if (bindingContext.PropertyFilter(propertyName))
				{
					var genericMethodInfo =
						_bindEnumCollectionMethodInfo.MakeGenericMethod(new Type[] { bindableEnumCollectionAttribute.EnumType });

					genericMethodInfo.Invoke(this, new object[] { controllerContext, bindingContext, propertyDescriptor, propertyName });
				}
				else
				{
					base.BindProperty(controllerContext, bindingContext, propertyDescriptor);
				}
			}
            else if (propertyDescriptor.PropertyType == typeof(Upload))
            {
                if (controllerContext.HttpContext.Request.Files.Count > 0)
                {
                    BindFileUpload(controllerContext, bindingContext, propertyDescriptor);
                }
                else
                {
                    base.BindProperty(controllerContext, bindingContext, propertyDescriptor);
                }
            }
			else
			{
				base.BindProperty(controllerContext, bindingContext, propertyDescriptor);
			}
		}

		protected void BindEntity<TEntity, TKey>(
			ControllerContext controllerContext, 
			ModelBindingContext bindingContext, 
			scm.PropertyDescriptor propertyDescriptor, 
			string subPropertyName)
			where TEntity : class, IEntity
			where TKey : struct
		{
			TKey? value = null;
			TEntity model = null;

			var valueProviderResult = bindingContext.ValueProvider.GetValue(subPropertyName);

			if (valueProviderResult != null)
			{
				value = (TKey?)valueProviderResult.ConvertTo(typeof(TKey?));

				if (value.HasValue)
				{
                    model = Repository.GetReference<TEntity, TKey>(value.Value);
				}
			}

			OnPropertyValidating(controllerContext, bindingContext, propertyDescriptor, value);
			
			propertyDescriptor.SetValue(bindingContext.Model, model);
		}

		protected void BindEntityCollection<TEntity>(
			ControllerContext controllerContext,
			ModelBindingContext bindingContext,
			scm.PropertyDescriptor propertyDescriptor,
			string subPropertyName)
			where TEntity : class, IEntity
		{
			var valueProviderResult = bindingContext.ValueProvider.GetValue(subPropertyName);

			IEnumerable<int> submittedEntityIds = new int[0];

			if (valueProviderResult != null && !string.IsNullOrEmpty(valueProviderResult.AttemptedValue))
			{
				submittedEntityIds = ((string[])valueProviderResult.RawValue).Select<string, int>(s => int.Parse(s));
			}

			var collectionProperty = (ICollection<TEntity>)propertyDescriptor.GetValue(bindingContext.Model);

			UpdateEntityCollection<TEntity>(submittedEntityIds, collectionProperty);				
		}

		protected void BindEnumCollection<TEnum>(
			ControllerContext controllerContext,
			ModelBindingContext bindingContext,
			scm.PropertyDescriptor propertyDescriptor,
			string subPropertyName)
			where TEnum : struct
		{
			var valueProviderResult = bindingContext.ValueProvider.GetValue(subPropertyName);

			IEnumerable<int> submittedEntityIds = new int[0];

			if (valueProviderResult != null)
			{
				submittedEntityIds = ((string[])valueProviderResult.RawValue).Select<string, int>(s => int.Parse(s));
			}

			var collectionProperty = (ICollection<TEnum>)propertyDescriptor.GetValue(bindingContext.Model);

			UpdateEnumCollection<TEnum>(submittedEntityIds, collectionProperty);
		}

		protected void UpdateEntityCollection<TModel>(
			IEnumerable<int> submittedEntityIds,
			ICollection<TModel> modelCollection)
			where TModel : class, IEntity
		{	
			var additions = new List<TModel>();
			var removals = new List<TModel>();

			// cater for the removals first.
			foreach (var modelItem in modelCollection)
			{
				if (submittedEntityIds.Count() == 0)
				{
					removals.Add(modelItem);
				}
				else
				{
					int? matchedItem = null;

					foreach (var entityId in submittedEntityIds)
					{
						if (entityId == (int)modelItem.Id)
						{
							matchedItem = entityId;
							break;
						}
					}

					if (matchedItem == null)
					{
						// save the items to be removed into another collection as we
						// can't modify the collection we are currently iterating over.
						removals.Add(modelItem);
					}
				}
			}

			foreach (var removedItem in removals)
			{
				modelCollection.Remove(removedItem);
			}

			// cater for the additions.
			foreach (var entityId in submittedEntityIds)
			{
				bool isMatched = false;

				foreach (var modelItem in modelCollection)
				{
					if (entityId == (int)modelItem.Id)
					{
						isMatched = true;
						break;
					}
				}

				if (!isMatched)
				{
                    var entity = Repository.GetReference<TModel>(entityId);

					additions.Add(entity);
				}
			}

			foreach (var addition in additions)
			{
				modelCollection.Add(addition);
			}
		}

		protected void UpdateEnumCollection<TEnum>(
			IEnumerable<int> submittedEntityIds,
			ICollection<TEnum> modelCollection)
			where TEnum : struct
		{
			var additions = new List<TEnum>();
			var removals = new List<TEnum>();

			// cater for the removals first.
			foreach (var modelItem in modelCollection)
			{
				if (submittedEntityIds.Count() == 0)
				{
					removals.Add(modelItem);
				}
				else
				{
					int? matchedItem = null;

					foreach (var entityId in submittedEntityIds)
					{
						if (((int)Enum.Parse(typeof(TEnum), modelItem.ToString())).Equals(entityId))
						{
							matchedItem = entityId;
							break;
						}
					}

					if (matchedItem == null)
					{
						// save the items to be removed into another collection as we
						// can't modify the collection we are currently iterating over.
						removals.Add(modelItem);
					}
				}
			}

			foreach (var removedItem in removals)
			{
				modelCollection.Remove(removedItem);
			}

			// cater for the additions.
			foreach (var entityId in submittedEntityIds)
			{
				bool isMatched = false;

				foreach (var modelItem in modelCollection)
				{
					if (((int)Enum.Parse(typeof(TEnum), modelItem.ToString())).Equals(entityId))
					{
						isMatched = true;
						break;
					}
				}

				if (!isMatched)
				{
					var entity = (TEnum)Enum.Parse(typeof(TEnum), Enum.GetName(typeof(TEnum), entityId));

					additions.Add(entity);
				}
			}

			foreach (var addition in additions)
			{
				modelCollection.Add(addition);
			}
		}

        protected void BindFileUpload(
            ControllerContext controllerContext,
            ModelBindingContext bindingContext,
            scm.PropertyDescriptor propertyDescriptor)
        {
			var propertyName = 
				DefaultModelBinder.CreateSubPropertyName(bindingContext.ModelName, propertyDescriptor.Name);
			
			Upload upload = null;
			var uploadedFile = controllerContext.HttpContext.Request.Files[propertyName];

            if (uploadedFile != null && uploadedFile.ContentLength > 0)
            {
                //Validate the upload
				if (IsFileUploadValid(bindingContext, uploadedFile, propertyName))
                {
                    //get existing upload against user
                    upload = (Upload)propertyDescriptor.GetValue(bindingContext.Model);

                    if (upload == null)
                    {
                        upload = new Upload();
                    }

                    //Load the binary data
                    upload.File = new byte[uploadedFile.ContentLength];
                    uploadedFile.InputStream.Read(upload.File, 0, uploadedFile.ContentLength);

                    //Load the other upload data
                    upload.OriginalFileName = Path.GetFileName(uploadedFile.FileName);
                    upload.Extension = upload.OriginalFileName.Substring(upload.OriginalFileName.LastIndexOf('.'));

                    upload.SizeInBytes = uploadedFile.ContentLength;
                }
            }

            propertyDescriptor.SetValue(bindingContext.Model, upload);
        }

        private bool IsFileUploadValid(ModelBindingContext bindingContext, HttpPostedFileBase uploadedFile, string propertyName)
        {
            bool isValid = false;

            if (uploadedFile.ContentLength > ApplicationConfig.Current.MaxFileUploadBytes)
            {
                bindingContext.ModelState.AddModelError(propertyName, propertyName + " exceeds file upload size limit");
            }
            else if (!IsFileExtensionValid(System.IO.Path.GetExtension(uploadedFile.FileName)))
            {
                bindingContext.ModelState.AddModelError(propertyName, propertyName + " is not an allowed file type");
            }
            else
            {
                isValid = true;
            }

            return isValid;
        }

        private bool IsFileExtensionValid(string fileExtension)
        {
            string values = ApplicationConfig.Current.AllowableUploadFileExtensions;

            if (!string.IsNullOrEmpty(values))
            {
                var list = values.ToLower().Split(new [] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries);
                
				return list.Contains(fileExtension.ToLower());
            }

            return false;
        }
	}
}
