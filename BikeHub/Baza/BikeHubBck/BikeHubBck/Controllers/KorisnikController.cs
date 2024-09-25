
using Microsoft.AspNetCore.Mvc;
using BikeHub.Services;
using BikeHub.Model;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : ControllerBase
    {
        private IKorisnikService _service;
        public KorisnikController(IKorisnikService service)
        {
            _service = service;
        }
        [HttpGet]
        public List<Korisnik> GetList()
        {
            return _service.GetList();
        }
    }
}
