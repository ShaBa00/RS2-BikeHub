using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaDijeloviSearchObject : BaseSearchObject
    {

        public int? DijeloviId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? Cijena { get; set; }
        public string? Status { get; set; }
    }
}
