using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaController : BaseController<Narudzba, NarudzbaSearchObject>
    {
        public NarudzbaController(INarudzbaService service) 
        : base(service){        }
    }
}
