using Microsoft.AspNetCore.Mvc;
using BikeHub.Services;
using BikeHub.Model.KorisnikFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using BikeHub.Model;
using Microsoft.AspNetCore.Authorization;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseCRUDController<BikeHub.Model.KorisnikFM.Korisnik, KorisniciSearchObject,KorisniciInsertR,KorisniciUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public KorisnikController(IKorisnikService service, BikeHubDbContext context, FunctionHelper functionHelper)
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.KorisnikFM.Korisnik> GetList([FromQuery] KorisniciSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.KorisnikFM.Korisnik GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.KorisnikFM.Korisnik Update(int id, KorisniciUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null )
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
