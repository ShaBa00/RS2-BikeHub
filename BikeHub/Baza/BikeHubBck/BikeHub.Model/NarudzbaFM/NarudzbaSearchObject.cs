using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaSearchObject : BaseSearchObject
    {
        public DateTime? DatumNarudzbe { get; set; }
        public string? Status { get; set; } = null!;
        public bool? NarudzbaBicikliIncluded { get; set; }
        public bool? NarudzbaDijeloviIncluded { get; set; }
    }
}
