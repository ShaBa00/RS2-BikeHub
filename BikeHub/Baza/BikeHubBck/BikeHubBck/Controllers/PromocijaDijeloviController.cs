using BikeHub.Model;
using BikeHub.Model.PromocijaFM;
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
    public class PromocijaDijeloviController : BaseCRUDController<BikeHub.Model.PromocijaFM.PromocijaDijelovi, PromocijaDijeloviSearchObject,
                                                                    PromocijaDijeloviInsertR, PromocijaDijeloviUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public PromocijaDijeloviController(IPromocijaDijeloviService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }
        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.PromocijaFM.PromocijaDijelovi> GetList([FromQuery] PromocijaDijeloviSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override BikeHub.Model.PromocijaFM.PromocijaDijelovi GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.PromocijaFM.PromocijaDijelovi Insert(PromocijaDijeloviInsertR request)
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
        public override BikeHub.Model.PromocijaFM.PromocijaDijelovi Update(int id, PromocijaDijeloviUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);
            if (currentUser != null)
            {
                var pocetnaPromocija = _context.PromocijaDijelovis.Find(id);
                if (pocetnaPromocija != null)
                {
                    var pocetniDio = _context.Dijelovis.Find(pocetnaPromocija.DijeloviId);
                    if (request.DijeloviId > 0)
                    {
                        var noviDijelovi = _context.Dijelovis.Find(request.DijeloviId);
                        if (noviDijelovi != null && pocetniDio.KorisnikId == currentUser.KorisnikId)
                        {
                            if (noviDijelovi.KorisnikId == currentUser.KorisnikId)
                            {
                                return base.Update(id, request);
                            }
                            else
                            {
                                throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                            }
                        }
                        else
                        {
                            throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                        }
                    }

                }
            }
            else
            {
                throw new UserException("Ne možete unositi podatke za drugog korisnika.");
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var promocijaDijelovi = _context.PromocijaDijelovis.Find(id);
            if (currentUsername != null && promocijaDijelovi != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserDijelovi(currentUsername, promocijaDijelovi.DijeloviId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
