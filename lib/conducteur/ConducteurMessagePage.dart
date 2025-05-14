// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/chatpage.dart';

class ConducteurMessagesPage extends StatelessWidget {
  final String conducteurId;
  Future<void> updateChat(String chatId, String lastMessage) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': lastMessage.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  const ConducteurMessagesPage({super.key, required this.conducteurId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mes messages")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: conducteurId)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(child: Text("Aucune discussion pour le moment."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat['passagerId'];
              final otherUserName =
                  "Passager"; // à remplacer par nom réel si dispo
              return ListTile(
                title: Text("Avec $otherUserName"),
                subtitle: Text(chat['lastMessage'] ?? ""),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chat.id,
                        otherUserName: otherUserName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
