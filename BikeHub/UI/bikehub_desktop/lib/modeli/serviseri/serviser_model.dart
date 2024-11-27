

class ServiserModel {
  int korisnikId;
  int serviserId;
  int brojServisa;
  double cijena;
  double ukupnaOcjena;
  String stanje;
  String username="";
  String grad="";
  int ak;

  ServiserModel({
    required this.korisnikId,
    required this.serviserId,
    required this.brojServisa,
    required this.cijena,
    required this.ukupnaOcjena,
    required this.stanje,
    required this.username,
    required this.grad,
    required this.ak,
  });
  factory ServiserModel.fromJson(Map<String, dynamic> json) {
    return ServiserModel(
      korisnikId: json['korisnikId'] ?? 0,
      serviserId: json['serviserId'] ?? 0,
      brojServisa: json['brojServisa'] ?? 0,
      cijena: json['cijena'] ?? 0,
      ukupnaOcjena: json['ukupnaOcjena'] ?? 0,
      username: json['username'] ?? '',
      grad: json['grad'] ?? '',
      stanje: json['aktivacija'] ?? false,
      ak: json['ak'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'korisnikId': korisnikId,
      'serviserId': serviserId,
      'brojServisa': brojServisa,
      'cijena': cijena,
      'ukupnaOcjena': ukupnaOcjena,
      'username': username,
      'grad': grad,
      'stanje': stanje,
      'ak': ak,
    };
  }
}
