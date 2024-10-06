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
    public class NarudzbaBicikliService : BaseService<Model.NarudzbaFM.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliSearchObject, Database.NarudzbaBicikli>, INarudzbaBicikliService
    {
        public NarudzbaBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }

        public override IQueryable<Database.NarudzbaBicikli> AddFilter(NarudzbaBicikliSearchObject search, IQueryable<Database.NarudzbaBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.Kolicina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Kolicina == search.Kolicina);
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            return NoviQuery;
        }
    }
}
