using BikeHub.Model.AdresaFM;
using BikeHub.Model.PromocijaFM;
using BikeHub.Model.ServisFM;
using BikeHub.Model.SlikeFM;
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
    public class AdresaService : BaseService<Model.AdresaFM.Adresa, Model.AdresaFM.AdresaSearchObject, Database.Adresa>, IAdresaService
    {
        public AdresaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){     }
        public override IQueryable<Database.Adresa> AddFilter(AdresaSearchObject search, IQueryable<Database.Adresa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Grad))
            {
                NoviQuery = NoviQuery.Where(x => x.Grad.StartsWith(search.Grad));
            }
            if (!string.IsNullOrWhiteSpace(search?.PostanskiBroj))
            {
                NoviQuery = NoviQuery.Where(x => x.PostanskiBroj.StartsWith(search.PostanskiBroj));
            }
            if (!string.IsNullOrWhiteSpace(search?.Ulica))
            {
                NoviQuery = NoviQuery.Where(x => x.Ulica.StartsWith(search.Ulica));
            }
            return NoviQuery;
        }
    }
}
