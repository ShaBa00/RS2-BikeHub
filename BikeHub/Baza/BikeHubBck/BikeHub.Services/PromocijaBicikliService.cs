using BikeHub.Model.PromocijaFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class PromocijaBicikliService : BaseService<Model.PromocijaFM.PromocijaBicikli, Model.PromocijaFM.PromocijaBicikliSearchObject, Database.PromocijaBicikli>, IPromocijaBicikliService
    {
        public PromocijaBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.PromocijaBicikli> AddFilter(PromocijaBicikliSearchObject search, IQueryable<Database.PromocijaBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.CijenaPromocije != null)
            {
                NoviQuery = NoviQuery.Where(x => x.CijenaPromocije == search.CijenaPromocije);
            }
            return NoviQuery;
        }
    }
}
