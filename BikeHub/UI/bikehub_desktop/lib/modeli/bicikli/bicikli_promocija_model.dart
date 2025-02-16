class BicikliPromocijaModel {
  int promocijaBicikliId;
  String stanje;
  int ak;

  BicikliPromocijaModel({
    required this.promocijaBicikliId,
    required this.stanje,
    required this.ak,
  });
  factory BicikliPromocijaModel.fromJson(Map<String, dynamic> json) {
    return BicikliPromocijaModel(
      promocijaBicikliId: json['promocijaBicikliId'] ?? 0,
      stanje: json['aktivacija'] ?? false,
      ak: json['ak'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'promocijaBicikliId': promocijaBicikliId,
      'stanje': stanje,
      'ak': ak,
    };
  }
}
