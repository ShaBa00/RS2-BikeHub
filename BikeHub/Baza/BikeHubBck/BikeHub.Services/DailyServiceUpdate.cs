using BikeHub.Services.Database;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace BikeHub.Services
{
    public class DailyServiceUpdate : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;

        public DailyServiceUpdate(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                using (var scope = _serviceProvider.CreateScope())
                {
                    var context = scope.ServiceProvider.GetRequiredService<BikeHubDbContext>();


                    while (!context.Database.CanConnect())
                    {
                        await Task.Delay(TimeSpan.FromSeconds(55), stoppingToken);
                    }

                    if (!context.PromocijaBiciklis.Any() && !context.PromocijaDijelovis.Any() && !context.RezervacijaServisas.Any())
                    {
                        await Task.Delay(TimeSpan.FromDays(1), stoppingToken);
                        continue;
                    }

                    if (context == null || !context.PromocijaBiciklis.Any() || !context.PromocijaDijelovis.Any() || !context.RezervacijaServisas.Any())
                    {
                        await Task.Delay(TimeSpan.FromDays(1), stoppingToken);
                        continue;
                    }

                    var expiredPromotions = context.PromocijaBiciklis
                                                    .Where(p => p.DatumZavrsetka < DateTime.Now && p.Status != "zavrseno")
                                                    .ToList();
                    
                    foreach (var promocija in expiredPromotions)
                    {
                        promocija.Status = "zavrseno";
                    }

                    var expiredPromotionsDijelovis = context.PromocijaDijelovis
                                                            .Where(p => p.DatumZavrsetka < DateTime.Now && p.Status != "zavrseno")
                                                            .ToList();
                    foreach (var promocija in expiredPromotionsDijelovis)
                    {
                        promocija.Status = "zavrseno";
                    }

                    var zavrseneRezervacije = context.RezervacijaServisas
                        .Where(r => r.Status == "zavrseno" && r.Ocjena.HasValue)
                        .GroupBy(r => r.ServiserId)
                        .Select(g => new
                        {
                            ServiserId = g.Key,
                            ProsjecnaOcjena = g.Average(r => r.Ocjena.Value),
                            BrojZavršenihServisa = g.Count()
                        })
                        .ToList();

                    foreach (var group in zavrseneRezervacije)
                    {
                        var serviser = await context.Servisers.FindAsync(group.ServiserId);
                        if (serviser != null)
                        {
                            serviser.UkupnaOcjena = group.ProsjecnaOcjena;
                            serviser.BrojServisa = group.BrojZavršenihServisa;
                        }
                    }

                    var korisnici = context.KorisnikInfos.ToList();
                    foreach (var korisnik in korisnici)
                    {
                        var brojNarudbi = context.Narudzbas
                            .Where(n => n.KorisnikId == korisnik.KorisnikId && n.Status == "zavrseno")
                            .Count();

                        var brojServisa = context.RezervacijaServisas
                            .Where(r => r.KorisnikId == korisnik.KorisnikId &&
                                        (r.Status == "zavrseno" || r.DatumRezervacije < DateTime.Now))
                            .Count();

                        korisnik.BrojNarudbi = brojNarudbi;
                        korisnik.BrojServisa = brojServisa;
                    }
                    await context.SaveChangesAsync();
                }
                await Task.Delay(TimeSpan.FromDays(1), stoppingToken);
            }
        }
    }
}
