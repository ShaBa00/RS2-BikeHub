// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/rezervacije_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:table_calendar/table_calendar.dart';

class ServiserPrikaz extends StatefulWidget {
  final int serviserId;

  const ServiserPrikaz({super.key, required this.serviserId});

  @override
  _ServiserPrikazState createState() => _ServiserPrikazState();
}

class _ServiserPrikazState extends State<ServiserPrikaz> {
  final ServiserService _serviserService = ServiserService();
  final KorisnikServis _korisnikServis = KorisnikServis();
  final RezervacijaServis _rezervacijaServis = RezervacijaServis();

  bool loading = true;
  Map<String, dynamic>? serviserZapis;

  getSlobodniDani() async {
    try {
      List<int> dani = await _serviserService.getSlobodniDani(
        serviserId: widget.serviserId,
        mjesec: odabraniMjesec,
        godina: odabranaGodina,
      );
      setState(() {
        slobodniDani = dani;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      // Handle error
    }
  }

  void _initialize() async {
    serviserZapis = await _serviserService.getServiseriDTOById(
        serviserId: widget.serviserId);
    await getSlobodniDani();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    odabraniMjesec = now.month;
    odabranaGodina = now.year;
    odabraniDatum = now;
    _initialize();
  }

  void onPageChanged(DateTime focusedDay) {
    setState(() {
      odabraniMjesec = focusedDay.month;
      odabranaGodina = focusedDay.year;
      loading = true;
    });
    getSlobodniDani();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
        child: AppBar(
          title: Text(
            'Serviser Prikaz',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Expanded(
              child: podatciServisera(context),
            ),
            const NavBar(),
          ],
        ),
      ),
    );
  }

