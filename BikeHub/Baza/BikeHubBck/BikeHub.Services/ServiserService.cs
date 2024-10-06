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
    public class ServiserService : BaseService<Model.ServisFM.Serviser, Model.ServisFM.ServiserSearchObject, Database.Serviser>, IServiserService
    {
        public ServiserService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.Serviser> AddFilter(ServiserSearchObject search, IQueryable<Database.Serviser> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }
            return NoviQuery;
        }
    }
}
