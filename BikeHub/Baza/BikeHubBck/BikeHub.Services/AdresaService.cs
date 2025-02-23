﻿using BikeHub.Model;
using BikeHub.Model.AdresaFM;
using BikeHub.Model.Ostalo;
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
                throw new UserException("KorisnikId ne smije biti null");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji");
            }
            var existingAddress = _context.Adresas.FirstOrDefault(a => a.KorisnikId == request.KorisnikId);
            if (existingAddress != null)
            {
                throw new UserException("Nova adresa se ne može dodati jer već postoji stara adresa za istog korisnika. Potrebno je ažurirati postojeću adresu.");
            }
            if (string.IsNullOrWhiteSpace(request.Grad))
            {
                throw new UserException("Grad ne smije biti prazan");
            }
            if (string.IsNullOrWhiteSpace(request.PostanskiBroj))
            {
                throw new UserException("Poštanski broj ne smije biti prazan");
            }
            if (string.IsNullOrWhiteSpace(request.Ulica))
            {
                throw new UserException("Ulica ne smije biti prazna");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.Grad = request.Grad;
            entity.PostanskiBroj = request.PostanskiBroj;
            entity.Ulica = request.Ulica;
            base.BeforeInsert(request, entity);
        }
        public override Model.AdresaFM.Adresa Insert(AdresaInsertR request)
        {
            var entity = new Database.Adresa();
            BeforeInsert(request, entity);
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
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

        public override Model.AdresaFM.Adresa Update(int id, AdresaUpdateR request)
        {
            var set = Context.Set<Database.Adresa>();
            var entity = set.Find(id);
            if (entity == null)
            {
                throw new UserException("Entitet sa datim ID-om ne postoji");
            }
            BeforeUpdate(request,entity);
            var state = _basePrvaGrupaState.CreateState(entity.Status);
            Mapper.Map(entity, request);
            return state.Update(id,request);
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

        public List<GradKorisniciDto> GetGradove()
        {
            var gradoviGrupe = _context.Adresas
                .GroupBy(a => a.Grad)
                .Select(g => new GradKorisniciDto
                {
                    Grad = g.Key,
                    KorisnikIds = g.Select(a => a.KorisnikId).ToList()
                })
                .ToList();

            int index = 1;
            foreach (var grad in gradoviGrupe)
            {
                grad.GradId = index++;
            }

            return gradoviGrupe;
        }

    }
}
