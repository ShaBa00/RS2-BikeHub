using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.DijeloviFM
{
    public class DijeloviInsertR
    {
        public string Naziv { get; set; } = null!;
        public decimal Cijena { get; set; }
        public string Opis { get; set; }
        public int KategorijaId { get; set; }
        public int Kolicina { get; set; }
        public int KorisnikId { get; set; }
    }
}
