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
  bool lozinkaError = false;
  String potvrdaLozinkeError = "";
  String emailError = "";
  String usernameError = "";
  String imePrezimeError = "";
  bool brojTelefonaError = false;
  bool gradError = false;
  bool postanskiBrojError = false;
  bool ulicaError = false;

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
                                        bottom: BorderSide(color: usernameError.isNotEmpty ? Colors.red : Colors.white),
                                        right: BorderSide(color: usernameError.isNotEmpty ? Colors.red : Colors.white),
                                        left: BorderSide(color: usernameError.isNotEmpty ? Colors.red : Colors.white),
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
                                          usernameError = text.isEmpty ? "Potrebno je dodati uzername" : "";
                                        });
                                      },
                                    ),
                                  ),
                                  if (usernameError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        usernameError,
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: lozinkaError ? Colors.red : Colors.white),
                                        right: BorderSide(color: lozinkaError ? Colors.red : Colors.white),
                                        left: BorderSide(color: lozinkaError ? Colors.red : Colors.white),
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
                                      obscureText: true,
                                      onChanged: (text) {
                                        setState(() {
                                          lozinka = text;
                                          lozinkaError = text.isEmpty;
                                        });
                                      },
                                    ),
                                  ),
                                  if (lozinkaError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Lozinka je potrebna",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: potvrdaLozinkeError.isNotEmpty ? Colors.red : Colors.white),
                                        right: BorderSide(color: potvrdaLozinkeError.isNotEmpty ? Colors.red : Colors.white),
                                        left: BorderSide(color: potvrdaLozinkeError.isNotEmpty ? Colors.red : Colors.white),
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
                                      obscureText: true,
                                      onChanged: (text) {
                                        setState(() {
                                          potvrdaLozinke = text;
                                          potvrdaLozinkeError = text.isEmpty ? "Potvrda lozinke je potrebna" : "";
                                        });
                                      },
                                    ),
                                  ),
                                  if (potvrdaLozinkeError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        potvrdaLozinkeError,
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: emailError.isNotEmpty ? Colors.red : Colors.white),
                                        right: BorderSide(color: emailError.isNotEmpty ? Colors.red : Colors.white),
                                        left: BorderSide(color: emailError.isNotEmpty ? Colors.red : Colors.white),
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
                                          emailError = text.isEmpty ? "Email je potreban" : "";
                                        });
                                      },
                                    ),
                                  ),
                                  if (emailError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        emailError,
                                        style: TextStyle(color: Colors.red, fontSize: 12),
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
                                        bottom: BorderSide(color: imePrezimeError.isNotEmpty ? Colors.red : Colors.white),
                                        right: BorderSide(color: imePrezimeError.isNotEmpty ? Colors.red : Colors.white),
                                        left: BorderSide(color: imePrezimeError.isNotEmpty ? Colors.red : Colors.white),
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
                                          imePrezimeError = text.isEmpty ? "Ime i prezime je potrebno" : "";
                                        });
                                      },
                                    ),
                                  ),
                                  if (imePrezimeError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        imePrezimeError,
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: brojTelefonaError ? Colors.red : Colors.white),
                                        right: BorderSide(color: brojTelefonaError ? Colors.red : Colors.white),
                                        left: BorderSide(color: brojTelefonaError ? Colors.red : Colors.white),
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
                                          brojTelefonaError = text.isEmpty;
                                        });
                                      },
                                    ),
                                  ),
                                  if (brojTelefonaError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Broj telefona je potreban",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
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
                                        bottom: BorderSide(color: gradError ? Colors.red : Colors.white),
                                        right: BorderSide(color: gradError ? Colors.red : Colors.white),
                                        left: BorderSide(color: gradError ? Colors.red : Colors.white),
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
                                          gradError = text.isEmpty;
                                        });
                                      },
                                    ),
                                  ),
                                  if (gradError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Grad je potreban",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: postanskiBrojError ? Colors.red : Colors.white),
                                        right: BorderSide(color: postanskiBrojError ? Colors.red : Colors.white),
                                        left: BorderSide(color: postanskiBrojError ? Colors.red : Colors.white),
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
                                          postanskiBrojError = text.isEmpty;
                                        });
                                      },
                                    ),
                                  ),
                                  if (postanskiBrojError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Postanski broj je potreban",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border(
                                        bottom: BorderSide(color: ulicaError ? Colors.red : Colors.white),
                                        right: BorderSide(color: ulicaError ? Colors.red : Colors.white),
                                        left: BorderSide(color: ulicaError ? Colors.red : Colors.white),
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
                                          ulicaError = text.isEmpty;
                                        });
                                      },
                                    ),
                                  ),
                                  if (ulicaError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Ulica je potrebna",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
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

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool isValidImePrezime(String imePrezime) {
    final regex = RegExp(r'^[a-zA-Z]+( [a-zA-Z]+)+$');
    return regex.hasMatch(imePrezime);
  }

  signUp() async {
    bool errorFirstPage = false;
    usernameError = "";
    lozinkaError = false;
    potvrdaLozinkeError = "";
    emailError = "";
    brojTelefonaError = false;
    imePrezimeError = "";
    gradError = false;
    postanskiBrojError = false;
    ulicaError = false;
    if (username.isEmpty) {
      errorFirstPage = true;
      usernameError = "Potrebno je dodati username";
    }
    if (lozinka.isEmpty) {
      errorFirstPage = true;
      lozinkaError = true;
    }
    if (potvrdaLozinke.isEmpty) {
      errorFirstPage = true;
      potvrdaLozinkeError = "Potrebno je potvrditi lozinku";
    }
    if (email.isEmpty) {
      errorFirstPage = true;
      emailError = "Potrebno je dodati email";
    }
    if (errorFirstPage) {
      setState(() {
        usernameError;
        lozinkaError;
        potvrdaLozinkeError;
        emailError;
        currentCardIndex = 0;
      });
      return;
    }
    if (lozinka != potvrdaLozinke) {
      setState(() {
        potvrdaLozinkeError = "Lozinka i potvrda moraju biti iste";
        currentCardIndex = 0;
      });
      return;
    }
    if (!isValidEmail(email)) {
      setState(() {
        currentCardIndex = 0;
        emailError = "Email je u pogresnom formatu";
      });
      return;
    }
    bool korisnikU = await korisnikService.ceckKorisnikUsername(username: username);
    if (korisnikU) {
      setState(() {
        currentCardIndex = 0;
        usernameError = "Username je zauzet";
      });
      return;
    }
    bool korisnikE = await korisnikService.ceckKorisnikEmail(email: email);
    if (korisnikE) {
      setState(() {
        currentCardIndex = 0;
        emailError = "Email je zauzet";
      });
      return;
    }
    bool errorSecundPage = false;
    if (imePrezime.isEmpty) {
      errorSecundPage = true;
      imePrezimeError = "Potrebno je dodati ime i prezime";
    }
    if (!isValidImePrezime(imePrezime)) {
      errorSecundPage = true;
      imePrezimeError = "Ime i prezime je pogresnog formata";
    }
    if (brojTelefona.isEmpty) {
      errorSecundPage = true;
      brojTelefonaError = true;
    }
    if (errorSecundPage) {
      setState(() {
        currentCardIndex = 1;
        imePrezimeError;
        brojTelefonaError;
      });
      return;
    }
    bool errorThPage = false;
    if (grad.isEmpty) {
      errorThPage = true;
      gradError = true;
    }
    if (postanskiBroj.isEmpty) {
      errorThPage = true;
      postanskiBrojError = true;
    }
    if (ulica.isEmpty) {
      errorThPage = true;
      ulicaError = true;
    }
    if (errorThPage) {
      setState(() {
        ulicaError;
        postanskiBrojError;
        gradError;
      });
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
