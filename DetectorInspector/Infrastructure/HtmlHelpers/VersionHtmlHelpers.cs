using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Reflection;

namespace DetectorInspector.Infrastructure
{
	public static class VersionHtmlHelpers
	{
		private static string _versionString = null;

		public static string Version(this HtmlHelper html)
		{
			if (_versionString == null)
			{
				_versionString = Assembly.GetExecutingAssembly().GetName().Version.ToString(4);

			}
			return _versionString;
		}
	}
}
