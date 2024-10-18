using BikeHub.Model;
using BikeHub.Model.RecommendedKategorijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RecommendedKategorijaController : BaseCRUDController<RecommendedKategorija, RecommendedKategorijaSearchObject, RecommendedKategorijaInsertR, RecommendedKategorijaUpdateR>
    {
        public RecommendedKategorijaController(IRecommendedKategorijaService service) 
        : base(service){        }

        [AllowAnonymous]
        public override PagedResult<RecommendedKategorija> GetList([FromQuery] RecommendedKategorijaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
