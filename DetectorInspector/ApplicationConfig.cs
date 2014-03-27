using System;
using System.Configuration;

namespace DetectorInspector
{
	public class ApplicationConfig : ConfigurationSection
	{
		public static ApplicationConfig Current
		{
			get
			{
				return (ApplicationConfig)ConfigurationManager.GetSection("kiandra");
			}
		}

		[ConfigurationProperty("mvcFileExtension", DefaultValue = "")]
		public string MvcFileExtension
		{
			get { return (string)this["mvcFileExtension"]; }
		}

		[ConfigurationProperty("notificationSenderName", IsRequired = true)]
		public string NotificationSenderName
		{
			get { return (string)this["notificationSenderName"]; }
		}

		[ConfigurationProperty("notificationSenderEmail", IsRequired = true)]
		public string NotificationSenderEmail
		{
			get { return (string)this["notificationSenderEmail"]; }
		}

		[ConfigurationProperty("systemBaseUrl", IsRequired = true)]
		public string SystemBaseUrl
		{
			get { return (string)this["systemBaseUrl"]; }
		}

        [ConfigurationProperty("systemBasePath", IsRequired = true)]
        public string SystemBasePath
        {
            get { return (string)this["systemBasePath"]; }
        }

        /// <summary>
        /// Maximim file upload allowance. Default to 10 mb.
        /// </summary>
        [ConfigurationProperty("maxFileUploadBytes", DefaultValue = 10485760)]
        public int MaxFileUploadBytes
        {
            get { return (int)this["maxFileUploadBytes"]; }
        }

        [ConfigurationProperty("allowableUploadFileExtensions")]
        public string AllowableUploadFileExtensions
        {
            get { return (string)this["allowableUploadFileExtensions"]; }
        }


        [ConfigurationProperty("importConnectionString")]
        public string ImportConnectionString
        {
            get { return (string)this["importConnectionString"]; }
        }

        /// <summary>
        /// GUID for the system account. This will be the account that new users are registered under
        /// </summary>
        [ConfigurationProperty("systemAccountId", IsRequired = true)]
        public Guid SystemAccountId
        {
            get { return (Guid)this["systemAccountId"]; }
        }


        /// <summary>
        /// Default stateId
        /// </summary>
        [ConfigurationProperty("defaultStateId", IsRequired = true)]
        public int DefaultStateId
        {
            get { return (int)this["defaultStateId"]; }
        }

        [ConfigurationProperty("gstPercentage", IsRequired = true)]
	    public decimal GstPercentage
	    {
            get { return (decimal) this["gstPercentage"]; }
	    }

	    [ConfigurationProperty("environment")]
	    public string Environment
	    {
            get { return (string) this["environment"]; }
	    }

	}
}
