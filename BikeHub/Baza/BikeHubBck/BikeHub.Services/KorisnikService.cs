using Azure.Core;
using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class KorisnikService : BaseCRUDService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Database.Korisnik,
        KorisniciInsertR, KorisniciUpdateR>, IKorisnikService
    {
        public BasePrvaGrupaState<Model.KorisnikFM.Korisnik, Database.Korisnik,
        KorisniciInsertRHS, Database.Korisnik> _basePrvaGrupaState;
        private BikeHubDbContext _context;


        public KorisnikService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.KorisnikFM.Korisnik, Database.Korisnik,
        KorisniciInsertRHS, Database.Korisnik> basePrvaGrupaState) : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public Model.KorisnikFM.Korisnik Login(string username, string password)
        {
            var entity = Context.Korisniks.FirstOrDefault(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.LozinkaSalt, password);

            if (hash != entity.LozinkaHash)
            {
                return null;
            }

            return this.Mapper.Map<Model.KorisnikFM.Korisnik>(entity);
        }

        public override IQueryable<Database.Korisnik> AddFilter(KorisniciSearchObject search, IQueryable<Database.Korisnik> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                NoviQuery = NoviQuery.Where(x => x.Username.StartsWith(search.Username));
            }
            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                NoviQuery = NoviQuery.Where(x => x.Email.StartsWith(search.Email));
            }
            if (search?.IsAdmin != null)
            {
                NoviQuery = NoviQuery.Where(x => x.IsAdmin == search.IsAdmin);
            }
            if (search?.IsInfoIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.KorisnikInfos);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override Model.KorisnikFM.Korisnik GetById(int id)
        {
            var result = Context.Set<Database.Korisnik>()
                .Include(b => b.KorisnikInfos)
                .Include(b => b.Bicikls)//.Where(b=>b.Status== "aktivan")
                .Include(b => b.Dijelovis)//.Where(b => b.Status == "aktivan")
                .Include(b => b.Servisers)//.Where(b => b.Status == "aktivan")
                .Include(b => b.RezervacijaServisas)
                .FirstOrDefault(b => b.KorisnikId == id);

            if (result == null)
            {
                return null;
            }
            int brojBicikala = result.Bicikls.Where(b => b.Status=="aktivan").ToList().Count;
            int brojDijelova = result.Dijelovis.Where(b => b.Status == "aktivan").ToList().Count;
            int brojProizvoda = brojBicikala + brojDijelova;
            int ukupnaKolicinaBicikala = result.Bicikls.Where(b => b.Status == "aktivan").ToList().Sum(b => b.Kolicina);
            int ukupnaKolicinaDijelova = result.Dijelovis.Where(b => b.Status == "aktivan").ToList().Sum(d => d.Kolicina);
            int ukupnaKolicina = ukupnaKolicinaBicikala + ukupnaKolicinaDijelova;
            int brojRezervacija = result.RezervacijaServisas.Where(b=>b.KorisnikId==id).ToList().Count;

            var serviserStatus = result.Servisers.FirstOrDefault(s => s.KorisnikId == id);
            // Provjera da li je korisnik serviser
            string jeServiser = serviserStatus?.Status ?? null;
            var mappedKorisnik = Mapper.Map<Model.KorisnikFM.Korisnik>(result);
            mappedKorisnik.BrojRezervacija = brojRezervacija;
            mappedKorisnik.BrojProizvoda = brojProizvoda;
            mappedKorisnik.UkupnaKolicina = ukupnaKolicina;
            mappedKorisnik.JeServiser = jeServiser;

            return mappedKorisnik;
        }

        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);

            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);

            return Convert.ToBase64String(inArray);
        }

        public override void BeforeInsert(KorisniciInsertR request, Database.Korisnik entity)
        {
            if (request.Lozinka != request.LozinkaPotvrda)
            {
                throw new UserException("Lozinka i LozinkaPotvrda moraju biti iste");
            }
            if (request.Username.IsNullOrEmpty())
            {
                throw new UserException("Username mora biti unesen");
            }
            var usernameP = _context.Korisniks.FirstOrDefault(s => s.Username == request.Username);
            if (usernameP != null)
            {
                throw new UserException("Username je zauzet");
            }
            if (request.Email.IsNullOrEmpty())
            {
                throw new UserException("Email mora biti unesen");
            }
            var emailP = _context.Korisniks.FirstOrDefault(s => s.Email == request.Email);
            if (emailP != null)
            {
                throw new UserException("Email je zauzet");
            }
            entity.Username = request.Username;
            entity.Email = request.Email;
            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            base.BeforeInsert(request, entity);
        }

        public override Model.KorisnikFM.Korisnik Insert(KorisniciInsertR request)
        {
            var entity = Mapper.Map<Database.Korisnik>(request);
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            entity.IsAdmin = false;
            var noviRequest = Mapper.Map<KorisniciInsertRHS>(entity);
            return state.Insert(noviRequest);
        }

        public override void BeforeUpdate(KorisniciUpdateR request, Database.Korisnik entity)
        {
            var korisnik = _context.Korisniks.FirstOrDefault(x=>x.Username==request.Username);
            if(korisnik != null)
            {
                throw new UserException("Username je zauzet");
            }
            if (!request.Username.IsNullOrEmpty())
            {
                entity.Username = request.Username;
            }
            if (!request.Email.IsNullOrEmpty())
            {
                var emailP=_context.Korisniks.FirstOrDefault(e=>e.Email==request.Email);
                if (emailP != null)
                {
                    throw new UserException("Email je zauzet");
                }
                entity.Email = request.Email;
            }
            bool isPasswordChangeRequested = !string.IsNullOrEmpty(request.StaraLozinka) &&
                                 !string.IsNullOrEmpty(request.Lozinka) &&
                                 !string.IsNullOrEmpty(request.LozinkaPotvrda);

            if (isPasswordChangeRequested)
            {
                string oldPasswordHash = GenerateHash(entity.LozinkaSalt, request.StaraLozinka);
                if (oldPasswordHash != entity.LozinkaHash)
                {
                    throw new UserException("Stara lozinka nije ispravna");
                }
                if (request.Lozinka != request.LozinkaPotvrda)
                {
                    throw new UserException("Lozinka i LozinkaPotvrda moraju biti iste");
                }
                entity.LozinkaSalt = GenerateSalt();
                entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            }
            if(request.Username.IsNullOrEmpty() && !isPasswordChangeRequested
                && request.Email.IsNullOrEmpty())
            {
                throw new UserException("Potreno je izvrsiti promjenu na nekom od objekata");
            }

            base.BeforeUpdate(request, entity);
        }

        public override Model.KorisnikFM.Korisnik Update(int id, KorisniciUpdateR request)
        {
            var set = Context.Set<Database.Korisnik>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            return state.Update(id, entity);
        }

        public override void Aktivacija(int id, bool aktivacija)
        {
            var set = Context.Set<Database.Korisnik>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            string status = "";
            if (aktivacija)
            {
                status = "aktivan";
            }
            else
            {
                status = "vracen";
            }
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            updateKorisnikInfoStatus(id, status);
            base.Aktivacija(id, aktivacija);
        }

        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }
            updateKorisnikInfoStatus(id, "obrisan");
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            updateKorisnikInfoStatus(id, "obrisan");
            state.Delete(id);
        }

        public Model.KorisnikFM.Korisnik Promjeni(int id, KorisniciUpdateR request)
        {
            var entity = Context.Korisniks.Find(id);
            Mapper.Map(request, entity);
            if (request.Lozinka != null)
            {
                entity.LozinkaSalt = GenerateSalt();
                entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            }
            Context.SaveChanges();
            return Mapper.Map<Model.KorisnikFM.Korisnik>(entity);
            throw new NotImplementedException();
        }

        public override void Zavrsavanje(int id)
        {
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }

        public void updateKorisnikInfoStatus(int korisnikId, string status)
        {
            var korisnikInfo = _context.KorisnikInfos.FirstOrDefault(x => x.KorisnikId == korisnikId);
            if (korisnikInfo != null)
            {
                korisnikInfo.Status = status;
                _context.Update(korisnikInfo);
            }
        }

        public IActionResult DodajNovogAdmina(KorisniciInsertR request)
        {
            try
            {
                var entity = Mapper.Map<Database.Korisnik>(request);
                BeforeInsert(request, entity);
                entity.IsAdmin = true;

                var state = _basePrvaGrupaState.CreateState("kreiran");
                var noviRequest = Mapper.Map<KorisniciInsertRHS>(entity);
                state.Insert(noviRequest);

                // Vraća uspješnu poruku
                return new OkObjectResult(new { message = "Novi admin je uspješno dodan." });
            }
            catch (UserException ex)
            {
                // Vraća grešku s porukom korisnika
                return new BadRequestObjectResult(new
                {
                    errors = new
                    {
                        userError = new[] { ex.Message }
                    }
                });
            }
            catch (Exception ex)
            {
                // Vraća neočekivanu grešku
                return new ObjectResult(new
                {
                    errors = new
                    {
                        serverError = new[] { "Došlo je do neočekivane greške.", ex.Message }
                    }
                })
                {
                    StatusCode = 500
                };
            }
        }
    }
}
