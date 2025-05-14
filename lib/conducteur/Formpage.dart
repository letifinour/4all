// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/conducteur/ConducteurHomePage.dart';

class Formpage extends StatefulWidget {
  final String? trajetId;

  Formpage({this.trajetId, required Map<String, dynamic> initialData})
      : initialData = {};

  final Map<String, dynamic> initialData;

  Formpage.withInitialData({this.trajetId, Map<String, dynamic>? initialData})
      : initialData = initialData ?? {};

  @override
  _FormpageState createState() => _FormpageState();
}

class _FormpageState extends State<Formpage> {
  final List<String> gouvernorats = [
    'Tunis',
    'Ariana',
    'Ben Arous',
    'Manouba',
    'Sousse',
    'Sfax',
    'Nabeul',
    'Bizerte',
    'Gabes',
    'Kairouan',
    'Gafsa',
    'Monastir',
    'Mahdia',
    'Kasserine',
    'Kebili',
    'Beja',
    'Jendouba',
    'Le Kef',
    'Siliana',
    'Zaghouan',
    'Tozeur',
    'Medenine',
    'Tataouine'
  ];
  final _formKey = GlobalKey<FormState>();
  final nomNameController = TextEditingController();
  final prenomNameController = TextEditingController();
  final phoneController = TextEditingController();
  final _placesDisponiblesController = TextEditingController();
  final _prixController = TextEditingController();
  String? selectedPointDepart;
  String? selectedPointArrivee;

  String? selectedGouvernorat;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;
    nomNameController.text = data['nom'] != null ? data['nom'].toString() : '';
    prenomNameController.text =
        data['prenom'] != null ? data['prenom'].toString() : '';
    phoneController.text =
        data['telephone'] != null ? data['telephone'].toString() : '';
    _placesDisponiblesController.text = data['places_disponibles'] != null
        ? data['places_disponibles'].toString()
        : '';
    _prixController.text = data['prix'] != null ? data['prix'].toString() : '';

    if (data['depart'] is String) {
      selectedPointDepart = data['depart'];
    }

    if (data['arrivee'] is String) {
      selectedPointArrivee = data['arrivee'];
    }

    if (data['date'] is Timestamp) {
      selectedDate = (data['date'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.blue[100],
        title: const Text("Remplir le annonce"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Conducteurhomepage()),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(children: [
              // le titre du formulaire
              Text(
                'Veuillez remplir le  ci-dessous pour chercher un passager',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 100, 100, 100),
                ),
              ),
              const SizedBox(height: 10),

              // le champ de texte pour le nom de conducteur
              TextFormField(
                controller: nomNameController,
                decoration: InputDecoration(
                  labelText: 'Nom conducteur',
                  hintText: 'Entrez votre nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

// le champ de texte pour le prenom de conducteur
              TextFormField(
                controller: prenomNameController,
                decoration: InputDecoration(
                  labelText: 'Prenom de conducteur',
                  hintText: 'Entrez votre prenom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrez votre point de départ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

// le champ de texte pour le némuro de téléphone de conducteur
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Entrez votre numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // le champ de texte pour le point de depart
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner votre point de départ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

// le champ de texte pour le point d'arivée
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner votre point d\'arrivée';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              //le champ de texte pour le date de départ
              DateTimeFormField(
                decoration: const InputDecoration(
                  labelText: 'Date ',
                  hintText: 'Sélectionnez une date',
                  enabledBorder: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                mode: DateTimeFieldPickerMode.date,
                onChanged: (DateTime? value) {
                  setState(() {
                    selectedDate = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // le champ de texte pour le nombre de places disponibles
              TextFormField(
                controller: _placesDisponiblesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de places disponibles',
                  hintText: 'Entrez le nombre de places disponibles',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de places disponibles';
                  } else if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // le champ de texte pour le prix
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Entrez le prix',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  } else if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

// le champ de bouton de formulaire
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Envoi en cours...')),
                      );
                      // Envoi des données à Firestore
                      if (widget.trajetId != null) {
                        // Mise à jour du trajet existant
                        await FirebaseFirestore.instance
                            .collection('trajets')
                            .doc(widget.trajetId)
                            .update({
                          'nom': nomNameController.text,
                          'prenom': prenomNameController.text,
                          'telephone': phoneController.text,
                          'depart': selectedPointDepart,
                          'arrivee': selectedPointArrivee,
                          'date': selectedDate,
                          'places_disponibles':
                              _placesDisponiblesController.text,
                          'prix': _prixController.text,
                        });
                      } else {
                        // Ajout d'un nouveau trajet
                        await FirebaseFirestore.instance
                            .collection('trajets')
                            .add({
                          'nom': nomNameController.text,
                          'prenom': prenomNameController.text,
                          'telephone': phoneController.text,
                          'depart': selectedPointDepart,
                          'arrivee': selectedPointArrivee,
                          'date': selectedDate,
                          'places_disponibles':
                              _placesDisponiblesController.text,
                          'prix': _prixController.text,
                          'conducteurId':
                              FirebaseAuth.instance.currentUser?.uid,
                          'createdAt': Timestamp.now(),
                        });

                        Navigator.pop(context,
                            true); // retourne vers la page précédente avec succès
                      }
                    }
                  },
                  child: const Text('publier Trajet'),
                ),
              ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
      ),
    );
  }
}
