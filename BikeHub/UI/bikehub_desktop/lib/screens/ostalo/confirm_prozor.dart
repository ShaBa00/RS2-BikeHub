// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ConfirmProzor {
  static Future<bool?> prikaziConfirmProzor(BuildContext context, String poruka) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Ne dozvoljava zatvaranje pritiskom van prozora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Potvrda'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(poruka),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Odbaci'),
              onPressed: () {
                Navigator.of(context).pop(false); // Vrati false kada se pritisne Odbaci
              },
            ),
            TextButton(
              child: Text('Potvrdi'),
              onPressed: () {
                Navigator.of(context).pop(true); // Vrati true kada se pritisne Potvrdi
              },
            ),
          ],
        );
      },
    );
  }
}
