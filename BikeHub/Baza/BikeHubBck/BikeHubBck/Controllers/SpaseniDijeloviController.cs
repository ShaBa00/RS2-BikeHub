using BikeHub.Model;
using BikeHub.Model.SpaseniFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SpaseniDijeloviController : BaseCRUDController<BikeHub.Model.SpaseniFM.SpaseniDijelovi, SpaseniDijeloviSearchObject, SpaseniDijeloviInsertR, SpaseniDijeloviUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public SpaseniDijeloviController(ISpaseniDijeloviService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service,context){ _functionHelper = functionHelper; _context = context; }

        public override BikeHub.Model.SpaseniFM.SpaseniDijelovi Insert(SpaseniDijeloviInsertR request)
        {

            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (request.KorisnikId > 0)
                {
                    if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId.Value))
                    {
                        throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                    }
                }
                else
                {
                    throw new UserException("Potrebno je unjeti korisnikId.");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.SpaseniFM.SpaseniDijelovi Update(int id, SpaseniDijeloviUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var spaseniDijelovi = _context.SpaseniDijelovis.Find(id);
            var stariZapis = _context.SpaseniDijelovis.Find(id);

            if (currentUsername != null && spaseniDijelovi != null)
            {
                if (request.KorisnikId > 0)
                {
                    if (stariZapis.KorisnikId != request.KorisnikId)
                    {
                        throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                    }
                    if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId.Value))
                    {
                        throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                    }
                }
                else
                {
                    throw new UserException("Potrebno je unjeti korisnikId.");
                }
            }
            return base.Update(id, request);
        }

        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var spaseniDijelovi = _context.SpaseniDijelovis.Find(id);
            if (currentUsername != null && spaseniDijelovi != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, spaseniDijelovi.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
