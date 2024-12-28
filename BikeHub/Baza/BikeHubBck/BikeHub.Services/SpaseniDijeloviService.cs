using BikeHub.Model;
using BikeHub.Model.SpaseniFM;
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
    public class SpaseniDijeloviService : BaseCRUDService<Model.SpaseniFM.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviSearchObject, 
        Database.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviInsertR, Model.SpaseniFM.SpaseniDijeloviUpdateR>, ISpaseniDijeloviService
    {
        private BikeHubDbContext _context;
        public BasePrvaGrupaState<Model.SpaseniFM.SpaseniDijelovi, Database.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviInsertR,
                        Model.SpaseniFM.SpaseniDijeloviUpdateR> _basePrvaGrupaState;

        public SpaseniDijeloviService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.SpaseniFM.SpaseniDijelovi, Database.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviInsertR,
                        Model.SpaseniFM.SpaseniDijeloviUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public override IQueryable<Database.SpaseniDijelovi> AddFilter(SpaseniDijeloviSearchObject search, IQueryable<Database.SpaseniDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }
            if (search?.DatumSpasavanja != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumSpasavanja.Date == search.DatumSpasavanja.Value.Date);
            }

            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override void BeforeInsert(SpaseniDijeloviInsertR request, Database.SpaseniDijelovi entity)
        {
            if (request.DijeloviId <= 0)
            {
                throw new Exception("DijeloviId mora biti manji od nule.");
            }
            if (request.KorisnikId <= 0)
            {
                throw new UserException("KorisnikId ne smije biti manji od nule.");
            }
            var dio = _context.Dijelovis.Find(request.DijeloviId);
            if (dio == null)
            {
                throw new UserException("Dio sa datim ID-om ne postoji.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji.");
            }
            if (request.DatumSpasavanja == default(DateTime))
            {
                entity.DatumSpasavanja = DateTime.Now;
            }
            else
            {
                entity.DatumSpasavanja = request.DatumSpasavanja;
            }
            bool diolVećSačuvan = _context.SpaseniDijelovis
             .Any(sb => sb.DijeloviId == request.DijeloviId && sb.KorisnikId == request.KorisnikId);
            if (diolVećSačuvan)
            {
                throw new UserException("Korisnik je već sačuvao ovaj dio.");
            }
            entity.DijeloviId = request.DijeloviId;
            entity.KorisnikId = request.KorisnikId;
            base.BeforeInsert(request, entity);
        }

        public override Model.SpaseniFM.SpaseniDijelovi Insert(SpaseniDijeloviInsertR request)
        {
            var entity = new Database.SpaseniDijelovi();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(SpaseniDijeloviUpdateR request, Database.SpaseniDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.Find(request.DijeloviId);
                if (dio == null)
                {
                    throw new UserException("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.KorisnikId.HasValue)
            {
                var korisnik = _context.Korisniks.Find(request.KorisnikId);
                if (korisnik == null)
                {
                    throw new UserException("Korisnik sa datim ID-om ne postoji.");
                }
                entity.KorisnikId = request.KorisnikId.Value;
            }
            if (request.DatumSpasavanja.HasValue)
            {
                entity.DatumSpasavanja = request.DatumSpasavanja.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.SpaseniFM.SpaseniDijelovi Update(int id, SpaseniDijeloviUpdateR request)
        {
            var set = Context.Set<Database.SpaseniDijelovi>();
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
