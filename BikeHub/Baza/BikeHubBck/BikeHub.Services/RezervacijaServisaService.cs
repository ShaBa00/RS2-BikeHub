using BikeHub.Model;
using BikeHub.Model.ServisFM;
using BikeHub.Services.BikeHubStateMachine;
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
        public BaseDrugaGrupaState<Model.ServisFM.RezervacijaServisa, Database.RezervacijaServisa,
    Model.ServisFM.RezervacijaServisaInsertR, Model.ServisFM.RezervacijaServisaUpdateR> _baseDrugaGrupaState;

        public RezervacijaServisaService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.ServisFM.RezervacijaServisa, Database.RezervacijaServisa,
            Model.ServisFM.RezervacijaServisaInsertR, Model.ServisFM.RezervacijaServisaUpdateR> baseDrugaGrupaState)
            : base(context, mapper)
            {
                _context = context;
                _baseDrugaGrupaState = baseDrugaGrupaState;
            }

        public override IQueryable<Database.RezervacijaServisa> AddFilter(RezervacijaServisaSearchObject search, IQueryable<Database.RezervacijaServisa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.ServiserId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.ServiserId == search.ServiserId);
            }
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
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
                throw new UserException("KorisnikId ne smije biti null.");
            }
            if (request?.ServiserId == null)
            {
                throw new UserException("ServiserId ne smije biti null.");
            }
            if (request?.DatumKreiranja == null)
            {
                throw new UserException("Datum kreiranja ne smije biti null.");
            }
            if (request?.DatumRezervacije == null)
            {
                throw new UserException("Datum rezervacije ne smije biti null.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji.");
            }
            var serviser = _context.Servisers.Find(request.ServiserId);
            if (serviser == null)
            {
                throw new UserException("Serviser sa datim ID-om ne postoji.");
            }
            if (request.DatumKreiranja > request.DatumRezervacije)
            {
                throw new UserException("Datum kreiranja ne smije biti veći od datuma rezervacije.");
            }
            if (request.DatumRezervacije.Date <= DateTime.Now.Date)
            {
                throw new UserException("Datum rezervacije mora biti u budućnosti.");
            }
            var existingReservation = _context.RezervacijaServisas
                .Where(r => r.ServiserId == request.ServiserId && r.DatumRezervacije.Date == request.DatumRezervacije.Date)
                .FirstOrDefault();

            if (existingReservation != null && existingReservation.Status != "obrisan")
            {
                throw new UserException($"Serviser već ima rezervaciju za {request.DatumRezervacije.Date.ToShortDateString()}.");
            }

            entity.KorisnikId = request.KorisnikId;
            entity.ServiserId = request.ServiserId;
            entity.DatumKreiranja = request.DatumKreiranja;
            entity.DatumRezervacije = request.DatumRezervacije;
            base.BeforeInsert(request, entity);
        }


        public override Model.ServisFM.RezervacijaServisa Insert(RezervacijaServisaInsertR request)
        {
            var entity = new Database.RezervacijaServisa();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(RezervacijaServisaUpdateR request, Database.RezervacijaServisa entity)
        {
            if (request.Ocjena.HasValue)
            {
                if (request.Ocjena < 1 || request.Ocjena > 5)
                {
                    throw new UserException("Ocjena mora biti broj između 1 i 5.");
                }
                entity.Ocjena = request.Ocjena;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.ServisFM.RezervacijaServisa Update(int id, RezervacijaServisaUpdateR request)
        {
            var set = Context.Set<Database.RezervacijaServisa>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            if (request.Ocjena.HasValue && request.Ocjena >= 1 && request.Ocjena <= 5 )
            {
                entity.Ocjena = request.Ocjena.Value;
                _context.Update(entity);
                _context.SaveChanges();
                return Mapper.Map<Model.ServisFM.RezervacijaServisa>(entity); 
            }
            BeforeUpdate(request, entity);
            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            return state.Update(id, request);
        }

        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }

        public override void Zavrsavanje(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            state.MarkAsFinished(id);
        }
    }
}
