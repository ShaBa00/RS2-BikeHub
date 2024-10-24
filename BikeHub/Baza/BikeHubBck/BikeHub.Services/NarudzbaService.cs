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
            Database.Narudzba, Model.NarudzbaFM.NarudzbaUpdateR> _baseDrugaGrupaState;

        private readonly NarudzbaBicikliService _narudzbaBicikliService;
        private readonly NarudzbaDijeloviService _narudzbaDijeloviService;

        public NarudzbaService(
            BikeHubDbContext context,
            IMapper mapper,
            BaseDrugaGrupaState<Model.NarudzbaFM.Narudzba, Database.Narudzba,
                Database.Narudzba, Model.NarudzbaFM.NarudzbaUpdateR> baseDrugaGrupaState,
            INarudzbaBicikliService narudzbaBicikliService,  
            INarudzbaDijeloviService narudzbaDijeloviService)  
            : base(context, mapper)
        {
            _context = context;
            _baseDrugaGrupaState = baseDrugaGrupaState;
            _narudzbaBicikliService = (NarudzbaBicikliService)narudzbaBicikliService;
            _narudzbaDijeloviService = (NarudzbaDijeloviService)narudzbaDijeloviService;
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
            return state.Insert(entity);
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
            var entityN = GetById(id);
            if (entityN == null)
            {
                throw new UserException("Entity not found.");
            }
            var narudzbaBiciklis = _context.NarudzbaBiciklis.Where(nb => nb.NarudzbaId == id).ToList();
            foreach (var narudzbaBicikli in narudzbaBiciklis)
            {
                _narudzbaBicikliService.SoftDelete(narudzbaBicikli.NarudzbaBicikliId);
            }
            var narudzbaDijelovis = _context.NarudzbaDijelovis.Where(nd => nd.NarudzbaId == id).ToList();
            foreach (var narudzbaDijelovi in narudzbaDijelovis)
            {
                _narudzbaDijeloviService.SoftDelete(narudzbaDijelovi.NarudzbaDijeloviId);
            }
            var state = _baseDrugaGrupaState.CreateState(entityN.Status);
            state.Delete(id);
        }

        public override void Zavrsavanje(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var narudzbaBiciklis = _context.NarudzbaBiciklis.Where(nb => nb.NarudzbaId == id).ToList();
            var narudzbaDijelovis = _context.NarudzbaDijelovis.Where(nd => nd.NarudzbaId == id).ToList();

            if (narudzbaBiciklis.Any() && narudzbaDijelovis.Any())
            {
                foreach (var narudzbaBicikli in narudzbaBiciklis)
                {
                    foreach (var narudzbaDijelovi in narudzbaDijelovis)
                    {
                        var recommendedKategorija = _context.RecommendedKategorijas
                            .FirstOrDefault(rk => rk.BicikliId == narudzbaBicikli.BiciklId && rk.DijeloviId == narudzbaDijelovi.DijeloviId);

                        if (recommendedKategorija != null)
                        {
                            recommendedKategorija.BrojPreporuka = (recommendedKategorija.BrojPreporuka ?? 0) + 1;
                            _context.RecommendedKategorijas.Update(recommendedKategorija);
                        }
                        else
                        {
                            var noviRecommendedKategorija = new RecommendedKategorija
                            {
                                BicikliId = narudzbaBicikli.BiciklId,
                                DijeloviId = narudzbaDijelovi.DijeloviId,
                                BrojPreporuka = 1,  
                                DatumKreiranja = DateTime.Now,
                                Status = "kreiran"
                            };
                            _context.RecommendedKategorijas.Add(noviRecommendedKategorija);
                        }
                        _context.SaveChanges();
                    }
                }
            }
            foreach (var narudzbaBicikli in narudzbaBiciklis)
            {
                _narudzbaBicikliService.Zavrsavanje(narudzbaBicikli.NarudzbaBicikliId);
            }
            foreach (var narudzbaDijelovi in narudzbaDijelovis)
            {
                _narudzbaDijeloviService.Zavrsavanje(narudzbaDijelovi.NarudzbaDijeloviId);
            }
            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            state.MarkAsFinished(id);
        }

        public override void Aktivacija(int id, bool aktivacija)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            var narudzbaBiciklis = _context.NarudzbaBiciklis.Where(nb => nb.NarudzbaId == id).ToList();
            foreach (var narudzbaBicikli in narudzbaBiciklis)
            {
                _narudzbaBicikliService.Aktivacija(narudzbaBicikli.NarudzbaBicikliId,aktivacija);
            }
            var narudzbaDijelovis = _context.NarudzbaDijelovis.Where(nd => nd.NarudzbaId == id).ToList();
            foreach (var narudzbaDijelovi in narudzbaDijelovis)
            {
                _narudzbaDijeloviService.Aktivacija(narudzbaDijelovi.NarudzbaDijeloviId, aktivacija);
            }
            var state = _baseDrugaGrupaState.CreateState(entity.Status);
            base.Aktivacija(id, aktivacija);
        }
    }
}
