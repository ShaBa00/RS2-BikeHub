using BikeHub.Model;
using BikeHub.Model.BicikliFM;
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
    public class BicikliService : BaseCRUDService<Model.BicikliFM.Bicikli, BicikliSearchObject, Database.Bicikl,
        Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> , IBicikliService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.BicikliFM.Bicikli, Database.Bicikl,
        Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> _basePrvaGrupaState;

        private readonly SlikeBicikliService _slikeBicikliService;

       public BicikliService(BikeHubDbContext context, IMapper mapper,
           BasePrvaGrupaState<Model.BicikliFM.Bicikli, Database.Bicikl,
         Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> basePrvaGrupaState,
           ISlikeBicikliService slikeBicikliService)
         : base(context, mapper)
        {
            _context = context; 
            _basePrvaGrupaState = basePrvaGrupaState; 
            _slikeBicikliService = (SlikeBicikliService)slikeBicikliService;
        }

        public override IQueryable<Database.Bicikl> AddFilter(BicikliSearchObject search, IQueryable<Database.Bicikl> query)
        {
            var NoviQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                NoviQuery = NoviQuery.Where(x => x.Naziv.StartsWith(search.Naziv));
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
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }
            if (!string.IsNullOrWhiteSpace(search?.VelicinaRama))
            {
                NoviQuery = NoviQuery.Where(x => x.VelicinaRama == search.VelicinaRama);
            }
            if (!string.IsNullOrWhiteSpace(search?.VelicinaTocka))
            {
                NoviQuery = NoviQuery.Where(x => x.VelicinaTocka == search.VelicinaTocka);
            }
            if (search?.BrojBrzina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojBrzina == search.BrojBrzina);
            }
            if (search?.KategorijaId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KategorijaId == search.KategorijaId);
            }

            NoviQuery = NoviQuery.Include(x => x.SlikeBiciklis);

            return NoviQuery;
        }

        public override Bicikli GetById(int id)
        {
            var result = Context.Set<Database.Bicikl>()
                                .Include(b => b.SlikeBiciklis) 
                                .FirstOrDefault(b => b.BiciklId == id);
            if (result == null)
            {
                return null;
            }
            return Mapper.Map<Model.BicikliFM.Bicikli>(result);
        }

        public override void BeforeInsert(BicikliInsertR request, Bicikl entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new UserException("Naziv bicikla ne smije biti prazan");
            }
            var Korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (Korisnik == null)
            {
                throw new UserException("Korisnik s tim Id-om ne postoji");
            }
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena bicikla mora biti veća od nule");
            }
            if (string.IsNullOrWhiteSpace(request.VelicinaRama))
            {
                throw new UserException("Veličina rama ne smije biti prazna");
            }
            if (string.IsNullOrWhiteSpace(request.VelicinaTocka))
            {
                throw new UserException("Veličina točka ne smije biti prazna");
            }
            if (request.BrojBrzina <= 0)
            {
                throw new UserException("Broj brzina mora biti veći od nule");
            }
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina mora biti veći od nule");
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
            if (kategorija.IsBikeKategorija == false)
            {
                throw new UserException("Ova Kategorija je namjenjena za dijelove");
            }
            entity.Naziv = request.Naziv;
            entity.Cijena = request.Cijena;
            entity.VelicinaRama = request.VelicinaRama;
            entity.VelicinaTocka = request.VelicinaTocka;
            entity.BrojBrzina = request.BrojBrzina;
            entity.KategorijaId = request.KategorijaId;
            entity.Kolicina = request.Kolicina;
            entity.KorisnikId = request.KorisnikId;
            base.BeforeInsert(request, entity);
        }

        public override Bicikli Insert(BicikliInsertR request)
        {
            var entity = new Database.Bicikl();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(BicikliUpdateR request, Bicikl entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                entity.Naziv = request.Naziv;
            }
            if (request.KorisnikId>0)
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
                    throw new UserException("Cijena bicikla mora biti veća od nule");
                }
                entity.Cijena = request.Cijena.Value; 
            }
            if (request.Kolicina.HasValue)
            {
                if (request.Kolicina < 0)
                {
                    throw new UserException("Kolicina bicikla ne moze biti manja od 0");
                }
                entity.Kolicina = request.Kolicina.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.VelicinaRama))
            {
                entity.VelicinaRama = request.VelicinaRama;
            }
            if (!string.IsNullOrWhiteSpace(request.VelicinaTocka))
            {
                entity.VelicinaTocka = request.VelicinaTocka;
            }
            if (request.BrojBrzina.HasValue)
            {
                if (request.BrojBrzina <= 0)
                {
                    throw new UserException("Broj brzina mora biti veći od nule");
                }
                entity.BrojBrzina = request.BrojBrzina.Value;
            }
            if (request.KategorijaId.HasValue)
            {
                var kategorija = _context.Kategorijas.Find(request.KategorijaId);
                if (kategorija == null)
                {
                    throw new UserException("Kategorija sa datim ID-om ne postoji");
                }
                if (kategorija.IsBikeKategorija == false)
                {
                    throw new UserException("Ova Kategorija je namjenjena za dijelove");
                }
                entity.KategorijaId = request.KategorijaId.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Bicikli Update(int id, BicikliUpdateR request)
        {
            var set = Context.Set<Database.Bicikl>();
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
                throw new UserException("Entitet sa datim ID-om ne postoji.");
            }
            var slikeBicikli = _context.SlikeBiciklis.Where(x => x.BiciklId == entity.BiciklId).ToList();
            foreach(var slika in slikeBicikli)
            {
                _slikeBicikliService.SoftDelete(slika.SlikeBicikliId);
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
            var slikeBicikli = _context.SlikeBiciklis.Where(x => x.BiciklId == entity.BiciklId).ToList();
            foreach (var slika in slikeBicikli)
            {
                _slikeBicikliService.Aktivacija(slika.SlikeBicikliId,aktivacija);
            }
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            base.Aktivacija(id, aktivacija);
        }

        public override void Zavrsavanje(int id)
        {
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }

        public List<object> GetPromotedItems()
        {
            var promotedBicikli = _context.Bicikls
                .Where(b => b.PromocijaBiciklis.Any(pb => pb.Status == "aktivan"))
                .Select(b => new
                {
                    b.BiciklId,
                    b.KorisnikId,
                    b.Naziv,
                    b.Cijena,
                    b.Status,
                    Slike = b.SlikeBiciklis.Select(s => new
                    {
                        s.SlikeBicikliId,
                        s.Slika 
                    }).ToList()
                }).ToList();

            var promotedDijelovi = _context.Dijelovis
                .Where(d => d.PromocijaDijelovis.Any(pd => pd.Status == "aktivan"))
                .Select(d => new
                {
                    d.DijeloviId,
                    d.KorisnikId,
                    d.Naziv,
                    d.Cijena,
                    d.Status,
                    Slike = d.SlikeDijelovis.Select(s => new
                    {
                        s.SlikeDijeloviId,
                        s.Slika 
                    }).ToList()
                }).ToList();

            return promotedBicikli.Cast<object>().Concat(promotedDijelovi.Cast<object>()).ToList();
        }
    }
}
