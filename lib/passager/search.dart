// ignore_for_file: unnecessary_cast, avoid_print, use_build_context_synchronously

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/passager/PassagerHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/passager/ResultatsPage.dart';

class AppLayout {
  static double getHeight(double height) {
    return height;
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _priceController = TextEditingController();
  DateTime? selectedDate;

  String? selectedPointDepart;
  String? selectedPointArrivee;

  final List<String> gouvernorats = [
    'Ariana',
    'Béja',
    'Ben Arous',
    'Bizerte',
    'Gabes',
    'Gafsa',
    'Jendouba',
    'Kairouan',
    'Kasserine',
    'Kébili',
    'Le Kef',
    'Mahdia',
    'La Manouba',
    'Médenine',
    'Monastir',
    'Nabeul',
    'Sfax',
    'Sidi Bouzid',
    'Siliana',
    'Sousse',
    'Tataouine',
    'Tozeur',
    'Tunis',
    'Zaghouan'
  ];

  @override
  void initState() {
    super.initState();
    _priceController.text = '';
    // Initialize selectedDate but don't set it to today's date by default
    selectedDate = null;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

 //
  Future<List<Map<String, dynamic>>> searchTrajets() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('trajets').get();

    List<Map<String, dynamic>> allTrajets =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    
    List<Map<String, dynamic>> filteredTrajets = allTrajets.where((trajet) {
      final String? depart = trajet['depart'];
      final String? arrivee = trajet['arrivee'];
      double? prix;
      var rawPrix = trajet['prix'];
      print("rawPrix: $rawPrix");
      print("depart: $depart");
      print("arrivee: $arrivee");
      if (rawPrix is int) {
        print("rawPrix is int: $rawPrix");
        prix = rawPrix.toDouble();
      } else if (rawPrix is double) {
        print("rawPrix is double: $rawPrix");
        prix = rawPrix;
      } else if (rawPrix is String) {
        print("rawPrix is String: $rawPrix");
        prix = double.tryParse(rawPrix);
      }

      final Timestamp? timestamp = trajet['date'] as Timestamp?;
      final DateTime? date = timestamp?.toDate();
      print("date: $date");
      print("selectedDate: $selectedDate");

      bool matchesDepart = selectedPointDepart == null ||
          selectedPointDepart!.isEmpty ||
          selectedPointDepart == depart;

      bool matchesArrivee = selectedPointArrivee == null ||
          selectedPointArrivee!.isEmpty ||
          selectedPointArrivee == arrivee;

      bool matchesPrix = _priceController.text.isEmpty ||
          (prix != null &&
              prix <=
                  (double.tryParse(_priceController.text) ?? double.infinity));

     //
      bool matchesDate = selectedDate == null ||
          (date != null &&
              date.year == selectedDate!.year &&
              date.month == selectedDate!.month &&
              date.day == selectedDate!.day);

      return matchesDepart && matchesArrivee && matchesPrix && matchesDate;
    }).toList();

    return filteredTrajets;
  }

  //
  void _handleSearch() async {
    List<Map<String, dynamic>> resultats = await searchTrajets();
    print("resultats: $resultats");
    if (resultats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucun trajet trouvé.")),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultatsPage(trajets: resultats),
        ),
      );

      for (var trajet in resultats) {
        print("Trajet trouvé: $trajet");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 166, 166, 166),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Passagerhomepage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text("CHERCHER UN TRAJET ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppLayout.getHeight(20),
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              )),
          const SizedBox(height: 16.0),


          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Point de départ',
              hintText: 'Sélectionnez votre point de départ',
              border: OutlineInputBorder(),
            ),
            value: selectedPointDepart,
            items: gouvernorats.map((String gouvernorat) {
              return DropdownMenuItem<String>(
                value: gouvernorat,
                child: Text(gouvernorat),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPointDepart = newValue;
              });
            },
          ),
          SizedBox(height: 16.0),

          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Point d\'arrivée',
              hintText: 'Sélectionnez votre point d\'arrivée',
              border: OutlineInputBorder(),
            ),
            value: selectedPointArrivee,
            items: gouvernorats.map((String gouvernorat) {
              return DropdownMenuItem<String>(
                value: gouvernorat,
                child: Text(gouvernorat),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPointArrivee = newValue;
              });
            },
          ),
          SizedBox(height: 16.0),

          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Prix',
              prefixIcon: const Icon(Icons.payments),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),

          DateTimeFormField(
            decoration: const InputDecoration(
              labelText: 'Date',
              hintText: 'Sélectionnez une date',
              enabledBorder: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            mode: DateTimeFieldPickerMode.date,
            initialValue: selectedDate,
            onChanged: (DateTime? value) {
              setState(() {
                //
                selectedDate = value;
              });
            },
            onSaved: (DateTime? value) {
              setState(() {
                selectedDate = value;
              });
            },
          ),
          SizedBox(height: 16.0),

          ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: const Color.fromARGB(255, 166, 166, 166),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 32.0,
                ),
              ),
              onPressed: () {
                _handleSearch();
              }),

          //
          if (selectedDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDate = null;
                });
              },
              child: Text('Effacer la date'),
            ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Passagerhomepage(),
            ),
          );
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
