using BikeHub.Model.KorisnikFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikInfoController : BaseCRUDController<KorisnikInfo, KorisnikInfoSearchObject,KorisnikInfoInsertR,KorisnikInfoUpdateR>
    {
        public KorisnikInfoController(IKorisnikInfoService service) 
        : base(service){        }
    }
}
