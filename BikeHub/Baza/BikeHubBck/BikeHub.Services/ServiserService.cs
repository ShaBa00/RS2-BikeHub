using BikeHub.Model;
using BikeHub.Model.ServisFM;
using BikeHub.Services.BikeHubStateMachine;
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
        public BasePrvaGrupaState<Model.ServisFM.Serviser, Database.Serviser, Model.ServisFM.ServiserInsertR,
                        Model.ServisFM.ServiserUpdateR> _basePrvaGrupaState;

        public ServiserService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.ServisFM.Serviser, Database.Serviser, Model.ServisFM.ServiserInsertR,
                        Model.ServisFM.ServiserUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

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
            if (search?.UkupnaOcjena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.UkupnaOcjena == search.UkupnaOcjena);
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
                throw new UserException("KorisnikId ne smije biti null.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji.");
            }
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena mora biti veća od 0.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.Cijena = request.Cijena;
            base.BeforeInsert(request, entity);
        }

        public override Model.ServisFM.Serviser Insert(ServiserInsertR request)
        {
            var entity = new Database.Serviser();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(ServiserUpdateR request, Database.Serviser entity)
        {
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new UserException("Cijena mora biti veća od 0.");
                }
                entity.Cijena = request.Cijena.Value;
            }
            if (request.BrojServisa.HasValue)
            {
                if (request.BrojServisa < 0)
                {
                    throw new UserException("Broj servisa ne može biti negativan.");
                }
                entity.BrojServisa = request.BrojServisa.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.ServisFM.Serviser Update(int id, ServiserUpdateR request)
        {
            var set = Context.Set<Database.Serviser>();
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
