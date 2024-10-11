using BikeHub.Model.PromocijaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PromocijaDijeloviController : BaseCRUDController<PromocijaDijelovi, PromocijaDijeloviSearchObject,
                                                                    PromocijaDijeloviInsertR, PromocijaDijeloviUpdateR>
    {
        public PromocijaDijeloviController(IPromocijaDijeloviService service) 
        : base(service){        }
    }
}
