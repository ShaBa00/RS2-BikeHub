using BikeHub.Model.AdresaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AdresaController : BaseCRUDController<Adresa, AdresaSearchObject,AdresaInsertR,AdresaUpdateR>
    {
        public AdresaController(IAdresaService service) 
        : base(service){        }
    }
}
