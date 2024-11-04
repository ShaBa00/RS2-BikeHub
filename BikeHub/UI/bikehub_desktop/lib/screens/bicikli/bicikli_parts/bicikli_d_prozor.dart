import 'package:flutter/material.dart';
import '../../../services/bicikli/bicikl_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class BicikliDProzor extends StatelessWidget {
  final BiciklService biciklService;
  final int currentPage;
  final Function nextPage;
  final Function previousPage;

  // ignore: use_super_parameters
  const BicikliDProzor({
    Key? key,
    required this.biciklService,
    required this.currentPage,
    required this.nextPage,
    required this.previousPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 188, 188, 188),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: biciklService.lista_ucitanih_bicikala,
        builder: (context, bicikli, _) {
          return bicikli.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 12.0,
                        ),
                        itemCount: bicikli.length,
                        itemBuilder: (context, index) {
                          final item = bicikli[index];
                          final naziv = item['naziv'] ?? 'Nepoznato';
                          final cijena = item['cijena'] ?? 0;

                          Uint8List? imageBytes;
                          if (item['slikeBiciklis'] != null && item['slikeBiciklis'].isNotEmpty) {
                            final base64Image = item['slikeBiciklis'][0]['slika'];
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
                                        : const Icon(Icons.image_not_supported, size: 50), // Ikona ako slika nije dostupna
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
                      ),
                    ),
                    // Paginacija
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => previousPage(),
                        ),
                        Text('Strana ${currentPage + 1}'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => nextPage(),
                        ),
                      ],
                    ),
                  ],
                );
        },
      ),
    );
  }
}
