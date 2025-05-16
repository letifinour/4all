import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_3/profile/ProfilePage.dart';
import 'package:flutter_application_3/conducteur/ConducteurHomePage.dart';
import 'package:flutter_application_3/conducteur/Formpage.dart';
import 'package:flutter_application_3/passager/search.dart';
import 'Login/signup/login.dart';
import 'Login/signup/welcome.dart';

import 'passager/PassagerHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

final user = FirebaseAuth.instance.currentUser;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomePage() 
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        // '/chat': (context) => Geminichatbot(),
        '/search': (context) => SearchPage(),
        '/forms': (context) => Formpage(
              initialData: {},
            ),
        '/ConducteurHomePage': (context) => Conducteurhomepage(),
        '/PassagerHomePage': (context) => Passagerhomepage(),
      },
    );
  }
}
