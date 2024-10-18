using BikeHub.Model;
using BikeHub.Model.BicikliFM;
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
    public class BicikliService : BaseCRUDService<Model.BicikliFM.Bicikli, BicikliSearchObject, Database.Bicikl,
        Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> , IBicikliService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.BicikliFM.Bicikli, Database.Bicikl,
        Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> _basePrvaGrupaState;

        public BicikliService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.BicikliFM.Bicikli, Database.Bicikl,
        Model.BicikliFM.BicikliInsertR, Model.BicikliFM.BicikliUpdateR> basePrvaGrupaState)
        :base(context,mapper){ _context = context; _basePrvaGrupaState = basePrvaGrupaState; }

        public override IQueryable<Bicikl> AddFilter(BicikliSearchObject search, IQueryable<Bicikl> query)
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
            if (search?.Cijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena == search.Cijena);
            }
            if (search?.Kolicina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Kolicina == search.Kolicina);
            }
            if (!string.IsNullOrWhiteSpace(search?.VelicinaRama))
            {
                NoviQuery = NoviQuery.Where(x => x.VelicinaRama == search.VelicinaRama);
            }

            if (!string.IsNullOrWhiteSpace(search?.VelicinaTocka))
            {
                NoviQuery = NoviQuery.Where(x => x.VelicinaTocka == search.VelicinaTocka);
            }

            if (search?.BrojBrzina != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojBrzina == search.BrojBrzina);
            }

            if (search?.KategorijaId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KategorijaId == search.KategorijaId);
            }
            return NoviQuery;
        }
        public override void BeforeInsert(BicikliInsertR request, Bicikl entity)
        {
            if (string.IsNullOrWhiteSpace(request.Naziv))
            {
                throw new UserException("Naziv bicikla ne smije biti prazan");
            }
            entity.Naziv = request.Naziv;
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena bicikla mora biti veća od nule");
            }
            entity.Cijena = request.Cijena;
            if (string.IsNullOrWhiteSpace(request.VelicinaRama))
            {
                throw new UserException("Veličina rama ne smije biti prazna");
            }
            entity.VelicinaRama = request.VelicinaRama;
            if (string.IsNullOrWhiteSpace(request.VelicinaTocka))
            {
                throw new UserException("Veličina točka ne smije biti prazna");
            }
            entity.VelicinaTocka = request.VelicinaTocka;
            if (request.BrojBrzina <= 0)
            {
                throw new UserException("Broj brzina mora biti veći od nule");
            }
            entity.BrojBrzina = request.BrojBrzina;
            if (request.Kolicina <= 0)
            {
                throw new UserException("Kolicina mora biti veći od nule");
            }
            entity.Kolicina = request.Kolicina;
            if (request.KategorijaId <= 0)
            {
                throw new UserException("Kategorija mora biti odabrana");
            }
            var kategorija = _context.Kategorijas.Find(request.KategorijaId);
            if (kategorija == null)
            {
                throw new UserException("Kategorija sa datim ID-om ne postoji");
            }
            entity.KategorijaId = request.KategorijaId;
            base.BeforeInsert(request, entity);
        }
        public override void BeforeUpdate(BicikliUpdateR request, Bicikl entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Naziv))
            {
                entity.Naziv = request.Naziv;
            }
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new UserException("Cijena bicikla mora biti veća od nule");
                }
                entity.Cijena = request.Cijena.Value; 
            }
            if (request.Kolicina.HasValue)
            {
                if (request.Kolicina < 0)
                {
                    throw new UserException("Kolicina bicikla ne moze biti manja od 0");
                }
                entity.Kolicina = request.Kolicina.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.VelicinaRama))
            {
                entity.VelicinaRama = request.VelicinaRama;
            }
            if (!string.IsNullOrWhiteSpace(request.VelicinaTocka))
            {
                entity.VelicinaTocka = request.VelicinaTocka;
            }
            if (request.BrojBrzina.HasValue)
            {
                if (request.BrojBrzina <= 0)
                {
                    throw new UserException("Broj brzina mora biti veći od nule");
                }
                entity.BrojBrzina = request.BrojBrzina.Value;
            }
            if (request.KategorijaId.HasValue)
            {
                var kategorija = _context.Kategorijas.Find(request.KategorijaId);
                if (kategorija == null)
                {
                    throw new UserException("Kategorija sa datim ID-om ne postoji");
                }
                entity.KategorijaId = request.KategorijaId.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Bicikli Insert(BicikliInsertR request)
        {
            var entity = new Database.Bicikl();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Bicikli Update(int id, BicikliUpdateR request)
        {
            var set = Context.Set<Database.Bicikl>();
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
                throw new UserException("Entitet sa datim ID-om ne postoji.");
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
