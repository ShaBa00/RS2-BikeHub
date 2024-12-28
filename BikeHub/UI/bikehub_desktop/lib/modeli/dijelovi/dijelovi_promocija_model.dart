class DijeloviPromocijaModel {
  int promocijaDijeloviId;
  String stanje;
  int ak;

  DijeloviPromocijaModel({
    required this.promocijaDijeloviId,
    required this.stanje,
    required this.ak,
  });
  factory DijeloviPromocijaModel.fromJson(Map<String, dynamic> json) {
    return DijeloviPromocijaModel(
      promocijaDijeloviId: json['promocijaDijeloviId'] ?? 0,
      stanje: json['aktivacija'] ?? false,
      ak: json['ak'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'promocijaDijeloviId': promocijaDijeloviId,
      'stanje': stanje,
      'ak': ak,
    };
  }
}
