using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.AdresaFM;

namespace BikeHub.Services
{
    public interface IAdresaService : ICRUDService<Model.AdresaFM.Adresa, AdresaSearchObject, Model.AdresaFM.AdresaInsertR, Model.AdresaFM.AdresaUpdateR>
    {
    }
}
