using System;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using Kiandra.Data;
using Kiandra.Web.Mvc;

using DetectorInspector.Data;
using DetectorInspector.Infrastructure;
using DetectorInspector.Model;
using DetectorInspector.ViewModels;
using DetectorInspector.Controllers;
using DetectorInspector.Areas.Booking.ViewModels;
using System.Collections.Generic;
using System.Web.UI.DataVisualization.Charting;
using System.IO;
using System.Text;
using System.Net.Mime;
using System.Drawing;

namespace DetectorInspector.Areas.Reporting.Controllers
{
    [HandleError]
    public class HomeController : SiteController
    {

        private IPropertyRepository _propertyRepository;

        public HomeController(
            ITransactionFactory transactionFactory,
            IRepository repository,
            IPropertyRepository propertyRepository,
            IModelMetadataProvider modelMetadataProvider,
            IHelpRepository helpRepository)
            : base(transactionFactory, repository, helpRepository)
        {
            _propertyRepository = propertyRepository;
        }

        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }



        private Chart PrepareChart(Font chartFont, Font titleFont, string title, int width, int height)
        {
            Chart chart = new Chart();

            chart.AntiAliasing = AntiAliasingStyles.All;
            chart.TextAntiAliasingQuality = TextAntiAliasingQuality.High;
            chart.RenderType = RenderType.ImageTag;
            chart.Palette = ChartColorPalette.BrightPastel;
            chart.Width = width;
            chart.Height = height;

            BorderSkin borderSkin = new BorderSkin();
            borderSkin.SkinStyle = BorderSkinStyle.Emboss;
            borderSkin.BorderColor = Color.DarkGray;
            borderSkin.BorderDashStyle = ChartDashStyle.Solid;
            borderSkin.BorderWidth = 2;
            chart.BorderSkin = borderSkin;
            chart.BorderlineWidth = 2;
            chart.BorderlineDashStyle = ChartDashStyle.Solid;
            chart.BorderlineColor = Color.DarkGray;

            chart.Titles.Add(new Title(title, Docking.Top, titleFont, Color.Black));

            chart.BackColor = Color.White;

            ChartArea plotArea = new ChartArea("PlotArea");
            plotArea.Area3DStyle.Enable3D = false;

            LabelStyle labelStyle = new LabelStyle();
            labelStyle.Font = chartFont;
                
            plotArea.AxisX.LabelAutoFitStyle = LabelAutoFitStyles.IncreaseFont;
            plotArea.AxisX.Interval = 1;
            plotArea.AxisX.LabelStyle = labelStyle;

            chart.ChartAreas.Add(plotArea);

            return chart;
        }

