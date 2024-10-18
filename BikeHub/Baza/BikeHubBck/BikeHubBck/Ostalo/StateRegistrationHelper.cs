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
        public static void DrugiRegisterStates<TModel, TDbEntity, TInsert, TUpdate>(IServiceCollection services) where TModel : class where TDbEntity : class
        {
            services.AddTransient<BaseDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<KreiranDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<IzmijenjenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<AktivanDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<ObrisanDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<VracenDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
            services.AddTransient<ZavrsenoDrugaGrupaState<TModel, TDbEntity, TInsert, TUpdate>>();
        }
    }
}
