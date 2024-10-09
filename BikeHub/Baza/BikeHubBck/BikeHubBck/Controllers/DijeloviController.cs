using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using BikeHub.Model.DijeloviFM;
using MapsterMapper;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DijeloviController : BaseCRUDController<Dijelovi, DijeloviSearchObject,DijeloviInsertR,DijeloviUpdateR>
    {
        public DijeloviController(IDijeloviService service)
        :base(service){        }

    }
}
