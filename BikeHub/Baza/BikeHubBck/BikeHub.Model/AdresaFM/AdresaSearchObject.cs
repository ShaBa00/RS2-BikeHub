using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.AdresaFM
{
    public class AdresaSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public string? Grad { get; set; } = null!;

        public string? PostanskiBroj { get; set; } = null!;

        public string? Ulica { get; set; } = null!;
    }
}
