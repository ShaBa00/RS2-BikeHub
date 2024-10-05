using BikeHub.Model.BicikliFM;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class BicikliService : BaseService<Model.BicikliFM.Bicikli, BicikliSearchObject, Database.Bicikl> , IBicikliService
    {

        public BicikliService(BikeHubDbContext context, IMapper mapper)
        :base(context,mapper){}

        public override IQueryable<Bicikl> AddFilter(BicikliSearchObject search, IQueryable<Bicikl> query)
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
        //public virtual List<Model.BicikliFM.Bicikli> GetList(BicikliSearchObject searchObject)
        //{
        //    List<Model.BicikliFM.Bicikli> result = new List<Model.BicikliFM.Bicikli>();

        //    var query = Context.Bicikls.AsQueryable();
        //    if (!string.IsNullOrWhiteSpace(searchObject?.Naziv))
        //    {
        //        query = query.Where(x => x.Naziv.StartsWith(searchObject.Naziv));
        //    }
        //    if (!string.IsNullOrWhiteSpace(searchObject?.Status))
        //    {
        //        query = query.Where(x => x.Status.StartsWith(searchObject.Status));
        //    }
        //    if (searchObject?.Cijena != null)
        //    {
        //        query = query.Where(x => x.Cijena == searchObject.Cijena);
        //    }
        //    if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true)
        //    {
        //        query = query.Skip(searchObject.Page.Value * searchObject.PageSize.Value).Take(searchObject.PageSize.Value);
        //    }
        //    var list = query.ToList();
        //    result = Mapper.Map(list, result);
        //    return result;
        //}
    }
}
