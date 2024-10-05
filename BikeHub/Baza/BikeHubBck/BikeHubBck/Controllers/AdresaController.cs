using BikeHub.Model.AdresaFM;
using BikeHub.Model.PromocijaFM;
using BikeHub.Model.ServisFM;
using BikeHub.Model.SlikeFM;
using BikeHub.Model.SpaseniFM;
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
