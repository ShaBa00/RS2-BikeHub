using BikeHub.Model;
using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
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
    public class NarudzbaBicikliService : BaseCRUDService<Model.NarudzbaFM.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliSearchObject,
        Database.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliInsertR, Model.NarudzbaFM.NarudzbaBicikliUpdateR>, INarudzbaBicikliService
    {
        private BikeHubDbContext _context;
        public BaseDrugaGrupaState<Model.NarudzbaFM.NarudzbaBicikli, Database.NarudzbaBicikli,
           Database.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliUpdateR> _baseDrugaGrupaState;
        public NarudzbaBicikliService(BikeHubDbContext context, IMapper mapper, BaseDrugaGrupaState<Model.NarudzbaFM.NarudzbaBicikli, Database.NarudzbaBicikli,
           Database.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliUpdateR> baseDrugaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
        }

        public override IQueryable<Database.NarudzbaBicikli> AddFilter(NarudzbaBicikliSearchObject search, IQueryable<Database.NarudzbaBicikli> query)
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

        public override void BeforeInsert(NarudzbaBicikliInsertR request, Database.NarudzbaBicikli entity)
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
            if (request.BiciklId <= 0)
            {
                throw new UserException("BiciklId mora biti veći od 0.");
            }
            var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId);
            if (bicikl == null)
            {
                throw new UserException("Bicikl sa datim ID-om ne postoji.");
            }
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina mora biti veća od 0.");
            }
            if (bicikl.Kolicina < request.Kolicina)
            {
                throw new UserException($"Na stanju nema dovoljan broj odabranih bicikala. Broj bicikala na stanju je {bicikl.Kolicina}.");
            }
            bicikl.Kolicina -= request.Kolicina;
            _context.Bicikls.Update(bicikl);
            _context.SaveChanges();
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina mora biti veća od 0.");
            }
            entity.NarudzbaId = request.NarudzbaId;
            entity.BiciklId = request.BiciklId;
            entity.Kolicina = request.Kolicina;
            entity.Cijena = bicikl.Cijena*request.Kolicina;
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(NarudzbaBicikliUpdateR request, Database.NarudzbaBicikli entity)
        {
            if (request.BiciklId.HasValue)
            {
                var noviBicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId.Value);
                if (noviBicikl == null)
                {
                    throw new UserException("Bicikl sa datim ID-om ne postoji.");
                }
                var stariBicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == entity.BiciklId);
                if (stariBicikl != null)
                {
                    stariBicikl.Kolicina += entity.Kolicina;  
                    _context.Bicikls.Update(stariBicikl);
                }
                if (request.Kolicina.HasValue)
                {
                    var novaKolicina = request.Kolicina.Value;

                    if (noviBicikl.Kolicina < novaKolicina)
                    {
                        throw new UserException($"Na stanju nema dovoljno novih bicikala. Broj bicikala na stanju je {noviBicikl.Kolicina}.");
                    }

                    noviBicikl.Kolicina -= novaKolicina;
                    _context.Bicikls.Update(noviBicikl);
                    entity.Kolicina = novaKolicina;
                    entity.Cijena = noviBicikl.Cijena * novaKolicina;
                }
                entity.BiciklId = request.BiciklId.Value;
                _context.SaveChanges();
            }
            else if (request.Kolicina.HasValue)
            {
                var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == entity.BiciklId);

                var staraKolicina = entity.Kolicina;
                var novaKolicina = request.Kolicina.Value;
                var razlika = novaKolicina - staraKolicina;

                if (razlika > 0)
                {
                    if (bicikl.Kolicina < razlika)
                    {
                        throw new UserException($"Na stanju nema dovoljno dodatnih bicikala. Broj bicikala na stanju je {bicikl.Kolicina}.");
                    }
                    bicikl.Kolicina -= razlika;
                }
                else if (razlika < 0)
                {
                    bicikl.Kolicina += Math.Abs(razlika);
                }

                _context.Bicikls.Update(bicikl);
                _context.SaveChanges();

                entity.Kolicina = novaKolicina;
                entity.Cijena = bicikl.Cijena * novaKolicina;
            }
            if (request.NarudzbaId.HasValue)
            {
                var narudzba=_context.Narudzbas.FirstOrDefault(x=>x.NarudzbaId == request.NarudzbaId);
                if(narudzba == null)
                {
                    throw new UserException("Narudžba sa datim ID-om ne postoji.");
                }
                entity.NarudzbaId = request.NarudzbaId.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.NarudzbaFM.NarudzbaBicikli Insert(NarudzbaBicikliInsertR request)
        {
            var entity = new Database.NarudzbaBicikli();
            BeforeInsert(request, entity);
            var state = _baseDrugaGrupaState.CreateState("kreiran");
            return state.Insert(entity);
        }

        public override Model.NarudzbaFM.NarudzbaBicikli Update(int id, NarudzbaBicikliUpdateR request)
        {
            var set = Context.Set<Database.NarudzbaBicikli>();
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
