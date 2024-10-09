using BikeHub.Model.KategorijaFM;
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
    public class KategorijaService : BaseCRUDService<Model.KategorijaFM.Kategorija, KategorijaSearchObject, Database.Kategorija, Model.KategorijaFM.KategorijaInsertR, Model.KategorijaFM.KategorijaUpdateR>, IKategorijaService
    {
        private BikeHubDbContext _context;
        public KategorijaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context;   }
        public override IQueryable<Database.Kategorija> AddFilter(KategorijaSearchObject search, IQueryable<Database.Kategorija> query)
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
            return NoviQuery;
        }
        public override void BeforeInsert(KategorijaInsertR request, Database.Kategorija entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new Exception("Naziv ne smije biti prazan");
            }
            var naziv = _context.Kategorijas.FirstOrDefault(x => x.Naziv==request.Naziv);
            if(naziv != null)
            {
                throw new Exception("Kategorija s ovim nazivom vec postoji");
            }
            entity.Naziv = request.Naziv;
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status ne smije biti prazan");
            }
            entity.Status = request.Status;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(KategorijaUpdateR request, Database.Kategorija entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                var naziv = _context.Kategorijas.FirstOrDefault(x => x.Naziv == request.Naziv);
                if (naziv!=null)
                {
                    throw new Exception("Kategorija s ovim nazivom vec postoji");
                }
                entity.Naziv = request.Naziv;
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
