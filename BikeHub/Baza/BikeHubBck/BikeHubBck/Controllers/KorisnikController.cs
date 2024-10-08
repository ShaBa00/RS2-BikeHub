using Microsoft.AspNetCore.Mvc;
using BikeHub.Services;
using BikeHub.Model.KorisnikFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using BikeHub.Model;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseCRUDController<Korisnik,KorisniciSearchObject,KorisniciInsertR,KorisniciUpdateR>
    {
        public KorisnikController(IKorisnikService service)
           : base(service) { }
    }
}
