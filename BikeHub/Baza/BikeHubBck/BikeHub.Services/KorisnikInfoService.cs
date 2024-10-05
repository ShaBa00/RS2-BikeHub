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
    public class KorisnikInfoService : BaseService<Model.KorisnikFM.KorisnikInfo, Model.KorisnikFM.KorisnikInfoSearchObject, Database.KorisnikInfo>, IKorisnikInfoService
    {
        public KorisnikInfoService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper)        {        }

        public override IQueryable<Database.KorisnikInfo> AddFilter(KorisnikInfoSearchObject search, IQueryable<Database.KorisnikInfo> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.ImePrezime))
            {
                NoviQuery = NoviQuery.Where(x => x.ImePrezime.StartsWith(search.ImePrezime));
            }
            if (!string.IsNullOrWhiteSpace(search?.Telefon))
            {
                NoviQuery = NoviQuery.Where(x => x.Telefon.StartsWith(search.Telefon));
            }
            if (search?.BrojNarudbi != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojNarudbi == search.BrojNarudbi);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }

            return NoviQuery;
        }
    }
}
