﻿using BikeHub.Model.BicikliFM;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeDijelovi
    {
        public int? SlikeDijeloviId { get; set; }

        public int? DijeloviId { get; set; }

        public byte[]? Slika { get; set; }
        public string? Status { get; set; }

    }
}
