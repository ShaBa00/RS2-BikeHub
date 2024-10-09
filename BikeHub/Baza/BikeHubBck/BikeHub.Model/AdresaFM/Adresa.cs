using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.AdresaFM
{
    public class Adresa
    {
        public int? AdresaId { get; set; }

        public int? KorisnikId { get; set; }
        public string? Grad { get; set; } = null!;

        public string? PostanskiBroj { get; set; } = null!;

        public string? Ulica { get; set; } = null!;
    }
}
