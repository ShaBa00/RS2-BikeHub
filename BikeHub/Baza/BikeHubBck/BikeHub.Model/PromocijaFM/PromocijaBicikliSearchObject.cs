﻿using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.PromocijaFM
{
    public class PromocijaBicikliSearchObject : BaseSearchObject
    {

        public int? BiciklId { get; set; }

        public decimal? CijenaPromocije { get; set; }

        public string? Status { get; set; }
    }
}
