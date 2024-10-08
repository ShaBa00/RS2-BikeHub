using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IKorisnikService : ICRUDService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Model.KorisnikFM.KorisniciInsertR, Model.KorisnikFM.KorisniciUpdateR>
    {

    }
}
