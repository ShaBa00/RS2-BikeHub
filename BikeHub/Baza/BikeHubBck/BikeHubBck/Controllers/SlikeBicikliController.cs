using BikeHub.Model;
using BikeHub.Model.SlikeFM;
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
    public class SlikeBicikliController : BaseCRUDController<BikeHub.Model.SlikeFM.SlikeBicikli, SlikeBicikliSearchObject,
        SlikeBicikliInsertR, SlikeBicikliUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public SlikeBicikliController(ISlikeBicikliService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service,context){ _functionHelper = functionHelper; _context = context; }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.SlikeFM.SlikeBicikli> GetList([FromQuery] SlikeBicikliSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        
        public override BikeHub.Model.SlikeFM.SlikeBicikli Insert([FromForm] SlikeBicikliInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserBicikl(currentUsername, request.BiciklId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.SlikeFM.SlikeBicikli Update(int id, [FromForm] SlikeBicikliUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserSlikaBicikl(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
                if (!_functionHelper.CurrentUserBicikl(currentUsername, request.BiciklId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }

        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserSlikaBicikl(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }

        public override IActionResult Aktivacija(int id, [FromQuery] bool aktivacija)
        {
            throw new UserException("Nije moguce izvrsiti aktivaciju slike na ovaj nacin vec se mora ista izvrsit kroz api od " +
            "Bicikl entiteta");
        }

    }
}
