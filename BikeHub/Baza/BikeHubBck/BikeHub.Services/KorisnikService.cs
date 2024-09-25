using BikeHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class KorisnikService : IKorisnikService
    {
        public List<Korisnik> List = new List<Korisnik>()
        {
            new Korisnik()
            {
                KorisnikId = 1,
                Username="Prvi",
                Password="Neki",
                Email="Em"
            },
            new Korisnik()
            {
                KorisnikId = 2,
                Username="Drugi",
                Password="Neki2",
                Email="Em2"
            }
        };
        public virtual List<Korisnik> GetList()
        {
            return List;
        }
    }
}
