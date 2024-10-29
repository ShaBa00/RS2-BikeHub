using BikeHub.Model.BicikliFM;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeDijeloviUpdateR
    {
        public int? DijeloviId { get; set; }

        public IFormFile? Slika { get; set; }

    }
}
