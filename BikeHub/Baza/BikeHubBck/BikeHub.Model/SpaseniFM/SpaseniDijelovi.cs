using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SpaseniFM
{
    public class SpaseniDijelovi
    {
        public int? SpaseniDijeloviId { get; set; }

        public int? DijeloviId { get; set; }

        public DateTime? DatumSpasavanja { get; set; }
        public string? Status { get; set; }
    }
}
