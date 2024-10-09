using BikeHub.Model.KorisnikFM;
using BikeHub.Model.RecommendedKategorijaFM;
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
    public class RecommendedKategorijaService : BaseCRUDService<Model.RecommendedKategorijaFM.RecommendedKategorija, RecommendedKategorijaSearchObject, Database.RecommendedKategorija, Model.RecommendedKategorijaFM.RecommendedKategorijaInsertR, Model.RecommendedKategorijaFM.RecommendedKategorijaUpdateR>, IRecommendedKategorijaService
    {
        private BikeHubDbContext _context;
        public RecommendedKategorijaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context;   }
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
                throw new Exception("DijeloviId ne smije biti null");
            }
            var dijelovi = _context.Dijelovis.Find(request.DijeloviId);
            if (dijelovi == null)
            {
                throw new Exception("Dio sa datim ID-om ne postoji");
            }
            if (request?.BicikliId == null)
            {
                throw new Exception("BicikliId ne smije biti null");
            }
            var bicikl = _context.Bicikls.Find(request.BicikliId);
            if (bicikl == null)
            {
                throw new Exception("Bicikl sa datim ID-om ne postoji");
            }
            var existingRecommendation = _context.RecommendedKategorijas
            .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
            if (existingRecommendation != null)
            {
                throw new Exception("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
            }
            entity.BicikliId = request.BicikliId;
            entity.DijeloviId = request.DijeloviId;
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status ne smije biti prazan");
            }
            entity.Status = request.Status;
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
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            if (request.BicikliId.HasValue)
            {
                var bicikl = _context.Bicikls.Find(request.BicikliId);
                if (bicikl==null)
                {
                    throw new Exception("Bicikl sa datim ID-om ne postoji");
                }
                var existingRecommendation = _context.RecommendedKategorijas
                .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
                if (existingRecommendation != null)
                {
                    throw new Exception("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
                }
                entity.BicikliId = request.BicikliId.Value;
            }
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.Find(request.DijeloviId);
                if (dio == null)
                {
                    throw new Exception("Dio sa datim ID-om ne postoji");
                }
                var existingRecommendation = _context.RecommendedKategorijas
                .FirstOrDefault(r => r.DijeloviId == request.DijeloviId && r.BicikliId == request.BicikliId);
                if (existingRecommendation != null)
                {
                    throw new Exception("Već postoji preporučena kategorija sa istom kombinacijom DijeloviId i BicikliId.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.BrojPreporuka.HasValue)
            {
                entity.BrojPreporuka = request.BrojPreporuka.Value;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
