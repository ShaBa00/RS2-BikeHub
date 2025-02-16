import 'package:flutter/material.dart';
import '../../../services/bicikli/bicikl_service.dart';

class BicikliLProzor extends StatefulWidget {
  const BicikliLProzor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BicikliLProzorState createState() => _BicikliLProzorState();
}

class _BicikliLProzorState extends State<BicikliLProzor> {
  final BiciklService biciklService = BiciklService();

  // Kontrole za input
  String? velicinaRama;
  String? velicinaTocka;
  int? brojBrzina;
  double? pocetnaCijena;
  double? krajnjaCijena;

  // Kontrola za slider
  RangeValues _currentRangeValues = const RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 92, 225, 230),
            Color.fromARGB(255, 7, 181, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Veličina Rama',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blueAccent,
                ),
                onChanged: (value) {
                  velicinaRama = value;
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Veličina Točka',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blueAccent,
                ),
                onChanged: (value) {
                  velicinaTocka = value;
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Broj Brzina',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blueAccent,
                ),
                onChanged: (value) {
                  brojBrzina = int.tryParse(value);
                },
              ),
              const SizedBox(height: 16),

              RangeSlider(
                values: _currentRangeValues,
                min: 0,
                max: 1000,
                divisions: 10,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                    pocetnaCijena = values.start;
                    krajnjaCijena = values.end;
                  });
                },
              ),
              const Text('Cijena:'),
              Text(
                'Od: ${_currentRangeValues.start.round()} do: ${_currentRangeValues.end.round()}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  await biciklService.getBicikli(
                    velicinaRama: velicinaRama,
                    velicinaTocka: velicinaTocka,
                    brojBrzina: brojBrzina,
                    pocetnaCijena: pocetnaCijena,
                    krajnjaCijena: krajnjaCijena,
                  );
                },
                child: const Text('Pretraži'),
              ),
              const SizedBox(height: 16),

              // Prikaz liste učitanih bicikala
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: biciklService.lista_ucitanih_bicikala,
                builder: (context, listaBicikala, child) {
                  if (listaBicikala.isEmpty) {
                    return const Text('Nema učitanih bicikala', style: TextStyle(color: Colors.white));
                  }
                  return Column(
                    children: listaBicikala.map((bicikl) {
                      return ListTile(
                        title: Text(
                          bicikl['naziv'] ?? 'N/A',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Cijena: ${bicikl['cijena'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
