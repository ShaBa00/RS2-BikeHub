using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace BikeHub.Services.BikeHubStateMachine
{
    // Pod prvu grupu spadaju: Bicikl, Dijelovi, PromocijaBicikli, PromocijaDijelovi, SlikeBicikli, SlikeDijelovi,
    // SpaseniBicikli, SpaseniDijelovi, Kategorija, RecommendedKategorija, Korisnik, KorisnikInfo, Serviser, Adresa
    public class BasePrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public BikeHubDbContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }
        public BasePrvaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }
        public virtual TModel Insert(TInsert request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual TModel Update(int id, TUpdate request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual TModel Activate(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual TModel Delete(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual TModel Return(int id)
        {
            throw new UserException("Method not allowed");
        }
        //public virtual List<string> AllowedActions(TDbEntity entity)
        //{
        //    throw new Exception("Metoda nije dozvoljena");
        //}
        public BasePrvaGrupaState<TModel, TDbEntity , TInsert, TUpdate> CreateState(string stateName)
        {
            switch (stateName)
            {
                case "kreiran":
                    return ServiceProvider.GetService<KreiranPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "izmijenjen":
                    return ServiceProvider.GetService<IzmijenjenPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "aktivan":
                    return ServiceProvider.GetService<AktivanPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "obrisan":
                    return ServiceProvider.GetService<ObrisanPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "vracen":
                    return ServiceProvider.GetService<VracenPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                default: throw new Exception("State not recognized");
            }
        }
    }
}
