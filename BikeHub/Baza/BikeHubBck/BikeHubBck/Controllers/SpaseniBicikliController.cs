using BikeHub.Model.SpaseniFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SpaseniBicikliController : BaseCRUDController<SpaseniBicikli, SpaseniBicikliSearchObject, SpaseniBicikliInsertR, SpaseniBicikliUpdateR>
    {
        public SpaseniBicikliController(ISpaseniBicikliService service) 
        : base(service){        }
    }
}
