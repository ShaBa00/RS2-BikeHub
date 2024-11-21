// ignore_for_file: sort_child_properties_last, use_build_context_synchronously



import 'package:bikehub_desktop/modeli/korisnik/korisnik_model.dart';
import 'package:bikehub_desktop/screens/korisnik/korisnik_proizvodi_prikaz.dart';
import 'package:bikehub_desktop/screens/korisnik/rezervacije_korisnika.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/screens/prijava/log_in_prozor.dart';
import 'package:bikehub_desktop/screens/serviser/serviser_profil.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_info_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/screens/administracija/administracija_p1_prozor.dart';
import 'package:flutter/material.dart';

class ProfilProzor extends StatefulWidget {
  final int korisnikId;
  const ProfilProzor({super.key, required this.korisnikId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilProzorState createState() => _ProfilProzorState();
}
class _ProfilProzorState extends State<ProfilProzor> {
  final KorisnikService korisnikService = KorisnikService();
  final KorisnikInfoService korisnikInfoService = KorisnikInfoService();
  Map<String, dynamic>? korisnik;

  KorisnikModel korisnikNoviPodatci = KorisnikModel(korisnikId: 0, username: "", staraLozinka: "", lozinka: "", lozinkaPotvrda: "", email: "", stanje: "", ak: 0);
  
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController imePrezimeController = TextEditingController();
  TextEditingController telefonController = TextEditingController();
  TextEditingController staraLozinkaController = TextEditingController();
  TextEditingController novaLozinkaController = TextEditingController();
  TextEditingController lozinkaPotvrdaController = TextEditingController();

  bool showUrediProzo = false;
  bool changePassword = false;

  void disposeInfo() {
    usernameController=TextEditingController();
    emailController=TextEditingController();
    imePrezimeController=TextEditingController();
    telefonController=TextEditingController();
    staraLozinkaController=TextEditingController();
    novaLozinkaController=TextEditingController();
    lozinkaPotvrdaController=TextEditingController();
  }

  void updateKorisnikZapis() async {
    changePassword=false;
    var imePrezime=imePrezimeController.text;
    var telefon=telefonController.text;
    if (korisnikNoviPodatci.username.isEmpty && korisnikNoviPodatci.email.isEmpty &&
        korisnikNoviPodatci.lozinka.isEmpty && korisnikNoviPodatci.lozinkaPotvrda.isEmpty &&
        korisnikNoviPodatci.staraLozinka.isEmpty && telefon.isEmpty
        && imePrezime.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je uneti neki od podataka");
      return;
    }
    if ((korisnikNoviPodatci.staraLozinka.isNotEmpty || korisnikNoviPodatci.lozinka.isNotEmpty || korisnikNoviPodatci.lozinkaPotvrda.isNotEmpty) &&
        (!korisnikNoviPodatci.staraLozinka.isNotEmpty || !korisnikNoviPodatci.lozinka.isNotEmpty || !korisnikNoviPodatci.lozinkaPotvrda.isNotEmpty)) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Za promenu lozinke potrebno je uneti staru lozinku, novu lozinku i potvrdu.");
      return;
    }
    if (korisnikNoviPodatci.lozinka != korisnikNoviPodatci.lozinkaPotvrda) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Nova lozinka i potvrda lozinke moraju biti iste");
      return;
    }
    if(korisnikNoviPodatci.lozinka.isNotEmpty && korisnikNoviPodatci.lozinkaPotvrda.isNotEmpty && 
    korisnikNoviPodatci.staraLozinka.isNotEmpty){
      changePassword=true;
    }
    if (korisnikNoviPodatci.username == korisnik?['username']) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Novi username mora biti drugačiji od starog");
      return;
    }
    if (korisnikNoviPodatci.email == korisnik?['email']) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Novi email mora biti drugačiji od starog");
      return;
    }

    
      if (korisnikNoviPodatci.username.isNotEmpty || korisnikNoviPodatci.email.isNotEmpty || changePassword==true) {
      try {
        await korisnikService.upravljanjeKorisnikom(korisnikNoviPodatci);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspešno ažuriran");
        if(korisnikNoviPodatci.username.isNotEmpty || changePassword==true){
          await korisnikService.logout();
          PorukaHelper.prikaziPorukuUspjeha(context, "Uspešno promenjen username ili password, potrebno je da se ponovo prijavite.");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogInProzor(onLogin: () {
                _fetchKorisnik();
              }),
            ),
          );
        }
        await _fetchKorisnik();
        disposeInfo();
        sakrijUrediProzo();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
      }
    }
      
    var korisnikInfos=await korisnikInfoService.getKorisnikInfos(korisnikId:  widget.korisnikId);
    int korisnikInfoId=0;
    if(korisnikInfos.isNotEmpty){
      korisnikInfoId = korisnikInfos[0]['korisnikInfoId'];
    }
    if((imePrezime.isNotEmpty || telefon.isNotEmpty) && korisnikInfoId!=0){

       try {
        await korisnikInfoService.updateInfo(korisnikInfoId, imePrezime, telefon);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspešno ažuriran");
        await _fetchKorisnik();
        disposeInfo();
        sakrijUrediProzo();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
      }
    }
  }

  

  void updateKorisnikModel() {
    setState(() {
      korisnikNoviPodatci = KorisnikModel(
        korisnikId: widget.korisnikId,
        username: usernameController.text,
        staraLozinka: staraLozinkaController.text,
        lozinka: novaLozinkaController.text,
        lozinkaPotvrda: lozinkaPotvrdaController.text,
        email: emailController.text,
        stanje: korisnikNoviPodatci.stanje,
        ak: korisnikNoviPodatci.ak,
      );
    });
  }

  void uredi() {
    PorukaHelper.prikaziPorukuUpozorenja(context, "Moguce je promjenuti samo Username ili Email, a ukoliko mijenjate lozinku potrebno je poslati Novu lozinku, staru lozinku i potvrdu lozinke");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: urediProzo(context),
        );
      },
    );
  }

  void sakrijUrediProzo() {
    Navigator.of(context).pop();
  }

  void obrisi() async {
    if (widget.korisnikId == 0) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Problem prilikom dohvacanja vašeg ID-a");
      return;
    }
    KorisnikModel korisnikZaBrisanje = KorisnikModel(
      korisnikId: widget.korisnikId,
      username: '',
      staraLozinka: '',
      lozinka: '',
      lozinkaPotvrda: '',
      email: '',
      stanje: 'obrisan',
      ak: 1,
    );

    try {
      await korisnikService.upravljanjeKorisnikom(korisnikZaBrisanje);
      PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspješno obrisan.");
      _fetchKorisnik();
    } catch (e) {
      PorukaHelper.prikaziPorukuGreske(context, "Greška pri brisanju korisnika: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchKorisnik();
  }

  Future<void> _fetchKorisnik() async {
    korisnik = await korisnikService.getKorisnikByID(widget.korisnikId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (korisnik == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil'),backgroundColor: const Color.fromARGB(255, 92, 225, 230),),
        body: const Center(
          child: CircularProgressIndicator(), // Prikazuje se dok se podaci učitavaju
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),        
        backgroundColor: const Color.fromARGB(255, 92, 225, 230),
      ),
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
            width: screenWidth * 0.75,
            height: screenHeight * 0.7,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 82, 205, 210),
                  Color.fromARGB(255, 7, 161, 235),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // 1. red 
                Container(
                  height: screenHeight * 0.65 * 0.2,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: korisnik != null
                      ? _buildDetailContainer("Username", korisnik!['username'])
                      : const CircularProgressIndicator(), 
                ),
                // 2. red 
                Expanded(
                  child: Column(
                    children: [
                      // 1. red drugog reda 
                      // ignore: sized_box_for_whitespace
                      Container(
                        height: screenHeight * 0.65 * 0.8 * 0.8,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Prva kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center, 
                                        children: [
                                          _buildDetailContainer("Email", korisnik!['email']),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer(
                                            "Ime i Prezime", 
                                            korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['imePrezime'] : 'N/A'
                                          ),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer(
                                            "Telefon", 
                                            korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['telefon'] : 'N/A'
                                          ),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer("Status", korisnik!['status']),
                                        ],
                                      )
                                    : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Druga kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center, 
                                        children: [
                                          _buildDetailContainer("Broj Proizvoda", korisnik!['brojProizvoda']),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                // ignore: prefer_const_constructors
                                                MaterialPageRoute(builder: (context) =>  KorisnikProizvodiPrikaz()),
                                              );
                                            },
                                            child: const Text("Pogledaj proizvode"),
                                          ),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer("Ukupna Kolicina", korisnik!['ukupnaKolicina']),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer("Broj rezervacija", korisnik!['brojRezervacija']),
                                          const SizedBox(height: 20),
                                              if (korisnik!['brojRezervacija'] > 0)
                                              ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                // ignore: prefer_const_constructors
                                                MaterialPageRoute(builder: (context) =>  RezervacijeKorisnika()),
                                              );
                                            },
                                                child: const Text("Rezervacije"),
                                              ),
                                        ],
                                      )
                                    : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Treća kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDetailContainer("Admin Status", korisnik!['isAdmin'] ? "Jeste admin" : "Nije admin"),
                                if (korisnik!['isAdmin'])                                   
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                       Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AdministracijaP1Prozor()),
                                      );
                                    },
                                    child: const Text("Administracije"),
                                  ),

                                const SizedBox(height: 20), 

                                // Prikaz za jeServiser
                                _buildDetailContainer("Serviser Status", korisnik!['jeServiser'] ? "Jeste serviser" : "Nije serviser"),
                                const SizedBox(height: 20), 
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        // ignore: prefer_const_constructors
                                        MaterialPageRoute(builder: (context) => ServiserProfil()),
                                      );
                                    },
                                    child: const Text("Serviser"),
                                  ),
                              ],
                            ),
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      // 2. red drugog reda - 20% visine 2. reda
                      Container(
                        height: screenHeight * 0.65 * 0.8 * 0.2,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                             onPressed: uredi,
                            child: const Text("Uredi"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              obrisi();
                            },
                            child: const Text("Obrisi"),
                          ),
                        ],
                      ),
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
  }
  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.15,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

   Widget urediProzo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.8,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 92, 225, 230),
              Color.fromARGB(255, 7, 181, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Container(
            width: screenWidth * 0.27,
            height: screenHeight * 0.76,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 188, 188, 188),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.27,
                  height: screenHeight * 0.37, // 50% of the height
                  color: const Color.fromARGB(0, 244, 67, 54), // Example color
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInput('Username', usernameController),
                        _buildInput('Ime i Prezime', imePrezimeController),
                        _buildInput('Telefon', telefonController,),
                        _buildInput('Email', emailController,),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.27,
                  height: screenHeight * 0.39, // 50% of the height
                  // ignore: prefer_const_constructors
                  color: Color.fromARGB(0, 0, 0, 0), // Example color
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.27,
                        height: screenHeight * 0.33, // 85% of the height
                        // ignore: prefer_const_constructors
                        color: Color.fromARGB(0, 76, 175, 79), // Example color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPasswordInput('Stara lozinka', staraLozinkaController),
                            _buildPasswordInput('Nova lozinka', novaLozinkaController),
                            _buildPasswordInput('Potvrda', lozinkaPotvrdaController),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.27,
                        height: screenHeight * 0.06, // 15% of the height
                        // ignore: prefer_const_constructors
                        color: Color.fromARGB(0, 255, 235, 59), // Example color
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                sakrijUrediProzo();
                              },
                              child: const Text('Nazad'),
                            ),
                            ElevatedButton(
                              onPressed: updateKorisnikZapis,
                              child: const Text('Izmjeni'),
                            ),
                          ],
                        ),
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
  }
    Widget _buildInput(String label, TextEditingController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 0.15,
      height: screenHeight * 0.07,
      padding: const EdgeInsets.only(left: 8.0),
      margin:  EdgeInsets.only(top: screenHeight*0.01),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 92, 225, 230),
            Color.fromARGB(255, 7, 181, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => updateKorisnikModel(),
      ),
    );
  }
  Widget _buildPasswordInput(String label, TextEditingController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 0.15,
      height: screenHeight * 0.07,
      padding: const EdgeInsets.only(left: 8.0),
      margin:  EdgeInsets.only(top: screenHeight*0.01),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 92, 225, 230),
            Color.fromARGB(255, 7, 181, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.white),
        obscureText: true,
        onChanged: (value) => updateKorisnikModel(),
      ),
    );
  }
}
