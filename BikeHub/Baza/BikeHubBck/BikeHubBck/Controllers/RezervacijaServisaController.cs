using BikeHub.Model;
using BikeHub.Model.ServisFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RezervacijaServisaController : BaseCRUDController<BikeHub.Model.ServisFM.RezervacijaServisa, RezervacijaServisaSearchObject,
                                                                    RezervacijaServisaInsertR, RezervacijaServisaUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public RezervacijaServisaController(IRezervacijaServisaService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        public override BikeHub.Model.ServisFM.RezervacijaServisa Insert(RezervacijaServisaInsertR request)
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

        public override BikeHub.Model.ServisFM.RezervacijaServisa Update(int id, RezervacijaServisaUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserRezervacija(currentUsername, id))
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
                if (!_functionHelper.CurrentUserRezervacija(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
