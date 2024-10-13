using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class KorisnikInfoSearchObject : BaseSearchObject
    {
        //public int? KorisnikInfoId { get; set; }

        //public int? KorisnikId { get; set; }

        public string? ImePrezime { get; set; } = null!;

        public string? Telefon { get; set; }

        public int? BrojNarudbi { get; set; }

        public int? BrojServisa { get; set; }
        public string? Status { get; set; }
    }
}
