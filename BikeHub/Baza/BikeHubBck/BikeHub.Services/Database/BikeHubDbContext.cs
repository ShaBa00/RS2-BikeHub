using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BikeHub.Services.Database;

public partial class BikeHubDbContext : DbContext
{
    public BikeHubDbContext()
    {
    }

    public BikeHubDbContext(DbContextOptions<BikeHubDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Adresa> Adresas { get; set; }

    public virtual DbSet<Bicikl> Bicikls { get; set; }

    public virtual DbSet<Dijelovi> Dijelovis { get; set; }

    public virtual DbSet<Korisnik> Korisniks { get; set; }

    public virtual DbSet<KorisnikInfo> KorisnikInfos { get; set; }

    public virtual DbSet<Narudzba> Narudzbas { get; set; }

    public virtual DbSet<NarudzbaBicikli> NarudzbaBiciklis { get; set; }

    public virtual DbSet<NarudzbaDijelovi> NarudzbaDijelovis { get; set; }

    public virtual DbSet<PromocijaBicikli> PromocijaBiciklis { get; set; }

    public virtual DbSet<PromocijaDijelovi> PromocijaDijelovis { get; set; }

    public virtual DbSet<RezervacijaServisa> RezervacijaServisas { get; set; }

    public virtual DbSet<Serviser> Servisers { get; set; }

    public virtual DbSet<SlikeBicikli> SlikeBiciklis { get; set; }

    public virtual DbSet<SlikeDijelovi> SlikeDijelovis { get; set; }

    public virtual DbSet<SpaseniBicikli> SpaseniBiciklis { get; set; }

    public virtual DbSet<SpaseniDijelovi> SpaseniDijelovis { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=BikeHubDb;Integrated Security=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Adresa>(entity =>
        {
            entity.HasKey(e => e.AdresaId).HasName("PK__Adresa__03B983FCA509345D");

            entity.ToTable("Adresa");

            entity.Property(e => e.Grad)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.PostanskiBroj)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.Ulica)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Adresas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Adresa__Korisnik__5DCAEF64");
        });

