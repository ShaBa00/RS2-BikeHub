using BikeHub.Model;
using BikeHub.Model.DijeloviFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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

        private readonly SlikeDijeloviService _slikeDijeloviService;

        public DijeloviService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.DijeloviFM.Dijelovi,
            Database.Dijelovi, Model.DijeloviFM.DijeloviInsertR,
            Model.DijeloviFM.DijeloviUpdateR> basePrvaGrupaState, ISlikeDijeloviService slikeDijeloviService)
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
            _slikeDijeloviService = (SlikeDijeloviService)slikeDijeloviService;
        }
        public override IQueryable<Database.Dijelovi> AddFilter(DijeloviSearchObject search, IQueryable<Database.Dijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                NoviQuery = NoviQuery.Where(x => x.Naziv.Contains(search.Naziv));
            }
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.PocetnaCijena != null && search?.KrajnjaCijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena >= search.PocetnaCijena && x.Cijena <= search.KrajnjaCijena);
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
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (search.isSlikaIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.SlikeDijelovis.Where(s => s.Status != "obrisan"));
            }

            if (!string.IsNullOrWhiteSpace(search?.SortOrder))
            {
                if (search.SortOrder.ToLower() == "asc")
                {
                    NoviQuery = NoviQuery.OrderBy(x => x.Cijena);
                }
                else if (search.SortOrder.ToLower() == "desc")
                {
                    NoviQuery = NoviQuery.OrderByDescending(x => x.Cijena);
                }
            }
            return NoviQuery;
        }

        public override Model.DijeloviFM.Dijelovi GetById(int id)
        {
            var result = Context.Set<Database.Dijelovi>()
                .Include(b => b.SlikeDijelovis.Where(s => s.Status != "obrisan"))
                .FirstOrDefault(b => b.DijeloviId == id);

            if (result == null)
            {
                return null;
            }
            return Mapper.Map<Model.DijeloviFM.Dijelovi>(result);
        }
        public override void BeforeInsert(DijeloviInsertR request, Database.Dijelovi entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new UserException("Naziv dijela ne smije biti prazan");
            }
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena dijela mora biti veća od nule");
            }
            var Korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (Korisnik == null)
            {
                throw new UserException("Korisnik s tim Id-om ne postoji");
            }
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina dijela mora biti veća od nule");
            }
            if (request.KategorijaId <= 0)
            {
                throw new UserException("Kategorija mora biti odabrana");
            }
            var kategorija = _context.Kategorijas.Find(request.KategorijaId);
            if (kategorija == null)
            {
                throw new UserException("Kategorija sa datim ID-om ne postoji");
            }
            if (kategorija.IsBikeKategorija == true)
            {
                throw new UserException("Ova Kategorija je namjenjena za bicikle");
            }
            if (string.IsNullOrWhiteSpace(request.Opis))
            {
                throw new UserException("Opis dijela ne smije biti prazan");
            }
            entity.Naziv = request.Naziv;
            entity.Cijena = request.Cijena;
            entity.Opis = request.Opis;
            entity.KategorijaId = request.KategorijaId;
            entity.Kolicina = request.Kolicina;
            entity.KorisnikId = request.KorisnikId;
            base.BeforeInsert(request, entity);
        }

        public override Model.DijeloviFM.Dijelovi Insert(DijeloviInsertR request)
        {
            var entity = new Database.Dijelovi();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
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
                if (kategorija.IsBikeKategorija == true)
                {
                    throw new UserException("Ova Kategorija je namjenjena za bicikle");
                }
                entity.KategorijaId = request.KategorijaId.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Opis))
            {
                entity.Opis = request.Opis;
            }
            base.BeforeUpdate(request, entity);
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
            Mapper.Map(entity, request);
            return state.Update(id, request);
        }
        
        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }
            var slikeDijelovi = _context.SlikeDijelovis.Where(x => x.DijeloviId == entity.DijeloviId).ToList();
            foreach (var slika in slikeDijelovi)
            {
                _slikeDijeloviService.SoftDelete(slika.SlikeDijeloviId);
            }
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }

        public override void Aktivacija(int id, bool aktivacija)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }
            var slikeDijelovi = _context.SlikeDijelovis.Where(x => x.DijeloviId == entity.DijeloviId).ToList();
            foreach (var slika in slikeDijelovi)
            {
                _slikeDijeloviService.Aktivacija(slika.SlikeDijeloviId, aktivacija);
            }
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            base.Aktivacija(id, aktivacija);
        }

        public override void Zavrsavanje(int id)
        {
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }
    }
}
