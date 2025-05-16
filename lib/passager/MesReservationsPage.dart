// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add this line

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<Map<String, dynamic>> fetchTrajetDetails(
      String trajetId, String idToken) async {
    try {
      final trajetDoc =
          await _firestore.collection('trajets').doc(trajetId).get();

      if (trajetDoc.exists) {
        final data = trajetDoc.data() as Map<String, dynamic>;

        return {
          'depart': data['depart'] ?? '',
          'arrivee': data['arrivee'] ?? '',
          'prix': data['prix'] ?? 0,
          'dateTrajet': data['date'] != null
              ? (data['date'] as Timestamp).toDate().toIso8601String()
              : '',
        };
      } else {
        print('Trajet non trouvé: $trajetId');
        return {};
      }
    } catch (e) {
      print('Erreur lors de la récupération du trajet: $e');
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("Utilisateur non connecté");

      final reservationsSnapshot =
          await _firestore.collection('reservations').get();
      List<Map<String, dynamic>> loadedReservations = [];

      for (var doc in reservationsSnapshot.docs) {
        final data = doc.data();

        final dateDemande = data['dateDemande'] != null
            ? (data['dateDemande'] as Timestamp).toDate()
            : null;

        final passagerId = data['passager_id'] ?? '';
        final conducteurId = data['conducteurId'] ?? '';
        final trajetId = data['trajetId'] ?? '';

        final trajetDetails =
            await fetchTrajetDetails(trajetId, ''); // idToken no longer needed

        loadedReservations.add({
          'depart': trajetDetails['depart'],
          'arrivee': trajetDetails['arrivee'],
          'prix': trajetDetails['prix'],
          'statut': data['statut'] ?? '',
          'dateDemande': dateDemande?.toString() ?? '',
          'passager_id': passagerId,
          'conducteurId': conducteurId,
        });
      }

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
          otherUserName: 'Conducteur', 
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
