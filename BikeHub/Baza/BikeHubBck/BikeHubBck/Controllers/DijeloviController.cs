using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Model.DijeloviFM;
using MapsterMapper;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DijeloviController : BaseController<Dijelovi, DijeloviSearchObject>
    {
        public DijeloviController(IDijeloviService service)
        :base(service){        }

    }
}
