using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.KorisnikFM
{
    public class Korisnik
    {
        public int KorisnikId { get; set; }
        public string Username { get; set; }
        public string? LozinkaSalt { get; set; }
        public string? LozinkaHash { get; set; }
        public bool? IsAdmin { get; set; }
        public string Email { get; set; }
        public virtual ICollection<KorisnikInfo> KorisnikInfos { get; set; } = new List<KorisnikInfo>();
        public string Status { get; set; }
        public int? BrojProizvoda { get; set; }
        public int? BrojRezervacija { get; set; }
        public int? UkupnaKolicina { get; set; }
        public string? JeServiser { get; set; }
    }
}
