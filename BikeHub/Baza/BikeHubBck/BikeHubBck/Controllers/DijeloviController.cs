using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using BikeHub.Model.DijeloviFM;
using MapsterMapper;
using BikeHub.Model;
using Microsoft.AspNetCore.Authorization;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DijeloviController : BaseCRUDController<Dijelovi, DijeloviSearchObject,DijeloviInsertR,DijeloviUpdateR>
    {
        public DijeloviController(IDijeloviService service)
        :base(service){        }

        [AllowAnonymous]
        public override PagedResult<Dijelovi> GetList([FromQuery] DijeloviSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
