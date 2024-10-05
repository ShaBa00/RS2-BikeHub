using BikeHub.Model.DijeloviFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class DijeloviService : BaseService<Model.DijeloviFM.Dijelovi,Model.DijeloviFM.DijeloviSearchObject,Database.Dijelovi>, IDijeloviService
    {
        public DijeloviService(BikeHubDbContext context, IMapper mapper)
        : base(context, mapper){        }
        public override IQueryable<Database.Dijelovi> AddFilter(DijeloviSearchObject search, IQueryable<Database.Dijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                NoviQuery = NoviQuery.Where(x => x.Naziv.StartsWith(search.Naziv));
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            return NoviQuery;
        }
    }
}
