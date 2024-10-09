using BikeHub.Model.BicikliFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class BicikliService : BaseCRUDService<Model.BicikliFM.Bicikli, BicikliSearchObject, Database.Bicikl, Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> , IBicikliService
    {
        private BikeHubDbContext _context;
        public BicikliService(BikeHubDbContext context, IMapper mapper)
        :base(context,mapper){ _context = context; }

        public override IQueryable<Bicikl> AddFilter(BicikliSearchObject search, IQueryable<Bicikl> query)
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
            return NoviQuery;
        }
        public override void BeforeInsert(BicikliInsertR request, Bicikl entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new Exception("Naziv bicikla ne smije biti prazan");
            }
            entity.Naziv = request.Naziv;
            if (request.Cijena <= 0)
            {
                throw new Exception("Cijena bicikla mora biti veća od nule");
            }
            entity.Cijena = request.Cijena;
            if (string.IsNullOrWhiteSpace(request.VelicinaRama))
            {
                throw new Exception("Veličina rama ne smije biti prazna");
            }
            entity.VelicinaRama = request.VelicinaRama;
            if (string.IsNullOrWhiteSpace(request.VelicinaTocka))
            {
                throw new Exception("Veličina točka ne smije biti prazna");
            }
            entity.VelicinaTocka = request.VelicinaTocka;
            if (request.BrojBrzina <= 0)
            {
                throw new Exception("Broj brzina mora biti veći od nule");
            }
            entity.BrojBrzina = request.BrojBrzina;
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status bicikla ne smije biti prazan");
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
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(BicikliUpdateR request, Bicikl entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                entity.Naziv = request.Naziv;
            }
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new Exception("Cijena bicikla mora biti veća od nule");
                }
                entity.Cijena = request.Cijena.Value; 
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
                    throw new Exception("Broj brzina mora biti veći od nule");
                }
                entity.BrojBrzina = request.BrojBrzina.Value;
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
            base.BeforeUpdate(request, entity);
        }
    }
}
