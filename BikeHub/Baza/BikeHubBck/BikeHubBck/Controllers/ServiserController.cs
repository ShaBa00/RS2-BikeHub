using BikeHub.Model.ServisFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ServiserController : BaseCRUDController<Serviser, ServiserSearchObject, ServiserInsertR, ServiserUpdateR>
    {
        public ServiserController(IServiserService service) 
        : base(service){        }
    }
}
