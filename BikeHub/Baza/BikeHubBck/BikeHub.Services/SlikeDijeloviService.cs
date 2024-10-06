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
    public class SlikeDijeloviService : BaseService<Model.SlikeFM.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviSearchObject, Database.SlikeDijelovi>, ISlikeDijeloviService
    {
        public SlikeDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.SlikeDijelovi> AddFilter(SlikeDijeloviSearchObject search, IQueryable<Database.SlikeDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            return NoviQuery;
        }
    }
}
