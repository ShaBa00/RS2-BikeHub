using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeDijeloviSearchObject : BaseSearchObject
    {
        //public int? SlikeDijeloviId { get; set; }

        public int? DijeloviId { get; set; }
        public string? Status { get; set; }

        //public byte[]? Slika { get; set; }
    }
}
