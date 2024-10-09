using BikeHub.Model.KategorijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KategorijaController : BaseCRUDController<Kategorija, KategorijaSearchObject, KategorijaInsertR, KategorijaUpdateR>
    {
        public KategorijaController(IKategorijaService service) 
        : base(service){        }
    }
}
