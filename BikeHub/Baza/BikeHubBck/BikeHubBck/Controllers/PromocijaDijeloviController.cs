using BikeHub.Model.PromocijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PromocijaDijeloviController : BaseController<PromocijaDijelovi, PromocijaDijeloviSearchObject>
    {
        public PromocijaDijeloviController(IPromocijaDijeloviService service) 
        : base(service){        }
    }
}
