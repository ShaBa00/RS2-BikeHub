using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class KorisniciInsertR
    {
        public string Username { get; set; }
        public string Lozinka { get; set; } = null!;
        public string LozinkaPotvrda { get; set; } = null!;
        public string Email { get; set; }
    }
}
