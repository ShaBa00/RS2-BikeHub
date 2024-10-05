using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.BicikliFM
{
    public class Bicikli
    {
        public string? Naziv { get; set; } = null!;
        public decimal? Cijena { get; set; }
        public string? Status { get; set; }
    }
}
