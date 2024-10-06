using BikeHub.Model.SlikeFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SlikeBicikliController : BaseController<SlikeBicikli, SlikeBicikliSearchObject>
    {
        public SlikeBicikliController(ISlikeBicikliService service) 
        : base(service){        }
    }
}
