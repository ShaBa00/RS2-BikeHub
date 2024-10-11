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
    public class SpaseniDijeloviService : BaseCRUDService<Model.SpaseniFM.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviSearchObject, 
        Database.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviInsertR, Model.SpaseniFM.SpaseniDijeloviUpdateR>, ISpaseniDijeloviService
    {
        private BikeHubDbContext _context;
        public SpaseniDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context; }

        public override IQueryable<Database.SpaseniDijelovi> AddFilter(SpaseniDijeloviSearchObject search, IQueryable<Database.SpaseniDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.DijeloviId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DijeloviId == search.DijeloviId);
            }
            if (search?.DatumSpasavanja != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumSpasavanja.Date == search.DatumSpasavanja.Value.Date);
            }

            return NoviQuery;
        }
        public override void BeforeInsert(SpaseniDijeloviInsertR request, Database.SpaseniDijelovi entity)
        {
            if (request.DijeloviId <= 0)
            {
                throw new Exception("DijeloviId ne smije biti veći od nule.");
            }
            var dio = _context.Dijelovis.Find(request.DijeloviId);
            if (dio == null)
            {
                throw new Exception("Dio sa datim ID-om ne postoji.");
            }
            entity.DijeloviId = request.DijeloviId;
            if (request.DatumSpasavanja == default(DateTime))
            {
                entity.DatumSpasavanja = DateTime.Now;
            }
            else
            {
                entity.DatumSpasavanja = request.DatumSpasavanja;
            }
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(SpaseniDijeloviUpdateR request, Database.SpaseniDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.Find(request.DijeloviId);
                if (dio == null)
                {
                    throw new Exception("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.DatumSpasavanja.HasValue)
            {
                entity.DatumSpasavanja = request.DatumSpasavanja.Value;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
