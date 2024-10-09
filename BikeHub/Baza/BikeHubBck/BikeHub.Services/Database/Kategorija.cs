using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Kategorija
{
    public int KategorijaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string Status { get; set; } = null!;

    public virtual ICollection<Bicikl> Bicikls { get; set; } = new List<Bicikl>();

    public virtual ICollection<Dijelovi> Dijelovis { get; set; } = new List<Dijelovi>();
}
