using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaDijeloviController : BaseController<NarudzbaDijelovi, NarudzbaDijeloviSearchObject>
    {
        public NarudzbaDijeloviController(INarudzbaDijeloviService service) 
        : base(service){        }
    }
}
