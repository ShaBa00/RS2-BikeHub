﻿using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.ServisFM
{
    public class ServiserSearchObject : BaseSearchObject
    {
        public decimal? PocetnaCijena { get; set; }
        public decimal? KrajnjaCijena { get; set; }

        public int? BrojServisa { get; set; }

        public string? Status { get; set; }
        public decimal? UkupnaOcjena { get; set; }
        public string? SortOrder { get; set; }
    }
}
