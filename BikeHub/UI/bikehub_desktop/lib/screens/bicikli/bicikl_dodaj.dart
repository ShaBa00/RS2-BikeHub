// ignore_for_file: unnecessary_null_comparison
// ignore: unused_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:bikehub_desktop/modeli/bicikli/bicikl_model.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'package:bikehub_desktop/services/bicikli/slike_bicikl_service.dart';
import 'package:bikehub_desktop/services/kategorije/kategorija_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BiciklDodajProzor extends StatefulWidget {
  const BiciklDodajProzor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BiciklDodajProzorState createState() => _BiciklDodajProzorState();
}

class _BiciklDodajProzorState extends State<BiciklDodajProzor> {  
  final KorisnikService korisnikService = KorisnikService();
  final KategorijaServis kategorijaServis = KategorijaServis();
  final BiciklService biciklService = BiciklService();
  final SlikeBicikliService slikeBicikliService = SlikeBicikliService();

  int? selectedKategorijaId;
  int? kategorijaId;
  String? selectedVelicinaRama;
  String? selectedVelicinaTocka;
  final TextEditingController nazivController = TextEditingController();
  final TextEditingController cijenaController = TextEditingController();
  final TextEditingController kolicinaController = TextEditingController();
  final TextEditingController brojBrzinaController = TextEditingController();

  List<Uint8List> slikeBicikli = [];  // Lista slika
  int currentIndex = 0; 

  late Bicikl biciklFinal;
  // Funkcija za prelazak na sledeću sliku
  void nextImage() {
    setState(() {
      if (currentIndex < slikeBicikli.length - 1) {
        currentIndex++;
      }
    });
  }

  // Funkcija za prelazak na prethodnu sliku
  void previousImage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void dodajSliku(Uint8List slika) {
    setState(() {
      slikeBicikli.add(slika);
      currentIndex = slikeBicikli.length - 1;  // Pomeriti indeks na poslednju dodanu sliku
    });
  }

  // Uklanjanje slike sa određenog indeksa
  void ukloniSliku(int index) {
    setState(() {
      if (slikeBicikli.isNotEmpty && index >= 0 && index < slikeBicikli.length) {
        // Prvo ukloni sliku sa željenog indeksa
        slikeBicikli.removeAt(index);

        // Ako je lista sada prazna, resetuj currentIndex na 0
        if (slikeBicikli.isEmpty) {
          currentIndex = 0;
        } else {
          // Ako je trenutni indeks veći od nove duzine liste, postavi ga na poslednji validni indeks
          if (currentIndex >= slikeBicikli.length) {
            currentIndex = slikeBicikli.length - 1;
          }
        }
      }
    });
  }



