using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KategorijaFM
{
    public class KategorijaUpdateR
    {
        public string? Naziv { get; set; } = null!;
        public bool? IsBikeKategorija { get; set; }
    }
}
