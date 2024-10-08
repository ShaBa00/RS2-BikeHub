using BikeHub.Model.AdresaFM;
using BikeHub.Model.PromocijaFM;
using BikeHub.Model.ServisFM;
using BikeHub.Model.SlikeFM;
using BikeHub.Model.SpaseniFM;
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
    public class AdresaService : BaseCRUDService<Model.AdresaFM.Adresa, AdresaSearchObject,Database.Adresa, Model.AdresaFM.AdresaInsertR, Model.AdresaFM.AdresaUpdateR>, IAdresaService
    {
        private BikeHubDbContext _context;
        public AdresaService(BikeHubDbContext context, IMapper mapper) 
        : base(context, mapper){ _context = context;   }
        public override IQueryable<Database.Adresa> AddFilter(AdresaSearchObject search, IQueryable<Database.Adresa> query)
        {
            var NoviQuery = base.AddFilter(search, query);
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
            //if (request?.KorisnikId != null)
            //{
            //    var korisnik = _context.Korisniks.Find(request.KorisnikId);
            //    if (korisnik != null)
            //    {
            //        entity.KorisnikId = request.KorisnikId.Value;
            //    }
            //    else
            //    {
            //        throw new Exception("Korisnik sa datim ID-om ne postoji");
            //    }
            //}
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
    }
}
