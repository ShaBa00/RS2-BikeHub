using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.KategorijaFM;

namespace BikeHub.Services
{
    public interface IKategorijaService : ICRUDService<Model.KategorijaFM.Kategorija, KategorijaSearchObject, Model.KategorijaFM.KategorijaInsertR, Model.KategorijaFM.KategorijaUpdateR>
    {
    }
}
