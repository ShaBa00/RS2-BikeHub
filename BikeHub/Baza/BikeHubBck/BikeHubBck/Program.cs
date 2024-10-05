using BikeHub.Services;
using BikeHub.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Localization;
using Microsoft.EntityFrameworkCore;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IKorisnikService, KorisnikService>();
builder.Services.AddTransient<IDijeloviService, DijeloviService>();
builder.Services.AddTransient<IBicikliService, BicikliService>();
builder.Services.AddTransient<IAdresaService, AdresaService>();
builder.Services.AddTransient<IKorisnikInfoService, KorisnikInfoService>();
builder.Services.AddTransient<INarudzbaService, NarudzbaService>();

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
