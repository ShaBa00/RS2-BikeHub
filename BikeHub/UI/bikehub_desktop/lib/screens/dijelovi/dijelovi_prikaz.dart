import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:flutter/material.dart';
import '../../services/adresa/adresa_service.dart';
import '../../services/korisnik/korisnik_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class DijeloviPrikaz extends StatefulWidget {
  final int dioId;
  final int korisnikId;

  const DijeloviPrikaz({super.key, required this.dioId, required this.korisnikId});

  @override
  // ignore: library_private_types_in_public_api
  _DijeloviPrikazState createState() => _DijeloviPrikazState();
}

class _DijeloviPrikazState extends State<DijeloviPrikaz> {
  Map<String, dynamic>? korisnik;
  Map<String, dynamic>? dio;
  Map<String, dynamic>? adresa;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final fetchedKorisnik = await KorisnikService().getKorisnikByID(widget.korisnikId);
    final fetchedDijelovi = await DijeloviService().getDijeloviById(widget.dioId);
    final fetchedAdresa = await AdresaService().getAdresaByKorisnikId(widget.korisnikId);

    setState(() {
      korisnik = fetchedKorisnik;
      dio = fetchedDijelovi;
      adresa = fetchedAdresa;
    });
  }
  Uint8List? getCurrentImageBytes() {
    if (dio != null &&
        dio!['slikeDijelovis'] != null &&
        dio!['slikeDijelovis'].isNotEmpty) {
      final base64Image = dio!['slikeDijelovis'][currentImageIndex]['slika'];
      return base64Decode(base64Image);
    }
    return null;
  }
  void showNextImage() {
    setState(() {
      if (dio != null && dio!['slikeDijelovis'].isNotEmpty) {
        currentImageIndex = ((currentImageIndex + 1) % dio!['slikeDijelovis'].length).toInt();
      }
    });
  }

  void showPreviousImage() {
    setState(() {
      if (dio != null && dio!['slikeDijelovis'].isNotEmpty) {
        currentImageIndex = ((currentImageIndex - 1 + dio!['slikeDijelovis'].length) % dio!['slikeDijelovis'].length).toInt();
      }
    });
  }
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
    child: Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: const Text('Dijelovi Prikaz'),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: korisnik == null || dio == null || adresa == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Left Panel (LP)
                      Expanded(
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 20% širine ekrana
                            height: MediaQuery.of(context).size.height * 0.3, // 30% visine ekrana
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Prozirna pozadina
                              border: Border(
                                left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Username: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        korisnik!['username'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Telefon: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        korisnik!['korisnikInfos'][0]['telefon'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Middle Panel (SP)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (getCurrentImageBytes() != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0), 
                                child: Image.memory(
                                  getCurrentImageBytes()!,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  height: MediaQuery.of(context).size.width * 0.32, 
                                  fit: BoxFit.cover, 
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: showPreviousImage,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: showNextImage,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Right Panel (DP)
                      Expanded(
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 20% širine ekrana
                            height: MediaQuery.of(context).size.height * 0.3, // 30% visine ekrana
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Prozirna pozadina
                              border: Border(
                                left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Grad: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        adresa!['grad'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                      right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Ulica: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        adresa!['ulica'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Info Panel
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8, 
                    height: MediaQuery.of(context).size.height * 0.2, 
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Prozirna pozadina
                      border: Border(
                        left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Naziv: ',
                                style: TextStyle(color: Colors.white),
                              ),   
                              const SizedBox(width: 118.0),
                              Text(
                                dio!['naziv'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Opis: ',
                                style: TextStyle(color: Colors.white),
                              ),   
                              const SizedBox(width: 118.0),
                              Text(
                                dio!['opis'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Cijena: ',
                                style: TextStyle(color: Colors.white),
                              ),   
                              const SizedBox(width: 118.0),
                              Text(
                                dio!['cijena'].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                              right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Kolicina: ',
                                style: TextStyle(color: Colors.white),
                              ),   
                              const SizedBox(width: 118.0),
                              Text(
                                dio!['kolicina'].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
