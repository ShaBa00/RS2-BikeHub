using BikeHub.Model.ServisFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RezervacijaServisaController : BaseController<RezervacijaServisa, RezervacijaServisaSearchObject>
    {
        public RezervacijaServisaController(IRezervacijaServisaService service) 
        : base(service){        }
    }
}
