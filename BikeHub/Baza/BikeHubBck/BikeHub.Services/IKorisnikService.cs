using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace BikeHub.Services
{
    public interface IKorisnikService : ICRUDService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Model.KorisnikFM.KorisniciInsertR, Model.KorisnikFM.KorisniciUpdateR>
    {
        public BikeHub.Model.KorisnikFM.Korisnik Login(string username, string password);

        public IActionResult DodajNovogAdmina(KorisniciInsertR korisnik);
    }
}
