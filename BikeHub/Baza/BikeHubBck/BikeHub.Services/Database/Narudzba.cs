using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Narudzba
{
    public int NarudzbaId { get; set; }

    public int KorisnikId { get; set; }
    public int ProdavaocId { get; set; }

    public DateTime DatumNarudzbe { get; set; }

    public string Status { get; set; } = null!;

    public decimal? UkupnaCijena { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual ICollection<NarudzbaBicikli> NarudzbaBiciklis { get; set; } = new List<NarudzbaBicikli>();

    public virtual ICollection<NarudzbaDijelovi> NarudzbaDijelovis { get; set; } = new List<NarudzbaDijelovi>();
}
