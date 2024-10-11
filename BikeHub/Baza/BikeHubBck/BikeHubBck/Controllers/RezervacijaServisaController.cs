using BikeHub.Model.ServisFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RezervacijaServisaController : BaseCRUDController<RezervacijaServisa, RezervacijaServisaSearchObject,
                                                                    RezervacijaServisaInsertR, RezervacijaServisaUpdateR>
    {
        public RezervacijaServisaController(IRezervacijaServisaService service) 
        : base(service){        }
    }
}
