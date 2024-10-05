using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class NarudzbaService : BaseService<Model.NarudzbaFM.Narudzba, Model.NarudzbaFM.NarudzbaSearchObject, Database.Narudzba>, INarudzbaService
    {
        public NarudzbaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }

        public override IQueryable<Database.Narudzba> AddFilter(NarudzbaSearchObject search, IQueryable<Database.Narudzba> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.DatumNarudzbe != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumNarudzbe.Date == search.DatumNarudzbe.Value.Date);
            }

            return NoviQuery;
        }
    }
}
