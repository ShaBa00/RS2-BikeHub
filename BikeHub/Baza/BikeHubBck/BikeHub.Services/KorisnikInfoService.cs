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
    public class KorisnikInfoService : BaseCRUDService<Model.KorisnikFM.KorisnikInfo, Model.KorisnikFM.KorisnikInfoSearchObject, Database.KorisnikInfo, Model.KorisnikFM.KorisnikInfoInsertR, Model.KorisnikFM.KorisnikInfoUpdateR>, IKorisnikInfoService
    {
        private BikeHubDbContext _context;
        public KorisnikInfoService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper)        { _context = context; }

        public override IQueryable<Database.KorisnikInfo> AddFilter(KorisnikInfoSearchObject search, IQueryable<Database.KorisnikInfo> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.ImePrezime))
            {
                NoviQuery = NoviQuery.Where(x => x.ImePrezime.StartsWith(search.ImePrezime));
            }
            if (!string.IsNullOrWhiteSpace(search?.Telefon))
            {
                NoviQuery = NoviQuery.Where(x => x.Telefon.StartsWith(search.Telefon));
            }
            if (search?.BrojNarudbi != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojNarudbi == search.BrojNarudbi);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }

            return NoviQuery;
        }
        public override void BeforeInsert(KorisnikInfoInsertR request, Database.KorisnikInfo entity)
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
            var korisnikInfo = _context.KorisnikInfos.FirstOrDefault(x => x.KorisnikId == request.KorisnikId);
            if (korisnikInfo != null)
            {
                throw new Exception("Informacije za korisnika sa ovim ID-om su već dodate. " +
                                    "Potrebno je izvršiti izmjenu ili obrisati postojeće podatke.");
            }
            if (string.IsNullOrWhiteSpace(request.ImePrezime))
            {
                throw new Exception("ImePrezime ne smije biti prazno.");
            }

            if (string.IsNullOrWhiteSpace(request.Telefon))
            {
                throw new Exception("Telefon ne smije biti prazan.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.ImePrezime = request.ImePrezime;
            entity.Telefon = request.Telefon;
            entity.BrojNarudbi = 0;
            entity.BrojServisa = 0;

            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(KorisnikInfoUpdateR request, Database.KorisnikInfo entity)
        {
            if (!string.IsNullOrWhiteSpace(request.ImePrezime))
            {
                entity.ImePrezime = request.ImePrezime;
            }
            if (!string.IsNullOrWhiteSpace(request.Telefon))
            {
                entity.Telefon = request.Telefon;
            }
            if (request.BrojNarudbi != null)
            {
                if (request.BrojNarudbi < 0)
                {
                    throw new Exception("Broj narudbi ne smije biti negativan.");
                }
                entity.BrojNarudbi = (int)request.BrojNarudbi;
            }
            if (request.BrojServisa != null)
            {
                if (request.BrojServisa < 0)
                {
                    throw new Exception("Broj servisa ne smije biti negativan.");
                }
                entity.BrojServisa = (int)request.BrojServisa;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
