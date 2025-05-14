// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Demandesconducteurpage extends StatefulWidget {
  const Demandesconducteurpage({super.key});

  @override
  State<Demandesconducteurpage> createState() => _DemandesconducteurpageState();
}

class _DemandesconducteurpageState extends State<Demandesconducteurpage> {
  final String projectId = 'projet-3d2e8';
  List<Map<String, dynamic>> demandes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<Map<String, dynamic>> fetchTrajetDetails(
      String trajetId, String idToken) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/trajets/$trajetId';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $idToken',
    });

    if (response.statusCode == 200) {
      print("response: ${response.body}");
      final data = json.decode(response.body);
      final fields = data['fields'];

      return {
        'depart': fields['depart']?['stringValue'] ?? '',
        'arrivee': fields['arrivee']?['stringValue'] ?? '',
        'date': fields['date']?['timestampValue'] ?? '',
        'prix': fields['prix']?['integerValue'] ?? '0',
      };
    } else {
      print("Erreur trajet: ${response.body}");
      return {};
    }
  }

  String formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> fetchReservations() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final conducteurId = user?.uid;

      final url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/reservations';

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $idToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> loaded = [];

        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            final fields = doc['fields'];
            final statut = fields['statut']?['stringValue'] ?? '';
            final conducteur = fields['conducteurId']?['stringValue'] ?? '';

            if (statut == 'en_attente' && conducteur == conducteurId) {
              final trajetId = fields['trajetId']?['stringValue'] ?? '';
              final trajetDetails =
                  await fetchTrajetDetails(trajetId, idToken!);

              loaded.add({
                'id': doc['name'].split('/').last,
                'passengerName': fields['passengerName']?['stringValue'] ?? '',
                'statut': statut,
                'trajet': trajetDetails,
              });
            }
          }
        }

        if (mounted) {
          setState(() {
            demandes = loaded;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Erreur: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateStatut(String id, String statut) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/reservations/$id?updateMask.fieldPaths=statut';

    final body = json.encode({
      "fields": {
        "statut": {"stringValue": statut}
      }
    });

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print("response: ${response.body}");

    if (response.statusCode == 200) {
      fetchReservations();
    } else {
      print("Erreur de mise à jour : ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes des Réservations'),
        backgroundColor: Colors.grey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : demandes.isEmpty
              ? const Center(child: Text("Aucune demande trouvée."))
              : ListView.builder(
                  itemCount: demandes.length,
                  itemBuilder: (context, index) {
                    final demande = demandes[index];
                    final trajet = demande['trajet'];
// l'affichage de la carte
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          "Demande de ${demande['passengerId'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "De : ${trajet['depart']} -> à : ${trajet['arrivee']}"),
                            Text(
                                "Date : ${trajet != null && trajet['date'] != null ? formatDate(trajet['date']) : 'Date non disponible'}"),
                            Text("Prix : ${trajet['prix']} TND"),
                            Text("Statut : ${demande['statut']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                print(demande['id']);
                                print(demande['passengerId']);
                                updateStatut(demande['id'], 'acceptee');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                updateStatut(demande['id'], 'Refuser');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
