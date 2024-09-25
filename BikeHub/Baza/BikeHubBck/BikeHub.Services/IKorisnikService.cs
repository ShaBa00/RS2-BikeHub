using BikeHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IKorisnikService
    {
        List<Korisnik> GetList();
    }
}
