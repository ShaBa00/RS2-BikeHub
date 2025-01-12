using BikeHub.Model;
using BikeHub.Model.BicikliFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Model.RecommendedKategorijaFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class RecommendedKategorijaService : BaseCRUDService<Model.RecommendedKategorijaFM.RecommendedKategorija,
        RecommendedKategorijaSearchObject, Database.RecommendedKategorija, Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR,
        Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR>, IRecommendedKategorijaService
    {
        private BikeHubDbContext _context;
        public BasePrvaGrupaState<Model.RecommendedKategorijaFM.RecommendedKategorija, Database.RecommendedKategorija,
            Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR,Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR> _basePrvaGrupaState;

        public IMapper _mapper;
        public RecommendedKategorijaService(BikeHubDbContext context, IMapper mapper,
            BasePrvaGrupaState<Model.RecommendedKategorijaFM.RecommendedKategorija, Database.RecommendedKategorija,
            Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR, Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _mapper = mapper;
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public override IQueryable<Database.RecommendedKategorija> AddFilter(RecommendedKategorijaSearchObject search, IQueryable<Database.RecommendedKategorija> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (search?.BicikliId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BicikliId == search.BicikliId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override void BeforeInsert(RecommendedKategorijaInsertR request, Database.RecommendedKategorija entity)
        {
            if (request?.DijeloviId == null)
            {
                throw new UserException("DijeloviId ne smije biti null");
            }
            var dijelovi = _context.Dijelovis.Find(request.DijeloviId);
            if (dijelovi == null)
            {
                throw new UserException("Dio sa datim ID-om ne postoji");
            }
            if (request?.BicikliId == null)
            {
                throw new UserException("BicikliId ne smije biti null");
            }
            var bicikl = _context.Bicikls.Find(request.BicikliId);
            if (bicikl == null)
            {
                throw new UserException("Bicikl sa datim ID-om ne postoji");
            }
            var existingRecommendation = _context.RecommendedKategorijas
            .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
            if (existingRecommendation != null)
            {
                throw new UserException("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
            }
            if(request?.DatumKreiranja==null)
            {
                entity.DatumKreiranja = DateTime.Now;
            }
            else
            {
                entity.DatumKreiranja = request.DatumKreiranja;
            }
            entity.BicikliId = request.BicikliId;
            entity.DijeloviId = request.DijeloviId;
            base.BeforeInsert(request, entity);
        }

        public override Model.RecommendedKategorijaFM.RecommendedKategorija Insert(RecommendedKategorijaInsertR request)
        {
            var entity = new Database.RecommendedKategorija();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(RecommendedKategorijaUpdateR request, Database.RecommendedKategorija entity)
        {
            if (request.BicikliId.HasValue)
            {
                var bicikl = _context.Bicikls.Find(request.BicikliId);
                if (bicikl==null)
                {
                    throw new UserException("Bicikl sa datim ID-om ne postoji");
                }
                var existingRecommendation = _context.RecommendedKategorijas
                .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
                if (existingRecommendation != null)
                {
                    throw new UserException("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
                }
                entity.BicikliId = request.BicikliId.Value;
            }
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.Find(request.DijeloviId);
                if (dio == null)
                {
                    throw new UserException("Dio sa datim ID-om ne postoji");
                }
                var existingRecommendation = _context.RecommendedKategorijas
                .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
                if (existingRecommendation != null)
                {
                    throw new UserException("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.BrojPreporuka.HasValue)
            {
                entity.BrojPreporuka = request.BrojPreporuka.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.RecommendedKategorijaFM.RecommendedKategorija Update(int id, RecommendedKategorijaUpdateR request)
        {
            var set = Context.Set<Database.RecommendedKategorija>();
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

        public List<Model.BicikliFM.Bicikli> GetRecommendedBiciklList(int DijeloviID)
        {
            var recommendedBicikliIds = _context.RecommendedKategorijas
                .Where(rk => rk.DijeloviId == DijeloviID && rk.Status == "aktivan")
                .Select(rk => rk.BicikliId)
                .ToList();

            if (recommendedBicikliIds.IsNullOrEmpty())
            {
                var bicikli = _context.Bicikls
                        .Include(x => x.SlikeBiciklis)
                        .Where(rk => rk.Status == "aktivan")
                        .Take(4)
                        .ToList();
                if (bicikli != null)
                {
                    List<BikeHub.Model.BicikliFM.Bicikli> mappedBicikli = 
                        _mapper.Map<List<BikeHub.Services.Database.Bicikl>, List<BikeHub.Model.BicikliFM.Bicikli>>(bicikli);
                    return mappedBicikli;
                }
                else
                {
                    return null;
                }
            }
            var recommendedBicikli = _context.Bicikls
                .Include(x => x.SlikeBiciklis)
                .Where(b => recommendedBicikliIds.Contains(b.BiciklId) && b.Kolicina > 0 && b.Status == "aktivan")
                .Take(4) 
                .ToList();
            if (recommendedBicikli.Count < 4)
            {
                var additionalBicikli = _context.Bicikls
                    .Include(x => x.SlikeBiciklis)
                    .Where(b => !recommendedBicikliIds.Contains(b.BiciklId) && b.Kolicina > 0 && b.Status == "aktivan")
                    .Take(4 - recommendedBicikli.Count)
                    .ToList();
                recommendedBicikli.AddRange(additionalBicikli);
                if (recommendedBicikli != null)
                {
                    List<BikeHub.Model.BicikliFM.Bicikli> mappedBicikli =
                    _mapper.Map<List<BikeHub.Services.Database.Bicikl>, List<BikeHub.Model.BicikliFM.Bicikli>>(recommendedBicikli);
                    return mappedBicikli;
                }
            }
            if (recommendedBicikli == null || recommendedBicikli.Count == 0)
            {
                recommendedBicikli = _context.Bicikls
                .Include(x => x.SlikeBiciklis)
                .Where(b => recommendedBicikliIds.Contains(b.BiciklId) && b.Kolicina > 0 && b.Status == "aktivan")
                .Take(4)
                .ToList();
            }
            List<BikeHub.Model.BicikliFM.Bicikli> Bicikli =
            _mapper.Map<List<BikeHub.Services.Database.Bicikl>, List<BikeHub.Model.BicikliFM.Bicikli>>(recommendedBicikli);
            return Bicikli;
        }
        public List<Model.DijeloviFM.Dijelovi> GetRecommendedDijeloviList(int BiciklID)
        {
            var recommendedDijeloviIds = _context.RecommendedKategorijas
                .Where(rk => rk.BicikliId == BiciklID && rk.Status == "aktivan")
                .Select(rk => rk.DijeloviId)
                .ToList();

            if (recommendedDijeloviIds.IsNullOrEmpty())
            {
                var dijelovi = _context.Dijelovis
                        .Include(x => x.SlikeDijelovis)
                        .Where(rk => rk.Status == "aktivan")
                        .Take(4)
                        .ToList();
                if (dijelovi != null)
                {
                    List<BikeHub.Model.DijeloviFM.Dijelovi> mappedBicikli =
                        _mapper.Map<List<BikeHub.Services.Database.Dijelovi>, List<BikeHub.Model.DijeloviFM.Dijelovi>>(dijelovi);
                    return mappedBicikli;
                }
                else
                {
                    return null;
                }
            }
            var recommendedDijelovi = _context.Dijelovis
                .Include(x => x.SlikeDijelovis)
                .Where(b => recommendedDijeloviIds.Contains(b.DijeloviId) && b.Kolicina > 0)
                .Take(4)
                .ToList();
            if (recommendedDijelovi.Count < 4)
            {
                var additionalDijelovi = _context.Dijelovis
                    .Include(x => x.SlikeDijelovis)
                    .Where(b => !recommendedDijeloviIds.Contains(b.DijeloviId) && b.Kolicina > 0)
                    .Take(4 - recommendedDijelovi.Count)
                    .ToList();
                recommendedDijelovi.AddRange(additionalDijelovi);
                if (recommendedDijelovi != null)
                {
                    List<BikeHub.Model.DijeloviFM.Dijelovi> mappedBicikli =
                    _mapper.Map<List<BikeHub.Services.Database.Dijelovi>, List<BikeHub.Model.DijeloviFM.Dijelovi>>(recommendedDijelovi);
                    return mappedBicikli;
                }
            }
            if(recommendedDijelovi==null || recommendedDijelovi.Count == 0)
            {
                recommendedDijelovi = _context.Dijelovis
                .Include(x => x.SlikeDijelovis)
                .Where(b => recommendedDijeloviIds.Contains(b.DijeloviId) && b.Kolicina > 0)
                .Take(4)
                .ToList();
            }
            List<BikeHub.Model.DijeloviFM.Dijelovi> Bicikli =
            _mapper.Map<List<BikeHub.Services.Database.Dijelovi>, List<BikeHub.Model.DijeloviFM.Dijelovi>>(recommendedDijelovi);
            return Bicikli;
        }
    }
}
