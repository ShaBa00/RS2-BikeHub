using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.BicikliFM
{
    public class BicikliSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; } = null!;
        public decimal? Cijena { get; set; }
        public string? Status { get; set; }
    }
}
