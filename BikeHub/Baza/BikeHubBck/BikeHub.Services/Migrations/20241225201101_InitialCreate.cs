using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BikeHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Kategorija",
                columns: table => new
                {
                    KategorijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    IsBikeKategorija = table.Column<bool>(type: "bit", nullable: true, defaultValueSql: "((0))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Kategori__6C3B8FEEE2B9895F", x => x.KategorijaId);
                });

            migrationBuilder.CreateTable(
                name: "Korisnik",
                columns: table => new
                {
                    KorisnikId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Username = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    LozinkaSalt = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    LozinkaHash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')"),
                    IsAdmin = table.Column<bool>(type: "bit", nullable: true, defaultValueSql: "((0))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__80B06D4166618F56", x => x.KorisnikId);
                });

            migrationBuilder.CreateTable(
                name: "Adresa",
                columns: table => new
                {
                    AdresaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Grad = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    PostanskiBroj = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: false),
                    Ulica = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Adresa__03B983FCA509345D", x => x.AdresaId);
                    table.ForeignKey(
                        name: "FK__Adresa__Korisnik__5DCAEF64",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Bicikl",
                columns: table => new
                {
                    BiciklId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    VelicinaRama = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    VelicinaTocka = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    BrojBrzina = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    KategorijaId = table.Column<int>(type: "int", nullable: true),
                    Kolicina = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Bicikl__6C2F5A7C6852ACEF", x => x.BiciklId);
                    table.ForeignKey(
                        name: "FK_Bicikl_Kategorija",
                        column: x => x.KategorijaId,
                        principalTable: "Kategorija",
                        principalColumn: "KategorijaId");
                    table.ForeignKey(
                        name: "FK_Bicikl_Korisnik",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Dijelovi",
                columns: table => new
                {
                    DijeloviId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Opis = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')"),
                    KategorijaId = table.Column<int>(type: "int", nullable: true),
                    Kolicina = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Dijelovi__DD1433FDF0768488", x => x.DijeloviId);
                    table.ForeignKey(
                        name: "FK_Dijelovi_Kategorija",
                        column: x => x.KategorijaId,
                        principalTable: "Kategorija",
                        principalColumn: "KategorijaId");
                    table.ForeignKey(
                        name: "FK_Dijelovi_Korisnik",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "KorisnikInfo",
                columns: table => new
                {
                    KorisnikInfoId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    ImePrezime = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Telefon = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    BrojNarudbi = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    BrojServisa = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__635A1589DE413B07", x => x.KorisnikInfoId);
                    table.ForeignKey(
                        name: "FK__KorisnikI__Koris__5EBF139D",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Narudzba",
                columns: table => new
                {
                    NarudzbaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    ProdavaocId = table.Column<int>(type: "int", nullable: false),
                    DatumNarudzbe = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    UkupnaCijena = table.Column<decimal>(type: "decimal(10,2)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Narudzba__FBEC13776B24CC09", x => x.NarudzbaId);
                    table.ForeignKey(
                        name: "FK__Narudzba__Korisn__5FB337D6",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Serviser",
                columns: table => new
                {
                    ServiserId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    BrojServisa = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')"),
                    UkupnaOcjena = table.Column<decimal>(type: "decimal(3,1)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Serviser__62E9F597520FA9DA", x => x.ServiserId);
                    table.ForeignKey(
                        name: "FK__Serviser__Korisn__68487DD7",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "PromocijaBicikli",
                columns: table => new
                {
                    PromocijaBicikliId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BiciklId = table.Column<int>(type: "int", nullable: false),
                    DatumPocetka = table.Column<DateTime>(type: "date", nullable: false),
                    DatumZavrsetka = table.Column<DateTime>(type: "date", nullable: false),
                    CijenaPromocije = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Promocij__BDD5375EB6ECA804", x => x.PromocijaBicikliId);
                    table.ForeignKey(
                        name: "FK__Promocija__Bicik__6477ECF3",
                        column: x => x.BiciklId,
                        principalTable: "Bicikl",
                        principalColumn: "BiciklId");
                });

            migrationBuilder.CreateTable(
                name: "SlikeBicikli",
                columns: table => new
                {
                    SlikeBicikliId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BiciklId = table.Column<int>(type: "int", nullable: false),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SlikeBic__7176487F559E61D2", x => x.SlikeBicikliId);
                    table.ForeignKey(
                        name: "FK__SlikeBici__Bicik__693CA210",
                        column: x => x.BiciklId,
                        principalTable: "Bicikl",
                        principalColumn: "BiciklId");
                });

            migrationBuilder.CreateTable(
                name: "SpaseniBicikli",
                columns: table => new
                {
                    SpaseniBicikliId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BiciklId = table.Column<int>(type: "int", nullable: false),
                    DatumSpasavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')"),
                    KorisnikId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SpaseniB__054423BB72AAF9DF", x => x.SpaseniBicikliId);
                    table.ForeignKey(
                        name: "FK_SpaseniBicikli_Korisnik",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__SpaseniBi__Bicik__6B24EA82",
                        column: x => x.BiciklId,
                        principalTable: "Bicikl",
                        principalColumn: "BiciklId");
                });

            migrationBuilder.CreateTable(
                name: "PromocijaDijelovi",
                columns: table => new
                {
                    PromocijaDijeloviId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DijeloviId = table.Column<int>(type: "int", nullable: false),
                    DatumPocetka = table.Column<DateTime>(type: "date", nullable: false),
                    DatumZavrsetka = table.Column<DateTime>(type: "date", nullable: false),
                    CijenaPromocije = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Promocij__3D3D4B47860B5207", x => x.PromocijaDijeloviId);
                    table.ForeignKey(
                        name: "FK__Promocija__Dijel__656C112C",
                        column: x => x.DijeloviId,
                        principalTable: "Dijelovi",
                        principalColumn: "DijeloviId");
                });

            migrationBuilder.CreateTable(
                name: "RecommendedKategorija",
                columns: table => new
                {
                    RecommendedKategorijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DijeloviId = table.Column<int>(type: "int", nullable: false),
                    BicikliId = table.Column<int>(type: "int", nullable: false),
                    BrojPreporuka = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    DatumKreiranja = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recommen__EC73A5F08D44C318", x => x.RecommendedKategorijaId);
                    table.ForeignKey(
                        name: "FK__Recommend__Bicik__7E37BEF6",
                        column: x => x.BicikliId,
                        principalTable: "Bicikl",
                        principalColumn: "BiciklId");
                    table.ForeignKey(
                        name: "FK__Recommend__Dijel__7D439ABD",
                        column: x => x.DijeloviId,
                        principalTable: "Dijelovi",
                        principalColumn: "DijeloviId");
                });

            migrationBuilder.CreateTable(
                name: "SlikeDijelovi",
                columns: table => new
                {
                    SlikeDijeloviId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DijeloviId = table.Column<int>(type: "int", nullable: false),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SlikeDij__70EC898A0F0F6418", x => x.SlikeDijeloviId);
                    table.ForeignKey(
                        name: "FK__SlikeDije__Dijel__6A30C649",
                        column: x => x.DijeloviId,
                        principalTable: "Dijelovi",
                        principalColumn: "DijeloviId");
                });

            migrationBuilder.CreateTable(
                name: "SpaseniDijelovi",
                columns: table => new
                {
                    SpaseniDijeloviId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DijeloviId = table.Column<int>(type: "int", nullable: false),
                    DatumSpasavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')"),
                    KorisnikId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SpaseniD__C3C4E858078D8670", x => x.SpaseniDijeloviId);
                    table.ForeignKey(
                        name: "FK_SpaseniDijelovi_Korisnik",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__SpaseniDi__Dijel__6C190EBB",
                        column: x => x.DijeloviId,
                        principalTable: "Dijelovi",
                        principalColumn: "DijeloviId");
                });

            migrationBuilder.CreateTable(
                name: "NarudzbaBicikli",
                columns: table => new
                {
                    NarudzbaBicikliId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NarudzbaId = table.Column<int>(type: "int", nullable: false),
                    BiciklId = table.Column<int>(type: "int", nullable: false),
                    Kolicina = table.Column<int>(type: "int", nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Narudzba__55EEB7C94E4BAE50", x => x.NarudzbaBicikliId);
                    table.ForeignKey(
                        name: "FK__NarudzbaB__Bicik__619B8048",
                        column: x => x.BiciklId,
                        principalTable: "Bicikl",
                        principalColumn: "BiciklId");
                    table.ForeignKey(
                        name: "FK__NarudzbaB__Narud__60A75C0F",
                        column: x => x.NarudzbaId,
                        principalTable: "Narudzba",
                        principalColumn: "NarudzbaId");
                });

            migrationBuilder.CreateTable(
                name: "NarudzbaDijelovi",
                columns: table => new
                {
                    NarudzbaDijeloviId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NarudzbaId = table.Column<int>(type: "int", nullable: false),
                    DijeloviId = table.Column<int>(type: "int", nullable: false),
                    Kolicina = table.Column<int>(type: "int", nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Kreiran')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Narudzba__F880F9DB54CE26CA", x => x.NarudzbaDijeloviId);
                    table.ForeignKey(
                        name: "FK__NarudzbaD__Dijel__6383C8BA",
                        column: x => x.DijeloviId,
                        principalTable: "Dijelovi",
                        principalColumn: "DijeloviId");
                    table.ForeignKey(
                        name: "FK__NarudzbaD__Narud__628FA481",
                        column: x => x.NarudzbaId,
                        principalTable: "Narudzba",
                        principalColumn: "NarudzbaId");
                });

            migrationBuilder.CreateTable(
                name: "RezervacijaServisa",
                columns: table => new
                {
                    RezervacijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    ServiserId = table.Column<int>(type: "int", nullable: false),
                    DatumKreiranja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    DatumRezervacije = table.Column<DateTime>(type: "datetime", nullable: false),
                    Ocjena = table.Column<decimal>(type: "decimal(3,2)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, defaultValueSql: "('Aktivan')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Rezervac__CABA44DD97C21C44", x => x.RezervacijaId);
                    table.ForeignKey(
                        name: "FK__Rezervaci__Koris__66603565",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Rezervaci__Servi__6754599E",
                        column: x => x.ServiserId,
                        principalTable: "Serviser",
                        principalColumn: "ServiserId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Adresa_KorisnikId",
                table: "Adresa",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Bicikl_KategorijaId",
                table: "Bicikl",
                column: "KategorijaId");

            migrationBuilder.CreateIndex(
                name: "IX_Bicikl_KorisnikId",
                table: "Bicikl",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Dijelovi_KategorijaId",
                table: "Dijelovi",
                column: "KategorijaId");

            migrationBuilder.CreateIndex(
                name: "IX_Dijelovi_KorisnikId",
                table: "Dijelovi",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "UQ__Korisnik__536C85E4B9F6B45A",
                table: "Korisnik",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Korisnik__A9D10534FE61FF99",
                table: "Korisnik",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikInfo_KorisnikId",
                table: "KorisnikInfo",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzba_KorisnikId",
                table: "Narudzba",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_NarudzbaBicikli_BiciklId",
                table: "NarudzbaBicikli",
                column: "BiciklId");

            migrationBuilder.CreateIndex(
                name: "IX_NarudzbaBicikli_NarudzbaId",
                table: "NarudzbaBicikli",
                column: "NarudzbaId");

            migrationBuilder.CreateIndex(
                name: "IX_NarudzbaDijelovi_DijeloviId",
                table: "NarudzbaDijelovi",
                column: "DijeloviId");

            migrationBuilder.CreateIndex(
                name: "IX_NarudzbaDijelovi_NarudzbaId",
                table: "NarudzbaDijelovi",
                column: "NarudzbaId");

            migrationBuilder.CreateIndex(
                name: "IX_PromocijaBicikli_BiciklId",
                table: "PromocijaBicikli",
                column: "BiciklId");

            migrationBuilder.CreateIndex(
                name: "IX_PromocijaDijelovi_DijeloviId",
                table: "PromocijaDijelovi",
                column: "DijeloviId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendedKategorija_BicikliId",
                table: "RecommendedKategorija",
                column: "BicikliId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendedKategorija_DijeloviId",
                table: "RecommendedKategorija",
                column: "DijeloviId");

            migrationBuilder.CreateIndex(
                name: "IX_RezervacijaServisa_KorisnikId",
                table: "RezervacijaServisa",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_RezervacijaServisa_ServiserId",
                table: "RezervacijaServisa",
                column: "ServiserId");

            migrationBuilder.CreateIndex(
                name: "IX_Serviser_KorisnikId",
                table: "Serviser",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_SlikeBicikli_BiciklId",
                table: "SlikeBicikli",
                column: "BiciklId");

            migrationBuilder.CreateIndex(
                name: "IX_SlikeDijelovi_DijeloviId",
                table: "SlikeDijelovi",
                column: "DijeloviId");

            migrationBuilder.CreateIndex(
                name: "IX_SpaseniBicikli_BiciklId",
                table: "SpaseniBicikli",
                column: "BiciklId");

            migrationBuilder.CreateIndex(
                name: "IX_SpaseniBicikli_KorisnikId",
                table: "SpaseniBicikli",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_SpaseniDijelovi_DijeloviId",
                table: "SpaseniDijelovi",
                column: "DijeloviId");

            migrationBuilder.CreateIndex(
                name: "IX_SpaseniDijelovi_KorisnikId",
                table: "SpaseniDijelovi",
                column: "KorisnikId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Adresa");

            migrationBuilder.DropTable(
                name: "KorisnikInfo");

            migrationBuilder.DropTable(
                name: "NarudzbaBicikli");

            migrationBuilder.DropTable(
                name: "NarudzbaDijelovi");

            migrationBuilder.DropTable(
                name: "PromocijaBicikli");

            migrationBuilder.DropTable(
                name: "PromocijaDijelovi");

            migrationBuilder.DropTable(
                name: "RecommendedKategorija");

            migrationBuilder.DropTable(
                name: "RezervacijaServisa");

            migrationBuilder.DropTable(
                name: "SlikeBicikli");

            migrationBuilder.DropTable(
                name: "SlikeDijelovi");

            migrationBuilder.DropTable(
                name: "SpaseniBicikli");

            migrationBuilder.DropTable(
                name: "SpaseniDijelovi");

            migrationBuilder.DropTable(
                name: "Narudzba");

            migrationBuilder.DropTable(
                name: "Serviser");

            migrationBuilder.DropTable(
                name: "Bicikl");

            migrationBuilder.DropTable(
                name: "Dijelovi");

            migrationBuilder.DropTable(
                name: "Kategorija");

            migrationBuilder.DropTable(
                name: "Korisnik");
        }
    }
}
