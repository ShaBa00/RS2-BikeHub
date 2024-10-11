using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaDijeloviController : BaseCRUDController<NarudzbaDijelovi, NarudzbaDijeloviSearchObject,
                                                                 NarudzbaDijeloviInsertR, NarudzbaDijeloviUpdateR>
    {
        public NarudzbaDijeloviController(INarudzbaDijeloviService service) 
        : base(service){        }
    }
}
