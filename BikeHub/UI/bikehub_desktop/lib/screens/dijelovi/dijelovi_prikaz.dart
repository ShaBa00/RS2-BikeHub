// ignore_for_file: use_build_context_synchronously

import 'package:bikehub_desktop/screens/bicikli/bicikl_prikaz.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/dijelovi/spaseni_dijelovi_service.dart';
import 'package:bikehub_desktop/services/kategorije/recommended_kategorije_service.dart';
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
  bool isLoggedIn=false;
  final RecommendedKategorijaService recommendedKategorijaService = RecommendedKategorijaService();
  final KorisnikService korisnikService = KorisnikService();
  final SpaseniDijeloviService spaseniDijeloviService = SpaseniDijeloviService();

  @override
  void initState() {
    super.initState();
    recommendedKategorijaService.getRecommendedBiciklList(widget.dioId);
    fetchData();
  }

  loggedIn() async {
    isLoggedIn = await korisnikService.isLoggedIn();
    setState(() {});
  }

  saveProduct() async {
    if(!isLoggedIn){
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je prijaviti se da bi mogli sacuvati proizvod");
    }
    final userInfo = await korisnikService.getUserInfo();
    final int? idKorisnika = int.tryParse(userInfo['korisnikId'] ?? '');
    if (dio != null && korisnik != null) {
      await spaseniDijeloviService.addSpaseniDijelovi(context,dio?['dijeloviId'], idKorisnika!);
    }
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
    await loggedIn();
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8, // prilagođeno za središnji sadržaj
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
                                        korisnik?['username'] ?? 'Korisničko ime nije pronađeno',
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
                                        korisnik?['korisnikInfos'] != null && korisnik!['korisnikInfos'].isNotEmpty 
                                          ? korisnik!['korisnikInfos'][0]['telefon'] ?? 'Telefon nije pronađen' 
                                          : 'Telefon nije pronađen',
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
                                  borderRadius: BorderRadius.circular(16.0), // Zaobljenje ivica
                                  child: Image.memory(
                                    getCurrentImageBytes()!,
                                    width: MediaQuery.of(context).size.width * 0.4, // širine ekrana
                                    height: MediaQuery.of(context).size.width * 0.32, // širine ekrana za kvadratne slike
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: saveProduct,
                                    child: const Text('Sačuvaj'),
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
                                          adresa?['grad'] ?? 'Grad nije pronađen',
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
                                          adresa?['ulica'] ?? 'Ulica nije pronađena',
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
                        _buildDetailContainer('Naziv', dio?['naziv'] ?? 'Naziv nije pronađen'),
                        _buildDetailContainer('Opis', dio?['opis'] ?? 'Opis nije pronađen'),
                        _buildDetailContainer('Cijena', dio?['cijena']?.toString() ?? 'Cijena nije pronađena'),
                        _buildDetailContainer('Količina', dio?['kolicina']?.toString() ?? 'Količina nije pronađena'),
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.40, // Visina glavnog okvira
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 188, 188, 188),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: recommendedKategorijaService.recommendedBicikliList,
                      builder: (context, bicikli, _) {
                        return bicikli.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nema preporučenih bicikl.",
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8.0),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, // Prilagodi broj stupaca prema potrebi
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 12.0,
                                  crossAxisSpacing: 12.0,
                                ),
                                itemCount: bicikli.length,
                                itemBuilder: (context, index) {
                                  final item = bicikli[index];
                                  final korisnikId = item['korisnikId'] ?? 0;
                                  final biciklId = item['biciklId'] ?? 0;
                                  final naziv = item['naziv'] ?? 'Nepoznato';
                                  final cijena = item['cijena'] ?? 0;
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
                                             userProfile:false,
                                             ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.02,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8.0),
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
                                                  Text(naziv, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 4),
                                                  Text('Cijena: $cijena KM', style: const TextStyle(fontSize: 12)),
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
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
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
          Text(
            '$label: ',
            // ignore: prefer_const_constructors
            style: TextStyle(color: Colors.white),
          ),   
          Text(
            '$value',
            style: const TextStyle(color: Colors.white),
          ),                           
        ],
      ),
    );
  }
