using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.ServisFM
{
    public class ServiserSearchObjectDTO : BaseSearchObject
    {
        public int? ServiserId { get; set; }
        public int? KorisnikId { get; set; }
        public string? Username { get; set; }
        public decimal? PocetnaCijena { get; set; }
        public decimal? KrajnjaCijena { get; set; }

        public int? PocetniBrojServisa { get; set; }
        public int? KrajnjiBrojServisa { get; set; }

        public string? Status { get; set; }
        public decimal? PocetnaOcjena { get; set; }
        public decimal? KrajnjaOcjena { get; set; }
    }
}
