using BikeHub.Model.PromocijaFM;
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
        public PromocijaDijeloviService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper) { _context = context; }
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
                throw new Exception("Dio sa datim ID-om ne postoji.");
            }
            if (request.DatumPocetka == default(DateTime))
            {
                throw new Exception("Datum početka mora biti unesen.");
            }

            if (request.DatumZavrsetka == default(DateTime))
            {
                throw new Exception("Datum završetka mora biti unesen.");
            }
            if (request.DatumPocetka > request.DatumZavrsetka)
            {
                throw new Exception("Datum početka ne smije biti veći od datuma završetka.");
            }
            if (string.IsNullOrWhiteSpace(request.Status))
            {
                throw new Exception("Status ne smije biti prazan.");
            }
            entity.DijeloviId = request.DijeloviId;
            entity.DatumPocetka = request.DatumPocetka;
            entity.DatumZavrsetka = request.DatumZavrsetka;
            entity.Status = request.Status;
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
                    throw new Exception("Dio sa datim ID-om ne postoji.");
                }
                entity.DijeloviId = request.DijeloviId.Value;
            }
            if (request.DatumPocetka.HasValue && request.DatumZavrsetka.HasValue)
            {
                if (request.DatumPocetka.Value > request.DatumZavrsetka.Value)
                {
                    throw new Exception("Datum početka ne može biti veći od datuma završetka.");
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
                    throw new Exception("Datum početka ne može biti veći od trenutnog datuma završetka.");
                }

                entity.DatumPocetka = request.DatumPocetka.Value;
                var brojDana = (entity.DatumZavrsetka - request.DatumPocetka.Value).Days + 1;
                entity.CijenaPromocije = brojDana * 5;
            }
            else if (request.DatumZavrsetka.HasValue)
            {
                if (entity.DatumPocetka > request.DatumZavrsetka.Value)
                {
                    throw new Exception("Datum završetka ne može biti manji od trenutnog datuma početka.");
                }

                entity.DatumZavrsetka = request.DatumZavrsetka.Value;
                var brojDana = (request.DatumZavrsetka.Value - entity.DatumPocetka).Days + 1;
                entity.CijenaPromocije = brojDana * 5;
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                entity.Status = request.Status;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
