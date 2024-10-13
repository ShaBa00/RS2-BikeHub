using BikeHub.Model.SlikeFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class SlikeDijeloviService : BaseCRUDService<Model.SlikeFM.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviSearchObject,
        Database.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviInsertR, Model.SlikeFM.SlikeDijeloviUpdateR>, ISlikeDijeloviService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR,
                                Model.SlikeFM.SlikeBicikliUpdateR> _basePrvaGrupaState;

        public SlikeDijeloviService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.SlikeFM.SlikeBicikli, Database.SlikeBicikli, Model.SlikeFM.SlikeBicikliInsertR,
                                Model.SlikeFM.SlikeBicikliUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }
        public override IQueryable<Database.SlikeDijelovi> AddFilter(SlikeDijeloviSearchObject search, IQueryable<Database.SlikeDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }
    }
}
