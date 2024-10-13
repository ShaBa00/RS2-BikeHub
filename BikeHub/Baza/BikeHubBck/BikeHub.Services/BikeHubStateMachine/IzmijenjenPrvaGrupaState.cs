using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;

namespace BikeHub.Services.BikeHubStateMachine
{
    public class IzmijenjenPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BasePrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public IzmijenjenPrvaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
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
}
