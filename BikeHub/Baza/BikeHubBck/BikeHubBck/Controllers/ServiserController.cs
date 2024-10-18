using BikeHub.Model;
using BikeHub.Model.ServisFM;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ServiserController : BaseCRUDController<Serviser, ServiserSearchObject, ServiserInsertR, ServiserUpdateR>
    {
        public ServiserController(IServiserService service) 
        : base(service){        }

        [AllowAnonymous]
        public override PagedResult<Serviser> GetList([FromQuery] ServiserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
