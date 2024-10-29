using BikeHub.Services.Database;
using System.Security.Claims;

namespace BikeHubBck.Ostalo
{
    public class FunctionHelper
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly BikeHubDbContext _context;

        public FunctionHelper(IHttpContextAccessor httpContextAccessor, BikeHubDbContext context)
        {
            _httpContextAccessor = httpContextAccessor;
            _context = context;
        }

        public bool IsCurrentUser(string currentUsername, int korisnikID)
        {
            if(korisnikID != 0)
            {
                var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);
                return currentUser?.KorisnikId == korisnikID;
            }
            return false;
        }
        public bool IsUserAdmin(string currentUsername)
        {
            var currentUser = _context.Korisniks.FirstOrDefault(x => x.Username == currentUsername);
            if(currentUser == null || currentUser.IsAdmin==false) return false;
            return true;
        }
        public bool CurrentUserKorisnikInfo(string currentUsername, int korisnikInfoId)
        {
            if (korisnikInfoId != 0 && currentUsername != null)
            {
                var korisnikInfo = _context.KorisnikInfos.Find(korisnikInfoId);
                if (korisnikInfo != null)
                {
                    return IsCurrentUser(currentUsername, korisnikInfo.KorisnikId);
                }
            }
            return false;
        }
        public bool CurrentUserNarudzba(string currentUsername, int narudzbaId)
        {
            if(narudzbaId!= 0 && currentUsername!=null) 
            {
                var narudzba = _context.Narudzbas.Find(narudzbaId);
                if (narudzba != null)
                {
                return IsCurrentUser(currentUsername, narudzba.KorisnikId);
                }
            }
            return false;
        }
        public bool CurrentUserBicikl(string currentUsername, int biciklID)
        {
            if(biciklID != 0 && currentUsername != null)
            {
                var bicikl = _context.Bicikls.Find(biciklID);
                if (bicikl != null)
                {
                    return IsCurrentUser(currentUsername, bicikl.KorisnikId.Value);
                }
            }
            return false;
        }
        public bool CurrentUserDijelovi(string currentUsername, int dijeloviID)
        {
            if (dijeloviID != 0 && currentUsername != null)
            {
                var dijelovi = _context.Dijelovis.Find(dijeloviID);
                if (dijelovi != null)
                {
                    return IsCurrentUser(currentUsername, dijelovi.KorisnikId.Value);
                }
            }
            return false;
        }
        public bool CurrentUserRezervacija(string currentUsername, int rezervacijaID)
        {
            if (rezervacijaID != 0 && currentUsername != null)
            {
                var rezervacija = _context.RezervacijaServisas.Find(rezervacijaID);
                if (rezervacija != null)
                {
                    return IsCurrentUser(currentUsername, rezervacija.KorisnikId);
                }
            }
            return false;
        }
        public bool CurrentUserServiser(string currentUsername, int serviserID)
        {
            if (serviserID != 0 && currentUsername != null)
            {
                var servis = _context.Servisers.Find(serviserID);
                if (servis != null)
                {
                    return IsCurrentUser(currentUsername, servis.KorisnikId);
                }
            }
            return false;
        }
        public bool CurrentUserSlikaBicikl(string currentUsername, int slikaBiciklId)
        {
            if(slikaBiciklId!=0 && currentUsername != null)
            {
                var slikaBicikl=_context.SlikeBiciklis.Find(slikaBiciklId);
                if(slikaBicikl != null)
                {
                    return CurrentUserBicikl(currentUsername, slikaBicikl.BiciklId);
                }
            }
            return false;
        }
        public bool CurrentUserSlikaDijelovi(string currentUsername, int slikaDijelovilId)
        {
            if (slikaDijelovilId != 0 && currentUsername != null)
            {
                var slikaDijelovi = _context.SlikeDijelovis.Find(slikaDijelovilId);
                if (slikaDijelovi != null)
                {
                    return CurrentUserDijelovi(currentUsername, slikaDijelovi.DijeloviId);
                }
            }
            return false;
        }
    }
}
