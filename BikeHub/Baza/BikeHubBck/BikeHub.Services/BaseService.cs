using BikeHub.Model;
using BikeHub.Model.Ostalo;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
    {
        public BikeHubDbContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public BaseService(BikeHubDbContext context, IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public PagedResult<TModel> GetPaged(TSearch search)
        {
            List<TModel> result = new List<TModel>(); //Genericka Lista, tako da, koji kod Model da dobijemo napravit cemu listu za nejeg
            
            var quary = Context.Set<TDbEntity>().AsQueryable(); // Genericki quary koji pravimo na odnosu clase TDbEntity koja nam je potrebna

            quary = AddFilter(search, quary);

            int count = quary.Count();
            
            if( search?.Page.HasValue== true && search?.PageSize.HasValue== true )
            {
                quary = quary.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = quary.ToList();
            result = Mapper.Map(list, result);

            PagedResult<TModel> pagedResult = new PagedResult<TModel>();
            pagedResult.ResultsList = result;
            pagedResult.Count = count;
            return pagedResult;
        }

        // Funkcija AddFilter je upravo ona funkcija u kojoj cemo kreirati kod koji nije zajednicki za sve modele,
        // ali da ne bi napravili neku gresku osigurat cemo se da on po defoltu ne radi nista tako sto ce vracati,
        // onaj query koji je dobio 
        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }

        public TModel GetById(int id)
        {
            var result = Context.Set<TDbEntity>().Find(id);
            if( result == null)
            {
                return null;
            }
            return Mapper.Map<TModel>(result);
        }
    }
}
