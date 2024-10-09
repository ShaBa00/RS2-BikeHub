using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class NarudzbaBicikliService : BaseCRUDService<Model.NarudzbaFM.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliSearchObject,
        Database.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliInsertR, Model.NarudzbaFM.NarudzbaBicikliUpdateR>, INarudzbaBicikliService
    {
        private BikeHubDbContext _context;
        public NarudzbaBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context; }

        public override IQueryable<Database.NarudzbaBicikli> AddFilter(NarudzbaBicikliSearchObject search, IQueryable<Database.NarudzbaBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.Kolicina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Kolicina == search.Kolicina);
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            return NoviQuery;
        }
        public override void BeforeInsert(NarudzbaBicikliInsertR request, Database.NarudzbaBicikli entity)
        {   
            if (request.NarudzbaId <= 0)
            {
                throw new Exception("NarudzbaId mora biti veći od 0.");
            }
            var narudzba = _context.Narudzbas.FirstOrDefault(x => x.NarudzbaId == request.NarudzbaId);
            if (narudzba == null)
            {
                throw new Exception("Narudžba sa datim ID-om ne postoji.");
            }
            if (request.BiciklId <= 0)
            {
                throw new Exception("BiciklId mora biti veći od 0.");
            }
            var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId);
            if (bicikl == null)
            {
                throw new Exception("Bicikl sa datim ID-om ne postoji.");
            }
            if (request.Kolicina <= 0)
            {
                throw new Exception("Kolicina mora biti veća od 0.");
            }

            if (request.Cijena <= 0)
            {
                throw new Exception("Cijena mora biti veća od 0.");
            }
            entity.NarudzbaId = request.NarudzbaId;
            entity.BiciklId = request.BiciklId;
            entity.Kolicina = request.Kolicina;
            entity.Cijena = request.Cijena;
            base.BeforeInsert(request, entity);
        }
    }
}
