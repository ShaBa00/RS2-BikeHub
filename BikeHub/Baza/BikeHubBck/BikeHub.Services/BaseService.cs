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
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
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
            List<TModel> result = new List<TModel>(); 
            
            var quary = Context.Set<TDbEntity>().AsQueryable(); 

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
        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }
        public virtual TModel GetById(int id)
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
