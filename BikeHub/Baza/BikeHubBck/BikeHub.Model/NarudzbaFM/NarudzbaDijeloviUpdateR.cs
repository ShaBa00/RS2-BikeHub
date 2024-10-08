using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaDijeloviUpdateR
    {
        public int? NarudzbaId { get; set; }

        public int? DijeloviId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? Cijena { get; set; }
    }
}
