using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaBicikliController : BaseCRUDController<NarudzbaBicikli, NarudzbaBicikliSearchObject,
                                                                NarudzbaBicikliInsertR, NarudzbaBicikliUpdateR>
    {
        public NarudzbaBicikliController(INarudzbaBicikliService service) 
        : base(service){        }
    }
}
