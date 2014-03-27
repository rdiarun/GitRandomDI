using System;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using Spire.DataExport.Common;

namespace DetectorInspector.Infrastructure
{
    public enum ExportFormat
    {
        Xls,
        Csv
    }

    public class DbExportContext
    {
        private string GetFilePath()
        {
            var filePath = Path.Combine(ApplicationConfig.Current.SystemBasePath, "write", Guid.NewGuid().ToString());
            return filePath;
        }

        public Stream Export(DbCommand command, string sheetName)
        {
            GetSchema(command);
            using (DbConnection conn = _factory.CreateConnection())
            {
                conn.ConnectionString = ConnectionString;
                conn.Open();
                command.Connection = conn;

                var ds = new DataSet();
                new SqlDataAdapter((SqlCommand) command).Fill(ds);

                var table = ds.Tables[0];
                
                var cols = table.Columns.Cast<DataColumn>().Select(c =>
                    {
                        var type = c.DataType;
                        if (c.DataType == typeof(DateTime) || c.DataType == typeof(DateTime?))
                            type = typeof (string);
                        return new DataColumn(c.ColumnName, type, c.Expression, c.ColumnMapping);
                    }).ToArray();

                var newTable = new DataTable();
                newTable.Columns.AddRange(cols);

                foreach(var row in table.Rows.Cast<DataRow>())
                {
                    var newRow = newTable.NewRow();

                    var i = 0;
                    foreach (var col in table.Columns.Cast<DataColumn>())
                    {
                        
                        if (col.DataType == typeof(DateTime) || col.DataType == typeof(DateTime?))
                        {
                            var dt = row[col] as DateTime?;
                            if (dt != null)
                                newRow[i] = dt.Value.ToShortDateString();
                        }
                        else
                            newRow[i] = row[i];
                        i++;
                    }

                    newTable.Rows.Add(newRow);
                }
                //Spire.License.LicenseProvider.SetLicenseFile(new FileInfo("license.elic.xml"));
                var cellExport = new Spire.DataExport.XLS.CellExport
                                     {
                                         ActionAfterExport = Spire.DataExport.Common.ActionType.OpenView,
                                         AutoFitColWidth = true,
                                         DataFormats =
                                             {
                                                 CultureName = "en-AU",
                                                 Currency = "#,###,##0.00",
                                                 DateTime = "yyyy-M-d",
                                                 Float = "#,###,##0.00",
                                                 Integer = "#,###,##0"
                                             }
                                     };
                //cellExport.
                //cellExport.DataFormats.Time = "H:mm";
                cellExport.SheetOptions.AggregateFormat.Font.Name = "Arial";
                cellExport.SheetOptions.CustomDataFormat.Font.Name = "Arial";
                cellExport.SheetOptions.DefaultFont.Name = "Arial";
                cellExport.SheetOptions.FooterFormat.Font.Name = "Arial";
                cellExport.SheetOptions.HeaderFormat.Font.Name = "Arial";
                cellExport.SheetOptions.HyperlinkFormat.Font.Color = Spire.DataExport.XLS.CellColor.Blue;
                cellExport.SheetOptions.HyperlinkFormat.Font.Name = "Arial";
                cellExport.SheetOptions.HyperlinkFormat.Font.Underline = Spire.DataExport.XLS.XlsFontUnderline.Single;
                cellExport.SheetOptions.NoteFormat.Alignment.Horizontal = Spire.DataExport.XLS.HorizontalAlignment.Left;
                cellExport.SheetOptions.NoteFormat.Alignment.Vertical = Spire.DataExport.XLS.VerticalAlignment.Top;
                cellExport.SheetOptions.NoteFormat.Font.Bold = true;
                cellExport.SheetOptions.NoteFormat.Font.Name = "Tahoma";
                cellExport.SheetOptions.NoteFormat.Font.Size = 8F;
                cellExport.SheetOptions.TitlesFormat.Font.Bold = true;
                cellExport.SheetOptions.TitlesFormat.Font.Name = "Arial";
                cellExport.SheetName = sheetName;
                cellExport.Columns = SelectedColumns;
                //cellExport.SQLCommand = command;
                cellExport.DataSource = ExportSource.DataTable;
                cellExport.DataTable = newTable;
                var memoryStream = new MemoryStream();
                cellExport.SaveToStream(memoryStream);
                conn.Close();
                
                return memoryStream;
            }
        }

        public DbParameter GetParameter(string parameterName, object parameterValue)
        { 
            DbParameter parameter = _factory.CreateParameter();
            parameter.ParameterName = parameterName;
            parameter.Value = parameterValue;
            return parameter;
        }

        public DbCommand GetCommand(string commandText, CommandType commandType)
        {
            DbCommand command = _factory.CreateCommand();
            command.CommandText = commandText;
            command.CommandType = commandType;
            return command;
        }

        public DbExportContext(ExportFormat exportFormat)
        {
            FactoryName = "System.Data.SqlClient";
            ConnectionString = ConfigurationManager.ConnectionStrings["Default"].ConnectionString;
            _factory = DbProviderFactories.GetFactory(FactoryName);
            ExportFormat = exportFormat;
        }

        private void GetSchema(DbCommand command)
        {
            using (DbConnection conn = _factory.CreateConnection())
            {
                conn.ConnectionString = ConnectionString;
                conn.Open();
                command.Connection = conn;

                DbDataReader result = command.ExecuteReader();
                Columns = result.GetSchemaTable();

                conn.Close();
            }
        }

        private DbProviderFactory _factory;
        public string FactoryName { get; protected set; }
        public string ConnectionString { get; protected set; }
        public IDbCommand Command { get; protected set; }
        public ExportFormat ExportFormat { get; protected set; }
        public DataTable Columns { get; private set; }

        public Spire.DataExport.Collections.StringListCollection SelectedColumns
        {
            get
            {
                Spire.DataExport.Collections.StringListCollection columns
                    = new Spire.DataExport.Collections.StringListCollection();
                foreach (DataRow columnMeta in Columns.Rows)
                {
                    columns.Add(columnMeta["ColumnName"]);
                }

                return columns;
            }
        }
    }
}