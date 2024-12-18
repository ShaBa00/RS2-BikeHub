// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, prefer_final_fields, unused_element, sized_box_for_whitespace, use_build_context_synchronously, prefer_const_constructors_in_immutables

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/ostalo/paypal_screen.dart';
import 'package:bikehub_mobile/screens/ostalo/prikaz_slika.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_promocija_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_promocija_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class PromocijaZapisa extends StatefulWidget {
  final int? zapisId;
  final bool? isBicikl;

  PromocijaZapisa({super.key, this.zapisId, this.isBicikl});

  @override
  _PromocijaZapisaState createState() => _PromocijaZapisaState();
}

class _PromocijaZapisaState extends State<PromocijaZapisa> {
  final KorisnikServis _korisnikService = KorisnikServis();
  final BiciklService _biciklService = BiciklService();
  final BiciklPromocijaService _biciklPromocijaService =
      BiciklPromocijaService();
  final DijeloviService _dijeloviService = DijeloviService();
  final DijeloviPromocijaService _dijeloviPromocijaService =
      DijeloviPromocijaService();

  int korisnikId = 0;
  Map<String, dynamic>? zapis;
  List<Map<String, dynamic>>? slikeZapis;

  bool isLogged = false;
  bool isLoading = true;
  bool isPromovisan = false;

  String _selectedSection = 'bicikl';
  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _korisnikService.getUserInfo();
      korisnikId = int.parse(userInfo['korisnikId']!);
      isLogged = true;
      await getZapis();
    }

    setState(() {
      isLoading = false;
    });
  }

  getZapis() async {
    if (widget.isBicikl != null &&
        widget.isBicikl == true &&
        widget.zapisId != null) {
      var result =
          await _biciklService.getBiciklById(widget.zapisId?.toInt() ?? 0);
      isPromovisan = await _biciklPromocijaService.isPromovisan(
          biciklId: widget.zapisId?.toInt() ?? 0);
      setState(() {
        isPromovisan;
        if (result['slikeBiciklis'] != null) {
          slikeZapis = (result['slikeBiciklis'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
        zapis = result;
      });
    } else {
      var result = await _dijeloviService.getDijeloviById(widget.zapisId ?? 0);
      isPromovisan = await _dijeloviPromocijaService.isPromovisan(
          dijeloviId: widget.zapisId?.toInt() ?? 0);
      setState(() {
        if (result['slikeDijelovis'] != null) {
          isPromovisan;
          slikeZapis = (result['slikeDijelovis'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
        zapis = result;
      });
    }
  }

  void _updateSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
        child: AppBar(
          title: Text(
            'Promocija Zapisa',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GlavniProzor()),
              );
            },
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.9,
              color: Colors.blueAccent,
              child: Column(
                children: <Widget>[
                  //glavniDio
                  dioPretrage(context),
                  // Prikaz odabranog dijela
                  _buildSelectedSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dioPretrage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.09,
      color: Colors.blueAccent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Promovišite svoj proizvod\n kako biste povećali šanse za prodaju",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSelectedSection(BuildContext context) {
    switch (_selectedSection) {
      case 'bicikl':
        return dioBicikla(context);
      case 'dijelovi':
      default:
        return dioBicikla(context);
    }
  }

  Widget dioBicikla(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.81,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 205, 210),
            Color.fromARGB(255, 7, 161, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Color.fromARGB(0, 0, 94, 255),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : isLogged
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.7,
                        color: Color.fromARGB(0, 0, 94, 255),
                        child: Column(
                          children: [
                            prikazSlike(context),
                            prazanProstor(context),
                            podatciWidget(context),
                            prazanProstor(context),
                            odabranaOpcija(context),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Potrebno je prijaviti se',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 87, 202, 255),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LogIn()),
                                );
                              },
                              child: Text(
                                "Prijava",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 18,
                                ),
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

  Widget prikazSlike(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 161, 235),
            Color.fromARGB(255, 82, 205, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: (slikeZapis == null || slikeZapis!.isEmpty)
          ? Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 50,
              ),
            )
          : PrikazSlike(
              slikeBiciklis: slikeZapis ?? [],
              isPromovisan: isPromovisan,
            ),
    );
  }

  Widget prazanProstor(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.025,
    );
  }

  Widget podatciWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 161, 235),
            Color.fromARGB(255, 82, 205, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white),
                right: BorderSide(color: Colors.white),
                left: BorderSide(color: Colors.white),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  zapis?['naziv'] ?? 'N/A',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white),
                right: BorderSide(color: Colors.white),
                left: BorderSide(color: Colors.white),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '${zapis?["cijena"] ?? "N/A"} KM',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int brojDana = 0;
  int cijena = 5;
  Widget odabranaOpcija(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.22,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 161, 235),
            Color.fromARGB(255, 82, 205, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.09,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Odaberi broj dana",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        int? broj = int.tryParse(value);
                        if (broj != null) {
                          brojDana = broj;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.08,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.04,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${cijena * brojDana} KM",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.05,
            child: Center(
              child: customButton(
                  context, 'Promoviši', () => _handlePayment(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context) async {
    if (brojDana <= 0) return;
    double ukupnaCijena = (brojDana * cijena).toDouble();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PayPalScreen(totalAmount: ukupnaCijena),
      ),
    );

    // Obradi rezultat
    if (result != null && result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Plaćanje uspješno izvršeno!',
            style: TextStyle(color: Colors.white), // Text color
          ),
          backgroundColor: Colors.green, // Background color
        ),
      );

      if (widget.isBicikl != null && widget.isBicikl == true) {
        _biciklPromocijaService.postPromocijaBicikl(
            brojDana: brojDana, biciklId: widget.zapisId);
      }

      if (widget.isBicikl != null && widget.isBicikl == false) {
        _dijeloviPromocijaService.postPromocijaDijelovi(
            brojDana: brojDana, dijeloviId: widget.zapisId);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlavniProzor()),
      );
    } else if (result != null && result['status'] == 'cancel') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plaćanje otkazano.')),
      );
    }
  }

  Widget customButton(BuildContext context, String title, Function onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 0, 199, 254),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
