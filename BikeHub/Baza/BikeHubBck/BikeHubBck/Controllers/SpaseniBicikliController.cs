using BikeHub.Model.SpaseniFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SpaseniBicikliController : BaseController<SpaseniBicikli, SpaseniBicikliSearchObject>
    {
        public SpaseniBicikliController(ISpaseniBicikliService service) 
        : base(service){        }
    }
}
