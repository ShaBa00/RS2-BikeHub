using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaUpdateR
    {
        public int? KorisnikId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public string? Status { get; set; } = null!;
    }
}
