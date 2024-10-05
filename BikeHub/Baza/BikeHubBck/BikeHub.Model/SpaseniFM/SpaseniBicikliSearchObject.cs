using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SpaseniFM
{
    public class SpaseniBicikliSearchObject : BaseSearchObject
    {
        public int? SpaseniBicikliId { get; set; }

        public int? BiciklId { get; set; }

        public DateTime? DatumSpasavanja { get; set; }
    }
}
