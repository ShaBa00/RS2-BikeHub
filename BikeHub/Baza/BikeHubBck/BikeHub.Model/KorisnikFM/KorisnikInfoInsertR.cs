﻿using System;
using System.Collections.Generic;


namespace BikeHub.Model.KorisnikFM
{
    public partial class KorisnikInfoInsertR
    {
        public int KorisnikId { get; set; }

        public string ImePrezime { get; set; } = null!;

        public string Telefon { get; set; }
    }
}

