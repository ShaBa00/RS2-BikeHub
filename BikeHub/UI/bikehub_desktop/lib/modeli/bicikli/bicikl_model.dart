class Bicikl {
  int biciklId;
  String naziv;
  double cijena;
  String velicinaRama;
  String velicinaTocka;
  int brojBrzina;
  int kategorijaId;
  int kolicina;
  int korisnikId;
  int ak;
  String stanje;

  Bicikl({
    required this.naziv,
    required this.cijena,
    required this.velicinaRama,
    required this.velicinaTocka,
    required this.brojBrzina,
    required this.kategorijaId,
    required this.kolicina,
    required this.korisnikId,
    required this.biciklId,
    required this.stanje,
    required this.ak,
  });

  factory Bicikl.fromJson(Map<String, dynamic> json) {
    return Bicikl(
      naziv: json['naziv'] as String,
      cijena: json['cijena'] as double,
      velicinaRama: json['velicinaRama'] as String,
      velicinaTocka: json['velicinaTocka'] as String,
      brojBrzina: json['brojBrzina'] as int,
      kategorijaId: json['kategorijaId'] as int,
      kolicina: json['kolicina'] as int,
      korisnikId: json['korisnikId'] as int,
      biciklId: json['biciklId'] as int,
      stanje: json['aktivacija'] ?? false,
      ak: json['ak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'naziv': naziv,
      'cijena': cijena,
      'velicinaRama': velicinaRama,
      'velicinaTocka': velicinaTocka,
      'brojBrzina': brojBrzina,
      'kategorijaId': kategorijaId,
      'kolicina': kolicina,
      'korisnikId': korisnikId,
      'biciklId': biciklId,
      'stanje': stanje,
      'ak': ak,
    };
  }
}
