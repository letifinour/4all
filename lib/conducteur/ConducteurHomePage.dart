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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Conducteurhomepage extends StatefulWidget {
  const Conducteurhomepage({super.key});

  @override
  _ConducteurhomepageState createState() => _ConducteurhomepageState();
}

//navigation function to go to profile page
void goToProfilePage(BuildContext context) {
  Navigator.pop(context);
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
        title: Text(
          'Espace Conducteur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: Colors.white),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Vos options",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: Duration(milliseconds: 600))
                      .slideY(begin: -0.2, end: 0),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (BuildContext context) => Formpage(
                                  initialData: const {},
                                ),
                              ),
                            );
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Trajet publié avec succès"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Nouvelle annonce",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                                duration: Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 100))
                            .slideX(begin: -0.2, end: 0),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Demandesconducteurpage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Demandes de réservation",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                                duration: Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 200))
                            .slideX(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.car_rental, color: Colors.blue.shade700, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "Mes annonces de trajets",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Chargement de vos trajets...",
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: Lottie.asset(
                              "assets/animations/empty_car.json",
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset("assets/covoiturage.png");
                              },
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 20),
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                'Aucun trajet trouvé',
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            ],
                            isRepeatingAnimation: true,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Créez votre première annonce en cliquant\nsur 'Nouvelle annonce'",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return CarouselSlider.builder(
                    itemCount: snapshot.data!.docs.length,
                    options: CarouselOptions(
                      height: 350,
                      enableInfiniteScroll: snapshot.data!.docs.length > 1,
                      enlargeCenterPage: true,
                      viewportFraction: 0.85,
                      initialPage: 0,
                      autoPlay: snapshot.data!.docs.length > 1,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.blue.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.person,
                                          color: Colors.blue.shade700),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "${data['nom']} ${data['prenom']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                    height: 20,
                                    color: Colors.grey.withOpacity(0.3)),

                                // Trip details
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.directions_car,
                                          color: Colors.green.shade700,
                                          size: 22),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "De: ${data['depart']}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.location_on,
                                          color: Colors.red.shade600, size: 22),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "À: ${data['arrivee']}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.calendar_today,
                                          color: Colors.orange.shade700,
                                          size: 20),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Date: ${data['date']?.toDate()?.toString().split(" ")[0]}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.people,
                                          color: Colors.purple.shade600,
                                          size: 22),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Places: ${data['places_disponibles']}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.attach_money,
                                          color: Colors.green.shade700,
                                          size: 22),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Prix: ${data['prix']} DT",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Spacer(),

                                // Action buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('trajets')
                                              .doc(doc.id)
                                              .delete();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text("Trajet supprimé"),
                                              backgroundColor:
                                                  Colors.red.shade700,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.delete, size: 18),
                                        label: Text("Supprimer",
                                            style: TextStyle(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
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
                                                    "Trajet modifié avec succès"),
                                                backgroundColor:
                                                    Colors.orange.shade800,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text("Modifier",
                                            style: TextStyle(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade600,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: Duration(milliseconds: 500),
                              delay: Duration(milliseconds: 100 * index))
                          .scale(
                              begin: Offset(0.95, 0.95),
                              end: Offset(1, 1),
                              duration: Duration(milliseconds: 500));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
