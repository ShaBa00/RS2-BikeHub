using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.PromocijaFM
{
    public class PromocijaDijeloviUpdateR
    {
        public int? DijeloviId { get; set; }

        public DateTime? DatumPocetka { get; set; }

        public DateTime? DatumZavrsetka { get; set; }

        public string? Status { get; set; }
    }
}
