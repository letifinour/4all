// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profilepage extends StatefulWidget {
  final Function onPressed;

  const Profilepage({super.key, required this.onPressed});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  Widget buildInfoBox(String text, {TextStyle? style}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }

//user data
  final currentUser = FirebaseAuth.instance.currentUser;

  late final DocumentReference ref;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  final String? userRole =
      FirebaseAuth.instance.currentUser?.providerData[0].providerId;
  final String? userFirstName = FirebaseAuth.instance.currentUser?.displayName;
  final String? userLastName = FirebaseAuth.instance.currentUser?.displayName;
  final String? userPhoneNumber =
      FirebaseAuth.instance.currentUser?.phoneNumber;
  final String? password =
      FirebaseAuth.instance.currentUser?.providerData[0].providerId;

  // edit fields
  Future<void> editField(String fieldName, String newValue) async {
    try {
      await ref.update({fieldName: newValue});
      print("Field $fieldName updated to $newValue");
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    if (userId != null) {
      ref = FirebaseFirestore.instance.collection('users').doc(userId);

      ref.get().then((doc) {
        if (!doc.exists) {
          // Créer automatiquement un profil utilisateur par défaut
          ref.set({
            'firstName': userFirstName ?? 'Prénom',
            'lastName': userLastName ?? 'Nom',
            'phoneNumber': userPhoneNumber ?? 'Non défini',
            'role': 'conducteur', // ou 'passager', selon ta logique
            'email': userEmail,
          });
          print("Document utilisateur créé.");
        } else {
          print("Document utilisateur déjà existant.");
        }
      }).catchError((e) {
        print("Erreur lors de la vérification du document: $e");
      });

      print("Utilisateur actuel : ${FirebaseAuth.instance.currentUser}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.grey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 50),
          // Profile picture
          Icon(
            Icons.person,
            size: 100,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 20),
          // user details
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(
                "MY DETAILS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          StreamBuilder<DocumentSnapshot>(
            stream: ref.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text("No data available"));
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // coins arrondis
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 9.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // email
                          Row(
                            children: [
                              Icon(Icons.email,
                                  color:
                                      const Color.fromARGB(255, 12, 24, 151)),
                              SizedBox(width: 10),
                              buildInfoBox(
                                "Email: ${userData['email'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // boite de dialogue pour modifier l'email
                                  // showDialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      // controller pour le champ de texte
                                      // je peut connait, l'utilisateur ecrit dans le textfield
                                      TextEditingController controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text('Modifier le email'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Entrez un nouveau email"),
                                        ),
                                        actions: [
                                          // button annuler
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Annuler'),
                                          ),
                                          //button enregistrer
                                          TextButton(
                                            onPressed: () {
                                              if (controller.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                editField('email',
                                                    controller.text.trim());
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text('Enregistrer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          //first name
                          Row(
                            children: [
                              Icon(Icons.person,
                                  color:
                                      const Color.fromARGB(255, 14, 117, 17)),
                              SizedBox(width: 10),
                              buildInfoBox(
                                "First Name: ${userData['firstName'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      TextEditingController controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text('Modifier le firstName'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Entrez un nouveau prénom"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (controller.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                editField('firstName',
                                                    controller.text.trim());
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text('Enregistrer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          //last name
                          Row(
                            children: [
                              Icon(Icons.person_2_outlined,
                                  color:
                                      const Color.fromARGB(255, 198, 45, 45)),
                              SizedBox(width: 10),
                              Row(
                                children: [
                                  buildInfoBox(
                                    "Last Name: ${userData['lastName'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          TextEditingController controller =
                                              TextEditingController();
                                          return AlertDialog(
                                            title: Text('Modifier le lastName'),
                                            content: TextField(
                                              controller: controller,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      "Entrez un nouveau prénom"),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (controller.text
                                                      .trim()
                                                      .isNotEmpty) {
                                                    editField('lastName',
                                                        controller.text.trim());
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Enregistrer'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          //phone number
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  color: const Color.fromARGB(255, 0, 0, 0)),
                              SizedBox(width: 10),
                              buildInfoBox(
                                "Phone: ${userData['phone'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      TextEditingController controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text('Modifier le phone'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Entrez un nouveau prénom"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (controller.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                editField('phone',
                                                    controller.text.trim());
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text('Enregistrer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          // user type
                          Row(
                            children: [
                              Icon(Icons.verified_user,
                                  color:
                                      const Color.fromARGB(255, 52, 165, 226)),
                              SizedBox(width: 10),
                              buildInfoBox(
                                "User Type: ${userData['userType'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      TextEditingController controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text('Modifier le prénom'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Entrez un nouveau prénom"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (controller.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                editField('userType',
                                                    controller.text.trim());
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text('Enregistrer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
