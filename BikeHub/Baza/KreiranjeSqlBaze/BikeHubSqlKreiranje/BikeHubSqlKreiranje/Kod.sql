GO
-- 1. Korisnik
CREATE TABLE Korisnik (
    KorisnikId INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);
GO

-- 2. KorisnikInfo
CREATE TABLE KorisnikInfo (
    KorisnikInfoId INT IDENTITY(1,1) PRIMARY KEY,
    KorisnikId INT NOT NULL,
    ImePrezime VARCHAR(100) NOT NULL,
    Telefon VARCHAR(20),
    BrojNarudbi INT DEFAULT 0,
    BrojServisa INT DEFAULT 0,
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(KorisnikId)
); 
GO

-- 3. Serviser
CREATE TABLE Serviser (
    ServiserId INT IDENTITY(1,1) PRIMARY KEY,
    KorisnikId INT NOT NULL,
    Cijena DECIMAL(10,2),
    BrojServisa INT DEFAULT 0,
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(KorisnikId)
);
GO

-- 4. RezervacijaServisa
CREATE TABLE RezervacijaServisa (
    RezervacijaId INT IDENTITY(1,1) PRIMARY KEY,
    KorisnikId INT NOT NULL,
    ServiserId INT NOT NULL,
    DatumKreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DatumRezervacije DATETIME NOT NULL,
    Odradena BIT DEFAULT 0,
    Ocjena DECIMAL(3,2),
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(KorisnikId),
    FOREIGN KEY (ServiserId) REFERENCES Serviser(ServiserId)
);
GO

-- 5. Adresa
CREATE TABLE Adresa (
    AdresaId INT IDENTITY(1,1) PRIMARY KEY,
    KorisnikId INT NOT NULL,
    Grad VARCHAR(100) NOT NULL,
    PostanskiBroj VARCHAR(10) NOT NULL,
    Ulica VARCHAR(100) NOT NULL,
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(KorisnikId)
);
GO

-- 6. Bicikl
CREATE TABLE Bicikl (
    BiciklId INT IDENTITY(1,1) PRIMARY KEY,
    Naziv VARCHAR(100) NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    VelicinaRama VARCHAR(50),
    VelicinaTocka VARCHAR(50),
    BrojBrzina INT
);
GO

-- 7. Dijelovi
CREATE TABLE Dijelovi (
    DijeloviId INT IDENTITY(1,1) PRIMARY KEY,
    Naziv VARCHAR(100) NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    Opis TEXT
);
GO

-- 8. SpaseniBicikli
CREATE TABLE SpaseniBicikli (
    SpaseniBicikliId INT IDENTITY(1,1) PRIMARY KEY,
    BiciklId INT NOT NULL,
    DatumSpasavanja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BiciklId) REFERENCES Bicikl(BiciklId)
);
GO

-- 9. SpaseniDijelovi
CREATE TABLE SpaseniDijelovi (
    SpaseniDijeloviId INT IDENTITY(1,1) PRIMARY KEY,
    DijeloviId INT NOT NULL,
    DatumSpasavanja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DijeloviId) REFERENCES Dijelovi(DijeloviId)
);
GO

-- 10. SlikeBicikli
CREATE TABLE SlikeBicikli (
    SlikeBicikliId INT IDENTITY(1,1) PRIMARY KEY,
    BiciklId INT NOT NULL,
    Slika VARBINARY(MAX),
    FOREIGN KEY (BiciklId) REFERENCES Bicikl(BiciklId)
);
GO

-- 11. SlikeDijelovi
CREATE TABLE SlikeDijelovi (
    SlikeDijeloviId INT IDENTITY(1,1) PRIMARY KEY,
    DijeloviId INT NOT NULL,
    Slika VARBINARY(MAX),
    FOREIGN KEY (DijeloviId) REFERENCES Dijelovi(DijeloviId)
);
GO

-- 12. PromocijaBicikli
CREATE TABLE PromocijaBicikli (
    PromocijaBicikliId INT IDENTITY(1,1) PRIMARY KEY,
    BiciklId INT NOT NULL,
    DatumPocetka DATE NOT NULL,
    DatumZavrsetka DATE NOT NULL,
    CijenaPromocije DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (BiciklId) REFERENCES Bicikl(BiciklId)
);
GO

-- 13. PromocijaDijelovi
CREATE TABLE PromocijaDijelovi (
    PromocijaDijeloviId INT IDENTITY(1,1) PRIMARY KEY,
    DijeloviId INT NOT NULL,
    DatumPocetka DATE NOT NULL,
    DatumZavrsetka DATE NOT NULL,
    CijenaPromocije DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (DijeloviId) REFERENCES Dijelovi(DijeloviId)
);
GO

-- 14. Narudzba
CREATE TABLE Narudzba (
    NarudzbaId INT IDENTITY(1,1) PRIMARY KEY,
    KorisnikId INT NOT NULL,
    DatumNarudzbe DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(50) NOT NULL,
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(KorisnikId)
);
GO

-- 15. NarudzbaBicikli
CREATE TABLE NarudzbaBicikli (
    NarudzbaBicikliId INT IDENTITY(1,1) PRIMARY KEY,
    NarudzbaId INT NOT NULL,
    BiciklId INT NOT NULL,
    Kolicina INT NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (NarudzbaId) REFERENCES Narudzba(NarudzbaId),
    FOREIGN KEY (BiciklId) REFERENCES Bicikl(BiciklId)
);
GO

-- 16. NarudzbaDijelovi
CREATE TABLE NarudzbaDijelovi (
    NarudzbaDijeloviId INT IDENTITY(1,1) PRIMARY KEY,
    NarudzbaId INT NOT NULL,
    DijeloviId INT NOT NULL,
    Kolicina INT NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (NarudzbaId) REFERENCES Narudzba(NarudzbaId),
    FOREIGN KEY (DijeloviId) REFERENCES Dijelovi(DijeloviId)
);
GO
