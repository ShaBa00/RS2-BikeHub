﻿using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaBicikli
    {
        public int? NarudzbaBicikliId { get; set; }

        public int? NarudzbaId { get; set; }

        public int? BiciklId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? Cijena { get; set; }
        public string? Status { get; set; }
    }
}
