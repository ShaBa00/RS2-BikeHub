using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services.BikeHubStateMachine
{//
    public class ObrisanPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BasePrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public ObrisanPrvaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {

        }
        public override TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            entity.GetType().GetProperty("Status").SetValue(entity, "izmijenjen");
            Context.Update(entity);
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
    }
}
