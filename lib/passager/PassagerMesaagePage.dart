// ignore_for_file: unused_local_variable, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/chatpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class PassagerMessagesPage extends StatefulWidget {
  final String passagerId;

  const PassagerMessagesPage({super.key, required this.passagerId});

  @override
  State<PassagerMessagesPage> createState() => _PassagerMessagesPageState();
}

class _PassagerMessagesPageState extends State<PassagerMessagesPage> {
  Future<void> updateChat(String chatId, String message) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': message.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

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

    // Get the other user ID (conducteur)
    final List<dynamic> participants = chatData['participants'] ?? [];
    String otherUserId = "inconnu";

    if (participants.isNotEmpty) {
      try {
        otherUserId = participants.firstWhere(
          (id) => id != widget.passagerId,
          orElse: () => "inconnu",
        );
      } catch (e) {
        print("Error finding other user ID: $e");
        // If we can't find otherId using participants, try conducteurId
        otherUserId = chatData['conducteurId'] ?? "inconnu";
      }
    } else {
      // Try alternative fields that might contain user IDs
      otherUserId = chatData['conducteurId'] ?? chatData['userId'] ?? "inconnu";
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
                backgroundColor: Colors.green[100],
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              title: Text("Chargement..."),
              subtitle: Text("Récupération des informations utilisateur"),
            ),
          );
        }

        String otherUserName = "Conducteur";
        String photoUrl = "";

        if (userSnapshot.hasData && userSnapshot.data != null) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            // Get email and remove "@gmail.com" if it exists
            String email = userData['email'] ?? "";
            if (email.contains("@gmail.com")) {
              email = email.replaceAll("@gmail.com", "");
            }

            otherUserName = userData['name'] ?? email ?? "Conducteur";
            photoUrl = userData['photoUrl'] ?? "";
          }
        }

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Hero(
                tag: "avatar_$otherUserId",
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green[100],
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Icon(Icons.person,
                            size: 32, color: Colors.green.shade600)
                        : null,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    otherUserName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.verified_user,
                    size: 14,
                    color: Colors.green,
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatData['lastMessage'] ?? "Conversation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.green.shade700,
                ),
              ),
              onTap: () {
                // Use the existing chat ID
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Debug print to check what passagerId is being used
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes messages"),
        backgroundColor: Colors.green,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: currentUser == null
          ? Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Veuillez vous connecter pour voir vos messages',
                    textStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    speed: Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mark_chat_unread,
                          color: Colors.green.shade700, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Mes discussions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.green.shade800,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: Duration(milliseconds: 600))
                          .slide(
                              begin: Offset(0, -0.2),
                              duration: Duration(milliseconds: 600)),
                    ],
                  ),
                ),
                // Regular chats from Firestore query
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('participants', arrayContains: widget.passagerId)
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
                              Lottie.network(
                                'https://assets6.lottiefiles.com/packages/lf20_KUFmbe.json',
                                width: 200,
                                height: 200,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Aucune discussion pour le moment",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700]),
                              )
                                  .animate()
                                  .fadeIn(duration: Duration(milliseconds: 800))
                                  .slideY(begin: 0.2, end: 0),
                              SizedBox(height: 15),
                              Text(
                                "Vos conversations apparaîtront ici",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return buildChatItem(context, chat)
                              .animate()
                              .fadeIn(
                                duration: Duration(milliseconds: 400),
                                delay: Duration(milliseconds: 50 * index),
                              )
                              .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeOutQuad,
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // You could implement functionality to start a new chat here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fonctionnalité à venir: Nouveau message'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          backgroundColor: Colors.green,
          elevation: 0,
          label: Text("Nouveau message"),
          icon: Icon(Icons.chat),
        ),
      )
          .animate()
          .scale(
              begin: Offset(0.5, 0.5),
              end: Offset(1.0, 1.0),
              duration: Duration(milliseconds: 500))
          .then(delay: Duration(milliseconds: 200))
          .shimmer(
              duration: Duration(milliseconds: 1200), color: Colors.white24),
    );
  }
}