  Widget podatciServisera(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7498,
      color: Colors.blueAccent, // Zamijeni bojom po želji
      child: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.06,
                  color: const Color.fromARGB(0, 76, 175, 79), // Prva pozadina
                  child: Center(
                    child: Text(
                      serviserZapis?['username'] ?? 'N/A',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6898,
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
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.03,
                        color: Colors.transparent,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.6598,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                                color: const Color.fromARGB(
                                    0, 255, 153, 0), // Prva pozadina
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                child: Center(
                                  child: osnovniPodatci(context),
                                ),
                              ),
                              SizedBox(height: 10),
                              kalendar(context),
                              SizedBox(height: 10),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget odabraniD(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.1,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Odabrani: ${odabraniDatum != null ? "${odabraniDatum!.day.toString().padLeft(2, '0')}-${odabraniDatum!.month.toString().padLeft(2, '0')}-${odabraniDatum!.year}" : "Nema odabranog datuma"}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.1,
            color: const Color.fromARGB(0, 76, 175, 79),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  rezervacija(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Boja pozadine dugmeta
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.35,
                    MediaQuery.of(context).size.height * 0.05,
                  ),
                ),
                child: Text(
                  "Rezervisi",
                  style: TextStyle(color: Colors.lightBlue), // Boja teksta
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  rezervacija(BuildContext context) async {
    bool loggedIn = await _korisnikServis.isLoggedIn();
    if (!loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Samo prijavljeni korisnici mogu rezervisati.'),
        ),
      );
      return;
    }
    String status = "kreiran";
    var userInfo = await _korisnikServis.getUserInfo();
    setState(() {
      status = userInfo['status'] ?? 'kreiran';
    });
    if (status != "aktivan") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Samo verifikovani korisnici mogu naruciti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 219, 244, 31),
        ),
      );
      return;
    }
    if (odabraniDatum != null && slobodniDani.contains(odabraniDatum!.day)) {
      try {
        Map<String, String?> korisnikInfo = await _korisnikServis.getUserInfo();
        int? korisnikId = int.tryParse(korisnikInfo['korisnikId'] ?? '');

        if (korisnikId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Ne možemo pronaći vaš ID. Molimo prijavite se ponovno.'),
            ),
          );
          return;
        }

        int serviserId = widget.serviserId;

        bool uspjeh = await _rezervacijaServis.postRezervacija(
          serviserId: serviserId,
          korisnikId: korisnikId,
          datumRezervacije: odabraniDatum!,
        );

        if (uspjeh) {
          getSlobodniDani();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rezervacija uspješno kreirana.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rezervacija nije uspjela.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: ${e.toString()}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odabrani dan nije dostupan za rezervaciju.'),
        ),
      );
    }
  }

  Widget osnovniPodatci(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        border: Border(
          left: BorderSide(color: Colors.white),
          right: BorderSide(color: Colors.white),
          bottom: BorderSide(color: Colors.white),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.42,
            height: MediaQuery.of(context).size.height * 0.15,
            color: const Color.fromARGB(0, 244, 67, 54),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.075,
                  color: const Color.fromARGB(0, 233, 30, 98),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.066,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cijena: ',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              serviserZapis?['cijena'] != null
                                  ? serviserZapis!['cijena'].toString()
                                  : 'N/A',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.073,
                  color: const Color.fromARGB(0, 0, 150, 135),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.066,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ocjena: ',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              serviserZapis?['ukupnaOcjena'] != null
                                  ? serviserZapis!['ukupnaOcjena'].toString()
                                  : 'N/A',
                              style: TextStyle(color: Colors.black),
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
          Container(
            width: MediaQuery.of(context).size.width * 0.424,
            height: MediaQuery.of(context).size.height * 0.15,
            color: const Color.fromARGB(0, 33, 149, 243),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.075,
                  color: const Color.fromARGB(0, 233, 30, 98),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.066,
                      decoration: BoxDecoration(
                        color: Colors.white, // Bijela pozadina
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)), // Zaobljene ivice
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Broj: ',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              serviserZapis?['brojServisa'] != null
                                  ? serviserZapis!['brojServisa'].toString()
                                  : 'N/A',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.073,
                  color: const Color.fromARGB(0, 0, 150, 135),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.066,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                            Text(
                              serviserZapis?['grad'] != null
                                  ? serviserZapis!['grad']
                                  : 'N/A',
                              style: TextStyle(color: Colors.black),
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
        ],
      ),
    );
  }

  late int odabraniMjesec;
  late int odabranaGodina;
  late DateTime? odabraniDatum;
  List<int> slobodniDani = [];

  Widget kalendar(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 82, 205, 210),
                Color.fromARGB(255, 7, 161, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.05,
                color: const Color.fromARGB(0, 255, 153, 0), // Prva pozadina
                child: Center(
                  child: Text(
                    "Slobodni termini",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.37,
                color:
                    const Color.fromARGB(0, 96, 125, 139), // Bilo koja pozadina
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.37,
                            color: const Color.fromARGB(0, 244, 67, 54),
                            child: Transform.scale(
                              scale:
                                  0.98, // Faktor skaliranja za cijeli kalendar
                              child: SingleChildScrollView(
                                child: TableCalendar(
                                  firstDay: DateTime(2000),
                                  lastDay: DateTime(2100),
                                  focusedDay:
                                      DateTime(odabranaGodina, odabraniMjesec),
                                  calendarFormat: CalendarFormat.month,
                                  availableCalendarFormats: const {
                                    CalendarFormat.month: 'Month'
                                  },
                                  onPageChanged: (focusedDay) {
                                    setState(() {
                                      odabraniMjesec = focusedDay.month;
                                      odabranaGodina = focusedDay.year;
                                      loading = true;
                                    });
                                    getSlobodniDani();
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      odabraniDatum = selectedDay;
                                    });
                                  },
                                  selectedDayPredicate: (day) {
                                    return isSameDay(day, odabraniDatum);
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    defaultBuilder: (context, day, focusedDay) {
                                      final isSlobodanDan =
                                          slobodniDani.contains(day.day);
                                      final isSelected =
                                          odabraniDatum != null &&
                                              isSameDay(day, odabraniDatum);
                                      return Container(
                                        width: 40, // Smanjena širina dana
                                        height: 40, // Smanjena visina dana
                                        margin: const EdgeInsets.all(4.0),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.orange
                                              : (isSlobodanDan
                                                  ? Colors.green
                                                  : Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 10),
              odabraniD(context),
            ],
          ),
        );
      },
    );
  }
}
