using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class Narudzba
    {
        public int? NarudzbaId { get; set; }

        public int? KorisnikId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public string? Status { get; set; } = null!;
        public decimal? UkupnaCijena { get; set; }
        public virtual ICollection<NarudzbaBicikli> NarudzbaBiciklis { get; set; } = new List<NarudzbaBicikli>();

        public virtual ICollection<NarudzbaDijelovi> NarudzbaDijelovis { get; set; } = new List<NarudzbaDijelovi>();
    }
}
