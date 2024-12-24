// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/adresa/adresa_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_info_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class SignUpProzor extends StatefulWidget {
  const SignUpProzor({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  _SignUpProzorState createState() => _SignUpProzorState();
}

class _SignUpProzorState extends State<SignUpProzor> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final KorisnikService korisnikService = KorisnikService();
  final KorisnikInfoService korisnikInfoService = KorisnikInfoService();
  final AdresaService adresaService = AdresaService();
  int currentCardIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    currentCardIndex = 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNextCard() {
    setState(() {
      currentCardIndex++;
    });
    _controller.forward(from: 0.0);
  }

  void _goToPreviousCard() {
    setState(() {
      currentCardIndex--;
    });
    _controller.forward(from: 0.0);
  }

  String username = "";
  String lozinka = "";
  String potvrdaLozinke = "";
  String email = "";

  String imePrezime = "";
  String brojTelefona = "";

  String grad = "";
  String postanskiBroj = "";
  String ulica = "";

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
          title: const Text('Sign up'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.5,
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
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Center(
                    child: SizeTransition(
                      sizeFactor: _animation,
                      axisAlignment: -1.0,
                      child: IndexedStack(
                        index: currentCardIndex,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(72, 59, 239, 255),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Username',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          username = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Lozinka',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      obscureText: true, // Omogućava prikazivanje kao zvjezdice ili točke
                                      onChanged: (text) {
                                        setState(() {
                                          lozinka = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Potvrda lozinke',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      obscureText: true, // Omogućava prikazivanje kao zvjezdice ili točke
                                      onChanged: (text) {
                                        setState(() {
                                          potvrdaLozinke = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Email',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          email = text;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(72, 59, 239, 255),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Ime i prezime',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          imePrezime = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Broj telefona',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          brojTelefona = text;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(72, 59, 239, 255),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Grad',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          grad = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Postanski broj',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          postanskiBroj = text;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white),
                                        right: BorderSide(color: Colors.white),
                                        left: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Ulica',
                                        labelStyle: TextStyle(color: Colors.white),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 8.0),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          ulica = text;
                                        });
                                      },
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
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentCardIndex > 0) ...[
                        ElevatedButton(
                          onPressed: _goToPreviousCard,
                          child: const Text(
                            "Nazad",
                            style: TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
                          ),
                        ),
                        const SizedBox(width: 20), // Odmak između dugmića
                      ],
                      ElevatedButton(
                        onPressed: () {
                          if (currentCardIndex < 2) {
                            _goToNextCard();
                          } else {
                            signUp();
                          }
                        },
                        child: Text(
                          currentCardIndex < 2 ? "Sljedeće" : "Sign up",
                          style: const TextStyle(color: Color.fromARGB(255, 87, 202, 255)),
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

  signUp() async {
    if (username.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati Username");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    if (lozinka.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati Lozinku");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    if (potvrdaLozinke.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati Potvrdu lozinke");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    if (lozinka != potvrdaLozinke) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Lozinka i potvrda moraju biti iste");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    if (email.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati Email");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    bool korisnikU = await korisnikService.ceckKorisnikUsername(username: username);
    if (korisnikU) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Username je zauzet");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    bool korisnikE = await korisnikService.ceckKorisnikEmail(email: email);
    if (korisnikE) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Email je zauzet");
      setState(() {
        currentCardIndex = 0;
      });
      return;
    }
    if (imePrezime.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati ime i prezime");
      setState(() {
        currentCardIndex = 1;
      });
      return;
    }
    if (brojTelefona.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati broj telefona");
      setState(() {
        currentCardIndex = 1;
      });
      return;
    }
    if (grad.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati grad");

      return;
    }
    if (postanskiBroj.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati postanski broj");

      return;
    }
    if (ulica.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati ulicu");
      return;
    }

    var response = await korisnikService.postKorisnik(username: username, lozinka: lozinka, lozinkaPotvrda: potvrdaLozinke, email: email);
    if (response['korisnikId'] != null && response['korisnikId'] != 0) {
      await korisnikService.login(username, lozinka);
      int korisnikId = response['korisnikId'];
      var responseKorisnikInfo = await korisnikInfoService.postKorisnikinfo(korisnikId: korisnikId, imePrezime: imePrezime, telefon: brojTelefona);
      if (responseKorisnikInfo != "Uspjesno") {
        PorukaHelper.prikaziPorukuGreske(context, responseKorisnikInfo);

        Future.delayed(Duration(seconds: 5), () {
          PorukaHelper.prikaziPorukuGreske(context, "Djelimicno uspjesna prijava");
          widget.onLogin();
          Navigator.pop(context);
        });

        return;
      }

      var responseAdresa = await adresaService.postAdresa(korisnikId: korisnikId, grad: grad, postanskiBroj: postanskiBroj, ulica: ulica);
      if (responseAdresa != "Uspjesno") {
        PorukaHelper.prikaziPorukuGreske(context, responseAdresa);
        Future.delayed(Duration(seconds: 5), () {
          PorukaHelper.prikaziPorukuGreske(context, "Djelimicno uspjesna prijava");
          widget.onLogin();
          Navigator.pop(context);
        });
        return;
      }
      PorukaHelper.prikaziPorukuUspjeha(context, "Uspjesno kreiran profil");
      widget.onLogin();
      Navigator.pop(context);
      return;
    } else {
      PorukaHelper.prikaziPorukuGreske(context, response['poruka']);
      Navigator.pop(context);
      vratiPodatke();
      return;
    }
  }

  vratiPodatke() async {
    setState(() {
      username = "";
      lozinka = "";
      potvrdaLozinke = "";
      email = "";

      imePrezime = "";
      brojTelefona = "";

      grad = "";
      postanskiBroj = "";
      ulica = "";
    });
  }
}
