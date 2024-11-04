using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.Ostalo
{
    public class ServiserDto
    {
        public int ServiserId { get; set; }
        public int KorisnikId { get; set; }
        public decimal Cijena { get; set; }
        public int BrojServisa { get; set; }
        public string Status { get; set; }
        public decimal UkupnaOcjena { get; set; }
        public string Username { get; set; }
        public string Grad { get; set; }
    }
}
