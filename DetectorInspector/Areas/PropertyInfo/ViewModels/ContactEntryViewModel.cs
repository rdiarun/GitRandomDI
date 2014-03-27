using System;
using System.Linq;
using System.Web.Mvc;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using System.Collections.Generic;
using DetectorInspector.Infrastructure;

namespace DetectorInspector.Areas.PropertyInfo.ViewModels
{
    public class ContactEntryViewModel : ViewModel
    {

        public Model.ContactEntry ContactEntry { get; private set; }
        public Model.PropertyInfo PropertyInfo { get; private set; }
        public SelectList ContactNumberTypes { get; private set; }
        
        public bool IsCreate()
        {
            return ContactEntry.Id == 0;
        }

        public ContactEntryViewModel(IRepository repository, Model.PropertyInfo propertyInfo, int id)
        {
            PropertyInfo = propertyInfo;
            if (id!=0)
			{
                ContactEntry = repository.Get<ContactEntry>(id);
			}
			else
			{
                ContactEntry = new ContactEntry(propertyInfo);
			}

            int? contactNumberTypeId = null;
            if (ContactEntry.ContactNumberType != null)
            {
                contactNumberTypeId = ContactEntry.ContactNumberType.Id;
            }
            ContactNumberTypes = new SelectList(repository.GetAllForList<ContactNumberType>(), "Id", "Name", contactNumberTypeId.HasValue?contactNumberTypeId.Value.ToString():string.Empty);

		}
    }
}
