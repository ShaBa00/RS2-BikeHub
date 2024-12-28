using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
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
    public class KorisnikInfoController : BaseCRUDController<BikeHub.Model.KorisnikFM.KorisnikInfo, KorisnikInfoSearchObject,KorisnikInfoInsertR,KorisnikInfoUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public KorisnikInfoController(IKorisnikInfoService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }
        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.KorisnikFM.KorisnikInfo> GetList([FromQuery] KorisnikInfoSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.KorisnikFM.KorisnikInfo GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.KorisnikFM.KorisnikInfo Insert(KorisnikInfoInsertR request)
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
        public override BikeHub.Model.KorisnikFM.KorisnikInfo Update(int id, KorisnikInfoUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserKorisnikInfo(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var KorisnikInfo = _context.KorisnikInfos.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && KorisnikInfo != null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, KorisnikInfo.KorisnikId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
