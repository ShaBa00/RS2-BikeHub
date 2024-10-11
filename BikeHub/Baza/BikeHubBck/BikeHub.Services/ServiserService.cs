using BikeHub.Model.ServisFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class ServiserService : BaseCRUDService<Model.ServisFM.Serviser, Model.ServisFM.ServiserSearchObject, Database.Serviser
                                                    , Model.ServisFM.ServiserInsertR, Model.ServisFM.ServiserUpdateR>, IServiserService
    {
        private BikeHubDbContext _context;
        public ServiserService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context; }
        public override IQueryable<Database.Serviser> AddFilter(ServiserSearchObject search, IQueryable<Database.Serviser> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }
            return NoviQuery;
        }
        public override void BeforeInsert(ServiserInsertR request, Database.Serviser entity)
        {
            if (request?.KorisnikId == null)
            {
                throw new Exception("KorisnikId ne smije biti null.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new Exception("Korisnik sa datim ID-om ne postoji.");
            }
            if (request.Cijena <= 0)
            {
                throw new Exception("Cijena mora biti veća od 0.");
            }
            entity.Status = "U procesu";
            entity.BrojServisa = 0;
            entity.KorisnikId = request.KorisnikId;
            entity.Cijena = request.Cijena;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(ServiserUpdateR request, Database.Serviser entity)
        {
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new Exception("Cijena mora biti veća od 0.");
                }
                entity.Cijena = request.Cijena.Value;
            }
            if (request.BrojServisa.HasValue)
            {
                if (request.BrojServisa < 0)
                {
                    throw new Exception("Broj servisa ne može biti negativan.");
                }
                entity.BrojServisa = request.BrojServisa.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
