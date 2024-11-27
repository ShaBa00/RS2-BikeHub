using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class KorisniciInsertRHS
    {
        public string Username { get; set; }
        public string? LozinkaSalt { get; set; }

        public string? LozinkaHash { get; set; }
        public string Email { get; set; }
        public bool IsAdmin { get; set; }
    }
}
