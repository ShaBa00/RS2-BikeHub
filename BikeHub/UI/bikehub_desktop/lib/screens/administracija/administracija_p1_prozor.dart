// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_element, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, unused_local_variable, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:bikehub_desktop/modeli/bicikli/bicikl_model.dart';
import 'package:bikehub_desktop/modeli/bicikli/bicikli_promocija_model.dart';
import 'package:bikehub_desktop/modeli/dijelovi/dijelovi_model.dart';
import 'package:bikehub_desktop/modeli/dijelovi/dijelovi_promocija_model.dart';
import 'package:bikehub_desktop/modeli/korisnik/korisnik_model.dart';
import 'package:bikehub_desktop/modeli/serviseri/serviser_model.dart';
import 'package:bikehub_desktop/screens/administracija/dodatno/image_carousel.dart';
import 'package:bikehub_desktop/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_desktop/screens/ostalo/pomocne_klase.dart';
import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'package:bikehub_desktop/services/bicikli/promocija_bicikli_service.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/dijelovi/promocija_dijelovi_service.dart';
import 'package:bikehub_desktop/services/kategorije/kategorija_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bikehub_desktop/services/serviser/serviser_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AdministracijaP1Prozor extends StatefulWidget {
  const AdministracijaP1Prozor({super.key});

  @override
  _AdministracijaP1ProzorState createState() => _AdministracijaP1ProzorState();
}

class _AdministracijaP1ProzorState extends State<AdministracijaP1Prozor> {
  String _selectedSection = 'Home';
  bool _isLoading = true;

  int odabraniId = 0;

  List _prikazaniKorisnici = [];
  int _currentPageKorisnik = 0;
  int _pageSizeKorisnik = 5;
  int _brojPrikazanihKorisnika = 0;
  String _selectedStatus = 'Kreirani';
  List _listaKorisnika = [];
  int _countKorisnik = 0;

  List _listaAdministratora = [];
  int _countAdministratora = 0;
  int _currentPageAdministrator = 0;
  int _pageSizeAdministrator = 4;

  List _prikazaniBicikli = [];
  int _currentPageBicikli = 0;
  int _pageSizeBicikli = 5;
  int _brojPrikazanihBicikli = 0;
  String _selectedStatusBicikli = 'Kreirani';
  List _listaBicikala = [];
  int _countBicikl = 0;

  List _prikazaniDijelovi = [];
  int _currentPageDijelovi = 0;
  int _pageSizeDijelovi = 5;
  int _brojPrikazanihDijelova = 0;
  String _selectedStatusDijelova = 'Kreirani';
  List _listaDijelova = [];
  int _countDijelovi = 0;

  List _prikazaniServiseri = [];
  int _currentPageServisera = 0;
  int _pageSizeServisera = 5;
  int _brojPrikazanihServisera = 0;
  String _selectedStatusServisera = 'Kreirani';
  List _listaServisera = [];
  int _countServisera = 0;

  List _prikazaniPromocijeB = [];
  int _currentPagePromocijeB = 0;
  int _pageSizePromocijeB = 5;
  int _brojPrikazanihPromocijeB = 0;
  String _selectedStatusPromocijeB = 'Kreirani';

  List _prikazaniPromocijeD = [];
  int _currentPagePromocijeD = 0;
  int _pageSizePromocijeD = 5;
  int _brojPrikazanihPromocijeD = 0;
  String _selectedStatusPromocijeD = 'Kreirani';

  String _username = "";
  final KorisnikService _korisnikService = KorisnikService();
  final BiciklService _bicikliService = BiciklService();
  final DijeloviService _dijeloviService = DijeloviService();
  final ServiserService _serviserService = ServiserService();
  final KategorijaServis _kategorijaServis = KategorijaServis();
  final PromocijaBicikliService _promocijaBicikliService = PromocijaBicikliService();
  final PromocijaDijeloviService _promocijaDijeloviService = PromocijaDijeloviService();

  @override
  void initState() {
    super.initState();
    _fetchPodatci();
  }

  Future _fetchPodatci() async {
    final credentials = await _korisnikService.getCredentials();
    _username = credentials['username']!;
    await _korisnikService.getKorisniks(status: '');
    await _bicikliService.getBicikli(status: '', isSlikaIncluded: false, page: null, pageSize: null);
    await _dijeloviService.getDijelovi(status: '', isSlikaIncluded: false, page: null, pageSize: null);
    await _serviserService.getServiseriDTO(status: '', page: null, pageSize: null);
    getPromovisani();
    await getKategorije();
    setState(() {
      _listaKorisnika = _korisnikService.listaKorisnika;
      _countKorisnik = _korisnikService.countKorisnika;
      _listaBicikala = _bicikliService.listaBicikala;
      _countBicikl = _bicikliService.count;
      _listaDijelova = _dijeloviService.listaDijelova;
      _countDijelovi = _dijeloviService.count;
      _listaAdministratora = _korisnikService.listaAdministratora;
      _countAdministratora = _listaAdministratora.length;
      _listaServisera = _serviserService.listaServisra;
      _countServisera = _listaServisera.length;
      _isLoading = false;
      promovisaniBicikl;
      promovisaniDijelovi;
    });
    await _filterKorisnici("Kreirani");
    await _filterBicikli("Kreirani");
    await _filterDijelovi("Kreirani");
    await _filterServiseri("Kreirani");
    await _filterPromocije("Kreirani");
  }

  List<Map<String, dynamic>> _listaBikeKategorije = [];
  List<Map<String, dynamic>> _listaDijeloviKategorije = [];

  Future<void> getKategorije() async {
    var bikeKategorije = await _kategorijaServis.getBikeKategorije();
    var dijeloviKategorije = await _kategorijaServis.getDijeloviKategorije();

    _listaBikeKategorije = List<Map<String, dynamic>>.from(bikeKategorije);
    _listaDijeloviKategorije = List<Map<String, dynamic>>.from(dijeloviKategorije);
    _filterKategorije("Kreirane");
  }

  List<dynamic> promovisaniBicikl = [];
  List<dynamic> promovisaniDijelovi = [];
  String ukupnaCijenaString = "";
  Future<void> getPromovisani() async {
    promovisaniBicikl = await _promocijaBicikliService.getPromocijaBicikli();
    promovisaniDijelovi = await _promocijaDijeloviService.getPromocijaDijelovi();

    double ukupnaCijena = 0;

    if (promovisaniBicikl != null && promovisaniBicikl.isNotEmpty) {
      for (var item in promovisaniBicikl) {
        ukupnaCijena += item['cijenaPromocije'];
      }
    }

    if (promovisaniDijelovi != null && promovisaniDijelovi.isNotEmpty) {
      for (var item in promovisaniDijelovi) {
        ukupnaCijena += item['cijenaPromocije'];
      }
    }

    ukupnaCijenaString = formatCijena(ukupnaCijena);
  }

  String formatCijena(double cijena) {
    if (cijena >= 1000) {
      return '${(cijena / 1000).toStringAsFixed(2)}K';
    }
    return cijena.toStringAsFixed(2);
  }

