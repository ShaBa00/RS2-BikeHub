using BikeHub.Model;
using BikeHub.Model.KorisnikFM;
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
    public class KorisnikInfoService : BaseCRUDService<Model.KorisnikFM.KorisnikInfo, Model.KorisnikFM.KorisnikInfoSearchObject,
        Database.KorisnikInfo, Model.KorisnikFM.KorisnikInfoInsertR, Model.KorisnikFM.KorisnikInfoUpdateR>, IKorisnikInfoService
    {
        private BikeHubDbContext _context;
        public BasePrvaGrupaState<Model.KorisnikFM.KorisnikInfo, Database.KorisnikInfo, Model.KorisnikFM.KorisnikInfoInsertR,
            Model.KorisnikFM.KorisnikInfoUpdateR> _basePrvaGrupaState;

        public KorisnikInfoService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.KorisnikFM.KorisnikInfo, Database.KorisnikInfo, Model.KorisnikFM.KorisnikInfoInsertR,
            Model.KorisnikFM.KorisnikInfoUpdateR> basePrvaGrupaState) 
        : base(context, mapper)        
        { 
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }

        public override IQueryable<Database.KorisnikInfo> AddFilter(KorisnikInfoSearchObject search, IQueryable<Database.KorisnikInfo> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.ImePrezime))
            {
                NoviQuery = NoviQuery.Where(x => x.ImePrezime.StartsWith(search.ImePrezime));
            }
            if (!string.IsNullOrWhiteSpace(search?.Telefon))
            {
                NoviQuery = NoviQuery.Where(x => x.Telefon.StartsWith(search.Telefon));
            }
            if (search?.BrojNarudbi != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojNarudbi == search.BrojNarudbi);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }
       
        public override void BeforeInsert(KorisnikInfoInsertR request, Database.KorisnikInfo entity)
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
            if (korisnik.Status == "obrisan")
            {
                throw new UserException("Za obrisanog korisnika nije moguće dodati zapis.");
            }
            var korisnikInfo = _context.KorisnikInfos.FirstOrDefault(x => x.KorisnikId == request.KorisnikId);
            if (korisnikInfo != null)
            {
                if (korisnikInfo.Status != "obrisan")
                {
                    throw new UserException("Informacije za korisnika sa ovim ID-om su već dodate. " +
                                        "Potrebno je izvršiti izmjenu ili obrisati postojeće podatke.");
                }
            }
            if (string.IsNullOrWhiteSpace(request.ImePrezime))
            {
                throw new UserException("ImePrezime ne smije biti prazno.");
            }

            if (string.IsNullOrWhiteSpace(request.Telefon))
            {
                throw new UserException("Telefon ne smije biti prazan.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.ImePrezime = request.ImePrezime;
            entity.Telefon = request.Telefon;
            base.BeforeInsert(request, entity);
        }

        public override Model.KorisnikFM.KorisnikInfo Insert(KorisnikInfoInsertR request)
        {
            var entity = new Database.KorisnikInfo();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        
        public override void BeforeUpdate(KorisnikInfoUpdateR request, Database.KorisnikInfo entity)
        {
            if (!string.IsNullOrWhiteSpace(request.ImePrezime))
            {
                entity.ImePrezime = request.ImePrezime;
            }
            if (!string.IsNullOrWhiteSpace(request.Telefon))
            {
                entity.Telefon = request.Telefon;
            }
            base.BeforeUpdate(request, entity);
        }
        
        public override Model.KorisnikFM.KorisnikInfo Update(int id, KorisnikInfoUpdateR request)
        {
            var set = Context.Set<Database.KorisnikInfo>();
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
