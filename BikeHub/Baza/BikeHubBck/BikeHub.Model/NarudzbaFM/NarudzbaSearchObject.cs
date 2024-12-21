using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaSearchObject : BaseSearchObject
    {
        public int ProdavaocId { get; set; }
        public DateTime? DatumNarudzbe { get; set; }
        public int KorisnikId { get; set; }
        public string? Status { get; set; } = null!;
        public bool? NarudzbaBicikliIncluded { get; set; }
        public decimal? UkupnaCijena { get; set; }
        public bool? NarudzbaDijeloviIncluded { get; set; }
    }
}
