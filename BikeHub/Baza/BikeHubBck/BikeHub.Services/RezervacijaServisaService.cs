using BikeHub.Model.ServisFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class RezervacijaServisaService : BaseService<Model.ServisFM.RezervacijaServisa, Model.ServisFM.RezervacijaServisaSearchObject, Database.RezervacijaServisa>, IRezervacijaServisaService
    {
        public RezervacijaServisaService(BikeHubDbContext context, IMapper mapper)
        : base(context, mapper) { }
        public override IQueryable<Database.RezervacijaServisa> AddFilter(RezervacijaServisaSearchObject search, IQueryable<Database.RezervacijaServisa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Ocjena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Ocjena == search.Ocjena);
            }
            return NoviQuery;
        }
    }
}
