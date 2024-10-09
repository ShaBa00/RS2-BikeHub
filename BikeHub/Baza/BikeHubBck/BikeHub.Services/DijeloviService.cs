using BikeHub.Model.DijeloviFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class DijeloviService : BaseCRUDService<Model.DijeloviFM.Dijelovi,Model.DijeloviFM.DijeloviSearchObject,Database.Dijelovi,Model.DijeloviFM.DijeloviInsertR, Model.DijeloviFM.DijeloviUpdateR>, IDijeloviService
    {
        private BikeHubDbContext _context;
        public DijeloviService(BikeHubDbContext context, IMapper mapper)
        : base(context, mapper){ _context = context; }
        public override IQueryable<Database.Dijelovi> AddFilter(DijeloviSearchObject search, IQueryable<Database.Dijelovi> query)
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
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
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
                throw new Exception("Naziv dijela ne smije biti prazan");
            }
            entity.Naziv = request.Naziv;
            if (request.Cijena <= 0)
            {
                throw new Exception("Cijena dijela mora biti veća od nule");
            }
            entity.Cijena = request.Cijena;
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status dijela ne smije biti prazan");
            }
            entity.Status = request.Status;
            if (request.KategorijaId <= 0)
            {
                throw new Exception("Kategorija mora biti odabrana");
            }
            var kategorija = _context.Kategorijas.Find(request.KategorijaId);
            if (kategorija == null)
            {
                throw new Exception("Kategorija sa datim ID-om ne postoji");
            }
            entity.KategorijaId = request.KategorijaId;
            if (string.IsNullOrWhiteSpace(request.Opis))
            {
                throw new Exception("Opis dijela ne smije biti prazan");
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
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new Exception("Cijena dijela mora biti veća od nule");
                }
                entity.Cijena = request.Cijena.Value;
            }
            if (request.KategorijaId.HasValue)
            {
                var kategorija = _context.Kategorijas.Find(request.KategorijaId);
                if (kategorija == null)
                {
                    throw new Exception("Kategorija sa datim ID-om ne postoji");
                }
                entity.KategorijaId = request.KategorijaId.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            if (!string.IsNullOrWhiteSpace(request.Opis))
            {
                entity.Opis = request.Opis;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
