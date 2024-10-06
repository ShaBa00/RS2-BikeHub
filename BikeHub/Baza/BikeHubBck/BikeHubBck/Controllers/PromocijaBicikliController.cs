using BikeHub.Model.PromocijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PromocijaBicikliController : BaseController<PromocijaBicikli, PromocijaBicikliSearchObject>
    {
        public PromocijaBicikliController(IPromocijaBicikliService service) 
        : base(service){        }
    }
}
