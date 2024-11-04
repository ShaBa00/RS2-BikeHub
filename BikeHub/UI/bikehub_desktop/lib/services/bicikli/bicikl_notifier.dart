import 'package:flutter/material.dart';

class BiciklNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _bicikli = [];

  List<Map<String, dynamic>> get bicikli => _bicikli;

  void setBicikli(List<Map<String, dynamic>> newBicikli) {
    _bicikli = newBicikli;
    notifyListeners();
  }
}
