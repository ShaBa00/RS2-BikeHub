using BikeHub.Model.BicikliFM;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.AspNetCore.Http;
namespace BikeHub.Model.SlikeFM
{
    public class SlikeBicikliInsertR
    {
        public int BiciklId { get; set; }

        public IFormFile Slika { get; set; }

    }
}
