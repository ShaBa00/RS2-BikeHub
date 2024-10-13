using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class SlikeDijelovi
{
    public int SlikeDijeloviId { get; set; }

    public int DijeloviId { get; set; }

    public byte[]? Slika { get; set; }

    public string? Status { get; set; }

    public virtual Dijelovi Dijelovi { get; set; } = null!;
}
