using System.Collections.Generic;
using DetectorInspector.Data;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;

namespace DetectorInspector.Areas.ServiceSheet.ViewModels
{
    public class ServiceSheetViewModel : ViewModel
    {
        public IEnumerable<DetectorType> DetectorTypes { get; private set; }
        public Model.Booking Booking { get; private set; }
        public Model.ServiceSheet ServiceSheet { get; private set; }
        
        public bool IsCreate()
        {
            return ServiceSheet.Id == 0;
        }

        public ServiceSheetViewModel(IRepository repository, Model.Booking booking, int id)
        {
            Booking = booking;
            ServiceSheet = id!=0 ? repository.Get<Model.ServiceSheet>(id) : new Model.ServiceSheet(booking, false);
            DetectorTypes = repository.GetAllForList<DetectorType>();
		}
    }
}
