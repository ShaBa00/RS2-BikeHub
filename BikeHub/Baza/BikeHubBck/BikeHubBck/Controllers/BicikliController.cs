using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using MapsterMapper;
using BikeHub.Model.BicikliFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using BikeHub.Model;
using Microsoft.AspNetCore.Authorization;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BicikliController : BaseCRUDController<Bicikli,BicikliSearchObject,BicikliInsertR,BicikliUpdateR>
    {
        public BicikliController(IBicikliService service)
        : base(service){        }

        [AllowAnonymous]
        public override PagedResult<Bicikli> GetList([FromQuery] BicikliSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
