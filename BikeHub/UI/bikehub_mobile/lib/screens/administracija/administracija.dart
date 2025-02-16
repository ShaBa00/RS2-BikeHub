// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, prefer_final_fields, unused_element, no_leading_underscores_for_local_identifiers, avoid_print, unnecessary_const, use_build_context_synchronously, sort_child_properties_last

import 'package:bikehub_mobile/screens/administracija/image_carousel.dart';
import 'package:bikehub_mobile/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';

class AdministracijaPage extends StatefulWidget {
  const AdministracijaPage({super.key});

  @override
  _AdministracijaPageState createState() => _AdministracijaPageState();
}

class _AdministracijaPageState extends State<AdministracijaPage> with SingleTickerProviderStateMixin {
  String activeTitle = 'home';
  bool _isLoading = true;
  String _username = "";

  final KorisnikServis _korisnikService = KorisnikServis();
  final ServiserService _serviserService = ServiserService();
  final BiciklService _biciklService = BiciklService();
  final DijeloviService _dijeloviService = DijeloviService();
  final AdresaServis _adresaService = AdresaServis();

  int _countKorisnik = 0;
  List _listaKorisnika = [];

  int _countServisera = 0;
  List _listaServisera = [];

  int _countBicikala = 0;
  List _listaBicikala = [];

  int _countDijelova = 0;
  List _listaDijelova = [];

  List _prikazaniKorisnici = [];
  int _currentPageKorisnik = 0;
  int _pageSizeKorisnik = 3;
  int _brojPrikazanihKorisnika = 0;
  String _selectedStatus = 'Kreirani';

  List _prikazaniServiseri = [];
  int _currentPageServiseri = 0;
  int _pageSizeServiseri = 3;
  int _brojPrikazanihServiseri = 0;
  String _selectedStatusServiseri = 'Kreirani';

  List _prikazaniBicikli = [];
  int _currentPageBicikli = 0;
  int _pageSizeBicikli = 10;
  int _brojPrikazanihBicikli = 0;
  String _selectedStatusBicikli = 'Kreirani';

  List _prikazaniDijelovi = [];
  int _currentPageDijelovi = 0;
  int _pageSizeDijelovi = 3;
  int _brojPrikazanihDijelovi = 0;
  String _selectedStatusDijelovi = 'Kreirani';

