// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_declarations, sized_box_for_whitespace, unused_local_variable

import 'package:bikehub_desktop/screens/dijelovi/dijelovi_prikaz.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/bicikli/promocija_bicikli_service.dart';
import 'package:bikehub_desktop/services/bicikli/spaseni_bicikl_service.dart';
// ignore: unused_import
import 'package:bikehub_desktop/services/paypal/paypal_service.dart';
import 'package:flutter/material.dart';
import '../../services/bicikli/bicikl_service.dart';
import '../../services/adresa/adresa_service.dart';
import '../../services/kategorije/recommended_kategorije_service.dart';
import '../../services/korisnik/korisnik_service.dart';
import 'dart:convert';
import 'dart:typed_data';


class BiciklPrikaz extends StatefulWidget {
  final int biciklId;
  final int korisnikId;
  final bool userProfile;

  const BiciklPrikaz({super.key, required this.biciklId, required this.korisnikId, required this.userProfile});

  @override
  // ignore: library_private_types_in_public_api
  _BiciklPrikazState createState() => _BiciklPrikazState();
}

class _BiciklPrikazState extends State<BiciklPrikaz> {
  Map<String, dynamic>? korisnik;
  Map<String, dynamic>? bicikl;
  Map<String, dynamic>? adresa;
  bool isPromovisan=false;
  final RecommendedKategorijaService recommendedKategorijaService = RecommendedKategorijaService();
  final KorisnikService korisnikService = KorisnikService();
  final SpaseniBicikliService spaseniBicikliService = SpaseniBicikliService();

  int currentImageIndex = 0;
  bool isLoggedIn=false;

  @override
  void initState() {
    super.initState();
    recommendedKategorijaService.getRecommendedDijeloviList(widget.biciklId);
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
    if (bicikl != null && korisnik != null) {
      await spaseniBicikliService.addSpaseniBicikl(context,bicikl?['biciklId'], idKorisnika!);
    }
  }

  orderProduct() async {
    if(!isLoggedIn){
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je prijaviti se da bi mogli narucili proizvod");
    }
  }

  Future<void> fetchData() async {
    final fetchedKorisnik = await KorisnikService().getKorisnikByID(widget.korisnikId);
    final fetchedBicikl = await BiciklService().getBiciklById(widget.biciklId);
    final fetchedAdresa = await AdresaService().getAdresaByKorisnikId(widget.korisnikId);
    Map<String, dynamic>? fetchedPromocija;

      try {
        fetchedPromocija = await PromocijaBicikliService().getPromocijaBicikliById(widget.biciklId);
      } catch (e) {
        fetchedPromocija = null;
      }

    // ignore: unnecessary_null_comparison, collection_methods_unrelated_type
    if (fetchedPromocija != null && fetchedPromocija.isNotEmpty && fetchedPromocija['status'] == 'aktivan') {
      isPromovisan = true;
    }
    setState(() {
      korisnik = fetchedKorisnik;
      bicikl = fetchedBicikl;
      adresa = fetchedAdresa;
      isPromovisan;
    });
    await loggedIn();
  }
  Uint8List? getCurrentImageBytes() {
    if (bicikl != null &&
        bicikl!['slikeBiciklis'] != null &&
        bicikl!['slikeBiciklis'].isNotEmpty) {
      final base64Image = bicikl!['slikeBiciklis'][currentImageIndex]['slika'];
      return base64Decode(base64Image);
    }
    return null;
  }
  void showNextImage() {
    setState(() {
      if (bicikl != null && bicikl!['slikeBiciklis'].isNotEmpty) {
        currentImageIndex = ((currentImageIndex + 1) % bicikl!['slikeBiciklis'].length).toInt();
      }
    });
  }

