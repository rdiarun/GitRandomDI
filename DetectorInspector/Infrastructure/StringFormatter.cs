using System;
using System.Text.RegularExpressions;

namespace DetectorInspector.Infrastructure
{
    /// <summary>
    /// Provides common string formats for common data types. Useful for formatting 
    /// data that will be presented to the user.
    /// </summary>
    public static class StringFormatter
    {
		private const int BytesPerMegabyte = 1048576;

        private static readonly DateTime NullDate = new DateTime(1900, 1, 1);

        public static string BooleanToYesNo(bool? value)
        {
            var result = "No";

            if (value.HasValue)
            {
                result = value.Value ? "Yes" : "No";
            }

            return result;
        }

        public static string CleanUpMobileNumber(string mobileNumber)
        {
            return Regex.Replace(mobileNumber, "[^0-9]", "");

        }

        public static string UtcToLocalDateTime(DateTime? value)
        {
            if (value.HasValue)
            {
                return value.Value.ToLocalTime().ToString("g");
            }

            return string.Empty;
        }

        public static string UtcToLocalDate(DateTime? value)
        {
            if (value.HasValue)
            {
                return value.Value.ToLocalTime().ToString("dd/MM/yyyy");
            }

            return string.Empty;
        }

        public static string LocalDateTime(DateTime? value)
        {
            if (value.HasValue)
            {
                return value.Value.ToString("g");
            }

            return string.Empty;
        }

        public static string LocalTime(DateTime? value)
        {
            if (value.HasValue)
            {
                return value.Value.ToString("hh:mm tt");
            }

            return string.Empty;
        }

        public static string LocalDate(DateTime? value)
        {
            if (value.HasValue)
            {
                return value.Value.ToString("dd/MM/yyyy");
            }

            return string.Empty;
        }

        public static string Currency(Decimal? value)
        {
            var result = string.Empty;

            if (value.HasValue)
            {
                result = value.Value.ToString("C0");
            }

            return result;
        }

        public static string Megabytes(int bytes)
        {
            string result = "0 MB";

            if (bytes > 0)
            {
				result = string.Format("{0} MB", (bytes / BytesPerMegabyte).ToString("N2"));
            }

            return result;
        }
	}
}
