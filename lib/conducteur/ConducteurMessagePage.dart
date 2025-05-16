// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/chatpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConducteurMessagesPage extends StatelessWidget {
  final String conducteurId;

  Future<void> updateChat(String chatId, String lastMessage) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': lastMessage.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  const ConducteurMessagesPage({super.key, required this.conducteurId});

  // Format timestamp for displaying last message time
  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Build a chat item widget
  Widget buildChatItem(BuildContext context, DocumentSnapshot chat) {
    final Map<String, dynamic> chatData = chat.data() as Map<String, dynamic>;

    // Get the other user ID (passager)
    final List<dynamic> participants = chatData['participants'] ?? [];
    String otherUserId = "inconnu";

    if (participants.isNotEmpty) {
      try {
        otherUserId = participants.firstWhere(
          (id) => id != conducteurId,
          orElse: () => "inconnu",
        );
      } catch (e) {
        print("Error finding other user ID: $e");
        // If we can't find otherId using participants, try passagerId
        otherUserId = chatData['passagerId'] ?? "inconnu";
      }
    } else {
      // Try alternative fields that might contain user IDs
      otherUserId = chatData['passagerId'] ?? chatData['userId'] ?? "inconnu";
    }

    // Format timestamp
    final Timestamp? timestamp = chatData['lastTimestamp'] as Timestamp?;
    final String timeText =
        timestamp != null ? _formatTimestamp(timestamp.toDate()) : '';

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        // If we're still loading user data
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue[100],
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              title: Text("Chargement..."),
              subtitle: Text("Récupération des informations utilisateur"),
            ),
          );
        }

        String otherUserName = "Passager";
        String photoUrl = "";

        if (userSnapshot.hasData && userSnapshot.data != null) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            // Get email and remove "@gmail.com" if it exists
            String email = userData['email'] ?? "";
            if (email.contains("@gmail.com")) {
              email = email.replaceAll("@gmail.com", "");
            }

            otherUserName = userData['name'] ?? email ?? "Passager";
            photoUrl = userData['photoUrl'] ?? "";
          }
        }

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue[100],
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Icon(Icons.person, size: 30, color: Colors.blue)
                  : null,
            ),
            title: Text(
              otherUserName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  chatData['lastMessage'] ?? "Conversation",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Use the existing chat ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    chatId: chat.id,
                    otherUserName: "Passager",
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Debug print to check what conducteurId is being used
    print("Conducteur ID used for query: $conducteurId");

    return Scaffold(
      appBar: AppBar(
        title: Text("Mes messages"),
        backgroundColor: Colors.blue,
      ),
      body: currentUser == null
          ? Center(
              child: Text("Veuillez vous connecter pour voir vos messages"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Mes discussions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                // Regular chats from Firestore query
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
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

                      // Debug: Print chat document IDs and content to understand structure
                      print("Nombre de discussions: ${chats.length}");
                      for (var doc in chats) {
                        print("Chat ID: ${doc.id}");
                        print("Chat data: ${doc.data()}");
                      }

                      if (chats.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 70, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                "Aucune discussion pour le moment",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final Map<String, dynamic> chatData =
                              chat.data() as Map<String, dynamic>;

                          // Skip chats with ID that matches our hardcoded chat to avoid duplicates
                          if (chat.id ==
                              "1qsA2sTpYTQQpgmj8K8HZpBLee92_xjalbGufksVx4QXyXOPDti3zWKI2") {
                            // Don't skip - show the actual chat from Firestore instead
                            // We'll remove the hardcoded entry later
                            return buildChatItem(context, chat);
                          }

                          return buildChatItem(context, chat);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You could implement functionality to start a new chat here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fonctionnalité à venir: Nouveau message')),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.chat),
      ),
    );
  }
}
