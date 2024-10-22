using BikeHub.Model;
using BikeHub.Model.AdresaFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AdresaController : BaseCRUDController<BikeHub.Model.AdresaFM.Adresa, AdresaSearchObject,AdresaInsertR,AdresaUpdateR>
    {
        private BikeHubDbContext _context;
        public AdresaController(IAdresaService service , BikeHubDbContext context) 
        : base(service,context){ _context = context;   }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.AdresaFM.Adresa> GetList([FromQuery] AdresaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.AdresaFM.Adresa GetById(int id)
        {
            return base.GetById(id);
        }
        public override BikeHub.Model.AdresaFM.Adresa Insert(AdresaInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (currentUsername == null)
            {
                throw new UserException("Prijava je neuspješna.");
            }
            var currentUser = _context.Korisniks.FirstOrDefault(x=>x.Username== currentUsername);
            if (currentUser == null || currentUser.KorisnikId != request.KorisnikId)
            {
                throw new UserException("Ne možete dodati adresu za drugog korisnika.");
            }
            return base.Insert(request);
        }
        public override BikeHub.Model.AdresaFM.Adresa Update(int id, AdresaUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername == null)
            {
                throw new UserException("Prijava je neuspješna.");
            }
            var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);
            var curretAdres = _context.Adresas.FirstOrDefault(x => x.AdresaId == id);
            if (curretAdres == null)
            {
                throw new UserException("Adresa nije pronadjenja.");
            }
            if (currentUser == null || currentUser.KorisnikId != curretAdres.KorisnikId)
            {
                throw new UserException("Ne možete dodati adresu za drugog korisnika.");
            }
            return base.Update(id, request);
        }
        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername == null)
            {
                throw new UserException("Prijava je neuspješna.");
            }
            var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);
            var curretAdres = _context.Adresas.FirstOrDefault(x => x.AdresaId == id);
            if (curretAdres == null)
            {
                throw new UserException("Adresa nije pronadjenja.");
            }
            if (currentUser == null || currentUser.KorisnikId != curretAdres.KorisnikId )
            {
                if (currentUser.IsAdmin==false)
                {
                    throw new UserException("Ne možete izbrisati adresu za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
