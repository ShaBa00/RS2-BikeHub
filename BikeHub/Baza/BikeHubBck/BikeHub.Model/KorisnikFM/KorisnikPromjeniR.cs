using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class KorisnikPromjeniR
    {
        public string Username { get; set; } = null!;
        public string? Lozinka { get; set; }
        public string? LozinkaPotvrda { get; set; }
        public string Email { get; set; } = null!;
    }
}