        [HttpGet]
        public ActionResult GetMonthlyService()
        {
            ViewData["Chart"] = _propertyRepository.GetMonthlyService(DateTime.Today, 5, 12);
            Font chartFont = new Font("Tahoma", 8, FontStyle.Regular);
            Font titleFont = new Font("Tahoma", 12, FontStyle.Bold);
            Chart MonthlyServicesChart = PrepareChart(chartFont, titleFont, "Services Due by Month", 960, 400);

            foreach (var seriesSet in (IEnumerable<SeriesSet>)ViewData["Chart"])
            {
                Series series = new Series(seriesSet.Name);
                series.ChartArea = "PlotArea";
                series.ChartType = SeriesChartType.Column;
                series.Font = chartFont;

                foreach (var value in seriesSet.Results)
                {
                    DataPoint point = new DataPoint();
                    point.AxisLabel = value.Label;
                    point.SetValueY(value.Value);
                    point.Font = chartFont;
                    point.IsValueShownAsLabel = true;
                    series.Points.Add(point);
                }
                MonthlyServicesChart.Series.Add(series);
            }

            MemoryStream imageStream = new MemoryStream();
          MonthlyServicesChart.SaveImage(imageStream, ChartImageFormat.Png);
            return new FileResult("monthlyservices.png", "image/png", imageStream.ToArray());
        }

        
        [HttpGet]
        public ActionResult GetServiceByZone(int? technicianId, int monthToAdd)
        {
            ViewData["Chart"] = _propertyRepository.GetServiceByZone(DateTime.Today.AddMonths(monthToAdd), technicianId);
            Font chartFont = new Font("Tahoma", 8, FontStyle.Regular);
            Font titleFont = new Font("Tahoma", 12, FontStyle.Bold);
            Chart ServicesByZone = PrepareChart(chartFont, titleFont, string.Format("Services By Zone: {0}", DateTime.Today.AddMonths(monthToAdd).ToString("MMM")), 315, 315);

            foreach (var seriesSet in (IEnumerable<SeriesSet>)ViewData["Chart"])
            {
                Series series = new Series(seriesSet.Name);
                series.ChartArea = "PlotArea";
                series.ChartType = SeriesChartType.Pie;
                series.Font = chartFont;

                foreach (var value in seriesSet.Results)
                {
                    DataPoint point = new DataPoint();
                    point.AxisLabel = string.Format("{0}({1})", value.Label, value.Value);
                    point.SetValueY(value.Value);
                    point.Font = chartFont;
                    series.Points.Add(point);
                }

                ServicesByZone.Series.Add(series);

            }

            MemoryStream imageStream = new MemoryStream();
            ServicesByZone.SaveImage(imageStream, ChartImageFormat.Png);
            return new FileResult("servicesbyzone.png", "image/png", imageStream.ToArray());
        }

    
    }


    public class FileResult : ActionResult
    {
        #region Constructors

        public FileResult(string fileName, string contentType, IEnumerable<byte> data)
            : this(fileName, contentType, data, null)
        {
        }

        public FileResult(string fileName, string contentType, IEnumerable<byte> data, IDictionary<string, string> headers)
        {
            this.FileName = fileName;
            this.ContentType = contentType;
            this.Data = data;
            this.Headers = headers;
        }

        public FileResult(string fileName, string contentType, Encoding contentEncoding, IEnumerable<byte> data)
            : this(fileName, contentType, contentEncoding, data, null)
        {
        }

        public FileResult(string fileName, string contentType, Encoding contentEncoding, IEnumerable<byte> data, IDictionary<string, string> headers)
            : this(fileName, contentType, data, headers)
        {
            this.ContentEncoding = contentEncoding;
        }

        public FileResult(string fileName, string contentType, string path)
            : this(fileName, contentType, path, null)
        {
        }

        public FileResult(string fileName, string contentType, string path, IDictionary<string, string> headers)
        {
            this.FileName = fileName;
            this.ContentType = contentType;
            this.Data = ReadBytes(path);
            this.Headers = headers;
        }

        #endregion

        IEnumerable<byte> ReadBytes(string path)
        {
            var stream = File.OpenRead(path);
            var bytes = new byte[1024];
            int n;

            while ((n = stream.Read(bytes, 0, bytes.Length)) != 0)
            {
                for (int i = 0; i < n; i++)
                {
                    yield return bytes[i];
                }
            }
        }

        // Methods
        public override void ExecuteResult(ControllerContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException("context");
            }

            HttpResponseBase response = context.HttpContext.Response;

            response.Clear();
            response.ClearContent();

            if (!string.IsNullOrEmpty(this.ContentType))
            {
                response.ContentType = this.ContentType;
            }
            else
            {
                response.ContentType = MediaTypeNames.Text.Plain;
            }

            response.ContentEncoding = this.ContentEncoding ?? Encoding.Default;

            if (!String.IsNullOrEmpty(this.FileName))
            {
                response.AppendHeader("content-disposition", "attachment; filename=" + this.FileName);
            }

            if (this.Headers != null)
            {
                foreach (var header in Headers)
                {
                    response.AppendHeader(header.Key, header.Value);
                }
            }

            if (this.Data != null)
            {
                response.BinaryWrite(this.Data.ToArray());
            }
        }

        // Properties
        public IEnumerable<byte> Data { get; set; }

        public string FileName { get; set; }

        public Encoding ContentEncoding { get; set; }

        public string ContentType { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public IDictionary<string, string> Headers { get; set; }
    }
}