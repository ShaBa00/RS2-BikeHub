using BikeHub.Model.AdresaFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikInfoController : BaseController<KorisnikInfo, KorisnikInfoSearchObject>
    {
        public KorisnikInfoController(IKorisnikInfoService service) 
        : base(service){        }
    }
}
