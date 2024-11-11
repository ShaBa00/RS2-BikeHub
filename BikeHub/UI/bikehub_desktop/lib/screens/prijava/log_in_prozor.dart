// ignore_for_file: use_build_context_synchronously

//import 'package:bikehub_desktop/screens/pocetni_prozor.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class LogInProzor extends StatelessWidget {
  const LogInProzor({super.key, required this.onLogin});

   final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final KorisnikService korisnikService = KorisnikService();

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
          title: const Text('Log in'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 6, 247, 255),
                  Color.fromARGB(255, 50, 131, 165),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 6, 4, 4)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Color.fromARGB(255, 6, 4, 4)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 6, 4, 4)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Color.fromARGB(255, 6, 4, 4)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: ElevatedButton(
                    onPressed: () async {
  final username = usernameController.text;
  final password = passwordController.text;

  final korisnik = await korisnikService.login(username, password);


  if (korisnik != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uspješno prijavljivanje!')),
    );
    onLogin();
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Neuspješno prijavljivanje.')),
    );
  }
},
                    child: const Text(
                      'Prijavi',
                      style: TextStyle(color: Colors.white),
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
}