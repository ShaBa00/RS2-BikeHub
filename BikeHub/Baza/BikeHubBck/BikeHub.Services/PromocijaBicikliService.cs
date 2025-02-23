﻿using BikeHub.Model;
using BikeHub.Model.PromocijaFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class PromocijaBicikliService : BaseCRUDService<Model.PromocijaFM.PromocijaBicikli, Model.PromocijaFM.PromocijaBicikliSearchObject,
        Database.PromocijaBicikli, Model.PromocijaFM.PromocijaBicikliInsertR, Model.PromocijaFM.PromocijaBicikliUpdateR>, IPromocijaBicikliService
    {
        private BikeHubDbContext _context;
        public BaseDrugaGrupaState<Model.PromocijaFM.PromocijaBicikli, Database.PromocijaBicikli,
            Database.PromocijaBicikli, Model.PromocijaFM.PromocijaBicikliUpdateR> _baseDrugaGrupaState;
        public PromocijaBicikliService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.PromocijaFM.PromocijaBicikli, Database.PromocijaBicikli,
            Database.PromocijaBicikli, Model.PromocijaFM.PromocijaBicikliUpdateR> baseDrugaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
        }
        public override IQueryable<Database.PromocijaBicikli> AddFilter(PromocijaBicikliSearchObject search, IQueryable<Database.PromocijaBicikli> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.BiciklId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BiciklId == search.BiciklId);
            }
            if (search?.CijenaPromocije != null)
            {
                NoviQuery = NoviQuery.Where(x => x.CijenaPromocije == search.CijenaPromocije);
            }
            return NoviQuery;
        }

        public override void BeforeInsert(PromocijaBicikliInsertR request, Database.PromocijaBicikli entity)
        {
            var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId);
            if (bicikl == null)
            {
                throw new UserException("Bicikl sa datim ID-om ne postoji.");
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

            var existingPromotion = _context.PromocijaBiciklis
                .FirstOrDefault(p => p.BiciklId == request.BiciklId &&
                                     p.DatumPocetka <= request.DatumZavrsetka &&
                                     p.DatumZavrsetka >= request.DatumPocetka);
            if (existingPromotion != null)
            {
                throw new UserException("Artikal je već promovisan u zadatim datumima.");
            }

            entity.BiciklId = request.BiciklId;
            entity.DatumPocetka = request.DatumPocetka;
            entity.DatumZavrsetka = request.DatumZavrsetka;
            var brojDana = (request.DatumZavrsetka - request.DatumPocetka).Days + 1;
            entity.CijenaPromocije = brojDana * 5;
            base.BeforeInsert(request, entity);
        }

        public override Model.PromocijaFM.PromocijaBicikli Insert(PromocijaBicikliInsertR request)
        {
            var entity = new Database.PromocijaBicikli();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(entity);
        }

        public override void BeforeUpdate(PromocijaBicikliUpdateR request, Database.PromocijaBicikli entity)
        {
            if (request.BiciklId.HasValue)
            {
                var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId.Value);
                if (bicikl == null)
                {
                    throw new UserException("Bicikl sa datim ID-om ne postoji.");
                }
                entity.BiciklId = request.BiciklId.Value;
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

        public override Model.PromocijaFM.PromocijaBicikli Update(int id, PromocijaBicikliUpdateR request)
        {
            var set = Context.Set<Database.PromocijaBicikli>();
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

        public IzvjestajPromocija GetIzvjestajPromocija()
        {
            var izvjestaj = new IzvjestajPromocija();

            var promocijeBicikli = _context.PromocijaBiciklis.ToList();
            var promocijeDijelovi = _context.PromocijaDijelovis.ToList();

            izvjestaj.UkupnaZarada = promocijeBicikli.Sum(p => p.CijenaPromocije) + promocijeDijelovi.Sum(p => p.CijenaPromocije);
            izvjestaj.BrojPromocija = promocijeBicikli.Count() + promocijeDijelovi.Count();
            izvjestaj.BrojAktivnihPromocija = promocijeBicikli.Count(p => p.Status == "aktivan") + promocijeDijelovi.Count(p => p.Status == "aktivan");

            var currentMonth = DateTime.Now.Month;
            var lastMonth = DateTime.Now.AddMonths(-1).Month;

            izvjestaj.ZbirCijenePromocijaTrenutniMjesec = promocijeBicikli.Where(p => p.DatumPocetka.Month == currentMonth).Sum(p => p.CijenaPromocije) +
                                                          promocijeDijelovi.Where(p => p.DatumPocetka.Month == currentMonth).Sum(p => p.CijenaPromocije);

            izvjestaj.BrojPromocijaTrenutniMjesec = promocijeBicikli.Count(p => p.DatumPocetka.Month == currentMonth) +
                                                    promocijeDijelovi.Count(p => p.DatumPocetka.Month == currentMonth);

            izvjestaj.ZbirCijenePromocijaProsliMjesec = promocijeBicikli.Where(p => p.DatumPocetka.Month == lastMonth).Sum(p => p.CijenaPromocije) +
                                                        promocijeDijelovi.Where(p => p.DatumPocetka.Month == lastMonth).Sum(p => p.CijenaPromocije);

            izvjestaj.BrojPromocijaProsliMjesec = promocijeBicikli.Count(p => p.DatumPocetka.Month == lastMonth) +
                                                  promocijeDijelovi.Count(p => p.DatumPocetka.Month == lastMonth);

            var groupedPromocije = promocijeBicikli.Concat<object>(promocijeDijelovi)
                .GroupBy(p => ((dynamic)p).DatumPocetka.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    TotalZarada = g.Sum(p => (decimal)((dynamic)p).CijenaPromocije)
                })
                .OrderByDescending(x => x.TotalZarada)
                .FirstOrDefault();


            if (groupedPromocije != null)
            {
                izvjestaj.MjesecSaNajvisePromocija = new DateTime(1, groupedPromocije.Month, 1).ToString("MMMM", new CultureInfo("en-US"));
                izvjestaj.NajvecaZaradaMjeseca = groupedPromocije.TotalZarada;
            }

            return izvjestaj;
        }


    }
}
