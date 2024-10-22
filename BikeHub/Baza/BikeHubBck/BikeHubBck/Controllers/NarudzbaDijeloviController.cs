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
    public class NarudzbaDijeloviController : BaseCRUDController<BikeHub.Model.NarudzbaFM.NarudzbaDijelovi, NarudzbaDijeloviSearchObject,
                                                                 NarudzbaDijeloviInsertR, NarudzbaDijeloviUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public NarudzbaDijeloviController(INarudzbaDijeloviService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        public override BikeHub.Model.NarudzbaFM.NarudzbaDijelovi Insert(NarudzbaDijeloviInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserNarudzba(currentUsername, request.NarudzbaId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }
        public override BikeHub.Model.NarudzbaFM.NarudzbaDijelovi Update(int id, NarudzbaDijeloviUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var narudzbaDijelovi = _context.NarudzbaDijelovis.Find(id);
            if (currentUsername != null && narudzbaDijelovi!=null)
            {
                if (!_functionHelper.CurrentUserNarudzba(currentUsername, narudzbaDijelovi.NarudzbaId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var narudzbaDijelovi = _context.NarudzbaDijelovis.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && narudzbaDijelovi != null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserNarudzba(currentUsername, narudzbaDijelovi.NarudzbaId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
