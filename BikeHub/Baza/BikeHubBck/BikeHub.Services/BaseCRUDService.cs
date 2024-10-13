﻿using BikeHub.Model.Ostalo;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
    {
        public BaseCRUDService(BikeHubDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public virtual TModel Insert(TInsert request)
        {


            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();


            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert request, TDbEntity entity) { }

        public virtual TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();

            var entity = set.Find(id);

            BeforeUpdate(request, entity);

            Mapper.Map(request, entity);

            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }

        public virtual void SoftDelete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new Exception($"{typeof(TDbEntity).Name} not found.");
            }
            var property = entity.GetType().GetProperty("Status");
            property.SetValue(entity, "obrisan");

            Context.SaveChanges();
        }
        //public virtual void BeforeSoftDelete(TModel request, TDbEntity r) { }
    }
}
