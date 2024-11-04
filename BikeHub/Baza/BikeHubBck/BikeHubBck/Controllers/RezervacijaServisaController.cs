using BikeHub.Model;
using BikeHub.Model.ServisFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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

        public override IActionResult Aktivacija(int id, [FromQuery] bool aktivacija)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (currentUsername != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.Aktivacija(id,aktivacija);
                }
                var rezervacija = _context.RezervacijaServisas.Include(r => r.Serviser)
                                                              .FirstOrDefault(r => r.RezervacijaId == id);
                if (rezervacija == null)
                {
                    throw new UserException("Rezervacija servisa nije pronađena.");
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, rezervacija.Serviser.KorisnikId))
                {
                    throw new UserException("Nemate pravo aktivirati ili vratiti ovu rezervaciju.");
                }
                _service.Aktivacija(id, aktivacija);

                return Ok("Rezervacija uspješno aktivirana/vracena.");
            }
            return Unauthorized("Korisnik nije prijavljen.");
        }

        public override IActionResult Zavrsavanje(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (currentUsername != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.Zavrsavanje(id);
                }
                var rezervacija = _context.RezervacijaServisas.Include(r => r.Serviser)
                                                              .FirstOrDefault(r => r.RezervacijaId == id);
                if (rezervacija == null)
                {
                    throw new UserException("Rezervacija servisa nije pronađena.");
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, rezervacija.Serviser.KorisnikId))
                {
                    throw new UserException("Nemate pravo završiti ovu rezervaciju.");
                }
                _service.Zavrsavanje(id);

                return Ok("Rezervacija uspješno završena.");
            }

            return Unauthorized("Korisnik nije prijavljen.");
        }


        [AllowAnonymous]
        [HttpGet("slobodni-dani")]
        public IActionResult GetSlobodniDani(int serviserId, int mjesec, int godina)
        {
            if (mjesec == 0)
            {
                mjesec = 1;
            }
            if (godina == 0)
            {
                godina = 2024;
            }
            var serviser = _context.Servisers.FirstOrDefault(s => s.ServiserId == serviserId);
            if (serviser == null)
            {
                return NotFound($"Serviser sa ID-om {serviserId} ne postoji.");
            }

            var trenutniDatum = DateTime.Now;

            var zauzetiDani = _context.RezervacijaServisas
                .Where(r => r.ServiserId == serviserId
                            && r.DatumRezervacije.Month == mjesec
                            && r.DatumRezervacije.Year == godina)
                .Select(r => r.DatumRezervacije.Day)
                .ToList();

            var brojDanaUMjesecu = DateTime.DaysInMonth(godina, mjesec);

            var slobodniDani = Enumerable.Range(1, brojDanaUMjesecu)
                .Where(dan => !zauzetiDani.Contains(dan) &&
                              (godina > trenutniDatum.Year ||
                              (godina == trenutniDatum.Year && mjesec > trenutniDatum.Month) ||
                              (godina == trenutniDatum.Year && mjesec == trenutniDatum.Month && dan > trenutniDatum.Day))) 
                .ToList();

            return Ok(slobodniDani);
        }
    }
}
