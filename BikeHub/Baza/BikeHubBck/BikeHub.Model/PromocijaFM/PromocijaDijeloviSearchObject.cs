using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.PromocijaFM
{
    public class PromocijaDijeloviSearchObject : BaseSearchObject
    {
        public int? PromocijaDijeloviId { get; set; }

        public int? DijeloviId { get; set; }

        public DateTime? DatumPocetka { get; set; }

        public DateTime? DatumZavrsetka { get; set; }

        public decimal? CijenaPromocije { get; set; }

        public string? Status { get; set; }
    }
}
