using BikeHub.Services;
using BikeHub.Services.BikeHubStateMachine;
using BikeHub.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Localization;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using BikeHub.Model.AdresaFM;
using BikeHubBck.Ostalo;
using BikeHub.Model.BicikliFM;
using BikeHub.Model.DijeloviFM;
using BikeHub.Model.KategorijaFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Model.RecommendedKategorijaFM;
using BikeHub.Model.ServisFM;
using BikeHub.Model.SlikeFM;
using BikeHub.Model.SpaseniFM;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IKorisnikService, KorisnikService>();
builder.Services.AddTransient<IDijeloviService, DijeloviService>();
builder.Services.AddTransient<IBicikliService, BicikliService>();
builder.Services.AddTransient<IAdresaService, AdresaService>();
builder.Services.AddTransient<IKorisnikInfoService, KorisnikInfoService>();
builder.Services.AddTransient<INarudzbaService, NarudzbaService>();
builder.Services.AddTransient<IPromocijaBicikliService, PromocijaBicikliService>();
builder.Services.AddTransient<IPromocijaDijeloviService, PromocijaDijeloviService>();
builder.Services.AddTransient<INarudzbaBicikliService, NarudzbaBicikliService>();
builder.Services.AddTransient<INarudzbaDijeloviService, NarudzbaDijeloviService>();
builder.Services.AddTransient<IRezervacijaServisaService, RezervacijaServisaService>();
builder.Services.AddTransient<IServiserService, ServiserService>();
builder.Services.AddTransient<ISlikeBicikliService, SlikeBicikliService>();
builder.Services.AddTransient<ISlikeDijeloviService, SlikeDijeloviService>();
builder.Services.AddTransient<ISpaseniBicikliService, SpaseniBicikliService>();
builder.Services.AddTransient<ISpaseniDijeloviService, SpaseniDijeloviService>();
builder.Services.AddTransient<IKategorijaService, KategorijaService>();
builder.Services.AddTransient<IRecommendedKategorijaService, RecommendedKategorijaService>();



StateRegistrationHelper.RegisterStates<BikeHub.Model.AdresaFM.Adresa, BikeHub.Services.Database.Adresa, AdresaInsertR, AdresaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.BicikliFM.Bicikli, BikeHub.Services.Database.Bicikl, BicikliInsertR, BicikliUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.DijeloviFM.Dijelovi, BikeHub.Services.Database.Dijelovi, DijeloviInsertR, DijeloviUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KategorijaFM.Kategorija, BikeHub.Services.Database.Kategorija, KategorijaInsertR, KategorijaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KorisnikFM.Korisnik, BikeHub.Services.Database.Korisnik, KorisniciInsertR, KorisniciUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KorisnikFM.KorisnikInfo, BikeHub.Services.Database.KorisnikInfo, KorisnikInfoInsertR, KorisnikInfoUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija, BikeHub.Services.Database.RecommendedKategorija, RecommendedKategorijaInsertR, RecommendedKategorijaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.ServisFM.Serviser, BikeHub.Services.Database.Serviser, ServiserInsertR, ServiserUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SlikeFM.SlikeBicikli, BikeHub.Services.Database.SlikeBicikli, SlikeBicikliInsertR, SlikeBicikliUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SpaseniFM.SpaseniBicikli, BikeHub.Services.Database.SpaseniBicikli, SpaseniBicikliInsertR, SpaseniBicikliUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SpaseniFM.SpaseniDijelovi, BikeHub.Services.Database.SpaseniDijelovi, SpaseniDijeloviInsertR, SpaseniDijeloviUpdateR>(builder.Services);

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Logging.ClearProviders();
builder.Logging.AddConsole();

var connectionString = builder.Configuration.GetConnectionString("BikeHubConnectionString");
builder.Services.AddDbContext<BikeHubDbContext>(options =>
options.UseSqlServer(connectionString));

builder.Services.Configure<RequestLocalizationOptions>(options =>
{
    var supportedCultures = new[]
    {
        new CultureInfo("hr-HR"),
        new CultureInfo("en-US")
    };
    options.DefaultRequestCulture = new RequestCulture("hr-HR");
    options.SupportedCultures = supportedCultures;
    options.SupportedUICultures = supportedCultures;
});

builder.Services.AddMapster();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
