using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.SpaseniFM
{
    public class SpaseniDijeloviInsertR
    {
        public int DijeloviId { get; set; }

        public DateTime DatumSpasavanja { get; set; }
        public int? KorisnikId { get; set; }
    }
}
