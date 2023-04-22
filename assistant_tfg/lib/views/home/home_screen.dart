import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../widgets/communication_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../themes/theme.dart';
import '../../providers/chats_provider.dart';
import '../../widgets/chat_widget.dart';
import '../../widgets/text_input_widget.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showButtons = true;
  bool _isTyping = false;
  bool _showScrollDownButton = false;
  String? audiopath;
  late TextEditingController textEditingController;
  late ScrollController _scrollController;
  late FocusNode focusNode;
 
void _onAudioRecordingStop(String path) {
  setState(() {
    audiopath = path;
  });
  if (kDebugMode) print('Recorded file path: $audiopath');
  // Luego puedes usar 'audioPath' para pasarlo a tu API.
}


 void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      setState(() {
        _showScrollDownButton = false;
      });
    } else {
      setState(() {
        _showScrollDownButton = true;
      });
    }
  }

  void _toggleChatVisibility() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      drawer: const MenuWidget(),
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Primera sección: lista de mensajes y botón de ir hacia abajo
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: chatProvider.getChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider.getChatList[index].msg,
                      chatIndex: chatProvider.getChatList[index].chatIndex,
                    );
                  },
                ),
                if (_showScrollDownButton)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      backgroundColor: AccentTwo,
                      onPressed: () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      },
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
              ],
            ),
          ),
          if (_isTyping) ...[
            
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            
          ],
          // Segunda sección: botones e input widget
          if (!_showButtons)
            Material(
              color: scaffoldBackgroundColor,
              child: InputWidget(
                focusNode: focusNode,
                textEditingController: textEditingController,
                onSendPressed: () async {
                  await sendMessageFCT(chatProvider: chatProvider);
                },
                onHidePressed: _toggleChatVisibility,
              ),
            )
          else
            CommunicationButtons(
              toggleChatVisibility: _toggleChatVisibility,
              onStop: _onAudioRecordingStop,
              chatProvider: Provider.of<ChatProvider>(context, listen: false),

            ),
        ],
      ),
    );
  }

  Future<void> sendMessageFCT({required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "No puedes mandar más de un mensaje a la vez",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Por favor, escribe un mensaje",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(msg: msg);
      // chatList.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }
}
