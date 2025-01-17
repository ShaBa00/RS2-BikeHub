﻿using BikeHub.Services;
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
using BikeHub.Model.NarudzbaFM;
using BikeHub.Model.PromocijaFM;
using BikeHubBck.Filters;
using BikeHubBck;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;

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
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<FunctionHelper>();
builder.Services.AddScoped<DataSeeder>();


builder.Services.AddHostedService<DailyServiceUpdate>();


StateRegistrationHelper.RegisterStates<BikeHub.Model.AdresaFM.Adresa, BikeHub.Services.Database.Adresa, AdresaInsertR, AdresaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.BicikliFM.Bicikli, BikeHub.Services.Database.Bicikl, BicikliInsertR, BicikliUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.DijeloviFM.Dijelovi, BikeHub.Services.Database.Dijelovi, DijeloviInsertR, DijeloviUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KategorijaFM.Kategorija, BikeHub.Services.Database.Kategorija, KategorijaInsertR, KategorijaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KorisnikFM.Korisnik, BikeHub.Services.Database.Korisnik, KorisniciInsertRHS, BikeHub.Services.Database.Korisnik>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.KorisnikFM.KorisnikInfo, BikeHub.Services.Database.KorisnikInfo, KorisnikInfoInsertR, KorisnikInfoUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija, BikeHub.Services.Database.RecommendedKategorija, RecommendedKategorijaInsertR, RecommendedKategorijaUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.ServisFM.Serviser, BikeHub.Services.Database.Serviser, ServiserInsertR, ServiserUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SpaseniFM.SpaseniBicikli, BikeHub.Services.Database.SpaseniBicikli, SpaseniBicikliInsertR, SpaseniBicikliUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SpaseniFM.SpaseniDijelovi, BikeHub.Services.Database.SpaseniDijelovi, SpaseniDijeloviInsertR, SpaseniDijeloviUpdateR>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SlikeFM.SlikeBicikli, BikeHub.Services.Database.SlikeBicikli, BikeHub.Model.SlikeFM.SlikeBicikli, BikeHub.Model.SlikeFM.SlikeBicikli>(builder.Services);
StateRegistrationHelper.RegisterStates<BikeHub.Model.SlikeFM.SlikeDijelovi, BikeHub.Services.Database.SlikeDijelovi, BikeHub.Model.SlikeFM.SlikeDijelovi, BikeHub.Model.SlikeFM.SlikeDijelovi>(builder.Services);

StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.ServisFM.RezervacijaServisa, BikeHub.Services.Database.RezervacijaServisa, RezervacijaServisaInsertR, RezervacijaServisaUpdateR>(builder.Services);
StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.NarudzbaFM.Narudzba, BikeHub.Services.Database.Narudzba, BikeHub.Services.Database.Narudzba, NarudzbaUpdateR>(builder.Services);
StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.NarudzbaFM.NarudzbaDijelovi, BikeHub.Services.Database.NarudzbaDijelovi, BikeHub.Services.Database.NarudzbaDijelovi, NarudzbaDijeloviUpdateR>(builder.Services);
StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.NarudzbaFM.NarudzbaBicikli, BikeHub.Services.Database.NarudzbaBicikli, BikeHub.Services.Database.NarudzbaBicikli, NarudzbaBicikliUpdateR>(builder.Services);
StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.PromocijaFM.PromocijaBicikli, BikeHub.Services.Database.PromocijaBicikli, BikeHub.Services.Database.PromocijaBicikli, PromocijaBicikliUpdateR>(builder.Services);
StateRegistrationHelper.DrugiRegisterStates<BikeHub.Model.PromocijaFM.PromocijaDijelovi, BikeHub.Services.Database.PromocijaDijelovi, BikeHub.Services.Database.PromocijaDijelovi, PromocijaDijeloviUpdateR>(builder.Services);

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});
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

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins",
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});
builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var rabbitMqFactory = new ConnectionFactory
{
    HostName = "rabbitmq",
    VirtualHost = "/",
    UserName = "guest",
    Password = "guest",
    Port = 5672
};

builder.Services.AddSingleton(rabbitMqFactory);

builder.Services.AddSingleton<IConnection>(provider =>
{
    var factory = provider.GetRequiredService<ConnectionFactory>();
    return factory.CreateConnection();
});

builder.Services.AddScoped<IModel>(provider =>
{
    var connection = provider.GetRequiredService<IConnection>();
    return connection.CreateModel();
});


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<BikeHubDbContext>();

    var databaseExists = dbContext.Database.CanConnect();

    if (!databaseExists)
    {
        //dbContext.Database.EnsureCreated();
        dbContext.Database.Migrate();
        DataSeeder.Seed(dbContext);
    }
    else
    {
        // Provjera postojanja bilo koje tabele u bazi podataka
        var anyTableExists = dbContext.Database.ExecuteSqlRaw("SELECT 1 FROM INFORMATION_SCHEMA.TABLES") == 1;

        // Ako bilo koja tabela postoji, preskoči migraciju
        if (anyTableExists)
        {
            Console.WriteLine("Database already contains tables. Migration not needed.");
        }
        else
        {
            var pendingMigrations = dbContext.Database.GetPendingMigrations();
            if (pendingMigrations.Any())
            {
                dbContext.Database.Migrate();
                Console.WriteLine("Database migrated successfully.");
            }
        }
    }
}




if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}



app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
