using BikeHub.Model.Ostalo;
using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class KorisniciSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
        public bool? IsAdmin { get; set; }
        public bool? IsInfoIncluded { get; set; }
        public string? Status { get; set; }
    }
}
