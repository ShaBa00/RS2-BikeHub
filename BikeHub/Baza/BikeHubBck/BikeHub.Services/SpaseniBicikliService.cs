﻿using BikeHub.Model.SpaseniFM;
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
    public class SpaseniBicikliService : BaseCRUDService<Model.SpaseniFM.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliSearchObject,
        Database.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliInsertR, Model.SpaseniFM.SpaseniBicikliUpdateR>, ISpaseniBicikliService
    {
        private BikeHubDbContext _context;
        public BasePrvaGrupaState<Model.SpaseniFM.SpaseniBicikli, Database.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliInsertR,
                        Model.SpaseniFM.SpaseniBicikliUpdateR> _basePrvaGrupaState;

        public SpaseniBicikliService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.SpaseniFM.SpaseniBicikli, Database.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliInsertR,
                        Model.SpaseniFM.SpaseniBicikliUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public override IQueryable<Database.SpaseniBicikli> AddFilter(SpaseniBicikliSearchObject search, IQueryable<Database.SpaseniBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.BiciklId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BiciklId == search.BiciklId);
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
        public override void BeforeInsert(SpaseniBicikliInsertR request, Database.SpaseniBicikli entity)
        {
            if (request.BiciklId <= 0)
            {
                throw new Exception("BiciklId ne smije biti veći od nule.");
            }
            var bicikl = _context.Bicikls.Find(request.BiciklId);
            if (bicikl == null)
            {
                throw new Exception("Bicikl sa datim ID-om ne postoji.");
            }
            entity.BiciklId = request.BiciklId;
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
        public override void BeforeUpdate(SpaseniBicikliUpdateR request, Database.SpaseniBicikli entity)
        {
            if (request.BiciklId.HasValue)
            {
                var bicikl = _context.Bicikls.Find(request.BiciklId);
                if (bicikl == null)
                {
                    throw new Exception("Bicikl sa datim ID-om ne postoji.");
                }
                entity.BiciklId = request.BiciklId.Value;
            }
            if (request.DatumSpasavanja.HasValue)
            {
                entity.DatumSpasavanja = request.DatumSpasavanja.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.SpaseniFM.SpaseniBicikli Insert(SpaseniBicikliInsertR request)
        {
            var entity = new Database.SpaseniBicikli();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Model.SpaseniFM.SpaseniBicikli Update(int id, SpaseniBicikliUpdateR request)
        {

            var set = Context.Set<Database.SpaseniBicikli>();
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