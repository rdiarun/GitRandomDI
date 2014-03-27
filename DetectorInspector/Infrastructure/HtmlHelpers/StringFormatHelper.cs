using System;
using System.Web.Mvc;

namespace DetectorInspector.Infrastructure
{
    public static class StringFormatHelper
    {
        public static string BooleanToYesNo(this HtmlHelper helper, bool value)
        {
            return StringFormatter.BooleanToYesNo(value);
        }

        public static string UtcToLocalDateTime(this HtmlHelper helper, DateTime? value)
        {
            return StringFormatter.UtcToLocalDateTime(value);
        }

        public static string UtcToLocalDate(this HtmlHelper helper, DateTime? value)
        {
            return StringFormatter.UtcToLocalDate(value);
        }

        public static string LocalDateTime(this HtmlHelper helper, DateTime? value)
        {
            return StringFormatter.LocalDateTime(value);
        }

        public static string LocalDate(this HtmlHelper helper, DateTime? value)
        {
            return StringFormatter.LocalDate(value);
        }

        public static string Currency(this HtmlHelper helper, Decimal? value)
        {
            return StringFormatter.Currency(value);
        }
    }
}
