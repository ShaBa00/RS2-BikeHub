import 'dart:typed_data';

class SlikeBicikliInsertR {
  final int biciklId;
  final Uint8List slika;

  SlikeBicikliInsertR({required this.biciklId, required this.slika});

  Map<String, dynamic> toJson() {
    return {
      'BiciklId': biciklId,
      'Slika': slika,
    };
  }

  factory SlikeBicikliInsertR.fromJson(Map<String, dynamic> json) {
    return SlikeBicikliInsertR(
      biciklId: json['BiciklId'],
      slika: json['Slika'] != null ? Uint8List.fromList(json['Slika']) : Uint8List(0),
    );
  }
}
