using BikeHub.Model;
using BikeHub.Model.DijeloviFM;
using BikeHub.Model.KorisnikFM;
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
    public class DijeloviService : BaseCRUDService<Model.DijeloviFM.Dijelovi,Model.DijeloviFM.DijeloviSearchObject,
        Database.Dijelovi,Model.DijeloviFM.DijeloviInsertR, Model.DijeloviFM.DijeloviUpdateR>, IDijeloviService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.DijeloviFM.Dijelovi,Database.Dijelovi, Model.DijeloviFM.DijeloviInsertR,
            Model.DijeloviFM.DijeloviUpdateR> _basePrvaGrupaState;

        public DijeloviService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.DijeloviFM.Dijelovi, Database.Dijelovi, Model.DijeloviFM.DijeloviInsertR,
            Model.DijeloviFM.DijeloviUpdateR> basePrvaGrupaState)
        : base(context, mapper){ _context = context; _basePrvaGrupaState = basePrvaGrupaState; }
        public override IQueryable<Database.Dijelovi> AddFilter(DijeloviSearchObject search, IQueryable<Database.Dijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                NoviQuery = NoviQuery.Where(x => x.Naziv.StartsWith(search.Naziv));
            }
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            if (search?.Kolicina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Kolicina == search.Kolicina);
            }
            if (!string.IsNullOrWhiteSpace(search?.Opis))
            {
                NoviQuery = NoviQuery.Where(x => x.Opis.StartsWith(search.Opis));
            }
            if (search?.KategorijaId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KategorijaId == search.KategorijaId);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(DijeloviInsertR request, Database.Dijelovi entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new UserException("Naziv dijela ne smije biti prazan");
            }
            entity.Naziv = request.Naziv;
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena dijela mora biti veća od nule");
            }
            entity.Cijena = request.Cijena;
            var Korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (Korisnik == null)
            {
                throw new UserException("Korisnik s tim Id-om ne postoji");
            }
            entity.KorisnikId = request.KorisnikId;
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina dijela mora biti veća od nule");
            }
            entity.Kolicina = request.Kolicina;
            if (request.KategorijaId <= 0)
            {
                throw new UserException("Kategorija mora biti odabrana");
            }
            var kategorija = _context.Kategorijas.Find(request.KategorijaId);
            if (kategorija == null)
            {
                throw new UserException("Kategorija sa datim ID-om ne postoji");
            }
            entity.KategorijaId = request.KategorijaId;
            if (string.IsNullOrWhiteSpace(request.Opis))
            {
                throw new UserException("Opis dijela ne smije biti prazan");
            }
            entity.Opis = request.Opis;
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(DijeloviUpdateR request, Database.Dijelovi entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                entity.Naziv = request.Naziv;
            }
            if (request.KorisnikId > 0)
            {
                var Korisnik = _context.Korisniks.Find(request.KorisnikId);
                if (Korisnik != null)
                {
                    entity.KorisnikId = request.KorisnikId;
                }
            }
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new UserException("Cijena dijela mora biti veća od nule");
                }
                entity.Cijena = request.Cijena.Value;
            }
            if (request.Kolicina.HasValue)
            {
                entity.Kolicina = request.Kolicina.Value;
            }
            if (request.KategorijaId.HasValue)
            {
                var kategorija = _context.Kategorijas.Find(request.KategorijaId);
                if (kategorija == null)
                {
                    throw new UserException("Kategorija sa datim ID-om ne postoji");
                }
                entity.KategorijaId = request.KategorijaId.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Opis))
            {
                entity.Opis = request.Opis;
            }
            base.BeforeUpdate(request, entity);
        }
        public override Model.DijeloviFM.Dijelovi Insert(DijeloviInsertR request)
        {
            var entity = new Database.Dijelovi();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Model.DijeloviFM.Dijelovi Update(int id, DijeloviUpdateR request)
        {
            var set = Context.Set<Database.Dijelovi>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            return state.Update(id, request);
        }
        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var state = _basePrvaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }

        public override void Zavrsavanje(int id)
        {
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }
    }
}
