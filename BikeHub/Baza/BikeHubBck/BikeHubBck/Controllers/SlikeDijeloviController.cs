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
    public class SlikeDijeloviController : BaseCRUDController<BikeHub.Model.SlikeFM.SlikeDijelovi, SlikeDijeloviSearchObject,
        SlikeDijeloviInsertR, SlikeDijeloviUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public SlikeDijeloviController(ISlikeDijeloviService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service,context) { _functionHelper = functionHelper; _context = context; }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.SlikeFM.SlikeDijelovi> GetList([FromQuery] SlikeDijeloviSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        public override BikeHub.Model.SlikeFM.SlikeDijelovi Insert( SlikeDijeloviInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserDijelovi(currentUsername, request.DijeloviId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.SlikeFM.SlikeDijelovi Update(int id,  SlikeDijeloviUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserSlikaDijelovi(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
                if (!_functionHelper.CurrentUserDijelovi(currentUsername, request.DijeloviId.Value))
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
                if (!_functionHelper.CurrentUserSlikaDijelovi(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }

        public override IActionResult Aktivacija(int id, [FromQuery] bool aktivacija)
        {
            throw new UserException("Nije moguce izvrsiti aktivaciju slike na ovaj nacin vec se mora ista izvrsit kroz api od " +
                "Dijelovi entiteta");
        }
    }
}
