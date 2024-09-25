using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Korisnik
{
    public int KorisnikId { get; set; }

    public string Username { get; set; } = null!;

    public string Password { get; set; } = null!;

    public string Email { get; set; } = null!;

    public virtual ICollection<Adresa> Adresas { get; set; } = new List<Adresa>();

    public virtual ICollection<KorisnikInfo> KorisnikInfos { get; set; } = new List<KorisnikInfo>();

    public virtual ICollection<Narudzba> Narudzbas { get; set; } = new List<Narudzba>();

    public virtual ICollection<RezervacijaServisa> RezervacijaServisas { get; set; } = new List<RezervacijaServisa>();

    public virtual ICollection<Serviser> Servisers { get; set; } = new List<Serviser>();
}