  // Odabir nove slike putem FilePicker
  Future<void> odaberiSliku() async {
    // Otvoriti dijalog za odabir slike
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      Uint8List slikaBytes = await file.readAsBytes();
      dodajSliku(slikaBytes);      
    }
  }


  @override
  void dispose() {
    nazivController.dispose();
    cijenaController.dispose();
    kolicinaController.dispose();
    brojBrzinaController.dispose();
    super.dispose();
  }

  Future<void> postBicikl() async {
    // Validacija podataka
    if (biciklFinal.kategorijaId == null || biciklFinal.velicinaRama == null
     || biciklFinal.velicinaTocka == null || biciklFinal.brojBrzina<= 0 || biciklFinal.cijena<=0
     || biciklFinal.kategorijaId<=0 || biciklFinal.kolicina<=0 || biciklFinal.korisnikId<=0
     || biciklFinal.naziv.isEmpty) {
      //logger.e('Nedostaju obavezni podaci.');
      return;
    }


    try {
      final biciklResponse = await biciklService.postBicikl(biciklFinal);

      if (biciklResponse != null) {
        final int biciklId = biciklResponse['biciklId'];

        for (var slika in slikeBicikli) {
          final slikaBase64 = base64Encode(slika);
          await slikeBicikliService.postBiciklSlika(biciklId, slikaBase64);
        }
        setState(() {
          kategorijaId = null;
          selectedVelicinaRama = null;
          selectedVelicinaTocka = null;
          nazivController.clear();
          cijenaController.clear();
          kolicinaController.clear();
          brojBrzinaController.clear();
          slikeBicikli.clear();
          currentIndex = 0;          
        });
        // ignore: use_build_context_synchronously
        PorukaHelper.prikaziPorukuUspjeha(context, "Uspjesno dodat bicikl");
      } else {
        // ignore: use_build_context_synchronously
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri dodavanju bicikla.");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
    }
  }

  void saveBicikl() async {

    final naziv = nazivController.text;
    final cijena = double.tryParse(cijenaController.text) ?? 0.0;
    final kolicina = int.tryParse(kolicinaController.text) ?? 0;
    final brojBrzina = int.tryParse(brojBrzinaController.text) ?? 0;

    if (naziv.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Naziv ne može biti prazan");
      return;
    }
    if (cijena == null || cijena <= 0) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Cijena mora biti numerickog tipa");
      return;
    }
    if (kolicina == null || kolicina <= 0) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Količina mora biti veća od nule");
      return;
    }
    if (brojBrzina == null || brojBrzina <= 0) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Broj brzina mora biti veći od nule");
      return;
    }
    if (slikeBicikli.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati barem jednu sliku");
      return;
    }
    if(slikeBicikli.length>8){      
      PorukaHelper.prikaziPorukuUpozorenja(context, "Moguce je dodati maximalno 8 slika");
      return;
    }
    if (selectedVelicinaRama==null) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je odabrati veličinu rama");
      return;
    }
    if (selectedVelicinaTocka==null) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je odabrati veličinu točka");
      return;
    }
    if (selectedKategorijaId == 0 || selectedKategorijaId == null) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je odabrati kategoriju");
      return;
    }
    final korisnikInfo = await korisnikService.getUserInfo();
    final korisnikId = int.parse(korisnikInfo['korisnikId'] ?? '0');
    // ignore: unused_local_variable
    Bicikl bicikl = Bicikl(
      naziv: naziv,
      cijena: cijena,
      velicinaRama: selectedVelicinaRama ?? "M", 
      velicinaTocka: selectedVelicinaTocka ?? "26",
      brojBrzina: brojBrzina,
      kategorijaId: selectedKategorijaId ?? 1,
      kolicina: kolicina,
      korisnikId: korisnikId, // Dodajte odgovarajući korisnik ID
    );
    biciklFinal=bicikl;
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return _confirmationDialog(bicikl);
      },
    );

  }

  @override
  void initState() {
    super.initState();
    kategorijaServis.getBikeKategorije();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pozadina celog ekrana sa gradijentom
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
        child: Column(
          children: [
            // AppBar sa providnom pozadinom
            AppBar(
              title: const Text("Dodaj Bicikl"),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            // Glavni deo ekrana
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                // Glavni deo je providan, pozadina se vidi kroz njega
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    // Uneseni podatci imaju tamniju pozadinu
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // 1D: "Osnovni podatci"
                        Container(
                          height: 0.10 * MediaQuery.of(context).size.height,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Osnovni podatci",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        // 2D: Gradijent pozadina i kartice
                        Container(
                          height: 0.69 * MediaQuery.of(context).size.height,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 255, 255),
                                Color.fromARGB(255, 188, 188, 188),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Kartica 1
                              Container(
                                height: 0.8 * (0.75 * MediaQuery.of(context).size.height),
                                width: 0.3 * MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child:  Padding(
                                padding: const EdgeInsets.all(30.0),  // Razmak unutar kontejnera
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ravnomeran razmak između inputa
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Input za naziv
                                    TextField(
                                      controller: nazivController,
                                      decoration: const InputDecoration(
                                        labelText: "Naziv",
                                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                    // Input za cijenu
                                    TextField(
                                      controller:cijenaController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Cijena",
                                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                    // Input za kolicinu
                                     TextField(
                                      controller: kolicinaController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Kolicina",
                                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                    // Input za broj brzina
                                     TextField(
                                      controller: brojBrzinaController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(                                      
                                        labelText: "Broj brzina",
                                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ),
                              // Kartica 2
                              Container(
                                height: 0.8 * (0.75 * MediaQuery.of(context).size.height),
                                width: 0.3 * MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: dodavanjeSlika(context),
                              ),
                              // Kartica 3
                              Container(
                                height: 0.8 * (0.75 * MediaQuery.of(context).size.height),
                                width: 0.3 * MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0), // Razmak unutar kartice
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Centriranje elemenata
                                    crossAxisAlignment: CrossAxisAlignment.start, // Poravnavanje sa leve strane
                                  children: [
                                    // 1. Red - "Velicina rama" i dropdown
                                    Container(
                                      padding: const EdgeInsets.all(8.0), // Padding oko celog reda
                                      margin:  EdgeInsets.only(left:  0.05 * MediaQuery.of(context).size.width, right:  0.05 * MediaQuery.of(context).size.width),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Bijela pozadina
                                        borderRadius: BorderRadius.circular(8.0), // Zaobljeni okviri
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Velicina rama",
                                            style: TextStyle(color: Colors.black), // Crni tekst
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: SizedBox(
                                              width: 0.05 * MediaQuery.of(context).size.width,
                                              child: DropdownButton<String>(
                                                hint: const Text(""),
                                                isExpanded: true,
                                                value: selectedVelicinaRama, // Poveži sa varijablom
                                                items: const [
                                                  DropdownMenuItem(value: "XS", child: Text("XS")),
                                                  DropdownMenuItem(value: "S", child: Text("S")),
                                                  DropdownMenuItem(value: "M", child: Text("M")),
                                                  DropdownMenuItem(value: "L", child: Text("L")),
                                                  DropdownMenuItem(value: "XL", child: Text("XL")),
                                                  DropdownMenuItem(value: "XXL", child: Text("XXL")),
                                                ],
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    selectedVelicinaRama = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 40), // Smanjen razmak između redova

                                    // 2. Red - "Velicina tocka" i dropdown
                                    Container(
                                      padding: const EdgeInsets.all(8.0), // Padding oko celog reda
                                      margin:  EdgeInsets.only(left:  0.05 * MediaQuery.of(context).size.width, right:  0.05 * MediaQuery.of(context).size.width),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Bijela pozadina
                                        borderRadius: BorderRadius.circular(8.0), // Zaobljeni okviri
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Velicina tocka",
                                            style: TextStyle(color: Colors.black), // Crni tekst
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: SizedBox(
                                              width: 0.05 * MediaQuery.of(context).size.width,
                                              child: DropdownButton<String>(
                                                hint: const Text(""),
                                                isExpanded: true,
                                                value: selectedVelicinaTocka, // Poveži sa varijablom
                                                items: const [
                                                  DropdownMenuItem(value: "12", child: Text("12")),
                                                  DropdownMenuItem(value: "14", child: Text("14")),
                                                  DropdownMenuItem(value: "16", child: Text("16")),
                                                  DropdownMenuItem(value: "20", child: Text("20")),
                                                  DropdownMenuItem(value: "24", child: Text("24")),
                                                  DropdownMenuItem(value: "26", child: Text("26")),
                                                  DropdownMenuItem(value: "27.5", child: Text("27.5")),
                                                  DropdownMenuItem(value: "28", child: Text("28")),
                                                  DropdownMenuItem(value: "29", child: Text("29")),
                                                ],
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    selectedVelicinaTocka = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 40), // Smanjen razmak između redova

                                    // 3. Red - "Kategorija" i dropdown
                                    Container(
                                      padding: const EdgeInsets.all(8.0), // Padding oko celog reda
                                      margin:  EdgeInsets.only(left:  0.05 * MediaQuery.of(context).size.width, right:  0.05 * MediaQuery.of(context).size.width),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Bijela pozadina
                                        borderRadius: BorderRadius.circular(8.0), // Zaobljeni okviri
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Kategorija",
                                            style: TextStyle(color: Colors.black), // Crni tekst
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: SizedBox(
                                              width: 0.1 * MediaQuery.of(context).size.width,
                                              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                                valueListenable: kategorijaServis.lista_ucitanih_kategorija,
                                                builder: (context, kategorije, _) {
                                                  return InputDecorator(
                                                    decoration: const InputDecoration(
                                                      labelText: '',
                                                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                                      filled: true,
                                                      fillColor: Color.fromARGB(255, 252, 252, 252),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                                      ),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<int?>(
                                                        value: selectedKategorijaId, // Poveži sa varijablom
                                                        hint: const Text("Sve Kategorije", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                                                        isExpanded: true,
                                                        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                                                        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                                        items: [
                                                          const DropdownMenuItem<int?>(value: null, child: Text("Sve Kategorije")),
                                                          ...kategorije.map((kategorija) {
                                                            return DropdownMenuItem<int>(
                                                              value: kategorija['kategorijaId'],
                                                              child: Text(kategorija['naziv']),
                                                            );
                                                          }),
                                                        ],
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            selectedKategorijaId = newValue;
                                                          });
                                                        },
                                                      ),
                                                    ),
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
                                ),
                              )
                            ],
                          ),
                        ),
                        // 3D: "3D"
                        Container(
                          height: 0.08 * MediaQuery.of(context).size.height,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center( // Ovdje centriramo sadržaj
                            child: ElevatedButton(
                              onPressed: saveBicikl,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Pozadinska boja dugmeta
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Zaobljeni rubovi dugmeta
                                ),
                              ),
                              child: const Text(
                                "Dodaj",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _confirmationDialog(Bicikl bicikl) {
  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 54, 180, 184),
                Color.fromARGB(255, 4, 134, 189),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      ),
      child: Column(
        children: [
          // 1.Dio
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.08, // 10% visine widgeta
            color: const Color.fromARGB(0, 33, 149, 243), 
            alignment: Alignment.center,
            child: const Text(
              "Pregled unesenih podataka",
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 2.Dio
          Expanded(
            flex: 8, // 80% visine widgeta
            child: Row(
              children: [
                // 2.D.1P
                Expanded(
                  flex: 5, // 50% širine 2.Dio
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDetailContainer('Naziv', bicikl.naziv),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Cijena', bicikl.cijena),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Veličina Rama', bicikl.velicinaRama),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Veličina Točka', bicikl.velicinaTocka),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Broj Brzina', bicikl.brojBrzina),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Kategorija ID', bicikl.kategorijaId),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Količina', bicikl.kolicina),
                      ],
                    ),
                  ),
                ),
                
                // 2.D.2P
                Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.only(top: 70.0), // Ovdje postavite željeni razmak od gornje ivice
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                      bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                      right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Broj slika u redu (4 slike po redu)
                      mainAxisSpacing: 30.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1, // Omjer širine i visine (kvadratne slike)
                    ),
                    itemCount: slikeBicikli.length > 8 ? 8 : slikeBicikli.length, // Maksimalno 8 slika
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), // Zaobljene ivice
                        child: Image.memory(
                          slikeBicikli[index],
                          fit: BoxFit.cover, // Popunjava cijeli prostor unutar grid elementa
                        ),
                      );
                    },
                  ),
                ),
              ),
              ],
            ),
          ),
          
          // 3.Dio
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.08, // 10% visine widgeta
            color: const Color.fromARGB(0, 155, 39, 176), // Boja za 3.Dio
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Zatvori dijalog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Nazad", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    postBicikl();
                    Navigator.of(context).pop(); // Zatvori dijalog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Potvrdi", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  
  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.20,
      decoration: BoxDecoration(        
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget dodavanjeSlika(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Section 1 - 
        Container(
          height: 0.7 * (0.8 * (0.75 * MediaQuery.of(context).size.height)),
          width: 0.9 * MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: slikeBicikli.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice slike
                  child: Image.memory(
                    slikeBicikli[currentIndex],
                    fit: BoxFit.contain, // Smanjuje sliku tako da ostane unutar granica
                  ),
                )
              : const Text(
                  "No image selected",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
        ) ,      
        // Section 2 - Dugmici za listanje slika
        Container(
          height: 0.15 * (0.8 * (0.75 * MediaQuery.of(context).size.height)),
          width: 0.9 * MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: previousImage,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: nextImage,
              ),
            ],
          ),
        ),        
        // Section 3 - Dugmici za dodavanje i uklanjanje slika
        Container(
          height: 0.15 * (0.8 * (0.75 * MediaQuery.of(context).size.height)),
          width: 0.9 * MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
          SizedBox(
            width: 0.10* MediaQuery.of(context).size.width, // Postavi željenu širinu dugmadi
            child: ElevatedButton(
              onPressed: () {
                odaberiSliku(); // Otvoriti prozor za odabir slike
              },
              child: const Text("Dodaj novu"),
            ),
          ),
          SizedBox(
            width: 0.10* MediaQuery.of(context).size.width, 
            child: ElevatedButton(
              onPressed: () {
                if (slikeBicikli.isNotEmpty) {
                  ukloniSliku(currentIndex); 
                }
              },
              child: const Text("Ukloni"),
            ),
          ),
        ],
          ),
        ),
      ],
    );
  }
}
