/*mport 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/conversation_model.dart';

class ConversationProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Conversation> _conversations = [];
  String? _selectedConversationId;

  List<Conversation> get conversations => _conversations;
  String? get selectedConversationId => _selectedConversationId;

  Future<void> loadConversations(String userId) async {
    final snapshot = await _firestore
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .get();

    _conversations = snapshot.docs
        .map((doc) => Conversation.fromFirestore(doc.data()))
        .toList();

    notifyListeners();
  }

  void selectConversation(String conversationId) {
    _selectedConversationId = conversationId;
    notifyListeners();
  }
}
*/