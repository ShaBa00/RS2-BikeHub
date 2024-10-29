using BikeHub.Model.BicikliFM;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeBicikliUpdateR
    {
        public int? BiciklId { get; set; }
        public IFormFile? Slika { get; set; }
    }
}
