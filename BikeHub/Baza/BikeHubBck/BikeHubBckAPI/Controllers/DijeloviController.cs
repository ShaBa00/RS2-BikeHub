using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using BikeHub.Model.DijeloviFM;
using MapsterMapper;
using BikeHub.Model;
using Microsoft.AspNetCore.Authorization;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using System.Security.Claims;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DijeloviController : BaseCRUDController<BikeHub.Model.DijeloviFM.Dijelovi, DijeloviSearchObject,DijeloviInsertR,DijeloviUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public DijeloviController(IDijeloviService service, BikeHubDbContext context, FunctionHelper functionHelper)
        :base(service,context){ _functionHelper = functionHelper; _context = context; }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.DijeloviFM.Dijelovi> GetList([FromQuery] DijeloviSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.DijeloviFM.Dijelovi GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.DijeloviFM.Dijelovi Insert(DijeloviInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }
        public override BikeHub.Model.DijeloviFM.Dijelovi Update(int id, DijeloviUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var Dijelovi = _context.Dijelovis.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && Dijelovi != null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, Dijelovi.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
