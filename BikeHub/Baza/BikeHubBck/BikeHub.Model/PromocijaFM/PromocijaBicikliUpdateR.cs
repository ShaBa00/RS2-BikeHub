using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.PromocijaFM
{
    public class PromocijaBicikliUpdateR
    {
        public int? BiciklId { get; set; }

        public DateTime? DatumPocetka { get; set; }

        public DateTime? DatumZavrsetka { get; set; }
    }
}
