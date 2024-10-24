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
    public class PromocijaBicikliController : BaseCRUDController<BikeHub.Model.PromocijaFM.PromocijaBicikli, PromocijaBicikliSearchObject,
                                                                  PromocijaBicikliInsertR, PromocijaBicikliUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public PromocijaBicikliController(IPromocijaBicikliService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }
        [AllowAnonymous]
        public override PagedResult<    BikeHub.Model.PromocijaFM.PromocijaBicikli> GetList([FromQuery] PromocijaBicikliSearchObject searchObject)
        {
            return base.GetList(searchObject);

        }
        [AllowAnonymous]
        public override BikeHub.Model.PromocijaFM.PromocijaBicikli GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.PromocijaFM.PromocijaBicikli Insert(PromocijaBicikliInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserBicikl(currentUsername, request.BiciklId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.PromocijaFM.PromocijaBicikli Update(int id, PromocijaBicikliUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var currentUser=_context.Korisniks.FirstOrDefault(x=>x.Username==currentUsername);
            if (currentUser != null)
            {
                var pocetnaPromocija = _context.PromocijaBiciklis.Find(id);
                if (pocetnaPromocija != null)
                {
                    var pocetniBicikl = _context.Bicikls.Find(pocetnaPromocija.BiciklId);
                    if (request.BiciklId > 0)
                    {
                        var noviBicikl = _context.Bicikls.Find(request.BiciklId);
                        if (noviBicikl != null && pocetniBicikl.KorisnikId == currentUser.KorisnikId)
                        {
                            if (noviBicikl.KorisnikId==currentUser.KorisnikId)
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
            var promocijaBicikl = _context.PromocijaBiciklis.Find(id);
            if (currentUsername != null && promocijaBicikl != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserBicikl(currentUsername, promocijaBicikl.BiciklId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
             return base.SoftDelete(id);
        }
        public override IActionResult Zavrsavanje(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var promocija = _context.PromocijaBiciklis.Find(id);
            if (promocija == null) return NotFound();

            var bicikl = _context.Bicikls.Find(promocija.BiciklId);
            if (bicikl == null) return NotFound();
            if (promocija.DatumZavrsetka < DateTime.Now)
            {
                promocija.Status = "zavrseno";
                _context.SaveChanges();
                return Ok("Promocija automatski završena jer je datum završetka istekao.");
            }
            if (currentUsername != null)
            {
                var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);

                if (currentUser != null && (currentUser.IsAdmin == true || bicikl.KorisnikId == currentUser.KorisnikId))
                {
                    promocija.Status = "zavrseno";
                    _context.SaveChanges();
                    return Ok("Promocija uspješno završena.");
                }
            }
            return Unauthorized("Nemate dozvolu za završavanje ove promocije.");
        }
    }
}
