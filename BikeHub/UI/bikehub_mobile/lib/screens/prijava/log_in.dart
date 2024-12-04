// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, sized_box_for_whitespace, use_build_context_synchronously

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final KorisnikServis _korisnikService = KorisnikServis();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lozinkaController = TextEditingController();
  final TextEditingController _potvrdaLozinkeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _lozinkaController.dispose();
    _potvrdaLozinkeController.dispose();
    super.dispose();
  }

  void logInPoziv(BuildContext context) async {
    String username = _usernameController.text;
    String password = _lozinkaController.text;

    if (username.isEmpty || password.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(
          context, 'Unesite korisničko ime i lozinku.');
      return;
    }

    Map<String, dynamic>? korisnik =
        await _korisnikService.login(username, password);

    if (korisnik != null) {
      PorukaHelper.prikaziPorukuUspjeha(context, 'Uspješno ste prijavljeni!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GlavniProzor()),
      );
    } else {}
  }

  String _currentScreen = 'Prijava';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Dodano za izbjegavanje overflow-a
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 238, 239),
              Color.fromARGB(255, 165, 196, 210),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          // Dodano za omogućavanje skrolanja
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.88, // 88% visine ekrana
                color:
                    const Color.fromARGB(0, 255, 172, 64), // Bilo koja pozadina
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the widgets vertically within the container
                  children: [
                    _getDioWidget(_currentScreen), // Poziv funkcije
                  ],
                ),
              ),
              // navBar
              const NavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDioWidget(String title) {
    switch (title) {
      case 'Prijava':
        return logInDio(context);
      case 'Kreirajte novi':
        return signUpDio(context);
      default:
        return logInDio(context); // Defaultno prikazujemo Log In dio
    }
  }

  Widget logInDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
      height: MediaQuery.of(context).size.height * 0.5, // 50% visine ekrana
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 205, 210),
            Color.fromARGB(255, 7, 161, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.0), // Zaobljene sve ivice
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: Colors.transparent, // Nema pozadine
            borderRadius: BorderRadius.circular(25.0), // Zaobljene ivice
            border: Border.all(
              color: Colors.lightBlueAccent, // Svijetlo plava boja za border
              width: 2.0, // Širina linije
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.34,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      0, 255, 82, 82), // Pozadina za prepoznavanje
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.lightBlueAccent, // Boja border-a
                      width: 5.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.25,
                      color: const Color.fromARGB(
                          0, 223, 64, 251), // Pozadina za prepoznavanje
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInputField(context, 0.75, 'Username', false,
                              _usernameController),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Lozinka', true,
                              _lozinkaController),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: const Color.fromARGB(
                          0, 255, 172, 64), // Pozadina za prepoznavanje
                      child: Center(
                        // Dodano za centriranje buttona
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 202, 255),
                            ),
                            onPressed: () {
                              logInPoziv(context);
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                color:
                    Color.fromARGB(0, 255, 255, 0), // Pozadina za prepoznavanje
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Nemate kreiran profil?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildButton('Kreirajte novi'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget signUpDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
      height: MediaQuery.of(context).size.height * 0.6, // 50% visine ekrana
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 205, 210),
            Color.fromARGB(255, 7, 161, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.0), // Zaobljene sve ivice
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.transparent, // Nema pozadine
            borderRadius: BorderRadius.circular(25.0), // Zaobljene ivice
            border: Border.all(
              color: Colors.lightBlueAccent, // Svijetlo plava boja za border
              width: 2.0, // Širina linije
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.44,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      0, 255, 82, 82), // Pozadina za prepoznavanje
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.lightBlueAccent, // Boja border-a
                      width: 5.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.35,
                      color: const Color.fromARGB(
                          0, 223, 64, 251), // Pozadina za prepoznavanje
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInputField(context, 0.75, 'Username', false,
                              _usernameController),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Lozinka', true,
                              _lozinkaController),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Potvrda lozinke',
                              true, _potvrdaLozinkeController),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Email', false,
                              _potvrdaLozinkeController),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: const Color.fromARGB(
                          0, 255, 172, 64), // Pozadina za prepoznavanje
                      child: Center(
                        // Dodano za centriranje buttona
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 202, 255),
                            ),
                            onPressed: () {
                              // Dodaj funkcionalnost za dugme ovdje
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                color:
                    Color.fromARGB(0, 255, 255, 0), // Pozadina za prepoznavanje
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Prijavi se vec na krirani profil:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildButton('Prijava'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 87, 202, 255),
        ),
        onPressed: () {
          setState(() {
            _currentScreen = title;
          });
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

  void handleButtonPress(BuildContext context, String title) {
    switch (title) {
      case 'Prijava':
        PorukaHelper.prikaziPorukuUspjeha(context, 'Profil uspješno uređen!');
        break;
      case 'Uredi profil':
        PorukaHelper.prikaziPorukuUspjeha(context, 'Profil uspješno uređen!');
        break;
      default:
        PorukaHelper.prikaziPorukuUpozorenja(context, 'Nepoznata radnja.');
    }
  }

  Widget _buildInputField(BuildContext context, double sirina, String title,
      bool isPassword, TextEditingController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * sirina,
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Ako je password, prikazuje zvjezdice
        style: const TextStyle(color: Colors.white), // Tekst bijele boje
        decoration: InputDecoration(
          labelText: title,
          labelStyle:
              const TextStyle(color: Colors.white), // Label tekst bijele boje
          enabledBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(30.0)), // Više zaobljene ivice
            borderSide: BorderSide(color: Colors.white), // Border bijele boje
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(30.0)), // Više zaobljene ivice
            borderSide: BorderSide(
                color: Colors.white), // Border bijele boje kada je fokusirano
          ),
        ),
      ),
    );
  }
}
