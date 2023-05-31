import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import 'package:uuid/uuid.dart';

final CollectionReference conversationsRef =
    FirebaseFirestore.instance.collection('conversaciones');

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  void Function()? onNewMessageReceived;
  ChatProvider({this.onNewMessageReceived});
  String? currentConversationId;
  int messageCount = 0;
  Future<void> loadLastConversationOrStartNew(String userId) async {
    try {
      QuerySnapshot conversationsSnapshot = await conversationsRef
          .where('userId', isEqualTo: userId)
          .orderBy('lastActivity', descending: true)
          .limit(1)
          .get();

      if (conversationsSnapshot.docs.isNotEmpty) {
        // Existe una última conversación, úsala
        DocumentSnapshot lastConversation = conversationsSnapshot.docs.first;
        currentConversationId = lastConversation.id;

        // Carga los mensajes de esta conversación en chatList
        chatList.clear();
        List messages = lastConversation['mensajes'];
        for (var message in messages) {
          int chatIndex = message['emisor'] == 'usuario' ? 0 : 1;
          chatList
              .add(ChatModel(msg: message['mensaje'], chatIndex: chatIndex));
        }
      } else {
        // No existe una última conversación, crea una nueva
        await createNewConversation(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar la última conversación o iniciar una nueva: $e');
      }
      rethrow;
    }
  }

  Future<void> loadConversation(String userId, String conversationId) async {
    try {
      // Obtiene el documento de la conversación
      DocumentSnapshot conversationSnapshot =
          await conversationsRef.doc(conversationId).get();

      if (conversationSnapshot.exists) {
        // La conversación existe, carga los mensajes
        currentConversationId = conversationId;
        chatList.clear();
        List messages = conversationSnapshot['mensajes'];
        for (var message in messages) {
          int chatIndex = message['emisor'] == 'usuario' ? 0 : 1;
          chatList
              .add(ChatModel(msg: message['mensaje'], chatIndex: chatIndex));
        }
      } else {
        // La conversación no existe, deberías manejar este caso
        // por ejemplo puedes crear una nueva conversación
        await createNewConversation(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar la conversación: $e');
      }
      rethrow;
    }
  }

Future<String> createNewConversation(String userId) async {
    try {
      // Genera un nuevo ID de conversación
      var newConversationId = const Uuid().v4();

      // Almacena el nuevo ID de conversación en Firestore
      await conversationsRef.doc(newConversationId).set({
        'userId': userId,
        'mensajes': [],
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // Guarda el nuevo ID de conversación y reinicia el contador de mensajes
      currentConversationId = newConversationId;
      messageCount = 0;

      // Devuelve el nuevo ID de conversación
      return newConversationId;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear una nueva conversación: $e');
      }
      rethrow;
    }
}

void clearChatList() {
  // Limpia la lista de mensajes actuales
  getChatList.clear();
}



  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String conversationId}) async {
    try {
      // Envía el mensaje y recibe las respuestas
      // Envía el mensaje y recibe las respuestas
      List<ChatModel> apiResponses =
          await ApiService.sendMessageGPT(message: msg);

// Agrega los mensajes de la API a la lista de chat
      chatList.addAll(apiResponses);

// Obtiene la referencia al documento de la conversación
      final DocumentReference conversationDoc =
          conversationsRef.doc(conversationId);

// Agrega el mensaje del usuario a Firestore
      await conversationDoc.update({
        'mensajes': FieldValue.arrayUnion([
          {
            'id': chatList.length,
            'emisor': 'usuario',
            'mensaje': msg,
            'timestamp': Timestamp.now(),
          },
        ]),
        'lastActivity': FieldValue.serverTimestamp(),
      });

// Prepara los datos para Firestore
      List<Map<String, dynamic>> firestoreMessages = apiResponses
          .map((response) => {
                'id': chatList.length,
                'emisor': 'chatbot',
                'mensaje': response.msg,
                'timestamp': Timestamp.now(),
              })
          .toList();

// Agrega todos los mensajes de la API a Firestore a la vez
      await conversationDoc.update({
        'mensajes': FieldValue.arrayUnion(firestoreMessages),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      onNewMessageReceived!();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar el mensaje y recibir las respuestas: $e');
      }
      rethrow;
    }
  }
}
