using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.ServisFM
{
    public class RezervacijaServisaInsertR
    {
        public int KorisnikId { get; set; }

        public int ServiserId { get; set; }

        public DateTime DatumKreiranja { get; set; }

        public DateTime DatumRezervacije { get; set; }
    }
}
