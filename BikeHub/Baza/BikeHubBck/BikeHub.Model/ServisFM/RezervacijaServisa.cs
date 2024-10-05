using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.ServisFM
{
    public class RezervacijaServisa
    {
        public int? RezervacijaId { get; set; }

        public int? KorisnikId { get; set; }

        public int? ServiserId { get; set; }

        public DateTime? DatumKreiranja { get; set; }

        public DateTime? DatumRezervacije { get; set; }

        public decimal? Ocjena { get; set; }

        public string? Status { get; set; }
    }
}
