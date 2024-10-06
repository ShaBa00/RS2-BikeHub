using BikeHub.Model.SlikeFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class SlikeBicikliService : BaseService<Model.SlikeFM.SlikeBicikli, Model.SlikeFM.SlikeBicikliSearchObject, Database.SlikeBicikli>, ISlikeBicikliService
    {
        public SlikeBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.SlikeBicikli> AddFilter(SlikeBicikliSearchObject search, IQueryable<Database.SlikeBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.BiciklId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BiciklId == search.BiciklId);
            }
            return NoviQuery;
        }
    }
}
