using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.DijeloviFM
{
    public class DijeloviSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; } = null!;
        public decimal? PocetnaCijena { get; set; }
        public decimal? KrajnjaCijena { get; set; }
        public string? Opis { get; set; }
        public string? Status { get; set; }
        public int? KategorijaId { get; set; }
        public int? Kolicina { get; set; }
        public int? KorisnikId { get; set; }
    }
}
