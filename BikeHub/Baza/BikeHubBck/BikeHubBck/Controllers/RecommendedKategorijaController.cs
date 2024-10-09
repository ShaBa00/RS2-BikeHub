using BikeHub.Model.RecommendedKategorijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RecommendedKategorijaController : BaseCRUDController<RecommendedKategorija, RecommendedKategorijaSearchObject, RecommendedKategorijaInsertR, RecommendedKategorijaUpdateR>
    {
        public RecommendedKategorijaController(IRecommendedKategorijaService service) 
        : base(service){        }
    }
}
