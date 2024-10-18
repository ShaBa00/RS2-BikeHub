using BikeHub.Model;
using BikeHub.Model.NarudzbaFM;
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
    public class NarudzbaService : BaseCRUDService<Model.NarudzbaFM.Narudzba, Model.NarudzbaFM.NarudzbaSearchObject, Database.Narudzba,
                                                    Model.NarudzbaFM.NarudzbaInsertR, Model.NarudzbaFM.NarudzbaUpdateR>, INarudzbaService
    {
        private BikeHubDbContext _context;
        public BaseDrugaGrupaState<Model.NarudzbaFM.Narudzba, Database.Narudzba,
            Model.NarudzbaFM.NarudzbaInsertR, Model.NarudzbaFM.NarudzbaUpdateR> _baseDrugaGrupaState;
        public NarudzbaService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.NarudzbaFM.Narudzba, Database.Narudzba,
            Model.NarudzbaFM.NarudzbaInsertR, Model.NarudzbaFM.NarudzbaUpdateR> baseDrugaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
        }

        public override IQueryable<Database.Narudzba> AddFilter(NarudzbaSearchObject search, IQueryable<Database.Narudzba> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.DatumNarudzbe != null)
            {
                NoviQuery = NoviQuery.Where(x => x.DatumNarudzbe.Date == search.DatumNarudzbe.Value.Date);
            }
            if (search?.NarudzbaBicikliIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.NarudzbaBiciklis);
            }
            if (search?.NarudzbaDijeloviIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.NarudzbaDijelovis);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(NarudzbaInsertR request, Database.Narudzba entity)
        {
            if (request.KorisnikId == 0)
            {
                throw new UserException("KorisnikId ne smije biti prazan ili nula.");
            }
            var korisnik = _context.Korisniks.FirstOrDefault(x => x.KorisnikId == request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.DatumNarudzbe = DateTime.Now;
            base.BeforeInsert(request, entity);
        }

        //public override void BeforeUpdate(NarudzbaUpdateR request, Database.Narudzba entity)
        //{
        //    if (!string.IsNullOrWhiteSpace(request.Status))
        //    {
        //        entity.Status = request.Status;
        //    }
        //    base.BeforeUpdate(request, entity);
        //}

        public override Model.NarudzbaFM.Narudzba Insert(NarudzbaInsertR request)
        {
            var entity = new Database.Narudzba();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override Model.NarudzbaFM.Narudzba Update(int id, NarudzbaUpdateR request)
        {
            var set = Context.Set<Database.Narudzba>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            //BeforeUpdate(request, entity);
            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            return state.Update(id, request);
        }

        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }

        public override void Zavrsavanje(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            state.MarkAsFinished(id);
        }
    }
}
