using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class SlikeBicikli
{
    public int SlikeBicikliId { get; set; }

    public int BiciklId { get; set; }

    public byte[]? Slika { get; set; }

    public string? Status { get; set; }

    public virtual Bicikl Bicikl { get; set; } = null!;
}
