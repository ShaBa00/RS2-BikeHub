import '../bicikli/bicikl_service.dart';
import '../bicikli/promocija_bicikli_service.dart';
import '../dijelovi/dijelovi_service.dart';
import '../dijelovi/promocija_dijelovi_service.dart';

class ItemsService {
  // ignore: unused_field
  final BiciklService _biciklService = BiciklService();
  final PromocijaBicikliService _promocijaBicikliService = PromocijaBicikliService();
  final DijeloviService _dijeloviService = DijeloviService();
  final PromocijaDijeloviService _promocijaDijeloviService = PromocijaDijeloviService();

  Future<List<Map<String, dynamic>>> loadBicikli() async {
    // ignore: unused_local_variable
    final List promocijaBicikli = await _promocijaBicikliService.getPromocijaBicikli();
    //final List<Map<String, dynamic>> allBicikli = await _biciklService.getBicikli();
    
    // Prvi 4 bicikla iz promocije
    final List<Map<String, dynamic>> finalBicikli = [];
    
    //for (var promocija in promocijaBicikli.take(4)) {
     // final bicikl = allBicikli.firstWhere((b) => b['id'] == promocija['id'], orElse: () => {});
     // if (bicikl.isNotEmpty) {
    //    finalBicikli.add(bicikl);
    ////  }
   // }

    // Dodaj ostatak bicikala
    //finalBicikli.addAll(allBicikli.where((b) => !finalBicikli.contains(b)));

    return finalBicikli;
  }

  Future<List<Map<String, dynamic>>> loadDijelovi() async {
    final List promocijaDijelovi = await _promocijaDijeloviService.getPromocijaDijelovi();
    final List<Map<String, dynamic>> allDijelovi = await _dijeloviService.getDijelovi();
    
    // Prvi 4 dijela iz promocije
    final List<Map<String, dynamic>> finalDijelovi = [];

    for (var promocija in promocijaDijelovi.take(4)) {
      final dijelovi = allDijelovi.firstWhere((d) => d['id'] == promocija['id'], orElse: () => {});
      if (dijelovi.isNotEmpty) {
        finalDijelovi.add(dijelovi);
      }
    }

    // Dodaj ostatak dijelova
    finalDijelovi.addAll(allDijelovi.where((d) => !finalDijelovi.contains(d)));

    return finalDijelovi;
  }
}