  void _loadAdministratori(int page) {
    setState(() {
      _currentPageAdministrator = page;
    });
  }

  _filterPromocije(String status) async {
    String _status;
    _currentPagePromocijeB = 0;
    _currentPagePromocijeD = 0;
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
      case 'Zavrseni':
        _status = 'zavrseno';
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

    setState(() {
      _selectedStatusPromocijeB = status;
      _prikazaniPromocijeB = promovisaniBicikl.where((promocija) => promocija['status'] == _status).toList();
      _brojPrikazanihPromocijeB = _prikazaniPromocijeB.length;
      _prikazaniPromocijeD = promovisaniDijelovi.where((promocija) => promocija['status'] == _status).toList();
      _brojPrikazanihPromocijeD = _prikazaniPromocijeD.length;
    });
  }

  _filterBicikli(String status) async {
    String _status;
    _currentPageBicikli = 0;
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

    setState(() {
      _selectedStatusBicikli = status;
      _prikazaniBicikli = _listaBicikala.where((bicikl) => bicikl['status'] == _status).toList();
      _brojPrikazanihBicikli = _prikazaniBicikli.length;
    });
  }

  _filterDijelovi(String status) async {
    String _status;
    _currentPageDijelovi = 0;
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

    setState(() {
      _selectedStatusDijelova = status;
      _prikazaniDijelovi = _listaDijelova.where((dio) => dio['status'] == _status).toList();
      _brojPrikazanihDijelova = _prikazaniDijelovi.length;
    });
  }

  _filterServiseri(String status) async {
    String _status;
    _currentPageServisera = 0;
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

    setState(() {
      _selectedStatusServisera = status;
      _prikazaniServiseri = _listaServisera.where((serviser) => serviser['status'] == _status).toList();
      _brojPrikazanihServisera = _prikazaniServiseri.length;
    });
  }

