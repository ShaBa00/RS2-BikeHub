using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.Ostalo
{
    public class GradKorisniciDto
    {
        public int GradId { get; set; } = 0;
        public string Grad { get; set; } = string.Empty;
        public List<int> KorisnikIds { get; set; } = new List<int>();
    }
}
