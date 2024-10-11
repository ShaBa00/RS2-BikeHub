using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Dijelovi
{
    public int DijeloviId { get; set; }

    public string Naziv { get; set; } = null!;

    public decimal Cijena { get; set; }

    public string? Opis { get; set; }

    public string? Status { get; set; }

    public int? KategorijaId { get; set; }

    public int Kolicina { get; set; }

    public virtual Kategorija? Kategorija { get; set; }

    public virtual ICollection<NarudzbaDijelovi> NarudzbaDijelovis { get; set; } = new List<NarudzbaDijelovi>();

    public virtual ICollection<PromocijaDijelovi> PromocijaDijelovis { get; set; } = new List<PromocijaDijelovi>();

    public virtual ICollection<RecommendedKategorija> RecommendedKategorijas { get; set; } = new List<RecommendedKategorija>();

    public virtual ICollection<SlikeDijelovi> SlikeDijelovis { get; set; } = new List<SlikeDijelovi>();

    public virtual ICollection<SpaseniDijelovi> SpaseniDijelovis { get; set; } = new List<SpaseniDijelovi>();
}
