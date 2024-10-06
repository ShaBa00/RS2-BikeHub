using BikeHub.Model.SpaseniFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class SpaseniBicikliService : BaseService<Model.SpaseniFM.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliSearchObject, Database.SpaseniBicikli>, ISpaseniBicikliService
    {
        public SpaseniBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }

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

            return NoviQuery;
        }
    }
}