  List _listaAdministratora = [];
  int _countAdministratora = 0;
  int _currentPageAdministrator = 0;
  int _pageSizeAdministrator = 4;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  int _odabraniId = 0;
  @override
  void initState() {
    super.initState();
    _fetchPodatci();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300), // Dodana reverseDuration
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset(0.7, 0.0), // Ovo je 40% šire od lijeve ivice
    ).animate(_controller);
  }

  Future _fetchPodatci() async {
    final credentials = await _korisnikService.getCredentials();
    _username = credentials['username']!;
    await _korisnikService.getKorisniks(status: '');
    await _serviserService.getServiseriDTO(
      status: '',
      page: null,
      pageSize: null,
    );
    await _biciklService.getBiciklis(status: '');
    await _dijeloviService.getDijelovis(status: '');
    setState(() {
      _listaKorisnika = _korisnikService.listaKorisnika;
      _countKorisnik = _korisnikService.countKorisnika;
      _listaAdministratora = _korisnikService.listaAdministratora;
      _countAdministratora = _listaAdministratora.length;
      _listaServisera = _serviserService.listaServisera;
      _countServisera = _serviserService.countServisera;
      _listaBicikala = _biciklService.listaBicikala;
      _countBicikala = _biciklService.countBicikala;
      _listaDijelova = _dijeloviService.listaDijelova;
      _countDijelova = _dijeloviService.countDijelova;
      _isLoading = false;
    });
    await _filterStatus("Kreirani", 1);
    await _filterStatus("Kreirani", 2);
    await _filterStatus("Kreirani", 3);
    await _filterStatus("Kreirani", 4);
  }

  _filterStatus(String status, int odabrani) async {
    String _status;
    switch (status) {
      case 'Kreirani':
        _status = 'kreiran';
        break;
      case 'Izmijenjeni':
        _status = 'izmijenjen';
        break;
      case 'Aktivni':
        _status = 'aktivan';
        break;
      case 'Obrisani':
        _status = 'obrisan';
        break;
      case 'Vraceni':
        _status = 'vracen';
        break;
      default:
        _status = '';
    }

    switch (odabrani) {
      case 1:
        setState(() {
          _currentPageKorisnik = 0;
          _selectedStatus = status;
          _prikazaniKorisnici = _listaKorisnika.where((korisnik) => korisnik['status'] == _status).toList();
          _brojPrikazanihKorisnika = _prikazaniKorisnici.length;
        });
        break;
      case 2:
        setState(() {
          _currentPageServiseri = 0;
          _selectedStatusServiseri = status;
          _prikazaniServiseri = _listaServisera.where((serviser) => serviser['status'] == _status).toList();
          _brojPrikazanihServiseri = _prikazaniServiseri.length;
        });
        break;
      case 3:
        setState(() {
          _currentPageBicikli = 0;
          _selectedStatusBicikli = status;
          _prikazaniBicikli = _listaBicikala.where((bicikl) => bicikl['status'] == _status).toList();
          _brojPrikazanihBicikli = _prikazaniBicikli.length;
        });
        break;
      case 4:
        setState(() {
          _currentPageDijelovi = 0;
          _selectedStatusDijelovi = status;
          _prikazaniDijelovi = _listaDijelova.where((dijelovi) => dijelovi['status'] == _status).toList();
          _brojPrikazanihDijelovi = _prikazaniDijelovi.length;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administracija',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                activeTitle = "adminD";
              });
            },
            child: Text(
              "Dodatno",
              style: TextStyle(
                color: Colors.blue, // Plavi tekst
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Bijela boja dugmeta
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Skloni tastaturu kada korisnik klikne izvan inputa
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    centralniDio(context),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: adminNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget centralniDio(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 205, 238, 239),
            Color.fromARGB(255, 165, 196, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: getActiveWidget(context),
    );
  }

  void navigacija(BuildContext context, String title) {
    setState(() {
      activeTitle = title;
    });
  }

  Widget getActiveWidget(BuildContext context) {
    switch (activeTitle) {
      case 'korisnici':
        return korisniciDio(context);
      case 'serviseri':
        return serviseriDio(context);
      case 'home':
        return homeDio(context);
      case 'bicikli':
        return bicikliDio(context);
      case 'dijelovi':
        return dijeloviDio(context);
      case 'korisniciP':
        return korisniciPrikaz(context);
      case 'serviseriP':
        return serviserPrikaz(context);
      case 'bicikliP':
        return biciklPrikaz(context);
      case 'dijeloviP':
        return dijeloviPrikaz(context);
      case 'adminD':
        return adminDodatno(context);
      default:
        return homeDio(context);
    }
  }

  bool showNewContainer = false;

  Widget adminDodatno(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueAccent, // Postavljena pozadina
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54), // Bilo koja pozadina
            child: Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: const Color.fromARGB(0, 33, 149, 243), // Bilo koja pozadina za prvi dio
                  child: Center(
                    child: Text(
                      _username,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255), // Plava boja teksta
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: const Color.fromARGB(0, 76, 175, 79), // Bilo koja pozadina za drugi dio
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNewContainer = !showNewContainer;
                        });
                      },
                      child: Text(
                        "Dodaj novog",
                        style: TextStyle(
                          color: Colors.blue, // Plava boja teksta
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // Bijela boja dugmeta
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          showNewContainer ? adminNewContainer(context) : adminListContainer(context),
        ],
      ),
    );
  }

  Widget adminListContainer(BuildContext context) {
    int startIndex = _currentPageAdministrator * _pageSizeAdministrator;
    int endIndex = startIndex + _pageSizeAdministrator;
    List currentAdmini = _listaAdministratora.sublist(
      startIndex,
      endIndex > _listaAdministratora.length ? _listaAdministratora.length : endIndex,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.657,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 205, 238, 239), Color.fromARGB(255, 165, 196, 210)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ), // Zaobljene gornje ivice
      ),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.59,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54), // Pozadina prvog dijela
            child: ListView.builder(
              itemCount: currentAdmini.length,
              itemBuilder: (context, index) {
                final korisnik = currentAdmini[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      ucitanZapis = false;
                      _odabraniId = korisnik['korisnikId'];
                      activeTitle = "korisniciP";
                    });
                    print('Kliknut red broj $index');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.15,
                              color: const Color.fromARGB(0, 244, 67, 54), // Promijeni boju po želji
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.65,
                              color: const Color.fromARGB(0, 76, 175, 79), // Promijeni boju po želji
                              child: Center(
                                child: Text(
                                  korisnik['username'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.15,
                              color: const Color.fromARGB(0, 33, 149, 243), // Promijeni boju po želji
                              child: Center(
                                child: _buildInfoButton(korisnik['korisnikId'], "korisniciP"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 76, 175, 79), // Pozadina drugog dijela
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentPageAdministrator > 0
                      ? () {
                          setState(() {
                            _currentPageAdministrator--;
                          });
                        }
                      : null,
                  child: Text('<'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: endIndex < _listaAdministratora.length
                      ? () {
                          setState(() {
                            _currentPageAdministrator++;
                          });
                        }
                      : null,
                  child: Text('>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final _usernameController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();
  final _emailController = TextEditingController();

  Widget adminNewContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.657,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 251, 251, 251), Color.fromARGB(255, 128, 255, 253)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ), // Zaobljene gornje ivice
      ),
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 110, 255, 253), Color.fromARGB(255, 255, 255, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10.0)), // Zaobljene ivice
          ),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.44,
                width: MediaQuery.of(context).size.width * 0.9,
                color: const Color.fromARGB(0, 158, 158, 158),
                child: Column(
                  children: [
                    buildCustomInput(
                      context: context,
                      title: "Username",
                      controller: _usernameController,
                      isPassword: false,
                    ),
                    buildCustomInput(
                      context: context,
                      title: "Lozinka",
                      controller: _lozinkaController,
                      isPassword: true,
                    ),
                    buildCustomInput(
                      context: context,
                      title: "Potvrda lozinke",
                      controller: _lozinkaPotvrdaController,
                      isPassword: true,
                    ),
                    buildCustomInput(
                      context: context,
                      title: "Email",
                      controller: _emailController,
                      isPassword: false,
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.9,
                color: const Color.fromARGB(0, 96, 125, 139), // Bilo koja pozadina
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showNewContainer = false;
                          });
                        },
                        child: Text(
                          "Nazad",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Boldiraj tekst
                            fontSize: 18.0, // Povećaj font teksta
                            color: Color.fromARGB(255, 255, 255, 255), // Plava boja teksta
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 202, 255), // Bijela boja dugmeta
                        ),
                      ),
                      SizedBox(width: 10), // Razmak između dugmadi
                      ElevatedButton(
                        onPressed: () {
                          dodajAdministratora();
                        },
                        child: Text(
                          "Dodaj",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Boldiraj tekst
                            fontSize: 18.0, // Povećaj font teksta
                            color: Color.fromARGB(255, 255, 255, 255), // Plava boja teksta
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 202, 255), // Bijela boja dugmeta
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomInput({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: title == "Lozinka" || title == "Potvrda lozinke" ? "Unesite $title" : null,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void dodajAdministratora() async {
    if (_usernameController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati username");
      return;
    }
    if (_lozinkaController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati lozinku");
      return;
    }
    if (_lozinkaPotvrdaController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati potvrdenu lozinku");
      return;
    }
    if (_lozinkaController.text != _lozinkaPotvrdaController.text) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Lozinka i potvrdena lozinka moraju biti iste");
      return;
    }
    if (_emailController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati email");
      return;
    }

    try {
      final responseMessage = await _korisnikService.postAdmina(
        _usernameController.text,
        _lozinkaController.text,
        _lozinkaPotvrdaController.text,
        _emailController.text,
      );
      if (responseMessage == "Administrator uspješno dodan") {
        PorukaHelper.prikaziPorukuUspjeha(context, responseMessage!);
        _usernameController.clear();
        _lozinkaController.clear();
        _lozinkaPotvrdaController.clear();
        _emailController.clear();
        await _korisnikService.getKorisniks(status: '');
        setState(() {
          _listaAdministratora = _korisnikService.listaAdministratora;
          _countAdministratora = _listaAdministratora.length;
          showNewContainer = false;
        });
      } else {
        PorukaHelper.prikaziPorukuUpozorenja(context, responseMessage ?? "Došlo je do greške prilikom dodavanja administratora");
      }
    } catch (e) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Došlo je do greške: $e");
    }
  }

  Widget korisniciDio(BuildContext context) {
    int startIndex = _currentPageKorisnik * _pageSizeKorisnik;
    int endIndex = startIndex + _pageSizeKorisnik;
    List currentKorisnik = _prikazaniKorisnici.sublist(
      startIndex,
      endIndex > _prikazaniKorisnici.length ? _prikazaniKorisnici.length : endIndex,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueAccent,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _selectedStatus, // Pretpostavljam da je ovo String varijabla
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                Text(
                  'Korisnici',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                _buildButton("Postavi status", 1),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.677,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.617,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina prvog dijela
                      child: ListView.builder(
                        itemCount: currentKorisnik.length,
                        itemBuilder: (context, index) {
                          final korisnik = currentKorisnik[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                ucitanZapis = false;
                                _odabraniId = korisnik['korisnikId'];
                                activeTitle = "korisniciP";
                              });
                              print('Kliknut red broj $index');
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Promijeni boju po želji
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.65,
                                        color: const Color.fromARGB(0, 76, 175, 79), // Promijeni boju po želji
                                        child: Center(
                                          child: Text(
                                            korisnik['username'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Promijeni boju po želji
                                        child: Center(
                                          child: _buildInfoButton(korisnik['korisnikId'], "korisniciP"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 76, 175, 79), // Pozadina drugog dijela
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPageKorisnik > 0
                                ? () {
                                    setState(() {
                                      _currentPageKorisnik--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _prikazaniKorisnici.length
                                ? () {
                                    setState(() {
                                      _currentPageKorisnik++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isSlideVisible,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.677,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomLeft: Radius.circular(50.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.597,
                          color: Color.fromARGB(0, 0, 0, 0), // Prva pozadina
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusButton("Kreirani", 1, 'korisnici'),
                              _buildStatusButton("Izmijenjeni", 1, 'korisnici'),
                              _buildStatusButton("Aktivni", 1, 'korisnici'),
                              _buildStatusButton("Obrisani", 1, 'korisnici'),
                              _buildStatusButton("Vraceni", 1, 'korisnici'),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 138, 195, 233),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                            ),
                          ),
                          child: Center(
                            child: _buildButton("Zatvori", 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget serviseriDio(BuildContext context) {
    int startIndex = _currentPageServiseri * _pageSizeServiseri;
    int endIndex = startIndex + _pageSizeServiseri;
    List currentServiseri = _prikazaniServiseri.sublist(
      startIndex,
      endIndex > _prikazaniServiseri.length ? _prikazaniServiseri.length : endIndex,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueAccent,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _selectedStatusServiseri, // Pretpostavljam da je ovo String varijabla
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                Text(
                  'Serviseri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                _buildButton("Postavi status", 2),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.677,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.617,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina prvog dijela
                      child: ListView.builder(
                        itemCount: currentServiseri.length,
                        itemBuilder: (context, index) {
                          final serviser = currentServiseri[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                ucitanZapis = false;
                                _odabraniId = serviser['serviserId'];
                                activeTitle = "serviseriP";
                              });
                              print('Kliknut red broj $index');
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Promijeni boju po želji
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.65,
                                        color: const Color.fromARGB(0, 76, 175, 79), // Promijeni boju po želji
                                        child: Center(
                                          child: Text(
                                            serviser['username'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Promijeni boju po želji
                                        child: Center(
                                          child: _buildInfoButton(serviser['serviserId'], "serviseriP"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 76, 175, 79), // Pozadina drugog dijela
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPageServiseri > 0
                                ? () {
                                    setState(() {
                                      _currentPageServiseri--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _prikazaniServiseri.length
                                ? () {
                                    setState(() {
                                      _currentPageServiseri++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isSlideVisibleServiseri,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.677,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomLeft: Radius.circular(50.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.597,
                          color: Color.fromARGB(0, 0, 0, 0), // Prva pozadina
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusButton("Kreirani", 2, 'serviseri'),
                              _buildStatusButton("Izmijenjeni", 2, 'serviseri'),
                              _buildStatusButton("Aktivni", 2, 'serviseri'),
                              _buildStatusButton("Obrisani", 2, 'serviseri'),
                              _buildStatusButton("Vraceni", 2, 'serviseri'),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 138, 195, 233),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                            ),
                          ),
                          child: Center(
                            child: _buildButton("Zatvori", 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget homeDio(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 205, 238, 239),
            Color.fromARGB(255, 165, 196, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //korisnici
          GestureDetector(
            onTap: () {
              navigacija(context, "korisnici");
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(bottom: 10.0), // Odvoji kontejnere vertikalno
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
              ),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 33, 149, 243), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
                        ),
                        child: Center(
                          child: Text(
                            'Korisnici',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 76, 175, 79), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_countKorisnik',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(width: 8), // Razmak između teksta
                          Text(
                            'Broj korisnika',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //serviseri
          GestureDetector(
            onTap: () {
              navigacija(context, "serviseri");
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(bottom: 10.0), // Odvoji kontejnere vertikalno
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
              ),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 33, 149, 243), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
                        ),
                        child: Center(
                          child: Text(
                            'Serviseri',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 76, 175, 79), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_countServisera',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(width: 8), // Razmak između teksta
                          Text(
                            'Broj servisera',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //bicikli
          GestureDetector(
            onTap: () {
              navigacija(context, "bicikli");
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(bottom: 10.0), // Odvoji kontejnere vertikalno
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
              ),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 33, 149, 243), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
                        ),
                        child: Center(
                          child: Text(
                            'Bicikli',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 76, 175, 79), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_countBicikala',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(width: 8), // Razmak između teksta
                          Text(
                            'Broj bicikala',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //dijelovi
          GestureDetector(
            onTap: () {
              navigacija(context, "dijelovi");
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(bottom: 10.0), // Odvoji kontejnere vertikalno
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
              ),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 33, 149, 243), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0), // Zaobljene ivice
                        ),
                        child: Center(
                          child: Text(
                            'Dijelovi',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 76, 175, 79), // Promijenite boju po potrebi
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_countDijelova',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(width: 8), // Razmak između teksta
                          Text(
                            'Broj dijelova',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bicikliDio(BuildContext context) {
    int startIndex = _currentPageBicikli * _pageSizeBicikli;
    int endIndex = startIndex + _pageSizeBicikli;
    List currentBicikli = _prikazaniBicikli.sublist(
      startIndex,
      endIndex > _prikazaniBicikli.length ? _prikazaniBicikli.length : endIndex,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueAccent,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _selectedStatusBicikli, // Pretpostavljam da je ovo String varijabla
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                Text(
                  'Bicikli',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                _buildButton("Postavi status", 3),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.677,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.617,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina prvog dijela
                      child: ListView.builder(
                        itemCount: currentBicikli.length,
                        itemBuilder: (context, index) {
                          final bicikl = currentBicikli[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                ucitanZapis = false;
                                _odabraniId = bicikl['biciklId'];
                                activeTitle = "bicikliP";
                              });
                              print('Kliknut red broj $index');
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Promijeni boju po želji
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.65,
                                        color: const Color.fromARGB(0, 76, 175, 79), // Promijeni boju po želji
                                        child: Center(
                                          child: Text(
                                            bicikl['naziv'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Promijeni boju po želji
                                        child: Center(
                                          child: _buildInfoButton(bicikl['biciklId'], "bicikliP"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 76, 175, 79), // Pozadina drugog dijela
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPageBicikli > 0
                                ? () {
                                    setState(() {
                                      _currentPageBicikli--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _prikazaniBicikli.length
                                ? () {
                                    setState(() {
                                      _currentPageBicikli++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isSlideVisibleBicikli,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.677,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomLeft: Radius.circular(50.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.597,
                          color: Color.fromARGB(0, 0, 0, 0), // Prva pozadina
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusButton("Kreirani", 3, 'bicikli'),
                              _buildStatusButton("Izmijenjeni", 3, 'bicikli'),
                              _buildStatusButton("Aktivni", 3, 'bicikli'),
                              _buildStatusButton("Obrisani", 3, 'bicikli'),
                              _buildStatusButton("Vraceni", 3, 'bicikli'),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 138, 195, 233),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                            ),
                          ),
                          child: Center(
                            child: _buildButton("Zatvori", 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dijeloviDio(BuildContext context) {
    int startIndex = _currentPageDijelovi * _pageSizeDijelovi;
    int endIndex = startIndex + _pageSizeBicikli;
    List currentDijelovi = _prikazaniDijelovi.sublist(
      startIndex,
      endIndex > _prikazaniDijelovi.length ? _prikazaniDijelovi.length : endIndex,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.757,
      width: MediaQuery.of(context).size.width,
      color: Colors.blueAccent,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _selectedStatusDijelovi, // Pretpostavljam da je ovo String varijabla
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                Text(
                  'Dijelovi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                _buildButton("Postavi status", 4),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.677,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.617,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina prvog dijela
                      child: ListView.builder(
                        itemCount: currentDijelovi.length,
                        itemBuilder: (context, index) {
                          final dijelovi = currentDijelovi[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                ucitanZapis = false;
                                _odabraniId = dijelovi['dijeloviId'];
                                activeTitle = "dijeloviP";
                              });
                              print('Kliknut red broj $index');
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Promijeni boju po želji
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.65,
                                        color: const Color.fromARGB(0, 76, 175, 79), // Promijeni boju po želji
                                        child: Center(
                                          child: Text(
                                            dijelovi['naziv'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Promijeni boju po želji
                                        child: Center(
                                          child: _buildInfoButton(dijelovi['dijeloviId'], "dijeloviP"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(0, 76, 175, 79), // Pozadina drugog dijela
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPageServiseri > 0
                                ? () {
                                    setState(() {
                                      _currentPageServiseri--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndex < _prikazaniServiseri.length
                                ? () {
                                    setState(() {
                                      _currentPageServiseri++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isSlideVisibleDijelovi,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.677,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomLeft: Radius.circular(50.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.597,
                          color: Color.fromARGB(0, 0, 0, 0), // Prva pozadina
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusButton("Kreirani", 4, 'dijelovi'),
                              _buildStatusButton("Izmijenjeni", 4, 'dijelovi'),
                              _buildStatusButton("Aktivni", 4, 'dijelovi'),
                              _buildStatusButton("Obrisani", 4, 'dijelovi'),
                              _buildStatusButton("Vraceni", 4, 'dijelovi'),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 138, 195, 233),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                            ),
                          ),
                          child: Center(
                            child: _buildButton("Zatvori", 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool ucitanZapis = false;
  Map<String, dynamic>? zapis;
  Map<String, dynamic>? adresa;

  Future<void> ucitavanjeZapisa(String objekat) async {
    switch (objekat) {
      case "Korisnik":
        try {
          zapis = await _korisnikService.getKorisnikById(_odabraniId);
          if (zapis != null) {
            adresa = await _adresaService.getAdresa(korisnikId: _odabraniId);
          }
          ucitanZapis = true;
        } catch (e) {
          ucitanZapis = false;
          print('Greska prilikom ucitavanja zapisa: $e');
        }
        break;
      case "Serviser":
        try {
          zapis = await _serviserService.getServiseriDTOById(serviserId: _odabraniId);
          ucitanZapis = true;
        } catch (e) {
          ucitanZapis = false;
          print('Greska prilikom ucitavanja zapisa: $e');
        }
        break;
      case "Bicikl":
        try {
          zapis = await _biciklService.getBiciklById(_odabraniId);
          ucitanZapis = true;
        } catch (e) {
          ucitanZapis = false;
          print('Greska prilikom ucitavanja zapisa: $e');
        }
        break;
      case "Dijelovi":
        try {
          zapis = await _dijeloviService.getDijeloviById(_odabraniId);
          ucitanZapis = true;
        } catch (e) {
          ucitanZapis = false;
          print('Greska prilikom ucitavanja zapisa: $e');
        }
        break;
      case "Admin":
        break;
      default:
        ucitanZapis = false;
        print('Nepoznat objekat: $objekat');
    }
  }

  Widget korisniciPrikaz(BuildContext context) {
    return FutureBuilder<void>(
      future: ucitavanjeZapisa("Korisnik"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done && ucitanZapis) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.757,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueAccent,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(0, 244, 67, 54), // Bilo koja pozadina
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Username korisnika:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          zapis?['username'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.677,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 205, 238, 239),
                        Color.fromARGB(255, 165, 196, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
                        height: MediaQuery.of(context).size.height * 0.28, // 28% visine ekrana
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25.0), // Zaobljene ivice
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Centriranje djece
                          children: [
                            // imePrezime, Status,
                            Container(
                              width: MediaQuery.of(context).size.width * 0.90, // 90% širine ekrana
                              height: MediaQuery.of(context).size.height * 0.06, // 6% visine ekrana
                              decoration: BoxDecoration(
                                color: Colors.white, // Bijela boja pozadine
                                borderRadius: BorderRadius.circular(12.0), // Zaobljene ivice
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Prvi dio: Ime i prezime korisnika
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.person, // Ikona umjesto teksta
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          getImePrezime(zapis!),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Drugi dio: Verifikovan checkbox
                                  Row(
                                    children: [
                                      const Text(
                                        'Status:',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${zapis?['status']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            //email broj
                            Container(
                              width: MediaQuery.of(context).size.width * 0.90, // 90% širine ekrana
                              height: MediaQuery.of(context).size.height * 0.06, // 6% visine ekrana
                              decoration: BoxDecoration(
                                color: Colors.white, // Bijela boja pozadine
                                borderRadius: BorderRadius.circular(12.0), // Zaobljene ivice
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Prvi dio: Email korisnika
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.email, // Ikona za email
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8), // Razmak između ikone i teksta
                                        Text(
                                          zapis?['email'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Drugi dio: Telefon korisnika
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone, // Ikona za telefon
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8), // Razmak između ikone i teksta
                                        Text(
                                          getTelefon(zapis!),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8), // Razmak između redova
                            //Grad, ulica
                            Container(
                              width: MediaQuery.of(context).size.width * 0.90, // 90% širine ekrana
                              height: MediaQuery.of(context).size.height * 0.06, // 6% visine ekrana
                              decoration: BoxDecoration(
                                color: Colors.white, // Bijela boja pozadine
                                borderRadius: BorderRadius.circular(12.0), // Zaobljene ivice
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on, // Ikona za lokaciju
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 8), // Razmak između ikone i teksta
                                    Text(
                                      adresa != null
                                          ? '${adresa?['grad'] ?? 'N/A'}, ${adresa?['ulica'] ?? 'N/A'}, ${adresa?['postanskiBroj'] ?? 'N/A'}'
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10), // Razmak između Containera
                      Container(
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 76, 175, 79), // Druga pozadina
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.23,
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 82, 205, 210),
                                    Color.fromARGB(255, 7, 161, 235),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          'Narudžbe',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          zapis != null && zapis?['korisnikInfos'] != null && zapis?['korisnikInfos'].isNotEmpty
                                              ? (zapis?['korisnikInfos'][0]['brojNarudbi']?.toString() ?? 'N/A')
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          'Servisi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          zapis != null && zapis?['korisnikInfos'] != null && zapis?['korisnikInfos'].isNotEmpty
                                              ? (zapis?['korisnikInfos'][0]['brojServisa']?.toString() ?? 'N/A')
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          'Proizvodi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          zapis?['brojProizvoda']?.toString() ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          'Kolicina',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          zapis?['ukupnaKolicina']?.toString() ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.23,
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 82, 205, 210),
                                    Color.fromARGB(255, 7, 161, 235),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          zapis?['isAdmin'] == true ? 'Admin' : 'Nije admin',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.045,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          zapis?['jeServiser'] == null ? 'nije Serviser' : 'Serviser',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10), // Razmak između Containera
                      Container(
                        height: MediaQuery.of(context).size.height * 0.077,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Zaobljene ivice
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (zapis?['status'] == 'kreiran' || zapis?['status'] == 'izmijenjen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Korisnik'),
                              _buildISetStatusButton('Vrati', 'Korisnik'),
                              _buildISetStatusButton('Obrisi', 'Korisnik'),
                            ] else if (zapis?['status'] == 'aktivan') ...[
                              _buildISetStatusButton('Vrati', 'Korisnik'),
                              _buildISetStatusButton('Obrisi', 'Korisnik'),
                            ] else if (zapis?['status'] == 'vracen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Korisnik'),
                              _buildISetStatusButton('Obrisi', 'Korisnik'),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Center(
            child: Text('Greska pri ucitavanju'),
          );
        }
      },
    );
  }

  Future<void> setStatusObjektu(String title, String objekat) async {
    String status = "";

    switch (title) {
      case "Aktiviraj":
        status = "aktivan";
        break;
      case "Vrati":
        status = "vracen";
        break;
      case "Obrisi":
        bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, "Da li ste sigurni da želite obrisati zapis?");
        if (confirmed != true) {
          return;
        }
        status = "obrisan";

        break;
      default:
        break;
    }

    switch (objekat) {
      case "Korisnik":
        try {
          await _korisnikService.upravljanjeKorisnikom(status, _odabraniId);
          PorukaHelper.prikaziPorukuUspjeha(context, "Status uspješno ažuriran");
        } catch (e) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom ažuriranja statusa");
        }
        await _korisnikService.getKorisniks(status: '');
        setState(() {
          _listaKorisnika = _korisnikService.listaKorisnika;
          _countKorisnik = _korisnikService.countKorisnika;
          _filterStatus(_selectedStatus, 1);
          activeTitle = "korisnici";
        });
        break;
      case "Serviser":
        try {
          await _serviserService.upravljanjeServiserom(status, _odabraniId);
          PorukaHelper.prikaziPorukuUspjeha(context, "Status uspješno ažuriran");
        } catch (e) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom ažuriranja statusa");
        }
        await _serviserService.getServiseriDTO(
          status: '',
          page: null,
          pageSize: null,
        );
        setState(() {
          _listaServisera = _serviserService.listaServisera;
          _countServisera = _serviserService.countServisera;
          _filterStatus(_selectedStatusServiseri, 2);
          activeTitle = "serviseri";
        });
        break;
      case "Bicikl":
        try {
          await _biciklService.upravljanjeBiciklom(status, _odabraniId);
          PorukaHelper.prikaziPorukuUspjeha(context, "Status uspješno ažuriran");
        } catch (e) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom ažuriranja statusa");
        }

        await _biciklService.getBiciklis(status: '');
        setState(() {
          _listaBicikala = _biciklService.listaBicikala;
          _countBicikala = _biciklService.countBicikala;
          _filterStatus(_selectedStatusBicikli, 3);
          activeTitle = "bicikli";
        });
        break;
      case "Dijelovi":
        try {
          await _dijeloviService.upravljanjeDijelom(status, _odabraniId);
          PorukaHelper.prikaziPorukuUspjeha(context, "Status uspješno ažuriran");
        } catch (e) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom ažuriranja statusa");
        }

        await _dijeloviService.getDijelovis(status: '');
        setState(() {
          _listaDijelova = _dijeloviService.listaDijelova;
          _countDijelova = _dijeloviService.countDijelova;
          _filterStatus(_selectedStatusDijelovi, 4);
          activeTitle = "dijelovi";
        });
        break;
      default:
        break;
    }

    print('Status: $status, Objekat: $objekat');
  }

  Widget _buildISetStatusButton(String title, String objekat) {
    return GestureDetector(
      onTap: () {
        setStatusObjektu(title, objekat);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20.0),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: Color.fromARGB(255, 87, 202, 255),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String getTelefon(Map<String, dynamic> korisnik) {
    if (korisnik['korisnikInfos'] != null && korisnik['korisnikInfos'].isNotEmpty) {
      String telefon = korisnik['korisnikInfos'][0]['telefon'] ?? 'N/A';
      return telefon.isNotEmpty ? telefon : 'N/A';
    }
    return 'N/A';
  }

  String getImePrezime(Map<String, dynamic> korisnik) {
    if (korisnik['korisnikInfos'] != null && korisnik['korisnikInfos'].isNotEmpty) {
      String imePrezime = korisnik['korisnikInfos'][0]['imePrezime'] ?? 'N/A';
      return imePrezime.isNotEmpty ? imePrezime : 'N/A';
    }
    return 'N/A';
  }

  Widget serviserPrikaz(BuildContext context) {
    return FutureBuilder<void>(
      future: ucitavanjeZapisa("Serviser"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done && ucitanZapis) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.757,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueAccent,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(0, 244, 67, 54), // Bilo koja pozadina
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Username servisera:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          zapis?['username'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.677,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 205, 238, 239),
                        Color.fromARGB(255, 165, 196, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 33, 149, 243), // Prva pozadina
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Prva pozadina
                                        child: Center(
                                          child: Text(
                                            "Cijena: ${zapis?['cijena'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Druga pozadina
                                        child: Center(
                                          child: Text(
                                            "Ocjena: ${zapis?['ukupnaOcjena'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        color: const Color.fromARGB(0, 244, 67, 54), // Prva pozadina
                                        child: Center(
                                          child: Text(
                                            "Broj Servisa: ${zapis?['brojServisa'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        color: const Color.fromARGB(0, 33, 149, 243), // Druga pozadina
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: const Color.fromARGB(255, 0, 0, 0),
                                              ),
                                              Text(
                                                "${zapis?['grad'] ?? 'N/A'}",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                  fontSize: 17.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Status",
                                          style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        Text(
                                          ": ${zapis?['status'] ?? 'N/A'}",
                                          style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.077,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Zaobljene ivice
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (zapis?['status'] == 'kreiran' || zapis?['status'] == 'izmijenjen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Serviser'),
                              _buildISetStatusButton('Vrati', 'Serviser'),
                              _buildISetStatusButton('Obrisi', 'Serviser'),
                            ] else if (zapis?['status'] == 'aktivan') ...[
                              _buildISetStatusButton('Vrati', 'Serviser'),
                              _buildISetStatusButton('Obrisi', 'Serviser'),
                            ] else if (zapis?['status'] == 'vracen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Serviser'),
                              _buildISetStatusButton('Obrisi', 'Serviser'),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text('Greska pri ucitavanju'),
          );
        }
      },
    );
  }

  Widget biciklPrikaz(BuildContext context) {
    return FutureBuilder<void>(
      future: ucitavanjeZapisa("Bicikl"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done && ucitanZapis) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.757,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueAccent,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(0, 244, 67, 54), // Bilo koja pozadina
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Naziv bicikla:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          zapis?['naziv'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.677,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 205, 238, 239),
                        Color.fromARGB(255, 165, 196, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // slika i status
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 244, 67, 54), // Prva pozadina
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            ),
                            child: Row(
                              children: [
                                //slika
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  color: const Color.fromARGB(0, 255, 153, 0), // Prva pozadina
                                  child: ImageCarousel(
                                    slikeBiciklis: zapis?['slikeBiciklis'],
                                    initialIndex: 0, // Početni indeks slike
                                  ),
                                ),

                                //status
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 39, 142, 176),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.1,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Bijela boja pozadine
                                        borderRadius: BorderRadius.circular(10.0), // Zaobljene ivice
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Status:",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                          Text(
                                            "${zapis?['status'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold, // Boldiran font za drugi dio
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
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 33, 149, 243), // Druga pozadina
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.23,
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Cijena: ${zapis?['cijena'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Velicina rama: ${zapis?['velicinaRama'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Količina: ${zapis?['kolicina'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Veličina točka: ${zapis?['velicinaTocka'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Kategorija: ${zapis?['kategorijaId'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Broj brzina: ${zapis?['brojBrzina'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
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
                      Container(
                        height: MediaQuery.of(context).size.height * 0.077,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Zaobljene ivice
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (zapis?['status'] == 'kreiran' || zapis?['status'] == 'izmijenjen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Bicikl'),
                              _buildISetStatusButton('Vrati', 'Bicikl'),
                              _buildISetStatusButton('Obrisi', 'Bicikl'),
                            ] else if (zapis?['status'] == 'aktivan') ...[
                              _buildISetStatusButton('Vrati', 'Bicikl'),
                              _buildISetStatusButton('Obrisi', 'Bicikl'),
                            ] else if (zapis?['status'] == 'vracen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Bicikl'),
                              _buildISetStatusButton('Obrisi', 'Bicikl'),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text('Greska pri ucitavanju'),
          );
        }
      },
    );
  }

  Widget dijeloviPrikaz(BuildContext context) {
    return FutureBuilder<void>(
      future: ucitavanjeZapisa("Dijelovi"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done && ucitanZapis) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.757,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueAccent,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(0, 244, 67, 54), // Bilo koja pozadina
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Naziv dijela:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          zapis?['naziv'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.677,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 205, 238, 239),
                        Color.fromARGB(255, 165, 196, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // slika i status
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 244, 67, 54), // Prva pozadina
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            ),
                            child: Row(
                              children: [
                                //slika
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  color: const Color.fromARGB(0, 255, 153, 0), // Prva pozadina
                                  child: ImageCarousel(
                                    slikeBiciklis: zapis?['slikeDijelovis'],
                                    initialIndex: 0, // Početni indeks slike
                                  ),
                                ),

                                //status
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 39, 142, 176),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.1,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Bijela boja pozadine
                                        borderRadius: BorderRadius.circular(10.0), // Zaobljene ivice
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Status:",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                          Text(
                                            "${zapis?['status'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold, // Boldiran font za drugi dio
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
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: const Color.fromARGB(0, 33, 149, 243), // Druga pozadina
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.23,
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Cijena: ${zapis?['cijena'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Količina: ${zapis?['kolicina'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "Kategorija: ${zapis?['kategorijaId'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        color: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              "Opis: ${zapis?['opis'] ?? 'N/A'}",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17.0,
                                              ),
                                            ),
                                          ),
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
                      Container(
                        height: MediaQuery.of(context).size.height * 0.077,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Zaobljene ivice
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (zapis?['status'] == 'kreiran' || zapis?['status'] == 'izmijenjen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Dijelovi'),
                              _buildISetStatusButton('Vrati', 'Dijelovi'),
                              _buildISetStatusButton('Obrisi', 'Dijelovi'),
                            ] else if (zapis?['status'] == 'aktivan') ...[
                              _buildISetStatusButton('Vrati', 'Dijelovi'),
                              _buildISetStatusButton('Obrisi', 'Dijelovi'),
                            ] else if (zapis?['status'] == 'vracen') ...[
                              _buildISetStatusButton('Aktiviraj', 'Dijelovi'),
                              _buildISetStatusButton('Obrisi', 'Dijelovi'),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text('Greska pri ucitavanju'),
          );
        }
      },
    );
  }

  Widget _buildInfoButton(int odabraniId, String object) {
    return GestureDetector(
      onTap: () {
        setState(() {
          ucitanZapis = false;
          _odabraniId = odabraniId;
          activeTitle = object;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.height * 0.05, // Da bude krug
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 68, 137, 255), // Promijeni boju po želji
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.info, // Možeš promijeniti ikonu po želji
            color: const Color.fromARGB(255, 87, 202, 255),
            size: 35.0,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String title, int odabrani, String statusType) {
    bool isSelected = false;
    switch (statusType) {
      case 'korisnici':
        isSelected = title == _selectedStatus;
      case 'serviseri':
        isSelected = title == _selectedStatusServiseri;
      case 'bicikli':
        isSelected = title == _selectedStatusBicikli;
      case 'dijelovi':
        isSelected = title == _selectedStatusDijelovi;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Color.fromARGB(255, 87, 202, 255) // Izabrana boja
              : Color.fromARGB(255, 255, 255, 255), // Standardna boja
        ),
        onPressed: () {
          _filterStatus(title, odabrani);
        },
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white // Boja teksta kada je dugme odabrano
                : Color.fromARGB(255, 87, 202, 255),
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title, int odabrani) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 87, 202, 255),
        ),
        onPressed: () {
          _toggleSlideri(odabrani);
        },
        child: Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  bool _isSlideVisible = false;
  bool _isSlideVisibleServiseri = false;
  bool _isSlideVisibleBicikli = false;
  bool _isSlideVisibleDijelovi = false;

  void _toggleSlideri(int odabrani) {
    switch (odabrani) {
      case 1:
        setState(() {
          _isSlideVisible = !_isSlideVisible;
          if (_isSlideVisible) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        break;
      case 2:
        setState(() {
          _isSlideVisibleServiseri = !_isSlideVisibleServiseri;
          if (_isSlideVisibleServiseri) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        break;
      case 3:
        setState(() {
          _isSlideVisibleBicikli = !_isSlideVisibleBicikli;
          if (_isSlideVisibleBicikli) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        break;
      case 4:
        setState(() {
          _isSlideVisibleDijelovi = !_isSlideVisibleDijelovi;
          if (_isSlideVisibleDijelovi) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        break;
      default:
        break;
    }
  }

  void handleButtonPress(BuildContext context, String title, int odabrani) {
    switch (title) {
      case 'Postavi status':
        setState(() {
          _isSlideVisible = !_isSlideVisible;
          if (_isSlideVisible) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        break;
      case 'Zatvori':
        if (odabrani == 1) {
          setState(() {
            _isSlideVisible = !_isSlideVisible;
            if (_isSlideVisible) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          });
        }
        break;
      case 'Servis':
        break;
      case 'Zahtjev':
        break;
      case 'Admin':
        break;
      case 'Uredi profil':
        break;
      default:
    }
  }

  Widget adminNavBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.12, // 12% visine ekrana
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navBarButton(context, 'korisnici', Icons.group),
          navBarButton(context, 'serviseri', Icons.build),
          navBarButton(context, 'home', Icons.home),
          navBarButton(context, 'bicikli', Icons.directions_bike),
          navBarButton(context, 'dijelovi', Icons.handyman),
        ],
      ),
    );
  }

  Widget navBarButton(BuildContext context, String title, IconData icon) {
    return IconButton(
      icon: Icon(icon, color: activeTitle == title ? Colors.blue : Colors.black),
      iconSize: 35.0, // Povećanje veličine ikone
      padding: const EdgeInsets.all(16.0), // Povećanje širine dugmića
      onPressed: () {
        _isSlideVisible = false;
        _isSlideVisibleServiseri = false;
        _isSlideVisibleBicikli = false;
        _isSlideVisibleDijelovi = false;
        _controller.reverse();
        navigacija(context, title);
      },
    );
  }
}
