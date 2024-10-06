using BikeHub.Model.SlikeFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SlikeDijeloviController : BaseController<SlikeDijelovi, SlikeDijeloviSearchObject>
    {
        public SlikeDijeloviController(ISlikeDijeloviService service) 
        : base(service){        }
    }
}
