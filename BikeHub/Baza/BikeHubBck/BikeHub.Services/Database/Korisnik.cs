using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Korisnik
{
    public int KorisnikId { get; set; }

    public string Username { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? LozinkaSalt { get; set; }

    public string? LozinkaHash { get; set; }

    public string? Status { get; set; }

    public bool? IsAdmin { get; set; }

    public virtual ICollection<Adresa> Adresas { get; set; } = new List<Adresa>();

    public virtual ICollection<Bicikl> Bicikls { get; set; } = new List<Bicikl>();

    public virtual ICollection<Dijelovi> Dijelovis { get; set; } = new List<Dijelovi>();

    public virtual ICollection<KorisnikInfo> KorisnikInfos { get; set; } = new List<KorisnikInfo>();

    public virtual ICollection<Narudzba> Narudzbas { get; set; } = new List<Narudzba>();

    public virtual ICollection<RezervacijaServisa> RezervacijaServisas { get; set; } = new List<RezervacijaServisa>();

    public virtual ICollection<Serviser> Servisers { get; set; } = new List<Serviser>();

    public virtual ICollection<SpaseniBicikli> SpaseniBiciklis { get; set; } = new List<SpaseniBicikli>();

    public virtual ICollection<SpaseniDijelovi> SpaseniDijelovis { get; set; } = new List<SpaseniDijelovi>();
}
