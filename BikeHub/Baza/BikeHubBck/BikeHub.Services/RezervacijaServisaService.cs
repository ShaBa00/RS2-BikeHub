using BikeHub.Model.ServisFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class RezervacijaServisaService : BaseCRUDService<Model.ServisFM.RezervacijaServisa, Model.ServisFM.RezervacijaServisaSearchObject,
        Database.RezervacijaServisa, Model.ServisFM.RezervacijaServisaInsertR, Model.ServisFM.RezervacijaServisaUpdateR>, IRezervacijaServisaService
    {
        private BikeHubDbContext _context;
        public RezervacijaServisaService(BikeHubDbContext context, IMapper mapper)
        : base(context, mapper) { _context = context; }
        public override IQueryable<Database.RezervacijaServisa> AddFilter(RezervacijaServisaSearchObject search, IQueryable<Database.RezervacijaServisa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Ocjena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Ocjena == search.Ocjena);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(RezervacijaServisaInsertR request, Database.RezervacijaServisa entity)
        {
            if (request?.KorisnikId == null)
            {
                throw new Exception("KorisnikId ne smije biti null.");
            }
            if (request?.ServiserId == null)
            {
                throw new Exception("ServiserId ne smije biti null.");
            }
            if (request?.DatumKreiranja == null)
            {
                throw new Exception("Datum kreiranja ne smije biti null.");
            }
            if (request?.DatumRezervacije == null)
            {
                throw new Exception("Datum rezervacije ne smije biti null.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new Exception("Korisnik sa datim ID-om ne postoji.");
            }
            var serviser = _context.Servisers.Find(request.ServiserId);
            if (serviser == null)
            {
                throw new Exception("Serviser sa datim ID-om ne postoji.");
            }
            if (request.DatumKreiranja > request.DatumRezervacije)
            {
                throw new Exception("Datum kreiranja ne smije biti veći od datuma rezervacije.");
            }
            entity.Ocjena = 0;
            entity.Status = "U procesu";
            entity.KorisnikId = request.KorisnikId;
            entity.ServiserId = request.ServiserId;
            entity.DatumKreiranja = request.DatumKreiranja;
            entity.DatumRezervacije = request.DatumRezervacije;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(RezervacijaServisaUpdateR request, Database.RezervacijaServisa entity)
        {
            if (request.DatumKreiranja.HasValue)
            {
                if (request.DatumKreiranja > (request.DatumRezervacije.HasValue ? request.DatumRezervacije : entity.DatumRezervacije))
                {
                    throw new Exception("Datum kreiranja ne smije biti veći od datuma rezervacije.");
                }
                entity.DatumKreiranja = request.DatumKreiranja.Value;
            }
            if (request.DatumRezervacije.HasValue)
            {
                if (request.DatumRezervacije < (request.DatumKreiranja.HasValue ? request.DatumKreiranja : entity.DatumKreiranja))
                {
                    throw new Exception("Datum rezervacije ne smije biti manji od datuma kreiranja.");
                }
                entity.DatumRezervacije = request.DatumRezervacije.Value;
            }
            if (request.Ocjena.HasValue)
            {
                if (request.Ocjena < 1 || request.Ocjena > 5)
                {
                    throw new Exception("Ocjena mora biti broj između 1 i 5.");
                }
                entity.Ocjena = request.Ocjena;
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
