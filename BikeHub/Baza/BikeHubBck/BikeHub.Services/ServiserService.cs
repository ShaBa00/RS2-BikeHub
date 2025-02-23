﻿using BikeHub.Model;
using BikeHub.Model.Ostalo;
using BikeHub.Model.PromocijaFM;
using BikeHub.Model.ServisFM;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using MapsterMapper;
using PayPal.Api;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class ServiserService : BaseCRUDService<Model.ServisFM.Serviser, Model.ServisFM.ServiserSearchObject, Database.Serviser
                                                    , Model.ServisFM.ServiserInsertR, Model.ServisFM.ServiserUpdateR>, IServiserService
    {
        private BikeHubDbContext _context;
        private readonly IMapper _mapper;
        public BasePrvaGrupaState<Model.ServisFM.Serviser, Database.Serviser, Model.ServisFM.ServiserInsertR,
                        Model.ServisFM.ServiserUpdateR> _basePrvaGrupaState;

        public ServiserService(BikeHubDbContext context, IMapper mapper, BasePrvaGrupaState<Model.ServisFM.Serviser, Database.Serviser, Model.ServisFM.ServiserInsertR,
                        Model.ServisFM.ServiserUpdateR> basePrvaGrupaState) 
        : base(context, mapper)
        {
            _context = context;
            _basePrvaGrupaState = basePrvaGrupaState;
            _mapper = mapper;
        }

        public override IQueryable<Database.Serviser> AddFilter(ServiserSearchObject search, IQueryable<Database.Serviser> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                NoviQuery = NoviQuery.Where(x => x.Status.StartsWith(search.Status));
            }
            if (search?.PocetnaCijena != null && search?.KrajnjaCijena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.Cijena >= search.PocetnaCijena && x.Cijena <= search.KrajnjaCijena);
            }
            if (search?.UkupnaOcjena != null)
            {
                NoviQuery = NoviQuery.Where(x => x.UkupnaOcjena == search.UkupnaOcjena);
            }
            if (search?.BrojServisa != null)
            {
                NoviQuery = NoviQuery.Where(x => x.BrojServisa == search.BrojServisa);
            }
            if (!string.IsNullOrWhiteSpace(search?.SortOrder))
            {
                if (search.SortOrder.ToLower() == "asc")
                {
                    NoviQuery = NoviQuery.OrderBy(x => x.Cijena);
                }
                else if (search.SortOrder.ToLower() == "desc")
                {
                    NoviQuery = NoviQuery.OrderByDescending(x => x.Cijena);
                }
            }
            return NoviQuery;
        }

        public override void BeforeInsert(ServiserInsertR request, Database.Serviser entity)
        {
            if (request?.KorisnikId == null)
            {
                throw new UserException("KorisnikId ne smije biti null.");
            }
            var korisnik = _context.Korisniks.Find(request.KorisnikId);
            if (korisnik == null)
            {
                throw new UserException("Korisnik sa datim ID-om ne postoji.");
            }
            if (request.Cijena <= 0)
            {
                throw new UserException("Cijena mora biti veća od 0.");
            }
            entity.KorisnikId = request.KorisnikId;
            entity.Cijena = request.Cijena;
            base.BeforeInsert(request, entity);
        }

        public override Model.ServisFM.Serviser Insert(ServiserInsertR request)
        {
            var entity = new Database.Serviser();
            BeforeInsert(request, entity);
            request.UkupnaOcjena = 0;
            var state = _basePrvaGrupaState.CreateState("kreiran");
            return state.Insert(request);
        }

        public override void BeforeUpdate(ServiserUpdateR request, Database.Serviser entity)
        {
            if (request.Cijena.HasValue)
            {
                if (request.Cijena <= 0)
                {
                    throw new UserException("Cijena mora biti veća od 0.");
                }
                entity.Cijena = request.Cijena.Value;
            }
            base.BeforeUpdate(request, entity);
        }

        public override Model.ServisFM.Serviser Update(int id, ServiserUpdateR request)
        {
            var set = Context.Set<Database.Serviser>();
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

        public PagedResult<Model.Ostalo.ServiserDto> GetServiserDTOList(Model.ServisFM.ServiserSearchObjectDTO searchObject)
        {
            var query = from s in _context.Servisers
                        join k in _context.Korisniks on s.KorisnikId equals k.KorisnikId
                        join a in _context.Adresas on k.KorisnikId equals a.KorisnikId
                        select new Model.Ostalo.ServiserDto
                        {
                            ServiserId = s.ServiserId,
                            KorisnikId = s.KorisnikId,
                            Cijena = s.Cijena.Value,
                            BrojServisa = s.BrojServisa.Value,
                            Status = s.Status,
                            UkupnaOcjena = s.UkupnaOcjena.Value,
                            Username = k.Username,
                            Grad = a.Grad
                        };

            // Filtriranje
            if (searchObject.ServiserId != null)
                query = query.Where(x => x.ServiserId == searchObject.ServiserId);
            if (searchObject.KorisnikId != null)
                query = query.Where(x => x.KorisnikId == searchObject.KorisnikId);

            if (!string.IsNullOrWhiteSpace(searchObject?.Status))
                query = query.Where(x => x.Status == searchObject.Status);

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
            {
                query = query.Where(x => x.Username.Contains(searchObject.Username));
            }

            if (searchObject.PocetnaCijena != null && searchObject.KrajnjaCijena != null)
                query = query.Where(x => x.Cijena >= searchObject.PocetnaCijena && x.Cijena <= searchObject.KrajnjaCijena);

            if (searchObject.PocetniBrojServisa != null && searchObject.KrajnjiBrojServisa != null)
                query = query.Where(x => x.BrojServisa >= searchObject.PocetniBrojServisa && x.BrojServisa <= searchObject.KrajnjiBrojServisa);

            if (searchObject.PocetnaOcjena != null && searchObject.KrajnjaOcjena != null)
                query = query.Where(x => x.UkupnaOcjena >= searchObject.PocetnaOcjena && x.UkupnaOcjena <= searchObject.KrajnjaOcjena);

            if (!string.IsNullOrWhiteSpace(searchObject?.SortOrder))
            {
                if (searchObject.SortOrder.ToLower() == "asc")
                {
                    query = query.OrderBy(x => x.Cijena);
                }
                else if (searchObject.SortOrder.ToLower() == "desc")
                {
                    query = query.OrderByDescending(x => x.Cijena);
                }
            }

            // Paginacija ručno
            var totalCount = query.Count();

            List<Model.Ostalo.ServiserDto> resultsList;
            if (searchObject.Page == null || searchObject.PageSize == null)
            {
                // Ako su Page i PageSize null, vrati sve rezultate
                resultsList = query.ToList();
            }
            else
            {
                // Ako nisu null, primeni paginaciju
                var page = Math.Max(searchObject.Page.Value, 1); // Osiguraj da je page >= 1
                var pageSize = searchObject.PageSize.Value;

                resultsList = query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToList();
            }

            return new PagedResult<Model.Ostalo.ServiserDto>
            {
                Count = totalCount,
                ResultsList = resultsList
            };
        }
        public ServiserIzvjestaj GetServiserIzvjestaj()
        {
            var izvjestaj = new ServiserIzvjestaj();

            var serviseri = _context.Servisers.ToList();
            var rezervacije = _context.RezervacijaServisas.ToList();

            var najaktivnijiServiser = rezervacije
                .Where(r => r.Status == "zavrseno")
                .GroupBy(r => r.Serviser)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            if (najaktivnijiServiser != null)
            {
                izvjestaj.NajaktivnijiServiser = najaktivnijiServiser.Key.Korisnik.Username;
                izvjestaj.BrojZavrsenihServisa = najaktivnijiServiser.Count();
                izvjestaj.ZbirCijenaZavrsenihServisa = najaktivnijiServiser.Sum(r => r.Serviser.Cijena ?? 0);
            }

            var currentMonth = DateTime.Now.Month;
            var lastMonth = DateTime.Now.AddMonths(-1).Month;

            var najboljiServiserTrenutniMjesec = rezervacije
                .Where(r => r.Status == "zavrseno" && r.DatumRezervacije.Month == currentMonth)
                .GroupBy(r => r.Serviser)
                .OrderByDescending(g => g.Average(r => r.Ocjena ?? 0))
                .FirstOrDefault();

            if (najboljiServiserTrenutniMjesec != null)
            {
                izvjestaj.NajboljiServiserTrenutniMjesec = najboljiServiserTrenutniMjesec.Key.Korisnik.Username;
                izvjestaj.ZbirCijenaTrenutniMjesec = najboljiServiserTrenutniMjesec.Sum(r => r.Serviser.Cijena ?? 0);
                izvjestaj.ProsjecnaOcjenaTrenutniMjesec = najboljiServiserTrenutniMjesec.Average(r => r.Ocjena ?? 0);
            }

            var najboljiServiserProsliMjesec = rezervacije
                .Where(r => r.Status == "zavrseno" && r.DatumRezervacije.Month == lastMonth)
                .GroupBy(r => r.Serviser)
                .OrderByDescending(g => g.Average(r => r.Ocjena ?? 0))
                .FirstOrDefault();

            if (najboljiServiserProsliMjesec != null)
            {
                izvjestaj.NajboljiServiserProsliMjesec = najboljiServiserProsliMjesec.Key.Korisnik.Username;
                izvjestaj.ZbirCijenaProsliMjesec = najboljiServiserProsliMjesec.Sum(r => r.Serviser.Cijena ?? 0);
                izvjestaj.ProsjecnaOcjenaProsliMjesec = najboljiServiserProsliMjesec.Average(r => r.Ocjena ?? 0);
            }

            izvjestaj.UkupanBrojServisera = serviseri.Count;
            izvjestaj.UkupanBrojRezervacija = rezervacije.Count;

            return izvjestaj;
        }
    }
}
