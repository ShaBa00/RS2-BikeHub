﻿using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services.BikeHubStateMachine
{
    public class KreiranDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public KreiranDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }
        public override TModel Insert(TInsert request)
        {
            var set = Context.Set<TDbEntity>();
            var entity = Mapper.Map<TDbEntity>(request);
            entity.GetType().GetProperty("Status").SetValue(entity, "kreiran"); // Kreiran prelazi u Izmijenjen
            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            entity.GetType().GetProperty("Status").SetValue(entity, "izmijenjen"); // Aktivan prelazi u Izmijenjen
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Activate(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "aktivan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Delete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "obrisan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Return(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "vracen");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
    }
    public class IzmijenjenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public IzmijenjenDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }
        public override TModel Activate(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "aktivan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Delete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "obrisan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Return(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "vracen");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
    }

    public class ObrisanDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public ObrisanDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }
    }

    public class VracenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public VracenDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }
        public override TModel Activate(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "aktivan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        public override TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            entity.GetType().GetProperty("Status").SetValue(entity, "izmijenjen");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }        
        public override TModel Delete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "obrisan");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
    }

}
