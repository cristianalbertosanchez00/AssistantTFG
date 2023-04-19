import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../themes/theme.dart';
import '../../providers/chats_provider.dart';
import '../../services/assets_manager.dart';
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
  bool _showChat = false;
  bool _showButtons = true;
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  void _toggleChatVisibility() {
    setState(() {
      _showButtons = !_showButtons;
      _showChat = !_showChat;
    });
  }

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
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
      body: Stack(
        children: [
          // Aquí va el contenido de ChatScreen
          Visibility(
            visible: _showChat,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        controller: _listScrollController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: chatProvider.getChatList.length,
                              itemBuilder: (context, index) {
                                return ChatWidget(
                                  msg: chatProvider.getChatList[index].msg,
                                  chatIndex:
                                      chatProvider.getChatList[index].chatIndex,
                                  shouldAnimate:
                                      chatProvider.getChatList.length - 1 ==
                                          index,
                                );
                              }),
                        ),
                      );
                    },
                  ),
                ),
                if (_isTyping) ...[
                  const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 18,
                  ),
                ],
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Material(
                      color: scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputWidget(
                          focusNode: focusNode,
                          textEditingController: textEditingController,
                          onSendPressed: () async {
                            await sendMessageFCT(chatProvider: chatProvider);
                          },
                          onHidePressed: _toggleChatVisibility,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Agrega los botones en la parte inferior
          Visibility(
            visible: _showButtons,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        // Implementa la función de la cámara
                      },
                    ),
                    const SizedBox(width: 50.0),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.greenAccent,
                            Colors.purpleAccent,
                          ],
                        ),
                      ),
                      child: IconButton(
                        iconSize: 60,
                        icon:
                            const Icon(Icons.mic_outlined, color: Colors.white),
                        onPressed: () {
                          // Implementa la función del micrófono
                        },
                      ),
                    ),
                    const SizedBox(width: 50.0),
                    IconButton(
                      icon: const Icon(Icons.keyboard, color: Colors.white),
                      iconSize: 30,
                      onPressed: _toggleChatVisibility,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
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
      setState(() {
        scrollListToEND();
      });
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
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
