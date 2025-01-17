﻿using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SpaseniFM
{
    public class SpaseniBicikliSearchObject : BaseSearchObject
    {

        public int? BiciklId { get; set; }

        public DateTime? DatumSpasavanja { get; set; }
        public string? Status { get; set; }
        public int? KorisnikId { get; set; }
    }
}
