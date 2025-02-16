class Dijelovi {
  int dijeloviId;
  String naziv;
  double cijena;
  String opis;
  int kategorijaId;
  int kolicina;
  int korisnikId;
  int ak;
  String stanje;

  Dijelovi({
    required this.naziv,
    required this.cijena,
    required this.opis,
    required this.kategorijaId,
    required this.kolicina,
    required this.korisnikId,
    required this.dijeloviId,
    required this.stanje,
    required this.ak,
  });

  factory Dijelovi.fromJson(Map<String, dynamic> json) {
    return Dijelovi(
      naziv: json['naziv'] as String,
      cijena: json['cijena'] as double,
      opis: json['opis'] as String,
      kategorijaId: json['kategorijaId'] as int,
      kolicina: json['kolicina'] as int,
      korisnikId: json['korisnikId'] as int,
      dijeloviId: json['dijeloviId'] as int,
      stanje: json['aktivacija'] ?? false,
      ak: json['ak'] ?? 0,
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
      'dijeloviId': dijeloviId,
      'stanje': stanje,
      'ak': ak,
    };
  }
}