  void showPreviousImage() {
    setState(() {
      if (bicikl != null && bicikl!['slikeBiciklis'].isNotEmpty) {
        currentImageIndex = ((currentImageIndex - 1 + bicikl!['slikeBiciklis'].length) % bicikl!['slikeBiciklis'].length).toInt();
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
        title: const Text('Bicikl Prikaz'),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: korisnik == null || bicikl == null || adresa == null
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
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: orderProduct,
                                  child: const Text('Naruči'),
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
    height: MediaQuery.of(context).size.height * 0.17,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border(
        left: BorderSide(color: Colors.blue.shade900, width: 2.0),
        bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
        right: BorderSide(color: Colors.blue.shade900, width: 2.0),
      ),
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetailContainer('Naziv:', bicikl?['naziv'] ?? 'Naziv nije pronađen'),
            _buildDetailContainer('Veličina Rama:', bicikl?['velicinaRama'] ?? 'Veličina rama nije pronađena'),
            _buildDetailContainer('Cijena:', bicikl?['cijena']?.toString() ?? 'Cijena nije pronađena'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetailContainer('Veličina Točka:', bicikl?['velicinaTocka'] ?? 'Veličina točka nije pronađena'),
            _buildDetailContainer('Broj Brzina:', bicikl?['brojBrzina']?.toString() ?? 'Broj brzina nije pronađen'),
            // ignore: collection_methods_unrelated_type
            _buildDetailContainer('', isPromovisan? 'Artikal promovisan' : 'Artikal nije promovisan'),
              if(widget.userProfile)
                ElevatedButton(
                    onPressed: () {
                      _showPromocijaProizvoda(context);
                    },
                    // ignore: prefer_const_constructors
                    child: Text('Promocija'),
                  ),
          ],
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
                      valueListenable: recommendedKategorijaService.recommendedDijeloviList,
                      builder: (context, dijelovi, _) {
                        return dijelovi.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nema preporučenih dijelova.",
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
                                itemCount: dijelovi.length,
                                itemBuilder: (context, index) {
                                  final item = dijelovi[index];
                                  final korisnikId = item['korisnikId'] ?? 0;
                                  final dijeloviId = item['dijeloviId'] ?? 0;
                                  final naziv = item['naziv'] ?? 'Nepoznato';
                                  final cijena = item['cijena'] ?? 0;
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
  

  
  void zahtjevPlacanja(int cijena, int brojDana, String email, String ime, String prezime) async {
    if (email.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je upisati email");
      return;
    }
    if (ime.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je upisati ime");
      return;
    }
    if (prezime.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je upisati prezime");
      return;
    }

  }



void _showPromocijaProizvoda(BuildContext context) {
  bool _isFirstPage = true;
  int _brojDana = 1;
  final int _cijena = 20;
  String _email = '';
  String _ime = '';
  String _prezime = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 92, 225, 230),
                    Color.fromARGB(255, 7, 181, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.36,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4325,
                        width: MediaQuery.of(context).size.width * 0.36,
                        child: Center(
                          child: _isFirstPage
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer2(
                                      'Broj dana:',
                                      DropdownButton(
                                        value: _brojDana,
                                        items: List.generate(10, (index) {
                                          return DropdownMenuItem(
                                            value: index + 1,
                                            child: Text('${index + 1}'),
                                          );
                                        }),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            _brojDana = newValue!;
                                          });
                                        },
                                      ), 0.16,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailContainer2('Cijena:', '20 EUR',0.16),
                                    const SizedBox(height: 10),
                                    _buildDetailContainer2(
                                      'Ukupna cijena:',
                                      '${_brojDana * _cijena} EUR',0.16
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer2(
                                      'Ukupna cijena:',
                                      '${_brojDana * _cijena} EUR',0.16
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailContainer2(
                                      'Email:',
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            _email = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Unesite email',
                                        ),
                                      ),0.2
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailContainer2(
                                      'Ime:',
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            _ime = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Unesite ime',
                                        ),
                                      ),0.2
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailContainer2(
                                      'Prezime:',
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            _prezime = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Unesite prezime',
                                        ),
                                      ),0.2
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.0675,
                        width: MediaQuery.of(context).size.width * 0.36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_isFirstPage) {
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    _isFirstPage = true;
                                  });
                                }
                              },
                              child: Text(_isFirstPage ? 'Nazad' : 'Nazad na Prvu Stranicu'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_isFirstPage) {
                                  setState(() {
                                    _isFirstPage = false;
                                  });
                                } else {
                                  zahtjevPlacanja(_cijena, _brojDana, _email, _ime, _prezime);
                                }
                              },
                              child: Text(_isFirstPage ? 'Placanje' : 'Plati'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  
  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.16,
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
            '$label ',
            style: const TextStyle(color: Colors.white),
          ),
          value is Widget ? value : Text(
            '$value',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
  Widget _buildDetailContainer2(String label, dynamic value, double sirina) {
    bool isDropdown = value is DropdownButton;

    return Container(
      padding:  EdgeInsets.all(MediaQuery.of(context).size.height * 0.009),
      width: MediaQuery.of(context).size.width * sirina,
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(16.0), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label ',
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 20),
          isDropdown
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.035, 
                  child: value,
                )
              : value is Widget
                  ? Expanded(child: value)
                  : Text(
                      '$value',
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      textAlign: TextAlign.center,
                    ),
        ],
      ),
    );
  }
}
