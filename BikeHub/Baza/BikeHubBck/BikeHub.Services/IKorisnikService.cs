using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IKorisnikService : IService<Model.KorisnikFM.Korisnik, Model.KorisnikFM.KorisniciSearchObject>
    {
        Korisnik Insert(KorisniciInsertR request);
        Korisnik Promjeni(int id, KorisnikPromjeniR request);

    }
}
