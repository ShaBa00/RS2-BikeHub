using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
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
    public class NarudzbaService : BaseCRUDService<Model.NarudzbaFM.Narudzba, Model.NarudzbaFM.NarudzbaSearchObject, Database.Narudzba,
                                                    Model.NarudzbaFM.NarudzbaInsertR, Model.NarudzbaFM.NarudzbaUpdateR>, INarudzbaService
    {
        private BikeHubDbContext _context;
        public NarudzbaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context; }

        public override IQueryable<Database.Narudzba> AddFilter(NarudzbaSearchObject search, IQueryable<Database.Narudzba> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.DatumNarudzbe != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumNarudzbe.Date == search.DatumNarudzbe.Value.Date);
            }
            if (search?.NarudzbaBicikliIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.NarudzbaBiciklis);
            }
            if (search?.NarudzbaDijeloviIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.NarudzbaDijelovis);
            }
            return NoviQuery;
        }
        public override void BeforeInsert(NarudzbaInsertR request, Database.Narudzba entity)
        {
            if (request.KorisnikId == 0)
            {
                throw new Exception("KorisnikId ne smije biti prazan ili nula.");
            }
            var korisnik = _context.Korisniks.FirstOrDefault(x => x.KorisnikId == request.KorisnikId);
            if (korisnik == null)
            {
                throw new Exception("Korisnik sa datim ID-om ne postoji.");
            }
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status ne smije biti prazan.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.DatumNarudzbe = DateTime.Now;
            entity.Status = request.Status;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(NarudzbaUpdateR request, Database.Narudzba entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
