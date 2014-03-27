using System.Text;
using System.Data;

namespace DetectorInspector.Infrastructure
{
    public static class CsvExtensionMethods
    {
        public static string ToCSV(this DataTable table)
        {
            var result = new StringBuilder();
            for (int i = 0; i < table.Columns.Count; i++)
            {
                result.Append(string.Format("\"{0}\"", table.Columns[i].ColumnName));
                result.Append(i == table.Columns.Count - 1 ? "\n" : ",");
            }

            foreach (DataRow row in table.Rows)
            {
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    result.Append(string.Format("\"{0}\"", row[i].ToString()));
                    result.Append(i == table.Columns.Count - 1 ? "\n" : ",");
                }
            }

            return result.ToString();
        }
    }
}