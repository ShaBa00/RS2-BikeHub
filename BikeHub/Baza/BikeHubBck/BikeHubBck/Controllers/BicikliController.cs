using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using MapsterMapper;
using BikeHub.Model.BicikliFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BicikliController : BaseController<Bicikli,BicikliSearchObject>
    {
        public BicikliController(IBicikliService service)
        : base(service){        }
    }
}
