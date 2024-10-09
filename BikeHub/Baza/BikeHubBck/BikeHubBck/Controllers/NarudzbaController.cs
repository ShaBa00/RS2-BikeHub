using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaController : BaseCRUDController<Narudzba, NarudzbaSearchObject, NarudzbaInsertR, NarudzbaUpdateR>
    {
        public NarudzbaController(INarudzbaService service) 
        : base(service){        }
    }
}
