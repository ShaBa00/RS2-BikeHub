using System;
using System.Collections.Generic;


namespace BikeHub.Model.KorisnikFM
{
    public partial class KorisnikInfo
    {
        public int? KorisnikInfoId { get; set; }

        public int? KorisnikId { get; set; }

        public string? ImePrezime { get; set; } = null!;

        public string? Telefon { get; set; }

        public int? BrojNarudbi { get; set; }

        public int? BrojServisa { get; set; }

    }
}


