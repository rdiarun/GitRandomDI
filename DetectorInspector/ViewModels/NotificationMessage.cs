using System;

namespace DetectorInspector.ViewModels
{
	public class NotificationMessage
	{
		public NotificationMessageType MessageType { get; set; }
		public string Title { get; set; }
		public string Body { get; set; }
	}
}
