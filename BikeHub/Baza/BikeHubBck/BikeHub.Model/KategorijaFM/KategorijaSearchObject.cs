﻿using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KategorijaFM
{
    public class KategorijaSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; } = null!;

        public string? Status { get; set; } = null!;
    }
}