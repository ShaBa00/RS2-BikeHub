using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services.BikeHubStateMachine
{
    public class ZavrsenoDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> : BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public ZavrsenoDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }
        public override TModel Delete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);
            entity.GetType().GetProperty("Status").SetValue(entity, "obrisano");
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
    }
}
