using BikeHub.Model;
using BikeHub.Model.KategorijaFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class KategorijaService : BaseCRUDService<Model.KategorijaFM.Kategorija, KategorijaSearchObject, Database.Kategorija, 
        Model.KategorijaFM.KategorijaInsertR, Model.KategorijaFM.KategorijaUpdateR>, IKategorijaService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.KategorijaFM.Kategorija, Database.Kategorija,
        Model.KategorijaFM.KategorijaInsertR, Model.KategorijaFM.KategorijaUpdateR> _basePrvaGrupaState;

        public KategorijaService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.KategorijaFM.Kategorija, Database.Kategorija,
        Model.KategorijaFM.KategorijaInsertR, Model.KategorijaFM.KategorijaUpdateR> basePrvaGrupaState) 
        : base(context, mapper){ _context = context; _basePrvaGrupaState = basePrvaGrupaState; }

        public override IQueryable<Database.Kategorija> AddFilter(KategorijaSearchObject search, IQueryable<Database.Kategorija> query)
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
            if (search.IsBikeKategorija != null)
            {
                NoviQuery = NoviQuery.Where(x => x.IsBikeKategorija==search.IsBikeKategorija);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(KategorijaInsertR request, Database.Kategorija entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new UserException("Naziv ne smije biti prazan");
            }
            var naziv = _context.Kategorijas.FirstOrDefault(x => x.Naziv==request.Naziv);
            if(naziv != null)
            {
                throw new UserException("Kategorija s ovim nazivom vec postoji");
            }
            if (request.IsBikeKategorija == null)
            {
                throw new UserException("Potrebno je dodati i vrijednost IsBikeKategorija");
            }
            entity.Naziv = request.Naziv;
            base.BeforeInsert(request, entity);
        }

        public override Model.KategorijaFM.Kategorija Insert(KategorijaInsertR request)
        {
            var entity = new Database.Kategorija();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(KategorijaUpdateR request, Database.Kategorija entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                var naziv = _context.Kategorijas.FirstOrDefault(x => x.Naziv == request.Naziv);
                if (naziv!=null)
                {
                    throw new UserException("Kategorija s ovim nazivom vec postoji");
                }
                entity.Naziv = request.Naziv;
            }
            if (request.IsBikeKategorija != null)
            {
                entity.IsBikeKategorija = request.IsBikeKategorija;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.KategorijaFM.Kategorija Update(int id, KategorijaUpdateR request)
        {
            var set = Context.Set<Database.Kategorija>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            return state.Update(id, request);
        }

        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }

        public override void Zavrsavanje(int id)
        {
            throw new UserException("Za ovaj entitet nije moguce izvrsiti ovu naredbu");
        }
    }
}
