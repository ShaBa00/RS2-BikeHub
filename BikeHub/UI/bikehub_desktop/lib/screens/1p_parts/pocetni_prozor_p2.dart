import 'package:flutter/material.dart';
import 'package:bikehub_desktop/services/bicikl_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class PocetniProzorP2 extends StatelessWidget {
  const PocetniProzorP2({super.key, required bool showBicikli});

  @override
  Widget build(BuildContext context) {
    final biciklService = BiciklService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bicikli'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: biciklService.getBicikli(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nema dostupnih bicikala'));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(8.0), // Veći razmak između kocki
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 bicikla po redu
                childAspectRatio: 0.7, // Manja visina proizvoda
                mainAxisSpacing: 12.0, // Veći razmak vertikalno
                crossAxisSpacing: 12.0, // Veći razmak horizontalno
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bicikl = snapshot.data![index];
                final naziv = bicikl['naziv'] ?? 'Nepoznato';
                final cijena = bicikl['cijena'] ?? 0;

                // Dekodiranje slike iz Base64
                Uint8List? imageBytes;
                if (bicikl['slikeBiciklis'] != null && bicikl['slikeBiciklis'].isNotEmpty) {
                  final base64Image = bicikl['slikeBiciklis'][0]['slika'];
                  imageBytes = base64Decode(base64Image);
                }

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                          child: imageBytes != null
                              ? Image.memory(
                                  imageBytes,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Cijena: $cijena KM'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
