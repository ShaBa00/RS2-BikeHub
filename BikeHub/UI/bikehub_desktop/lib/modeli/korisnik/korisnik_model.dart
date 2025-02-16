class KorisnikModel {
  int korisnikId;
  String username="";
  String staraLozinka="";
  String lozinka="";
  String lozinkaPotvrda="";
  String email="";
  String stanje;
  int ak;
  bool isAdmin=false;

  KorisnikModel({
    required this.korisnikId,
    required this.username,
    required this.staraLozinka,
    required this.lozinka,
    required this.lozinkaPotvrda,
    required this.email,
    required this.stanje,
    required this.ak,
    required this.isAdmin,
  });
  factory KorisnikModel.fromJson(Map<String, dynamic> json) {
    return KorisnikModel(
      korisnikId: json['korisnikId'] ?? 0,
      username: json['username'] ?? '',
      staraLozinka: json['staraLozinka'] ?? '',
      lozinka: json['lozinka'] ?? '',
      lozinkaPotvrda: json['lozinkaPotvrda'] ?? '',
      email: json['email'] ?? '',
      stanje: json['aktivacija'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      ak: json['ak'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'korisnikId': korisnikId,
      'username': username,
      'staraLozinka': staraLozinka,
      'lozinka': lozinka,
      'lozinkaPotvrda': lozinkaPotvrda,
      'email': email,
      'stanje': stanje,
      'ak': ak,
      'isAdmin': isAdmin,
    };
  }
}
