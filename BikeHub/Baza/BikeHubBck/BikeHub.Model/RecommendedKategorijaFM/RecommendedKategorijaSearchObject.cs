using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.RecommendedKategorijaFM
{
    public class RecommendedKategorijaSearchObject : BaseSearchObject
    {
        public int? DijeloviId { get; set; }

        public int? BicikliId { get; set; }

        public string? Status { get; set; }
    }
}
