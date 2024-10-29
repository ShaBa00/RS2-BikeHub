using BikeHub.Model;
using BikeHub.Model.SlikeFM;
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
    public class SlikeDijeloviService : BaseCRUDService<Model.SlikeFM.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviSearchObject,
        Database.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviInsertR, Model.SlikeFM.SlikeDijeloviUpdateR>, ISlikeDijeloviService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.SlikeFM.SlikeDijelovi, Database.SlikeDijelovi, Model.SlikeFM.SlikeDijelovi,
                                Model.SlikeFM.SlikeDijelovi> _basePrvaGrupaState;

        public SlikeDijeloviService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.SlikeFM.SlikeDijelovi, Database.SlikeDijelovi, Model.SlikeFM.SlikeDijelovi,
                                Model.SlikeFM.SlikeDijelovi> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }
        public override IQueryable<Database.SlikeDijelovi> AddFilter(SlikeDijeloviSearchObject search, IQueryable<Database.SlikeDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override void BeforeInsert(SlikeDijeloviInsertR request, Database.SlikeDijelovi entity)
        {
            if (request?.DijeloviId == null)
            {
                throw new UserException("DijeloviId ne smije biti null.");
            }

            var dio = _context.Dijelovis.Find(request.DijeloviId);
            if (dio == null)
            {
                throw new UserException("Dio sa datim ID-om ne postoji.");
            }

            if (request?.Slika == null || request.Slika.Length == 0)
            {
                throw new UserException("Slika ne smije biti prazna.");
            }

            using (var memoryStream = new MemoryStream())
            {
                request.Slika.CopyTo(memoryStream);
                entity.Slika = memoryStream.ToArray();
            }

            entity.DijeloviId = request.DijeloviId;
            base.BeforeInsert(request, entity);
        }

        public override Model.SlikeFM.SlikeDijelovi Insert(SlikeDijeloviInsertR request)
        {
            var entity = new Database.SlikeDijelovi();
            BeforeInsert(request, entity);
            var novo = Mapper.Map<Model.SlikeFM.SlikeDijelovi>(entity); ;
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(novo);
        }

        public override void BeforeUpdate(SlikeDijeloviUpdateR request, Database.SlikeDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var dioExists = _context.Dijelovis.Any(b => b.DijeloviId == request.DijeloviId.Value);
                if (!dioExists)
                {
                    throw new UserException("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.Slika != null)
            {
                using (var memoryStream = new MemoryStream())
                {
                    request.Slika.CopyTo(memoryStream);
                    entity.Slika = memoryStream.ToArray();
                }
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.SlikeFM.SlikeDijelovi Update(int id, SlikeDijeloviUpdateR request)
        {
            var set = Context.Set<Database.SlikeDijelovi>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
            var novo = Mapper.Map<Model.SlikeFM.SlikeDijelovi>(entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            return state.Update(id, novo);
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
            throw new Exception("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }
    }
}
