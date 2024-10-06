using BikeHub.Model.ServisFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ServiserController : BaseController<Serviser, ServiserSearchObject>
    {
        public ServiserController(IServiserService service) 
        : base(service){        }
    }
}
