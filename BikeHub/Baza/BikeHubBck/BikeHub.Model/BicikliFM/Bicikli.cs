using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.BicikliFM
{
    public class Bicikli
    {
        public int? BiciklId { get; set; }

        public string? Naziv { get; set; } = null!;

        public decimal? Cijena { get; set; }

        public string? VelicinaRama { get; set; }

        public string? VelicinaTocka { get; set; }

        public int? BrojBrzina { get; set; }

        public string? Status { get; set; }

        public int? KategorijaId { get; set; }

        public int? Kolicina { get; set; }
        public int? KorisnikId { get; set; }
    }
}
