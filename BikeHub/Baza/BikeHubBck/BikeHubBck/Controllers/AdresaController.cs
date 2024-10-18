using BikeHub.Model;
using BikeHub.Model.AdresaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AdresaController : BaseCRUDController<Adresa, AdresaSearchObject,AdresaInsertR,AdresaUpdateR>
    {
        public AdresaController(IAdresaService service) 
        : base(service){        }

        [AllowAnonymous]
        public override PagedResult<Adresa> GetList([FromQuery] AdresaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
