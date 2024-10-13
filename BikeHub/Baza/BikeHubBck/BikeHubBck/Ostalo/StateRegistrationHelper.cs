using BikeHub.Services.BikeHubStateMachine;

namespace BikeHubBck.Ostalo
{
    public static class StateRegistrationHelper
    {
        public static void RegisterStates<TModel, TDbEntity, TInsert, TUpdate>(IServiceCollection services) where TModel : class where TDbEntity : class
        {
            services.AddTransient<BasePrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<KreiranPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<IzmijenjenPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<AktivanPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<ObrisanPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<VracenPrvaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
        }
    }
}
