using BikeHub.Model.NarudzbaFM;
using BikeHub.Model.PromocijaFM;
using BikeHub.Model.SlikeFM;
using BikeHub.Model.SpaseniFM;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.BicikliFM
{
    public class BicikliUpdateR
    {
        public string? Naziv { get; set; } = null!;

        public decimal? Cijena { get; set; }

        public string? VelicinaRama { get; set; }

        public string? VelicinaTocka { get; set; }

        public int? BrojBrzina { get; set; }

        public int? KategorijaId { get; set; }
        public int? KorisnikId { get; set; }

        public int? Kolicina { get; set; }
    }
}
