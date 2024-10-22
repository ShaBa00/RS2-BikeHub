using BikeHub.Model;
using BikeHub.Model.AdresaFM;
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
    public class NarudzbaDijeloviService : BaseCRUDService<Model.NarudzbaFM.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviSearchObject,
           Database.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviInsertR, Model.NarudzbaFM.NarudzbaDijeloviUpdateR>, INarudzbaDijeloviService
    {
        private BikeHubDbContext _context;
        public BaseDrugaGrupaState<Model.NarudzbaFM.NarudzbaDijelovi, Database.NarudzbaDijelovi,
            Database.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviUpdateR> _baseDrugaGrupaState;
        public NarudzbaDijeloviService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.NarudzbaFM.NarudzbaDijelovi, Database.NarudzbaDijelovi,
            Database.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviUpdateR> baseDrugaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
        }

        public override IQueryable<Database.NarudzbaDijelovi> AddFilter(NarudzbaDijeloviSearchObject search, IQueryable<Database.NarudzbaDijelovi> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.Kolicina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Kolicina == search.Kolicina);
            }
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override void BeforeInsert(NarudzbaDijeloviInsertR request, Database.NarudzbaDijelovi entity)
        {
            if (request.NarudzbaId <= 0)
            {
                throw new UserException("NarudzbaId mora biti veći od 0.");
            }
            var narudzba = _context.Narudzbas.FirstOrDefault(x => x.NarudzbaId == request.NarudzbaId);
            if (narudzba == null)
            {
                throw new UserException("Narudžba sa datim ID-om ne postoji.");
            }
            if (request.DijeloviId <= 0)
            {
                throw new UserException("DijeloviId mora biti veći od 0.");
            }
            var dio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == request.DijeloviId);
            if (dio == null)
            {
                throw new UserException("Dio sa datim ID-om ne postoji.");
            }
            if (dio.Kolicina < request.Kolicina)
            {
                throw new UserException($"Na stanju nema dovoljno dijelova. Broj dijelova na stanju je {dio.Kolicina}.");
            }
            dio.Kolicina -= request.Kolicina;
            entity.NarudzbaId = request.NarudzbaId;
            entity.DijeloviId = request.DijeloviId;
            entity.Kolicina = request.Kolicina;
            entity.Cijena = dio.Cijena * request.Kolicina;

            _context.Dijelovis.Update(dio);
            _context.SaveChanges();
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(NarudzbaDijeloviUpdateR request, Database.NarudzbaDijelovi entity)
        {
            if (request.DijeloviId.HasValue)
            {
                var noviDio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == request.DijeloviId.Value);
                if (noviDio == null)
                {
                    throw new UserException("Dio sa datim ID-om ne postoji.");
                }
                var stariDio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == entity.DijeloviId);
                if (stariDio != null)
                {
                    stariDio.Kolicina += entity.Kolicina;
                    _context.Dijelovis.Update(stariDio);
                }
                if (request.Kolicina.HasValue)
                {
                    var novaKolicina = request.Kolicina.Value;

                    if (noviDio.Kolicina < novaKolicina)
                    {
                        throw new UserException($"Na stanju nema dovoljno novih dijelova. Broj dijelova na stanju je {noviDio.Kolicina}.");
                    }
                    noviDio.Kolicina -= novaKolicina;
                    _context.Dijelovis.Update(noviDio);
                    entity.Kolicina = novaKolicina;
                    entity.Cijena = noviDio.Cijena * novaKolicina;
                }
                entity.DijeloviId = request.DijeloviId.Value;
                _context.SaveChanges();
            }
            else if (request.Kolicina.HasValue)
            {
                var dio = _context.Dijelovis.FirstOrDefault(x => x.DijeloviId == entity.DijeloviId);
                var staraKolicina = entity.Kolicina;
                var novaKolicina = request.Kolicina.Value;
                var razlika = novaKolicina - staraKolicina;
                if (razlika > 0)
                {
                    if (dio.Kolicina < razlika)
                    {
                        throw new UserException($"Na stanju nema dovoljno dodatnih dijelova. Broj dijelova na stanju je {dio.Kolicina}.");
                    }
                    dio.Kolicina -= razlika;
                }
                else if (razlika < 0)
                {
                    dio.Kolicina += Math.Abs(razlika);
                }

                _context.Dijelovis.Update(dio);
                _context.SaveChanges();

                entity.Kolicina = novaKolicina;
                entity.Cijena = dio.Cijena * novaKolicina;
            }
            if (request.NarudzbaId.HasValue)
            {
                var narudzba = _context.Narudzbas.FirstOrDefault(x => x.NarudzbaId == request.NarudzbaId);
                if (narudzba == null)
                {
                    throw new UserException("Narudžba sa datim ID-om ne postoji.");
                }
                entity.NarudzbaId = request.NarudzbaId.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.NarudzbaFM.NarudzbaDijelovi Insert(NarudzbaDijeloviInsertR request)
        {
            var entity = new Database.NarudzbaDijelovi();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(entity);
        }

        public override Model.NarudzbaFM.NarudzbaDijelovi Update(int id, NarudzbaDijeloviUpdateR request)
        {
            var set = Context.Set<Database.NarudzbaDijelovi>();
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
