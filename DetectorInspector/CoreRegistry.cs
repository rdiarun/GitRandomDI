using System;
using System.Web;
using System.Web.Mvc;
using Kiandra.Data;
using Kiandra.Data.NHibernateClient;
using Kiandra.Entities.Validation;
using Kiandra.Entities.Validation.Castle;
using Kiandra.Web.Mvc.Security;
using DetectorInspector.Common.Notifications;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using Microsoft.Practices.ServiceLocation;
using NHibernate;
using StructureMap.Configuration.DSL;

namespace DetectorInspector
{
	public class CoreRegistry : Registry
	{
		public CoreRegistry()
		{
			var config = ApplicationConfig.Current;

			ForRequestedType<IInterceptor>()
				.TheDefault.Is.ConstructedBy(() =>
					new AuditingInterceptor<Audit, AuditAction, Guid>("DetectorInspector.Model", GetUserID)
				);

			ForRequestedType<IAuthenticationProvider>()
				.TheDefaultIsConcreteType<FormsAuthenticationProvider>()
				.AsSingletons();

			ForRequestedType<IMembershipService>()
				.TheDefaultIsConcreteType<AspNetMembershipService>()
				.AsSingletons();

			ForRequestedType<ITransactionFactory>()
				.TheDefaultIsConcreteType<NHibernateTransactionFactory>();

            //ForRequestedType<IModelValidator>()
            //    .TheDefaultIsConcreteType<CastleModelValidator>();

			ForRequestedType<IModelMetadataProvider>()
				.TheDefault.IsThis(new CachedModelMetadataProvider("DetectorInspector.Model", "DetectorInspector.Model"));

			ForRequestedType<INotificationService>()
				.AsSingletons()
				.TheDefault.Is.OfConcreteType<NotificationService>()
				.WithCtorArg("senderEmailAddress").EqualTo(config.NotificationSenderEmail)
				.WithCtorArg("senderName").EqualTo(config.NotificationSenderName)
				.WithCtorArg("systemBaseUrl").EqualTo(config.SystemBaseUrl)
                .WithCtorArg("systemBasePath").EqualTo(config.SystemBasePath);

			Scan(o =>
			{
				o.AssemblyContainingType<INotificationService>();
				o.ExcludeType<INotificationService>();
				o.LookForRegistries();
			});

			Scan(o =>
			{
				o.TheCallingAssembly();
				o.IncludeNamespace("DetectorInspector.ModelBinders");
				o.AddAllTypesOf<IModelBinder>();
			});

			Scan(o =>
			{
				o.TheCallingAssembly();
				o.AddAllTypesOf<IController>();
			});

			Scan(o =>
			{
				o.Assembly("DetectorInspector.Data");
				o.WithDefaultConventions();
			});
		}

		private readonly Func<Guid> GetUserID = new Func<Guid>(() =>
		{
			var membershipService = ServiceLocator.Current.GetInstance<IMembershipService>();

            return membershipService.GetUserIdForUserName(HttpContext.Current.User.Identity.Name) ?? ApplicationConfig.Current.SystemAccountId;
		});
	}
}
