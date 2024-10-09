using System;
using System.Collections.Generic;


namespace BikeHub.Model.KorisnikFM
{
    public partial class KorisnikInfoUpdateR
    {
        public string? ImePrezime { get; set; } = null!;

        public string? Telefon { get; set; }

        public int? BrojNarudbi { get; set; }

        public int? BrojServisa { get; set; }
    }
}


