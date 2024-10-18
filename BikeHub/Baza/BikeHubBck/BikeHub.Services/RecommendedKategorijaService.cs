using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
using BikeHub.Model.RecommendedKategorijaFM;
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
    public class RecommendedKategorijaService : BaseCRUDService<Model.RecommendedKategorijaFM.RecommendedKategorija,
        RecommendedKategorijaSearchObject, Database.RecommendedKategorija, Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR,
        Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR>, IRecommendedKategorijaService
    {
        private BikeHubDbContext _context;
        public BasePrvaGrupaState<Model.RecommendedKategorijaFM.RecommendedKategorija, Database.RecommendedKategorija,
            Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR,Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR> _basePrvaGrupaState;

        public RecommendedKategorijaService(BikeHubDbContext context, IMapper mapper,
            BasePrvaGrupaState<Model.RecommendedKategorijaFM.RecommendedKategorija, Database.RecommendedKategorija,
            Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR, Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
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
            if (search?.BrojPreporuka != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojPreporuka == search.BrojPreporuka);
            }
            if (search?.DatumKreiranja != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumKreiranja.Value.Date == search.DatumKreiranja.Value.Date);
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
            entity.BicikliId = request.BicikliId;
            entity.DijeloviId = request.DijeloviId;
            if(request?.DatumKreiranja==null)
            {
                entity.DatumKreiranja = DateTime.Now;
            }
            else
            {
                entity.DatumKreiranja = request.DatumKreiranja;
            }
            entity.BrojPreporuka=0;
            base.BeforeInsert(request, entity);
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

        public override Model.RecommendedKategorijaFM.RecommendedKategorija Insert(RecommendedKategorijaInsertR request)
        {
            var entity = new Database.RecommendedKategorija();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
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
    }
}
