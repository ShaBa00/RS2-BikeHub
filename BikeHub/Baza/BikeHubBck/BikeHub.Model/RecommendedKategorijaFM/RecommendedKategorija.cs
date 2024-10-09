using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.RecommendedKategorijaFM
{
    public class RecommendedKategorija
    {
        public int? RecommendedKategorijaId { get; set; }

        public int? DijeloviId { get; set; }

        public int? BicikliId { get; set; }

        public int? BrojPreporuka { get; set; }

        public DateTime? DatumKreiranja { get; set; }

        public string? Status { get; set; }
    }
}
