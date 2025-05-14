// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../chatpage.dart'; // Ensure this file exists and contains the ChatPage class

class MesReservationsPage extends StatefulWidget {
  const MesReservationsPage({super.key});

  @override
  State<MesReservationsPage> createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  List<Map<String, dynamic>> reservations = [];
  String getChatId(String user1, String user2) {
    final ids = [user1, user2]..sort();
    return ids.join("_");
  }

  bool isLoading = true;

  final String projectId = 'projet-3d2e8';

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<Map<String, dynamic>> fetchTrajetDetails(
      String trajetId, String idToken) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/trajets/$trajetId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fields = data['fields'];

      return {
        'depart': fields['depart']?['stringValue'] ?? '',
        'arrivee': fields['arrivee']?['stringValue'] ?? '',
        'prix': fields['prix']?['integerValue'] ?? '0',
        'dateTrajet': fields['date']?['timestampValue'] ?? '',
      };
    } else {
      print('Erreur lors de la récupération du trajet : ${response.body}');
      return {};
    }
  }

  String formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  Future<void> fetchReservations() async {
    setState(() => isLoading = true);
    try {
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception("Utilisateur non connecté");

      final url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/reservations';

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $idToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> loadedReservations = [];

        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            final fields = doc['fields'] as Map<String, dynamic>;

            final dateDemande = fields['dateDemande']?['timestampValue'] != null
                ? DateTime.parse(fields['dateDemande']['timestampValue'])
                : null;

            final passagerId = fields['passager_id']?['stringValue'] ?? '';
            final conducteurId = fields['conducteurId']?['stringValue'] ?? '';
            final trajetId = fields['trajetId']?['stringValue'] ?? '';

            final trajetDetails = await fetchTrajetDetails(trajetId, idToken);

            loadedReservations.add({
              'depart': trajetDetails['depart'],
              'arrivee': trajetDetails['arrivee'],
              'prix': trajetDetails['prix'],
              'statut': fields['statut']?['stringValue'] ?? '',
              'dateDemande': dateDemande?.toString() ?? '',
              'passager_id': passagerId,
              'conducteurId': conducteurId,
            });
          }
        }

        final userId = FirebaseAuth.instance.currentUser!.uid;
        final userReservations = loadedReservations
            .where((res) => res['passager_id'] == userId)
            .toList();

        userReservations.sort((a, b) {
          final dateA = DateTime.parse(a['dateDemande']);
          final dateB = DateTime.parse(b['dateDemande']);
          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            reservations = userReservations;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void startChat(String conducteurId) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatId(userId, conducteurId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatId: chatId,
          otherUserName: 'Conducteur', // ou récupérer le vrai nom si tu veux
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Colors.grey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: reservations.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                            child: Text('Aucune réservation trouvée.',
                                style: TextStyle(fontSize: 18))),
                      ],
                    )
                  : ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              'De : ${reservation['depart']} -> à: ${reservation['arrivee']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                    'Date du trajet : ${formatDate(reservation['dateDemande'])}'),
                                Text('prix: ${reservation['prix']} TND'),
                                Text('Statut: ${reservation['statut']}'),
                                // lorsque le statut change "acceptee",alors afficher le bouton de chat
                                if (reservation['statut'] == 'acceptee')
                                  ElevatedButton(
                                    onPressed: () =>
                                        startChat(reservation['conducteurId']),
                                    child: const Text('Démarrer le chat'),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              formatDate(reservation['dateDemande']),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 24, 23, 23)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
