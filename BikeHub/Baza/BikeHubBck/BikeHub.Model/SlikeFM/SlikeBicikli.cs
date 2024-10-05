using BikeHub.Model.BicikliFM;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeBicikli
    {
        public int? SlikeBicikliId { get; set; }

        public int? BiciklId { get; set; }

        public byte[]? Slika { get; set; }

    }
}
