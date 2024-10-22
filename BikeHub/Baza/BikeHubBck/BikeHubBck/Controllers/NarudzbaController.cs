using BikeHub.Model;
using BikeHub.Model.NarudzbaFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaController : BaseCRUDController<BikeHub.Model.NarudzbaFM.Narudzba, NarudzbaSearchObject, NarudzbaInsertR, NarudzbaUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public NarudzbaController(INarudzbaService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        public override BikeHub.Model.NarudzbaFM.Narudzba Insert(NarudzbaInsertR request)
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

        public override BikeHub.Model.NarudzbaFM.Narudzba Update(int id, NarudzbaUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var nardzba=_context.Narudzbas.FirstOrDefault(x=>x.NarudzbaId==id);
            if (currentUsername != null && nardzba !=null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, nardzba.KorisnikId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var Narudzba = _context.Narudzbas.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && Narudzba != null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, Narudzba.KorisnikId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id); 
        }
    }
}
