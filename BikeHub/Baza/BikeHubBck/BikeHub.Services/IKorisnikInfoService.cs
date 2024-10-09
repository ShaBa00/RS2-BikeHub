using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IKorisnikInfoService : ICRUDService<Model.KorisnikFM.KorisnikInfo, Model.KorisnikFM.KorisnikInfoSearchObject,Model.KorisnikFM.KorisnikInfoInsertR, Model.KorisnikFM.KorisnikInfoUpdateR>
    {
    }
}
