using BikeHub.Model.SlikeFM;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.DijeloviFM
{
    public class Dijelovi
    {
        public int? DijeloviId { get; set; }
        public string? Naziv { get; set; } = null!;
        public decimal? Cijena { get; set; }
        public string? Opis { get; set; }
        public string? Status { get; set; }
        public int? KategorijaId { get; set; }
        public int? Kolicina { get; set; }
        public int? KorisnikId { get; set; }

        public virtual ICollection<SlikeDijelovi>? SlikeDijelovis { get; set; } = new List<SlikeDijelovi>();
    }
}
