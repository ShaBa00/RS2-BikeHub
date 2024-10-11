using BikeHub.Model.PromocijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PromocijaBicikliController : BaseCRUDController<PromocijaBicikli, PromocijaBicikliSearchObject,
                                                                  PromocijaBicikliInsertR, PromocijaBicikliUpdateR>
    {
        public PromocijaBicikliController(IPromocijaBicikliService service) 
        : base(service){        }
    }
}
