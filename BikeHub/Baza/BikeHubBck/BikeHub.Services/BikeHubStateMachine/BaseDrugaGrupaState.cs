using BikeHub.Model;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services.BikeHubStateMachine
{
    public class BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> where TModel : class where TDbEntity : class
    {
        public BikeHubDbContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseDrugaGrupaState(BikeHubDbContext context, IMapper mapper, IServiceProvider serviceProvider)
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

        public virtual TModel MarkAsFinished(int id)
        {
            throw new UserException("Method not allowed");
        }

        public BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate> CreateState(string stateName)
        {
            switch (stateName)
            {
                case "kreiran":
                    return ServiceProvider.GetService<KreiranDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "izmijenjen":
                    return ServiceProvider.GetService<IzmijenjenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "aktivan":
                    return ServiceProvider.GetService<AktivanDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "zavrseno":
                    return ServiceProvider.GetService<ZavrsenoDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "obrisan":
                    return ServiceProvider.GetService<ObrisanDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                case "vracen":
                    return ServiceProvider.GetService<VracenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
                default: throw new Exception("State not recognized");
            }
        }
    }
}
