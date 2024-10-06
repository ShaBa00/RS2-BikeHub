using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaBicikliController : BaseController<NarudzbaBicikli, NarudzbaBicikliSearchObject>
    {
        public NarudzbaBicikliController(INarudzbaBicikliService service) 
        : base(service){        }
    }
}
