﻿using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.NarudzbaFM
{
    public class NarudzbaBicikliSearchObject : BaseSearchObject
    {

        public int? BiciklId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? Cijena { get; set; }
        public string? Status { get; set; }
    }
}