  _filterKorisnici(String status) async {
    String _status;
    _currentPageKorisnik = 0;
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

    setState(() {
      _selectedStatus = status;
      _prikazaniKorisnici = _listaKorisnika.where((korisnik) => korisnik['status'] == _status).toList();
      _brojPrikazanihKorisnika = _prikazaniKorisnici.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: Text('Administracija'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  body: Row(
                    children: [
                      _buildNavDio(),
                      _buildSadrzajDio(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNavDio() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 1,
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.13,
            child: Center(
              child: Text(
                'BikeHub',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.lightBlue,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  color: const Color.fromARGB(0, 68, 137, 255),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavButton('Home'),
                      SizedBox(height: 15),
                      _buildNavButton('Korisnici'),
                      SizedBox(height: 15),
                      _buildNavButton('Bicikli'),
                      SizedBox(height: 15),
                      _buildNavButton('Dijelovi'),
                      SizedBox(height: 15),
                      _buildNavButton('Promocije'),
                      SizedBox(height: 15),
                      _buildNavButton('Serviseri'),
                      SizedBox(height: 15),
                      _buildNavButton('Kategorije'),
                      SizedBox(height: 15),
                      _buildNavButton('Dodaj Administratora'),
                      SizedBox(height: 15),
                      _buildNavButton('Izvjestaj'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSadrzajDio() {
    var visina = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: visina,
      color: Color.fromARGB(0, 254, 0, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: visina * 0.13,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(Icons.person, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Administrator: $_username',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildCentralniDio(visina),
          _buildAdministratori(visina),
        ],
      ),
    );
  }

  Widget _buildCentralniDio(var visina) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 249, 238, 238),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _getCentralniDioContent(),
      ),
    );
  }

  Widget _buildAdministratori(var visina) {
    int startIndex = _currentPageAdministrator * _pageSizeAdministrator;
    int endIndex = startIndex + _pageSizeAdministrator;
    List currentAdministratori = _listaAdministratora.sublist(
      startIndex,
      endIndex > _listaAdministratora.length ? _listaAdministratora.length : endIndex,
    );

    return Container(
      width: double.infinity,
      height: visina * 0.25,
      color: Color.fromARGB(0, 38, 255, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: visina * 0.05,
            color: const Color.fromARGB(0, 33, 149, 243),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Administratori:',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: currentAdministratori.length,
                      itemBuilder: (context, index) {
                        final admin = currentAdministratori[index];
                        final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                        return Column(
                          children: [
                            if (index != 0) SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                color: backgroundColor,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 24,
                                          color: Colors.grey[700],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          admin['username'],
                                          style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      admin['email'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacer(),
                                    Text(
                                      admin['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                    SizedBox(width: 10)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPageAdministrator > 0
                            ? () {
                                _loadAdministratori(_currentPageAdministrator - 1);
                              }
                            : null,
                        child: Text('<'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: endIndex < _listaAdministratora.length
                            ? () {
                                _loadAdministratori(_currentPageAdministrator + 1);
                              }
                            : null,
                        child: Text('>'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCentralniDioContent() {
    switch (_selectedSection) {
      case 'Home':
        return _buildHome();
      case 'Izvjestaj':
        return _buildIzvjestaj();
      case 'Promocije':
        return _buildPromocije();
      case 'Korisnici':
        return _buildKorisnici();
      case 'Bicikli':
        return _buildBicikli();
      case 'Dijelovi':
        return _buildDijelovi();
      case 'Dodaj Administratora':
        return _buildDodajAdministratora();
      case 'Korisnik info':
        return _buildKorisnikInfo();
      case 'Bicikli info':
        return _buildBicikliInfo();
      case 'Dijelovi info':
        return _buildDijeloviInfo();
      case 'Serviseri':
        return _buildServiseri();
      case 'Serviser info':
        return _buildServiserInfo();
      case 'Kategorije':
        return _buildKategorije(context);
      case 'Promocija info bicikl':
        return _buildBicikliPromocijaInfo();
      case 'Promocija info dijelovi':
        return _buildDijeloviPromocijaInfo();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Korisnici';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.25,
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
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Korisnici',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countKorisnik\nBroj korisnika',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Serviseri';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.25,
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
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Serviseri',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countServisera\nBroj servisera',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Bicikli';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.25,
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
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Bicikli',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countBicikl\nBroj bicikala',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Dijelovi';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.25,
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
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Dijelovi',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countDijelovi\nBroj dijelova',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> printIzvjestajPromocije(BuildContext context) async {
    try {
      var podatci = await _promocijaBicikliService.getIzvjestajPromocije();

      final pdf = pw.Document();

      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'Izvjestaj Promocija',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Divider(),
                  pw.Text(
                    'Generisano: $now',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Ovaj izvjestaj sadrzi detaljne informacije o promocijama koje su aktivne ili su bile aktivne u datom periodu.',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Osnovne informacije:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Ukupna zarada: ${(podatci['ukupnaZarada']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Broj promocija: ${(podatci['brojPromocija']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Broj aktivnih promocija: ${(podatci['brojAktivnihPromocija']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Promocije u trenutnom mjesecu:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Zbir cijene promocija: ${(podatci['zbirCijenePromocijaTrenutniMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Broj promocija: ${(podatci['brojPromocijaTrenutniMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Promocije u proslom mjesecu:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Zbir cijene promocija: ${(podatci['zbirCijenePromocijaProsliMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Broj promocija: ${(podatci['brojPromocijaProsliMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Najbolji rezultati:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Mjesec sa najviše promocija: ${(podatci['mjesecSaNajvisePromocija']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Najveća zarada mjeseca: ${(podatci['najvecaZaradaMjeseca']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Zakljucak:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Promocije su kljucan dio poslovanja, omogucavajuci povecanje prodaje i dosega.',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Preporucuje se analiziranje podataka kako bi se identificirale najbolje strategije.',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      );
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Odaberite lokaciju za spremanje PDF-a',
        fileName: 'izvjestaj_promocija.pdf',
      );

      if (outputFile != null) {
        final file = File(outputFile);

        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izvještaj je uspješno sačuvan!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odabir lokacije za spremanje je otkazan.'),
          ),
        );
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> printIzvjestajServisera(BuildContext context) async {
    try {
      var podatci = await _serviserService.getServiserIzvjestaj();

      final pdf = pw.Document();

      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'Izvjestaj Servisera',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Divider(),
                  pw.Text(
                    'Generisano: $now',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Ovaj izvjestaj sadrzi detaljne informacije o servisima koji su bili aktivni ili su trenutno aktivni.',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Osnovne informacije:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Najaktivniji serviser: ${(podatci['najaktivnijiServiser']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Broj zavrsenih servisa: ${(podatci['brojZavrsenihServisa']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Zbir cijena zavrsenih servisa: ${(podatci['zbirCijenaZavrsenihServisa']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Najbolji serviser u trenutnom mjesecu:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Ime: ${(podatci['najboljiServiserTrenutniMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Zbir cijena servisa: ${(podatci['zbirCijenaTrenutniMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Prosjecna ocjena: ${(podatci['prosjecnaOcjenaTrenutniMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Najbolji serviser u proslom mjesecu:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Ime: ${(podatci['najboljiServiserProsliMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Zbir cijena servisa: ${(podatci['zbirCijenaProsliMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Prosjecna ocjena: ${(podatci['prosjecnaOcjenaProsliMjesec']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Ostale informacije:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Bullet(
                    text: 'Ukupan broj servisera: ${(podatci['ukupanBrojServisera']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Bullet(
                    text: 'Ukupan broj rezervacija: ${(podatci['ukupanBrojRezervacija']?.toString() ?? 'N/A')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      );

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Odaberite lokaciju za spremanje PDF-a',
        fileName: 'izvjestaj_servisera.pdf',
      );

      if (outputFile != null) {
        final file = File(outputFile);

        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izvještaj je uspješno sačuvan!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odabir lokacije za spremanje je otkazan.'),
          ),
        );
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Widget _buildIzvjestaj() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                await printIzvjestajPromocije(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.35,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Promocije',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.26,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.08,
                            color: const Color.fromARGB(0, 244, 67, 54),
                            child: Center(
                                child: Container(
                              width: MediaQuery.of(context).size.width * 0.17,
                              height: MediaQuery.of(context).size.height * 0.07,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Broj promocija ${promovisaniBicikl.length + promovisaniDijelovi.length}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.017,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.08,
                            color: const Color.fromARGB(0, 76, 175, 79),
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.17,
                                height: MediaQuery.of(context).size.height * 0.07,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white),
                                    right: BorderSide(color: Colors.white),
                                    left: BorderSide(color: Colors.white),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "$ukupnaCijenaString KM",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width * 0.017,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Izvjestaj",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.017,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                await printIzvjestajServisera(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.35,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Serviseri',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.26,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.08,
                            color: const Color.fromARGB(0, 244, 67, 54),
                            child: Center(
                                child: Container(
                              width: MediaQuery.of(context).size.width * 0.17,
                              height: MediaQuery.of(context).size.height * 0.07,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Broj Servisera ${promovisaniBicikl.length + promovisaniDijelovi.length}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.017,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Izvjestaj",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.017,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
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
    );
  }

  Widget _buildKorisnici() {
    int startIndex = _currentPageKorisnik * _pageSizeKorisnik;
    int endIndex = startIndex + _pageSizeKorisnik;
    List currentKorisnici = _prikazaniKorisnici.sublist(
      startIndex,
      endIndex > _prikazaniKorisnici.length ? _prikazaniKorisnici.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Korisnici',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButton('Kreirani'),
                _buildStatusButton('Izmijenjeni'),
                _buildStatusButton('Aktivni'),
                _buildStatusButton('Obrisani'),
                _buildStatusButton('Vraceni'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  color: const Color.fromARGB(0, 33, 149, 243),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: currentKorisnici.length,
                    itemBuilder: (context, index) {
                      final korisnik = currentKorisnici[index];
                      final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                      return Column(
                        children: [
                          if (index != 0) SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: backgroundColor,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.supervised_user_circle_rounded,
                                    size: 24,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      korisnik['username'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      korisnik['email'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      korisnik['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        odabraniId = korisnik['korisnikId'];
                                        _selectedSection = "Korisnik info";
                                      });
                                    },
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBicikli() {
    int startIndex = _currentPageBicikli * _pageSizeBicikli;
    int endIndex = startIndex + _pageSizeBicikli;
    List currentBicikli = _prikazaniBicikli.sublist(
      startIndex,
      endIndex > _prikazaniBicikli.length ? _prikazaniBicikli.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Bicikli',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButtonBicikl('Kreirani'),
                _buildStatusButtonBicikl('Izmijenjeni'),
                _buildStatusButtonBicikl('Aktivni'),
                _buildStatusButtonBicikl('Obrisani'),
                _buildStatusButtonBicikl('Vraceni'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  color: const Color.fromARGB(0, 33, 149, 243),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: currentBicikli.length,
                    itemBuilder: (context, index) {
                      final bicikl = currentBicikli[index];
                      final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                      return Column(
                        children: [
                          if (index != 0) SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: backgroundColor,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pedal_bike,
                                    size: 24,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bicikl['naziv'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bicikl['cijena'].toString(),
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bicikl['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        odabraniId = bicikl['biciklId'];
                                        _selectedSection = "Bicikli info";
                                      });
                                    },
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDijelovi() {
    int startIndex = _currentPageDijelovi * _pageSizeDijelovi;
    int endIndex = startIndex + _pageSizeDijelovi;
    List currentDijelovi = _prikazaniDijelovi.sublist(
      startIndex,
      endIndex > _prikazaniDijelovi.length ? _prikazaniDijelovi.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Dijelovi',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButtonDijelovi('Kreirani'),
                _buildStatusButtonDijelovi('Izmijenjeni'),
                _buildStatusButtonDijelovi('Aktivni'),
                _buildStatusButtonDijelovi('Obrisani'),
                _buildStatusButtonDijelovi('Vraceni'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  color: const Color.fromARGB(0, 33, 149, 243),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: currentDijelovi.length,
                    itemBuilder: (context, index) {
                      final dijelovi = currentDijelovi[index];
                      final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                      return Column(
                        children: [
                          if (index != 0) SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: backgroundColor,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.construction,
                                    size: 24,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dijelovi['naziv'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      dijelovi['cijena'].toString(),
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      dijelovi['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        odabraniId = dijelovi['dijeloviId'];
                                        _selectedSection = "Dijelovi info";
                                      });
                                    },
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPageDijelovi > 0
                          ? () {
                              setState(() {
                                _currentPageDijelovi--;
                              });
                            }
                          : null,
                      child: Text('<'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: endIndex < _prikazaniDijelovi.length
                          ? () {
                              setState(() {
                                _currentPageDijelovi++;
                              });
                            }
                          : null,
                      child: Text('>'),
                    ),
                  ],
                ),
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiseri() {
    int startIndex = _currentPageServisera * _pageSizeServisera;
    int endIndex = startIndex + _pageSizeServisera;
    List currentServiser = _prikazaniServiseri.sublist(
      startIndex,
      endIndex > _prikazaniServiseri.length ? _prikazaniServiseri.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Serviseri',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButtonServiseri('Kreirani'),
                _buildStatusButtonServiseri('Izmijenjeni'),
                _buildStatusButtonServiseri('Aktivni'),
                _buildStatusButtonServiseri('Obrisani'),
                _buildStatusButtonServiseri('Vraceni'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  color: const Color.fromARGB(0, 33, 149, 243),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: currentServiser.length,
                    itemBuilder: (context, index) {
                      final serviseri = currentServiser[index];
                      final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                      return Column(
                        children: [
                          if (index != 0) SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: backgroundColor,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.miscellaneous_services,
                                    size: 24,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      serviseri['username'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      serviseri['grad'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      serviseri['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        odabraniId = serviseri['serviserId'];
                                        _selectedSection = "Serviser info";
                                      });
                                    },
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPageServisera > 0
                          ? () {
                              setState(() {
                                _currentPageServisera--;
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
                                _currentPageServisera++;
                              });
                            }
                          : null,
                      child: Text('>'),
                    ),
                  ],
                ),
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromocije() {
    int startIndexB = _currentPagePromocijeB * _pageSizePromocijeB;
    int endIndexB = startIndexB + _pageSizePromocijeB;
    List currentPromocijeB = _prikazaniPromocijeB.sublist(
      startIndexB,
      endIndexB > _prikazaniPromocijeB.length ? _prikazaniPromocijeB.length : endIndexB,
    );

    int startIndexD = _currentPagePromocijeD * _pageSizePromocijeD;
    int endIndexD = startIndexD + _pageSizePromocijeD;
    List currentPromocijeD = _prikazaniPromocijeD.sublist(
      startIndexD,
      endIndexD > _prikazaniPromocijeD.length ? _prikazaniPromocijeD.length : endIndexD,
    );

    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Promocije',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButtonPromocije('Kreirani'),
                _buildStatusButtonPromocije('Izmijenjeni'),
                _buildStatusButtonPromocije('Aktivni'),
                _buildStatusButtonPromocije('Zavrseni'),
                _buildStatusButtonPromocije('Obrisani'),
                _buildStatusButtonPromocije('Vraceni'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          itemCount: currentPromocijeB.length,
                          itemBuilder: (context, index) {
                            final promocijeB = currentPromocijeB[index];
                            final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                            return Column(
                              children: [
                                if (index != 0) SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    color: backgroundColor,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.directions_bike,
                                          size: 24,
                                          color: Colors.grey[700],
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            promocijeB['datumPocetka'].split('T')[0].replaceAll('-', '.'),
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            promocijeB['datumZavrsetka'].split('T')[0].replaceAll('-', '.'),
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            promocijeB['status'],
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedPromocija = promocijeB;

                                              _selectedSection = "Promocija info bicikl";
                                            });
                                          },
                                          child: Text(
                                            "Više informacija",
                                            style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPagePromocijeB > 0
                                ? () {
                                    setState(() {
                                      _currentPagePromocijeB--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndexB < _prikazaniPromocijeB.length
                                ? () {
                                    setState(() {
                                      _currentPagePromocijeB++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          itemCount: currentPromocijeD.length,
                          itemBuilder: (context, index) {
                            final promocijeD = currentPromocijeD[index];
                            final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                            return Column(
                              children: [
                                if (index != 0) SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    color: backgroundColor,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          size: 24,
                                          color: Colors.grey[700],
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            promocijeD['datumPocetka'].split('T')[0].replaceAll('-', '.'),
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            promocijeD['datumZavrsetka'].split('T')[0].replaceAll('-', '.'),
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            promocijeD['status'],
                                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedPromocija = promocijeD;

                                              _selectedSection = "Promocija info dijelovi";
                                            });
                                          },
                                          child: Text(
                                            "Više informacija",
                                            style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPagePromocijeD > 0
                                ? () {
                                    setState(() {
                                      _currentPagePromocijeD--;
                                    });
                                  }
                                : null,
                            child: Text('<'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: endIndexD < _prikazaniPromocijeD.length
                                ? () {
                                    setState(() {
                                      _currentPagePromocijeD++;
                                    });
                                  }
                                : null,
                            child: Text('>'),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  late Map<String, dynamic> selectedPromocija;

  final _usernameController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();
  final _emailController = TextEditingController();

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

    KorisnikModel noviAdministrator = KorisnikModel(
      korisnikId: 0,
      username: _usernameController.text,
      staraLozinka: "",
      lozinka: _lozinkaController.text,
      lozinkaPotvrda: _lozinkaPotvrdaController.text,
      email: _emailController.text,
      stanje: "",
      ak: 0,
      isAdmin: true,
    );

    try {
      final responseMessage = await _korisnikService.postAdmina(noviAdministrator);
      if (responseMessage == "Administrator uspješno dodan") {
        PorukaHelper.prikaziPorukuUspjeha(context, responseMessage!);
        _usernameController.clear();
        _lozinkaController.clear();
        _lozinkaPotvrdaController.clear();
        _emailController.clear();
      } else {
        PorukaHelper.prikaziPorukuUpozorenja(context, responseMessage ?? "Došlo je do greške prilikom dodavanja administratora");
      }
    } catch (e) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Došlo je do greške: $e");
    }
  }

  Widget _buildDodajAdministratora() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.553,
      child: Column(
        children: [
          Expanded(
            flex: 15,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 33, 149, 243),
              child: Center(
                child: Text(
                  'Dodavanje novog administratora',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 85,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 82, 205, 210),
                        Color.fromARGB(255, 7, 161, 235),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.18,
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.18,
                        child: TextField(
                          controller: _lozinkaController,
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.18,
                        child: TextField(
                          controller: _lozinkaPotvrdaController,
                          decoration: InputDecoration(
                            labelText: 'Potvrda Lozinke',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.18,
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: dodajAdministratora,
                        child: Text(
                          'Dodaj',
                          style: TextStyle(
                            color: Colors.blue,
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
    );
  }

  promjeniStatus(String status, String objekat) async {
    String _status;

    switch (status) {
      case "Aktiviraj":
        _status = "aktivan";
        break;
      case "Vrati":
        _status = "vracen";
        break;
      case "Obrisi":
        bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, 'Da li ste sigurni da želite obrisati ovaj zapis?');
        if (confirmed != true) {
          return;
        }
        _status = "obrisan";
        break;
      default:
        return;
    }
    if (objekat == "Korisnik") {
      KorisnikModel korisnik = KorisnikModel(
        korisnikId: odabraniId,
        username: '',
        staraLozinka: '',
        lozinka: '',
        lozinkaPotvrda: '',
        email: '',
        stanje: _status,
        ak: 1,
        isAdmin: false,
      );
      try {
        await _korisnikService.upravljanjeKorisnikom(korisnik);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspješno azuriran.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju korisnika: $e");
      }
    }
    if (objekat == "Bicikl") {
      Bicikl bicikl = Bicikl(
        biciklId: odabraniId,
        naziv: "",
        cijena: 0,
        velicinaRama: "",
        velicinaTocka: "",
        brojBrzina: 0,
        kategorijaId: 0,
        kolicina: 0,
        korisnikId: 0,
        stanje: _status,
        ak: 1,
      );
      try {
        await _bicikliService.upravljanjeBiciklom(bicikl);
        PorukaHelper.prikaziPorukuUspjeha(context, "Bicikl uspješno azuriran.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju bicikla: $e");
      }
    }
    if (objekat == "Dijelovi") {
      Dijelovi dijelovi = Dijelovi(
        dijeloviId: odabraniId,
        naziv: "",
        cijena: 0,
        opis: "",
        kategorijaId: 0,
        kolicina: 0,
        korisnikId: 0,
        stanje: _status,
        ak: 1,
      );
      try {
        await _dijeloviService.upravljanjeDijelom(dijelovi);
        PorukaHelper.prikaziPorukuUspjeha(context, "Dijelovi uspješno azurirani.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju Dijelova: $e");
      }
    }
    if (objekat == "Serviser") {
      ServiserModel serviser = ServiserModel(
        korisnikId: 0,
        username: '',
        stanje: _status,
        ak: 1,
        serviserId: odabraniId,
        brojServisa: 0,
        cijena: 0,
        ukupnaOcjena: 0,
        grad: '',
      );
      try {
        await _serviserService.upravljanjeServiserom(serviser);
        PorukaHelper.prikaziPorukuUspjeha(context, "Serviser uspješno azuriran.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju servisera: $e");
      }
    }
    if (objekat == "DijeloviPromocija") {
      DijeloviPromocijaModel promocija = DijeloviPromocijaModel(
        stanje: _status,
        ak: 1,
        promocijaDijeloviId: selectedPromocija['promocijaDijeloviId'],
      );
      try {
        await _promocijaDijeloviService.upravljanjePromocijomDijelovi(promocija);
        PorukaHelper.prikaziPorukuUspjeha(context, "Promocija uspješno azuriran.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju promocije: $e");
      }
      setState(() {
        _selectedSection = "Promocije";
      });
    }
    if (objekat == "BicikliPromocija") {
      BicikliPromocijaModel promocija = BicikliPromocijaModel(
        stanje: _status,
        ak: 1,
        promocijaBicikliId: selectedPromocija['promocijaBicikliId'],
      );
      try {
        await _promocijaBicikliService.upravljanjePromocijomBicikl(promocija);
        PorukaHelper.prikaziPorukuUspjeha(context, "Promocija uspješno azuriran.");
        await _fetchPodatci();
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju promocije: $e");
      }
      setState(() {
        _selectedSection = "Promocije";
      });
    }
  }

  Widget _buildKorisnikInfo() {
    return FutureBuilder(
      future: _korisnikService.getKorisnikByID(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja korisnika',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              'Korisnik nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var korisnik = snapshot.data as Map;
          var korisnikInfo = korisnik['korisnikInfos'] != null && korisnik['korisnikInfos'].isNotEmpty ? korisnik['korisnikInfos'][0] : {};
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Username', korisnik['username'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('User ID', korisnik['korisnikId'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer(
                                      'Admin',
                                      korisnik == null || korisnik['isAdmin'] == null
                                          ? 'N/A'
                                          : korisnik['isAdmin']
                                              ? 'Da'
                                              : 'Ne',
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('', korisnik['email'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Ime i Prezime', korisnikInfo['imePrezime'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Telefon', korisnikInfo['telefon'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Broj Narudbi', korisnikInfo['brojNarudbi'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Broj Servisa', korisnikInfo['brojServisa'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status info', korisnikInfo['status'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Broj Proizvoda', korisnik['brojProizvoda'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Broj Rezervacija', korisnik['brojRezervacija'] ?? 'N/A'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer(
                                      'Serviser',
                                      korisnik == null || korisnik['jeServiser'] == null
                                          ? 'N/A'
                                          : korisnik['jeServiser'] == "aktivan"
                                              ? 'Da'
                                              : 'Ne',
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status korisnika', korisnik['status'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 0),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (korisnik['status'] == "kreiran" || korisnik['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Korisnik"),
                                SizedBox(width: 10),
                              ],
                              if (korisnik['status'] != "obrisan") ...[
                                if (korisnik['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Korisnik"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Korisnik"),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBicikliInfo() {
    return FutureBuilder(
      future: _bicikliService.getBiciklById(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja bicikla',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null)) {
          return Center(
            child: Text(
              'Biciklo nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var bicikl = snapshot.data as Map;
          var slikeBiciklis = bicikl['slikeBiciklis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', bicikl['naziv']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Cijena', bicikl['cijena']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Velicina Rama', bicikl['velicinaRama']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Velicina Tocka', bicikl['velicinaTocka']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeBiciklis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Broj Brzina', bicikl['brojBrzina']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Kolicina', bicikl['kolicina']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Kategorija Id', bicikl['kategorijaId']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status bicikla', bicikl['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (bicikl['status'] == "kreiran" || bicikl['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Bicikl"),
                                SizedBox(width: 10),
                              ],
                              if (bicikl['status'] != "obrisan") ...[
                                if (bicikl['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Bicikl"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Bicikl"),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBicikliPromocijaInfo() {
    return FutureBuilder(
      future: _bicikliService.getBiciklById(selectedPromocija['biciklId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja bicikla',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null)) {
          return Center(
            child: Text(
              'Biciklo nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var bicikl = snapshot.data as Map;
          var slikeBiciklis = bicikl['slikeBiciklis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', bicikl['naziv']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Cijena', bicikl['cijena']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Kolicina', bicikl['kolicina']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeBiciklis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Promovisan od:', selectedPromocija['datumPocetka'].split('T')[0].replaceAll('-', '.')),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Promovisan do:', selectedPromocija['datumZavrsetka'].split('T')[0].replaceAll('-', '.')),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status', selectedPromocija['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (selectedPromocija['status'] != "zavrseno") ...[
                                if (selectedPromocija['status'] == "kreiran" || bicikl['status'] == "izmijenjen") ...[
                                  _buildSetStatusButton("Aktiviraj", "BicikliPromocija"),
                                  SizedBox(width: 10),
                                ],
                                if (selectedPromocija['status'] != "obrisan") ...[
                                  if (selectedPromocija['status'] != "vracen") ...[
                                    _buildSetStatusButton("Vrati", "BicikliPromocija"),
                                    SizedBox(width: 10),
                                  ],
                                  _buildSetStatusButton("Obrisi", "BicikliPromocija"),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDijeloviPromocijaInfo() {
    return FutureBuilder(
      future: _dijeloviService.getDijeloviById(selectedPromocija['dijeloviId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja dijela',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null)) {
          return Center(
            child: Text(
              'Dio nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var dio = snapshot.data as Map;
          var slikeDijelovis = dio['slikeDijelovis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', dio['naziv']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Cijena', dio['cijena']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Kolicina', dio['kolicina']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeDijelovis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Promovisan od:', selectedPromocija['datumPocetka'].split('T')[0].replaceAll('-', '.')),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Promovisan do:', selectedPromocija['datumZavrsetka'].split('T')[0].replaceAll('-', '.')),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status', selectedPromocija['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (selectedPromocija['status'] != "zavrseno") ...[
                                if (selectedPromocija['status'] == "kreiran" || selectedPromocija['status'] == "izmijenjen") ...[
                                  _buildSetStatusButton("Aktiviraj", "DijeloviPromocija"),
                                  SizedBox(width: 10),
                                ],
                                if (selectedPromocija['status'] != "obrisan") ...[
                                  if (selectedPromocija['status'] != "vracen") ...[
                                    _buildSetStatusButton("Vrati", "DijeloviPromocija"),
                                    SizedBox(width: 10),
                                  ],
                                  _buildSetStatusButton("Obrisi", "DijeloviPromocija"),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDijeloviInfo() {
    return FutureBuilder(
      future: _dijeloviService.getDijeloviById(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja dijela',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null)) {
          return Center(
            child: Text(
              'Dio nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var dio = snapshot.data as Map;
          var slikeDijelovis = dio['slikeDijelovis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', dio['naziv']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Cijena', dio['cijena']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Kolicina', dio['kolicina']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeDijelovis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('KategorijaId', dio['kategorijaId']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status dijela', dio['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dio['status'] == "kreiran" || dio['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Dijelovi"),
                                SizedBox(width: 10),
                              ],
                              if (dio['status'] != "obrisan") ...[
                                if (dio['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Dijelovi"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Dijelovi"),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildServiserInfo() {
    return FutureBuilder(
      future: _serviserService.getServiserDtoByKorisnikId(serviserId: odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja servisera',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              'Serviser nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var serviser = snapshot.data as Map;
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Username', serviser['username'] ?? 'null'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Serviser Id', serviser['serviserId'] ?? 'null'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('User ID', serviser['korisnikId'] ?? 'null'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Grad', serviser['grad'] ?? 'null'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Cijena', serviser['cijena'] ?? 'null'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Broj servisa', serviser['brojServisa'] ?? 'null'),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Ukupna ocjena', serviser['ukupnaOcjena']),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.008,
                                    ),
                                    _buildDetailContainer('Status servisera', serviser['status'] ?? 'null'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 0),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (serviser['status'] == "kreiran" || serviser['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Serviser"),
                                SizedBox(width: 10),
                              ],
                              if (serviser['status'] != "obrisan") ...[
                                if (serviser['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Serviser"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Serviser"),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // kategorije
  //zajednicko
  int _itemsPerPage = 5;
  String _selectedStatusKategorije = 'Kreirane';

  //dijelovi
  String nazivNoveD = "";
  int _currentPageD = 0;
  String _selectedSectionKategorijaDijelovi = 'Home';
  String odabraniD = "Kategorija za";
  List<Map<String, dynamic>> _filteredKategorijeD = [];
  var odabranaKategorijaD;

  //bicikl
  String nazivNove = "";
  int _currentPage = 0;
  String _selectedSectionKategorija = 'Home';
  String odabraniK = "Kategorija za";
  List<Map<String, dynamic>> _filteredKategorije = [];
  var odabranaKategorija;

  Widget _buildKategorije(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Kategorije',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                _buildStatusButtonKategorije('Kreirane'),
                _buildStatusButtonKategorije('Izmijenjene'),
                _buildStatusButtonKategorije('Aktivne'),
                _buildStatusButtonKategorije('Obrisane'),
                _buildStatusButtonKategorije('Vracene'),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(0, 33, 149, 243),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.375,
                          height: MediaQuery.of(context).size.height * 0.07,
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
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.height * 0.07,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  "Bicikl kategorije",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.075,
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.lightBlue,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _selectedSectionKategorija == 'Home' ? Icons.add : Icons.arrow_back,
                                      ),
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedSectionKategorija == 'Nova') {
                                            _selectedSectionKategorija = 'Home';
                                            odabraniK = "Kategorija za";
                                            nazivNove = "";
                                          } else if (_selectedSectionKategorija == 'Info') {
                                            _selectedSectionKategorija = 'Home';
                                            odabraniK = "Kategorija za";
                                            nazivNove = "";
                                          } else {
                                            odabraniK = "Za bicikl";
                                            nazivNove = "";
                                            _selectedSectionKategorija = 'Nova';
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _getKategorijaContent(context),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(0, 33, 149, 243),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.375,
                          height: MediaQuery.of(context).size.height * 0.07,
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
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.height * 0.07,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  "Dijelovi kategorije",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.075,
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.lightBlue,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _selectedSectionKategorijaDijelovi == 'Home' ? Icons.add : Icons.arrow_back,
                                      ),
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedSectionKategorijaDijelovi == 'Nova') {
                                            _selectedSectionKategorijaDijelovi = 'Home';
                                            odabraniD = "Kategorija za";
                                            nazivNoveD = "";
                                          } else if (_selectedSectionKategorijaDijelovi == 'Info') {
                                            _selectedSectionKategorijaDijelovi = 'Home';
                                            odabraniD = "Kategorija za";
                                            nazivNoveD = "";
                                          } else {
                                            odabraniD = "Za dijelove";
                                            nazivNoveD = "";
                                            _selectedSectionKategorijaDijelovi = 'Nova';
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _getKategorijaContentDijelovi(context),
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
    );
  }

  Widget _getKategorijaContentDijelovi(BuildContext context) {
    switch (_selectedSectionKategorijaDijelovi) {
      case 'Home':
        return _buildKategorijaListaDijelovi(context);
      case 'Info':
        return _buildKategorijaInfoDijelovi(context);
      case 'Nova':
        return _buildKategorijaNovaDijelovi(context);
      default:
        return _buildKategorijaListaDijelovi(context);
    }
  }

  Widget _getKategorijaContent(BuildContext context) {
    switch (_selectedSectionKategorija) {
      case 'Home':
        return _buildKategorijaLista(context);
      case 'Info':
        return _buildKategorijaInfo(context);
      case 'Nova':
        return _buildKategorijaNova(context);
      default:
        return _buildKategorijaLista(context);
    }
  }

  Widget _buildKategorijaListaDijelovi(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Map<String, dynamic>> paginatedKategorije = _filteredKategorijeD.skip(_currentPageD * _itemsPerPage).take(_itemsPerPage).toList();
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.75,
                child: ListView.builder(
                  itemCount: paginatedKategorije.length,
                  itemBuilder: (context, index) {
                    var kategorija = paginatedKategorije[index];
                    return Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            odabraniD = "Za dijelove";
                            nazivNoveD = "";
                            odabranaKategorijaD = kategorija;
                            _selectedSectionKategorijaDijelovi = "Info";
                          });
                        },
                        child: Container(
                          width: constraints.maxWidth * 0.9,
                          height: constraints.maxHeight * 0.1,
                          margin: EdgeInsets.symmetric(vertical: 9.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 7, 161, 235),
                                Color.fromARGB(255, 82, 205, 210),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    kategorija['status'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.03,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    kategorija['naziv'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.03,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: Container(
                                  width: constraints.maxWidth * 0.25,
                                  height: constraints.maxHeight * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 3, 199, 253),
                                        fontSize: constraints.maxWidth * 0.03,
                                      ),
                                    ),
                                  ),
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
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPageD > 0
                          ? () {
                              setState(() {
                                _currentPageD--;
                              });
                            }
                          : null,
                      child: Text("<"),
                    ),
                    ElevatedButton(
                      onPressed: (_currentPageD + 1) * _itemsPerPage < _filteredKategorijeD.length
                          ? () {
                              setState(() {
                                _currentPageD++;
                              });
                            }
                          : null,
                      child: Text(">"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKategorijaNova(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.375,
      height: MediaQuery.of(context).size.height * 0.397,
      color: const Color.fromARGB(0, 244, 67, 54),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.17,
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 82, 205, 210),
                Color.fromARGB(255, 7, 161, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.05,
                color: const Color.fromARGB(0, 244, 67, 54),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.18,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.015,
                      color: const Color.fromARGB(0, 76, 175, 79),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Naziv",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.013,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.013,
                          ),
                          onChanged: (text) {
                            nazivNove = text;
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.03,
                      color: const Color.fromARGB(0, 76, 175, 79),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: odabraniK.isEmpty ? null : odabraniK,
                          hint: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Kategorija za",
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          items: <String>['Za bicikl', 'Za dijelove', 'Kategorija za'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              odabraniK = newValue!;
                            });
                          },
                          underline: SizedBox(),
                          iconSize: 0.0,
                          dropdownColor: Color.fromARGB(255, 6, 205, 250),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.07,
                color: const Color.fromARGB(0, 33, 149, 243),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 87, 202, 255),
                      ),
                      onPressed: () {
                        addNovaKategorija(true);
                      },
                      child: Text(
                        "Sacuvaj",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKategorijaNovaDijelovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.375,
      height: MediaQuery.of(context).size.height * 0.397,
      color: const Color.fromARGB(0, 244, 67, 54),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.17,
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 7, 161, 235),
                Color.fromARGB(255, 82, 205, 210),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.05,
                color: const Color.fromARGB(0, 244, 67, 54),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.18,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.015,
                      color: const Color.fromARGB(0, 76, 175, 79),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Naziv",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.013,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.013,
                          ),
                          onChanged: (text) {
                            nazivNoveD = text;
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.03,
                      color: const Color.fromARGB(0, 76, 175, 79),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: odabraniD.isEmpty ? null : odabraniD,
                          hint: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Kategorija za",
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          items: <String>['Za bicikl', 'Za dijelove', 'Kategorija za'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              odabraniD = newValue!;
                            });
                          },
                          underline: SizedBox(),
                          iconSize: 0.0,
                          dropdownColor: Color.fromARGB(255, 6, 205, 250),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                height: MediaQuery.of(context).size.height * 0.07,
                color: const Color.fromARGB(0, 33, 149, 243),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 87, 202, 255),
                      ),
                      onPressed: () {
                        addNovaKategorija(false);
                      },
                      child: Text(
                        "Sacuvaj",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKategorijaInfo(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.375,
      height: MediaQuery.of(context).size.height * 0.397,
      child: Stack(
        children: [
          ClipPath(
            clipper: DiagonalClipper(isTop: true),
            child: Container(
              color: const Color.fromARGB(0, 244, 67, 54),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if (odabranaKategorija != null && odabranaKategorija['status'] == 'kreiran' || odabranaKategorija['status'] == 'izmijenjen') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('aktiviraj', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Aktiviraj',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('vrati', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 208, 210, 82),
                              Color.fromARGB(255, 212, 235, 7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Vrati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (odabranaKategorija != null && odabranaKategorija['status'] == 'aktivan') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('vrati', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 208, 210, 82),
                              Color.fromARGB(255, 212, 235, 7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Vrati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (odabranaKategorija != null && odabranaKategorija['status'] == 'vracen') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('aktiviraj', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Aktiviraj',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ClipPath(
            clipper: DiagonalClipper(isTop: false),
            child: Container(
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
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Naziv",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.01,
                        ),
                        onChanged: (text) {
                          nazivNove = text;
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: DropdownButton<String>(
                        value: odabraniK.isEmpty ? null : odabraniK,
                        hint: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Kategorija za",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        items: <String>['Za bicikl', 'Za dijelove', 'Kategorija za'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            odabraniK = newValue!;
                          });
                        },
                        underline: SizedBox(),
                        iconSize: 0.0,
                        dropdownColor: Color.fromARGB(255, 6, 205, 250),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  GestureDetector(
                    onTap: () {
                      izmjeniKategoriju(true);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.07,
                      ),
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Izmjeni",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategorijaInfoDijelovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.375,
      height: MediaQuery.of(context).size.height * 0.397,
      child: Stack(
        children: [
          ClipPath(
            clipper: DiagonalClipper(isTop: true),
            child: Container(
              color: const Color.fromARGB(0, 244, 67, 54),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if (odabranaKategorijaD != null && odabranaKategorijaD['status'] == 'kreiran' || odabranaKategorijaD['status'] == 'izmijenjen') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('aktiviraj', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Aktiviraj',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('vrati', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 208, 210, 82),
                              Color.fromARGB(255, 212, 235, 7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Vrati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (odabranaKategorijaD != null && odabranaKategorijaD['status'] == 'aktivan') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('vrati', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 208, 210, 82),
                              Color.fromARGB(255, 212, 235, 7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Vrati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (odabranaKategorijaD != null && odabranaKategorijaD['status'] == 'vracen') ...[
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('aktiviraj', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Aktiviraj',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
                        upravljanjeKategorijom('obrisi', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                        ),
                        width: MediaQuery.of(context).size.width * 0.07,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 210, 82, 101),
                              Color.fromARGB(255, 235, 7, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Obrisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ClipPath(
            clipper: DiagonalClipper(isTop: false),
            child: Container(
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
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Naziv",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.01,
                        ),
                        onChanged: (text) {
                          nazivNoveD = text;
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: DropdownButton<String>(
                        value: odabraniD.isEmpty ? null : odabraniD,
                        hint: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Kategorija za",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        items: <String>['Za bicikl', 'Za dijelove', 'Kategorija za'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            odabraniD = newValue!;
                          });
                        },
                        underline: SizedBox(),
                        iconSize: 0.0,
                        dropdownColor: Color.fromARGB(255, 6, 205, 250),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  GestureDetector(
                    onTap: () {
                      izmjeniKategoriju(false);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.07,
                      ),
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Izmjeni",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> izmjeniKategoriju(bool isBike) async {
    String naziv = isBike ? nazivNove : nazivNoveD;
    String odabrani = isBike ? odabraniK : odabraniD;
    var odabranaKategorijaa = isBike ? odabranaKategorija : odabranaKategorijaD;

    if (naziv.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potreno je unijeti naziv");
      return;
    }
    if (odabrani == "Kategorija za") {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potreno je odabrati vrstu kategorije");
      return;
    }

    bool isBikeKategorija = odabrani == "Za bicikl";
    String poruka = await _kategorijaServis.updateKategorija(odabranaKategorijaa['kategorijaId'], naziv, isBikeKategorija);

    if (poruka == "Uspjesno ažurirana kategorija") {
      PorukaHelper.prikaziPorukuUspjeha(context, poruka);
      await getKategorije();
      setState(() {
        if (isBike) {
          odabraniK = "Kategorija za";
          nazivNove = "";
          _selectedSectionKategorija = 'Home';
        } else {
          odabraniD = "Kategorija za";
          nazivNoveD = "";
          _selectedSectionKategorijaDijelovi = 'Home';
        }
      });
      return;
    }

    PorukaHelper.prikaziPorukuGreske(context, poruka);
  }

  Future<void> upravljanjeKategorijom(String status, bool isBike) async {
    if (status == "obrisi") {
      bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, 'Da li ste sigurni da želite obrisati ovu kategoriju?');
      if (confirmed != true) {
        return;
      }
    }
    var odabranaKategorijaa = isBike ? odabranaKategorija : odabranaKategorijaD;

    if (odabranaKategorijaa == null) {
      return;
    }

    String poruka = await _kategorijaServis.upravljanjeKategorijom(status, odabranaKategorijaa['kategorijaId']);

    if (poruka == "Uspješno izvršena operacija za kategoriju") {
      PorukaHelper.prikaziPorukuUspjeha(context, poruka);
      await getKategorije();
      setState(() {
        if (isBike) {
          odabraniK = "Kategorija za";
          nazivNove = "";
          _selectedSectionKategorija = 'Home';
        } else {
          odabraniD = "Kategorija za";
          nazivNoveD = "";
          _selectedSectionKategorijaDijelovi = 'Home';
        }
      });
      return;
    }

    PorukaHelper.prikaziPorukuGreske(context, poruka);
  }

  void _filterKategorije(String title) {
    String status;
    switch (title) {
      case 'Kreirane':
        status = 'kreiran';
        break;
      case 'Izmijenjene':
        status = 'izmijenjen';
        break;
      case 'Aktivne':
        status = 'aktivan';
        break;
      case 'Obrisane':
        status = 'obrisan';
        break;
      case 'Vracene':
        status = 'vracen';
        break;
      default:
        status = '';
    }

    setState(() {
      _selectedStatusKategorije = title;
      _filteredKategorije = _listaBikeKategorije.where((kategorija) => kategorija['status'] == status).toList();
      _filteredKategorijeD = _listaDijeloviKategorije.where((kategorija) => kategorija['status'] == status).toList();
    });
  }

  Widget _buildKategorijaLista(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Map<String, dynamic>> paginatedKategorije = _filteredKategorije.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.75,
                child: ListView.builder(
                  itemCount: paginatedKategorije.length,
                  itemBuilder: (context, index) {
                    var kategorija = paginatedKategorije[index];
                    return Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            odabraniK = "Za bicikl";
                            nazivNove = "";
                            odabranaKategorija = kategorija;
                            _selectedSectionKategorija = "Info";
                          });
                        },
                        child: Container(
                          width: constraints.maxWidth * 0.9,
                          height: constraints.maxHeight * 0.1,
                          margin: EdgeInsets.symmetric(vertical: 9.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 82, 205, 210),
                                Color.fromARGB(255, 7, 161, 235),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    kategorija['status'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.03,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    kategorija['naziv'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.03,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth * 0.3,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.center,
                                child: Container(
                                  width: constraints.maxWidth * 0.25,
                                  height: constraints.maxHeight * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Više informacija",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 3, 199, 253),
                                        fontSize: constraints.maxWidth * 0.03,
                                      ),
                                    ),
                                  ),
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
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      child: Text("<"),
                    ),
                    ElevatedButton(
                      onPressed: (_currentPage + 1) * _itemsPerPage < _filteredKategorije.length
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      child: Text(">"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addNovaKategorija(bool isBike) async {
    String naziv = isBike ? nazivNove : nazivNoveD;
    String odabrani = isBike ? odabraniK : odabraniD;

    if (naziv.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potreno je unijeti naziv");
      return;
    }
    if (odabrani == "Kategorija za") {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potreno je odabrati vrstu kategorije");
      return;
    }

    bool isBikeKategorija = odabrani == "Za bicikl";
    String poruka = await _kategorijaServis.addKategorija(naziv, isBikeKategorija);

    if (poruka == "Uspjesno dodana kategorija") {
      PorukaHelper.prikaziPorukuUspjeha(context, poruka);
      await getKategorije();
      setState(() {
        if (isBike) {
          odabraniK = "Kategorija za";
          nazivNove = "";
          _selectedSectionKategorija = 'Home';
        } else {
          odabraniD = "Kategorija za";
          nazivNoveD = "";
          _selectedSectionKategorijaDijelovi = 'Home';
        }
      });
      return;
    }

    PorukaHelper.prikaziPorukuGreske(context, poruka);
  }

  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.19,
      height: MediaQuery.of(context).size.height * 0.05,
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.005),
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
          AutoSizeText(
            '$label ',
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            minFontSize: 8,
            stepGranularity: 1,
          ),
          AutoSizeText(
            '$value',
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            minFontSize: 8,
            stepGranularity: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.14,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedSection == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          setState(() {
            _selectedSection = title;
          });
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedSection == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildSetStatusButton(String status, String objekat) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.07,
      height: MediaQuery.of(context).size.height * 0.04,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedSection == status ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () async {
          await promjeniStatus(status, objekat);
        },
        child: Text(
          status,
          style: TextStyle(
            color: _selectedSection == status ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatus == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterKorisnici(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatus == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonBicikl(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusBicikli == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterBicikli(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusBicikli == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonDijelovi(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusDijelova == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterDijelovi(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusDijelova == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonKategorije(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusKategorije == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterKategorije(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusKategorije == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonServiseri(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusServisera == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterServiseri(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusServisera == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonPromocije(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusPromocijeB == title ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterPromocije(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusPromocijeB == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }
}
