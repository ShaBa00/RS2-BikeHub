using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.RecommendedKategorijaFM;

namespace BikeHub.Services
{
    public interface IRecommendedKategorijaService : ICRUDService<Model.RecommendedKategorijaFM.RecommendedKategorija, RecommendedKategorijaSearchObject, Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR, Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR>
    {
    }
}
