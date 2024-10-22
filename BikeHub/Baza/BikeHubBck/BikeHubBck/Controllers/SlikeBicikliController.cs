using BikeHub.Model;
using BikeHub.Model.SlikeFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SlikeBicikliController : BaseController<SlikeBicikli, SlikeBicikliSearchObject>
    {
        public SlikeBicikliController(ISlikeBicikliService service) 
        : base(service){        }
        [AllowAnonymous]
        public override PagedResult<SlikeBicikli> GetList([FromQuery] SlikeBicikliSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override SlikeBicikli GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
