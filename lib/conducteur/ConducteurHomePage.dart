// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_3/profile/MyDrawer.dart';
import 'package:flutter_application_3/profile/ProfilePage.dart';
import 'package:flutter_application_3/conducteur/ConducteurMessagePage.dart';
import 'package:flutter_application_3/conducteur/DemandesConducteurPage.dart';
import 'package:flutter_application_3/conducteur/Formpage.dart';
import 'package:flutter_application_3/Login/signup/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Conducteurhomepage extends StatefulWidget {
  const Conducteurhomepage({super.key});

  @override
  _ConducteurhomepageState createState() => _ConducteurhomepageState();
}

class FormsPage extends StatelessWidget {
  final String? trajetId;
  final Map<String, dynamic>? initialData;

  const FormsPage({super.key, this.trajetId, this.initialData});

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//navigation function to go to profile page
void goToProfilePage(BuildContext context) {
  Navigator.pop(context);
//go to profile page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Profilepage(onPressed: () {})),
  );
}

class _ConducteurhomepageState extends State<Conducteurhomepage> {
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Mydrawer(
          onProfileTap: () => goToProfilePage(context),
          onLogoutTap: () => signOut(context)),
      appBar: AppBar(
        title: Text('Conducteur Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            tooltip: 'Mes messages',
            onPressed: () {
              final conducteurId = FirebaseAuth.instance.currentUser!.uid;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ConducteurMessagesPage(conducteurId: conducteurId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            // le bouton pour remplir les annonces
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                      builder: (BuildContext context) => Formpage(
                            initialData: const {},
                          )),
                );
                // Vérifiez si le résultat est vrai avant d'afficher le message de succès
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Trajet publié avec succès")),
                  );
                }
              },
              // sinon il va afficher le message d'erreur
              child: Text("Remplir les annonces"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Demandesconducteurpage(),
                  ),
                );
              },
              child: Text("les demandes de réservation"),
            ),
          ),
          Expanded(
            // le bouton pour afficher les annonces
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('trajets')
                      .where('conducteurId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun trajet trouvé.'));
                }
                Text(
                  "Mes annonces",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                );
                return ListView(
                  padding: EdgeInsets.all(10),
                  children: snapshot.data!.docs.map(
                    (doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      // Affichage des informations du trajet
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text(
                                      "Conducteur : ${data['nom']} ${data['prenom']}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  SizedBox(height: 10),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.directions_car,
                                      color: Colors.green),
                                  SizedBox(width: 10),
                                  Text("Départ : ${data['depart']}",
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text("Arrivée : ${data['arrivee']}",
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.orange),
                                  SizedBox(width: 10),
                                  Text(
                                      "Date : ${data['date']?.toDate()?.toString().split(" ")[0]}",
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people, color: Colors.purple),
                                  SizedBox(width: 10),
                                  Text(
                                      "Places disponibles : ${data['places_disponibles']}",
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text("Tarif : ${data['prix']} DT",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green[700])),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // le bouton pour supprimer les annonces
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('trajets')
                                          .doc(doc.id)
                                          .delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text("Trajet supprimé")),
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                    label: Text("Supprimer"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // le bouton pour modifier les annonces
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Formpage(
                                            trajetId: doc.id,
                                            initialData: data,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Trajet modifié avec succès")),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.edit),
                                    label: Text("Modifier"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
