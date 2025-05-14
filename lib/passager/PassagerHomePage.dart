// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_3/profile/MyDrawer.dart';
import 'package:flutter_application_3/profile/ProfilePage.dart';
import 'package:flutter_application_3/passager/MesReservationsPage.dart';
import 'package:flutter_application_3/passager/PassagerMesaagePage.dart';
import 'package:flutter_application_3/passager/search.dart';
import 'package:flutter_application_3/Login/signup/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Passagerhomepage extends StatefulWidget {
  const Passagerhomepage({super.key});

  @override
  State<Passagerhomepage> createState() => _PassagerhomepageState();
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

class _PassagerhomepageState extends State<Passagerhomepage> {
 
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Mydrawer(
        onProfileTap: () => goToProfilePage(context),
        onLogoutTap: signOut,
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PassagerMessagesPage(
                        passagerId: FirebaseAuth.instance.currentUser!.uid)),
              );
            },
          ),
        ],
        backgroundColor: Colors.grey,
        title: Text('Passager Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
            ),
            Text(
              'Welcome to the Passager Home Page!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 240, 74, 74),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'You can search for rides here.',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 98, 99, 99),
              ),
            ),
            Icon(
              Icons.arrow_downward,
              color: const Color.fromARGB(255, 79, 79, 79),
              size: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                backgroundColor: const Color.fromARGB(255, 166, 166, 166),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: Text('Go to Search Page'),
            ),
            SizedBox(height: 20),
            Text(
              'Available Rides:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('trajets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun trajet disponible.'));
                }

                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final trajetId = doc.id;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Départ : ${data['depart']}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text("Arrivée : ${data['arrivee']}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "Date : ${data['date']?.toDate()?.toString().split(" ")[0]}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "Places disponibles : ${data['places_disponibles']}",
                                  style: TextStyle(fontSize: 16)),
                              Text("Prix : ${data['prix']} DT",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),

                              // reservation button
                              ElevatedButton(
                                onPressed: () async {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (currentUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Erreur : utilisateur non connecté!'),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('reservations')
                                        .add({
                                      'trajetId': trajetId,
                                      'passager_id': currentUser.uid,
                                      'conducteurId': data['conducteurId'],
                                      'dateDemande': Timestamp.now(),
                                      'statut': 'en_attente',
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Réservation envoyée avec succès !')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Erreur lors de la réservation : $e')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Réserver'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MesReservationsPage()),
                );
              },
              icon: Icon(Icons.bookmark, color: Colors.white),
              label: Text(
                'Mes Réservations',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5),
            ),
          ],
        ),
      ),
    );
  }
}
