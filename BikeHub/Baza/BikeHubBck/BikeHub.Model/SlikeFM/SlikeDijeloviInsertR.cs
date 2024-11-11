using BikeHub.Model.BicikliFM;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SlikeFM
{
    public class SlikeDijeloviInsertR
    {
        public int DijeloviId { get; set; }

        public byte[]? Slika { get; set; }

    }
}
