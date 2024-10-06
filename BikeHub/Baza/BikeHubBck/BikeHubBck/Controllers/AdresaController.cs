using BikeHub.Model.AdresaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AdresaController : BaseController<Adresa, AdresaSearchObject>
    {
        public AdresaController(IAdresaService service) 
        : base(service){        }
    }
}