        modelBuilder.Entity<Bicikl>(entity =>
        {
            entity.HasKey(e => e.BiciklId).HasName("PK__Bicikl__6C2F5A7C6852ACEF");

            entity.ToTable("Bicikl");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Naziv)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.VelicinaRama)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.VelicinaTocka)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Dijelovi>(entity =>
        {
            entity.HasKey(e => e.DijeloviId).HasName("PK__Dijelovi__DD1433FDF0768488");

            entity.ToTable("Dijelovi");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Naziv)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Opis).HasColumnType("text");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.KorisnikId).HasName("PK__Korisnik__80B06D4166618F56");

            entity.ToTable("Korisnik");

            entity.HasIndex(e => e.Username, "UQ__Korisnik__536C85E4B9F6B45A").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Korisnik__A9D10534FE61FF99").IsUnique();

            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.IsAdmin).HasDefaultValueSql("((0))");
            entity.Property(e => e.LozinkaHash).HasMaxLength(255);
            entity.Property(e => e.LozinkaSalt).HasMaxLength(255);
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");
            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<KorisnikInfo>(entity =>
        {
            entity.HasKey(e => e.KorisnikInfoId).HasName("PK__Korisnik__635A1589DE413B07");

            entity.ToTable("KorisnikInfo");

            entity.Property(e => e.BrojNarudbi).HasDefaultValueSql("((0))");
            entity.Property(e => e.BrojServisa).HasDefaultValueSql("((0))");
            entity.Property(e => e.ImePrezime)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Telefon)
                .HasMaxLength(20)
                .IsUnicode(false);

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KorisnikInfos)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__KorisnikI__Koris__5EBF139D");
        });

        modelBuilder.Entity<Narudzba>(entity =>
        {
            entity.HasKey(e => e.NarudzbaId).HasName("PK__Narudzba__FBEC13776B24CC09");

            entity.ToTable("Narudzba");

            entity.Property(e => e.DatumNarudzbe)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false);

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Narudzbas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Narudzba__Korisn__5FB337D6");
        });

        modelBuilder.Entity<NarudzbaBicikli>(entity =>
        {
            entity.HasKey(e => e.NarudzbaBicikliId).HasName("PK__Narudzba__55EEB7C94E4BAE50");

            entity.ToTable("NarudzbaBicikli");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Bicikl).WithMany(p => p.NarudzbaBiciklis)
                .HasForeignKey(d => d.BiciklId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaB__Bicik__619B8048");

            entity.HasOne(d => d.Narudzba).WithMany(p => p.NarudzbaBiciklis)
                .HasForeignKey(d => d.NarudzbaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaB__Narud__60A75C0F");
        });

        modelBuilder.Entity<NarudzbaDijelovi>(entity =>
        {
            entity.HasKey(e => e.NarudzbaDijeloviId).HasName("PK__Narudzba__F880F9DB54CE26CA");

            entity.ToTable("NarudzbaDijelovi");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Dijelovi).WithMany(p => p.NarudzbaDijelovis)
                .HasForeignKey(d => d.DijeloviId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaD__Dijel__6383C8BA");

            entity.HasOne(d => d.Narudzba).WithMany(p => p.NarudzbaDijelovis)
                .HasForeignKey(d => d.NarudzbaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaD__Narud__628FA481");
        });

        modelBuilder.Entity<PromocijaBicikli>(entity =>
        {
            entity.HasKey(e => e.PromocijaBicikliId).HasName("PK__Promocij__BDD5375EB6ECA804");

            entity.ToTable("PromocijaBicikli");

            entity.Property(e => e.CijenaPromocije).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DatumPocetka).HasColumnType("date");
            entity.Property(e => e.DatumZavrsetka).HasColumnType("date");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");

            entity.HasOne(d => d.Bicikl).WithMany(p => p.PromocijaBiciklis)
                .HasForeignKey(d => d.BiciklId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Promocija__Bicik__6477ECF3");
        });

        modelBuilder.Entity<PromocijaDijelovi>(entity =>
        {
            entity.HasKey(e => e.PromocijaDijeloviId).HasName("PK__Promocij__3D3D4B47860B5207");

            entity.ToTable("PromocijaDijelovi");

            entity.Property(e => e.CijenaPromocije).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DatumPocetka).HasColumnType("date");
            entity.Property(e => e.DatumZavrsetka).HasColumnType("date");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");

            entity.HasOne(d => d.Dijelovi).WithMany(p => p.PromocijaDijelovis)
                .HasForeignKey(d => d.DijeloviId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Promocija__Dijel__656C112C");
        });

        modelBuilder.Entity<RezervacijaServisa>(entity =>
        {
            entity.HasKey(e => e.RezervacijaId).HasName("PK__Rezervac__CABA44DD97C21C44");

            entity.ToTable("RezervacijaServisa");

            entity.Property(e => e.DatumKreiranja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DatumRezervacije).HasColumnType("datetime");
            entity.Property(e => e.Ocjena).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.RezervacijaServisas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Rezervaci__Koris__66603565");

            entity.HasOne(d => d.Serviser).WithMany(p => p.RezervacijaServisas)
                .HasForeignKey(d => d.ServiserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Rezervaci__Servi__6754599E");
        });

        modelBuilder.Entity<Serviser>(entity =>
        {
            entity.HasKey(e => e.ServiserId).HasName("PK__Serviser__62E9F597520FA9DA");

            entity.ToTable("Serviser");

            entity.Property(e => e.BrojServisa).HasDefaultValueSql("((0))");
            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("('Aktivan')");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Servisers)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Serviser__Korisn__68487DD7");
        });

        modelBuilder.Entity<SlikeBicikli>(entity =>
        {
            entity.HasKey(e => e.SlikeBicikliId).HasName("PK__SlikeBic__7176487F559E61D2");

            entity.ToTable("SlikeBicikli");

            entity.HasOne(d => d.Bicikl).WithMany(p => p.SlikeBiciklis)
                .HasForeignKey(d => d.BiciklId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SlikeBici__Bicik__693CA210");
        });

        modelBuilder.Entity<SlikeDijelovi>(entity =>
        {
            entity.HasKey(e => e.SlikeDijeloviId).HasName("PK__SlikeDij__70EC898A0F0F6418");

            entity.ToTable("SlikeDijelovi");

            entity.HasOne(d => d.Dijelovi).WithMany(p => p.SlikeDijelovis)
                .HasForeignKey(d => d.DijeloviId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SlikeDije__Dijel__6A30C649");
        });

        modelBuilder.Entity<SpaseniBicikli>(entity =>
        {
            entity.HasKey(e => e.SpaseniBicikliId).HasName("PK__SpaseniB__054423BB72AAF9DF");

            entity.ToTable("SpaseniBicikli");

            entity.Property(e => e.DatumSpasavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Bicikl).WithMany(p => p.SpaseniBiciklis)
                .HasForeignKey(d => d.BiciklId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SpaseniBi__Bicik__6B24EA82");
        });

        modelBuilder.Entity<SpaseniDijelovi>(entity =>
        {
            entity.HasKey(e => e.SpaseniDijeloviId).HasName("PK__SpaseniD__C3C4E858078D8670");

            entity.ToTable("SpaseniDijelovi");

            entity.Property(e => e.DatumSpasavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Dijelovi).WithMany(p => p.SpaseniDijelovis)
                .HasForeignKey(d => d.DijeloviId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SpaseniDi__Dijel__6C190EBB");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
