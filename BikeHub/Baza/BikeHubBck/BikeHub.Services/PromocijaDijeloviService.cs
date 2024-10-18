using BikeHub.Model;
using BikeHub.Model.PromocijaFM;
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
    public class PromocijaDijeloviService : BaseCRUDService<Model.PromocijaFM.PromocijaDijelovi, Model.PromocijaFM.PromocijaDijeloviSearchObject,
        Database.PromocijaDijelovi, Model.PromocijaFM.PromocijaDijeloviInsertR, Model.PromocijaFM.PromocijaDijeloviUpdateR>, IPromocijaDijeloviService
    {
        private BikeHubDbContext _context;
        public BaseDrugaGrupaState<Model.PromocijaFM.PromocijaDijelovi, Database.PromocijaDijelovi,
            Model.PromocijaFM.PromocijaDijeloviInsertR, Model.PromocijaFM.PromocijaDijeloviUpdateR> _baseDrugaGrupaState;
        public PromocijaDijeloviService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.PromocijaFM.PromocijaDijelovi, Database.PromocijaDijelovi,
            Model.PromocijaFM.PromocijaDijeloviInsertR, Model.PromocijaFM.PromocijaDijeloviUpdateR> baseDrugaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
        }
        public override IQueryable<Database.PromocijaDijelovi> AddFilter(PromocijaDijeloviSearchObject search, IQueryable<Database.PromocijaDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.CijenaPromocije != null)
            {
                NoviQuery = NoviQuery.Where(x => x.CijenaPromocije == search.CijenaPromocije);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(PromocijaDijeloviInsertR request, Database.PromocijaDijelovi entity)
        {
            var dio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == request.DijeloviId);
            if (dio == null)
            {
                throw new UserException("Dio sa datim ID-om ne postoji.");
            }
            if (request.DatumPocetka == default(DateTime))
            {
                throw new UserException("Datum početka mora biti unesen.");
            }

            if (request.DatumZavrsetka == default(DateTime))
            {
                throw new UserException("Datum završetka mora biti unesen.");
            }
            if (request.DatumPocetka > request.DatumZavrsetka)
            {
                throw new UserException("Datum početka ne smije biti veći od datuma završetka.");
            }
            entity.DijeloviId = request.DijeloviId;
            entity.DatumPocetka = request.DatumPocetka;
            entity.DatumZavrsetka = request.DatumZavrsetka;
            var brojDana = (request.DatumZavrsetka - request.DatumPocetka).Days + 1;
            entity.CijenaPromocije = brojDana * 5;
            base.BeforeInsert(request, entity); 
        }

        public override void BeforeUpdate(PromocijaDijeloviUpdateR request, Database.PromocijaDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var dio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == request.DijeloviId.Value);
                if (dio == null)
                {
                    throw new UserException("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.DatumPocetka.HasValue && request.DatumZavrsetka.HasValue)
            {
                if (request.DatumPocetka.Value > request.DatumZavrsetka.Value)
                {
                    throw new UserException("Datum početka ne može biti veći od datuma završetka.");
                }

                entity.DatumPocetka = request.DatumPocetka.Value;
                entity.DatumZavrsetka = request.DatumZavrsetka.Value;
                var brojDana = (request.DatumZavrsetka.Value - request.DatumPocetka.Value).Days + 1;
                entity.CijenaPromocije = brojDana * 5;
            }
            else if (request.DatumPocetka.HasValue)
            {
                if (request.DatumPocetka.Value > entity.DatumZavrsetka)
                {
                    throw new UserException("Datum početka ne može biti veći od trenutnog datuma završetka.");
                }

                entity.DatumPocetka = request.DatumPocetka.Value;
                var brojDana = (entity.DatumZavrsetka - request.DatumPocetka.Value).Days + 1;
                entity.CijenaPromocije = brojDana * 5;
            }
            else if (request.DatumZavrsetka.HasValue)
            {
                if (entity.DatumPocetka > request.DatumZavrsetka.Value)
                {
                    throw new UserException("Datum završetka ne može biti manji od trenutnog datuma početka.");
                }

                entity.DatumZavrsetka = request.DatumZavrsetka.Value;
                var brojDana = (request.DatumZavrsetka.Value - entity.DatumPocetka).Days + 1;
                entity.CijenaPromocije = brojDana * 5;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.PromocijaFM.PromocijaDijelovi Insert(PromocijaDijeloviInsertR request)
        {
            var entity = new Database.PromocijaDijelovi();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override Model.PromocijaFM.PromocijaDijelovi Update(int id, PromocijaDijeloviUpdateR request)
        {
            var set = Context.Set<Database.PromocijaDijelovi>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request, entity);
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
