using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SpaseniFM
{
    public class SpaseniDijeloviSearchObject : BaseSearchObject
    {
        //public int? SpaseniDijeloviId { get; set; }

        public int? DijeloviId { get; set; }

        public DateTime? DatumSpasavanja { get; set; }
        public string? Status { get; set; }
        public int? KorisnikId { get; set; }
    }
}
