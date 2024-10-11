using BikeHub.Model.AdresaFM;
using BikeHub.Model.NarudzbaFM;
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
        public NarudzbaBicikliService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context; }

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
            return NoviQuery;
        }
        public override void BeforeInsert(NarudzbaBicikliInsertR request, Database.NarudzbaBicikli entity)
        {   
            if (request.NarudzbaId <= 0)
            {
                throw new Exception("NarudzbaId mora biti veći od 0.");
            }
            var narudzba = _context.Narudzbas.FirstOrDefault(x => x.NarudzbaId == request.NarudzbaId);
            if (narudzba == null)
            {
                throw new Exception("Narudžba sa datim ID-om ne postoji.");
            }
            if (request.BiciklId <= 0)
            {
                throw new Exception("BiciklId mora biti veći od 0.");
            }
            var bicikl = _context.Bicikls.FirstOrDefault(x => x.BiciklId == request.BiciklId);
            if (bicikl == null)
            {
                throw new Exception("Bicikl sa datim ID-om ne postoji.");
            }
            if (request.Kolicina <= 0)
            {
                throw new Exception("Kolicina mora biti veća od 0.");
            }
            if (bicikl.Kolicina < request.Kolicina)
            {
                throw new Exception($"Na stanju nema dovoljan broj odabranih bicikala. Broj bicikala na stanju je {bicikl.Kolicina}.");
            }
            bicikl.Kolicina -= request.Kolicina;
            _context.Bicikls.Update(bicikl);
            _context.SaveChanges();
            if (request.Kolicina <= 0)
            {
                throw new Exception("Kolicina mora biti veća od 0.");
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
                    throw new Exception("Bicikl sa datim ID-om ne postoji.");
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
                        throw new Exception($"Na stanju nema dovoljno novih bicikala. Broj bicikala na stanju je {noviBicikl.Kolicina}.");
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
                        throw new Exception($"Na stanju nema dovoljno dodatnih bicikala. Broj bicikala na stanju je {bicikl.Kolicina}.");
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
                    throw new Exception("Narudžba sa datim ID-om ne postoji.");
                }
                entity.NarudzbaId = request.NarudzbaId.Value;
            }
            base.BeforeUpdate(request, entity);
        }
    }
}
