class Dijelovi {
  String naziv;
  double cijena;
  String opis;
  int kategorijaId;
  int kolicina;
  int korisnikId;

  Dijelovi({
    required this.naziv,
    required this.cijena,
    required this.opis,
    required this.kategorijaId,
    required this.kolicina,
    required this.korisnikId,
  });

  factory Dijelovi.fromJson(Map<String, dynamic> json) {
    return Dijelovi(
      naziv: json['naziv'] as String,
      cijena: json['cijena'] as double,
      opis: json['opis'] as String,
      kategorijaId: json['kategorijaId'] as int,
      kolicina: json['kolicina'] as int,
      korisnikId: json['korisnikId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'naziv': naziv,
      'cijena': cijena,
      'opis': opis,
      'kategorijaId': kategorijaId,
      'kolicina': kolicina,
      'korisnikId': korisnikId,
    };
  }
}
