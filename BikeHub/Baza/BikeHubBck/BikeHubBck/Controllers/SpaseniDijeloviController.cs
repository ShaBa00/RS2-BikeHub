using BikeHub.Model.SpaseniFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SpaseniDijeloviController : BaseController<SpaseniDijelovi, SpaseniDijeloviSearchObject>
    {
        public SpaseniDijeloviController(ISpaseniDijeloviService service) 
        : base(service){        }
    }
}
