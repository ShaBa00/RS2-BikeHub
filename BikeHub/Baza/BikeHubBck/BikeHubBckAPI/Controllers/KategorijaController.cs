using BikeHub.Model;
using BikeHub.Model.KategorijaFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KategorijaController : BaseCRUDController<BikeHub.Model.KategorijaFM.Kategorija, KategorijaSearchObject, KategorijaInsertR, KategorijaUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public KategorijaController(IKategorijaService service, BikeHubDbContext context,FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context;   }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.KategorijaFM.Kategorija> GetList([FromQuery] KategorijaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.KategorijaFM.Kategorija GetById(int id)
        {
            return base.GetById(id);
        }
        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (_functionHelper.IsUserAdmin(currentUsername))
            {
                return base.SoftDelete(id);
            }
            else
            {
                throw new UserException("Samo administratori mogu izvršiti aktivaciju.");
            }
        }
    }
}
