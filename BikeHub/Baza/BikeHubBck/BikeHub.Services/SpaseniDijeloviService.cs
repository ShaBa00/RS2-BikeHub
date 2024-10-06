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
    public class SpaseniDijeloviService : BaseService<Model.SpaseniFM.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviSearchObject, Database.SpaseniDijelovi>, ISpaseniDijeloviService
    {
        public SpaseniDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }

        public override IQueryable<Database.SpaseniDijelovi> AddFilter(SpaseniDijeloviSearchObject search, IQueryable<Database.SpaseniDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (search?.DatumSpasavanja != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumSpasavanja.Date == search.DatumSpasavanja.Value.Date);
            }

            return NoviQuery;
        }
    }
}
