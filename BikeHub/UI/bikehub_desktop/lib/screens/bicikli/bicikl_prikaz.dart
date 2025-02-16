// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_declarations, sized_box_for_whitespace, unused_local_variable, prefer_const_constructors, avoid_print, non_constant_identifier_names, unnecessary_to_list_in_spreads

import 'package:bikehub_desktop/screens/dijelovi/dijelovi_prikaz.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/screens/pocetni_prozor.dart';
import 'package:bikehub_desktop/services/bicikli/promocija_bicikli_service.dart';
import 'package:bikehub_desktop/services/bicikli/slike_bicikl_service.dart';
import 'package:bikehub_desktop/services/bicikli/spaseni_bicikl_service.dart';
import 'package:bikehub_desktop/services/kategorije/kategorija_service.dart';
import 'package:bikehub_desktop/screens/ostalo/confirm_prozor.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import '../../services/bicikli/bicikl_service.dart';
import '../../services/adresa/adresa_service.dart';
import '../../services/kategorije/recommended_kategorije_service.dart';
import '../../services/korisnik/korisnik_service.dart';
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
  int prijavljeniKorisnikID = 0;
  Map<String, dynamic>? bicikl;
  Map<String, dynamic>? adresa;
  bool isPromovisan = false;
  final RecommendedKategorijaService recommendedKategorijaService = RecommendedKategorijaService();
  final KorisnikService korisnikService = KorisnikService();
  final SpaseniBicikliService spaseniBicikliService = SpaseniBicikliService();
  final KategorijaServis kategorijaServis = KategorijaServis();
  final SlikeBicikliService slikeBicikliService = SlikeBicikliService();
  final BiciklService biciklService = BiciklService();

  final ValueNotifier<List<Map<String, dynamic>>> _listaBikeKategorijeNotifier = ValueNotifier([]);

  getKategorije() async {
    var bikeKategorije = await kategorijaServis.getBikeKategorije();
    _listaBikeKategorijeNotifier.value = List<Map<String, dynamic>>.from(bikeKategorije.where((kategorija) => kategorija['status'] == 'aktivan'));
  }

  int currentImageIndex = 0;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    recommendedKategorijaService.getRecommendedDijeloviList(widget.biciklId);
    fetchData();
  }

  loggedIn() async {
    isLoggedIn = await korisnikService.isLoggedIn();
    if (isLoggedIn) {
      var rez = await korisnikService.getUserInfo();

      prijavljeniKorisnikID = (rez['korisnikId'] != null ? int.tryParse(rez['korisnikId'].toString()) : null)!;
    }
    setState(() {});
  }

  saveProduct() async {
    if (!isLoggedIn) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je prijaviti se da bi mogli sacuvati proizvod");
    }
    final userInfo = await korisnikService.getUserInfo();
    final int? idKorisnika = int.tryParse(userInfo['korisnikId'] ?? '');
    if (bicikl != null && korisnik != null) {
      await spaseniBicikliService.addSpaseniBicikl(context, bicikl?['biciklId'], idKorisnika!);
    }
  }

  bool sacuvanZapisi = false;
  Map<String, dynamic>? zapisSacuvanog;
  bool? isLoggedInCache;

  _getSpaseni() async {
    isLoggedInCache ??= await korisnikService.isLoggedIn();
    if (isLoggedInCache == true) {
      zapisSacuvanog = await spaseniBicikliService.isBiciklSacuvan(korisnikId: prijavljeniKorisnikID, biciklId: widget.biciklId);
      if (zapisSacuvanog != null && zapisSacuvanog?['status'] != "obrisan") {
        sacuvanZapisi = true;
      }
      setState(() {
        sacuvanZapisi;
      });
    }
  }

  List<String> listaSlika = [];
  List<int> listaIdiova = [];

  Future<void> fetchData() async {
    await loggedIn();
    final fetchedKorisnik = await korisnikService.getKorisnikByID(widget.korisnikId);
    final fetchedBicikl = await biciklService.getBiciklById(widget.biciklId);
    if (fetchedBicikl != null) {
      if (fetchedBicikl['slikeBiciklis'] != null) {
        for (var slika in fetchedBicikl['slikeBiciklis']) {
          listaSlika.add(slika['slika']);
          listaIdiova.add(slika['slikeBicikliId']);
        }
      }
    }
    final fetchedAdresa = await AdresaService().getAdresaByKorisnikId(widget.korisnikId);
    Map<String, dynamic>? fetchedPromocija;

    try {
      fetchedPromocija = await PromocijaBicikliService().getPromocijaBicikliById(widget.biciklId);
    } catch (e) {
      fetchedPromocija = null;
    }
    if (fetchedPromocija != null && fetchedPromocija.isNotEmpty && fetchedPromocija['status'] == 'aktivan') {
      isPromovisan = true;
    }
    await _getSpaseni();
    await getKategorije();
    setState(() {
      korisnik = fetchedKorisnik;
      bicikl = fetchedBicikl;
      adresa = fetchedAdresa;
      isPromovisan;
      nazivNovog = bicikl?['naziv']?.toString() ?? "N/A";
      CijenaNovog = bicikl?['cijena']?.toString() ?? "N/A";
      KolicinaNovog = bicikl?['kolicina']?.toString() ?? "N/A";
      brojBrzinaNovog = bicikl?['brojBrzina']?.toString() ?? "N/A";
      VelicinaRamaNovog = bicikl?['velicinaRama']?.toString() ?? "N/A";
      VelicinaTockaNovog = bicikl?['velicinaTocka']?.toString() ?? "N/A";
    });
  }

  Uint8List? getCurrentImageBytes() {
    if (bicikl != null && bicikl!['slikeBiciklis'] != null && bicikl!['slikeBiciklis'].isNotEmpty) {
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
                                    prijavljeniKorisnikID == bicikl?['korisnikId']
                                        ? Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (bicikl != null) {
                                                    setState(() {
                                                      nazivNovog = bicikl?['naziv']?.toString() ?? "N/A";
                                                      CijenaNovog = bicikl?['cijena']?.toString() ?? "N/A";
                                                      KolicinaNovog = bicikl?['kolicina']?.toString() ?? "N/A";
                                                      brojBrzinaNovog = bicikl?['brojBrzina']?.toString() ?? "N/A";
                                                      VelicinaRamaNovog = bicikl?['velicinaRama']?.toString() ?? "N/A";
                                                      VelicinaTockaNovog = bicikl?['velicinaTocka']?.toString() ?? "N/A";
                                                    });
                                                    if (bicikl?['slikeBiciklis'] != null) {
                                                      currentIndex = 0;
                                                      listaSlika = [];
                                                      listaIdiova = [];
                                                      for (var slika in bicikl?['slikeBiciklis']) {
                                                        listaSlika.add(slika['slika']);
                                                        listaIdiova.add(slika['slikeBicikliId']);
                                                      }
                                                    }
                                                  }
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: _editPopUp(context),
                                                      );
                                                    },
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromARGB(255, 87, 202, 255),
                                                  minimumSize: Size(
                                                    MediaQuery.of(context).size.width * 0.08,
                                                    36,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.01,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  obrisiBicikl();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromARGB(255, 87, 202, 255),
                                                  minimumSize: Size(
                                                    MediaQuery.of(context).size.width * 0.08,
                                                    36,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Obriši',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : ElevatedButton(
                                            onPressed: saveProduct,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(255, 87, 202, 255),
                                              minimumSize: Size(
                                                MediaQuery.of(context).size.width * 0.06,
                                                36,
                                              ),
                                            ),
                                            child: Text(
                                              'Sačuvaj',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
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
                                _buildDetailContainer('', isPromovisan ? 'Artikal promovisan' : 'Artikal nije promovisan'),
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

  obrisiBicikl() async {
    bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, 'Da li ste sigurni da želite obrisati ovaj bicikl?');
    if (confirmed != true) {
      return;
    }
    var rezultat = await biciklService.deleteBicikl(widget.biciklId);
    if (rezultat != null) {
      PorukaHelper.prikaziPorukuUspjeha(context, "Uspjesno obrisan zapis");
    } else {
      PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom brisanja zapisa");
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PocetniProzor()),
    );
  }

  bool showFirstSlider = true;
  int currentIndex = 0;

  Widget _editPopUp(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.47,
      width: MediaQuery.of(context).size.width * 0.34,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.34,
                color: const Color.fromARGB(0, 244, 67, 54),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width * 0.34,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: showFirstSlider
                            ? Container(
                                key: ValueKey(1),
                                height: MediaQuery.of(context).size.height * 0.33,
                                width: MediaQuery.of(context).size.width * 0.34,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 7, 161, 235),
                                      Color.fromARGB(255, 82, 205, 210),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.33,
                                      width: MediaQuery.of(context).size.width * 0.17,
                                      color: const Color.fromARGB(0, 233, 30, 98),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.02,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  nazivNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: nazivNovog.isNotEmpty ? nazivNovog : 'Naziv',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.02,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  CijenaNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: CijenaNovog.isNotEmpty ? CijenaNovog : 'Cijena',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.02,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  KolicinaNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: KolicinaNovog.isNotEmpty ? KolicinaNovog : 'Kolicina',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.02,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  brojBrzinaNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: brojBrzinaNovog.isNotEmpty ? brojBrzinaNovog : 'Broj brzina',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.33,
                                      width: MediaQuery.of(context).size.width * 0.17,
                                      color: const Color.fromARGB(0, 0, 187, 212), // Promijenite boju prema potrebi
                                      child: Column(
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.04,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  VelicinaRamaNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: VelicinaRamaNovog.isNotEmpty ? VelicinaRamaNovog : 'Velicina rama',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.03,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  VelicinaTockaNovog = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: VelicinaTockaNovog.isNotEmpty ? VelicinaTockaNovog : 'Velicina tocka',
                                                hintStyle: TextStyle(color: Colors.white),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.03,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border(
                                                bottom: BorderSide(color: Colors.white),
                                                right: BorderSide(color: Colors.white),
                                                left: BorderSide(color: Colors.white),
                                              ),
                                            ),
                                            child: Center(
                                              child: ValueListenableBuilder(
                                                valueListenable: _listaBikeKategorijeNotifier,
                                                builder: (context, kategorije, _) {
                                                  return DropdownButton<int?>(
                                                    value: selectedKategorijaId,
                                                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: const TextStyle(color: Colors.white),
                                                    underline: Container(
                                                      height: 2,
                                                      color: Colors.transparent,
                                                    ),
                                                    hint: const Text(
                                                      "Sve Kategorije",
                                                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    onChanged: (int? newValue) {
                                                      setState(() {
                                                        selectedKategorijaId = newValue;
                                                      });
                                                    },
                                                    items: [
                                                      const DropdownMenuItem<int?>(value: null, child: Text("Sve Kategorije")),
                                                      ...kategorije.map<DropdownMenuItem<int>>((kategorija) {
                                                        return DropdownMenuItem<int>(
                                                          value: kategorija['kategorijaId'],
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width * 0.10,
                                                            alignment: Alignment.center,
                                                            child: Text(kategorija['naziv']),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ],
                                                    dropdownColor: Colors.transparent,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                key: ValueKey(2),
                                height: MediaQuery.of(context).size.height * 0.33,
                                width: MediaQuery.of(context).size.width * 0.34,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    //slikee
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.33,
                                      width: MediaQuery.of(context).size.width * 0.26,
                                      color: const Color.fromARGB(0, 155, 39, 176), // Promijenite boju prema potrebi
                                      child: Column(
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.28,
                                            width: MediaQuery.of(context).size.width * 0.26,
                                            color: const Color.fromARGB(0, 244, 67, 54), // Promijenite boju prema potrebi
                                            child: Center(
                                              child: Container(
                                                height: MediaQuery.of(context).size.height * 0.25,
                                                width: MediaQuery.of(context).size.width * 0.20,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue, // Promijenite boju prema potrebi
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: listaSlika.isNotEmpty
                                                      ? Image.memory(
                                                          base64Decode(listaSlika[currentIndex]),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Center(
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            color: Colors.white,
                                                            size: 50,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.05,
                                            width: MediaQuery.of(context).size.width * 0.26,
                                            color: const Color.fromARGB(0, 76, 175, 79), // Promijenite boju prema potrebi
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.arrow_back, color: Colors.white),
                                                  onPressed: listaSlika.isNotEmpty && currentIndex > 0
                                                      ? () {
                                                          setState(() {
                                                            currentIndex--;
                                                          });
                                                        }
                                                      : null,
                                                ),
                                                SizedBox(width: 16), // Razmak između dugmadi
                                                IconButton(
                                                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                                                  onPressed: listaSlika.isNotEmpty && currentIndex < listaSlika.length - 1
                                                      ? () {
                                                          setState(() {
                                                            currentIndex++;
                                                          });
                                                        }
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.33,
                                      width: MediaQuery.of(context).size.width * 0.08,
                                      color: const Color.fromARGB(0, 255, 153, 0), // Promijenite boju prema potrebi
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              final ImagePicker _picker = ImagePicker();
                                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                                              if (image != null) {
                                                final bytes = await File(image.path).readAsBytes();
                                                final base64Image = base64Encode(bytes);
                                                setState(() {
                                                  listaSlika.add(base64Image);
                                                  currentIndex = listaSlika.length - 1;
                                                });

                                                print("Slika dodana u listu!");
                                              } else {
                                                print("Nijedna slika nije odabrana.");
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(255, 242, 242, 242),
                                              minimumSize: Size(
                                                MediaQuery.of(context).size.width * 0.08,
                                                36,
                                              ),
                                            ),
                                            child: Text(
                                              'Dodaj',
                                              style: TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                          if (listaSlika.isNotEmpty) ...[
                                            SizedBox(height: 16), // Razmak između dugmadi
                                            ElevatedButton(
                                              onPressed: () {
                                                if (listaSlika.isNotEmpty && currentIndex >= 0 && currentIndex < listaSlika.length) {
                                                  setState(() {
                                                    listaSlika.removeAt(currentIndex);
                                                    if (currentIndex > 0) {
                                                      currentIndex--;
                                                    }
                                                  });
                                                  print("Slika obrisana iz liste!");
                                                } else {
                                                  print("Nema slika za obrisati.");
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                minimumSize: Size(
                                                  MediaQuery.of(context).size.width * 0.08,
                                                  36,
                                                ),
                                              ),
                                              child: Text(
                                                'Obrisi',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                      width: MediaQuery.of(context).size.width * 0.34,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showFirstSlider = true;
                              });
                            },
                            child: Container(
                              height: showFirstSlider ? MediaQuery.of(context).size.height * 0.015 : MediaQuery.of(context).size.height * 0.013,
                              width: showFirstSlider ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.width * 0.03,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 82, 205, 210),
                                    Color.fromARGB(255, 7, 161, 235),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showFirstSlider = false;
                              });
                            },
                            child: Container(
                              height: !showFirstSlider ? MediaQuery.of(context).size.height * 0.015 : MediaQuery.of(context).size.height * 0.013,
                              width: !showFirstSlider ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.width * 0.03,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 82, 205, 210),
                                    Color.fromARGB(255, 7, 161, 235),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Dugmici edit
              Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.34,
                color: const Color.fromARGB(0, 33, 149, 243),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: showFirstSlider
                        ? ElevatedButton(
                            key: ValueKey(1),
                            onPressed: () {
                              editBicikl();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 87, 202, 255),
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.08,
                                36,
                              ),
                            ),
                            child: Text(
                              'Edit podatci',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            key: ValueKey(2),
                            onPressed: () {
                              editSlike();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 87, 202, 255),
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.08,
                                36,
                              ),
                            ),
                            child: Text(
                              'Edit slike',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  String nazivNovog = "";
  String CijenaNovog = "";
  String KolicinaNovog = "";
  String brojBrzinaNovog = "";
  String VelicinaRamaNovog = "";
  String VelicinaTockaNovog = "";
  int? selectedKategorijaId;

  editBicikl() async {
    if (nazivNovog.isEmpty &&
        CijenaNovog.isEmpty &&
        KolicinaNovog.isEmpty &&
        brojBrzinaNovog.isEmpty &&
        VelicinaRamaNovog.isEmpty &&
        VelicinaTockaNovog.isEmpty &&
        (selectedKategorijaId == 0 || selectedKategorijaId == null)) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je promjenuti barem jednu vrijednost");
      return;
    }
    selectedKategorijaId ??= 0;
    if (CijenaNovog.isEmpty) {
      CijenaNovog = '0';
    } else if (!isNumeric(CijenaNovog)) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Cijena mora biti numerička vrijednost");
      return;
    }

    if (KolicinaNovog.isEmpty) {
      KolicinaNovog = '0';
    } else if (!isNumeric(KolicinaNovog)) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Količina mora biti numerička vrijednost");
      return;
    }

    if (brojBrzinaNovog.isEmpty) {
      brojBrzinaNovog = '0';
    } else if (!isNumeric(brojBrzinaNovog)) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Broj brzina mora biti numerička vrijednost");
      return;
    }
    int cijena = double.parse(CijenaNovog).toInt();

    int kolicina = double.parse(KolicinaNovog).toInt();
    int brojBrzina = double.parse(brojBrzinaNovog).toInt();

    var rezultat = await biciklService.putBicikl(widget.biciklId, nazivNovog, cijena, VelicinaRamaNovog, VelicinaTockaNovog, brojBrzina,
        selectedKategorijaId!, prijavljeniKorisnikID, kolicina);

    if (rezultat != null) {
      PorukaHelper.prikaziPorukuUspjeha(context, "Bicikl je uspješno ažuriran.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PocetniProzor()),
      );
    } else {
      PorukaHelper.prikaziPorukuGreske(context, "Dogodila se greška prilikom ažuriranja bicikla.");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PocetniProzor()),
      );
    }
  }

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> editSlike() async {
    bool uspjeh = true;

    if (listaSlika.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati barem jednu sliku");
      return;
    }

    if (listaIdiova.isEmpty) {
      for (var slika in listaSlika) {
        final rezultat = await slikeBicikliService.postBiciklSlika(widget.biciklId, slika);
        if (rezultat == null) {
          uspjeh = false;
          break;
        }
      }
    } else {
      if (listaIdiova.length == listaSlika.length) {
        for (int i = 0; i < listaIdiova.length; i++) {
          final rezultat = await slikeBicikliService.putBiciklSlika(widget.biciklId, listaIdiova[i], listaSlika[i]);
          if (rezultat == null) {
            uspjeh = false;
            break;
          }
        }
      } else if (listaIdiova.length > listaSlika.length) {
        for (int i = 0; i < listaSlika.length; i++) {
          final rezultat = await slikeBicikliService.putBiciklSlika(widget.biciklId, listaIdiova[i], listaSlika[i]);
          if (rezultat == null) {
            uspjeh = false;
            break;
          }
        }
        for (int i = listaSlika.length; i < listaIdiova.length; i++) {
          final rezultat = await slikeBicikliService.deleteBiciklSlika(listaIdiova[i]);
          if (rezultat == null) {
            uspjeh = false;
            break;
          }
        }
      } else if (listaIdiova.length < listaSlika.length) {
        for (int i = 0; i < listaIdiova.length; i++) {
          final rezultat = await slikeBicikliService.putBiciklSlika(widget.biciklId, listaIdiova[i], listaSlika[i]);
          if (rezultat == null) {
            uspjeh = false;
            break;
          }
        }
        for (int i = listaIdiova.length; i < listaSlika.length; i++) {
          final rezultat = await slikeBicikliService.postBiciklSlika(widget.biciklId, listaSlika[i]);
          if (rezultat == null) {
            uspjeh = false;
            break;
          }
        }
      }
    }

    if (uspjeh) {
      PorukaHelper.prikaziPorukuUspjeha(context, "Slike su uspješno ažurirane.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PocetniProzor()),
      );
    } else {
      PorukaHelper.prikaziPorukuGreske(context, "Dogodila se greška prilikom ažuriranja slika.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PocetniProzor()),
      );
    }
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
          value is Widget
              ? value
              : Text(
                  '$value',
                  style: const TextStyle(color: Colors.white),
                ),
        ],
      ),
    );
  }
}
