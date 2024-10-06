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
    public class PromocijaDijeloviService : BaseService<Model.PromocijaFM.PromocijaDijelovi, Model.PromocijaFM.PromocijaDijeloviSearchObject, Database.PromocijaDijelovi>, IPromocijaDijeloviService
    {
        public PromocijaDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.PromocijaDijelovi> AddFilter(PromocijaDijeloviSearchObject search, IQueryable<Database.PromocijaDijelovi> query)
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
