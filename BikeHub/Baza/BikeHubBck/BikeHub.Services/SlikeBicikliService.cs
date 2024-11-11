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
    public class SlikeBicikliService : BaseCRUDService<Model.SlikeFM.SlikeBicikli, Model.SlikeFM.SlikeBicikliSearchObject,
        Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR, Model.SlikeFM.SlikeBicikliUpdateR>, ISlikeBicikliService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli,
            Model.SlikeFM.SlikeBicikli,Model.SlikeFM.SlikeBicikli> _basePrvaGrupaState;


        public SlikeBicikliService(BikeHubDbContext context, IMapper mapper,
            BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli,
                Model.SlikeFM.SlikeBicikli,Model.SlikeFM.SlikeBicikli> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public override IQueryable<Database.SlikeBicikli> AddFilter(SlikeBicikliSearchObject search, 
            IQueryable<Database.SlikeBicikli> query)
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
                throw new UserException("BiciklId ne smije biti null.");
            }
    
            var bicikl = _context.Bicikls.Find(request.BiciklId);
            if (bicikl == null)
            {
                throw new UserException("Bicikl sa datim ID-om ne postoji.");
            }

            if (request?.Slika == null)
            {
                throw new UserException("Slika ne smije biti prazna.");
            }
            entity.Slika = request.Slika;
            entity.BiciklId = request.BiciklId;
            base.BeforeInsert(request, entity);
        }

        public override Model.SlikeFM.SlikeBicikli Insert(SlikeBicikliInsertR request)
        {
            var entity = new Database.SlikeBicikli();
            BeforeInsert(request, entity);
            var novo = Mapper.Map<Model.SlikeFM.SlikeBicikli>(entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(novo);
        }

        public override void BeforeUpdate(SlikeBicikliUpdateR request, Database.SlikeBicikli entity)
        {
            if (request.BiciklId.HasValue)
            {
                var biciklExists = _context.Bicikls.Any(b => b.BiciklId == request.BiciklId.Value);
                if (!biciklExists)
                {
                    throw new UserException("Bicikl sa datim ID-om ne postoji.");
                }
                entity.BiciklId = request.BiciklId.Value;
            }
            if (request.Slika != null)
            {
                entity.Slika = request.Slika;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.SlikeFM.SlikeBicikli Update(int id, SlikeBicikliUpdateR request)
        {
            var set = Context.Set<Database.SlikeBicikli>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
            var novo = Mapper.Map<Model.SlikeFM.SlikeBicikli>(entity);
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
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }

    }
}
