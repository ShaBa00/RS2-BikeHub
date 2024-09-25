using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model
{
    public class Korisnik
    {
        public int KorisnikId { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
    }
}
