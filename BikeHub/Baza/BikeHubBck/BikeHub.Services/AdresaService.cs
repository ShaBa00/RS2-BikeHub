using BikeHub.Model.AdresaFM;
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
    public class AdresaService : BaseCRUDService<Model.AdresaFM.Adresa, AdresaSearchObject,Database.Adresa, Model.AdresaFM.AdresaInsertR,
                                                   Model.AdresaFM.AdresaUpdateR>, IAdresaService
    {
        private BikeHubDbContext _context;

        public BasePrvaGrupaState<Model.AdresaFM.Adresa, Database.Adresa ,Model.AdresaFM.AdresaInsertR,
                                Model.AdresaFM.AdresaUpdateR> _basePrvaGrupaState;

        public AdresaService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.AdresaFM.Adresa, Database.Adresa, Model.AdresaFM.AdresaInsertR,
                                Model.AdresaFM.AdresaUpdateR> basePrvaGrupaState)  
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
        }


        public override IQueryable<Database.Adresa> AddFilter(AdresaSearchObject search, IQueryable<Database.Adresa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (search?.KorisnikId != null)
            {
                NoviQuery = NoviQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }
            if (!string.IsNullOrWhiteSpace(search?.Grad))
            {
                NoviQuery = NoviQuery.Where(x => x.Grad.StartsWith(search.Grad));
            }
            if (!string.IsNullOrWhiteSpace(search?.PostanskiBroj))
            {
                NoviQuery = NoviQuery.Where(x => x.PostanskiBroj.StartsWith(search.PostanskiBroj));
            }
            if (!string.IsNullOrWhiteSpace(search?.Ulica))
            {
                NoviQuery = NoviQuery.Where(x => x.Ulica.StartsWith(search.Ulica));
            }
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            return NoviQuery;
        }

        public override void BeforeInsert(AdresaInsertR request, Database.Adresa entity)
        {
            if (request?.KorisnikId == null)
            {
                throw new Exception("KorisnikId ne smije biti null");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new Exception("Korisnik sa datim ID-om ne postoji");
            }
            var existingAddress = _context.Adresas.FirstOrDefault(a => a.KorisnikId == request.KorisnikId);
            if (existingAddress != null)
            {
                throw new Exception("Nova adresa se ne može dodati jer već postoji stara adresa za istog korisnika. Potrebno je ažurirati postojeću adresu.");
            }
            entity.KorisnikId = request.KorisnikId;
            if (string.IsNullOrWhiteSpace(request.Grad))
            {
                throw new Exception("Grad ne smije biti prazan");
            }
            entity.Grad = request.Grad;
            if (string.IsNullOrWhiteSpace(request.PostanskiBroj))
            {
                throw new Exception("Poštanski broj ne smije biti prazan");
            }
            entity.PostanskiBroj = request.PostanskiBroj;
            if (string.IsNullOrWhiteSpace(request.Ulica))
            {
                throw new Exception("Ulica ne smije biti prazna");
            }
            entity.Ulica = request.Ulica;
            base.BeforeInsert(request, entity);
        }


        public override void BeforeUpdate(AdresaUpdateR request, Database.Adresa entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Grad))
            {
                entity.Grad = request.Grad;
            }
            if (!string.IsNullOrWhiteSpace(request.PostanskiBroj))
            {
                entity.PostanskiBroj = request.PostanskiBroj;
            }
            if (!string.IsNullOrWhiteSpace(request.Ulica))
            {
                entity.Ulica = request.Ulica;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.AdresaFM.Adresa Insert(AdresaInsertR request)
        {
            var entity = new Database.Adresa();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }
        public override Model.AdresaFM.Adresa Update(int id, AdresaUpdateR request)
        {
            var set = Context.Set<Database.Adresa>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new Exception("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request,entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            return state.Update(id,request);
        }
        public override void SoftDelete(int id)
        {
            var entity = GetById(id);
            if (entity == null)
            {
                throw new Exception("Entity not found.");
            }

            var state = _basePrvaGrupaState.CreateState(entity.Status);
            state.Delete(id);
        }


    }
}
