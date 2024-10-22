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
    public class NarudzbaBicikliController : BaseCRUDController<BikeHub.Model.NarudzbaFM.NarudzbaBicikli, NarudzbaBicikliSearchObject,
                                                                NarudzbaBicikliInsertR, NarudzbaBicikliUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public NarudzbaBicikliController(INarudzbaBicikliService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        public override BikeHub.Model.NarudzbaFM.NarudzbaBicikli Insert(NarudzbaBicikliInsertR request)
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
        public override BikeHub.Model.NarudzbaFM.NarudzbaBicikli Update(int id, NarudzbaBicikliUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var narudzbaBicikl = _context.NarudzbaBiciklis.Find(id);
            if (currentUsername != null && narudzbaBicikl!=null)
            {
                if (!_functionHelper.CurrentUserNarudzba(currentUsername, narudzbaBicikl.NarudzbaId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var narudzbaBicikl = _context.NarudzbaBiciklis.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && narudzbaBicikl != null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserNarudzba(currentUsername, narudzbaBicikl.NarudzbaId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
