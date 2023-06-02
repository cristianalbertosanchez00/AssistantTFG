/*import 'package:assistant_tfg/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/conversation_provider.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final conversations = conversationProvider.conversations;

    return Drawer(
      backgroundColor: scaffoldBackgroundColor,
      child: ListView(
        children: conversations.map((conversation) {
          return ListTile(
            title: Text(conversation.lastMessage, style: const TextStyle(color: Colors.white),),
            onTap: () {
              conversationProvider
                  .selectConversation(conversation.conversationId);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
*/