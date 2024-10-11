using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Bicikl
{
    public int BiciklId { get; set; }

    public string Naziv { get; set; } = null!;

    public decimal Cijena { get; set; }

    public string? VelicinaRama { get; set; }

    public string? VelicinaTocka { get; set; }

    public int? BrojBrzina { get; set; }

    public string? Status { get; set; }

    public int? KategorijaId { get; set; }

    public int Kolicina { get; set; }

    public virtual Kategorija? Kategorija { get; set; }

    public virtual ICollection<NarudzbaBicikli> NarudzbaBiciklis { get; set; } = new List<NarudzbaBicikli>();

    public virtual ICollection<PromocijaBicikli> PromocijaBiciklis { get; set; } = new List<PromocijaBicikli>();

    public virtual ICollection<RecommendedKategorija> RecommendedKategorijas { get; set; } = new List<RecommendedKategorija>();

    public virtual ICollection<SlikeBicikli> SlikeBiciklis { get; set; } = new List<SlikeBicikli>();

    public virtual ICollection<SpaseniBicikli> SpaseniBiciklis { get; set; } = new List<SpaseniBicikli>();
}
