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
    public class SlikeBicikliService : BaseCRUDService<Model.SlikeFM.SlikeBicikli, Model.SlikeFM.SlikeBicikliSearchObject,
        Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR, Model.SlikeFM.SlikeBicikliUpdateR>, ISlikeBicikliService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR,
                                Model.SlikeFM.SlikeBicikliUpdateR> _basePrvaGrupaState;
        public SlikeBicikliService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR,
                                Model.SlikeFM.SlikeBicikliUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }
        public override IQueryable<Database.SlikeBicikli> AddFilter(SlikeBicikliSearchObject search, IQueryable<Database.SlikeBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.BiciklId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BiciklId == search.BiciklId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }
        public override void BeforeInsert(SlikeBicikliInsertR request, Database.SlikeBicikli entity)
        {
            if (request?.BiciklId == null)
            {
                throw new Exception("BiciklId ne smije biti null.");
            }
            var bicikl = _context.Bicikls.Find(request.BiciklId);
            if (bicikl == null)
            {
                throw new Exception("Bicikl sa datim ID-om ne postoji.");
            }
            if (request?.Slika == null || request.Slika.Length == 0)
            {
                throw new Exception("Slika ne smije biti prazna.");
            }
            entity.BiciklId = request.BiciklId;
            entity.Slika = request.Slika;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(SlikeBicikliUpdateR request, Database.SlikeBicikli entity)
        {
            if (request.BiciklId.HasValue)
            {
                var bicikl = _context.Bicikls.Find(request.BiciklId.Value);
                if (bicikl == null)
                {
                    throw new Exception("Bicikl sa datim ID-om ne postoji.");
                }
                entity.BiciklId = request.BiciklId.Value;
            }
            if (request.Slika != null && request.Slika.Length > 0)
            {
                entity.Slika = request.Slika;
            }
            base.BeforeUpdate(request, entity);
        }
        public override Model.SlikeFM.SlikeBicikli Insert(SlikeBicikliInsertR request)
        {
            var entity = new Database.SlikeBicikli();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Model.SlikeFM.SlikeBicikli Update(int id, SlikeBicikliUpdateR request)
        {
            var set = Context.Set<Database.SlikeBicikli>();
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
