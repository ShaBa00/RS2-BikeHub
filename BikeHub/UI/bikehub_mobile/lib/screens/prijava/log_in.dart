// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, sized_box_for_whitespace, use_build_context_synchronously

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_info_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final KorisnikServis _korisnikService = KorisnikServis();
  final KorisnikInfoServis _korisnikInfoServis = KorisnikInfoServis();
  final AdresaServis _adresaServis = AdresaServis();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lozinkaController = TextEditingController();
  final TextEditingController _potvrdaLozinkeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _postanskiBrojController =
      TextEditingController();
  final TextEditingController _ulicaController = TextEditingController();

  final TextEditingController _imePrezimeBrojController =
      TextEditingController();
  final TextEditingController _telefonController = TextEditingController();

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
    } else {
      PorukaHelper.prikaziPorukuUpozorenja(
          context, 'Greska prilikom prijave, pokusajte ponovo');
    }
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
                              _usernameController, isUsernameValid),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Lozinka', true,
                              _lozinkaController, isLozinkaValid),
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

  int _currentStep = 0;

  Widget signUpDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 205, 210),
            Color.fromARGB(255, 7, 161, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(
              color: Colors.lightBlueAccent,
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() {
                        _currentStep++;
                      });
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
                  steps: [
                    Step(
                      title: Text('1. Korak'),
                      content: Column(
                        children: [
                          _buildInputField(context, 0.75, 'Username', false,
                              _usernameController, isUsernameValid),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Lozinka', true,
                              _lozinkaController, isLozinkaValid),
                          const SizedBox(height: 8),
                          _buildInputField(
                              context,
                              0.75,
                              'Potvrda lozinke',
                              true,
                              _potvrdaLozinkeController,
                              isPotvrdaLozinkeValid),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Email', false,
                              _emailController, isEmailValid),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 0
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: Text('2. Korak'),
                      content: Column(
                        children: [
                          _buildInputField(context, 0.75, 'Grad', false,
                              _gradController, isGradValid),
                          const SizedBox(height: 8),
                          _buildInputField(
                              context,
                              0.75,
                              'Poštanski broj',
                              false,
                              _postanskiBrojController,
                              isPostanskiBrojValid),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Ulica', false,
                              _ulicaController, isUlicaValid),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep == 1
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: Text('3. Korak'),
                      content: Column(
                        children: [
                          _buildInputField(
                              context,
                              0.75,
                              'Ime i Prezime',
                              false,
                              _imePrezimeBrojController,
                              isImePrezimeValid),
                          const SizedBox(height: 8),
                          _buildInputField(context, 0.75, 'Telefon', false,
                              _telefonController, isTelefonValid),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep == 2
                          ? StepState.editing
                          : StepState.complete,
                    ),
                  ],
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controlsDetails) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton(
                            onPressed: controlsDetails.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 202, 255),
                            ),
                            child: const Text(
                              'Nazad',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        if (_currentStep < 2)
                          ElevatedButton(
                            onPressed: controlsDetails.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 202, 255),
                            ),
                            child: const Text(
                              'Sljedeće',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        if (_currentStep == 2)
                          ElevatedButton(
                            onPressed: () {
                              kreirajNoviProfil(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 202, 255),
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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

  bool isUsernameValid = true;
  bool isLozinkaValid = true;
  bool isPotvrdaLozinkeValid = true;
  bool isEmailValid = true;
  bool isGradValid = true;
  bool isPostanskiBrojValid = true;
  bool isUlicaValid = true;
  bool isImePrezimeValid = true;
  bool isTelefonValid = true;

  Future<void> kreirajNoviProfil(BuildContext context) async {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@[a-zA-Z]+\.[a-zA-Z]+(\.[a-zA-Z]+)?$');

    final gradRegex = RegExp(r'^[a-zA-Z\s]+$');
    final imePrezimeRegex = RegExp(r'^(\w+\s)+\w+$');

    isUsernameValid = _usernameController.text.isNotEmpty;
    isLozinkaValid = _lozinkaController.text.isNotEmpty;
    isPotvrdaLozinkeValid =
        _potvrdaLozinkeController.text == _lozinkaController.text;
    isEmailValid = emailRegex.hasMatch(_emailController.text);
    isGradValid = gradRegex.hasMatch(_gradController.text);
    isPostanskiBrojValid = _postanskiBrojController.text.isNotEmpty;
    isUlicaValid = _ulicaController.text.isNotEmpty;
    isImePrezimeValid =
        imePrezimeRegex.hasMatch(_imePrezimeBrojController.text);
    isTelefonValid = _telefonController.text.isNotEmpty;

    if (!isUsernameValid ||
        !isLozinkaValid ||
        !isPotvrdaLozinkeValid ||
        !isEmailValid ||
        !isGradValid ||
        !isPostanskiBrojValid ||
        !isUlicaValid ||
        !isImePrezimeValid ||
        !isTelefonValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unesite ispravne podatke!'),
          backgroundColor: Colors.yellow,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {});
      return;
    }
    try {
      // 1. Pozivanje `postNoviKorisnik`
      final Map<String, dynamic> response =
          await _korisnikService.postNoviKorisnik(
        _usernameController.text,
        _lozinkaController.text,
        _potvrdaLozinkeController.text,
        _emailController.text,
      );

      final String message = response['message'];
      final int? korisnikId = response['korisnikId'];

      if (message == 'Uspjesno' && korisnikId != null) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Greška: $message',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Pozivanje `postKorisnikInfo`
      String username = _usernameController.text;
      String password = _lozinkaController.text;

      await _korisnikService.login(username, password);
      final responseInfo = await _korisnikInfoServis.postKorisnikInfo(
        korisnikId,
        _imePrezimeBrojController.text,
        _telefonController.text,
      );

      if (responseInfo != "Korisnik Info uspješno izmjenjena") {
        logInPoziv(context);
        _resetInputs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Prijava djelimično uspješna',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToHome(context);
        return;
      }

      // 3. Pozivanje `postAdresa`
      final responseAdresa = await _adresaServis.postAdresa(
        korisnikId,
        _gradController.text,
        _postanskiBrojController.text,
        _ulicaController.text,
      );

      if (responseAdresa != "Adresa uspješno izmjenjena") {
        logInPoziv(context);
        _resetInputs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Prijava djelimično uspješna',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToHome(context);
        return;
      }

      // Sve uspješno

      logInPoziv(context);
      _resetInputs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uspješno ste prijavljeni',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToHome(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Došlo je do greške: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetInputs() {
    _usernameController.clear();
    _lozinkaController.clear();
    _potvrdaLozinkeController.clear();
    _emailController.clear();
    _gradController.clear();
    _postanskiBrojController.clear();
    _ulicaController.clear();
    _imePrezimeBrojController.clear();
    _telefonController.clear();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GlavniProzor()),
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
      bool isPassword, TextEditingController controller, bool isValid) {
    return Container(
      width: MediaQuery.of(context).size.width * sirina,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(
              color: isValid
                  ? Colors.white
                  : Colors.red, // Crvena ako nije validno
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(
              color: isValid ? Colors.white : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
