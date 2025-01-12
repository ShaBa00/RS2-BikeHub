// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bikehub_desktop/modeli/korisnik/korisnik_model.dart';
import 'package:bikehub_desktop/screens/korisnik/korisnik_proizvodi_prikaz.dart';
import 'package:bikehub_desktop/screens/korisnik/rezervacije_korisnika.dart';
import 'package:bikehub_desktop/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/screens/prijava/log_in_prozor.dart';
import 'package:bikehub_desktop/screens/serviser/serviser_profil.dart';
import 'package:bikehub_desktop/services/adresa/adresa_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_info_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/screens/administracija/administracija_p1_prozor.dart';
import 'package:bikehub_desktop/services/serviser/serviser_service.dart';
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
  final AdresaService adresaService = AdresaService();
  Map<String, dynamic>? korisnik;
  Map<String, dynamic>? adresaK;

  KorisnikModel korisnikNoviPodatci =
      KorisnikModel(korisnikId: 0, username: "", staraLozinka: "", lozinka: "", lozinkaPotvrda: "", email: "", stanje: "", ak: 0, isAdmin: false);

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController imePrezimeController = TextEditingController();
  TextEditingController telefonController = TextEditingController();
  TextEditingController staraLozinkaController = TextEditingController();
  TextEditingController novaLozinkaController = TextEditingController();
  TextEditingController lozinkaPotvrdaController = TextEditingController();
  TextEditingController gradController = TextEditingController();
  TextEditingController postanskiBrojController = TextEditingController();
  TextEditingController ulicaController = TextEditingController();

  bool showUrediProzo = false;
  bool changePassword = false;

  void disposeInfo() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    imePrezimeController = TextEditingController();
    telefonController = TextEditingController();
    staraLozinkaController = TextEditingController();
    novaLozinkaController = TextEditingController();
    lozinkaPotvrdaController = TextEditingController();
    gradController = TextEditingController();
    postanskiBrojController = TextEditingController();
    ulicaController = TextEditingController();
  }

  void updateKorisnikZapis() async {
    changePassword = false;
    if (korisnikNoviPodatci.username.isEmpty &&
        korisnikNoviPodatci.email.isEmpty &&
        korisnikNoviPodatci.lozinka.isEmpty &&
        korisnikNoviPodatci.lozinkaPotvrda.isEmpty &&
        korisnikNoviPodatci.staraLozinka.isEmpty) {
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
    if (korisnikNoviPodatci.lozinka.isNotEmpty && korisnikNoviPodatci.lozinkaPotvrda.isNotEmpty && korisnikNoviPodatci.staraLozinka.isNotEmpty) {
      changePassword = true;
    }
    if (korisnikNoviPodatci.username == korisnik?['username']) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Novi username mora biti drugačiji od starog");
      return;
    }
    if (korisnikNoviPodatci.email == korisnik?['email']) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Novi email mora biti drugačiji od starog");
      return;
    }

    if (korisnikNoviPodatci.username.isNotEmpty || korisnikNoviPodatci.email.isNotEmpty || changePassword == true) {
      try {
        await korisnikService.upravljanjeKorisnikom(korisnikNoviPodatci);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspešno ažuriran");
        if (korisnikNoviPodatci.username.isNotEmpty || changePassword == true) {
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
  }

  void updateKorisnikInfo() async {
    var imePrezime = imePrezimeController.text;
    var telefon = telefonController.text;

    var korisnikInfos = await korisnikInfoService.getKorisnikInfos(korisnikId: widget.korisnikId);

    if (korisnikInfos.isEmpty) {
      if (imePrezime.isEmpty || telefon.isEmpty) {
        PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je unjeti obe stavke");
        return;
      }
      try {
        await korisnikInfoService.addInfo(widget.korisnikId, imePrezime, telefon);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspešno dodana");
        await _fetchKorisnik();
        disposeInfo();
        sakrijUrediProzo();
        return;
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
      }
    }
    int korisnikInfoId = 0;
    if (korisnikInfos.isNotEmpty) {
      korisnikInfoId = korisnikInfos[0]['korisnikInfoId'];
    }
    if (imePrezime.isEmpty && telefon.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je unjeti barem jednu promjenu");
      return;
    }
    if ((imePrezime.isNotEmpty || telefon.isNotEmpty) && korisnikInfoId != 0) {
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

  void updateKorisnikAdres() async {
    var grad = gradController.text;
    var ulica = ulicaController.text;
    var postanskiBroj = postanskiBrojController.text;

    var adresa = await adresaService.getAdresaByKorisnikId(widget.korisnikId);

    if (adresa == null) {
      if (grad.isEmpty || ulica.isEmpty || postanskiBroj.isEmpty) {
        PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati sve stavke");
        return;
      }
      try {
        await adresaService.addAdresa(widget.korisnikId, grad, ulica, postanskiBroj);
        PorukaHelper.prikaziPorukuUspjeha(context, "Adresa uspešno dodana");
        await _fetchKorisnik();
        disposeInfo();
        sakrijUrediProzo();
        return;
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška: $e");
      }
    }
    int adresaId = 0;
    if (adresa != null) {
      adresaId = adresa['adresaId'];
    }
    if (grad.isEmpty && ulica.isEmpty && postanskiBroj.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je unjeti barem jednu promjenu");
      return;
    }
    if ((grad.isNotEmpty || ulica.isNotEmpty || postanskiBroj.isNotEmpty) && adresaId != 0) {
      try {
        await adresaService.updateAdresa(adresaId, grad, ulica, postanskiBroj);
        PorukaHelper.prikaziPorukuUspjeha(context, "Adresa uspešno ažuriran");
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
        isAdmin: false,
      );
    });
  }

  void uredi() {
    PorukaHelper.prikaziPorukuUpozorenja(context,
        "Moguce je promjenuti samo Username ili Email, a ukoliko mijenjate lozinku potrebno je poslati Novu lozinku, staru lozinku i potvrdu lozinke");
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
    bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, 'Da li ste sigurni da želite obrisati vaš profil?');
    if (confirmed != true) {
      return;
    }
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
      isAdmin: false,
    );

    try {
      await korisnikService.upravljanjeKorisnikom(korisnikZaBrisanje);
      PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspješno obrisan.");
      _fetchKorisnik();
    } catch (e) {
      PorukaHelper.prikaziPorukuGreske(context, "Greška pri brisanju korisnika: $e");
    }
  }

  final TextEditingController _cijenaController = TextEditingController();
  void zahtjevZaServiserLincencu() async {
    String cijenaText = _cijenaController.text;
    if (cijenaText.isEmpty || double.tryParse(cijenaText) == null || double.parse(cijenaText) <= 0) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Unesite validnu cijenu veću od 0.");
      return;
    }

    double cijena = double.parse(cijenaText);
    int korisnikId = widget.korisnikId;

    String? rezultat = await ServiserService().dodajServisera(korisnikId, cijena);

    if (rezultat != null) {
      PorukaHelper.prikaziPorukuUspjeha(context, rezultat);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchKorisnik();
  }

  Future<void> _fetchKorisnik() async {
    korisnik = await korisnikService.getKorisnikByID(widget.korisnikId);
    adresaK = await adresaService.getAdresaByKorisnikId(widget.korisnikId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (korisnik == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: const Color.fromARGB(255, 92, 225, 230),
        ),
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
            width: screenWidth * 0.85,
            height: screenHeight * 0.8,
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
                  child: korisnik != null ? _buildDetailContainer("Username", korisnik!['username']) : const CircularProgressIndicator(),
                ),
                // 2. red
                Expanded(
                  child: Column(
                    children: [
                      // 1. red drugog reda
                      // ignore: sized_box_for_whitespace
                      Container(
                        height: screenHeight * 0.9 * 0.8 * 0.8,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Prva kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.8 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildDetailContainer("Email", korisnik!['email']),
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildDetailContainer("Ime i Prezime",
                                            korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['imePrezime'] : 'N/A'),
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildDetailContainer(
                                            "Telefon", korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['telefon'] : 'N/A'),
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildDetailContainer("Grad",
                                            adresaK == null || adresaK?['grad'] == null || adresaK?['grad'].isEmpty ? "N/A" : adresaK?['grad']),
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildDetailContainer("Ulica",
                                            adresaK == null || adresaK?['ulica'] == null || adresaK?['ulica'].isEmpty ? "N/A" : adresaK?['ulica']),
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildDetailContainer(
                                            "Postanski broj",
                                            adresaK == null || adresaK?['postanskiBroj'] == null || adresaK?['postanskiBroj'].isEmpty
                                                ? "N/A"
                                                : adresaK?['postanskiBroj']),
                                      ],
                                    )
                                  : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Druga kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.8 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildDetailContainer("Broj Proizvoda", korisnik!['brojProizvoda']),
                                        const SizedBox(height: 20),
                                        customButton(
                                          width: screenWidth * 0.65 * 0.19,
                                          title: "Pogledaj proizvode",
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => KorisnikProizvodiPrikaz()),
                                            );
                                          },
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
                                                MaterialPageRoute(
                                                  builder: (context) => RezervacijeKorisnika(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              "Rezervacije",
                                              style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                            ),
                                          ),
                                      ],
                                    )
                                  : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Treća kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.8 * 0.25,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDetailContainer("Admin Status", korisnik!['isAdmin'] ? "Jeste admin" : "Nije admin"),
                                  if (korisnik!['isAdmin']) ...[
                                    SizedBox(height: 20),
                                    customButton(
                                      width: screenWidth * 0.65 * 0.19,
                                      title: "Administracije",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AdministracijaP1Prozor()),
                                        );
                                      },
                                    ),
                                  ],
                                  SizedBox(height: screenHeight * 0.015),
                                  _buildDetailContainer(
                                    "Status Korisnika",
                                    korisnik!['status'] == 'aktivan'
                                        ? "Verifikovan"
                                        : korisnik?['status'] == 'vracen'
                                            ? "Potrebne izmjene"
                                            : "Nije verifikovan",
                                  ),

                                  SizedBox(height: 20),
                                  // Prikaz za jeServiser
                                  _buildDetailContainer(
                                    "Serviser Status",
                                    (() {
                                      if (korisnik!.containsKey('jeServiser') && korisnik!['jeServiser'] != null) {
                                        switch (korisnik!['jeServiser']) {
                                          case "aktivan":
                                            return "Jeste serviser";
                                          case "izmijenjen":
                                          case "kreiran":
                                            return "Poslan zahtjev";
                                          case "obrisan":
                                            return "Obrisan";
                                          case "vracen":
                                            return "Zahtjev vraćen";
                                          default:
                                            return "Nepoznat status";
                                        }
                                      } else {
                                        return "Status nije definisan";
                                      }
                                    })(),
                                  ),
                                  if (korisnik!['jeServiser'] == "aktivan" ||
                                      korisnik!['jeServiser'] == "izmijenjen" ||
                                      korisnik!['jeServiser'] == "obrisan") ...[
                                    SizedBox(height: 20),
                                    customButton(
                                      width: screenWidth * 0.65 * 0.19,
                                      title: "Serviser",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ServiserProfil()),
                                        );
                                      },
                                    ),
                                  ] else if (korisnik!['jeServiser'] == null || korisnik!['jeServiser'] == "vracen") ...[
                                    SizedBox(height: 20),
                                    customButton(
                                      width: screenWidth * 0.65 * 0.19,
                                      title: "Postani serviser",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding: EdgeInsets.all(20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                              content: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(255, 82, 205, 210),
                                                      Color.fromARGB(255, 7, 161, 235),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Unesite cijenu vasih usluga servisa",
                                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                                                    ),
                                                    SizedBox(height: 20),
                                                    TextField(
                                                      controller: _cijenaController,
                                                      decoration: InputDecoration(
                                                        labelText: "Cijena",
                                                        labelStyle: TextStyle(color: Colors.white),
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                    SizedBox(height: 20),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        zahtjevZaServiserLincencu();
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text(
                                                        "Posalji zahtjev",
                                                        style: TextStyle(color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      // 2. red drugog reda - 20% visine 2. reda
                      Container(
                        height: screenHeight * 0.5 * 0.8 * 0.2,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customButton(
                              width: 120,
                              title: "Uredi",
                              onPressed: uredi,
                            ),
                            const SizedBox(width: 10),
                            if (korisnik!['status'] != 'obrisan')
                              customButton(
                                width: 120,
                                title: "Obrisi",
                                onPressed: () {
                                  obrisi();
                                },
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

  Widget customButton({required double width, required String title, required VoidCallback onPressed}) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 242, 242, 242), // Pozadina dugmeta
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.blue), // Tekst dugmeta
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
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white),
          ),
          // Zamjena Flexible-a s odgovarajućim widgetom
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.15),
            child: Text(
              '$value',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.visible,
              maxLines: 2, // Adjust this value as needed
            ),
          ),
        ],
      ),
    );
  }

  int selectedButton = 0;

  void setSelectedButton(int index) {
    setState(() {
      selectedButton = index;
    });
  }

  Widget customButtonInfo({
    required double width,
    required String title,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
      ),
      onPressed: onPressed,
      child: Container(
        width: width,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected == true ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget urediProzo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Center(
          child: Container(
            width: screenWidth * 0.5,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prvi kontejner
                Container(
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.76,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(0, 255, 200, 200), // Različita boja
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centriranje dugmadi u koloni
                    children: [
                      customButtonInfo(
                        width: screenWidth * 0.1, // Širina dugmeta
                        title: "Osnovni podatci",
                        onPressed: () => setState(() => selectedButton = 0),
                        isSelected: selectedButton == 0,
                      ),
                      const SizedBox(height: 10), // Razmak između dugmadi
                      customButtonInfo(
                        width: screenWidth * 0.1, // Širina dugmeta
                        title: "Dodatni podatci",
                        onPressed: () => setState(() => selectedButton = 1),
                        isSelected: selectedButton == 1,
                      ),
                      const SizedBox(height: 10), // Razmak između dugmadi
                      customButtonInfo(
                        width: screenWidth * 0.1, // Širina dugmeta
                        title: "Adresa",
                        onPressed: () => setState(() => selectedButton = 2),
                        isSelected: selectedButton == 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Razmak između kontejnera
                // Drugi kontejner (isti kao original)
                if (selectedButton == 0)
                  osnovniPodatci(context)
                else if (selectedButton == 1)
                  dodatniPodatci(context)
                else if (selectedButton == 2)
                  adresaKorisnika(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget osnovniPodatci(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            height: screenHeight * 0.37,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInput('Username', usernameController),
                  _buildInput('Email', emailController),
                ],
              ),
            ),
          ),
          Container(
            width: screenWidth * 0.27,
            height: screenHeight * 0.39,
            color: const Color.fromARGB(0, 0, 0, 0),
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.27,
                  height: screenHeight * 0.33,
                  color: const Color.fromARGB(0, 76, 175, 79),
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
                  height: screenHeight * 0.06,
                  color: const Color.fromARGB(0, 255, 235, 59),
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
    );
  }

  Widget dodatniPodatci(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            height: screenHeight * 0.70,
            color: Color.fromARGB(0, 244, 67, 54),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInput('Ime i Prezime', imePrezimeController),
                  _buildInput('Telefon', telefonController),
                ],
              ),
            ),
          ),
          Container(
            width: screenWidth * 0.27,
            height: screenHeight * 0.06,
            color: Color.fromARGB(0, 0, 0, 0),
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.27,
                  height: screenHeight * 0.06,
                  color: Color.fromARGB(0, 255, 235, 59),
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
                        onPressed: updateKorisnikInfo,
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
    );
  }

  Widget adresaKorisnika(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            height: screenHeight * 0.70,
            color: Color.fromARGB(0, 244, 67, 54),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInput('Grad', gradController),
                  _buildInput('Ulica', ulicaController),
                  _buildInput('Postanski broj', postanskiBrojController),
                ],
              ),
            ),
          ),
          Container(
            width: screenWidth * 0.27,
            height: screenHeight * 0.06,
            color: Color.fromARGB(0, 0, 0, 0),
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.27,
                  height: screenHeight * 0.06,
                  color: Color.fromARGB(0, 255, 235, 59),
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
                        onPressed: updateKorisnikAdres,
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
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 0.15,
      height: screenHeight * 0.07,
      padding: const EdgeInsets.only(left: 8.0),
      margin: EdgeInsets.only(top: screenHeight * 0.01),
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
      margin: EdgeInsets.only(top: screenHeight * 0.01),
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
