// ignore_for_file: unnecessary_null_comparison
// ignore: unused_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:bikehub_desktop/modeli/dijelovi/dijelovi_model.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/dijelovi/slike_dijelovi_service.dart';
import 'package:bikehub_desktop/services/kategorije/kategorija_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DijeloviDodajProzor  extends StatefulWidget {
  const DijeloviDodajProzor ({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DijeloviDodajProzorState createState() => _DijeloviDodajProzorState();
}

class _DijeloviDodajProzorState extends State<DijeloviDodajProzor > {  
  final KorisnikService korisnikService = KorisnikService();
  final KategorijaServis kategorijaServis = KategorijaServis();
  final DijeloviService dijeloviService = DijeloviService();
  final SlikeDijeloviService slikeDijeloviService = SlikeDijeloviService();

  int? selectedKategorijaId;
  int? kategorijaId;
  final TextEditingController nazivController = TextEditingController();
  final TextEditingController opisController = TextEditingController();
  final TextEditingController cijenaController = TextEditingController();
  final TextEditingController kolicinaController = TextEditingController();

  late Dijelovi dijeloviFinal;


  List<Uint8List> slikeDijelovi = [];  // Lista slika
  int currentIndex = 0; 
  void nextImage() {
    setState(() {
      if (currentIndex < slikeDijelovi.length - 1) {
        currentIndex++;
      }
    });
  }

  void previousImage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void dodajSliku(Uint8List slika) {
    setState(() {
      slikeDijelovi.add(slika);
      currentIndex = slikeDijelovi.length - 1;  
    });
  }


  void ukloniSliku(int index) {
    setState(() {
      if (slikeDijelovi.isNotEmpty && index >= 0 && index < slikeDijelovi.length) {
        
        slikeDijelovi.removeAt(index);

        
        if (slikeDijelovi.isEmpty) {
          currentIndex = 0;
        } else {          
          if (currentIndex >= slikeDijelovi.length) {
            currentIndex = slikeDijelovi.length - 1;
          }
        }
      }
    });
  }



  Future<void> odaberiSliku() async {
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
    opisController.dispose();
    cijenaController.dispose();
    kolicinaController.dispose();
    super.dispose();
  }

  Future<void> postDijelovi() async {
    
    if (dijeloviFinal.kategorijaId == null || dijeloviFinal.cijena<=0
     || dijeloviFinal.kategorijaId<=0 || dijeloviFinal.kolicina<=0 
     || dijeloviFinal.korisnikId<=0 || dijeloviFinal.opis.isEmpty
     || dijeloviFinal.naziv.isEmpty) {
      // ignore: use_build_context_synchronously
      PorukaHelper.prikaziPorukuGreske(context, "Nedostaju obavezni podaci.");
      return;
    }


    try {
      final dijeloviResponse = await dijeloviService.postDijelovi(dijeloviFinal);

      if (dijeloviResponse != null) {
        final int dijeloviId = dijeloviResponse['dijeloviId'];

        for (var slika in slikeDijelovi) {
          final slikaBase64 = base64Encode(slika);
          await slikeDijeloviService.postDijeloviSlika(dijeloviId, slikaBase64);
        }
        setState(() {
          kategorijaId = null;
          nazivController.clear();
          opisController.clear();
          cijenaController.clear();
          kolicinaController.clear();
          slikeDijelovi.clear();
          currentIndex = 0;          
        });
        // ignore: use_build_context_synchronously
        PorukaHelper.prikaziPorukuUspjeha(context, "Uspjesno dodati dijelovi");
      } else {
        // ignore: use_build_context_synchronously
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri dodavanju dijelova.");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
    }
  }

  void saveBicikl() async {

    final naziv = nazivController.text;
    final opis = opisController.text;
    final cijena = double.tryParse(cijenaController.text) ?? 0.0;
    final kolicina = int.tryParse(kolicinaController.text) ?? 0;

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
    if (slikeDijelovi.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati barem jednu sliku");
      return;
    }
    if(slikeDijelovi.length>8){      
      PorukaHelper.prikaziPorukuUpozorenja(context, "Moguce je dodati maximalno 8 slika");
      return;
    }
    if (opis.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Opis ne može biti prazan");
      return;
    }
    if (selectedKategorijaId == 0 || selectedKategorijaId == null) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je odabrati kategoriju");
      return;
    }
    final korisnikInfo = await korisnikService.getUserInfo();
    final korisnikId = int.parse(korisnikInfo['korisnikId'] ?? '0');
    // ignore: unused_local_variable
    Dijelovi dijelovi = Dijelovi(
      dijeloviId: 0,
      ak: 0,
      stanje: "",
      naziv: naziv,
      cijena: cijena,
      opis: opis,
      kategorijaId: selectedKategorijaId ?? 1,
      kolicina: kolicina,
      korisnikId: korisnikId, // Dodajte odgovarajući korisnik ID
    );
    dijeloviFinal=dijelovi;
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return _confirmationDialog(dijelovi);
      },
    );

  }

  @override
  void initState() {
    super.initState();
    kategorijaServis.getDijeloviKategorije();
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
              title: const Text("Dodaj Dijelove"),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            // Glavni deo ekrana
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
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
                                padding: const EdgeInsets.all(30.0), 
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
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
                                  padding: const EdgeInsets.all(8.0), 
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, 
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    Container(
                                      margin:  EdgeInsets.only(left:  0.05 * MediaQuery.of(context).size.width, right:  0.05 * MediaQuery.of(context).size.width),
                                      child: TextField(
                                        controller: opisController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 5, 
                                        minLines: 3, 
                                        decoration: const InputDecoration(
                                          labelText: "Opis",
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
                                    ),   
                                    const SizedBox(height: 40), 
                                    Container(
                                      padding: const EdgeInsets.all(8.0), 
                                      margin:  EdgeInsets.only(left:  0.05 * MediaQuery.of(context).size.width, right:  0.05 * MediaQuery.of(context).size.width),
                                      decoration: BoxDecoration(
                                        color: Colors.white, 
                                        borderRadius: BorderRadius.circular(8.0), 
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Kategorija",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: SizedBox(
                                              width: 0.1 * MediaQuery.of(context).size.width,
                                              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                                valueListenable: kategorijaServis.lista_ucitanih_d_kategorija,
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
                          child: Center( 
                            child: ElevatedButton(
                              onPressed: saveBicikl,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), 
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
  
  Widget _confirmationDialog(Dijelovi bicikl) {
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
            height: MediaQuery.of(context).size.height * 0.08, 
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
            flex: 8, 
            child: Row(
              children: [
                // 2.D.1P
                Expanded(
                  flex: 5, 
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
                        _buildDetailContainer('Kategorija ID', bicikl.kategorijaId),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Količina', bicikl.kolicina),
                        const SizedBox(height: 20.0),
                        _buildDetailContainer('Opis', bicikl.opis),
                      ],
                    ),
                  ),
                ),
                
                // 2.D.2P
                Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.only(top: 70.0), 
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
                      crossAxisCount: 4, 
                      mainAxisSpacing: 30.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1, 
                    ),
                    itemCount: slikeDijelovi.length > 8 ? 8 : slikeDijelovi.length, 
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), 
                        child: Image.memory(
                          slikeDijelovi[index],
                          fit: BoxFit.cover, 
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
            height: MediaQuery.of(context).size.height * 0.08,
            color: const Color.fromARGB(0, 155, 39, 176), 
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
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
                    postDijelovi();
                    Navigator.of(context).pop(); 
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
          child: slikeDijelovi.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.memory(
                    slikeDijelovi[currentIndex],
                    fit: BoxFit.contain, 
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
            width: 0.10* MediaQuery.of(context).size.width, 
            child: ElevatedButton(
              onPressed: () {
                odaberiSliku(); 
              },
              child: const Text("Dodaj novu"),
            ),
          ),
          SizedBox(
            width: 0.10* MediaQuery.of(context).size.width, 
            child: ElevatedButton(
              onPressed: () {
                if (slikeDijelovi.isNotEmpty) {
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
