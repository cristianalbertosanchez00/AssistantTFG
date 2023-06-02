/*import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String conversationId;
  final String lastMessage;
  final DateTime lastActivity;

  Conversation({
    required this.conversationId,
    required this.lastMessage,
    required this.lastActivity,
  });

  factory Conversation.fromFirestore(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'],
      lastMessage: json['lastMessage'],
      lastActivity: (json['lastActivity'] as Timestamp).toDate(),
    );
  }
}*/
