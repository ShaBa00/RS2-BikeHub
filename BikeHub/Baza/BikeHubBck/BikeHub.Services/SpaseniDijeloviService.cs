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
                throw new Exception("DijeloviId ne smije biti veći od nule.");
            }
            var dio = _context.Dijelovis.Find(request.DijeloviId);
            if (dio == null)
            {
                throw new Exception("Dio sa datim ID-om ne postoji.");
            }
            entity.DijeloviId = request.DijeloviId;
            if (request.DatumSpasavanja == default(DateTime))
            {
                entity.DatumSpasavanja = DateTime.Now;
            }
            else
            {
                entity.DatumSpasavanja = request.DatumSpasavanja;
            }
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(SpaseniDijeloviUpdateR request, Database.SpaseniDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.Find(request.DijeloviId);
                if (dio == null)
                {
                    throw new Exception("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.DatumSpasavanja.HasValue)
            {
                entity.DatumSpasavanja = request.DatumSpasavanja.Value;
            }
            base.BeforeUpdate(request, entity);
        }
        public override Model.SpaseniFM.SpaseniDijelovi Insert(SpaseniDijeloviInsertR request)
        {
            var entity = new Database.SpaseniDijelovi();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Model.SpaseniFM.SpaseniDijelovi Update(int id, SpaseniDijeloviUpdateR request)
        {
            var set = Context.Set<Database.SpaseniDijelovi>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new Exception("Entitet sa datim ID-om ne postoji");
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
                throw new Exception("Entity not found.");
            }

            var state = _basePrvaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }
    }
}
