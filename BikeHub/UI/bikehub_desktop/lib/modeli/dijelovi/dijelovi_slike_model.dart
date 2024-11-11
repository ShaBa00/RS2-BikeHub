import 'dart:typed_data';

class SlikeDijeloviInsertR {
  final int dijeloviId;
  final Uint8List slika;

  SlikeDijeloviInsertR({required this.dijeloviId, required this.slika});

  Map<String, dynamic> toJson() {
    return {
      'BiciklId': dijeloviId,
      'Slika': slika,
    };
  }

  factory SlikeDijeloviInsertR.fromJson(Map<String, dynamic> json) {
    return SlikeDijeloviInsertR(
      dijeloviId: json['DijeloviId'],
      slika: json['Slika'] != null ? Uint8List.fromList(json['Slika']) : Uint8List(0),
    );
  }
}
