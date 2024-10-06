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
    public class NarudzbaDijeloviService : BaseService<Model.NarudzbaFM.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviSearchObject, Database.NarudzbaDijelovi>, INarudzbaDijeloviService
    {
        public NarudzbaDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }

        public override IQueryable<Database.NarudzbaDijelovi> AddFilter(NarudzbaDijeloviSearchObject search, IQueryable<Database.NarudzbaDijelovi> query)
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
