import 'package:bikehub_desktop/screens/bicikli/bicikl_prikaz.dart';
import 'package:bikehub_desktop/screens/dijelovi/dijelovi_prikaz.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class PocetniProzorP2 extends StatelessWidget {
  final bool showBicikli; // Dodajemo showBicikli kao atribut

  const PocetniProzorP2({super.key, required this.showBicikli});

  @override
  Widget build(BuildContext context) {
    final biciklService = BiciklService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotivni Artikli'), 
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: biciklService.getPromotedItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nema dostupnih artikala'));
          } else {
            return GridView.builder(
  padding: const EdgeInsets.all(8.0),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    childAspectRatio: 0.7,
    mainAxisSpacing: 12.0,
    crossAxisSpacing: 12.0,
  ),
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    final item = snapshot.data![index];
    final naziv = item['naziv'] ?? 'Nepoznato';
    final cijena = item['cijena'] ?? 0;

    Uint8List? imageBytes;
    if (item['slike'] != null && item['slike'].isNotEmpty) {
      final base64Image = item['slike'][0]['slika'];
      imageBytes = base64Decode(base64Image);
    }

    bool isHovered = false; // Dodatno stanje za hover efekt

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              if (item.containsKey('biciklId')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BiciklPrikaz(
                      biciklId: item['biciklId'],
                      korisnikId: item['korisnikId'],
                    ),
                  ),
                );
              } else if (item.containsKey('dijeloviId')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DijeloviPrikaz(
                      dioId: item['dijeloviId'],
                      korisnikId: item['korisnikId'],
                    ),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isHovered ? Colors.grey[200] : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: isHovered
                    ? [BoxShadow(color: Colors.grey.shade400, blurRadius: 6, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
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
            ),
          ),
        );
      },
    );
  },
);

          }
        },
      ),
    );
  }
}
