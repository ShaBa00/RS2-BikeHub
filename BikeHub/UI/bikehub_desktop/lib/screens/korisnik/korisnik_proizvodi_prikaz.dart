import 'package:bikehub_desktop/screens/bicikli/bicikl_prikaz.dart';
import 'package:bikehub_desktop/screens/dijelovi/dijelovi_prikaz.dart';
import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class KorisnikProizvodiPrikaz  extends StatefulWidget {
  const KorisnikProizvodiPrikaz ({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KorisnikProizvodiPrikazState createState() => _KorisnikProizvodiPrikazState();
}

class _KorisnikProizvodiPrikazState extends State<KorisnikProizvodiPrikaz > {
  late Future<Map<String, List<Map<String, dynamic>>>> _proizvodi;
  bool _showBicikli = true;
  int _currentPage = 0;
  final int _itemsPerPage = 8;

Widget _buildBicikliList(List<Map<String, dynamic>> bicikli) {
  final displayedBicikli = bicikli.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();
  
  return Column(
    children: [
      Expanded(
        child: displayedBicikli.isEmpty
            ? const Center(
                child: Text(
                  'Korisnik nema kreiranih bicikala.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayedBicikli.length,
                itemBuilder: (context, index) {
                  final item = displayedBicikli[index];
                  final naziv = item['naziv'] ?? 'Nepoznato';
                  final cijena = item['cijena'] ?? 0;
                  final biciklId = item['biciklId'] ?? 0;
                  final korisnikId = item['korisnikId'] ?? 0;
                  Uint8List? imageBytes;
                  if (item['slikeBiciklis'] != null && item['slikeBiciklis'].isNotEmpty) {
                    final base64Image = item['slikeBiciklis'][0]['slika'];
                    imageBytes = base64Decode(base64Image);
                  }

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BiciklPrikaz(
                              biciklId: biciklId, 
                              korisnikId: korisnikId,
                              userProfile:true,
                              ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
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
                                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                                    : const Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Cijena: $cijena KM'),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeBicikl(biciklId),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousPage,
          ),
          Text('Strana ${_currentPage + 1}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextPage,
          ),
        ],
      ),
    ],
  );
}

Widget _buildDijeloviList(List<Map<String, dynamic>> dijelovi) {
  final displayedDijelovi = dijelovi.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();

  return Column(
    children: [
      Expanded(
        child: displayedDijelovi.isEmpty
            ? const Center(
                child: Text(
                  'Korisnik nema kreiranih dijelova.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayedDijelovi.length,
                itemBuilder: (context, index) {
                  final item = displayedDijelovi[index];
                  final naziv = item['naziv'] ?? 'Nepoznato';
                  final cijena = item['cijena'] ?? 0;
                  final dijeloviId = item['dijeloviId'] ?? 0;
                  final korisnikId = item['korisnikId'] ?? 0;
                  Uint8List? imageBytes;
                  if (item['slikeDijelovis'] != null && item['slikeDijelovis'].isNotEmpty) {
                    final base64Image = item['slikeDijelovis'][0]['slika'];
                    imageBytes = base64Decode(base64Image);
                  }

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DijeloviPrikaz(dioId: dijeloviId, korisnikId: korisnikId),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
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
                                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                                    : const Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Cijena: $cijena KM'),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeDio(dijeloviId),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousPage,
          ),
          Text('Strana ${_currentPage + 1}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextPage,
          ),
        ],
      ),
    ],
  );
}

  @override
  void initState() {
    super.initState();
    _proizvodi = _fetchSacuvaniProizvodi();
  }
  
  void _removeBicikl(int biciklId) async {
    await BiciklService().removeBicikl(biciklId);
    setState(() {      
    _proizvodi = _fetchSacuvaniProizvodi();
   });
  }

  void _removeDio(int dijeloviId) async {
    await DijeloviService().removeDijelovi(dijeloviId);
    setState(() {      
    _proizvodi = _fetchSacuvaniProizvodi();
    });
  }
  // ignore: unused_element
  Future<Map<String, List<Map<String, dynamic>>>> _fetchSacuvaniProizvodi() async {
    final KorisnikService korisnikService = KorisnikService();
    final DijeloviService dijeloviService = DijeloviService();
    final BiciklService biciklService = BiciklService();

    final korisnikInfo = await korisnikService.getUserInfo();
    final korisnikId = int.parse(korisnikInfo['korisnikId'] ?? '0');

    final korisnikoviDijelovi = await dijeloviService.getDijelovi(korisnikId:korisnikId, status: "aktivan");
  

    final korisnikoviBicikli = await biciklService.getBicikli(korisnikId:korisnikId,status: "aktivan");

    return {
      'dijelovi': korisnikoviDijelovi,
      'bicikli': korisnikoviBicikli,
    };
  }
  
  void _nextPage() {
    setState(() => _currentPage++);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kreirani proizvodi"),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      extendBodyBehindAppBar: true, 
      body: Container(
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
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10), 
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.17,
                  height: MediaQuery.of(context).size.height * 0.85 * 0.10,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showBicikli = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showBicikli ? Colors.blue : Colors.grey,
                            ),
                            child: const Text("Bicikli"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showBicikli = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showBicikli ? Colors.grey : Colors.blue,
                            ),
                            child: const Text("Dijelovi"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // DonjiP1 
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                      future: _proizvodi,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Greška: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Nema kreiranih proizvoda.'));
                        }

                        final proizvodi = snapshot.data!;
                        final korisnikoviBicikli = proizvodi['bicikli']!;
                        final korisnikoviDijelovi = proizvodi['dijelovi']!;

                        return Container(
                          width: MediaQuery.of(context).size.width * 0.85 * 0.90,
                          height: MediaQuery.of(context).size.height * 0.85 * 0.85,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 255, 255),
                                Color.fromARGB(255, 188, 188, 188),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _showBicikli
                              ? _buildBicikliList(korisnikoviBicikli)
                              : _buildDijeloviList(korisnikoviDijelovi),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
