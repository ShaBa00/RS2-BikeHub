using BikeHub.Model;
using BikeHub.Model.SlikeFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SlikeDijeloviController : BaseController<SlikeDijelovi, SlikeDijeloviSearchObject>
    {
        public SlikeDijeloviController(ISlikeDijeloviService service) 
        : base(service){        }

        [AllowAnonymous]
        public override PagedResult<SlikeDijelovi> GetList([FromQuery] SlikeDijeloviSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override SlikeDijelovi GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
